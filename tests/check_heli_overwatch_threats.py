"""Source-derived AA policy fixtures; no Arma execution.

Initial calibration: explicit air flag, damaging bullet/shell, hit >= 30 and
automatic reload <= .06 s is dedicated AA; <= .2 s is secondary AA only.
These are config heuristics, not physical constants: barrel count, scripted
fire, dispersion, cooling, tracking and actual engine cadence are not modeled.
Tigris cannon hit/rate were not supplied; its cannon fixture is conditional on
those properties, not proof of that vehicle's installed config. No names decide
production classification. FFV exclusion requires absence of owned vehicle arms,
not personTurret alone. Infantry loaded/reserve MANPADS semantics are preserved.
BMP-2K hit is also an assumption for its nonzero secondary grade: its supplied
rate excludes Tier 1 regardless of hit, but Tier 2 still needs hit >= 30.
Reported cannon rates are treated as valid automatic-mode observations; actual
mode definitions and installed loadouts must still be inspected in Arma.
"""

import math
import re

from check_heli_overwatch_missile_control import ROOT, SELECTOR, delimiters, head, mask_literals, section


def expression(source, values):
    """Evaluate only the engine-free boolean/arithmetic subset used by AA policy.

    Conditions come from production SQF, rather than a second AA classifier.
    Engine observations (config values, crew and canFire) are fixture inputs.
    """
    source = re.sub(r'getNumber\s*\(_cfg\s*>>\s*"canLock"\)', '_canLock', source)
    source = source.replace('alive _target', '_alive')
    source = source.replace('canFire _target', '_fireable')
    source = source.replace('canMove _target', '_mobile')
    source = source.replace('isClass _mode', '_modeClass')
    source = source.replace('getNumber (_mode >> "autoFire")', '_autoFire')
    source = source.replace('_info get "damaging"', '_damaging')
    source = source.replace('_info get "simulation"', '_simulation')
    source = source.replace('!isNull _operator', '_operatorPresent')
    source = source.replace('alive _operator', '_operatorAlive')
    source = source.replace('lifeState _operator', '_operatorState')
    source = source.replace('vehicle _operator == _target', '_operatorMounted')
    source = source.replace('(_target unitTurret _operator) isEqualTo _path', '_operatorPathMatches')
    source = re.sub(r'\btoLower (_\w+)', r'\1.lower()', source)
    source = re.sub(r'\(_x select (\d+)\)', r'_x[\1]', source)
    source = source.replace('isEqualTo', '==').replace('isNotEqualTo', '!=')
    source = source.replace('&&', ' and ').replace('||', ' or ')
    source = re.sub(r'!(?!=)', ' not ', source)
    source = source.replace('{', '(').replace('}', ')')
    source = re.sub(r'\btrue\b', 'True', source)
    source = re.sub(r'\bfalse\b', 'False', source)
    return eval(re.sub(r'\s+', ' ', source).strip(), {"__builtins__": {}, "floor": math.floor}, values)


def run_assignments(source, values):
    """Execute production AA-grade assignments/if branches, not engine commands."""
    source = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
    _, pairs = delimiters(source)
    index = 0
    while index < len(source):
        if source[index].isspace() or source[index] == ';':
            index += 1
            continue
        if source.startswith('if', index):
            opening = source.index('(', index)
            closing = pairs[opening]
            condition = source[opening + 1:closing]
            branch_start = source.index('{', closing)
            branch_end = pairs[branch_start]
            then_branch = source[branch_start + 1:branch_end]
            index = branch_end + 1
            else_branch = ''
            match = re.match(r'\s*else\s*\{', source[index:])
            if match:
                branch_start = index + match.end() - 1
                branch_end = pairs[branch_start]
                else_branch = source[branch_start + 1:branch_end]
                index = branch_end + 1
            run_assignments(then_branch if expression(condition, values) else else_branch, values)
        else:
            match = re.match(r'(?:private\s+)?(_\w+)\s*=\s*([^;]+);', source[index:])
            assert match, f"Unsupported AA policy statement: {source[index:index + 80]}"
            values[match[1]] = expression(match[2], values)
            index += match.end()


def sustained_reload(ammo, modes):
    """Evaluate production mode predicates on observed [class, autoFire, reload]."""
    automatic = re.search(r'private _automatic = (.*?);', ammo)[1]
    condition = re.search(r'if \((_automatic.*?)\) then \{', ammo)[1]
    values = {'_sustainedReload': -1}
    for mode_class, auto_fire, reload_time in modes:
        values.update(_modeClass=mode_class, _autoFire=auto_fire, _reload=reload_time)
        values['_automatic'] = expression(automatic, values)
        if expression(condition, values):
            run_assignments('_sustainedReload = _reload;', values)
    return values['_sustainedReload']


def live_aa(threat, aa, *, operator=True, fireable=True, in_range=True,
            alive=True, is_air=False, mobile=True, is_man=False,
            simulation='shotbullet', damaging=True):
    values = dict(_aa=aa, _alive=alive, _operatorReady=operator, _isMan=is_man,
                  _fireable=fireable, _inRange=in_range, _isAir=is_air,
                  _mobile=mobile, _simulation=simulation, _damaging=damaging)
    override = section(threat, 'if (_isAir &&', 'if (_aa > 0)')
    run_assignments(override, values)
    qualifier = re.search(r'if \((_aa > 0)\) then \{', threat)[1]
    if not expression(qualifier, values):
        return 0
    values['_canFire'] = expression(re.search(r'private _canFire = (.*);', threat)[1], values)
    values['_ready'] = expression(re.search(r'private _ready = (.*?);', threat, re.S)[1], values)
    condition = re.search(r'private _liveGrade = if \((.*?)\) then \{1\} else \{2\};', threat)[1]
    return 1 if expression(condition, values) else 2


def infantry_fixtures(threat, launcher_aa):
    """Actual secondary-magazine, compatibility, operator and readiness predicates.

    The selected primary rifle is deliberately not an input to classification.
    fireable=False demonstrates that canFire of the held rifle is bypassed.
    """
    stock_condition = re.search(r'private _stockHere = if \(_isMan\) then \{(.*?)\} else', threat, re.S)[1]
    compatible_condition = re.search(r'if \((_stockHere[^\n]+)\) then \{', threat)[1]
    operator_condition = re.search(r'private _operatorReady = (.*?);', threat, re.S)[1]
    assert '[secondaryWeapon _target]' in threat and 'magazinesAmmoFull _target' in threat
    assert 'currentWeapon' not in threat and 'currentMagazine' not in threat
    for name, rounds, loaded, slot, compatible, operator_state, weapon, expected in [
        ('loaded MANPADS with primary rifle selected', 1, True, 4, True, 'HEALTHY', True, 1),
        ('compatible reserve MANPADS round, primary rifle selected', 1, False, -1, True, 'HEALTHY', True, 1),
        ('empty AA launcher', 0, True, 4, True, 'HEALTHY', True, 0),
        ('no secondary weapon', 1, True, 4, True, 'HEALTHY', False, 0),
        ('AA round loaded in unrelated weapon', 1, True, 1, True, 'HEALTHY', True, 0),
        ('incompatible launcher ammunition', 1, True, 4, False, 'HEALTHY', True, 0),
        ('incapacitated AA operator', 1, True, 4, True, 'INCAPACITATED', True, 2),
    ]:
        values = dict(_x=['AA', rounds, loaded, slot], _isMan=True,
                      _operatorPresent=True, _operatorAlive=True, _operatorState=operator_state,
                      _operatorMounted=False, _operatorPathMatches=False)
        values['_stockHere'] = expression(stock_condition, values)
        values.update(_mag='AA', _compatible=['aa'] if compatible else [], _pylonMatch=False)
        available = weapon and expression(compatible_condition, values)
        operator_ready = expression(operator_condition, values)
        grade = live_aa(threat, launcher_aa if available else 0, is_man=True,
                        operator=operator_ready, fireable=False, simulation='shotmissile')
        assert grade == expected, (name, grade)
        print(f'PASS: {name}: live AA grade {grade}')
    assert live_aa(threat, launcher_aa, is_man=True, fireable=False, in_range=False) == 2


def station_fixtures(threat, stock_expr):
    """Evaluate the production seat/stock/compatibility/readiness predicates.

    fullCrew rows, installed weapons and compatibility lists are engine inputs;
    this exercises the actual acceptance conditions, not an Arma seat query.
    """
    block = section(threat, 'private _crewSeats = fullCrew', '    private _canFire =')
    assert 'fullCrew [_target, "", true]' in block
    assert '_matchingSeats param [0, []]' in block
    assert 'toLower (_seat param [1, ""])' in block
    assert '_seat param [4, true]' in block
    driver_expr = re.search(r'private _dedicated = (.*?);', block)[1]
    match_expr = re.search(r'_crewSeats select \{(.*?)\};', block)[1]
    path_expr = re.search(r'private _pathNonempty = (.*?);', block)[1]
    role_expr = re.search(r'private _weaponRole = (.*?);', block)[1]
    station_expr = re.search(r'^\s*_dedicated = (.*?);', block, re.M)[1]
    compatibility_expr = re.search(r'if \((_stockHere[^\n]+)\) then \{', threat)[1]
    ready_expr = re.search(r'private _ready = (.*?);', threat, re.S)[1]
    live_condition = re.search(r'private _liveGrade = if \((.*?)\) then \{1\} else \{2\};', threat)[1]
    aa_qualifier = re.search(r'if \((_aa > 0)\) then \{', threat)[1]
    # name, path, seat rows, weapons, stock, compatible mags, ready operator,
    # ammo AA grade, accepted station, live AA grade contribution.
    fixtures = [
        ("mounted Shilka despite personTurret", [0], [["gunner", "gunner", -1, [0], True]], ["cannon"], [["AA", [0], 1734]], ["aa"], True, 1, True, 1),
        ("secondary BMP-2 cannon", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, True, 2),
        ("ordinary mounted cannon without AA evidence", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["ball", [0], 100]], ["ball"], True, 0, True, 0),
        ("personal FFV arms are not vehicle weapons", [0], [["passenger", "turret", 0, [0], True]], [], [], ["aa"], True, 1, True, 0),
        ("FFV cannot borrow personal ammo for vehicle weapon", [0], [["passenger", "turret", 0, [0], True]], ["cannon"], [], ["aa"], True, 1, True, 0),
        ("cargo role without FFV flag", [0], [["passenger", "cargo", 0, [0], False]], ["cannon"], [["AA", [0], 1734]], ["aa"], True, 2, False, 0),
        ("nested mounted turret", [0, 1], [["gunner", "TuRrEt", -1, [0, 1], False]], ["cannon"], [["AA", [0, 1], 100]], ["aa"], True, 1, True, 1),
        ("driver-operated weapon", [-1], [["driver", "driver", -1, [], False]], ["cannon"], [["AA", [-1], 100]], ["aa"], True, 1, True, 1),
        ("missing seat", [0], [], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("unrelated seat path", [0], [["gunner", "gunner", -1, [1], False]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("ambiguous seats", [0], [["a", "gunner", -1, [0], False], ["b", "turret", -1, [0], False]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("owned weapon despite missing personTurret metadata", [0], [["gunner", "gunner", -1, [0]]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 1, True, 1),
        ("missing installed weapon", [0], [["gunner", "gunner", -1, [0], False]], [], [["AA", [0], 100]], ["aa"], True, 2, True, 0),
        ("missing ammunition", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [], ["aa"], True, 2, True, 0),
        ("incompatible ammunition", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["AA", [0], 100]], ["other"], True, 2, True, 0),
        ("other turret owns ammunition", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["AA", [1], 100]], ["aa"], True, 2, True, 0),
        ("no rounds remaining", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["AA", [0], 0]], ["aa"], True, 2, True, 0),
        ("empty gunner seat", [0], [[None, "gunner", -1, [0], False]], ["cannon"], [["AA", [0], 100]], ["aa"], False, 1, True, 2),
    ]
    for name, path, seats, weapons, stock, compatible, operator, aa, expected_station, expected_grade in fixtures:
        values = dict(_path=path)
        accepted = expression(driver_expr, values)
        if not accepted:
            matches = [row for row in seats if expression(match_expr, dict(values, _x=row))]
            seat = matches[0] if matches else []
            # Adapt the documented fullCrew fields/param defaults as observations.
            values.update(_seatCount=len(matches), _role=seat[1].lower() if len(seat) > 1 else '',
                          _personTurret=seat[4] if len(seat) > 4 else True)
            values['_pathNonempty'] = expression(path_expr, values)
            values['_weaponRole'] = expression(role_expr, values)
            accepted = expression(station_expr, values)
        assert accepted == expected_station, (name, values)
        contribution = 0
        if accepted:
            for weapon in weapons:
                if not weapon:
                    continue
                for row in stock:
                    values['_stockHere'] = expression(stock_expr, dict(values, _x=row))
                    values.update(_mag=row[0], _compatible=compatible, _pylonMatch=False)
                    if expression(compatibility_expr, values):
                        values.update(_aa=aa, _alive=True, _operatorReady=operator, _canFire=True, _inRange=True, _isAir=False, _mobile=True)
                        values['_ready'] = expression(ready_expr, values)
                        if expression(aa_qualifier, values):
                            contribution = 1 if expression(live_condition, values) else 2
        assert contribution == expected_grade, (name, contribution)
        print(f"PASS: {name}: station={accepted}, AA contribution={contribution}")
    assert 'pathNonempty=%2 seatCount=%3 role=%4 weaponRole=%5 personTurret=%6' in block
    assert 'CBA_fnc_getTurret' not in block and 'proxyType' not in block and 'isPersonTurret' not in block


def run():
    ammo_path = "A3C_CORE/main/functions/fnc_getHeliOverwatchAmmoInfo.sqf"
    ammo = (ROOT / ammo_path).read_text(encoding="utf-8")
    selector = (ROOT / SELECTOR).read_text(encoding="utf-8")
    delimiters(ammo)
    delimiters(selector)
    # Nothing outside threat classification changes in the selector. Numeric/
    # text flag parsing and firing-facing damage/simulation/range remain exact.
    old_selector = head(SELECTOR, '187a6ac')
    start, end = '// Live threat readiness.', '\n{\n    private _target = _x;\n    private _detection ='
    assert selector[:selector.index(start)] == old_selector[:old_selector.index(start)]
    assert selector[selector.index(end):] == old_selector[old_selector.index(end):]
    old_ammo = head(ammo_path, '187a6ac')
    assert ammo[:ammo.index('private _sustainedReload')] == old_ammo[:old_ammo.index('{\n    private _mode =')]
    for field in ['["airAmmo", _offensiveAir || {_airOnly}]', '["damaging", _damaging]', '["range", _range]', '["minRange", _minRange]', '["simulation", _simulation]']:
        assert field in ammo and field in old_ammo
    for statement in ['_range = _range max getNumber (_mode >> "maxRange");', '_minRange = _minRange min getNumber (_mode >> "minRange");']:
        assert statement in ammo and statement in old_ammo
    air_expr = re.search(r'private _offensiveAir = (.*);', ammo)[1]
    other = re.search(r'private _otherOffensive = (\[[^;]+?\]) findIf \{(.*?)\} >= 0;', ammo)
    policy = section(ammo, 'private _aa =', 'private _evidence =')
    # name, flags, simulation, per-shot hit, automatic reload, airOnly, AA grade.
    fixtures = [
        ("Shilka additive mask", "64 + 128 + 256", "shotbullet", 60, .024, False, 1),
        ("Shilka numeric mask", 448, "shotbullet", 60, .024, False, 1),
        ("static ZU-23", 448, "shotbullet", 60, .024, False, 1),
        ("35mm cannon IF hit/rate meet boundary", 448, "shotshell", 30, .06, False, 1),
        ("BMD-1 slow main cannon", 448, "shotshell", 60, 6, False, 0),
        ("PKT", 448, "shotbullet", 11.47, .075, False, 0),
        ("BMP-2K faster autocannon", 448, "shotshell", 60, .1, False, 2),
        ("BMP-2K slower autocannon", 448, "shotshell", 60, .2, False, 2),
        ("tank FCS", 992, "shotsubmunitions", 60, .024, False, 0),
        ("smoke", 448, "shotsmoke", 0, .024, False, 0),
        ("dummy", 448, "", 0, .024, False, 0),
        ("ordinary infantry MG", 64, "shotbullet", 11.47, .075, False, 0),
        ("ordinary mixed MG", "64 + 128", "shotbullet", 60, .024, False, 0),
        ("ordinary shell", 192, "shotshell", 60, .024, False, 0),
        ("air-flagged MG", 256, "shotbullet", 11.47, .024, False, 0),
        ("below damage boundary", 448, "shotbullet", 29.99, .024, False, 0),
        ("beyond dedicated rate boundary", 448, "shotbullet", 60, .06001, False, 2),
        ("beyond secondary rate boundary", 448, "shotbullet", 60, .20001, False, 0),
        ("unknown firing rate", 448, "shotbullet", 60, 0, False, 0),
        ("AA missile", 256, "shotmissile", 60, 6, False, 1),
        ("Tigris missile IF AA missile evidence present", 256, "shotmissile", 60, 6, True, 1),
        ("air-only modded MANPADS", 0, "shotmissile", 60, 6, True, 1),
        ("AT missile", 128, "shotmissile", 60, 6, False, 0),
        ("air-flagged rocket remains unsupported by ammo helper", 256, "shotrocket", 60, .024, False, 0),
        ("nondamaging missile", 256, "shotmissile", 0, 6, True, 0),
        ("unresolved expression", "256 * 1", "shotbullet", 60, .024, False, 0),
    ]
    grades = {}
    for name, flags, simulation, hit, reload_time, air_only, expected in fixtures:
        # Decimal sums are fixture configuration input, not an Arma config read.
        resolved = isinstance(flags, int) or bool(re.fullmatch(r'\d+(?:\s*\+\s*\d+)*', flags))
        mask = flags if isinstance(flags, int) else sum(map(int, re.split(r'\s*\+\s*', flags))) if resolved else 0
        values = {"_flagsResolved": resolved, "_flags": mask}
        values['_offensiveAir'] = expression(air_expr, values)
        values['_otherOffensive'] = any(expression(other[2], dict(values, _x=bit)) for bit in expression(other[1], values))
        values.update(_simulation=simulation, _damaging=hit > 0, _hit=hit, _airOnly=air_only,
                      _sustainedReload=sustained_reload(ammo, [(True, 1, reload_time)]))
        run_assignments(policy, values)
        assert values['_aa'] == expected, (name, values)
        grades[name] = values['_aa']
        if name.startswith('Shilka'):
            assert mask == 448 and values['_offensiveAir']
        print(f"PASS: {name}: AA grade {expected}")

    threat = section(selector, '// Live threat readiness.', '\n{\n    private _target = _x;\n    private _detection =')
    assert 'forEach allTurrets [_target, true]' in threat
    assert '{if ((_x select 2) > 0) then {_stations pushBackUnique (_x select 1);};} forEach _stock;' in threat
    assert 'private _stations = if (_isMan) then {[[]]} else {[[-1]]};' in threat
    assert '_target weaponsTurret _path' in threat and 'compatibleMagazines [_weapon, _x]' in threat
    assert 'vehicle _operator == _target' in threat and '(_target unitTurret _operator) isEqualTo _path' in threat
    assert 'turretUnit _path' in threat and 'driver _target' in threat
    stock_expr = re.search(r'\} else \{(\(_x select 1\).*?)\};', threat)[1]
    shilka_stock = ['rhs_mag_AZP23_2000', [0], 1734]
    assert expression(stock_expr, {"_x": shilka_stock, "_path": [0]})
    assert not expression(stock_expr, {"_x": shilka_stock, "_path": [-1]})
    assert not expression(stock_expr, {"_x": [shilka_stock[0], [0], 0], "_path": [0]})
    station_fixtures(threat, stock_expr)
    print("PASS: inventory [0] discovery contract; dedicated-station/FFV, installed-weapon, compatibility, exact-path and positive-stock guards")

    for modes, expected, expected_aa in [
        ([(True, 1, .024)], .024, 1),
        ([(True, 0, .024)], -1, 0), # Single/burst-only config is not sustained auto evidence.
        ([(False, 1, .024)], -1, 0),
        ([(True, 1, 0), (True, 1, -1)], -1, 0),
        ([(True, 1, .2), (True, 1, .1), (False, 1, .001)], .1, 2),
    ]:
        assert sustained_reload(ammo, modes) == expected
        mode_values = dict(_damaging=True, _simulation='shotbullet', _offensiveAir=True,
                           _airOnly=False, _hit=60, _sustainedReload=expected)
        run_assignments(policy, mode_values)
        assert mode_values['_aa'] == expected_aa
    rate_block = section(ammo, 'private _sustainedReload', 'private _hit =')
    assert 'getNumber (_mode >> "burst")' not in rate_block
    assert 'getNumber (_mode >> "multiplier")' not in rate_block
    assert 'canLock' not in mask_literals(policy) and '_otherOffensive' not in mask_literals(policy)
    print('PASS: invalid/nonautomatic/unknown rate modes rejected; bursts and multipliers do not inflate sustained rate')

    for name, aa, observations, expected in [
        ('operational Shilka', grades['Shilka additive mask'], {}, 1),
        ('static ZU-23', grades['static ZU-23'], {}, 1),
        ('35mm cannon conditional on supplied thresholds', grades['35mm cannon IF hit/rate meet boundary'], {}, 1),
        ('AA missile installation', grades['Tigris missile IF AA missile evidence present'], {'simulation': 'shotmissile'}, 1),
        ('BMD-1 slow main cannon', grades['BMD-1 slow main cannon'], {}, 0),
        ('PKT', grades['PKT'], {}, 0),
        ('BMP-2K .1 s', grades['BMP-2K faster autocannon'], {}, 2),
        ('BMP-2K .2 s', grades['BMP-2K slower autocannon'], {}, 2),
        ('tank FCS', grades['tank FCS'], {}, 0),
        ('dedicated gun unavailable', grades['Shilka additive mask'], {'fireable': False}, 2),
        ('dedicated operator unavailable', 1, {'operator': False}, 2),
        ('dedicated out of range', 1, {'in_range': False}, 2),
        ('armed helicopter with ordinary live MG', 0, {'is_air': True}, 1),
        ('armed helicopter gunner not ready', 0, {'is_air': True, 'operator': False}, 2),
        ('unarmed helicopter', 0, {'is_air': True, 'damaging': False}, 0),
        ('disabled armed helicopter', 0, {'is_air': True, 'mobile': False}, 2),
        ('destroyed armed aircraft', 0, {'is_air': True, 'alive': False}, 2),
        ('aircraft targeting laser', 0, {'is_air': True, 'simulation': 'shotsubmunitions'}, 0),
    ]:
        grade = live_aa(threat, aa, **observations)
        assert grade == expected, (name, grade)
        print(f'PASS: {name}: live AA grade {grade} (eligibility remains separate)')
    infantry_fixtures(threat, grades['air-only modded MANPADS'])
    # Regression boundary for established infantry behavior, independent of the
    # new mounted/cannon rules. No current selected-weapon checks are introduced.
    old_threat = section(old_selector, start, end)
    for first, last in [('private _stockHere =', 'private _pylonMatch ='),
                        ('private _operatorReady =', 'if (_debug) then')]:
        assert section(threat, first, last) == section(old_threat, first, last)
    assert re.search(r'private _canFire = (.*);', threat)[0] == re.search(r'private _canFire = (.*);', old_threat)[0]
    assert 'if (_simulation == "shotmissile" && {_offensiveAir || {_airOnly}}) then {_aa = 1;};' in ammo
    assert 'case (_aa == 1): {1};' in selector and 'case (_aa == 2): {2};' in selector
    assert 'turret=%2 rounds=%3 operator=%4 operatorReady=%5 canFire=%6 inRange=%7 ready=%8 liveGrade=%9' in threat
    assert not re.search(r'rhs_|zsu|shilka', threat + ammo, re.I)
    doc = (ROOT / 'docs/heli-overwatch-shilka-threat-validation.md').read_text(encoding='utf-8')
    for block in re.findall(r'```sqf\s*\n(.*?)```', doc, re.S):
        delimiters(block)
    print("PASS: Shilka runtime diagnostic block has balanced SQF strings/comments/delimiters")
    print('LIMIT: Tigris cannon config was not supplied; its cannon/missile fixtures are conditional property checks.')
    print('LIMIT: BMP-2K Tier 2 assumes hit >= 30; reported .1-.2 s alone proves it is not dedicated Tier 1.')
    print("No Arma/config database, turret enumeration, RHS integration or gameplay execution is established by these checks.")


if __name__ == '__main__':
    run()
