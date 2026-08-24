params ["_group","_pos","_target","_callerUID","_preCondition"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};


private _leader =  leader _group;
if (isPlayer _leader) exitWith {true};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;

_group setVariable ["A3C_HC_groupVehicleReadyToBoard",false,true]; //-- default for when player moves wp during boarding

[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
sleep 2;
private _wp = [_group,currentwaypoint _group];


private _syncWps = synchronizedWaypoints _wp;

if (count _syncWps == 0) exitWith {
//	"no sync" remoteExec ["systemchat",0];
	true
};

private _syncWP = _syncWps select 0;
private _loadingGroup = _syncWP select 0;
private _vehicle = vehicle (leader _loadingGroup);
private _isAir = _vehicle isKindOf "AIR";
private _driver = driver _vehicle;


//-- wait for unit to arrive
waituntil {unitReady _leader && {{_leader distance2D _x < 10} count [_pos,getPosASL _vehicle] > 0 }}; 

//-- engage group for boarding sync recognition
_group setVariable ["A3C_HC_groupVehicleReadyToBoard",true,true];


//-- wait for vehicle to arrive
waituntil {
	currentWaypoint _loadingGroup == (_syncWP select 1) && 
	{
		_vehicle getVariable ["A3C_HC_groupVehicleReadyToBoard",false]
	}
};

//-- compose pre- and post conditions, wait for pre-condition
private _exitCondition = {};
{
	_x params ["_condType","_condVal"];
	_exitCondition = switch (toUpper _condType) do {
		case ("TIMEOUT") : {
			_timeAtCompletion = time + _condVal;

			compile format [
				"time > %1",
				_timeAtCompletion
			];
		};

		case ("GOCODE") : {
			private _goCodeActivationVariableName = [
				_condVal,
				side _group
			] call A3C_main_fnc_getGoCodeActivationVariableName;

			compile format [
				"missionNamespace getVariable ['%1', false]",
				_goCodeActivationVariableName
			];
		};

		case ("DAYTIME") : {
			_str = _condVal splitString ":";
			_checkParams = [];

			{
				_checkParams pushBack (parseNumber _x);
			} foreach _str;

			compile format [
				"%1 call A3C_main_fnc_isDaytimeCompleted",
				_checkParams
			];
		};

		default {
			{true}
		};
	};
	if (_foreachIndex == 0) then {
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			_wp setWaypointScript format 
			[
				"A3C_CORE\waypointScripts\wpScript_groupGetInVehicle.sqf ['%1',%2]",
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

//"cargoGroup at wp position - boarding" remoteExec ["systemchat",0];

private _units = units _group;
if ({!isNull objectParent _x} count units _group == 0) then {
	private _emptySeats = [];
	{
		_v = objectParent _x;
		if (!isNull _v && {_x == driver _v}) then {
			_empty = (fullCrew [_v, "", true]) select 
			{
				isNull (_x select 0) &&
				{isNull (_x select 5)} &&
				{
					(_x select 1 == "cargo") OR
					{
						(_x select 1 == "Turret") && 
						{
							_x select 4
						}
					}
				}
			};
			if (count _empty > 0) then {
				{
					_empty set [_foreachIndex, [_v] + _x];
				} foreach _empty;
				_emptySeats = _emptySeats +_empty;
			};
		};
	} foreach (units _loadingGroup);
	if (count _emptySeats >= count _units) then {
		_unassignedUnits = +(_units);
		{
			_seatData = _emptySeats select _foreachIndex;
			_seatData params ["_vic","_nulUnit","_role","_cargoIndex","_turretPath"];
			if (_role == "cargo") then {
				_x assignAsCargoIndex [_vic,_cargoIndex];
			} else {
				_x assignAsTurret [_vic,_turretPath];
			};
		} foreach _units;
		_units allowGetIn true;
		_units orderGetIn true;
		while {{alive _x && {assignedVehicle _x == _vehicle && {!(_x in _vehicle)}}} count _units > 0} do {
			sleep 1;
		};
	};
	
	
};
//systemchat "cargoGroup has boarded";
_group setVariable ["A3C_HC_groupVehicleReadyToBoard",nil,true];

_wp synchronizeWaypoint [];

true
