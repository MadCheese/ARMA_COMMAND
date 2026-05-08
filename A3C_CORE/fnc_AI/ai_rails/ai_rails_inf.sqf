//-----------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------  I N F A N T R Y  /  M A N  R A I L S    ----------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

//~~ only used by rappel?
A3C_RAIL_INF = {
	private ["_rail"];
	params ["_unit","_dest","_bld"];
	//systemchat str _this;	
	if (isPlayer _unit) exitWith {};
	_unit forceSpeed 0;

	[_unit] call MCSS_fnc_setVehicleVarname;	
	[_unit, (position vehicle _unit)] remoteExec ["doMove",_unit]; //-- prevent unit from any autonomous movement
	[_unit, (position vehicle _unit)] remoteExec ["moveTo",_unit];	
	sleep (random 0.3);
	private _rail = [_unit,ATLtoASL _dest,_bld,false] spawn A3C_forceDestination;

	waituntil {scriptDone _rail};
	
	_unit setpos _dest;
	
	_ins = lineIntersectsSurfaces
	[
		getposASL _unit,
		((getposASL _unit) select [0,2]) + [0],
		_unit,
		objnull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	
	_unit setPosASL ((_ins select 0) select 0);
	
	_unit forceSpeed -1;
	
	[_unit,objNull] remoteExec ["lookAt",_unit];
	[_unit,_dest] remoteExec ["doMove",_unit];
	[_unit,_dest] remoteExec ["moveTo",_unit];
	_dest spawn {
		sleep 15;
		A3C_OCC_BPOSES = A3C_OCC_BPOSES - [_this];
	};
};


/*
//~~ only used by rappel?
A3C_RAIL_INF = {
	private ["_rail"];
	params ["_unit","_dest","_bld"];
	if (isPlayer _unit) exitWith {};
	[_unit] call MCSS_fnc_setVehicleVarname;	
	[_unit, (position vehicle _unit)] remoteExec ["doMove",_unit]; //-- prevent unit from any autonomous movement
	[_unit, (position vehicle _unit)] remoteExec ["moveTo",_unit];	
	sleep (random 0.3);	
	if (_dest isEqualTo []) exitWith {};
	private _dir = [_unit,_dest] call BIS_fnc_dirTo;
	private _tm = time;
	private _pos = getPosASL _unit;	
	_unit lookat ([_unit,100,([_unit,_dest] call BIS_fnc_dirTo)] call BIS_fnc_RelPos);
	private _exit = false;
	private _rail = [_unit,ATLtoASL _dest,_bld,false] spawn A3C_forceDestination;
	waituntil {scriptDone _rail};
	[_unit,objNull] remoteExec ["lookAt",_unit];
	[_unit,_dest] remoteExec ["doMove",_unit];
	[_unit,_dest] remoteExec ["moveTo",_unit];
	_unit setPos _dest;
	sleep 15;
	A3C_OCC_BPOSES = A3C_OCC_BPOSES - [_dest];
};
*/



//[runner, getposASL player] spawn A3C_forceDestination;
A3C_forceDestination = {
	
	params ["_unit","_destination"];
	private ["_unitPos","_anims","_dist","_relDir","_dirto","_offset","_speed","_c","_exit","_target","_t"];
	private _target = if (count _this > 2) then {_this select 2} else {objnull};
	private _doRotate = if (count _this > 3) then {_this select 3} else {true};
	
	private _unitPos = getpos _unit; //_unit doMove _unitPos; _unit moveTo _unitPos;
	private _dirto = [_unitPos,_destination] call BIS_fnc_dirTo;	
	
	if (((_unitPos select 2) > 1) && {abs ((_unitPos select 2) - (_destination select 2)) > 0.2}) exitWith {};
	{[_unit,_x] remoteExec ["disableAI",_unit]} foreach ["ANIM","MOVE","PATH"];
	
	
	
	private _handle = _unit addEventHandler
	[
		"HandleDamage",
		{
			params ["_unit","_hitselection","_damage","_source"];
			_effectiveDamage = if (isNull _source OR {side _source == civilian OR {side _source getFriend side _unit >= 0.6}}) then {0} else {_damage};
			_effectiveDamage
		}
	];
	

	_animFnc = {
		params ["_u"];
		private ["_ind","_sA","_eA"];
		_sA = ['amovpercmwlksraswrfldf','amovpknlmwlkslowwrfldf','amovppnemevaslowwrfldf'];
		_eA = ['aidlpercmstpsraswrfldnon_ai','aidlpknlmstpsraswrfldnon_ai','aidlppnemstpsraswrfldnon_ai'];
		_ind = switch (stance _u) do {
			case ("STAND")  : {0};
			case ("CROUCH") : {1};
			case ("PRONE")  : {2};
		};
		[_sA select _ind,_eA select _ind]
	};
	
	_anims = [_unit] call _animFnc;

	//_dist = _unit distance2D _destination;
	
	if (_doRotate) then {
		_duration = linearConversion [0,180,(abs (180 - (_unit getRelDIr _destination))),0,1];
		_subBehaviour = 
		[
			_unit,
			getPosASL _unit,
			getPosASL _unit,
			vectorDirVisual _unit,
			[_unit getDir _destination] call MCSS_fnc_DegreeToVector,
			vectorUpVisual _unit,
			[0,0,1],
			_duration
		] spawn A3C_ai_rail_fnc_vehicleOrient;
		waituntil {scriptDone _subBehaviour};
		//_scr1 = [_unit,_destination] spawn A3C_FORCEORIENT;
		//waituntil {scriptDone _scr1};
	} else {
		(vehicle _unit) setDir _dirTo;
	};
	
	{[_unit,_x] remoteExec ["disableAI",_unit];} foreach ["MOVE","PATH","ANIM"];
	
	//if (isNull objectParent _unit) exitWith {
		//private _scr = [_unit,_destination,_anims] spawn A3C_unitDYN_inf;
		//waituntil {scriptDone _scr}; //-- wait so that RAIL script can kow we are really done
	//};
	
	
	
		
	_c = 0;
	_strikes = 0;
	_exit = false;
	_unitPos = getpos _unit;
	
	_fnc = {
		params ["_anims","_unit","_destination"];
		private ["_dirTo","_relDir","_relDirABS","_dist","_vel","_allowMovement"];
		_allowMovement = true;
		//if (_unit == leader group _unit) then {
		//	hint str (_unit distance2d _destination);
		//};
		if (A3C_EHM) then {
			if (_unit getVariable ["A3C_EM_ACTIVE",false]) then {
				//-- unit is climbing
				_allowMovement = false;
				
			} else {
				if (_unit distance2d _destination > 1.5 && {[_unit,_destination] call A3C_Babe_fnc_detect}) then {
					{[_unit,_x] remoteExec ["enableAI",_unit]} foreach ["ANIM","MOVE","PATH"];
					//systemchat 'meh';
					_unit setVariable ["A3C_EM_ACTIVE",true,true];
					_allowMovement = false;
				};
			};
		};
		if (!isTouchingGround _unit) then {
			_allowMovement = false;
		};
		//hint str _allowmovement;
		if (_allowMovement) then {
			//hintsilent str "move";
			{[_unit,_x] remoteExec ["disableAI",_unit]} foreach ["ANIM","MOVE","PATH"];
			if !(isTouchingGround _unit) then {
				_refPos1 = +(getposASL _unit);
				_refPos2 = +(getposASL _unit);
				_refPos2 set [2,(_refPos2 select 2) - 1];
				_liF = (lineintersectsSurfaces [_refPos1,_refPos2,_unit,objnull]);
				if (count _liF > 0) then {
					_refPos2 set [2, ((_lif select 0) select 0) select 2];
					_unit setPosASL _refPos2;
				//} else {
				//	_exit = true;
				};
			};
			_dirTo = _unit getDir _destination;
			_unit setVectorDir ([_dirto] call MCSS_fnc_DegreeToVector);
			_unit lookAt (_destination getpos[100,_dirTo]);
			_relDir = [_unit,_destination] call BIS_fnc_RelativeDirTo;
			_dist = _unit distance _destination;
			_relDirABS = +(_relDir);		
			while {_relDirABS > 180} do {_relDirABS = _relDirABS - 360};
			_relDirABS = abs _relDirABS;
			
			//_vel = if (_dist > 1) then {2.5} else {4};
			private _speed = 10 / 3.6;
			

			//if !(animationstate _unit == (_anims select 0)) then {
			if (moveTime _unit == 0) then {
				[_unit,(_anims select 0)] remoteExec ["playMoveNow",_unit]; //"amovpercmtacsraswrfldf"
				
			};
			if (moveTime _unit > 0) then {
				private _vel =  
				[
					_speed * sin _dirTo, //(sin ([_unit,_destination] call BIS_fnc_dirTo)),
					_speed * cos _dirTo, //(cos ([_unit,_destination] call BIS_fnc_dirTo)),
					0
				];
				[_unit,_vel] remoteExec ["setVelocity",_unit];
			};
			

		//} else {
		//	hintsilent str "pause";
		};
		
	};
	//systemchat str _anims;
	//if (true) exitWith {};
	

	
	
	
	[
		str _unit,
		"onEachFrame",
		compile format 
		[
			'
				[%1,%2,%3] call %4;
			',
			_anims,
			_unit,
			_destination,
			_fnc		
		] 
	] call BIS_fnc_addStackedEventHandler;
	_initPos = getPosASL _unit;
	_originaldist = _unit distance2D _destination;
	_bsCounter = 0;
	_checkedPosition = getPosASL _unit;
	_moveTime = 0;
	while {alive _unit} do {
		_dist = _unit distance2D _destination;
		if (_dist < 0.3) exitWith {};
		if ({_unit distance2d _x > _originaldist} count [_initPos,_destination] > 1) exitWith {};
		if ("ladder" in animationState _unit) exitWith {};
		sleep 0.1;
		if (_moveTime == movetime _unit OR {(_unit Distance2d _checkedPosition) < 0.2 && {!(_unit getVariable ["A3C_EM_ACTIVE",false])}}) then {
			_bsCounter = _bsCounter + 1;
		};
		if (_bsCounter > 30) exitWith {};
		_checkedPosition = getPosASL _unit;
		_moveTime = moveTime _unit;
	};	
	/*
	_dest = ((expectedDestination _unit) select 0);
	_t = time;
	while {alive _unit} do {	
		
		_dirto = [_unitPos,_destination] call BIS_fnc_dirTo;	
		if ( ((expectedDestination _unit) select 0) distance2d _dest > 1) exitWith {	
			_exit = true; 
		};
		
		if !(isTouchingGround _unit) then {
			_refPos1 = +(getposASL _unit);
			_refPos2 = +(getposASL _unit);
			_refPos2 set [2,(_refPos2 select 2) - 1];
			_liF = (lineintersectsSurfaces [_refPos1,_refPos2,_unit,objnull]);
			if (count _liF > 0) then {
				_refPos2 set [2, ((_lif select 0) select 0) select 2];
				_unit setPosASL _refPos2;
			} else {
				_exit = true;
			};
		};
		if (_exit) exitWith {};
		if (time - _t > 1) then {
			_t = time;	
			if ( (_unitPos distance (position _unit)) < 0.2) then {
				_c = _c + 1;
			} else {
				_unitPos = getpos _unit;
				_c = 0;
			};
		};
		if (_c >= 2) exitWith {};
		_dist = _unit distance2D _destination;
		if (_dist < 0.2) exitWith {};		
	};
	*/
	
	//-- stop fake walking
	[(str _unit),"onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	[_unit,[0,0,0]] remoteExec ["setVelocity",_unit];	
	//_unit setvelocity [0,0,0];
	//_unit playMoveNow (_anims select 1);
//	[_unit,(_anims select 1)] remoteExec ["playMoveNow",_unit];
//	[_unit,(_anims select 1)] remoteExec ["playMove",_unit];
	//_unit playMove (_anims select 1);
	//_unit lookat objnull;
	//sleep 1;
	[_unit,(_anims select 1)] remoteExec ["playMoveNow",_unit];
	
	sleep 1;
	
	//if (_exit) exitWith {};
	//if ((typename _target == "OBJECT") && {_target isKindOf "house"}) exitWith {};
	//_unit setposASL _destination;
	
	
	{[_unit,_x] remoteExec ["enableAI",_unit]} foreach ["ANIM","MOVE","PATH"];
	[_unit,_handle] spawn {
		params ["_unit","_handle"];
		sleep 5;
		_unit removeEventHandler ["HandleDamage",_handle];
	};	
};