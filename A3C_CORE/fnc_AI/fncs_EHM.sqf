//[_x, true] call A3C_Babe_fnc_detect
//-- NEEDED
A3C_Babe_fnc_detect = {
	//private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_EM_fnc_detect'} else {_fnc_scriptName};
	//private _fnc_scriptName = 'BABE_EM_fnc_detect';
	//scriptName _fnc_scriptName;
	
	//#line 1 "\babe\babe_em\func\mov\fn_detect.sqf [BABE_EM_fnc_detect]"
	params ["_climber","_destination"];
	private _climbonly = true;
	if (isNil "_climber") then {
		_climber = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player]; 
	};
	private _mc_dir = if (isNil '_destination') then {getDir _climber} else {_climber getDir _destination};
	_babe_em_vars = _climber getvariable "babe_em_vars";
	if !(_babe_em_vars select 2) exitWith {false};
	
	_refPos1 = (((getPosASL _climber) getPos [0.5,_mc_dir]) select [0,2]) + [(getPosASL _climber) select 2];
	_refPos2 = (_refPos1 select [0,2]) + [0];
	
	_ins = lineIntersectsSurfaces
	[
		_refPos1,
		_refPos2,
		_climber,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	private _checkPos = (_ins select 0) select 0;
	
	//--A3C additions to check for AI drop
	private _doDrop = false;
	private _heightDiff = abs ( (getPosASL _climber select 2) - (_checkPos select 2)  );
	
	if ( (_checkPos select 2) < (getPosASL _climber select 2) && { _heightDiff < 3 && {_heightDiff > 0.5} }) then {
		_doDrop = true;
	};
	
	
	//if (_heightDiff > 0.5 && {_heightDiff < 3}) then {	
	//}; 
	
	
	
	//
	//_checkPos =  positionCameraToWorld [0,0,5];
	//_checkPos = player getpos [1,getdir player]
	_cos = 0; 
	if (_checkPos select 2 < (((getPosASL _climber) select 2) - 0.5)  ) then {
		_checkPos = ASLtoAGL _checkPos;
		_v1 = asltoagl(atltoasl(_climber modeltoworld (_climber selectionPosition "Head"))) vectorfromto _checkPos;
		_v2 = (_climber modeltoworld [0,0,0]) vectorfromto (_climber modeltoworld [0,0,-5]);
		_cos = _v1 vectorCos _v2;
	};

	

	_dpos = [0,0,0];
	
	
	//_cos = 0;
	//-- drop to lower position	
	//if (_cos > 0.8) exitWith {
	if (_doDrop) exitWith {
		//systemchat str time;
		for "_i" from 0 to 20 do { 
			_intcount = 0;

			_posa = _climber modeltoWorld [0, (_i*0.05), 0.5];   

			_posb = _climber modeltoWorld [0, (_i*0.05), -1.7];  

			_int = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"]; 

			_intcount = (count _int)+_intcount;



			_posa = _climber modeltoWorld [0, 0, (_i*0.05)];   

			_posb = _climber modeltoWorld [0, 1.5, (_i*0.05)];  		

			_int2 = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"]; 

			_intcount = (count _int2)+_intcount;		



			if (_intcount == 0) then {
				_anm = "";

				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_drop_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_drop_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_drop_pst";
					};
				};

				if (_anm != "" && str _dpos != "[0,0,0]") then {

					_babe_em_vars = _climber getvariable "babe_em_vars";
					_babe_em_vars set [0, true];
					_climber setVariable ["babe_em_vars", _babe_em_vars];

					[((name _climber) + "EH_em_drop"), {animationState (_condpars select 0) == (_condpars select 1)}, [_climber, _anm], "A3C_babe_em_fnc_exec_drop", [_dpos, _climber], true, "A3C_babe_em_fnc_finish_drop", [_climber], 0] call babe_core_fnc_addEH;

					_climber playMoveNow _anm;
				};
			} else {
				_dpos = (_int select 0) select 0;

			};
		};
		false
	};

	//-- climb
	_pos = [0,0,0];

	_posa = [0,0,0];

	_posb = [0,0,0];

	_toppos = [0,0,0];

	_goodZ = [];

	_blocked = false;

	_top = false;

	_poses = [];

	_int = [];

	_obj = _climber;

	for "_i" from 3 to 60 do  { 
		_posa = _climber modeltoWorld [0, 0, (_i*0.05)];   

		_posb = _climber modeltoWorld [0, 1.5, (_i*0.05)+ 0.1];
		//ball setpos _posB;   
		//systemchat str time;

		_int = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"]; 


		_respos = (_int select 0) select 0;

		_succ = count _int > 0;


		if (_succ) then {
			_obj = (_int select 0) select 3;

			if (EM_debug) then {
				drawLine3D [_posa, _posb, [1,0,0,1]];
			};

			_testpos = (_int select 0) select 0;

			_posWT = _climber worldToModel (asltoagl _testpos);

			if (_posWT select 2 > 0.5) then {
				_pos = _testpos;
				_goodZ pushback (_posWT select 1);
			};
		} else {
			if (str _pos != "[0,0,0]") then {
				_ppWT = (_climber worldtomodel (asltoagl _pos)) select 2;
				_tpWT = (_i*0.05)+ 0.1;

				_dst = (_ppWT max _tpWT) - (_ppWT min _tpWT);

				if (EM_debug) then {	
					drawLine3D [_posa, _posb, [0,1,1,1]];
				};

				_posWT = _climber worldToModel (asltoagl _pos);

				if (!(_pos in _poses) && _posWT select 2 > 0.5 && _dst > 0.5) then {
					_poses pushback _pos;
				};

			};
		};
	};

	if (typeOf _obj in EM_blacklist_obj) exitWith {false};


	if (count _poses > 0) then {
		_pos = _poses select 0;
	};




	_posWT = _climber worldToModel (asltoagl _pos);

	_posa = _climber modeltoWorld [_posWT select 0, (_posWT select 1) + 0.75, (_posWT select 2) + 0.5];

	_posb = _climber modeltoWorld [_posWT select 0, (_posWT select 1) + 0.75, (_posWT select 2) - 5];

	_toptest = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"];
	_toppos = (_toptest select 0)select 0;
	
	_obstacle = (_toptest select 0)select 2;
	
	
	
	_postopos = ((_toptest select 0)select 3);

	_top = !isNil "_postopos";

	if (!_top) then  {

		_toppos = agltoasl(_climber modeltoworld [0,2,0]);
	} else {
		
		_a = abs (_pos select 2);
		_b = abs (_toppos select 2);

		_max = _a max _b;

		if (_max == _a) then  {
			if (_a - _b > 0.6) then {
				_top = false;
				if (_a-_b > 1.8) then {
					_toppos = agltoasl(_climber modeltoworld [0,2,0]);
				};
			} else {
				_top = true
			};
		} else {
			_top = true;
		};
	};

	if (str _pos != "[0,0,0]" && _top) then {
		_avZ = 0;
		_min = 999;
		_max = 0;
		for "_i" from 0 to (count _goodZ)-1 do { 
			_z = _goodZ select _i;

			if (_i > 0) then {
				_min = _min min _z;	
				_max = _max max _z;
			};

			_avZ = _avZ + _z;
		};

		if (_max - _min > 0.5) then {
			_avZ = _avZ/(count _goodZ);

			_pos = agltoasl (_climber modeltoworld [_posWT select 0, _avZ, _posWT select 2]);
		};				
	};


	private _posWT = _climber worldToModel (asltoagl _pos);


	private _bone = _climber selectionPosition "Spine3";

	private _posa = _climber modeltoWorld _bone;

	private _posb = _climber modeltoWorld [_bone select 0, _bone select 1, (_posWT select 2)+0.5];

	private _int2 = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"];



	private _posa = _climber modeltoworld [0,0, (_posWT select 2) + 0.2];

	private _posb = _climber modeltoworld [_posWT select 0, (_posWT select 1)+ 0.2, (_posWT select 2) + 0.2];

	private _int3 = lineintersectsSurfaces [agltoasl _posa, agltoasl _posb, _climber, objNull, true, 1, "GEOM", "FIRE"];

	private _int2o = if (count _int2 > 0) then {_int2 select 0 select 2} else {objNull}; //-- modified
	private _int3o = if (count _int3 > 0) then {_int3 select 0 select 2} else {objNull};  //-- modified

	private _blocked = ((count _int2) + (count _int3) > 0) && ((!isNil "_int2o" or !isNil "_int3o") or {!isNull _int2o or !isNull _int3o});

	//private _blocked = ((count _int2) + (count _int3) > 0) && {};



	if (_blocked) then {
		_pos = [0,0,0];
	};

	if (!_top && _obj != _climber && _obj isKindOf "CaManBase") then  {
		_pos = [0,0,0];
	};

	_wide = true;

	if (!_top) then {
		_posWT = _climber worldToModel asltoagl _pos;

		_a = agltoasl (_climber modeltoworld [(_posWT select 0) + 0.3, _posWT select 1, (_posWT select 2)+0.2]);

		_b = agltoasl (_climber modeltoworld [(_posWT select 0) - 0.3, _posWT select 1, (_posWT select 2)+0.2]);

		_c = agltoasl (_climber modeltoworld [(_posWT select 0) + 0.3, (_posWT select 1) + 0.1, (_posWT select 2)+0.2]);

		_d = agltoasl (_climber modeltoworld [(_posWT select 0) - 0.3, (_posWT select 1) - 0.1, (_posWT select 2)+0.2]);

		_e = agltoasl (_climber modeltoworld [(_posWT select 0) + 0.3, (_posWT select 1) - 0.1, (_posWT select 2)+0.2]);

		_f = agltoasl (_climber modeltoworld [(_posWT select 0) - 0.3, (_posWT select 1) + 0.1, (_posWT select 2)+0.2]);

		_int1 = lineintersectsSurfaces [_a, _b, _climber, objNull, true, 1, "GEOM", "FIRE"]; 

		_int2 = lineintersectsSurfaces [_c, _d, _climber, objNull, true, 1, "GEOM", "FIRE"]; 

		_int3 = lineintersectsSurfaces [_e, _f, _climber, objNull, true, 1, "GEOM", "FIRE"]; 

		_wide = (count _int1) + (count _int2) + (count _int3) == 0;

	};

	if (EM_debug) then {
		//systemchat str [(count _int2), (count _int3), _wide, _top, _pos];
		babe_em_debug_a setposasl (_poses select 0);
	};

	if !_wide then {
		_pos = [0,0,0];
	};
	//systemchat str [_top, _wide];

	_blocked = false;

	if (str _pos != "[0,0,0]" && count _poses > 0) then {
		if (_top) then {
			_posa = _poses select 0;

			_posa set [2, (_posa select 2)+0.2];

			_posb = [_posa select 0, _posa select 1, (_posa select 2) + 1.25];

			_int4 = lineintersectsSurfaces [_posa, _posb, _climber, objNull, true, 1, "GEOM", "FIRE"];

			if (EM_debug) then {
				_a = createVehicle ["Sign_Arrow_F", _posa, [], 0, "can_collide"];
				_a setposasl _posa;
				_b = createVehicle ["Sign_Arrow_F", _posb, [], 0, "can_collide"];
				_b setposasl _posb;
			};

			_blocked = count _int4 != 0;
		} else {
			_rpos = _poses select 0;
			_mtw = agltoasl (_climber modeltoWorld [0,2,0]);
			_posa = [_rpos select 0, _rpos select 1, (_rpos select 2) + 0.5];

			_posb = [_mtw select 0, _mtw select 1, _posa select 2];

			_int5 = lineintersectsSurfaces [_posa, _posb, _climber, objNull, true, 1, "GEOM", "FIRE"];

			if (EM_debug) then {
				_a = createVehicle ["Sign_Arrow_F", _posa, [], 0, "can_collide"];
				_a setposasl _posa;
				_b = createVehicle ["Sign_Arrow_F", _posb, [], 0, "can_collide"];
				_b setposasl _posb;
			};

			_blocked = count _int5 != 0;
		};
	};
	//copytoclipboard str (typeOf _obstacle);
	//if (typeOf _obstacle in []) then {
	//	_blocked = true;
	//};
	if (_pos isEqualTo [0,0,0]) exitWith {};
	if (!_blocked) then {
		
		

		/*
		private _sb = 
		[
			_climber,
			getPosASL _climber,
			getPosASL _climber,
			vectorDirVisual _climber,
			[_refDir] call MCSS_fnc_DegreeToVector,
			vectorUpVisual _climber,
			[0,0,1],
			0.5
		] spawn A3C_ai_rail_fnc_vehicleOrient;
		waituntil {scriptDone _sb};
		*/
		if !( _obstacle isKindOf "MAN" && {stance _climber in ["STAND","PRONE"]}) then {
			//-- added A3C commands for rooftops / forced paths
			_refPos = (((getPosASL _climber) getPos [-100,_mc_dir + 180]) select [0,2]) + [getPosASL _climber select 2];
			
			_refDir = [
				getPosASL _climber,
				_refPos,
				_climber,
				objNull,
				true	
			] call A3C_main_fnc_getSurfaceNormalAzimuth;

			// systemchat str _refDir;
			
			// _refDir = 
			// [
			// 	( ([_refPos,_obstacle] call A3C_UI_squadPlacement_fnc_snapFormation) select 2) + 180
			// ] call mcss_fnc_correctDir;
			_climber setdir _refDir;
			[_pos, _top, _toppos, _climber, _climbonly] call A3C_Babe_fnc_EM; //babe_em_fnc_em;
			_climber setVariable ["A3C_EM_ACTIVE",true,true];
			//systemchat str [_refDir, _pos, _top, _toppos];
		};
		
	};
	_return = !_blocked;
	_return
};






//--NEEDED
A3C_Babe_fnc_EM = {
	//private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_EM_fnc_em'} else {_fnc_scriptName};
	//private _fnc_scriptName = 'BABE_EM_fnc_em';
	//scriptName _fnc_scriptName;

	//#line 1 "\babe\babe_em\func\mov\fn_em.sqf [BABE_EM_fnc_em]"
	params ["_pos", "_top", "_toppos", "_climber", "_climbonly"];
//	player commandchat format ["%1 is climbing",name _climber];
//	_h = (getposASL _Climber) select 2;
//	_tpos = _climber getpos [2,0];
//	_tpos set [2,_h];
//	player setPosASL _tpos;
//	player setDir 180; 
	
	
	_st = stance _climber;
	_stnope = ["PRONE"];

	_babe_em_vars = _climber getvariable "babe_em_vars";

	if ((_babe_em_vars select 0) or (damage _climber) > 0.85 or _st in _stnope or vehicle _climber != _climber) exitWith {}; 

	if (_climber == player) then {
		_babe_em_vars set [0, false];
		_babe_em_vars set [1, false];
	};



	_stepa = EM_heightsOn select 0;
	_stepb = EM_heightsOn select 1;

	_ona = EM_heightsOn select 1;
	_onb = EM_heightsOn select 2;

	_onha = EM_heightsOn select 2;
	_onhb = EM_heightsOn select 3;

	_onhera = EM_heightsOn select 3;
	_onherb = EM_heightsOn select 4;


	_vaulta = EM_heightsOver select 0;
	_vaultb = EM_heightsOver select 1;

	_overa = EM_heightsOver select 1;
	_overb = EM_heightsOver select 2;

	_overha = EM_heightsOver select 2;
	_overhb = EM_heightsOver select 3;

	_overhera = EM_heightsOver select 3;
	_overherb = EM_heightsOver select 4;

	_wl1 = EM_weightlimits select 0;

	_wl2 = EM_weightlimits select 1;

	_wl3 = EM_weightlimits select 2;

	_wlj = EM_weightlimits select 3;


	_enableover = EM_enable select 0;
	_enableon = EM_enable select 1;


	EM_default_animspeedcoef = getAnimSpeedCoef player; //-- can stay. if player is objNull, it will still return 1


	_anm = "";

	_stmpn = 2;
	_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);

	if (str _pos == "[0,0,0]") exitWith {
		if (isTouchingGround _climber && {!(_babe_em_vars select 0) && (getstamina _climber > 8) && isNil "_climbonly"}) then {
			[_climber, _wlj] call babe_em_fnc_jump
		};
	};

	_h = ((_climber worldToModel asltoagl _pos) select 2) max 0;



	
	_over = false;

	if (_top) then {

		switch (true) do {
			case (_h > _onhera && _h <= _onherb && load _climber < _wl3 && _enableon): {
				_stmpn = 10;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climbonHer_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climbonHer_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climbonHer_pst";
					};
				};
			};
			case (_h > _onha && _h < _onhb && load _climber < _wl2 && _enableon): {
				_stmpn = 8;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climbonH_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climbonH_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climbonH_pst";
					};
				};
			};
			case (_h > _ona && _h <= _onb && load _climber < _wl1 && _enableon): {
				_stmpn = 6;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climbon_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climbon_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climbon_pst";
					};
				};
			};
			case (_h > _stepa && _h <= _stepb): {
				_stmpn = 2;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_stepon_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_stepon_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_stepon_pst";
					};
				};
			};
		};
	} else {
		switch (true) do {
			case (_h > _overhera && _h <= _overherb && load _climber < _wl3 && _enableover): {
				_stmpn = 10;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climboverHer_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climboverHer_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climboverHer_pst";
					};
				};
			};
			case (_h > _overha && _h <= _overhb && load _climber < _wl2 && _enableover): {
				_stmpn = 8;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climboverH_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climboverH_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climboverH_pst";
					};
				};
			};
			case (_h > _overa && _h < _overb && load _climber < _wl1 && _enableover): {
				_stmpn = 6;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_climbover_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_climbover_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_climbover_pst";
					};
				};
			};
			case (_h > _vaulta && _h <= _vaultb): {
				_stmpn = 4;
				_stmpn = _stmpn * 0.5 + _stmpn * 0.5 * (load _climber);
				switch (currentWeapon _climber) do {
					case (""): {
						_anm = "babe_vaultover_ua";
					};
					case (primaryWeapon _climber): {
						_anm = "babe_vaultover_rfl";
					};
					case (handgunWeapon _climber): {
						_anm = "babe_vaultover_pst";
					};
				};
			};
		};
		_over = true;	
	};
	if (_anm == "") exitWith  {
		if (isTouchingGround _climber && {!(_babe_em_vars select 0) && (getstamina _climber > 8) && isNil "_climbonly"}) then {
			[_climber, _wlj] call babe_em_fnc_jump			
		};
	};
	_babe_em_vars = _climber getvariable "babe_em_vars";
	_babe_em_vars set [0, true];
	_climber setVariable ["babe_em_vars", _babe_em_vars];

	[((name _climber) + "EH_em"), {animationState (_condpars select 0) == (_condpars select 1)}, [_climber, _anm], "A3C_babe_em_fnc_exec_em", [_pos, _over, _climber], true, "A3C_babe_em_fnc_finish_em", [_toppos, _over, _stmpn, _climber], 0] call babe_core_fnc_addEH;
	_climber setAnimSpeedCoef 1-(load _climber)*0.3;
	_climber playMoveNow _anm;
};




//-- NEEDED
A3C_babe_em_fnc_exec_em = {
	//private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_EM_fnc_exec_em'} else {_fnc_scriptName};
	//private _fnc_scriptName = 'BABE_EM_fnc_exec_em';
	//scriptName _fnc_scriptName;

	params ["_pos", "_over", "_climber","_animClip"];
	

	[
		((name _climber) + "EH_em_loop"),
		{((_condpars select 0) getVariable "babe_em_vars") select 0},
		[_climber],
		{(_pars select 0) setVelocity [0,0,0]}, //--_pars??
		[_climber],
		false,
		{},
		[],
		0
	] call babe_core_fnc_addEH;

	_help = _climber getVariable "A3C_EM_helper";

	if (!isPlayer _climber) then {
		_help = "babe_helper" createVehicleLocal [0,0,0];
		[_climber,_help] spawn {
			params ["_climber","_help"] ;
			sleep 4;
			deleteVehicle _help;
			_climber setVariable ["A3C_EM_helper",nil,true];
		};
	};

	_help setposASL _pos;

	_help setdir getdir _climber;

	_poswt = _climber worldtomodel (asltoagl _pos);

	if (_over) then { 
		_climber setposASL (agltoasl (_climber modeltoworld [_posWT select 0, _posWT select 1, (_posWT select 2) + 0.1]));
	} else {
		_climber setposASL (agltoasl (_climber modeltoworld [_posWT select 0, (_posWT select 1)+0.1, (_posWT select 2) + 0.1]));
	};
};

//--NEEDED
A3C_babe_em_fnc_finish_em = {

	params ["_toppos", "_over", "_stmpn", "_climber"];

	[((name _climber) + "EH_em")] call babe_core_fnc_removeEH;
	[((name _climber) + "EH_em_loop")] call babe_core_fnc_removeEH;

	_climber setStamina (getStamina _climber)-_stmpn;

	_help = _climber getVariable "A3C_EM_helper";

	if (_over) then
	{ 
		_climber setposASL _toppos;
	};

	_help setpos [0,0,0];

	_babe_em_vars = _climber getvariable "babe_em_vars";
	_babe_em_vars set [0, false];
	_babe_em_vars set [1, false];
	
	_climber setVariable ["babe_em_vars", _babe_em_vars];
	_climber setAnimSpeedCoef EM_default_animspeedcoef;
	_climber spawn {
		//sleep 0.5;
		waituntil {isTouchingGround _this && {!('babe' in animationstate _this)}};
		//sleep 0.5;
		_this setVariable ["A3C_EM_ACTIVE",nil,true];
	};

	if (_climber == player)then
	{
		EM_busy = false;
		EM_climbing = false;
	};
	//_climber setVariable ["A3C_EM_climbing",false,false];
};

A3C_babe_em_fnc_finish_drop = {
	//private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_EM_fnc_finish_drop'} else {_fnc_scriptName};
	//private _fnc_scriptName = 'BABE_EM_fnc_finish_drop';
	//scriptName _fnc_scriptName;

	//#line 1 "\babe\babe_em\func\mov\fn_finish_drop.sqf [BABE_EM_fnc_finish_drop]"
	params ["_climber"];

	[((name _climber) + "EH_em_drop")] call babe_core_fnc_removeEH;

	[((name _climber) + "EH_em_loop")] call babe_core_fnc_removeEH;

	babe_em_help setpos [0,0,0];

	_babe_em_vars = _climber getvariable "babe_em_vars";
	_babe_em_vars set [0, false];
	_babe_em_vars set [1, false];
	_climber setVariable ["babe_em_vars", _babe_em_vars];
	_climber spawn {
		//sleep 0.5;
		waituntil {isTouchingGround _this && {!('babe' in animationstate _this)}};
		//sleep 0.5;
		_this setVariable ["A3C_EM_ACTIVE",nil,true];
		_this setvelocity [0,1,0];
	};

};


//-- NEEDED

A3C_babe_em_fnc_exec_drop = {
	//private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_EM_fnc_exec_drop'} else {_fnc_scriptName};
	//private _fnc_scriptName = 'BABE_EM_fnc_exec_drop';
	//scriptName _fnc_scriptName;

	//#line 1 "\babe\babe_em\func\mov\fn_exec_drop.sqf [BABE_EM_fnc_exec_drop]"
	params ["_pos", "_climber"];

	[((name _climber) + "EH_em_loop"), {((_condpars select 0) getVariable "babe_em_vars") select 0}, [_climber], {(_pars select 0) setVelocity [0,0,0]}, [_climber], false, {}, [], 0] call babe_core_fnc_addEH;

	_endpos = [_pos select 0, _pos select 1, (_pos select 2)-1.9];

	_help = _climber getVariable "A3C_EM_helper";

	if (!isPlayer _climber) then {
		_help = "babe_helper" createVehicleLocal [0,0,0];
		_climber setVariable ["A3C_EM_helper",_help,true];
		[_climber,_help] spawn {
			params ["_climber","_help"] ;
			sleep 4;
			deleteVehicle _help;
			_climber setVariable ["A3C_EM_helper",nil,true];
		};
	};

	_help setposASL _endpos;

	_help setdir getdir _climber;

	_poswt = _climber worldtomodel (asltoagl _endpos);

	_climber setposASL (agltoasl (_climber modeltoworld [_posWT select 0, (_posWT select 1)+0.1, (_posWT select 2) + 0.1]));
	
};




/*
A3C_babe_em_fnc_exec_drop1 = {
	params ["_pos", "_climber"];
	systemchat 't2';
	private ["_endPos"];
	[
		format
		[
			"EH_em_loop%1",
			_climber getvariable ['A3C_FORMATION_INDEX', name _climber]
		],
		{(_climber getVariable "A3C_EM_climbing")},
		[],
		{},
		[],
		false,
		{},
		[],
		0
	] call A3C_babe_core_fnc_addEH; //systemchat str _this; player setVelocity [0,0,0]
	_endpos = [_pos select 0, _pos select 1, (_pos select 2)-1.9];
	_help = "babe_helper" createVehicleLocal [0,0,0];
	_climber setVariable ["A3C_EM_helper",_help,false];
	_help setposASL _endpos;
	_help setdir getdir _climber;
	_poswt = _climber worldtomodel (asltoagl _endpos);
	_climber setposASL (agltoasl (_climber modeltoworld [_posWT select 0, (_posWT select 1)+0.1, (_posWT select 2) + 0.1]));
};


A3C_babe_em_fnc_finish_drop = {
	params ["_climber"];
	systemchat 't3';
	[
		format 
		[
			"EH_em_drop%1",
			_climber getvariable ['A3C_FORMATION_INDEX', name _climber]
		]
	] call babe_core_fnc_removeEH;	
	[
		format
		[
			"EH_em_loop%1",
			_climber getvariable ['A3C_FORMATION_INDEX', name _climber]
		]
	] call babe_core_fnc_removeEH;
	deletevehicle (_climber getVariable "A3C_EM_helper");

	if (_climber == player)then
	{
		EM_busy = false;
		EM_climbing = false;
	} else {
		_climber setVariable ["A3C_EM_climbing",false,false];
	};
};



A3C_babe_core_fnc_addEH = {
	private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'BABE_CORE_fnc_addEH'} else {_fnc_scriptName};
	private _fnc_scriptName = 'BABE_CORE_fnc_addEH';
	scriptName _fnc_scriptName;

	params ["_id", "_cond", "_condpars", "_fnc", "_pars", "_switch", "_switchfnc", "_switchpars", "_delay"];
	//player groupchat str [_cond,_condpars];
	if (_fnc isEqualType "") then {
		if (isNil _fnc) then {
			[
				_fnc + "_fnc", 
				{true}, 
				[], 
				{
					params ["_fnc", "_id"];

					if (!isNil _fnc) then {
						_index = babe_core_ehs find ((babe_core_ehs select {(_x select 0) isEqualTo _id}) select 0);
						(babe_core_ehs select _index) set [3, missionNameSpace getVariable _fnc];	
						[_fnc + "_fnc"] call babe_core_fnc_removeEH;			
					} else {
						systemchat ("isNil " + _fnc);
					};
				}, 
				[_fnc, _id], 
				false, 
				{}, 
				[], 
				0
			] call babe_core_fnc_addEH;
			_fnc = {};
		} else {
			_fnc = missionNameSpace getVariable _fnc;
		};
	};

	if (_switchfnc isEqualType "") then {
		if (isNil _switchfnc) then {
			[
				_switchfnc + "_fnc", 
				{true}, 
				[], 
				{
					params ["_fnc", "_id"];

					if (!isNil _fnc) then {
						_index = babe_core_ehs find ((babe_core_ehs select {(_x select 0) isEqualTo _id}) select 0);
						(babe_core_ehs select _index) set [3, missionNameSpace getVariable _fnc];	
						[_fnc + "_fnc"] call babe_core_fnc_removeEH;			
					} else {
						systemchat ("isNil " + _fnc);
					};
				}, 
				[_switchfnc, _id], 
				false, 
				{}, 
				[], 
				0
			] call babe_core_fnc_addEH;

			_switchfnc = {};
		} else {
			_switchfnc = missionNameSpace getVariable _switchfnc;
		};
	};

	if (count babe_core_EHs > 0) then {
		_replace = false;
		for "_i" from 0 to (count babe_core_EHs)-1 do {
			if ((babe_core_EHs select _i) select 0 == _id) then {
				_replace = true;
				babe_core_EHs set [_i, [_id, _cond, _condpars, _fnc, _pars, _switch, _switchfnc, _switchpars, _delay, diag_tickTime, false]];
			};
		};
		if !_replace then {
			babe_core_EHs pushback [_id, _cond, _condpars, _fnc, _pars, _switch, _switchfnc, _switchpars, _delay, diag_tickTime, false];
		};
	} else {
		babe_core_EHs pushback [_id, _cond, _condpars, _fnc, _pars, _switch, _switchfnc, _switchpars, _delay, diag_tickTime, false];
	};

};
