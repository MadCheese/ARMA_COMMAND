
params ["_group","_pos","_target","_callerUID","_preCondition","_postCondition"];

if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _wp = [_group,currentwaypoint _group];

//-- terminate previous execution
private _currentActions = _group getvariable ["A3C_SCRIPTS",[]];
{
	_x params ["_actionID","_scr"]; //-- move this to 'A3C_HC_WPScriptBlock'???
	if ("landing_full" in toLower _actionID) then {
		terminate _scr;
		_currentActions = _currentActions - [_x];
	};
	
} foreach _currentActions;

_group setvariable ["A3C_SCRIPTS",_currentActions,true]; //-- guarantee at least the 2 sec of no script so that old one can exit

private _addRadius = if (_leaderVic isKindOf "AIR") then {50} else {0};

//-- determine landing distance
private _landingDistance = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) + _addRadius);

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

while {[_leaderVic,_landingDistance,false] call _cond} do { //&& (unitReady _leader)
	_leaderVic = vehicle _leader; //-- has to be refreshed in case of crash
	[_group,_pos, true] call A3C_HC_MoveToWaypoint;
	sleep 2;
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
				"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing_Combat.sqf ['%1',%2,%3]",
				_callerUID,
				["ARRIVAL",""],
				_postCondition
			];
			_wp setWaypointPosition [_pos,0];
			//systemchat 'ah';
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


private ["_vehsMove","_vehsLand"];
_vehsMove = [];
_vehsLand = [];
waituntil {
	private ["_countReady","_vehsGroup"];
	_countReady = 0;
	_vehsGroup = [];
	private _allCrew = [];

	{
		private ["_veh","_d"];
		_veh = vehicle _x;
		_d = driver _veh;
		if (_x == effectivecommander _x) then {
			if (!(_veh in _vehsMove) && {!(istouchingground _veh)}) then {
				_veh domove _pos;
				_veh moveTo _pos;
				_vehsMove set [count _vehsMove,_veh];
				//systemChat format ["%1 COMBAT LAND MOVE",group _x];
			} else {
				if !(istouchingground _veh) then {
				//	if (unitready _veh && !(_veh in _vehsLand)) then {
						_veh land "GET IN";
						_vehsLand set [count _vehsLand,_veh];
						//systemChat format ["%1 COMBAT LAND DROP",group _x];
				//	};
				//} else {
				//	_veh engineon true;
				//	_veh flyInHeight 0;
				//	_countReady = _countReady + 1;
				} else {
					
					_veh flyInHeight 0; //-- is this ever executed really? it should be, but check
					private _crewNonGroup = (crew _veh) select {
						group _x != group _d &&
						{
							assignedVehicle _x == _veh
						}
					};
					if !(_crewNonGroup isEqualTo []) then {
						{
							[
								[_x],
								{
									params ["_unit"];
									// unassignVehicle _unit;
									// // moveOut _unit;
									// doGetOut _unit;
									[_unit] call A3C_AIGetOut;

								}
							] remoteExec ["bis_fnc_call",_x];
						} foreach _crewNonGroup;	
					};
				};
			};
			_vehsGroup set [count _vehsGroup,_veh];
		};
	} foreach units _group;

	_vehsMove = _vehsMove - (_vehsMove - _vehsGroup);
	_vehsLand = _vehsLand - (_vehsLand - _vehsGroup);

	sleep 1;

	_doExit = //-- no vehicle of the group carries any more units from another group
	{
		
		private _oP = objectParent _x;
		!isNull _oP &&
		{
			_x == driver _op &&
			{
				canMove _op &&
				{
					{!(_x in units _group)} count (crew _op) > 0
				}
			}
		}
	} count units _group == 0;

	// hint str _doExit;

	// if (_doExit) exitWith {};

	
	//count _vehsGroup == _countReady OR {[] call _exitCondition}
	//systemchat str [time,"COMBAT LAND LOOP"];
	// [] call _exitCondition
	_doExit
};
if !([_group] call A3C_isGroupOnFinalWP) then {
	{
		private ["_veh"];
		_veh = vehicle _x;
		if (_x == effectivecommander _x && {_veh isKindOf "HELICOPTER"}) then {
			_veh land "NONE";
		};
	} foreach units _group;
};
[_group] call A3C_HC_ReInitGroupMovement;


//systemchat "COMBAT LAND END";
[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

true

