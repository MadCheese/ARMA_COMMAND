#include "..\..\dialog_defines.hpp"
#include "..\..\script_component.hpp"
#include "..\..\..\..\SHARED\shared_ui_defines.hpp"

params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];

private _ins = lineIntersectsSurfaces [
    AGLToASL positionCameraToWorld [0,0,0],
    ATLToASL screenToWorld [_sX, _sY],
    cameraOn,
    objNull,
    true,
    1,
    "GEOM",
    "NONE"
];

private _clickedVehicle = objNull;
if (count _ins > 0) then {
    _clickedVehicle = (_ins select 0) select 2;
};

if ({
    ctrlShown _x && {[[_sX, _sY], _x] call MCSS_fnc_isClickPosInCTRLArea}
} count (["radial_clickBlockAreas"] call FUNC(ctrlGroup)) > 0) exitWith {};

private _unitDetected = false;

if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
    private _hcAll = A3C_HC_getAllGroups_Player_Current;
    private _group = grpNull;
    private _refGroup = group driver _clickedVehicle;

    if (_refGroup in _hcAll) then {
        _group = _refGroup;
    } else {
        private _groupIconsAtClickPos = [[_sX, _sY]] call A3C_UI_RADIAL_iconsAtClickPos;
        if (count _groupIconsAtClickPos > 0) then {
            private _clickedGroupIcon = _groupIconsAtClickPos select 0;
            _group = _clickedGroupIcon select 0;
        };
    };

    if (!isNull _group) then {
        _unitDetected = true;

        if (_button == 1) then {
            if (_group in A3C_RD_UNITS) then {
                A3C_RD_UNITS = A3C_RD_UNITS - [_group];
            } else {
                A3C_RD_UNITS pushBackUnique _group;
            };
        } else {
            A3C_RD_UNITS = [_group];
        };

        private _ind = [_group, _hcAll] call MCSS_fnc_GetArrayIndex;
        A3C_BUTTONPAGE_TABLET = (ceil ((_ind + 1) / 18)) - 1;

        if (count A3C_RD_UNITS == 0) then {
            (findDisplay 100040 displayCtrl 8005) ctrlSetText "SELECT UNIT";
        } else {
            if (count A3C_RD_UNITS == 1) then {
                (findDisplay 100040 displayCtrl 8005) ctrlSetText (groupID (A3C_RD_UNITS select 0));
            } else {
                (findDisplay 100040 displayCtrl 8005) ctrlSetText "MULTIPLE GROUPS";
            };
        };

        A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;
        [] call A3C_UNITSEL_REFRESH_UI;
        [] call A3C_UI_SHARED_createDashBoard;
    };
} else {
    private _refUnit = driver _clickedVehicle;

    if (_refUnit in units player) then {
        _unitDetected = true;

        if (_button == 1) then {
            if (_refUnit in A3C_RD_UNITS) then {
                A3C_RD_UNITS = A3C_RD_UNITS - [_refUnit];
            } else {
                A3C_RD_UNITS pushBackUnique _refUnit;
            };
        } else {
            A3C_RD_UNITS = [_refUnit];
        };

        [] call A3C_UNITSEL_REFRESH_UI;
    };

    A3C_RD_UNITS = A3C_RD_UNITS select {!isPlayer _x};

    [] spawn {
        for "_i" from 1 to 2 do {
            sleep 0.1;
            {
                if (_x in A3C_RD_UNITS) then {
                    player groupSelectUnit [_x, true];
                } else {
                    player groupSelectUnit [_x, false];
                };
            } forEach (units player - [player]);
        };
    };
};

if (_unitDetected) then {
    private _CT_TREE = findDisplay 100040 displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
    _CT_TREE tvSetCurSel [-1];

    if (count A3C_RD_UNITS == 1) then {
        _button = (A3C_RD_UNITS select 0) getVariable ["A3C_TREESEL_INDEX", []];
        _button = _button select ((count _button) - 1);
        _CT_TREE tvSetCurSel _button;
    };
};