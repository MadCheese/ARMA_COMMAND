
private _groups = +A3C_HC_getAllGroups_Player_Current;
_groups pushBackUnique (group player);

private _charges = [];

{
    private _group = _x;

    if (!isPlayer leader _group || {player == leader _group}) then {
        {
            private _unit = _x;
            private _explosives = _unit getVariable ["A3C_UNIT_EXPLOSIVES", []];

            {
                _charges pushBackUnique [_unit, _x];
            } forEach _explosives;
        } forEach units _group;
    };
} forEach _groups;

_charges