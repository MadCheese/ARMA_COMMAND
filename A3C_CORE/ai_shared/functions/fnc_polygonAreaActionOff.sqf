// A3C_ai_shared_fnc_polygonAreaActionOff

params ["_units", "_mode"];

// Empty selection means auto-select all player-group suppression units.
if (_units isEqualTo []) then {
	if (!isNull player) then {
		_units = A3C_SUPPRESSION_UNITS_SQ;
	};
};

if (_units isEqualTo []) exitWith {};

private _poly = [];

switch (_mode) do {
	case "SUPPRESSION": {
		private _refAIUnits = +A3C_SUPPRESSION_UNITS_AI;

		{
			private _unit = _x;
			private _isPlayerGroup = _unit in (units player);

			/*
				Signal the controller first. This prevents another shot from
				being issued while the remaining cleanup is performed.
			*/
			_unit setVariable [
				"A3C_POLY_ACTION_ACTIVE",
				false,
				true
			];

			private _isMounted = !isNull objectParent _unit;
			private _firingObject = if (_isMounted) then {
				vehicle _unit
			} else {
				_unit
			};

			/*
				Stop the forced firing command before removing its handler.
			*/
			if (!isNull _firingObject) then {
				if (_isMounted) then {
					[
						_firingObject,
						[objNull]
					] remoteExecCall [
						"fireAtTarget",
						_firingObject
					];
				} else {
					[
						_unit,
						["", ""]
					] remoteExecCall [
						"forceWeaponFire",
						_unit
					];
				};

				/*
					No token is passed deliberately. Manual cancellation owns
					the complete suppression state and may remove whichever
					suppression handler is currently installed.
				*/
				[
					[_firingObject],
					A3C_ai_shared_fnc_removeEventhandlerFired
				] remoteExecCall [
					"BIS_fnc_call",
					_firingObject
				];
			};

			[
				_unit,
				objNull
			] remoteExecCall ["doTarget", _unit];

			[
				_unit,
				objNull
			] remoteExecCall ["doWatch", _unit];

			[
				_unit,
				objNull
			] remoteExecCall ["lookAt", _unit];

			private _targetData = _unit getVariable [
				"A3C_SUPPRESSION_TARGET",
				[objNull]
			];

			private _target = _targetData param [0, objNull];

			if (
				_target isEqualType objNull
				&& {!isNull _target}
			) then {
				deleteVehicle _target;
			};

			_unit setVariable [
				"A3C_SUPPRESSION_TARGET",
				[0, false, -1],
				true
			];

			private _polyOwner = if (_isPlayerGroup) then {
				_unit
			} else {
				group _unit
			};

			_poly = _polyOwner getVariable [
				"A3C_POLY_ACTIVE",
				[]
			];

			_polyOwner setVariable [
				"A3C_POLY_ACTIVE",
				[],
				true
			];

			[
				_unit,
				_poly
			] call A3C_ai_shared_fnc_polygonAreaRemove;

			[
				_unit
			] call A3C_ai_squad_fnc_actionResumeDestination;

			A3C_SUPPRESSION_UNITS_SQ =
				A3C_SUPPRESSION_UNITS_SQ - [_unit];

			A3C_SUPPRESSION_UNITS_AI =
				A3C_SUPPRESSION_UNITS_AI - [_unit];
		} forEach _units;

		if !(_refAIUnits isEqualTo A3C_SUPPRESSION_UNITS_AI) then {
			publicVariable "A3C_SUPPRESSION_UNITS_AI";
		};
	};

	case "AMBUSH": {
		{
			private _unit = _x;
			private _isPlayerGroup = _unit in (units player);

			_unit setBehaviour "AWARE";
			_unit setUnitPos "AUTO";
			_unit setCombatMode "YELLOW";
			_unit doWatch objNull;

			private _polyOwner = if (_isPlayerGroup) then {
				_unit
			} else {
				group _unit
			};

			_poly = _polyOwner getVariable "A3C_POLY_ACTIVE";
			_polyOwner setVariable ["A3C_POLY_ACTIVE", [], true];

			[_unit, _poly] call A3C_ai_shared_fnc_polygonAreaRemove;
		} forEach _units;
	};

	case "DEFEND": {
	};
};

showCommandingMenu "";