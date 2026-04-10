
if (isDedicated) exitwith {};

A3C_MAPTAB_UNITBUTTONCEIL = 16;

/////////////////////////////   NEW MAP OVERLAY FNCS    ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////   

[] spawn {
	waitUntil {!isNull findDisplay 12}; //-- necessary because otherwise weird offset


	A3C_COMMANDBAR_X = (profilenamespace getvariable ["IGUI_GRID_BAR_X", (safezoneX + 1 * ( ((safezoneW / safezoneH) min 1.2) / 40))]);
	A3C_COMMANDBAR_Y = (profilenamespace getvariable ["IGUI_GRID_BAR_Y", (safezoneY + safezoneH - 4.5 * ( (((safezoneW / safezoneH) min 1.2) / 1.2) / 25))]);
	A3C_COMMANDBAR_W = (36 * (((safezoneW / safezoneH) min 1.2) / 40));
	A3C_COMMANDBAR_H =  (4 * ( ( ((safezoneW / safezoneH) min 1.2) / 1.2) / 25));
	A3C_COMMANDBAR_PADDING_Y =  (safeZoneY + safeZoneH) - A3C_COMMANDBAR_H;
	
	A3C_MAPTAB_GAMEUI_REFERENCE_MENU = (ctrlPosition (findDisplay 12 displayctrl 1021));
	A3C_MAPTAB_GAMEUI_REFERENCE_MENU_X = A3C_MAPTAB_GAMEUI_REFERENCE_MENU select 0;
	A3C_MAPTAB_GAMEUI_REFERENCE_MENU_Y = A3C_MAPTAB_GAMEUI_REFERENCE_MENU select 1;
	A3C_MAPTAB_GAMEUI_REFERENCE_BAR = (ctrlPosition (findDisplay 12 displayctrl 1020));
	A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y = A3C_MAPTAB_GAMEUI_REFERENCE_MENU_Y - ((A3C_MAPTAB_GAMEUI_REFERENCE_BAR select 1) + (A3C_MAPTAB_GAMEUI_REFERENCE_BAR select 3));
	A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_X = (A3C_MAPTAB_GAMEUI_REFERENCE_MENU select 0) - safeZoneX;
	A3C_MAPTAB_GAMEUI_REFERENCE_PADDEDBOTTOM_Y = (safezoneH + safezoneY) - A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y;

	A3C_MAPTAB_SELECTOR_TREE_ROWHEIGHT_MAIN = 0.039 / (getResolution select 5);
	A3C_MAPTAB_SELECTOR_TREE_ROWHEIGHT_SUB = 0.03 / (getResolution select 5);
	A3C_MAPTAB_SELECTOR_TREE_W = 8 * A3C_MAPTAB_SELECTOR_TREE_ROWHEIGHT_SUB;// 0.14 * safezoneW; //0.19477 * safezoneW; ( 10 * ( pixelGrid * pixelW * 2.5 )); //
	A3C_MAPTAB_SELECTOR_TREE_X = (safeZoneX + safeZoneW) - A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_X - A3C_MAPTAB_SELECTOR_TREE_W;
	



	A3C_MAPTAB_GOCODE_BUTTONPOS_ROOT_H = 0.05 / (getResolution select 5);
	A3C_MAPTAB_GOCODE_BUTTONPOS_ROOT_W = A3C_MAPTAB_GOCODE_BUTTONPOS_ROOT_H * 0.75;
	A3C_MAPTAB_GOCODE_BUTTONPOS_ROOT_X = (safeZoneX + safeZoneW) - A3C_MAPTAB_GOCODE_BUTTONPOS_ROOT_W - A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_X;

	
	A3C_MAPTAB_SETTINGSGROUP_W_FULL = 0.555611 * safezoneW;
	A3C_MAPTAB_SETTINGSGROUP_W_COLLAPSED = A3C_MAPTAB_SETTINGSGROUP_W_FULL * 0.011;
	A3C_MAPTAB_SETTINGSGROUP_X = A3C_MAPTAB_SELECTOR_TREE_X - A3C_MAPTAB_SETTINGSGROUP_W_COLLAPSED; //A3C_MAPTAB_GAMEUI_REFERENCE_MENU_X + A3C_MAPTAB_SELECTOR_TREE_W;
	A3C_MAPTAB_SETTINGSGROUP_H = ( 0.11899 * safezoneH) * 1.5;
	A3C_MAPTAB_SETTINGSGROUP_Y = A3C_MAPTAB_GAMEUI_REFERENCE_PADDEDBOTTOM_Y - A3C_MAPTAB_SETTINGSGROUP_H;

	A3C_MAPTAB_SETTINGSGROUP_BUTTON_H = (A3C_MAPTAB_SETTINGSGROUP_H * 0.6) - (A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y * 2);
	A3C_MAPTAB_SETTINGSGROUP_BUTTON_W = A3C_MAPTAB_SETTINGSGROUP_BUTTON_H * 0.75;
	A3C_MAPTAB_SETTINGSGROUP_W_EXPANDED = (12 * (A3C_MAPTAB_SETTINGSGROUP_BUTTON_W + (A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y / 2))) + (3 * (A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y / 2) ); //-- 12 is (count _settingsButtonsPairs)
	A3C_MAPTAB_SETTINGSGROUP_X_EXPANDED = A3C_MAPTAB_SELECTOR_TREE_X - A3C_MAPTAB_SETTINGSGROUP_W_EXPANDED;


	//A3C_MAPTAB_SETTINGSGROUP_COMMITBUTTON_W = 0.0973751 * safezoneW;
	A3C_MAPTAB_SETTINGSGROUP_COMMITBUTTON_H = 0.044007 * safezoneH;

	A3C_MAPTAB_SUBSEL_BUTTON_H = 0.08 * safezoneH; //0.0330046;  = 0.07; //0.0330046;
	A3C_MAPTAB_SUBSEL_BUTTON_W = A3C_MAPTAB_SUBSEL_BUTTON_H * 0.75; 

	A3C_MAPTAB_TREEBOX_Y = (safezoneH + safezoneY); //-- default, out of bounds on first spawn

	A3C_MAPTAB_teamcolorboxH = (0.04 * safezoneH) - A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y;

	A3C_MAPTAB_Upper_buttonH = 0.04 * safezoneH; 
	//
};

/*
A3C_MAPUI_DRAW_MACRO_ICON = {
	params ["_ctrl","_type","_size","_color","_text"];
	private _iconType = switch (_type) do {
		case ("SYNC_REG") : {};
		case ("SYNC_BOARD") : {};
	};
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
*/


A3C_MAPUI_DRAW_MACRO_VEHICON = {
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


A3C_MAPUI_DRAW_THICC_LINE = {
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

A3C_MAPUI_DRAW_Polyframe = {
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



A3C_MAPTAB_OVERLAY_isUnFolded = false;

A3C_MAPTAB_OVERLAY_TOGGLE_FOLD = {
	params ["_mode","_animTime"];
	private _doExit = false;
	if (_mode == "OPEN") then {
		if (A3C_MAPTAB_OVERLAY_isUnFolded) then {
			if (count A3C_SELECTED_UNITS == 0) then {
				A3C_MAPTAB_OVERLAY_isUnFolded = false;
			};
			_doExit = true;
		} else {
			A3C_MAPTAB_OVERLAY_isUnFolded = true;
		};
	} else {
		A3C_MAPTAB_OVERLAY_isUnFolded = false;
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

	
	_padding = A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y / 2;

	_newSettingsBGW = if (_mode == "OPEN") then {A3C_MAPTAB_SETTINGSGROUP_W_EXPANDED} else {A3C_MAPTAB_SETTINGSGROUP_W_COLLAPSED};
	
	_macroWidth = A3C_MAPTAB_SETTINGSGROUP_BUTTON_W + _padding;
	_xPos = A3C_MAPTAB_SETTINGSGROUP_X - _padding - _macroWidth;

	
	//systemchat str time;

	//-- animate buttons
	{
		//_xPos = A3C_MAPTAB_SETTINGSGROUP_X + (_foreachIndex * A3C_MAPTAB_SETTINGSGROUP_BUTTON_H) + ((A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y / 2) * (_foreachIndex + 1));
		//_xPos = A3C_MAPTAB_SETTINGSGROUP_X + (_foreachIndex * A3C_MAPTAB_SETTINGSGROUP_BUTTON_H);
		{
			_btnCtrl = (findDisplay 6998 displayCtrl _x);
			
			_doShow = true;
			if (_mode == "OPEN") then {
				//systemchat 'hey';
				//_btnCtrl ctrlCommit 0;
				//_newSettingsBGW = _newSettingsBGW + (0.5 *  (A3C_MAPTAB_SETTINGSGROUP_BUTTON_W + _padding)  ); //-- 0.5 because it's run twice per control
				
				_btnCtrl ctrlSetPosition
				[
					_xPos,
					A3C_MAPTAB_SETTINGSGROUP_Y + (A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y),
					A3C_MAPTAB_SETTINGSGROUP_BUTTON_W,
					A3C_MAPTAB_SETTINGSGROUP_BUTTON_H
				];
				
			} else {
				_doShow = false;
				_btnCtrl ctrlSetPosition
				[
					A3C_MAPTAB_SETTINGSGROUP_X,
					A3C_MAPTAB_SETTINGSGROUP_Y,
					0,
					A3C_MAPTAB_SETTINGSGROUP_BUTTON_H
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
	_xPos = (A3C_MAPTAB_SETTINGSGROUP_X - _padding) -  (11.5 * _macroWidth); //-- 11.5 is half a button offset to last button (CONTINUE)
	_buttonWidthFull = (3 * _macroWidth);
	{
		
		if (_foreachIndex > 0) then {
			_xPos = _xPos + (4 * _macroWidth);				
		};
		
		_btnCtrl = (findDisplay 6998 displayCtrl _x);
		_btnCtrl ctrlSetPosition
		[
			A3C_MAPTAB_SETTINGSGROUP_X,
			A3C_MAPTAB_SETTINGSGROUP_Y,
			0,
			A3C_MAPTAB_SETTINGSGROUP_BUTTON_H
		];
		if (_mode == "OPEN") then {
			
			//systemchat 'hey';
			//_btnCtrl ctrlCommit 0;
			//_newSettingsBGW = _newSettingsBGW + (0.5 *  (A3C_MAPTAB_SETTINGSGROUP_BUTTON_W + _padding)  ); //-- 0.5 because it's run twice per control
			
			_btnCtrl ctrlSetPosition
			[
				_xPos,
				A3C_MAPTAB_SETTINGSGROUP_Y + ((A3C_MAPTAB_GAMEUI_REFERENCE_PADDING_Y + A3C_MAPTAB_SETTINGSGROUP_BUTTON_H) * 1.25),
				_buttonWidthFull,
				A3C_MAPTAB_SETTINGSGROUP_COMMITBUTTON_H
			];
			
		};
		_btnCtrl ctrlCommit _animTime;
		sleep 0.0001;
	} foreach [7018,7019,7020];


	//private _shiftX = if (_mode == "OPEN") then {_newSettingsBGW} else {0};
	//-- animate BG frame WP SETTINGS
	{
		_settingsCtrl = (findDisplay 6998 displayCtrl _x);
		_settingsCtrl ctrlSetPosition
		[
			A3C_MAPTAB_SELECTOR_TREE_X - _newSettingsBGW, //A3C_MAPTAB_SETTINGSGROUP_X
			A3C_MAPTAB_SETTINGSGROUP_Y,
			_newSettingsBGW,
			A3C_MAPTAB_SETTINGSGROUP_H
		];
		_settingsCtrl ctrlCommit _animTime;
	} foreach [10,11,13];
	if (_mode == "COLLAPSE") then {
		{
			(findDisplay 6998 displayCtrl _x) ctrlShow false;
		} foreach [PRNT_ACTION_SUBSET_1,PRNT_ACTION_SUBSET_2,MAP_BG_SUB_BG_1,MAP_BG_SUB_BG_2,A3C_RC_TimeOut];
	} else {
		
		//(findDisplay 6998 displayCtrl 7066) ctrlSetText str _spacing;
		//[(findDisplay 6998 displayCtrl 7066)] spawn {
		//	sleep 0.5;
		//	_spacing = if (A3C_HELI_INF_MODE == "AIR") then {A3C_SPACING_AIR} else {A3C_SPACING_INF};
		//	(_this select 0) ctrlSetText str _spacing;
		//};
	};

};


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

A3C_getArtilleryAmmo = {
	//-- _includeOrders: bolean to include planned orders or not
	//-- _getDisplayName : bolean to convert/bundle array into displayName
	params ["_includeOrders","_getDisplayName","_targetPos"]; 
	
	private _availableMagsAll= [];
	{
		private _artyPiece = _x;
		private _artyMagTypes = getArtilleryAmmo [_artyPiece];
		private _availableMagsVehicle = (magazinesAmmoFull _artyPiece) select
		{
			_x params ["_magType","_magAmount"];
			_inRange = if (isNil '_targetPos' OR {_targetPos isEqualTo []}) then {true} else {_targetPos inRangeOfArtillery [[_artyPiece], _magType]};
			_inRange && {_magType in _artyMagTypes}
		};
		{
			_x params ["_magType","_magAmount"];
			if ({_x select 0 == _magType} count _availableMagsAll == 0) then {
				//-- create new entry
				_availableMagsAll set
				[
					count _availableMagsAll,
					[_magType,_magAmount]
				];
			} else {
				//-- add to existing entry
				{
					_x params ["_magTypeRef","_magAmountRef"];
					if (_magType == _magTypeRef) exitWith {
						_x set [1, _magAmountRef + _magAmount];
					};
				} foreach _availableMagsAll;
			};	
		} foreach _availableMagsVehicle;
		if (_includeOrders) then {
			private _artyOrdersPlanned = _artyPiece getvariable ["A3C_ARTY_ORDERS",[]];
			{
				//-- filter for matching magtype
				_x params ["_firePos","_magType","_orderCount"];
				{
					_x params ["_magTypeRef","_orderCountRef"];
					if (_magTypeRef == _magType) exitWith {
						(_availableMagsAll select _foreachIndex) set [1,_orderCountRef - _orderCount];
					};
				} foreach _availableMagsAll;
			} foreach _artyOrdersPlanned;
		};
	} foreach MCSS_REMOTE_ARTILLERY_ARRAY;

	
	
	_availableMagsAll = _availableMagsAll select {_x select 1 > 0}; //-- keep only those mags that can be shot
	private _return = _availableMagsAll;
	if (_getDisplayName) then {
		
		private _displayNameArray = [];
		{
			_x params ["_magType","_magAmount"];
			private _displayName = getText (configfile >> "CfgMagazines" >> _magType >> "displayName");

			if ({_x select 0 == _displayName} count _displayNameArray == 0) then {
				//-- create new entry
				_displayNameArray set
				[
					count _displayNameArray,
					[_displayName,_magAmount]
				];
			} else {
				//-- add to existing entry
				{
					_x params ["_displayNameRef","_magAmountRef"];
					private _dspn = getText (configfile >> "CfgMagazines" >> _magType >> "displayName");
					if (_displayNameRef == _displayName) exitWith {
						_x set [1, _magAmountRef + _magAmount];
					};
				} foreach _displayNameArray;
			};	
		} foreach _availableMagsAll;
		_return = _displayNameArray;
	};	
	_return
};




A3C_OPEN_OBJECTSELECTOR_MAP = {
	params ["_mode"];
	
	private _a3c_dsp = if (visibleMap) then {6998} else {if (!isNull findDisplay 6999) then {6999} else {79996}};
	_parent = findDisplay _a3c_dsp displayCtrl A3C_ObjectSelector_Parent;
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
						//systemchat format ["1 %1, %2",_mineTrigger,isNull _targetVehicle];
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
			(findDisplay 79996) closeDisplay 0;
		};
	};
	
};

A3C_MapOverlayDefaultkeys = {
	params ["_display","_data"];
	//player sidechat str _this;
	


	private _key = _data select 1;

	private _exit = false;

	private _A3C_HC_ObjectSelector_ListBox = findDisplay _display displayCtrl 800803;
	if (ctrlShown _A3C_HC_ObjectSelector_ListBox) then {
		
		private _lbSize = lbSize _A3C_HC_ObjectSelector_ListBox;
		if (_key in [1,2,3,4,5,6,7,8,9,0]) then {
			private _keyValueIndex = _key - 2;
			if ((_key - 1) <= _lbSize) then {
				[_A3C_HC_ObjectSelector_ListBox, _keyValueIndex, true] call A3C_setCurSel;
			};
			_exit = true;
		};	
	};

	if (_exit) exitWith {};

	private _bool = false;
	if (count groupselectedUnits player == 0) then {
		switch (_key) do {
			case 2 : {
				_bool = true;
			};
			case 3 : {
				_bool = true;
			};
			case 4 : {
				_bool = true;
			};
			case 5 : {
				_bool = true;
			};
			case 6 : {
				_bool = true;
			};
			case 7 : {
				_bool = true;
			};
			case 8 : {
				_bool = true;
			};
			case 9 : {
				_bool = true;
			};
			case 10 : {
				_bool = true;
			};
		};
	};
	if (_key in [28,57,156]) then { //- Spacebar, Enter, NUMpad Enter --> COMMIT
		if (ctrlshown (findDisplay _display displayCtrl 800713)) then {
			//-- prevent A3 EH (display 46) but still confirn
			//systemchat str _key;
			if (_key == 28) then {
				_bool = true;
				[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm
			};

		} else {
			if ( A3C_HELI_INF_MODE in ["INF","AIR"] && {count groupselectedUnits player == 0}) then {
				['ALL'] spawn A3C_Btn_fnc_Execute;
				_bool = true
			};
		};

	};
	//systemchat str _key;
	_bool
};


A3C_MAP_iconsAtMapPos = {
	params ["_mode","_mapPositionX","_mapPositionY"];
	private ["_iconArray","_iconAtPositionFound","_iconsAtPosition","_iconsNotAtPosition"];
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	private _map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
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

		// if(_iconAtPositionFound) then {
			// _iconsNotAtPosition pushBack _x;
		// } else {
			if( (_mapPositionX < _iconMapPositionX + (_iconMapWidth/2)) && (_mapPositionX > _iconMapPositionX - (_iconMapWidth/2)) && (_mapPositionY < _iconMapPositionY + (_iconMapHeight/2)) && (_mapPositionY > _iconMapPositionY - (_iconMapHeight/2)) ) then {
				_iconsAtPosition pushBack _x;
				// _iconAtPositionFound = true; //- mechanic to prevent multiple options for layered
			// } else {
			// 	_iconsNotAtPosition pushBack _x;
			};
		// };

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


//------------------  I N T E R F A C E   O P E R A T I O N :   K E Y -   A N D   M O U S E   F U N C T I O N S   -------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------    Functions for UI-Eventhandlers      -------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------


A3C_SwitchTabletImage = {
	if ((profileNameSpace getVariable "A3C_TABLET_IMG") == "A3C_CORE\ui\pictures\BG_Tablet_Tough.paa") then {
		profileNameSpace setVariable ["A3C_TABLET_IMG","A3C_CORE\ui\pictures\BG_Tablet_Small.paa"];
		((findDisplay 79991) displayCtrl 1604) ctrlSetText "SMALL";
	} else {
		profileNameSpace setVariable ["A3C_TABLET_IMG","A3C_CORE\ui\pictures\BG_Tablet_Tough.paa"];
		((findDisplay 79991) displayCtrl 1604) ctrlSetText "REG";
	};
};

A3C_MAP_ResetMapClick = {
	params ["_mode"];
	/*
	private _doOverWrite = false;
	//if (_alt) then {true};
	if !(isnull objectParent player) then {
		if !(player == driver (vehicle player)) then {
			if (player == effectiveCommander (vehicle player)) then {
				if (_mode == 0) then {
					if !(_shift) then {
						_doOverWrite = true;
					};
				//} else {
				//	onMapSingleClick {};
				};
			};
		};
	};
	
	_ctrls = 
	[
		10, //-- settingsBar
		A3C_RC_Context,
		A3C_RC_Context_HC_WP,
		// 709135, //-- some listbox, should be covered via main
		A3C_ObjectSelector_Parent,
		A3C_SELECTOR_TREE,
		A3C_HC_GROUP_MENU_CTRLPARENT,
		A3C_ObjectSelector_Parent,
		A3C_RC_Context_HC_WP,
		709099 //-- goCode BackgroundBox
	];	
	if ({[(worldToScreen _pos),findDisplay 6998 displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctrls > 0) then {
		_doOverWrite = true;
	};
	*/
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

A3C_Close_Map_Overlay = {
	params ["_display"];
	(findDisplay _display) closeDisplay 0;
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	[1] call A3C_Btn_fnc_Cancel;
	A3C_HELI_INF_MODE = "INF"; A3C_SELECTED_UNITS = [];
	A3C_SELECTED_UNITS = [];
	{_x setvariable ["A3C_PLOT_TEMP",[],true];} foreach units group player;
	[1] call A3C_MAP_ResetMapClick;
};


A3C_isOverlayClosed = {
	Private ["_btn1","_shift","_ctrl","_alt","_closed"];
	_btn1 = _this select 1;
	_shift = _this select 2;
	_ctrl = _this select 3;
	_alt = _this select 4;
	_closed = false;

	if (A3C_MAP_BOOL_CT) exitWith {};
	_keyId = if (isnil "A3C_MAP_KEY_ID") then {A3C_MAP_KEY_ID} else {profilenamespace getvariable "A3C_MAP_KEY_ID"}; //~~~~~~~~~~~
	if (visibleMap && ([_btn1,[_shift,_ctrl,_alt]] isEqualTo _keyID) ) then {
		if !(A3C_MAP_BOOL_CT) then {
			_closed = true
		};
	};
	//~~~~~~~~~~~
	//if ((inputaction "showmap") > 0) then {_closed = true};
	if (_btn1 == 1) then {_closed = true};

	if (_closed) then {
		[6998] call A3C_Close_Map_Overlay;
		profilenamespace setvariable ["A3C_MAP_VAR",false];  //~~~~~~~~~~~

	};
	_closed
};


A3C_isMapClosed = {
	Private ["_btn1","_shift","_ctrl","_alt","_closed"];
	_btn1 = _this select 1;
	_shift = _this select 2;
	_ctrl = _this select 3;
	_alt = _this select 4;
	_closed = false;
	if (A3C_MAP_BOOL_CT) exitWith {};
	//if ((inputaction "showmap") > 0) then {_closed = true};
	if (_btn1 in actionKeys "showmap") then {_closed = true};
	if (_btn1 == 1) then {_closed = true};
	if (_closed) then {
		[6998] call A3C_Close_Map_Overlay;
		A3C_BOOL_MAPFORCE = false;
	};
	_closed
};



//-- find HC_waypoints within 5m of clickpos (ie fetch HC-waypoint to be dragged to another position
//-- only relevant when player is not syncronized to a HC-Module
A3C_ISNEARHC = {
	private ["_return"];
	_return = false;
	_display = if (visibleMap) then {6998} else {6999};
	_clickPos = if (count _this > 2) then {_this} else {( (findDisplay _display displayCtrl 7043) posscreentoworld _this)};
	{
		_gp = _x;
		{
			if ( (_clickpos distance (waypointPosition _x)) < 5) then {
				A3C_HC_TOSWITCH = [_gp,_x];
				A3C_HC_ACTIVEGROUP = _gp;
				A3C_HC_ACTIVE_IND = _x;
				_return = true;
			};
		} foreach (waypoints _gp);
	} foreach (hcAllgroups player);
	if !(_return) then {A3C_HC_TOSWITCH = [grpNull,-1]};
	//systemchat str _return;
	_return
};






//-- Main Tablet "MmouseDown"-Handler


A3C_SQ_CLICKED_UNIT = objNull;





A3C_TAB_LMOUSE_D = {

	/*
	Let's overwork this entire handler shall we.
	Best shot right now:
	1. Pick up all icons (and/or markers)
	2. Seperate execution through right and leftclick
	*/
	params ["_displayCtrl","_mouseButton","_sX","_sY","_shift","_ctrl","_alt"];
	private ["_mouseOverIcon","_groupControls","_isHCMark"];

	disableserialization;

	

	private _left = _mouseButton == 0;
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	if (isNull findDisplay _a3c_dsp) exitWith {};
	if (A3C_MAP_BOOL_CT) exitWith {};
	if (A3C_UI_MAPTAB_isCircleMenu) exitWith {
		if !(_left) then {
			[_a3c_dsp,-1] call A3C_UI_MAPTAB_CLOSEMENU;
		};
	};
	
	//-- contextMenues are open
	if ({ctrlShown (findDisplay _a3c_dsp displayCtrl _x)} count [A3C_RC_Context_HC_WP,A3C_HC_GROUP_MENU_CTRLPARENT,A3C_ObjectSelector_Parent] > 0) exitwith {};
	private _ctls = if (visibleMap) then {[A3C_SELECTOR_TREE,7077,7071,709099,8008]} else {[]};
	//-- exit if mouseclick was within certain controls
	if ({[[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctls > 0) exitWith {};

	private _unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
	private _map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
	private _sPos = (_map1 posscreentoworld [_sx,_sy]);
	private _clickdata = (ctrlMapMouseOver _map1); //~~ IS THIS STILL USED?
	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	private _marker = "";
	private _isHcMark= false;

	A3C_MovedItem_ID = ""; //-- reset movedItem on every moueDown event
	A3C_MMCode = {};
	A3C_SQ_CLICKED_UNIT = objNull;
	A3C_LB_TICKTIME = time;
	A3C_CLICKPOS_1 = (_map1 posscreentoworld [_sx,_sy]);
	
	A3C_HC_TOSWITCH = [grpNull,-1];


	if (A3C_HC_DETONATION_BOOL) exitWith {
		private _demoIcons = (["DEMO",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		if (count _demoIcons > 0) then {
			_hoverIcon = _demoIcons select 0;
			_hoverVic = _hoverIcon select 0;
			if ((vehicleVarName _hoverVic) == "") then {
				_hoverVic = missionNameSpace getVariable ([_hoverVic] call MCSS_fnc_setVehicleVarname);
			};
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] waypointAttachVehicle _hoverVic;
		};
		A3C_HC_DETONATION_BOOL = false;
	};



	//-- detect SLING LOAD PICKUP icons
	if (A3C_HC_EDIT_ACTION == "SLING LOAD" && {count A3C_PICKUP_OBJECTS > 0}) exitWith {
		A3C_HC_EDIT_ACTION = "";
		//systemchat 'uuu3';
		A3C_UI_MAPICONS_PICKUP = [A3C_UI_MAPICONS_PICKUP,[],{(_x select 2) distance2D _sPos},"ASCEND"] call BIS_fnc_sortBy;
		private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		A3C_PICKUP_OBJECTS = []; //-- remove UI
		if (count _slingIcons > 0) then {
			private _slingIcon = _slingIcons select 0;
			private _veh = (_slingIcon select 0);
			//systemChat str (typeOf _veh);
			
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] setWaypointPosition [(position _veh),0];
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] setWayPointType "HOOK";
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] waypointAttachVehicle _veh;
			_statements = waypointStatements [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND];
			_statements set [1, (_statements select 1) + " 'SLING LOAD HOOK'; " ]; //-- just to have something for the UI to read
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] setWaypointStatements _statements;
			
		};
	};

	//-- detect click on VEHICLE BOARDING ICONS	
	if (A3C_HC_VEHICLEBOARD_BOOL) exitWith {

		private _vhIcons = [];
		//-- Boarding HC-units via map-ui pt 2
		_vhIcons = (["HC_VB",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		_doReset = false;
		if (_left) then {
			if (count _vhIcons > 0) then {
				_vhIcon = _vhIcons select 0;
				private _selectedVehicle = _vhIcon select 0;
				//_boardGroup = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

				[A3C_SELECTED_HC_GROUPS_SETTINGS,_selectedVehicle] call A3C_HC_AssignVehicle;
				_doReset = true;
			} else {
				A3C_HC_VEHICLEBOARD_BOOL = false; //-- disable boarding interface
				_doReset = true;
			};
		} else {
			if (_ctrl) then {
				A3C_HC_VEHICLEBOARD_BOOL = false; //-- disable boarding interface
				_doReset = true;
			};
		};
		if (_doReset) then {
			A3C_UI_MAPICONS_HC_VICS = [];
			A3C_HC_VEHICLEBOARD_BOOL = false;
			A3C_HC_VEHICLEBOARD_GROUPS = [];
			A3C_MMCode = {};
			A3C_BOOL_MOUSEMOVING = false;
			A3C_BOOL_DRAGLINE = false;
			A3C_CONNECTING_MODE = "LOOKDIR";
		};
		
	};
	A3C_PICKUP_OBJECTS = []; //-- if no sling vic was selected via click, remove icons

	//-- right click limited to rightClicks (<< ~~say wut??). Change this for future left doubleclicks
	private _doubleClick = false;
	if !(_left) then {
		_tickTime = (time - A3C_LB_TICKTIME);
		if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
			_doubleClick = true;
		};
	};
	if (A3C_isArtyAwaitingSuborder) exitWith { //~~ ??? wtf is going on here lol
		//systemchat 'oi';
		if (_doubleClick && !(_left)) then {
			A3C_isArtyAwaitingSuborder = false;
			player groupChat format ["%1 this is %2, firemission is no longer needed.", groupID (group (gunner A3C_HC_FOCUS_ARTY)), groupID (group player)];
			["A3C_ARTY_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
		};
	};
	

	

	if (A3C_HELI_INF_MODE in ["INF","AIR"]) then {
	//	systemchat str A3C_SPACING_INF;
		["SPACING","OFF"] call A3C_MAP_fnc_CT;
	};

	private _exit = false;
	_gpIcons = (["HC_GP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	// systemchat format ["group Icons clicked: %1", count _gpIcons];
	_gpIcons = 
	[
		_gpIcons,
		[],
		{
			_gp = _x select 0;
			_val = if (driver vehicle leader _gp in (units _gp)) then {1} else {0};
			_val
		},
		"ASCEND"
	] call BIS_fnc_sortBy;
	(findDisplay _a3c_dsp displayCtrl 303030) ctrlShow false;
	private _gpIconsCount = count _gpIcons;
	if (_gpIconsCount > 0) exitWith {

		
			
		// _gpIcon = _gpIcons select 0;
		_gpIcon = if ({typeName _x != "GROUP"} count A3C_SELECTED_UNITS == 0 && {count A3C_SELECTED_UNITS == 1}) then {
			private _selectionIndex = -1;
			
			{
				// private _iconIndex = [_x,_gpIcons] call MCSS_fnc_GetArrayIndex;
				if (_x select 0 == A3C_SELECTED_UNITS select 0) exitWith {
					_selectionIndex = _foreachIndex;
				};
			} foreach _gpIcons;
			
			private _return = if (_selectionIndex == -1) then {
				_gpIcons select 0
			} else {
				private _newIndex = _selectionIndex + 1;
				// systemchat str _newIndex;
				_newIndex = if (_newIndex >= _gpIconsCount) then {0} else {_newIndex};
				_gpIcons select _newIndex;
			};
			_return
		} else {
			_gpIcons select 0
		};
		// systemchat str _gpIcon;

		private _gp = _gpIcon select 0;
		A3C_SQ_CLICKED_UNIT = _gp;
		_exit = true;
		if (_left) then {
			if (A3C_isMergeGroupActive) then {
				_gp1 = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
				(units _gp1) joinSilent A3C_SQ_CLICKED_UNIT;
				deleteGroup _gp1;
				A3C_isMergeGroupActive = false;
			} else {
				A3C_HELI_INF_MODE = "HC";
				_resetSelection = false;
				if (_ctrl) then {
					A3C_SELECTED_UNITS = if (_gp in A3C_SELECTED_UNITS) then {
						A3C_SELECTED_UNITS - [_gp];
					} else {
						A3C_SELECTED_UNITS + [_gp];
					};
				} else {;
					A3C_SELECTED_UNITS = [_gp];
				};
				//sleep 0.4;
				
				//~~
				//-- #TODO: #HuiHui -- streamline this duplicate code for visualizing selection change in tree-UI
				private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SELECTOR_TREE;
				_CT_TREE tvSetCurSel [-1];
				//sleep 0.7;
				//playsound 'A3C_MenuSound1';
				//0.3;
				
				if (count A3C_SELECTED_UNITS == 1) then { //--
					_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
					if (count _button > 0) then {
						_button = _button select 0;
						_buttonParent = _button select [0,count _button -1];
						if ([_button select 0] in A3C_MAPTAB_TREES_OPEN) then {
							_CT_TREE tvSetCurSel _button;
							[
								[
									findDisplay 6998 displayCtrl 202020,
									_button select [0,(count _button) - 1]
								],
								"OPEN",
								false,
								0.1
							] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE
						};
					};	
				};
				//~~



				//sleep 1;
				//playsound 'A3C_MenuSound1';
				if (A3C_MAPTAB_OVERLAY_isUnFolded) then {
					//systemchat 'ay';
					["COLLAPSE",0.1] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
				};
				//["HC"] call A3C_START_TABMODE;

				if (!isPlayer leader _gp) then {
					if ( (count A3C_SELECTED_UNITS == 0) OR (A3C_SQ_CLICKED_UNIT in A3C_SELECTED_UNITS) ) then {
						A3C_MAP_DRAGPLANNING_ACTIVE = true;
						A3C_BOOL_MOUSEMOVING = true;
						A3C_MMCode = {
							_this spawn A3C_TAB_MouseDrag;
						};
					};
				};
			};			
		} else {
			if (A3C_isMergeGroupActive) then {
				_gp1 = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
				(units _gp1) joinSilent A3C_SQ_CLICKED_UNIT;
				deleteGroup _gp1;
				A3C_isMergeGroupActive = false;
			} else {
				
				//if (_ctrl) then {
					//(findDisplay _a3c_dsp displayCtrl A3C_HC_GROUP_MENU_CTRLPARENT) ctrlShow true;
					// if ({private _ld = leader _x; isPlayer _ld} count A3C_SELECTED_UNITS == 0) then {
						(findDisplay _a3c_dsp displayCtrl A3C_HC_GROUP_MENU_CTRLPARENT) ctrlSetPosition ([_a3c_dsp,A3C_HC_GROUP_MENU_CTRLPARENT,[_sx, _sy]] call A3C_DSP_FindControlSafePos);
						(findDisplay _a3c_dsp displayCtrl A3C_HC_GROUP_MENU_CTRLPARENT) ctrlCommit 0;
					// } else {
						// hint "A3C: "; //-- not needed, should already be executed in actions
					// };

					
					
					//A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
					//[_gp,0] call A3C_Map_HC_groupContext_OpenMenu;
					A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
					if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
						A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
						[A3C_SELECTED_HC_GROUPS_SETTINGS,1] call A3C_Map_HC_groupContext_OpenMenu;
					} else {
						A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
						[_gp,0] call A3C_Map_HC_groupContext_OpenMenu;
					};				
				//};
			};
			
		};
	};
	
	
	//-- detect click on HC-GROUP WAYPOINT ICON
	if !(_isHighCommand) then {
		_wpIcons = (["HC_WP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		if (count _wpIcons > 0) then {
			_wpIcon = _wpIcons select 0;
			_gp = _wpIcon select 0;
			_wpiC = _wpIcon select 3;
			_exit = true; //~~ sure?
			if (_left) then {
				if (_ctrl) then {
					//-- HC waypoint sync
					A3C_CONNECTING_MODE = "HCSYNC";
					A3C_BOOL_DRAGLINE = true;
					A3C_HC_VEHICLEBOARD_GROUPS = [_gp];
					A3C_CLICKPOS_ORIG =  A3C_CLICKPOS_1;
					A3C_BOOL_MOUSEMOVING = true;
					A3C_HC_WP_SYNC_ROOT = [_gp,_wpiC];
					A3C_MMCode = {
						_this spawn {
							params ["_clickData","_sX","_sY"];
							_a3c_dsp = if (visibleMap) then {6998} else {6999};
							if (isNull findDisplay _a3c_dsp) exitWith {};
							_map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
							A3C_DRAGPOS = (_map1 posscreentoworld [_sx,_sy]);
						};
					};
				} else {
					if ([_gp,_wpIC] in A3C_BLACKLIST_WAYPOINT_EDIT) then {
						systemchat  "A3C: It is too late to move this waypoint - wait for completion";
					} else {
						//-- waypoint marker about to be moved
						A3C_BOOL_MOUSEUP = true;
						A3C_BOOL_MOUSEMOVING = true;
						A3C_HC_TOSWITCH = [_gp,_wpIC];
						A3C_HC_ACTIVEGROUP = _gp;
						A3C_HC_ACTIVE_IND = _wpIC;
						A3C_UI_MAP_BOOL_isHCWaypointPosEdit = true;
						if (["PlantExplosive_HC",(waypointStatements [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND]) select 1 ] call BIS_fnc_instring) then {
							A3C_HC_DETONATION_BOOL = true;
						};
						// [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] waypointAttachVehicle (leader A3C_HC_ACTIVEGROUP); systemchat 'wtf';
						A3C_UI_MAP_BOOL_isHCWaypointPosEdit = true;
						A3C_MMCode = {
							[A3C_HC_TOSWITCH,_this] spawn A3C_MOVEHC;
						};
					};
				};

				_exit = true;

			} else {

				_wpIcons = (["HC_WP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
				if (count _wpIcons > 0) then {
					_exit = true;
					_wpIcon = _wpIcons select 0;
					_gp = _wpIcon select 0;
					_wpiC = _wpIcon select 3;
					[_gp,_wpiC,A3C_HC_EDIT_ACTION,_a3c_dsp,[_sx, _sy]] call A3C_OPEN_RC_HC;
					_resetSelection = false;
				};
			};

		};
	};

	if (_exit) exitWith {};

	//-- detect click on PLAYER SQUAD UNIT ICONS
	_sqIcons = (["SQUAD",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	if (count _sqIcons > 0) exitWith {
		_sqIcon = _sqIcons select 0;
		A3C_SQ_CLICKED_UNIT = _sqIcon select 0;
		if (_left) then {
			if (_ctrl && _shift) then {
				_cargoObjects = ([vehicle A3C_SQ_CLICKED_UNIT] call MCSS_fnc_getNearCargoLoadObjects);
				if ( ((getPosATL (vehicle A3C_SQ_CLICKED_UNIT)) select 2) < 1) then {
					if ((count _cargoObjects > 0) && (A3C_SQ_CLICKED_UNIT == driver (vehicle A3C_SQ_CLICKED_UNIT))) then {
						_parent = findDisplay _a3c_dsp displayCtrl A3C_ObjectSelector_Parent;
						_text = findDisplay _a3c_dsp displayCtrl 800802;
						_listBox = findDisplay _a3c_dsp displayCtrl 800803;
						//(findDisplay 6998 displayCtrl A3C_HC_GROUP_MENU_CTRLPARENT) ctrlShow false;
						A3C_OBJECTSELECTOR_MODE = "PARALOAD_SQ";
						_parent ctrlShow true;
						_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
						_parent ctrlCommit 0;
						_text ctrlSetText "Select Object to load";
						ctrlSetFocus _listBox;
						
						lbClear _listBox;

						{
							private _lbText = format ["%1 (%2m)",(getText (configfile >> "CfgVehicles" >> typeof _x >> "displayName")),round( (vehicle A3C_SQ_CLICKED_UNIT) distance _x)];
							[_listBox, _lbText] call A3C_addLbEntry;
						} foreach _cargoObjects;
						
						_exit = true;
					};
					//systemchat str _sqUnit;
				};
			} else {
				if (A3C_SQ_CLICKED_UNIT == driver (vehicle A3C_SQ_CLICKED_UNIT)) then {
					A3C_SELECTED_UNITS = if (_ctrl) then {
						if (A3C_SQ_CLICKED_UNIT in A3C_SELECTED_UNITS) then {
							A3C_SELECTED_UNITS - [A3C_SQ_CLICKED_UNIT]
						} else {
							A3C_SELECTED_UNITS + [A3C_SQ_CLICKED_UNIT];
						};
					} else {
						[A3C_SQ_CLICKED_UNIT]
					};

					private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SELECTOR_TREE;
					_CT_TREE tvSetCurSel [-1];

					if (count A3C_SELECTED_UNITS == 1) then {
						_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
						if (count _button > 0) then {
							_button = _button select 0;
							_buttonParent = _button select [0,count _button -1];
							if ([_button select 0] in A3C_MAPTAB_TREES_OPEN) then {
								//systemchat str _button;
								_CT_TREE tvSetCurSel _button;
								[
									[
										findDisplay 6998 displayCtrl 202020,
										_button select [0,(count _button) - 1]
									],
									"OPEN",
									false,
									0.1
								] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE
							};
						};
						//if ( ((A3C_SELECTED_UNITS select 0) == A3C_SQ_CLICKED_UNIT) && (A3C_HELI_INF_MODE == "INF") ) then {
						if (count A3C_SELECTED_UNITS > 0) then {
							A3C_MAP_DRAGPLANNING_ACTIVE = true;
							A3C_BOOL_MOUSEMOVING = true;
							A3C_MMCode = {
								_this spawn A3C_TAB_MouseDrag;
							};
						};
						_exit = true; //~~?	
					};
					
					//-- toggle or collapse wpsettings bar
					_foldMode = if (count A3C_SELECTED_UNITS > 0) then {"OPEN"} else {"COLLAPSE"};
					[_foldMode,0.1] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
					//A3C_SELECTED_UNITS = [A3C_SQ_CLICKED_UNIT];
					if (vehicle A3C_SQ_CLICKED_UNIT isKindOf "AIR") then {
						A3C_HELI_INF_MODE = "AIR";
						["AIR"] call A3C_START_TABMODE;
					} else {
						A3C_HELI_INF_MODE = "INF";
						["INF"] call A3C_START_TABMODE;
					};
				};
			};			
		};
	};

	//-- detect click on FORCE TRACKER ICON
	_trIcons = (["TRACKER",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	//systemchat str _trIcons;
	if ( !(_left) && (count _trIcons > 0)) exitWith {
		_trIcon = _trIcons select 0;
		if (_trIcon select 3 == "ENEMY") then {
			A3C_LB_MODE = 1;
			A3C_TRACKED_ENEMYGROUP = _trIcon select 0;
			lbClear ((findDisplay _a3c_dsp) displayCtrl 7078);
			((findDisplay _a3c_dsp) displayCtrl 7078) ctrlShow true;
			ctrlsetfocus (finddisplay _a3c_dsp displayctrl 7078);
			(findDisplay _a3c_dsp displayCtrl 7078) ctrlSetPosition [_sx, _sy];
			(findDisplay _a3c_dsp displayCtrl 7078) ctrlCommit 0;
			[findDisplay _a3c_dsp displayCtrl 7078, "Ignore"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl 7078, "Attack"] call A3C_addLbEntry;

			[findDisplay _a3c_dsp displayCtrl 7078, 0] call A3C_setCurSel;
			
		};
	};


	//-- detect click on UI POLYGON MAIN MARKERS
	private _mapPolygons =(["POLY_MAIN",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	if (count _mapPolygons > 0 && {_left}) exitWith {

		private _mapPolygon = _mapPolygons select 0;

		private _polyID = (_mapPolygon select 0);
		A3C_MovedItem_ID = _polyID; //= "";
		if ({((_x select 0) select 1) == _polyID} count A3C_ALL_POLYS > 0) then {
			A3C_BOOL_MOUSEUP = true;
			A3C_BOOL_MOUSEMOVING = true;
			A3C_BOOL_MOVINGMARKER = true;
			A3C_DRAGPOS = [_sx, _sy];
			{
				private _polyRefID = (_x select 0) select 1;
				if (_polyID == _polyRefID) exitWith {
					//systemchat str _polyRefID;
					A3C_CUR_EDIT_POLY = ([(_x select 0) select 0,0,"",false] call A3C_SUP_CREATE_POLY) select 0; //~~ poly: what is going on here: since create_poly does not create markers, it is used to find // 0 is replacing (markerDir A3C_MovedItem_ID)
					A3C_MMCode = if (_ctrl) then {
						{[_this,A3C_MovedItem_ID,"WP",true,false] spawn A3C_MoveMapItem;}
					} else {
						if (_alt) then {

							{[_this,A3C_MovedItem_ID,"WP",false,true] spawn A3C_MoveMapItem;}
						} else {
							{[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_MoveMapItem;}
						};
					};


				};
			} foreach A3C_ALL_POLYS;

		};
		_exit = true;
	};

	//-- detect click on UI POLYGON EDGE MARKERS
	private _mapPolygonEdges = (["POLY_EDGE",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	if (count _mapPolygonEdges > 0 && {_left}) exitWith {
		private _PolygonEdgeIcon = _mapPolygonEdges select 0;
		_parentPoly = _PolygonEdgeIcon select 0;
		_edgePosition = _PolygonEdgeIcon select 2;
		//systemchat str _PolygonEdgeIcon;

		{
			private _polyRefID = (_x select 0) select 1;
			if (_parentPoly == _polyRefID) exitWith {

				_poses = _x select 1;
				private _ind = [_edgePosition,_poses] call MCSS_fnc_GetArrayINdex;
				A3C_MovedItem_ID = [_parentPoly,_ind];
				A3C_BOOL_MOUSEUP = true;
				A3C_BOOL_MOUSEMOVING = true;
				A3C_BOOL_MOVINGMARKER = true;
				A3C_DRAGPOS = [_sx, _sy];
				A3C_MMCode = {
					_this call A3C_Adjust_Poly_Edge;
				};
			};
		} foreach A3C_ALL_POLYS;

		_exit = true;
	};



	//-- detect click on PLAYER SQUAD UNIT WAYPOINT ICON
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	if (count _squadWaypoints > 0) exitWith {
		private _squadWaypointSelected = _squadWaypoints select 0;
		_squadWaypointSelected params ["_unit","_size","_position","_wpDotIDS"];
		if (_left) then {
			A3C_MovedItem_ID = if (_wpDotIDS select 1 == "" ) then {_wpDotIDS select 0} else {_wpDotIDS select 1};
			if !(_ctrl) then {
				A3C_BOOL_MOUSEUP = true;
				A3C_BOOL_MOUSEMOVING = true;
				A3C_BOOL_MOVINGMARKER = true;
				A3C_DRAGPOS = [_sx, _sy];
				A3C_MMCode = {[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_MoveMapItem;};
			} else {
				[_sx,_sy] call A3C_TAB_LOOP_LM_DOWN;
			};
		} else {
			[_wpDotIDS select 0,[_sX,_sY]] call A3C_RC_Menu_Inf;
		};
	};

	//-- detect click on PLAYER SQUAD UNIT WAYPOINT LOOKDIR ICON
	private _squadWaypointLookDirs = (["SQ_WP_LOOKDIR",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	if (count _squadWaypointLookDirs > 0) exitWith {
		A3C_DIR_POS = (_map1 posscreentoworld [_sx,_sy]);
		private _squadWaypointLookDirSelected = _squadWaypointLookDirs select 0;
		_squadWaypointLookDirSelected params ["_unit","_size","_area","_markerID"];
		A3C_MovedItem_ID = _squadWaypointLookDirSelected;
		A3C_BOOL_MOUSEUP = true;
		A3C_BOOL_MOUSEMOVING = true;
		A3C_BOOL_MOVINGMARKER = true;
		A3C_DRAGPOS = [_sx, _sy];
		A3C_MMCode = {[_this,A3C_MovedItem_ID,"LDIR",false,false] spawn A3C_MoveMapItem;};
	};





	if (_exit) exitWith {};




	//-- 7078 (UnitButton RMB-contextMenu) requires special assistance: 0.1 delay is required for lb-selection to fire!!
	if (ctrlShown (findDisplay _a3c_dsp displayCtrl 7078)) exitWith {
		sleep 0.1;
		if !(A3C_MAPTAB_OPENING_CONTEXTMENU OR ([[_sX,_sY],findDisplay _a3c_dsp displayCtrl 7078] call MCSS_fnc_isClickPosInCTRLArea)) then {
			sleep 0.1;
			((findDisplay _a3c_dsp) displayCtrl 7078) ctrlShow false;
		};
	};



	//-- mapclick is within overlay area >> exit
	if (_a3c_dsp == _a3c_dsp && {[[_sX,_sY],findDisplay _a3c_dsp displayCtrl 11] call MCSS_fnc_isClickPosInCTRLArea}) exitWith {};




	if (_left) then {
		if ( {ctrlShown ((findDisplay _a3c_dsp) displayCtrl _x)} count [7078,A3C_RC_Context] > 0) then  { ////~~~~ ?????
			_exit = true;
		};
	};

	//-- hide other contextmenu's
	_ctls = if (visibleMap) then {[A3C_RC_Context,A3C_RC_Context_HC_WP,709135,A3C_ObjectSelector_Parent]} else {[A3C_RC_Context,709112,709135,A3C_ObjectSelector_Parent]};
	{
		if !([[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea) then {
			((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false;
		};
	} foreach _ctls;

	if (_exit) exitwith {};

	if (visibleMap) then {
		if !(isnull (findDisplay 6998 displayCtrl A3C_RC_Context)) then {
			if ([_a3c_dsp] call A3C_InMapControls) then {
				_exit = true;
			};
		};
	};

	if (_exit) exitWith {};







	//-- right Mouse Button
	if !(_left) exitwith {
		private _resetSelection = true;
		((findDisplay _a3c_dsp) displayCtrl A3C_RC_Context) ctrlShow false;


		if (_resetSelection) then {
			if (_ctrl) then {
				A3C_SELECTED_UNITS = [];
				A3C_SELECTED_HC_GROUPS_SETTINGS = [];
				["COLLAPSE",0.1] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
				[A3C_HELI_INF_MODE] call A3C_START_TABMODE;
			};
		};
	};


	if (_exit) exitwith {};

	//-- LeftClick on A3-HC marker //~~??
	if (_isHighCommand) then {
		if (A3C_HELI_INF_MODE == "HC") then {
			if ([_sX,_sY] call A3C_ISNEARHC) then {
				systemchat "ALERT! PLEASE REPORT IF YOU SEE THIS ERROR: MAP_LEFTDOWN_OLD_HC";
				A3C_BOOL_MOUSEUP = true;
				A3C_BOOL_MOUSEMOVING = true;
				A3C_BOOL_MOVINGHC = true;
				A3C_MMCode = {
					[A3C_HC_TOSWITCH,_this] spawn A3C_MOVEHC
				};
				_exit = true;
			};
		};
	};






	if (_exit) exitwith {};

	A3C_MovedItem_ID = "";
	if (A3C_TAB_BUILDING_BOOL) then {
		[] call A3C_DELETE_BPOS_MARKERS;
		A3C_TAB_BUILDING_BOOL = false;
	};

	//-- Left Click on empty Area
	if (((A3C_TEMP_ACTION select 0) == "GRENADE") && {count A3C_AI_GREN_ARRAY == 0}) exitWith {
		systemchat "A3C: No grenades available with current selection";
	};


	//-- Current Mode is HC
	if (A3C_HELI_INF_MODE == "HC" && !(_ctrl)) exitWith {
		if ((count A3C_SELECTED_UNITS) > 0) then {
			if !(ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_HC_GROUP_MENU_CTRLPARENT)) then {
				if (_alt) then {
					//-- clear all waypoints
					{
						{
							_x setVariable ["A3C_CLEARING",false,true];
						} foreach (units _x);
					} foreach A3C_SELECTED_UNITS;
					
					{
						_gp = _x;
						while {(count (waypoints _gp)) > 1} do {
							{
								if (_forEachIndex > 0) then {
									deletewaypoint _x;
									A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_x];
								};
							} foreach waypoints _gp;
						};
						// private _effCom = effectiveCommander (vehicle leader _gp);
						// [_effCom, A3C_CLICKPOS_1] call A3C_DOMOVE;
					} foreach A3C_SELECTED_UNITS;
					publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';
					
				};
				private _formDir = A3C_CLICKPOS_1 getDir (position (leader (A3C_SELECTED_UNITS select 0)));
				private _factor = 1;

			//	if (isOnRoad A3C_CLICKPOS_1) then {
			//		systemchat 'ay';
			//		_nearRoads = (A3C_CLICKPOS_1 nearroads 30);
			//		if (count _nearRoads > 0) then {
			//			A3C_CLICKPOS_1 = position (_nearRoads select 0);
			//		};
			//	};

				private _clickPos = +A3C_CLICKPOS_1;

				A3C_MULTIWAYPOINT = true;
				if (count A3C_SELECTED_UNITS > 2) then {
					A3C_MULTIWAYPOINT = false;
					["MULTIWAYPOINT"] call A3C_OPEN_OBJECTSELECTOR_MAP;
					waituntil {!ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_ObjectSelector_Parent)};
				};
				//systemchat str ['ey1',A3C_MULTIWAYPOINT];
				//systemchat str [_clickPos,isOnRoad _clickPos];
				private _refArray = +A3C_SELECTED_UNITS; // select {(driver (vehicle leader _x))  in units _x};
				
				//private _switchsafe = false;
				if (count _refArray > 1) then {

					private _infantryOnly = true;
					{
						if ({!isNull objectParent _x && {_x == driver (objectParent _x)}} count (units _x) > 0 ) exitWith { //
							_infantryOnly = false;
						};
					} foreach _refArray;

					if !(_infantryOnly) then {
						_refArray = _refArray select {
							private _lVIc = objectParent (leader _x); !isNull _lVIc && {driver _lVIc in (units _x)}
						};
					};
				};

				

				//-- remember - A3C_MULTIWAYPOINT can be true with one unit selected - it's used by the security
				if (A3C_MULTIWAYPOINT) then {
					
					if (count A3C_SELECTED_UNITS == 1) then {
						private _wpPos = _clickPos;
						private _gp = A3C_SELECTED_UNITS select 0;
						_wpParams = [_gp,_wpPos];
						_eligibleForBuildingSearch  = {!isNull objectParent _x && {(assignedVehicleRole _x) select 0 != "cargo"}} count (units _gp) == 0;
						_addWp = true;
						if (_eligibleForBuildingSearch) then {
							_nearestB = nearestBuilding _clickPos;

							_ref = waypoints _gp;
							{
								if (_x select 1 < currentWaypoint _gp) then {
									_ref = _ref - [_x];
								};
							} foreach _ref;
							if ({[waypointPosition _x,_nearestB] call A3C_fnc_INSIDE} count _ref > 0) then {
								_addWP = false;
							};

							if ([_clickPos,_nearestB] call A3C_fnc_INSIDE) then {
								_wpParams set [1,_nearestB buildingPos 0];
								_wpParams set [2,[]];
								_wpParams = _wpParams +
								[
									"MOVE",
									[0,0,A3C_STANCE1_TEMP,A3C_STANCE2_TEMP,A3C_WP_SPEED_TEMP,"CLEARBUILDING"]
								];
							};		
						};
						if (_addWP) then {
							_wpParams call A3C_HC_ADD_WP;
						} else {
							systemchat "A3C: Clearing this building is already planned for this group";
						};
					} else {
						/*
						_pathFnc = {
							params ["_unit"];
							if !(local _unit) exitWith {};
							private _handle = _unit addEventHandler 
							[
								"PathCalculated",
								{
									params ["_agent", "_path"];
									if (count _path == 2 && {(_path select 0) isEqualTo (_path select 1)}) exitWith {};
									private _data = _agent getVariable ["A3C_PathHandler",[-1,-1]];
									_data params ["_handler","_sumDist"];
									if (_handler == -1) exitWith {};
									private _distance = 0;
									{
										_pathpos = _x;
										if (_foreachIndex > 0) then {
											_distance = _distance + (_pathpos distance (_path select (_forEachIndex - 1)));
										} else {
											_distance = _distance + (vehicle _agent distance _pathPos);
										};
									} forEach _path;
									
									_data set [1,_distance];
									_agent removeEventhandler ["PathCalculated",_handler];
									_data set [0,-1];
									_agent setVariable ["A3C_PathHandler",_data,false];
									
								}
							];
							_unit setVariable ["A3C_PathHandler",[_handle,-1],false];
						};
						*/

						//private _drivers = [];
						//systemchat str _refArray;
						// true; //{currentWaypoint _x >= count waypoints _x} count A3C_SELECTED_UNITS > 0;
						[_refArray,_clickPos] spawn A3C_FNCS_CONVOY_MULTIGROUP;
					};

					
				};
				A3C_BOOL_MOUSEUP = true;
			};
		};
	};

	if (_ctrl) exitWith {
		[_sx,_sy] call A3C_TAB_LOOP_LM_DOWN;
	};



	//-- Current Mode is Non - HC

	A3C_CLICKPOS_ORIG = A3C_CLICKPOS_1;
	A3C_TAB_BUILDING = (nearestBuilding A3C_CLICKPOS_1);

	if (A3C_HELI_INF_MODE == "INF") then {
		if !(A3C_FORMMODE_TEMP == 5) then {
			if ([A3C_CLICKPOS_1,A3C_TAB_BUILDING] call A3C_fnc_INSIDE) then {
				if ((count A3C_SELECTED_UNITS) > ([A3C_TAB_BUILDING] call MCSS_fnc_countBPos)) then {
					if (A3C_TAB_BUILDING_BOOL) then {
						[] call A3C_DELETE_BPOS_MARKERS;
						A3C_TAB_BUILDING_BOOL = false;
					};
					player groupchat "selection surpasses building capacity";
					_exit = true;
				};
				if !(_exit) then {
					A3C_CLICKPOS_1 = A3C_TAB_BUILDING buildingPos 0;
					A3C_CLICKPOS_ORIG = A3C_TAB_BUILDING buildingPos 0;
					A3C_TAB_BUILDING_BOOL = true;
					[] call A3C_CREATE_BPOS_MARKERS;
				};
			} else {
				A3C_TAB_BUILDING = objnull;
			};
		};
	};
	if (_exit) exitwith {};

	if ((count A3C_SELECTED_UNITS) == 0) exitwith {};

	//-- precaution: if player is effectiveCommander of vehicle, ALT must be held down to prevent clash with engine-command
	//if ( ({(player == (effectivecommander (vehicle _x)))  && (_x == (driver (vehicle _x)))} count (units group player - [player]) > 0) && !(_alt) && (_left)) exitwith {};



	A3C_BOOL_MOUSEUP = true;
	if (A3C_TAB_TOGGLE_VAR == 0) then {
		//if (true) then {
			//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [7041,7092];
			(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow true;
			(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,1];
		//};
	};



	//if (_exit) exitWith {};
//systemchat 'yo';
	//-- Create Dummy to have target for Direction-Arrow.
	if !(A3C_BOOL_DRAGLINE) then {
		A3C_BOOL_DRAGLINE = true; //  
		//systemchat str time;
	};



	A3C_MovedItem_ID = "";


	A3C_BOOL_MOUSEMOVING = true;
	if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION","SLINGLOAD","CTRL_DET","STATIC"]) then { //~~ REMOVE GRENADE FROM THIS??   "GRENADE",
		A3C_CONNECTING_MODE = "LOOKDIR";
		A3C_MMCode = {
			_this spawn A3C_TAB_MouseDrag;
		};
	};

	_pos = A3C_CLICKPOS_ORIG;
	if (A3C_FORMMODE_TEMP == 5) then {
		A3C_RADIMARK = ["A3C_RADIMARK",_pos,"Ellipse","Ellipse",[0,0],"","ColorOrange",0,"SolidBorder"] call MCSS_fnc_createMarker;
		"A3C_RADIMARK" setmarkeralphaLocal 1;
	};
	if (A3C_TAB_BUILDING_BOOL) then {
			_pos = A3C_TAB_BUILDING buildingPos 0;
	};

	if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
		A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut)));
	};
	//switch (A3C_HELI_INF_MODE) do { //-- done above via A3C_MAP_fnc_CT??
	//	case ("INF") :{
	//		A3C_SPACING_INF = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066)));
	//	};
	//	case ("AIR") :{
	//		A3C_SPACING_AIR = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl 7066)));
	//	};
	//};




	//~~WTF CLEAN THIS UP, move up in the swith block! :S
	if ((A3C_TEMP_ACTION select 0) == 'CTRL_DET') then {

		if (count A3C_SELECTED_UNITS == 1) then {
			if (isNull objectParent (A3C_SELECTED_UNITS select 0)) then {
				A3C_STATE_CHECKING_PICKUP = true;
				A3C_PICKUP_OBJECTS = [A3C_SELECTED_UNITS select 0,A3C_CLICKPOS_ORIG,250,true] call MCSS_fnc_nearDetonationTargets;
				{
					if !(typeName _x == "OBJECT") then {
						A3C_PICKUP_OBJECTS = A3C_PICKUP_OBJECTS - [_x];
					};
				} forEach A3C_PICKUP_OBJECTS;
				if (count A3C_PICKUP_OBJECTS > 0) then {


					A3C_CONNECTING_MODE = "";
					A3C_MMCode = {
						_this spawn A3C_TAB_MouseDrag;
					};
				};

			} else {
				_exit = true;
				systemchat "A3C: Planting charges is only available for infantry.";
			};
		} else {
			systemchat "A3C: Placing charges is only compatible with single unit selections.";
			_exit = true;
		};
	};
	private _packMode = "";

	if ((A3C_TEMP_ACTION select 0) == 'STATIC') then {

		_packMode = [A3C_SELECTED_UNITS] call A3C_SMART_getWeaponAssemblyMode;
		if (_packMode in ["ASSEMBLE","DUAL"]) then {
			_packMode = "ASSEMBLE";
			_text = (getText (configfile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName"));
			A3C_TEMP_ACTION = ["STATIC",["ASSEMBLE",((A3C_STATIC_PACKS select 0) select 1)]];
			A3C_CONNECTING_MODE = "LOOKDIR";
			A3C_MMCode = {
				_this spawn A3C_TAB_MouseDrag;
			};
		} else {
			//_mSize = [0.5,0.5];
			A3C_STATE_CHECKING_PICKUP = true;
			A3C_PICKUP_OBJECTS = []; //-- find near statics to selected units
			{
				if ( (!alive (gunner _x)) OR ((gunner _x) in A3C_SELECTED_UNITS) ) then {
					A3C_PICKUP_OBJECTS pushbackUnique _x;
				};
			} foreach (A3C_CLICKPOS_ORIG nearObjects ["Staticweapon", 250]);

			if (count A3C_PICKUP_OBJECTS > 0) then {

				A3C_PICKUP_MARKERS = [];

				A3C_CONNECTING_MODE = "";
				A3C_MMCode = {
					_this spawn A3C_TAB_MouseDrag;
				};
			} else {
				systemchat "A3C: No static weapons found or allowed";
				_exit = true;
			};
		};

	};
	if ((A3C_TEMP_ACTION select 0) == 'SLINGLOAD') then {
		//_mCol = 'DEFAULT';
		//_mSize = [1,1]; uuu


		//SYSTEMCHAT 'UU1';

		if (count A3C_SELECTED_UNITS == 1) then {
			if ( (vehicle (A3C_SELECTED_UNITS select 0)) isKindOf 'HELICOPTER') then {
				if ([A3C_SELECTED_UNITS select 0,-1,"SQ"] call A3C_Sling_willBeLoaded) then {
				} else {
					A3C_STATE_CHECKING_PICKUP = true;
					A3C_PICKUP_OBJECTS = [vehicle (A3C_SELECTED_UNITS select 0),A3C_CLICKPOS_ORIG] call MCSS_fnc_getNearSlingLoadObjects;
					{
						if !(typeName _x == "OBJECT") then {
							A3C_PICKUP_OBJECTS = A3C_PICKUP_OBJECTS - [_x];
						};
					} forEach A3C_PICKUP_OBJECTS;
					if (count A3C_PICKUP_OBJECTS > 0) then {
						A3C_CONNECTING_MODE = "";
						A3C_MMCode = {
							_this spawn A3C_TAB_MouseDrag;
						};
					} else {
						systemchat "A3C: No sling-objects found";
						_exit = true;
					};
				};
			} else {
				_exit = true;
				systemchat "A3C: Slingload is only compatible with helicopters.";
			};
		} else {
			systemchat "A3C: Slingload is only compatible with single unit selections.";
			_exit = true;
		};
	};

	if (_exit) exitWith {
		A3C_BOOL_DRAGLINE = false;
		A3C_BOOL_MOUSEUP = false;
	};


	A3C_TEMP_WP_ID_MAIN = if ((A3C_TEMP_ACTION select 0) in ["SUPPRESSION"]) then {format ['A3C_SUP_WP_Mark_%1',A3C_MARKER_COUNT]} else {format ['A3C_Mark_P%1',A3C_MARKER_COUNT]};
	A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
	//A3C_MARKERS_TEMP pushback A3C_TEMP_WP_ID_MAIN;
	if (  ((A3C_TEMP_ACTION select 0) in ['SLINGLOAD','CTRL_DET']) OR (_packMode == "DISASSEMBLE")  ) then {
		A3C_MovedItem_ID = A3C_TEMP_WP_ID_MAIN;
	};



	A3C_UNDO_MODE = 0;
	[0] call A3C_SET_ORDER_WIP;

};





A3C_BOOL_MOUSEMOVING = false;

A3C_MAP_DRAGPLANNING_POSITIONS = [];
A3C_MAP_DRAGPLANNING_ACTIVE = false;

A3C_TAB_MouseDrag = {
	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};


	_sx = _this select 1;
	_sy = _this select 2;
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	disableSerialization;
	_map1 = if (_a3c_dsp == 6998) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	_sPos = (_map1 posscreentoworld [_sx,_sy]);

	if (A3C_MAP_DRAGPLANNING_ACTIVE) then {
		_addToDrag = false;
		A3C_DRAGPOS = _sPos;
		private _targetUnit = if (typeName A3C_SQ_CLICKED_UNIT == "GROUP") then {leader A3C_SQ_CLICKED_UNIT} else {(A3C_SELECTED_UNITS select 0)}; //--aaa
		if ((time - A3C_LB_TICKTIME) > 0.3) then {
			if (count A3C_MAP_DRAGPLANNING_POSITIONS == 0) then {
				if ((_targetUnit distance2D _sPos >= 5)) then {
					_addToDrag = true;
				};
			} else {
				if (_spos distance2d (A3C_MAP_DRAGPLANNING_POSITIONS select  ((count A3C_MAP_DRAGPLANNING_POSITIONS) -1) )  >= 5) then {
					_addToDrag = true;
				};
			};
			if (_addToDrag) then {
				//systemchat str time;
				A3C_MAP_DRAGPLANNING_POSITIONS pushBack _sPos;
				//hintsilent str A3C_MAP_DRAGPLANNING_POSITIONS;
			};
		};
	};


	A3C_DRAGPOS = _sPos;

	if (A3C_BOOL_DRAGLINE) then {
		//A3C_AIC_DRAGPOS = _sPos;
		if (A3C_STATE_CHECKING_PICKUP) then {
			//A3C_MovedItem_ID setMarkerPosLocal _sPos;
			private ["_unit","_wpData"];
			_unit = A3C_SELECTED_UNITS select 0;
			_wpData = _unit getVariable "A3C_PLOT_TEMP";
			{
				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				if ((_wpMarkers select 0) == A3C_MovedItem_ID) then {
					(_x select 0) set [0,_sPos];
				};
			} foreach _wpData;
			_unit setVariable ["A3C_PLOT_TEMP",_wpData,true];
		};
	};
	if !(getmarkerColor "A3C_RADIMARK" == "") then {
		_size = (getmarkerPos "A3C_RADIMARK") distance2d _sPos;
		"A3C_RADIMARK" setMarkerSizeLocal [_size,_size];
	};
};


A3C_DRAGPOS = [];
A3C_Prevent_SCALING = false;

A3C_BEHAVIOUR_HC_MoveToWayPointPosition = {
	params ["_group","_wpi"];

	// systemchat str ["MVTWPS",time];
	private _leader = leader _group;
	if (!isPlayer leader _group) then {
		//_group setCurrentWaypoint [_group,(currentWaypoint _group)];
		sleep 1.5;
		[_leader,waypointposition [_group,_wpi]] call A3C_DOMOVE;
		sleep 1;
		_leader setDestination [waypointposition [_group,_wpi],"FORMATION PLANNED",true];
		//private _grunts = ((units _group) - [_leader]) select {!isPlayer _x && {isNull objectParent _x}};
		//_grunts doFollow (leader _group);
	};
};


A3C_UI_MAPTAB_CLOSEMENU = {
	params ["_a3c_dsp","_ctrlID"];
	//systemchat str _this;
	//systemchat str A3C_UI_MAPTAB_CircleMenu_CTRLS;
	{
		{
			ctrlDelete (findDisplay _a3c_dsp displayCtrl _x);
		} foreach _x;
	} foreach A3C_UI_MAPTAB_CircleMenu_CTRLS;
	A3C_UI_MAPTAB_isCircleMenu = false;
};
//






A3C_UI_MAPTAB_SYNC_LoadGroupInVehicle = {
	private ["_wp","_syncWps"];

	_wp = [A3C_UI_MAPTAB_SYNC_HOSTGROUP,A3C_UI_MAPTAB_SYNC_HostWPI];

	_syncWps = synchronizedWaypoints _wp;
	A3C_UI_MAPTAB_SYNC_HOSTGROUP setVariable ["A3C_HC_SYNCWPS",_syncWps,true]; //~~ necessary?

	private _precond = [((waypointStatements _wp) select 0), waypointTimeout _wp] call A3C_GetConditionFromStatements;
	_wp setWayPointType "SCRIPTED";
	_wp setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_LoadGroupInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
	_wp setWaypointTimeout [0,0,0];
	
	{
		_precond = [((waypointStatements _x) select 0), waypointTimeout _x] call A3C_GetConditionFromStatements;
		_x setWayPointType "SCRIPTED";
		_x setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
		_x setWaypointTimeout [0,0,0];
	} foreach _syncWps;
};


A3C_UI_MAPTAB_SYNC_LoadVehicleInVehicle = {
	private ["_wp","_syncWps"];

	_wp = [A3C_UI_MAPTAB_SYNC_HOSTGROUP,A3C_UI_MAPTAB_SYNC_HostWPI];
	_syncWps = synchronizedWaypoints _wp;
	A3C_UI_MAPTAB_SYNC_HOSTGROUP setVariable ["A3C_HC_SYNCWPS",_syncWps,true]; //~~ necessary?

	private _precond = [((waypointStatements _wp) select 0), waypointTimeout _wp] call A3C_GetConditionFromStatements;
	_wp setWayPointType "SCRIPTED";
	_wp setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_LoadVehicleInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
	_wp setWaypointTimeout [0,0,0];
	{
		_precond = [((waypointStatements _x) select 0), waypointTimeout _x] call A3C_GetConditionFromStatements;
		_x setWayPointType "SCRIPTED";
		_x setWayPointScript format ["A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetVehicleInVehicle.sqf ['%1',%2]",getPlayerUID player, _precond];
		_x setWaypointTimeout [0,0,0];
	} foreach _syncWps;
};





A3C_FNC_SYNC_WP = {
	params ["_wp","_syncData"];
	_wp synchronizeWaypoint _syncData;
};


A3C_LEFTMOUSEUP = {
	private ["_exit","_sX","_sY","_sPos","_marker","_veh","_unit","_wpData"];



	//A3C_ConvoyUnits = [];

	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	_sX = _this select 2;
	_sY = _this select 3;
	private _shift = _this select 4;
	disableserialization;

	

	private _map1 = if (_a3c_dsp == 6998) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	private _sPos = (_map1 posscreentoworld [_sx,_sy]);

	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};

	//
	

	if (A3C_UI_MAP_BOOL_isHCWaypointPosEdit) then {
		// systemchat format ["selected WP: %1",[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND]];

		//-- SELECT HC GROUP THAT OWNS THE CLICKED WAY POINT. >> maybe add check if waypoint was moved, ignore if moved to only select on click??
		A3C_SELECTED_UNITS = [A3C_HC_ACTIVEGROUP]; //-- #TODO: this whole 'A3C_SELECTED_HC_GROUPS_SETTINGS', 'A3C_SELECTED_HC_GROUPS_SETTINGS', 'RD_UNITS' layout is a mess boiiii! IMPROVE
		A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
		A3C_HELI_INF_MODE == "HC";
		[] call A3C_UNITSEL_REFRESH_UI;

		//~~
		//-- #TODO: #HuiHui -- streamline this duplicate code for visualizing selection change in tree-UI
		private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SELECTOR_TREE;
		_CT_TREE tvSetCurSel [-1];
		//sleep 0.7;
		//playsound 'A3C_MenuSound1';
		//0.3;
		
		if (count A3C_SELECTED_UNITS == 1) then { //--
			_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
			if (count _button > 0) then {
				_button = _button select 0;
				_buttonParent = _button select [0,count _button -1];
				if ([_button select 0] in A3C_MAPTAB_TREES_OPEN) then {
					_CT_TREE tvSetCurSel _button;
					[
						[
							findDisplay 6998 displayCtrl 202020,
							_button select [0,(count _button) - 1]
						],
						"OPEN",
						false,
						0.1
					] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE
				};
			};	
		};
		//~~
		// systemchat format ["A3C_SELECTED_HC_GROUPS_SETTINGS: %1",A3C_SELECTED_HC_GROUPS_SETTINGS];


		//-- after moving the current HC waypoint of a group, send the leader to the position and make units follow him
		private _currentWP = currentWaypoint A3C_HC_ACTIVEGROUP;
		if (A3C_HC_ACTIVE_IND == _currentWP) then {
			[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] setwaypointposition [_sPos,0];

			if (waypointType [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] != "SCRIPTED") then {
				[_sPos] spawn {
					params ["_sPos"];
					sleep 1;
					// #HCMOVE
					[leader A3C_HC_ACTIVEGROUP,_sPos] call A3C_DOMOVE; //~~ #MONITOR
					//A3C_HC_ACTIVEGROUP move _sPos;

				};
			};
	
		};

		A3C_UI_MAP_BOOL_isHCWaypointPosEdit = false;
	};


	if (A3C_BOOL_DRAGLINE && {A3C_CONNECTING_MODE == "HCSYNC"}) exitWith  {
		
		A3C_CONNECTING_MODE = "";
		A3C_BOOL_DRAGLINE = false;
		if !(_isHighCommand) then {
			_wpIcons = (["HC_WP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
			A3C_HC_WP_SYNC_ROOT params ["_rootGroup","_rootWPI"];
			if (count _wpIcons > 0) then {
				_wpIcon = _wpIcons select 0;
				_gp = _wpIcon select 0;
				_wpiC = _wpIcon select 3;

				if (A3C_HC_WP_SYNC_ROOT select 0 != _gp) then {
					
					[[A3C_HC_WP_SYNC_ROOT,[ [_gp,_wpIC] ]],A3C_FNC_SYNC_WP] remoteExec ["bis_fnc_call",0];
					//[A3C_HC_WP_SYNC_ROOT,[ [_gp,_wpIC] ]] remoteExec ["synchronizeWaypoint",leader _rootGroup];
					//A3C_HC_WP_SYNC_ROOT synchronizeWaypoint [ [_gp,_wpIC] ]; //-- sync first , otherwise wrong indexes in MP
					//[_gp,_wpIC] synchronizeWaypoint [ A3C_HC_WP_SYNC_ROOT ];
					private _syncTypes = ["SYNC"];
					A3C_UI_MAPTAB_SYNC_BOARDGROUP = grpNull;
					A3C_UI_MAPTAB_SYNC_HOSTGROUP = grpNull;
					A3C_UI_MAPTAB_SYNC_BoardWPI = -1;
					A3C_UI_MAPTAB_SYNC_HostWPI = -1;
					private _targetLeadVic = objNull;
					{
						private _checkedGroup = _x;
						private _leadVic = vehicle (leader _checkedGroup);
						private _refGroup = if (_forEachIndex == 0) then {_rootGroup} else {_gp};
						private _refVic = vehicle (leader _refGroup);
						switch (true) do {
							case ({!isNull  objectparent _x} count units _checkedGroup == 0) : {
								//systemchat str typeof _refVic;
								//private _emptyPoses = 0;
								//{
								//	_emptyPoses = _emptyPoses + (_refVic emptypositions _x);
								//} foreach ["gunner","commander","cargo"];
								private _emptyPoses = [];
								{
									_v = objectParent _x;
									if (!isNull _v && {_x == driver _v}) then {
										_empty = (fullCrew [_v, "", true]) select 
										{
											isNull (_x select 0) &&
											{
												(_x select 1 == "cargo") OR
												{
													(_x select 1 == "Turret") && 
													{
														_x select 4
													}
												}
											}
										};
										if (count _empty > 0) then {
											//{
											//	_empty set [_foreachIndex, [_v] + _x];
											//} foreach _empty;
											_emptyPoses = _emptyPoses + _empty;
										};
									};
								} foreach (units _refGroup);
								if (count _emptyPoses >= (count units _checkedGroup)) then {
									A3C_UI_MAPTAB_SYNC_BOARDGROUP = _checkedGroup;
									A3C_UI_MAPTAB_SYNC_BoardWPI =  if (_checkedGroup == _gp) then {_wpIC} else {_rootWPI};
									A3C_UI_MAPTAB_SYNC_HostWPI =  if (_checkedGroup == _gp) then {_rootWPI} else {_wpiC};
									A3C_UI_MAPTAB_SYNC_HOSTGROUP = _refGroup;
									//_targetVeh = (vehicle leader _refGroup);
									_syncTypes pushBackUnique "GET IN";
								};

							};
							case ({vehicle _x != _leadVic} count units _checkedGroup == 0) : {
								if ((driver _leadVic) in (units _leadVic)) then {
									if ((_refVic canVehicleCargo _leadVic) select 0) then {
										A3C_UI_MAPTAB_SYNC_BOARDGROUP = _checkedGroup;
										A3C_UI_MAPTAB_SYNC_HOSTGROUP = _refGroup;
										A3C_UI_MAPTAB_SYNC_BoardWPI =  if (_checkedGroup == _gp) then {_wpIC} else {_rootWPI};
										A3C_UI_MAPTAB_SYNC_HostWPI =  if (_checkedGroup == _gp) then {_rootWPI} else {_wpiC};
										//systemchat str [_refVic,_refVic];
										_syncTypes pushBackUnique "VEHICLE GET IN";
									};
								};
							};
						};
					} foreach [_gp,_rootGroup];
					//systemchat str _syncTypes;
					if (count _syncTypes > 1) then {
						A3C_UI_MAPTAB_isCircleMenu = true;
						A3C_UI_MAPTAB_CircleMenu_CTRLS = [];
						private _cycle = 0;
						private _angle = 180;
						private _angleSplit = (360 / (count _syncTypes)) min 90;
						private _originPos = +(_sPos);
						//private _rad = _spos distance2d ();
						private _w = 0.0171838 * safezoneW;
						private _h = 0.0330053 * safezoneH;
						private _bgH = _h * 1.7;
						private _bgW = _w * 1.7;
						private _idc = 2000;
						{
							private _bgID = _idc;
							private _imgID = _idc + 1;
							private _clickerID = _idc + 2;
							
							private _btnBG  = (findDisplay _a3c_dsp) ctrlCreate ["A3C_RscPicture", _bgID];
							private _btnImg  = (findDisplay _a3c_dsp) ctrlCreate ["A3C_RscPicture", _imgID];
							private _btnClicker  = (findDisplay _a3c_dsp) ctrlCreate ["A3C_RscButton_Invisible", _clickerID];

							_btnBG ctrlSetText "A3C_UI\markers\icon_marker_vehicleHexagon.paa";
							_btnImg ctrlSetTextColor ([A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity);
							//systemchat str [_bgID,_imgID,_clickerID];
							private _btnFnc = {};
							switch (_x) do {
								case ("SYNC") : {
									_btnImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_sync.paa";
								};
								case ("GET IN") : {
									_btnImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
									_btnFnc = {[] call A3C_UI_MAPTAB_SYNC_LoadGroupInVehicle;};
								};

								case ("VEHICLE GET IN") : {
									_btnImg ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa";
									_btnFnc = {[] call A3C_UI_MAPTAB_SYNC_LoadVehicleInVehicle;};
								};
							};

							_btnClicker buttonSetAction format
							[
								"

									[%1] call A3C_UI_MAPTAB_CLOSEMENU;
									[] spawn %2;

								",
								_a3c_dsp,
								_btnFnc
							];
							_btnClicker ctrlSetToolTip _x;

							

							

							private _mainMacroPos = ([_sx,_sy] getPos [_bgH * 1.5,_angle]) select [0,2];    //-- 1. move to main pos (1.5x background height)
							
							private _outerMacroPos = (_mainMacroPos getPos [_bgH / 2, 180]) select [0,2]; //-- 2. adjust h
							_outerMacroPos = (_outerMacroPos getPos [_bgW / 2, -90]) select [0,2]; //-- 3. adjust w
							_btnBG ctrlSetPosition (_outerMacroPos + [_bgW,_bgH]);
							_btnBG ctrlCommit 0;

							private _innerMacroPos = (_mainMacroPos getPos [_h / 2, 180]) select [0,2]; //-- 2. adjust h
							_innerMacroPos = (_innerMacroPos getPos [_w / 2, -90]) select [0,2]; //-- 3. adjust w
							{
								_x ctrlSetPosition (_innerMacroPos + [_w,_h]);
								_x ctrlCommit 0;
							} foreach [_btnImg,_btnClicker];
							A3C_UI_MAPTAB_CircleMenu_CTRLS pushBackUnique [_bgID,_imgID,_clickerID]; //_bgID
							
							_angle = _angle - _angleSplit;

							_idc = _idc + 3;

						} foreach _syncTypes;
					};








					private _targetLeadVic = vehicle leader _gp;
					if ({!isNull  objectparent _x} count units _rootGroup == 0) then { //-- inf only groups can board a vehicle via sync

					} else {
						//-- units that are all in the same vic can be loaded appropriately
						private _rootVic = vehicle (leader _rootGroup);
						if ((driver _rootVic) in (units _rootGroup)  &&  {{vehicle _x != _rootVic} count units _rootGroup == 0}) then {
							if ((_targetLeadVic canVehicleCargo _rootVic) select 0) then {
								//[_rootGroup,_rootWPI]

							};

						};
					};


				};




				//-- sync behaviour: if all units are without vehicle and target has open seats, then do GET INArea//-- otherwise try to achieve regular wait sync
			} else {
				//-- UN SYNC

				{

					//if ({_x isEqualTo A3C_HC_WP_SYNC_ROOT  } count _x > 0) then {
						{
							_wp = _x;
							_syncWps = synchronizedWaypoints _wp;
							_doReset = false;
							if (_wp isEqualTo A3C_HC_WP_SYNC_ROOT) then {
								_doReset = true;
							} else {
								//systemChat str _wp;
								{
									_otherSyncWps = (synchronizedWaypoints _wp) - [A3C_HC_WP_SYNC_ROOT];
									//systemchat str _otherSyncWps;
									if (count _otherSyncWps == 0) then {
										_doReset = true;
									};
								} foreach _syncWps;
							};
							if (_doReset) then {
								//systemchat "reset";
								_wp synchronizeWaypoint [];
								_wp setWaypointScript "";
								_wp setWaypointType "MOVE";
								_wp setWaypointStatements
								[
									"true",
									"if !(false) then {[(group this)] call A3C_HC_WP_COMPLETE}; "
								];
							};
							
						} foreach _x;
						A3C_HC_WP_SYNC_ARRAYS = A3C_HC_WP_SYNC_ARRAYS - [_x];
					//};
				} foreach A3C_HC_WP_SYNC_ARRAYS;
				//-- remove existing sync node

			};
		};
	};

	if (A3C_MapSel_Field_Active) then {
		//-- Selection field is active: Generate Area and find units within
		A3C_MapSel_Field_Active = false; //-- always disable Selection field
		private _selPoses =
		[
			A3C_MapSel_Field_Root,
			[(A3C_MapSel_Field_DEST select 0), (A3C_MapSel_Field_Root select 1), 0],
			A3C_MapSel_Field_DEST,
			[(A3C_MapSel_Field_Root select 0), (A3C_MapSel_Field_DEST select 1), 0]
		];
		//if ((position player) inPolygon _selPoses) then {systemchat "Success"};
		//if (A3C_HELI_INF_MODE == "HC") then {
			private _gps = [];
			{
				_gp = _x;
				if ( (position (vehicle leader _x)) inPolygon _selPoses) then {

					//_leaderVic = vehicle _leader;
					//if (_leader == driver _leaderVic) then {
						_gps pushbackUnique _gp;
					//};
					
				};
			} foreach A3C_HCALLGROUPS_Current;

			private _infantryOnly = true;
			{
				if ({!isNull objectParent _x && {_x == driver (objectParent _x)}} count (units _x) > 0 ) exitWith { //
					_infantryOnly = false;
				};
			} foreach _gps;
			if !(_infantryOnly) then {
				_gps = _gps select {
					private _lVIc = objectParent (leader _x); !isNull _lVIc && {driver _lVIc in (units _x)}
				};
			};

			

		//} else {
			private _squadUnits = [];
			
				{
					if ((position _x) inPolygon _selPoses && {_x == driver vehicle _x}) then {
						_squadUnits pushbackUnique _x;
					};
				} foreach (units player - [player]);
				private _pageMode = "INF";

			if (A3C_HELI_INF_MODE == "HC" && {count (_gps - [group player]) > 0}) then {
				_squadUnits = []; //~~ sure this could be done better than resetting the value. try to avoid check instead
			} else {
				if (count _squadUnits > 0) then {
					_gps = [];
				};
			};
			
			//player sidechat str [count _squadUnits , count _gps];


			if (count (_squadUnits + _gps) == 0) exitWith {};

			if (count _squadUnits > count _gps) then {
				A3C_SELECTED_UNITS = A3C_SELECTED_UNITS select {typeName _x == "OBJECT"};
				if ({_x in A3C_SELECTED_UNITS} count _squadUnits == count _squadUnits) then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - _squadUnits;
				} else {
					{
						if (_x == driver vehicle _x) then { //~~ DRIVERCODE
							A3C_SELECTED_UNITS pushbackUnique _x;
						};
					} foreach _squadUnits;

				};
				
				if (({(_x == (driver vehicle _x)) && {typeOf (vehicle _x) iskindOf "AIR"}} count A3C_SELECTED_UNITS) > ((count A3C_SELECTED_UNITS) / 2)) then {
					_pageMode = "AIR";
					{
						if !(vehicle _x isKindOf "AIR") then {
							A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
						};
					} foreach A3C_SELECTED_UNITS;
				} else {
					{
						if (vehicle _x isKindOf "AIR") then {
							A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
						};
					} foreach A3C_SELECTED_UNITS;
				};
				 A3C_SELECTED_HC_GROUPS_SETTINGS = +(A3C_SELECTED_UNITS);
				//_cond = if (_pageMode == "AIR") then {};
				
			} else {
				A3C_SELECTED_UNITS = A3C_SELECTED_UNITS select {typeName _x == "GROUP"};
				if ({_x in A3C_SELECTED_UNITS} count _gps == count _gps) then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - _gps;
				} else {
					{
						A3C_SELECTED_UNITS pushBackUnique _x;
					} foreach _gps;
				};
				_pageMode = "HC";
			};
			private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SELECTOR_TREE;
			_CT_TREE tvSetCurSel [-1];
			if (count A3C_SELECTED_UNITS == 1) then {
				_CT_TREE tvSetCurSel [-1];
				_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
				if (count _button > 0) then {
					_button = _button select 0;
					_buttonParent = _button select [0,count _button -1];
					if ([_button select 0] in A3C_MAPTAB_TREES_OPEN) then {
						_CT_TREE tvSetCurSel _button;
						[
							[
								findDisplay 6998 displayCtrl 202020,
								_button select [0,(count _button) - 1]
							],
							"OPEN",
							false,
							0.1
						] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE
					};
				};
			};
			A3C_HELI_INF_MODE = _pageMode;
			//-- toggle or collapse wpsettings bar
			_foldMode = if (count A3C_SELECTED_UNITS > 0 && {_pageMode != "HC"}) then {"OPEN"} else {"COLLAPSE"};
			[_foldMode,0.1] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
			[_pageMode] call A3C_START_TABMODE;
		//};
	};

	

	A3C_DRAGPOS = [];
	////~~~~ TEMP! MOVE THIS!
	if (count A3C_MAP_DRAGPLANNING_POSITIONS > 0) then {
		_gpIcons = (["HC_GP",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		_drawBoardIcons = (["BOARDING_DRAW",_sx,_sy] call A3C_MAP_iconsAtMapPos);
		if (typeName A3C_SQ_CLICKED_UNIT == "OBJECT") then {
			if (count _drawBoardIcons > 0) then {
				private _drawBoardIcon = _drawBoardIcons select 0;
				private _vehi = _drawBoardIcon select 0;
				//systemchat 'sq units get in';
				[A3C_SELECTED_UNITS,true,true] call A3C_CANCELPLANS;
				
				_vehi spawn {
					sleep 1;
					_boardingUnits = (A3C_SELECTED_UNITS) select {isNull objectParent _x};
					[_this,'all',0,_boardingUnits] spawn A3C_AssignVehicleSeatMacro;
					
				//	params ["_vehi"];
				//	[_vehi] call A3C_FINDVEHROLES;
//
//					//sleep 1;
//					if (count A3C_VEHROLES > 0) then {
//						A3C_TARGETVEH = _vehi;
//						{
//							if (_x in A3C_VEHROLES) then {
//								_sc = [0,_x,A3C_SELECTED_UNITS,_vehi] call A3C_CREW;
//								sleep 0.5;
//							};
//						} foreach ["driver","gunner","commander","cargo"];
//					};
					
				};
			} else {
				if (count A3C_SELECTED_UNITS == 1) then {
					private _unit = A3C_SELECTED_UNITS select 0;
					if ( (_unit == A3C_SQ_CLICKED_UNIT) && (A3C_HELI_INF_MODE == "INF") ) then {
						//_unit setvariable ["A3C_PLOT_TEMP",[],true];
						if (count (_unit getVariable ["A3C_PLOT",[]]) > 0 ) then {
							[[_unit],true,true] call A3C_CANCELPLANS;
							waitUntil {count (_unit getvariable 'A3C_PLOT') == 0};
						};
						private _data = [];
						{
							_dir = if (_foreachIndex == 0) then {_unit getDir _x} else {(A3C_MAP_DRAGPLANNING_POSITIONS select (_foreachIndex - 1)) getDir _x};
							_mainMark = "A3C_SQ_" + (str (random 10000000000));
							_wp =
							[
								[_x,_x getPos [50,_dir]], //-- positions
								[_mainMark,"",""], //-- markers
								["NONE","NONE"], //-- wp action
								["NONE","NONE"], //--WP Condition
								[A3C_STANCE1_TEMP,A3C_STANCE2_TEMP], //-- WP Stances
								[[0,false]], // WP Sync Data
								true, //-- isWPCompleted
								0, //-- Combat Mode
								A3C_WP_SPEED_TEMP, //-- WP SPeed
								25, //-- WP Flying Height
								-1, //-- WP Loop Value
								0 // -- radius (for circle, not completion)
							];
							_data pushBack _wp;
						} foreach A3C_MAP_DRAGPLANNING_POSITIONS;
						_unit setvariable ["A3C_PLOT",_data,true];
						_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_MOVE);
					};
				} else {
					
				};
			};
		} else {
			//if (A3C_HELI_INF_MODE == "HC") then {
				_groupsToAssign = if (count A3C_SELECTED_UNITS > 0 && A3C_HELI_INF_MODE == "HC") then {+(A3C_SELECTED_UNITS)} else {[A3C_SQ_CLICKED_UNIT]};
				
				//if (count A3C_SELECTED_UNITS > 0) then {

					{
						_iconArray = _x;
						if (count _iconArray > 0) exitWith {
							_Icon = _iconArray select 0;
							private _unit = _icon select 0;
							private _vehi = objNull;
							if (typeName _unit == "GROUP") then {
								_unit = leader _unit;
								_vehi = vehicle _unit;
							} else {
								_vehi = _unit;
							};
							{
								if ({!isNull objectParent _x} count units _x > 0) then {
									_groupsToAssign = _groupsToAssign - [_x];
								};
							} foreach _groupsToAssign;
							
							{
								//if () then {
									[_x,_vehi] call A3C_HC_AssignVehicle;
								//};
							} foreach _groupsToAssign;
							//systemchat format ["A3C: %1 is connected to %2",A3C_SELECTED_UNITS,_gp];
						};
					} foreach [_drawBoardIcons];


					if (count _gpIcons > 0) then {
						_gpIcon = _gpIcons select 0;
						_gp = _gpIcon select 0;
						{
							if ({!isNull objectParent _x} count units _x > 0) then {
								_groupsToAssign = _groupsToAssign - [_x];
							};
						} foreach _groupsToAssign;
						{
							//if () then {
								[_x,vehicle leader _gp] call A3C_HC_AssignVehicle;
							//};
						} foreach _groupsToAssign;
						//systemchat format ["A3C: %1 is connected to %2",A3C_SELECTED_UNITS,_gp];
					} else {
						//-- Not dragged on vehicle icon: check for vehicle drag
						if (A3C_UI_MAPICONS_BOARDING_DRAW isEqualTo []) then {
							//-- dragged without vehicle modifier: delete all waypoints
							private _gp = A3C_SELECTED_UNITS select 0;
							// _wps = waypoints _gp;
							// while {!(_wps isEqualTo [])} do {
							// 	//-- delete ALL existing waypoints
							// 	deleteWaypoint (waypoints _gp select 0);
							// 	hintsilent 'deleting wp';
							// };
							// {deleteWaypoint _x} foreach _wps;
							// hintsilent 'wps deleted';
							// //-- add wp on position (default 1st wp)
							// [_gp,position leader _gp] call A3C_HC_ADD_WP;
							//-- add actual waypoint
							//-- clear all waypoints
							{
								{
									_x setVariable ["A3C_CLEARING",false,true];
								} foreach (units _x);
							} foreach A3C_SELECTED_UNITS;
							
							{
								_gp = _x;
								while {(count (waypoints _gp)) > 1} do {
									{
										if (_forEachIndex > 0) then {
											deletewaypoint _x;
											A3C_BLACKLIST_WAYPOINT_EDIT = A3C_BLACKLIST_WAYPOINT_EDIT - [_x];
										};
									} foreach waypoints _gp;
								};
								{
									_x remoteExec ["unassignVehicle",0];
									moveOut _x;
								} foreach (units _gp);
							} foreach A3C_SELECTED_UNITS;
							publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';
							[_gp, _sPos] call A3C_HC_ADD_WP;
						};
						
						
						
						
					};
					if (count _drawBoardIcons > 0) then {
						_drawBoardIcon = _drawBoardIcons select 0;
					};
				//};
			//};
		};

	};

	A3C_MAP_DRAGPLANNING_POSITIONS = [];
	A3C_MAP_DRAGPLANNING_ACTIVE = false;


	if (A3C_TAB_BUILDING_BOOL) then {
		[] call A3C_DELETE_BPOS_MARKERS;
		//A3C_TAB_BUILDING = objnull;
		[] spawn {
			sleep 0.1;
			A3C_TAB_BUILDING_BOOL = false;
		};
	};

	if (A3C_BOOL_DISABLEMAPCTRL && !((typename (_this select 0)) == "SCALAR") ) exitwith {};

	_a3c_dsp = if (visibleMap) then {6998} else {6999};

	if !(A3C_BOOL_MOUSEUP) exitwith {};

	if !(getmarkerColor "A3C_RADIMARK" == "") then {deletemarkerLocal "A3C_RADIMARK"};
	if (A3C_BOOL_LOOPING) exitwith {
		_this spawn A3C_TAB_LOOP_LM_UP;
	};

	

	if ( ((A3C_TEMP_ACTION select 0) in ["SLINGLOAD","CTRL_DET","STATIC"])) then {
		A3C_STATE_CHECKING_PICKUP = false;
		if (_this select 1 == 0) then {


			A3C_UI_MAPICONS_PICKUP = [A3C_UI_MAPICONS_PICKUP,[],{(_x select 2) distance2D _sPos},"ASCEND"] call BIS_fnc_sortBy;
			if (count A3C_UI_MAPICONS_PICKUP > 0) then {
				_unit = A3C_SELECTED_UNITS select 0;
				//private _marker = ((A3C_PIC KUP_MARKERS select 0) select 0);
				private _veh = ((A3C_UI_MAPICONS_PICKUP select 0) select 0);//[[[]]]
				switch (A3C_TEMP_ACTION select 0) do {
					case ("SLINGLOAD") : {

						//private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_MAP_iconsAtMapPos);
						A3C_PICKUP_OBJECTS = [];

						if ( _veh distance2d _sPos < 60) then {
							_wpData = _unit getVariable "A3C_PLOT_TEMP";
							A3C_TEMP_ACTION set [1,_veh];

							{
								_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
								if ((_wpMarkers select 0) == A3C_MovedItem_ID) exitWith {
									(_x select 0) set [0,(getPosATL _veh)];
									(_x select 2) set [1,_veh];
								};
							} foreach _wpData;

							_unit setVariable ["A3C_PLOT_TEMP",_wpData,true];

						} else {
							[] spawn {
								sleep 0.2;
								[] call A3C_UNDO;
								systemchat "A3C: No Cargo Selected";
							};
						};

					};
					case ("CTRL_DET") : {
						//systemchat 'go';
						A3C_MAP_CONNECTING_ID = A3C_TEMP_WP_ID_MAIN;
						_attachPos = _sPos;
						if ( _veh distance2d _sPos < 20) then {

							_attachPos = ([_veh,1] call MCSS_fnc_BBOX) select 1;
							_attachPos set [2,1];

							_attachPos = (lineintersectsSurfaces [AGLtoASL _attachPos,(((position _veh) select [0,2]) + [1])]); //,objnull, objnull, true, 1, "GEOM", "FIRE"
							_attachPos = (_attachPos select 0) select 0;
							_attachPos set [2,0];
							A3C_TEMP_ACTION set [1,[_veh,""]];
							//A3C_MovedItem_ID setMarkerTextLocal ("Destroy " + (getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName")));
						} else {
							_veh = objNull;
							A3C_TEMP_ACTION set [1,[objNull,""]];
						};


						_wpData = _unit getVariable "A3C_PLOT_TEMP";
						{
							_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
							if ((_wpMarkers select 0) == A3C_MovedItem_ID) then {
								(_x select 0) set [0,_attachPos];
								_x set [2,["CTRL_DET",[_veh,""]]];
								//systemchat A3C_MovedItem_ID;
								//player setpos _sPos;
							};
						} foreach _wpData;
						_unit setVariable ["A3C_PLOT_TEMP",_wpData,true];
						//[] spawn {
						//	sleep 0.2;
							["A3C_CTRL_DET_SELECT"] call A3C_OPEN_OBJECTSELECTOR_MAP;
						//};
					};
					case ("STATIC") : {
						if ( _veh distance2d _sPos < 30) then {
							A3C_TEMP_ACTION = ["STATIC",["DISASSEMBLE",_veh]];
							{
								private _soldier = _x;
								_wpData = _soldier getVariable "A3C_PLOT_TEMP";
								{
									_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
									if ((_wpMarkers select 0) == A3C_MovedItem_ID) then {
										if (_soldier == (A3C_SELECTED_UNITS select 0)) then {
											(_x select 0) set [0,(getPosATL _veh)];
											A3C_CLICKPOS_ORIG = (getPosATL _veh);
											A3C_CLICKPOS_ROOT = (getPosATL _veh);
											A3C_CLICKPOS_1 = (getPosATL _veh);

										};
									};
								} foreach _wpData;
								_soldier setVariable ["A3C_PLOT_TEMP",_wpData,true];
							} foreach A3C_SELECTED_UNITS;
						} else {
							[] spawn {
								sleep 0.2;
								[] call A3C_UNDO;
								systemchat "A3C: No Static Weapon Selected";
							};
						};
					};
				};


				A3C_MovedItem_ID = "";
			} else {
				if ( ((A3C_TEMP_ACTION select 0) in ["CTRL_DET"])) then {
					//-- bbb
					["A3C_CTRL_DET_SELECT"] call A3C_OPEN_OBJECTSELECTOR_MAP;

				};
			};
			A3C_PICKUP_OBJECTS = [];


		};
	};






	_exit = false;
	if (typeName A3C_MovedItem_ID == "ARRAY") exitWith {
		A3C_BOOL_MOUSEUP = false;
		A3C_BOOL_MOUSEMOVING = false;
	};

	_hcGroup = A3C_HC_TOSWITCH select 0;
	_wpID = A3C_HC_TOSWITCH select 1;
	private _activeWPindex = currentWaypoint _hcGroup;
	private _releasePos = (_map1 posscreentoworld [_sx,_sy]);
	private _build = nearestBuilding _releasePos;

	if (!isNull _hcGroup) then {
		_eligibleForBuildingSearch  = ({!isNull objectParent _x && {(assignedVehicleRole _x) select 0 != "cargo"}} count (units _hcGroup) == 0);
		if (_eligibleForBuildingSearch) then {
			// RELEASE A3C WP DRAG!
			private _wpToEdit = [_hcGroup,_wpID];  //~~ BUG HERE!?
			if (waypointType _wpToEdit in ["MOVE","HOLD","SCRIPTED"]) then {
				
				if ([_releasePos, _build] call A3C_fnc_INSIDE) then {

					_wpToEdit setWaypointPosition [(_build buildingPos 0),0];
					_wpToEdit setWaypointType "SCRIPTED";
					_wpToEdit setWaypointScript (format ["A3C_CORE\fnc_AI\wpFncs\wpScript_CLEARBUILDING.sqf ['%1',['ARRIVAL','']]",getPlayerUID player]);

					_statementsExec = "if !(false) then {[(group this)] call A3C_HC_WP_COMPLETE};"; //format
					//[
					//	"
					//		if !(false) then {[(group this)] call A3C_HC_WP_COMPLETE};
					//		['%1',this,[['NONE','NONE'],'CLEARBUILDING'],'NO CHANGE',%2] call A3C_HC_INSERT_ACTION_WP;
					//	",
					//	getPlayerUID player,
					//	_wpID
					//];
					_wpToEdit setWaypointStatements ["true",_statementsExec];
					private _data = _hcGroup getvariable ["A3C_UNIT_POLYS",[]];
					{
						_wpIndex = (_x select 0) select 2;
						if (_wpIndex == _wpID) exitWith {
							_data = _data - [_x];
						};
					} foreach _data;
					_hcGroup setvariable ["A3C_UNIT_POLYS",_data,true];
				} else {
					//-- DRAGGED IN THE OPEN (VANILLA): reset CLEARING wps
					_wpScript = waypointScript _wpToEdit;
					if (["CLEARBUILDING",_wpScript] call BIS_fnc_instring) then {
						//systemchat str _wpToEdit;
						_wpToEdit setWaypointType "MOVE";
						_wpToEdit setWaypointScript "";
						_wpToEdit setWaypointStatements ["true","if !(false) then {[(group this)] call A3C_HC_WP_COMPLETE};"];
					};
					if (_wpID == _activeWPindex) then {
						{
							_x setVariable ["A3C_CLEARING",false,true];
						} foreach (units _hcGroup);
					};
				};
			};
		};
		_wpStatements = (waypointStatements [_hcGroup,_wpID]);
		_actionCond = _wpStatements select 0;
		_actionScript = _wpStatements select 1;
		if (["PlantExplosive_HC",_actionScript] call BIS_fnc_instring) then {
			_demoIcons = (["DEMO",_sx,_sy] call A3C_MAP_iconsAtMapPos);
			if (count _demoIcons > 0) then {
				_hoverIcon = _demoIcons select 0;
				_hoverVic = _hoverIcon select 0;
				_actionScript = _actionScript splitString ";";
				if ((vehicleVarName _hoverVic) == "") then {
					_hoverVic = missionNameSpace getVariable ([_hoverVic] call MCSS_fnc_setVehicleVarname);
				};
				[_hcGroup,_wpID] waypointAttachVehicle _hoverVic;
			} else {
				[_hcGroup,_wpID] waypointAttachVehicle (leader _hcGroup);
			};
			A3C_HC_DETONATION_BOOL = false;
		};
		_exit = true;
	};
	

	if (_exit) exitWith {};


	//-- exit: drag is over, reset evh's
	if (A3C_BOOL_MOVINGHC) exitwith {
		A3C_BOOL_MOUSEUP = false;
		A3C_BOOL_MOUSEMOVING = false;
		 [grpNull,-1];
		A3C_BOOL_MOVINGHC = false;
	};

	//-- exit: Mode is HC
	if (A3C_HELI_INF_MODE == "HC") exitWith {
		A3C_BOOL_MOUSEUP = false;
	};


	//-- exit: No Drag Marker selected
	if !(A3C_MovedItem_ID == "") exitwith {
		A3C_BOOL_MOUSEUP = false;
		A3C_BOOL_MOUSEMOVING = false;
		A3C_MovedItem_ID = "";

		if (count A3C_MV_MARKERDATA > 0 ) then {
			A3C_MV_MARKERDATA params ["_soldier","_wPos","_varName"];
			_soldier setDestination [_wPos,"LEADER PLANNED",true];
			if !(_soldier getvariable ["A3C_HOLD",true]) then {
				if (_varName == "A3C_PLOT") then {
					[_soldier,_wPos] call A3C_DoMove;
				};
			};
			A3C_MV_MARKERDATA = [];
		};
		[] spawn {sleep 0.5; A3C_BOOL_MOVINGMARKER = false;};
	};


	_left = true;

	if (_this select 1 == 1) then {_left = false};
	if !(_left) exitwith {};






	//-- exit: No units selected
	if ((count A3C_SELECTED_UNITS) == 0) exitwith {
		A3C_BOOL_MOUSEUP = false;
	};


	_pos = _sPos; // ((getposASL A3C_DUMMY) select [0,2]) + [0];

	//-- exit if DragLine does not exist
	if !(A3C_BOOL_DRAGLINE) exitwith {};
	A3C_BOOL_DRAGLINE = false;







	//A3C_LOOP_CONT  = false;
	if (A3C_TAB_TOGGLE_VAR == 0) then {
		{
			((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true;
		} foreach [7018,7022,7041];
		(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor [1,1,1,1];
	};
	//A3C_LOOP_CONT  = true;
	A3C_DIR = [A3C_CLICKPOS_1,_pos] call bis_fnc_dirto;

	A3C_CLICKPOS_2 = _pos;
	A3C_USERACTION pushback [A3C_USERACTION_ID,0,0];
	A3C_USERACTION_ID = A3C_USERACTION_ID + 1;

	[1] call A3C_SET_ORDER_WIP;
	//systemchat 'yep';

	if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION"]) then {  //"GRENADE",
		A3C_BOOL_MOUSEMOVING = false;
	};

	//-- streamline UI: Suppression and Grenade Plans by resetting Condition
	if ((A3C_TEMP_ACTION select 0) in ["SUPPRESSION","GRENADE"]) then {
		if ((A3C_TEMP_CONDITION select 0) in ["TIMEOUT","GOCODE"]) then {
			//if (ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut)) then { // <<-- Sleep Box (Timeout Only)
				A3C_TEMP_CONDITION = ["GOCODE","D"]; //~~ THIS CAN BE PRETTIER. DON"T PURPOSELY SET VALUE TO BE OVERRIDEN BY FUNC
				[0] call A3C_BTN_FNC_COND;
			//};
		};
	};




	if ((A3C_TEMP_ACTION select 0) == "SUPPRESSION") then { //~~this can also be prettier, combine this and ove "SUPPRESSION" checks
		private ["_polygon","_dirTo","_countInd","_root","_u"];
		_u = A3C_SELECTED_UNITS select 0;
		_countIn = (count (_u getvariable "A3C_PLOT_TEMP")  ) -1;
		_root = [_u,0,_countIn] call A3C_FIND_SMOKELESS_WP;
		_dirTo = [_root,A3C_CLICKPOS_ORIG] call BIS_fnc_dirTo; //~~ get last smokeless WP of A3C_SELECTED_UNITS select 0

		_polygon = ([[A3C_CLICKPOS_ORIG,A3C_TEMP_WP_ID_MAIN]] + ([A3C_CLICKPOS_ORIG,_dirTo,"SUPPRESSION",true] call A3C_SUP_CREATE_POLY));

		A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
		{
			private ["_var"];

				_var = _x getvariable ["A3C_UNIT_POLYS",[]];
				_var pushback _polygon;
				_x setvariable ["A3C_UNIT_POLYS",_var,true];
		} foreach A3C_SELECTED_UNITS;
	};



	(findDisplay _a3c_dsp displayCtrl 7064) ctrlSetTextColor [1,1,1,1];
	if ((A3C_TEMP_ACTION select 0) == "SLINGLOAD") then {//~~ unnecessary! change setup in Button Function!
		A3C_TEMP_ACTION = ["SLINGLOAD","SLINGLOAD"];
	};
	_units = [];
	if (A3C_FORMMODE_TEMP == 4) then {
		_units = [(A3C_SPLIT_UNITS select 0)];
		//-- Shuffle back to end of array
		A3C_SPLIT_UNITS = A3C_SPLIT_UNITS - _units;
		A3C_SPLIT_UNITS = A3C_SPLIT_UNITS + _units;
		if ((count A3C_SPLIT_UNITS) == 0) then {
			A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
		};
	} else {
		_units = A3C_SELECTED_UNITS;
	};
	A3C_TAB_BUILDING_BOOL = false;
	A3C_CLICKPOS_1 = [0,0,0];
	A3C_CLICKPOS_2 = [0,0,0];
	A3C_TEMP_WP_ID_MAIN = "";

	//streamline UI: reset action to "NONE" for actions that are unusual to set in sequence (ie Cargo_out) ..CARGO IN not necessarily good, trying atm
	//if ((A3C_TEMP_ACTION select 0) in ["SUPPRESSION","GRENADE","CARGO_IN","CARGO_OUT","STATIC","CTRL_DET"]) then {
	if !((A3C_TEMP_ACTION select 0) in ["SLINGLOAD"]) then {
	//	if ((A3C_TEMP_ACTION select 0) != "STATIC" OR {count A3C_STATIC_PACKS == 1}) then {
			A3C_TEMP_ACTION = ["NONE","NONE"];
			(findDisplay _a3c_dsp displayCtrl 7064) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "No Action || Use LMB to open settings or mousewheel to cycle";
		//};
	};
};

//-- adjust the position of HC-waypoint while dragged
A3C_MOVEHC = {
	params ["_waypoint","_data"];

	_waypoint params ["_group","_wpi"];
	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	disableSerialization;
	_map1 = if (_a3c_dsp == 6998) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	_posi = _map1 posscreentoworld [(_data select 1),(_data select 2)];
	private _currentWP = currentWaypoint A3C_HC_ACTIVEGROUP;
	//if (A3C_HC_ACTIVE_IND != _currentWP) then {
		_waypoint setwaypointposition [_posi,0];
		//(leader _group) setDestination [_posi, "FORMATION PLANNED", true];
		//[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] spawn A3C_BEHAVIOUR_HC_MoveToWayPointPosition;
	//};
	
};



A3C_Adjust_Poly_Edge = {

	//-- Adjusts the edge markers of a polygon
	private _data = _this;
	private _sx = _data select 1;
	private _sy = _data select 2;

	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
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
	} foreach (A3C_HCALLGROUPS_Current + (units player - [player]));
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

A3C_MoveMapItem = {

	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};
	params ["_data","_item","_mode","_ctrl","_alt"];
	private ["_mode","_cI","_markerDir","_rPos","_dMark","_polygon","_var","_t","_exit"];


	//systemchat str _item;
	_sx = _data select 1;
	_sy = _data select 2;

	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	_map1 = if (visibleMap) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	



	_markerDir = 0;
	_rPos = [];
	_dMark = "";
	_exit = false;

	private _referenceUnit = objNull;
	if (typeName _item == "ARRAY") then {
		_referenceUnit = _item select 0;
		_item = _item select 3;
	};

	disableSerialization;



	//-- _item is Icon, unless coming from squad level suppression. IN this case, marker is treated as icon
	if ( {((_x select 0) select 1) == _item} count A3C_ALL_POLYS > 0) then {  //_item in A3C_HC_MARKERS &&
		//-- rewrite this: make general function that can be called by unit or group.
		//-- add suppression marker check for unit-marker-arrays

		{
			private ["_u","_va"];
			_u =_x;
			_va = (_u getVariable ["A3C_UNIT_POLYS",[]]);
			if ({_item == (_x select 0) select 1} count _va > 0) then {
				_sPos = (_map1 posscreentoworld [_sx,_sy]);
				if !(_ctrl) then {
					if (_alt) then {
						[_x,_item,_sPos,2] call A3C_ADJUST_POLY;
					} else {
						[_x,_item,_sPos,0] call A3C_ADJUST_POLY;
					};
				} else {

					{
						if (((_x select 0) select 1) == A3C_MovedItem_ID) exitwith {
							[_u,A3C_MovedItem_ID,_sPos,1] call A3C_ADJUST_POLY;
						};

					} foreach _va;
					_x setVariable ["A3C_UNIT_POLYS",_va,true];
				};
			};
		} foreach (A3C_HCALLGROUPS_Current + (units player - [player]));
	};




	if (_exit) exitWith {};

	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");

	//systemchat str _item;


	{
		private ["_soldier","_var","_ci"];
		_soldier = _x;
		_var = (_soldier getVariable ["A3C_UNIT_POLYS",[]]);
		_cI = 0; //if (_mode == "WP") then {0} else {2}; // "_cI" = Checked Index
		{
			private ["_plotVar","_data"];
			_plotVar = _x;
			_data = _soldier getvariable [_plotVar,[]];
			{

				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
				private _isTargetWP = false;
				if (_item in _wpMarkers) then {
					if ((_wpMarkers select 1) == "") then {
						if ((_wpMarkers select 0) == _item) then {
							_isTargetWP = true;
						};
					} else {
						if ((_wpMarkers select 1) == _item) then {
							_isTargetWP = true;
						};
					};
				};

				if (_isTargetWP) exitwith {
					_sPos = (_map1 posscreentoworld [_sx,_sy]);
					if (_mode == "WP") then {
						if !(_ctrl) then {
							if !(_alt) then {
								if ({((_x select 0) select 1) == _item} count A3C_ALL_POLYS > 0) then {
									[_soldier,_item,_sPos,0] call A3C_ADJUST_POLY;
								};
							};

							//_nB = (nearestBuilding _sPos); // __ this took way to much time and resulted in more ui-lag than the alternative approach
							_sPosASL = ATLtoASL _sPos;
							_ins = lineIntersectsObjs
							[
								_sPosASL vectorAdd [0,0,30],
								_sPosASL,
								objNull,
								objNull
							];
							_ins = _ins select { ([_x] call MCSS_fnc_countBPos) > 0};
							_nB = if (count _ins > 0) then {_ins select 0} else {objNull};

							if (!isNull _nB) then { //}([_sPos, _nB] call A3C_fnc_INSIDE) then {
								_bPoses = [];
								for "_i" from 0 to ([_nB] call MCSS_fnc_countBPos) do {
									_bPoses pushback (_nb buildingPos _i);
								};
								_bPoses = [_bPoses,[],{_x distance2d _sPos},"ASCEND"] call BIS_fnc_sortBy;
								_sPos = _bPoses select 0;
							};
							if !(_alt) then {
								//_item setMarkerPosLocal _sPos;
								(_x select 0) set [0,_sPos];
							};

							_soldier setvariable [_plotVar,_data,true];
						} else {

							//if !(_alt) then {
								if ({((_x select 0) select 1) == _item} count A3C_ALL_POLYS > 0) then {
									{
										if (((_x select 0) select 1) == A3C_MovedItem_ID) exitwith {
											[_soldier,_item,_sPos,1] call A3C_ADJUST_POLY;
										};
									} foreach _var;
								};
							//};
						};
						// --	re-Order units to move
						if ((_soldier getvariable "A3C_CURRENTWAYPOINT_INDEX") == (_foreachIndex + 1)) then {
							if (_soldier == (driver (vehicle _soldier))) then {
								A3C_MV_MARKERDATA = [_soldier,_sPos,_plotVar];
								if !(player == (effectiveCommander	(vehicle _soldier))) then {
									if !(_soldier in A3C_SUPPRESSION_UNITS_SQ) then {

										if !(_soldier getvariable ["A3C_HOLD",false]) then {
											if (_plotVar == "A3C_PLOT") then {
												if !((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) then {
													if ((time - A3C_TICKTIME_MoveMark) > 1.5) then {
														A3C_TICKTIME_MoveMark = time;
														_soldier setdestination [_sPos,"LEADER PLANNED",true];
														[_soldier,_sPos,true] call A3C_DoMove;
													};
												};
											};
										};
									};
								};
							};
						};
					} else {
						_markerDir = ([A3C_DIR_POS,_sPos] call BIS_fnc_DirTo);
						if (_soldier == _referenceUnit) then {
							(_x select 0) set [1,([(_wpPositions select 0),100,_markerDir] call BIS_fnc_Relpos)];
							_soldier setvariable [_plotVar,_data,true];
						};

					};
				};
			} foreach _data;
		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
		_soldier setVariable ["A3C_UNIT_POLYS",_var,true];
	} foreach _unitArray;

};

//--------------------------  I N T E R F A C E   O P E R A T I O N :   F U N C T I O N S  ---------
//--------------------------------------------------------------------------------------------------
//--------------------------    Functions to operate the actual interface itself -------------------


//-- does this double
A3C_InMapControls = {
	_ctl = _this select 0;
	_pos = [A3C_MAP_X,A3C_MAP_Y,0];
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
	if (_group in A3C_HCALLGROUPS_Current) then {
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
		24 + ( (count A3C_HCALLGROUPS_CURRENT) - (A3C_BUTTONPAGE_TABLET * 16) )
	} else {
		24 + ((count((profileNamespace getvariable "A3C_GROUPUNITS") - [player])) - (A3C_BUTTONPAGE_TABLET * 16))
	};
	if (_limit > 40) then {_limit = 40};

	//systemchat str (_limit - 24);
	//-- reset tablet UI
	_maxWunit = 0.452508 * safezoneW;
	if (_a3c_dsp == 6999) then {
		(findDisplay 6999 displayCtrl 11) ctrlSetPosition
		[
			0.167779 * safezoneW + safezoneX,
			0.598968 * safezoneH + safezoneY,
			0.42 * safezoneW,
			0.175944 * safezoneH
		];
		(findDisplay 6999 displayCtrl 2301) ctrlSetPosition
		[
			0.190691 * safezoneW + safezoneX,
			0.68694 * safezoneH + safezoneY,
			0.22603 * safezoneW,
			0.0560031 * safezoneH
		];
		(findDisplay 6999 displayCtrl 2302) ctrlSetPosition
		[
			0.43 * safezoneW + safezoneX,
			0.609965 * safezoneH + safezoneY,
			0.189022 * safezoneW,
			0.142954 * safezoneH
		];



		//(findDisplay 6999 displayCtrl 23001) ctrlSetPosition
		//[
		//	0.190691 * safezoneW + safezoneX,
		//	0.68694 * safezoneH + safezoneY,
		//	(0.22339 * safezoneW), // min (0.452508 * safezoneW)
		//	0.0549824 * safezoneH
		//];
		//(findDisplay 6999 displayCtrl 23002) ctrlSetPosition
		//[
		//	0.419809 * safezoneW + safezoneX,
		//	0.609965 * safezoneH + safezoneY,
		//	0.189022 * safezoneW,
		//	0.142954 * safezoneH
		//];

		{
			(findDisplay 6999 displayCtrl _x) ctrlCommit 0;
		} foreach [11,2302,23001,23002];
		if (count (profileNamespace getvariable "A3C_GROUPUNITS") > 17) then {
			{
				(findDisplay 6999 displayCtrl _x) ctrlShow true;
			} foreach [7097,7098,70981,70982,70983];
		} else {
			{
				(findDisplay 6999 displayCtrl _x) ctrlShow false;
			} foreach [7097,7098,70981,70982,70983];
		};
	};


	for "_i" from 25 to 40  do {
		if (_i <= _limit) then {
			//-- adjust tablet UI
			if (_a3c_dsp == 6999) then {
				if (_i in [33,35,37,39]) then {
					_mult = switch _i do {
						//case 31 : {1};
						//case 32 : {1};
						case 33 : {1};
						case 35 : {2};
						case 37 : {3};
						case 39 : {4};
					};
					_pX = (ctrlPosition ((findDisplay 6999 displayCtrl 2301) controlsGroupCtrl 7027)) select 0;
					_pW = switch (_i) do {
						case 33 : {0.28436 * safezoneW};
						case 35 : {0.342691 * safezoneW};
						case 37 : {0.401021 * safezoneW};
						case 39 : {0.45206 * safezoneW};
					};
					//systemchat str _pW;
					//systemChat str _mult;
					(findDisplay 6999 displayCtrl 11) ctrlSetPosition
					[
						0.167779 * safezoneW + safezoneX,
						0.598968 * safezoneH + safezoneY,
						((0.42 * safezoneW) + (_mult * _pX)), //(0.057279 * safezoneW)
						0.175944 * safezoneH
					];

					//systemchat str _mult;
					(findDisplay 6999 displayCtrl 2301) ctrlSetPosition
					[
						0.190691 * safezoneW + safezoneX,
						0.68694 * safezoneH + safezoneY,
						_pW, //(0.22339 * safezoneW) + (_mult * (0.057279 * safezoneW)), // min (0.452508 * safezoneW) //0.22339 * safezoneW,
						1 * safezoneH
					];
					//(findDisplay 6999 displayCtrl 23001) ctrlSetPosition
					//[
					//	0.190691 * safezoneW + safezoneX,
					//	0.68694 * safezoneH + safezoneY,
					//	(0.22339 * safezoneW) + (_mult * (0.057279 * safezoneW)), // min (0.452508 * safezoneW) //0.22339 * safezoneW,
					//	0.0549824 * safezoneH
					//];
					(findDisplay 6999 displayCtrl 2302) ctrlSetPosition
					[
						((0.43 * safezoneW + safezoneX) + (_mult * (0.057279 * safezoneW))),
						0.609965 * safezoneH + safezoneY,
						0.189022 * safezoneW,
						0.142954 * safezoneH
					];
					//(findDisplay 6999 displayCtrl 23002) ctrlSetPosition
					//[
					//	((0.419809 * safezoneW + safezoneX) + (_mult * (0.057279 * safezoneW))),
					//	0.609965 * safezoneH + safezoneY,
					//	0.189022 * safezoneW,
					//	0.142954 * safezoneH
					//];
					{
						(findDisplay 6999 displayCtrl _x) ctrlCommit 0;
					} foreach [11,2301,2302,23001,23002];
					ctrlsetfocus (finddisplay 6999 displayctrl 2301)
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
				//if ( ({alive _x} count (units (A3C_HCALLGROUPS_CURRENT select ((_i - 25) + (A3C_BUTTONPAGE_TABLET * 16))))) == 0 ) then {
				//	_text = 'N/A';
				////	_textCol = [0.5,0.5,0.5,1];
					(findDisplay _a3c_dsp displayCtrl (7000 + _i)) ctrlSetBackgroundColor [0,0,0,0.7];
				//} else {
					_buttonMode = 0;
					///_hcGroups= A3C_HCALLGROUPS_Current_ORGANIZED; 
					///A3C_HC_MENU_REFERENCE_UNITS = _hcGroups;
					_hcGroups = A3C_HCALLGROUPS_Current;
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
	[_a3c_dsp,_mode] call A3C_MAPTAB_RESIZE_TEAMCOLORS_XWH;
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{deleteMarkerLocal _x} foreach A3C_BPMARKERS;
	A3C_BPICONS = [];
};






//-- simple mapclick to world coordinates function [AN: RETURNS NOTHING AND APARENTLY DEAD WEIGHT?? OTHER?]
A3C_MAPCOORDINATES = {
	_left = true;
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	disableSerialization;
	_map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
		(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlShow false;
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	switch (A3C_TAB_TOGGLE_VAR) do {
		case (0) : {
			for "_i" from 7044 to 7089 do {
				call compile format ["
					(findDisplay _a3c_dsp displayCtrl _i) ctrlShow false;
				",_i];
			};
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;} foreach [7007,A3C_RC_TimeOut,7018,7019,7022,7097,7098,70981,70982,70983];
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
				{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true} foreach [A3C_RC_TimeOut];
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
			//[A3C_HELI_INF_MODE] call A3C_LABEL_SELECTORS;

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




A3C_MAPTAB_BARSETTINGS_LABEL = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	//-- hide subselection controls
	if (_mode != A3C_HELI_INF_MODE) then {
		//-- TOGGLE SUBSELECTION OFF ON MODESWITCHs
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [PRNT_ACTION_SUBSET_1,PRNT_ACTION_SUBSET_2,MAP_BG_SUB_BG_1,MAP_BG_SUB_BG_2]; 
	};
};


A3C_MAPTAB_REFRESH_BARCONTROLS = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
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
				} foreach [PRNT_ACTION_SUBSET_1,PRNT_ACTION_SUBSET_2,MAP_BG_SUB_BG_1,MAP_BG_SUB_BG_2];
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
			_spacing = if (A3C_HELI_INF_MODE == "AIR") then {A3C_SPACING_AIR} else {A3C_SPACING_INF max 2};
			_spacing = if (_spacing < 10) then {"0" + (str _spacing)} else {str _spacing};
			(findDisplay _this displayCtrl 7066) ctrlSetText _spacing;	
		};
			
	};
};

A3C_START_TABMODE = {
	private ["_mode","_stanceHeight","_stanceLand","_stance2Col","_smokeBool","_spacing","_pagebutton","_stance1TT","_stance2TT","_pageTT","_ctrlBool"];
	params ["_mode"];


	private _a3c_dsp = if (visibleMap) then {6998} else {6999};

	
	//-- open trere first so that other controls can adjust accodingly | ADD CONDITION / PROFILE
	//systemchat 'tabmode';

	
	
	//--  asasas
	
	//if (_mode != A3C_HELI_INF_MODE) then {
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [PRNT_ACTION_SUBSET_1,PRNT_ACTION_SUBSET_2,MAP_BG_SUB_BG_1,MAP_BG_SUB_BG_2];
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
	(findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut) ctrlSetText (str A3C_TIMEOUT_VAL);
	(findDisplay _a3c_dsp displayCtrl 303030) ctrlShow false;
	

	//A3C_HELI_HELI_WP_BEHAVIOUR = "NONE";
	A3C_HELIHEIGHT = 0;

	_ctrlBool = true;

	(findDisplay _a3c_dsp displayCtrl 7065) ctrlSetToolTip "No Action || Use LMB to open settings or mousewheel to cycle";


	

	_ctrlShowLowerBar = true;

	switch (_mode) do {
		case ("INF") : {
			if (typeName A3C_WP_SPEED_TEMP == "STRING") then {A3C_WP_SPEED_TEMP = -1};
			_stance2Col = [1,1,1,0.3];
			//if (A3C_HELI_INF_MODE == "INF") then {
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

			if (A3C_HELI_INF_MODE == "HC") then {
				//(findDisplay _a3c_dsp displayCtrl 7008) ctrlSetText "^";
				{
					(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
				} foreach [A3C_RC_TimeOut];
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
			//if (A3C_HELI_INF_MODE == "AIR") then {
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


			if (A3C_HELI_INF_MODE == "HC") then {
				//(findDisplay _a3c_dsp displayCtrl 7008) ctrlSetText "^";
				{
					(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
				} foreach [A3C_RC_TimeOut];
			};
		};
		case ("HC") : {
			if (A3C_MAPTAB_OVERLAY_isUnFolded) then {
				["COLLAPSE",0.1] call A3C_MAPTAB_OVERLAY_TOGGLE_FOLD;
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
			} foreach [A3C_RC_TimeOut,7022,7066];
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
	[_mode] call A3C_MAPTAB_REFRESH_BARCONTROLS;
	
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
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [A3C_RC_TimeOut,7078,A3C_RC_Context]; //-- hide rClick contextMenu, undo, small rClick-menu
	(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow false;
	(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,0.2];
	(findDisplay _a3c_dsp displayCtrl 7048) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
	//(findDisplay _a3c_dsp displayCtrl 7050) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_formDir_None.paa";

	if (count A3C_SELECTED_UNITS > 0) then {
		private _refItem = A3C_SELECTED_UNITS select 0;
		private _refArray = if (_mode != "HC") then {profileNamespace getvariable "A3C_GROUPUNITS"} else {A3C_HCALLGROUPS_Current};
		private _refDif = if (_mode != "HC") then {-1} else {0}; //-- on squad level, buttons exclude the player. Therefore, 1 needs to be substracted from refr
		private _refIndex = [_refItem, _refArray] call MCSS_fnc_getArrayIndex;
		A3C_BUTTONPAGE_TABLET = (floor ( (_refIndex + _refDif) / 16)) max 0;
	};
	//[_mode] call A3C_LABEL_SELECTORS;
};


A3C_SWITCH_COMMAND_PAGE = {
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	A3C_SELECTED_UNITS = [];
	switch (A3C_HELI_INF_MODE) do {
		case ("INF") : {
			["AIR"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "AIR";
		};
		case ("AIR") : {
			A3C_BUTTONPAGE_TABLET = 0;
			["HC"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "HC";
		};
		case ("HC") : {
			A3C_BUTTONPAGE_TABLET = 0;
			["INF"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "INF";
		};
	};
};



A3C_TRACKER_GROUPS = [];
//-- Super simple Force-Tracker (units known to group members)
A3C_CREATE_TRACKER = {
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
				//-- NO ACTION. will be drawn by AIC or in individual section >> A3C_MAPTAB_fnc_drawMapUI
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


//-- old version
A3C_CREATE_TRACKER1 = {
	private ["_markerType"];
	_trackerGroups = [];
	_markerType = "n_inf";
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	A3C_TRACKER_ENEMYGROUPS = [];
	if (A3C_DISABLE_TRACKER) exitWith {};
	{
		if (_x == (leader group _x)) then {
			if ((faction _x) == (faction player)) then {
				//if !((group _x) in _trackerGroups) then {
				//	_trackerGroups pushback (group _x);
				//};
			} else {
				if ((player knowsabout (vehicle _x)) > 0) then {
					if !((group _x) in _trackerGroups) then {
						_trackerGroups pushback (group _x);
					};
				};
			};
		};


	} foreach allunits - (units group player);

	{

		_checkedGroup = _x;
		_markerType = [_checkedGroup] call MCSS_fnc_ICONTYPE;
		_markerColor= "ColorGreen";

		_fnc_Tracker = {
			private ["_group","_marker","_pause"];
			_group = _this select 0;
			_marker = _this select 1;
			_a3c_dsp = if (visibleMap) then {6998} else {6999};
			_pause = if (_group in A3C_HCALLGROUPS_Current) then {0.1} else {1};
			//systemchat str _pause;
			{
				_x setvariable ["A3C_TRACKEDGROUPMARK",_marker,false];
			} foreach units _group;
			if ( ((side _group) getFriend (side player)) < 0.6) then {
				A3C_TRACKER_ENEMYGROUPS pushback _group;
			};
			while {!(isnull (finddisplay _a3c_dsp))} do {
				if ({alive _x} count units _group == 0) exitwith {deletemarkerLocal _marker};
				if ((faction (leader _group)) == (faction player)) then {
					_marker setMarkerPosLocal (getPosASL (leader _group));
				};
				sleep _pause;
			};
		};
		switch (side _checkedGroup) do {
			case (WEST) : {_markercolor = 'ColorBlufor'};
			case (EAST) : {_markercolor = 'ColorRed'};
			case (CIVILIAN) : {_markercolor = 'ColorCiv'};

		};
		if (isnil "_markertype") then {_markerType = "n_inf";};
		if ((count (units _checkedGroup)) > 0) then {
			call compile format ["
				A3C_TrackerMark_%1 = createMarkerLocal ['A3C_TrackerMark_%1', position (leader _checkedGroup)];
				A3C_TRACKER_MARKERS pushback A3C_TrackerMark_%1;
				A3C_TrackerMark_%1 setmarkerTypeLocal '%2';
				A3C_TrackerMark_%1 setMarkerColorLocal '%3';
				A3C_TrackerMark_%1 setMarkerSizeLocal %4;
				A3C_TrackerMark_%1 setMarkerAlphaLocal %5;
				[_checkedGroup,A3C_TrackerMark_%1] spawn _fnc_Tracker;
			", _forEachIndex,_markerType,_markerColor,[_checkedGroup] call A3C_GetTrackerMarkSize,if (A3C_TRACKER_VISIBLE == 0) then {0} else {0.6}];
		};
	} foreach _trackerGroups;
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
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	private _hcAll = A3C_HCALLGROUPS_Current;
	if (!isNull findDisplay 7999) then {
		_a3c_dsp = 7999;
	};
	//ddddd
	if !(isnull (findDisplay _a3c_dsp)) then {
		{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	};
	_groupCount =  if (A3C_HELI_INF_MODE == "HIGHCOMMAN") then {count _hcAll} else {};
	_groupCount = 0;
	if (_a3c_dsp == 7999) then {
		_groupCount = count _hcAll;
	} else {
		if (A3C_HELI_INF_MODE == "HC") then {
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
		if (_a3c_dsp == 7999) then {
			if !(isnull (findDisplay 7999)) then {
				//[] call A3C_RD_LABEL_SELECTORS;
			};
		} else {
			if !(isnull (findDisplay _a3c_dsp)) then {
				//[A3C_HELI_INF_MODE] call A3C_LABEL_SELECTORS;
			};
		};


	};
};

//-- function for the cancel button. Reverts and deletes all orders/data created in planning stage
A3C_Btn_fnc_Cancel = {
	private ["_mode","_a3c_dsp"];
	_mode = if (count _this > 0) then {_this select 0} else {0};
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	if !(currentWeapon player == A3C_WeaponCurr) then {
		player selectWeapon A3C_WeaponCurr;
	};
	//(findDisplay _a3c_dsp) closeDisplay 0;
	if (_mode == 0) then {
		[_a3c_dsp] call A3C_Close_Map_Overlay;
	};
	if (_a3c_dsp == 6999) then {
		(findDisplay _a3c_dsp) closeDisplay 0; //~~~~ YOU MESSY BOY, CLEAN THIS SHIT UP WILL U? make coherent modes.
	};
};

A3C_MAPTAB_MOUSEMON = {
	params ["_display","_sX","_sY","_unUsed"];

	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	private _ctls = [13,7071,7077,202020,709099,8009,8010,709109,709115,8007];
	A3C_MAP_X = _this select 1;
	A3C_MAP_Y = _this select 2;
	if ({[[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctls > 0) then {
		(findDisplay 12 displayCtrl 51) ctrlEnable false;
		//hintSilent str [time, 'off'];
	} else {
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
		ctrlSetFocus (findDisplay 12 displayCtrl 51);
		//hintSilent str [time,'on'];
		if (A3C_MapSel_Field_Active) then {
			A3C_MapSel_Field_DEST = (findDisplay 12 displayCtrl 51) posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
		};
		if (A3C_BOOL_MOUSEMOVING) then {
			_this spawn A3C_MMCode;
		};
	};
	
};

A3C_MAP_DelLoopObs = {
	//-- this function cancels the dragging of LookDir arrows and AIC-waypointarrows while setting them
	//-- executes when mouse is dragged into map controls
	//~~ this whole solution is sloppy, there has to be a better way  || ~~ is this still true? yes, just pausing would be better. But that's complex.

	A3C_BOOL_MOUSEUP = true;
	if (A3C_BOOL_MAP_MD) then {
		A3C_BOOL_MAP_MD = false;
		if (A3C_BOOL_DRAGLINE) then {
			[0,0,0,0,false,false,false] spawn A3C_LEFTMOUSEUP;
		};
	};
};




//A3C_Timeout_Setting = 0;
A3C_BTN_FNC_COND = {
	params ["_mode","_shift"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	private ["_a3c_dsp","_goCode"];
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	switch (A3C_TEMP_CONDITION select 0) do {
		case ("NONE") : {
			if (_mode ==  0) then {
				A3C_TEMP_CONDITION = ["TIMEOUT",A3C_TIMEOUT_VAL]; //-- TIMEOUT
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText 'A3C_CORE\ui\pictures\icon_menu_condition_Timer.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: TIMEOUT (LMB to cycle through options)';
				((findDisplay _a3c_dsp) displayCtrl 7008) ctrlSetText '(';
				{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_RC_TimeOut];
			} else {
				A3C_TEMP_CONDITION = ["GOCODE","D"];
				((findDisplay _a3c_dsp) displayCtrl 7022) ctrlSetText 'A3C_CORE\ui\pictures\icon_menu_gocode_D.paa';
				((findDisplay _a3c_dsp) displayCtrl 7007) ctrlSetToolTip 'WP Condition: GoCode D (LMB to cycle through options)';
				//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
				{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_RC_TimeOut];
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
			{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_RC_TimeOut];
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
			{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_RC_TimeOut];
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
					{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_RC_TimeOut];
				};
			};

		};
	};
};


A3C_BTN_FNC_TEAMCOLOR = {
	private ["_unitArray","_units","_cond","_switch"];

	_teamColor = _this select 0;
	_shift = _this select 1;
	_a3c_dsp = if (visibleMap) then {6998} else {6999};


	private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SELECTOR_TREE;
	_CT_TREE tvSetCurSel [-1];

	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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
		if (A3C_HELI_INF_MODE == 'AIR') then {
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
		switch (A3C_HELI_INF_MODE) do {
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
			A3C_HELI_INF_MODE = "AIR";
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
			A3C_HELI_INF_MODE = "INF";
			//private _spacing = str A3C_SPACING_INF;
			//if (A3C_SPACING_INF < 10) then {
			//	_spacing = "0" + _spacing;
			//};
			//(findDisplay _a3c_dsp displayCtrl 7066) ctrlSetText _spacing;
		};
	};
	A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;
	[A3C_HELI_INF_MODE] call A3C_START_TABMODE;
	[] call A3C_UNITSEL_REFRESH_UI;
};

A3C_STANCE_BTN_1 = {
	params ["_mode"];
	if (_mode < 0) then {_mode = 0};
	if (_mode > 1) then {_mode = 1};
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	if (A3C_HELI_INF_MODE in ["INF","HC"]) then {
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


A3C_MAPTAB_SPAWN_TIMEOUTBOX = {
	params ["_mode"];
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};
	private _timeOutBox = findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut;
	
	if (_mode == "OPEN") then {
		private _ctrlFrameOriginalY = if (_a3c_dsp == 6998) then {A3C_MAPTAB_SETTINGSGROUP_Y} else {0.598968 * safezoneH + safezoneY};
		_timeOutBox ctrlSetPosition
		[
			(ctrlPosition (findDisplay _a3c_dsp displayCtrl 7022)) select 0,
			_ctrlFrameOriginalY - (1 * A3C_MAPTAB_SUBSEL_BUTTON_H),
			A3C_MAPTAB_SUBSEL_BUTTON_W,
			A3C_MAPTAB_SUBSEL_BUTTON_H
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
	private _a3c_dsp = if (visibleMap) then {6998} else {6999};

	(findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut) ctrlShow false;

	//-- re-assign STANCE2 to ACTION if on AIRCRAFT PAGE
	if (A3C_HELI_INF_MODE == "AIR") then {
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

	private _ctrlFrameOriginalY = if (_a3c_dsp == 6998) then {A3C_MAPTAB_SETTINGSGROUP_Y} else {0.598968 * safezoneH + safezoneY};
	private _ctrlFrame = findDisplay _a3c_dsp displayCtrl 11;


	private _ctrlFramePos = [];


	if (_a3c_dsp == 6998) then {
		_ctrlFramePos = ctrlPosition _ctrlFrame;
	};

	private _subsetCtrl_1 = (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1);
	private _subsetCtrl_2 = (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2);


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
			if (A3C_HELI_INF_MODE == "INF") then {
				_subsetActionStrings pushbackUnique "SQ_ACTION_NONE";
				_buttonImages = ["\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa"];
				//_actionArray = [0,false,false] call A3C_BUTTON_wpFiringMode;
				_actionArray = [A3C_SELECTED_UNITS] call A3C_getActionsArray;
			};
			if (A3C_HELI_INF_MODE == "AIR") then {
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
		private _parentPos = ctrlPosition (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1);
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
	//private _subsetButtonSize = [A3C_MAPTAB_SUBSEL_BUTTON_W, A3C_MAPTAB_SUBSEL_BUTTON_H] ;


//A3C_MAPTAB_SUBSEL_BUTTON_H
	//-- create positional array for subset bar
	private _subsetBarPos =
	[
		((_originButtonPos select 0) + (_shiftFactorX * A3C_MAPTAB_SUBSEL_BUTTON_W)) max A3C_MAPTAB_SETTINGSGROUP_X_EXPANDED,
		_ctrlFrameOriginalY -  (A3C_MAPTAB_SUBSEL_BUTTON_H * _subset) //(_originButtonPos select 1) - ((_subsetButtonSize select 1) + ((_subsetButtonSize select 1) * _gap)   )
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
			_ctrlPos set [2,A3C_MAPTAB_SUBSEL_BUTTON_H];
			_ctrlPos set [3,A3C_MAPTAB_SUBSEL_BUTTON_H];
			_ctrl ctrlSetPosition _ctrlPos;
			//_ctrl ctrlSetPositionW A3C_MAPTAB_SUBSEL_BUTTON_H;
			//_ctrl ctrlSetPositionH A3C_MAPTAB_SUBSEL_BUTTON_H;
			_ctrl ctrlCommit 0;
		} foreach _x;
		*/
	} foreach _subsetCtrls;

	//-- shortcut for button background fields
	_bg1 = findDisplay _a3c_dsp displayCtrl MAP_BG_SUB_BG_1;
	_bg2 = findDisplay _a3c_dsp displayCtrl MAP_BG_SUB_BG_2;


	if (_subSet == 1) then {
		if (_doToggleCntrls) then {
			if (ctrlShown (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1) && (_actionButton == A3C_LAST_SUBSET_ACTION)) then {
				_subsetCtrl_1 ctrlShow false;
				_subsetCtrl_2 ctrlShow false;
				_bg1 ctrlShow false;
				_bg2 ctrlShow false;
				_ctrlFramePos set [1,_ctrlFrameOriginalY];
			} else {
				if (ctrlShown (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2)) then {
					_ctrlFramePos set [1,_ctrlFrameOriginalY];
					_subsetCtrl_1 ctrlShow false;
					_subsetCtrl_2 ctrlShow false;
					_bg1 ctrlShow false;
					_bg2 ctrlShow false;
				} else {
					_subsetBarPos set [2, A3C_MAPTAB_SUBSEL_BUTTON_W * _selectionAmount]; //-- adjust w to match button-amount
					_subsetBarPos set [3,A3C_MAPTAB_SUBSEL_BUTTON_H];
					_ctrlFramePos set [1,_ctrlFrameOriginalY - (1 * A3C_MAPTAB_SUBSEL_BUTTON_H)];

					//--position bg frame
					
					_bg1 ctrlSetPosition _subsetBarPos;
					_bg1 ctrlCommit 0;
					_bg1 ctrlShow true;

					_subsetBarPos set [3,A3C_MAPTAB_SUBSEL_BUTTON_H * 1.5];
					_subsetCtrl_1 ctrlSetPosition _subsetBarPos;
					_subsetCtrl_1 ctrlCommit 0;
					_subsetCtrl_1 ctrlShow true;
				};
			};
		};
	} else {
		if (_doToggleCntrls) then {
			if (ctrlShown (findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2) && (_actionButton == A3C_LAST_SUBSET_ACTION)) then {
				_subsetCtrl_2 ctrlShow false;
				_bg2 ctrlShow false;
				_ctrlFramePos set [1,_ctrlFrameOriginalY - (1 * A3C_MAPTAB_SUBSEL_BUTTON_H)];;
			} else {
				_ctrlFramePos set [1,_ctrlFrameOriginalY - (2 * A3C_MAPTAB_SUBSEL_BUTTON_H)];
				

				//--position bg frame
				_subsetBarPos set [2, A3C_MAPTAB_SUBSEL_BUTTON_W * _selectionAmount]; //-- adjust w to match button-amount
				_subsetBarPos set [3,A3C_MAPTAB_SUBSEL_BUTTON_H];
				_bg2 ctrlSetPosition _subsetBarPos;
				_bg2 ctrlCommit 0;
				_bg2 ctrlShow true;

				_subsetBarPos set [3,A3C_MAPTAB_SUBSEL_BUTTON_H * 1.5];
				_subsetCtrl_2 ctrlSetPosition _subsetBarPos;
				_subsetCtrl_2 ctrlCommit 0;
				_subsetCtrl_2 ctrlShow true;


//systemChat '2';
				_subsetCtrl_2 ctrlSetPosition _subsetBarPos;
				_subsetCtrl_2 ctrlCommit 0;
			};
		};
	};
	if (_a3c_dsp == 6998) then {
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

	_bg1 = findDisplay _a3c_dsp displayCtrl MAP_BG_SUB_BG_1;
	_bg2 = findDisplay _a3c_dsp displayCtrl MAP_BG_SUB_BG_2;

	if (_action == "SQ_COND_TIMEOUT") then {
		//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlSetText '(';
		//{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow true} foreach [A3C_RC_TimeOut];
		["OPEN"] call A3C_MAPTAB_SPAWN_TIMEOUTBOX;
	} else {
		//((findDisplay _a3c_dsp) displayCtrl 7008) ctrlsettext '^';
		{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [A3C_RC_TimeOut];
	};


	if (_action == "SQ_ACTION_GRENADE" && A3C_GREN_MUZZLE == "") then {
		_action = "SQ_ACTION_NONE";

	};

//systemchat str _action;
	if !(_action in ["SQ_ACTION_GRENADE"]) then {
		_originButton = _originButtonImage; //~~??
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2) ctrlShow false;
		_bg1 ctrlShow false;
		_bg2 ctrlShow false;
	};

	//-- adjust cntrl frames
	if (_subset == 1 OR (_action in A3C_AI_GREN_ARRAY)) then {

		if (_a3c_dsp == 6998) then {

			private _ctrlFrameOriginalY = A3C_MAPTAB_SETTINGSGROUP_Y; //if (_a3c_dsp == 6998) then {0.797058 * safezoneH + safezoneY} else {}; //~~ ALERT! WHAT IS GOING ON IN TABLET? NO FRAME?
			private _ctrlFrame = if (_a3c_dsp == 6998) then {(findDisplay _a3c_dsp displayCtrl 11)} else {};

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
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2) ctrlShow false;
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
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_1) ctrlShow false;
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2) ctrlShow false;
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	if (A3C_HELI_INF_MODE in ["INF","HC"]) then {
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	if ((count A3C_SELECTED_UNITS == 0)) exitWith {};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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


A3C_BUTTON_UNIT = objnull;

A3C_BTN_SELECT_HC = { //~~ #unused
	_unitIndex = (_this select 0) - 1; //-- minus 1 because HC array starts at 0 while squad array starts at (units player select 1)
	_button = _this select 1;
	_data = _this select 2;
	_shift = _data select 4; //false;  //-- disabled for now _data select 4;
	_ctrl = _data select 5;
	_alt = _data select 6;
	private _unitArray =  A3C_HCALLGROUPS_Current; //+(A3C_HC_MENU_REFERENCE_UNITS); 
	private _unit = _unitArray select _unitIndex;
	systemchat 'ayayay';
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	if ((_data select 1) == 0) then {
		if (_shift) then {
			if ((count A3C_SELECTED_UNITS) < (count _unitArray)) then {
				//-- no or not not all units selected
				_step = 1;
				if (count A3C_SELECTED_UNITS > 0) then {
					if !(_unit == A3C_ACTIVE_BUTTONUNIT) then {
						//-- some units are selected
						_destIndex = ([A3C_ACTIVE_BUTTONUNIT,_unitArray] call MCSS_fnc_GetArrayIndex);
						if (_unitIndex > _destIndex) then {
							_step = -1;
						};
						for "_i" from _unitIndex to _destIndex step _step do {
							//if (!isPlayer leader (_unitArray select _i)) then {
								A3C_SELECTED_UNITS pushbackUnique (_unitArray select _i);
							//};

						};
						//-- Author Note: Make general function for unitButton Colors //~~ #unused is this still used?
						for "_t" from 7025 to 7040 do {
							_index = ((_t - 7025) + (A3C_BUTTONPAGE_TABLET * 16));
							if (_index < (count _unitArray)) then {
								if ((_unitArray select _index) in A3C_SELECTED_UNITS) then {
									(findDisplay _a3c_dsp displayCtrl _t) ctrlSetTextColor [0,1,0,1];
								} else {
									(findDisplay _a3c_dsp displayCtrl _t) ctrlSetTextColor [0.9,0.9,0,1];
								};
							};
						};
					};
				} else {
					//-- no units are selected
					if (!isPlayer _unit) then { //~~ what is tihs? we are in HC?
						player groupSelectUnit [_unit,true];
						A3C_SELECTED_UNITS pushbackUnique _unit;
						(findDisplay 7999 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,1];
					};
				};
			} else {
				//-- all units selected
			};


			A3C_ACTIVE_BUTTONUNIT = _unit;
		} else {
			A3C_ACTIVE_BUTTONUNIT = _unit;
			{player hcselectgroup [_x,false]} foreach (hcallgroups player);
			if (_ctrl) then {
				for "_i" from 25 to 40 do {
					if ((_i - 24) == _button) then { //~~ #unused is this still used?
						if ((A3C_HCALLGROUPS_CURRENT select _unitIndex) in A3C_SELECTED_UNITS) then {
							((findDisplay _a3c_dsp) displayCtrl (7000 + _i) ) ctrlSetTextColor [0.9,0.9,0,1];
							A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [(A3C_HCALLGROUPS_CURRENT select _unitIndex)];
							player hcSelectGroup [(A3C_HCALLGROUPS_CURRENT select _unitIndex),false];
						} else {
							((findDisplay _a3c_dsp) displayCtrl (7024 + _button) ) ctrlSetTextColor [0,1,0,1];
							A3C_SELECTED_UNITS pushback (A3C_HCALLGROUPS_CURRENT select _unitIndex);
							player hcselectgroup [A3C_HCALLGROUPS_CURRENT select _unitIndex,true];
						};
					};
				};
			} else {
				A3C_SELECTED_UNITS = [A3C_HCALLGROUPS_CURRENT select _unitIndex];
				player hcselectgroup [A3C_HCALLGROUPS_CURRENT select _unitIndex,true];

				//systemchat str _unitindex;
				for "_i" from 25 to 40 do { //~~ #unused is this still used?
					if ((_i - 24) == _button) then {
						((findDisplay _a3c_dsp) displayCtrl (7024 + _button) ) ctrlSetTextColor [0,1,0,1];
					} else {
						((findDisplay _a3c_dsp) displayCtrl (7000 + _i) ) ctrlSetTextColor [0.9,0.9,0,1];
					};
				};
			};
		};
	} else {
		if (_ctrl) then {
			//-- center map on group leader
			if (visiblemap) then {
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
				(findDisplay 12 displayCtrl 51) ctrlMapAnimAdd [0.1,(ctrlMapScale (findDisplay 12 displayCtrl 51)),(position (leader (A3C_HCALLGROUPS_CURRENT select _unitIndex)))];
				ctrlMapAnimCommit (findDisplay 12 displayCtrl 51);
				[] spawn {
					sleep 0.2;
					(findDisplay 12 displayCtrl 51) ctrlEnable false;
				};
			} else {
				(findDisplay 6999 displayCtrl 7043) ctrlMapAnimAdd [0.1,(ctrlMapScale (findDisplay 6999 displayCtrl 7043)),(position (leader (A3C_HCALLGROUPS_CURRENT select _unitIndex)))];
				ctrlMapAnimCommit (findDisplay 6999 displayCtrl 7043);
			};
		} else {
			//-- right click menu
			lbClear ((findDisplay _a3c_dsp) displayCtrl 7078);
			((findDisplay _a3c_dsp) displayCtrl 7078) ctrlShow true;
			ctrlsetfocus (finddisplay _a3c_dsp displayctrl 7078);
			A3C_LB_MODE = [4,(_button + (A3C_BUTTONPAGE_TABLET * 16))];
			(findDisplay _a3c_dsp displayCtrl 7078) ctrlSetPosition [(_data select 2),(_data select 3)];
			(findDisplay _a3c_dsp displayCtrl 7078) ctrlCommit 0;
			[findDisplay _a3c_dsp displayCtrl 7078, "REJOIN"] call A3C_addLbEntry;
			
			[findDisplay _a3c_dsp displayCtrl 7078, 0] call A3C_setCurSel;
			
		};
	};
};

A3C_BTN_SELECT_UNIT = { //-- currently unused?
	private ["_unit","_unitIndex","_unitArray","_a3c_dsp","_mB","_sX","_sY","_shift","_ctrl"];

//systemchat str [A3C_HELI_INF_MODE,A3C_SELECTED_UNITS]; 

	_unitIndex = _this select 0;
	//systemChat str _unitIndex;
	_button = ((_this select 0) - (A3C_BUTTONPAGE_TABLET * 16));
	_data = _this select 1;
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	if (A3C_HELI_INF_MODE == "HC") exitwith {[_unitIndex,_button,_data] call A3C_BTN_SELECT_HC};
	_mB = _data select 1;
	_sX = _data select 2;
	_sY = _data select 3;
	_shift = _data select 4;
	_ctrl = _data select 5;
	//if (_ctrl) exitwith {};
	_unitArray = profileNamespace getvariable "A3C_GROUPUNITS";
	_unit = _unitArray select _unitIndex;
	if (isPlayer _unit) exitWith {
		systemchat format ["A3C: %1 is controlled by a player and will not be selected",name (_unitArray select _unitIndex)];
	};
	if (!alive _unit) exitwith {systemchat 'A3C: Unit not available'};
	if (_mB == 0) then {
		if (_shift) then {

			if ((count A3C_SELECTED_UNITS) < (count _unitArray)) then {
				//-- no or not not all units selected
				_step = 1;
				if (count A3C_SELECTED_UNITS > 0) then {
					if !(_unit == A3C_ACTIVE_BUTTONUNIT) then {
						//-- some units are selected
						_destIndex = [A3C_ACTIVE_BUTTONUNIT,_unitArray] call MCSS_fnc_GetArrayIndex;
						if (_unitIndex > _destIndex) then {
							_step = -1;
						};
						for "_i" from _unitIndex to _destIndex step _step do {
							_add = false; //~~??

							if (A3C_HELI_INF_MODE == 'AIR') then {
								if ( ((_unitArray select _i)== driver vehicle (_unitArray select _i)) OR (isNull (driver vehicle (_unitArray select _i))) ) then {
								//if ((_unitArray select _i)== (driver (vehicle (_unitArray select _i))) ) then {
									if ((vehicle (_unitArray select _i)) isKindOf 'AIR') then {
										//if (A3C_UNIT_%1_BV == 0) then {
										//};
										_add = true;
									};
								};
							} else {
								if ( ((_unitArray select _i)== driver vehicle (_unitArray select _i)) OR (isNull (driver vehicle (_unitArray select _i))) ) then {
								//if ((_unitArray select _i) == (driver (vehicle (_unitArray select _i))) ) then {
									if !((vehicle (_unitArray select _i)) isKindOf 'AIR') then {
										//if (A3C_UNIT_%1_BV == 0) then {
											//if ((_unitArray select _i) == (driver vehicle (_unitArray select _i))) then {
												_add = true;
											//};
										//};
									};
								};
							};

							if (_add) then {
								if (!isPlayer (_unitArray select _i)) then {
									//player groupSelectUnit [(_unitArray select _i),true];
									A3C_SELECTED_UNITS pushbackUnique (_unitArray select _i);
									call compile format ["A3C_UNIT_%1_BV = 1",_unitIndex];
									if (A3C_FORMMODE_TEMP == 4) then {
										A3C_SPLIT_UNITS pushbackUnique (_unitArray select _i);
									};
								} else {
									systemchat format ["A3C: %1 is controlled by a player and will not be selected",name (_unitArray select _i)];
								};
							};
						};
						//-- Author Note: Make general function for unitButton Colors
						for "_t" from 7025 to 7040 do {
							_index = ((_t - 7024) + (A3C_BUTTONPAGE_TABLET * 16));
							if (_index < (count _unitArray)) then {
								if ((_unitArray select _index) in A3C_SELECTED_UNITS) then {
									(findDisplay _a3c_dsp displayCtrl _t) ctrlSetTextColor [1,1,1,1];
								} else {
									(findDisplay _a3c_dsp displayCtrl _t) ctrlSetTextColor [1,1,1,0.5];
								};
							};
						};
					};
				} else {
					//-- no units are selected
					//player groupSelectUnit [_unit,true];
					if (!isPlayer _unit) then {
						A3C_SELECTED_UNITS pushbackUnique _unit;
						(findDisplay _a3c_dsp displayCtrl (7024 + _button)) ctrlSetTextColor [1,1,1,1];
					} else {
						systemchat format ["A3C: %1 is controlled by a player and will not be selected",name (_unitArray select _unit)];
					};
				};
			}  else {
				//-- all units selected
			};
			A3C_ACTIVE_BUTTONUNIT = _unit;
		} else {
			A3C_ACTIVE_BUTTONUNIT = _unit;
			if (!isPlayer _unit) then {	//~~ this isPlayer check still necessary? exits above if otherwise
				call compile format ["
					if (A3C_UNIT_%1_BV == 0) then {
						if (alive (_unitArray select %1) ) then {
							if (A3C_HELI_INF_MODE == 'AIR') then {
								if ( (%2== driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
									if ((vehicle %2) isKindOf 'AIR') then {
										[%1] call A3C_BTN_FNC_NOSHIFT;
										if !(_ctrl) then {
											A3C_SELECTED_UNITS = [%2];
										} else {
											A3C_SELECTED_UNITS pushbackUnique %2;
										};
										A3C_UNIT_%1_BV = 1;
										((findDisplay _a3c_dsp) displayCtrl (7024 + %3) ) ctrlSetTextColor [1,1,1,1];
									} else {
										A3C_SELECTED_UNITS = [%2];
										['INF'] call A3C_START_TABMODE;
										A3C_HELI_INF_MODE = 'INF';
									};
								};
							} else {
								if ( (%2== driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
									if !((vehicle %2) isKindOf 'AIR') then {
										[%1] call A3C_BTN_FNC_NOSHIFT;
										if !(_ctrl) then {
											A3C_SELECTED_UNITS = [%2];
										} else {
											A3C_SELECTED_UNITS pushbackUnique %2;
										};
										A3C_UNIT_%1_BV = 1;
										((findDisplay _a3c_dsp) displayCtrl (7024 + %3) ) ctrlSetTextColor [1,1,1,1];
									} else {
										A3C_SELECTED_UNITS = [%2];
										['AIR'] call A3C_START_TABMODE;
										A3C_HELI_INF_MODE = 'AIR';
									};
								};
							};
						};
					} else {
						if (alive (_unitArray select %1) ) then {
							if (A3C_HELI_INF_MODE == 'AIR') then {
								if ( (%2== driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
									if ((vehicle %2) isKindOf 'AIR') then {
										[%1] call A3C_BTN_FNC_NOSHIFT;
										if !(_ctrl) then {
											A3C_SELECTED_UNITS = [%2];
										} else {
											A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [%2];
										};
										A3C_UNIT_%1_BV = 1;
										((findDisplay _a3c_dsp) displayCtrl (7024 + %3) ) ctrlSetTextColor [1,1,1,1];
									};
								};
							} else {
								if ( (%2== driver vehicle %2) OR (isNull (driver vehicle %2)) ) then {
									if !((vehicle %2) isKindOf 'AIR') then {
										[%1] call A3C_BTN_FNC_NOSHIFT;
										if !(_ctrl) then {
											A3C_SELECTED_UNITS = [%2];
										} else {
											A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [%2];
										};
										A3C_UNIT_%1_BV = 1;
										((findDisplay _a3c_dsp) displayCtrl (7024 + %3) ) ctrlSetTextColor [1,1,1,1];
									};
								};
							};
						};
					};
				",_unitIndex,(_unitArray select _unitindex),_button];
			};
		};

		[A3C_HELI_INF_MODE] call A3C_START_TABMODE;
	} else {
		//-- right click
		//if (alive _unit) then {
			
		//};
	};
	
	//-- Subset Controls: Adjust images and hide subset-2
	if (A3C_LAST_SUBSET_ACTION in ["SQ_ACTION"]) then {
		[[7064,7065],A3C_LAST_SUBSET_ACTION,1,false] call A3C_TOGGLE_SUBSELECTION;
		(findDisplay _a3c_dsp displayCtrl PRNT_ACTION_SUBSET_2) ctrlShow false;
	};
};

A3C_MAPTAB_CONTEXTMENU_BOOLFNC = {
	A3C_MAPTAB_OPENING_CONTEXTMENU = true;
	sleep 0.5;
	A3C_MAPTAB_OPENING_CONTEXTMENU = false;
};

A3C_BTN_FNC_NOSHIFT = { //-- currently unnused?
	_unitIndex = _this select 0;
	_unit = ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitIndex + 1));
	if (isPlayer _unit) exitWith {
		systemchat format ["A3C: %1 is controlled by a player and will not be selected",name _unit];
	};
	_button = _unit getvariable 'A3C_Unt_Btn';
	_unitNumber = 0;
	_a3c_dsp = if (visibleMap) then {6998} else {6999};

	A3C_UNITCOUNT = ((count (units group player)) -1);
	for "_i" from 25 to 40 do {
		_unitNumber = (_i - 24);
		if (_unitNumber <= ( (count (profileNamespace getvariable "A3C_GROUPUNITS")) -1) ) then {
			if !(_i == _unitIndex) then {
				if (!isnull ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitNumber )) ) then {
					if (alive ((profileNamespace getvariable "A3C_GROUPUNITS") select (_unitNumber )) ) then {

						call compile format ["

							switch (A3C_HELI_INF_MODE) do {
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
	_groups = if ((count _this) > 1) then {_this select 1} else {A3C_HCALLGROUPS_Current };
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
	_unit = objnull;
	//~~ below is not bulletproof! what if AICOmmand, but not synced to module
	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	_units = [];
	_params = [];
	_isLoop = false;
	_loopPos = [0,0,0];
	_loopDest = [0,0,0];
	if ( (_mode == 0) && ((count A3C_SELECTED_UNITS) == 0)) exitwith {};
	if ( (_mode == 0) && (A3C_HELI_INF_MODE == "HC") ) exitwith {};
	if ( (_mode == 1) && ((count A3C_HCALLGROUPS_Current ) == 0)) exitwith {};
	if ( (_mode == 1) && A3C_BOOL_REJOINING) exitwith {};
	_data = [];
	_fnc_Tracker = {
		private ["_group","_marker"];
		_group = _this select 0;
		_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
		} foreach A3C_HCALLGROUPS_Current;
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

		if (A3C_HELI_INF_MODE in ["INF","AIR"]) then {
			if ((count units group player) == 1) then {
				["HC"] call A3C_START_TABMODE;
				A3C_HELI_INF_MODE = "HC";
			};
		};

		A3C_SELECTED_UNITS = [];
		
		//systemchat str _disbandedPhonetics;
		
		{[_x] spawn A3C_HC_ROLES;} foreach units _newGroup;

	} else {
		// re-join units
		[_groups] call A3C_fnc_SecuRejoin_fnc; //-- spawn security mechanic



		//systemchat str _groups;



		/*
		A3C_BOOL_REJOINING = true;

		{
			_gp = _x;
			_unts = units _gp;
			if !(_isHighCommand) then {
				{
					call compile format
					[
						"
							deletemarkerlocal 'A3C_HC_MARKER_%1_%2';
						",
						([_gp,A3C_HC_DISBANDED] call MCSS_fnc_GetArrayIndex),
						(_forEachIndex + 1)
					];
				} foreach (waypoints _x) + [1,2,3,4,5,6-1]; //-- the + [1,2,3] is just to make sure that the loop WP is removed too
			};

			{
				(vehicle _x) spawn {
					[_this,"LOCKED"] remoteExec ["setvehicleLock", _this];
					sleep 5;
					[_this,"UNLOCKED"] remoteExec ["setvehicleLock", _this];
				};
				[_x] spawn A3C_HC_ROLES;

			} foreach _unts;
			_unts join group player;
			sleep 0.5;
		} foreach _groups;
		{
			A3C_HC_DISBANDED = A3C_HC_DISBANDED - [_x];
			(_x getvariable 'A3C_TAB_MARKER') setmarkeralphaLocal 1;
		} foreach _groups;
		[(units group player) - [player]] call A3C_GROUP_RESET;
		A3C_BOOL_REJOINING = false;
		*/
	};





	sleep 0.2;

	if (A3C_HELI_INF_MODE == "HC") then {
		if ((count units group player) == 1) then {
			["HC"] call A3C_START_TABMODE;
			A3C_HELI_INF_MODE = "HC";
		};
	};
	A3C_BOOL_MAP_MD = false;
	A3C_BOOL_MOUSEUP = false;
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	{((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false} foreach [7078,A3C_RC_Context];
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
					//[A3C_HELI_INF_MODE] call A3C_LABEL_SELECTORS;
				};
			};
		};
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
};

A3C_MAPTAB_TREE_getSubParentCount = {
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
			A3C_TEMP_CONDITION set [1,(parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut)))];
			A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut)));
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
		[A3C_HELI_INF_MODE] call A3C_MAPTAB_REFRESH_BARCONTROLS;
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
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
A3C_RC_Menu_Inf = {
	private ["_marker","_mode","_building","_units","_data","_func"];
	_marker = _this select 0;
	_pos = _this select 1;
	_sX = _pos select 0;
	_sY = _pos select 1;
	_markerType = (markerType _marker);
	_building = objnull;
	_mode = "INF";
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	if (_markerType in A3C_AIR_MARKERS) then {_mode = "HELI"};
	if ((markertype _marker) == 'A3C_Marker_HCWP') then {_mode = "HC"};
	//systemchat 'o';

	A3C_MARKERTOSWITCH = _marker;
	lbClear ((findDisplay _a3c_dsp) displayCtrl 709112);
	(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlSetPosition [_sx, _sy];
	(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlCommit 0;
	if (_mode == "HELI") then {
		((findDisplay _a3c_dsp) displayCtrl A3C_RC_Context) ctrlShow true;
		A3C_LB_MODE = 0;
		(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlSetPosition [_sx, _sy];
		(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlCommit 0;

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
	_units = [];
	_data = [];
	_func = {
		private ["_soldier","_mode","_marker","_return","_data"];
		_soldier = _this select 0;
		_mode = _this select 1;
		_marker = _this select 2;
		_return = false;
		_data = [];
		_a3c_dsp = if (visibleMap) then {6998} else {6999};

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

	_funcHC = {
		private ["_wp"];
		_marker = _this select 0;
		_a3c_dsp = if (visibleMap) then {6998} else {6999};
		_wp = 0;
		((findDisplay _a3c_dsp) displayCtrl A3C_RC_Context) ctrlShow true;

		{
			private ["_stance1","_stance2"];
			_gp = _x;
			_statements = "";
			_stance1 = "";
			_stance2 = "";
			if ( (parseNumber ((_marker splitstring "_") select 3)) == ([_gp,A3C_HCALLGROUPS_CURRENT] call MCSS_fnc_GetArrayIndex)   ) exitWith {
				_wp = [_gp,((parseNumber ((_marker splitstring "_") select 4)) - 1)];
				_statements = ((waypointstatements _wp) select 1) splitstring ";";
				_stance1 = (((_statements select 0) splitstring "'") select 1);
				_stance2 = (((_statements select 1) splitstring "'") select 1);
				switch (_stance1) do {
					case "DOWN" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
					case "MIDDLE" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
					case "UP" : {((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
				};
				switch (_stance2) do {
					case "DOWN" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
					case "MIDDLE" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
					case "UP" : {((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
				};
				if ((waypointSpeed _wp) == "LIMITED") then {
					((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
				} else {
					((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
				};


			};
		} foreach A3C_HCALLGROUPS_CURRENT;
	};

	if (_mode == "HC") exitWith {
		[_marker] call _funcHC;
	};

	{
		if ([_x,_mode,_marker] call _func) then {_units pushback _x};
	} foreach (profileNamespace getvariable "A3C_GROUPUNITS");


	if (_mode == "INF") then {
		if ((count _units) > 0) then {
			A3C_GCUNITS = _units;
			A3C_MARKERTOSWITCH = _marker;
			lbClear ((findDisplay _a3c_dsp) displayCtrl 709112);
			((findDisplay _a3c_dsp) displayCtrl A3C_RC_Context) ctrlShow true;
			A3C_LB_MODE = 2;
			(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlSetPosition [_sx, _sy];
			(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlCommit 0;

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
			
			switch (_markertype) do {
				case ('A3C_Marker_GoCode_A') : {[findDisplay _a3c_dsp displayCtrl 709112, 1] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_B') : {[findDisplay _a3c_dsp displayCtrl 709112, 2] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_C') : {[findDisplay _a3c_dsp displayCtrl 709112, 3] call A3C_setCurSel;};
				case ('A3C_Marker_GoCode_D') : {[findDisplay _a3c_dsp displayCtrl 709112, 4] call A3C_setCurSel;};
				default {[findDisplay _a3c_dsp displayCtrl 709112, 0] call A3C_setCurSel;};
			};
			
		};
	};
	lbClear ((findDisplay _a3c_dsp) displayCtrl A3C_RC_Context_HC_WP);
	if ((count _units) == 1) then {
		[findDisplay _a3c_dsp displayCtrl A3C_RC_Context_HC_WP, "NONE"] call A3C_addLbEntry;
		_data =  (_units select 0) getvariable A3C_CHECKVAR;
		_wpInd = ( ((_units select 0) getvariable "A3C_CURRENTWAYPOINT_INDEX") - 1 );
		[findDisplay _a3c_dsp displayCtrl A3C_RC_Context_HC_WP, 1] call A3C_setCurSel;
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
	//_data params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
	//systemchat str _data;
	//systemchat str _wpMarkers;
//	for "_i" from 0 to ((count _vari) + 1) do {
//		_del = if (_vari == "A3C_PLOT_TEMP") then {true} else {(_i <= ((_unit getvariable "A3C_CURRENTWAYPOINT_INDEX") -2))};
//		if (_del) then {
//			if (_vari == "A3C_PLOT") then {
//				//{deletemarkerLocal _x} foreach ((_data select _i) select 1);
//				{[_x,_unit,_vari] call A3C_DELETE_MARKER} foreach ((_data select _i) select 1);
//
//				//{deletemarkerLocal _x} foreach (_data select 1);
//			};
//		};
//	};
	if (A3C_BOOL_DRAGLINE) then {
		A3C_BOOL_DRAGLINE = false;
	};
};


//-- "mousebuttonDown" on marker. If Loop can be created, adds displayEventHandlers and creates Dummy for MouseDrag-Arrow
A3C_TAB_LOOP_LM_DOWN = {
	private ["_units","_syncData"];
	_sx = _this select 0;
	_sy = _this select 1;
	_units = [];
	_data = [];
	A3C_LOOPSYNC_START = ["",[0,0,0]];
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	disableSerialization;
	_map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};

	private _waypointIDS = [];
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	private _waypointPosition = [0,0,0];
	if (count _squadWaypoints > 0) then {
		_squadWaypoint = _squadWaypoints select 0;
		_waypointPosition = _squadWaypoint select 2;
		_waypointIDS = _squadWaypoint select 3;

	};



	//systemchat str (_clickedItem);
	if (count _waypointIDS > 0) then {
			//-- we are in business!
			{
				private ["_u"];
				_u =_x;
				{
					private ["_var","_varType"];
					_varType = _x;
					_var = _u getVariable _varType;
					{
						_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
						//systemchat str _wpMarkers;
						if ( ((_wpMarkers select 0) == (_waypointIDS select 0)) && (_wpMarkers select 1 != "") ) then {

							{
								_syncItem = _x;
								if !(_syncItem select 0 == 0) then {
									{
										_u1 = _x;
										{
											_var1 = _u1 getVariable _x;
											{
												_synchro2 = (_x select 5);
												{
													if ((_x select 0) == (_syncItem select 0)) then {
														_synchro2 = _synchro2 - [_x];
													};
												} foreach _synchro2;
												_x set [5,_synchro2];
											} foreach _var1;

											_u1 setVariable [_x,_var1,true];

										} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
									} foreach (units player - [player,_u]);
								};
							} foreach _wpSyncData;
							_x set [5,[[0,false]]];
							_u setVariable [_varType,_var,true];
						};
					} foreach _var;
				} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
			} foreach (units player - [player]);
			A3C_BOOL_MOUSEMOVING = true;
			A3C_BOOL_MOUSEUP = true;

			A3C_MMCode = {
				_this spawn A3C_TAB_MouseDrag;
			};

			//-- step 1:
			{
				if ( ({(_waypointIDS select 0) in (_x select 1)} count   ((_x getvariable "A3C_PLOT_TEMP") + (_x getvariable "A3C_PLOT")) ) > 0 ) then {
					_units pushback _x;
				};
			} foreach (profileNamespace getvariable "A3C_GROUPUNITS") - [player];

			if (({ (({(_waypointIDS select 0) in (_x select 1)} count (_x getvariable "A3C_PLOT_TEMP")) > 0) && ((count (_x getvariable "A3C_PLOT")) > 0) } count _units) > 0) then {
				[] spawn {
					hint "This feature is not compatible with extending sessions. Press 'COMMIT' first!";
					sleep 3;
					hintSilent "";
				};
			} else {

				{[_x] call A3C_LOOP_VIS_1} foreach _units;
				A3C_BOOL_LOOPING = true;
				A3C_LOOPSYNC_START = [(_waypointIDS select 0),_waypointPosition] ;
				if !(A3C_BOOL_DRAGLINE) then {
					A3C_BOOL_DRAGLINE = true;
					A3C_CONNECTING_MODE = "LOOP";
				};
			};

	} else {
		//-- create Drag Field
		//systemchat str [A3C_MAP_X,A3C_MAP_Y];
		A3C_MapSel_Field_Root = _map1 posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
		A3C_MapSel_Field_DEST = _map1 posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
		A3C_MapSel_Field_Active = true; //-- send signal to Draw function: Draw the field

	};
};


A3C_MapSel_Field_Root = [0,0,0];
A3C_MapSel_Field_DEST = [0,0,0];
A3C_MapSel_Field_Active = false;

A3C_TAB_LOOP_LM_UP = {
	private ["_startMark","_exit","_units","_data","_isLoop","_dragMode","_sc","_wrongDir"];

	A3C_BOOL_LOOPING = false;
	A3C_BOOL_MOUSEUP = false;
	A3C_BOOL_MOUSEMOVING = false;


	if ((_this select 1) == 1) exitwith {}; //-- exit if rmb was used to enable mapdrag
	_sx = _this select 2;
	_sy = _this select 3;
	_isLoop = false;
	_units = [];
	_checkVar = "A3C_PLOT_TEMP";
	_dragMode = "LOOP";
	_a3c_dsp = if (visibleMap) then {6998} else {6999};
	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS") - [player];

	
	disableSerialization;
	_map1 = if (_a3c_dsp == 6998) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};

	_clickedItem = (ctrlMapMouseOver _map1);
	_marker = "";

	A3C_BOOL_DRAGLINE = false;
	//systemchat str time;
	private _waypointIDS = [];
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_MAP_iconsAtMapPos);
	private _waypointPosition = [0,0,0];
	if (count _squadWaypoints > 0) then {
		_squadWaypoint = _squadWaypoints select 0;
		_waypointPosition = _squadWaypoint select 2;
		_waypointIDS = _squadWaypoint select 3;

	};

	private _exit = true;
	//systemchat str (_clickedItem);
	if (count _waypointIDS > 0) then {
		_marker = _waypointIDS select 0;

		if !(A3C_LOOPSYNC_START select 0 == _marker) then {
			_exit = false;
		};

	};

	if (_exit) exitwith {};


	{
		//-- determine what var we start off from, add units for both vars if the marker is inside of var

		if ( ({A3C_LOOPSYNC_START select 0 in (_x select 1)} count   (_x getvariable "A3C_PLOT_TEMP") ) > 0 ) then {
			_units pushback _x;
		};

		if (({A3C_LOOPSYNC_START select 0  in (_x select 1)} count (  (_x getvariable "A3C_PLOT"))) > 0) then {
			_units pushback _x;
			_checkVar = "A3C_PLOT";
		};
		//-- var is determined, destination needs to be within same var (planning vs real could mean issues)
		if ( ({_marker in (_x select 1)} count  (_x getvariable _checkVar)) == 0) then {
			_units = _units - [_x];
		};

	} foreach _unitArray;
	//if (A3C_FORMMODE_TEMP == 4 && {(count _units) > 0}) exitWith {systemchat "exit"};
	if ((count _units) == 0) then {
		//-- No Loop found. Check for sync
		_dragMode = "SYNC";

		_sc = false;
		{
			private ["_u"];
			_u = _x;
			{
				private ["_var","_varType"];
				_varType = _x;
				_var = _u getVariable _varType;
				{
					_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
					if (A3C_LOOPSYNC_START select 0 in _wpMarkers) then {
						_units pushbackUnique _u;
						if (((_wpSyncData select 0) select 0) == 0) then {
							_x set [5,[[A3C_SYNC_INDEX,false]]];
						} else {
							(_x select 5) pushBackUnique [A3C_SYNC_INDEX,false];
						};
						_sc = true;
					};
					if (_marker in _wpMarkers) then {
						_units pushbackUnique _u;
						if (((_wpSyncData select 0) select 0) == 0) then {
							_x set [5,[[A3C_SYNC_INDEX,false]]];
						} else {
							(_x select 5) pushBackUnique [A3C_SYNC_INDEX,false];
						};

						_sc = true;
						if (_forEachIndex == 1) then {
							_checkVar = "A3C_PLOT";
						};
					};
				} foreach _var;
				_u setVariable [_varType,_var,true];
			} foreach ["A3C_PLOT_TEMP","A3C_PLOT"];
		} foreach _unitArray;
		if (_sc) then {A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1};
	};
	//[((units player select 1) getvariable "A3C_PLOT_TEMP") , ((units player select 5) getvariable "A3C_PLOT_TEMP")]
	//systemchat str _dragmode;
	//-- still no units: exit.
	if ((count _units) == 0) exitWith {
		A3C_LOOPSYNC_START = ["",[0,0,0]];
		A3C_AIC_DRAGPOS = [];
		A3C_DRAGPOS = [];
	};


	//systemchat str _checkVar;
	if (_dragMode == "LOOP") then {
		_wrongDir = false;
		{
			private ["_dest","_sl","_loopVal","_markerIndex"];
			_sl = _x;
			_data = (_sl getvariable _checkVar);
			_dest = 0;
			_destPos = [];
			_markerIndex = -1;
			{
				_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

				if ((_wpMarkers select 0) == (A3C_LOOPSYNC_START select 0)) then {

					_markerIndex = _forEachIndex;
				};
				if ((_wpMarkers select 0) == _marker) then {
					if (_markerIndex != -1) then {
						_wrongDir = true;
					};

				};
			} foreach _data;
		} foreach _units;
		if !(_wrongDir) then {
			{
				private ["_dest","_sl","_loopVal","_markerIndex","_loopToIndex"];
				_sl = _x;
				_data = (_sl getvariable _checkVar);
				_loopToIndex = 0;
				{
					_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
					switch (true) do {
						case ((_wpMarkers select 0) == _marker) : {
							_x set [10,-2]; //-- loopDest aka the EARLIER waypoint
							_loopToIndex = _forEachIndex;
						};
						case ((_wpMarkers select 0) == (A3C_LOOPSYNC_START select 0)) : {
							_x set [10,_loopToIndex]; //-- loopStart aka the LATER waypoint
						};
						default {_x set [10,-1]}; //-- all other waypoints get loopVar reset
					};
				} foreach _data;
				_sl setvariable [_checkvar,_data,true];
			} foreach _units;
		} else {
			[] spawn {
				hint "Are you looping in the wrong direction?";
				sleep 2;
				hint "";
			};
		};
	};
	A3C_WAYPOINTS_TEMP pushback [_units,"","","",1];
	A3C_USERACTION pushback [0,1,1];
	A3C_USERACTION_ID = (A3C_USERACTION_ID + 1);
	A3C_LOOPSYNC_START = ["",[0,0,0]];
	A3C_AIC_DRAGPOS = [];
	A3C_DRAGPOS = [];
	A3C_CLICKPOS_1 = [0,0,0];
	A3C_CLICKPOS_2 = [0,0,0];
	A3C_TEMP_WP_ID_MAIN = "";
};




A3C_CONTEXTBUTTON = {
	// AUTHOR NOTE: ~ can this be optimized more and shortened??
	private ["_mode","_func","_createLoopLine"];
	_mode = _this select 0;
	if ((markertype A3C_MARKERTOSWITCH) in A3C_AIR_MARKERS) then {
		if (_mode == "STANCE1") then {
			_mode = "HEIGHT";
		};
		if (_mode == "STANCE2") then {
			_mode = "HELIWP";
		};
	};
	_func = {
		private ["_unit","_mode","_data","_isCurrent","_isLoop","_loopStart","_loopDest"];
		_unit = _this select 0;
		_mode = _this select 1;
		_data = [];
		_isLoop = false;
		_loopStart = 0;
		_loopDest = 0;
		_a3c_dsp = if (visibleMap) then {6998} else {6999};
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
								(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlShow false;
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
	/*
	//~~ hc functions replaced by waypoint contectmenu. keeping them for reference when I see a chance to include stances and speed again
	_funcHC = {
		private ["_wp","_marker","_preWP","_mode","_wpData"];
		_mode = _this select 0;
		_marker = A3C_MARKERTOSWITCH;
		_wp = 0;
		_preWP = [];
		_wpData = [];
		{
			private ["_gp","_stance1","_stance2","_isCurrent","_altState","_speed","_wp","_altWP"];
			_gp = _x;
			_statements = "";
			_altState = "";
			_stance1 = "";
			_stance2 = "";
			_speed = "";
			_isCurrent = false;
			_wp = [];
			_altWP = [];
			_a3c_dsp = if (visibleMap) then {6998} else {6999};
			if ( (parseNumber ((_marker splitstring "_") select 3)) == ([_gp,A3C_HCALLGROUPS_CURRENT] call MCSS_fnc_GetArrayIndex)   ) exitWith {
				_wp = [_gp,((parseNumber ((_marker splitstring "_") select 4)) - 1)];
				_statements = ((waypointstatements _wp) select 1) splitstring ";";
				if ((_wp select 1) == (currentWaypoint _gp)) then {_isCurrent = true};
				_stance1 = (((_statements select 0) splitstring "'") select 1);
				_stance2 = (((_statements select 1) splitstring "'") select 1);
				switch (_mode) do {
					case ("STANCE1") : {
						_altWP = [_gp,((parseNumber ((_marker splitstring "_") select 4)) - 2)];
						_altState = ((waypointstatements _altWP) select 1) splitstring ";";
						//player sidechat str _altState;
						switch (_stance1) do {
							case ("DOWN") : {
								_altState set [1," {_x setunitpos 'UP'} foreach units (group this)"];
								_statements set [0," {_x setunitpos 'UP'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
								if (_isCurrent) then {
									{_x SetUnitPos "UP"} foreach units _gp;
								};
							};
							case ("MIDDLE") : {
								_altState set [1," {_x setunitpos 'DOWN'} foreach units (group this)"];
								_statements set [0," {_x setunitpos 'DOWN'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
								if (_isCurrent) then {
									{_x SetUnitPos "DOWN"} foreach units _gp;
								};


							};
							case ("UP") : {
								_altState set [1," {_x setunitpos 'MIDDLE'} foreach units (group this)"];
								_statements set [0," {_x setunitpos 'MIDDLE'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709111) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
								if (_isCurrent) then {
									{_x SetUnitPos "MIDDLE"} foreach units _gp;
								};
							};
						};
						_altState = _altState joinString ";";
						_statements = _statements joinString ";";
						_wp setwaypointStatements [((waypointstatements _wp) select 0),_statements];
						if ((_altWP select 1) < 0) then {
							_altWP setwaypointStatements [((waypointstatements _altWP) select 0),_altState];
						};
					};
					case ("SPEED") : {
						if ((waypointSpeed _wp) == "LIMITED") then {
							_wp setwaypointSpeed "NORMAL";
							((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
						} else {
							_wp setwaypointSpeed "LIMITED";
							((findDisplay _a3c_dsp) displayCtrl 709110) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
						};
					};
					case ("STANCE2") : {
						//-- note: 'alt' is now actually the 'post' wp
						_altWP = [_gp,((parseNumber ((_marker splitstring "_") select 4)) - 0)];
						_altState = ((waypointstatements _altWP) select 1) splitstring ";";
						//player sidechat str _altState;
						switch (_stance2) do {
							case ("DOWN") : {
								_altState set [0," {_x setunitpos 'UP'} foreach units (group this)"];
								_statements set [1," {_x setunitpos 'UP'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
							};
							case ("MIDDLE") : {
								_altState set [0," {_x setunitpos 'DOWN'} foreach units (group this)"];
								_statements set [1," {_x setunitpos 'DOWN'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
							};
							case ("UP") : {
								_altState set [0," {_x setunitpos 'MIDDLE'} foreach units (group this)"];
								_statements set [1," {_x setunitpos 'MIDDLE'} foreach units (group this)"];
								((findDisplay _a3c_dsp) displayCtrl 709113) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
							};
						};
						//player commandchat str _altState;
						_statements = _statements joinString ";";
						//player commandchat str _statements;
						_altState  = _altState  joinString ";";
						_wp setwaypointStatements [((waypointstatements _wp) select 0),_statements];
						if ((_altWP select 1) <= (count waypoints _gp)) then {
							_altWP setwaypointStatements [((waypointstatements _altWP) select 0),_altState];
						};
					};
					case ("DELETE") : {
						(findDisplay _a3c_dsp displayCtrl A3C_RC_Context) ctrlShow false;
						systemchat "HCWP ALERT";
					};
				};
			};
		} foreach A3C_HCALLGROUPS_CURRENT;
	};
	*/

	//if ((markertype A3C_MARKERTOSWITCH) == 'A3C_Marker_HCWP') then {
	//	[_mode] spawn _funcHC; // change back to call!!!
	//} else {
		{
			[_x,_mode] call _func;
		} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
	//};


};

A3C_MAP_BOOL_CT = false;


A3C_MAP_fnc_CT_DASHBOARD = {
	params ["_mode"];

	private _a3c_dsp = if (visibleMap) then {6998} else {if (!isNull findDisplay 6999) then {6999} else {7999}};

	if (_a3c_dsp == 7999) exitWith {}; //-- temp solution until figured out

	private _textCtrl = findDisplay _a3c_dsp displayCtrl 11001;
	private _editCtrl = findDisplay _a3c_dsp displayCtrl 800713;
	private _groupName = str (parsetext (ctrlText _editCtrl));

	if (_mode == "ON") then {
		_textCtrl ctrlSetTextColor [1,1,1,0];
		_editCtrl ctrlSetText _groupName;
		_editCtrl ctrlSetTextColor [1,1,1,1];
		A3C_GROUP_NAMEING_ACTIVE = true;
	} else {
		A3C_GROUP_NAMEING_ACTIVE = nil;
		_textCtrl ctrlSetText _groupName;
		_textCtrl ctrlSetTextColor [1,1,1,1];
		_editCtrl ctrlSetTextColor [1,1,1,0];
	};
};

A3C_MAP_fnc_CT = {
	params ["_controlType","_mode"];
	private ["_a3c_dsp"];
	private _a3c_dsp = if (visibleMap) then {6998} else {if (!isNull findDisplay 6999) then {6999} else {7999}};
	if (_a3c_dsp == 7999) exitWith {}; 
	
	if (_mode == "ON") then {
		A3C_MAP_BOOL_CT = true;
		A3C_BOOL_CT_SPACING = true; A3C_BOOL_DISABLEMAPCTRL = true; (findDisplay 12 displayCtrl 51) ctrlEnable false;
	} else {
		A3C_MAP_BOOL_CT = false;
		A3C_BOOL_CT_SPACING = false; A3C_BOOL_DISABLEMAPCTRL = false; (findDisplay 12 displayCtrl 51) ctrlEnable true;
		switch (_controlType) do {
			case ("TIMEOUT") : {
				if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
					A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_RC_TimeOut)));
				};
			};
			case ("SPACING") : {
				//systemchat 'spacingf';
				switch (A3C_HELI_INF_MODE) do {
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


