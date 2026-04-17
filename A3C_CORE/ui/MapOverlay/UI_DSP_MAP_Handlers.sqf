A3C_UI_MAP_onOnMouseButtonDown_Overlay = {

	/*
	Let's overwork this entire handler shall we.
	Best shot right now:
	1. Pick up all icons (and/or markers)
	2. Seperate execution through right and leftclick
	*/
	params ["_displayCtrl","_mouseButton","_sX","_sY","_shift","_ctrl","_alt"];
	private ["_mouseOverIcon","_groupControls","_isHCMark"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	disableserialization;

	A3C_BOOL_MAP_MD = true; 

	private _exit = false;

	private _left = _mouseButton == 0; // << #TODO this sux, remove lol


	if (a3c_is_HC_remote && {!(_left)}) exitWith  {
		_this call A3C_UI_SHARED_OnMouseButtonDown_remoteVehicle;
		false //-- potentially not needed. WIP stage, this entire mouseDown EH needs serious overhaul
	};

	//------------------------- EXIT CONDITIONS (MAPCLICK NOT ALLOWED)
	
	if (isNull findDisplay _a3c_dsp) exitWith {};
	if (A3C_MAP_BOOL_CT_EDIT_ACTIVE) exitWith {};
	if (A3C_UI_MAP_isCircleMenu) exitWith {
		if !(_left) then {
			[_a3c_dsp,-1] call A3C_UI_MAP_FNC_CloseSyncCircleMenu;
		};
	};
	
	//-- contextMenues are open
	if ({ctrlShown (findDisplay _a3c_dsp displayCtrl _x)} count [A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT] > 0) exitwith {};
	private _ctls = if (visibleMap) then {[A3C_SHARED_GAMEUI_TREE_CONTROL,7077,7071,709099,8008]} else {[]};
	//-- exit if mouseclick was within certain controls
	if ({[[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctls > 0) exitWith {};

	

	//-- ENEMY-TARGET Combo is open - ALWAYS disables mapclick, hides Combo if it's not clicked on directly
	if (ctrlShown (findDisplay _a3c_dsp displayCtrl 7078)) exitWith {
		if !([[_sX,_sY],findDisplay _a3c_dsp displayCtrl 7078] call MCSS_fnc_isClickPosInCTRLArea) then {
			((findDisplay _a3c_dsp) displayCtrl 7078) ctrlShow false;
		};
	};

	//-----------------------------------------------------------------------------------
	
	
	
	
	
	private _unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
	private _map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
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


	//-- Artillery Shortcut 
	private _artilleryShortcutCondition = (count A3C_SELECTED_UNITS > 0 && {
		_ctrl && {
			_alt && {
				{ 
					!([_x] call A3C_GroupHasArtilleryCapacity) &&
					{
						typeName _x != "GROUP"
					}
				} count A3C_SELECTED_UNITS == 0
			}
		}
	});
	if (_artilleryShortcutCondition) exitWith {
		A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
		playsound "TacticalPing4";
		A3C_HC_FOCUS_ARTY_POS = A3C_CLICKPOS_1;
		["ARTY"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
	};





	if (A3C_HC_DETONATION_BOOL) exitWith {
		private _demoIcons = (["DEMO",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
		private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
		_vhIcons = (["HC_VB",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
			player groupChat format ["Fire-Support, this is %1, firemission is no longer needed.", groupID (group player)];
			["A3C_ARTY_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
		};
	};
	

	

	if (A3C_MAP_CommandMode in ["INF","AIR"]) then {
		["SPACING","OFF"] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE;
	};

	//-- detect click on HC-GROUP WAYPOINT ICON
	if !(_isHighCommand) then {
		_wp_Icons = (["HC_WP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
		if (count _wp_Icons > 0) then {
			_wp_Icon = _wp_Icons select 0;
			_gp = _wp_Icon select 0;
			_wp_Index = _wp_Icon select 3;
			_exit = true; //~~ sure?
			if (_left) then {
				if (_alt) then {
					//-- HC waypoint sync
					A3C_CONNECTING_MODE = "HCSYNC";
					A3C_BOOL_DRAGLINE = true;
					A3C_HC_VEHICLEBOARD_GROUPS = [_gp];
					A3C_CLICKPOS_ORIG =  A3C_CLICKPOS_1;
					A3C_BOOL_MOUSEMOVING = true;
					A3C_HC_WP_SYNC_ROOT = [_gp,_wp_Index];
					A3C_MMCode = {
						_this spawn {
							params ["_clickData","_sX","_sY"];
							_a3c_dsp = if (visibleMap) then {100020} else {100030};
							if (isNull findDisplay _a3c_dsp) exitWith {};
							_map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};
							A3C_DRAGPOS = (_map1 posscreentoworld [_sx,_sy]);
						};
					};
				} else {
					if ([_gp,_wp_Index] in A3C_BLACKLIST_WAYPOINT_EDIT) then {
						systemchat  "A3C: It is too late to move this waypoint - wait for completion";
					} else {
						
						if (_ctrl) then {
							private _wp = [_gp, _wp_Index];
							if (_wp in A3C_Selection_MultiWaypoint) then {
								A3C_Selection_MultiWaypoint = A3C_Selection_MultiWaypoint - [_wp];
							} else {
								A3C_Selection_MultiWaypoint set [count A3C_Selection_MultiWaypoint, _wp];
							};
						} else {
							//-- waypoint marker about to be moved
							A3C_BOOL_MAP_MU = true;
							A3C_BOOL_MOUSEMOVING = true;
							A3C_HC_TOSWITCH = [_gp,_wp_Index];
							A3C_HC_ACTIVEGROUP = _gp;
							A3C_HC_ACTIVE_IND = _wp_Index;
							A3C_UI_MAP_BOOL_isHCWaypointPosEdit = true;
							if (["PlantExplosive_HC",(waypointStatements [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND]) select 1 ] call BIS_fnc_instring) then {
								A3C_HC_DETONATION_BOOL = true;
							};
							
							A3C_MMCode = {
								[A3C_HC_TOSWITCH,_this] spawn A3C_UI_MAP_onMouseDrag_HCWP;
							};
						};
							
						
						
					};
				};

				_exit = true;

			} else {
				_exit = true;
				_wp_Icon = _wp_Icons select 0;
				_gp = _wp_Icon select 0;
				_wp_Index = _wp_Icon select 3;
				[_gp,_wp_Index,A3C_HC_EDIT_ACTION,_a3c_dsp,[_sx, _sy]] call A3C_UI_MAP_FNC_HCWPContext_OpenMenu;
				_resetSelection = false;
			};

		} else {
			A3C_Selection_MultiWaypoint = [];
		};
	};

	if (_exit) exitWith {};

	
	_gpIcons = (["HC_GP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
	(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
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
				A3C_MAP_CommandMode = "HC";
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
				
				//~~
				//-- #TODO: #HuiHui -- streamline this duplicate code for visualizing selection change in tree-UI
				private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
				_CT_TREE tvSetCurSel [-1];

				
				if (count A3C_SELECTED_UNITS == 1) then { //--
					_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
					if (count _button > 0) then {
						_button = _button select 0;
						_buttonParent = _button select [0,count _button -1];
						if ([_button select 0] in A3C_UI_MAP_TREES_OPEN) then {
							_CT_TREE tvSetCurSel _button;
							[
								[
									findDisplay 100020 displayCtrl 202020,
									_button select [0,(count _button) - 1]
								],
								"OPEN",
								false,
								0.1
							] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE
						};
					};	
				};
				//~~

				//playsound 'A3C_MenuSound1';
				if (A3C_UI_MAP_Overlay_VAR_isUnFolded) then {
					//systemchat 'ay';
					["COLLAPSE",0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
				};
				//["HC"] call A3C_START_TABMODE;

				if (!isPlayer leader _gp) then {
					if ( (count A3C_SELECTED_UNITS == 0) OR (A3C_SQ_CLICKED_UNIT in A3C_SELECTED_UNITS) ) then {
						A3C_MAP_DRAGPLANNING_ACTIVE = true;
						A3C_BOOL_MOUSEMOVING = true;
						A3C_MMCode = {
							_this spawn A3C_UI_MAP_onMouseDrag;
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
					//(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow true;
					// if ({private _ld = leader _x; isPlayer _ld} count A3C_SELECTED_UNITS == 0) then {
						(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlSetPosition ([_a3c_dsp,A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,[_sx, _sy]] call A3C_DSP_FindControlSafePos);
						(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlCommit 0;
					// } else {
						// hint "A3C: "; //-- not needed, should already be executed in actions
					// };

					
					
					//A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
					//[_gp,0] call A3C_UI_MAP_FNC_HCGPContext_OpenMenu;
					A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
					if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
						A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
						[A3C_SELECTED_HC_GROUPS_SETTINGS,1] call A3C_UI_MAP_FNC_HCGPContext_OpenMenu;
					} else {
						A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
						[_gp,0] call A3C_UI_MAP_FNC_HCGPContext_OpenMenu;
					};				
				//};
			};
			
		};
	};
	
	
	

	//-- detect click on PLAYER SQUAD UNIT ICONS
	_sqIcons = (["SQUAD",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
	if (count _sqIcons > 0) exitWith {
		_sqIcon = _sqIcons select 0;
		A3C_SQ_CLICKED_UNIT = _sqIcon select 0;
		if (_left) then {
			if (_ctrl && _shift) then {
				_cargoObjects = ([vehicle A3C_SQ_CLICKED_UNIT] call MCSS_fnc_getNearCargoLoadObjects);
				if ( ((getPosATL (vehicle A3C_SQ_CLICKED_UNIT)) select 2) < 1) then {
					if ((count _cargoObjects > 0) && (A3C_SQ_CLICKED_UNIT == driver (vehicle A3C_SQ_CLICKED_UNIT))) then {
						_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
						_text = findDisplay _a3c_dsp displayCtrl 800802;
						_listBox = findDisplay _a3c_dsp displayCtrl 800803;
						//(findDisplay 100020 displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
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

					private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
					_CT_TREE tvSetCurSel [-1];

					if (count A3C_SELECTED_UNITS == 1) then {
						_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
						if (count _button > 0) then {
							_button = _button select 0;
							_buttonParent = _button select [0,count _button -1];
							if ([_button select 0] in A3C_UI_MAP_TREES_OPEN) then {
								//systemchat str _button;
								_CT_TREE tvSetCurSel _button;
								[
									[
										findDisplay 100020 displayCtrl 202020,
										_button select [0,(count _button) - 1]
									],
									"OPEN",
									false,
									0.1
								] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE
							};
						};
						//if ( ((A3C_SELECTED_UNITS select 0) == A3C_SQ_CLICKED_UNIT) && (A3C_MAP_CommandMode == "INF") ) then {
						if (count A3C_SELECTED_UNITS > 0) then {
							A3C_MAP_DRAGPLANNING_ACTIVE = true;
							A3C_BOOL_MOUSEMOVING = true;
							A3C_MMCode = {
								_this spawn A3C_UI_MAP_onMouseDrag;
							};
						};
						_exit = true; //~~?	
					};
					
					//-- toggle or collapse wpsettings bar
					_foldMode = if (count A3C_SELECTED_UNITS > 0) then {"OPEN"} else {"COLLAPSE"};
					[_foldMode,0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
					//A3C_SELECTED_UNITS = [A3C_SQ_CLICKED_UNIT];
					if (vehicle A3C_SQ_CLICKED_UNIT isKindOf "AIR") then {
						A3C_MAP_CommandMode = "AIR";
						["AIR"] call A3C_START_TABMODE;
					} else {
						A3C_MAP_CommandMode = "INF";
						["INF"] call A3C_START_TABMODE;
					};
				};
			};			
		};
	};

	//-- detect click on FORCE TRACKER ICON
	_trIcons = (["TRACKER",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
	private _mapPolygons =(["POLY_MAIN",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
	if (count _mapPolygons > 0 && {_left}) exitWith {

		private _mapPolygon = _mapPolygons select 0;

		private _polyID = (_mapPolygon select 0);
		A3C_MovedItem_ID = _polyID; //= "";
		if ({((_x select 0) select 1) == _polyID} count A3C_ALL_POLYS > 0) then {
			A3C_BOOL_MAP_MU = true;
			A3C_BOOL_MOUSEMOVING = true;
			A3C_BOOL_MOVINGMARKER = true;
			A3C_DRAGPOS = [_sx, _sy];
			{
				private _polyRefID = (_x select 0) select 1;
				if (_polyID == _polyRefID) exitWith {
					//systemchat str _polyRefID;
					A3C_CUR_EDIT_POLY = ([(_x select 0) select 0,0,"",false] call A3C_SUP_CREATE_POLY) select 0; //~~ poly: what is going on here: since create_poly does not create markers, it is used to find // 0 is replacing (markerDir A3C_MovedItem_ID)
					A3C_MMCode = if (_ctrl) then {
						{[_this,A3C_MovedItem_ID,"WP",true,false] spawn A3C_UI_MAP_onMouseDrag_MapItem;}
					} else {
						if (_alt) then {

							{[_this,A3C_MovedItem_ID,"WP",false,true] spawn A3C_UI_MAP_onMouseDrag_MapItem;}
						} else {
							{[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_UI_MAP_onMouseDrag_MapItem;}
						};
					};


				};
			} foreach A3C_ALL_POLYS;

		};
		_exit = true;
	};

	//-- detect click on UI POLYGON EDGE MARKERS
	private _mapPolygonEdges = (["POLY_EDGE",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
				A3C_BOOL_MAP_MU = true;
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
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
	if (count _squadWaypoints > 0) exitWith {
		private _squadWaypointSelected = _squadWaypoints select 0;
		_squadWaypointSelected params ["_unit","_size","_position","_wpDotIDS"];
		if (_left) then {
			A3C_MovedItem_ID = if (_wpDotIDS select 1 == "" ) then {_wpDotIDS select 0} else {_wpDotIDS select 1};
			if !(_alt) then {
				A3C_BOOL_MAP_MU = true;
				A3C_BOOL_MOUSEMOVING = true;
				A3C_BOOL_MOVINGMARKER = true;
				A3C_DRAGPOS = [_sx, _sy];
				A3C_MMCode = {[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_UI_MAP_onMouseDrag_MapItem;};
			} else {
				[_sx,_sy] call A3C_UI_MAP_onMouseButtonDown_Loop;
			};
		} else {
			[_wpDotIDS select 0,[_sX,_sY]] call A3C_UI_MAP_FNC_SQContext_OpenMenu;
		};
	};

	//-- detect click on PLAYER SQUAD UNIT WAYPOINT LOOKDIR ICON
	private _squadWaypointLookDirs = (["SQ_WP_LOOKDIR",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
	if (count _squadWaypointLookDirs > 0) exitWith {
		A3C_DIR_POS = (_map1 posscreentoworld [_sx,_sy]);
		private _squadWaypointLookDirSelected = _squadWaypointLookDirs select 0;
		_squadWaypointLookDirSelected params ["_unit","_size","_area","_markerID"];
		A3C_MovedItem_ID = _squadWaypointLookDirSelected;
		A3C_BOOL_MAP_MU = true;
		A3C_BOOL_MOUSEMOVING = true;
		A3C_BOOL_MOVINGMARKER = true;
		A3C_DRAGPOS = [_sx, _sy];
		A3C_MMCode = {[_this,A3C_MovedItem_ID,"LDIR",false,false] spawn A3C_UI_MAP_onMouseDrag_MapItem;};
	};





	if (_exit) exitWith {};


	



	//-- mapclick is within overlay area >> exit
	if (_a3c_dsp == _a3c_dsp && {[[_sX,_sY],findDisplay _a3c_dsp displayCtrl 11] call MCSS_fnc_isClickPosInCTRLArea}) exitWith {};




	if (_left) then {
		if ( {ctrlShown ((findDisplay _a3c_dsp) displayCtrl _x)} count [7078,A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT] > 0) then  { ////~~~~ ?????
			_exit = true;
		};
	};

	//-- hide other contextmenu's
	_ctls = if (visibleMap) then {[A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT,A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT,709135,A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT]} else {[A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT,709112,709135,A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT]};
	{
		if !([[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea) then {
			((findDisplay _a3c_dsp) displayCtrl _x) ctrlShow false;
		};
	} foreach _ctls;

	if (_exit) exitwith {};

	if (visibleMap) then {
		if !(isnull (findDisplay 100020 displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT)) then {
			if ([_a3c_dsp] call A3C_InMapControls) then {
				_exit = true;
			};
		};
	};

	if (_exit) exitWith {};

	//-- right Mouse Button
	if !(_left) exitwith {
		private _resetSelection = true;
		((findDisplay _a3c_dsp) displayCtrl A3C_MAP_OVERLAY_GAMEUI_SQ_WP_MENU_CTRLPARENT) ctrlShow false;


		if (_resetSelection) then {
			if (_ctrl) then {
				A3C_SELECTED_UNITS = [];
				A3C_SELECTED_HC_GROUPS_SETTINGS = [];
				["COLLAPSE",0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
				[A3C_MAP_CommandMode] call A3C_START_TABMODE;
			};
		};
	};


	if (_exit) exitwith {};

	// //-- LeftClick on A3-HC marker //~~??
	// if (_isHighCommand) then {
	// 	if (A3C_MAP_CommandMode == "HC") then {
	// 		if (count (["HC_WP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos) > 0) then {
	// 			systemchat "ALERT! PLEASE REPORT IF YOU SEE THIS ERROR: MAP_LEFTDOWN_OLD_HC";
	// 			A3C_BOOL_MAP_MU = true;
	// 			A3C_BOOL_MOUSEMOVING = true;
	// 			A3C_BOOL_MOVINGHC = true;
	// 			A3C_MMCode = {
	// 				[A3C_HC_TOSWITCH,_this] spawn A3C_UI_MAP_onMouseDrag_HCWP
	// 			};
	// 			_exit = true;
	// 		};
	// 	};
	// };






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
	if (A3C_MAP_CommandMode == "HC" && !(_ctrl)) exitWith {
		if ((count A3C_SELECTED_UNITS) > 0) then {
			if !(ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT)) then {
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
					} foreach A3C_SELECTED_UNITS;
					publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';
					
				};
				private _formDir = A3C_CLICKPOS_1 getDir (position (leader (A3C_SELECTED_UNITS select 0)));
				private _factor = 1;

				private _clickPos = +A3C_CLICKPOS_1;

				A3C_MULTIWAYPOINT = true;
				if (count A3C_SELECTED_UNITS > 2) then {
					A3C_MULTIWAYPOINT = false;
					["MULTIWAYPOINT"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
					waituntil {!ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT)};
				};

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
				A3C_BOOL_MAP_MU = true;
			};
		};
	};

	if (_ctrl) exitWith {
		[_sx,_sy] call A3C_UI_MAP_onMouseButtonDown_Loop;
	};



	//-- Current Mode is Non - HC

	A3C_CLICKPOS_ORIG = A3C_CLICKPOS_1;
	A3C_TAB_BUILDING = (nearestBuilding A3C_CLICKPOS_1);

	if (A3C_MAP_CommandMode == "INF") then {
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



	A3C_BOOL_MAP_MU = true;
	if (A3C_TAB_TOGGLE_VAR == 0) then {
		(findDisplay _a3c_dsp displayCtrl 7041) ctrlShow true;
		(findDisplay _a3c_dsp displayCtrl 7092) ctrlSetTextColor  [1,1,1,1];
	};



	//-- Create Dummy to have target for Direction-Arrow.
	if !(A3C_BOOL_DRAGLINE) then {
		A3C_BOOL_DRAGLINE = true;   
	};



	A3C_MovedItem_ID = "";


	A3C_BOOL_MOUSEMOVING = true;
	if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION","SLINGLOAD","CTRL_DET","STATIC"]) then { //~~ REMOVE GRENADE FROM THIS??   "GRENADE",
		A3C_CONNECTING_MODE = "LOOKDIR";
		A3C_MMCode = {
			_this spawn A3C_UI_MAP_onMouseDrag;
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
		A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout)));
	};





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
						_this spawn A3C_UI_MAP_onMouseDrag;
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
				_this spawn A3C_UI_MAP_onMouseDrag;
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
					_this spawn A3C_UI_MAP_onMouseDrag;
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
							_this spawn A3C_UI_MAP_onMouseDrag;
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
		A3C_BOOL_MAP_MU = false;
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


A3C_UI_MAP_onOnMouseButtonUp_Overlay = {
	
	
	
	private ["_exit","_sX","_sY","_sPos","_marker","_veh","_unit","_wpData"];

	A3C_BOOL_MAP_MD = false;
	A3C_BOOL_MOUSEMOVING = false;

	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	_sX = _this select 2;
	_sY = _this select 3;
	private _shift = _this select 4;
	private _ctrl = _this select 5;
	disableserialization;

	

	private _map1 = if (_a3c_dsp == 100020) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	private _sPos = (_map1 posscreentoworld [_sx,_sy]);

	private _isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};


	
	
	if (A3C_UI_MAP_BOOL_isHCWaypointPosEdit) then {

		//-- SELECT HC GROUP THAT OWNS THE CLICKED WAY POINT. >> maybe add check if waypoint was moved, ignore if moved to only select on click??
		//-- check 1: is there any non group-element in the array?
		if ({typeName _x == "GROUP"} count A3C_SELECTED_UNITS == 0) then {
			A3C_SELECTED_UNITS = [A3C_HC_ACTIVEGROUP];
		} else {
			if (_ctrl) then {
				if (A3C_HC_ACTIVEGROUP in A3C_SELECTED_UNITS) then {
					A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [A3C_HC_ACTIVEGROUP];
				} else {
					A3C_SELECTED_UNITS set [count A3C_SELECTED_UNITS, A3C_HC_ACTIVEGROUP];
				};
			} else {
				A3C_SELECTED_UNITS = [A3C_HC_ACTIVEGROUP];
			};
		};
		//-- check 2: if _ctrl, then potentially add to selection
		
		
		
		 //-- #TODO: this whole 'A3C_SELECTED_HC_GROUPS_SETTINGS', 'A3C_SELECTED_HC_GROUPS_SETTINGS', 'RD_UNITS' layout is a mess boiiii! IMPROVE
		A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
		A3C_MAP_CommandMode = "HC";


		[] call A3C_UNITSEL_REFRESH_UI;
		// systemchat format ["HC Select WP-CLick: %1", [A3C_UI_MAP_BOOL_isHCWaypointPosEdit, A3C_SELECTED_UNITS]];
	
		//~~
		//-- #TODO: #HuiHui -- streamline this duplicate code for visualizing selection change in tree-UI
		private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
		_CT_TREE tvSetCurSel [-1];
		//sleep 0.7;
		//playsound 'A3C_MenuSound1';
		//0.3;
		
		if (count A3C_SELECTED_UNITS == 1) then { //--

			_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
			if (count _button > 0) then {
				_button = _button select 0;
				_buttonParent = _button select [0,count _button -1];
				if ([_button select 0] in A3C_UI_MAP_TREES_OPEN) then {
					_CT_TREE tvSetCurSel _button;
					[
						[
							findDisplay 100020 displayCtrl 202020,
							_button select [0,(count _button) - 1]
						],
						"OPEN",
						false,
						0.1
					] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE
				};
			};	
		};
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
			_wp_Icons = (["HC_WP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
			A3C_HC_WP_SYNC_ROOT params ["_rootGroup","_rootWPI"];
			if (count _wp_Icons > 0) then {
				_wp_Icon = _wp_Icons select 0;
				_gp = _wp_Icon select 0;
				_wp_Index = _wp_Icon select 3;
				
				if (A3C_HC_WP_SYNC_ROOT select 0 != _gp) then {
					// systemchat str (synchronizedWaypoints A3C_HC_WP_SYNC_ROOT);
					private _updatedSyncWaypoints = (synchronizedWaypoints A3C_HC_WP_SYNC_ROOT) + [ [_gp,_wp_Index] ];
					[[A3C_HC_WP_SYNC_ROOT, _updatedSyncWaypoints],A3C_HC_FNC_SYNC_WP] remoteExec ["bis_fnc_call",0];
					// [] spawn {
					// 	sleep 0.5;
					// 	systemchat str (synchronizedWaypoints A3C_HC_WP_SYNC_ROOT);
					// };
					// if (true) exitWith {};
					private _syncTypes = ["SYNC"];
					A3C_UI_MAP_SYNC_BOARDGROUP = grpNull;
					A3C_UI_MAP_SYNC_HOSTGROUP = grpNull;
					A3C_UI_MAP_SYNC_BoardWPI = -1;
					A3C_UI_MAP_SYNC_HostWPI = -1;
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
									A3C_UI_MAP_SYNC_BOARDGROUP = _checkedGroup;
									A3C_UI_MAP_SYNC_BoardWPI =  if (_checkedGroup == _gp) then {_wp_Index} else {_rootWPI};
									A3C_UI_MAP_SYNC_HostWPI =  if (_checkedGroup == _gp) then {_rootWPI} else {_wp_Index};
									A3C_UI_MAP_SYNC_HOSTGROUP = _refGroup;
									//_targetVeh = (vehicle leader _refGroup);
									_syncTypes pushBackUnique "GET IN";
								};

							};
							case ({vehicle _x != _leadVic} count units _checkedGroup == 0) : {
								if ((driver _leadVic) in (units _leadVic)) then {
									if ((_refVic canVehicleCargo _leadVic) select 0) then {
										A3C_UI_MAP_SYNC_BOARDGROUP = _checkedGroup;
										A3C_UI_MAP_SYNC_HOSTGROUP = _refGroup;
										A3C_UI_MAP_SYNC_BoardWPI =  if (_checkedGroup == _gp) then {_wp_Index} else {_rootWPI};
										A3C_UI_MAP_SYNC_HostWPI =  if (_checkedGroup == _gp) then {_rootWPI} else {_wp_Index};
										//systemchat str [_refVic,_refVic];
										_syncTypes pushBackUnique "VEHICLE GET IN";
									};
								};
							};
						};
					} foreach [_gp,_rootGroup];
					
					if (count _syncTypes > 1) then {
						A3C_UI_MAP_isCircleMenu = true;
						A3C_UI_MAP_CircleMenu_CTRLS = [];
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
									_btnFnc = {[] call A3C_UI_MAP_FNC_SYNC_LoadGroupInVehicle;};
								};

								case ("VEHICLE GET IN") : {
									_btnImg ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa";
									_btnFnc = {[] call A3C_UI_MAP_FNC_SYNC_LoadVehicleInVehicle;};
								};
							};

							_btnClicker buttonSetAction format
							[
								"

									[%1] call A3C_UI_MAP_FNC_CloseSyncCircleMenu;
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
							A3C_UI_MAP_CircleMenu_CTRLS pushBackUnique [_bgID,_imgID,_clickerID]; //_bgID
							
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
									"if !(false) then {[(group this)] call A3C_HC_FNC_CompleteWaypoint}; "
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
		
		private _gps = [];
		{
			_gp = _x;
			if ( (position (vehicle leader _x)) inPolygon _selPoses) then {

				//_leaderVic = vehicle _leader;
				//if (_leader == driver _leaderVic) then {
					_gps pushbackUnique _gp;
				//};
				
			};
		} foreach A3C_HC_getAllGroups_Player_Current;

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

		private _squadUnits = [];
		
		{
			if ((position _x) inPolygon _selPoses && {_x == driver vehicle _x}) then {
				_squadUnits pushbackUnique _x;
			};
		} foreach (units player - [player]);
		private _pageMode = "INF";

		if (A3C_MAP_CommandMode == "HC" && {count (_gps - [group player]) > 0}) then {
			_squadUnits = []; //~~ sure this could be done better than resetting the value. try to avoid check instead
		} else {
			if (count _squadUnits > 0) then {
				_gps = [];
			};
		};
		

		if (count (_squadUnits + _gps) != 0) then {
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
			private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
			_CT_TREE tvSetCurSel [-1];
			if (count A3C_SELECTED_UNITS == 1) then {
				_CT_TREE tvSetCurSel [-1];
				_button = (A3C_SELECTED_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
				if (count _button > 0) then {
					_button = _button select 0;
					_buttonParent = _button select [0,count _button -1];
					if ([_button select 0] in A3C_UI_MAP_TREES_OPEN) then {
						_CT_TREE tvSetCurSel _button;
						[
							[
								findDisplay 100020 displayCtrl 202020,
								_button select [0,(count _button) - 1]
							],
							"OPEN",
							false,
							0.1
						] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE
					};
				};
			};
			A3C_MAP_CommandMode = _pageMode;
			//-- toggle or collapse wpsettings bar
			_foldMode = if (count A3C_SELECTED_UNITS > 0 && {_pageMode != "HC"}) then {"OPEN"} else {"COLLAPSE"};
			[_foldMode,0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
			[_pageMode] call A3C_START_TABMODE;
		} else {
			//-- no units in selection field: Check for waypoints
            
            private _waypointiconsInField = A3C_UI_MAPICONS_HC_WPS select {
                (_x select 2) inPolygon _selPoses
            };
            if (count _waypointiconsInField > 0) then {
                A3C_Selection_MultiWaypoint = _waypointiconsInField apply {
                    [_x select 0, _x select 3]
                };
                // systemchat format ["MouseUp - A3C_Selection_MultiWaypoint: %1", A3C_Selection_MultiWaypoint];
            };
		};
	};

	

	A3C_DRAGPOS = [];
	////~~~~ TEMP! MOVE THIS!
	if (count A3C_MAP_DRAGPLANNING_POSITIONS > 0) then {
		
		_gpIcons = (["HC_GP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
		_drawBoardIcons = (["BOARDING_DRAW",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
				};
			} else {
				if (count A3C_SELECTED_UNITS == 1) then {
					private _unit = A3C_SELECTED_UNITS select 0;
					if ( (_unit == A3C_SQ_CLICKED_UNIT) && (A3C_MAP_CommandMode == "INF") ) then {
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
			//if (A3C_MAP_CommandMode == "HC") then {
				_groupsToAssign = if (count A3C_SELECTED_UNITS > 0 && A3C_MAP_CommandMode == "HC") then {+(A3C_SELECTED_UNITS)} else {[A3C_SQ_CLICKED_UNIT]};
				
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

	_a3c_dsp = if (visibleMap) then {100020} else {100030};

	if !(A3C_BOOL_MAP_MU) exitwith {};

	if !(getmarkerColor "A3C_RADIMARK" == "") then {deletemarkerLocal "A3C_RADIMARK"};
	if (A3C_BOOL_LOOPING) exitwith {
		_this spawn A3C_UI_MAP_onMouseButtonUp_Loop;
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

						//private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
							["A3C_CTRL_DET_SELECT"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
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
					["A3C_CTRL_DET_SELECT"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;

				};
			};
			A3C_PICKUP_OBJECTS = [];


		};
	};






	_exit = false;
	// if (typeName A3C_MovedItem_ID == "ARRAY") exitWith { // << NOTE: MouseUp means these should be reset anyways, no??
		A3C_BOOL_MAP_MU = false;
		// A3C_BOOL_MOUSEMOVING = false; //-- keeping this as a reminder it was initially here >> i moved it to top
	// };

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

					_statementsExec = "if !(false) then {[(group this)] call A3C_HC_FNC_CompleteWaypoint};"; //format
					//[
					//	"
					//		if !(false) then {[(group this)] call A3C_HC_FNC_CompleteWaypoint};
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
						_wpToEdit setWaypointStatements ["true","if !(false) then {[(group this)] call A3C_HC_FNC_CompleteWaypoint};"];
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
			_demoIcons = (["DEMO",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
		A3C_BOOL_MAP_MU = false;
		A3C_BOOL_MOUSEMOVING = false;
		 [grpNull,-1];
		A3C_BOOL_MOVINGHC = false;
	};

	//-- exit: Mode is HC
	if (A3C_MAP_CommandMode == "HC") exitWith {
		A3C_BOOL_MAP_MU = false;
	};


	//-- exit: No Drag Marker selected
	if !(A3C_MovedItem_ID == "") exitwith {
		A3C_BOOL_MAP_MU = false;
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
		A3C_BOOL_MAP_MU = false;
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
			//if (ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_CTEDIT_SQTImeout)) then { // <<-- Sleep Box (Timeout Only)
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



A3C_UI_MAP_onOnMouseMoving_Main = {
	
	if (isNull findDisplay 100020) then {
		// player commandChat "A3C_UI_MAP_onOnMouseMoving_Main";
		A3C_MAP_X = _this select 1;
		A3C_MAP_Y = _this select 2;
	};
};

A3C_UI_MAP_onOnMouseMoving_Overlay = {
	// player sideChat "A3C_UI_MAP_onOnMouseMoving_Overlay";
	params ["_display","_sX","_sY","_unUsed"];
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
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


A3C_UI_MAP_onKeyDown_Map = { //-- This handler is needed because ESC behaves differently than ALL other keys
	params ["_mapControl","_key","_shift","_ctrl","_alt"];


	// player sidechat format ["Display %1, A3C_UI_MAP_onKeyDown_Map - %2 %3",_mapControl, keyName (_this select 1), round time];

	
	




	private _display = findDisplay 100020;
	if (_key == 1) exitWith {
		private _groupContextmenuHC = _display displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT;
		private _groupDashboardHC = _display displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT;
		private _wpContextmenuHC = _display displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT;
		private _blockDefault = false;
		if (ctrlShown _groupContextmenuHC) then {
			{
				_x ctrlShow false;
			} foreach [_groupContextmenuHC, _groupDashboardHC];
			_blockDefault = true; 
		} else {
			if (ctrlShown _wpContextmenuHC) then {
				_wpContextmenuHC ctrlShow false;
				_blockDefault = true; 
			};
		};
		_blockDefault
	};
	false //-- standard - keep everything enabled
};

A3C_UI_MAP_onKeyDown_Overlay = {
	disableSerialization;
	params ["_display","_key","_shift","_ctrl","_alt"];
	
	// player commandchat format ["Display %1, A3C_UI_MAP_onKeyDown_Overlay: %2 - %3", _display, keyName _key, round time];


	
	

	//-- 1: MAP KEYBIND (close map > Does not work if overlay is open)
	if ((_this select 1) in actionKeys "showmap") exitWith {
		false //-- this will close the map automatically, no need for 'showMap false'
	};


	//-- declare variable for suppression of Engine Binds
	private _blockDefault = false;



	//-- Disable Numbers (#TODO: Check why this is dependent on selectedUnits). Also Avoids weapon switch?
	if (
		count groupselectedUnits player == 0
		&& {_key >= 2 && _key <= 10}
	) exitWith {
		true	
	};
	
	//-- 2: DEFAULT EXIT CONDITIONS
	if (
		[_key] call A3C_UI_Shared_shouldBlockKeyRepeat
		// || {A3C_MAP_BOOL_CT_EDIT_ACTIVE}
	) exitwith {false};

	if (_alt && {_key == 15}) exitWith {// safety if user alt-tabs out of the game
        A3C_UI_DOWNKEYS = [];
        false
    };


	[_key] call A3C_UI_Shared_FNC_AddDownkey;


	private _mapObjectSelector = _display displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
	switch (true) do {
		//-- 3: Check if keybind should control ObjectSelector //-- #
		case
		(
			ctrlShown _mapObjectSelector &&
			{
				private _lbSize = lbSize _mapObjectSelector;
				_key >= 0 && _key <= 9 &&
				{(_key - 1) <= _lbSize}
			}
		) : {
			private _keyValueIndex = _key - 2;

			[_mapObjectSelector, _keyValueIndex] spawn {
				sleep 0.1;
				params ["_mapObjectSelector","_keyValueIndex"];
				[_mapObjectSelector, _keyValueIndex, true] call A3C_setCurSel;
			};
			_blockDefault = true;
		};
		//-- switch Squad-Bar pages
		case
		(
			commandingMenu == ""
			&& {_key in [2,3,4]}
		) : {
			switch (_key) do {
				case 2: {
					if !(A3C_MAP_CommandMode == "INF") then {
						A3C_SELECTED_UNITS = [];
					};

					["INF"] call A3C_START_TABMODE;
					A3C_MAP_CommandMode = "INF";
				};
				case 3: {
					if !(A3C_MAP_CommandMode == "AIR") then {
						A3C_SELECTED_UNITS = [];
					};

					["AIR"] call A3C_START_TABMODE;
					A3C_MAP_CommandMode = "AIR";
				};
				case 4: {
					if !(A3C_MAP_CommandMode == "HC") then {
						A3C_SELECTED_UNITS = [];
					};

					["HC"] call A3C_START_TABMODE;
					A3C_MAP_CommandMode = "HC";
				};
			};
			_blockDefault = true;
		};
		case 
		(
			a3c_is_HC_remote
			&& {_key in [17,30,31,32,200,203,205,208]}
		) :
		{
				_this call A3C_UI_SHARED_onKeyDown_remoteVehicle;
				_exit = true;
				_blockDefaultKey = true;
		};
		//-- Other keybinds
		case (_key in [28,57,207]) : {

			private _groupContextmenuHC = _display displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT;
			private _wpContextmenuHC = _display displayCtrl A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT;

			switch (_key) do {
				case 28: { // Enter
					if (ctrlShown _groupContextmenuHC) then {
						[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm;
					} else {
						if (ctrlShown _wpContextmenuHC) then {
							[] call A3C_Map_HC_waypointContext_ButtonFnc_Confirm;
						};
					};
					_blockDefault = true;
				};
				case 57: { // Spacebar
					if ( A3C_MAP_CommandMode in ["INF","AIR"] && {count groupselectedUnits player == 0}) then {
						['ALL'] spawn A3C_Btn_fnc_Execute;
					};
					_blockDefault = true;
				};
				case 207: { //-- END-key
					if (A3C_Selection_MultiWaypoint isEqualTo []) then {
						//-- SINGLE - need to hover exactly over waypoint
						getMousePosition params ["_sX","_sY"];
						_wpIcons = (["HC_WP",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
						if (count _wpIcons > 0) then {
							_wpIcon = _wpIcons select 0;
							_gp = _wpIcon select 0;
							_wpiC = _wpIcon select 3;
							[_gp, _wpiC] call A3C_HC_REMOVE_WP_RC;
						};
					} else {
						//-- MULTIPLE WAYPOINTS SELECTED - can just delete
						{
							_x params ["_group", "_wpIndex"];
							while {_x in (waypoints _group)} do {
								_x call A3C_HC_REMOVE_WP_RC;
							};
							A3C_Selection_MultiWaypoint = A3C_Selection_MultiWaypoint - [_x];
						} foreach A3C_Selection_MultiWaypoint;
					};
				};
			};
		};
	};
	_blockDefault
};

//-- MAP Main "KeyUp"
A3C_UI_MAP_onKeyUp_Overlay = {
	params ["_display","_key","_shift","_ctrl","_alt"];
	
	player commandchat format ["MAP KEY-UP: %1 (%2)", _key, keyName _key];

	if (player != (leader group player)) exitwith {false};
	if ( !isNull(findDisplay 312) ) exitWith {false}; //-- ZEUS interface is open. Prevent most A3C stuff
	
	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

	switch (true) do {
		case 
		(
			a3c_is_HC_remote
			&& {_key in [17,30,31,32,200,203,205,208]}
		) :
		{
				_this call A3C_UI_SHARED_onKeyUp_remoteVehicle;
		};
		case (
			vehicle player isKindOf "HELICOPTER"
			&& {player == (gunner vehicle player)}
		) : {
				(vehicle player) spawn {
				sleep 1;
				_this flyInHeight((getPosATL _this) select 2);
			};
		};
		
	};

	false
	
};




///--- RELATED HELPERS / EXTENSIONS

//-- A3C_MMCode Helpers:
A3C_UI_MAP_onMouseDrag = {
	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};


	_sx = _this select 1;
	_sy = _this select 2;
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	disableSerialization;
	_map1 = if (_a3c_dsp == 100020) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
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


//-- adjust the position of HC-waypoint while dragged
A3C_UI_MAP_onMouseDrag_HCWP = {
	params ["_waypoint","_data"];

	_waypoint params ["_group","_wpi"];


	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};



	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	disableSerialization;
	_map1 = if (_a3c_dsp == 100020) then {findDisplay 12 displayCtrl 51} else {findDisplay _a3c_dsp displayCtrl 7043};
	_posi = _map1 posscreentoworld [(_data select 1),(_data select 2)];

	if !(_waypoint in A3C_Selection_MultiWaypoint) then {
		//-- Single Waypoint Drag
		_waypoint setwaypointposition [_posi,0];	
	} else {
		//-- Multiple Waypoint Drag
		private _childWaypoints = A3C_Selection_MultiWaypoint - [_waypoint];
		private _parentWaypointPos = waypointPosition _waypoint;
		private _waypointRelposMap = _childWaypoints apply {
			private _childWaypointPos = waypointPosition _x;
			[_parentWaypointPos distance2D _childWaypointPos, _parentWaypointPos getDir _childWaypointPos]
		};
		_waypoint setwaypointposition [_posi,0];
		{
			private _waypointRelposMapEntry = _waypointRelposMap select _forEachIndex;
			private _newWaypointPos = _posi getPos [_waypointRelposMapEntry select 0, _waypointRelposMapEntry select 1];
			_newWaypointPos set [2, 1000];
			// _newWaypointPos set [2,0];
			// _newWaypointPos set = ATLtoASL _newWaypointPos;
			_x setWaypointPosition [_newWaypointPos, -1]; //-- << Force exact placement with negative radius
		} foreach _childWaypoints;

	};	
	

	
};



A3C_UI_MAP_onMouseDrag_MapItem = {

	if (A3C_BOOL_DISABLEMAPCTRL) exitwith {};
	params ["_data","_item","_mode","_ctrl","_alt"];
	private ["_mode","_cI","_markerDir","_rPos","_dMark","_polygon","_var","_t","_exit"];


	//systemchat str _item;
	_sx = _data select 1;
	_sy = _data select 2;

	_a3c_dsp = if (visibleMap) then {100020} else {100030};
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
		} foreach (A3C_HC_getAllGroups_Player_Current + (units player - [player]));
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

//////////////////////////////////

//-- EXTENDED HANDLER FNCS (Sub-Handler fncs spawned by parent Handler)
//-- "mousebuttonDown" on marker. If Loop can be created, adds displayEventHandlers and creates Dummy for MouseDrag-Arrow
A3C_UI_MAP_onMouseButtonDown_Loop = {
	private ["_units","_syncData"];
	_sx = _this select 0;
	_sy = _this select 1;
	_units = [];
	_data = [];
	A3C_LOOPSYNC_START = ["",[0,0,0]];
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	disableSerialization;
	_map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};

	private _waypointIDS = [];
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
			A3C_BOOL_MAP_MU = true;

			A3C_MMCode = {
				_this spawn A3C_UI_MAP_onMouseDrag;
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



A3C_UI_MAP_onMouseButtonUp_Loop = {

	//-- #NOTE seems to be used for sync
	private ["_startMark","_exit","_units","_data","_isLoop","_dragMode","_sc","_wrongDir"];

	A3C_BOOL_LOOPING = false;
	A3C_BOOL_MAP_MU = false;
	A3C_BOOL_MOUSEMOVING = false;


	if ((_this select 1) == 1) exitwith {}; //-- exit if rmb was used to enable mapdrag
	_sx = _this select 2;
	_sy = _this select 3;
	_isLoop = false;
	_units = [];
	_checkVar = "A3C_PLOT_TEMP";
	_dragMode = "LOOP";
	_a3c_dsp = if (visibleMap) then {100020} else {100030};
	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS") - [player];

	
	disableSerialization;
	_map1 = if (_a3c_dsp == 100020) then {(findDisplay 12 displayCtrl 51)} else {(findDisplay _a3c_dsp displayCtrl 7043)};

	_clickedItem = (ctrlMapMouseOver _map1);
	_marker = "";

	A3C_BOOL_DRAGLINE = false;
	//systemchat str time;
	private _waypointIDS = [];
	private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
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
