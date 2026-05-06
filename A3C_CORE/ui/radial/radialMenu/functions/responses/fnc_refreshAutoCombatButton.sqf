#include "..\..\script_component.hpp"

params [["_units", A3C_RD_UNITS]];

private _buttonImg = ["outerTop4Img"] call FUNC(ctrl);
private _buttonBtn = ["outerTop4Btn"] call FUNC(ctrl);

if (isNull _buttonImg || {isNull _buttonBtn}) exitWith {};

if ({_x in A3C_AutoCombatDisabledUnits} count _units > 0) then {
    _buttonImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_autocombat_disabled.paa";
    _buttonBtn ctrlSetToolTip "ENABLE AUTOCOMBAT";
} else {
    _buttonImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa";
    _buttonBtn ctrlSetToolTip "DISABLE AUTOCOMBAT";
};