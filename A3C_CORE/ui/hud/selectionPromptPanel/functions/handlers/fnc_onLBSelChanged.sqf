#include "..\..\script_component.hpp"

params ["_control", "_selectedIndex"];

if !(isNil "A3C_SelectionPromptPanel_LB_Change") then {
    [_selectedIndex] call A3C_SelectionPromptPanel_LB_Change;
};