"""Source-derived AA policy fixtures and static station contracts; no Arma execution."""

import math
import re

from check_heli_overwatch_missile_control import ROOT, SELECTOR, delimiters, head, section


def expression(source, values):
    """Evaluate only the engine-free boolean/arithmetic subset used by AA policy.

    Conditions come from production SQF, rather than a second AA classifier.
    Engine observations (config values, crew and canFire) are fixture inputs.
    """
    source = re.sub(r'getNumber\s*\(_cfg\s*>>\s*"canLock"\)', '_canLock', source)
    source = source.replace('alive _target', '_alive')
    source = source.replace('canFire _target', '_fireable')
    source = re.sub(r'\btoLower (_\w+)', r'\1.lower()', source)
    source = re.sub(r'\(_x select (\d+)\)', r'_x[\1]', source)
    source = source.replace('isEqualTo', '==').replace('isNotEqualTo', '!=')
    source = source.replace('&&', ' and ').replace('||', ' or ')
    source = re.sub(r'!(?!=)', ' not ', source)
    source = source.replace('{', '(').replace('}', ')')
    source = re.sub(r'\btrue\b', 'True', source)
    source = re.sub(r'\bfalse\b', 'False', source)
    return eval(source.strip(), {"__builtins__": {}, "floor": math.floor}, values)


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
    ready_expr = re.search(r'private _ready = (.*);', threat)[1]
    live_condition = re.search(r'private _liveGrade = if \((.*?)\) then \{1\} else \{2\};', threat)[1]
    # name, path, seat rows, weapons, stock, compatible mags, ready operator,
    # ammo AA grade, accepted station, live AA grade contribution.
    fixtures = [
        ("mounted Shilka [0]", [0], [["gunner", "gunner", -1, [0], False]], ["cannon"], [["AA", [0], 1734]], ["aa"], True, 2, True, 2),
        ("actual FFV", [0], [["passenger", "turret", 0, [0], True]], ["cannon"], [["AA", [0], 1734]], ["aa"], True, 2, False, 0),
        ("cargo role without FFV flag", [0], [["passenger", "cargo", 0, [0], False]], ["cannon"], [["AA", [0], 1734]], ["aa"], True, 2, False, 0),
        ("nested mounted turret", [0, 1], [["gunner", "TuRrEt", -1, [0, 1], False]], ["cannon"], [["AA", [0, 1], 100]], ["aa"], True, 1, True, 1),
        ("driver-operated weapon", [-1], [["driver", "driver", -1, [], False]], ["cannon"], [["AA", [-1], 100]], ["aa"], True, 1, True, 1),
        ("missing seat", [0], [], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("unrelated seat path", [0], [["gunner", "gunner", -1, [1], False]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("ambiguous seats", [0], [["a", "gunner", -1, [0], False], ["b", "turret", -1, [0], False]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
        ("missing personTurret evidence", [0], [["gunner", "gunner", -1, [0]]], ["cannon"], [["AA", [0], 100]], ["aa"], True, 2, False, 0),
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
                        values.update(_aa=aa, _alive=True, _operatorReady=operator, _canFire=True, _inRange=True)
                        values['_ready'] = expression(ready_expr, values)
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
    # This patch may change only station validation; all other production text
    # (including the ammo parser/grades and earlier LOS/reselection fix) is exact.
    station_baseline = head(SELECTOR, '30d45ba')
    old_start = station_baseline.index('        _stations = _stations select {')
    new_start = selector.index('        private _crewSeats = fullCrew')
    end = '\n    };\n    private _canFire ='
    assert selector[:new_start] == station_baseline[:old_start]
    assert selector[selector.index(end, new_start):] == station_baseline[station_baseline.index(end, old_start):]
    assert ammo == head(ammo_path, '30d45ba')
    old_ammo = head(ammo_path, "a6568c2")
    # Config parsing, damage/range calculation and firing-facing fields are exact.
    assert ammo[:ammo.index('private _aa =')] == old_ammo[:old_ammo.index('private _aa =')]
    assert ammo[ammo.index('private _evidence ='):] == old_ammo[old_ammo.index('private _evidence ='):]
    air_expr = re.search(r'private _offensiveAir = (.*);', ammo)[1]
    other = re.search(r'private _otherOffensive = (\[[^;]+?\]) findIf \{(.*?)\} >= 0;', ammo)
    policy = section(ammo, 'private _aa =', 'private _evidence =')
    fixtures = [
        ("Shilka additive mask", "64 + 128 + 256", "shotbullet", True, 0, False, 2),
        ("Shilka numeric mask", 448, "shotbullet", True, 0, False, 2),
        ("infantry-only MG", 64, "shotbullet", True, 0, False, 0),
        ("ordinary mixed MG", "64 + 128", "shotbullet", True, 1, False, 0),
        ("ordinary mixed shell", 192, "shotshell", True, 1, False, 0),
        ("dedicated AA bullet", 256, "shotbullet", True, 0, False, 1),
        ("mixed AA shell", 448, "shotshell", True, 0, False, 2),
        ("locking AA shell", 448, "shotshell", True, 1, False, 1),
        ("AA missile", 256, "shotmissile", True, 0, False, 1),
        ("air-only missile", 0, "shotmissile", True, 0, True, 1),
        ("AT missile", 128, "shotmissile", True, 1, False, 0),
        ("nondamaging countermeasure", 448, "shotbullet", False, 0, False, 0),
        ("unresolved expression", "256 * 1", "shotbullet", True, 0, False, 0),
    ]
    for name, flags, simulation, damaging, can_lock, air_only, expected in fixtures:
        # Decimal sums are fixture configuration input, not an Arma config read.
        resolved = isinstance(flags, int) or bool(re.fullmatch(r'\d+(?:\s*\+\s*\d+)*', flags))
        mask = flags if isinstance(flags, int) else sum(map(int, re.split(r'\s*\+\s*', flags))) if resolved else 0
        values = {"_flagsResolved": resolved, "_flags": mask}
        values['_offensiveAir'] = expression(air_expr, values)
        values['_otherOffensive'] = any(expression(other[2], dict(values, _x=bit)) for bit in expression(other[1], values))
        values.update(_simulation=simulation, _damaging=damaging, _canLock=can_lock, _airOnly=air_only)
        run_assignments(policy, values)
        assert values['_aa'] == expected, (name, values)
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

    ready_expr = re.search(r'private _ready = (.*);', threat)[1]
    fire_expr = re.search(r'private _canFire = (.*);', threat)[1]
    live_condition = re.search(r'private _liveGrade = if \((.*?)\) then \{1\} else \{2\};', threat)[1]
    for name, aa, alive, operator, can_fire, in_range, expected in [
        ("reported Shilka", 2, True, True, False, True, 2),
        ("ready mixed Shilka", 2, True, True, True, True, 2),
        ("dedicated operational AA", 1, True, True, True, True, 1),
        ("uncrewed dedicated AA", 1, True, False, True, True, 2),
        ("disabled dedicated AA", 1, True, True, False, True, 2),
        ("destroyed dedicated AA", 1, False, True, True, True, 2),
        ("out-of-range dedicated AA", 1, True, True, True, False, 2),
    ]:
        values = dict(_aa=aa, _alive=alive, _operatorReady=operator, _isMan=False, _fireable=can_fire, _inRange=in_range)
        values['_canFire'] = expression(fire_expr, values)
        values['_ready'] = expression(ready_expr, values)
        tier = 1 if expression(live_condition, values) else 2
        assert tier == expected, name
        assert tier < 3  # Existing eligible AA tiers outrank ordinary tiers 3-5.
        print(f"PASS: {name}: live AA tier {tier} (candidate eligibility remains separate)")
    assert 'case (_aa == 1): {1};' in selector and 'case (_aa == 2): {2};' in selector
    assert 'turret=%2 rounds=%3 operator=%4 operatorReady=%5 canFire=%6 inRange=%7 ready=%8 liveGrade=%9' in threat
    assert not re.search(r'rhs_|zsu|shilka', threat + ammo, re.I)
    doc = (ROOT / 'docs/heli-overwatch-shilka-threat-validation.md').read_text(encoding='utf-8')
    for block in re.findall(r'```sqf\s*\n(.*?)```', doc, re.S):
        delimiters(block)
    print("PASS: Shilka runtime diagnostic block has balanced SQF strings/comments/delimiters")
    print("No Arma/config database, turret enumeration, RHS integration or gameplay execution is established by these checks.")


if __name__ == '__main__':
    run()
