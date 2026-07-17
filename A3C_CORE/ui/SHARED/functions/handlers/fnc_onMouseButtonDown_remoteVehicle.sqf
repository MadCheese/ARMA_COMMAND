// A3C_ui_shared_fnc_onMouseButtonDown_remoteVehicle

/*
	Ends HC vehicle remote control and restores the vehicle's normal
	movement state.

	The caller is responsible for restricting invocation to the intended
	mouse combination, currently CTRL + right mouse button.

	Returns false so the mouse-button event is not consumed.
*/
params [
	["_display", displayNull, [displayNull]],
	["_button", -1, [0]],
	["_screenX", 0, [0]],
	["_screenY", 0, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

private _remoteVehicle = missionNamespace getVariable [
	"a3c_remote_tank_obj",
	objNull
];

if (
	_remoteVehicle isEqualType objNull
	&& {!isNull _remoteVehicle}
) then {
	[
		[
			_remoteVehicle
		],
		{
			params [
				["_vehicle", objNull, [objNull]]
			];

			if (isNull _vehicle) exitWith {};

			private _driver = driver _vehicle;

			if (!isNull _driver) then {
				_driver enableAI "MOVE";
			};

			/*
				Preserve the legacy vehicle-level AI restoration.
			*/
			_vehicle enableAI "MOVE";

			/*
				Remote-control cancellation immediately stops the vehicle.
				This intentionally preserves the original behavior.
			*/
			_vehicle setVelocityModelSpace [0, 0, 0];
			_vehicle disableBrakes false;
		}
	] remoteExec [
		"BIS_fnc_call",
		_remoteVehicle
	];
};

a3c_remote_tank_obj = objNull;
a3c_is_HC_remote = false;
a3c_tank_speed = 0;

hint "";

false