#include "..\..\script_component.hpp"

params ["_mode"];

private _data = [];
private _check = if (_mode == 0) then {A3C_HUD_STANCE_MODE_TRAVEL} else {A3C_HUD_STANCE_MODE_DESTINATION};
private _toolTip = "";

switch (_check) do {
    case 0: {
        _toolTip = "Stance: Prone";
        _data = [
            "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa",
            "DOWN",
            [1, 1, 1, 1],
            true
        ];
    };
    case 1: {
        _toolTip = "Stance: Crouch";
        _data = [
            "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa",
            "MIDDLE",
            [1, 1, 1, 1],
            true
        ];
    };
    case 2: {
        _toolTip = "Stance: Stand";
        _data = [
            "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
            "UP",
            [1, 1, 1, 1],
            true
        ];
    };
    case 3: {
        _toolTip = "Stance: Auto";
        _data = [
            "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
            "AUTO",
            [1, 1, 1, 1],
            true
        ];
    };
    case 4: {
        _toolTip = "Stance: No Change";
        _data = [
            "A3C_CORE\ui\pictures\icon_menu_stance_NoChange.paa",
            "",
            [1, 1, 1, 1],
            false
        ];
    };
};

if (A3C_HUD_FORM == 8) then {
    (_data select 2) set [2, 0.1];
};

if (_mode == 0) then {
    _toolTip = "Travel " + _toolTip;

    A3C_HUD_STANCE_ICON_TRAVEL = _data select 0;
    A3C_HUD_STANCE_ICON_COLOR_TRAVEL = _data select 2;
    A3C_BOOL_STANCE_ICON_TRAVEL = _data select 3;

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 10) ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 10) ctrlSetTextColor [1, 1, 1, 1];

    (findDisplay 100050 displayCtrl 16) ctrlSetTooltip _toolTip;
} else {
    _toolTip = "End " + _toolTip;

    A3C_HUD_STANCE_ICON_DESTINATION = _data select 0;
    A3C_HUD_STANCE_ICON_COLOR_DESTINATION = _data select 2;
    A3C_BOOL_STANCE_ICON_DESTINATION = _data select 3;

    (findDisplay 100050 displayCtrl 17) ctrlSetTooltip _toolTip;

    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 11) ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
    ((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 11) ctrlSetTextColor [1, 1, 1, 1];
};

{
    private _unitGhost = _x;

    {
        private _unit = _x;
        private _var = _unit getVariable ["A3C_HUD_DATA", [objNull, -1]];

        if ((_var select 0) == _unitGhost) exitWith {
            [_unitGhost, _unit] call FUNC(switchUnitGhostStance);
        };
    } forEach (units player - [player]);
} forEach A3C_UI_squadPlacement_unitGhosts;