// A3C_ai_highCommand_fnc_moduleCAS

//-- Adaptation of BIS_fnc_moduleCAS

private _fnc_scriptNameParent = if (isNil "_fnc_scriptName") then {"BIS_fnc_moduleCAS"} else {_fnc_scriptName};
private _fnc_scriptName = "A3C_ai_highCommand_fnc_moduleCAS";
scriptName _fnc_scriptName;

private _logic = _this select 0;
private _units = _this select 1;
private _activated = _this select 2;
private _plane  = _this select 3;
private _caller = _this select 4;

private _pilot = driver _plane;
private _gp = group _pilot;

if (_activated) then {
	if (_logic call BIS_fnc_isCuratorEditable) then {
		waitUntil {!isNil {_logic getVariable "vehicle"} || isNull _logic};
	};

	if (isNull _logic) exitWith {};

	if ({local _x} count (objectCurators _logic) > 0) then {
		_logic hideObject false;
		_logic setPos position _logic;
	};

	private _cfgVehicles = configFile >> "CfgVehicles";
	private _cfgWeapons = configFile >> "CfgWeapons";

	private _planeClass = _logic getVariable ["vehicle","B_Plane_CAS_01_F"];
	private _planeCfg = _cfgVehicles >> _planeClass;

	if !(_planeClass == (typeOf _plane)) exitWith {
		["Planetypes do not match",nil] call BIS_fnc_error;
		false
	};

	_pilot doMove (getPos _logic);
	_pilot moveTo (getPos _logic);

	waitUntil {
		private _r = _plane getRelDir _logic;

		if (_r > 180) then {
			_r = 360 - _r;
		};

		_r < 20
	};

	private _dirVar = _fnc_scriptName + typeOf _logic;
	_logic setDir (missionNamespace getVariable [_dirVar,direction _logic]);

	private _weaponTypesID = _logic getVariable ["type",getNumber (_cfgVehicles >> typeOf _logic >> "moduleCAStype")];

	private _weaponTypes = switch _weaponTypesID do {
		case 0: {["machinegun"]};
		case 1: {["missilelauncher"]};
		case 2: {["machinegun","missilelauncher"]};
		case 3: {["bomblauncher"]};
		default {[]};
	};

	private _weapons = [];

	{
		private _weapon = _x;

		if (toLower ((_weapon call BIS_fnc_itemType) select 1) in _weaponTypes) then {
			private _modes = getArray (_cfgWeapons >> _weapon >> "modes");

			if (count _modes > 0) then {
				private _mode = _modes select 0;

				if (_mode == "this") then {
					_mode = _weapon;
				};

				_weapons set [count _weapons,[_weapon,_mode]];
			};
		};
	} forEach (_planeClass call BIS_fnc_weaponsEntityType);

	if (count _weapons == 0) exitWith {
		["No weapon of types %2 wound on '%1'",_planeClass,_weaponTypes] call BIS_fnc_error;
		false
	};

	private _posATL = getPosATL _logic;
	private _pos = +_posATL;
	_pos set [2,(_pos select 2) + getTerrainHeightASL _pos];

	private _dir = direction _logic;

	private _dis = 3000;
	private _alt = 1000;
	private _pitch = atan (_alt / _dis);
	private _speed = 400 / 3.6;
	private _duration = ([0,0] distance [_dis,_alt]) / _speed;

	private _planeAltitude = (getPosATL _plane) select 2;

	[_pilot] remoteExec ["setBehaviourStrong",_pilot];

	private _isLeader = _pilot == leader group _pilot;

	if (_isLeader) then {
		[
			[_gp,_pos,_caller],
			{
				params ["_gp","_pos","_caller"];

				if (getPlayerUID player == _caller) then {
					systemChat format ["This is %1-1, CAS at %2 is imminent",parseText (groupID _gp), mapGridPosition _pos];
				};
			}
		] remoteExec ["BIS_fnc_call",0];
	};

	{
		[_plane,_x] remoteExec ["disableAI",_plane];
	} forEach ["move","target","autotarget"];

	[_plane,"blue"] remoteExec ["setCombatMode",_plane];

	private _planePos = getPosATL _plane;
	private _planeSide = (getNumber (_planeCfg >> "side")) call BIS_fnc_sideType;

	private _vectorDir = [_planePos,_pos] call BIS_fnc_vectorFromXtoY;
	private _velocity = [_vectorDir,_speed] call BIS_fnc_vectorMultiply;

	_plane setVectorDir _vectorDir;
	[_plane,-90 + atan (_dis / _alt),0] call BIS_fnc_setPitchBank;

	private _vectorUp = vectorUp _plane;

	private _currentWeapons = weapons _plane;

	{
		private _weapon = _x;

		if !(toLower ((_weapon call BIS_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
			[_plane,_weapon] remoteExec ["removeWeapon",_plane];
		};
	} forEach _currentWeapons;

	//-- if I understand correctly, Fired EH only has to be added on the executing machine
	private _ehFired = _plane addEventHandler [
		"Fired",
		{
			_this spawn {
				private _plane = _this select 0;

				_plane removeEventHandler ["Fired",_plane getVariable ["ehFired",-1]];
				[_plane,["Fired",_plane getVariable ["ehFired",-1]]] remoteExec ["removeEventHandler",_plane];

				private _projectile = _this select 6;

				waitUntil {isNull _projectile};

				[[0.005,4,[_plane getVariable ["logic",objNull],200]],"BIS_fnc_shakeCuratorCamera"] call bis_fnc_mp;
			};
		}
	];

	_plane setVariable ["ehFired",_ehFired];
	_plane setVariable ["logic",_logic];

	private _fire = [] spawn {waitUntil {false}};
	private _fireNull = true;
	private _time = time;
	private _offset = if ({_x == "missilelauncher"} count _weaponTypes > 0) then {20} else {0};

	waitUntil {
		private _fireProgress = _plane getVariable ["fireProgress",0];

		if ((getPosATL _logic distance _posATL > 0 || direction _logic != _dir) && _fireProgress == 0) then {
			_posATL = getPosATL _logic;
			_pos = +_posATL;
			_pos set [2,(_pos select 2) + getTerrainHeightASL _pos];

			_dir = direction _logic;
			missionNamespace setVariable [_dirVar,_dir];

			_planePos = [_pos,_dis,_dir + 180] call BIS_fnc_relPos;
			_planePos set [2,(_pos select 2) + _alt];

			_vectorDir = [_planePos,_pos] call BIS_fnc_vectorFromXtoY;
			_velocity = [_vectorDir,_speed] call BIS_fnc_vectorMultiply;

			[_plane,_vectorDir] remoteExec ["setVectorDir",_plane];

			_vectorUp = vectorUp _plane;

			private _movePos = [_pos,_dis,_dir] call BIS_fnc_relPos;

			[_pilot,_movePos] remoteExec ["doMove", _pilot];
			[_pilot,_movePos] remoteExec ["moveTo", _pilot];
		};

		[
			_plane,
			[
				_planePos,
				[_pos select 0,_pos select 1,(_pos select 2) + _offset + _fireProgress * 12],
				_velocity,
				_velocity,
				_vectorDir,
				_vectorDir,
				_vectorUp,
				_vectorUp,
				(time - _time) / _duration
			]
		] remoteExec ["setVelocityTransformation",_plane];

		[_plane,velocity _plane] remoteExec ["setVelocity",_plane];

		if ((getPosASL _plane) distance _pos < 1000 && _fireNull) then {
			private _target = ((position _logic nearEntities ["LaserTarget",250])) param [0,objNull];

			if (isNull _target) then {
				_target = createVehicle ["LaserTargetC",position _logic,[],0,"NONE"];
			};

			[_plane,laserTarget _target] remoteExec ["reveal",_plane];
			[_plane,laserTarget _target] remoteExec ["doWatch",_plane];
			[_plane,laserTarget _target] remoteExec ["doTarget",_plane];

			_fireNull = false;

			terminate _fire;

			_fire = [_plane,_weapons,_target,_weaponTypesID] spawn {
				private _plane = _this select 0;
				private _planeDriver = driver _plane;
				private _weapons = _this select 1;
				private _target = _this select 2;
				private _weaponTypesID = _this select 3;
				private _duration = 3;
				private _time = time + _duration;

				waitUntil {
					{
						[_planeDriver,[_target,(_x select 0)]] remoteExec ["fireAtTarget",_planeDriver];
					} forEach _weapons;

					_plane setVariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];

					sleep 0.1;

					time > _time || _weaponTypesID == 3 || isNull _plane
				};

				sleep 1;
			};
		};

		sleep 0.01;

		scriptDone _fire || isNull _logic || isNull _plane
	};

	[_plane,velocity _plane] remoteExec ["setVelocity",_plane];
	[_plane,_alt] remoteExec ["flyInHeight",_plane];

	_gp setVariable ["CAS_COMPLETED",true,true];

	{
		[_plane,_x] remoteExec ["enableAI",_plane];
	} forEach ["move","target","autotarget"];

	[_plane,"YELLOW"] remoteExec ["setCombatMode",_plane]; //~~ gfetch combatmode before and reset here

	if ({_x == "bomblauncher"} count _weaponTypes == 0) then {
		for "_i" from 0 to 1 do {
			[driver _plane,["CMFlareLauncher","Burst"]] remoteExec ["forceWeaponFire",driver _plane];
			driver _plane forceWeaponFire ["CMFlareLauncher","Burst"];

			_time = time + 1.1;

			waitUntil {time > _time || isNull _logic || isNull _plane};
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
		] remoteExec ["BIS_fnc_call",0];
	};

	sleep 2;

	if (((count (waypoints _gp) - 1) > (currentWaypoint _gp))) then {
		private _wpc = currentWaypoint _gp;
		[_gp,currentWaypoint _gp] call A3C_ai_highCommand_fnc_removeWaypoint;
	} else {
		deleteWaypoint [_gp,currentWaypoint _gp];
	};

	sleep 18;

	if !(isNull _logic) then {
		sleep 1;
		deleteVehicle _logic;
	};

	[_plane,_planeAltitude] remoteExec ["flyInHeight",_plane];
};