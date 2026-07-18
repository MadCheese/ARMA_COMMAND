// A3C_UI_mainDisplay_fnc_onKeyUp_Main

/*
	Main Display KeyUp handler.

	Responsibilities:
	- Remove the released key from A3C_UI_DOWNKEYS.
	- Close or cancel the radial interaction when its activation key is released.
	- Release HC remote-vehicle steering and throttle state.
	- Forward helicopter-gunner KeyUp events to the collective-release helper.

	Returns false because normal KeyUp events are not consumed.
*/
params [
	["_display", displayNull, [displayNull]],
	["_key", -1, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

if (player != leader group player) exitWith {
	false
};

/*
	Do not process Main Display input while Zeus is open.
*/
if (!isNull (findDisplay 312)) exitWith {
	false
};

/*
	KeyUp handlers own removal from the shared held-key collection.
*/
private _downKeys = missionNamespace getVariable [
	"A3C_UI_DOWNKEYS",
	[]
];

if !(_downKeys isEqualType []) then {
	_downKeys = [];
};

A3C_UI_DOWNKEYS = _downKeys - [_key];

/*
	The radial key data is expected to begin with the DIK key code.
*/
private _radialMenuKeyData = missionNamespace getVariable [
	"A3C_RadialMenu_KEY_ID",
	[]
];

private _radialMenuKey = if (
	_radialMenuKeyData isEqualType []
) then {
	_radialMenuKeyData param [
		0,
		-1,
		[0]
	]
} else {
	-1
};

if (
	_radialMenuKey >= 0
	&& {_key == _radialMenuKey}
) exitWith {
	[
		_display
	] call A3C_ui_shared_fnc_releaseMenuKey;

	false
};

private _isHighCommandRemote = missionNamespace getVariable [
	"a3c_is_HC_remote",
	false
];

switch true do {
	case (
		_isHighCommandRemote
		&& {
			_key in [
				200,
				203,
				205,
				208
			]
		}
	): {
		_this call A3C_ui_shared_fnc_onKeyUp_remoteVehicle;
	};

	case (
		vehicle player isKindOf "HELICOPTER"
		&& {
			player == gunner vehicle player
		}
	): {
		/*
			Preserve the existing routing contract: all helicopter-gunner
			KeyUp events reach the helper. The helper decides whether a
			collective input requires processing.
		*/
		_this call A3C_UI_mainDisplay_fnc_onKeyUp_heliGunner;
	};
};

false