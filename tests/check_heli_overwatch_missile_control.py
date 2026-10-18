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


def head(path, revision=BASELINE):
    return subprocess.check_output(
        ["git", "-c", f"safe.directory={ROOT.as_posix()}", "show", f"{revision}:{path}"],
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
    prefix = prefix.replace('\t\tprivate _engagementRejections = []; // [target, until, cause]; target failures only, never missile reservations.\n', '')
    prefix = prefix.replace('\t\tprivate _lastEngagementRejection = createHashMap; // Bounded diagnostic state; suppress unchanged retries.\n', '')
    assert prefix.rstrip() == old_wp[:old_wp.index('// Run on engagement boundaries')].rstrip()
    footer = wp[wp.index('// No live ammo, no executable mode'):].replace(
        'if (!_preempted && {!_retrySelection}) then {sleep 1;}; // Target rejection immediately reselects; normal cadence is unchanged.',
        'if (!_preempted) then {sleep 1;}; // Bounded burst/failure/idle pacing, then a new decision.',
    )
    assert footer == old_wp[old_wp.index('// No live ammo, no executable mode'):]
    for command in ['spawn', 'addEventHandler', 'addMissionEventHandler', 'enableAIFeature', 'flyInHeight', 'limitSpeed']:
        assert len(re.findall(r'\b' + command + r'\b', masked, re.I)) == len(re.findall(r'\b' + command + r'\b', mask_literals(old_wp), re.I)), command
    for start, end in [
        ('private _startGuidance = {', '_request set ["handoff",true]'),
        ('if (_kind == "GUN") exitWith {', 'if ((_request get "shots") > 1) exitWith'),
        ('private _clearAim = {', '// Confirmed flights reserve only'),
    ]:
        old_end = '// Preemption may rotate/aim at B' if end.startswith('// Confirmed') else end
        actual = section(wp, start, end)
        if start == 'private _clearAim = {':
            actual = actual.replace('\t\t\tprivate _retrySelection = false;\n', '').replace('\t\t\tprivate _authorizationReason = "";\n', '')
        assert actual.rstrip() == section(old_wp, start, old_end).rstrip(), start
    # The LOS fix deliberately replaces only these acquisition/eligibility rays.
    # Normalize those exact edits; still compare all detection rules verbatim.
    los_selector = selector.replace(
        'private _sensorObjects = _sensorContacts apply {_x select 0};\n',
        'private _sensorObjects = _sensorContacts apply {_x select 0};\n'
        'private _observerASL = eyePos _heli; // Vehicle eyes/main turret; ignore our own geometry below.\n',
    ).replace(
        '_visual = [_heli, _target] call A3C_main_fnc_hasHeliOverwatchLOS;',
        '_visual = (lineIntersectsSurfaces [\n'
        '                        _observerASL, aimPos _target, _heli, _target, true, 1, "VIEW", "GEOM"\n'
        '                    ]) isEqualTo [];',
    ).replace(
        '// Detection alone never establishes fireability; all paths use the same\n'
        '            // elevated observation geometry as the final firing check. Reuse a just-tested optical ray.\n'
        '            && {(_detection get "visual") || {[_heli, _target] call A3C_main_fnc_hasHeliOverwatchLOS}};',
        '// A successful optical ray already proved visibility using appropriate endpoints.\n'
        '            // Keep legacy vehicle LOS for knowledge/sensor paths; do not contradict optical LOS with origins.\n'
        '            && {(_detection get "visual") || {!(lineIntersects [getPosASL _heli, getPosASL _target, _heli, _target])}};',
    )
    # Threat implementation has its own focused checks; still compare every
    # acquisition and eligibility token outside that explicitly changed block.
    threat_end = '\n{\n    private _target = _x;\n    private _detection ='
    los_selector = los_selector.replace(
        section(los_selector, '// Live threat readiness.', threat_end),
        section(old_selector, '// Live threat readiness.', threat_end),
    )
    assert section(los_selector, 'private _knowledgeGroup', '    private _missileHeld =') == section(
        old_selector, 'private _knowledgeGroup', '    private _method ='
    )
    assert section(selector, '    // Detection is unchanged;', '    // Temporary authorization failures') == section(
        old_selector, '    // Detection is unchanged;', '    private _eligible ='
    )
    assert selector[selector.index('    _rows pushBack _row;'):] == old_selector[old_selector.index('    _rows pushBack _row;'):]
    air_guard = section(wp, '// Final AIR authorization,', 'if (_method == "MISSILE" && {(([_target]').replace(
        '\t\t\t\t\t\t\t\t\t\t\t[_target,"TARGET_INVALID",true] call _rejectEngagement;\n', '',
    )
    assert air_guard == section(
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

    los = (ROOT / "A3C_CORE/main/functions/fnc_hasHeliOverwatchLOS.sqf").read_text(encoding="utf-8")
    delimiters(los)
    assert 'A3C_PREP(hasHeliOverwatchLOS);' in (ROOT / "A3C_CORE/main/functions/XEH_PREP.hpp").read_text(encoding="utf-8")
    assert 'private _start = eyePos _heli;' in los and 'private _end = aimPos _target;' in los
    assert 'ceil ((_start vectorDistance _end) / 4000)' in los
    assert 'from 0 to (_segments - 1)' in los and 'vectorNormalized _delta' in los
    assert '[_from, _to, _heli, _target, true, 1, "VIEW", "GEOM"]' in los
    assert 'isNotEqualTo []) exitWith {\n        _clear = false;' in los
    assert not re.search(r'\blineIntersects\s*\[', mask_literals(selector + wp))
    assert selector.count('call A3C_main_fnc_hasHeliOverwatchLOS') == 2
    authorization = section(wp, 'private _engagementCurrent = {', 'private _clearAim = {')
    assert 'call A3C_main_fnc_hasHeliOverwatchLOS' in authorization
    print("PASS: registered shared elevated LOS, ignored endpoint vehicles, bounded full-path segments and no origin-ray authorization")

    exclusion = section(selector, '    // Temporary authorization failures', '    private _row =')
    assert '(_x select 0) isEqualTo _target && {time < (_x select 1)}' in exclusion
    assert 'private _eligible = _valid && {_method != ""} && {!_temporarilyExcluded};' in exclusion
    assert selector.index(exclusion) < selector.index('    if (_eligible) then {') < selector.index('private _best = []')
    assert '(_x get "target") isEqualTo _retained && {_x get "eligible"}' in selector
    for field in ['temporarilyExcluded', 'rejectedUntil', 'rejectionCause']:
        assert f'["{field}",' in selector
    evaluate = section(wp, 'private _evaluateTargets = {', 'private _handle = _vehicle addEventHandler')
    assert '_engagementRejections select {!isNull (_x select 0) && {time < (_x select 1)}}' in evaluate
    assert '_rankingCache,_reservedTargets,_engagementRejections]' in evaluate
    assert '["engagementRejections",_engagementRejections apply {+_x}]' in evaluate
    assert '["lastEngagementRejection",_lastEngagementRejection]' in evaluate
    rejection = section(wp, 'private _rejectEngagement = {', 'private _engagementCurrent = {')
    assert '_until = time + 5;' in rejection and '_authorizationReason = _cause;' in rejection
    assert 'if (_authorizationReason != "") exitWith {false};' in authorization
    _, rejection_pairs = delimiters(rejection)
    target_opening = rejection.index('{', rejection.index('if (_targetSpecific) then'))
    target_branch = rejection[target_opening:rejection_pairs[target_opening] + 1]
    assert '_retrySelection = true;' in target_branch and '_nextEvaluation = 0;' in target_branch
    assert '_engagementRejections pushBack _entry' in target_branch and '_engagementRejections set [_index,_entry]' in target_branch
    assert 'if (!_preempted && {!_retrySelection}) then {sleep 1;};' in wp
    assert set(re.findall(r'\[_target,"([A-Z_]+)",true\] call _rejectEngagement', wp)) == {
        'LOS_BLOCKED', 'TARGET_OUT_OF_RANGE', 'TARGET_INVALID',
    }
    for cause in ['TARGET_TEMPORARILY_UNAVAILABLE', 'WEAPON_UNAVAILABLE', 'TARGET_PREEMPTED', 'SESSION_CANCELLED']:
        assert f'[_target,"{cause}",false] call _rejectEngagement' in authorization
    assert '_failed' not in rejection and '_blockedUntil' not in rejection
    assert 'get "missileFlight' not in rejection and 'setVariable' not in rejection
    print("PASS: five-second worker-local target exclusions precede ranking/retention; immediate alternatives; weapon/reservation/preemption/cancellation never exclude")

    changed = section(rejection, 'private _changed =', '_lastEngagementRejection = createHashMapFromArray')
    assert '"cause"' in changed and '"target"' in changed and '"scope"' in changed
    assert '"until"' not in changed and 'time' not in changed
    assert 'if (_changed && {_vehicle getVariable ["A3C_OW_Debug",false]}) then {' in rejection
    cleanup = section(wp, '_request set ["acceptShots",false];\n\t\t\t\t\tif', '// No live ammo, no executable mode')
    assert '_request set ["reason",_authorizationReason]' in cleanup
    assert 'if ((_request getOrDefault ["commands",0]) > 0 && {_vehicle getVariable ["A3C_OW_Debug",false]}) then {' in cleanup
    assert '"AUTHORIZATION_CANCELLED"' in cleanup
    print("PASS: early cause survives absent request ID; changed-state debug logging; generic fire summaries require an actual issued command")

    # Compare the complete Phase 2 control/guidance and command path to the
    # committed source before this fix, beyond the individual contracts above.
    phase2 = head(WAYPOINT, "a6568c2")
    for start, end in [
        ('// Session-private safety bookkeeping', '// Run on engagement boundaries'),
        ('private _handle = _vehicle addEventHandler', '// These are worker-local engagement helpers'),
        ('private _limit = if (_method == "MISSILE")', '// Launch acknowledgement is complete;'),
    ]:
        actual = section(wp, start, end).replace(
            '\t\t\t\t\t\t\t\t\t\t\t[_target,"TARGET_INVALID",true] call _rejectEngagement;\n', '',
        )
        assert actual == section(phase2, start, end), start
    print("PASS: full flight/assessment/quarantine, Fired/guidance and readiness/command/ammunition paths preserved (only final rejection reporting added)")

    for doc in [ROOT / "docs/heli-overwatch-missile-fire-control-validation.md", ROOT / "docs/heli-overwatch-los-validation.md"]:
        for index, block in enumerate(re.findall(r"```sqf\s*\n(.*?)```", doc.read_text(encoding="utf-8"), re.S), 1):
            delimiters(block)
            print(f"PASS: diagnostic/test console block {index}")
    print("No Arma command execution, engine concurrency, collision/damage, network or gameplay result is established by these checks.")


if __name__ == "__main__":
    run()
