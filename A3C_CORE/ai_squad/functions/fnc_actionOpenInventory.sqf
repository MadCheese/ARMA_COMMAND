params ["_target", "_source"];

A3C_UI_INV_TARGET_UNIT = _target;
[] call A3C_UI_RADIAL_CloseDisplay;
{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
[_target,_source] spawn A3C_UI_RADIAL_INV_LB_CREATE;