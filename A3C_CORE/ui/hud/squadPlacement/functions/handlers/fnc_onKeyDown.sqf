#include "..\..\script_component.hpp"

params ["_display", "_key", "_shift", "_ctrl", "_alt"];

private _refKey = ((["A3C", "A3C_KeyFnc_Hud_Order_Reg"] call CBA_fnc_getKeybind) select 5) select 0;

if (_refKey == _key) then {
    [false, false] spawn FUNC(executeOrder);
    _display closeDisplay 0;
};