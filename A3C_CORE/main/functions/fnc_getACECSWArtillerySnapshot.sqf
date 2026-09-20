// A3C_main_fnc_getACECSWArtillerySnapshot

/*
	Returns the physical ACE-CSW artillery ammunition state for the supplied
	artillery pieces.

	This function deliberately reports current physical state only.
	Reservations / scheduled A3C artillery orders are handled separately.

	Params:
		0: ARRAY - artillery vehicles
		1: ARRAY - optional target position. [] skips range filtering.

	Return:
		[
			[
				carryMagazine,
				displayName,
				totalLoadedAmmo,
				totalExternalAmmo,
				totalPhysicalAmmo,

				[
					[
						vehicle,
						turretPath,
						loadedAmmo,
						compatibleVehicleMagazines,
						inRangeVehicleMagazines
					],
					...
				],

				[
					[
						sourceObject,
						ammoCount,
						[vehiclesThatCanUseThisSource]
					],
					...
				]
			],
			...
		]

	ACE autonomous AI reload semantics mirrored here:
		- gunner inventory
		- vehicle nearSupplies 10
		- ungrouped supplies
		- friendly non-player grouped supplies
		- external ammunition only when ace_csw_ammoHandling == 2

	The carry magazine from ACE_CSW_Groups is the logical ammunition-family ID.
*/

params [
	["_vehicles", [], [[]]],
	["_targetPos", [], [[]]]
];

if !(missionNamespace getVariable ["A3C_IsAce3", false]) exitWith {
	[]
};

private _cfgGroups = configFile >> "ACE_CSW_Groups";

if !(isClass _cfgGroups) exitWith {
	[]
};

private _cfgMagazines = configFile >> "CfgMagazines";
private _groupConfigs = "true" configClasses _cfgGroups;
private _families = [];

private _aceAmmoHandling = missionNamespace getVariable [
	"ace_csw_ammoHandling",
	0
];

{
	private _vehicle = _x;

	if (
		!isNull _vehicle
		&& {alive _vehicle}
		&& {
			getNumber (
				configOf _vehicle
				>> "artilleryScanner"
			) > 0
		}
		&& {
			isClass (
				configOf _vehicle
					>> "ACE_CSW"
			)
		}
	) then {
		private _gunner = gunner _vehicle;

		if (
			!isNull _gunner
			&& {alive _gunner}
		) then {
			private _turretPath = [
				_gunner
			] call ace_common_fnc_getTurretIndex;

			private _turretWeapons = _vehicle weaponsTurret _turretPath;

			private _compatibleVehicleMags = [];

			{
				_compatibleVehicleMags append (
					compatibleMagazines _x
				);
			} forEach _turretWeapons;

			_compatibleVehicleMags = (
				_compatibleVehicleMags
				arrayIntersect
				_compatibleVehicleMags
			);

			{
				private _groupConfig = _x;
				private _carryMag = configName _groupConfig;

				private _vehicleMags = _compatibleVehicleMags select {
					getNumber (
						_groupConfig >> _x
					) == 1
				};

				if (_vehicleMags isNotEqualTo []) then {

					private _inRangeVehicleMags = [
						_vehicle,
						_turretPath,
						_vehicleMags,
						_targetPos
					] call A3C_main_fnc_getACECSWArtilleryMagsInRange;

					private _loadedAmmo = 0;

					{
						_x params [
							"_magType",
							"_magTurret",
							"_magAmmo"
						];

						if (
							_magTurret isEqualTo _turretPath
							&& {_magAmmo > 0}
							&& {_magType in _vehicleMags}
						) then {
							_loadedAmmo = _loadedAmmo + _magAmmo;
						};
					} forEach magazinesAllTurrets _vehicle;

					private _familyIndex = _families findIf {
						(_x select 0) == _carryMag
					};

					if (_familyIndex < 0) then {
						private _displayName = getText (
							_cfgMagazines
								>> _carryMag
								>> "displayName"
						);

						_families pushBack [
							_carryMag,
							_displayName,
							0,
							0,
							0,
							[],
							[]
						];

						_familyIndex = (count _families) - 1;
					};

					private _family = _families select _familyIndex;

					private _pieceData = [
						_vehicle,
						_turretPath,
						_loadedAmmo,
						+_vehicleMags,
						+_inRangeVehicleMags
					];

					(_family select 5) pushBack _pieceData;

					if (_inRangeVehicleMags isNotEqualTo []) then {
						_family set [
							2,
							(_family select 2) + _loadedAmmo
						];

						private _canUseExternalAmmo = (
							_aceAmmoHandling == 2
							&& {
								!([
									_gunner
								] call ace_common_fnc_isPlayer)
							}
						);

						if (_canUseExternalAmmo) then {
							private _reloadSources = [_gunner];

							_reloadSources append (
								(_vehicle nearSupplies 10) select {
									isNull (group _x)
									|| {
										!([
											_x
										] call ace_common_fnc_isPlayer)
										&& {
											[
												side group _gunner,
												side group _x
											] call BIS_fnc_sideIsFriendly
										}
									}
								}
							);

							_reloadSources = (
								_reloadSources
									arrayIntersect
									_reloadSources
							);

							{
								private _source = _x;

								private _sourceAmmo = if (
									_source isKindOf "CAManBase"
								) then {
									magazinesAmmo _source
								} else {
									magazinesAmmoCargo _source
								};

								private _sourceCount = 0;

								{
									_x params [
										"_sourceMag",
										"_sourceMagAmmo"
									];

									if (
										_sourceMag == _carryMag
										&& {_sourceMagAmmo > 0}
									) then {
										_sourceCount =
											_sourceCount
											+ _sourceMagAmmo;
									};
								} forEach _sourceAmmo;

								if (_sourceCount > 0) then {
									private _sources = _family select 6;

									private _sourceIndex = _sources findIf {
										(_x select 0) isEqualTo _source
									};

									if (_sourceIndex < 0) then {
										_sources pushBack [
											_source,
											_sourceCount,
											[_vehicle]
										];

										_family set [
											3,
											(_family select 3)
											+ _sourceCount
										];
									} else {
										private _sourceData =
											_sources select _sourceIndex;

										(_sourceData select 2)
											pushBackUnique _vehicle;
									};
								};

							} forEach _reloadSources;
						};
					};

					_family set [
						4,
						(_family select 2)
						+ (_family select 3)
					];

					_families set [
						_familyIndex,
						_family
					];
				};

			} forEach _groupConfigs;
		};
	};

} forEach (_vehicles arrayIntersect _vehicles);

_families select {
	(_x select 4) > 0
}