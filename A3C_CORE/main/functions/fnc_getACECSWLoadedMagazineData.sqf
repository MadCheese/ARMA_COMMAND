// A3C_main_fnc_getACECSWLoadedMagazineData

params [
	["_vehicle", objNull, [objNull]],
	["_turretPath", [], [[]]],
	["_requestedCarryMag", "", [""]]
];

if (
	isNull _vehicle
	|| {
		!(missionNamespace getVariable [
			"A3C_IsAce3",
			false
		])
	}
) exitWith {
	["", "", 0]
};

private _groupsCfg =
	configFile >> "ACE_CSW_Groups";

private _groupCfgs =
	"true" configClasses _groupsCfg;

private _result = [
	"",
	"",
	0
];

{
	_x params [
		"_vehicleMag",
		"_magTurret",
		"_ammo"
	];

	if (
		_magTurret isEqualTo _turretPath
		&& {_ammo > 0}
	) then {
		private _carryMag = "";

		if (_requestedCarryMag != "") then {
			if (
				getNumber (
					_groupsCfg
					>> _requestedCarryMag
					>> _vehicleMag
				) == 1
			) then {
				_carryMag =
					_requestedCarryMag;
			};
		} else {
			{
				if (
					getNumber (
						_x >> _vehicleMag
					) == 1
				) exitWith {
					_carryMag =
						configName _x;
				};

			} forEach _groupCfgs;
		};

		if (_carryMag != "") exitWith {
			_result = [
				_vehicleMag,
				_carryMag,
				_ammo
			];
		};
	};

} forEach magazinesAllTurrets _vehicle;

_result