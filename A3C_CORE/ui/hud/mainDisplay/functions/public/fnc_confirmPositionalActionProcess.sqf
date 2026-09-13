// A3C_UI_mainDisplay_fnc_confirmPositionalActionProcess


//---------------------------- SHARED POSITIONAL CONFIRM FUNCTION

params [
	["_flickerMode", "", [""]]
];


A3C_UI_HUD_3D_TAG_ICON_MOD = "NONE";

if (!isNull A3C_OBJECTPLACER) then {
	A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";
	A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (
		configFile >> "CfgVehicles" >> typeOf A3C_OBJECTPLACER >> "picture"
	);
	deleteVehicle A3C_OBJECTPLACER;
	A3C_OBJECTPLACER = objNull;
};


private _flickerScript = [+A3C_UI_HUD_3D_TAG_ICON_POS, _flickerMode] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

waitUntil {
	scriptDone _flickerScript
};



[] call A3C_UI_mainDisplay_fnc_cancelPositionalActionProcess; //-- Reset UI