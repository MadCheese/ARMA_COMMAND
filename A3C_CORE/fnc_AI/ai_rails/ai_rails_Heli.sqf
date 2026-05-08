

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------  H E L I C O P T E R  R A I L S    ------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------


A3C_RAIL_HELI_LANDING = {
	params ["_vehicle","_landingPos","_finalEndDir","_landingRailType","_exitCondition"];
	

	

	_flyinheightVar = _vehicle getVariable ["A3C_FLYINHEIGHT",50];
	
	
	//-- security measure to make sure the chopper has caught enough air!
	if (isTouchingGround _vehicle) then {
		(driver _vehicle) doMove (_landingPos getPos [1000,_vehicle getDir _landingPos]); //-- if unit is too close it is misdirect further away first so that it does take off 100%
	};
	while {canMove _vehicle} do {
		_aslPos = getposASL _vehicle;
		_ins = lineIntersectsSurfaces
		[
			_aslPos,
			(_aslPos select [0,2]) + [(((_aslPos select 2) - (15 min _flyinheightVar))) 	max ( (_landingPos select 2) + 10 )  ],
			_vehicle,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];
		if (_ins isEqualTo []) exitWith {_exit = true};
		sleep 1;
	};
	
	
	(driver _vehicle) doMove _landingPos; //-- set expectedDestination and reset above misdirection 

	
	
	
	//~~ add this later?
	private _damageHandler = _vehicle addEventHandler
	[
		"HandleDamage",
		{
			params ["_unit", "_selection", "_damage", "_source"]; //, "_projectile", "_hitIndex", "_instigator", "_hitPoint"
			_realDamage = if (isNull _source OR {_source in (crew _unit + [_unit])}) then {0} else {_damage};
			_realDamage
		}
	];
	

	_crewUnits = (crew _vehicle);
	
	private _railPos = +(_landingPos); //-- copy landingPos, to be altered later while original surface pos can still be referred to
	//_railPos = [_railPos select 0, _railPos select 1, (_railPos select 2) + 2];
	private _railPosHeight = (_railPos select 2);
	private _startDir = vectorDirVisual _vehicle;
	private _finalEndDir = if (!isNil '_finalEndDir') then {_finalEndDir} else {[_vehicle getDir _railPos] call MCSS_fnc_DegreeToVector};
	private _pad = "Land_HelipadEmpty_F" createvehicle _landingPos;

	{
		_railPos set [2, _railPosHeight + (_x select 0)]; //-- height for rail-step
		_speed = (_x select 1); //-- speed for rail step
		_endDir = if (_foreachIndex == 0) then {[_vehicle getDir _railPos] call MCSS_fnc_DegreeToVector} else {_finalEndDir}; //-- rail step vectorDir

		//-- security measure:
		if (_foreachIndex == 1) then {
			{
				[_x, false] remoteExec ["allowDamage",_x];
			} foreach _crewUnits;

		};
		if (_foreachIndex == 2) then {
			if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
				_vehicle land "GET IN";
			} else {
				{
					if (_x == driver vehicle _x && {vehicle _x isKindOf "AIR"}) then {
						_vehicle land "LAND";
					};
				} foreach (units (group driver _vehicle));
			};
		};

		_subBehaviour = 
		[
			_vehicle,
			getPosASL _vehicle,
			_railPos,
			_speed,
			_endDir 
		] spawn A3C_ai_rail_fnc_helicopter;
		waituntil {scriptdone _subBehaviour};
		
		
		_startDir = vectorDirVisual _vehicle;
		_endDir = _startDir;
	} foreach [[5,(speed _vehicle max 20) min 50],[3,5],[0,5]]; //,
	
	
	
	

	if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
		_vehicle land "GET IN";
	} else {
		{
			if (_x == driver vehicle _x && {vehicle _x isKindOf "AIR"}) then {
				_vehicle land "LAND";
			};
		} foreach (units (group driver _vehicle));
	};
	
	//-- bunny hop prevention (somehow the aircraft catches altitude if it has another waypoint after the current one
	_vehicle spawn {
		_timer = 0;
		//_vdir = vectorDir _this;
		//_this disableAI "MOVE";
		while {alive _this} do {
			_zVel = (velocity _this) select 2;
			
			if (_zVel >= 0 ) then {
				_this setvelocity [0,0,_zVel * -1]; //
			};
			if (isTouchingGround _this && {_timer == 0}) then {
				_timer = time;
			};
			if (_timer != 0 && {time - _timer > 5}) exitWith {};
			//_this setVectorDir _vdir;
		};
		//_this enableAI "MOVE";
	};

	waituntil {isTouchingGround _vehicle};
	
	//
	
	_crewUnits spawn {
		{
			[_x, true] remoteExec ["allowDamage",_x];
		} foreach _this;
	};

	if (!canMove _vehicle OR {!alive driver _vehicle}) exitWith {};
	
	//_exit = false;
	
	if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
		_cargoUnits = [];
		if (_landingRailType == "TRANSPORT UNLOAD") then {
			
			{
				if (!isPlayer (leader group _x)) then {
					if (group _x != (group driver _vehicle)) then {
						_x leaveVehicle _vehicle;
						_x remoteExec ["unassignVehicle",0];
						_cargoUnits pushBack _x;
					};
				};
			} foreach (crew _vehicle); 
			
		};
		while {alive _vehicle} do {
			private _cond = switch (_landingRailType) do {
				case ("COMBAT LANDING") : {call compile _exitCondition};
				//case ("TRANSPORT UNLOAD") : {{ alive _x &&  {(group _x) == (group driver _vehicle)}} count crew _vehicle == 0};
				case ("TRANSPORT UNLOAD") : {{ alive _x &&  {_x in _vehicle}} count _cargoUnits == 0};
			};
			_vehicle flyinHeight 0; //-- security super-glue
			
			//-- exit conditions here!
//			hintSilent str (   ((expectedDestination driver _vehicle) select 0) distance2D _railPos     );
//			hintsilent str [_exitCondition,call compile _exitCondition,_cond];

			
			sleep 0.5;
			if (_cond) exitWith {};
			
		};
	};
	//systemchat "CONT";	
	deletevehicle _pad;
	_vehicle flyInHeight _flyinheightVar;
	
	
	//-- handleDamage removal EH - has to be spawned, so that WP can complete after conditions are met
	[_vehicle,_damageHandler] spawn {
		params ["_vehicle","_damageHandler"];
		private _exit = false;
		while {alive _vehicle} do {
			if !(isEngineOn _vehicle) then {
				sleep 4;
			};
			if !(isTouchingGround _vehicle) then {
				_aslPos = getposASL _vehicle;
				_ins = lineIntersectsSurfaces
				[
					_aslPos,
					(_aslPos select [0,2]) + [(_aslPos select 2) - 4],
					_vehicle,
					objNull,
					true,
					1,
					"GEOM",
					"NONE"
				];
				if (_ins isEqualTo []) then {
					_exit = true;
				};
			};
			sleep 1;
			if (_exit) exitWith {};
		};
		_vehicle removeEventHandler ["HandleDamage",_damageHandler];
		//systemchat "EH REMOVED";
	};
	
	//deleteWaypoint [group driver _vehicle,currentWaypoint (group driver _vehicle)];
	_vehicle setVariable ["A3C_isBeingRailed",false,true];

};











