// A3C_ai_shared_fnc_unitRouteIsWpComplete
// Checks if a unit has completed/reached a route waypoint.

params [
	"_unit",
	"_wpPos",
	"_variableDistance",
	["_inBuilding", false],
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
	_timeout isEqualTo 0
	&& {_vehicle isKindOf "Air"}
	&& {
		(_unit getVariable ["A3C_CURRENTWAYPOINT_INDEX", -1]) !=
		(count (_unit getVariable ["A3C_PLOT", []]))
	}
) then {
	_effectiveDistance = 500;
};

private _basePrecision = if (_isOnFoot) then {
	1.5
} else {
	getNumber (
		configFile
		>> "CfgVehicles"
		>> typeOf _vehicle
		>> "precision"
	)
};

private _precision = _basePrecision + _effectiveDistance;

// -- Movement completion state does not prove that an exact 3D destination
// -- was reached.
private _heightIsValid = true;

if (_isOnFoot && {_inBuilding}) then {
	private _unitHeightATL = getPosATL _unit select 2;
	private _wpHeightATL = _wpPos param [2, 0];

	_heightIsValid = (abs (_unitHeightATL - _wpHeightATL)) < 1;
};

private _distance2D = _vehicle distance2D _wpPos;

private _engineCompletionDistance = if (_isOnFoot) then {
	_precision max 15
} else {
	_precision * 1.5
};


// -- Normal geometric completion is authoritative and does not require an
// -- engine movement-state query.
private _isWithinNormalDistance = _distance2D < _precision;

private _isEngineMovementComplete = false;
private _isWithinEngineCompletedDistance = false;

private _isComplete = (
	_heightIsValid
	&& {_isWithinNormalDistance}
);


// -- Only query the engine movement state when normal geometric completion
// -- failed and engine completion could actually change the result.
// -- There is no reason to call A3C_main_fnc_isEngineMovementComplete when
// -- already within the normal completion radius, when building height is
// -- invalid, or when outside the wider engine-completion radius.
if (
	!_isComplete
	&& {_heightIsValid}
	&& {!_isWithinNormalDistance}
	&& {_distance2D < _engineCompletionDistance}
) then {
	_isEngineMovementComplete = [_unit] call A3C_main_fnc_isEngineMovementComplete;

	_isWithinEngineCompletedDistance = _isEngineMovementComplete;
	_isComplete = _isEngineMovementComplete;
};


// -- Experimental: do not move on unless the destination area is clear.
// -- Run this after every possible completion path so that an engine-completed
// -- state cannot accidentally bypass it.
if (_isComplete && {_isOnFoot}) then {
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

if (A3C_DEBUG && {_isWithinEngineCompletedDistance}) then {
	systemChat format [
		"completion candidate %1 | engine movement complete: %2 | height valid: %3 | distance2D: %4",
		_isComplete,
		_isEngineMovementComplete,
		_heightIsValid,
		_distance2D
	];
};

if (_isComplete && {A3C_DEBUG}) then {
	systemChat "waypoint was reached";
};

_isComplete