// A3C_ui_shared_fnc_onKeyDown_remoteVehicle

/*
	Handles arrow-key input while remotely controlling an HC vehicle.

	Returns:
		true	Remote-control input was handled; block the engine keybind.
		false	No valid remote-control action was performed.
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

/*
	The legacy initialization currently uses false in some startup code, so
	validate the type before applying object commands.
*/
if !(_remoteVehicle isEqualType objNull) exitWith {
	false
};

if (
	isNull _remoteVehicle
	|| {!alive _remoteVehicle}
) exitWith {
	false
};

private _remoteDriver = driver _remoteVehicle;

if (
	isNull _remoteDriver
	|| {!alive _remoteDriver}
	|| {isPlayer _remoteDriver}
) exitWith {
	false
};

hint "CONTROL THE VEHICLE WITH ARROW KEYS. CANCEL REMOTE WITH CTRL+RMB";

/*
	Preserved global state. Note that the throttle code below still retains
	the legacy hard limit of +/-5 model-space velocity.
*/
a3c_tank_speed_max = if (_shift) then {
	15
} else {
	5
};

switch (_key) do {
	case 203: {
		// Left arrow.
		if (_alt) then {
			[
				_remoteVehicle,
				"LEFT"
			] remoteExec [
				"sendSimpleCommand",
				_remoteVehicle
			];
		} else {
			[
				[
					_remoteVehicle,
					-0.5
				],
				A3C_ai_highCommand_fnc_actionRemoteSteer
			] remoteExec [
				"BIS_fnc_call",
				_remoteVehicle
			];
		};
	};

	case 205: {
		// Right arrow.
		if (_alt) then {
			[
				_remoteVehicle,
				"RIGHT"
			] remoteExec [
				"sendSimpleCommand",
				_remoteVehicle
			];
		} else {
			[
				[
					_remoteVehicle,
					0.5
				],
				A3C_ai_highCommand_fnc_actionRemoteSteer
			] remoteExec [
				"BIS_fnc_call",
				_remoteVehicle
			];
		};
	};

	case 200;
	case 208: {
		/*
			Up/down arrows adjust forward model-space velocity on the
			machine where the vehicle is local.
		*/
		private _velocityChange = if (_key == 200) then {
			0.2
		} else {
			-0.2
		};

		[
			[
				_remoteVehicle,
				_velocityChange
			],
			{
				params [
					["_vehicle", objNull, [objNull]],
					["_velocityChange", 0, [0]]
				];

				if (
					isNull _vehicle
					|| {!alive _vehicle}
				) exitWith {};

				_vehicle engineOn true;
				_vehicle disableBrakes true;

				private _velocityModelSpace =
					velocityModelSpace _vehicle;

				private _forwardVelocity =
					_velocityModelSpace select 1;

				_forwardVelocity = (
					(_forwardVelocity + _velocityChange)
					max -5
				) min 5;

				_velocityModelSpace set [
					1,
					_forwardVelocity
				];

				_vehicle setVelocityModelSpace _velocityModelSpace;
			}
		] remoteExec [
			"BIS_fnc_call",
			_remoteVehicle
		];
	};
};

true