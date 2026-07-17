params ["_group","_pos","_target","_callerUID","_preCondition"];
//_group = _this param [0,grpnull,[grpnull]];
//_pos = _this param [1,[],[[]],3];
//_target = _this param [2,objnull,[objnull]];


if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

_wp = [_group,currentwaypoint _group];

private _syncWps = synchronizedWaypoints _wp;




private ["_vehsMove","_vehsLand"];
_vehsMove = [];
_vehsLand = [];

private _leader = leader _group;

_loadVic = vehicle _leader;
private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _loadVic) >> "precision")) * 1.2);

[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;


waituntil {unitready (driver _loadVic) && {_loadVic distance2D _pos < _precision}};
//"arrived" remoteExec ["systemchat",0];
_loadVic setVariable ["A3C_HC_groupVehicleReadyToBoard",true,true];




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
	if (_foreachIndex == 0) then {
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			_wp setWaypointScript format 
			[
				"A3C_CORE\waypointScripts\wpScript_LoadVehicleInVehicle.sqf ['%1',%2]",
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



waituntil {
	private ["_countReady","_vehsGroup"];
	_countReady = 0;
	_vehsGroup = [];


	{
		private ["_veh"];
		_veh = vehicle _x;
		if (_x == effectivecommander _vehicle) then {
			if (!(_veh in _vehsMove)) then {


				_veh domove _pos;
				_veh moveTo _pos;
				_vehsMove set [count _vehsMove,_veh];
			} else {
				if !(istouchingground _veh) then {
					if (unitready _veh && !(_veh in _vehsLand)) then {


						_veh land "GET IN";
						_vehsLand set [count _vehsLand,_veh];
						private _doorState = if ((getPosVisual _veh) select 2 < 5) then {1} else {0};
						{	
							_veh animateDoor [_x,_doorState];
						} foreach ['door_rear','door_rear_source','Door_1_source'];
					};
				} else {
					{
						_veh animateDoor [_x,1];
					} foreach ['door_rear','door_rear_source','Door_1_source'];
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

sleep 3;



while {canMove _loadVic} do {
	
	
	_swps = synchronizedWaypoints _wp;
	_exit = true;
	
	{
		_x params ['_group1','_wpi'];
		private _cond = (_group1 getVariable ["A3C_HC_groupVehicleReadyToBoard",false]) OR 
		{
			 
			{
				_objP = objectParent _x;
				!isNull _objP &&
				{
					_x == driver _objP &&
					{
						(_loadVic canVehicleCargo _objP) select 0 &&
						{
							!(_objP in (getVehicleCargo _loadVic))
						}
					}
				}
			} count units _group1 > 0
		};
		
		if (_cond) exitWith {
			_exit = false;
		};
	} foreach _swps;

	
	if (_exit) exitWith {};
	sleep 1;
};

_loadVic setVariable ["A3C_HC_groupVehicleReadyToBoard",nil,true];
{
	private _veh = vehicle _x;
	if (_x == effectiveCommander _veh) then {	
		{
			_veh animateDoor [_x,0];
		} foreach ['door_rear','door_rear_source','Door_1_source'];
	};
} foreach units _group;


true