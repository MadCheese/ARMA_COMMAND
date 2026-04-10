A3C_CLEARBUILDING = {	
	// IMPROVE: distribute all wp's from the beginning, so the whole thing gets executed smoothly and shows well on map/tablet
	private ["_units","_building","_unit","_bpA","_func","_firstWP","_stackPos"];
	
	//-- sub-function no longer needed
	_func = {
		private ["_u","_bldg","_bPos","_pos","_scr"];
		_u = _this select 0;
		_bldg = _this select 1;
		_bPos = _this select 2;
		_pos = _bldg buildingPos _bPos;
		_data = [[_pos,([_pos,50,([(position _bldg),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"UP","AUTO",-1,0,[0,""],0,"NONE","NONE",-1]];
		_u setvariable ["A3C_PLOT",_data,true];
		_scr = ([_u,(_u getvariable "A3C_PLOT")] spawn A3C_MOVE);
		//waituntil {scriptDone _scr};
	};
	
	_units = _this select 0;
	_building = _this select 1;
	_bbox = [_building] call MCSS_fnc_BBOX;
	_doorpos = (_building modelToWorld (_building  selectionPosition "Door_1_trigger"));
	_bpC = ([_building] call MCSS_fnc_countBPos);
	_bpA = [];

	_units = [_units,[],{_x distance _doorPos},"ASCEND"] call BIS_fnc_sortBy;	
	{
		if !(isnull objectParent _x) then {_units = _units - [_x]};
	} foreach _units;
	if ((count _units) == 0) exitwith {};
	_firstWP = (_building buildingpos 0);
	_houseData = [_building] call A3C_HouseData;	
	{
		{
			_bpA pushback _x;
			if ( ((_building buildingpos _x) distance _doorPos) < (_firstWp distance _doorPos)) then {
				if (((_building buildingpos _x) select 2) < 1.8) then {
					_firstWp = (_building buildingpos _x);
				};
			};
		} foreach _x;
	} foreach _houseData;
	systemchat str _bpa;
	
	_unit = objnull;
	{
		_x setVariable ["A3C_DEST",(expectedDestination _x),true];
		// -- NOTE: MAKE A DAMN CREATE_MARKER FUNCTION TO SAVE ALL THE MESS EVERYWHERE
		call compile format 
			[
				"
					ASMark_P%1 = createmarkerLocal ['A3C_Mark_P%1', %2];
					'A3C_Mark_P%1' setMarkershapeLocal 'ICON';
					A3C_TEMP_WP_ID_MAIN = 'A3C_Mark_P%1';
					A3C_MARKERS pushback A3C_TEMP_WP_ID_MAIN;
					A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
				",
				A3C_MARKER_COUNT,
				_firstwp
			];
		_data = 
			[
				
				[
					_firstWP,
					([_firstWP,50,([(position _building),_firstWP] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),
					A3C_TEMP_WP_ID_MAIN,
					"",
					"",
					0,
					[[0,false]],
					false,
					"MIDDLE",
					"AUTO",
					-1,
					0,
					[0,""],
					0,
					"NONE",
					"NONE",
					-1
				]
			];
		_x setVariable ["A3C_PLOT_TEMP",_data,true];
		//_stackPos = [_stackPos,3,((getDir _building) + _stackDir)] call BIS_fnc_RelPos;
	} foreach _units;
	while {count _bpA > 0} do {
		{
			//if (_forEachIndex > (count _bpA)) exitwith {};
			if (count _bpA == 0) exitwith {};
			
			_pos = _building buildingpos (_bpA select 0);
			//[A3C_CLICKPOS_1,A3C_CLICKPOS_2,"","","",A3C_TIMEOUT, [[0,false]],false,A3C_STANCE1_TEMP,A3C_STANCE2_TEMP,A3C_WP_SPEED_TEMP,A3C_CMODE_TEMP,[A3C_wpFireMode_TEMP,A3C_GREN_MUZZLE],A3C_HELIHEIGHT,A3C_HELI_HELI_WP_BEHAVIOUR,"NONE",-1]
			call compile format 
			[
				"
					ASMark_P%1 = createmarkerLocal ['A3C_Mark_P%1', %2];
					'A3C_Mark_P%1' setMarkershapeLocal 'ICON';
					A3C_TEMP_WP_ID_MAIN = 'A3C_Mark_P%1';
					A3C_MARKERS pushback A3C_TEMP_WP_ID_MAIN;
					A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
				",
				A3C_MARKER_COUNT,
				_pos
			];
			
			
			_data = 
			[
				_pos,
				([_pos,50,([(position _building),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),
				A3C_TEMP_WP_ID_MAIN,
				"",
				"",
				0,
				[[0,false]],
				false,
				"MIDDLE",
				"AUTO",
				-1,
				0,
				[0,""],
				0,
				"NONE",
				"NONE",
				-1
			];			
			_v = (_x getVariable "A3C_PLOT_TEMP");
			_v pushBack _data;
			_x setVariable ["A3C_PLOT_TEMP",_v,true];
			_bpA = _bpA - [(_bpA select 0)];
		} foreach _units;
	};
	{dostop _x} foreach _units;
	//sleep 1;
	for "_i" from 0 to _bpc do {
		if (_i > ((count _units) - 1)) exitwith {};
		_unit = (_units select _i);
		waituntil {(count (_unit getvariable "A3C_PLOT")) == 0};
		_unit setvariable ["A3C_PLOT",(_unit getVariable "A3C_PLOT_TEMP"),true];
		_unit setvariable ["A3C_PLOT_TEMP",[],true];
		_scr = ([_unit,(_unit getvariable "A3C_PLOT")] spawn A3C_MOVE);
		sleep 0.1;	
	};
	while {{alive _x} count _units > 0} do {
		sleep 0.2;
		if (({(count (_x getVariable "A3C_PLOT")) > 0} count _units) == 0) exitwith {
			if (({(_x distance (_building buildingpos _bpc)) < 1} count _units) > 0) then {
				{
					if (alive _x) exitwith {_x groupchat "Building Clear"}
				} foreach _units;
			};
		};
		{
			if (_foreachindex > 0) then {
				if ((_x distance (_units select (_foreachIndex -1))) < 2) then {
					_x forcespeed 0;
					sleep 1;
					_x forcespeed -1;
					sleep 1;
				} else {
					_x forcespeed -1;
				};
			};
			if !(alive _x) then {_units = _units - [_x]};
		} foreach _units;
		
	};
	{_x forcespeed -1} foreach _units;
	{
		_expD = _x getvariable "A3C_DEST";
		if (count _expD > 0) then {
			if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				_x doFollow player;
				_x setUnitPos "AUTO";
				_x lookAt objNull;
			} else {
				//_x lookAt objnull;
				//_x domove (_expD select 0);
				//_x moveTo (_expD select 0);
			};
			_x setVariable ["A3C_DEST",[],true];
		};		
	} foreach _units;	

};


A3C_CLEARBUILDING = {	
	// IMPROVE: distribute all wp's from the beginning, so the whole thing gets executed smoothly and shows well on map/tablet
	private ["_units","_building","_unit","_bpA","_func","_firstWP","_stackPos"];
	
	//-- sub-function no longer needed
	_func = {
		private ["_u","_bldg","_bPos","_pos","_scr"];
		_u = _this select 0;
		_bldg = _this select 1;
		_bPos = _this select 2;
		_pos = _bldg buildingPos _bPos;
		_data = [[_pos,([_pos,50,([(position _bldg),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"UP","AUTO",-1,0,[0,""],0,"NONE","NONE",-1]];
		_u setvariable ["A3C_PLOT",_data,true];
		_scr = ([_u,(_u getvariable "A3C_PLOT")] spawn A3C_MOVE);
		//waituntil {scriptDone _scr};
	};
	
	_units = _this select 0;
	_building = _this select 1;
	_bbox = [_building] call MCSS_fnc_BBOX;
	_doorpos = (_building modelToWorld (_building  selectionPosition "Door_1_trigger"));
	//_stackPos = ([_bbox,[],{_x distance _doorpos},"ASCEND"] call BIS_fnc_sortBy) select 0;
	//_stackPos = [_stackPos,2,([_building,_stackPos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos;
	_stackPos = _doorPos;
	
	_bpC = ([_building] call MCSS_fnc_countBPos);
	_bpA = [];
	//_dirToDoor = [_building,_doorPos] call BIS_fnc_dirTo;
	//_dirToDoor = [_building,_doorPos] call BIS_fnc_Relativedirto; 
	_stackDir = 270;
	/*
	//-- test below vs switch command
	if (_dirToDoor > 45) then {
		if (_dirToDoor > 90) then {
			if (_dirToDoor > 135) then {
				if (_dirToDoor > 180) then {
					if (_dirToDoor > 225) then {
						if (_dirToDoor > 270) then {
							if (_dirToDoor > 315) then {
								// front wall left
								_stackDir = 90;
							} else {
								// left wall top
							};
						} else {
							// left wall bottom
							_stackDir = 0;
						};
					} else {
						// back wall left
						_stackDir = 90;
					};
				} else {
					// back wall right
					_stackDir = 270;
				};
			} else {
				//-- right wall bottom
				_stackDir = 0;
			};
		} else {
			// right wall top
			_stackDir = 180;
		};
	};
	*/
	_units = [_units,[],{_x distance _stackPos},"ASCEND"] call BIS_fnc_sortBy;	
	{
		if !(isnull objectParent _x) then {_units = _units - [_x]};
	} foreach _units;
	if ((count _units) == 0) exitwith {};
	_firstWP = (_building buildingpos 0);
	_houseData = [_building] call A3C_HouseData;	
	{
		{
			_bpA pushback _x;
			if ( ((_building buildingpos _x) distance _doorPos) < (_firstWp distance _doorPos)) then {
				if (((_building buildingpos _x) select 2) < 1.8) then {
					_firstWp = (_building buildingpos _x);
				};
			};
		} foreach _x;
	} foreach _houseData;
	systemchat str _bpa;
	/*for "_i" from 0 to _bpc do {
		_bp = _building buildingpos _i;
		if (_bp select 2 > 1.8) then {
			_bpA pushback _i;			
		} else {
			_bp set [2,((_bp select 2) + 0.4)];
			if ([_bp, _building] call A3C_fnc_INSIDE) then {
				_bpA pushback _i;
				//systemchat str _i;
			};
		};
		if ( ((_building buildingpos _i) distance _doorPos) < (_firstWp distance _doorPos)) then {
			if (((_building buildingpos _i) select 2) < 1.8) then {
				_firstWp = (_building buildingpos _i);
			};
		};
	};
	*/
	//player setpos _firstWP;
	
	/*
	[
					_stackPos,
					(position _building),
					"",
					"",
					"",
					0,
					[[0,false]],
					true,
					"UP",
					"AUTO",
					-1,
					0,
					[0,""],
					0,
					"NONE",
					"NONE",
					-1
				],
	*/
	_unit = objnull;
	{
		_x setVariable ["A3C_DEST",(expectedDestination _x),true];
		call compile format 
			[
				"
					ASMark_P%1 = createmarkerLocal ['A3C_Mark_P%1', %2];
					'A3C_Mark_P%1' setMarkershapeLocal 'ICON';
					A3C_TEMP_WP_ID_MAIN = 'A3C_Mark_P%1';
					A3C_MARKERS pushback A3C_TEMP_WP_ID_MAIN;
					A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
				",
				A3C_MARKER_COUNT,
				_firstwp
			];
		_data = 
			[
				
				[
					_firstWP,
					([_firstWP,50,([(position _building),_firstWP] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),
					A3C_TEMP_WP_ID_MAIN,
					"",
					"",
					0,
					[[0,false]],
					false,
					"MIDDLE",
					"AUTO",
					-1,
					0,
					[0,""],
					0,
					"NONE",
					"NONE",
					-1
				]
			];
		_x setVariable ["A3C_PLOT_TEMP",_data,true];
		_stackPos = [_stackPos,3,((getDir _building) + _stackDir)] call BIS_fnc_RelPos;
	} foreach _units;
	while {count _bpA > 0} do {
		{
			//if (_forEachIndex > (count _bpA)) exitwith {};
			if (count _bpA == 0) exitwith {};
			
			_pos = _building buildingpos (_bpA select 0);
			//[A3C_CLICKPOS_1,A3C_CLICKPOS_2,"","","",A3C_TIMEOUT, [[0,false]],false,A3C_STANCE1_TEMP,A3C_STANCE2_TEMP,A3C_WP_SPEED_TEMP,A3C_CMODE_TEMP,[A3C_wpFireMode_TEMP,A3C_GREN_MUZZLE],A3C_HELIHEIGHT,A3C_HELI_HELI_WP_BEHAVIOUR,"NONE",-1]
			call compile format 
			[
				"
					ASMark_P%1 = createmarkerLocal ['A3C_Mark_P%1', %2];
					'A3C_Mark_P%1' setMarkershapeLocal 'ICON';
					A3C_TEMP_WP_ID_MAIN = 'A3C_Mark_P%1';
					A3C_MARKERS pushback A3C_TEMP_WP_ID_MAIN;
					A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
				",
				A3C_MARKER_COUNT,
				_pos
			];
			
			
			_data = 
			[
				_pos,
				([_pos,50,([(position _building),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),
				A3C_TEMP_WP_ID_MAIN,
				"",
				"",
				0,
				[[0,false]],
				false,
				"MIDDLE",
				"AUTO",
				-1,
				0,
				[0,""],
				0,
				"NONE",
				"NONE",
				-1
			];			
			_v = (_x getVariable "A3C_PLOT_TEMP");
			_v pushBack _data;
			_x setVariable ["A3C_PLOT_TEMP",_v,true];
			_bpA = _bpA - [(_bpA select 0)];
		} foreach _units;
	};
	{dostop _x} foreach _units;
	//sleep 1;
	for "_i" from 0 to _bpc do {
		if (_i > ((count _units) - 1)) exitwith {};
		_unit = (_units select _i);
		waituntil {(count (_unit getvariable "A3C_PLOT")) == 0};
		_unit setvariable ["A3C_PLOT",(_unit getVariable "A3C_PLOT_TEMP"),true];
		_unit setvariable ["A3C_PLOT_TEMP",[],true];
		_scr = ([_unit,(_unit getvariable "A3C_PLOT")] spawn A3C_MOVE);
		sleep 0.1;	
	};
	while {{alive _x} count _units > 0} do {
		sleep 0.2;
		if (({(count (_x getVariable "A3C_PLOT")) > 0} count _units) == 0) exitwith {
			if (({(_x distance (_building buildingpos _bpc)) < 1} count _units) > 0) then {
				{
					if (alive _x) exitwith {_x groupchat "Building Clear"}
				} foreach _units;
			};
		};
		{
			if (_foreachindex > 0) then {
				if ((_x distance (_units select (_foreachIndex -1))) < 2) then {
					_x forcespeed 0;
					sleep 1;
					_x forcespeed -1;
				} else {
					_x forcespeed -1;
				};
			};
			if !(alive _x) then {_units = _units - [_x]};
		} foreach _units;
		
	};
	{_x forcespeed -1} foreach _units;
	{
		_expD = _x getvariable "A3C_DEST";
		if (count _expD > 0) then {
			if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				_x doFollow player;
			} else {
				//_x lookAt objnull;
				//_x domove (_expD select 0);
				//_x moveTo (_expD select 0);
			};
			_x setVariable ["A3C_DEST",[],true];
		};		
	} foreach _units;	

};


A3C_CLEARBUILDING_1 = {	
	// IMPROVE: distribute all wp's from the beginning, so the whole thing gets executed smoothly and shows well on map/tablet
	private ["_units","_building","_unit","_bpA","_func","_firstWP"];
	_func = {
		private ["_u","_bldg","_bPos","_pos","_scr"];
		_u = _this select 0;
		_bldg = _this select 1;
		_bPos = _this select 2;
		_pos = _bPos;
		_data = [[_pos,([_pos,50,([(position _bldg),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"UP","AUTO",-1,0,[0,""],0,"NONE","NONE",-1]];
		_u setvariable ["A3C_PLOT",_data,true];
		_scr = ([_u,(_u getvariable "A3C_PLOT")] spawn A3C_MOVE);
		//waituntil {scriptDone _scr};
	};
	
	_units = _this select 0;
	_building = _this select 1;
	
	_units = [_units,[],{_x distance _building},"ASCEND"] call BIS_fnc_sortBy;
	_bpC = ([_building] call MCSS_fnc_countBPos);
	_bpA = [];
	_doorpos = (_building modelToWorld (_building  selectionPosition "Door_1_trigger"));
	
	{
		if !(isnull objectParent _x) then {_units = _units - [_x]};
	} foreach _units;
	if ((count _units) == 0) exitwith {};
	_firstWP = (_building buildingpos 0);
	for "_i" from 0 to _bpc do {
		_bp = _building buildingpos _i;
		
		if (_bp select 2 > 1.8) then {
			_bpA pushback _bP;			
		} else {
			_bp set [2,((_bp select 2) + 0.4)];
			if ([_bp, _building] call A3C_fnc_INSIDE) then {
				_bpA pushback _bp;
				//systemchat str _i;
			};
		};
		if ( ((_building buildingpos _i) distance _doorPos) < (_firstWp distance _doorPos)) then {
			if (((_building buildingpos _i) select 2) < 1.8) then {
				_firstWp = (_building buildingpos _i);
			};
		};
	};
	_unit = objnull;
	{
		_x setVariable ["A3C_DEST",(expectedDestination _x),true];
		_data = 
			[
				
				[
					_firstWP,
					([_firstWP,50,([(position _building),_firstWP] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),
					"",
					"",
					"",
					0,
					[[0,false]],
					true,
					"MIDDLE",
					"AUTO",
					-1,
					0,
					[0,""],
					0,
					"NONE",
					"NONE",
					-1
				]
			];
		_x setVariable ["A3C_PLOT_TEMP",_data,true];
		//_stackPos = [_stackPos,3,((getDir _building) + _stackDir)] call BIS_fnc_RelPos;
	} foreach _units;
	_bpa1 = _bpa;
	while {count _bpA > 0} do {
		{
			//if (_forEachIndex > (count _bpA)) exitwith {};
			if (count _bpA == 0) exitwith {};
			_pos = (_bpA select 0);
			_data = [_pos,([_pos,50,([(position _building),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"MIDDLE","AUTO",-1,0,[0,""],0,"NONE","NONE",-1];
			_v = (_x getVariable "A3C_PLOT_TEMP");
			_v pushBack _data;
			_x setVariable ["A3C_PLOT_TEMP",_v,true];
			_bpA = _bpA - [(_bpA select 0)];
		} foreach _units;
	};
	{dostop _x} foreach _units;
	sleep 1;
	for "_i" from 0 to _bpc do {
		if (_i > ((count _units) - 1)) exitwith {};
		_unit = (_units select _i);
		waituntil {(count (_unit getvariable "A3C_PLOT")) == 0};
		//systemchat str (_unit getvariable "A3C_PLOT_TEMP");
		_unit setvariable ["A3C_PLOT",(_unit getVariable "A3C_PLOT_TEMP"),true];
		_unit setvariable ["A3C_PLOT_TEMP",[],true];
		_scr = ([_unit,(_unit getvariable "A3C_PLOT")] spawn A3C_MOVE);
		sleep 1;	
	};
	while {{alive _x} count _units > 0} do {
		sleep 0.5;
		
		if (({(count (_x getVariable "A3C_PLOT")) > 0} count _units) == 0) exitwith {
			if (({(_x distance (_building buildingpos _bpc)) < 1} count _units) > 0) then {
				{
					if (alive _x) exitwith {_x groupchat "Building Clear"}
				} foreach _units;
			};
		};
		{
			if (_foreachindex > 0) then {
				if ((_x distance (_units select (_foreachIndex -1))) <3) then {
					_x forcespeed 0;
					systemchat "hey";
				} else {
					_x forcespeed 800;
				};
			};
			_data = _x getvariable "A3C_PLOT";
			{
				if (_x select 7) then {
					//_bpa1 = _bpa1 - [(_x select 0)];
				};
			} foreach _data;
			if (!alive _x) then {_units = _units - [_x]};
		} foreach _units;
		hintsilent str _bpa1;
		
	};
	{_x forcespeed -1} foreach _units;
	{
		_expD = _x getvariable "A3C_DEST";
		if (count _expD > 0) then {
			if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				_x doFollow player;
			} else {
				//_x lookAt objnull;
				//_x domove (_expD select 0);
				//_x moveTo (_expD select 0);
			};
			_x setVariable ["A3C_DEST",[],true];
		};		
	} foreach _units;	

};

A3C_CLEARBUILDING_1 = {	
	// IMPROVE: distribute all wp's from the beginning, so the whole thing gets executed smoothly and shows well on map/tablet
	private ["_units","_building","_unit","_bpA","_func","_firstWP"];
	_func = {
		private ["_u","_bldg","_bPos","_pos","_scr"];
		_u = _this select 0;
		_bldg = _this select 1;
		_bPos = _this select 2;
		_pos = _bPos;
		_data = [[_pos,([_pos,50,([(position _bldg),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"UP","AUTO",-1,0,[0,""],0,"NONE","NONE",-1]];
		_u setvariable ["A3C_PLOT",_data,true];
		_scr = ([_u,(_u getvariable "A3C_PLOT")] spawn A3C_MOVE);
		//waituntil {scriptDone _scr};
	};
	
	_units = _this select 0;
	_building = _this select 1;
	
	_units = [_units,[],{_x distance _building},"ASCEND"] call BIS_fnc_sortBy;
	_bpC = ([_building] call MCSS_fnc_countBPos);
	_bpA = [];
	_doorpos = (_building modelToWorld (_building  selectionPosition "Door_1_trigger"));
	
	{
		if !(isnull objectParent _x) then {_units = _units - [_x]};
	} foreach _units;
	if ((count _units) == 0) exitwith {};
	_firstWP = (_building buildingpos 0);
	for "_i" from 0 to _bpc do {
		_bp = _building buildingpos _i;
		
		if (_bp select 2 > 1.8) then {
			_bpA pushback _bP;			
		} else {
			_bp set [2,((_bp select 2) + 0.4)];
			if ([_bp, _building] call A3C_fnc_INSIDE) then {
				_bpA pushback _bp;
				//systemchat str _i;
			};
		};
		if ( ((_building buildingpos _i) distance _doorPos) < (_firstWp distance _doorPos)) then {
			if (((_building buildingpos _i) select 2) < 1.8) then {
				_firstWp = (_building buildingpos _i);
			};
		};
	};
	_unit = objnull;
	{
		_x setVariable ["A3C_DEST",(expectedDestination _x),true];
		//_x setVariable ["A3C_PLOT_TEMP",[],true];
	} foreach _units;

	while {count _bpA > 0} do {
		{
			//if (_forEachIndex > (count _bpA)) exitwith {};
			if (count _bpA == 0) exitwith {};
			_pos = (_bpA select 0);
			_data = [_pos,([_pos,50,([(position _building),_pos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos),"","","",0,[[0,false]],true,"MIDDLE","AUTO",-1,0,[0,""],0,"NONE","NONE",-1];
			_v = (_x getVariable "A3C_PLOT_TEMP");
			_v pushBack _data;
			_x setVariable ["A3C_PLOT_TEMP",_v,true];
			_bpA = _bpA - [(_bpA select 0)];
		} foreach _units;
	};
	{dostop _x} foreach _units;
	sleep 1;
	for "_i" from 0 to _bpc do {
		if (_i > ((count _units) - 1)) exitwith {};
		_unit = (_units select _i);
		waituntil {(count (_unit getvariable "A3C_PLOT")) == 0};
		_unit setvariable ["A3C_PLOT",(_unit getVariable "A3C_PLOT_TEMP"),true];
		_unit setvariable ["A3C_PLOT_TEMP",[],true];
		_scr = ([_unit,(_unit getvariable "A3C_PLOT")] spawn A3C_MOVE);
		//sleep 2;	
	};
	while {{alive _x} count _units > 0} do {
		sleep 0.5;
		if (({(count (_x getVariable "A3C_PLOT")) > 0} count _units) == 0) exitwith {
			if (({(_x distance (_building buildingpos _bpc)) < 1} count _units) > 0) then {
				{
					if (alive _x) exitwith {_x groupchat "Building Clear"}
				} foreach _units;
			};
		};
		{
			if (_foreachindex > 0) then {
				if ((_x distance (_units select (_foreachIndex -1))) <3) then {
					_x forcespeed 0;
				} else {
					_x forcespeed -1;
				};
			};
		} foreach _units;
		
	};
	{_x forcespeed -1} foreach _units;
	{
		_expD = _x getvariable "A3C_DEST";
		if (count _expD > 0) then {
			if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
				_x doFollow player;
			} else {
				//_x lookAt objnull;
				//_x domove (_expD select 0);
				//_x moveTo (_expD select 0);
			};
			_x setVariable ["A3C_DEST",[],true];
		};		
	} foreach _units;	

};