// A3C_ai_highCommand_fnc_moduleCAS

	//-- Adaptation of BIS_fnc_moduleCAS

	private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BIS_fnc_moduleCAS'} else {_fnc_scriptName};
	private _fnc_scriptName = 'A3C_ai_highCommand_fnc_moduleCAS';
	scriptName _fnc_scriptName;

	private _logic = _this select 0;
	private _units = _this select 1;
	private _activated = _this select 2;
	private _plane  = _this select 3;
	private _caller = _this select 4;

	private _pilot = driver _plane;
	private _gp = group _pilot;


	//if (!isserver && {local _x} count (objectcurators _logic) == 0) exitWith {};

	if (_activated) then {
		if (_logic call bis_fnc_isCuratorEditable) then {
			waituntil {!isnil {_logic getvariable "vehicle"} || isnull _logic};
		};

		if (isnull _logic) exitWith {};


		if ({local _x} count (objectcurators _logic) > 0) then {
			_logic hideobject false;
			_logic setpos position _logic;
		};

		//if !(isserver) exitWith {};

		_planeClass = _logic getvariable ["vehicle","B_Plane_CAS_01_F"];
		_planeCfg = configfile >> "cfgvehicles" >> _planeClass;

		if !(_planeClass == (typeOf _plane)) exitWith {
			["Planetypes do not match",nil] call bis_fnc_error;
			false
		};

		_pilot doMove (getPos _logic);
		_pilot moveTo (getPos _logic);

		waitUntil
		{
			_r = _plane getRelDir _logic;
			if (_r > 180) then {
				_r = 360 - _r;
			};
			_r < 20
		};

		//if !(isclass _planeCfg) exitWith {["Vehicle class '%1' not found",_planeClass] call bis_fnc_error; false};


		_dirVar = _fnc_scriptname + typeof _logic;
		_logic setdir (missionnamespace getvariable [_dirVar,direction _logic]);


		_weaponTypesID = _logic getvariable ["type",getnumber (configfile >> "cfgvehicles" >> typeof _logic >> "moduleCAStype")];
		_weaponTypes = switch _weaponTypesID do {
			case 0: {["machinegun"]};
			case 1: {["missilelauncher"]};
			case 2: {["machinegun","missilelauncher"]};
			case 3: {["bomblauncher"]};
			default {[]};
		};
		_weapons = [];
		{
			if (tolower ((_x call bis_fnc_itemType) select 1) in _weaponTypes) then {
				_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
				if (count _modes > 0) then {
					_mode = _modes select 0;
					if (_mode == "this") then {
						_mode = _x;
					};
					_weapons set [count _weapons,[_x,_mode]];
				};
			};
		} foreach (_planeClass call bis_fnc_weaponsEntityType);
		if (count _weapons == 0) exitWith {
			["No weapon of types %2 wound on '%1'",_planeClass,_weaponTypes] call bis_fnc_error;
			false
		};

		_posATL = getposatl _logic;
		_pos = +_posATL;
		_pos set [2,(_pos select 2) + getterrainheightasl _pos];
		_dir = direction _logic;

		_dis = 3000;
		_alt = 1000;
		_pitch = atan (_alt / _dis);
		_speed = 400 / 3.6;
		_duration = ([0,0] distance [_dis,_alt]) / _speed;

		_planeAltitude = (getposATL _plane) select 2;

		[(_pilot)] remoteExec ["setBehaviourStrong",(_pilot)];
		private _isLeader = _pilot == leader group (_pilot);
		if (_isLeader) then {
			[
		 		[_gp,_pos,_caller],
		 		{
					params ["_gp","_pos","_caller"];
					if (getPlayerUID player == _caller) then {
						systemChat format ["This is %1-1, CAS at %2 is imminent",parseText (groupID _gp), mapGridPosition _pos];
					};
				}
			] remoteExec ["bis_fnc_call",0];
		};

		{[_plane,_x] remoteExec ["disableAI",_plane]} foreach ["move","target","autotarget"];
		//{_plane disableAI _x} foreach ["move","target","autotarget"];
		[_plane,"blue"] remoteExec ["setCombatMode",_plane];

		_planePos = getposATL _plane;

		_planeSide = (getnumber (_planeCfg >> "side")) call bis_fnc_sideType;

		
		_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
		_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
		_plane setvectordir _vectorDir;
		[_plane,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
		_vectorUp = vectorup _plane;


		_currentWeapons = weapons _plane;
		{
			if !(tolower ((_x call bis_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
				[_plane,_x] remoteExec ["removeWeapon",_plane];
				//_plane removeweapon _x;
			};
		} foreach _currentWeapons;

		//-- if I understand correctly, Fired EH only has to be added on the executing machine
		_ehFired = _plane addeventhandler
		[
			"fired",
			{
				_this spawn {
					_plane = _this select 0;
					_plane removeeventhandler ["fired",_plane getvariable ["ehFired",-1]];
					[_plane,["fired",_plane getvariable ["ehFired",-1]]] remoteExec ["removeEventhandler",_plane];
					_projectile = _this select 6;
					waituntil {isnull _projectile};
					[[0.005,4,[_plane getvariable ["logic",objnull],200]],"bis_fnc_shakeCuratorCamera"] call bis_fnc_mp;
				};
			}
		];
		_plane setvariable ["ehFired",_ehFired];
		_plane setvariable ["logic",_logic];



		_fire = [] spawn {waituntil {false}};
		_fireNull = true;
		_time = time;
		_offset = if ({_x == "missilelauncher"} count _weaponTypes > 0) then {20} else {0};
		waituntil {
			_fireProgress = _plane getvariable ["fireProgress",0];
			if ((getposatl _logic distance _posATL > 0 || direction _logic != _dir) && _fireProgress == 0) then {
				_posATL = getposatl _logic;
				_pos = +_posATL;
				_pos set [2,(_pos select 2) + getterrainheightasl _pos];
				_dir = direction _logic;
				missionnamespace setvariable [_dirVar,_dir];

				_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
				_planePos set [2,(_pos select 2) + _alt];
				_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
				_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
		
				[_plane,_vectorDir] remoteExec ["setVectorDir",_plane];

				_vectorUp = vectorup _plane;
	
				[_pilot, ([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["doMove", _pilot];
				[_pilot,([_pos,_dis,_dir] call bis_fnc_relpos)] remoteExec ["moveTo", _pilot];
			};

			[
				_plane,
				[
					_planePos, [_pos select 0,_pos select 1,(_pos select 2) + _offset + _fireProgress * 12],
					_velocity, _velocity,
					_vectorDir,_vectorDir,
					_vectorUp, _vectorUp,
					(time - _time) / _duration
				]

			]
			remoteExec ["setVelocityTransformation",_plane];

			[_plane,velocity _plane] remoteExec ["setvelocity",_plane];


			if ((getposasl _plane) distance _pos < 1000 && _fireNull) then {
				_target = ((position _logic nearEntities ["LaserTarget",250])) param [0,objnull];
				if (isnull _target) then {
					_target = createvehicle ["LaserTargetC",position _logic,[],0,"none"];
				};
				[_plane,lasertarget _target] remoteExec ["reveal",_plane];

				[_plane,lasertarget _target] remoteExec ["doWatch",_plane];
		
				[_plane,lasertarget _target] remoteExec ["doTarget",_plane];
		

				_fireNull = false;
				terminate _fire;
				_fire = [_plane,_weapons,_target,_weaponTypesID] spawn {
				_plane = _this select 0;
				_planeDriver = driver _plane;
				_weapons = _this select 1;
				_target = _this select 2;
				_weaponTypesID = _this select 3;
				_duration = 3;
				_time = time + _duration;
				waituntil
				{
					{
						[_planeDriver,[_target,(_x select 0)]] remoteExec ["fireAtTarget",_planeDriver];
				
					} foreach _weapons;
					_plane setvariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];
					sleep 0.1;
					time > _time || _weaponTypesID == 3 || isnull _plane
				};
				sleep 1;
			};
		};

		sleep 0.01;
		scriptdone _fire || isnull _logic || isnull _plane
	};

	[_plane,velocity _plane] remoteExec ["setvelocity",_plane];

	[_plane,_alt] remoteExec ["flyInHeight",_plane];
	



	_gp setvariable ['CAS_COMPLETED',true,true];
	{[_plane,_x] remoteExec ["enableAI",_plane]} foreach ["move","target","autotarget"];
	
	[_plane,"YELLOW"] remoteExec ["setCombatMode",_plane]; //~~ gfetch combatmode before and reset here





	if ({_x == "bomblauncher"} count _weaponTypes == 0) then {
		for "_i" from 0 to 1 do {
			[driver _plane,["CMFlareLauncher","Burst"]] remoteExec ["forceWeaponFire",driver _plane];
			driver _plane forceweaponfire ["CMFlareLauncher","Burst"];
			_time = time + 1.1;
			waituntil {time > _time || isnull _logic || isnull _plane};
		};
	};
	sleep 2;
	if (_isLeader) then {
	 	[
	 		[_gp,_pos,_caller],
	 		{
				params ["_gp","_pos","_caller"];
				if (getPlayerUID player == _caller) then {
					systemChat format ["This is %1-1, CAS at %2 is complete",parseText (groupID _gp), mapGridPosition _pos];
				};
			}
		] remoteExec ["bis_fnc_call",0];
	};
	sleep 2;

		
	if ( ((count (waypoints _gp) - 1) > (currentwaypoint _gp)) ) then { //&& !(_actionType in ["SUPPRESSION","AMBUSH","CAS-STRIKE"])
		private _wpc = (currentWaypoint _gp);
		[_gp, currentwaypoint _gp] call A3C_ai_highCommand_fnc_removeWaypoint;
	} else {
		deletewaypoint [_gp,currentwaypoint _gp];
	};


	sleep 18;
	if !(isnull _logic) then {
		sleep 1;
		deletevehicle _logic;


	};

	[_plane,_planeAltitude] remoteExec ["flyInHeight",_plane];

};
