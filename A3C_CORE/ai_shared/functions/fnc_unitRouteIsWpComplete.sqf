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
	_timeout isEqualTo 0
	&& {_vehicle isKindOf "Air"}
	&& {
		(_unit getVariable ["A3C_CURRENTWAYPOINT_INDEX", -1]) !=
		(count (_unit getVariable ["A3C_PLOT", []]))
	}
) then {
	_effectiveDistance = 500;
};

private _precision = (
	getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "precision")
) + _effectiveDistance;

// -- Movement completion commands report the state of the engine movement
// -- order; they do not prove that an exact 3D destination was reached.
// -- On-foot waypoints therefore always retain an independent height check.
private _heightIsValid = true;

if (_isOnFoot) then {
	private _unitHeightATL = getPosATL _unit select 2;
	private _wpHeightATL = _wpPos param [2, 0];

	_heightIsValid = (abs (_unitHeightATL - _wpHeightATL)) < 1;
	_precision = 1.5;
};

private _distance2D = _vehicle distance2D _wpPos;
private _completionFactor = if (_isOnFoot) then {
	10
} else {
	1.5
};

private _isUnitReady = false;
private _isMoveToCompleted = false;

// -- These engine states may widen the accepted distance, but they must never
// -- override the independent height or enemy-clearance checks below.
if (!isPlayer (effectiveCommander _vehicle)) then {
	_isUnitReady = unitReady _unit;
	_isMoveToCompleted = moveToCompleted _unit;
};

private _isWithinNormalDistance = _distance2D < _precision;
private _isWithinEngineCompletedDistance = (
	(_isUnitReady || {_isMoveToCompleted})
	&& {_distance2D < (_precision * _completionFactor)}
);

private _isComplete = (
	_heightIsValid
	&& {
		_isWithinNormalDistance
		|| {_isWithinEngineCompletedDistance}
	}
);

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
		"completion candidate %1 | unitReady: %2 | moveToCompleted: %3 | height valid: %4 | distance2D: %5",
		_isComplete,
		_isUnitReady,
		_isMoveToCompleted,
		_heightIsValid,
		_distance2D
	];
};

if (_isComplete && {A3C_DEBUG}) then {
	systemChat "waypoint was reached";
};

_isComplete
