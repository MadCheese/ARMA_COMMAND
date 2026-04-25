//-- REQUIRED PARAMETERS. ADD CUSTOM PARAMETERS AS YOU WISH.
params
[
	"_group",
	"_pos",
	"_target",
	"_callerUID",
	"_preCondition", //-- _preCondition: ARRAY >> example: ["GOCODE","A"]
	"_postCondition" //-- _postCondition: ARRAY >> example: ["GOCODE","A"]
];

if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

private _wpIndex = currentWaypoint _group;
private _wp = [_group,_wpIndex];
private _leader = leader _group;
private _leaderVic = vehicle _leader;
private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 4;



//-- WAIT FOR ARRIVAL
while {alive _leaderVic} do { 
	private _dist = _leaderVic distance2d _pos;
	private _precision = (speed _leaderVic / 3.6) * 8; //-- calculate distance: 5 sec at current speed since doors need 5s to open
	if (_dist <= _precision) exitWith {};
	_wPos = waypointPosition _wp;
	{_x set [2,0]} foreach [_pos, _wPos];
	if !(_pos isEqualTo _wPos) then {
		_pos = _wPos;
	};
	[_group,_pos] call A3C_HC_MoveToWaypoint;
	sleep 5;
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
			compile format ["%1 call A3C_fnc_DAYTIME_COMPLETED",_checkParams];
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
} foreach [_preCondition];

//-------------------------------//
//-- INSERT ACTION SCRIPT here --//
//-------------------------------//

private _aircraft = [];
{
	private _veh = objectParent _x;
	if (!isNull _veh && {!(_veh in _aircraft) && {_x == driver _veh && {_veh isKindOf "AIR"}}}) then {
		_aircraft set [count _aircraft, _veh];
	};
} foreach (units _group);

{
	private _vehicle1 = _x;
	{
		_vehicle1 animateDoor [_x,1];
	} foreach ['door_rear','door_rear_source','Door_1_source'];
} foreach _aircraft;


sleep 3;

{
	[_callerUID,_x] call A3C_Paradrop_Eject;
} foreach _aircraft;


//-- CONDITIONS: Step 2

waitUntil {[] call _exitCondition};

//-- SCRIPT END
[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color
true;