// A3C_ui_shared_fnc_onKeyUp_remoteVehicle

/*
	Releases steering and braking state for the remotely controlled vehicle.

	The event-handler parameters are retained for KeyUp compatibility.
	This handler does not block the released key.
*/
params [
	["_display", displayNull, [displayNull]],
	["_key", -1, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

if !(_key in [200, 203, 205, 208]) exitWith {
	false
};

private _remoteVehicle = missionNamespace getVariable [
	"a3c_remote_tank_obj",
	objNull
];

if !(_remoteVehicle isEqualType objNull) exitWith {
	false
};

if (isNull _remoteVehicle) exitWith {
	false
};

[
	[
		_remoteVehicle
	],
	{
		params [
			["_vehicle", objNull, [objNull]]
		];

		if (isNull _vehicle) exitWith {};

		_vehicle sendSimpleCommand "STOPTURNING";

		private _driver = driver _vehicle;

		if (!isNull _driver) then {
			_driver enableAI "MOVE";
		};

		/*
			Preserve the legacy vehicle-level enableAI call in addition to
			restoring the driver's movement AI.
		*/
		_vehicle enableAI "MOVE";
		_vehicle disableBrakes false;
	}
] remoteExec [
	"BIS_fnc_call",
	_remoteVehicle
];

false