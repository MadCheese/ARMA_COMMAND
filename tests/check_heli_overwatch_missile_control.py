"""Static SQF/state-transition contracts. Does not emulate Arma or execute SQF."""

from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]
WAYPOINT = "A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf"
SELECTOR = "A3C_CORE/main/functions/fnc_selectHeliOverwatchTarget.sqf"
BASELINE = "f981344"  # Pre-Phase-2 source, including working acquisition/guidance/Phase 1.


def mask_literals(source):
    """Keep offsets/newlines while masking SQF comments and escaped strings."""
    result = list(source)
    index = 0
    while index < len(source):
        start = index
        if source.startswith("//", index):
            stop = source.find("\n", index)
            index = len(source) if stop < 0 else stop
        elif source.startswith("/*", index):
            stop = source.find("*/", index + 2)
            assert stop >= 0, "Unclosed comment"
            index = stop + 2
        elif source[index] in "\"'":
            quote = source[index]
            index += 1
            while index < len(source):
                if source[index] == quote:
                    if index + 1 < len(source) and source[index + 1] == quote:
                        index += 2
                        continue
                    index += 1
                    break
                index += 1
            else:
                raise AssertionError("Unclosed SQF string")
        else:
            index += 1
            continue
        for offset in range(start, index):
            if source[offset] != "\n":
                result[offset] = " "
    return "".join(result)


def delimiters(source):
    masked = mask_literals(source)
    stack, pairs = [], {}
    for index, char in enumerate(masked):
        if char in "([{":
            stack.append((char, index))
        elif char in ")]}":
            assert stack and stack[-1][0] == {")": "(", "]": "[", "}": "{"}[char], (
                "Mismatched SQF delimiter", source.count("\n", 0, index) + 1
            )
            _, opening = stack.pop()
            pairs[opening] = index
    assert not stack, "Unclosed SQF delimiter"
    return masked, pairs


def section(source, start, end):
    opening = source.index(start)
    return source[opening:source.index(end, opening)]


def head(path):
    return subprocess.check_output(
        ["git", "-c", f"safe.directory={ROOT.as_posix()}", "show", f"{BASELINE}:{path}"],
        cwd=ROOT, text=True, encoding="utf-8",
    )


def run():
    wp = (ROOT / WAYPOINT).read_text(encoding="utf-8")
    selector = (ROOT / SELECTOR).read_text(encoding="utf-8")
    masked, pairs = delimiters(wp)
    delimiters(selector)
    print("PASS: both SQF sources have balanced strings, comments and delimiters")

    old_wp, old_selector = head(WAYPOINT), head(SELECTOR)
    prefix = wp[:wp.index('// Session-private safety bookkeeping')]
    prefix = prefix.replace('\t_session set ["missileFlights",[]];\n', '')
    prefix = prefix.replace('["missileFlight",createHashMap],["missileFlights",[]],', '["missileFlight",createHashMap],')
    assert prefix.rstrip() == old_wp[:old_wp.index('// Run on engagement boundaries')].rstrip()
    assert wp[wp.index('// No live ammo, no executable mode'): ] == old_wp[old_wp.index('// No live ammo, no executable mode'): ]
    for command in ['spawn', 'addEventHandler', 'addMissionEventHandler', 'enableAIFeature', 'flyInHeight', 'limitSpeed']:
        assert len(re.findall(r'\b' + command + r'\b', masked, re.I)) == len(re.findall(r'\b' + command + r'\b', mask_literals(old_wp), re.I)), command
    for start, end in [
        ('private _startGuidance = {', '_request set ["handoff",true]'),
        ('if (_kind == "GUN") exitWith {', 'if ((_request get "shots") > 1) exitWith'),
        ('private _clearAim = {', '// Confirmed flights reserve only'),
    ]:
        old_end = '// Preemption may rotate/aim at B' if end.startswith('// Confirmed') else end
        assert section(wp, start, end).rstrip() == section(old_wp, start, old_end).rstrip(), start
    assert section(selector, 'private _knowledgeGroup', '    private _missileHeld =') == section(
        old_selector, 'private _knowledgeGroup', '    private _method ='
    )
    assert section(selector, '    // Detection is unchanged;', '    private _row =') == section(
        old_selector, '    // Detection is unchanged;', '    private _row ='
    )
    assert selector[selector.index('    _rows pushBack _row;'):] == old_selector[old_selector.index('    _rows pushBack _row;'):]
    assert section(wp, '// Final AIR authorization,', 'if (_method == "MISSILE" && {(([_target]') == section(
        old_wp, '// Final AIR authorization,', 'if (_method == "MISSILE") then {'
    )
    print("PASS: native/ACE/fallback guidance, gun guidance, aiming/rotation, acquisition, Phase 1 and ranking/retention preserved")

    # Transition contracts are checked on production source, not a second ledger implementation.
    maintenance = section(wp, 'private _maintainMissileFlights = {', '// Run on engagement boundaries')
    assert 'isNil {' in maintenance and 'if !(call _current) exitWith {};' in maintenance
    termination = section(maintenance, 'if ((_flight get "state") == "FLIGHT" &&', 'if ((_flight get "state") == "FLIGHT")')
    assert '!(_flight getOrDefault ["unknown",false])' in termination
    assert '_projectiles findIf {!isNull _x && {alive _x}} < 0' in termination
    assert termination.index('["state","ASSESSING"]') < termination.index('["assessmentUntil",time + 0.5]')
    completion = section(maintenance, 'if ((_flight get "state") == "ASSESSING"', '} forEach (_session get "missileFlights");')
    assert 'time >= (_flight get "assessmentUntil")' in completion
    assert '!(_flight getOrDefault ["acceptShots",false])' in completion
    assert 'count (_session get "missileFlight") == 0' in completion
    assert completion.index('call _assessMissileTarget') < completion.index('["state","COMPLETE"]')
    assert 'deleteVehicle _laser' in completion and 'deleteVehicle _laser' not in termination
    assert 'select {(_x get "state") != "COMPLETE"}' in maintenance
    print("PASS: all-projectile termination precedes assessment; unresolved extras prevent assessment; 0.5 s deadline and closed request precede release")

    timeout = section(maintenance, 'if (time >= (_flight get "flightDeadline")', 'if ((_flight get "state") == "ASSESSING"')
    assert '["safetyHold",true]' in timeout and '["state","COMPLETE"]' not in timeout
    quarantine_release = section(maintenance, 'if (!(_quarantine get "unobservable")', '} else {\n\t\t\t\t\t\tif (time >= (_quarantine')
    assert '(_quarantine get "unresolved") isEqualTo []' in quarantine_release
    assert 'findIf {!isNull _x && {alive _x}} < 0' in quarantine_release
    assert 'time >= (_quarantine get "assessmentUntil")' in quarantine_release
    assert 'private _quarantined = count (_session get "missileFlight") > 0' in wp
    assert wp.count('if (_method == "MISSILE" && {count (_session get "missileFlight") > 0') == 2
    assert wp.count('findIf {(_x get "target") isEqualTo _target || {_x getOrDefault ["safetyHold",false]}}') == 2
    print("PASS: unknown/unobservable launches, extra rounds, handoff failures and diagnostic timeouts remain globally fail-closed")

    for match in re.finditer(r"\bwaitUntil\s*\{", masked):
        opening = masked.index("{", match.start())
        body = wp[opening:pairs[opening] + 1]
        assert 'get "missileFlight"' not in body and 'get "missileFlights"' not in body, "Global flight wait remains"
    reservation = section(wp, '// Atomic reservation precedes', '_operator forceWeaponFire [_muzzle,_mode];')
    assert reservation.index('["state","RESERVED"]') < reservation.index('pushBack _request') < reservation.index('["pending",true]')
    assert not re.search(r"\b(sleep|waitUntil|spawn|remoteExec)\b", mask_literals(reservation))
    assert wp.count('_operator forceWeaponFire [_muzzle,_mode];') == 1
    assert 'if (_method == "MISSILE") then {!(call _combatCurrent)} else {!(call _mayEngage)}' in wp
    print("PASS: no flight-completion waits; one serial command path; atomic target reservation and missile acknowledgement independent of target preemption")

    fired = section(wp, 'private _handle = _vehicle addEventHandler ["Fired",{', '// These are worker-local engagement helpers')
    assert 'private _lateMatch = count _lateCandidates == 1;' in fired
    assert 'count _lateCandidates > 1' in fired
    assert '(_projectile getVariable ["A3C_OW_MissileGuidanceOwner",""]) != "NATIVE"' in fired
    assert '_projectile in (_x get "projectiles")' in fired
    assert 'A3C_OW_MissileLaunch' in fired
    assert 'Missile ammunition consumption exceeds captured projectiles' in wp
    assert '(_request get "stockBefore") - _stockAfter - (_request get "shots")' in wp
    extra = section(fired, 'if ((_request get "shots") > 1) exitWith {', '_request set ["projectile",_projectile];')
    assert 'pushBackUnique _projectile' in extra and '["assessmentUntil",-1]' in extra and '["safetyHold",true]' in extra
    assert 'call A3C_ai_shared_fnc_guideProjectileMissile' not in extra
    assert '["unaccountedShots",_missing]' in fired
    print("PASS: immutable captured target/id, projectile deduplication, unique late recovery and all-extra-projectile accounting")

    assert '_target in _missileUnavailable' in selector
    assert '!_missileHeld && {!_groundNeutralized}' in selector
    assert 'if (_method == "" && {!_isAir}) then {' in selector
    assert '!(_target isKindOf "StaticWeapon")' in selector
    assert '!canMove _target} && {!canFire _target}' in selector
    assert 'magazinesAllTurrets [_target, true]' in selector
    assert 'No reliable armed-vehicle evidence' in wp
    assert 'Crewed static weapon: canFire=false alone is not reliable' in wp
    assert wp.count('param [0,-1]) == _id') >= 2 and wp.count('param [2,-1]) == _id') >= 2
    assert 'if (!isNull _laser && {(_request getOrDefault ["shots",0]) == 0}' in wp
    print("PASS: target-only withholding with ground gun fallback; immobilized firing tanks/static weapons preserved; ID-guarded public state and per-flight lasers")

    for doc in ROOT.glob("docs/heli-overwatch-missile-fire-control-validation.md"):
        for index, block in enumerate(re.findall(r"```sqf\s*\n(.*?)```", doc.read_text(encoding="utf-8"), re.S), 1):
            delimiters(block)
            print(f"PASS: diagnostic/test console block {index}")
    print("No Arma command execution, engine concurrency, collision/damage, network or gameplay result is established by these checks.")


if __name__ == "__main__":
    run()
