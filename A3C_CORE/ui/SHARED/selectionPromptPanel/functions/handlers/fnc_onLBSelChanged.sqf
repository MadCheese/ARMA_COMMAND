#include "..\..\script_component.hpp"

params ["_control", "_selectedIndex"];

if !(isNil "A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared") then {
    [_selectedIndex] call A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared;
};