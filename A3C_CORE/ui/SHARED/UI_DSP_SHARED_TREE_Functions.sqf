#include "shared_ui_defines.hpp"
#include "script_component.hpp"
#include "..\radial\radialMenu\dialog_defines.hpp"
#include "..\mapOverlay\dialog_defines.hpp"

//[_CT_TREE,"SQUAD_VEH", [_veh,_crewUnits],_mainTreeIndex,_foreachIndex] call A3C_UI_MAP_TREE_ADD_ITEM;
A3C_UI_MAP_TREE_ADD_ITEM = {
	params ["_CT_TREE","_mode","_dataParam","_mainTreeIndex","_parentIndex"];
	private _unitArray = +(profileNamespace getvariable "A3C_GROUPUNITS");

	_fn_buttonColor = {
		params ["_unit"];
		private _assignedTeam = if (player == cameraOn) then {assignedTeam _unit} else {_unit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		private _color = switch (_assignedTeam ) do {
			case ("RED") : {[A3C_UI_COLOR_RED,1] call A3C_UI_fnc_setOpacity};
			case ("GREEN") : {[0,1,0,1]};
			case ("BLUE") : {[A3C_UI_COLOR_BLUE,1] call A3C_UI_fnc_setOpacity};
			case ("YELLOW") : {[A3C_UI_COLOR_YELLOW,1] call A3C_UI_fnc_setOpacity};
			default {[1,1,1,1]};
		};
		_color
	};

	switch (_mode) do {
		case ("SQUAD_INF") : {
			
			_dataParam params ["_unit"];
			if (!isNull _unit ) then { //&& {alive _unit}
				_CT_TREE tvAdd [[_mainTreeIndex], if (!isNull _unit && {alive _unit}) then {[_unit] call MCSS_fnc_getUnitNameString} else {"N/A"}];
				_ct_indexArray = [_mainTreeIndex,_parentIndex];
				//_CT_TREE tvAdd [[_i], [_unit] call MCSS_fnc_getUnitNameString];
				_weapon = if ((secondaryweapon _unit) isKindOf ["Launcher", configFile >> "CfgWeapons"]) then {secondaryWEapon _unit} else {primaryWeapon _unit};
				_CT_TREE tvSetPicture [_ct_indexArray, getText (configFile >> "CfgWeapons" >> _weapon >> "picture")];
				switch (true) do {
					case ({[_x] call A3C_main_fnc_getBaseWeapon == "Medikit"} count (items _unit) > 0) : {
						_CT_TREE tvSetPictureRight [_ct_indexArray, "A3C_CORE\ui\pictures\icon_menu_Medical.paa"];
						//_CT_TREE tvSetPictureRightColor [_ct_indexArray, [A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity];
						_CT_TREE tvSetPictureRightColor [_ct_indexArray, [1,1,1,0.7]];						
					};
					case ({[_x] call A3C_main_fnc_getBaseWeapon == "ToolKit"} count (items _unit) > 0) : {
						_CT_TREE tvSetPictureRight [_ct_indexArray, "A3C_CORE\ui\pictures\icon_menu_action_repair_noBG.paa"];
						_CT_TREE tvSetPictureRightColor [_ct_indexArray, [1,1,1,0.7]];					
					};
				};
				_unit setVariable ["A3C_TREESEL_INDEX",[_ct_indexArray]];

				_CT_TREE tvSetValue 
				[
					_ct_indexArray,
					[_unit,_unitArray] call MCSS_fnc_getArrayIndex
				];

				_CT_TREE tvSetColor
				[
					_ct_indexArray,
					[_unit] call _fn_buttonColor
				];
			};
		};
		case ("SQUAD_VEH") : {
			_dataParam params ["_veh","_crewUnits"];

			private _driver = driver _veh;
			private _vehType = typeof _veh;

			_CT_TREE tvAdd [[_mainTreeIndex], gettext(configFile >> "CfgVehicles" >> _vehType >> "displayName")];
			_CT_TREE tvSetPicture [[_mainTreeIndex,_parentIndex], gettext(configFile >> "CfgVehicles" >> _vehType >> "picture")];
			if (_driver in (_unitArray - [player])) then { //~~_crewUnits ??
				_CT_TREE tvSetValue 
				[
					[0,_parentIndex],
					[_driver,_unitArray] call MCSS_fnc_getArrayIndex
				];
			};

			_crewUnits = 
			[
				_crewUnits,
				[],
				{
					//-- idea: 'crew' command always returns units in [driver,(gunner,commander/copilot),FFV] > so we sort by crew-array index
					_val = [_x,crew vehicle _x] call MCSS_fnc_getArrayIndex;
					_val
				},
				"ASCEND"
			] call BIS_fnc_sortBy;
			{
				[_CT_TREE,"SQUAD_CREW", [_x],_mainTreeIndex,_parentIndex] call A3C_UI_MAP_TREE_ADD_ITEM;	
			} foreach _crewUnits;
		};
		case ("SQUAD_CREW") : {
			_dataParam params ["_unit"];
			_v = vehicle _unit;
				
			_CT_TREE tvAdd [[_mainTreeIndex,_parentIndex],if (!isNull _unit && {alive _unit}) then {[_unit] call MCSS_fnc_getUnitNameString} else {"N/A"}];
			private _ct_indexArray = [_mainTreeIndex,_parentIndex, (_CT_TREE tvCount [_mainTreeIndex,_parentIndex]) -1]; //_foreachIndex

			_unit setVariable ["A3C_TREESEL_INDEX",[_ct_indexArray]];
			
			_CT_TREE tvSetColor
			[
				_ct_indexArray,
				[_unit] call _fn_buttonColor
			];

			_roleImg = switch (true) do {//assignedVehicleRole _unit
				case (_unit == driver _v) : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_driver_ca.paa"};
				case (_unit == gunner _v) : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa"};
				case (_unit == commander _v OR {_unit call MCSS_fnc_isUnitCopilot}) : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa"};
				case (toLower ((assignedVehicleRole _unit) select 0) == "turret") : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa"};
				default {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"};
			};
			_CT_TREE tvSetPicture 
			[
				_ct_indexArray,
				_roleImg
			];
			//_current = tvCurSel _CT_TREE;
			//player groupChat str _current;

			_CT_TREE tvSetValue 
			[
				_ct_indexArray,
				[_unit,_unitArray] call MCSS_fnc_getArrayIndex
			];
		};
		case ("HC_CLASS") : {
			//_unitArray set to HCALL!!!!!
		};
		case ("HC_CARGO") : {
			_dataParam params ["_cargoGroup","_ct_index"];
			_ct_indexArray = [_mainTreeIndex,_parentIndex,_ct_index]; 
			//systemChat str [_ct_indexArray,_mainTreeIndex,_parentIndex];
			_CT_TREE tvAdd [_ct_indexArray,toUpper ( groupID _cargoGroup)];
			private _cargoGroup_ct_indexArray = _ct_indexArray + [(_CT_TREE tvCount _ct_indexArray) -1];
			//_cargoGroup_ct_indexArray = [_mainTreeIndex,_parentIndex, (_CT_TREE tvCount [_mainTreeIndex,_parentIndex]) -1]; //_foreachIndex
			_CT_TREE tvSetPicture 
			[
				_cargoGroup_ct_indexArray,
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"
			];
			_CT_TREE tvSetValue 
			[
				_cargoGroup_ct_indexArray,
				[_cargoGroup,A3C_UI_SHARED_TREE_HC_AT_TICK] call MCSS_fnc_getArrayIndex
			];
			_cargoGroup setVariable ["A3C_TREESEL_INDEX",[_cargoGroup_ct_indexArray]];
		};
	};
};



A3C_UI_MAP_TREE_LABEL = {

	params ["_a3c_dsp"];

	

	//systemChat "LABEL";
	A3C_UI_SHARED_TREE_HC_AT_TICK = A3C_HC_allGroupsClient_Current;
	private _modes = if (_a3c_dsp == IDD_RADIAL_MENU) then {if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {["SQUAD"]} else {["HIGHCOMMAND"]}} else {["SQUAD","HIGHCOMMAND"]};
	if (count A3C_UI_SHARED_TREE_HC_AT_TICK < 2 && {"HIGHCOMMAND" in _modes}) then {
		_modes = _modes - ["HIGHCOMMAND"];
	};
	

	
	_CT_TREE = findDisplay _a3c_dsp displayctrl IDC_SHARED_UI_TREE_SELECTOR;

	tvClear _CT_TREE;
	
	
	

	_mainTreeIndex = 0;

	if ("SQUAD" in _modes) then {
		private _unitArray = +(profileNamespace getvariable "A3C_GROUPUNITS");
		private _vehicles = [];
		private _soldiers = [];
		
		{
			_u = _x;
			if (!isNull objectParent _x) then {
				_v = (vehicle _x);
				_doAdd = true;
				{
					if (_x select 0 == _v) exitWith {
						(_x select 1) pushBack _u;
						_doAdd = false;
					};
				} foreach _vehicles;
				if (_doAdd) then {
					_vehicles pushBackUnique [_v,[_u]];
				};		
			} else {
				_soldiers pushBack _x;
			};
		} foreach (_unitArray - [player]);


		_CT_TREE tvAdd [[], toUpper groupID group player];
		if (count _vehicles > 0) then {
			//-- sort vehicles by classes
			_vehicles = 
			[
				_vehicles,
				[],
				{
					
					_veh = _x select 0;
					_armor = getnumber (configfile >> "Cfgvehicles" >> typeof _veh >> "armor");
					_val = 0;
					{
						
						if (_veh isKindOf _x) exitWith {
							_val = 7000 - (1000 * _forEachIndex);
							_val = _val + _armor + ((count weapons _veh) * 100);
							//systemchat str _val;
						};
					} foreach ["PLANE","HELICOPTER","TANK","CAR","SHIP","STATICWEAPON"];
					_val
				},
				"DESCEND"
			] call BIS_fnc_sortBy;
			{
				_x params ["_veh","_crewUnits"];
				//private _fi = _foreachIndex;
				[_CT_TREE,"SQUAD_VEH", [_veh,_crewUnits],_mainTreeIndex,_foreachIndex] call A3C_UI_MAP_TREE_ADD_ITEM;
			} foreach _vehicles; 
		};

		if (count _soldiers > 0) then {
			private _squadTreeCount = count _vehicles;
			{
				[_CT_TREE,"SQUAD_INF", [_x],_mainTreeIndex,_foreachIndex + _squadTreeCount] call A3C_UI_MAP_TREE_ADD_ITEM;
			} foreach _soldiers; 
		};
		_mainTreeIndex = _mainTreeIndex + 1;
		
	};
	_subTreeIndex = 0;
	if ("HIGHCOMMAND" in _modes) then {
		_CT_TREE tvAdd [[], "HIGH COMMAND"];
		
		//_CT_TREE tvAdd [[1], "SOMETHING ELSE"];

		

		_planeGroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "PLANE"}};
		_heliGroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "HELICOPTER"}};
		_tankGroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "TANK"}};
		_wheeledAPCgroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "wheeled_apc_f"}};
		_carGroups = (A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "CAR"}}) - _wheeledAPCgroups; 
		_shipGroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; driver _lV in (units _x) && {_lV isKindOf "SHIP"}};
		_staticGroups = A3C_UI_SHARED_TREE_HC_AT_TICK select {{vehicle _x isKindOf "STATICWEAPON"} count units _x > 0};
		_infantryGroups = (A3C_UI_SHARED_TREE_HC_AT_TICK select {_lV = vehicle leader _x; _lV isKindOf "MAN"}) - _staticGroups;
		//!(driver _lV in (units _x)) OR {_lV isKindOf "MAN"}

		_planeGroupsUAV = _planeGroups select {_lV = vehicle leader _x; unitIsUAV _lV};
		_planeGroups = _planeGroups - _planeGroupsUAV;

		_heliGroupsUAV = _heliGroups select {_lV = vehicle leader _x; unitIsUAV _lV};
		// systemchat str (count _heliGroups);
		_heliGroups = _heliGroups - _heliGroupsUAV;
		// systemchat str (count _heliGroups);

		_carGroupsUAV = _carGroups select {_lV = vehicle leader _x; unitIsUAV _lV};
		_carGroups = _carGroups - _carGroupsUAV;

		// systemchat str _heliGroupsUAV;
		

		for "_i" from 0 to 8 do {
			_refArray = [];
			_tvString = "";
			switch (_i) do {
				
				case (0) : {
					_refArray = _planeGroups;
					_tvString = "PLANES";
				};
				case (1) : {
					_refArray = _heliGroups;
					_tvString = "HELICOPTERS";
				};
				case (2) : {
					_refArray = _tankGroups;
					_tvString = "TANKS";
				};
				case (3) : {
					_refArray = _wheeledAPCgroups;
					_tvString = "APCS";
				};
				case (4) : {
					_refArray = _carGroups;
					_tvString = "CARS";
				};
				case (5) : {
					_refArray = _shipGroups;
					_tvString = "SHIPS";
				};
				case (6) : {
					_refArray = _staticGroups;
					_tvString = "STATIC WEAPONS";
				};
				case (7) : {
					_refArray = _infantryGroups;
					_tvString = "INFANTRY";
				};
				case (8) : {
					_refArray = _planeGroupsUAV + _heliGroupsUAV + _carGroupsUAV;
					// _refArray = 
					// [
					// 	_refArray,
					// 	[],
					// 	{
					// 		private _gp = _x;
					// 		_lv = vehicle leader _gp;
					// 		_armor = getNumber (configfile >> "CfgVehicles" >> typeOf _lv >> "armor");
					// 		_weaponCount = count weapons _lv;
					// 		_cargoFactor = if ({group _x != _gp} count crew _lv > 0) then {1000} else {0};
					// 		_val = _armor * _weaponCount * _cargoFactor;
					// 		_val
					// 	},
					// 	"DESCEND"
					// ] call BIS_fnc_sortBy;
					_tvString = "AUTONOMOUS";
				};
			};
			
			if (count _refArray > 0) then {
				//-- sort vehicles by power
				_refArray = 
				[
					_refArray,
					[],
					{
						private _gp = _x;
						_lv = vehicle leader _gp;
						_armor = getNumber (configfile >> "CfgVehicles" >> typeOf _lv >> "armor");
						_weaponCount = count weapons _lv;
						_cargoFactor = if ({group _x != _gp} count crew _lv > 0) then {1000} else {0};
						
						_val = _armor; // * _weaponCount * _cargoFactor;
						{
							if (_x > 0) then {
								_val = _val * _x;
							};
						} foreach [_weaponCount, _cargoFactor];
						_val = _val * (sizeOf (typeOf _lV));
						// systemchat str [typeOf _lv, _val];
						_val
					},
					"DESCEND"
				] call BIS_fnc_sortBy;
				//-- add Category and vehicles to tree
				_CT_TREE tvAdd [[_mainTreeIndex], _tvString];
				{
					private _gp = _x;
					private _fi = _foreachIndex;
					_CT_TREE tvAdd [[_mainTreeIndex,_subTreeIndex],toUpper ( groupID _gp)];
					_ct_indexArray = [_mainTreeIndex,_subTreeIndex,_fi];
					_lv = vehicle leader _gp;
					_cargoGroups = [];
					{
						_vic = vehicle _x;
						if (!isNull objectParent _x && {_x == driver _vic}) then {
							{
								if (!(_x in units _gp) && {_x == leader group _x}) then {
									_cargoGroups pushBackUnique (group _x);
								};
							} foreach crew _vic;
						};
					} foreach (units _gp);
					_CT_TREE tvSetPicture 
					[
						_ct_indexArray,
						if (_i == 7) then {"A3C_CORE\ui\pictures\icon_menu_Stance_Stand.paa"} else {gettext(configFile >> "CfgVehicles" >> typeOf _lv >> "picture")}
					];
					_CT_TREE tvSetValue 
					[
						_ct_indexArray,
						[_gp,A3C_UI_SHARED_TREE_HC_AT_TICK] call MCSS_fnc_getArrayIndex
					];
					_gp setVariable ["A3C_TREESEL_INDEX",[_ct_indexArray]];
					{
						_cargoGroup = _x;
						[_CT_TREE,"HC_CARGO", [_cargoGroup,_fi],_mainTreeIndex,_subTreeIndex] call A3C_UI_MAP_TREE_ADD_ITEM;
					} foreach _cargoGroups;

				} foreach _refArray;
				//systemchat str _subTreeIndex;
				_subTreeIndex = _subTreeIndex + 1;	
			};
		};
		_mainTreeIndex = _mainTreeIndex + 1;
	};
	

	private _openTrees = if (_a3c_dsp == IDD_MAP_OVERLAY) then {
		A3C_UI_MAP_TREES_OPEN
	} else {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RADIAL_TREES_OPEN_SQ
		} else {
			A3C_RADIAL_TREES_OPEN_HC
		}
	};


	if (count _openTrees > 0) then {
		[_ct_tree,_openTrees] spawn {
			params ["_ct_tree","_openTrees"];
			{
				_scr = [[_ct_tree,_x],"OPEN",if (_forEachIndex == 0) then {true} else {false} ,0] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;
				waitUntil {scriptDone _scr};
				//sleep 1;
			} foreach _openTrees;
		};
	} else {
		[[_ct_tree,[0]],"COLLAPSE",true,0] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;
	};
};



A3C_UI_MAP_TREES_OPEN = [];
A3C_RADIAL_TREES_OPEN_SQ = [[0]];
A3C_RADIAL_TREES_OPEN_HC = [[0]];

//-- animate tree collapse
A3C_UI_MAP_TREE_OPEN_COLLAPSE = {

	//-- exit if no dialog is active
	if ({!isNull findDisplay _x} count [IDD_MAP_OVERLAY, IDD_RADIAL_MENU] == 0) exitWith {};

	params ["_ctrlData","_mode","_isInit","_animTime"]; 
	//-- _mode == "OPEN" or "COLLAPSE"
	//-- _isInit == true (when initializing/refreshing tree) or false when toggled by player
	_ctrlData params ["_ctrl","_selectedParent"];
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	private _isMainParent = count _selectedParent == 1;

	private _openTrees = if (_a3c_dsp == IDD_RADIAL_MENU) then {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {A3C_RADIAL_TREES_OPEN_SQ} else {A3C_RADIAL_TREES_OPEN_HC}
	} else {
		A3C_UI_MAP_TREES_OPEN
	};

	playsound "ReadOutHideClick1";

	if (isNull _ctrl) then {_mode = "COLLAPSE"};
	
	private _mainEntryCount = _ctrl tvCount [];
	private _subEntryCount = (_ctrl tvCount _selectedParent);

	private _minCtrlH = if (_a3c_dsp != IDD_RADIAL_MENU) then {
		(A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H); 
	} else {
		(safeZoneY + safeZoneH) * 0.2
	};
	private _maxCtrlH = if (_a3c_dsp != IDD_RADIAL_MENU) then {

		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y - 
		A3C_MAP_GAMEUI_MENU_Y +//-
		A3C_MAP_GAMEUI_Upper_buttonH +
		A3C_MAP_GAMEUI_PADDING_Y	
	} else {
		(safeZoneY + safeZoneH) - ((A3C_GAMEUI_COMMANDBAR_H + A3C_MAP_GAMEUI_PADDING_Y )* 2.5)
	};

	private _treePos = (ctrlPosition _ctrl);
	_treePos params ["_currentX","_currentY","_currentW","_currentH"];



	private _ctrlPosCollapsed = if (_a3c_dsp != IDD_RADIAL_MENU) then {
		[
			A3C_MAP_OVERLAY_GAMEUI_TREEX,
			(safezoneH + safezoneY) - A3C_MAP_GAMEUI_PADDING_Y - _minCtrlH, 
			A3C_MAP_OVERLAY_GAMEUI_TREEW,
			_minCtrlH 
		]
	} else {
		[
			_currentX, //-- stays constant
			_currentY, //-- stays constant because only h is extended downwards
			_currentW, //-- stays constant
			_minCtrlH
		]
	};

	if (_mode == "OPEN") then {
		_ctrl tvExpand _selectedParent;
		_openTrees pushBackUnique _selectedParent;	
	} else {
		if (_isMainParent) then { //-- main parents close all their child parents along
			//_openTrees = _openTrees select {_x select 0 != _selectedParent select 0}; //-- remove all childTrees from open_array
			while { {_x select 0 == _selectedParent select 0} count  _openTrees > 0 } do { //-- again, complicated workaround because the copied array can not be redefined without losing connection
				{
					if (_x select 0 == _selectedParent select 0) exitWith {
						_openTrees deleteAt _foreachIndex;
					};
				} foreach _openTrees;	
			};	
		};

		{
			if (_x isEqualTo _selectedParent) exitWith { //-- no idea why it only works like this, adding to copied global array works with pushBack (as above) but not with +/- [_x]
				_openTrees deleteAt _foreachIndex;
			};
		} foreach _openTrees;

		_ctrl tvCollapse _selectedParent;
	};

	_shownEntryCount = _ctrl tvCount []; //-- start with main entries (these are always counted)
	{
		_tree = _x;
		if (count _tree > 1) then { //-- exclude main entries	
			_shownEntryCount = _shownEntryCount + 1; //-- count parent
		};
		_childCount = _ctrl tvCount _tree;
		for "_i" from 0 to (_childCount - 1) do {
			_subChild = _tree + [_i];
			if !(_subChild in _openTrees) then {
				_shownEntryCount = _shownEntryCount + 1;
			};
		};
	} foreach _openTrees;

	
	private _effectiveH = (A3C_MAP_OVERLAY_GAMEUI_TREEROWHEIGHT_MAIN) * _shownEntryCount; 
	_effectiveH = (_effectiveH min _maxCtrlH) max _minCtrlH; //-- FIX CLIPPINGjijiji
	//systemchat str [_shownEntryCount,_effectiveH];

	if (_a3c_dsp != IDD_RADIAL_MENU) then {
		A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y = (safeZoneY + safeZoneH) - A3C_MAP_GAMEUI_PADDING_Y - _effectiveH;


		_ctrl ctrlSetPosition
		[
			A3C_MAP_OVERLAY_GAMEUI_TREEX,
			A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y,
			_ctrlPosCollapsed select 2,
			_effectiveH
		];
		_ctrl ctrlCommit _animTime; 
		[_ctrl,_animTime] call A3C_UI_SHARED_TREE_ADJUST_TOP_ROW;
		
	} else {
		private _ctrlGroup = findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP;
		private _ctrlGroupPos = ctrlPosition _ctrlGroup;

		//-- to extend tree, extend the H value of Tree and Ctrlsgroup, then set y to (0.5 - ((realGroupH) * 0.5))

		_newPos = +(_ctrlPosCollapsed);
		_newPos set [3,_effectiveH];
		_ctrl ctrlSetPosition _newPos;
		_ctrl ctrlCommit _animTime; 

		_newCtrlH = _currentY + _effectiveH;
		_ctrlGroupPos set [1,0.5 - (_newCtrlH / 2)];
		_ctrlGroupPos set [3,_newCtrlH];
		{
			_ct = (findDisplay IDD_RADIAL_MENU displayCtrl _x);
			_ct ctrlSetPosition _ctrlGroupPos;
			_ct ctrlCommit _animTime; 
		} foreach [
			IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP,
			IDC_RADIAL_EXTENSIONLEFT_BG
		];
	};
};


A3C_UI_MAP_RESIZE_TEAMCOLORS_Y = {
	//-- this function matches the teamcolor bars to the height of the CT_TREE control depending on teamcolor presence (otherwise sets bars out of bounds)
	params ["_animTime"];

	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	private _display = findDisplay _a3c_dsp;
	if (isNull _display) exitWith {};

	//-- Hardcoded Values (from .hpp)
	//private _ctrlX = A3C_MAP_OVERLAY_GAMEUI_TREEX;
	private _ctrlH = 0.04 * safezoneH; //-- HARDCODED h value of first teamcolor box
	
	//-- adjust height for teamcolor controls
	private _ctrlY = if (_a3c_dsp == IDD_RADIAL_MENU) then {
		private _refFramePos = ctrlPosition (_display displayCtrl IDC_UI_SHARED_TEAMCOLOR_BG);
		_refFramePos select 1
	} else {
		A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y - _ctrlH - (A3C_MAP_GAMEUI_PADDING_Y / 2)
	};

	private _refUnits = (units player) - [player];
	private _teamColors = ["RED", "GREEN", "BLUE", "YELLOW", "MAIN", "ALL"];
	private _teamColorsAssigned = [];
	
	{
		private _assignedTeam = if (player == cameraOn) then {
			assignedTeam _x
		} else {
			_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
		};

		_teamColorsAssigned pushBackUnique _assignedTeam;
	} forEach _refUnits;

	private _teamColorCtrls = [_display, "shared_teamColorMacros"] call A3C_UI_SHARED_fnc_ctrlGroup;
	private _teamColor = "RED";
	
	for "_i" from 0 to ((count _teamColorCtrls) - 1) step 2 do {
		private _ctrlBar = _teamColorCtrls select _i;
		private _ctrlBtn = _teamColorCtrls select (_i + 1);
		private _ctrlPos = ctrlPosition _ctrlBar;
		
		private _showBool = false;

		if (_teamColor in _teamColorsAssigned || {_teamColor == "ALL" && {count _teamColorsAssigned > 1}}) then {
			_ctrlPos set [1, _ctrlY];
			_ctrlPos set [3, _ctrlH];

			_ctrlBar ctrlSetText "#(argb,8,8,3)color(1,1,1,0.8)";

			private _tCol = switch (_teamColor) do {
				case "RED": {[A3C_UI_COLOR_RED, 1] call A3C_UI_fnc_setOpacity};
				case "GREEN": {[0, 1, 0, 1]};
				case "BLUE": {[A3C_UI_COLOR_BLUE, 1] call A3C_UI_fnc_setOpacity};
				case "YELLOW": {[A3C_UI_COLOR_YELLOW, 1] call A3C_UI_fnc_setOpacity};
				case "MAIN": {[1, 1, 1, 1]};
				case "ALL": {[0.5, 0.2, 0.6, 1]};
			};

			_ctrlBar ctrlSetTextColor _tCol;
			_showBool = true;
		};

		{
			_x ctrlSetPosition _ctrlPos;
			_x ctrlCommit _animTime;
			_x ctrlShow _showBool;
		} forEach [_ctrlBar, _ctrlBtn];
		
		_teamColors = _teamColors - [_teamColor];

		if (count _teamColors > 0) then {
			_teamColor = _teamColors select 0;
		};
	};
};



//-- fnc to adjust Height of teamcolor and toprow-controls to tree-size
A3C_UI_SHARED_TREE_ADJUST_TOP_ROW = { //asasas
	params ["_ctrl","_animTime"];

	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};

	//-- not executed via radial - map only!
	 
	//-- Hardcoded Values (from .hpp)
	private _ctrlX = A3C_MAP_OVERLAY_GAMEUI_TREEX;
	private _ctrlH = 0.034 * safezoneH; //-- HARDCODED h value of first teamcolor box

	private _totalW = (ctrlPosition (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR)) select 2;
	//--adjust height for teamcolor controls
	[_animTime] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;
	_ctrlY = A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y - _ctrlH - (A3C_MAP_GAMEUI_PADDING_Y / 2); //0.85733 * safezoneH + safezoneY; //-- HARDCODED y value of first box
	//-- adjust teamcolor bg and frame
	{
		_btnCtrl = (findDisplay _a3c_dsp displayCtrl _x);
		_btnCtrl ctrlSetPosition
		[
			_ctrlX,
			A3C_MAP_OVERLAY_GAMEUI_TREEBOX_Y - _ctrlH - A3C_MAP_GAMEUI_PADDING_Y,
			_totalW,
			_ctrlH + A3C_MAP_GAMEUI_PADDING_Y

		];
		_btnCtrl ctrlCommit _animTime;
	} foreach [IDC_UI_SHARED_TEAMCOLOR_BG,IDC_SHARED_UI_TEAMCOLOR_FRAME]; 

	if (_a3c_dsp == IDD_RADIAL_MENU) exitWith {}; //-- radial menu does not have the same settings buttons and can exit UNNEXESSARY!!!
	
	//-- ADDITIONAL MAP SPECIFIC UI REACTIONS
	
	
	private _additionalbuttonCombos = 
	[
		[IDC_MAP_TOP_REFRESH_IMG,IDC_MAP_TOP_REFRESH_BTN],             //-- refresh button
		[IDC_MAP_TOP_DISBAND_IMG,IDC_MAP_TOP_DISBAND_BTN],             //-- disband button
		[IDC_MAP_TOP_TOGGLETRACKER_IMG,IDC_MAP_TOP_TOGGLETRACKER_BTN]  //-- tracker toggle
	];
	
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_TOP_REFRESH_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_refresh.paa"; 
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_TOP_DISBAND_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_hc_disband.paa";
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_TOP_TOGGLETRACKER_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_toggleForceTracker.paa"; 


	//-- adjust height and pos for settings controls
	_ctrlX = (A3C_MAP_OVERLAY_GAMEUI_TREEX + A3C_MAP_OVERLAY_GAMEUI_TREEW) - (3 * A3C_MAP_GAMEUI_Upper_buttonH); //--reset for left-falling top buttons
	_ctrlY = _ctrlY - A3C_MAP_GAMEUI_Upper_buttonH - (A3C_MAP_GAMEUI_PADDING_Y / 2);

	//-- adjust top button bg and frame
	
	{
		_btnCtrl = (findDisplay _a3c_dsp displayCtrl _x);
		_btnCtrl ctrlSetPosition
		[
			_ctrlX, 
			_ctrlY,
			(A3C_MAP_GAMEUI_Upper_buttonH * 4) * 0.75,
			A3C_MAP_GAMEUI_Upper_buttonH 

		];
		_btnCtrl ctrlCommit _animTime;
	} foreach [
		IDC_MAP_TOP_EXTRAS_BACKGROUND,
		IDC_MAP_TOP_EXTRAS_FRAME
	];

	{
		_xPos = _ctrlX + (A3C_MAP_GAMEUI_Upper_buttonH * _foreachIndex); //!!!! TEMP!
		{
			_btnCtrl = (findDisplay _a3c_dsp displayCtrl _x);
			_btnCtrl ctrlSetPosition
			[
				_xPos, 
				_ctrlY,
				A3C_MAP_GAMEUI_Upper_buttonH * 0.75,
				A3C_MAP_GAMEUI_Upper_buttonH 

			];
			//systemchat str _animTime;
			_btnCtrl ctrlCommit _animTime;
		} foreach _x;
	} foreach _additionalbuttonCombos;
	
};

A3C_TREE_TVCHANGE = {
	//if (A3C_CurSel) exitWith {};
	params ["_control","_tvSelTo"];

	_tvSelTo params ["_parentTo","_childTo"];
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
	private _shift = 42 in A3C_UI_DOWNKEYS;
	private _ctrl = 29 in A3C_UI_DOWNKEYS;
	
	if (count _tvSelTo == 1) exitWith {}; //-- click on main category - no application
	playsound "ReadOutHideClick1"; 
	_tvSelFrom = tvCurSel _control;
	_tvSelFrom params ["_parentFrom","_childFrom"];

	_isSquadLevel = _tvSelTo select 0 == 0;


	if (_a3c_dsp == IDD_RADIAL_MENU) then {
		_isSquadLevel = _isSquadLevel && {A3C_CURRENT_COMMAND_LEVEL == "SQUAD"};
	};


	
	_refArray = if (_isSquadLevel) then {(profileNamespace getvariable "A3C_GROUPUNITS") - [player]} else {A3C_UI_SHARED_TREE_HC_AT_TICK }; //~~ TO DO:: ADD HC!!!
	_valueFrom =  (_control tvValue _tvSelFrom);
	_valueTo =  (_control tvValue _tvSelTo);
	_startUnit = objNull;
	_endUnit = objNull;
	if (count _refArray > 0) then {		
		_endUnit = _refArray select ((_valueTo - 1) max 0);
		_startUnit = _endUnit;
		if (_tvSelFrom select 0 == _tvSelTo select 0) then {
			_startUnit = _refArray select ((_valueFrom - 1) max 0);
		} else {
			_tvSelFrom = _tvSelTo;
		};

	};
	
	//-- multiselection with shift works only downwards within the same main category

	///-- reset selection if group is not the same (prevent multiclick)
	private _abortModifierCondition = 
	(
		( _tvSelFrom select 0) != ( _tvSelTo select 0) OR 
		{		
			_isSquadLevel && 
			{
				//-- SQUAD ONLY check for modifier click between categories
				(_shift OR {_ctrl}) && 
				{
					(count _tvSelFrom) != (count _tvSelTo)
				}
			}
		}
	);


	if (_abortModifierCondition) then {
		//systemchat str "parent change";
		_control tvSetCurSel [-1];
		_control tvSetCurSel _tvSelTo;
		_tvSelFrom = _tvSelTo;
		A3C_SELECTED_UNITS = []; //-- reset arrays on pure left click
		A3C_SELECTED_HC_GROUPS_SETTINGS = [];

		//~~ NOTE: WHAT DO THE COMMENTS BELOW MEAN???
		//-- parent/category was changed. Due to the missing functionality of detecting shift/ctrl in the selChange-EH,
		// -- and the fact that ctrl works but shift does not, we need to prevent multiparent selections
	};

			
	_infModeTo = "HC"; //-- default
	//_mode = "COLLAPSE";
	if (_isSquadLevel) then {
		_refArray = (profileNamespace getvariable "A3C_GROUPUNITS") - [player]; //--~ currently squad level only
		_clickedFromSquad = _tvSelFrom select 0 == 0;
		_infModeFrom = "HC"; //-- default
		_infModeTo = if ((vehicle _endUnit) isKindOf "AIR") then {"AIR"} else {"INF"};
		_doSwitchPage = true;
		//systemchat str [_infModeTo,A3C_MAP_CommandMode,111111];
		if (_clickedFromSquad) then { //-- click from High Command to squad - start_tab
			if (_infModeTo == A3C_MAP_CommandMode) then {
				_doSwitchPage = false;
			};
			
		};
		//systemchat str [_infModeTo , A3C_MAP_CommandMode, _startUnit, _endUnit, typeof vehicle _endunit];
		if (_doSwitchPage) then {
			//systemchat str ['switch',_control];
			A3C_MAP_CommandMode = _infModeTo;
			A3C_SELECTED_UNITS = []; //-- reset arrays on pure left click
			A3C_RD_UNITS = [];
			A3C_SELECTED_HC_GROUPS_SETTINGS = [];
			_control tvSetCurSel [-1];
			_control tvSetCurSel _tvSelTo;
			[_infModeTo] call A3C_UI_MAP_UFSB_ApplyMode;
		};
	} else {
		_refArray = A3C_UI_SHARED_TREE_HC_AT_TICK; //-- copy the current HC array so we can address groups even if the hc-structure has changed while planning
		A3C_MAP_CommandMode = "HC";	
	};

	_buttonValues = [];
	if (_shift) then {
		
		_startIndex = _tvSelFrom select ((count _tvSelFrom) - 1);
		_endIndex = _tvSelTo select ((count _tvSelTo) - 1);
		//
		
		_step = if (_startIndex <= _endIndex) then {1} else {-1};
		
		for "_i" from _startIndex to _endIndex step _step do {
			_btn = (_tvSelFrom select  [0, count _tvSelFrom - 1]) + [_i];
			_btnV = (_control tvValue _btn);
			
			_buttonValues pushBackUnique _btnV;
			//systemchat str [_btnV];
		};
	} else {
		if (_ctrl) then {
			_buttonValues pushBackUnique _valueTo;
			
		} else {
			_buttonValues = [_valueTo];
			A3C_SELECTED_UNITS = []; //-- reset arrays on pure left click
			A3C_SELECTED_HC_GROUPS_SETTINGS = [];
			A3C_RD_UNITS = [];
			if (_isRadial && {_isSquadLevel}) then {
				{player groupSelectUnit [_x,false]} foreach units player;
			};
		}
	};

	//systemchat str [_refArray,_buttonValues]; //hcupd

	private _add = if (_isSquadLevel) then {1} else {0};
	{
		if ((_foreachIndex + _add) in _buttonValues) then {
			_doPushBack = true;
			
			if (_ctrl) then {
				if (_x in A3C_SELECTED_UNITS) then {
					_doPushBack = false;
					
					if !(_isSquadLevel) then {
						A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_HC_GROUPS_SETTINGS - [_x];
					};
					if (_isRadial) then {
						A3C_RD_UNITS = A3C_RD_UNITS - [_x];
						player groupSelectUnit [_x,false]
					} else {
						A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
					};
					_control tvSetCurSel [-1];
				};
			};
			if (_doPushBack) then {
				
				if !(_isSquadLevel) then {
					A3C_SELECTED_HC_GROUPS_SETTINGS pushBackUnique _x;
				};
				if (_isRadial) then {
					A3C_RD_UNITS pushBackUnique _x;
					player groupSelectUnit [_x,true];
				} else {
					A3C_SELECTED_UNITS pushBackUnique _x;
				};
			};
		};
	} foreach _refArray;		

	[] call A3C_UNITSEL_REFRESH_UI;
	
	
};




A3C_TREE_BOXCLICK = {
	
	params ["_displayCtrl","_mouseButton","_sX","_sY","_shift","_ctrl","_alt"];
	
	private _left = _mouseButton == 0;
	private _a3c_dsp = IDD_MAP_OVERLAY;

	if (!(_left) && {count A3C_SELECTED_UNITS > 0}) then {
		if (_shift && {A3C_MAP_CommandMode != "HC"}) then { //~~ TO DO: ALIGN TEAMCOLORS THROUGH COMMAND LEVELS AND ALLOW FOR HC TEAMCOLOR VIA LISTBOX
			//-- USER IS MANAGING SQUAD TEAMCOLORS VIA MAP-TREE
			lbClear (findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo);

			(findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo) ctrlShow true;
			ctrlsetfocus (finddisplay _a3c_dsp displayctrl IDC_MAP_DynamicCombo);
			A3C_LB_MODE = 3;
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo) ctrlSetPosition [_sx, _sy];
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo) ctrlCommit 0;

			[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, "RED"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, "GREEN"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, "BLUE"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, "YELLOW"] call A3C_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, "WHITE"] call A3C_addLbEntry;

			
			private _assignedTeam = if (player == cameraOn) then {assignedTeam (A3C_SELECTED_UNITS select 0)} else {(A3C_SELECTED_UNITS select 0) getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
			switch (_assignedTeam) do { //assignedTeam (_unitArray select _unitIndex)
				case ('RED') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, 0] call A3C_setCurSel;};
				case ('GREEN') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, 1] call A3C_setCurSel;};
				case ('BLUE') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, 2] call A3C_setCurSel;};
				case ('YELLOW') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, 3] call A3C_setCurSel;};
				case ('MAIN') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_DynamicCombo, 4] call A3C_setCurSel;};
			};
			
		} else {
			_unit = A3C_SELECTED_UNITS select 0;
			if (_shift) then {
				A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS select {typeName _x == "GROUP"};
				
				if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
					[A3C_SELECTED_HC_GROUPS_SETTINGS,1] call A3C_UI_MAP_FNC_HCGPContext_OpenMenu;
					//systemchat '1';
				} else {
					//A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
					//systemChat str [A3C_SELECTED_HC_GROUPS_SETTINGS select 0];
					if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
						[A3C_SELECTED_HC_GROUPS_SETTINGS select 0,0] call A3C_UI_MAP_FNC_HCGPContext_OpenMenu;
					};		
				};
			} else {
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
				_unitPos = if (typeName _unit == "GROUP") then {position leader _unit} else {position _unit};
				(findDisplay 12 displayCtrl 51) ctrlMapAnimAdd [0.1,(ctrlMapScale (findDisplay 12 displayCtrl 51)),_unitPos];
				ctrlMapAnimCommit (findDisplay 12 displayCtrl 51);
				[] spawn {
					sleep 0.2;
					(findDisplay 12 displayCtrl 51) ctrlEnable false;
				};
			};
		};
	};
};




A3C_UI_MAP_UnitTree_CtrlDelete = {
	params ["_CT_TREE","_button","_mode"];
	//systemchat str _this;
	private _refArray = [];
	private _buttonValue = _CT_TREE tvValue _button;
	private _buttonChildIndex = _button select ((count _button) -1);
	_CT_TREE tvDelete _button;
	switch (_mode) do {
		case ("SQUAD") : {
			_refArray = profileNamespace getvariable "A3C_GROUPUNITS";
		};
		case ("HIGHCOMMAND") : {
			_refArray = A3C_UI_SHARED_TREE_HC_AT_TICK;
		};
	};

	//-- reWrite unitVariable button references for reverse Tree selection (ie mapCLick-selecting changing UI display)
	if (_buttonValue != -1) then {
		private _buttonUnit = _refArray select _buttonValue;
		private _mainParent = _button select 0;
		private _parentButton = _button select [0, (count _button) -1];
		private _parentCount = _CT_TREE tvCount _parentButton;
		for "_i" from _buttonChildIndex to (_parentCount -1) do { //-- since _button was deleted, _buttonChildIndex is now the index of the initial following button
			private _childButton = _parentButton + [_i];
			private _childButtonsAll = [];
			private _childCount = _CT_TREE tvCount _childButton;

			if (_childCount > 0) then {
				for "_t" from 0 to _childCount do {
					_childButtonsAll pushBack (_childButton + [_t]);
				};
				{
					private _btn = _x;
					private _buttonValueSub = _CT_TREE tvValue _btn;
					if (_buttonValueSub != -1) then {
						_buttonUnitSub = _refArray select _buttonValueSub;
						private _btns = switch (_mode) do {
							case ("SQUAD") : {
								if (_buttonUnitSub == driver vehicle _buttonUnitSub) then { //-- two buttons for squad drivers
									[_childButton,_btn]
								} else {
									[_btn]
								};
							};
							case ("HIGHCOMMAND") : {
								[_btn]
							};
						};
						_buttonUnitSub setVariable ["A3C_TREESEL_INDEX",_btns];
					};
					
				} foreach _childButtonsAll;
			} else {
				private _buttonValueSub = _CT_TREE tvValue _childButton;
				if (count _refArray > _buttonValueSub) then {
					_buttonUnitSub = _refArray select _buttonValueSub;
					private _btns = [_childButton]; //if (_buttonUnitSub == driver vehicle _buttonUnitSub) then {[_childButton,_childButton]} else {[_childButton]};
					_buttonUnitSub setVariable ["A3C_TREESEL_INDEX",_btns];
				};
			};
		};
	};
};


A3C_UI_MAP_UnitTree_Sync = {

	// if (true) exitWith {};
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	private _modes = if (_a3c_dsp == IDD_RADIAL_MENU) then {if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {["SQUAD"]} else {["HIGHCOMMAND"]}} else {["SQUAD","HIGHCOMMAND"]};
	private _CT_TREE = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
	private _mainTreeIndex = 0;
	
	private _refArray = [];
	{
		private _mode = _x;
		_refArray = switch (_mode) do {
			case ("SQUAD") : {
				profileNamespace getvariable "A3C_GROUPUNITS";
			};
			case ("HIGHCOMMAND") : {
				A3C_UI_SHARED_TREE_HC_AT_TICK;
			};
		};
		//-- go through button values and delete the ones that return isNULL (we can not return data from nul-unit)
		_mainClassCount = _CT_TREE tvCount [_mainTreeIndex];
		//if (_mainClassCount > 0) then {
			for "_i" from 0 to (_mainClassCount - 1) do {
				_button = [_mainTreeIndex,_i];
				_buttonsAll = []; //-- we only take SUB buttons of drivers, not VEHICLE button
				_buttonSubCount = _CT_TREE tvCount _button;
				if (_buttonSubCount > 0) then { 
					for "_t" from 0 to (_buttonSubCount - 1) do {
						_buttonsAll pushBackUnique (_button + [_t]);
					};
				} else {
					_buttonsAll = [_button]; 
				};
				{
					_button = _x;
					_buttonValue = _CT_TREE tvValue _button;
					
					//systemchat str _buttonValue;
					if (_buttonValue != -1 && {count _refArray > _buttonValue}) then {
						_buttonUnit = _refArray select _buttonValue;
						if (_mode == "SQUAD") then {
							if (isNull _buttonUnit ) then { //OR { !alive _buttonUnit }
								[_CT_TREE,_button,"SQUAD"] call A3C_UI_MAP_UnitTree_CtrlDelete;
							} else {
								if (alive _buttonUnit) then {
									if (count _button > 2) then {
									
										//-- vehicle button -> check for dismount
										if (isNull objectParent _buttonUnit) then {
											//player sideChat str [_buttonValue,_buttonUnit];
											[_CT_TREE,_button,"SQUAD"] call A3C_UI_MAP_UnitTree_CtrlDelete;
											_ctrlParent = _button select [0,count _button -1];
											if (_CT_TREE tvCount _ctrlParent == 0) then {
												[_CT_TREE,_ctrlParent,"SQUAD"] call A3C_UI_MAP_UnitTree_CtrlDelete;
											};
											//_squadTreeCount = [_CT_TREE,_mainTreeIndex] call A3C_UI_MAP_TREE_getSubParentCount;
											[_CT_TREE,"SQUAD_INF", [_buttonUnit],_mainTreeIndex, _CT_TREE tvCount [_mainTreeIndex] ] call A3C_UI_MAP_TREE_ADD_ITEM;
										};
									} else {
										//-- infantry button -> check for boardings
										if (!isNull objectParent _buttonUnit) then {
											[_CT_TREE,_button,"SQUAD"] call A3C_UI_MAP_UnitTree_CtrlDelete;
											_vehicle = vehicle _buttonUnit;
											//-- crew present needs to be in referred array and needs to have a crew-button assigned to it
											_crewPresent = 
											(
												(crew _vehicle) select 
												{
													_include = false;
													if (_x in (_refArray - [player])) then {
														_refButton =  _x getVariable ["A3C_TREESEL_INDEX",[]];
														if ((count _refButton) > 0) then {
															_refButton = _refButton select ((count _refButton) - 1); //-- make sure we catch the vehicle's sub button
															if ((count _refButton) > 1) then {
																_include = true;
															};
														};
													};
													_include
												}
											) - [_buttonUnit];
											
											
											if (count _crewPresent > 0) then {
												_refButtonData = (_crewPresent select 0) getVariable ["A3C_TREESEL_INDEX",[]];
												//player sideChat str ( _refButtonData);
												if (count _refButtonData > 0) then {
													//-- vehicle already shown in UI
													//~~ this bit does not work because the button indexi structure changes when deleting and adding buttons
													_refButtonData = _refButtonData select ((count _refButtonData) - 1); //-- make sure we catch the vehicle's sub button
													[
														_CT_TREE,
														"SQUAD_CREW",
														[_buttonUnit],
														_mainTreeIndex,
														_refButtonData select 1
													] call A3C_UI_MAP_TREE_ADD_ITEM;
												};										
											} else {
												[
													_CT_TREE,
													"SQUAD_VEH", 
													[
														_vehicle,
														(crew _vehicle) select { _x in ( _refArray - [player] ) } 
													],
													_mainTreeIndex,
													_CT_TREE tvCount [_mainTreeIndex]
												] call A3C_UI_MAP_TREE_ADD_ITEM;
											};
											
										};
									};
								};
							};
							
						} else {
							if (isNull _buttonUnit OR { {alive _x} count units _buttonUnit == 0}) then {
								// systemchat "delete";
								[_CT_TREE,_button,"HIGHCOMMAND"] call A3C_UI_MAP_UnitTree_CtrlDelete;
							};
						};
						
					};	
				} foreach _buttonsAll;	
			};
			//-- check for newly joined units
			switch (_mode) do {
				case ("SQUAD") : {
					private _reInforcementsWIP = (_refArray - [player]) select {_treeButtonVar = _x getVariable ["A3C_TREESEL_INDEX",[]]; count _treeButtonVar == 0};
					private _reinforcementVics = [];
					{
						_vic = vehicle _x;
						if (!isNull objectParent _x && {!(_vic in _reinforcementVics)}) then {
							_reinforcementVics pushBack _vic;
							_reInforcementsWIP = _reInforcementsWIP - (crew _vic); //-- take driver and other groupunits from crew out of _reinForcementsWIP (only inf now)
						};
					} foreach _reInforcementsWIP;
					//systemchat str _reInforcementsWIP;
					{
						[_CT_TREE,"SQUAD_INF", [_x],_mainTreeIndex, _CT_TREE tvCount [_mainTreeIndex] ] call A3C_UI_MAP_TREE_ADD_ITEM;
					} forEach _reInforcementsWIP;
					{
						_vehicle = _x;
						[
							_CT_TREE,
							"SQUAD_VEH", 
							[
								_vehicle,
								(crew _vehicle) select { _x in ( _refArray - [player] ) } 
							],
							_mainTreeIndex,
							_CT_TREE tvCount [_mainTreeIndex]
						] call A3C_UI_MAP_TREE_ADD_ITEM;
					} forEach _reinforcementVics;
				};
				case ("HIGHCOMMAND") : {
					//-- _reInforcementsWIP: groups that have no button yet
					private _reInforcementsWIP = (A3C_HC_allGroupsClient_Current ) select {_treeButtonVar = _x getVariable ["A3C_TREESEL_INDEX",[]]; count _treeButtonVar == 0}; //- _refArray
					
					
					{
						private _gp = _x;
						private _refLeader = leader _gp;
						private _refLeadVic = vehicle _refLeader;
						private _treeButton = _gp getVariable ["A3C_TREESEL_INDEX",[]];
						if (count _treeButton > 0) then {
							_treeButton = _treeButton select 0;
							private _classParentIndex = _treeButton select 1;
							private _unitIndex = _treeButton select 2;
							private _classText = _CT_TREE tvText [_mainTreeIndex,_classParentIndex];
							private _kindOfString = switch (_classText) do {
								case ("AUTONOMOUS") : {"UAV"};
								case ("HELICOPTERS") : {"HELICOPTER"};
								case ("TANKS") : {"TANK"};
								case ("APCS") : {"wheeled_apc_f"};
								case ("CARS") : {"CAR"};
								case ("SHIPS") : {"SHIP"};
								case ("STATIC WEAPONS") : {"STATICWEAPON"};
								case ("INFANTRY") : {"MAN"};
								default {""};
							};
							_changeCondition = ({(vehicle _x) isKindOf "STATICWEAPON"} count (units _gp) > 0 && {_kindOfString != "STATICWEAPON"}) OR 
							{
								!(_refLeadVic isKindOf _kindOfString)
							};
							if (_kindOfString == "UAV") then {
								// systemchat str (groupID _gp);
								// systemchat str ({unitIsUAV (vehicle _x)} count (units _gp));
								_changeCondition = {unitIsUAV (vehicle _x)} count (units _gp) == 0;
							};

							// _changeCondition = _changeCondition || {_kindOfString == "UAV" && {{unitIsUAV _x} count (units _gp) == 0}};
							if (_changeCondition && _kindOfString != "") then {
								// systemchat str [_changeCondition, _kindOfString];
								//-- leadervehicle has changed. remove unit and add to _reinforcements for new group assignment
								private _parent = _treeButton select [0, (count _treeButton) -1];
								[_CT_TREE,_treeButton,"HIGHCOMMAND"] call A3C_UI_MAP_UnitTree_CtrlDelete;
								if (_CT_TREE tvCount _parent == 0) then {
									_CT_TREE tvDelete _parent;
								};
								// remove main class if no more units inside
								_reInforcementsWIP = [_gp] + _reInforcementsWIP;
							};
						};
					} foreach A3C_UI_SHARED_TREE_HC_AT_TICK;
					//player commandChat str _reInforcementsWIP;
					//-- _reInforcementsWIP is now both new groups and those who have hade a change of leader-vehicle
					//-- check for new HC groups and change boarded / dismounted groups
					_subTreeIndex = _CT_TREE tvCount [_mainTreeIndex];

					

					{
						_leader = leader _x;
						if (!isNil '_leader') then {
							_lV = vehicle _leader;

							_isCargo = !(driver _lV in (units _x)) &&
							{
								{(vehicle _x) isKindOf "STATICWEAPON"} count (units _x) == 0
							};

							private _mainEntryCount = _CT_TREE tvCount [];
							if (_mainEntryCount == 1 && {_a3c_dsp != IDD_RADIAL_MENU}) then {
								_CT_TREE tvAdd [[], "HIGH COMMAND"];
							};
							_tvText = switch (true) do {
								case (unitIsUAV _lV) : {"AUTONOMOUS"};
								case (_lV isKindOf "PLANE") : {"PLANES"};
								case (_lV isKindOf "HELICOPTER") : {"HELICOPTERS"};
								case (_lV isKindOf "TANK") : {"TANKS"};
								case (_lV isKindOf "wheeled_apc_f") : {"APCS"};
								case (_lV isKindOf "CAR" && {!(_lV isKindOf "wheeled_apc_f")}) : {"CARS"};
								case (_lV isKindOf "SHIP") : {"SHIPS"};
								case (_lV isKindOf "STATICWEAPON" OR {_lV isKindOf "MAN" && {{(vehicle _x) isKindOf "STATICWEAPON"} count (units _x) > 0}}) : {"STATIC WEAPONS"};
								case (_lV isKindOf "MAN") : {"INFANTRY"};
								default {"UNKNOWN CLASS"};
							};
							_doAddClass = true;
							_subTreeIndex = _CT_TREE tvCount [_mainTreeIndex];
							for "_i" from 0 to (_subTreeIndex - 1) do {
								_tvtSub = _CT_TREE tvText [_mainTreeIndex,_i];
								if (!isNil '_tvtSub' && {!isNil '_tvText' && { typeName _tvtSub == "STRING" && {_tvtSub == _tvText}}}) then {
									// systemchat 'yeppo';
									_doAddClass = false;
									_subTreeIndex = _i;
								};
							};
							
							if (_doAddClass) then {
								_CT_TREE tvAdd [[_mainTreeIndex], _tvText];
								//systemchat str [[_mainTreeIndex], _tvText];
							};
							//aiaiai
							A3C_UI_SHARED_TREE_HC_AT_TICK pushBackUnique _x;
							if (_isCargo) then {
								_host = group driver _lV;
								_hostButton = _host getVariable ["A3C_TREESEL_INDEX",[]];
								//systemchat "cargo detected";
								if (count _hostButton > 0) then {
									_hostButton = _hostButton select ((count _hostButton) - 1);
									[_CT_TREE,"HC_CARGO", [_x,_hostButton select 2],_hostButton select 0, _hostButton select 1] call A3C_UI_MAP_TREE_ADD_ITEM;
								};
								
							} else {
								
								//systemchat str [[_mainTreeIndex,_subTreeIndex],toUpper ( groupID _x)];
								_entryIndex = _CT_TREE tvCount [_mainTreeIndex,_subTreeIndex];
								_CT_TREE tvAdd [[_mainTreeIndex,_subTreeIndex],toUpper ( groupID _x)];
								_ct_indexArray = [_mainTreeIndex,_subTreeIndex,_entryIndex];
								_lv = vehicle leader _x;
								_CT_TREE tvSetPicture 
								[
									_ct_indexArray,
									if (_tvText == "INFANTRY") then {"A3C_CORE\ui\pictures\icon_menu_Stance_Stand.paa"} else {gettext(configFile >> "CfgVehicles" >> typeOf _lv >> "picture")}
								];
								_CT_TREE tvSetValue 
								[
									_ct_indexArray,
									[_x,A3C_UI_SHARED_TREE_HC_AT_TICK] call MCSS_fnc_getArrayIndex
								];
								_x setVariable ["A3C_TREESEL_INDEX",[_ct_indexArray]];
								//systemchat str [_ct_indexArray]; //hcupd
							};
						};
						
						
					} foreach _reInforcementsWIP;
				};
			};		
		//};
		_mainTreeIndex = _mainTreeIndex + 1;
	} foreach _modes;
};

A3C_UI_MAP_TREE_REFRESH_BUTTONVALUES = { //~~ WIP
	params ["_CT_TREE"];
	private _modes = if (_a3c_dsp == IDD_RADIAL_MENU) then {if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {["SQUAD"]} else {["HIGHCOMMAND"]}} else {["SQUAD","HIGHCOMMAND"]};
	private _mainTreeIndex = 0;
	private _refArray = [];
	if ("SQUAD" in _modes) then {
		_refArray = profileNamespace getvariable "A3C_GROUPUNITS";
		private _tvMainCount = _CT_TREE tvCount [_mainTreeIndex];

		_mainTreeIndex = _mainTreeIndex + 1;
	};
};