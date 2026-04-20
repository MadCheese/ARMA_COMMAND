
A3C_COVER_BLACKLIST =
[
];

A3C_AI_Squad_action_FindCoverExecute = {
	private
	[
		"_occupiedPositions","_houses","_positionCheck","_enemies","_altSelection","_realCoverPoses",
		"_checkedObjects","_checkedPositions","_dispersion"
	];
	
	private _units = _this select 0; //Array of units to find cover
	if (typeName _units == "STRING") then {_units = call compile _units};
	_units = _units select {isNull objectparent _x && {!isPlayer _x}};

	_mode = if (count _this > 1) then {_this select 1} else {0};
	if ((count _units) == 0 ) exitwith {};
	if (_mode == 0) then {
		_busyUnits = _units select {count (_x getVariable ["A3C_PLOT",[]]) > 0};
		if (count _busyUnits > 0) then {
			[_busyUnits,true,false] spawn A3C_AI_Shared_cancelUnitPlot;
			sleep 1;
		};	
		player groupRadio "SentCmdHide";
	};
	//if (true) exitWith {};
	private _unitClusters = []; //-- positions
	{
		_u = _x;
		private _createNew = true;
		{
			if ((getPosASL _u) distance2D (getPosASL (_x select 0)) < 20) exitWith {
				_createNew = false;
				_x set [count _x,_u];
			};
		} foreach _unitClusters;
		if (_createNew) then {
			_unitClusters set [count _unitClusters,[_u]];
		};
	} foreach _units;

	{
		_xc = 0;
		_yc = 0;
		{
			_aslPos = getPosASL _x;
			_xc = _xc + (_aslPos select 0);
			_yc = _yc + (_aslPos select 1);
		} foreach _x;
		if (_xc > 0) then {
			_xc = _xc / (count _x);
		};
		if (_yc > 0) then {
			_yc = _yc / (count _x);
		};
		_unitClusters set [_foreachIndex, [_x,[_xc,_yc,0]]];
	} foreach _unitClusters;
	//{
	//	systemchat str (_x select 1 );
	//} foreach _unitClusters;		
	
	_dispersion = 4;
	
	//player say "A3C_TakeCover";
	//sleep 1;
	_side = side (_units select 0);
	_enemies = [];
	_occupiedPositions = [];
	_realCoverPoses = [];
	_realCoverInside = [];
	_checkedObjects = [];
	_checkedPositions = [];
	_houses = [];
	_positionCheck = [];
	_altSelection = [];
	
	//-- Step 1: Find enemies to take cover from
	//~~ note: change this to units that are known to player side?	
	{
		_soldier = _x;
		if ((_side getfriend (side _soldier)) < 0.5) then {
			if (({((vehicle _soldier) distance _x) < 300} count _units) > 0 ) then {
				if !((vehicle _soldier) in _enemies) then {
					_enemies pushback (vehicle _soldier);
				};
			}; 
		};
	} foreach allunits; //~~ there must be a faster way??
	/*
	{
		_un = _x;
		if (({[_x,_un] call MCSS_fnc_LOS_SIMPLE} count _enemies) == 0) then {
			_units = _units - [_un];
			_un setUnitPos "middle";
			doStop _un;
		};
	} foreach _units;
	*/
	
	_isClassFnc = {
		params ["_obj"];
		
		//_isClass = isClass (configFile >> 'cfgVehicles' >> typeOf _obj);
		//systemchat str [_obj, _isClass];
		!isNull _obj//true //_isClass
	};
	
	

	private _checkedObjects = [];
	{
		_x params ["_unitsCluster","_center"];
		//systemchat str _center;
		//_coverObjects = [];
		private _radius = 50;
		_coverObjects = (nearestObjects [_center, [],_radius]) select {[_x] call _isClassFnc};
		_terrainRocks = (nearestTerrainObjects [_center, ["ROCK", "ROCKS","HIDE"], _radius]) select {[_x] call _isClassFnc};
		_terrainWalls = (nearestTerrainObjects [_center, ["WALL"], _radius]) select {[_x] call _isClassFnc};
		_terrainBushes = (nearestTerrainObjects [_center, ["BUSH"], _radius]) select {[_x] call _isClassFnc};
		_terrainTrees = (nearestTerrainObjects [_center, ["TREE", "SMALL TREE"], _radius]) select {[_x] call _isClassFnc};
		
		_coverObjects = _coverObjects select {
			_checkedObject = _x;
			!((typeOf _x) in A3C_COVER_BLACKLIST) &&
			{
				!(_x in (_terrainRocks + _terrainWalls + _terrainBushes + _terrainTrees)) &&
				{
					private _checkString = if (typeof _checkedObject == "") then {str _checkedObject} else {typeOf _checkedObject};
					_checkString = toLower _checkString;
					private _idStrings = ["noid ",": cl_","dummyweapon",": pavement_",": garbage_","line","sign","light","runway","fence","gate","indfnc","land_woodenwall_02","honeybee.p3d","fly.p3d","mosquito.p3d","bee.p3d"," b_ficusc2d_f.p3d"]; //--"lamp",
					private _typeStrings = []; 
					({_checkString find _x > -1} count _idStrings == 0) &&
					{
						({_checkedObject iskindof _x} count ["EmptyDetector"] == 0) && 
						{
							({_checkedObject iskindof _x && {alive _checkedObject}} count ["Animal","Animals","MAN"] == 0) &&
							{
								!(_checkedObject in (_center nearRoads 50)) &&
								{
									( ((boundingboxreal _checkedObject select 1) select 2) > 0.5)
								}
							}
						}
					}
				}
				
			}
		};
		_hardCover = _coverObjects select 
		{
			_armor = getnumber (configfile >> "Cfgvehicles" >> typeof _x >> "armor"); 
			_armor > 30
		};
		_coverObjects = _coverObjects + _terrainBushes - _hardCover;

		
		
		//_tt = [];
		//{
		//	_tt pushBack [_x, getnumber (configfile >> "Cfgvehicles" >> typeof _x >> "armor")];
		//} foreach _coverObjects;
		//copytoclipboard str _tt;
		//_softCover = _coverObjects - _hardCover;

		if (!isNil 'A_HELPERS') then {
			{deleteVehicle _x} foreach A_HELPERS;
		} else {
			A_HELPERS = [];
		};

		private _assignmentFull = [];
		private _positionsAssigned = [];
		private _positionsBlacklisted = [];
		
		if (count _coverObjects > 0) then {
			
			{
				_soldier = _x;
				
				//_softCover = _softCover - _assignmentFull;
				_hardCover = _hardCover - _assignmentFull;
				_terrainRocks = _terrainRocks - _assignmentFull;
				_terrainWalls = _terrainWalls - _assignmentFull;
				_terrainTrees = _terrainTrees - _assignmentFull;
				_coverObjects = _coverObjects - _assignmentFull;
				
				
				_hardCover = [_hardCover,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
				_terrainRocks = [_terrainRocks,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
				_terrainWalls = [_terrainWalls,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
				_terrainTrees = [_terrainTrees,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

				_closeRadius = 30;
				
				_closeHardCover = _hardCover select {_x distance2D _soldier <= _closeRadius};
				_closeHardCover = [_closeHardCover,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy; //-- necessary?

				_closeRocks = _terrainRocks select {_x distance2D _soldier <= _closeRadius};
				_closeRocks = [_closeRocks,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

				_closeWalls = _terrainWalls select {_x distance2D _soldier <= _closeRadius};
				_closeWalls = [_closeWalls,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

				_closeTrees = _terrainTrees select {_x distance2D _soldier <= _closeRadius};
				_closeTrees = [_closeTrees,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

				_closePreferred = _closeHardCover + _closeRocks;
				_closePreferred = [_closePreferred,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
				
				_coverObjectsRest = 
				(
					(_hardCover - _closeHardCover) +
					(_terrainRocks - _closeRocks) +
					(_terrainWalls - _closeWalls) +
					(_terrainTrees - _closeTrees) +
					_coverObjects
				);
				_coverObjectsRest = [_coverObjectsRest,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

				//-- to do: further sort close cover including size and other factors
				_coverObjectsFinal = 
				(
					_closePreferred +
					_closeWalls + 
					_closeTrees +
					_coverObjectsRest
				) select {
					//_size = sizeOf (typeOf _x);
					!isNull _x &&
					{
						private _size = _x call BIS_fnc_objectHeight;
						//systemchat str _size;
						_size > 1
					}
					
				};
				//systemchat str (_coverObjects select 0);
				private _unitCoverPos = [];
				//hint str _coverObjectsFinal;
				//{systemchat str [_x, _x call BIS_fnc_objectHeight]} foreach _coverObjectsFinal;
				//private _selectedCover = objNull;
				{
					//systemchat str _x;
					if (count _unitCoverPos > 0) exitWith {};
					
					_bldg = _x;

					_bBox2d = [];
					//-- check if object was checked before
					{
						if ((_x select 0) == _bldg) exitWith {_bBox2d = _x select 1};
					} foreach _checkedObjects;

					//-- if no bbox data exists, create it
					if (count _bBox2d == 0) then {
						_bBox2d = [_bldg,1] call MCSS_fnc_BBOX;
						_refPos2 = (getPosASL _bldg) vectorAdd [0,0,0.4];
						{
							_refPos1 = (ATLtoASL _x) vectorAdd [0,0,0.4];
							private _ins = lineIntersectsSurfaces
							[
								_refPos1,
								_refPos2,
								objNull,
								objNull,
								true,
								-1,
								"GEOM",
								"NONE"
							];
							_ins = _ins select {
								_object = _x select 2;
								_object == _bldg
							};
							if (count _ins > 0) then {
								private _insPos = ((_ins select 0) select 0) select [0,2];
								_bBox2d set [_foreachIndex, (_insPos) + [0]]
							};
						} foreach _bBox2d;
						_checkedObjects pushBack [_bldg,_bBox2d];
					};

					_bBox2d = _bBox2d - (_positionsAssigned + _positionsBlacklisted);
					_bBox2d = [_bBox2d,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;

					{
						_bBox2d set [_foreachIndex, _x getPos [1,_bldg getDir _x]];
					} foreach _bBox2d;
					
					if (count _bBox2d > 0) then {
						
						{
							_tPos =  [(_x select 0),(_x select 1), 1];	//-- add 1m to guarantee some kind of cover
							
							_cond = ( ({(_tPos distance _x) < _dispersion} count (_positionsAssigned )) == 0) && {
								//player commandChat str _x;
								//true
								//systemChat str _x;
								(({([_tPos,_x,_bldg] call MCSS_fnc_LOS_Cover)} count _enemies) == 0)
							};
							
							if (_cond) exitWith {  //+ _checkedPositions
								//_v = "Sign_Arrow_Large_Pink_F" createVehicle _tPos;
								//A_HELPERS pushBack _v;

								_unitCoverPos = _tPos;
								_positionsAssigned set [count _positionsAssigned,_unitCoverPos];
								[_soldier,_tPos] spawn {

									
									params ["_soldier","_unitCoverPos"];
									[_soldier,_unitCoverPos] call A3C_DOMOVE;
									sleep 1;
									waituntil {unitReady _soldier};
									//if (_soldier distance2D _unitCoverPos < 1.5) then {
										_soldier setUnitPos "MIDDLE";
									//};
								};
								
								
								
								
								/*
								//_ints = lineIntersectsObjs 
								//[
								//	ATLtoASL ((_tPos select [0,2]) + [(_tPos select 2) + 15]),
								//	ATLtoASL _tPos, 
								//	objnull, 
								//	objnull, 
								//	false
								//];
								//if (count _ints == 0) then {
									if (count _realCoverPoses > 0 ) then {
										{
											if (_bldg == _x select 0) exitWith {
												(_x select 1) pushBack _tPos;
											};
											if (_foreachIndex == ((count _realCoverposes) -1)) then {
											
												_realCoverposes pushBack [_bldg,[_tPos]];
											
											};
										} foreach _realCoverPoses;
									} else {
										_realCoverposes pushBack [_bldg,[_tPos]];
									};
								//} else {
									_realCoverInside pushBack _tPos;
								//};
								*/
							};
							//-- pos not suitable, add to blacklisted
							_positionsBlacklisted set [count _positionsBlacklisted,_tPos];
							
							//-- no cover pos was found - blacklist cover object
							if (_forEachIndex == ((count _bBox2d) -1) ) then {
								_assignmentFull set [count _assignmentFull, _bldg];
							};
						} foreach _bBox2d;
					} else {
						//-- no available positions - add to blacklist
						_assignmentFull set [count _assignmentFull, _bldg];
					};
				} foreach _coverObjectsFinal;
				if (count _unitCoverPos > 0) then {

					//player setpos _unitCoverPos;
				} else {
					//-- no cover
					_soldier setUnitPos "DOWN";
					[_soldier,position _soldier] call A3C_DOMOVE;
				};
			} foreach _unitsCluster;
		};
		//_checkedObjects = _checkedObjects + _coverObjects;
	} foreach _unitClusters;

	

	
	if (true) exitWith {};
	systemchat str 'zz1-2';

	//-- Step 2: Find Cover objects close to selected units and their real cover poses and saves those to new array
	//-- _realCoverPoses is an array with subarrays of [object,[cpos1,cpos2,...]] 
	{
		_center = _x select 1;
		_positioncheck = [];
		_coverObjects = [];
		_coverObjectsHard = [];
		_nearObjects = [];
		

		
		
		//for "_i" from 1 to 30 step 5 do {
			_nearObjects = nearestObjects [_center, [],30];
			//-- nearestTerrainObjects etc should be included in nearestObjects
			//-- filter nearestobjects
			{
				_checkedObject = _x;
				if !(_x in _checkedObjects) then {
					if !((typeOf _x) in A3C_COVER_BLACKLIST) then {
						_checkedObjects pushback _x;
						private _checkString = if (typeof _checkedObject == "") then {str _checkedObject} else {typeOf _checkedObject};
						_checkString = toLower _checkString;
						private _idStrings = ["noid ",": cl_",": pavement_",": garbage_","sign","light","runway","fence","gate","indfnc","land_woodenwall_02","honeybee.p3d","fly.p3d","mosquito.p3d","bee.p3d"," b_ficusc2d_f.p3d"]; //--"lamp",
						private _typeStrings = []; 
						if ({_checkedObject iskindof _x && {alive _checkedObject}} count ["Animal","Animals","MAN"] == 0) then {
							if ({_checkedObject iskindof _x} count ["EmptyDetector"] == 0) then {
								if ({_checkString find _x > -1} count _idStrings == 0) then {
									//if ({_checkString find _x > -1} count _idStrings == 0) then {
										if !(_checkedObject in (_center nearRoads 50))  then {
											if ( ((boundingboxreal _checkedObject select 1) select 2) > 0.5) then {
												_coverObjects pushbackUnique _checkedObject;
												//diag_log [_checkedObject,_checkString];											
											};
										};
									//};
								};
							};
						};
					};
				};
										
			} foreach _nearObjects;

			//_nearTerrain = nearestTerrainObjects [_soldier, ["Tree","Bush","ROCK","ROCKS"], 30];
			//{
			//	if !(_x in _checkedObjects) then {
			//		_nearObjects pushbackUnique _x;
			//	};
			//} foreach _nearTerrain;
			
			
			//-- sort the array according to priorities
			//_coverObjects = [_coverObjects,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
			//_coverObjectsHard = [_coverObjectsHard,[],{_soldier distance _x},"ASCEND"] call BIS_fnc_sortBy;
		//};
		_nearObjects = [];
		//systemchat str _coverObjects;
		//systemchat "2";
		{
			private ["_bldg"];
			_bldg = _x;
			/*
			_bPosCount = ([_x] call MCSS_fnc_countBPos);
			if (_bPosCount > -1 ) then {	
				for "_i" from 0 to _bPosCount do {
					if ( ({((_bldg buildingpos _i) distance _x) < 1} count _occupiedPositions) == 0) then {
						// _check position for visibility
						_bpos = (_bldg buildingpos _i);
						if (({[[(_bpos select 0),(_bPos select 1),((_bPos select 2) + 1.2)],_x] call MCSS_fnc_LOS_SIMPLE} count _enemies) == 0) then {
							_positionCheck = (_bldg buildingpos _i);
							_occupiedPositions pushback _positionCheck;
							_soldier moveTo (_bldg buildingpos _i);
							_soldier domove (_bldg buildingpos _i);
							_soldier dowatch objnull;
							_soldier lookat objnull;
							
						};
					};					
					if ((count _positionCheck) > 0) exitwith {};
					
				};
				if ((count _positionCheck) > 0) exitwith {};
			};
			if ((count _positionCheck) > 0) exitwith {};
			*/
			
			_bBox2d = [_x,1] call MCSS_fnc_BBOX;
			{
				_tPos =  [(_x select 0),(_x select 1), 1];
				
				if ( ({(_tPos distance _x) < _dispersion} count (_occupiedPositions )) == 0) then {  //+ _checkedPositions
					_checkedPositions pushBack _tPos;
					if (({[_tPos,_x,_bldg] call MCSS_fnc_LOS_Cover} count _enemies) == 0) then {
						
						_ints = lineIntersectsObjs 
						[
							ATLtoASL ((_tPos select [0,2]) + [(_tPos select 2) + 15]),
							ATLtoASL _tPos, 
							objnull, 
							objnull, 
							false
						];
						if (count _ints == 0) then {
							//player allowdamage false; player setpos _tpos; sleep 1; 
							if (count _realCoverPoses > 0 ) then {
								{
								
									//player sidechat str _x;
									if (_bldg == _x select 0) exitWith {
										(_x select 1) pushBack _tPos;
									};
									if (_foreachIndex == ((count _realCoverposes) -1)) then {
									
										_realCoverposes pushBack [_bldg,[_tPos]];
									
									};
								} foreach _realCoverPoses;
							} else {
								_realCoverposes pushBack [_bldg,[_tPos]];
							};
						} else {
							_realCoverInside pushBack _tPos;
						};
						
						
					};
				};
				//if ((count _positionCheck) > 0) exitwith {};
			} foreach _bBox2d;
			//if ((count _positionCheck) > 0) exitwith {};
		} foreach _coverobjects;
		//sleep 0.01;		
	} forEach _unitClusters;
	systemchat str 'zz2';	
	//-- send units to cover
	//copyToClipboard str _realCoverPoses;
	_allCoverPoses = [];
	{
		
		_soldier = _x;
		_softC = [];
		_hardC = [];
		_mPos = position _soldier;
		_mPoses = [];
		if ((vehicle _soldier) == _soldier) then {	
			for "_i" from 5 to 50 step 5 do {
				{
					_obj = _x select 0;
					_poses = _x select 1;
					_armor = getnumber (configfile >> "Cfgvehicles" >> typeof _obj >> "armor");
					//systemchat str [_armor, _obj];
					if ({_soldier distance2D _x <=50} count _poses > 0) then {
						//if (_armor > 0) then { //-->> this removes too many objects from selection
							if (_armor >= 100) then {
								_hardC pushBack _x;
							} else {
								//systemchat str _armor;
								if (_i > 30) then {
									_softC pushBack _x;
								};
							};
						//};
					};
				} foreach _realCoverPoses;
				if ((count (_softC + _hardC)) > 0) exitwith {};			
			};
			//diag_log [_softC , _hardC];
			//diag_log (_softC select ((count _softC) - 1));
			//systemchat str  (count _softC);
			//diag_log _hardC;
			//-- no cover. lay down
			if ((count (_softC + _hardC)) == 0) exitwith {
				_soldier setUnitPos "DOWN";
			};
			//systemchat str _hardC select 0;
			_coverFound = false;
			//systemchat str _occupiedPositions;
			_softC = [_softC,[],{_soldier distance2D (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
			_hardC = [_hardC,[],{_soldier distance2D (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
			if (count _hardC > 0) then {
				{
					private _ob = _x select 0;
					private _cp = _x select 1;
					{	
						private _p = _x;
						if ( ({(_p distance _x) < _dispersion} count _occupiedPositions) == 0) then {
							_mPoses pushback [_p,_ob];
							_coverFound = true;
							_allCoverPoses pushBackUnique _p;
						};
						//if (_coverFound) exitWith {};
					} foreach _cp;
					if (_coverFound) exitWith {};
				} foreach _hardC;
			};
			if !(_coverFound) then {
				{
					private _ob = _x select 0;
					private _cp = _x select 1;
					{
						private _p = _x;
						if ( ({(_p distance _x) < _dispersion} count _occupiedPositions) == 0) then {
							_mPoses pushback [_p,_ob];
							_coverFound = true;
							_allCoverPoses pushBackUnique _p;
							//systemchat str _ob;
						};
						if (_coverFound) exitWith {};
					} foreach _cp;
					if (_coverFound) exitWith {};
				} foreach _softC;
			};
			//hint str _mPoses;
			if (count _mPoses > 0) then {
				_mPoses = [_mPoses,[],{(_x select 0) distance _soldier},"ASCEND"] call BIS_fnc_sortBy;
				_mPosSel = (_mPoses select 0); //-- select array			
				_mPos = _mPosSel select 0; //-- select position
				_mOb = _mPosSel select 1;
				_dir = [_mOb, _mPos] call BIS_fnc_dirTo;
				_mPos = [_mPos,1,_dir] call BIS_fnc_RelPos;
				//_occupiedPositions pushback _mPos;
			};
			_soldier setUnitPos "UP";
			[_soldier,_mPos] spawn {
				params ["_soldier","_mPos"];
				sleep ((_soldier distance _mPos) / 3);
				_soldier setUnitPos "middle";
			};
			//systemchat str (_mPos distance2d _soldier);
			//player setpos _mpos;
			_occupiedPositions pushbackUnique _mPos;
			
			
			_soldier dowatch objnull;
			_soldier lookat objnull;
		//	_soldier forceSpeed -1;
			sleep 0.5;	
			[_soldier,_mPos] call A3C_DOMOVE;
			//_soldier moveTo _mPos;
			//_soldier domove _mPos;
			
			//if ( ((boundingboxreal _bldg select 1) select 2) < 1) then {
			//	_soldier setunitPos "middle";
			//};
		//} else {
		//	_positionCheck = [1,1,1];
		};
		//sleep 2;
		
	} foreach _units;
	systemchat str 'zz3';
	if (A3C_Debug) then {
		//sleep 5;
		_objects = [];
		{
			//
			_ob = 'Sign_Arrow_Blue_F' createVehicleLocal _x;
			_objects pushBack _ob;
		} foreach _allCoverPoses;
		sleep 5;
		{deleteVehicle _x;} foreach _objects;
	};			
	//systemchat str _realCoverPoses;
};

