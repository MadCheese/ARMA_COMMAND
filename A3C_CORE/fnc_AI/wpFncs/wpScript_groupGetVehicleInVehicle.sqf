

params ["_group","_pos","_target","_callerUID","_preCondition"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

_group setVariable ["A3C_HC_groupVehicleReadyToBoard",false,true]; //-- default for when player moves wp during boarding
private _leader =  leader _group;
[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
sleep 2;
private _wp = [_group,currentwaypoint _group];


private _syncWps = synchronizedWaypoints _wp;

if (count _syncWps == 0) exitWith {
//	"no sync VIV_CARGO" remoteExec ["systemchat",0];
	true
};

private _syncWP = _syncWps select 0;
private _loadingGroup = _syncWP select 0;
private _hostingVehicle = vehicle (leader _loadingGroup);
private _isAir = _hostingVehicle isKindOf "AIR";
private _hostingDriver = driver _hostingVehicle;
private _leaderVic = vehicle _leader;


//-- wait for unit to arrive
waituntil {unitReady _leader && {{_leader distance2D _x < 10} count [_pos,getPosASL _hostingVehicle] > 0 }}; 


//-- engage group for boarding sync recognition
_group setVariable ["A3C_HC_groupVehicleReadyToBoard",true,true];

//-- wait for vehicle to arrive
waituntil {
	currentWaypoint _loadingGroup == (_syncWP select 1) && 
	{
		_hostingVehicle getVariable ["A3C_HC_groupVehicleReadyToBoard",false]
	}
}; 

//"vehicle has arrived / waiting for loadvic final pos" remoteExec ["systemchat",0];

waituntil {(getPosATL _hostingVehicle) select 2 < 20 && { speed _hostingVehicle < 20}};

private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.2);

//"vehicle is ready / adjusting position" remoteExec ["systemchat",0];


[_group,((getPosASL _hostingVehicle) getPos [15,_hostingVehicle getDir _leaderVic])] call A3C_ai_shared_fnc_approachWaypointRegular;

sleep 3;
waitUntil {currentcommand _hostingDriver != "MOVE" && {isTouchingGround _hostingVehicle OR {(getPosATL _hostingVehicle) select 2 < 0.4}}};
sleep 5;

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
			compile format ["%1 call A3C_main_fnc_isDaytimeCompleted",_checkParams];
		};
		default {{true}};
	};
	if (_foreachIndex == 0) then { //-- _foreachIndex == 0 is for pre-condition
		
		waitUntil {[] call _exitCondition}; 
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			_wp setWaypointScript format 
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_GroupGetVehicleInVehicle.sqf ['%1',%2]",
				_callerUID,
				["ARRIVAL",""]
			];
			_wp setWaypointPosition [_pos,0];
			private _statements = waypointStatements _wp;
			_statements set [0,"true"];
			_wp setWaypointStatements _statements;
		};
	};
} foreach [_preCondition];
//"loading vehicle" remoteExec ["systemchat",0];
private _groupVehicles = [];
{
	_objP = objectParent _x;
	if (!isNull _objP && {_x == driver _objP}) then {
		_groupVehicles pushBackUnique _objP;
	};
} foreach units _group;

{
	if ((_hostingVehicle canVehicleCargo _x) select 0) then {
		_hostingVehicle setVehicleCargo _x;
	};
} foreach _groupVehicles;

_group setVariable ["A3C_HC_groupVehicleReadyToBoard",nil,true];

_wp synchronizeWaypoint [];


true
