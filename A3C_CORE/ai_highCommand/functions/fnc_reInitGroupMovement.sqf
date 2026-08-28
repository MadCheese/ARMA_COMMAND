// A3C_ai_highCommand_fnc_reInitGroupMovement


params ["_group"];

private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

private _speedLimit = _leaderVehicle getVariable ["A3C_LIMIT_SPEED", false];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;
	

	{
		_unit enableAI _x;
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
			_vehicle enableAI _x;
		} forEach ["MOVE", "PATH"];
	};
	
	if (
		_unit != _leader
		&& {objectParent _unit != objectParent _leader}
	) then {
		_unit commandFollow _leader;
	};
} forEach (units _group);