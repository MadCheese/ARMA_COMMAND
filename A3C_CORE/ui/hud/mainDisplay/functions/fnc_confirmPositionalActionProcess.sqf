//---------------------------- SHARED POSITIONAL CONFIRM FUNCTION

params [
	["_flickerMode", "", [""]]
];

A3C_isHud3dTag = true;
A3C_UI_HUD_3D_TAG_reposition = false;

if (!isNull A3C_OBJECTPLACER) then {
	deleteVehicle A3C_OBJECTPLACER;
	A3C_OBJECTPLACER = objNull;
};

private _flickerScript = [+A3C_UI_HUD_3D_TAG_ICON_POS, _flickerMode] spawn A3C_UI_HUD_3D_TAG;

waitUntil {
	scriptDone _flickerScript
};

A3C_isHud3dTag = false;

[] call A3C_UI_mainDisplay_fnc_cancelPositionalActionProcess; //-- Reset UI