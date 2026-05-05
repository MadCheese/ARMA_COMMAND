#include "..\..\script_component.hpp"

params ["_control", "_key"];

if (_key == (A3C_SUP_DRAWKEY_ID select 0)) exitWith {
    if (A3C_SUP_DRAW_TOGGLE) then {
        [] call FUNC(closeDisplay);
    };

    true
};

false