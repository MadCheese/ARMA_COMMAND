// A3C_ai_shared_fnc_unitRouteIsWpComplete
// Checks if a unit has completed/reached a route waypoint.

params [
	"_unit",
	"_wpPos",
	"_variableDistance",
	["_unusedArg", objNull],
	["_radius", 0],
	["_timeout", false]
];

if (isNull _unit) exitWith {
	false
};

if (isPlayer _unit) exitWith {
	true
};

private _parentVehicle = objectParent _unit;
private _isOnFoot = isNull _parentVehicle;
private _vehicle = vehicle _unit;

private _effectiveDistance = _variableDistance + _radius;

if (
	_timeout isEqualTo 0 &&
	{ _vehicle isKindOf "Air" } &&
	{
		(_unit getVariable ["A3C_CURRENTWAYPOINT_INDEX", -1]) !=
		(count (_unit getVariable ["A3C_PLOT", []]))
	}
) then {
	_effectiveDistance = 500;
};

private _precision = (
	getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "precision")
) + _effectiveDistance;

private _isComplete = false;

if (_isOnFoot) then {
	private _unitHeightATL = (getPosATL _unit) select 2;
	private _wpHeightATL = _wpPos param [2, 0];

	if ((abs (_unitHeightATL - _wpHeightATL)) < 1) then {
		_precision = 1.5;

		if ((_vehicle distance2D _wpPos) < _precision) then {
			_isComplete = true;

			// Experimental: do not move on unless room is clear.
			private _nearEnemies = [
				side _unit,
				10,
				"ENEMY",
				_wpPos,
				["MAN"]
			] call MCSS_fnc_NearEntities;

			{
				if ([_x, _unit] call MCSS_fnc_lineOfSightSimple) exitWith {
					_isComplete = false;
				};
			} forEach _nearEnemies;
		};
	};
} else {
	if ((_vehicle distance2D _wpPos) < _precision) then {
		_isComplete = true;
	};
};

private _completionFactor = if (_isOnFoot) then {
	10
} else {
	1.5
};

if (!isPlayer (effectiveCommander _vehicle)) then {
	if (unitReady _unit || { moveToCompleted _unit }) then {
		if ((_vehicle distance2D _wpPos) < (_precision * _completionFactor)) then {
			if (A3C_DEBUG) then {
				systemChat format [
					"complete %1 | unitReady: %2 | moveToCompleted: %3",
					_isComplete,
					unitReady _unit,
					moveToCompleted _unit
				];
			};

			_isComplete = true;
		};
	};
};

if (_isComplete && { A3C_DEBUG }) then {
	systemChat "waypoint was reached";
};

_isComplete