// A3C_main_fnc_handleInitializationAbort

if (!hasInterface) exitWith {};
if (A3C_InitializationAbortHandled) exitWith {};

A3C_InitializationAbortHandled = true;

[0] call A3C_main_fnc_closeInitializationScreen;

[] spawn {
	waitUntil {alive player};
	sleep 1;

	"ARMA COMMAND DLC" hintC [
		"ARMA 3 COMMAND and ADVANCED AI COMMAND are running simultaneously.",
		"These addons are not compatible.",
		"ARMA 3 COMMAND initialization has been aborted.",
		"Please restart Arma 3 without ADVANCED AI COMMAND enabled."
	];
};
