// A3C_main_fnc_closeInitializationScreen

params [
	["_fadeTime", 0, [0]]
];

if (!hasInterface) exitWith {};
if (!A3C_InitScreenShown) exitWith {};

"A3C_INIT_IMAGE" cutFadeOut 0;

"A3C_INIT_BLACK" cutText [
	"",
	"BLACK IN",
	_fadeTime
];

A3C_InitScreenShown = false;
