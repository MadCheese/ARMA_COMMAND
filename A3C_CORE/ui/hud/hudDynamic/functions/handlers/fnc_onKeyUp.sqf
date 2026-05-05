#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_display", "_key", "_shift", "_ctrl", "_alt"];

if (_key == (A3C_RadialMenu_KEY_ID select 0)) then {
	
    A3C_DISABLE_RADIAL = false;
    A3C_UI_HUD_3D_TAG_ICON_TYPE = "";

    private _hudDynamicDisplay = findDisplay IDD_HUD_DYNAMIC;

    if (isNull _hudDynamicDisplay) then {
        _hudDynamicDisplay = _display;
    };

    if !(isNull _hudDynamicDisplay) then {
        _hudDynamicDisplay closeDisplay 0;
    };

    A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

    {
        player groupSelectUnit [_x, false];
    } forEach units player;

    showCommandingMenu "";

    true

} else {

    false

};