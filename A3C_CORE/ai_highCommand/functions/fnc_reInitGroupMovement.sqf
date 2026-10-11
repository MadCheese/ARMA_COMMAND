// A3C_ai_highCommand_fnc_reInitGroupMovement


params ["_group", ["_preserveHeliPath", false]];

// Overwatch captures/restores PATH itself. A generic restart releases it BEFORE
// movement reset, and must not immediately overwrite the restored false value.
private _owRun = _group getVariable ["A3C_OW_Run", createHashMap];
if (!_preserveHeliPath && {count _owRun > 0}) then {
	["releaseGroup", _group, "movement reinitialization"] call A3C_main_fnc_heliOverwatchLifecycle;
	_preserveHeliPath = true;
};

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

private _speedLimit = _leaderVehicle getVariable ["A3C_LIMIT_SPEED", false];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;
	private _keepPath = _preserveHeliPath && {!isNull _vehicle} && {_vehicle isKindOf "Helicopter"}
		&& {[_vehicle] call A3C_main_fnc_isAttackHelicopter};
	

	{
		if (_x != "PATH" || {!_keepPath}) then {_unit enableAI _x;};
	} forEach ["MOVE", "PATH"];

	if (!isNull _vehicle && {_unit == driver _vehicle}) then {

		if (
			!(_speedLimit)
			|| {_vehicle != _leaderVehicle}
		) then {
			_vehicle limitSpeed false;
		};
		
		if (_vehicle isKindOf "AIR") then {
			private _flyInHeight = _vehicle getVariable ["A3C_FLYINHEIGHT", 75];
			_vehicle flyInHeight _flyInHeight;
			_vehicle land "NONE";
		};
		{
			if (_x != "PATH" || {!_keepPath}) then {_vehicle enableAI _x;};
		} forEach ["MOVE", "PATH"];
	};
	
	if (
		_unit != _leader
		&& {objectParent _unit != objectParent _leader}
	) then {
		_unit commandFollow _leader;
	};
} forEach (units _group);
