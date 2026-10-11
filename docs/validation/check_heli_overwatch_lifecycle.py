"""Overwatch source contracts only: not an SQF compiler or an Arma gameplay test."""
from pathlib import Path
import argparse
import re

ROOT = Path(__file__).resolve().parents[2]
WP = ROOT / 'A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf'
LC = ROOT / 'A3C_CORE/main/functions/fnc_heliOverwatchLifecycle.sqf'


def code_only(source, keep_strings=False):
    # Mask comments and strings without moving offsets; SQF escapes quotes by
    # doubling them, rather than using backslashes.
    out = list(source)
    i = 0
    while i < len(source):
        end = i + 1
        mask = False
        if source.startswith('//', i):
            end = source.find('\n', i)
            end = len(source) if end < 0 else end
            mask = True
        elif source.startswith('/*', i):
            end = source.find('*/', i + 2)
            assert end >= 0, 'unterminated comment'
            end += 2
            mask = True
        elif source[i] in '\"\'':
            quote = source[i]
            end = i + 1
            while end < len(source):
                if source[end] == quote:
                    end += 1
                    if end < len(source) and source[end] == quote:
                        end += 1
                        continue
                    break
                end += 1
            else:
                raise AssertionError('unterminated SQF string')
            mask = not keep_strings
        if mask:
            out[i:end] = ['\n' if x == '\n' else ' ' for x in source[i:end]]
        i = end
    return ''.join(out)


def balanced(source):
    stack = []
    for offset, char in enumerate(code_only(source)):
        if char in '([{':
            stack.append((char, offset))
        elif char in ')]}':
            assert stack and stack[-1][0] == {')': '(', ']': '[', '}': '{'}[char], f'unmatched {char} at {offset}'
            stack.pop()
    assert not stack, f'unclosed delimiters {stack}'


def block(source, marker):
    start = source.index('{', source.index(marker))
    code = code_only(source)
    depth = 1
    end = start + 1
    while depth:
        depth += (code[end] == '{') - (code[end] == '}')
        end += 1
    return source[start:end]


def compact(source):
    return re.sub(r'\s+', '', code_only(source, keep_strings=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, help='pre-lifecycle working-tree waypoint snapshot')
    args = parser.parse_args()
    relative_files = [
        'A3C_CORE/waypointScripts/wpScript_heli_overwatch.sqf',
        'A3C_CORE/main/functions/fnc_heliOverwatchLifecycle.sqf',
        'A3C_CORE/ai_highCommand/functions/fnc_reInitGroupMovement.sqf',
        'A3C_CORE/ai_highCommand/functions/fnc_moveGroupToPosition.sqf',
        'A3C_CORE/ai_highCommand/functions/fnc_addWaypoint.sqf',
        'A3C_CORE/ai_highCommand/functions/fnc_removeWaypoint.sqf',
        'A3C_CORE/ai_highCommand/functions/fnc_deleteAllWaypoints.sqf',
        'A3C_CORE/main/functions/XEH_PREP.hpp',
    ]
    for name in relative_files:
        balanced((ROOT / name).read_text(encoding='utf-8-sig'))
    wp = WP.read_text(encoding='utf-8-sig')
    lc = LC.read_text(encoding='utf-8-sig')
    executable_wp = code_only(wp, keep_strings=True)
    assert not re.search(r'\b(?:enableAI|disableAI)\s+[\"\'](?:ALL|PATH|FIREWEAPON)[\"\']', executable_wp, re.I)
    assert wp.index('["begin",') < wp.index('call A3C_ai_highCommand_fnc_reInitGroupMovement')
    end = wp.index('["end", _run, if (_normalDeparture)')
    assert end < wp.index('_leader domove (waypointPosition', end) < wp.index('sleep 3;', end)
    phase = block(lc, 'case "phase":')
    assert 'abs ((getPosATL _vehicle select 2)' in phase and '<= 20' in phase
    assert '_argument == "ACTIVE"' in phase and '_state get "exclusiveFire"' in phase
    assert '["A3C_OW_DevExclusiveFire", false]' in lc
    assert '["A3C_OW_LifecycleDebug", false]' in lc
    begin = block(lc, 'case "begin":')
    assert begin.index('["release", _old') < begin.index('checkAIFeature "PATH"') < begin.index('enableAIFeature ["PATH", true]')
    assert '[clientOwner, _serial]' in begin
    assert '["vehicles", []]' in begin and '(_run get "vehicles") pushBack _vehicle' in begin
    assert '["sessions", []]' not in begin  # no run -> session -> run HashMap cycle
    release = block(lc, 'case "release":')
    assert release.index('_state set ["released", true]') < release.index('terminate _x') < release.index('enableAIFeature')
    assert 'if (_owned)' in release and 'local _vehicle' in release
    for feature in ['PATH', 'FIREWEAPON']:
        assert f'_vehicle enableAIFeature ["{feature}", _state get "saved{feature}"]' in release
    assert 'removeMissionEventHandler ["EachFrame", _monitor]' in release
    assert 'removeEventHandler ["FIRED", _eh]' in release
    monitor = block(lc, 'case "monitor":')
    assert not re.search(r'NearEntities|selectHeliOverwatchTarget|doFire|fireAtTarget|selectWeapon|createVehicle', monitor, re.I)
    for evidence in ['waypointScript', 'waypointStatements', 'waypointFormation', 'waypointSpeed',
                     'waypointBehaviour', 'waypointCombatMode', 'waypointTimeout',
                     'waypointName', 'waypointDescription', 'waypointCompletionRadius',
                     'waypointType', 'currentWaypoint', 'scriptDone', 'heartbeat']:
        assert evidence in lc
    assert '(_session get "firedEH") != _thisEventHandler' in wp
    delayed = block(wp, 'private _delayed =')
    assert delayed.index('sleep 1;') < delayed.index('["current", _session]') < delayed.index('remoteExec')
    assert '(_session get "lasers") pushBack _activeTarget' in wp
    assert wp.count('sleep 0.05;') >= 5
    assert '(_session get "savedPATH")' not in wp  # restoration belongs to the helper
    assert 'A3C_PREP(heliOverwatchLifecycle);' in (ROOT / relative_files[-1]).read_text()
    docs = (ROOT / 'docs/heli-overwatch-lifecycle-validation.md').read_text(encoding='utf-8-sig')
    for snippet in re.findall(r'```sqf\n(.*?)```', docs, re.S):
        balanced(snippet)
    assert '["ALPHA",' not in docs  # stored GoCode is A, not its display label
    if args.baseline:
        old = args.baseline.read_text(encoding='utf-8-sig')
        for name in ['_fnc_vehicleWeaponAmmo =', 'private _getAvailableGuns =']:
            assert compact(block(wp, name)) == compact(block(old, name)), f'combat helper changed: {name}'
        # Command arguments in the cannon firing path must remain intact.
        for command in ['selectWeaponTurret', 'loadMagazine', 'doFire']:
            def commands(text):
                return [compact(x) for x in re.findall(r'_primaryGunner\s+' + command + r'\s+[^;]+|_vehicle\s+' + command + r'\s+[^;]+', code_only(text, True), re.I)]
            assert commands(wp) == commands(old), f'cannon command changed: {command}'
        print('PASS: live-ammo helpers and cannon command arguments match the pre-lifecycle working tree')
    print(f'PASS: delimiters for {len(relative_files)} source files and all SQF documentation blocks')
    print('PASS: baseline capture, Boolean restoration, altitude/dev gate, ownership/async guards, departure ordering, monitor scope')
    print('LIMIT: source contracts only; no SQF compiler, Arma engine, gameplay or multiplayer execution')


if __name__ == '__main__':
    main()
