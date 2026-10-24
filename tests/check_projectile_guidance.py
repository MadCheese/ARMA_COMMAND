"""Source boundaries and independent steering-math properties; no SQF/Arma execution."""

from math import acos, cos, degrees, isclose, radians, sin, sqrt
from pathlib import Path
import random
import re

from check_heli_overwatch_missile_control import delimiters, head, section


ROOT = Path(__file__).resolve().parents[1]
BASE = "b8bc47a"
WP = "A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf"
HELPER = "A3C_CORE/ai_shared/functions/fnc_guideProjectileMissile.sqf"
REMOTE = "A3C_CORE/ai_shared/functions/fnc_orderRemoteLaunch.sqf"


def dot(a, b):
    return sum(x * y for x, y in zip(a, b))


def unit(a):
    magnitude = sqrt(dot(a, a))
    return tuple(x / magnitude for x in a)


def angle(a, b):
    return degrees(acos(max(-1, min(1, dot(a, b)))))


def turn(a, b, limit):
    """Double-precision reference of the bounded great-circle construction."""
    product = max(-1, min(1, dot(a, b)))
    if angle(a, b) <= limit:
        return b
    tangent = tuple(y - x * product for x, y in zip(a, b))
    if sqrt(dot(tangent, tangent)) < 0.000001:
        reference = (0, 0, 1) if abs(a[2]) < 0.9 else (1, 0, 0)
        tangent = tuple(y - x * dot(reference, a) for x, y in zip(a, reference))
    tangent = unit(tangent)
    return unit(tuple(x * cos(radians(limit)) + y * sin(radians(limit)) for x, y in zip(a, tangent)))


def run():
    wp = (ROOT / WP).read_text(encoding="utf-8")
    helper = (ROOT / HELPER).read_text(encoding="utf-8")
    old_wp, old_helper = head(WP, BASE), head(HELPER, BASE)
    for source in (wp, helper):
        delimiters(source)
    print("PASS: edited SQF strings/comments/delimiters")

    # A whole-file boundary comparison protects target selection, firing,
    # reservations, quarantine, assessment, cannon guidance and laser lifecycle.
    start, end = "private _startGuidance = {", '_request set ["handoff",true]'
    assert wp[:wp.index(start)] == old_wp[:old_wp.index(start)]
    assert wp[wp.index(end):] == old_wp[old_wp.index(end):]
    assert (ROOT / REMOTE).read_text(encoding="utf-8") == head(REMOTE, BASE)
    print("PASS: only missile receiver/dispatch changed in Overwatch; remote-launch source unchanged")

    receiver = section(wp, start, end)
    native = section(receiver, "private _guidanceOwner", "// Native flights never")
    assert 'if (_target isKindOf "Air") then' not in native
    assert native.index('case (_aceConfigured)') < native.index('setMissileTarget _x')
    assert native.index('_candidates pushBack _target') < native.index('_candidates pushBack _laser')
    assert '_nativeAccepted = _assigned && {_verifiedTarget isEqualTo _x}' in native
    assert 'if (_nativeAccepted) exitWith {}' in native
    assert 'else {getNumber (_ammoCfg >> "irLock") == 1}' in native
    assert 'else {getNumber (_ammoCfg >> "laserLock") == 1}' in native
    assert native.count('if (isClass _sensorManager)') == 2
    assert '(attachedTo _laser) isEqualTo _target' in native
    assert '"LaserSensorComponent"' in native
    assert re.findall(r'\bsetMissileTarget\s+([^;]+);', delimiters(native)[0]) == ['_x']
    assert receiver.count('_request getOrDefault ["laser",objNull]') == 2
    assert receiver.index('if (_guidanceOwner != "") exitWith') < receiver.index('call A3C_ai_shared_fnc_guideProjectileMissile')
    print("PASS: ordinary native object-first/attached-laser acquisition, verified acceptance, ACE/existing-owner exit")

    # Fixed point, proxy-following, OVERFLY height and terminal policies retain
    # their original implementation. Do not grant launch speed or new physics.
    aim_start, aim_end = "private _fixedAimASL", "private _offset"
    aim = section(helper, aim_start, aim_end)
    aim = re.sub(r'^\s*if \(!\(_targetPosASL isEqualTypeArray.*?\n', '\n', aim, flags=re.M)
    assert aim.rstrip() == section(old_helper, aim_start, aim_end).rstrip()
    assert 'private _handoff = ((diag_deltaTime * 3) max 0.035) min 0.10;' in helper
    assert 'if (_currentSpeed <= 0.001) exitWith {_continue = true;};' in helper
    assert 'if (!_first && {(_offset vectorDotProduct _velocity) <= 0})' in helper
    assert 'if (!_first && {_policy == "DIRECT"} && {_distance / _currentSpeed <= _handoff})' in helper
    assert '_continue = !(_policy == "DIRECT" && {_distance / _currentSpeed <= _handoff});' in helper
    masked, _ = delimiters(helper)
    assert len(re.findall(r'\bspawn\b', masked)) == 1
    assert len(re.findall(r'\baddEventHandler\b', masked)) == 1
    for forbidden in ('remoteExec', 'createVehicle', 'deleteVehicle', 'setPos', 'setDamage', 'setShotParents'):
        assert forbidden not in masked
    assert helper.index('case (!local _projectile)') < helper.index('setVariable ["A3C_Guidance_Started", true]')
    assert helper.index('case (_aceLoaded') < helper.index('setVariable ["A3C_Guidance_Started", true]')
    assert helper.count('setVariable ["A3C_Guidance_Started", true]') == 1
    assert 'ALREADY_CLAIMED' in helper and 'LOCALITY_LOST' in helper and 'HIT_OR_RELEASED' in helper
    assert 'sleep 0.05' in helper and 'sleep 0.01' not in helper
    assert '(_now - (_state get "lastTime")) max 0' in helper
    assert '_elapsed min 0.10' in helper
    assert helper.count('90 * _dt] call _turnTowards') == 2
    assert '(_turnAngle max _facingAngle) > 0.05' in helper
    assert 'setVelocity (_direction vectorMultiply _currentSpeed)' in helper
    assert len(re.findall(r'\bdiag_log\b', masked)) == 3  # reject/start/stop only
    print("PASS: single local worker, permanent claim, release/handoff/aim policies, speed preservation, bounded diagnostics")

    # These properties exercise numerical failure modes (opposite vectors,
    # poles, tiny errors, frame stalls and irregular timing), rather than merely
    # restating expected coordinates. They do not establish SQF float precision.
    rng = random.Random(98317)
    pairs = [((0, 1, 0), (0, -1, 0)), ((0, 0, 1), (0, 0, -1)),
             ((0, 1, 0), unit((0.0000001, 1, 0))), ((0, 1, 0), (0, 1, 0))]
    pairs += [(unit(tuple(rng.uniform(-1, 1) for _ in range(3))),
               unit(tuple(rng.uniform(-1, 1) for _ in range(3)))) for _ in range(2000)]
    for a, b in pairs:
        for dt in (0, 0.001, 0.0167, 0.05, 0.083, 0.1, 0.8):
            limit = 90 * min(dt, 0.1)
            result = turn(a, b, limit)
            assert all(abs(x) <= 1.00000001 for x in result)
            assert isclose(dot(result, result), 1, abs_tol=1e-10)
            assert angle(a, result) <= limit + 0.00001
            assert angle(result, b) <= angle(a, b) + 0.00001
            speed = rng.uniform(0.01, 1800)
            velocity = tuple(x * speed for x in result)
            assert isclose(sqrt(dot(velocity, velocity)), speed, rel_tol=1e-12)
    # Equal elapsed time gives equal turns when neither run hits the stall cap.
    a, b = (0, 1, 0), (1, 0, 0)
    regular, irregular = a, a
    for dt in [0.05] * 10:
        regular = turn(regular, b, 90 * dt)
    for dt in [0.02, 0.08, 0.03, 0.07, 0.1, 0.1, 0.1]:
        irregular = turn(irregular, b, 90 * dt)
    assert angle(regular, irregular) < 0.00001
    assert isclose(angle(a, regular), 45, abs_tol=1e-8)
    assert isclose(angle(a, turn(a, b, 90 * min(0.8, 0.1))), 9, abs_tol=1e-8)
    print("PASS: 14,028 reference-math cases: turn bounds, speed, antiparallel/poles, cadence independence, stall cap")
    doc = (ROOT / "docs/heli-overwatch-projectile-guidance-validation.md").read_text(encoding="utf-8")
    blocks = re.findall(r"```sqf\s*\n(.*?)```", doc, re.S)
    for block in blocks:
        delimiters(block)
    print(f"PASS: {len(blocks)} documentation SQF blocks have balanced strings/comments/delimiters")
    print("No SQF compiler/runtime, collision, hit-reliability or multiplayer visual result is established.")


if __name__ == "__main__":
    run()
