//-- Find the weapons that a unit selection can possibly assemble.

params ["_units", "_mode"];

A3C_STATIC_PACKS = []; //-- #TODO check why we need this global array in the first place.

private _fnc_isUnitAlreadyAssigned = {
	params ["_unit"];

	{
		_unit in (_x select 0)
	} count A3C_STATIC_PACKS > 0
};

//-- REGULAR APPROACH: backpack-based static weapons
{
	private _unit = _x;
	private _unitGroup = group _unit;
	private _unitBackpackClass = backpack _unit;
	private _unitBackpackObject = unitBackpack _unit;

	private _allowInfantryPlanning = (
		isNull objectParent _unit ||
		{
			!isPlayer leader _unitGroup &&
			{
				!(driver vehicle leader _unitGroup in units _unitGroup)
			}
		}
	);

	private _hasStaticWeaponBackpack = (
		_unitBackpackObject isKindOf "Weapon_Bag_Base" ||
		{_unitBackpackClass in A3C_SOG_BASEPACKS}
	);

	if (_hasStaticWeaponBackpack && {_allowInfantryPlanning}) then {
		if (_unitBackpackClass in A3C_SOG_BASEPACKS) then {
			//-- SOG weapons: one shared base backpack can be compatible with multiple statics.
			{
				private _pairedUnit = _x;
				private _pairedBackpackClass = backpack _pairedUnit;

				if (_pairedBackpackClass != "") then {
					private _pairedAssembleInfoCfg = configFile >> "CfgVehicles" >> _pairedBackpackClass >> "assembleInfo";
					private _compatibleBasePacks = getArray (_pairedAssembleInfoCfg >> "base");

					if (_unitBackpackClass in _compatibleBasePacks) then {
						private _unitAlreadyAssigned = [_unit] call _fnc_isUnitAlreadyAssigned;
						private _pairedUnitAlreadyAssigned = [_pairedUnit] call _fnc_isUnitAlreadyAssigned;

						if (!_unitAlreadyAssigned && {!_pairedUnitAlreadyAssigned}) then {
							A3C_STATIC_PACKS pushBack [
								[_unit, _pairedUnit],
								getText (_pairedAssembleInfoCfg >> "assembleTo")
							];
						};
					};
				};
			} forEach (_units - [_unit]);
		} else {
			if (_unitBackpackClass != "") then {
				private _unitBackpackClassLower = toLower _unitBackpackClass;
				private _unitAssembleInfoCfg = configFile >> "CfgVehicles" >> _unitBackpackClassLower >> "assembleInfo";
				private _baseCfg = _unitAssembleInfoCfg >> "base";

				private _compatibleBases = if (isText _baseCfg) then {
					[toLower getText _baseCfg]
				} else {
					getArray _baseCfg
				};

				{
					_compatibleBases set [_forEachIndex, toLower _x];
				} forEach _compatibleBases;

				{
					private _pairedUnit = _x;
					private _pairedBackpackClassLower = toLower backpack _pairedUnit;

					if (_pairedBackpackClassLower != "" && {_pairedBackpackClassLower in _compatibleBases}) then {
						private _unitAlreadyAssigned = [_unit] call _fnc_isUnitAlreadyAssigned;
						private _pairedUnitAlreadyAssigned = [_pairedUnit] call _fnc_isUnitAlreadyAssigned;

						if (!_unitAlreadyAssigned && {!_pairedUnitAlreadyAssigned}) then {
							A3C_STATIC_PACKS pushBack [
								[_unit, _pairedUnit],
								getText (_unitAssembleInfoCfg >> "assembleTo")
							];
						};
					};
				} forEach (_units - [_unit]);
			};
		};
	};
} forEach _units;


//-- IFA APPROACH: weapon-part-based static weapons
{
	private _unit = _x;
	private _staticTurretClass = "";
	private _staticPodVehicleClass = "";

	{
		private _carriedWeaponClass = _x;

		{
			private _staticPartPair = _x;
			private _partData = _staticPartPair select 1;
			private _turretClass = _partData select 0;
			private _podVehicleClass = _partData select 1;

			if (_carriedWeaponClass == _turretClass) exitWith {
				_staticTurretClass = _turretClass;
				_staticPodVehicleClass = _podVehicleClass;
			};
		} forEach A3C_IFA_StaticPartPairs;

		if (_staticTurretClass != "") exitWith {};
	} forEach [primaryWeapon _unit, secondaryWeapon _unit];

	if (_staticTurretClass != "") then {
		//-- IFA stores the pod as deployed CfgVehicles class, but units carry the corresponding CfgWeapons tripod.
		private _podWeaponClass = getText (
			configFile >> "CfgVehicles" >> _staticPodVehicleClass >> "LIB_Equipped_Tripod_Name"
		);

		private _candidateUnits = [_unit] + (_units - [_unit]);

		{
			private _pairedUnit = _x;

			if (secondaryWeapon _pairedUnit == _podWeaponClass) then {
				private _unitAlreadyAssigned = [_unit] call _fnc_isUnitAlreadyAssigned;
				private _pairedUnitAlreadyAssigned = [_pairedUnit] call _fnc_isUnitAlreadyAssigned;

				if (!_unitAlreadyAssigned && {!_pairedUnitAlreadyAssigned}) then {
					private _vehicleType = "";

					{
						if ((_x select 1) isEqualTo [_staticTurretClass, _staticPodVehicleClass]) exitWith {
							_vehicleType = _x select 0;
						};
					} forEach A3C_IFA_StaticPartPairs;

					if (_vehicleType != "") then {
						A3C_STATIC_PACKS pushBack [
							[_unit, _pairedUnit],
							_vehicleType
						];
					};
				};
			};
		} forEach _candidateUnits;
	};
} forEach _units;


if (_mode == "EXECUTING") exitWith {
	+A3C_STATIC_PACKS
};


//-- Remove static weapons that are already planned in existing unit plot data.
private _plannedWeapons = [];

{
	private _staticPack = _x;
	private _staticPackUnits = _staticPack select 0;
	private _firstUnit = _staticPackUnits select 0;
	private _weaponClass = _staticPack select 1;

	private _unitPlotData = (
		(_firstUnit getVariable ["A3C_PLOT", []]) +
		(_firstUnit getVariable ["A3C_PLOT_TEMP", []])
	);

	{
		_x params [
			"_wpPositions",
			"_wpMarkers",
			"_wpAction",
			"_wpCondition",
			"_wpStances",
			"_wpSyncData",
			"_wpCompleted",
			"_wpCombatMode",
			"_wpSpeed",
			"_wpFlyInHeight",
			"_wpLoopValue",
			"_wpRadius"
		];

		if (_wpAction select 0 == "STATIC") then {
			private _staticAction = _wpAction select 1;

			if (_staticAction select 0 == "ASSEMBLE") then {
				if (_staticAction select 1 == _weaponClass) then {
					private _marker = _wpMarkers select 0;

					if ({(_x select 0) == _marker} count _plannedWeapons == 0) then {
						_plannedWeapons pushBack [_marker, _weaponClass];
					};
				};
			};
		};
	} forEach _unitPlotData;
} forEach A3C_STATIC_PACKS;

{
	private _plannedWeaponClass = _x select 1;

	{
		private _staticPack = _x;
		private _staticPackWeaponClass = _staticPack select 1;

		if (_plannedWeaponClass == _staticPackWeaponClass) exitWith {
			A3C_STATIC_PACKS = A3C_STATIC_PACKS - [_staticPack];
		};
	} forEach A3C_STATIC_PACKS;
} forEach _plannedWeapons;

+A3C_STATIC_PACKS