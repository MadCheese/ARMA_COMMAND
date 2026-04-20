params ["_group", "_pos", "_target","_callerUID","_preCondition"];

if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

private _leader =  leader _group;

if (isPlayer _leader) exitWith {true};



//-- wait for arrival
private _leaderVic = vehicle _leader;
//private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;
//_t = str (floor random 9);  //~~ ??
sleep 1;
//while {_leaderVic distance2d _pos >= _precision} do {
//	//if (currentWaypoint _group != _wpIndex) exitWith {_exit = true};
//	_leader domove _pos; //(_waypointPositions select _assignedIndex);
//	_leader moveTo _pos;
//	(units _group - [_leader]) doFollow _leader;
//	sleep 10;
//};
private _building = nearestBuilding _pos;
private _wp = [_group,currentwaypoint _group];
private _buildingSize = (sizeOf (typeOf _building)) * 1.1;
_movePos = _building getPos [_buildingSize,_building getDir _leader];
while {!(_leader distance2D _building < (_buildingSize * 1.5) )} do { //&& (unitReady _leader)
	
	[_group,_movePos] call A3C_HC_MoveToWaypoint;
	for "_i" from 1 to 10 do {
		if (_leader distance2D _pos < 4 && (unitReady _leader)) exitWith {};
		sleep 1;
	};
};
_leader forceSpeed 0;
while {{_x distance2D (formationPosition _x) > 10} count ((units _group) - [_leader]) > 0} do {
	sleep 2;
};
_leader forceSpeed -1;
sleep 1;
if ((waypointPosition _wp) distance2D _pos > 0) exitWith {};

//-- prevent multiple execution
private _currentAction = _group getvariable ["A3C_SCRIPT",-1];
if (typeName _currentAction != "SCALAR") then {
	terminate _currentAction;
};
_occupiedUnits = (units _group) select {!isPlayer _x && {count (_x getVariable ["A3C_PLOT",[]]) > 0}};

[_occupiedUnits,false,true,true] spawn A3C_AI_Shared_cancelUnitPlot;
waituntil {{count (_x getVariable ["A3C_PLOT",[]]) > 0} count _occupiedUnits == 0};


//player setpos (_building buildingpos 0);



//{_x setVariable ["A3C_CLEARING",true,true]} foreach (units _group);



//systemchat "arrived";
//waituntil {};

private _scr = [units _group,_building] spawn A3C_AI_Shared_action_CLEARBUILDING;
_group setvariable ["A3C_SCRIPT",_scr,true];
waituntil {scriptdone _scr};
waituntil {{_x getVariable ["A3C_CLEARING",false] && {alive _x}} count (units _group) == 0};
_group setvariable ["A3C_SCRIPT",nil,true];
//systemchat 'DONE';
true