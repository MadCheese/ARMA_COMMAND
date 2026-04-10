

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------  H E L I C O P T E R  R A I L S    ------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------


A3C_RAIL_HELI_LANDING = {
	params ["_vehicle","_landingPos","_finalEndDir","_landingRailType","_exitCondition"];
	
	/*
	_exitCode = switch (_exitCondition) do {
		case ("NONE") : {true};
		case ("A") : { {A3C_GoCode_Activate_A} };
		case ("B") : { {A3C_GoCode_Activate_B} };
		case ("C") : { {A3C_GoCode_Activate_C} };
		case ("D") : { {A3C_GoCode_Activate_D} };
		case ("DISMOUNTED") : {
			
			
			
			
			{(group _x) != group driver _vehicle && {isPlayer leader group _x}} count crew _vehicle == 0
		};
	};
	*/

	
	
	player sidechat str _landingRailType;
	if (isTouchingGround _vehicle) then {
		(driver _vehicle) doMove (_landingPos getPos [1000,_vehicle getDir _landingPos]);
	};
	
	_flyinheightVar = _vehicle getVariable ["A3C_FLYINHEIGHT",100];
	
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
	
	
	(driver _vehicle) doMove _landingPos;
	
	
	
//	_vehicle disableAI "MOVE";
	
	private _railPos = +(_landingPos); //ATLtoASL _landingPos;
	//player setposASL _landingpos;
	
	_startDir = vectorDirVisual _vehicle;
	_finalEndDir = if (!isNil '_finalEndDir') then {_finalEndDir} else {[_vehicle getDir _railPos] call MCSS_fnc_DegreeToVector};
	_pad = "Land_HelipadEmpty_F" createvehicle _landingPos;
	
	
	private _damageHandler = _vehicle addEventHandler
	[
		"HandleDamage",
		{
			params ["_unit", "_selection", "_damage", "_source"]; //, "_projectile", "_hitIndex", "_instigator", "_hitPoint"
			//systemchat str _source;
			//diag_log _source;
			_realDamage = if (isNull _source OR {_source in (crew _unit + [_unit])}) then {0} else {_damage};
			_realDamage
		}
	];
	
	
	
	
	_fnc_crewDamageHandler = {
		
		if (true) exitWith {};
		params ["_unit"];
		private _vehicle = vehicle _unit;
		//systemchat 'oi';
		private _exit = false;
		

		private _damageHandler1 = _unit addEventHandler
		[
			"HandleDamage",
			{
				params ["_unit", "_selection", "_damage", "_source"]; //, "_projectile", "_hitIndex", "_instigator", "_hitPoint"
				_realDamage = if (isNull _source OR {_source in ((crew vehicle _unit) + [_unit])}) then {0} else {_damage};
				//diag_log _source;
				//0
				_realDamage
			}
		];
		
		
		while {alive _unit && {!isNull objectParent _unit && {canMove objectParent _unit}}} do { //


			if !(isEngineOn _vehicle) then {
				sleep 4;
			};
			if (!isTouchingGround _vehicle && {!(_vehicle getVariable ["A3C_isBeingRailed",false])}) then {
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
			

			if !(_exit) exitWith {};
			sleep 1;
		};
		//systemchat str (alive _unit);
		_unit removeEventHandler ["HandleDamage",_damageHandler1];
		//systemchat "unit damage handler removed";
//		_unit allowdamage true;
	};
	_crewUnits = (crew _vehicle);
	{
		[[_x],_fnc_crewDamageHandler] remoteExec ["bis_fnc_spawn",_x];
		//_x allowdamage false;
	} foreach (crew _vehicle);
	
	
	_railPos = [_railPos select 0, _railPos select 1, (_railPos select 2) + 5];
	_railPosHeight = (_railPos select 2);

	
	{
		_railPos set [2, _railPosHeight + (_x select 0)];
		_speed = (_x select 1);
		//systemchat str _foreachIndex;
		_dist = (getPosASL _vehicle) distance _railPos;
		_factor = (((_dist / _speed) * 0.001) * 60) * 60;

		_endTimeEstimated = time + _factor;
		
		_endDir = if (_foreachIndex == 0) then {[_vehicle getDir _railPos] call MCSS_fnc_DegreeToVector} else {_finalEndDir};
		//if (false) then {
		if (_foreachIndex == 3) then {
			{
				[_x, false] remoteExec ["allowDamage",_x];
			} foreach _crewUnits;
			
			
			
//			_hasRetractingGear = (getNumber (configfile >> "CfgVehicles" >> typeof _vehicle >> "gearRetracting")) == 1;
			
			
//			if (_hasRetractingGear && {_landingRailType == "FULL LANDING"} ) then { //--
//				[_vehicle,_landingRailType] spawn {
//					params ["_vehicle","_landingRailType"];
//					_driver = driver _vehicle;
//					_driver disableAI "ANIM";
//					_driver setPos [0,0,1000];
//					_driver action ["landgear", _vehicle];
//					//sleep .1;
//					_driver moveInDriver _vehicle;
//					_driver enableAI "ANIM";
//					//sleep 2;
//					//systemchat 'GEAR';
//					//if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
//					//	sleep 0.5;
//						
//					//	_vehicle engineOn true;
//					//};
//				};
//			};
		};
		//
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
	} foreach [[5,speed _vehicle max 20],[3,5],[1,3],[0,2]]; //,
	
	_crewUnits spawn {
		sleep 1;
		{
//			[_x, true] remoteExec ["allowDamage",_x];
		} foreach _this;
	};
	
	_timer = time;
	
	
	
	
	
	if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
		
		
		_vehicle land "GET IN";
		
		//_hoverHeight = ((ASLtoATL _railPos) select 2);
		//_vehicle flyinheight 0; 
		//systemchat str _hoverheight;
	} else {
		_vehicle land "LAND";
	};
	
	
//	if (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) then {
		//waituntil {istouchingground _vehicle};
		//systemchat "TOUCHED";
//		_vehicle engineOn true;
//		_vehicle disableAI "MOVE";
//		_vehicle limitSpeed 0;
//		while {false} do { //canMove _vehicle
//			if ((expectedDestination (driver _vehicle) select 0) distance2d _railPos > 10) exitWith {};
//			
//			_velZ = if ( ((getPosASL _vehicle) select 2) > (_railPos select 2)  ) then {-2} else {0};
//			
//			
//			_vehicle setVelocity [0,0,_velZ];
//			sleep 1;
//		};
//		_vehicle land "GET IN";
		//_vehicle enableAI "MOVE";
		//_vehicle limitSpeed 1000;
		
		
	
//		while {time < _timer + 20} do {
//			if ((expectedDestination _vehicle select 0) distance2d _vehicle > 10) exitWith {};
			//if (isEngineOn _vehicle) then {
			//	[_vehicle,["engineOff",_vehicle]] remoteExec ["action",_vehicle];
			//};
//			if (!isTouchingGround _vehicle) then {
//				_vehicle setVelocity [0,0,-1];
			//} else {
//			};
//		};
		
//	};
	
	
	
	//systemchat str "LOOP EXITED";
	sleep 2;
	
	//deletevehicle _pad;
//	_vehicle enableAI "MOVE";
	
	_exit = false;
	while {alive _vehicle} do {
		
		
		if (_landingRailType == "LANDING FULL") then {
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
		} else {
		};
		
		
		if (_exit) exitWith {};
		
	};
	
	//waituntil {alive _vehicle OR {};
	_vehicle removeEventHandler ["HandleDamage",_damageHandler];
	//systemchat "EH REMOVED";
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
	] call BIS_fnc_addStackedEventHandler;
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
		if( _distanceToPosition <= 2 ) exitwith {};
		
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