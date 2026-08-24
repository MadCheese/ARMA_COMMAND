// A3C_ai_shared_fnc_polygonAreaActionLoop
// Note/trick: in order to make the unit fire no matter what, set the height to 1000.

params ["_unit"];

private _vehicle = vehicle _unit;

if (isPlayer _unit) exitWith {};

private _exit = false;

while { alive _unit } do {
	if (!isNull objectParent _unit) then {
		_exit = true;
	} else {
		if (!isPlayer leader group _unit) then {
			if (_unit distance formationPosition _unit < 3) then {
				_exit = true;
			};
		} else {
			_exit = true;
		};
	};

	if (_exit) exitWith {};

	sleep 0.1;
};

if (_vehicle isKindOf "PLANE") exitWith {};

if !(alive _unit) exitWith {};

private _mode = _this select 1;
private _polyMarker = _this select 2;
private _target = if ((count _this) > 3) then {
	_this select 3
} else {
	objNull
};

private _groupPlayer = _unit in (units player);
private _actual = if (_groupPlayer) then {
	_unit
} else {
	group _unit
};

private _getCurrentPolygon = {
	params [
		"_polygonOwner",
		"_polygonMarkerId"
	];

	private _currentPolygons =
		_polygonOwner getVariable [
			"A3C_UNIT_POLYS",
			[]
		];

	private _polygonIndex =
		_currentPolygons findIf {
			((_x select 0) select 1)
				== _polygonMarkerId
		};

	if (_polygonIndex == -1) exitWith {
		[]
	};

	+(_currentPolygons select _polygonIndex)
};

private _polys = [];
private _polyID = -1;
private _exitMain = true;

private _restrictiveArray = profileNamespace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED", 0]];
private _restrictiveType = _restrictiveArray select 0;
private _restrictiveValue = _restrictiveArray select 1;

private _usedMagazine = currentMagazine _unit;

private _restrictiveOrigin = switch (_restrictiveType) do {
	case "UNLIMITED": {
		0
	};

	case "MAGAZINE": {
		{ _x == _usedMagazine } count magazines _unit
	};

	case "PERCENTAGE": {
		round (({ _x == _usedMagazine } count magazines _unit) * (_restrictiveValue / 100))
	};

	case "TIME": {
		time
	};
};

private _restrictiveFnc = switch (_restrictiveType) do {
	case "UNLIMITED": {
		{ false }
	};

	case "MAGAZINE": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			private _magCount = { _x == _usedMagazine } count magazines _unit;

			_magCount <= ((_restrictiveOrigin - _restrictiveValue) max 1)
		}
	};

	case "PERCENTAGE": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			private _magCount = { _x == _usedMagazine } count magazines _unit;

			_magCount <= (_restrictiveOrigin max 1)
		}
	};

	case "TIME": {
		{
			params ["_usedMagazine", "_restrictiveOrigin", "_restrictiveValue"];

			time > _restrictiveOrigin + _restrictiveValue
		}
	};
};

// If unit has AI leader and waypoints, waypoint conditions override restrictions.
if !(isPlayer leader group _unit) then {
	if ((count waypoints group _unit) > 0) then {
		_restrictiveFnc = { false };
	};
};

// If unit has squad-level waypoints assigned, waypoint conditions override restrictions.
if ((count (_unit getVariable ["A3C_PLOT", []])) > 0) then {
	_restrictiveFnc = { false };
};

private _exitRestrictive = false;

switch (_mode) do {
	case "SUPPRESSION": {
		_unit setVariable ["A3C_POLY_ACTION_ACTIVE", true, true];

		// Put in AWARE.
		if !(isPlayer leader group _unit) then {
			if !(behaviour _unit in ["AWARE", "COMBAT"]) then {
				[leader group _unit, "AWARE"] remoteExec ["setBehaviour", leader group _unit];
			};
		};

		(vehicle _unit) setVariable ["A3C_AIM_ADJUST", 0, true];

		private _targetFnc = {
			params ["_unit", "_target"];

			private _targetPos = position _target;

			[_unit, [_target, 4]] remoteExec ["reveal", _unit];
			[_unit, _target] remoteExec ["doTarget", _unit];

			[_unit, objNull] remoteExec ["lookAt", _unit];
			[_unit, _targetPos] remoteExec ["lookAt", _unit];
		};

		while { !isNull _target } do {
			if (isNull _unit) exitWith {};
			if (!alive _unit) exitWith {};

			private _currentPolygon = [
				_actual,
				_polyMarker
			] call _getCurrentPolygon;

			if (_currentPolygon isEqualTo []) exitWith {};

			if (_exitRestrictive) exitWith {
				[[_unit], "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;

				_unit groupChat (
					[
						"SUPPRESSION COMPLETE!",
						"SUPPRESSION COMPLETE!",
						"I'M DONE SUPPRESSING",
						"I'M NO LONGER SUPPRESSING!"
					] call BIS_fnc_selectRandom
				);
			};

			private _pos = [];
			private _cycle = 0;

			_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

			private _polygon = [];
			_exitMain = true;

			{
				if (((_x select 0) select 1) == _polyMarker) exitWith {
					_polygon = +_x;
					_exitMain = false;
				};
			} forEach _polys;

			if (_exitMain) exitWith {};

			private _center = (_polygon select 0) select 0;
			_polyID = if ((count (_polygon select 0)) > 2) then {
				(_polygon select 0) select 2
			} else {
				-1
			};

			private _polygonData = _polygon select 1;
			private _height = _center select 2;

			_center = ATLToASL _center;

			private _heightASL = ((ATLToASL _center) select 2) + 0.7;
			private _radius = 0;
			private _mainDest = (expectedDestination _unit) select 0;

			if (isNull objectParent _unit) then {
				[_unit, _target] remoteExec ["doTarget", _unit];
			};

			sleep 1;

			{
				private _distance = _x distance2D _center;

				if (_distance > _radius) then {
					_radius = _distance;
				};
			} forEach _polygonData;

			if (!isPlayer leader group _unit) then {
				if (isNull objectParent _unit) then {
					_unit setUnitPos "MIDDLE";
				};
			};

			while { !isNull _target } do {
				if ([_usedMagazine, _restrictiveOrigin, _restrictiveValue] call _restrictiveFnc) exitWith {
					_exitRestrictive = true;
				};

				private _currentPolygon = [
					_actual,
					_polyMarker
				] call _getCurrentPolygon;

				if (_currentPolygon isEqualTo []) exitWith {};

				_exit = false;
				_cycle = _cycle + 1;

				if (_cycle > 300) exitWith {
					_exitMain = true;
				};

				_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

				if !(_polygon in _polys) exitWith {
					if ({ ((_x select 0) select 1) == _polyMarker } count _polys == 0) then {
						_exitMain = true;
					};
				};

				_pos = [_center, _radius] call BIS_fnc_randomPosTrigger;

				if (_pos inPolygon _polygonData) then {
					_pos set [2, (_pos select 2) + 0.7];

					if ([vehicle _unit, _pos, _target, false] call MCSS_fnc_lineOfSightSimple) then {
						private _dir = [_pos, _unit] call BIS_fnc_dirTo;

						_pos = [_pos, 5, _dir] call BIS_fnc_relPos;
						_exit = true;

						if (_height >= 1) then {
							[_target, _pos] remoteExec ["setPosASL", _target];
						} else {
							[_target, ((_pos select [0, 2]) + [0])] remoteExec ["setPos", _target];
						};
					} else {
						private _lineIntersections = lineIntersectsSurfaces [
							[_unit] call MCSS_fnc_getViewPosASL,
							_pos,
							vehicle _unit,
							objNull
						];

						if ((count _lineIntersections) > 0) then {
							_pos = (_lineIntersections select 0) select 0;

							if (_pos inPolygon _polygonData) then {
								_exit = true;
								_height = (ASLToATL _pos) select 2;

								if (_height >= 1) then {
									_target setPosASL _pos;
								} else {
									_target setPos ((_pos select [0, 2]) + [0]);
								};
							};
						};
					};
				};

				if (_exit) exitWith {};
			};

			if (_vehicle isKindOf "HELICOPTER") then {
				if (!isPlayer driver _vehicle) then {
					[_vehicle, 0] remoteExec ["limitSpeed", _vehicle];

					while { canMove _vehicle } do {
						if (speed _vehicle < 2) exitWith {};
					};

					[_vehicle, "ALL"] remoteExec ["disableAI", _vehicle];
					[driver _vehicle, "ALL"] remoteExec ["disableAI", driver _vehicle];

					sleep 1;

					if (speed _vehicle < 1) then {
						private _orientPos = position _target;
						private _rotateScript = [_vehicle, _orientPos] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;

						waitUntil {
							scriptDone _rotateScript ||
							{ !canMove _vehicle } ||
							{
								([
									_actual,
									_polyMarker
								] call _getCurrentPolygon) isEqualTo []
							}
						};

						if (
							([
								_actual,
								_polyMarker
							] call _getCurrentPolygon) isEqualTo []
						) then {
							_exitMain = true;
						};
					} else {
						_exitMain = true;
					};
				};
			};

			if (_exitMain && { _groupPlayer }) exitWith {
				_unit groupChat (
					[
						"Can not comply",
						"I can't see the target",
						"Target out of sight"
					] call BIS_fnc_selectRandom
				);

				[[_unit], "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
			};

			// Refresh order.
			[_unit, [_target, 4]] remoteExec ["reveal", _unit];

			if (isNull objectParent _unit) then {
				[_unit, _target] remoteExec ["doTarget", _unit];
			} else {
				[_unit, _target] call _targetFnc;
			};

			sleep 1;

			if (isNull objectParent _unit) then {
				[_unit, _target] remoteExec ["doSuppressiveFire", _unit];
			} else {
				[[vehicle _unit, _target], A3C_ai_shared_fnc_addEventhandlerFired] remoteExec ["BIS_fnc_call", 0];

				private _handle = {};

				[
					_unit,
					_vehicle,
					_target,
					_handle,
					_targetFnc
				] spawn {
					params ["_unit", "_vehicle", "_target", "_handle", "_targetFnc"];

					for "_i" from 1 to 3 do {
						for "_l" from 1 to 10 do {
							if (!isNull _target) then {
								if (
									(_vehicle isKindOf "HELICOPTER") ||
									{ [position _target, _unit, 10] call MCSS_fnc_lineOfSightVehicle }
								) then {
									private _magType = currentMagazine vehicle _unit;
									private _currentAmmo = getText (
										configFile >> "CfgMagazines" >> _magType >> "ammo"
									);

									private _lock = getNumber (
										configFile >> "CfgAmmo" >> _currentAmmo >> "weaponLockSystem"
									);

									if (_lock == 0) then {
										[vehicle _unit, [_target]] remoteExec ["fireAtTarget", vehicle _unit];
										sleep 0.1;
									};
								};
							};
						};

						sleep 2;
					};

					[[vehicle _unit], A3C_ai_shared_fnc_removeEventhandlerFired] remoteExec ["BIS_fnc_call", 0];
				};
			};

			private _count = 0;
			private _origPos = position _unit;

			// Firing cycle - units are already firing.
			// This loop waits for the suppression cycle to complete.
			while { alive _unit } do {
				if ([_usedMagazine, _restrictiveOrigin, _restrictiveValue] call _restrictiveFnc) exitWith {
					_exitRestrictive = true;
				};

				// Exit if poly no longer exists.
				private _currentPolygon = [
					_actual,
					_polyMarker
				] call _getCurrentPolygon;

				if (_currentPolygon isEqualTo []) exitWith {};

				// Exit and reset loop if polygon was dragged.
				private _currentCenter =
					(_currentPolygon select 0) select 0;

				if (
					_currentCenter distance2D _center > 1
				) exitWith {
					sleep 1;
				};

				_count = _count + 1;

				sleep 1;

				_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

				if !(_polygon in _polys) exitWith {
					{
						if (((_x select 0) select 1) == _polyMarker) then {
							_target setPos ((_x select 0) select 0);
						};
					} forEach _polys;
				};

				private _expectedDestination = expectedDestination _unit;

				if !((toLower currentCommand _unit) in ["attack", "suppress", "", "scripted"]) exitWith {
					_exitMain = true;
				};

				if !(_unit getVariable "A3C_POLY_ACTION_ACTIVE") exitWith {
					_exitMain = true;
				};

				if ((_mainDest distance2D (_expectedDestination select 0)) > 5) then {
					if (_unit distance2D _origPos > 2) then {
						_exitMain = true;
					};
				};

				if (_exitMain) exitWith {};
			};

			if (_exitMain && { _groupPlayer }) exitWith {
				if !(isNull _target) then {
					[_unit, _polygon] call A3C_ai_shared_fnc_polygonAreaRemove;
				};
			};
		};

		if (!isPlayer _unit) then {
			if !(isPlayer leader group _unit) then {
				// Preserved original condition, even though objectParent is null in this branch.
				if (isNull objectParent _unit && { _unit == driver objectParent _unit }) then {
					[_unit, formationPosition _unit] remoteExec ["doMove", _unit];
					[_unit, formationPosition _unit] remoteExec ["moveTo", _unit];
				};
			};
		};

		if (!isPlayer leader group _unit) then {
			if (isNull objectParent _unit) then {
				_unit setUnitPos "AUTO";
			};
		};

		_unit setVariable ["A3C_POLY_ACTION_ACTIVE", false, true];

		if (_vehicle isKindOf "HELICOPTER") then {
			[_vehicle, "ALL"] remoteExec ["enableAI", _vehicle];
			[driver _vehicle, "ALL"] remoteExec ["enableAI", driver _vehicle];
			[_vehicle, false] remoteExec ["limitSpeed", _vehicle];
		};
	};

	case "AMBUSH": {
		_unit setVariable ["A3C_POLY_ACTION_ACTIVE", true, true];

		while { alive _unit } do {
			_polys = _actual getVariable ["A3C_UNIT_POLYS", []];

			if ({ ((_x select 0) select 1) == _polyMarker } count _polys == 0) then {
				_exitMain = true;
			};

			private _polygon = [];
			_exitMain = true;

			{
				if (((_x select 0) select 1) == _polyMarker) exitWith {
					_polygon = +_x;
					_exitMain = false;
				};
			} forEach _polys;

			if !(_unit getVariable "A3C_POLY_ACTION_ACTIVE") exitWith {
				_exitMain = true;
			};

			if (_exitMain) exitWith {};

			private _center = (_polygon select 0) select 0;
			_polyID = (_polygon select 0) select 2;

			private _polygonData = _polygon select 1;
			private _radius = 0;
			private _origPos = position _unit;

			{
				private _distance = _x distance2D _center;

				if (_distance > _radius) then {
					_radius = _distance;
				};
			} forEach _polygonData;

			if !(_polygon in _polys) then {
				systemChat "turns out this COULD happen";
			};

			private _expectedDestination = expectedDestination _unit;
			private _mainDest = _expectedDestination select 0;

			if ((_mainDest distance2D (_expectedDestination select 0)) > 5) then {
				if (_unit distance2D _origPos > 2) then {
					_exitMain = true;
				};
			};

			if (_exitMain) exitWith {};

			private _targets = [
				side _unit,
				_radius,
				"ENEMY",
				_center,
				["MAN", "CAR", "TANK"]
			] call MCSS_fnc_nearEntities;

			private _pause = if ((count _targets) > 0) then {
				0.1
			} else {
				1
			};

			if ({ (getPosASL vehicle _x) inPolygon _polygonData } count _targets > 0) exitWith {
				[_unit, "RED"] remoteExec ["setCombatMode", _unit];
				[_unit, "COMBAT"] remoteExec ["setBehaviour", _unit];

				{
					[_unit, [_x, 4]] remoteExec ["reveal", _unit];
				} forEach _targets;

				[
					_unit,
					_targets call BIS_fnc_selectRandom
				] remoteExec ["doSuppressiveFire", _unit];
			};

			sleep _pause;
		};

		[_unit, "YELLOW"] remoteExec ["setCombatMode", _unit];
		[_unit, "AWARE"] remoteExec ["setBehaviour", _unit];
		[_unit, "AUTO"] remoteExec ["setUnitPos", _unit];
	};
};
