

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
		] spawn A3C_AI_RAIL_HELI;
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

//-- morph this fnc and rail_heli into one ANIMATEFLIGHT fnc. First attempt failed, this is a placeholder
A3C_AI_AIRCRAFT_LOOKAT = {

	params ["_vehicle","_startPos","_endPos","_vectorDirFrom","_vectorDirTo","_vectorUpFrom","_vectorUpTo","_duration"];

	if (isTouchingGround _vehicle && {_vehicle isKindOf "AIR"}) exitWith {};

	_startTime = time; 
	_endTimeEstimated = time + _duration;
	private _velocity = velocity _vehicle;
	
	[_vehicle] call MCSS_fnc_setVehicleVarname;
	{
		_x disableAI "ALL";
	} foreach [_vehicle,driver _vehicle];
	_vehicle setVariable ['A3C_AI_RAIL',true,true];


	[
		format ["A3C_EH_RAIL_%1",str _vehicle],
		"onEachFrame",
		compile format
		[
			"
				private _interval = (linearConversion [%4, %5, time, 0, 1,true]);	 
				_transformation =
				[
					%2,
					%3,
					[0,0,0],
					[0,0,0],
					%6, 
					%7,
					%8,
					%9, 
					_interval
				];
				[%1,_transformation] remoteExec ['setVelocityTransformation',%1];

				if (_interval >= 0.9999999999 OR {!alive %1}) exitWith {
					
					[format ['A3C_EH_RAIL_%1',str %1], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
					{
						[_x,'ALL'] remoteExec ['enableAI',_x];
					} foreach [%1,driver %1];
					%1 setVariable ['A3C_AI_RAIL',false,true];
					%1 setVectorUp [0,0,1];
				};
			",
			_vehicle,
			_startPos,
			_endPos,
			_startTime,
			_endTimeEstimated,
			_vectorDirFrom,
			_vectorDirTo,
			_vectorUpFrom,
			_vectorUpTo,
			_velocity
		]
	] call BIS_fnc_addStackedEventHandler; //-- is this getting removed again??
	waituntil {!(_vehicle getVariable ["A3C_AI_RAIL",false])};
};



A3C_AI_RAIL_HELI = {

	params ["_vehicle","_startPos","_endPos","_speed","_endDir"];
	
	_endDir = if (!isNil '_endDir') then {_endDir} else {[_vehicle getDir _endPos] call MCSS_fnc_DegreeToVector};
	//_vehicle = vehicle player;
	//_startPos = getPosASLVisual _vehicle;
	//_endPos = ((_startPos getPos [200,getDir _vehicle]) select [0,2]) + [(_startPos select 2) + 100];
	_dist = _startPos distance _endPos;
	_factor = (((_dist / _speed) * 0.001) * 60) * 60;
	_startTime = time; 
	_endTimeEstimated = time + _factor;
	[_vehicle] call MCSS_fnc_setVehicleVarname;
	{
		_x disableAI "ALL";
	} foreach [_vehicle,driver _vehicle];
	_vehicle setVariable ['A3C_AI_RAIL',true,true];

	[
		format ["A3C_EH_RAIL_%1",str _vehicle],
		"onEachFrame",
		compile format
		[
			"
				_dist1 = (%1 distance %3);
				_endTimeEstimated = if (isNil '_endTimeEstimated') then {%5} else {_endTimeEstimated};
				_factor = (((_dist1 / 80) * 0.001) * 60) * 60;
				
				_interval = (linearConversion [%4, _endTimeEstimated, time, 0, 1]);
				_endTimeEstimated = time + _factor;
				 
				_transformation =
				[
					%2,
					%3,
					[10,0,0],
					[10,0,0],
					vectorDirVisual %1, 
					%6,
					vectorUpVisual %1,
					[0,0,1],  
					_interval
				];

				
				[%1,_transformation] remoteExec ['setVelocityTransformation',%1];


				if (_interval >= 0.9999999999 OR {isTouchingGround %1 OR {!canMove %1}}) exitWith {
					[format ['A3C_EH_RAIL_%1',str %1], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
					{
						[_x,'ALL'] remoteExec ['enableAI',_x];
					} foreach [%1,driver %1];
					%1 setVariable ['A3C_AI_RAIL',false,true];
					%1 setVectorUp [0,0,1];
				};
			",
			_vehicle,
			_startPos,
			_endPos,
			_startTime,
			_endTimeEstimated,
			_endDir
		]
	] call BIS_fnc_addStackedEventHandler;
	waituntil {!(_vehicle getVariable ["A3C_AI_RAIL",false])};
};

// [vehicle player, waypointposition [vg,currentwaypoint vg]]  spawn A3C_AI_RAIL_VTOL
A3C_AI_RAIL_VTOL = 
{
	
	params ["_vehicle","_pos","_inside"];

	if (_inside) then {
		_refPos1 = ATLtoASL _pos;
		_refPos1 set [2,(_refPos1 select 2) + 50];
		_refPos2 = (_refPos1 select [0,2]) + [0];
		_lif = (lineintersectsSurfaces [_refPos1,_refPos2,objNull,objNull, true]);
		if (count _lif > 0) then {
			_pos =  ((_lif select 0) select 0);
		}; 
		_pos set [2,(_pos select 2) + 15];
	};

	waituntil {_vehicle distance2D _pos < 2500};
	[_vehicle,0] remoteExec ["limitspeed",_vehicle];
	{
		[_x,"ALL"] remoteExec ["disableAI",_x];
	} foreach [_vehicle, driver _vehicle];

	_isHeli = _vehicle isKindOf "HELICOPTER";
	//systemchat str _isHeli;
	
	_speed = speed _vehicle;
	_cycle = 1;
	private _exit = false;
	private _timer = time;
	private _maxSpeed = _speed max (20); //-- default for helicopter (used for SLING-DROP)
	while {alive _vehicle} do {
		//systemchat str [((getPosASL _vehicle) select 2),((_pos select 2) + 2)];
		if (_vehicle distance2d _pos < 2) then {
			
			if ( ((getPosASL _vehicle) select 2) <  ((_pos select 2) + 2) ) then {
				_exit = true;
			};
		};
		
		if (_exit) exitWith {};

		_vel = velocity _vehicle;
		
		_dir = _vehicle getDir _pos;
		
		_velZ = 0;
		if ((getPosASL _vehicle) select 2 > (_pos select 2)) then {
			_velZ = -4;
		} else {
			if ((getPosASL _vehicle) select 2 < ((_pos select 2) - 2)) then {
				_velZ = 4;
			};
		};
		if (time - _timer > 5) then {
			_interSectList = lineIntersectsSurfaces [getPosASL _vehicle, _pos, _vehicle, objNull, true, 1, "GEOM", "NONE", true];
			if (count _interSectList > 0) then {
				_velZ = 4;
			};
			_timer = time;
		};
		
		if !(_isHeli) then {
			_maxSpeed = 350;
			if (_vehicle distance2D _pos < 800) then {
				_maxSpeed = 200;
			};
			if (_vehicle distance2D _pos < 400) then {
				_maxSpeed = 150;
			};
			if (_vehicle distance2D _pos < 200) then {
				_maxSpeed = 100;
			};
			if (_vehicle distance2D _pos < 100) then {
				_maxSpeed = 70;
			};
				
		};
		
		if (_vehicle distance2D _pos < 50) then {
			_maxSpeed = 30;
		};
		if (_vehicle distance2D _pos < 10) then {
			_maxSpeed = 10;
		};
		if (_vehicle distance2D _pos < 2) then {
			_maxSpeed = 0;
		};
		
		
		
		_speed = (_speed - 5) max _maxSpeed;
		_adjustSpeed = 0;
		if (_speed > 0) then {
			_adjustSpeed = _speed / 3.6;
		};
		
		if (_speed >= 0) then {
			_newVelocity =  
			[
				(sin _dir * _adjustSpeed), 
				(cos _dir * _adjustSpeed), 
				_velZ
			];
			[_vehicle,_newVelocity] remoteExec ["setVelocity",_vehicle];

		};
		sleep 0.1;
		_cycle = _cycle + 1;
	
	};

	[_vehicle,10000] remoteExec ["limitSpeed",_vehicle];
	{
		_u = _x;
		[_x,"ALL"] remoteExec ["enableAI",_x];
	} foreach [_vehicle, driver _vehicle];


};


A3C_DUDA_CHOPPER_RAIL = {
	//--- snippet adapted from ADVANCED RAPELLING BY DUDA!! ~~ give credit in forums	
	//-- takes ASLpos
	params ["_vehicle","_rappelPos","_hoverHeight"];
	private ["_velocityMagatude","_vU","_vX","_vY","_vZ","_distanceToPosition"];
	//-- prevent issue in SP where vehicle won't let itself be forceMoved when time is > 1
	if !(isMultiplayer) then {
		setaccTime 1;
	};
	_velocityMagatude = 15;
	//------------------------------------------------------------------------------------------------------------------------
	while {alive _vehicle} do { // _vehicle getVariable ["AR_Units_Rappelling",false] && 
		_vU = vectorUp _vehicle;
		_vU params ["_vX","_vY","_vZ"];
		if !(_vX == 0) then {
			if (_vX > 0) then {
				_vx = (_vX - 0.1) max 0;
			} else {
				_vx = (_vX + 0.1) min 0;
			};
		};
		if !(_vY == 0) then {
			if (_vY > 0) then {
				_vY = (_vY - 0.1) max 0;
			} else {
				_vY = (_vY + 0.1) min 0;
			};
		};
		if (_vZ < 1) then {
			_vZ = (_vZ + 0.1) min 1;
		};
		//_vehicle setVectorUp [_vX,_vY,_vZ];
		[_vehicle,[_vX,_vY,_vZ]] remoteExec ["setVectorUp",_vehicle];
		_distanceToPosition = ((getPosASL _vehicle) distance _rappelPos);
		if( _distanceToPosition <= 10 ) then {
			_velocityMagatude = ((_distanceToPosition / 10) * _velocityMagatude) max 5;
		} else {
			if( _distanceToPosition <= 50 ) then {
				if (_velocityMagatude > 5) then {
					_velocityMagatude = _velocityMagatude - 0.1;
				};
			};
		};
		if( _distanceToPosition <= 2 ) exitWith {};
		
		//_vehicle setVectorUp [0,0,1];
		[_vehicle,[0,0,1]] remoteExec ["setVectorUp",_vehicle];
		_currentVelocity = velocity _vehicle;
		_currentVelocity = _currentVelocity vectorAdd (( (getPosASL _vehicle) vectorFromTo _rappelPos ) vectorMultiply _velocityMagatude);
		_currentVelocity = (vectorNormalized _currentVelocity) vectorMultiply ( (vectorMagnitude _currentVelocity) min _velocityMagatude );
		//_vehicle setVelocity _currentVelocity;
		[_vehicle,_currentVelocity] remoteExec ["setVelocity",_vehicle];
		//_vehicle flyinheight _hoverHeight;
		[_vehicle,_hoverHeight] remoteExec ["flyinheight",_vehicle];
		sleep 0.05;
		//hintsilent str [round _velocityMagatude,round _distanceToPosition];
	};
};