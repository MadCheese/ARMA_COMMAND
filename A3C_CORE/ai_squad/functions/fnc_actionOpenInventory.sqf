params ["_target", "_source"];

A3C_UI_INV_TARGET_UNIT = _target;
[] call A3C_ui_radialMenu_fnc_closeDisplay;
{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
[_target,_source] spawn A3C_ui_radialMenu_fnc_inventoryLbCreate;