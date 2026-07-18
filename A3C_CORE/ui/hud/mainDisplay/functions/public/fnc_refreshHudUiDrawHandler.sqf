// A3C_UI_mainDisplay_fnc_refreshHudUiDrawHandler

if (!isNil "A3C_EVH_DRAW_HUD") then {
	removeMissionEventHandler [
		"Draw3D",
		A3C_EVH_DRAW_HUD
	];
};

A3C_EVH_DRAW_HUD = addMissionEventHandler [
	"Draw3D",
	{
		[] call A3C_UI_mainDisplay_fnc_drawHudUI;
	}
];

A3C_EVH_DRAW_HUD