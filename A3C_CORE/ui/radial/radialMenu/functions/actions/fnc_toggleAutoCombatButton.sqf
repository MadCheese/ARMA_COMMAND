#include "..\..\script_component.hpp"

params ["_units"];

private _result = [_units] call A3C_AI_ROE_fnc_toggleAutoCombat;
_result params ["_state", "_unitNames"];

if (_state == "NONE") exitWith {};

[_units] call FUNC(refreshAutoCombatButton);

hint format ["AUTOCOMBAT %1 FOR %2", _state, _unitNames];

[] spawn {
    sleep 2;
    hint "";
};