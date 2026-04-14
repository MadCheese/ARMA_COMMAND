
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


//[gpT,[17193.6,16281.9,0]] call A3C_HC_Suppression_Immediate;
A3C_HC_Suppression_Immediate = {
	params ["_group","_pos"];
	_indSel = (currentWaypoint _group) + 1;
	_dirTo = (vehicle leader _group) getDir _pos;
	_polygon = ([[_pos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext 'SUP',getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ([_pos,_dirTo,'SUPPRESSION',true] call A3C_SUP_CREATE_POLY));
	A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
	_var = _group getvariable ["A3C_UNIT_POLYS",[]];
	_var = [_polygon] + _var;
	_group setvariable ["A3C_UNIT_POLYS",_var,true];
	[[getPlayerUID player,leader _group,[['GoCode','D'],'SUPPRESSION'],'LINE',_indSel], A3C_HC_INSERT_ACTION_WP] remoteExec ['bis_fnc_call',0];
};

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





A3C_VEHICLE_SUPPRESSION = {
	_unit = _this select 0;
	_target = _this select 1;
	_exit = false;			
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
	if (count _units == 0) exitwith {};
	
	
	
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
					if ( ((_x select 0) select 2) == _wpI) exitwith {
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
		//systemchat 'exit';
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
				//"bg" remoteExec ["systemChat",0];
				//_target = "B_Soldier_F" createVehicle ((_polygon select 0) select 0); //
				_target = "A3C_Supression_Target_F" createVehicle ((_polygon select 0) select 0); //
				_target setPos ((_polygon select 0) select 0);
				_target enableSimulation false;
				_unit dotarget _target;
				//_unit lookat position _target;
				//_unit domove position _unit;
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

A3C_SUP_SET_NUMSAFE = {
	params ["_mode"];
	private ["_control","_default"];
	_ctrl = switch (_mode) do {
		case ("PERCENTAGE") : {findDisplay 100070 displayCtrl 1401};
		case ("MAGAZINE") : {findDisplay 100070 displayCtrl 1402};
		case ("TIME") : {findDisplay 100070 displayCtrl 1403};
	};
	_default = switch (_mode) do {
		case ("PERCENTAGE") : {(str (profileNameSpace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25]))};
		case ("MAGAZINE") : {(str (profileNameSpace getVariable ["A3C_SUP_VAL_MAGAZINE", 1]))};
		case ("TIME") : {(str (profileNameSpace getVariable ["A3C_SUP_VAL_TIME", 30]))};
	};
	//systemchat str _default;
	//systemchat str (parseNumber (ctrlText _ctrl));
	if ((parseNumber (ctrlText _ctrl)) == 0) then {_ctrl ctrlSetText _default};
};


A3C_SUP_SETTINGS = {
	params ["_mode","_overRide"];
	private ["_idcSelected"];
	//systemchat str time;
	for "_i" from 1200 to 1203 do {
		(findDisplay 100070 displayCtrl _i) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_checkbox_Unchecked.paa";
	};
	_idcSelected = switch (_mode) do {
		case ("UNLIMITED") : {1200};
		case ("PERCENTAGE") : {1201};
		case ("MAGAZINE") : {1202};
		case ("TIME") : {1203};
	};
	(findDisplay 100070 displayCtrl _idcSelected) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_checkbox_Checked.paa";
	//ctrlSetFocus (findDisplay 100070 displayCtrl 2);
	if (_overRide) then {
		profilenamespace setvariable ["A3C_SUP_VAL_PERCENTAGE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1401))];
		profilenamespace setvariable ["A3C_SUP_VAL_MAGAZINE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1402))];
		profilenamespace setvariable ["A3C_SUP_VAL_TIME",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1403))];
		//if !(ctrlShown (findDisplay 100070 displayCtrl 1401)) then {systemchat 'A3C: you can now let go of the keys and enter your desired values. Confirm or cancel order with the buttons.'};
		
		//for "_i" from 1401 to 1403 do {
		//	(findDisplay 100070 displayCtrl _i) ctrlShow true;
		//};
	};
	_modeData = switch (_mode) do {
		case ("UNLIMITED") : {0};
		case ("PERCENTAGE") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1401))};
		case ("MAGAZINE") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1402))};
		case ("TIME") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1403))};
	};
	(findDisplay 100070 displayCtrl 1401) ctrlSetText (str (profileNameSpace getVariable ["A3C_SUP_VAL_PERCENTAGE", 25]));
	(findDisplay 100070 displayCtrl 1402) ctrlSetText (str (profileNameSpace getVariable ["A3C_SUP_VAL_MAGAZINE", 1]));
	(findDisplay 100070 displayCtrl 1403) ctrlSetText (str (profileNameSpace getVariable ["A3C_SUP_VAL_TIME", 30]));
	ctrlSetFocus (findDisplay 100070 displayCtrl 1601);
	profilenamespace setvariable ["A3C_SUP_RESTRICTIVE",[_mode,_modeData]];
};





A3C_SPAWN_POLY_ACTION_LOOP = {
	//-- trick: in order to make the unit fire no matter what, set the height to 1000
	private ["_unit","_vehicle","_mode","_actual","_polys","_target","_polygon","_polyID","_polyMarker","_center","_pgD","_height","_heightASL","_radius","_mainDest","_exitMain","_groupPlayer","_tgts","_pause",
		"_restrictiveArray","_restrictiveTYPE","_restrictiveVAL","_restrictiveFNC","_restrictiveORIGIN","_usedMagazine"
	];
	_unit = _this select 0;
	_vehicle = vehicle _unit;
	
	//if ((!isNull objectParent _unit) && (_unit == gunner _vehicle) && (getDir _unit != getDir _vehicle) ) exitWith {
	//	systemchat 'non';
	//};
	//"bg1" remoteExec ["systemChat",0];
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
				if (isnull _unit) exitwith {};
				if (!alive _unit) exitwith {};
				if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitwith {};
				
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
						if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitwith {};
						_exit = false;
						_cycle = _cycle + 1;
						if (_cycle > 300) exitwith {
							_exitMain = true;
							//"e2 (cycle)" remoteExec ["systemChat",0];
						};
						_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];

						if !(_polygon in _polys) exitwith {
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
					
					[[vehicle _unit,_target],A3C_addFiredHandler] remoteExec ["bis_fnc_call",0];
					
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
										//[_target, vehicle _unit] call A3C_Turret_HEIGHTRANGE;
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
						[[vehicle _unit],A3C_removeFiredHandler] remoteExec ["bis_fnc_call",0];
					};
					
					
				};
				
				_count = 0;
				_origPos = position _unit;
					
				//-- Firing cycle - units are already firing, the loop waits for suppression cycle (infantry) tp complete
				while {alive _unit} do {
					//if (isnil '_poly') exitWith {};
					if ([_usedMagazine,_restrictiveORIGIN,_restrictiveVAL] call _restrictiveFNC) exitWith {_exitRestrictive = true};
					//-- exit if poly no longer exists 
					if ( !isnil '_poly' && {!(_polyID == -1) && ({_polyID == ((_x select 0) select 2)} count A3C_ALL_POLYS == 0)}) exitwith {};
					//-- exit and reset loop if polygon was dragged!
					if ({_polyID == ((_x select 0) select 2) && {_dist = (((_x select 0) select 0) distance2d _center); _dist > 1}} count A3C_ALL_POLYS > 0) exitWith {sleep 1;}; 
					
					//_center = (_polygon select 0) select 0; 
					//_polyID = (_polygon select 0) select 2;
					
					_count = _count + 1;
					sleep 1;
					_polys = _actual getvariable ["A3C_UNIT_POLYS",[]];
					if !(_polygon in _polys) exitwith {
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
					//if (_count >= 3) exitwith {};
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
				//if (behaviour _unit != "SAFE") exitwith {};
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
				if ( {(getposASL vehicle _x) inPolygon _pgD} count _tgts > 0) exitwith {
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
			//[_unit,_polygon] call A3C_SUP_REMOVE_POLY;
			//systemchat "exit";
			//_unit setVariable ["A3C_POLY_ACTION_ACTIVE",false,true];
		};
	};	
};

A3C_Turret_HEIGHTRANGE = {
	params ["_target","_vehicle"];
	_dist = _target distance2D _vehicle;
	_heightDif = if ((getposASL _target select 2) >= (getposASL _vehicle select 2)) then {
		(getposASL _target select 2) - (getposASL _vehicle select 2);
	} else {
		(getposASL _vehicle select 2) - (getposASL _target select 2);
	};
	_alpha = [0,0,0] getDir [_heightDif,_dist,0]; //-- sloppy dumbsmart way to get z-angle 
	_weaponAngle = atan (_vehicle AnimationPhase "maingun");
	_radNeeded = rad _alpha;
	_radWeapon = (_vehicle AnimationPhase "maingun");
	private _reg = (_radNeeded - _radWeapon);
	_abs = abs (_radNeeded - _radWeapon);
	
	_aimAdjust = _vehicle getVariable ["A3C_AIM_ADJUST",0];
	//_abs = abs (_alpha - _weaponAngle);
	//_inRange = (_abs < 2);
	_inRange = _abs < 0.05;
	//if (_inRange) then {
		//hintsilent str [_abs, _weaponAngle, _inRange];
	//	hintsilent str [_radNeeded, _radWeapon];
	//};
	if !(_inRange) then {
		if (_reg >= 0) then {
			_aimAdjust = _aimAdjust + 0.01;
		} else{
			_aimAdjust = _aimAdjust - 0.01;
		};
		_vehicle setVariable ["A3C_AIM_ADJUST",_aimAdjust,true];
		_aimPos = +(getPosATL _target);
		_aimPos set [2,(_aimPos select 2) + _aimAdjust];
		(gunner _vehicle) doWatch _aimPos;
		player setPos _aimPos
		//hintsilent str [_radNeeded, _radWeapon,_aimPos select 2,_abs];
	};
	_inRange
	//true
};



A3C_POLY_ACTION_OFF = {

	private ["_units","_mode","_run","_playerGroup","_poly"];
	_units = _this select 0;
	_mode = _this select 1;
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
				if (typename _target == "ARRAY" ) then {
					_target = _target select 0;
				};
				if !(typename _target == "SCALAR") then {
					if (!isnull _target) then {
						deletevehicle _target;										
					};
				};
				//if (false) then {
					doStop _x;
					_x dowatch objnull;
			
					//--target is individual per unit
					
					
					_x setvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1],true];
					_poly = _t getvariable "A3C_POLY_ACTIVE";
					_t setvariable ["A3C_POLY_ACTIVE",[],true];
					[_u,_poly] call A3C_SUP_REMOVE_POLY;

					_ed = _x getvariable ["A3C_DEST",(expectedDestination _x)];
					[_u] call A3C_UNIT_RESUME_DESTINATION;	
				//};
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

	if (count _polygon == 0) exitwith {};

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
		
	} foreach ( (_units - [_unit]) ); //A3C_HCALLGROUPS_Current + 
	
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
			//str ([( _unit),_poly,_var]) remoteExec ["systemChat",0];
			//(composeText [str _unit, lineBreak, str _polyGon,lineBreak, str _var]) remoteExec ["hint",0];
		};
	};
	if (group _unit == group player) then {
		_var = _unit getvariable "A3C_UNIT_POLYS";
		_var = _var - [_polygon];
		_unit setVariable ["A3C_UNIT_POLYS",_var,true];
	};
	
	_unit setvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1],true];
	
};


if (isDedicated) exitWith {};


//-- CLIENT STUFF: UI, CONTROLS ETC

A3C_SUP_MouseDown = {
	if (A3C_SUP_BOOL_MD) exitwith {};
	
	if (_this select 1 == 1) exitwith {
		[] call A3C_SUP_CloseDisplay; //(findDisplay 100070) closeDisplay 0;
	};
	A3C_SUP_BOOL_MD = true;
	A3C_SUP_CLICKPOS = [_this select 2,_this select 3];
	//hintsilent str _this;
};

A3C_SUP_MouseMoving = {
	A3C_SUP_MOUSEPOS = [_this select 1,_this select 2];
	_mouseX = A3C_SUP_MOUSEPOS select 0;
	_mouseY = A3C_SUP_MOUSEPOS select 1;
	if !(A3C_SUP_BOOL_MD) exitwith {};
	
	_ctrl = (findDisplay 100070 displayCtrl 3);
	_cPos = ctrlPosition _ctrl;
	_clickX = A3C_SUP_CLICKPOS select 0;
	_clickY = A3C_SUP_CLICKPOS select 1;
	_w = (_mouseX - _clickX);
	_h = (_mouseY - _clickY);
	_ctrl ctrlSetPosition [_clickX,_clickY,_w,_h];
	_ctrl ctrlCommit 0;
};

A3C_SUP_MouseUp = {
	A3C_SUP_BOOL_MD = false;
};

A3C_SUP_KeyDown = {
	_btn = _this select 1;
	if (_btn == A3C_SUP_DRAWKEY_ID select 0) exitWith {
		if (A3C_SUP_DRAW_TOGGLE) then {
			[] call A3C_SUP_CloseDisplay;
		};
	};
};

A3C_SUP_CloseDisplay = {
	profilenamespace setvariable ["A3C_SUP_VAL_PERCENTAGE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1401))];
	profilenamespace setvariable ["A3C_SUP_VAL_MAGAZINE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1402))];
	profilenamespace setvariable ["A3C_SUP_VAL_TIME",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1403))];
	
	private _mode = (profilenamespace getvariable ["A3C_SUP_RESTRICTIVE",["UNLIMITED",0]]) select 0;
	_modeData = switch (_mode) do {
		case ("UNLIMITED") : {0};
		case ("PERCENTAGE") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1401))};
		case ("MAGAZINE") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1402))};
		case ("TIME") : {parseNumber (ctrlText (findDisplay 100070 displayCtrl 1403))};
	};
	//systemchat "ay";
	profilenamespace setvariable ["A3C_SUP_RESTRICTIVE",[_mode,_modeData]];
	
	
	(findDisplay 100070) closeDisplay 0;
};


A3C_SUP_KeyUp = {
	_btn = _this select 1;
	_exit = false;
	
	if (_btn == A3C_SUP_DRAWKEY_ID select 0) then {
		if !(A3C_SUP_DRAW_TOGGLE) then {
			if (A3C_DRAW_ORDER_RELEASE) then {
				_exit = true;
				_cPos = (ctrlPosition (findDisplay 100070 displayCtrl 3));
				profilenamespace setvariable ["A3C_SUP_VAL_PERCENTAGE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1401))];
				profilenamespace setvariable ["A3C_SUP_VAL_MAGAZINE",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1402))];
				profilenamespace setvariable ["A3C_SUP_VAL_TIME",parseNumber (ctrlText (findDisplay 100070 displayCtrl 1403))];
				if ({_x > 0} count _cPos > 0) then {
					[] spawn A3C_SUP_DRAW_SETORDER;
				} else {
					systemchat 'A3C: No Target Area received';
					
					[] call A3C_SUP_CloseDisplay; //(findDisplay 100070) closeDisplay 0;
				};
			};							
		};
	};
	if (_exit) exitWith {};
};


A3C_SUP_DRAW_SETORDER = {
	private ["_mainMark","_dirTo"];
	disableSerialization;
	_ctrl = (findDisplay 100070 displayCtrl 3);
	
	//-- get dimensions of Suppression-Area Indicator
	_cPos = ctrlPosition _ctrl;
	_x = _cPos select 0;
	_y = _cPos select 1;
	_w = _cPos select 2;
	_h = _cPos select 3;
	
	//-- form cornerPoints of rectangle into Screen Coordinates
	_sP1 = [_x,_y]; //-- Top Left (further pos left)
	_sP2 = [(_x + _w),_y]; //-- Back Right (further right)
	_sP4 = [_x,(_y + _h)]; //-- Front Left  //        vv switched
	_sP3 = [(_x + _w),(_y + _h)]; //-- Front Right    ^^ switched
	_center = [(_x + (_w / 2)),(_y + (_h / 2))]; //-- center 
	_add = [(_x + (_w / 2)),((_y + _h) + 0.1)]; //-- additional polygon point (towards player) 
	
	//-- convert positions to worldpositions
	_sP1 = screenToWorld _sP1;
	_sP2 = screenToWorld _sP2;
	_sP3 = screenToWorld _sP3;
	_sP4 = screenToWorld _sP4;
	_center = screenToWorld _center;
	_add = screenToWorld _add;
	
	//-- if the rectangle was started 'in the sky', the area must be reduced 
	_fnc = {
		_p = _this;
		if ((_p distance2D player) > viewDistance) then {
			_dir = [player,_p] call BIS_fnc_dirTo;
			_p = [player,viewDistance,_dir] call BIS_fnc_RelPos;
		};
		_p
	};
	//-- adjust position if need be
	_sP1 = _sP1 call _fnc;
	_sP2 = _sP2 call _fnc;
	_sP3 = _sP3 call _fnc;
	_sP4 = _sP4 call _fnc;
	_center = _center call _fnc;
	_add = _add call _fnc;
		
	//-- create 3D-Polygon and add data to polygon-array
	//-- create main markerAlpha
	//_mainMark = "";
	A3C_SUP_MAIN_POLY = [[_center,""],[_sP1,_sP2,_sP3,_sP4]]; // _add (after 3)	
	_dirTo = [(vehicle player),_center] call BIS_fnc_dirTo;
	//_mainMark setMarkerDirLocal _dirTo;
	A3C_SUP_MAIN_POLY = [[_center,""]] + ( [(A3C_SUP_MAIN_POLY select 1),_dirTo,"SUPPRESSION",true,A3C_SUPPRESSION_UNITS_SQ_TEMP] call A3C_SUP_CREATE_POLY); //-- no ID needed because it's local and the drawn and unusual poly should not be movable

	//-- blinking effect to visualize given order
	for "_i" from 1 to 2 do {
		_ctrl ctrlShow false;
		sleep 0.05;
		_ctrl ctrlShow true;
		sleep 0.05;
	};
	
	//-- close the display
	[] call A3C_SUP_CloseDisplay; //(findDisplay 100070) closeDisplay 0;	
	//-- spawn Suppression
	{
		_x setvariable ["A3C_UNIT_POLYS",[A3C_SUP_MAIN_POLY],true];
	} foreach A3C_SUPPRESSION_UNITS_SQ_TEMP;
	[A3C_SUPPRESSION_UNITS_SQ_TEMP,A3C_SUP_MAIN_POLY,'SUPPRESSION',true] spawn A3C_POLY_ACTION_ON;					
};




A3C_Replace_Unit1 = {
	//-- purpose: completely replace a soldier that is in STOP mode
	params ["_unit"];
	if !(_unit == driver vehicle _unit) exitWith {};
	
	_unitArray = +(profileNamespace getvariable "A3C_GROUPUNITS");
	_index = [_unit, _unitArray] call MCSS_fnc_GetArrayIndex;
	
	
	_hasParent = !isNull objectParent _unit;
	_vehicle = vehicle _unit;
	
	_type = typeOf _unit;
	_name = name _unit;
	_weapons = weapons _unit;
	_primItems = primaryWeaponItems _unit;
	_secItems = primaryWeaponItems _unit;
	_primMag = (primaryWeaponMagazine _unit);
	_mags = (magazines _unit) + _primMag + (handgunMagazine _unit); //(secondaryWeaponMagazine _unit) +
	_secMag = (secondaryWeaponMagazine _unit);
	if (count _primMag > 1) then {{_secMag pushBack _x} foreach (_primMag - [_primMag select 0])};
	//if (count _secMag > 0) then {_secMag = _secMag select 0} else {_secMag = ""};
	//systemchat str _mags;
	_items = items _unit;
	_uniform = uniform _unit;
	_vest = vest _unit;
	_goggles = goggles _unit;
	_headGear = headGear _unit;
	_backPack = backPack _unit;
	_dir = getDir _unit;
	_anim = animationState _unit;
	_face = face _unit;
	_pos = getPosASL _unit;
	_stance = stance _unit;
	_face = face _unit;
	_VVN = vehicleVarname _unit;
	_group = group _unit;
	_vehicle = vehicle _unit;
	_teamColor = if (player == cameraOn) then {assignedTeam _unit} else {_unit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};;
	_plot = _unit getVariable ["A3C_PLOT",[]];
	_wpI = _unit getVariable ["A3C_CURRENTWAYPOINT_INDEX",1];
	_A3C_FORMATION_INDEX = _unit getvariable ["A3C_FORMATION_INDEX", [_unit] call A3C_GETUNITINDEX];
	_A3C_VVNI = _unit getvariable ["A3C_VVNI",A3C_VARNAME_INDEX];

	_loadOut = getUnitLoadOut _unit;
	//-- to do: add checks for correct formation index number
	deleteVehicle _unit;
	_newUnit = objNull;

	
	_logics = [];
	for "_i" from 1 to (_A3C_FORMATION_INDEX -2) do {
		_un = _unitArray select _i;
		if !(_un in units player) then {
			_gL = (group player) createUnit ["LOGIC", [0,0,0], [], 0, ""];
			_logics pushbackUnique _gL;
		};
	};
	
	
	
	call compile format ["%1 = _group  createUnit [""%3"", %4, [], 0, ""FORM""];  _newUnit =%1;", parseText _vvn,_group,_type,[0,0,0]];
	{deletevehicle _x} foreach _logics;
	removeAllWeapons _newUnit;
	//_newUnit setUnitLoadout _loadout;
	_newUnit forceAddUniform _uniform;
	_newUnit addVest _vest;
	_newUnit addBackPack _backPack;
	clearMagazineCargo unitBackpack _newUnit;


	{
	    if ( isClass (configFile >> "CFGitems" >> _x)) then {
	        _newUnit addItem _x;
	    };
	    if ( isClass (configFile >> "CFGweapons" >> _x)) then {
	        _newUnit addWeapon _x;
	    };
	    if ( isClass (configFile >> "CFGmagazines" >> _x)) then {
	        _newUnit addMagazine _x; //[_x,1];
	    };
	} foreach (_mags + _items);
	[_newUnit,_secMag] spawn {
		params ["_newUnit","_secMag"];
		sleep 1;
		//if (backPack _newUnit == '') then {
			{_newUnit addMagazine _x} foreach _secMag;
		//} else {
		//	_newUnit addItemToBackpack _secMag;
		//};
	};
	{
	    
	    if ( isClass (configFile >> "CFGweapons" >> _x)) then {
	        _newUnit addWeapon _x;
	    };
	} foreach _weapons;
	if (_hasParent) then {
		_newUnit moveInDriver _vehicle;
	} else {
		_newUnit setDir _dir;
		_newUnit setPosASL _pos;
		_newUnit switchMove _anim;
	};
	_newUnit setFace _face;

	_newUnit setFace _face;
	_newUnit addHeadGear _headGear;


	switch (_stance) do {
		case ("STAND") : {_newUnit setUnitPos "UP"};
		case ("CROUCH") : {_newUnit setUnitPos "MIDDLE"};
		case ("PRONE") : {_newUnit setUnitPos "DOWN"};
	};

	[_newUnit,0] call A3C_UNIT_INIT;
	_newUnit setvariable ["A3C_FORMATION_INDEX", _A3C_FORMATION_INDEX, true];
	_newUnit setvariable ["A3C_VVNI",_A3C_VVNI,true];
	_newUnit setVariable ["A3C_PLOT",_plot,true];
	_newUnit setVariable ["A3C_CURRENTWAYPOINT_INDEX",_wpI,false];
	{_newUnit addPrimaryWeaponItem _x} foreach _primItems;
	{_newUnit addSecondaryWeaponItem _x} foreach _secItems;
	
	_unitArray set [_index,_newUnit];

	_newUnit assignTeam _teamColor;
	_newUnit setVariable ["A3C_ASSIGNEDTEAM",_teamColor];

	_nameStringArray = _name splitString " ";
	_firstName = _nameStringArray deleteAt 0;
	_lastName = _nameStringArray joinstring " ";
	_name = [_firstName + " " + _lastName,_firstName,_lastName];
	
	_inv = (magazines _newUnit) + (primaryWeaponMagazine _newUnit) + (secondaryWeaponMagazine _newUnit) + (handgunMagazine _newUnit);
	//systemchat str [count _mags,count _inv];

	profileNamespace setvariable ["A3C_GROUPUNITS",_unitArray];
	[_newUnit,_goggles,_vvn,_name] spawn {
		params ["_unit","_goggles","_vvn","_name"];
		_unit addGoggles _goggles;
		_unit setVehicleVarname _VVN;
		[_unit,_name] remoteExec ["setName",0];
	};
	_newUnit
};




A3C_Replace_Unit = {
	//-- purpose: completely replace a soldier that is in STOP mode
	params ["_unit"];
	if !(_unit == driver vehicle _unit) exitWith {};
	
	_unitArray = +(profileNamespace getvariable "A3C_GROUPUNITS");
	_index = [_unit, _unitArray] call MCSS_fnc_GetArrayIndex;
	
	
	_hasParent = !isNull objectParent _unit;
	_vehicle = vehicle _unit;
	
	//-- retrieve unit data
	_type = typeOf _unit;
	_name = name _unit;
	_dir = getDir _unit;
	_anim = animationState _unit;
	_face = face _unit;
	_pos = getPosASL _unit;
	_stance = stance _unit;
	_face = face _unit;
	_VVN = vehicleVarname _unit;
	_group = group _unit;
	_vehicle = vehicle _unit;
	_teamColor = if (player == cameraOn) then {assignedTeam _unit} else {_unit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};;
	_fatigueAndStamina = [getFatigue _unit, getStamina _unit];
	_isStaminaEnabled = isStaminaEnabled _unit;
	_destination = expectedDestination _unit;
	_plot = _unit getVariable ["A3C_PLOT",[]];
	_wpI = _unit getVariable ["A3C_CURRENTWAYPOINT_INDEX",1];
	_A3C_FORMATION_INDEX = _unit getvariable ["A3C_FORMATION_INDEX", [_unit] call A3C_GETUNITINDEX];
	_A3C_VVNI = _unit getvariable ["A3C_VVNI",A3C_VARNAME_INDEX];
	_inHud = _unit in A3C_HUD_UNITS;
	_rdIIndex = [_unit,A3C_RD_UNITS] call MCSS_fnc_GetArrayIndex;
	_tabletIndex = [_unit,A3C_SELECTED_UNITS] call MCSS_fnc_GetArrayIndex;
	

	

	_damage = [];
	{
		_damage pushBack [_x,_unit getHitPointDamage _x];
	} foreach A3C_HUMAN_HITPOINTS;
	
	_loadOut = getUnitLoadOut _unit;
	_allVariables = [];
	{
		_allVariables pushBack [_x,_unit getVariable _x];
	} foreach allVariables _unit;
	

	//-- delete unit, spawn logics until unit's formationIndex is reached, then spawn new unit and delete logics
	deleteVehicle _unit;
	_newUnit = objNull;
	_logics = [];
	for "_i" from 1 to (_A3C_FORMATION_INDEX -2) do {
		_un = _unitArray select _i;
		if !(_un in units player) then {
			_gL = (group player) createUnit ["LOGIC", [0,0,0], [], 0, ""];
			_logics pushbackUnique _gL;
		};
	};
	call compile format ["%1 = _group  createUnit [""%3"", %4, [], 0, ""FORM""];  _newUnit =%1;", parseText _vvn,_group,_type,[0,0,0]];
	{deletevehicle _x} foreach _logics;
	
	//-- reEstablish Damage
	for "_i" from 0 to 9 do {
		_hitPointArray = _damage select _i;
		_newUnit setHitPointDamage [_hitPointArray select 0, _hitPointArray select 1];
	};

	if (_hasParent) then {
		_newUnit moveInDriver _vehicle;
	} else {
		_newUnit setDir _dir;
		_newUnit setPosASL _pos;
		_newUnit switchMove _anim;
	};
	
	//-- reset fatigue
	_newUnit setFatigue (_fatigueAndStamina select 0);
	_newUnit setStamina (_fatigueAndStamina select 1);
	_newUnit enableStamina _isStaminaEnabled;
	if (_inHud) then {
		A3C_HUD_UNITS pushBackUnique _newUnit;
		
	};
	if !(_rdIIndex == -1) then {
		A3C_RD_UNITS set [_rdIIndex,_newUnit];
	};
	if !(_tabletIndex == -1) then {
		A3C_SELECTED_UNITS set [_tabletIndex,_newUnit];
	};


	
	switch (_stance) do {
		case ("STAND") : {_newUnit setUnitPos "UP"};
		case ("CROUCH") : {_newUnit setUnitPos "MIDDLE"};
		case ("PRONE") : {_newUnit setUnitPos "DOWN"};
	};
	[_newUnit,0] call A3C_UNIT_INIT;
	//-- reset variables
	{
		_bool = if ((_x select 0) in ["A3C_unit_polys","A3C_poly_active"]) then {true} else {false};
		_newUnit setVariable [_x select 0,_x select 1,_bool];
	} foreach _allVariables;



	
	_unitArray set [_index,_newUnit];

	_newUnit assignTeam _teamColor;
	_newUnit setVariable ["A3C_ASSIGNEDTEAM",_teamColor];

	_nameStringArray = _name splitString " ";
	_firstName = _nameStringArray deleteAt 0;
	_lastName = _nameStringArray joinstring " ";
	_name = [_firstName + " " + _lastName,_firstName,_lastName];
	

	profileNamespace setvariable ["A3C_GROUPUNITS",_unitArray];
	[_newUnit,_vvn,_name,_loadout,_face,_destination] spawn {
		params ["_unit","_vvn","_name","_loadout","_face","_destination"];
		_unit setVehicleVarname _VVN;
		_unit setName _name;		
		_unit setUnitLoadout _loadOUt;
		_unit setFace _face;
		_unit setDestination _destination;
	};
	_newUnit
};



/*
A3C_MOVE_SUPPRESSION_INDICATOR = {
	params ["_indicator"];
	private ["_pos"];
	_objectCollision = [];
	_pos = [];

	while {!(isnull _indicator)} do {
		A3C_SUPPRESSIONHEIGHT = A3C_SUPPRESSIONHEIGHT max 0;
		_pos = [player,_indicator] call MCSS_fnc_posIntersect;
		_indicatorHeight = (((ASLtoATL _pos) select 2) + A3C_SUPPRESSIONHEIGHT) max 0;
		_indicatorPos = ATLtoASL [(_pos select 0),(_pos select 1),_indicatorHeight];
		_indicator setposASL _indicatorPos;
		_dir = [vehicle player ,_indicator] call bis_fnc_dirto;
		if ((typeName _dir) == "SCALAR") then {
			_indicator setdir _dir;
		};
		sleep 0.01;
	};	
};

MCSS_fnc_Get_Radian_Z = {
	params ["_unit"];
	private ["_return","_vehicle","_dir","_vectorDirZ","_alpha"];
	_vehicle = vehicle _unit;
	_dir = getDir _vehicle;

	_vectorDirZ = 0;
	//if (isNull objectParent _unit) then {
	//	_vectorDirZ = (eyeDirection _unit) select 2;
	//} else {
	//};
	
	
	
	
	if (_unit == player) then {
		if (isNull objectParent _unit) then {
			//-- player is on foot - cameraViewDirection always works, except if looking down sights
			if (cameraview in ["INTERNAL","EXTERNAL"]) then { 
				_vectorDirZ = (getCameraViewDirection player) select 2;
			};
			//-- player is looking down weapon sights
			if (cameraview == "GUNNER") then { 
				_vectorDirZ = (player weaponDirection (currentWeapon player)) select 2;
			};
		} else {
			//-- default driver / cargo / 3rd person
			_vectorDirZ = (getCameraViewDirection player) select 2;
			//-- specifics: Gunner and Commander, Internal and Gunner view ('Gunner' refers to looking down sights)
			if (player == gunner _vehicle) then {
				if (cameraview == "GUNNER") then {
					_vectorDirZ = (_vehicle weapondirection currentweapon _vehicle) select 2;
				};
				//if (cameraview == "INTERNAL") then { //-- NOTE! Gunner needs extra head movement style checks. Commander has the screen so we use that for INTERNAL
				//	_vectorDirZ = _vehicle animationphase "MainGun";
				//};
			};
			if (player == commander _vehicle) then {
				if (cameraview in ["INTERNAL","GUNNER"]) then { //== NOTE: Commander has the little screen, so we override the regular cameraDirection
					_vectorDirZ = _vehicle animationphase "ObsGun";
				};
			};

		};
		
	} else {
		if (isNull objectParent _unit) then {
			if (weaponLowered _unit) then {
				_vectorDirZ = (eyeDirection _unit) select 2;
			} else {
				_vectorDirZ = (_unit weaponDirection (currentWeapon _unit)) select 2;
			};
		};
	};
	//_alpha = tan _vectorDirZ;
	_vectorDirZ
};
//[] spawn {
//	TP1 = [0,0,0];
//	TP2 = [0,0,0];
//	sleep 2;
//	addMissionEventHandler ["Draw3D", {
//		drawLine3D [TP1, TP2, [1,0,0,1]];
//		drawLine3D [TP1, TP2, [1,0,0,1]];
//		drawLine3D [TP1, TP2, [1,0,0,1]];
//	}];
//};




MCSS_fnc_posIntersectW = {
	_refPos1 = ATLtoASL (positionCameraToWorld [0,0,0]);

	comment "let's get a very long line pointing in the direction of the barrel";
	_weaponDirection = ( (vehicle player) weaponDirection (currentWeapon (vehicle player)) );
	_weaponDirection = _weaponDirection vectorMultiply 1000;

	comment "Now we need to put that vector line on a proper starting point, maybe should be the memory point of the barrel end.";
	private _barrelEnd = (vehicle player) selectionPosition "konec hlavne";
	comment "Make sure to use ASL";
	_barrelEnd = player modelToWorldWorld _barrelEnd;
	_vectorPoint = _barrelEnd vectorAdd _weaponDirection;


	_interSectList = lineIntersectsSurfaces [_refPos1, _vectorPoint, player, vehicle player, true, 1, "GEOM", "NONE", true];
	 ((_interSectList select 0) select 0);
};

//-- ball setPos (player modelToWorldWorld (vehicle player selectionPosition _x));

MCSS_fnc_posIntersect = {
	private ["_unit","_ignore","_alpha","_refPos1","_refPos2","_dist","_height","_objectCollision","_pos","_ob"];
	_unit = _this select 0;
	_ignore = _this select 1;

	//-- _refpos1: origin / player's cameraview
	_refPos1 = ATLtoASL (positionCameraToWorld [0,0,0]);
	_unitHeightASL = _refPos1 select 2;
	
	//-- refPos2: worldposition center screen unless specified (@woof: not the case here)
	_refPos2orig = if (count _this > 2) then {_this select 2} else {((screentoworld [0.5,0.5]) select [0,2]) + [0]};
	_refPos2orig = ATLtoASL _refPos2orig;
	_refPos2origZ = _refPos2orig select 2;
	_refPos2 = +(_refPos2Orig);
	
	_refDist = _refPos1 distance2d _refpos2;
	_refRadian = [_unit] call MCSS_fnc_Get_Radian_Z;
	_refHeight = (_refPos1 select 2) + (_refDist * (tan (deg _refRadian)));  
	
	
	_refPos2 set [2,_refHeight];
	if (player == commander vehicle player) then {
		if (_refPos2origZ > 0) then {
			_refPos2 = _refPos2orig; //-- weak workaround because animationPhase does not work correctly
		};
	};


	_objectCollision = (lineintersectsSurfaces [_refPos1,_refPos2,_ignore, (vehicle _unit), true]); //([_unit] call MCSS_fnc_Switch_Eyepos)
	if (count _objectCollision == 0) then {
		_objectCollision = lineintersectsSurfaces [_refPos1, _refPos2,_ignore,(vehicle _unit)]; //([_unit] call MCSS_fnc_Switch_Eyepos)
	};

	//hintsilent str  [_refHeight,round _unitHeightASL, round _refPos2origZ];
	_pos = [0,0,0];
	if ((count _objectCollision) > 0) then {
		_pos = ((_objectCollision select 0) select 0);
		A3C_SNAP_OBJECT = ((_objectCollision select 0) select 2);
	} else {
		A3C_SNAP_OBJECT = objnull;
		_pos =  ATLtoASL (screenToWorld [0.5,0.5]); //~~ note: this fnc is only compatible with player-entities
	};
	_pos
};	

MCSS_fnc_posIntersect1 = {
	private ["_unit","_ignore","_alpha","_refPos1","_refPos2","_dist","_height","_objectCollision","_pos","_ob"];
	_unit = _this select 0;
	_ignore = _this select 1;
	_alpha = 0;
	_body = 0;
	_turretDir = 0;
	_aim = 0;
	if (!isNull objectParent _unit) then {
		_Body = GetDir (vehicle _unit);
		if (_unit == driver vehicle _unit) then {
			_alpha = _body;
		} else {
			_alpha = _body;
			//_alpha = _body - _turretDir;
		};
		if (_unit == gunner vehicle _unit) then {
			//_turretDir = Deg ((vehicle _unit) AnimationPhase "mainturret");
			_turretDir =  ((vehicle _unit) AnimationPhase "maingun");
			_alpha = atan _turretDir;
		};
		if (_unit == commander vehicle _unit) then {
			//_turretDir = Deg ((vehicle _unit) AnimationPhase "obsturret");
			_turretDir =  ((vehicle _unit) AnimationPhase "obsgun");
			_alpha = atan _turretDir;
		};
		
		//if (_alpha > 360) then {_alpha = _alpha - 360};
	} else {
		_alpha = atan ((_unit weapondirection (currentweapon _unit) ) select 2) ;
	};

	_refPos1 =  (positionCameraToWorld [0,0,0]);
	_refPos1 = ATLtoASL _refPos1;
	
	_refPos2Orig = if (count _this > 2) then {_this select 2} else {(screentoworld [0.5,0.5])};
	_refPos2 = +(_refPos2Orig);
	_refDist =  (_refPos1 distance2d _refPos2);
	_refRadian = [_unit] call MCSS_fnc_Get_Radian_Z;
	_refHeight = (_refPos1 select 2) + (_refDist * _refRadian);
	//_unitASL = getPosASL (vehicle _unit);
	_unitHeightASL = _refPos1 select 2;
	//_unitHeightASL = (_unitASL select 2);
	_refpos2OrigAslZ = (ATLtoASL _refPos2Orig) select 2;
	//if ((_refPos1 select 2) >= _refpos2OrigAslZ) then {
	//	_refPos2 set [2,_refHeight + _unitHeightASL]; //-- no longer need to convert to ASL?
	//} else {
		_refPos2 set [2,_refpos2OrigAslZ];
	//};
	//_refPos2 set [2,_refHeight];

	_objectCollision = (lineintersectsSurfaces [_refPos1,_refPos2,_ignore, (vehicle _unit), true]); //([_unit] call MCSS_fnc_Switch_Eyepos)
	if (count _objectCollision == 0) then {
		_objectCollision = lineintersectsSurfaces [_refPos1, _refPos2,_ignore,(vehicle _unit)]; //([_unit] call MCSS_fnc_Switch_Eyepos)
	};

	hintsilent str  [_refHeight,_objectCollision];
	_pos = [0,0,0];
	if ((count _objectCollision) > 0) then {
		_pos = ((_objectCollision select 0) select 0);
		//hintsilent str _pos;
		A3C_SNAP_OBJECT = ((_objectCollision select 0) select 2);
	} else {
		A3C_SNAP_OBJECT = objnull;
		_pos =  ATLtoASL (screenToWorld [0.5,0.5]); //~~ note: this fnc is only compatible with player-entities
	};
	_pos
};
*/