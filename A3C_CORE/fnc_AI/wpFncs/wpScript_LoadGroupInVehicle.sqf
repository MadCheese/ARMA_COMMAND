params ["_group","_pos","_target","_callerUID","_preCondition"];
private ["_syncWps","_wp"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

private _leader = leader _group;


_wp = [_group,currentwaypoint _group];

_synchroWPS = synchronizedWaypoints _wp;

_syncWps = _group getVariable ["A3C_HC_SYNCWPS",[]]; //-- syncwps is used to access boarding groups


private ["_vehsMove","_vehsLand"];
_vehsMove = [];
_vehsLand = [];

_loadVic = vehicle leader _group;
private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _loadVic) >> "precision")) * 1.2) max 30;

[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;

waituntil {unitready (driver _loadVic) && {_loadVic distance2D _pos < _precision}};


_loadVic setVariable ["A3C_HC_groupVehicleReadyToBoard",true,true];
waituntil {
	private ["_countReady","_vehsGroup"];
	_countReady = 0;
	_vehsGroup = [];


	{
		private ["_veh"];
		_veh = vehicle _x;
		if (_x == effectivecommander _x) then {
			if (!(_veh in _vehsMove)) then {


				_veh domove _pos;
				_veh moveTo _pos;
				_vehsMove set [count _vehsMove,_veh];
			} else {
				if !(istouchingground _veh) then {
					if (unitready _veh && !(_veh in _vehsLand)) then {


						_veh land "GET IN";
						_vehsLand set [count _vehsLand,_veh];
					};
				} else {

					_veh engineon true;
					_countReady = _countReady + 1;
				};
			};
			_vehsGroup set [count _vehsGroup,_veh];
		};
	} foreach units _group;


	_vehsMove = _vehsMove - (_vehsMove - _vehsGroup);
	_vehsLand = _vehsLand - (_vehsLand - _vehsGroup);

	sleep 1;
	count _vehsGroup == _countReady
};

//"vehicle is ready to board" remoteExec ["systemchat",0];
_dest = (expectedDestination (driver _loadVic)) select 0;


//-- we can now exit as the waypoint will complete only after synced wps are completed >>> INCORRECT IF VEHICLE ARRIVES BEFORE


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
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			_wp setWaypointScript format 
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_LoadGroupInVehicle.sqf ['%1',%2]",
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

while {canMove _loadVic} do {
	
	private _emptySeats = [];
	{
		_v = objectParent _x;
		if (!isNull _v && {_x == driver _v}) then {
			_emptySeats pushBack (fullCrew [_v, "cargo", true] select {isNull (_x select 0)});
		};
	} foreach (units _group);
	_exit = true;
	if (count _emptySeats > 0) then {
		_swps = synchronizedWaypoints _wp;
		{
			_x params ['_group1','_wpi'];
			private _cond = (_group1 getVariable ["A3C_HC_groupVehicleReadyToBoard",false]) OR 
			{
				{!((driver (vehicle _x)) in (units _group))} count units _group1 > 0
			};
			if (_cond) exitWith {
				_exit = false;
			};
		} foreach _swps;
	};
	
	if (_exit) exitWith {};
	sleep 1;
};

//"boarding complete" remoteExec ["systemchat",0];
_loadVic setVariable ["A3C_HC_groupVehicleReadyToBoard",nil,true];

true

