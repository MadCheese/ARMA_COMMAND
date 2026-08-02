params ["_group","_pos","_target","_callerUID","_preCondition", "_postCondition", "_explosivesData"];

if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

_explosivesData params ["_chargeType"];

private _wpIndex = currentWaypoint _group;
private _wp = [_group,_wpIndex];
private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3;



//-- WAIT FOR ARRIVAL
while {_leaderVic distance2d _pos >= _precision} do { //--_precision
	private _wPos = waypointPosition _wp;
	{_x set [2,0]} foreach [_pos, _wPos];
	if !(_pos isEqualTo _wPos) then {
		_pos = _wPos;
	};
	[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
	sleep 1;
};

//-- CONDITIONS: Step 1
private _exitCondition = {{true}};
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
	

	//-- pre-condition other than 'arrival' will wait and re-trigger waypoint script
	//-- when script is re-triggered, condition is satisfied and script continues
	//-- second cycle is only relevant if post-condition exists. In that case the _exitCondition is stored for later reference


	if (_foreachIndex == 0) then {
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			private _wpScript = waypointScript _wp;
			if ("[" in _wpScript) then {
				//-- assign new params for script re-trigger
				_wpScript = _wpScript splitString " ";
				_wpScript params ["_scrPath","_scrParams"];
				_scrParams =  call compile _scrParams;
				_scrParams set [1, ['ARRIVAL',''] ];
				_scrParams set [2, _postCondition ];
				_scrParams = str _scrParams;
				_wpScript = format ["%1 %2", _scrPath,_scrParams];
			};
			_wp setWaypointScript _wpScript;
			_wp setWaypointPosition [_pos,0];
			private _statements = waypointStatements _wp;
			_statements set [0,"true"];
			_wp setWaypointStatements _statements;
		};
	};
} foreach [_preCondition,_postCondition];

//-------------------------------//
//-- INSERT ACTION SCRIPT here --//
//-------------------------------//






//-- CONDITIONS: Step 2

waitUntil {[] call _exitCondition};

//-- NOTE: _attachToObject should be fetched after arrival because it might be objNull as waypointscript starts
private _attachToObject = waypointAttachedVehicle _wp;

// systemchat str _chargeType;

//-- get unit with type of charge
private _detoUnits = (
	[units _group] call A3C_ai_shared_fnc_getUnitsWithExplosives
) select {_chargeType in (magazines _x)};



//-- no units with _chargeType >> exit
if (_detoUnits isEqualTo []) exitWith {true};

//-- choose unit to place charge
private _plantUnit = _detoUnits select 0;

//-- action: place charge
private _actionScript = [
	_plantUnit,
	_pos,
	[
		_attachToObject,
		_chargeType
	]
] spawn A3C_AI_Shared_fnc_wpActionPlantExplosive;

waituntil {scriptDone _actionScript}; //-- << maybe better to remove this so waypoint completes? team units are frozen anyways

//-- SCRIPT END
[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

true;