
//---------------------------------------  S U P R E S S I O N  F U N C T I O N S  ------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------

A3C_SUP_BOOL_MD = false;

A3C_SUP_DRAW_TOGGLE = false;
A3C_DRAW_ORDER_RELEASE = true;

A3C_SUP_CLICKPOS = [];
A3C_SUP_MOUSEPOS = [];
A3C_SUP_PosArray = [];


A3C_SUP_MAIN_POLY = []; //~~ is this still needed?

A3C_ALL_POLYS = [];

A3C_SUPPRESSION_UNITS_SQ = []; //-- array for suppressing player controlled units. LOCAL TO CLIENT, CHANGES NOT BROADCASTED
if (isServer) then {
	A3C_SUPPRESSION_UNITS_AI = []; //-- array for suppressing AI controlled units. CHANGES ARE BROADCASTED
	publicVariable 'A3C_SUPPRESSION_UNITS_AI';
};
A3C_SUPPRESSION_UNITS_SQ_TEMP = [];



A3C_SUP_POLYMARKS = [];
A3C_POLYEDGE_MARKERS = [];
A3C_SUP_POLY_IND = 1;
A3C_SUP_POLY_IND_MARK = 1;


A3C_SUPPRESSION = false;





//-- rename to poly_markers
A3C_SUP_CREATE_POLY = {
	private ["_input","_dir","_mode","_draw","_color","_poses","_mrks"];
	_input = _this select 0;
	_dir = _this select 1;
	_mode = _this select 2;	
	_draw = _this select 3; //if (count _this > 3) then {_this select 3} else {true};
	_owners = if (count _this > 4) then {_this select 4} else {nil}; //-- array of units using the polygon
	_color = switch (_mode) do {
		case ("SUPPRESSION") : {"colorOpfor"};
		case ("AMBUSH") : {"colorBlack"};
	};
	_poses = [];
	if ((typeName (_input select 0)) == "SCALAR") then {
		
		//-- _input is a position
		private ["_pgData","_inPos","_inX","_inY","_inZ"];
		
		_pgData = [];
		_inPos = +(_input);	
		_inX = _inPos select 0;
		_inY = _inPos select 1;	
		_inZ = _inPos select 2;
	
		for "_i" from 1 to 4 do {
			_add = [];
			_size = 10;
			if (( count (nearestobjects [_inPos,["house"],10])) > 0) then {_size = 1.5};
			//systemchat "ok";
			switch (_i) do {				
				case (1) : {
					//-- Top left
					_add = [[_inX,_inY,_inZ],_size,270 + _dir] call BIS_fnc_RelPos;
					_add = [_add,_size,0 + _dir] call BIS_fnc_RelPos;
				};
				case (2) : {
					//-- Top Right
					_add = [[_inX,_inY,_inZ],_size,90 + _dir] call BIS_fnc_RelPos;
					_add = [_add,_size,0 + _dir] call BIS_fnc_RelPos;
				};
				case (3) : {
					//-- Bottom Right
					_add = [[_inX,_inY,_inZ],(_size * 0.75),90 + _dir] call BIS_fnc_RelPos; //(_size * 0.7)
					_add = [_add,_size,180 + _dir] call BIS_fnc_RelPos;
				};
				case (4) : {
					//-- Bottom Left
					_add = [[_inX,_inY,_inZ],(_size  * 0.75), 270 + _dir] call BIS_fnc_RelPos; //(_size * 0.7)
					_add = [_add,_size,180 + _dir] call BIS_fnc_RelPos;
				};
			};
			_pgData pushback _add;
			
		};
		_poses = _pgData;
	} else {
		//-- input is polygon array
		_poses = _input;
	};

	//-- create Polygon Markers
	_mrks = [];
	if (_draw) then {
		{
			_text = if (_forEachIndex == 0) then {"SZ"} else {""};

		} foreach _poses;
	};
	
	_return = [_poses,_mrks,_dir];

	//-- return markerarray to be added to Polygon-Data
	_return
};






/*
	Takes different types of inputs:
	1. [_position,""] >> coming from 3D-Indicator / Positional Suppression
	2. ["A3C_HC_POLY"",0] >> coming from HC-Waypoint //-- 0 does not represent waypoint index
*/

A3C_POLY_ACTION_ON = {

	private ["_units","_unit","_actionType","_input","_draw","_target","_veh","_weapons","_polygon","_group","_exit","_wpI","_polyIndex","_actual","_vari"];

	_units = _this select 0;
	_input = _this select 1;
	
	_actionType = _this select 2;	
	_draw = if (count _this > 3) then {_this select 3} else {false}; //-- only draw for 3D issued orders. other orders are set before
	_wpI = if (count _this > 4) then {_this select 4} else {-1};

	_target = 0;
	_polygon = [];
	_polyIndex = -1;
	_group = group (_units select 0);
	//(str [_wpi]) remoteExec ["systemCHat", 0];

	
	{
		//-- remove players from suppressing units
		if (isPlayer _x) then {
			_units = _units - [_x];
		};
	} foreach _units;
	if (count _units == 0) exitWith {};
	
	
	
	//{
	//	systemchat str (_x distance (formationposition _x));
	//} foreach _units;
	
	_exit = false;
	_isPlayerGroup = if ({player == leader group _x} count _units == (count _units)) then {true} else {false};

	//-- STEP 01: determine polygon and draw if necessary
	if ((typeName (_input select 1)) == "STRING") then {
		//-- _input is position -> order is coming from suppression indicator (or planning mode unless updated). Polygon must be created		
		//-- create polygon and markers add data to _polygon array
		if (_draw) then {
			_dirTo = [(_units select 0),(_input select 0)] call BIS_fnc_dirTo;
			(_input select 1) setMarkerDirLocal _dirTo;
			_idVal = if (_isPlayerGroup) then {getPlayerUID player} else {0100101001010100101010010101001}; //-- very random number, mockup for getServerUID //((groupID group (_units select 0)) splitstring " ") joinString ""
			_input set 
			[
				1,
				format ["A3C_SUP_MAIN_Mark_%1_%2", _idVal,A3C_SUP_POLY_IND_MARK]
			];
			A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
			_polygon = [_input] + ( [(_input select 0),_dirTo,_actionType,true,_units] call A3C_SUP_CREATE_POLY ); //~~ _units not needed!
			{
				private ["_var"];
				_var = _x getvariable ["A3C_UNIT_POLYS",[]];
				_var pushback _polygon;
				_x setvariable ["A3C_UNIT_POLYS",_var,true];
			} foreach _units;
		};
		
	} else {	
		if ((typeName (_input select 0)) == "STRING") then {
			//-- HC: polygon already displayed, will be taken from group's avariable
			_var = _group getvariable ["A3C_UNIT_POLYS",[]];
			//str [_var,_wPI] remoteExec ["systemchat",0];
			
			if (count _var > 0) then {
				_polygon = []; //(_var select 0);
				{
					if ( ((_x select 0) select 2) == _wpI) exitWith {
						_polygon = _x;
					};
				} foreach _var;
				_group setvariable ["A3C_POLY_ACTIVE",_polygon,true];
			} else {
				_exit = true;
			};
		} else {	
			//-- default: input was given as polygon (ARRAY)
			_polygon = _input;
		};
			
	};
	
	_center = (_polygon select 0) select 0;
	
	if (isnil '_center') exitWith {
		systemchat "Oops.. something went wrong. No poly detected";
		//"no poly" remoteExec ["systemchat",0];
		//systemchat str _input;
		//systemchat str _polygon;
		
	};

	
	if !(_group == group player) then {
		_group setFormDir ([(leader _group),_center] call BIS_fnc_dirTo);
	};


	//-- shared vars for all modes
	if (_exit) exitWith {
		//('exit') remoteExec ["systemchat",0];
		// systemchat 'exit poly ON';
	};
	
	{
		_unit = _x;
		if (group _unit == group player) then {
			_unit setvariable ["A3C_POLY_ACTIVE",_polygon,true];
			_expectedDestination = (expectedDestination _unit);
			if ((_expectedDestination select 0 ) distance2D [0,0,0] < 1) then {
				_expectedDestination set [0, position vehicle _unit];
			};
			_unit setVariable ["A3C_DEST",_expectedDestination,true];
		};
	} foreach _units;
	
	//waitUntil
	//{
	//	{ (alive _x) && ( (_x distance (formationposition _x)) > 3) } count _units == 0
	//};
	//-- STEP 02: Assign action
	
	switch (_actionType) do {
		case ("SUPPRESSION") : {
			_AIsuppressionRef = +(A3C_SUPPRESSION_UNITS_AI);
			_suppressionUnits = [];
			_remoteFireUnits = [];
			_artyFireUnits = [];
			{
				private _unit = _x;
				private _v = vehicle _unit;
				private _addUnit = true;
				_gunnerUnit = true;
				if (!isNull objectParent _unit) then {
					_aR = (assignedVehicleRole _unit);
					//if !(_ar isEqualTo ["Turret",[0]]) then {
					if !(_unit == gunner (vehicle _unit)) then {
						_gunnerUnit = false;
					};
				};
				
				if (_gunnerUnit) then {
					if !(isPlayer _unit) then {
						//-- remove statics with guided ammo / artilleryAmmo from suppressing units (these will be accessible via FOCUS GROUP REMOTE FIRE)
						if (_v isKindOf "STATICWEAPON") then {
							_turretmags = getArray (configfile >> "CfgVehicles" >> typeOf _v >> "Turrets" >> "MainTurret" >> "magazines");
							{
								_ammoType = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
								_lock = getNumber (configfile >> "CfgAmmo" >> _ammoType >> "weaponLockSystem");
								if (_lock > 0) then {
									_addUnit = false;
									_remoteFireUnits pushBack _unit;
								};
							} foreach _turretMags;
							if (count (getArtilleryAmmo [_v]) > 0) then {
								_addUnit = false;
								_artyFireUnits pushBack _unit;
							};
							
						};
						if (_addUnit) then {
							_suppressionUnits pushBack _unit;
						};
					};
				};													

			} foreach _units;
			
			if (count _suppressionUnits == 0) then {
				if (count (_remoteFireUnits + _artyFireUnits) > 0) then {
					_remoteString = if (count _remoteFireUnits > 0) then {"FOCUS GROUP "} else {""};
					_artyString = if (count _artyFireUnits > 0) then {"ARTILLERY "} else {""};
					_artyAddString = "";
					if (count _artyFireUnits > 0) then {
						if (count _remoteFireUnits == 0) then {
							_artyAddString = if ({group _x == group player} count _artyFireunits > 0) then {
								" (A3 Squad Controls)"
							} else {
								" (map >> groupContextMenu)"
							};
						};
					};
					_orString = "";
					_pluralString = "";
					if ( (count _remoteFireUnits > 0) && (count _artyFireUnits > 0)  ) then {
						_orString = "or ";
						_pluralString = "s";
					};
					systemchat ("A3C: Suppression not possible with current selection. Try " + _remoteString + _orString + _artyString + "method" + _pluralString + _artyAddString + " instead!");
				} else {
					systemchat "A3C: Suppression not possible with ciurrent selection";
				};
			};
			
			{
				private _unit = _x;
				if (player == (leader group _unit)) then {
					A3C_SUPPRESSION_UNITS_SQ pushbackUnique _unit;
				} else {
					A3C_SUPPRESSION_UNITS_AI pushbackUnique _unit;
				};
				
				//-- alternative targetType: "SuppressTarget" || does not work with positions above ground
				//_target = "B_Soldier_F" createVehicle ((_polygon select 0) select 0); //
				_target = "A3C_Supression_Target_F" createVehicle ((_polygon select 0) select 0); //
				_target setPos ((_polygon select 0) select 0);
				_target enableSimulation false;
				_unit dotarget _target;

				[_unit,"SUPPRESSION",(_polygon select 0) select 1,_target] spawn A3C_SPAWN_POLY_ACTION_LOOP; //(_polygon select [0,2])			
				_poses = (_polygon select 1);
				_poses = [_poses,[],{_x distance2D _unit},"ASCEND"] call BIS_fnc_sortBy;
				_root = _poses select 0;		
				call compile format
				[
					"
						_unit setvariable ['A3C_SUPPRESSION_TARGET',[_target,true,(_polygon select 0) select 2,-1],true]; 
					",
					_unit,
					_root
				];
				if (_unit in (units player)) then {
					[_unit,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual;
				} else {
					_unit setCombatMode "YELLOW";
				};
			} foreach _suppressionUnits;
			if !(_AIsuppressionRef isEqualTo A3C_SUPPRESSION_UNITS_AI) then {
				publicVariable 'A3C_SUPPRESSION_UNITS_AI';
			};
		};
		case ("AMBUSH") : {
			{
				_unit = _x;
				if (_unit in (units player)) then {
					[_unit,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
					[_unit,["BEHAVIOUR","SAFE"]] call MCSS_fnc_orderIndividual;
				} else {
					_unit setCombatMode "BLUE";
					_unit setBehaviour "SAFE";
				};
				_unit setUnitPos "DOWN";
				_unit dowatch _center; //_unit lookat _center;
				[_unit,"AMBUSH",(_polygon select 0) select 1,_target] spawn A3C_SPAWN_POLY_ACTION_LOOP; 
			} foreach _units;
		};
		case ("DEFEND") :{
		};
		case ("THROW") :{
		};
		case ("PLANT") :{
		};
		case ("ASSEMBLE") :{
		};
	};	
};




A3C_SPAWN_POLY_ACTION_LOOP = {
	//-- trick: in order to make the unit fire no matter what, set the height to 1000
	private ["_unit","_vehicle","_mode","_actual","_polys","_target","_polygon","_polyID","_polyMarker","_center","_pgD","_height","_heightASL","_radius","_mainDest","_exitMain","_groupPlayer","_tgts","_pause",
		"_restrictiveArray","_restrictiveTYPE","_restrictiveVAL","_restrictiveFNC","_restrictiveORIGIN","_usedMagazine"
	];
	_unit = _this select 0;
	_vehicle = vehicle _unit;
	

	if (isPlayer _unit) exitWith {};
	_exit = false;
	while {alive _unit} do {
		if (!isNull objectparent _unit) then {
			_exit = true;
		} else {
			if (!isPlayer leader group _unit) then {
				if (_unit distance (formationposition _unit) < 3) then {
					_exit = true;
				};
			} else {
				_exit = true;
			};
		};
		if (_exit) exitWith {};
		sleep 0.1;
	};

	if (_vehicle isKindOf 'PLANE') exitWith {};
	
	
	if !(alive _unit) exitWith {};
	//systemchat str _this;
	_mode = _this select 1;
	_polyMarker = _this select 2; //-- polyI
	_target = if (count _this > 3) then {_this select 3} else {objNull};
	
	_groupPlayer = if (_unit in (units player)) then {true} else {false};
	_actual = if (_groupPlayer) then {_unit} else {group _unit};
	_polys = [];
	_polyID = -1;

	_exitMain = true;
	
	_restrictiveArray = (profileNameSpace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED",0]]);
	_restrictiveTYPE = _restrictiveArray select 0;
	_restrictiveVAL = _restrictiveArray select 1;
	_usedMagazine = currentMagazine _unit;
	_restrictiveORIGIN = switch (_restrictiveTYPE) do {
		case ("UNLIMITED") : {0};
		case ("MAGAZINE") : { {_x == _usedMagazine} count magazines _unit};
		case ("PERCENTAGE") : {round (({_x == _usedMagazine} count magazines _unit) * (_restrictiveVAL / 100)) };
		case ("TIME") : { time };
	};
	_restrictiveFNC = switch (_restrictiveTYPE) do {
		case ("UNLIMITED") : { {false} };
		case ("MAGAZINE") : {
			{
				params ["_usedMagazine","_restrictiveORIGIN","_restrictiveVAL"];
				private _magCount = {_x == _usedMagazine} count magazines _unit;
				_magCount <= ((_restrictiveORIGIN - _restrictiveVAL) max 1)
				
			}
		};
		case ("PERCENTAGE") : {
			{
				params ["_usedMagazine","_restrictiveORIGIN","_restrictiveVAL"];
				private _magCount = {_x == _usedMagazine} count magazines _unit;
				//systemchat str [_magCount, (_restrictiveORIGIN max 1),_restrictiveORIGIN];
				_magCount <= (_restrictiveORIGIN max 1)
			} 
		};
		case ("TIME") : { 
			{
				params ["_usedMagazine","_restrictiveORIGIN","_restrictiveVAL"];
				time > _restrictiveORIGIN + _restrictiveVAL
			}
		};
	};
	
	
	
	//-- if unit has AI leader and waypoints, waypoint conditions override restrictions
	if !(isplayer (leader group _unit)) then {
		if (count (waypoints group _unit) > 0) then {
			_restrictiveFNC = {false};
		};
	};
	//-- if unit has Squad level waypoints assigned, waypoint conditions override restrictions
	if (count (_unit getVariable ["A3C_PLOT",[]]) > 0) then {
		_restrictiveFNC = {false};
	};
	
	
	private _exitRestrictive = false;

	switch (_mode) do {
		case ("SUPPRESSION") : {
			//systemchat str _unit;
			_unit setVariable ["A3C_POLY_ACTION_ACTIVE",true,true];
			
			//if (_unit == gunner vehicle _unit) then {
			//	[_unit,_target] remoteExec ["doWatch",_unit];
			//	[_unit,_target] remoteExec ["doTarget",_unit];
			//	_unit lookAt _target; 
			//	sleep 3;
			//};
			//-- put in AWARE
			if !(isPlayer leader group _unit) then {
				if !(behaviour _unit in ["AWARE","COMBAT"]) then {
					[leader (group _unit),"AWARE"] remoteExec ["setBehaviour", leader group _unit];
				};
			}; 
			(vehicle _unit) setVariable ["A3C_AIM_ADJUST",0,true];
			private _targetFnc = {
				params ["_unit","_target"];
				//private _vehicle = vehicle _unit;
				_targetPos = position _target;
				//systemchat str _targetPos;
				[_unit,[_target,4]] remoteExec ["reveal",_unit];
				[_unit,_target] remoteExec ["doTarget",_unit];
				//[_unit,_target] remoteExec ["doWatch",_unit];
				//if ( !(_vehicle isKindOf "HELICOPTER") OR (getDir _unit == getDir _vehicle)) then {
					[_unit,objNull] remoteExec ["lookAt",_unit];
					[_unit,_targetpos] remoteExec ["lookAt",_unit];
				//};
			};
			
			while {!isnull _target} do {
				if (isnull _unit) exitWith {};
				if (!alive _unit) exitWith {};
				if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitWith {};
				
				if (_exitRestrictive) exitWith {
					[[_unit],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
					_unit groupChat (["SUPPRESSION COMPLETE!","SUPPRESSION COMPLETE!","I'M DONE SUPPRESSING","I'M NO LONGER SUPPRESSING!"] call BIS_fnc_SelectRandom);
				};
				
				
				private _pos = [];
				_cycle = 0;
					
				_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];
				_polygon = [];
				_exitMain = true;
				{
					if ( ((_x select 0) select 1) == _polyMarker) exitWith {
						_polygon = +(_x);
						_exitMain = false;
					};
				} foreach _polys;
				
				if (_exitMain) exitWith {
					//"e1" remoteExec ["systemChat",0];
				};
				
				_center = (_polygon select 0) select 0; 
				_polyID = if (count (_polygon select 0) > 2) then {(_polygon select 0) select 2} else {-1};
				//systemchat str [(isNil '_polyID'),_polygon];
				private _pgD = _polygon select 1;
				_height = _center select 2;
				//systemchat str _height;
				_center = ATLtoASL _center;
				_heightASL = ((ATLtoASL _center) select 2) + 0.7;
				_radius = 0;
				
				_mainDest = (expectedDestination _unit) select 0;
				
				if (isNull objectParent _unit) then {
					[_unit,_target] remoteExec ["doTarget",_unit];
				} else {
					//[_unit,_target] remoteExec ["doWatch",_unit];
					//[_unit,_target] call _targetFnc; 
				};
				//[_unit,_target] remoteExec ["doWatch",_unit];
				//_unit lookat position _target;
				sleep 1;
			
				{
					_dst = _x distance2D _center;
					if (_dst > _radius) then {
						_radius = _dst;
					};
				} foreach _pgD;
				//hintsilent str [_center];

				//player sidechat "loop";
				if (!isPlayer (leader group _unit)) then {
					if (isNull objectParent _unit) then {
						_unit setUnitPos "MIDDLE";
					};
				};
				
				//if (_height < 1) then {
					while {!isnull _target} do {
						//hintsilent "searching";
						if ([_usedMagazine,_restrictiveORIGIN,_restrictiveVAL] call _restrictiveFNC) exitWith {_exitRestrictive = true};
						if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitWith {};
						_exit = false;
						_cycle = _cycle + 1;
						if (_cycle > 300) exitWith {
							_exitMain = true;
							//"e2 (cycle)" remoteExec ["systemChat",0];
						};
						_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];

						if !(_polygon in _polys) exitWith {
							if ({ ((_x select 0) select 1) == _polyMarker} count _polys == 0) then {
								_exitMain = true;
								//"e3 (poly lost)" remoteExec ["systemChat",0];
							};
							//systemchat "player moving";
						};
						_pos = [_center,_radius] call BIS_fnc_randomPosTrigger;
						
						if (_pos inPolygon _pgD) then {
								
							_pos set [2,(_pos select 2) + 0.7];
							if ([vehicle _unit,_pos,_target,false] call MCSS_fnc_LOS_SIMPLE) then {
								_dir = [_pos,_unit] call BIS_fnc_dirTo;
								_pos = [_pos,5,_dir] call BIS_fnc_relPos;
								//player sidechat "found a position easy";		
								_exit = true;
								if (_height >= 1) then {
									[_target,_pos] remoteExec ["setPosASL",_target];
								} else {
									[_target,((_pos select [0,2]) + [0])] remoteExec ["setPos",_target];
								};
							} else {
								
								//_lSF = (terrainIntersectASL [([_unit] call MCSS_fnc_Switch_Eyepos),_pos]);
								//if !(_lSF) then {
								//	_exit = true;
								//	[_target,_pos] remoteExec ["setPosASL",_target];	
								//};
								
								_lSF = (lineintersectsSurfaces [([_unit] call MCSS_fnc_Switch_Eyepos),_pos,vehicle _unit,objnull]);
								if (count _lSF > 0) then {
									
									_pos = (_lSF select 0) select 0;

									if (_pos inPolygon _pgD) then {
										_exit = true;
										//player commandchat "found a position LSF";	
										_height = (ASLtoATL _pos) select 2;
										if (_height >= 1) then {
											_target setposASL _pos;
										} else {
											_target setpos ((_pos select [0,2]) + [0]);
										};
									};		
								};
								
							};
							
						
						};
						if (_exit) exitWith {
							//[_unit,_target] call _targetFnc; 
						};
						//systemchat "not found a position";
						
					};
				//};
				if (_vehicle isKindOf 'HELICOPTER') then {
					if (!isPlayer (driver _vehicle)) then {
						[_vehicle,0] remoteExec ["limitSpeed",_vehicle];
						while {canMove _vehicle} do {
							if (speed _vehicle < 2) exitWith {};
						};
						//{_v = _x; {_v disableAI _x} foreach ["ALL"]} foreach [_vehicle,driver _vehicle];
						[_vehicle,"ALL"] remoteExec ["disableAI",_vehicle];
						[driver _vehicle,"ALL"] remoteExec ["disableAI",driver _vehicle];
						sleep 1;
						//while {alive _vehicle} do {
							if (speed _vehicle < 1) then {
								_orientPos = position _target;
								//if (getDir _unit != getDir _vehicle) then {
								//	_relDir = [_unit, _vehicle getPos [100,0]]  call BIS_fnc_relativeDirTo;
								//	_dirToOrient = _vehicle getDir _target;
								//	if (_relDir <= 180) then {
								//		_dirToOrient = _dirToOrient + 90; //_relDir;
								//	} else {
								//		_dirToOrient = _dirToOrient - 90; //_relDir;
								//	};
								//	_dirToOrient = [_dirToOrient] call MCSS_fnc_CorrectDir;
								//	_orientPos = _vehicle getPos [100,_dirToOrient];
								//};
								_scr1 = [_vehicle,_orientPos] spawn A3C_FORCEORIENT;
								waituntil {scriptDone _scr1 or !canMove _vehicle OR ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}; 
								//
								if ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0) then {_exitMain = true};
							} else {
								_exitMain = true;
							};
							//sleep 0.2;
						//};
						//-- instead of this, make vehicle stop!
					};
				};
				if (_exitMain && {_groupPlayer}) exitWith {
					_unit groupchat (["Can not comply","I can't see the target","Target out of sight"] call BIS_fnc_SelectRandom);
					[[_unit],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
					//"e4" remoteExec ["systemChat",0];
					//systemchat "off move tar";
				};
				
			
				//-- refresh order
				[_unit,[_target,4]] remoteExec ["reveal",_unit];
				if (isNull objectParent _unit) then {
					[_unit,_target] remoteExec ["doTarget",_unit];
				} else {
					[_unit,_target] call _targetFnc; 
				};
				sleep 1;
				//_unit doSuppressiveFire _target;
				_scr = {};
				//systemchat str _unit;
				if (isNull objectParent _unit) then {
					[_unit,_target] remoteExec ["doSuppressiveFire",_unit];
					//systemchat "1";
					_scr = [] spawn {};
				} else {
					//systemchat str _target;
					//systemchat str
					
					[[vehicle _unit,_target],A3C_ai_shared_fnc_addEventhandlerFired] remoteExec ["bis_fnc_call",0];
					
					//_handle = vehicle _unit addEventHandler
					//[
					//	"Fired",
					//	{
					//		_this spawn A3C_guided_BulletHandler
					//	}	
					//];
					
					
					_handle = {};
					
					//-- vehicle fire has to be spawned so that the exit conditions can run in parallel!
					[_unit,_vehicle,_target,_handle,_targetFnc] spawn {
						params ["_unit","_vehicle","_target","_handle","_targetFnc"];
						for "_i" from 1 to 3 do {
							for "_l" from 1 to 10 do {
								if (!isNull _target) then {
									//[_unit,position _target] remoteExec ["doWatch",_unit];
									//[_unit,_target] remoteExec ["doTarget",_unit];
									//[_unit,_target] call _targetFnc; 
									//hintsilent "1";
									if ((_vehicle isKindOf "HELICOPTER") OR [position _target, _unit,10] call MCSS_fnc_LOS_Vehicle) then {
										//hintsilent "2";
										//[_target, vehicle _unit] call A3C_fnc_isTargetWithinTurretElevationRange;
										_magType = currentMagazine (vehicle _unit);
										_currentAmmo = getText (configfile >> "CfgMagazines" >> _magType >> "ammo");
										_lock = getNumber (configfile >> "CfgAmmo" >> _currentAmmo >> "weaponLockSystem");
										if (_lock == 0) then {
											[(vehicle _unit),[_target]] remoteExec ["fireAtTarget",(vehicle _unit)];
											//(vehicle _unit) fireAtTarget [_target]; //[_target];
											sleep 0.1;
										};
									};
								};
							};
							//[_unit,_target] remoteExec ["doWatch",_unit];
							sleep 2;
						};
						//(vehicle _unit) removeEventHandler ["Fired",_handle];
						[[vehicle _unit],A3C_ai_shared_fnc_removeEventhandlerFired] remoteExec ["bis_fnc_call",0];
					};
					
					
				};
				
				_count = 0;
				_origPos = position _unit;
					
				//-- Firing cycle - units are already firing, the loop waits for suppression cycle (infantry) tp complete
				while {alive _unit} do {
					//if (isnil '_poly') exitWith {};
					if ([_usedMagazine,_restrictiveORIGIN,_restrictiveVAL] call _restrictiveFNC) exitWith {_exitRestrictive = true};
					//-- exit if poly no longer exists 
					if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitWith {};
					//-- exit and reset loop if polygon was dragged!
					if ({_polyID == ((_x select 0) select 2) && {_dist = (((_x select 0) select 0) distance2d _center); _dist > 1}} count A3C_ALL_POLYS > 0) exitWith {sleep 1;}; 
					
					//_center = (_polygon select 0) select 0; 
					//_polyID = (_polygon select 0) select 2;
					
					_count = _count + 1;
					sleep 1;
					_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];
					if !(_polygon in _polys) exitWith {
						{
							if ((_x select 0) select 1 == _polyMarker) then {
								_target setpos ((_x select 0) select 0);
							};
						} foreach _polys;
						
					};
					_exp = expectedDestination _unit;
					//if (currentCommand _unit == "STOP") then {
					//	if ((_exp select 1) in ["DoNotPlanFormation","FORMATION PLANNED" ] ) then {
					if !((tolower (currentCommand _unit)) in ["attack","suppress","","scripted"]) exitWith {
						_exitMain = true;
						//"ec 1" remoteExec ["systemChat",0];
					};
					//if !(currentCommand _unit == "Suppress") exitWith {
						//_exitMain = true;
					//};
					if !(_unit getVariable "A3C_POLY_ACTION_ACTIVE") exitWith {
						_exitMain = true;
						//"ec 2" remoteExec ["systemChat",0];
					};
					
					if ( (_mainDest distance2D (_exp select 0)) > 5) then {
						if (_unit distance2D _origPos > 2) then {
								_exitMain = true;
								//"ec 3" remoteExec ["systemChat",0];
								//systemchat "5";
								//systemchat ((str _unit) + " exit expD");
						};
					};
					if (_exitMain) exitWith {};
					//if (_count >= 3) exitWith {};
				};
				if (_exitMain && {_groupPlayer}) exitWith {
					if !(isnull _target) then {
						//systemchat "remove polyg";
						[_unit,_polygon] call A3C_SUP_REMOVE_POLY;
					};
					//"e4" remoteExec ["systemChat",0];
				};
					
			};
			if (!isPlayer _unit) then {
				if !(isPlayer (leader group _unit)) then {
					if (isNull objectParent _unit && {_unit == driver (objectParent _unit)}) then {
						[_unit,(formationPosition _unit)] remoteExec ["doMove",_unit];
						[_unit,(formationPosition _unit)] remoteExec ["moveTo",_unit];
					};
				};
			};
			if (!isPlayer (leader group _unit)) then {
				if (isNull objectParent _unit) then {
					_unit setUnitPos "AUTO";
				};
			};
			_unit setVariable ["A3C_POLY_ACTION_ACTIVE",false,true];
			if (_vehicle isKindOf 'HELICOPTER') then {
				//{_v = _x; {_v enableAI _x} foreach ["MOVE","PATH"]} foreach [_vehicle,driver _vehicle];
				[_vehicle,"ALL"] remoteExec ["enableAI",_vehicle];
				[driver _vehicle,"ALL"] remoteExec ["enableAI",driver _vehicle];
				[_vehicle,2000] remoteExec ["limitSpeed",_vehicle];
			};
			//systemchat "exit";
		};
		case ("AMBUSH") : {
			_unit setVariable ["A3C_POLY_ACTION_ACTIVE",true,true];
			while {alive _unit} do {
				_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];
				//if (behaviour _unit != "SAFE") exitWith {};
				if ({ ((_x select 0) select 1) == _polyMarker} count _polys == 0) then {_exitMain = true};
				_polygon = [];
				_exitMain = true;
				{
					if ( ((_x select 0) select 1) == _polyMarker) exitWith {
						_polygon = +(_x);
						_exitMain = false;
					};
				} foreach _polys;
				if !(_unit getVariable "A3C_POLY_ACTION_ACTIVE") exitWith {
					_exitMain = true;
				};
				if (_exitMain) exitWith {};
				_center = (_polygon select 0) select 0; 
				_polyID = (_polygon select 0) select 2;
				_pgD = _polygon select 1;
				_radius = 0;
				_origPos = position _unit;	
				{
					_dst = _x distance2D _center;
					if (_dst > _radius) then {
						_radius = _dst;
					};
				} foreach _pgD;
				if !(_polygon in _polys) then { //-- can not happen/ not necessary?
					systemchat "turns out this COULD happen";
					
				};
				
				_exp = expectedDestination _unit;
				_mainDest =_exp select 0;
	
				if ( (_mainDest distance2D (_exp select 0)) > 5) then {
					if (_unit distance2D _origPos > 2) then {
						_exitMain = true;
					};
				};
				if (_exitMain) exitWith {};

				_tgts = [(side _unit),_radius,"ENEMY",_center,["MAN","CAR","TANK"]] call MCSS_fnc_NearEntities;
				_pause = if (count _tgts > 0) then {0.1} else {1};
				if ( {(getposASL vehicle _x) inPolygon _pgD} count _tgts > 0) exitWith {
					//~~ lots of room for improvement as far as behaviour is concerned
					[_unit,"RED"] remoteExec ["setCombatMode",_unit];
					[_unit,"COMBAT"] remoteExec ["setBehaviour",_unit];
					//_unit doSuppressiveFire (_tgts call BIS_fnc_selectRandom);
					{[_unit,[_x,4]] remoteExec ["reveal",_unit]} foreach _tgts;
					[_unit,(_tgts call BIS_fnc_selectRandom)] remoteExec ["doSuppressiveFire",_unit];
					//{_unit reveal [_x,4]} foreach _tgts;
					
				};
				sleep _pause;
			};
			[_unit,"YELLOW"] remoteExec ["setCombatMode",_unit];
			[_unit,"AWARE"] remoteExec ["setBehaviour",_unit];
			[_unit,"AUTO"] remoteExec ["setUnitPos",_unit];
		};
	};	
};





A3C_POLY_ACTION_OFF = {

	private ["_units","_mode","_run","_playerGroup","_poly"];

	_units = _this select 0;
	_mode = _this select 1;

	// systemchat format ["A3C_POLY_ACTION_OFF units %1", _units];
	if (count _units == 0) then {
		if (!isNull player) then {
			_units = A3C_SUPPRESSION_UNITS_SQ; //-- auto selection ALL for playerGroup units 
		};
	};
	if (count _units == 0) exitWith {};
	_poly = [];
	_followunits = [];
	switch (_mode) do {
		case ("SUPPRESSION") : {
			_refAIunits = +(A3C_SUPPRESSION_UNITS_AI);
			{
				private ["_u","_target","_pVar","_t"];
				_u = _x;
				_playerGroup = if (_x in (units player)) then {true} else {false};
				_target = [((_x getvariable ["A3C_SUPPRESSION_TARGET",[objNull]]) select 0),objnull];
				_t = if (_playerGroup) then {_u} else {group _u};
				if (_target isEqualType []) then {
					_target = _target select 0;
				};
				if !(typename _target == "SCALAR") then {
					if (!isnull _target) then {
						deletevehicle _target;										
					};
				};
				
				doStop _x;
				_x dowatch objnull;
		
				//--target is individual per unit
				
				
				_x setvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1],true];
				_poly = _t getvariable "A3C_POLY_ACTIVE";
				_t setvariable ["A3C_POLY_ACTIVE",[],true];
				[_u,_poly] call A3C_SUP_REMOVE_POLY;

				_ed = _x getvariable ["A3C_DEST",(expectedDestination _x)];
				// systemchat format ["POLY ACTION OFF: %1", _u];
				[_u] call A3C_ai_squad_fnc_actionResumeDestination;	
			
				A3C_SUPPRESSION_UNITS_SQ = A3C_SUPPRESSION_UNITS_SQ - [_u];
				A3C_SUPPRESSION_UNITS_AI = A3C_SUPPRESSION_UNITS_AI - [_u];
				
			} foreach _units;
			if !(_refAIunits isEqualTo A3C_SUPPRESSION_UNITS_AI) then {
				publicVariable 'A3C_SUPPRESSION_UNITS_AI';
			};
			
		};
		case ("AMBUSH") : { //~~ adjust this for playerGroup
			{
				private ["_u","_target","_pVar","_t"];
				_u = _x;
				_playerGroup = if (_x in (units player)) then {true} else {false};
				_u setBehaviour "AWARE"; 
				_u setUnitPos "AUTO"; 
				_u setCombatMode "YELLOW"; 
				_target = [((_x getvariable "A3C_SUPPRESSION_TARGET") select 0),objnull];
				_t = if (_playerGroup) then {_u} else {group _u};
				_x dowatch objnull;
				_poly = _t getvariable "A3C_POLY_ACTIVE";
				_t setvariable ["A3C_POLY_ACTIVE",[],true];
				[_u,_poly] call A3C_SUP_REMOVE_POLY;
			} foreach _units;
		};
		case ("DEFEND") : {
		};
	};
	showCommandingMenu "";	
};


A3C_SUP_REMOVE_POLY = {
	private ["_unit","_polygon","_markers","_delPoly","_units"];
	_unit = _this select 0;
	_polygon = _this select 1;

	if (count _polygon == 0) exitWith {};

	_markers = [(_polygon select 0) select 1] + (_polygon select 2);

	A3C_SUPPRESSION_UNITS_SQ = A3C_SUPPRESSION_UNITS_SQ - [_unit]; //-- leave this here, not sure if it's needed. However, removing AI-Array units is taken care in the functions calling remove_poly
	//_units  = if (group _unit == group player) then {A3C_SUPPRESSION_UNITS_SQ} else {units group _unit};
	_units  = if (group _unit == group player) then {A3C_SUPPRESSION_UNITS_SQ} else {A3C_SUPPRESSION_UNITS_AI};
	//_units  = units _unit;
	//

	//"removePoly" remoteExec ["systemChat",0];
	_delPoly = true;
	{
		private ["_mks","_data","_var"];
		_var = _x getvariable ["A3C_UNIT_POLYS",[]]; //~~ can't be read for groups :s

		if (count _var > 0) then {	
			_mks = (_var select 0) select 2;
			if ((_markers select 0) in _mks) then {
				_delPoly = false;
			};
		};
		
	} foreach ( (_units - [_unit]) ); //A3C_HC_getAllGroups_Player_Current + 
	
	if (_delPoly) then {
		{
			A3C_POLYEDGE_MARKERS = A3C_POLYEDGE_MARKERS - [_x];
			deleteMarkerLocal _x;
		} foreach _markers;
		if !(group _unit == group player) then {
			private ["_group","_var"];
			_group = group _unit;
			_var = _group getvariable "A3C_UNIT_POLYS";
			private _polyID = (_polygon select 0) select 1;
			{
				_refID = (_x select 0) select 1;
				if (_polyID == _refID) exitWith {
					_var = _var - [_x];
				};
			} foreach _var;
			
			_group setVariable ["A3C_UNIT_POLYS",_var,true];
		};
	};
	if (group _unit == group player) then {
		_var = _unit getvariable "A3C_UNIT_POLYS";
		_var = _var - [_polygon];
		_unit setVariable ["A3C_UNIT_POLYS",_var,true];
	};
	
	_unit setvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1],true];
	
};


if (isDedicated) exitWith {}; //-- just keeping this as a reminder that above is to run everywhere



















