
params ["_group","_pos","_target","_callerUID","_preCondition","_postCondition"];

if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _wp = [_group,currentwaypoint _group];

//-- terminate previous execution
private _currentActions = _group getvariable ["A3C_SCRIPTS",[]];
{
	_x params ["_actionID","_scr"];
	if ("landing_full" in toLower _actionID) then {
		terminate _scr;
		_currentActions = _currentActions - [_x];
	};	
} foreach _currentActions;

_group setvariable ["A3C_SCRIPTS",_currentActions,true]; //-- guarantee at least the 2 sec of no script so that old one can exit

//-- determine landing distance
private _landingDistance = if (_leaderVic isKindOf "PLANE" && {(getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) > 10}) then {
	5000
} else {
	((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) + 50);
};

private _cond = {
	params ["_leaderVic","_landingDistance","_isPlane"];
	private _return = if (_isPlane) then {
		(_leaderVic distance2D _pos) > _landingDistance
	} else {
		!unitReady (driver _leaderVic) OR
		{
			(_leaderVic distance2D _pos) > (_landingDistance * 2)
		}
	};
	_return
};
private _isPlane = _leaderVic isKindOf "PLANE";
while {[_leaderVic,_landingDistance,_isPlane] call _cond} do { //&& (unitReady _leader)
	_leaderVic = vehicle _leader; //-- has to be refreshed in case of crash
	[_group,_pos, true] call A3C_HC_MoveToWaypoint;
	sleep 5;
};

private _drivers = (units _group) select {_oP = objectParent _x; !isNull _oP && {_x == driver _oP}};
private _drivenVics = _drivers apply {vehicle _x;};

{_x limitSpeed 5000} foreach _drivenVics; //-- reset slowdown

//-- compose pre- and post conditions, wait for pre-condition
private _exitCondition = {};
{
	_x params ["_condType","_condVal"];
	_exitCondition = switch (toUpper _condType) do {
		case ("TIMEOUT") : {
			_timeAtCompletion = time + _condVal;
			compile format ["time > %1",_timeAtCompletion];
		};
		case ("GOCODE") : {
			compile format ["A3C_GoCode_Activate_%1",_condVal];
		};
		case ("DAYTIME") : {
			_str = _condVal splitString ":";
			_checkParams = [];
			{
				_checkParams pushBack (parseNumber _X)
			} foreach _str;
			compile format ["%1 call A3C_fnc_DAYTIME_COMPLETED",_checkParams];
		};
		default {{true}};
	};
	if (_foreachIndex == 0) then {
		//systemchat str _exitCondition;
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			_wp setWaypointScript format 
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing.sqf ['%1',%2,%3]",
				_callerUID,
				["ARRIVAL",""],
				_postCondition
			];
			_wp setWaypointPosition [_pos,0];
			systemchat 'ah';
			private _statements = waypointStatements _wp;
			_statements set [0,"true"];
			_wp setWaypointStatements _statements;
		};
	};
} foreach [_preCondition,_postCondition];


//A3C_BLACKLIST_WAYPOINT_EDIT pushbackUnique _wp;
//publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';


_helicopterPilots = (units _group) select {
	_v = objectParent _x;
	!isNull _v && {_x == driver _v && {_v isKindOf "HELICOPTER"}}
};


sleep 2;
private _scr = [_leader,_pos,_callerUID,[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
_currentActions pushBack ["landing_full_1",_scr];
_group setvariable ["A3C_SCRIPTS",_currentActions,true];

[_group,_wp] spawn {
	params ["_group","_wp"];
	private _currentActions = [];
	waitUntil {
		sleep 1;
		_currentActions = _group getvariable ["A3C_SCRIPTS",[]];
		private _cwp = currentWaypoint _group;
		({"landing_full" in (_x select 0)} count _currentActions == 0)  OR 
		{
			_cwp != (_wp select 1) OR 
			{
				waypointType [_group, _cwp] != "SCRIPTED" OR 
				{
					private _wps = waypointScript [_group, _cwp];
					!('wpscript_landing.sqf' in (toLower _wps))
				}
			}
		}
	};
	//systemchat "exit";
	A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];
	{
		_x params ["_actionID","_scr"];
		if ("landing_full" in _actionID) then {
			_currentActions = _currentActions - [_x];
			terminate _scr;
		};
	} foreach _currentActions;
	_group setvariable ["A3C_SCRIPTS",if (count _currentActions > 0) then {_currentActions} else {nil},true];
	{
		private _v = objectParent _x;
		if (!isNull _v && {_x == driver _v && { ((getPosATL _v) select 2) > 1 && {_v isKindOf "AIR"}}}) then {
			_v land "NONE";
			_x setVariable ["A3C_VAR_LANDING",nil,true];
		};
	} foreach (units _group);
	_group setVariable ["A3C_ISwpLANDING",nil,true];
};
waituntil {scriptdone _scr};
_cond = {
	params ["_unit"];
	private _objectParent = objectParent _unit;
	private _return = !isNull _objectParent && 
	{
		_unit == driver _objectParent && 
		{
			!isTouchingGround _objectParent &&
			{
				(speed _objectParent > 0) &&
				{
					_objectParent isKindOf "AIR"
				}
			}
		}
	};
	_return
};
waitUntil {sleep 1; {[_x] call _cond} count (units _group) == 0};
sleep 15;
_currentActions = _group getvariable ["A3C_SCRIPTS",[]];
{
	if ("landing_full" in (_x select 0)) then {
		_currentActions = _currentActions - [_x];
	};
} foreach _currentActions;
_group setvariable ["A3C_SCRIPTS",if (count _currentActions > 0) then {_currentActions} else {nil},true];
//systemchat "END";
A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_wp];
publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';

true

