
if (isDedicated) exitwith {};

/////////////////////////////   DRAW FNCS (MOVE TO OWN SCRIPT WITH UI FNCS)    ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////  

A3C_UI_MAP_DRAW_MACRO_VEHICON = {
	params ["_ctrl","_vehicle","_size","_color","_text"];
	private _iconType = (gettext(configfile >> "CfgVehicles" >> (typeof _vehicle) >> "Icon"));
	private _iconPos = getPos _vehicle;
	_text = if (!isNil '_text') then {_text} else {""};
	_ctrl drawIcon
	[
		"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
		[1,1,1,_color select 3],
		_iconPos,
		_size * 1.5,
		_size * 1.5,
		0
	];
	_ctrl drawIcon
	[
		_iconType,
		_color, //, //[0.8,0.6,0,0.6],
		_iconPos,
		_size,
		_size,
		0,
		_text
	];
};


A3C_UI_MAP_DRAW_THICC_LINE = {
	params ["_ctrl","_root","_wPos","_thickness","_color"];
	_dir = _root getDir _wpos;
	_selPoses =
	[
		_root getPos [_thickness,_dir - 90],
		_wPos getPos [_thickness,_dir - 90],
		_wPos getPos [_thickness,_dir + 90],
		_root getPos [_thickness,_dir + 90]
	];
	
	_ctrl drawTriangle
	[
		[
			_selPoses select 0,
			_selPoses select 1,
			_selPoses select 2,
			_selPoses select 2,
			_selPoses select 3,
			_selPoses select 0
		],
		_color,
		"#(rgb,1,1,1)color(1,1,1,1)"
	];
};

A3C_UI_MAP_DRAW_Polyframe = {
	params ["_ctrl","_positions","_thickness","_color"];
	//hint str _this;
	_dotLength = 5;
	_dotSpacing = 5;
	{
		_pos1 = _positions select (_x select 0);
		_pos2 = _positions select (_x select 1);
		_dir = _pos1 getDir _pos2;
		_distance = _pos1 distance2D _pos2;
		_dotAmount = _distance / (_dotLength + _dotSpacing);
		_rootPos = +(_pos1);
		for "_i" from 1 to _dotAmount do {
			_endPos = _rootPos getPos [_dotLength,_dir];
			_selPoses =
			[
				_rootPos getPos [_thickness,_dir - 90],
				_endPos getPos [_thickness,_dir - 90],
				_endPos getPos [_thickness,_dir + 90],
				_rootPos getPos [_thickness,_dir + 90]
			];
			
			_ctrl drawTriangle
			[
				[
					_selPoses select 0,
					_selPoses select 1,
					_selPoses select 2,
					_selPoses select 2,
					_selPoses select 3,
					_selPoses select 0
				],
				_color,
				"#(rgb,1,1,1)color(1,1,1,1)"
			];
			_rootPos = _rootPos getPos [_dotLength + _dotSpacing,_dir];
		};
	} foreach [
		[0,1],
		[1,2],
		[2,3],
		[3,0]
	];
};

/////////////////////////////   UI FNCS (MOVE TO OWN SCRIPT)    ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////   
A3C_UI_MAP_Overlay_ResizeTeamColorsXWH = {
	params ["_a3c_dsp","_mode"];
	

	//-- DYNAMIC TEAMCOLOR BOXES

	
	if (_mode == "HC") exitWith {}; //~~ TEMPORARY: Exit for HC after removing teamcolor Boxes. TO DO: Align HC Teamcolors with Default-Colors and add funtionality


	//-- Hardcoded Values (from .hpp)
	_ctrlX = if (_a3c_dsp == 100040) then {0} else {A3C_MAP_OVERLAY_GAMEUI_TREEX}; 
	
	_ctrlH = 0.0110018 * safezoneH; //-- HARDCODED h value of first teamcolor box

	_totalW = (ctrlPosition (findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL)) select 2; 

	_gapW = A3C_MAP_GAMEUI_PADDING_Y / 2; 

	_teamColors = [];
	_grunts = ((units player) - [player]);
	if (_mode == "HC") then {

	} else {
		{
			_col = _x;
			if ({private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]}; _assignedTeam == _col} count _grunts > 0) then {
				_teamColors pushBack _col;
			};
		} foreach ["RED","GREEN","BLUE","YELLOW","MAIN"];
		if (count _teamColors > 1) then {
			_teamColors pushBack "PURPLE";
		};
	};

	if (count _teamColors == 0) exitWith {};
	
	_gapAmount = (count _teamColors) - 1;
	_dynamicButtonW = (_totalW - (_gapAmount * _gapW)) / (count _teamColors);


	{
		_color = _x;
		_btnCtrls = switch (_color) do {
			case ("RED") : {[1000,1001]};
			case ("GREEN") : {[1002,1003]};
			case ("BLUE") : {[1004,1005]};
			case ("YELLOW") : {[1006,1007]};
			case ("MAIN") : {[1008,1009]};
			case ("PURPLE") : {[1010,1011]};
		};
		{
			_ctrl = (findDisplay _a3c_dsp displayCtrl _x);
			_ctrlY = if (_a3c_dsp == 100040) then {(ctrlPosition _ctrl) select 1} else {safeZoneY + safezoneH};
			_ctrl ctrlSetPosition
			[
				_ctrlX,
				_ctrlY,
				_dynamicButtonW,
				_ctrlH
			];
			_ctrl ctrlCommit 0;
		} foreach _btnCtrls;
		_ctrlX = _ctrlX + _dynamicButtonW + _gapW;
	} foreach _teamColors;
};






/////////////////////////////   MAP OVERLAY FNCS    ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////// 

A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls = {
	params ["_mode","_animTime"];
	private _doExit = false;
	if (_mode == "OPEN") then {
		if (A3C_UI_MAP_Overlay_VAR_isUnFolded) then {
			if (count A3C_SELECTED_UNITS == 0) then {
				A3C_UI_MAP_Overlay_VAR_isUnFolded = false;
			};
			_doExit = true;
		} else {
			A3C_UI_MAP_Overlay_VAR_isUnFolded = true;
		};
	} else {
		A3C_UI_MAP_Overlay_VAR_isUnFolded = false;
	};
	if (_doExit) exitWith {};

	private _settingsButtonsPairs =  //-- in reverse order
	[
		[8002,8003], //-- continue button
		[8000,8001], //-- hold button
		[7069,7070], //-- cancel data
		[7092,7041], //-- undo
		[7022,7007],  //-- condition
		[7066], //-- Spacing Input
		[7050,7051], //-- squad formations
		[7064,7065], //-- squad actions
		[7062,7063], //combatmode
		[7046,7047], //-- stance2
		[7048,7049], //-- wp-speed
		[7044,7045] //-- stance1
	];

	
	_padding = A3C_MAP_GAMEUI_PADDING_Y / 2;

	_newSettingsBGW = if (_mode == "OPEN") then {A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_EXPANDED} else {A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_COLLAPSED};
	
	_macroWidth = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W + _padding;
	_xPos = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X - _padding - _macroWidth;

	


	//-- animate buttons
	{
		{
			_btnCtrl = (findDisplay 100020 displayCtrl _x);
			
			_doShow = true;
			if (_mode == "OPEN") then {

				_btnCtrl ctrlSetPosition
				[
					_xPos,
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y + (A3C_MAP_GAMEUI_PADDING_Y),
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W,
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
				];
				
			} else {
				_doShow = false;
				_btnCtrl ctrlSetPosition
				[
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X,
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
					0,
					A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
				];
			};
			_btnCtrl ctrlCommit _animTime;
			[_btnCtrl,_animTime,_doShow] spawn {
				params ["_btnCtrl","_animTime","_doShow"];
				sleep _animTime;
				_btnCtrl ctrlShow _doShow;
			};
			//
		} foreach _x;
		sleep 0.0001;
		_xPos = _xPos - _macroWidth;	
	} foreach _settingsButtonsPairs;

	//-- EXECUTE / CANCEL buttons
	_xPos = (A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X - _padding) -  (11.5 * _macroWidth); //-- 11.5 is half a button offset to last button (CONTINUE)
	_buttonWidthFull = (3 * _macroWidth);
	{
		
		if (_foreachIndex > 0) then {
			_xPos = _xPos + (4 * _macroWidth);				
		};
		
		_btnCtrl = (findDisplay 100020 displayCtrl _x);
		_btnCtrl ctrlSetPosition
		[
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X,
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
			0,
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
		];
		if (_mode == "OPEN") then {

			_btnCtrl ctrlSetPosition
			[
				_xPos,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y + ((A3C_MAP_GAMEUI_PADDING_Y + A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H) * 1.25),
				_buttonWidthFull,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_COMMITBUTTON_H
			];
			
		};
		_btnCtrl ctrlCommit _animTime;
		sleep 0.0001;
	} foreach [7018,7019,7020];

	//-- animate BG frame WP SETTINGS
	{
		_settingsCtrl = (findDisplay 100020 displayCtrl _x);
		_settingsCtrl ctrlSetPosition
		[
			A3C_MAP_OVERLAY_GAMEUI_TREEX - _newSettingsBGW, //A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
			_newSettingsBGW,
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H
		];
		_settingsCtrl ctrlCommit _animTime;
	} foreach [10,11,13];
	if (_mode == "COLLAPSE") then {
		{
			(findDisplay 100020 displayCtrl _x) ctrlShow false;
		} foreach [A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2,A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
	};

};


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////






A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP = {
	params ["_mode"];
	
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
	_parent = findDisplay _a3c_dsp displayCtrl 8008;
	_text = findDisplay _a3c_dsp displayCtrl 800802;
	_listBox = findDisplay _a3c_dsp displayCtrl 800803;
	//if !(visibleMap) then {
	//};

	ctrlSetFocus _listBox;
	
	lbClear _listBox;
	ctrlSetFocus _listBox;
	private _ctrlShow = true;
	switch (_mode) do {

		case ("DELETE") : {
			// systemchat 'oioi';
			A3C_OBJECTSELECTOR_MODE = "DELETE";
			private _ref = A3C_SELECTED_HC_GROUPS_SETTINGS;
			_text ctrlSetText format ["REALLY DELETE %1 GROUP%2?",count _ref, if (count _ref <= 1) then {""} else {"S"}];

			{
				[_listBox, _x] call A3C_addLbEntry;
			} foreach ["YES","NO"];
		};

		case ("MULTIWAYPOINT") : {
			A3C_OBJECTSELECTOR_MODE = "MULTIWAYPOINT";
			private _ref = A3C_SELECTED_UNITS select {(driver (vehicle leader _x))  in units _x};
			_text ctrlSetText format ["GIVE WAYPOINT TO %1 GROUP%2",count _ref, if (count _ref <= 1) then {""} else {"S"}];

			{
				[_listBox, _x] call A3C_addLbEntry;
			} foreach ["YES","NO"];
		};
		case ("ARTY") : {

				hintSilent "";
				
				A3C_OBJECTSELECTOR_MODE = "ARTY_0";
				_text ctrlSetText "Ammo Within Range";

				MCSS_REMOTE_ARTILLERY_ARRAY = [];
				
				{
					private _units = units _x;
					{
						private _v = objectParent _x;

						private _cond = !isNull _v && {
							_x == gunner _v && {
								_artyAmmo = (getArtilleryAmmo [_v]) select {A3C_HC_FOCUS_ARTY_POS inRangeOfArtillery [[_v], _x]};
								count _artyAmmo > 0
							}
						};

						if (_cond) then {
							MCSS_REMOTE_ARTILLERY_ARRAY set [count MCSS_REMOTE_ARTILLERY_ARRAY,_v];
						};

					} foreach _units;
				} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

				private _shellDSPs = [true,true,A3C_HC_FOCUS_ARTY_POS] call A3C_getArtilleryAmmo;

				if (_shellDSPs isEqualTo []) then {
					_ctrlShow = false;
					hint "SELECTED POSITION IS OUT OF RANGE FOR ALL AMMO-TYPES";
					playsound "TacticalPing"
				} else {
					{
						[_listBox, _x select 0] call A3C_addLbEntry;
					} foreach _shellDSPs;

					[_parent,_listBox, count _shellDSPs] call A3C_OBJECTSEL_RESIZE;
					
				};
		};
		case ("A3C_CTRL_DET_SELECT") :{
			A3C_OBJECTSELECTOR_MODE = "CTRL_DET";
			_text ctrlSetText "Select Ammo Type";
			private _availableAmmo = [];
			private _targetVehicle = (A3C_TEMP_ACTION select 1) select 0;
			{
				_soldier = _x;
				{
					if (getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]) then {
						private _allowAdding = false;
						private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
						private _mineTrigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");
						if (_mineTrigger == "RemoteTrigger") then {
							_allowAdding = true;
						} else {
							if (isNull _targetVehicle) then {
								_allowAdding = true;
							};
						};
						if (_allowAdding) then {
							_availableAmmo pushBackUnique _x;
						};
					};
				} foreach magazines _x;
			} foreach A3C_SELECTED_UNITS;
			if (count _availableAmmo > 4) then {
				_parentPos = ctrlPosition _parent;
				_parentPos set [3,(_parentPos select 3) + (  ((count _availableAmmo) - 4)   * (0.0440051 * safezoneH) )];
				_parent ctrlSetPosition _parentPos;
				_parent ctrlCommit 0;
			};

			{
				private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
				[_listBox, _lbText] call A3C_addLbEntry;
			} foreach _availableAmmo;

		};
	};
	
	if (_ctrlShow) then {
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
	} else {
		with uiNamespace do {
			(findDisplay 100060) closeDisplay 0;
		};
	};
	
};







//------------------  I N T E R F A C E   O P E R A T I O N :   K E Y -   A N D   M O U S E   F U N C T I O N S   -------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------    Actions for UI-Eventhandlers      -------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------




A3C_UI_MAP_FNC_ResetMapClick = {
	params ["_mode"];
	if (_mode == 0) then {
		onMapSingleClick {
			
			_doOverWrite = false;
			if !(player == driver (vehicle player)) then {
				if (player == effectiveCommander (vehicle player)) then {
					if !(_shift) then {
						//systemchat 'hey1';
						_doOverWrite = true;
					};
				};
			};
			_doOverWrite
		};
	} else {
		//if (_mode == 1) then {
			onMapSingleClick {};
		//};
	};
};

A3C_UI_MAP_FNC_CloseMapOverlay = {
	params ["_display"];
	(findDisplay _display) closeDisplay 0;
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	[1] call A3C_Btn_fnc_Cancel;
	A3C_MAP_CommandMode = "INF"; A3C_SELECTED_UNITS = [];
	A3C_SELECTED_UNITS = [];
	{_x setvariable ["A3C_PLOT_TEMP",[],true];} foreach units group player;
	[1] call A3C_UI_MAP_FNC_ResetMapClick;
};


A3C_UI_MAP_FNC_CloseSyncCircleMenu = {
	//-- closes the little circle menu to select sync/board when syncing waypoints
	params ["_a3c_dsp","_ctrlID"];
	{
		{
			ctrlDelete (findDisplay _a3c_dsp displayCtrl _x);
		} foreach _x;
	} foreach A3C_UI_MAP_CircleMenu_CTRLS;
	A3C_UI_MAP_isCircleMenu = false;
};







A3C_UI_MAP_FNC_SYNC_LoadGroupInVehicle = {
	private ["_wp","_syncWps"];

	_wp = [A3C_UI_MAP_SYNC_HOSTGROUP,A3C_UI_MAP_SYNC_HostWPI];

	_syncWps = synchronizedWaypoints _wp;
	A3C_UI_MAP_SYNC_HOSTGROUP setVariable ["A3C_HC_SYNCWPS",_syncWps,true]; //~~ necessary?

	private _precond = [((waypointStatements _wp) select 0), waypointTimeout _wp] call A3C_HC_getConditionFromStatements;
	_wp setWayPointType "SCRIPTED";
	_wp setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_LoadGroupInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
	_wp setWaypointTimeout [0,0,0];
	
	{
		_precond = [((waypointStatements _x) select 0), waypointTimeout _x] call A3C_HC_getConditionFromStatements;
		_x setWayPointType "SCRIPTED";
		_x setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
		_x setWaypointTimeout [0,0,0];
	} foreach _syncWps;
};


A3C_UI_MAP_FNC_SYNC_LoadVehicleInVehicle = {
	private ["_wp","_syncWps"];

	_wp = [A3C_UI_MAP_SYNC_HOSTGROUP,A3C_UI_MAP_SYNC_HostWPI];
	_syncWps = synchronizedWaypoints _wp;
	A3C_UI_MAP_SYNC_HOSTGROUP setVariable ["A3C_HC_SYNCWPS",_syncWps,true]; //~~ necessary?

	private _precond = [((waypointStatements _wp) select 0), waypointTimeout _wp] call A3C_HC_getConditionFromStatements;
	_wp setWayPointType "SCRIPTED";
	_wp setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_LoadVehicleInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
	_wp setWaypointTimeout [0,0,0];
	{
		_precond = [((waypointStatements _x) select 0), waypointTimeout _x] call A3C_HC_getConditionFromStatements;
		_x setWayPointType "SCRIPTED";
		_x setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetVehicleInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
		_x setWaypointTimeout [0,0,0];
	} foreach _syncWps;
};








A3C_UNITSEL_REFRESH_UI = {

	// if (true) exitWith {};

	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
	
	private _commandMode = if (_a3c_dsp == 100040) then {
		A3C_CURRENT_COMMAND_LEVEL
	} else {
		if (A3C_MAP_CommandMode == "HC") then {
			"HIGHCOMMAND"
		} else {
			"SQUAD"
		};
	};
	
	//-- security:
	if (_commandMode == "SQUAD") then {
		A3C_SELECTED_UNITS = A3C_SELECTED_UNITS select {typename _x == "OBJECT"};
	} else {
		A3C_SELECTED_UNITS = A3C_SELECTED_UNITS select {typename _x == "GROUP"};
	};

	if (_a3c_dsp == 100040) then {
		private _radialHoverReal = A3C_RADIAL_HOVER;
		A3C_RADIAL_HOVER = true;
		if (_commandMode == "SQUAD") then {
			//-- radial squad

			if ("act" in tolower A3C_RADIALMODE) then {	
				BV_ACT = 0;
				["ACTIONS",-1] call A3C_RADIAL_BTN_FNC_RING_INNER;
			};



			//-- Medical controls opened: reset Listbox entries and medical data  uuu
			if (BV_MEDICAL == 1) then {
				["MEDICAL"] call A3C_LABEL_LB;
			};
			if (A3C_LBR_1 == "REARM") then {
				A3C_ReArm_options = [];
				[] call A3C_ReArm_OpenUI;
			};
			

			if (A3C_RADIALMODE == "VEHS") then {
				[A3C_RD_UNITS] call A3C_FINDVEHS;
			};
			[] call A3C_BTN_REINIT;	
		} else {
			//-- radial highCommand
			if ("act" in tolower A3C_RADIALMODE) then {
				["ROE",-1,false,true] call A3C_RADIAL_BTN_FNC_RING_INNER;
				//A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;
			};
			//if (count A3C_RD_UNITS == 1) then {
				[] call A3C_UI_SHARED_createDashBoard;
			//};
		};
		A3C_RADIAL_HOVER = _radialHoverReal;
	} else {
		if (_commandMode == "SQUAD") then {
			//-- map/table - squad
			_mode = "COLLAPSE";
			if (count A3C_SELECTED_UNITS > 0) then {
				_mode = "OPEN";
				// private _vehicle = if ()
				private _infModeTo = if (vehicle (A3C_SELECTED_UNITS select 0) isKindOf "AIR") then {"AIR"} else {"INF"};
				[_infModeTo] call A3C_UI_MAP_REFRESH_BARCONTROLS;
			};
			[_mode,0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;

			
		} else {
			//-- map/tablet - high command
			["COLLAPSE",0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
		};

	};
};




A3C_Adjust_Poly_Edge = {

	//-- Adjusts the edge markers of a polygon
	private _data = _this;
	private _sx = _data select 1;
	private _sy = _data select 2;

	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	private _map1 = if (visibleMap) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	private _sPos = (_map1 posscreentoworld [_sx,_sy]);
	{
		private ["_u","_va"];
		_u =_x;
		_va = (_u getVariable ["A3C_UNIT_POLYS",[]]);
		{
			if ((_x select 0) select 1 == (A3C_MovedItem_ID select 0)) exitWith {
				private _poses = _x select 1;
				_poses set [(A3C_MovedItem_ID select 1),_sPos]; //-- switch polygon-edgepos with mouse-dragpos
				_u setVariable ["A3C_UNIT_POLYS",_va,true];
			};
		} foreach _va;
	} foreach (A3C_HC_getAllGroups_Player_Current + (units player - [player]));
};

A3C_ADJUST_POLY = {

	//---- Function is used with different _mode valuse to either move (0), resize (1) or rotate (2) ----


	private ["_unit","_polyID","_sPos","_mode","_var"];
	_unit = _this select 0;
	_polyID = _this select 1;
	_sPos = _this select 2;
	_mode = _this select 3; //-- 0: Normal | 1: CTRL | 2: ALT
	_rotation = if (count _this > 4) then {_this select 4} else {0}; //-- rotation
	_var = _unit getvariable ["A3C_UNIT_POLYS",[]];

	//-- when rotating,  _sPos is reset to poly-center and determine rotation
	//systemchat str _polyID;
	if (_mode == 2) then {
		{
			if (_polyID == (_x select 0) select 1) exitWith {
				_center = (_x select 0) select 0;
				_rotation = ([_center,_sPos] call BIS_fnc_dirto); //-- rotation is determined via direction from center to mousePosition
				_sPos = _center; //-- reset _sPos to keep the poly in place
			};
		} foreach A3C_ALL_POLYS;
	};

	{
		if !(typename _x == "ARRAY") then {
			_var = _var - [_x];
		};
	} foreach _var;

	{
		private ["_p","_dir","_wpMarkers","_wpPoses","_mainPos"];
		_p = _x;
		_mainPos = (_p select 0) select 0;
		_dir = if (count _p > 3) then {_p select 3} else {0};
		if (_polyID in (_p select 0)) then {
			//-- fetch poly features
			_wpPoses = _p select 1;
			_wpMarkers = _p select 2;
			private _addAngle = if (_mode == 2) then {_rotation - _dir} else {0};
			_p1 =
			[
				(_wpPoses select 0), //-- edgePosition
				_mainPos distance2D (_wpPoses select 0), //-- distance from center
				([_mainPos, (_wpPoses select 0)] call BIS_fnc_dirTo) + _addAngle //-- direction from center plus flexible rotation value
			];
			_p2 =
			[
				(_wpPoses select 1),
				_mainPos distance2D (_wpPoses select 1),
				([_mainPos, (_wpPoses select 1)] call BIS_fnc_dirTo) + _addAngle
			];

			_p3 =
			[
				(_wpPoses select 2),
				_mainPos distance2D (_wpPoses select 2),
				([_mainPos, (_wpPoses select 2)] call BIS_fnc_dirTo) + _addAngle
			];
			_p4 =
			[
				(_wpPoses select 3),
				_mainPos distance2D (_wpPoses select 3),
				([_mainPos, (_wpPoses select 3)] call BIS_fnc_dirTo) + _addAngle
			];
			//-- re-Write points
			switch (_mode) do {
				case (0) :{
					_p1 = [_sPos,(_p1 select 1),(_p1 select 2)] call BIS_fnc_RelPos;
					_p2 = [_sPos,(_p2 select 1),(_p2 select 2)] call BIS_fnc_RelPos;
					_p3 = [_sPos,(_p3 select 1),(_p3 select 2)] call BIS_fnc_RelPos;
					_p4 = [_sPos,(_p4 select 1),(_p4 select 2)] call BIS_fnc_RelPos;

					(_x select 0) set [0,_SPos];

				};
				case (1) : {
					_refDist = _sPos distance2D _mainPos;
					if (_refDist > 5) then {
						//-- over a threshold of 5m (distance mouse to polyCenter) the polygon will be resized
						_reffactor1 = (_refDist / (_p1 select 1)); //-- factor of resize
						_reffactor2 = (_refDist / (_p2 select 1));
						_reffactor3 = (_refDist / (_p3 select 1));
						_reffactor4 = (_refDist / (_p4 select 1));

						_p1 = [_mainPos,(_p1 select 1) * _reffactor1,(_p1 select 2)] call BIS_fnc_RelPos;
						_p2 = [_mainPos,(_p2 select 1) * _reffactor2,(_p2 select 2)] call BIS_fnc_RelPos;
						_p3 = [_mainPos,(_p3 select 1) * _reffactor3,(_p3 select 2)] call BIS_fnc_RelPos;
						_p4 = [_mainPos,(_p4 select 1) * _reffactor4,(_p4 select 2)] call BIS_fnc_RelPos;

					} else {
						//-- under 5m threshold the unaffected poly will be recreated
						_p1 = [_mainPos,(_p1 select 1),(_p1 select 2)] call BIS_fnc_RelPos;
						_p2 = [_mainPos,(_p2 select 1),(_p2 select 2)] call BIS_fnc_RelPos;
						_p3 = [_mainPos,(_p3 select 1),(_p3 select 2)] call BIS_fnc_RelPos;
						_p4 = [_mainPos,(_p4 select 1),(_p4 select 2)] call BIS_fnc_RelPos;
					};
				};
				case (2) :{
					//-- same as (1) but also resets the new poly-direction
					_p1 = [_sPos,(_p1 select 1),(_p1 select 2)] call BIS_fnc_RelPos;
					_p2 = [_sPos,(_p2 select 1),(_p2 select 2)] call BIS_fnc_RelPos;
					_p3 = [_sPos,(_p3 select 1),(_p3 select 2)] call BIS_fnc_RelPos;
					_p4 = [_sPos,(_p4 select 1),(_p4 select 2)] call BIS_fnc_RelPos;

					(_x select 0) set [0,_SPos];
					_x set [3,_rotation];

				};
			};
			//-- replace positions array
			_x set [1,[_p1,_p2,_p3,_p4]];

		};
	} foreach _var;
	//-- overRide poly-unitVariable
	_unit setVariable ["A3C_UNIT_POLYS",_var,true];
};

A3C_CUR_EDIT_POLY = [];



//--------------------------  I N T E R F A C E   O P E R A T I O N :   F U N C T I O N S  ---------
//--------------------------------------------------------------------------------------------------
//--------------------------    Functions to operate the actual interface itself -------------------


//-- does this double
A3C_InMapControls = {
	_ctl = _this select 0;
	_pos = [A3C_MAP_X,A3C_MAP_Y,0];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	_cPos = ctrlPosition (findDisplay _a3c_dsp displayCtrl _ctl);
	_h = (_cPos select 3);
	_w = (_cPos select 2);

	_cPos = [_cPos select 0,_cPos select 1,0];
	_rPos1 = [_cPos,_h,180] call BIS_fnc_RelPos;
	_rPos2 = [_cPos,_w,90] call BIS_fnc_RelPos;
	_return = _pos inPolygon [_cPos,_rPos1,_rPos2];
	_return
};


A3C_GetDiagDeg = {
	//-- get the direction and distance of mousePos and player (for tablet cursor)
	_data = _this;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	if (_data select 3) then {
		(findDisplay _a3c_dsp displayCtrl 709108) ctrlShow true;
	} else {
		(findDisplay _a3c_dsp displayCtrl 709108) ctrlShow false;
	};
	_worldPos = ((findDisplay _a3c_dsp displayCtrl 7043) posscreentoworld [(_this select 1),(_this select 2)]);
	(findDisplay _a3c_dsp displayCtrl 709108) ctrlSetPosition [(_this select 1),(_this select 2)];
	(findDisplay _a3c_dsp displayCtrl 709108) ctrlCommit 0;
	(findDisplay _a3c_dsp displayCtrl 709108) ctrlSetText  format ["     %1dg, %2m",(round([(vehicle player),_worldPos] call BIS_fnc_dirto)),(round ((vehicle player) distance _worldPos))] ;
};



A3C_GetTrackerMarkSize = {
	_group = _this select 0;
	_size = count (units _group);
	_valX = 0.5;
	_valY = 0.5;
	_return = [];
	if (_group in A3C_HC_getAllGroups_Player_Current) then {
		_valX = 1.5;
		_valY = 1;
	} else {
		{
			if (_forEachIndex > 19) exitwith {};
			if (_forEachIndex == 1) then {_valX = 0.75};
			_valX = _valX + 0.045;
			_valY = _valY + 0.045; //0,0225
		} foreach (units _group);
	};
	_return = [_valX,_valY];
	_return
};

A3C_GoCode_Switch = {
	_lb = _this;
	_result = "NONE";
	_bPos = 0;
	_mSize = [1,1];
	//systemchat "1";
	if (_lb > 4) exitwith {
		_bPos = A3C_TAB_BUILDING buildingPos (_lb - 5);
		{
			private ["_soldier","_data"];
			_soldier = _x;
			_data = _soldier getVariable A3C_CHECKVAR;
			{
				//systemchat str (_x select 2);
				if ((_x select 2) == A3C_MARKERTOSWITCH) then {
					if ( ((getMarkerPos A3C_MARKERTOSWITCH) select [0,2]) distance ((_x select 0) select [0,2]) < 0.2) then {
						//A3C_MARKERTOSWITCH setMarkerPosLocal _bPos;
						_x set [0,_bPos];
						_x set [1,([A3C_TAB_BUILDING,100,([A3C_TAB_BUILDING,_bPos] call BIS_fnc_dirTo)] call BIS_fnc_RelPos)];
						_data set [_forEachIndex,_x];
						_soldier setvariable [A3C_CHECKVAR,_data,true];
					};
				};
			} foreach _data;
		} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
	};
	switch (_lb) do {
		//systemChat str _lb;
		case (0) : {
			_result ="NONE";
		};
		case (1) : {
			_result ="A";
		};
		case (2) : {
			_result ="B";
		};
		case (3) : {
			_mSize = [1,1];
			_result ="C";
		};
		case (4) : {
			_mSize = [1,1];
			_result ="D";
		};
	};
	//systemchat str _result;
		{
			_data = _x getVariable A3C_CHECKVAR;
			{
				if (((_x select 1) select 0) == A3C_MARKERTOSWITCH) then {
					_x set [3,["GOCODE",_result]];
				};
			} foreach _data;
			_x setvariable [A3C_CHECKVAR,_data,true];
			//systemchat str (_x getVariable A3C_CHECKVAR);
		} foreach A3C_GCUNITS;
	[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
//	if (A3C_CHECKVAR == "A3C_PLOT") then {
//		A3C_MARKERS pushBackUnique A3C_MARKERTOSWITCH;
//	} else {
//		A3C_MARKERS_TEMP pushBackUnique A3C_MARKERTOSWITCH;
//	};

	missionNamespace setVariable ["#markerSize_" + A3C_MARKERTOSWITCH, _mSize];
	//A3C_MARKERTOSWITCH setmarkerSizeLocal _mSize;
	//systemchat str (markersize A3C_MARKERTOSWITCH);
	//777
};


//-- function to label the unit selector buttons
A3C_LABEL_SELECTORS = {
	private ["_mode","_limit","_text","_textCol","_u","_unitIndex","_toolTip"];
	_mode = _this select 0;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	//systemchat str _a3c_dsp;
	//cccccccc
	_text = "";
	_textCol = [];
	_backCol = [1,1,1,0.7];
	_tooltip = "";
	_sub = 7000;
	_u = objnull;
	_unitIndex = -1;
	//systemchat str _mode;
	for "_i" from 7025 to 7040 do {
		call compile format ["(findDisplay _a3c_dsp displayCtrl %1) ctrlShow false;",_i];
	};
	_limit = if (_mode == "HC") then {
		24 + ( (count A3C_HC_getAllGroups_Player_CURRENT) - (A3C_BUTTONPAGE_TABLET * 16) )
	} else {
		24 + ((count((profileNamespace getvariable "A3C_GROUPUNITS") - [player])) - (A3C_BUTTONPAGE_TABLET * 16))
	};
	if (_limit > 40) then {_limit = 40};

	//systemchat str (_limit - 24);
	//-- reset tablet UI
	_maxWunit = 0.452508 * safezoneW;
	if (_a3c_dsp == 100030) then {
		(findDisplay 100030 displayCtrl 11) ctrlSetPosition
		[
			0.167779 * safezoneW + safezoneX,
			0.598968 * safezoneH + safezoneY,
			0.42 * safezoneW,
			0.175944 * safezoneH
		];
		(findDisplay 100030 displayCtrl 2301) ctrlSetPosition
		[
			0.190691 * safezoneW + safezoneX,
			0.68694 * safezoneH + safezoneY,
			0.22603 * safezoneW,
			0.0560031 * safezoneH
		];
		(findDisplay 100030 displayCtrl 2302) ctrlSetPosition
		[
			0.43 * safezoneW + safezoneX,
			0.609965 * safezoneH + safezoneY,
			0.189022 * safezoneW,
			0.142954 * safezoneH
		];



		//(findDisplay 100030 displayCtrl 23001) ctrlSetPosition
		//[
		//	0.190691 * safezoneW + safezoneX,
		//	0.68694 * safezoneH + safezoneY,
		//	(0.22339 * safezoneW), // min (0.452508 * safezoneW)
		//	0.0549824 * safezoneH
		//];
		//(findDisplay 100030 displayCtrl 23002) ctrlSetPosition
		//[
		//	0.419809 * safezoneW + safezoneX,
		//	0.609965 * safezoneH + safezoneY,
		//	0.189022 * safezoneW,
		//	0.142954 * safezoneH
		//];

		{
			(findDisplay 100030 displayCtrl _x) ctrlCommit 0;
		} foreach [11,2302,23001,23002];
		if (count (profileNamespace getvariable "A3C_GROUPUNITS") > 17) then {
			{
				(findDisplay 100030 displayCtrl _x) ctrlShow true;
			} foreach [7097,7098,70981,70982,70983];
		} else {
			{
				(findDisplay 100030 displayCtrl _x) ctrlShow false;
			} foreach [7097,7098,70981,70982,70983];
		};
	};


	for "_i" from 25 to 40  do {
		if (_i <= _limit) then {
			//-- adjust tablet UI
			if (_a3c_dsp == 100030) then {
				if (_i in [33,35,37,39]) then {
					_mult = switch _i do {
						//case 31 : {1};
						//case 32 : {1};
						case 33 : {1};
						case 35 : {2};
						case 37 : {3};
						case 39 : {4};
					};
					_pX = (ctrlPosition ((findDisplay 100030 displayCtrl 2301) controlsGroupCtrl 7027)) select 0;
					_pW = switch (_i) do {
						case 33 : {0.28436 * safezoneW};
						case 35 : {0.342691 * safezoneW};
						case 37 : {0.401021 * safezoneW};
						case 39 : {0.45206 * safezoneW};
					};
					//systemchat str _pW;
					//systemChat str _mult;
					(findDisplay 100030 displayCtrl 11) ctrlSetPosition
					[
						0.167779 * safezoneW + safezoneX,
						0.598968 * safezoneH + safezoneY,
						((0.42 * safezoneW) + (_mult * _pX)), //(0.057279 * safezoneW)
						0.175944 * safezoneH
					];

					//systemchat str _mult;
					(findDisplay 100030 displayCtrl 2301) ctrlSetPosition
					[
						0.190691 * safezoneW + safezoneX,
						0.68694 * safezoneH + safezoneY,
						_pW, //(0.22339 * safezoneW) + (_mult * (0.057279 * safezoneW)), // min (0.452508 * safezoneW) //0.22339 * safezoneW,
						1 * safezoneH
					];
					//(findDisplay 100030 displayCtrl 23001) ctrlSetPosition
					//[
					//	0.190691 * safezoneW + safezoneX,
					//	0.68694 * safezoneH + safezoneY,
					//	(0.22339 * safezoneW) + (_mult * (0.057279 * safezoneW)), // min (0.452508 * safezoneW) //0.22339 * safezoneW,
					//	0.0549824 * safezoneH
					//];
					(findDisplay 100030 displayCtrl 2302) ctrlSetPosition
					[
						((0.43 * safezoneW + safezoneX) + (_mult * (0.057279 * safezoneW))),
						0.609965 * safezoneH + safezoneY,
						0.189022 * safezoneW,
						0.142954 * safezoneH
					];
					//(findDisplay 100030 displayCtrl 23002) ctrlSetPosition
					//[
					//	((0.419809 * safezoneW + safezoneX) + (_mult * (0.057279 * safezoneW))),
					//	0.609965 * safezoneH + safezoneY,
					//	0.189022 * safezoneW,
					//	0.142954 * safezoneH
					//];
					{
						(findDisplay 100030 displayCtrl _x) ctrlCommit 0;
					} foreach [11,2301,2302,23001,23002];
					ctrlsetfocus (finddisplay 100030 displayctrl 2301)
				} else {
					//systemchat "2";

				};
			};
			if (_mode in ["INF","AIR"]) then {
				//systemchat str A3C_SELECTED_UNITS;
				//private ["_opacT"];
				//-- "INF" and "AIR" share function only have one difference
				_unitIndex = ( (_i - 24) + (A3C_BUTTONPAGE_TABLET * 16) );
				_u = ((profileNamespace getvariable "A3C_GROUPUNITS") select _unitIndex);
				//_opacT = if (_u in A3C_SELECTED_UNITS) then {1} else {0.5};
				if (isNil '_u' OR {isnull _u}) then {
					_text = 'N/A';
					_textCol = [0.5,0.5,0.5,1];
					_tooltip = "Unit not available";
				} else {
					_toolTip = getText (configfile >> "CfgVehicles" >> (typeOf _u) >> "displayName");
					_backCol = [_u] call A3C_GET_UB_COLOR;
					call compile format
					[
						"
							if (_u in A3C_SELECTED_UNITS) then {
								_textCol = [1,1,1,1];
								A3C_UNIT_%1_BV = 1;
							} else {
								_textCol = [1,1,1,0.7];
								A3C_UNIT_%1_BV = 0;
							};
						",
						_unitIndex
					];

					if !(alive _u) then {
						_text = 'N/A';
						_textCol =  [0.5,0.5,0.5,0.2];
					} else {
						_text = [_u] call MCSS_fnc_NAMESTRING;
						if (_mode == "INF") then {
							//-- grey out passengers and pilots
							if (((vehicle _u) iskindof 'AIR') OR !(_u == driver vehicle _u)) then {
								//_textCol = [0.5,0.5,0.5,0.2];
								_backCol set [3,0.1];
							};
						} else {
							//-- grey out non pilots
							if ( !((vehicle _u) iskindof 'AIR') OR !(_u == driver vehicle _u)) then {
								//_textCol = [0.5,0.5,0.5,0.2];
								_backCol set [3,0.1];
							};
						};
					};
					if (isPlayer _u) then {
						_backCol = [0.86,0.47,0.56,1];
					} else {
						[_u,_i] spawn {
							private ['_unit','_control'];
							_unit = _this select 0;
							_control = _this select 1;
							_unit setvariable ['A3C_Unt_Btn',_control,true];
						};
					};
				};
				//if ((getResolution select 5) == 0.7) then {
					//(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlsetTextSize _text;
				//};
				(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlShow true;
				(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlsettext _text;
				(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlSetTextColor _textCol;
				(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlSetBackgroundColor _backCol;
			} else {
				//-- Mode: High Command
				_unitIndex = ( (_i - 24) + (A3C_BUTTONPAGE_TABLET * 16) );
				//if ( ({alive _x} count (units (A3C_HC_getAllGroups_Player_CURRENT select ((_i - 25) + (A3C_BUTTONPAGE_TABLET * 16))))) == 0 ) then {
				//	_text = 'N/A';
				////	_textCol = [0.5,0.5,0.5,1];
					(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlSetBackgroundColor [0,0,0,0.7];
				//} else {
					_buttonMode = 0;
					///_hcGroups= A3C_HC_getAllGroups_Player_Current_ORGANIZED; 
					///A3C_HC_MENU_REFERENCE_UNITS = _hcGroups;
					_hcGroups = A3C_HC_getAllGroups_Player_Current;
					if (( (_hcGroups) select ((_i - 25) + (A3C_BUTTONPAGE_TABLET * 16) )) in A3C_SELECTED_UNITS) then {
						_textCol = [0.21,0.63,0,1];
						_buttonMode = 1;
					} else {
						_textCol = [0.9,0.9,0,1];
					};

					_text = (str ((_i - 23)+ (A3C_BUTTONPAGE_TABLET * 16))    ) + ": " ;
					_backCol = [A3C_UI_COLOR_BLUE,0.7] call A3C_UI_Color_setOpacity ;
					//systemchat str [_unitIndex , (count A3C_HC_DISBANDED)];
					if (_unitIndex <= (count A3C_HC_DISBANDED) ) then {

						_text =  _text + ("RS: " + (groupID ( (_hcGroups) select ((_i - 25) + (A3C_BUTTONPAGE_TABLET * 16) ))));
						_backCol = [0.33,0.63,0.97,0.7];
					} else {

						_text =  _text + ("HC: " + (groupID ( (_hcGroups) select ((_i - 25) + (A3C_BUTTONPAGE_TABLET * 16) ))));

					};
					(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlSetBackgroundColor _backCol;
					call compile format ["A3C_UNIT_%1_BV = %2;",_unitIndex,_buttonMode];
				//};
			};
			(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlShow true;
			(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlsettext _text;
			(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlSetTextColor _textCol;
			(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlSetTooltip _toolTip;
		} else {
			//-- no unit for button
			call compile format ["
				(findDisplay _a3c_dsp displayCtrl 70%1) ctrlShow false;
			",_i];
		};
	};
	[_a3c_dsp,_mode] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
};


// -- function to find last WP without smoke or suppression of certain variable put back around line 195
A3C_FIND_SMOKELESS_WP = {
	private ["_vari","_data","_index"];
	_unit = _this select 0;
	_vari = _this select 1; // _vari number selects variable-name 0 == TEMP
	_index = _this select 2;
	_count = count _this;
	_data = if (_vari == 0) then {(_unit getvariable "A3C_PLOT_TEMP")} else {(_unit getvariable "A3C_PLOT")};
	_end = count _data;
	_result = position _unit;
	_exit = false;
	for "_i" from _index to 0 step - 1 do {
		if (_i > 0) then {
			if !((((_data select (_i - 1)) select 2) select 0) in ["GRENADE","SUPPRESSION"]) then {
				_result = ((_data select ( _i - 1 )) select 0) select 0;
				_exit = true;
			};
		} else {
			_result = position _unit;
		};
		if (_exit) exitwith {};
	};
	_result
};

A3C_CREATE_BPOS_MARKERS = {
	private ["_bPos","_icon","_count"];
	A3C_BUILDING_VIEWER = createMarkerLocal ["A3C_BUILDING_VIEWER", (position A3C_TAB_BUILDING)];
	"A3C_BUILDING_VIEWER" setmarkerAlphaLocal 0.5;
	"A3C_BUILDING_VIEWER" setmarkershapeLocal "RECTANGLE";
	"A3C_BUILDING_VIEWER" setmarkerColorLocal "ColorGreen";
	"A3C_BUILDING_VIEWER" setmarkerposLocal (position A3C_TAB_BUILDING);
	"A3C_BUILDING_VIEWER" setMarkerDirLocal (getDir A3C_TAB_BUILDING);
	"A3C_BUILDING_VIEWER" setMarkerSizeLocal [(((boundingboxReal A3C_TAB_BUILDING select 1)) select 0),(((boundingboxReal A3C_TAB_BUILDING) select 1) select 1)];
	A3C_BPMARKERS pushback "A3C_BUILDING_VIEWER";
	_doorPositions = [A3C_TAB_BUILDING] call A3C_DOORPOSITIONS;
	{
		call compile format [
			"
				A3C_BDPS_D_%1 = createMarkerLocal ['A3C_BDPS_D_%1', (position A3C_TAB_BUILDING)];
				'A3C_BDPS_D_%1' setMarkershapeLocal 'RECTANGLE';
				'A3C_BDPS_D_%1' setMarkerPosLocal %2;
				'A3C_BDPS_D_%1' setMarkerTextLocal str %1;
				'A3C_BDPS_D_%1' setMarkerDirLocal ([A3C_TAB_BUILDING,%2] call A3C_DOOR_DIR);
				'A3C_BDPS_D_%1' setMarkerSizeLocal [0.5,0.1];
				'A3C_BDPS_D_%1' setmarkerColorLocal 'ColorBlufor';
				'A3C_BDPS_D_%1' setmarkerAlphaLocal 1;
				A3C_BPMARKERS pushback 'A3C_BDPS_D_%1';
				if ((%2 select 2) <= 2) then {'A3C_BDPS_D_%1' setmarkerColorLocal 'ColorBlufor'};
				if ((%2 select 2) > 2) then {'A3C_BDPS_D_%1' setmarkerColorLocal 'ColorGreen'};
				if ((%2 select 2) > 8) then {'A3C_BDPS_D_%1' setmarkerColorLocal 'ColorYellow'};
			",
			_forEachIndex,
			_x
		];
	} foreach _doorPositions;
	_count = ([A3C_TAB_BUILDING] call MCSS_fnc_countBPos);
};

A3C_ICONCOLORSIZE = {
	private ["_bPos","_size","_color","_textSize","_result"];
	_bPos = _this select 0;
	_color = [A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity;
	_size = 4;
	_textSize = 0.03;
	if ((_bPos select 2) > 2) then {_color = [0,1,0,1]; _size = 6; _textSize = 0.0415;};
	if ((_bPos select 2) > 8) then {_color = [1,1,0,1]; _size = 7; _textSize = 0.047;};
	_result = [_color,_size,_textSize];
	_result
};

A3C_DELETE_BPOS_MARKERS = {
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{deleteMarkerLocal _x} foreach A3C_BPMARKERS;
	A3C_BPICONS = [];
};






//-- simple mapclick to world coordinates function [AN: RETURNS NOTHING AND APARENTLY DEAD WEIGHT?? OTHER?]
A3C_MAPCOORDINATES = {
	_left = true;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	disableSerialization;
	_map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
	if (_this select 1 == 1) then {_left = false};
	_sx = _this select 2;
	_sy = _this select 3;
	_pos = (_map1 posscreentoworld [_sx,_sy]);
};

//////
A3C_SWITCHMARKER = {
	private ["_newMode"];
	_data = _this select 0; // 0 = "NONE", 1 = "PICKUP", 2 = "DROPOFF", 3 = "LANDFINAL", 4 == "RAPPEL"
	_hide = if (count _this > 1) then {_this select 1} else {false};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	_newAction = "";
	switch (_data) do {
		case 0 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal "A3C_Marker_WAYPOINT";
			//A3C_MARKERTOSWITCH setmarkerColorLocal "ColorBlufor";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.8] call A3C_UI_Color_setOpacity);
			_newAction = ["LANDING","NONE"];
		};
		case 1 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal 'A3C_Marker_PICKUP_AIR';
			//A3C_MARKERTOSWITCH setmarkerColorLocal "DEFAULT";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
			_newAction = ["LANDING","PICKUP"];
		};
		case 2 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal 'A3C_Marker_DROPOFF_AIR';
			//A3C_MARKERTOSWITCH setmarkerColorLocal "DEFAULT";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
			_newAction = ["LANDING","DROPOFF"];
		};
		case 3 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal 'A3C_Marker_LANDING';
			//A3C_MARKERTOSWITCH setmarkerColorLocal "DEFAULT";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
			_newAction = ["LANDING","LANDFINAL"];
		};
		case 4 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal 'A3C_Marker_Rappel';
			//A3C_MARKERTOSWITCH setmarkerColorLocal "DEFAULT";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
			_newAction = ["LANDING","RAPPEL"];
		};
		case 5 : {
			//A3C_MARKERTOSWITCH setmarkerTypeLocal 'A3C_Marker_Paradrop';
			//A3C_MARKERTOSWITCH setmarkerColorLocal "DEFAULT";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
			((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
			_newAction = ["PARADROP","PARADROP"];
		};
	};
	if (_hide) then {
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow false;
	};
	{
		_unit = _x;
		{
			_data = _unit getvariable _x;
			{
				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				if ((_wpMarkers select 0) == A3C_MARKERTOSWITCH) then {
					_x set [2,_newAction];
				};
			} foreach _data;
			_unit setvariable [_x,_data,true];
		} foreach ["A3C_PLOT_TEMP","A3C_PLOT"];
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
};



A3C_GET_UNITBUTTON = {
	_unit = _this select 0;
	_return = 0;
	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
	{
		if (_foreachIndex > 15) exitwith {};
		if (_x == _unit) then {_return = (7024 + _foreachIndex)};
	} foreach _unitArray;
	_return;
};

//-- Function to toggle the control section for more map visibility - used by talet only (?)

A3C_TAB_TOGGLE_CONTROLS = {
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	switch (A3C_TAB_TOGGLE_VAR) do {
		case (0) : {
			for "_i" from 7044 to 7089 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow false;
				",_i];
			};
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;} foreach [7007,A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout,7018,7019,7022,7097,7098,70981,70982,70983];
			for "_i" from 7025 to 7041 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow false;
				",_i];
			};
			for "_i" from 8000 to 8003 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow false;
				",_i];
			};

			(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow false;
			(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,0.2];

			A3C_TAB_TOGGLE_VAR = 1;
		};
		case (1) : {
			for "_i" from 7044 to 7089 do {
				call compile format ["
					if !(_i in [7078]) then {(findDisplay _a3c_dsp displayCtrl _i) ctrlShow true;};
				",_i];
			};
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true} foreach [7007,7018,7019,7022,7097,7098,70981,70982,70983];
			if !((A3C_TEMP_CONDITION select 0) == "NONE") then {
				{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			};
			for "_i" from 7025 to 7040 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow true;
				",_i];
			};
			for "_i" from 8000 to 8003 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow true;
				",_i];
			};
			//[A3C_MAP_CommandMode] call A3C_LABEL_SELECTORS;

			if (count A3C_WAYPOINTS_TEMP > 0) then {
				//{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true} foreach [7041,7092];
				(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow true;
				(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,1];
			};
			A3C_TAB_TOGGLE_VAR = 0;
		};
	};
};


//-- Function to toggle force tracking on and off
A3C_TAB_TOGGLE_TRACKER = {
	if (A3C_TRACKER_VISIBLE == 0) then {
		A3C_TRACKER_VISIBLE = 1;
		//{
		//	_x setMarkerAlphaLocal 0.6;
		//} foreach A3C_TRACKER_MARKERS;
	} else {
		A3C_TRACKER_VISIBLE = 0;
		//{
		//	_x setMarkerAlphaLocal 0;
		//} foreach A3C_TRACKER_MARKERS;
	};
};


//-- start tablet mode (page) and switch tablet-controls




A3C_UI_MAP_BARSETTINGS_LABEL = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	//-- hide subselection controls
	if (_mode != A3C_MAP_CommandMode) then {
		//-- TOGGLE SUBSELECTION OFF ON MODESWITCHs
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2]; 
	};
};


A3C_UI_MAP_REFRESH_BARCONTROLS = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	if !(_mode == "HC") then {
		if (count A3C_SELECTED_UNITS > 0) then {
			((findDisplay _a3c_dsp) displayCtrl 7014) ctrlShow true;
			((findDisplay _a3c_dsp) displayCtrl 7042) ctrlShow false;
		} else {
			((findDisplay _a3c_dsp) displayCtrl 7014) ctrlShow false;
			((findDisplay _a3c_dsp) displayCtrl 7042) ctrlShow true;
		};
		if (count A3C_SELECTED_UNITS > 1) then {
			if (A3C_FORMMODE_TEMP == 0) then {
				A3C_FORMMODE_TEMP = 1;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";
			};
		} else {
			((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_None.paa";
			A3C_FORMMODE_TEMP = 0;

			if (A3C_LAST_SUBSET_ACTION == "SQ_FORMATION") then {
				{
					(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
				} foreach [A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2];
			};
		};
		_tColHold = [1,1,1,0.2];
		_tColCont = [1,1,1,0.2];
		if ({!(_x getvariable ["A3C_HOLD",false])} count A3C_SELECTED_UNITS> 0) then {
			_tColHold = [1,1,1,1];		
		};
		if ({_x getvariable ["A3C_HOLD",false]} count A3C_SELECTED_UNITS> 0) then {
			_tColCont = [1,1,1,1];		
		};
		
		(findDisplay _a3c_dsp displayCtrl 8000)	ctrlSetTextColor _tColHold;	
		(findDisplay _a3c_dsp displayCtrl 8002)	ctrlSetTextColor _tColCont;
		_tColCancelData = [1,1,1,0.2];
		if ({_u = _x; {count (_u getvariable [_x,[]]) > 0} count ["A3C_PLOT","A3C_PLOT_TEMP"] > 0} count A3C_SELECTED_UNITS > 0) then {
			_tColCancelData = [1,1,1,1];
		};
		(findDisplay _a3c_dsp displayCtrl 7069)	ctrlSetTextColor _tColCancelData;
		
		_a3c_dsp spawn {
			sleep 0.5;
			_spacing = if (A3C_MAP_CommandMode == "AIR") then {A3C_SPACING_AIR} else {A3C_SPACING_INF max 2};
			_spacing = if (_spacing < 10) then {"0" + (str _spacing)} else {str _spacing};
			(findDisplay _this displayCtrl 7066) ctrlSetText _spacing;	
		};
			
	};
};

A3C_START_TABMODE = {
	private ["_mode","_stanceHeight","_stanceLand","_stance2Col","_smokeBool","_spacing","_pagebutton","_stance1TT","_stance2TT","_pageTT","_ctrlBool"];
	params ["_mode"];


	private _a3c_dsp = if (visibleMap) then {100020} else {100030};

	
	//-- open trere first so that other controls can adjust accodingly | ADD CONDITION / PROFILE
	//systemchat 'tabmode';

	
	
	//--  asasas
	
	//if (_mode != A3C_MAP_CommandMode) then {
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1,A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2];
	//};


	private _lowerBar = [7018,7019,7072,7092,7041,7069,7070,8000,8001,8002,8003];

	//systemchat str A3C_BUTTONPAGE_TABLET;
	//systemchat str A3C_SELECTED_UNITS;

	_stanceHeight = "";
	_stanceLand = "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
	_stance2Col = [];
	_smokeBool = true;
	_spacing = "";
	_pagebutton = "A3C_CORE\ui\pictures\icon_menu_page_INF.paa";
	_stance1TT = "stance while en route";
	_stance2TT = "set stance upon arrival";
	_pageTT = "switch page to AIRCRAFT";

	//-- reset Timeout
	(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout) ctrlSetText (str A3C_TIMEOUT_VAL);
	(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
	

	//A3C_HELI_HELI_WP_BEHAVIOUR = "NONE";
	A3C_HELIHEIGHT = 0;

	_ctrlBool = true;

	(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "No Action || Use LMB to open settings or mousewheel to cycle";


	

	_ctrlShowLowerBar = true;

	switch (_mode) do {
		case ("INF") : {
			if (typeName A3C_WP_SPEED_TEMP == "STRING") then {A3C_WP_SPEED_TEMP = -1};
			_stance2Col = [1,1,1,0.3];
			//if (A3C_MAP_CommandMode == "INF") then {
			//	_pn = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066)));
			//	if (_pn > 0) then {
			//		A3C_SPACING_INF = _pn;
			//	};

			//};

			///_spacing = str A3C_SPACING_INF;
			///if (A3C_SPACING_INF < 10) then {
			///	_spacing = "0" + _spacing;
			///};
			if (hcShownBar) then {hcShowBar false};

			{
				(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true;
			} foreach [7007,7022]; //7010,7066

			if (A3C_MAP_CommandMode == "HC") then {
				//(findDisplay _a3c_dsp displayCtrl 7008) ctrlSetText "^";
				{
					(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
				} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			};
			if ((A3C_TEMP_ACTION select 0) in ["LANDING","SLINGLOAD"]) then {
				A3C_TEMP_ACTION = ["NONE","NONE"];
			};
			if ({!isnull objectparent _x} count A3C_SELECTED_UNITS > 0) then {
				A3C_TEMP_ACTION = ["NONE","NONE"];
			};


			//-- adjust action button
			switch (A3C_TEMP_ACTION select 0) do {
				case ("GRENADE") : {
					[0] call A3C_GREN_DATA;
				};
				case ("STATIC") : {
					[A3C_SELECTED_UNITS,"PLANNING"] call A3C_getSelectionBackpackStatics;
					private _cond1 = ({isnull objectParent _x && {backPack _x == ""}} count A3C_SELECTED_UNITS >= 2);
					private _cond2 = (count A3C_STATIC_PACKS > 0);
					if (_cond1 || _cond2) then {
						A3C_TEMP_ACTION = ["STATIC",[]];
						(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";
						(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Deploy or Pack Static Weapon || Use LMB to open settings or mousewheel to cycle";
					} else {
						A3C_TEMP_ACTION = ["NONE","NONE"];
						(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettextColor [1,1,1,1];
						(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
					};

				};
				default {
					A3C_TEMP_ACTION = ["NONE","NONE"];
					(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettextColor [1,1,1,1];
					(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				};
			};



			//(findDisplay _display displayCtrl 7064) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";

		};
		case ("AIR") : {
			if (typename A3C_WP_SPEED_TEMP == "STRING") then {A3C_WP_SPEED_TEMP = -1};
			A3C_HELIHEIGHT = 25;
			_stanceHeight = "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
			_stanceLand = "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			_stance2Col = [1,1,1,0.8]; //[0,0.3,0.6,0.8]; //  [0.5,0.5,0.5,0.8];
			_smokeBool = false;
			//if (A3C_MAP_CommandMode == "AIR") then {
			//	_pn = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066)));
			//	if (_pn > 0) then {
			//		A3C_SPACING_AIR = _pn;
			//	};

			//};
			if ((A3C_TEMP_ACTION select 0) in ["GRENADE","SUPPRESSION"]) then {
				A3C_TEMP_ACTION = ["NONE","NONE"];
			};
			//_spacing = str A3C_SPACING_AIR;
			//if (A3C_SPACING_AIR < 10) then {
			//	_spacing = "0" + _spacing;
			//};
			_pagebutton = "A3C_CORE\ui\pictures\icon_Menu_page_aircraft.paa";
			_stance1TT = "Aircraft flying height";
			_stance2TT = "MOVE";
			_pageTT = "switch page to HIGH COMMAND";
			if (hcShownBar) then {hcShowBar false};
			{
				(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true;
			} foreach [7007,7022]; //7010,7066


			if (A3C_MAP_CommandMode == "HC") then {
				//(findDisplay _a3c_dsp displayCtrl 7008) ctrlSetText "^";
				{
					(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
				} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			};
		};
		case ("HC") : {
			if (A3C_UI_MAP_Overlay_VAR_isUnFolded) then {
				["COLLAPSE",0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
			};

			_ctrlShowLowerBar = false;
			if (typeName A3C_WP_SPEED_TEMP == "SCALAR") then {A3C_WP_SPEED_TEMP = "UNCHANGED"};
			_stance2Col = [1,1,1,0.6];
			_pagebutton = "\a3\ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
			_pageTT = "switch page to GROUND TROOPS";
			if ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) then {
				hcShowBar true; //~~ ??? WHY DO WE NEED THAT?!
			};
			_smokeBool = false;
			onHCGroupSelectionChanged {};
			_ctrlBool = false;
			{
				(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
			} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout,7022,7066];
			if ((A3C_TEMP_ACTION select 0) in ["GRENADE","SUPPRESSION","LANDING"]) then {
				A3C_TEMP_ACTION = ["NONE","NONE"];
			};
		};
	};

	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow _ctrlShowLowerBar} foreach _lowerBar;


	for "_i" from 7007 to 7007 do { //-- timeout box 7708 removed ~~~~~~
		(findDisplay _a3c_dsp displayCtrl _i) ctrlShow _ctrlBool;
	};
	for "_i" from 7044 to 7051 do { //-- stances to form
		(findDisplay _a3c_dsp displayCtrl _i) ctrlShow _ctrlBool;
	};
	for "_i" from 7062 to 7066 do { //-- cmode - spacing input
		(findDisplay _a3c_dsp displayCtrl _i) ctrlShow _ctrlBool;
	};
	//for "_i" from 7085 to 7088 do { //-- slashses
	//	(findDisplay _a3c_dsp displayCtrl _i) ctrlShow _ctrlBool;
	//};

	if !(_mode == "AIR") then {
		_stanceHeight = switch (A3C_STANCE1_TEMP) do {
			case ("AUTO") : {"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa"};
			case ("UP") : {"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa"};
			case ("MIDDLE") : {"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa"};
			case ("DOWN") : {"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"};
		};
		_stanceLand = switch (A3C_STANCE2_TEMP) do {
			case ("AUTO") : {"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa"};
			case ("UP") : {"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa"};
			case ("MIDDLE") : {"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa"};
			case ("DOWN") : {"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"};
		};
		//A3C_STANCE1_TEMP = "UP";
		//A3C_STANCE2_TEMP = "MIDDLE";
	} else {
		//~~ this is sloppy, fix this weird 'ctrlBool' thingy
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [7064,7065];
	};
	[_mode] call A3C_UI_MAP_REFRESH_BARCONTROLS;
	
	(findDisplay _a3c_dsp displayCtrl 7022) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";
	A3C_TEMP_CONDITION = ["NONE","NONE"];
	((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: NONE (LMB to cycle through options)';
	(findDisplay _a3c_dsp displayCtrl 7062) ctrlSetText "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
	(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_undo.paa";
	(findDisplay _a3c_dsp displayCtrl 7069) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_cancel.paa";
	(findDisplay _a3c_dsp displayCtrl 8000) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";
	(findDisplay _a3c_dsp displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";
	
	(findDisplay _a3c_dsp displayCtrl 7044) ctrlsettext _stanceHeight;
	(findDisplay _a3c_dsp displayCtrl 7045) ctrlSetTooltip _stance1TT;
	(findDisplay _a3c_dsp displayCtrl 7046) ctrlsettext _stanceLand;
	(findDisplay _a3c_dsp displayCtrl 7046) ctrlSetTextColor _stance2Col;
	(findDisplay _a3c_dsp displayCtrl 7047) ctrlSetTooltip _stance2TT;
	(findDisplay _a3c_dsp displayCtrl 7062) ctrlSetTextColor [1,1,1,1];
	(findDisplay _a3c_dsp displayCtrl 7064) ctrlShow _smokeBool;
	//(findDisplay _a3c_dsp displayCtrl 7066) ctrlSetText _spacing;
	(findDisplay _a3c_dsp displayCtrl 7067) ctrlsettext _pagebutton;
	(findDisplay _a3c_dsp displayCtrl 7068) ctrlsetToolTip _pageTT;
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout,7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT]; //-- hide rClick contextMenu, undo, small rClick-menu
	(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow false;
	(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,0.2];
	(findDisplay _a3c_dsp displayCtrl 7048) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
	//(findDisplay _a3c_dsp displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_None.paa";

	if (count A3C_SELECTED_UNITS > 0) then {
		private _refItem = A3C_SELECTED_UNITS select 0;
		private _refArray = if (_mode != "HC") then {profileNamespace getvariable "A3C_GROUPUNITS"} else {A3C_HC_getAllGroups_Player_Current};
		private _refDif = if (_mode != "HC") then {-1} else {0}; //-- on squad level, buttons exclude the player. Therefore, 1 needs to be substracted from refr
		private _refIndex = [_refItem, _refArray] call MCSS_fnc_getArrayIndex;
		A3C_BUTTONPAGE_TABLET = (floor ( (_refIndex + _refDif) / 16)) max 0;
	};
	//[_mode] call A3C_LABEL_SELECTORS;
};


A3C_SWITCH_COMMAND_PAGE = {
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	A3C_SELECTED_UNITS = [];
	switch (A3C_MAP_CommandMode) do {
		case ("INF") : {
			["AIR"] call A3C_START_TABMODE;
			A3C_MAP_CommandMode = "AIR";
		};
		case ("AIR") : {
			A3C_BUTTONPAGE_TABLET = 0;
			["HC"] call A3C_START_TABMODE;
			A3C_MAP_CommandMode = "HC";
		};
		case ("HC") : {
			A3C_BUTTONPAGE_TABLET = 0;
			["INF"] call A3C_START_TABMODE;
			A3C_MAP_CommandMode = "INF";
		};
	};
};



A3C_TRACKER_GROUPS = [];
//-- Super simple Force-Tracker (units known to group members)
A3C_UI_MAP_FNC_createEnemyForceTracker = {
	if (A3C_DISABLE_TRACKER) exitWith {};
	_factionGroups = [];
	_friendlyGroups = [];
	A3C_TRACKER_Groups = [];
	private _enemyGroups = [];
	private _nearTargets = player nearTargets 1300;
	{
		private _group = _x;
		_color = switch (side _x) do {
			case (WEST) : {[A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity}; //{"colorBlufor"};
			case (EAST) : {[A3C_UI_COLOR_RED,1] call A3C_UI_Color_setOpacity}; //{"colorOpfor"};
			case (RESISTANCE) : {[0,0.5,0,1]}; //{"ColorGUER"};
			case (civilian) : {[0.4,0,0.5,1]}; //{"ColorCivilian"};
			default  {[0.4,0,0.5,1]};
		};
		
		//-- #WIP #ISSUE: somehow _color can be returned as BOOL we paint them red to get more intel as it happens.
		if (typeName _color != "ARRAY") then {_color = [1,0,0,1]};
		
		
		
		//_color = (configfile >> "CfgMarkerColors" >> _color >> "color") call BIS_fnc_colorConfigToRGBA;
		_color set [3,0.5];
		if ((side _x) getFriend (side player) >= 0.6) then {
			//-- friendly
			if ((faction leader _x) == (faction player)) then {
				//-- player faction
				//-- NO ACTION. will be drawn by AIC or in individual section >> MAP_UI_fnc_drawMapUI
			} else {
				//-- friendly faction
			};
			if (side _x == civilian) then {
				A3C_TRACKER_GROUPS pushBackUnique [_x,position (vehicle leader _x),"CIVILIAN",_color];
			};
		} else {
			//-- enemy
			private _inNeartargets = false;
			{
				private _perceivedPosition = _x select 0;
				private _object = _x select 4;
				if ({_x == _object} count [leader _group, vehicle leader _group] > 0) exitWith {
					_inNeartargets = true;
					A3C_TRACKER_GROUPS pushBackUnique [_group,_perceivedPosition,"ENEMY",_color];
				};
			} foreach _nearTargets;
			if !(_inNeartargets) then {
				A3C_TRACKER_GROUPS pushBackUnique [_group,position (vehicle leader _x),"ENEMY",_color];
			};


			//if ({ _obj = _x; {_x select 4 == _obj} count _nearTargets > 0 } count [leader _x, vehicle leader _x] > 0) then {
			//} else {
			//};

		};
	} foreach allGroups;


};


A3C_HC_getIconType = {
	params ["_gp"];

	private _kindFnc = {
		params ["_gp","_kind"];
		private _return = false;
		{
			private _v = objectParent _x;
			if (!isNull _v && {_x == driver _v && {_v isKindOf _kind}}) exitWith {
				_return = true;
			};
		} foreach (units _gp);
		_return
	};
	private _leader = (leader _gp);
	private _leaderVic = vehicle _leader;
	private _root = "\a3\ui_f\data\GUI\Cfg\Hints\icon_text\";	
	private _iconType = "";
	private _units = (units _gp) select {_v = (objectParent _x); !isNull _v && {_x == driver _v} };

	if (isPlayer _leader && {{["A3C_Terminal", _x] call BIS_fnc_instring} count assignedItems _leader > 0}) then {
		_iconType = "b_hq_ca.paa"
	} else {
		_iconType = switch (true) do {
			case ([_gp,"PLANE"] call _kindFnc) : {"b_plane_ca.paa"};
			case ([_gp,"HELICOPTER"] call _kindFnc) : {"b_air_ca.paa"};
			case ([_gp,"TANK"] call _kindFnc) : {
				if ((getArtilleryAmmo [_leaderVic]) isEqualTo []) then {
					//if ({isNull (objectParent _x)} count units _gp == 0) then {
						"b_armor_ca.paa"	
					//} else {
					//	"b_mech_inf_ca.paa"
					//};	
				} else {
					"b_artillery_ca.paa"
				};
			};
			case ([_gp,"wheeled_apc_f"] call _kindFnc) : {"b_mech_inf_ca.paa"};
			case ([_gp,"CAR"] call _kindFnc) : {
				//systemchat str (units _gp);
				switch (true) do {
					//case ({[_x] call A3C_canUnitRepair} count _units > 0) : {
					//	_root = "\a3c_ui\markers\";
					//};
					case (count (getArtilleryAmmo [_leaderVic]) > 0) : {
						"b_artillery_ca.paa"
					};
					case ({getNumber (configFile >> "CfgVehicles" >> typeof (objectParent _x) >> "transportRepair" ) > 1000} count _units > 0) : {
						_root = "\a3c_ui\markers\";
						"icon_map_b_rePair_ca.paa"

					};
					case ({getNumber (configFile >> "CfgVehicles" >> typeof (objectParent _x) >> "transportAmmo" ) > 1000} count _units > 0) : {
						_root = "\a3c_ui\markers\";
						"icon_map_b_reArm_ca.paa"

					};
					case ({getNumber (configFile >> "CfgVehicles" >> typeof (objectParent _x) >> "transportFuel" ) > 1000} count _units > 0) : {
						_root = "\a3c_ui\markers\";
						"icon_map_b_reFuel_ca.paa"
					};

					case ({getNumber (configFile >> "CfgVehicles" >> typeof (objectParent _x) >> "attendant" )  == 1} count _units > 0) : {
						_root = "\a3c_ui\markers\";
						"icon_map_b_medical_ca"
					};

					case ({count ((weapons (vehicle _x)) select {!("horn" in toLower _x)}) > 0} count _units == 0) : {
						_root = "\a3c_ui\markers\";
						"icon_map_b_transport_ca.paa"
					};

					
					
					default {"b_motor_inf_ca.paa"};
				};
				
			};
			default {
				if ({_x == gunner vehicle _x && {count (getArtilleryAmmo [vehicle _x]) > 0}} count (units _gp) == 0) then {
					"b_inf_ca.paa"
				} else {
					"b_artillery_ca.paa"				
				};
				
			};
		};
		if ({_x in _iconType} count ["air","plane"] > 0) then {
			if (_leaderVic in allunitsuav) then {
				_iconType = "b_UAV_ca.paa";
			};
		};
	};
	
	_iconType = _root + _iconType;
	_iconType
};




//-- FUNCTION DELETES MARKER ONLY IF IT IS NO LONGER NEEDED BY ANY UNIT
A3C_DELETE_MARKER = { //~~ currently used / unused?
	private ["_delete","_data","_marker"];
	_marker = _this select 0;
	_unit = _this select 1;
	_vari = _this select 2;
	//_data = _unit getvariable "A3C_PLOT";
	_otherUnits = (units group player) - [player,_unit];
	_delete = true;
	_data = [];
	{
		_soldier = _x;
		{
			private _var = _x;
			_data = _soldier getvariable _var;
			{
				if (_marker in (_x select 1)) then {
					if (_var == "A3C_PLOT") then {
						//if ( ((_soldier getVariable "A3C_CURRENTWAYPOINT_INDEX") -1) <= _foreachIndex) then {
							if !(_x select 6) then {
								_delete = false
							};
						//};

					} else {
						_delete = false
					};
				};
			} foreach _data;
		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
	} foreach _otherUnits;
	if (_delete) then {
		A3C_MARKERS = (A3C_MARKERS - [_marker]);
		deletemarkerLocal _marker;
		//systemchat format ["deletemarker %1",time];
	};
};

//----------------------  D I A L O G   I N P U T :   B U T T O N  F U N C T I O N S  ---------------
//---------------------------------------------------------------------------------------------------


//-- switch unit page in dialog and radial
//-- Author Note: Move to A3C_init
A3C_SWITCHPAGE_TABLET = {
	_mode = _this select 0;
	_amount = _this select 1;
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	private _hcAll = A3C_HC_getAllGroups_Player_Current;
	if (!isNull findDisplay 100040) then {
		_a3c_dsp = 100040;
	};
	//ddddd
	if !(isnull (findDisplay _a3c_dsp)) then {
		{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	};
	_groupCount =  if (A3C_MAP_CommandMode == "HIGHCOMMAN") then {count _hcAll} else {};
	_groupCount = 0;
	if (_a3c_dsp == 100040) then {
		_groupCount = count _hcAll;
	} else {
		if (A3C_MAP_CommandMode == "HC") then {
			_groupCount = count _hcAll;
		} else {
			_groupCount = (count(profileNamespace getvariable "A3C_GROUPUNITS")) -1 ;
		};
	};

	_switchPages = false;

	if (_mode == "next") then {
		if (_groupCount > ((A3C_BUTTONPAGE_TABLET + 1) * _amount)) then {
			A3C_BUTTONPAGE_TABLET = A3C_BUTTONPAGE_TABLET + 1;
			_switchPages = true;
		};
	} else {
		if (A3C_BUTTONPAGE_TABLET > 0) then {
			A3C_BUTTONPAGE_TABLET = A3C_BUTTONPAGE_TABLET - 1;
			_switchPages = true;
		};
	};
	if (_switchPages) then {
		if (_a3c_dsp == 100040) then {
			if !(isnull (findDisplay 100040)) then {
				//[] call A3C_RD_LABEL_SELECTORS;
			};
		} else {
			if !(isnull (findDisplay _a3c_dsp)) then {
				//[A3C_MAP_CommandMode] call A3C_LABEL_SELECTORS;
			};
		};


	};
};

//-- function for the cancel button. Reverts and deletes all orders/data created in planning stage
A3C_Btn_fnc_Cancel = {
	private ["_mode","_a3c_dsp"];
	_mode = if (count _this > 0) then {_this select 0} else {0};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	if !(currentWeapon player == A3C_WeaponCurr) then {
		player selectWeapon A3C_WeaponCurr;
	};
	//(findDisplay _a3c_dsp) closeDisplay 0;
	if (_mode == 0) then {
		[_a3c_dsp] call A3C_UI_MAP_FNC_CloseMapOverlay;
	};
	if (_a3c_dsp == 100030) then {
		(findDisplay _a3c_dsp) closeDisplay 0; //~~~~ YOU MESSY BOY, CLEAN THIS SHIT UP WILL U? make coherent modes.
	};
};



A3C_MAP_DelLoopObs = {
	//-- this function cancels the dragging of LookDir arrows and AIC-waypointarrows while setting them
	//-- executes when mouse is dragged into map controls
	//~~ this whole solution is sloppy, there has to be a better way  || ~~ is this still true? yes, just pausing would be better. But that's complex.

	A3C_BOOL_MAP_MU = true;
	if (A3C_BOOL_MAP_MD) then {
		A3C_BOOL_MAP_MD = false;
		if (A3C_BOOL_DRAGLINE) then {
			[0,0,0,0,false,false,false] spawn A3C_UI_MAP_onOnMouseButtonUp_Overlay;
		};
	};
};




//A3C_Timeout_Setting = 0;
A3C_BTN_FNC_COND = {
	params ["_mode","_shift"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	private ["_a3c_dsp","_goCode"];
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	switch (A3C_TEMP_CONDITION select 0) do {
		case ("NONE") : {
			if (_mode ==  0) then {
				A3C_TEMP_CONDITION = ["TIMEOUT",A3C_TIMEOUT_VAL]; //-- TIMEOUT
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText 'A3C_CORE\ui\pictures\icon_menu_condition_Timer.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: TIMEOUT (LMB to cycle through options)';
				((findDisplay _a3c_dsp) displayCtrl 7008) ctrlSetText '(';
				{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			} else {
				A3C_TEMP_CONDITION = ["GOCODE","D"];
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText 'A3C_CORE\ui\pictures\icon_menu_gocode_D.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: GoCode D (LMB to cycle through options)';
				//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
				{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			};
		};
		case ("TIMEOUT") : {
			if (_mode ==  0) then {
				A3C_TEMP_CONDITION = ["GOCODE","A"];
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText 'A3C_CORE\ui\pictures\icon_menu_gocode_A.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: GoCode A (LMB to cycle through options)';
				//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
			} else {
				A3C_TEMP_CONDITION = ["NONE","NONE"];
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlsettext 'A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: NONE (LMB to cycle through options)';
			};
			{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
		};
		case ("GOCODE") : {
			private ["_goCode"];
			_goCode = (A3C_TEMP_CONDITION select 1);
			A3C_TEMP_CONDITION = switch (_goCode) do {
				case ("NONE") : {if (_mode ==  0) then {["GOCODE","A"]} else {["GOCODE","D"]}};
				case ("A") : {if (_mode ==  0) then {["GOCODE","B"]} else {["TIMEOUT",A3C_TIMEOUT_VAL]}};
				case ("B") : {if (_mode ==  0) then {["GOCODE","C"]} else {["GOCODE","A"]}};
				case ("C") : {if (_mode ==  0) then {["GOCODE","D"]} else {["GOCODE","B"]}};
				case ("D") : {if (_mode ==  0) then {["NONE","NONE"]} else {["GOCODE","C"]}};
			};
			//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^'; // ~~ sloppy
			{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
			if (A3C_TEMP_CONDITION select 0 == "GOCODE") then {
				private ["_img","_toolTip"];
				_img = ('A3C_CORE\ui\pictures\icon_menu_gocode_' + (A3C_TEMP_CONDITION select 1) + '.paa');
				_toolTip = ( 'WP Condition: GoCode ' + (A3C_TEMP_CONDITION select 1) + ' (LMB to cycle through options)' );
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText _img;
			} else {
				if (_mode == 0) then {
					((findDisplay _a3c_dsp) displayCtrl 7022) ctrlsettext 'A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa';
					((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: NONE (LMB to cycle through options)';
				} else {
					A3C_TEMP_CONDITION = ["TIMEOUT",A3C_TIMEOUT_VAL]; //-- TIMEOUT
					((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText '\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa';
					((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: TIMEOUT (LMB to cycle through options)';
					//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlSetText '(';
					{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
				};
			};

		};
	};
};


A3C_BTN_FNC_TEAMCOLOR = {
	private ["_unitArray","_units","_cond","_switch"];

	_teamColor = _this select 0;
	_shift = _this select 1;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};


	private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
	_CT_TREE tvSetCurSel [-1];

	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	if !(_shift) then {A3C_SELECTED_UNITS = []};
	//A3C_SELECTED_UNITS = [];
	_unitNumber = 0;
	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS") - [player];
	_units = [];
	{
		private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		if (_assignedTeam == _teamColor) then {
			if (!isPlayer _x) then {
				_units pushback _x;
			};
		};
	} foreach _unitArray;
	if (_teamColor == "PURPLE") then {
		_units = (profileNamespace getvariable "A3C_GROUPUNITS") - [player];
		{
			if (isPlayer _x) then {_units = _units - [_x]};
		} foreach _units;
	};
	/*
	{
		private ["_remove"];
		_remove = false;
		if !(_x == (driver (vehicle _x))) then {_remove = true};
		if (A3C_MAP_CommandMode == 'AIR') then {
			if !((vehicle _x) isKindOf "AIR") then {_remove = true};
		} else {
			if ((vehicle _x) isKindOf "AIR") then {_remove = true};
		};
		if (_remove) then {_units = _units - [_x]};
	} foreach _units;
	*/

	_count = ({_x in A3C_SELECTED_UNITS} count _units);
	if (_count == (count _units)) then {
		{
			A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
			call compile format ["A3C_UNIT_%1_BV = 0",(_forEachIndex + 1)];
		} forEach _units;
	} else {
		{
			if (_x == (driver vehicle _x)) then {
				if (!isPlayer _x) then {
					A3C_SELECTED_UNITS pushbackUnique _x;
					call compile format ["A3C_UNIT_%1_BV = 1",(_forEachIndex + 1)];
				} else {
					systemchat format ["A3C: %1 is controlled by a player and will not be selected",name _x];
				};
			};
		} forEach _units;
	};
	_switch = false;
	if (_teamColor == "PURPLE") then {
		_cond = {};
		switch (A3C_MAP_CommandMode) do {
			case ("INF") : {
				_cond = {_return = typeOf (vehicle _this) iskindOf "AIR"; _return};
			};
			case ("AIR") : {
				_cond = {_return = !(typeOf (vehicle _this) iskindOf "AIR"); _return};
			};
			case ("HC") : {
				_switch = true;
			};
		};
		if !(_switch) then {
			{
				if (_x call _cond) then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
				};
			} foreach A3C_SELECTED_UNITS;
		};
	} else {
		_switch = true;
	};
	if (_switch) then {
		if (({(_x == (driver vehicle _x)) && {typeOf (vehicle _x) iskindOf "AIR"}} count A3C_SELECTED_UNITS) > ((count A3C_SELECTED_UNITS) / 2)) then {
			A3C_MAP_CommandMode = "AIR";
			//private _spacing = str A3C_SPACING_AIR;
			//if (A3C_SPACING_AIR < 10) then {
			//	_spacing = "0" + _spacing;
			//};
			//(findDisplay _a3c_dsp displayCtrl 7066) ctrlSetText _spacing;
			{
				if !(typeOf (vehicle _x) iskindOf "AIR") then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
				};
			} foreach A3C_SELECTED_UNITS;
		} else {
			{
				if (typeOf (vehicle _x) iskindOf "AIR") then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
				};
			} foreach A3C_SELECTED_UNITS;
			A3C_MAP_CommandMode = "INF";
			//private _spacing = str A3C_SPACING_INF;
			//if (A3C_SPACING_INF < 10) then {
			//	_spacing = "0" + _spacing;
			//};
			//(findDisplay _a3c_dsp displayCtrl 7066) ctrlSetText _spacing;
		};
	};
	A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
	[A3C_MAP_CommandMode] call A3C_START_TABMODE;
	[] call A3C_UNITSEL_REFRESH_UI;
};

A3C_STANCE_BTN_1 = {
	params ["_mode"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	if (A3C_MAP_CommandMode in ["INF","HC"]) then {
		switch (A3C_STANCE1_TEMP) do {
			case ("DOWN") : {
				if (_mode == 0) then {
					//-- switch to STAND
					A3C_STANCE1_TEMP = "UP";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				} else {
					//-- switch to CROUCH
					A3C_STANCE1_TEMP = "MIDDLE";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
				};
			};
			case "MIDDLE" : {
				if (_mode == 0) then {
					//-- switch to PRONE
					A3C_STANCE1_TEMP = "DOWN";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
				} else {
					//-- switch to STAND
					A3C_STANCE1_TEMP = "UP";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				};
			};
			case "UP" : {
				if (_mode == 0) then {
					//-- switch to CROUCH
					A3C_STANCE1_TEMP = "MIDDLE";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
				} else {
					//-- switch to PRONE
					A3C_STANCE1_TEMP = "DOWN";
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
				};
			};
		};
	} else {
		switch (A3C_HELIHEIGHT) do {
			case (500) : {
				if (_mode == 0) then {
					A3C_HELIHEIGHT = 200; // set to high
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
				} else {
					A3C_HELIHEIGHT = 5; // set to lowest
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
				};
			};
			case (200) : {
				if (_mode == 0) then {
					A3C_HELIHEIGHT = 25; // set to med
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
				} else {
					A3C_HELIHEIGHT = 500; // set to highest
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
				};
			};
			case (25) : {
				if (_mode == 0) then {
					A3C_HELIHEIGHT = 5; // set to lowest
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
				} else {
					A3C_HELIHEIGHT = 200; // set to high
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
				};
			};
			case (5) : {
				if (_mode == 0) then {
					A3C_HELIHEIGHT = 500; // set to highest
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
				} else {
					A3C_HELIHEIGHT = 25; // set to med
					((findDisplay _a3c_dsp) displayCtrl 7044) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
				};
			};
		};
	};

};



A3C_getActionsArray = {
	params ["_units"];
	private ["_actions","_staticData"];
	_actions = ["NONE"];

	if ({isNull objectParent _x} count _units > 0) then {
		{_actions pushBack _x} foreach ["GRENADE","SUPPRESSION"];
	};
	_staticData = [_units,"PLANNING"] call A3C_getSelectionBackpackStatics;
	if (count _staticData > 0) then {
		_actions pushbackUnique "STATIC";
	};
	if ({isnull objectParent _x && {backPack _x == ""}} count _units >= 2) then {
		_actions pushbackUnique "STATIC";
	};
	if (count _units == 1) then { //~~ CURRENTLY ONLY SINGLE SELECTIONS. WHY???
		if (({(getText (configfile >> "CfgMagazines" >> _x >> "nameSound")) in ["satchelcharge","mine"]} count magazines (_units select 0) > 0) && (isNull objectParent (_units select 0)) ) then {
			_actions pushBack "CTRL_DET";
		};
	};
	if ({!isnull objectparent _x && (_x == driver vehicle _x)} count _units > 0) then {
		{_actions pushBack _x} foreach ["CARGO_IN","CARGO_OUT"];
	};
	_actions
};


A3C_UI_MAP_SPAWN_TIMEOUTBOX = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	private _timeOutBox = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout;
	
	if (_mode == "OPEN") then {
		private _ctrlFrameOriginalY = if (_a3c_dsp == 100020) then {A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y} else {0.598968 * safezoneH + safezoneY};
		_timeOutBox ctrlSetPosition
		[
			(ctrlPosition (findDisplay _a3c_dsp displayCtrl 7022)) select 0,
			_ctrlFrameOriginalY - (1 * A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H),
			A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W,
			A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
		];
		_timeOutBox ctrlCommit 0;
		_timeOutBox ctrlShow true;
	} else {
		_timeOutBox ctrlShow false;
	};
};


//[-25] call A3C_TOGGLE_SUBSELECTION;
A3C_TOGGLE_SUBSELECTION = {

	params ["_originButton","_actionButton","_subSet","_doToggleCntrls"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};

	(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout) ctrlShow false;

	//-- re-assign STANCE2 to ACTION if on AIRCRAFT PAGE
	if (A3C_MAP_CommandMode == "AIR") then {
		if (_actionButton == "SQ_STANCE_1") then {
			_actionButton = "SQ_HELIHEIGHT";
		};
		if (_actionButton == "SQ_STANCE_2") then {
			_actionButton = "SQ_ACTION";
		};
	};

	
	private _originButtonImage = _originButton select 0;
	private _originButtonClicker = _originButton select 0;

	private _gap = 0.25;

	private _ctrlFrameOriginalY = if (_a3c_dsp == 100020) then {A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y} else {0.598968 * safezoneH + safezoneY};
	private _ctrlFrame = findDisplay _a3c_dsp displayCtrl 11;


	private _ctrlFramePos = [];


	if (_a3c_dsp == 100020) then {
		_ctrlFramePos = ctrlPosition _ctrlFrame;
	};

	private _subsetCtrl_1 = (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT);
	private _subsetCtrl_2 = (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT);


	private _shiftFactorX = 0;
	private _selectionAmount = 10;
	private _buttonImages = [];
	private _selectionAmount = 0;
	private _subsetActionStrings = [];

	private _exit = false;

	private _subsetCtrls = if (_subSet == 1) then {
		[
			[800901,800911], //-- Button 1
			[800902,800912], //-- Button 2
			[800903,800913], //-- Button 3
			[800904,800914], //-- Button 4
			[800905,800915], //-- Button 5
			[800906,800916], //-- Button 6
			[800907,800917], //-- Button 7
			[800908,800918], //-- Button 8
			[800909,800919], //-- Button 9
			[800910,800910] //-- Button 10
		]
	} else {
		[
			[801001,801011], //-- Button 1
			[801002,801012], //-- Button 2
			[801003,801013], //-- Button 3
			[801004,801014], //-- Button 4
			[801005,801015], //-- Button 5
			[801006,801016], //-- Button 6
			[801007,801017], //-- Button 7
			[801008,801018], //-- Button 8
			[801009,801019], //-- Button 9
			[801010,801020]  //-- Button 10
		]
	};
	//-- reset button controls:
	if (_subSet == 1) then {
		for "_i" from 800901 to 800910 do {
			(findDisplay _a3c_dsp displayCtrl _i) ctrlSetText "";
		};
		for "_i" from 800911 to 800920 do {
			(findDisplay _a3c_dsp displayCtrl _i) buttonSetAction "";
		};
	};
	if (_subSet == 2) then {
		for "_i" from 801001 to 801010 do {
			(findDisplay _a3c_dsp displayCtrl _i) ctrlSetText "";
		};
		for "_i" from 801011 to 801020 do {
			(findDisplay _a3c_dsp displayCtrl _i) buttonSetAction "";
		};
	};
	//-- create subset UI-data
	switch (_actionButton) do {
		case ("SQ_STANCE_1") : {

			_shiftFactorX = 0;
			_selectionAmount = 4;
			_buttonImages =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
			];
			_subsetActionStrings =
			[

				"SQ_STANCE_1_AUTO",
				"SQ_STANCE_1_STAND",
				"SQ_STANCE_1_CROUCH",
				"SQ_STANCE_1_PRONE"
			];
		};


		case ("SQ_HELIHEIGHT") : {

			_shiftFactorX = -1;
			_selectionAmount = 4;
			_buttonImages =
			[
				"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa",
				"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa",
				"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa",
				"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa"
			];
			_subsetActionStrings =
			[

				"SQ_HELIHEIGHT_MAX",
				"SQ_HELIHEIGHT_HIGH",
				"SQ_HELIHEIGHT_MID",
				"SQ_HELIHEIGHT_MIN"
			];
		};

		case ("SQ_STANCE_2") : {

			_shiftFactorX = -1;
			_selectionAmount = 4;
			_buttonImages =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
			];
			_subsetActionStrings =
			[

				"SQ_STANCE_2_AUTO",
				"SQ_STANCE_2_STAND",
				"SQ_STANCE_2_CROUCH",
				"SQ_STANCE_2_PRONE"
			];
		};




		case ("SQ_ACTION") : {

			if (Count A3C_SELECTED_UNITS == 0) exitWIth {
				_exit = true;
			};

			_actionArray = [];
			if (A3C_MAP_CommandMode == "INF") then {
				_subsetActionStrings pushbackUnique "SQ_ACTION_NONE";
				_buttonImages = ["\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa"];
				//_actionArray = [0,false,false] call A3C_BUTTON_wpFiringMode;
				_actionArray = [A3C_SELECTED_UNITS] call A3C_getActionsArray;
			};
			if (A3C_MAP_CommandMode == "AIR") then {
				_actionArray = ["SQ_AIR_MOVE","SQ_LAND_PICKUP","SQ_LAND_DROPOFF","SQ_RAPPELL","SQ_PARADROP","SQ_SLING","SQ_LAND_FULL"];
			};

			_selectionAmount = count _actionArray;
			_shiftFactorX = (( floor((count _actionArray) / 3 )) max 0) * -1;

			if ("GRENADE" in _actionArray) then {
				[0,false] call A3C_GREN_DATA;

				if !(A3C_GREN_MUZZLE == "") then {
					_buttonImages pushBackUnique (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "picture"));
				} else {
				      _buttonImages pushBackUnique "A3C_CORE\ui\pictures\icon_menu_smokeGrey.paa"
				};
				_subsetActionStrings pushbackUnique "SQ_ACTION_GRENADE";
			};
			if ("SUPPRESSION" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_SUPPRESSION";
			};
			if ("STATIC" in _actionArray) then {
				_buttonImages pushbackUnique "\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_STATIC";
			};
			if ("CTRL_DET" in _actionArray) then {
				_buttonImages pushbackUnique "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_CTRL_DET";
			};
			if ("CARGO_IN" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_CARGO_IN";
			};
			if ("CARGO_OUT" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_CARGO_OUT";
			};
			if ("SQ_AIR_MOVE" in _actionArray) then {
				_buttonImages pushbackUnique "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_AIR_MOVE";
			};
			if ("SQ_LAND_PICKUP" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_LAND_PICKUP";
			};
			if ("SQ_LAND_DROPOFF" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_LAND_DROPOFF";
			};
			if ("SQ_RAPPELL" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_RAPPELL";
			};
			if ("SQ_PARADROP" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_PARADROP";
			};
			if ("SQ_SLING" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_slingUNI.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_SLING";
			};
			if ("SQ_LAND_FULL" in _actionArray) then {
				_buttonImages pushbackUnique "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
				_subsetActionStrings pushbackUnique "SQ_ACTION_LAND_FULL";
			};
			ctrlSetFocus (findDisplay _a3c_dsp displayCtrl _originButtonClicker);

		};

		case ("SQ_ACTION_GRENADE") : {
			[0,false] call A3C_GREN_DATA;
			_buttonImages = [];
			{
				_img = (gettext (configfile >> "CfgMagazines" >> _x >> "picture"));
				_buttonImages pushback _img; //-- not using pushbackUnique because images might be shared
				_subsetActionStrings pushback _x;

			} foreach A3C_AI_GREN_ARRAY;
			//systemchat str A3C_AI_GREN_ARRAY;
			_selectionAmount = count A3C_AI_GREN_ARRAY;
			_shiftFactorX = (( floor((_selectionAmount) / 3 )) max 0) * -1;
		};

		case ("SQ_FORMATION") : {
			if (count A3C_SELECTED_UNITS < 2) then {
				_exit = true;
			};
			_shiftFactorX = -3;
			_selectionAmount = 5;
			_buttonImages =
			[
				"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa",
				"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa",
				"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa",
				"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa",
				 "\a3\ui_f\data\Map\Markers\Military\circle_ca.paa"
			];
			_subsetActionStrings =
			[

				"SUB_FORM1",
				"SUB_FORM2",
				"SUB_FORM3",
				"SUB_FORM4",
				"SUB_FORM5"
			];
		};
		case ("SQ_CONDITION") : {
			_shiftFactorX = -1;
			_selectionAmount = 6;
			_buttonImages =
			[
				"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa",
				'\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa',
				"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"
			];
			_subsetActionStrings =
			[

				"SQ_COND_NONE",
				"SQ_COND_TIMEOUT",
				"SQ_COND_GOCODE_A",
				"SQ_COND_GOCODE_B",
				"SQ_COND_GOCODE_C",
				"SQ_COND_GOCODE_D"
			];
		};
	};

	if (_exit) exitWith {
		_subsetCtrl_1 ctrlShow false;
		_subsetCtrl_2 ctrlShow false;
	};
	private _originButtonCtrl = (findDisplay _a3c_dsp displayCtrl _originButtonImage);
	private _originButtonPos = [];
	if (_subset == 1) then {
		_originButtonPos = ctrlPosition _originButtonCtrl;
	} else {
		private _parentPos = ctrlPosition (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT);
		_originButtonPos = (ctrlPosition _originButtonCtrl);
		_originButtonPos =
		[
			(_parentPos select 0) + (_originButtonPos select 0),
			(_parentPos select 1) + (_originButtonPos select 1),
			_originButtonPos select 2,
			_originButtonPos select 3
		];
	};

	//private _subsetButtonSize = ctrlPosition (findDisplay _a3c_dsp displayCtrl 800901); //-- 800901 is just the first image. we only need the size. Same for all subset buttons
	//for "_i" from 0 to 1 do {
	//	_subsetButtonSize deleteAt 0;
	//};
	//private _subsetButtonSize = [A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W, A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H] ;


//A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
	//-- create positional array for subset bar
	private _subsetBarPos =
	[
		((_originButtonPos select 0) + (_shiftFactorX * A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W)) max A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X_EXPANDED,
		_ctrlFrameOriginalY -  (A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * _subset) //(_originButtonPos select 1) - ((_subsetButtonSize select 1) + ((_subsetButtonSize select 1) * _gap)   )
		//(_subsetButtonSize select 0) * _selectionAmount,
		//(_subsetButtonSize select 1) * 2

	];
	//systemchat str _subsetBarPos;


	//-- assign button images and functions
	{
		_btn = _x;


		if (_foreachIndex < (count _buttonImages)) then {
			_actionString = _subsetActionStrings select _foreachIndex;
			_toolTip = switch (_actionString) do {

				case ("SQ_ACTION_NONE") : {
					"No Action || Use LMB to open settings or mousewheel to cycle"
				};

				case ("SQ_ACTION_GRENADE") : {
					"Throwables"
				};

				case ("SQ_ACTION_SUPPRESSION") : {
					"Suppress Area"
				};
				case ("SQ_ACTION_STATIC") : {
					"Deploy or pack Static Weapon"
				};
				case ("SQ_ACTION_CTRL_DET") : {
					"Plant Explosive"
				};
				case ("SQ_ACTION_CARGO_IN") : {
					"Pickup"
				};
				case ("SQ_ACTION_CARGO_OUT") : {
					"Dropoff"
				};
				case ("SQ_COND_NONE") : {
					"NONE"
				};
				case ("SQ_COND_TIMEOUT") : {
					"TIMEOUT"
				};
				case ("SQ_COND_GOCODE_A") : {
					"GoCode A"
				};
				case ("SQ_COND_GOCODE_B") : {
					"GoCode B"
				};
				case ("SQ_COND_GOCODE_C") : {
					"GoCode C"
				};
				case ("SQ_COND_GOCODE_D") : {
					"GoCode D"
				};
				case ("SUB_FORM1") : {
					"Orient towards looking direction"
				};
				case ("SUB_FORM2") : {
					"Orient towards looking direction +90deg"
				};
				case ("SUB_FORM3") : {
					"Orient towards looking direction -90deg"
				};
				case ("SUB_FORM4") : {
					"Split Formation (give synchronized Waypoints to units one by one"
				};
				case ("SUB_FORM5") : {
					"Circle (Drag to adjust size)"
				};
				case ("SQ_ACTION_AIR_MOVE") : {
					"Move"
				};
				case ("SQ_ACTION_LAND_PICKUP") : {
					"Pickup"
				};
				case ("SQ_ACTION_LAND_DROPOFF") : {
					"DropOff"
				};
				case ("SQ_ACTION_RAPPELL") : {
					"Rappel"
				};
				case ("SQ_ACTION_PARADROP") : {
					"Paradrop"
				};
				case ("SQ_ACTION_SLING") : {
					"Sling LOAD/DROP"
				};
				case ("SQ_ACTION_LAND_FULL") : {
					"Full Landing"
				};
				case ("SQ_HELIHEIGHT_MAX") : {
					"Max - 500m"
				};
				case ("SQ_HELIHEIGHT_HIGH") : {
					"High - 200m"
				};
				case ("SQ_HELIHEIGHT_MID") : {
					"Default - 25m"
				};
				case ("SQ_HELIHEIGHT_MIN") : {
					"Low - 5m (RISKY)"
				};
				default  {""};

			};
			if (_actionString in A3C_AI_GREN_ARRAY) then {
				//systemchat str [_actionString,_foreachIndex];
				_actionString = _subsetActionStrings select _foreachIndex;
				_toolTip = ("Throw " + (gettext (configfile >> "CfgMagazines" >> _actionString >> "displayNameShort")));
			};
			(findDisplay _a3c_dsp displayCtrl (_x select 0)) ctrlSetText (_buttonImages select _foreachIndex);
			(findDisplay _a3c_dsp displayCtrl (_x select 1)) ctrlSetTooltip _toolTip;
			(findDisplay _a3c_dsp displayCtrl (_x select 1)) buttonSetAction format
			[
				"['%1',%2,%3,%4,%5,%6,'%7'] call A3C_fnc_SUBSET",
				_actionString,
				_subSet, //-- subset row of buttons
				_a3c_dsp, //-- display used
				_originButton, //-- button array [IMG,BTN] of selection root
				_btn select 0,
				_btn select 1,
				_toolTip
			];
		};
		/*
		{
			_ctrl = findDisplay _a3c_dsp displayCtrl _x;
			_ctrlPos = ctrlPosition _ctrl;
			_ctrlPos set [2,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H];
			_ctrlPos set [3,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H];
			_ctrl ctrlSetPosition _ctrlPos;
			//_ctrl ctrlSetPositionW A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
			//_ctrl ctrlSetPositionH A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
			_ctrl ctrlCommit 0;
		} foreach _x;
		*/
	} foreach _subsetCtrls;

	//-- shortcut for button background fields
	_bg1 = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1;
	_bg2 = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2;


	if (_subSet == 1) then {
		if (_doToggleCntrls) then {
			if (ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT) && (_actionButton == A3C_LAST_SUBSET_ACTION)) then {
				_subsetCtrl_1 ctrlShow false;
				_subsetCtrl_2 ctrlShow false;
				_bg1 ctrlShow false;
				_bg2 ctrlShow false;
				_ctrlFramePos set [1,_ctrlFrameOriginalY];
			} else {
				if (ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT)) then {
					_ctrlFramePos set [1,_ctrlFrameOriginalY];
					_subsetCtrl_1 ctrlShow false;
					_subsetCtrl_2 ctrlShow false;
					_bg1 ctrlShow false;
					_bg2 ctrlShow false;
				} else {
					_subsetBarPos set [2, A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * _selectionAmount]; //-- adjust w to match button-amount
					_subsetBarPos set [3,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H];
					_ctrlFramePos set [1,_ctrlFrameOriginalY - (1 * A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H)];

					//--position bg frame
					
					_bg1 ctrlSetPosition _subsetBarPos;
					_bg1 ctrlCommit 0;
					_bg1 ctrlShow true;

					_subsetBarPos set [3,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 1.5];
					_subsetCtrl_1 ctrlSetPosition _subsetBarPos;
					_subsetCtrl_1 ctrlCommit 0;
					_subsetCtrl_1 ctrlShow true;
				};
			};
		};
	} else {
		if (_doToggleCntrls) then {
			if (ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT) && (_actionButton == A3C_LAST_SUBSET_ACTION)) then {
				_subsetCtrl_2 ctrlShow false;
				_bg2 ctrlShow false;
				_ctrlFramePos set [1,_ctrlFrameOriginalY - (1 * A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H)];;
			} else {
				_ctrlFramePos set [1,_ctrlFrameOriginalY - (2 * A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H)];
				

				//--position bg frame
				_subsetBarPos set [2, A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * _selectionAmount]; //-- adjust w to match button-amount
				_subsetBarPos set [3,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H];
				_bg2 ctrlSetPosition _subsetBarPos;
				_bg2 ctrlCommit 0;
				_bg2 ctrlShow true;

				_subsetBarPos set [3,A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 1.5];
				_subsetCtrl_2 ctrlSetPosition _subsetBarPos;
				_subsetCtrl_2 ctrlCommit 0;
				_subsetCtrl_2 ctrlShow true;


//systemChat '2';
				_subsetCtrl_2 ctrlSetPosition _subsetBarPos;
				_subsetCtrl_2 ctrlCommit 0;
			};
		};
	};
	if (_a3c_dsp == 100020) then {
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlSetPosition _ctrlFramePos;
			(findDisplay _a3c_dsp displayCtrl _x) ctrlCommit 0;
		} foreach [11];
	};
	A3C_LAST_SUBSET_ACTION = _actionButton;

};





A3C_fnc_SUBSET = {

	params ["_action","_subSet","_a3c_dsp","_originButton","_buttonImageID","_buttonClickerID","_tooltip"];
	private _originButtonImage = (findDisplay _a3c_dsp displayCtrl (_originButton select 0));
	private _originButtonClicker = (findDisplay _a3c_dsp displayCtrl (_originButton select 1));

	_bg1 = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_1;
	_bg2 = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_MAP_SUB_BG_2;

	if (_action == "SQ_COND_TIMEOUT") then {
		//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlSetText '(';
		//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
		["OPEN"] call A3C_UI_MAP_SPAWN_TIMEOUTBOX;
	} else {
		//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
		{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout];
	};


	if (_action == "SQ_ACTION_GRENADE" && A3C_GREN_MUZZLE == "") then {
		_action = "SQ_ACTION_NONE";

	};

//systemchat str _action;
	if !(_action in ["SQ_ACTION_GRENADE"]) then {
		_originButton = _originButtonImage; //~~??
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT) ctrlShow false;
		_bg1 ctrlShow false;
		_bg2 ctrlShow false;
	};

	//-- adjust cntrl frames
	if (_subset == 1 OR (_action in A3C_AI_GREN_ARRAY)) then {

		if (_a3c_dsp == 100020) then {

			private _ctrlFrameOriginalY = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y; //if (_a3c_dsp == 100020) then {0.797058 * safezoneH + safezoneY} else {}; //~~ ALERT! WHAT IS GOING ON IN TABLET? NO FRAME?
			private _ctrlFrame = if (_a3c_dsp == 100020) then {(findDisplay _a3c_dsp displayCtrl 11)} else {};

			_ctrlFramePos = ctrlPosition _ctrlFrame;
			_ctrlFramePos set [1,_ctrlFrameOriginalY];
			{
				(findDisplay _a3c_dsp displayCtrl _x) ctrlSetPosition _ctrlFramePos;
				(findDisplay _a3c_dsp displayCtrl _x) ctrlCommit 0;
			} foreach [11];
			//_ctrlFrame ctrlSetPosition _ctrlFramePos;
			//_ctrlFrame ctrlCommit 0;
		};
	};



	if (_action in A3C_AI_GREN_ARRAY) exitWith {
		_originButtonImage = findDisplay _a3c_dsp displayCtrl 7064;
		_originButtonClicker = findDisplay _a3c_dsp displayCtrl 7065;
		_originButtonImage ctrlSetText (gettext (configfile >> "CfgMagazines" >> _action >> "picture"));
		_originButtonClicker ctrlSetToolTip _toolTip;
		//systemchat str [_action];
		A3C_TEMP_ACTION = ["GRENADE",_action];
		A3C_GREN_MUZZLE = _action;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT) ctrlShow false;
		_bg1 ctrlShow false;
		_bg2 ctrlShow false;

	};

	if (["SUB_FORM",_action] call BIS_fnc_instring) exitWith {
		_buttonImages =
		[
			"IamJustHereToreresentIndex0",
			"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa",
			 "\a3\ui_f\data\Map\Markers\Military\circle_ca.paa"
		];
		_formID = parseNumber ((_action splitstring "SUB_FORM") select 0);
		A3C_FORMMODE_TEMP = _formID;
		A3C_SPLIT_UNITS = if (_formID == 4) then {A3C_SELECTED_UNITS} else {[]};
		_originButtonImage ctrlSetText (_buttonImages select _formID);
		_originButtonClicker ctrlSetToolTip _toolTip;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT) ctrlShow false;
		_bg1 ctrlShow false;
		_bg2 ctrlShow false;

	};


	switch (_action) do {
		case ("SQ_ACTION_NONE") : {
			_originButtonImage ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			_originButtonClicker ctrlSetToolTip _toolTip;
			A3C_TEMP_ACTION = ["NONE","NONE"];
		};
		case ("SQ_ACTION_GRENADE") : {
			[[_buttonImageID,_buttonClickerID],"SQ_ACTION_GRENADE",2,true] call A3C_TOGGLE_SUBSELECTION;
		};

		case ("SQ_HELIHEIGHT_MAX") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
			A3C_HELIHEIGHT= 500; //,200,25,5
		};
		case ("SQ_HELIHEIGHT_HIGH") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
			A3C_HELIHEIGHT= 200; //,200,25,5
		};
		case ("SQ_HELIHEIGHT_MID") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
			A3C_HELIHEIGHT= 25; //,200,25,5
		};
		case ("SQ_HELIHEIGHT_MIN") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
			A3C_HELIHEIGHT= 5; //,200,25,5
		};



		case ("SQ_ACTION_AIR_MOVE") : {
			_originButtonImage ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: MOVE/NONE || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["LANDING","NONE"];
		};
		case ("SQ_ACTION_LAND_PICKUP") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: PICKUP || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["LANDING","PICKUP"];
		};
		case ("SQ_ACTION_LAND_DROPOFF") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: DROPOFF || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["LANDING","DROPOFF"];
		};
		case ("SQ_ACTION_RAPPELL") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: RAPPEL || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["LANDING","RAPPEL"];
		};
		case ("SQ_ACTION_PARADROP") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: PARADROP || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["PARADROP","PARADROP"];
		};
		case ("SQ_ACTION_SLING") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: SLING LOAD/DROP || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["SLINGLOAD","SLINGLOAD"];
		};

		case ("SQ_ACTION_LAND_FULL") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
			_originButtonClicker ctrlSetToolTip "WP ACTION: FULL LANDING || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["LANDING","LANDFINAL"];
		};

		case ("SQ_ACTION_SUPPRESSION") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
			_originButtonClicker ctrlSetToolTip "Suppress Area || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["SUPPRESSION",""];
			if (A3C_TEMP_CONDITION select 0 == "NONE") then {
				(findDisplay _a3c_dsp displayCtrl 7022) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
				(findDisplay _a3c_dsp displayCtrl 7007) ctrlSetToolTip "WP Condition: GoCode D || Use LMB to open selection or mousewheel to cycle";
				A3C_TEMP_CONDITION = ["GOCODE","D"];
			};
		};
		case ("SQ_ACTION_STATIC") : {
			_originButtonImage ctrlSetText "\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";
			_originButtonClicker ctrlSetToolTip "Pack or unpack static weapon || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["STATIC",[]];
		};
		case ("SQ_ACTION_CTRL_DET") : {
			_originButtonImage ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
			_originButtonClicker ctrlSetToolTip "Plant Explosive || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["CTRL_DET",[objNull,""]];
		};
		case ("SQ_ACTION_CARGO_IN") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
			_originButtonClicker ctrlSetToolTip "Pickup || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["CARGO_IN","PICKUP"];
		};
		case ("SQ_ACTION_CARGO_OUT") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
			_originButtonClicker ctrlSetToolTip "Dropoff || Use LMB to open settings or mousewheel to cycle";
			A3C_TEMP_ACTION = ["CARGO_OUT",""];
		};

		case ("SQ_STANCE_1_AUTO") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";
			_originButtonClicker ctrlSetToolTip "TravelStance: AUTO || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE1_TEMP = "AUTO";
		};
		case ("SQ_STANCE_1_STAND") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
			_originButtonClicker ctrlSetToolTip "TravelStance: STAND || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE1_TEMP = "UP";

		};
		case ("SQ_STANCE_1_CROUCH") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
			_originButtonClicker ctrlSetToolTip "TravelStance: CROUCH || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE1_TEMP = "MIDDLE";
		};
		case ("SQ_STANCE_1_PRONE") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
			_originButtonClicker ctrlSetToolTip "TravelStance: PRONE || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE1_TEMP = "DOWN";
		};

		case ("SQ_STANCE_2_AUTO") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";
			_originButtonClicker ctrlSetToolTip "EndStance: AUTO || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE2_TEMP = "AUTO";
		};
		case ("SQ_STANCE_2_STAND") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
			_originButtonClicker ctrlSetToolTip "EndStance: STAND || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE2_TEMP = "UP";
		};
		case ("SQ_STANCE_2_CROUCH") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
			(findDisplay _a3c_dsp displayCtrl 7047) ctrlSetToolTip "EndStance: CROUCH || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE2_TEMP = "MIDDLE";
		};
		case ("SQ_STANCE_2_PRONE") : {
			_originButton ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
			_originButtonClicker ctrlSetToolTip "EndStance: PRONE || Use LMB to open selection or mousewheel to cycle";
			A3C_STANCE2_TEMP = "DOWN";
		};

		case ("SQ_COND_NONE") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";
			_originButtonClicker ctrlSetToolTip "WP Condition: NONE || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["NONE","NONE"];
		};
		case ("SQ_COND_TIMEOUT") : {
			_originButtonImage ctrlSetText '\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa';
			_originButtonClicker ctrlSetToolTip "WP Condition: TIMEOUT || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["TIMEOUT",A3C_TIMEOUT_VAL]; //-- TIMEOUT
		};
		case ("SQ_COND_GOCODE_A") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
			_originButtonClicker ctrlSetToolTip "WP Condition: GoCode A || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["GOCODE","A"];
		};
		case ("SQ_COND_GOCODE_B") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
			_originButtonClicker ctrlSetToolTip "WP Condition: GoCode B || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["GOCODE","B"];
		};
		case ("SQ_COND_GOCODE_C") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
			_originButtonClicker ctrlSetToolTip "WP Condition: GoCode C || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["GOCODE","C"];
		};
		case ("SQ_COND_GOCODE_D") : {
			_originButtonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
			_originButtonClicker ctrlSetToolTip "WP Condition: GoCode D || Use LMB to open selection or mousewheel to cycle";
			A3C_TEMP_CONDITION = ["GOCODE","D"];
		};
	};
};



A3C_STANCE_BTN_2 = {
	params ["_mode"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	if (A3C_MAP_CommandMode in ["INF","HC"]) then {
		switch (A3C_STANCE2_TEMP) do {
			case ("DOWN") : {
				if (_mode == 0) then {
					A3C_STANCE2_TEMP = "UP";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "STAND";
				} else {
					A3C_STANCE2_TEMP = "MIDDLE";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "CROUCH";
				};
			};
			case "MIDDLE" : {
				if (_mode == 0) then {
					A3C_STANCE2_TEMP = "DOWN";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "PRONE";
				} else {
					A3C_STANCE2_TEMP = "UP";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "STAND";
				};
			};
			case "UP" : {
				if (_mode == 0) then {
					A3C_STANCE2_TEMP = "MIDDLE";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "CROUCH";
				} else {
					A3C_STANCE2_TEMP = "DOWN";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "PRONE";
				};
			};
		};
		((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,0.6];
	} else {
		switch (A3C_TEMP_ACTION select 1) do {
			case ("NONE") : {
				if (_mode == 0) then {
					//-- set to PICKUP
					A3C_TEMP_ACTION = ["LANDING","PICKUP"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "PICKUP";
				} else {
					//-- set to LAND FINAL
					A3C_TEMP_ACTION = ["LANDING","LANDFINAL"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "LAND";
				};
			};
			case ("PICKUP") : {
				if (_mode == 0) then {
					//-- set to DROPOFF
					A3C_TEMP_ACTION = ["LANDING","DROPOFF"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "DROPOFF";
				} else {
					//-- set to NONE
					A3C_TEMP_ACTION = ["LANDING","NONE"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_Color_setOpacity); //[0.5,0.5,0.5,0.6];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "MOVE";
				};
			};
			case ("DROPOFF") : {
				if (_mode == 0) then {
					if (A3C_IsRappel) then {
						//-- set to RAPPELL
						A3C_TEMP_ACTION = ["LANDING","RAPPEL"];
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
						((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "RAPPEL";
					} else {
						//-- set to SLINGLOAD
						A3C_TEMP_ACTION = ["SLINGLOAD","SLINGLOAD"];
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
						((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "Sling Load/Drop";
					};
				} else {
					//-- set to PICKUP
					A3C_TEMP_ACTION = ["LANDING","PICKUP"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "PICKUP";
				};
			};
			case ("RAPPEL") : {
				if (_mode == 0) then {
					//-- set to PARADROP
					A3C_TEMP_ACTION = ["PARADROP","PARADROP"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "Para-Drop";
				} else {
					//-- set to DROPOFF
					A3C_TEMP_ACTION = ["LANDING","DROPOFF"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "DROPOFF";
				};
			};
			case ("PARADROP") : {
				if (_mode == 0) then {
					//-- set to SLINGLOAD
					A3C_TEMP_ACTION = ["SLINGLOAD","SLINGLOAD"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "Sling Load/Drop";
				} else {
					if (A3C_IsRappel) then {
						//-- set to RAPPELL
						A3C_TEMP_ACTION = ["LANDING","RAPPEL"];
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
						((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "RAPPEL";
					} else {
						//-- set to DROPOFF
						A3C_TEMP_ACTION = ["LANDING","DROPOFF"];
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
						((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
						((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "DROPOFF";
					};
				};
			};
			case ("SLINGLOAD") : {
				if (_mode == 0) then {
					//-- set to LAND FINAL
					A3C_TEMP_ACTION = ["LANDING","LANDFINAL"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "LAND";
				} else {
					//-- set to PARADROP
					A3C_TEMP_ACTION = ["PARADROP","PARADROP"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "Para-Drop";
				};
			};
			case ("LANDFINAL") : {
				if (_mode == 0) then {
					//-- set to NONE
					A3C_TEMP_ACTION = ["LANDING","NONE"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.8] call A3C_UI_Color_setOpacity); //[0.5,0.5,0.5,0.6];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "MOVE";
				} else {
					//-- set to SLINGLOAD
					A3C_TEMP_ACTION = ["SLINGLOAD","SLINGLOAD"];
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
					((findDisplay _a3c_dsp) displayCtrl 7046) ctrlSetTextColor [1,1,1,1];
					((findDisplay _a3c_dsp) displayCtrl 7047) ctrlsetToolTip "Sling Load/Drop";
				};
			};
		};
	};
};
A3C_BUTTON_CMODE = {
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	switch (A3C_CMODE_TEMP) do {
		case (0) : {
			A3C_CMODE_TEMP = 1;
			(findDisplay _a3c_dsp displayCtrl 7062) ctrlSetTextColor [0.52,0.78,0.97,0.6];
			(findDisplay _a3c_dsp displayCtrl 7063) ctrlSetToolTip "WP Combat-Mode: Disengage";
		};
		case (1) : {
			A3C_CMODE_TEMP = 0;
			(findDisplay _a3c_dsp displayCtrl 7062) ctrlSetTextColor [1,1,1,1];
			(findDisplay _a3c_dsp displayCtrl 7063) ctrlSetToolTip "WP Combat-Mode: Default/Engage";
		};
	};
};




A3C_GROUND_ACTIONS = ["NONE","GRENADE","SUPPRESSION"];
A3C_GROUND_ACTIONS_INDEX = 0;
//A3C_BUTTON_SHIFT = false;
A3C_BUTTON_wpFiringMode = {
	params ["_mode","_shift","_doExecute"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	if ((count A3C_SELECTED_UNITS == 0)) exitWith {};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	private _actions = [];
	//if !(A3C_BUTTON_SHIFT) then {



		(findDisplay _a3c_dsp displayCtrl 7064) ctrlSetTextColor [1,1,1,1];
		_actions = [A3C_SELECTED_UNITS] call A3C_getActionsArray;

		if !(_doExecute) exitWith {
			//systemchat 'exit';
		};

		//systemchat 'firingmode1';;

		private _index = 	[A3C_TEMP_ACTION select 0,_actions] call MCSS_fnc_GetArrayIndex,
		if (_mode == 0) then {
			if (_index == ((count _actions) - 1) ) then {
				_index = 0;
			} else {
				_index = _index + 1;
			};
		} else {
			if (_index == 0) then {
				_index = ((count _actions) - 1);
			} else {
				_index= _index - 1;
			};
		};

		_sel = if (_index >= 0) then {_actions select _index} else {"NONE"};
		//systemchat str _index;
		switch (_sel) do {
			case ("NONE") : {
				//-- switches to OFF
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "No Action || Use LMB to open settings or mousewheel to cycle";
				A3C_TEMP_ACTION = ["NONE","NONE"]; //~~ WHEN MORE ACTIONS ARE IN PLACE, ENGAGE THIS!
			};
			case ("GRENADE") : {
				//-- switches GREN ON
				A3C_TEMP_ACTION = ["GRENADE",A3C_GREN_MUZZLE];
				[0] call A3C_GREN_DATA;
			};
			case ("SUPPRESSION") : {
				//-- switches to SUPRESSION
				A3C_TEMP_ACTION = ["SUPPRESSION",""];
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlSetTextColor [1,0,0,1];
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Suppress Area || Use LMB to open settings or mousewheel to cycle";
			};
			case ("CARGO_IN") : {
				//-- switches to Cargo In
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Load Vehicle || Use LMB to open settings or mousewheel to cycle";
				A3C_TEMP_ACTION = ["CARGO_IN","PICKUP"];
			};
			case ("CARGO_OUT") : {
				//-- switches to Cargo Out
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Unload Vehicle || Use LMB to open settings or mousewheel to cycle";
				A3C_TEMP_ACTION = ["CARGO_OUT",""];
			};
			case ("CTRL_DET") : {
				//-- switches to Controlled Detonation
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Plant Explosive (Trigger via Radial) || Use LMB to open settings or mousewheel to cycle";
				A3C_TEMP_ACTION = ["CTRL_DET",[objNull,""]];
			};
			case ("STATIC") : {
				//-- switches to Static Weapon (Smart Detect)
				(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";
				(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "Deploy or Pack Static Weapon || Use LMB to open settings or mousewheel to cycle";
				A3C_TEMP_ACTION = ["STATIC",[]];
			};
		};
	//} else {
	//	if ((A3C_TEMP_ACTION select 0) == "GRENADE") then {
	//		[1] call A3C_GREN_DATA;
	//	};

	//};
	_actions
};


A3C_SPEED_BTN = {
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	if (A3C_WP_SPEED_TEMP == (-1) ) then {
		A3C_WP_SPEED_TEMP = 2;
		((findDisplay _a3c_dsp) displayCtrl 7048) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
	} else {
		A3C_WP_SPEED_TEMP = -1;
		((findDisplay _a3c_dsp) displayCtrl 7048) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
	};


};

A3C_BUTTON_FORMMODE = {
	params ["_mode"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	switch (A3C_FORMMODE_TEMP) do {
		case (0) : {};
		case (1) : {
			if (_mode == 0) then {
				A3C_FORMMODE_TEMP = 2;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa";
			} else {
				A3C_FORMMODE_TEMP = 5;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "\a3\ui_f\data\Map\Markers\Military\circle_ca.paa";
				A3C_SPLIT_UNITS = [];
			};
			A3C_SPLIT_UNITS = [];
		};
		case (2) : {
			if (_mode == 0) then {
				A3C_FORMMODE_TEMP = 3;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa";
			} else {
				A3C_FORMMODE_TEMP = 1;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";
			};
			A3C_SPLIT_UNITS = [];
		};
		case (3) : {
			if (_mode == 0) then {
				A3C_FORMMODE_TEMP = 4;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_split.paa";
				A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
			} else {
				A3C_FORMMODE_TEMP = 2;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa";
				A3C_SPLIT_UNITS = [];
			};
		};
		case (4) : {
			if (_mode == 0) then {
				A3C_FORMMODE_TEMP = 5;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "\a3\ui_f\data\Map\Markers\Military\circle_ca.paa";
			} else {
				A3C_FORMMODE_TEMP = 3;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa";
			};
			A3C_SPLIT_UNITS = [];
		};
		case (5) : {
			if (_mode == 0) then {
				A3C_FORMMODE_TEMP = 1;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa";
				A3C_SPLIT_UNITS = [];
			} else {
				A3C_FORMMODE_TEMP = 4;
				((findDisplay _a3c_dsp) displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_split.paa";
				A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
			};
		};
	};
};





A3C_BTN_FNC_NOSHIFT = { //-- currently unnused?
	_unitIndex = _this select 0;
	_unit = ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitIndex + 1));
	if (isPlayer _unit) exitWith {
		systemchat format ["A3C: %1 is controlled by a player and will not be selected",name _unit];
	};
	_button = _unit getvariable 'A3C_Unt_Btn';
	_unitNumber = 0;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};

	A3C_UNITCOUNT = ((count (units group player)) -1);
	for "_i" from 25 to 40 do {
		_unitNumber = (_i - 24);
		if (_unitNumber <= ( (count (profileNamespace getvariable "A3C_GROUPUNITS")) -1) ) then {
			if !(_i == _unitIndex) then {
				if (!isnull ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitNumber )) ) then {
					if (alive ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitNumber )) ) then {

						call compile format ["

							switch (A3C_MAP_CommandMode) do {
								case ('INF') : {
									if ( (%2 == driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
										if !((vehicle %2) isKindOf 'AIR') then {
											((findDisplay _a3c_dsp) displayCtrl (7024 + %1) ) ctrlSetTextColor [1,1,1,0.5];
											A3C_UNIT_%1_BV = 0;
										};
									};
								};
								case ('AIR') : {
									if ( (%2 == driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
										if ((vehicle %2) isKindOf 'AIR') then {
											((findDisplay _a3c_dsp) displayCtrl (7024 + %1) ) ctrlSetTextColor [1,1,1,0.5];
											A3C_UNIT_%1_BV = 0;
										};
									};
								};

							};

						",_unitNumber,((profileNamespace getvariable "A3C_GROUPUNITS") select _unitnumber)];
					};
				};
			};
		};
	};
};

A3C_BTN_HC = {

	private ["_isHighCommand","_isLoop","_loopPos","_loopDest","_params"];

	_mode = _this select 0;
	_groups = if ((count _this) > 1) then {_this select 1} else {A3C_HC_getAllGroups_Player_Current };
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	_unit = objnull;
	//~~ below is not bulletproof! what if AICOmmand, but not synced to module
	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	_units = [];
	_params = [];
	_isLoop = false;
	_loopPos = [0,0,0];
	_loopDest = [0,0,0];
	if ( (_mode == 0) && ((count A3C_SELECTED_UNITS) == 0)) exitwith {};
	if ( (_mode == 0) && (A3C_MAP_CommandMode == "HC") ) exitwith {};
	if ( (_mode == 1) && ((count A3C_HC_getAllGroups_Player_Current ) == 0)) exitwith {};
	if ( (_mode == 1) && A3C_BOOL_REJOINING) exitwith {};
	_data = [];
	_fnc_Tracker = {
		private ["_group","_marker"];
		_group = _this select 0;
		_a3c_dsp = if (visibleMap) then {100020} else {100030};
		_marker = _this select 1;
		{
			_x setvariable ["A3C_TRACKEDGROUPMARK",_marker,false];
		} foreach units _group;
		if ( ((side _group) getFriend (side player)) < 0.6) then {
			A3C_TRACKER_ENEMYGROUPS pushback _group;
		};
		while {!(isnull (finddisplay _a3c_dsp))} do {
			if ({alive _x} count units _group == 0) exitwith {deletemarkerLocal _marker};
			if ((side (leader _group)) == (side player)) then {
				_marker setMarkerPosLocal (position (leader _group));
			};
			sleep 0.1;
		};
	};
	//{(vehicle _x) setvehicleLock "LOCKED"} foreach units group player;
	_unitArray = profileNamespace getvariable "A3C_GROUPUNITS";

	if (_mode == 0) then {
		// disband units
		_units = A3C_SELECTED_UNITS;
		{
			_sl = _x;
			if !(_x in A3C_SELECTED_UNITS) then {
				if ( ({_sl in (vehicle _x)} count A3C_SELECTED_UNITS) > 0) then {
					if !(_x in (vehicle player)) then {
						_units pushback _sl;
					};
				};
			};
		} foreach (units group player) - [player];
		_newgroup = creategroup (side player);
		private _disbandedPhonetics = []; //A3C_HC_DISBANDED; //; //
		{
			if (["A3C-",groupID _x] call BIS_fnc_instring) then {
				_disbandedPhonetics pushBackUnique _x;
			};
		} foreach A3C_HC_getAllGroups_Player_Current;
		_newGroup setGroupIDGlobal [ format ["A3C-%1",[(count _disbandedPhonetics + 1) max 1] call A3C_HC_getPhonetic] ];
		_unit = (A3C_SELECTED_UNITS select 0);
		_loopPos = position _unit;
		{
			_candidate = _x;

			{
				if (_x == _candidate) then {
					_unitarray set [_forEachIndex,objnull];
				};
			} foreach _unitarray;
			deletemarkerlocal (_x getvariable 'A3C_TAB_MARKER'); //~~ HCWP ALERT
			{_unit setVariable [_x,false]} foreach ["A3C_HOLD","A3C_HOLD_COVER"];
		} foreach _units;
		_units joinsilent _newGroup;

		A3C_HC_DISBANDED pushback _newgroup;
		_newGroup setvariable ["d_do_not_delete",true,true];
		if (_isHighCommand) then {
			player groupchat "Group Added To High Command";
			player hcSetGroup [_newgroup,"HQ","teamred"];
		} else {
			//~~ HCWP ALERT
			/*
			call compile format
			[
				"
					A3C_HC_GP_MARKER_%1 = createmarkerLocal ['A3C_HC_GP_MARKER_%1', %2];
					'A3C_HC_GP_MARKER_%1' setMarkerTypeLocal '%3';
					'A3C_HC_GP_MARKER_%1' setMarkerSizeLocal [1,0.5];
					'A3C_HC_GP_MARKER_%1' setMarkerColorLocal 'ColorBlufor';
					'A3C_HC_GP_MARKER_%1' setMarkerAlphaLocal 0.5;
					[_newGroup,'A3C_HC_GP_MARKER_%1'] spawn _fnc_tracker;
					A3C_TRACKER_MARKERS pushback 'A3C_HC_GP_MARKER_%1';
				",
				(count A3C_TRACKER_MARKERS),
				position (leader _newGroup),
				[_newGroup] call MCSS_fnc_ICONTYPE
			];
			*/
		};

		[(units group player) - [player]] call A3C_GROUP_RESET;

		while {(count (waypoints _newGroup)) > 1} do {
			{
				if (_forEachIndex > 0) then {
					deletewaypoint _x;
				};
			} foreach waypoints _newGroup;
		};

		if (count (_unit getvariable "A3C_PLOT") > 0) then {
			{
				_wpd = _x;
				_wpD params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				private ["_timeOut","_landingData"];
				_params = [];
				_timeout = if (_wpAction select 0 == "TIMEOUT") then {_wpAction select 1} else {0};
				_landingData = if (_wpAction select 0 == "LANDING") then {_wpAction select 1} else {"NONE"};
				if (_foreachIndex == 0) then {
					[
						_newGroup,
						(position (leader _newGroup)),
						[],
						"MOVE",
						[
							0,
							_timeOut,
							_wpStances select 0,
							_wpStances select 1,
							_wpSpeed,
							"NONE"
						],
						false
					] call A3C_HC_ADD_WP; //-- "NONE" is landingData
				};
				if (_forEachIndex >= ((_unit getvariable "A3C_CURRENTWAYPOINT_INDEX") - 1)) then {
					_params =
					[
						_newGroup,
						((_x select 0) select 0),
						[],
						"MOVE",
						[
							0,
							_timeOut,
							_wpStances select 0,
							_wpStances select 1,
							_wpSpeed,
							_landingData
						]
					];
					if (_wpLoopValue < -1) then {
						_isLoop = true;
						_loopPos = (_x select 0);

					};
					if (_wpLoopValue > -1) then {
						_loopDest = (_x select 0);
					};
					if (_isLoop) then {_params pushback true};
					_params call A3C_HC_ADD_WP;
					/*
					switch (_wpAction select 1) do {
						case ("DROPOFF") : {
							_wp setwaypointType "TR UNLOAD"; AUTHOR NOTE: _wp doesn't adress anything anymore!!, include in ADD_WP
						};
						case ("PICKUP") : {
							_wp setwaypointType "TR UNLOAD";
						};
						case ("LANDFINAL") : {
							_wp setwaypointType "TR UNLOAD";
							_wp setWaypointStatements [((waypointStatements _wp) select 0), (((waypointStatements _wp) select 1) + " {player action ['engineOff', vehicle _x]} foreach thislist; ")];
						};
					};
					*/
				};
			} foreach (_unit getvariable "A3C_PLOT");
			if (_isLoop) then {
				[
					_newGroup,
					([_loopPos,5,([_loopPos,_loopDest] call BIS_fnc_Dirto)] call BIS_fnc_Relpos),
					[],
					"CYCLE"
				] call A3C_HC_ADD_WP;
			};
			[_newGroup,0] setWaypointPosition [_loopPos,0];
		} else {
			_newGroup setVariable ["AIC_Waypoints",[0,[]],true];
			//{[_x,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler} foreach (missionNamespace getVariable ["AIC_Group_Controls",[]]);
			//[_newGroup,(position (leader _newGroup))] call A3C_HC_ADD_WP;
		};

		[A3C_SELECTED_UNITS,true,false] spawn A3C_CANCELPLANS;

		if (hcShownBar) then {
			hcshowbar false;
			sleep 0.1;
			hcShowBar true;
		};

		if (A3C_MAP_CommandMode in ["INF","AIR"]) then {
			if ((count units group player) == 1) then {
				["HC"] call A3C_START_TABMODE;
				A3C_MAP_CommandMode = "HC";
			};
		};

		A3C_SELECTED_UNITS = [];
		
		//systemchat str _disbandedPhonetics;
		
		{[_x] spawn A3C_HC_ROLES;} foreach units _newGroup;

	} else {
		// re-join units
		[_groups] call A3C_AI_HIGHCOMMAND_fnc_mergeGroups; //-- spawn security mechanic

	};





	sleep 0.2;

	if (A3C_MAP_CommandMode == "HC") then {
		if ((count units group player) == 1) then {
			["HC"] call A3C_START_TABMODE;
			A3C_MAP_CommandMode = "HC";
		};
	};
	A3C_BOOL_MAP_MD = false;
	A3C_BOOL_MAP_MU = false;
	[] spawn {
		sleep 1;
		{(vehicle _x) setvehicleLock "UNLOCKED"} foreach units group player;
	};


};


A3C_FIND_PROMINENT_UnitMode = {
	params ["_units","_mode"];
	_reference = if (_mode == "BEHAVIOUR") then {["CARELESS","SAFE","AWARE","COMBAT","STEALTH"]} else {["BLUE","GREEN","WHITE","YELLOW","RED"]};
	_return = [];
	{
		_value = _x;
		_return pushBack
		[
			_x,
			if (_mode == "BEHAVIOUR") then {{behaviour _x == _value} count _units} else {{combatMode _x == _value} count _units}

		];
	} foreach _reference;
	_return = [_return,[],{_x select 1},"DESCEND"] call BIS_fnc_sortBy;
	//systemchat str _return;
	(_return select 0) select 0 //-- leave something like ["aware",5] >> "aware"
};




A3C_HC_getPhonetic = {
	params ["_number"];
	private ["_return"];
	_return = "";
	if (_number > 26) then {
		_return = str _number;
	} else {
		_return = switch (_number) do {
			case (1) : {"ALPHA"};
			case (2) : {"BRAVO"};
			case (3) : {"CHARLIE"};
			case (4) : {"DELTA"};
			case (5) : {"ECHO"};
			case (6) : {"FOXTROT"};
			case (7) : {"GOLF"};
			case (8) : {"HOTEL"};
			case (9) : {"INDIA"};
			case (10) : {"JULIET"};
			case (11) : {"KILO"};
			case (12) : {"LIMA"};
			case (13) : {"MIKE"};
			case (14) : {"NOVEMBER"};
			case (15) : {"OSCAR"};
			case (16) : {"PAPA"};
			case (17) : {"QUEBEC"};
			case (18) : {"ROMEO"};
			case (19) : {"SIERRA"};
			case (20) : {"TANGO"};
			case (21) : {"UNIFORM"};
			case (22) : {"VICTOR"};
			case (23) : {"WHISKEY"};
			case (24) : {"XRAY"};
			case (25) : {"YANKEE"};
			case (26) : {"ZULU"};
		};
	};
	_return
};


A3C_UNDO = {
	private ["_syncData"];
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT];
	_waypoint = A3C_WAYPOINTS_TEMP select ((count A3C_WAYPOINTS_TEMP) -1);
	_unitNumber = 0;
	_UndoData = (A3C_USERACTION select ((count A3C_USERACTION) -1));
	_SyncData = [];
	_SyncArray = [];
	_previousWP = [];
	_previousUnits = [];
	_formation = _waypoint select 3;
	if ((_undoData select 1) == 0) then {
		//-- undo WP
		{
			private ["_u","_unitNumber","_var"];
			_u = _x;
			_unitNumber = _u getvariable "A3C_VVNI"; //"A3C_FORMATION_INDEX";
			_var = (_x getvariable ["A3C_UNIT_POLYS",[]]);
			{
				private ["_p"];
				_p = _x;
				if ((_waypoint select 1) == ((_p select 0) select 1) ) then {
					[_u,_p] call A3C_SUP_REMOVE_POLY;
					_var = _var - [_p];
				}; //~~ exitwith??
			} foreach _var;
			_u setvariable ["A3C_UNIT_POLYS",_var,true];
			_u setvariable ["A3C_PLOT_TEMP",(_u getvariable "A3C_PLOT_TEMP") - [((_u getvariable "A3C_PLOT_TEMP") select ((count (_u getvariable "A3C_PLOT_TEMP")) - 1))],true];
		} foreach (_waypoint select 0);


		//{
		//	if !(_foreachindex in [0,4]) then {
		//		A3C_MARKERS = (A3C_MARKERS - [_x]);
		//		deletemarkerLocal _x;
		//	};
		//} foreach _waypoint;

		if ((_waypoint select 3) == 4) then {
			if ((count A3C_WAYPOINTS_TEMP) > 1) then {
				_previousWP = (A3C_WAYPOINTS_TEMP select ((count A3C_WAYPOINTS_TEMP) -2));
				_previousUnits = (_previousWP select 0);
				if ((_previousWP select 3) == 4) then {
					if !( (A3C_SPLIT_UNITS select 0) == (_previousUnits select 0)) then {
						A3C_SPLIT_UNITS = [(A3C_SPLIT_UNITS select ((count A3C_SPLIT_UNITS) -1))] + (A3C_SPLIT_UNITS - [(A3C_SPLIT_UNITS select ((count A3C_SPLIT_UNITS) -1))]);
					} else {
						A3C_SPLIT_UNITS = [(A3C_SPLIT_UNITS select ((count A3C_SPLIT_UNITS) -1))] + (A3C_SPLIT_UNITS - [(A3C_SPLIT_UNITS select ((count A3C_SPLIT_UNITS) -1))]);
					};
				};
			};
		};
		A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP - [_waypoint];
	} else {

		//-- undo Loop
		{
			_sl = _x;
			_data = _sl getvariable "A3C_PLOT_TEMP";
			{_x set [10,-1];} foreach _data;
			A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP - [_waypoint];
			_sl setvariable ["A3C_PLOT_TEMP",_data,true];
		} foreach (_waypoint select 0);


	};
	A3C_USERACTION = A3C_USERACTION - [_undoData];
	A3C_USERACTION_ID = (A3C_USERACTION_ID - 1);
	if (count A3C_WAYPOINTS_TEMP > 0) then {
		//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [7041,7092];
		(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow true;
		(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,1];
	} else {
		//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7041,7092];
		(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor [1,1,1,0.2];
	};
	[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
};

//-- REVERT AND DELETE ALL DATA CREATED DURING THE PLANNING STAGE
A3C_RESET_WIP = { //-- currently unused?
	_unit = _this select 0;
	//if (isPlayer _unit) exitWith {};
	_data = (_unit getvariable "A3C_PLOT_TEMP");
	_start = ((count (_unit getvariable "A3C_PLOT")) + 1);
	if (isnil '_start') exitWith {};
	_amount = ((_start + (count _data)) -1);
	_unitnumber = _unit getvariable "A3C_VVNI";  //"A3C_FORMATION_INDEX";
	{
		_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
		//_syncArray = (_x select 5);
		{
			[_x,_unit,"A3C_PLOT_TEMP"] call A3C_DELETE_MARKER;
		} foreach _wpMarkers;
	} foreach (_unit getvariable "A3C_PLOT_TEMP");
};

//--------------------------  I N T E R F A C E   O P E R A T I O N :   C O N T R O L   ---------
//---------------------------------------------------------------------------------------------------
//--------------------------    functions for changing circumstances    -----------------------

//-- if units die while player is planning, data gets erased.
A3C_CHECK_FOR_DEAD_WIP = { //-- currently unused
	{
		if (!isnull _x) then {
			if !(alive _x) then {
				if !(_x in A3C_DIED_IN_PLANNING) then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
					A3C_DIED_IN_PLANNING pushback _x;
					//[_x] call A3C_RESET_WIP; //-- no need to delete markers anymore?
					[_x] join grpnull;
					//waituntil {!(_x in (units group player))}; //--how's this working in 'call' scope?
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
					//[A3C_MAP_CommandMode] call A3C_LABEL_SELECTORS;
				};
			};
		};
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
};

A3C_UI_MAP_TREE_getSubParentCount = {
	params ["_CT_TREE","_mainTreeIndex"];
	private _squadTreeCount = _CT_TREE tvCount [_mainTreeIndex];
	private _parentSubCount = 0;
	for "_i" from 0 to (_squadTreeCount -1) do {
		_subTreeCount = _CT_TREE tvCount [_mainTreeIndex,_i];
		if (_subTreeCount > 0) then {
			_parentSubCount = _parentSubCount + 1;
		};
	};
	_parentSubCount
};





//--------------------------  I N T E R F A C E   O P E R A T I O N :   E X E C U T I O N   ---------
//---------------------------------------------------------------------------------------------------
//--------------------------    Functions to apply settings on selected AI    -----------------------

A3C_SNAP_MAP_BOOL = false;


A3C_SET_ORDER_WIP = {
	//----------------------
	//-- Pt. 1: determine input (leader or grunt)
	//----------------------
	// BE AWARE, THIS FUNCTION IS RUN TWO DIFFERENT WAYS (Button down: Leader, Button up: rest)
	private ["_mode","_fetchedUnit","_formDir","_goCode","_wpSyncData"];
	_mode = _this select 0; //-- 0 == ButtonDown, 1 == ButtonUp
	_fetchedUnit = if ((count _this) > 1) then {(_this select 1)} else {objnull};
	_formdir = 0;
	_units = [];
	_btn = 0;
	_spread = 0;
	_dist = 0;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	_splitUnit = objNull;
	_wpSyncData = [[0,false]];
	A3C_TEMP_WP_ID_SUB = "";


	//systemchat str A3C_TEMP_ACTION; //uuu


	_goCode = switch (A3C_TEMP_CONDITION) do {
		case (2) : {"A"};
		case (3) : {"B"};
		case (4) : {"C"};
		case (5) : {"D"};
		default {"NONE"};
	};


	//-- security measure: prevent too close position to look at (resulting in shivering units)
	//if (_mode == 0) then {
		//if (A3C_CLICKPOS_1 distance2d A3C_CLICKPOS_2 < 50) then {
			//A3C_CLICKPOS_2 = [A3C_CLICKPOS_1,100,([A3C_CLICKPOS_1,A3C_CLICKPOS_2] call BIS_FNC_DirTo)] call BIS_fnc_RelPos;
		//};
	//};
	//systemchat str _formdir;
	A3C_SNAP_MAP_BOOL = true;
	switch (_mode) do {
		case (0) : {
			if (A3C_FORMMODE_TEMP == 4) then {
				_units = [(A3C_SPLIT_UNITS select 0)];
				_btn = _units call A3C_GET_UNITBUTTON;
				if !(_btn == 0) then {
					((findDisplay _a3c_dsp) displayCtrl _btn ) ctrlSetTextColor [1,0.63,0,1];
				};
				A3C_SNAP_MAP_BOOL = false;


			} else {
				if (A3C_FORMMODE_TEMP == 5) then {
					A3C_SNAP_MAP_BOOL = false;
				} else {
					_units = [(A3C_SELECTED_UNITS select 0)];

					if (A3C_FORMMODE_TEMP == 4) then {
						A3C_SNAP_MAP_BOOL = false;
					};
					if ((A3C_TEMP_ACTION select 0) in ["GRENADE","SUPPRESSION"]) then {
						A3C_SNAP_MAP_BOOL = false;

					};
					if (A3C_TAB_BUILDING_BOOL) then {
						A3C_SNAP_MAP_BOOL = false;
					};
					if (A3C_SNAP_MAP_BOOL) then {
					};
				};

			};
			A3C_CLICKPOS_ROOT = A3C_CLICKPOS_1;
		};
		case (1) : {

			//A3C_CLICKPOS_2 set [2,(ATLtoASL A3C_CLICKPOS_ROOT) select 2];
			//A3C_CLICKPOS_2 = ASLtoATL A3C_CLICKPOS_2;

			if (A3C_FORMMODE_TEMP in [0,1,2,3,4]) then {
				A3C_CLICKPOS_2 = [A3C_CLICKPOS_ROOT,100,([A3C_CLICKPOS_ROOT,A3C_CLICKPOS_2] call BIS_FNC_DirTo)] call BIS_fnc_RelPos;
				A3C_CLICKPOS_2 set [2,10];
			};


			switch (A3C_FORMMODE_TEMP) do {
				case (1) : {_formDir = (([A3C_CLICKPOS_1,A3C_CLICKPOS_2] call BIS_FNC_DirTo) + 180);};
				case (2) : {_formDir = (([A3C_CLICKPOS_1,A3C_CLICKPOS_2] call BIS_FNC_DirTo) + 90);};
				case (3) : {_formDir = (([A3C_CLICKPOS_1,A3C_CLICKPOS_2] call BIS_FNC_DirTo) - 90);};
				case (5) : {_spread = (360 / (count A3C_SELECTED_UNITS)); _dist = (A3C_CLICKPOS_1 distance2D A3C_CLICKPOS_2);};
			};

			_formdir = [_formdir] call MCSS_fnc_CorrectDir;

			if (A3C_FORMMODE_TEMP == 4) then {
				if (A3C_SPLIT_UNITS isEqualTo A3C_Selected_Units) then {
					A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1;
				};
				_wpSyncData = [[A3C_SYNC_INDEX,false]];
				A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP + [[[(A3C_SPLIT_UNITS select 0)],A3C_TEMP_WP_ID_MAIN,A3C_TEMP_WP_ID_SUB,A3C_FORMMODE_TEMP]];
				_btn = [(A3C_SPLIT_UNITS select 0)] call A3C_GET_UNITBUTTON;
				if !(_btn == 0) then {
					((findDisplay _a3c_dsp) displayCtrl _btn ) ctrlSetTextColor [0.21,0.63,0,1];
				};
			} else {
				if (A3C_FORMMODE_TEMP == 5) then {
					_units = A3C_SELECTED_UNITS;
				} else {
					_units = (A3C_SELECTED_UNITS - [(A3C_SELECTED_UNITS select 0)]);
				};

				A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP + [[A3C_SELECTED_UNITS,A3C_TEMP_WP_ID_MAIN,A3C_TEMP_WP_ID_SUB,A3C_FORMMODE_TEMP]];
			};
		};
	};


	switch (A3C_TEMP_CONDITION select 0) do {
		case ("TIMEOUT") : {
			A3C_TEMP_CONDITION set [1,(parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout)))];
			A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout)));
		};
	};


	//player commandchat '222'; //str [A3C_TEMP_ACTION select 0,A3C_TEMP_ACTION select 1];


	//----------------------
	//-- Pt. 2  Assign Data
	//----------------------
	//systemchat str _units;
	{
		private ["_effectivePos","_collider","_snapPoses"];
		_secMark = true;
		A3C_TEMP_WP_ID_SUB = "";
		_unitnumber = _x getvariable "A3C_VVNI";
		_effectivePos = [];
		_collider = nil;
		_snapPoses = [];
		_unitArrayIndex = _foreachIndex;
		if !(A3C_FORMMODE_TEMP in [4,5]) then {
			if !(_x == (A3C_SELECTED_UNITS select 0)) then {
				//if !(A3C_FORMMODE_TEMP == 4) then {
					//-- any formation but "split" and "circle" >> modify positions
					if (A3C_TAB_BUILDING_BOOL) then {
						//-- clickpos within building: assign building positions
						A3C_CLICKPOS_1 = A3C_TAB_BUILDING buildingPos ([_x,A3C_SELECTED_UNITS] call MCSS_fnc_GetArrayIndex);
					} else {
						//-- clickpos outdoors:
						A3C_CLICKPOS_1 = ([A3C_CLICKPOS_1,A3C_DIAG_SPACING,_formDir] call BIS_fnc_Relpos);
						if (A3C_SNAP_MAP_BOOL) then {
							//-- check for snap positions:
							{
								private ["_clickPos","_refPos","_cL","_collider","_prms"];
								_clickPos = +(A3C_CLICKPOS_1); //-- copy clickpos so the formation line stays intact
								_clickPos set [2,0.3];
								_clickPos = ATLtoASL _clickPos;
								_refPos = [_clickPos,15,(_formDir + _x)] call BIS_fnc_relPos;
								_cl = (lineintersectsSurfaces [_clickPos, _refPos, objNull, objNull, true, 1, "GEOM", "FIRE"]);
									_collider = objNull;

								if (count _cl > 0) then {
									_collider = ((_cl select 0) select 2);
									if (!isNil '_collider') then {
										if ((getnumber (configfile >> "Cfgvehicles" >> typeof _collider >> "armor")) >= 200) then {
											_prms = [((_cl select 0) select 0),_collider] call A3C_HUD_SNAP_FORMATION;
											(_prms select 0) set [2,0];
											//~~ #unused_prms set [2,[(_prms select 2) + 180] call MCSS_fnc_correctDir];
											_snapPoses pushBack (_prms select 0); //([(_prms select 0),0.2,(_prms select 2)] call BIS_fnc_relPos);
										};
									};
								};
								if (_foreachindex == 1) then {
									if (count _snapPoses > 0) then {
										_snapPoses = [_snapPoses,[],{_x distance2D A3C_CLICKPOS_1},"ASCEND"] call BIS_fnc_sortBy;
										_effectivePos = _snapPoses select 0;
									};
								};
								//if (_exit) exitWith {

								//};
							} foreach [90,-90];
						};
					};
				//};
			};
		} else {
			//-- split and circle: do not modify positions
			A3C_CLICKPOS_1 = [A3C_CLICKPOS_ROOT,_dist,(_spread * _forEachIndex)] call BIS_fnc_RelPos;
			A3C_CLICKPOS_2 = [A3C_CLICKPOS_1,100,(_spread * _forEachIndex)] call BIS_fnc_RelPos;
		};

		if (count _effectivePos == 0) then {_effectivePos = A3C_CLICKPOS_1};

		if (A3C_FORMMODE_TEMP in [1,2,3,5]) then {
			if (A3C_CLICKPOS_1 isEqualTo A3C_CLICKPOS_ROOT) then {
				_secMark = false;
			};
			if (_secMark) then {
				A3C_TEMP_WP_ID_SUB = (format ['A3C_Mark_P%1',A3C_MARKER_COUNT]);
				A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
				//A3C_MARKERS_TEMP pushback A3C_TEMP_WP_ID_SUB;
				(A3C_WAYPOINTS_TEMP select ((count A3C_WAYPOINTS_TEMP) -1) ) pushback A3C_TEMP_WP_ID_SUB;
			};
		};

		_effectiveLookPos = if (A3C_FORMMODE_TEMP in [1]) then {_effectivePos getPos [100,(_effectivePos getDir A3C_CLICKPOS_2) + (180 * ((_unitArrayIndex + 1) / (count A3C_SELECTED_UNITS))  )]} else {+(A3C_CLICKPOS_2)};
		//-- Assign Data


		//player groupchat 'set'; //uuu
		_act = +(A3C_TEMP_ACTION);
		_x setvariable
		[
			"A3C_PLOT_TEMP",
			(
				(_x getvariable "A3C_PLOT_TEMP") +
				[
					[
						[_effectivePos,_effectiveLookPos], //-- positions
						[A3C_TEMP_WP_ID_MAIN,A3C_TEMP_WP_ID_SUB], //-- markers
						_act, //[A3C_TEMP_ACTION select 0,A3C_TEMP_ACTION select 1], //--WP Action
						A3C_TEMP_CONDITION, //--WP Condition
						[A3C_STANCE1_TEMP,A3C_STANCE2_TEMP], //-- WP Stances
						_wpSyncData, // WP Sync Data
						false, //-- isWPCompleted
						A3C_CMODE_TEMP, //-- Combat Mode
						A3C_WP_SPEED_TEMP, //-- WP SPeed
						A3C_HELIHEIGHT, //-- WP Flying Height
						-1, //-- WP Loop Value
						0 // -- radius (for circle, not completion)
					]
				]
			),
			true
		];

		if !(_x in A3C_ORDER_UNITS) then {A3C_ORDER_UNITS = A3C_ORDER_UNITS + [_x]};
		A3C_DIAG_SPACING = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066)));
	} foreach _units;
	//-- replace correct lookingDir marker
	if (_mode == 1) then {
		if (A3C_TEMP_ACTION select 0 == "STATIC") then {
			_units = [(A3C_SELECTED_UNITS select 0)];
			{
				_switchData = _x getvariable "A3C_PLOT_TEMP";
				//systemchat str _switchdata;
				if (count _switchData > 0) then {
					(_switchData select ((count _switchData) - 1)) set [2,A3C_TEMP_ACTION];
				};
			} foreach _units;
		};
		if (A3C_FORMMODE_TEMP in [0,1,2,3]) then {
			_units = [(A3C_SELECTED_UNITS select 0)];
			{
				_switchData = _x getvariable ["A3C_PLOT_TEMP",[]];
				//systemchat str _switchdata;
				if (count _switchData > 0) then {
					((_switchData select ((count _switchData) - 1)) select 0) set [1,A3C_CLICKPOS_2];
					_x setvariable ["A3C_PLOT_TEMP",_switchData,true];
				};
			} foreach _units;
		};

		if (A3C_FORMMODE_TEMP == 4) then {
			_units = [(A3C_SPLIT_UNITS select 0)];
			//systemchat str (A3C_SPLIT_UNITS select 0);
			{
				_switchData = _x getvariable ["A3C_PLOT_TEMP",[]];
				((_switchData select ((count _switchData) - 1)) select 0) set [1,A3C_CLICKPOS_2];
				(_switchData select ((count _switchData) - 1)) set [5,_wpSyncData];
				_x setvariable ["A3C_PLOT_TEMP",_switchData,true];
			} foreach _units;
		};
		[A3C_MAP_CommandMode] call A3C_UI_MAP_REFRESH_BARCONTROLS;
	} else {
		[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
	};

};

//-- function for the execute button. Assigns all orders created in planning stage
A3C_Btn_fnc_Execute = {
	params ["_mode"];

	private _addressedUnits = if (_mode == "ALL") then {A3C_ORDER_UNITS} else {A3C_SELECTED_UNITS};
	//A3C_MARKERS = A3C_MARKERS + A3C_MARKERS_TEMP;
	//A3C_MARKERS_TEMP = [];
	A3C_DIAG_ACTIVE = false;
	A3C_UNDO_MODE = 0; // 0 means undo WP, 1 means undo SYNC
	//-- A3C_USERACTION: Array to contain data input information used in Undo function. passed as [_inputIndex,_InputType,_syncWPindex]
	//-- _inputType: 0 == Waypoint Entry , 1 == Sync Entry
	A3C_USERACTION = [];
	A3C_USERACTION_ID = 0;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7041,7092];
	(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow false;
	(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,0.2];
	{
		private ["_data"];
		_u = _x;
		_data = (_u getvariable ['A3C_PLOT_TEMP',[]]);


		if !(isplayer _u) then {
			if ((count (_u getvariable ["A3C_PLOT",[]])) == 0) then {
				_x setvariable ["A3C_PLOT",((_x getvariable "A3C_PLOT") + _data),true];

				_script = [_u,(_u getvariable ['A3C_PLOT',[]])] spawn A3C_MOVE;

			} else {
				_u setvariable ["A3C_PLOT",((_x getvariable "A3C_PLOT") + _data),true];
			};
			_x setvariable ["A3C_PLOT_TEMP",[],true];
		};
	} foreach _addressedUnits;
	//{
	//	_x setvariable ["A3C_PLOT_TEMP",[],true];
	//} foreach A3C_SELECTED_UNITS;

};



//-- Open Right Click Context Menu Infantry
A3C_UI_MAP_FNC_SQContext_OpenMenu = {

	private _marker = _this select 0;
	private _pos = _this select 1;
	private _sX = _pos select 0;
	private _sY = _pos select 1;
	private _markerType = (markerType _marker); //~~ #BUG - always "" because we do not use markers
	private _building = objnull;
	private _mode = "INF";
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	

	private _units = [];
	private _data = [];
	private _funcSQ = {
		private ["_soldier","_mode","_marker","_return","_data"];
		_soldier = _this select 0;
		_mode = _this select 1;
		_marker = _this select 2;
		_return = false;
		_data = [];
		_a3c_dsp = if (visibleMap) then {100020} else {100030};

		{
			_vari = _x;
			_data = (_soldier getvariable [_x,[]]);
			{
				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				if (_marker in _wpMarkers) then {
					A3C_CHECKVAR = _vari;
					_return  = true;
					if (_mode == "INF") then {
						switch (_wpStances select 0) do {
							case "DOWN" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
							case "MIDDLE" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
							case "UP" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
						};
						switch (_wpStances select 1) do {
							case "DOWN" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
							case "MIDDLE" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
							case "UP" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
						};

					};
					if (_mode == "HELI") then {
						switch (_wpFlyInHeight) do {
							case (200) : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";};
							case (75) : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";};
							case (25) : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";};
							case (5) : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";};
						};
						switch (_wpAction select 1) do {
							case "NONE" : {
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.8] call A3C_UI_Color_setOpacity);
							};
							case "PICKUP" : {
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
							};
							case "DROPOFF" : {
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
							};
							case "RAPPEL" :{
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
							};
							case "LANDFINAL" : {
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
							};
							case "PARADROP" : {
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
							};
						};
					};
					if (_wpSpeed == 2) then {
						((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
					} else {
						((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
					};
				};
			} foreach _data;

		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
		_return
	};
	{
		if ([_x,_mode,_marker] call _funcSQ) then {_units pushback _x}; //-- #Cleanup Note: For grouped sq-wp's we can indeed have +1 selections
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");

	if (
		{
			private _op = objectParent _x;
			!(_x == driver _op && {_op isKindOf "AIR"})
		} count _units == 0
	) then {_mode = "HELI"};


	A3C_MARKERTOSWITCH = _marker;
	lbClear ((findDisplay _a3c_dsp) displayCtrl 709112);
	(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlSetPosition [_sx, _sy];
	(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlCommit 0;
	if (_mode == "HELI") then {
		((findDisplay _a3c_dsp) displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow true;
		A3C_LB_MODE = 0;
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlSetPosition [_sx, _sy];
		(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlCommit 0;

		[findDisplay _a3c_dsp displayCtrl 709112, "NONE"] call A3C_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl 709112, "PICKUP"] call A3C_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl 709112, "DROPOFF"] call A3C_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl 709112, "LANDFINAL"] call A3C_addLbEntry;
		if (A3C_IsRappel) then {
			[findDisplay _a3c_dsp displayCtrl 709112, "RAPPEL"] call A3C_addLbEntry;
		};
		[findDisplay _a3c_dsp displayCtrl 709112, "PARADROP"] call A3C_addLbEntry;

		

		_paraSel = if (A3C_IsRappel) then {5} else {4};
		
		switch (markertype A3C_MARKERTOSWITCH) do {
			case ('A3C_Marker_WAYPOINT') : {[findDisplay _a3c_dsp displayCtrl 709112, 0] call A3C_setCurSel;};
			case ('A3C_Marker_PICKUP_AIR') : {[findDisplay _a3c_dsp displayCtrl 709112, 1] call A3C_setCurSel;};
			case ('A3C_Marker_DROPOFF_AIR') : {[findDisplay _a3c_dsp displayCtrl 709112, 2] call A3C_setCurSel;};
			case ('A3C_Marker_LANDING') : {[findDisplay _a3c_dsp displayCtrl 709112, 3] call A3C_setCurSel;};
			case ('A3C_Marker_RAPPEL') : {[findDisplay _a3c_dsp displayCtrl 709112, 4] call A3C_setCurSel;};
			case ('A3C_Marker_Paradrop') : {[findDisplay _a3c_dsp displayCtrl 709112, _paraSel] call A3C_setCurSel;};

		};
		
	};
	A3C_CHECKVAR = "A3C_PLOT_TEMP";
	

	


	if (_mode == "INF") then {
		if ((count _units) > 0) then {
			A3C_GCUNITS = _units;
			A3C_MARKERTOSWITCH = _marker;
			lbClear ((findDisplay _a3c_dsp) displayCtrl 709112);
			((findDisplay _a3c_dsp) displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow true;
			A3C_LB_MODE = 2;
			(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlSetPosition [_sx, _sy];
			(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlCommit 0;

			[findDisplay _a3c_dsp displayCtrl 709112, "NONE"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl 709112, "A"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl 709112, "B"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl 709112, "C"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl 709112, "D"] call A3C_addLbEntry;

			if ( (markertype A3C_MARKERTOSWITCH) == "A3C_Marker_BUILDING") then {
				A3C_TAB_BUILDING = (nearestBuilding (getmarkerpos A3C_MARKERTOSWITCH));
				for "_i" from 0 to ([A3C_TAB_BUILDING] call MCSS_fnc_countBPos) do {
					[findDisplay _a3c_dsp displayCtrl 709112, format ["BPos %1",_i]] call A3C_addLbEntry;
				};
			};
			
			switch (_markertype) do { //~~ #BUG - markertype always, "", will ALWAYS use default :S
				case ('A3C_Marker_GoCode_A') : {[findDisplay _a3c_dsp displayCtrl 709112, 1] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_B') : {[findDisplay _a3c_dsp displayCtrl 709112, 2] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_C') : {[findDisplay _a3c_dsp displayCtrl 709112, 3] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_D') : {[findDisplay _a3c_dsp displayCtrl 709112, 4] call A3C_setCurSel;};
				default {[findDisplay _a3c_dsp displayCtrl 709112, 0] call A3C_setCurSel;};
			};
			
		};
	};
	lbClear ((findDisplay _a3c_dsp) displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT);
	if ((count _units) == 1) then {
		[findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT, "NONE"] call A3C_addLbEntry;
		_data =  (_units select 0) getvariable A3C_CHECKVAR;
		_wpInd = ( ((_units select 0) getvariable "A3C_CURRENTWAYPOINT_INDEX") - 1 );
		[findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT, 1] call A3C_setCurSel;
	};
};


A3C_LOOP_VIS_1 = {
	private ["_unit","_vari","_variAlt","_data","_start","_end","_del"];
	_unit = _this select 0;
	_vari = "A3C_PLOT_TEMP";
	_variAlt = "A3C_PLOT";
	{
		if !((_x select 10) == -1) then {
			_vari = "A3C_PLOT";
			_variAlt = "A3C_PLOT_TEMP";
		};
	} foreach (_unit getvariable "A3C_PLOT");
	_data = _unit getvariable _variAlt;
	{
		_x set [10,-1];
	} foreach _data;
	if (_vari =="A3C_PLOT_TEMP") then {_unit setvariable [_variAlt,_data,true]};
	_variAlt = objnull;
	_data = _unit getvariable _vari;
	_start = 0;
	_end = 0;
	_del = true;

	_data = _unit getvariable _vari;
	if (_vari == "A3C_PLOT_TEMP") then {
		_end = count _data;
	} else {
		{
			if !((_x select 10) == -1) then {
				if ((_x select 10) < -1) then {_start = _forEachIndex};
				if ((_x select 10) > -1) then {_end = (_forEachIndex +1)};
			};
		} foreach _data;
	};

	{
		_x set [10,-1];
	} foreach _data;
	_unit setvariable [_vari,_data,true];

	if (A3C_BOOL_DRAGLINE) then {
		A3C_BOOL_DRAGLINE = false;
	};
};





A3C_MapSel_Field_Root = [0,0,0];
A3C_MapSel_Field_DEST = [0,0,0];
A3C_MapSel_Field_Active = false;






A3C_CONTEXTBUTTON = {
	// AUTHOR NOTE: ~ can this be optimized more and shortened??
	private ["_mode","_func","_createLoopLine"];
	_mode = _this select 0;

	_func = {
		private ["_unit","_mode","_data","_isCurrent","_isLoop","_loopStart","_loopDest"];
		_unit = _this select 0;
		_mode = _this select 1;
		_data = [];
		_isLoop = false;
		_loopStart = 0;
		_loopDest = 0;
		_a3c_dsp = if (visibleMap) then {100020} else {100030};
		_isCurrent = {
			private ["_unit","_var","_index","_return"];
			_unit = _this select 0;
			_var = _this select 1;
			_index = _this select 2;
			_return = false;
			if !(_var == "A3C_PLOT") exitWith {_return};
			if ((_foreachIndex + 1) == (_unit getvariable "A3C_CURRENTWAYPOINT_INDEX")) then {_return = true};
			_return
		};
		{
			_var = _x;
			_data = _unit getvariable _var;
			{
				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				if ((_wpMarkers select 0) == A3C_MARKERTOSWITCH) then {
					switch (_mode) do {
						case ("SPEED") : {
							if (_wpSpeed == -1) then {
								_x set [8,2];
								((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
							} else {
								_x set [8,-1];
								((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
							};
						};
						case ("STANCE1") : {
							switch (_wpStances select 0) do {
								case ("DOWN") : {
									(_x select 4) set [0,"UP"];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											_unit SetUnitPos "UP";
									};
								};
								case ("MIDDLE") : {
									(_x select 4) set [0,"DOWN"];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											_unit SetUnitPos "DOWN";
									};
								};
								case ("UP") : {
									(_x select 4) set [0,"MIDDLE"];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											_unit SetUnitPos "MIDDLE";
									};
								};
							};
						};
						case ("STANCE2") : {
							switch (_wpStances select 1) do {
								case ("DOWN") : {
									(_x select 4) set [1,"UP"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
									};
								case ("MIDDLE") : {
									(_x select 4) set [1,"DOWN"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
								};
								case ("UP") : {
									(_x select 4) set [1,"MIDDLE"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
								};
							};
						};
						case ("HEIGHT") : {
							switch (_wpFlyInHeight) do {
								case (200) : {
									_x set [9,75];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 75;
									};
								};
								case (75) : {
									_x set [9,25];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 25;
									};
								};
								case (25) : {
									_x set [9,5];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 5;
									};
								};
								case (5) : {
									_x set [9,200];
									((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 200;
									};
								};
							};
						};
						case ("HELIWP") : {

							switch (_wpAction select 1) do {
								case ("NONE") : {
									(_x select 2) set [1,"PICKUP"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_PICKUP_AIR","DEFAULT"] call MCSS_fnc_SwitchMarker;

									[findDisplay _a3c_dsp displayCtrl 709112, 1] call A3C_setCurSel;
								};
								case ("PICKUP") : {
									(_x select 2) set [1,"DROPOFF"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_DROPOFF_AIR","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl 709112, 2] call A3C_setCurSel;
								};

								case ("DROPOFF") : {
									if (A3C_IsRappel) then {
										(_x select 2) set [1,"RAPPEL"];
										((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
										((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
										[A3C_MARKERTOSWITCH,"A3C_Marker_Rappel","DEFAULT"] call MCSS_fnc_SwitchMarker;
										[findDisplay _a3c_dsp displayCtrl 709112, 4] call A3C_setCurSel;
									} else {
										(_x select 2) set [1,"LANDFINAL"];
										((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
										((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
										[A3C_MARKERTOSWITCH,"A3C_Marker_LANDING","DEFAULT"] call MCSS_fnc_SwitchMarker;
										[findDisplay _a3c_dsp displayCtrl 709112, 3] call A3C_setCurSel;
									};

								};
								case ("RAPPEL") : {
									(_x select 2) set [1,"LANDFINAL"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_LANDING","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl 709112, 3] call A3C_setCurSel;
								};
								case ("LANDFINAL") : {
									(_x select 2) set [1,"NONE"];
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
									((findDisplay _a3c_dsp) displayCtrl 709113) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_Color_setOpacity);
									[A3C_MARKERTOSWITCH,"A3C_Marker_WAYPOINT","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl 709112, 0] call A3C_setCurSel;
								};
							};
						};
						case ("DELETE") : {

							if !((markertype A3C_MARKERTOSWITCH) == 'A3C_Marker_HCWP') then { //~~ is this condition still needed since no more HC markers are used??
								(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow false;
								if ([_unit,_var,_forEachIndex] call _isCurrent) then {
									[[_unit],false,true,true] spawn A3C_CANCELPLANS;
									_unit setvariable ["A3C_BOOL_WP_DELETED",true,true];
								} else {
									// marker is left overif !(_isLoop) then {{deletemarkerlocal _x} foreach [((_data select _i) select 2),((_data select _i) select 3),((_data select _i) select 4)];};

									{deleteMarkerLocal _x} foreach _wpMarkers;
									if !( ((_data select _forEachIndex) select 10) == -1) then {
										{
											_x set [10,-1];
										} foreach _data;
									};
									_data deleteAt _forEachIndex;
									_unit setvariable [_var,_data,true];
								};
							};
						};
					};
				};

			} foreach _data;
			_unit setvariable [_var,_data,true];
		} foreach ["A3C_PLOT_TEMP","A3C_PLOT"];
	};
	{
		[_x,_mode] call _func;
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
};

A3C_MAP_BOOL_CT_EDIT_ACTIVE = false;


A3C_UI_MAP_FNC_CTEDIT_ACTIVATE_DASHBOARD = {
	params ["_mode"];

	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};

	if (_a3c_dsp == 100040) exitWith {}; //-- temp solution until figured out

	private _textCtrl = findDisplay _a3c_dsp displayCtrl 11001;
	private _editCtrl = findDisplay _a3c_dsp displayCtrl 800713;
	private _groupName = str (parsetext (ctrlText _editCtrl));

	if (_mode == "ON") then {
		_textCtrl ctrlSetTextColor [0,0,1,0];
		_editCtrl ctrlSetText _groupName;
		_editCtrl ctrlSetTextColor [0,1,1,0.5];
		A3C_GROUP_NAMING_ACTIVE = true;
	} else {
		A3C_GROUP_NAMING_ACTIVE = nil;
		_textCtrl ctrlSetText _groupName;
		_textCtrl ctrlSetTextColor [1,1,1,1];
		_editCtrl ctrlSetTextColor [1,1,1,0];
	};
};

A3C_UI_MAP_FNC_CTEDIT_ACTIVATE = {
	//-- This function fires when the player is using a CT-Edit UI-control
	params ["_controlType","_mode"];
	private ["_a3c_dsp"];
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
	if (_a3c_dsp == 100040) exitWith {}; 
	
	if (_mode == "ON") then {
		A3C_MAP_BOOL_CT_EDIT_ACTIVE = true;
		A3C_BOOL_CT_SPACING = true; A3C_BOOL_DISABLEMAPCTRL = true; (findDisplay 12 displayCtrl 51) ctrlEnable false;
	} else {
		A3C_MAP_BOOL_CT_EDIT_ACTIVE = false;
		A3C_BOOL_CT_SPACING = false; A3C_BOOL_DISABLEMAPCTRL = false; (findDisplay 12 displayCtrl 51) ctrlEnable true;
		switch (_controlType) do {
			case ("TIMEOUT") : {
				if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
					A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout)));
				};
			};
			case ("SPACING") : {
				//systemchat 'spacingf';
				switch (A3C_MAP_CommandMode) do {
					case ("INF") : {
						A3C_SPACING_INF = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066))) max 2;
					};
					case ("AIR") : {
						A3C_SPACING_AIR = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066))) max 30;
					};
				};
			};
			case ("GROUPNAME") : {

			};
		};
	};

};

/////////////////////////////   GETTERS    ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////   

A3C_UI_MAP_Overlay_getIconsAtMapPos = {
	params ["_mode","_mapPositionX","_mapPositionY"];
	private ["_iconArray","_iconAtPositionFound","_iconsAtPosition","_iconsNotAtPosition"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	private _map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
	_iconAtPositionFound = false;
	_iconsAtPosition = [];
	_iconsNotAtPosition = [];
	//systemchat str (_this + [_map1]);
	//systemchat str _mapPositionX;
	_iconArray = switch (_mode) do {
		case ("SQUAD") : {A3C_UI_MAPICONS_SQUAD};
		case ("HC_GP") : {A3C_UI_MAPICONS_HC_GROUP};
		case ("HC_WP") : {A3C_UI_MAPICONS_HC_WPS};
		case ("HC_VB") : {A3C_UI_MAPICONS_HC_VICS};
		case ("TRACKER") : {A3C_UI_MAPICONS_HC_TRACKER};
		case ("POLY_MAIN") : {A3C_UI_MAPICONS_POLYGON_MAIN};
		case ("POLY_EDGE") : {A3C_UI_MAPICONS_POLYGON_EDGE};
		case ("SLINGLOAD") : {A3C_UI_MAPICONS_PICKUP};
		case ("DEMO") : {A3C_UI_MAPICONS_DEMO_VICS};
		case ("SQ_WP_DOT") : {A3C_UI_MAPICONS_SQ_WPS_WPDOTS};
		case ("BOARDING_DRAW") : {A3C_UI_MAPICONS_BOARDING_DRAW};
		default {[]};
	};
	{
		_iconWorldPosition = _x select 2;
		_iconMapPosition = _map1 ctrlMapWorldToScreen _iconWorldPosition;
		_iconMapPositionX = _iconMapPosition select 0;
		_iconMapPositionY = _iconMapPosition select 1;
		_iconMapDimensions = _x select 1;
		_iconIndex = if (count _x > 3) then {_x select 3} else {-1};
		_iconMapWidth = safeZoneWAbs * ( (_iconMapDimensions select 0) / (getResolution select 0));
		_iconMapHeight = safeZoneH * ( (_iconMapDimensions select 1) / (getResolution select 1));
		if( (_mapPositionX < _iconMapPositionX + (_iconMapWidth/2)) && (_mapPositionX > _iconMapPositionX - (_iconMapWidth/2)) && (_mapPositionY < _iconMapPositionY + (_iconMapHeight/2)) && (_mapPositionY > _iconMapPositionY - (_iconMapHeight/2)) ) then {
			_iconsAtPosition pushBack _x;
		};
	} forEach _iconArray;
	if (_mode == "SQ_WP_LOOKDIR") then {
		_sPos = _map1 posscreentoworld [_mapPositionX,_mapPositionY];
		{
			if (_sPos inPolygon (_x select 2)) then {
				_iconsAtPosition pushBack _x;
			};
		} foreach A3C_UI_MAPICONS_SQ_WPS_LOOKDIR;

	};
	_iconsAtPosition
};




/*


STANDBY: TABLET SPECIFIC FUNCTIONS (DISBANDED)
A3C_SwitchTabletImage = {
	if ((profileNameSpace getVariable "A3C_TABLET_IMG") == "A3C_CORE\ui\pictures\BG_Tablet_Tough.paa") then {
		profileNameSpace setVariable ["A3C_TABLET_IMG","A3C_CORE\ui\pictures\BG_Tablet_Small.paa"];
		(findDisplay 100010 displayCtrl 1604) ctrlSetText "SMALL";
	} else {
		profileNameSpace setVariable ["A3C_TABLET_IMG","A3C_CORE\ui\pictures\BG_Tablet_Tough.paa"];
		(findDisplay 100010 displayCtrl 1604) ctrlSetText "REG";
	};
};
