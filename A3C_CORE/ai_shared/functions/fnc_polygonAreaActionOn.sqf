// A3C_ai_shared_fnc_polygonAreaActionOn

/*
	Takes different types of inputs:
	1. [_position,""] >> coming from 3D-Indicator / Positional Suppression
	2. ["A3C_HC_POLY",0] >> coming from HC-Waypoint //-- 0 does not represent waypoint index
*/

params [
	"_units",
	"_input",
	"_actionType",
	["_draw", false],
	["_wpI", -1]
];

private _target = 0;
private _polygon = [];
private _group = group (_units select 0);

// Remove players from suppressing/action units.
_units = _units select {
	!isPlayer _x
};

if (_units isEqualTo []) exitWith {};

private _exit = false;
private _isPlayerGroup = ({ player == leader group _x } count _units) == (count _units);

//-- STEP 01: determine polygon and draw if necessary

if ((_input select 1) isEqualType "") then {
	// _input is position -> order is coming from suppression indicator.
	// Polygon must be created.

	if (_draw) then {
		private _dirTo = [_units select 0, _input select 0] call BIS_fnc_dirTo;

		(_input select 1) setMarkerDirLocal _dirTo;

		private _idVal = if (_isPlayerGroup) then {
			getPlayerUID player
		} else {
			0100101001010100101010010101001
		};

		_input set [
			1,
			format ["A3C_SUP_MAIN_Mark_%1_%2", _idVal, A3C_SUP_POLY_IND_MARK]
		];

		A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;

		_polygon = [_input] + (
			[
				_input select 0,
				_dirTo,
				_actionType,
				true,
				_units
			] call A3C_ai_shared_fnc_polygonAreaCreate
		);

		{
			private _unitPolys = _x getVariable ["A3C_UNIT_POLYS", []];
			_unitPolys pushBack _polygon;
			_x setVariable ["A3C_UNIT_POLYS", _unitPolys, true];
		} forEach _units;
	};
} else {
	if ((_input select 0) isEqualType "") then {
		// HC: polygon already displayed, will be taken from group's variable.

		private _groupPolys = _group getVariable ["A3C_UNIT_POLYS", []];

		if !(_groupPolys isEqualTo []) then {
			_polygon = [];

			{
				if (((_x select 0) select 2) == _wpI) exitWith {
					_polygon = _x;
				};
			} forEach _groupPolys;

			_group setVariable ["A3C_POLY_ACTIVE", _polygon, true];
		} else {
			_exit = true;
		};
	} else {
		// Default: input was given as polygon array.
		_polygon = _input;
	};
};

private "_center";

if !(_polygon isEqualTo []) then {
	_center = (_polygon select 0) select 0;
};

if (isNil "_center") exitWith {
	systemChat "Oops.. something went wrong. No poly detected";
};

if !(_group == group player) then {
	_group setFormDir ([leader _group, _center] call BIS_fnc_dirTo);
};

//-- shared vars for all modes

if (_exit) exitWith {};

{
	private _unit = _x;

	if (group _unit == group player) then {
		_unit setVariable ["A3C_POLY_ACTIVE", _polygon, true];

		private _expectedDestination = expectedDestination _unit;

		if ((_expectedDestination select 0) distance2D [0, 0, 0] < 1) then {
			_expectedDestination set [0, position vehicle _unit];
		};

		_unit setVariable ["A3C_DEST", _expectedDestination, true];
	};
} forEach _units;

//-- STEP 02: Assign action

switch (_actionType) do {
	case "SUPPRESSION": {
		private _aiSuppressionRef = +A3C_SUPPRESSION_UNITS_AI;
		private _suppressionUnits = [];
		private _remoteFireUnits = [];
		private _artyFireUnits = [];

		{
			private _unit = _x;
			private _vehicle = vehicle _unit;
			private _addUnit = true;
			private _gunnerUnit = true;

			if (!isNull objectParent _unit) then {
				if !(_unit == gunner _vehicle) then {
					_gunnerUnit = false;
				};
			};

			if (_gunnerUnit) then {
				if !(isPlayer _unit) then {
					// Remove statics with guided ammo / artilleryAmmo from suppressing units.
					// These will be accessible via FOCUS GROUP REMOTE FIRE.
					if (_vehicle isKindOf "STATICWEAPON") then {
						private _turretMags = getArray (
							configFile >> "CfgVehicles" >> typeOf _vehicle >> "Turrets" >> "MainTurret" >> "magazines"
						);

						{
							private _ammoType = getText (
								configFile >> "CfgMagazines" >> _x >> "ammo"
							);

							private _lock = getNumber (
								configFile >> "CfgAmmo" >> _ammoType >> "weaponLockSystem"
							);

							if (_lock > 0) then {
								_addUnit = false;
								_remoteFireUnits pushBack _unit;
							};
						} forEach _turretMags;

						if (
							getNumber (
								(configOf _vehicle)
								>> "artilleryScanner"
							) > 0
						) then {
							// Artillery platforms are never used for generic suppression.
							_addUnit = false;

							// Only recommend ARTILLERY if the weapon can currently fire artillery.
							if ((getArtilleryAmmo [_vehicle]) isNotEqualTo []) then {
								_artyFireUnits pushBack _unit;
							};
						};
					};

					if (_addUnit) then {
						_suppressionUnits pushBack _unit;
					};
				};
			};
		} forEach _units;

		/*
			Publish the exact controller-participation state before spawning
			the controller scripts. This prevents the HC completion monitor
			from observing an all-false startup window.

			Rejected drivers, cargo units, players and unsupported units remain
			inactive.
		*/
		{
			_x setVariable [
				"A3C_POLY_ACTION_ACTIVE",
				_x in _suppressionUnits,
				true
			];
		} forEach _units;

		if (_suppressionUnits isEqualTo []) then {
			if (!((_remoteFireUnits + _artyFireUnits) isEqualTo [])) then {
				private _remoteString = if !(_remoteFireUnits isEqualTo []) then {
					"FOCUS GROUP "
				} else {
					""
				};

				private _artyString = if !(_artyFireUnits isEqualTo []) then {
					"ARTILLERY "
				} else {
					""
				};

				private _artyAddString = "";

				if !(_artyFireUnits isEqualTo []) then {
					if (_remoteFireUnits isEqualTo []) then {
						_artyAddString = if ({ group _x == group player } count _artyFireUnits > 0) then {
							" (A3 Squad Controls)"
						} else {
							" (map >> groupContextMenu)"
						};
					};
				};

				private _orString = "";
				private _pluralString = "";

				if (!(_remoteFireUnits isEqualTo []) && { !(_artyFireUnits isEqualTo []) }) then {
					_orString = "or ";
					_pluralString = "s";
				};

				systemChat (
					"A3C: Suppression not possible with current selection. Try " +
					_remoteString +
					_orString +
					_artyString +
					"method" +
					_pluralString +
					_artyAddString +
					" instead!"
				);
			} else {
				systemChat "A3C: Suppression not possible with ciurrent selection";
			};
		};

		{
			private _unit = _x;

			if (player == leader group _unit) then {
				A3C_SUPPRESSION_UNITS_SQ pushBackUnique _unit;
			} else {
				A3C_SUPPRESSION_UNITS_AI pushBackUnique _unit;
			};

			_target = "A3C_Supression_Target_F" createVehicle ((_polygon select 0) select 0);
			_target setPos ((_polygon select 0) select 0);
			_target enableSimulation false;

			_unit doTarget _target;

			[
				_unit,
				"SUPPRESSION",
				(_polygon select 0) select 1,
				_target
			] spawn A3C_ai_shared_fnc_polygonAreaActionLoop;

			private _polygonMarkerId =
				(_polygon select 0) param [
					1,
					"",
					[""]
				];

			_unit setVariable [
				"A3C_SUPPRESSION_TARGET",
				[
					_target,
					true,
					_polygonMarkerId,
					-1
				],
				true
			];

			if (_unit in (units player)) then {
				[_unit, ["COMBATMODE", "YELLOW"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
			} else {
				_unit setCombatMode "YELLOW";
			};
		} forEach _suppressionUnits;

		if !(_aiSuppressionRef isEqualTo A3C_SUPPRESSION_UNITS_AI) then {
			publicVariable "A3C_SUPPRESSION_UNITS_AI";
		};
	};

	case "AMBUSH": {
		{
			private _unit = _x;

			_unit setVariable [
				"A3C_POLY_ACTION_ACTIVE",
				true,
				true
			];

			if (_unit in (units player)) then {
				[_unit, ["COMBATMODE", "BLUE"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
				[_unit, ["BEHAVIOUR", "SAFE"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
			} else {
				_unit setCombatMode "BLUE";
				_unit setBehaviour "SAFE";
			};

			_unit setUnitPos "DOWN";
			_unit doWatch _center;

			[
				_unit,
				"AMBUSH",
				(_polygon select 0) select 1,
				_target
			] spawn A3C_ai_shared_fnc_polygonAreaActionLoop;
		} forEach _units;
	};

	case "DEFEND": {
		// Placeholder
	};

	case "THROW": {
		// Placeholder
	};

	case "PLANT": {
		// Placeholder
	};

	case "ASSEMBLE": {
		// Placeholder
	};
};