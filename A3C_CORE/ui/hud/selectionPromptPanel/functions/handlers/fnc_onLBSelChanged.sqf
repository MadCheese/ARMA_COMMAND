#include "..\..\script_component.hpp"

params ["_control", "_selectedIndex"];

if !(isNil "A3C_UI_SHARED_selectionPromptPanel_onLbChange") then {
    [_selectedIndex] call A3C_UI_SHARED_selectionPromptPanel_onLbChange;
};