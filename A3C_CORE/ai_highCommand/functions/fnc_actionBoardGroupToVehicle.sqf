// A3C_ai_highCommand_fnc_actionBoardGroupToVehicle

private _vehicle = cursortarget;
[ A3C_RD_UNITS select {!isPlayer leader _x}, _vehicle] call A3C_ai_highCommand_fnc_assignGroupToVehicle;

A3C_UI_HUD_3D_TAG_ICON_TYPE = (gettext (configfile >> "CfgVehicles" >> typeof _vehicle >> "picture"));

private _uiPos = getPosASL _vehicle;
_uiPos set [2,(((boundingBoxReal _vehicle) select 1) select 2) / 2];

A3C_UI_MAPICONS_HC_VICS = [];
A3C_UI_HUD_ASSIGNVEHICLE = false;   