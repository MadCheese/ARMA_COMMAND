// A3C_UI_mainDisplay_fnc_onKeyDown_heliGunner

/*
	Provides additional helicopter controls while the player occupies the
	gunner position.

	Supported input actions:
	- Countermeasures:
		Attempts to fire the driver's countermeasure weapon and starts the
		existing evasive maneuver.
	- Collective raise/lower:
		Changes the AI pilot's commanded flight height.
	- Rudder left/right:
		Rotates the helicopter at low speed while preserving velocity.

	Returns true when an input action was handled.
*/
params [
	["_display", displayNull, [displayNull]],
	["_key", -1, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

private _helicopter = vehicle player;

if (
	isNull _helicopter
	|| {!alive _helicopter}
) exitWith {
	false
};

private _isCounterMeasures =
	inputAction "launchCM" > 0;

private _isCollectiveRaise =
	inputAction "HeliCollectiveRaise" > 0;

private _isCollectiveLower =
	inputAction "HeliCollectiveLower" > 0;

private _isRudderLeft =
	inputAction "HeliRudderLeft" > 0;

private _isRudderRight =
	inputAction "HeliRudderRight" > 0;

private _remoteArguments = [
	_helicopter
];

private _remoteCode = {};
private _handled = false;

switch true do {
	case _isCounterMeasures: {
		_remoteCode = {
			params [
				["_helicopter", objNull, [objNull]]
			];

			if (
				isNull _helicopter
				|| {!alive _helicopter}
			) exitWith {};

			private _driver = driver _helicopter;

			if (!isNull _driver) then {
				private _cfgWeapons =
					configFile >> "CfgWeapons";

				private _cfgMagazines =
					configFile >> "CfgMagazines";

				private _cfgAmmo =
					configFile >> "CfgAmmo";

				private _countermeasureFired = false;

				{
					private _weapon = _x;
					private _weaponConfig =
						_cfgWeapons >> _weapon;

					private _weaponModes = getArray (
						_weaponConfig >> "modes"
					);

					if (_weaponModes isNotEqualTo []) then {
						private _weaponMode =
							_weaponModes select 0;

						private _weaponMagazines = getArray (
							_weaponConfig >> "magazines"
						);

						{
							private _magazineConfig =
								_cfgMagazines >> _x;

							private _ammoClass = getText (
								_magazineConfig >> "ammo"
							);

							private _ammoConfig =
								_cfgAmmo >> _ammoClass;

							if (
								getText (
									_ammoConfig >> "simulation"
								) == "shotCM"
								&& {
									getText (
										_ammoConfig >> "effectsSmoke"
									) in [
										"CounterMeasureFlare",
										"CounterMeasureChaff"
									]
								}
							) exitWith {
								_driver forceWeaponFire [
									_weapon,
									_weaponMode
								];

								_countermeasureFired = true;
							};
						} forEach _weaponMagazines;
					};

					if (_countermeasureFired) exitWith {};
				} forEach (
					_helicopter weaponsTurret [-1]
				);
			};

			[
				_helicopter
			] call A3C_ai_highCommand_fnc_helicopterEvasive;
		};

		_handled = true;
	};

	case _isCollectiveRaise: {
		_remoteCode = {
			params [
				["_helicopter", objNull, [objNull]]
			];

			if (
				isNull _helicopter
				|| {!alive _helicopter}
			) exitWith {};

			private _currentHeight =
				getPosATL _helicopter select 2;

			_helicopter flyInHeight (
				_currentHeight + 20
			);
		};

		_handled = true;
	};

	case _isCollectiveLower: {
		_remoteCode = {
			params [
				["_helicopter", objNull, [objNull]]
			];

			if (
				isNull _helicopter
				|| {!alive _helicopter}
			) exitWith {};

			private _currentHeight =
				getPosATL _helicopter select 2;

			_helicopter flyInHeight (
				(_currentHeight - 20) max 0
			);
		};

		_handled = true;
	};

	case (
		abs speed _helicopter < 25
		&& {
			_isRudderLeft
			|| {_isRudderRight}
		}
	): {
		private _rotationStep = if (_ctrl) then {
			0.5
		} else {
			0.2
		};

		private _rotation = if (_isRudderLeft) then {
			-_rotationStep
		} else {
			_rotationStep
		};

		_remoteArguments = [
			_helicopter,
			_rotation
		];

		_remoteCode = {
			params [
				["_helicopter", objNull, [objNull]],
				["_rotation", 0, [0]]
			];

			if (
				isNull _helicopter
				|| {!alive _helicopter}
			) exitWith {};

			private _velocity =
				velocity _helicopter;

			private _direction =
				vectorDir _helicopter;

			private _upVector =
				vectorUp _helicopter;

			private _cosine =
				cos _rotation;

			private _sine =
				sin _rotation;

			private _newDirection = [
				(
					(_direction select 0) * _cosine
				) + (
					(_direction select 1) * _sine
				),
				-(
					(_direction select 0) * _sine
				) + (
					(_direction select 1) * _cosine
				),
				_direction select 2
			];

			_helicopter setVectorDirAndUp [
				_newDirection,
				_upVector
			];

			/*
				setVectorDirAndUp can affect motion. Restore the velocity
				captured immediately before the rotation.
			*/
			_helicopter setVelocity _velocity;
		};

		_handled = true;
	};
};

if (_handled) then {
	[
		_remoteArguments,
		_remoteCode
	] remoteExec [
		"BIS_fnc_call",
		_helicopter
	];
};

_handled