// A3C_ui_shared_fnc_blockKeyDownEvent

/*
	Returns true when the key-down event should be blocked.

	Exceptions:
	- Arrow keys remain available during HC remote control.
	- A key that is not already registered as held is not blocked.
	- Helicopter flight controls remain available to a player acting as gunner.
*/

params [
	["_key", -1, [0]]
];

if (_key < 0) exitWith {
	false
};

private _isHighCommandRemote = missionNamespace getVariable [
	"a3c_is_HC_remote",
	false
];

// DIK codes: Up, Left, Right, Down.
if (
	_isHighCommandRemote
	&& {_key in [200, 203, 205, 208]}
) exitWith {
	false
};

private _downKeys = missionNamespace getVariable [
	"A3C_UI_DOWNKEYS",
	[]
];

if !(_key in _downKeys) exitWith {
	false
};

private _vehicle = objectParent player;

if (
	!isNull _vehicle
	&& {_vehicle isKindOf "Helicopter"}
	&& {player == gunner _vehicle}
	&& {
		inputAction "HeliCollectiveRaise" > 0
		|| {inputAction "HeliCollectiveLower" > 0}
		|| {inputAction "HeliRudderLeft" > 0}
		|| {inputAction "HeliRudderRight" > 0}
	}
) exitWith {
	false
};

true