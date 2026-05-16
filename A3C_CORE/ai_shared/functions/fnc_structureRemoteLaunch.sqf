// A3C_ai_shared_fnc_structureRemoteLaunch

params [
    ["_units", [], [[]]],
    ["_remFireType", "", [""]]
];

if (_units isEqualTo []) exitWith {};

private _aimPos = ATLToASL A3C_UI_HUD_3D_TAG_ICON_POS;
private _unitsByGroups = [];

if ((count _units) > 1) then {
    {
        private _unit = _x;
        private _group = group _unit;

        private _index = _unitsByGroups findIf {
            (_x select 0) isEqualTo _group
        };

        if (_index isEqualTo -1) then {
            _unitsByGroups pushBack [_group, [_unit]];
        } else {
            ((_unitsByGroups select _index) select 1) pushBack _unit;
        };
    } forEach _units;
};

private _shooters = [];

if !(_unitsByGroups isEqualTo []) then {
    {
        private _groupUnits = _x select 1;
        private _unitsViewOnTarget = [_groupUnits, _aimPos] call A3C_UI_SHARED_FIND_BEST_SHOOTERS;

        if !(_unitsViewOnTarget isEqualTo []) then {
            _shooters pushBackUnique (_unitsViewOnTarget select 0);
        };
    } forEach _unitsByGroups;
} else {
    _shooters = _units;
};

if (_shooters isEqualTo []) exitWith {};

{
    [[_x, _aimPos, _remFireType], A3C_ai_shared_fnc_orderRemoteLaunch] remoteExec [
        "BIS_fnc_spawn",
        _x
    ];
} forEach _shooters;

sleep 2;

waitUntil {
    ({
        alive _x && {
            _x getVariable ["A3C_unit_is_Remote_Firing", false]
        }
    } count _shooters) isEqualTo 0
};



[] call A3C_ui_radialMenu_fnc_structureRemoteLaunchUiResponse;