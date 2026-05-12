




A3C_REMOTE_VTOL_HandlerFNC = {
	/*
		INFORMATION / NOTE:
		Compared to the other guided bullet functions, this VTOL handlers do not replace the projectile. 
		While I don't claim to know everything, it seems that the projectile needs to be guided on every machine.
		Server might own the vehicle and needs to guide it's projectiles. But while the impacts from the server can be seen at
		the desired position, the client sees the tracers without guidance, which is a discrepancy.
		Therefore, the guidance is done on every machine.
	*/
	params ["_action", "_id", "_vehicleNetID"];
	private _allShips = (allmissionobjects "B_T_VTOL_01_armed_fixed_F") + (allmissionobjects "B_T_VTOL_01_armed_F");
	if (_allShips isEqualTo []) exitWith {};
	private _vtol = (_allShips select {netID _x == _vehicleNetID}) select 0;
	if (isNil '_vtol') exitWith {};
	private _existingHandlers = _vtol getVariable ["A3C_GUNSHIP_HANDLERS", []];
	if (_action == "ADD") then {
		_handler = _vtol addEventhandler
		[
			"FIRED",
			{
				params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
				
				
				// private _str = format ["FIRED HANDLER EXECUTED ON: %1", if (isServer) then {"SERVER"} else {"CLIENT"}];
				// _str remoteExec ["systemchat", 0];
				
				private _var = _vehicle getvariable ["A3C_VTOL_REMOTE_HANDLE", ["NoID", objNull, "NoBehavior"]];
				_var params ["_targetNetID","_snapObject","_behaviour"];
				private _allTargets = (allMissionObjects "CBA_O_InvisibleTargetAir"); // + (allMissionObjects "CBA_B_InvisibleTargetAir");	
				//-- reduce to only target with the correct netID
				_allTargets = _allTargets select {netID _x == _targetNetID};
				if (_allTargets isEqualTo []) exitWith {}; //-- No target found
				private _target = _allTargets select 0; //-- fetch object from array
				//-- execute projectile guidance
				[_vehicle, _projectile, 0, _target, objNull] spawn A3C_ExactoVTOL;
			}
		];
		_existingHandlers pushBack [_id, _handler];
	} else {
		{
			_x params ["_handlerID", "_handlerIndex"];
			if (_handlerID == _id) exitWith {
				_vtol removeEventHandler ["FIRED", _handlerIndex];
				_existingHandlers = _existingHandlers - [_x];
			};
		} foreach _existingHandlers;
	};
	// (str _existingHandlers) remoteExec ["systemchat", 0];
	_vtol setVariable ["A3C_GUNSHIP_HANDLERS", _existingHandlers, false];
};










A3C_ExactoVTOL = {
	params ["_unit","_projectile","_lock","_target"];

	if !(local _projectile) exitWith {};



	_projectile setDir (_projectile getDir _target);

	private _ammo = typeOf _projectile;
	private _vectorDir = vectorDir _projectile;
	private _vectorUp = vectorUp _projectile;
	private _posi = getPosASL _projectile;

	//-- default: use missile max speed
	_projectileSpeed = speed _projectile; // / 2;



	private _targetPosASL = (getPosASL _target);

	_counter = 0;

	while {alive _projectile} do {

		if (_lock > 0) then {
			//-- update target position for locked ammo
			_targetPosASL = (getPosASL _target);
		};

		_vd = _targetPosASL vectorDiff (getPosASL _projectile);
		_vd params ["_dX","_dY","_dZ"];
		_d = sqrt(_dx * _dx + _dy * _dy + _dz * _dz);

		_vx = 0;
		_vy = 0;
		_vz = 0;

		if ((_d * _projectileSpeed) > 0) then {
			_vx = _dx / _d * _projectileSpeed;
			_vy = _dy / _d * _projectileSpeed;
			_vz = _dz / _d * _projectileSpeed;
		};

		_velNew = [_vX,_vY,_vZ];
		
		// 	_tilt_to = [_projectile,position _target] call MCSS_fnc_TiltTowardsPos;
		// 	_tilt_to params ["_vDi","_vUp"];
		// 	_projectile setVectorDirAndUp [_vDi,_vUp];

		if (_counter >= 1) exitWith {};
		_counter = _counter + 1;

		_projectile setVelocity _velNew;

		// if (speed _projectile < 30) exitWith {	
		// 	_projectile setDamage 1;
		// };

		// if (_projectile distance _target < 100) exitWith {};

		// if ('20mm' in (toLower _ammo) && {_projectile distance _target < 100}) exitWith {};
		// if (true) exitWith {};
		sleep 0.2;
	};
};




