#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

/*
Let's overwork this entire handler shall we.
Best shot right now:
1. Pick up all icons (and/or markers)
2. Seperate execution through right and leftclick
*/



params ["_displayCtrl","_mouseButton","_sX","_sY","_shift","_ctrl","_alt"];
private ["_mouseOverIcon","_groupControls","_isHCMark"];

disableserialization;

A3C_BOOL_MAP_MD = true; 

private _exit = false;

private _left = _mouseButton == 0; // << #TODO this sux, remove lol


if (a3c_is_HC_remote && {!(_left)}) exitWith {
	_this call A3C_UI_SHARED_OnMouseButtonDown_remoteVehicle;
	false //-- potentially not needed. WIP stage, this entire mouseDown EH needs serious overhaul
};


//------------------------- EXIT CONDITIONS (MAPCLICK NOT ALLOWED)

if (isNull findDisplay IDD_MAP_OVERLAY) exitWith {};
if (A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE) exitWith {};
if (A3C_UI_MAP_isCircleMenu) exitWith {
	if !(_left) then {
		[IDD_MAP_OVERLAY,-1] call A3C_ui_mapOverlay_fnc_closeSyncCircleMenu;
	};
};

//-- contextMenues are open >> exit
if (
	{
		ctrlShown (findDisplay IDD_MAP_OVERLAY displayCtrl _x)
	} count [
		IDC_MAP_SQWP_Combo,
		IDC_MAP_DynamicCombo,
		IDC_MAP_HCWP_Parent,
		IDC_MAP_HCGP_Parent,
		IDC_SHARED_UI_SelectionPromptPanel_Parent,
		IDC_MAP_UFSB_Subselection_01_BG,
		IDC_MAP_UFSB_Subselection_02_BG
	] > 0
) exitWith {};




private _ctls =
[
	IDC_SHARED_UI_TREE_SELECTOR,
	IDC_UI_SHARED_TEAMCOLOR_BG,
	IDC_MAP_TOP_EXTRAS_BACKGROUND,
	IDC_MAP_Order_GoCode_BG,
	IDC_SHARED_UI_SelectionPromptPanel_Parent,
	IDC_MAP_INPUT_BLOCKER,
	IDC_MAP_HCGP_Parent
];

//-- exit if mouseclick was within certain controls
if ({[[_sX,_sY],findDisplay IDD_MAP_OVERLAY displayCtrl _x] call MCSS_fnc_isClickPosInCtrlArea} count _ctls > 0) exitWith {};



//-- ENEMY-TARGET Combo is open - ALWAYS disables mapclick, hides Combo if it's not clicked on directly
if (ctrlShown (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo)) exitWith {
	if !([[_sX,_sY],findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo] call MCSS_fnc_isClickPosInCtrlArea) then {
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo) ctrlShow false;
	};
};

//-----------------------------------------------------------------------------------





private _unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
private _map1 = findDisplay 12 displayCtrl 51;
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
				!([_x] call A3C_ai_highCommand_fnc_getArtilleryCapacity) &&
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
	["ARTY"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
};





if (A3C_HC_DETONATION_BOOL) exitWith {
	private _demoIcons = (["DEMO",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
	if (count _demoIcons > 0) then {
		_hoverIcon = _demoIcons select 0;
		_hoverVic = _hoverIcon select 0;
		if ((vehicleVarName _hoverVic) == "") then {
			_hoverVic = missionNameSpace getVariable ([_hoverVic] call A3C_main_fnc_setVehicleVarname);
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
	private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
if (A3C_Boarding_ACTIVE) exitWith {

	private _vhIcons = [];
	//-- Boarding HC-units via map-ui pt 2
	_vhIcons = (["HC_VB",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
	_doReset = false;
	if (_left) then {
		if (count _vhIcons > 0) then {
			_vhIcon = _vhIcons select 0;
			private _selectedVehicle = _vhIcon select 0;
			//_boardGroup = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

			[A3C_SELECTED_HC_GROUPS_SETTINGS,_selectedVehicle] call A3C_ai_highCommand_fnc_assignGroupToVehicle;
			_doReset = true;
		} else {
			A3C_Boarding_ACTIVE = false; //-- disable boarding interface
			_doReset = true;
		};
	} else {
		if (_ctrl) then {
			A3C_Boarding_ACTIVE = false; //-- disable boarding interface
			_doReset = true;
		};
	};
	if (_doReset) then {
		A3C_UI_MAPICONS_HC_VICS = [];
		A3C_Boarding_ACTIVE = false;
		A3C_BOARDING_GROUPS = [];
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
	["SPACING","OFF"] call A3C_ui_mapOverlay_fnc_CTEdit_setActive;
};

//-- detect click on HC-GROUP WAYPOINT ICON
if !(_isHighCommand) then {
	_wp_Icons = (["HC_WP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
				A3C_BOARDING_GROUPS = [_gp];
				A3C_CLICKPOS_ORIG =  A3C_CLICKPOS_1;
				A3C_BOOL_MOUSEMOVING = true;
				A3C_HC_WP_SYNC_ROOT = [_gp,_wp_Index];
				A3C_MMCode = {
					_this spawn {
						params ["_clickData","_sX","_sY"];
						if (isNull findDisplay IDD_MAP_OVERLAY) exitWith {};
						_map1 = findDisplay 12 displayCtrl 51;
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
							[A3C_HC_TOSWITCH,_this] spawn A3C_ui_mapOverlay_fnc_onDragMapHCWP;
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
			[_gp,_wp_Index,A3C_HC_EDIT_ACTION,IDD_MAP_OVERLAY,[_sx, _sy]] call A3C_ui_mapOverlay_fnc_HCWP_openMenu;
			_resetSelection = false;
		};

	} else {
		A3C_Selection_MultiWaypoint = [];
	};
};

if (_exit) exitWith {};


_gpIcons = (["HC_GP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
private _gpIconsCount = count _gpIcons;
if (_gpIconsCount > 0) exitWith {

	
		
	// _gpIcon = _gpIcons select 0;
	_gpIcon = if ({typeName _x != "GROUP"} count A3C_SELECTED_UNITS == 0 && {count A3C_SELECTED_UNITS == 1}) then {
		private _selectionIndex = -1;
		
		{
			// private _iconIndex = [_x,_gpIcons] call MCSS_fnc_getArrayIndex;
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
			private _CT_TREE = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
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
								findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR,
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
				["COLLAPSE",0.1] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
			};


			if (!isPlayer leader _gp) then {
				if ( (count A3C_SELECTED_UNITS == 0) OR (A3C_SQ_CLICKED_UNIT in A3C_SELECTED_UNITS) ) then {
					A3C_MAP_DRAGPLANNING_ACTIVE = true;
					A3C_BOOL_MOUSEMOVING = true;
					A3C_MMCode = {
						_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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
				//(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCGP_Parent) ctrlShow true;
				// if ({private _ld = leader _x; isPlayer _ld} count A3C_SELECTED_UNITS == 0) then {
					(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCGP_Parent) ctrlSetPosition ([IDD_MAP_OVERLAY,IDC_MAP_HCGP_Parent,[_sx, _sy]] call A3C_ui_mapOverlay_fnc_findCtrlSafePos);
					(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCGP_Parent) ctrlCommit 0;
				// } else {
					// hint "A3C: "; //-- not needed, should already be executed in actions
				// };

				
				
				//A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
				//[_gp,0] call A3C_ui_mapOverlay_fnc_HCGP_openMenu;
				A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
				if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
					A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_UNITS;
					[A3C_SELECTED_HC_GROUPS_SETTINGS,1] call A3C_ui_mapOverlay_fnc_HCGP_openMenu;
				} else {
					A3C_SELECTED_HC_GROUPS_SETTINGS = [_gp];
					[_gp,0] call A3C_ui_mapOverlay_fnc_HCGP_openMenu;
				};				
			//};
		};
		
	};
};




//-- detect click on PLAYER SQUAD UNIT ICONS
_sqIcons = (["SQUAD",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
if (count _sqIcons > 0) exitWith {
	_sqIcon = _sqIcons select 0;
	A3C_SQ_CLICKED_UNIT = _sqIcon select 0;
	if (_left) then {
		if (_ctrl && _shift) then {
			_cargoObjects = ([vehicle A3C_SQ_CLICKED_UNIT] call A3C_main_fnc_getNearCargoLoadObjects);
			if ( ((getPosATL (vehicle A3C_SQ_CLICKED_UNIT)) select 2) < 1) then {
				if ((count _cargoObjects > 0) && (A3C_SQ_CLICKED_UNIT == driver (vehicle A3C_SQ_CLICKED_UNIT))) then {
					_parent = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
					_text = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
					_listBox = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
					A3C_SelectionPromptPanel_MODE = "PARALOAD_SQ";
					_parent ctrlShow true;
					_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
					_parent ctrlCommit 0;
					_text ctrlSetText "Select Object to load";
					ctrlSetFocus _listBox;
					
					lbClear _listBox;

					{
						private _lbText = format ["%1 (%2m)",(getText (configfile >> "CfgVehicles" >> typeof _x >> "displayName")),round( (vehicle A3C_SQ_CLICKED_UNIT) distance _x)];
						[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
					} foreach _cargoObjects;
					
					_exit = true;
				};
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

				private _CT_TREE = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
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
									findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR,
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
							_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
						};
					};
					_exit = true; //~~?	
				};
				
				//-- toggle or collapse wpsettings bar
				_foldMode = if (count A3C_SELECTED_UNITS > 0) then {"OPEN"} else {"COLLAPSE"};
				[_foldMode,0.1] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
				//A3C_SELECTED_UNITS = [A3C_SQ_CLICKED_UNIT];
				if (vehicle A3C_SQ_CLICKED_UNIT isKindOf "AIR") then {
					A3C_MAP_CommandMode = "AIR";
					["AIR"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
				} else {
					A3C_MAP_CommandMode = "INF";
					["INF"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
				};
			};
		};			
	};
};

//-- detect click on FORCE TRACKER ICON
_trIcons = (["TRACKER",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
//systemchat str _trIcons;
if ( !(_left) && (count _trIcons > 0)) exitWith {
	_trIcon = _trIcons select 0;
	if (_trIcon select 3 == "ENEMY") then {
		A3C_LB_MODE = 1;
		A3C_TRACKED_ENEMYGROUP = _trIcon select 0;
		lbClear (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo);
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo) ctrlShow true;
		ctrlsetfocus (finddisplay IDD_MAP_OVERLAY displayctrl IDC_MAP_DynamicCombo);
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo) ctrlSetPosition [_sx, _sy];
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo) ctrlCommit 0;
		[findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo, "Ignore"] call A3C_ui_shared_fnc_addLbEntry;
		[findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo, "Attack"] call A3C_ui_shared_fnc_addLbEntry;

		[findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DynamicCombo, 0] call A3C_ui_shared_fnc_lbSetCurSel;
		
	};
};


//-- detect click on UI POLYGON MAIN MARKERS
private _mapPolygons =(["POLY_MAIN",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
				A3C_CUR_EDIT_POLY = ([(_x select 0) select 0,0,"",false] call A3C_ai_shared_fnc_polygonAreaCreate) select 0; //~~ poly: what is going on here: since create_poly does not create markers, it is used to find // 0 is replacing (markerDir A3C_MovedItem_ID)
				A3C_MMCode = if (_ctrl) then {
					{[_this,A3C_MovedItem_ID,"WP",true,false] spawn A3C_ui_mapOverlay_fnc_onDragMapItem;}
				} else {
					if (_alt) then {

						{[_this,A3C_MovedItem_ID,"WP",false,true] spawn A3C_ui_mapOverlay_fnc_onDragMapItem;}
					} else {
						{[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_ui_mapOverlay_fnc_onDragMapItem;}
					};
				};


			};
		} foreach A3C_ALL_POLYS;

	};
	_exit = true;
};

//-- detect click on UI POLYGON EDGE MARKERS
private _mapPolygonEdges = (["POLY_EDGE",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
if (count _mapPolygonEdges > 0 && {_left}) exitWith {
	private _PolygonEdgeIcon = _mapPolygonEdges select 0;
	_parentPoly = _PolygonEdgeIcon select 0;
	_edgePosition = _PolygonEdgeIcon select 2;
	//systemchat str _PolygonEdgeIcon;

	{
		private _polyRefID = (_x select 0) select 1;
		if (_parentPoly == _polyRefID) exitWith {

			_poses = _x select 1;
			private _ind = [_edgePosition,_poses] call MCSS_fnc_getArrayIndex;
			A3C_MovedItem_ID = [_parentPoly,_ind];
			A3C_BOOL_MAP_MU = true;
			A3C_BOOL_MOUSEMOVING = true;
			A3C_BOOL_MOVINGMARKER = true;
			A3C_DRAGPOS = [_sx, _sy];
			A3C_MMCode = {
				_this call A3C_ui_mapOverlay_fnc_adjustPolygonEdge;
			};
		};
	} foreach A3C_ALL_POLYS;

	_exit = true;
};



//-- detect click on PLAYER SQUAD UNIT WAYPOINT ICON
private _squadWaypoints = (["SQ_WP_DOT",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
			A3C_MMCode = {[_this,A3C_MovedItem_ID,"WP",false,false] spawn A3C_ui_mapOverlay_fnc_onDragMapItem;};
		} else {
			[_sx,_sy] call A3C_ui_mapOverlay_fnc_HXT_OMBD_prepLoopOrSyncSQ;
		};
	} else {
		[_wpDotIDS select 0,[_sX,_sY]] call A3C_ui_mapOverlay_fnc_SQWP_openMenu;
	};
};

//-- detect click on PLAYER SQUAD UNIT WAYPOINT LOOKDIR ICON
private _squadWaypointLookDirs = (["SQ_WP_LOOKDIR",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
if (count _squadWaypointLookDirs > 0) exitWith {
	A3C_DIR_POS = (_map1 posscreentoworld [_sx,_sy]);
	private _squadWaypointLookDirSelected = _squadWaypointLookDirs select 0;
	_squadWaypointLookDirSelected params ["_unit","_size","_area","_markerID"];
	A3C_MovedItem_ID = _squadWaypointLookDirSelected;
	A3C_BOOL_MAP_MU = true;
	A3C_BOOL_MOUSEMOVING = true;
	A3C_BOOL_MOVINGMARKER = true;
	A3C_DRAGPOS = [_sx, _sy];
	A3C_MMCode = {[_this,A3C_MovedItem_ID,"LDIR",false,false] spawn A3C_ui_mapOverlay_fnc_onDragMapItem;};
};





if (_exit) exitWith {};






//-- mapclick is within overlay area >> exit
if ([[_sX,_sY],findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_INPUT_BLOCKER] call MCSS_fnc_isClickPosInCtrlArea) exitWith {};





if (visibleMap) then {
	if !(isnull (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_SQWP_Parent)) then {
		if ([IDD_MAP_OVERLAY] call A3C_ui_mapOverlay_fnc_isCursorOverControl) then {
			_exit = true;
		};
	};
};

if (_exit) exitWith {};

//-- right Mouse Button
if !(_left) exitWith {
	private _resetSelection = true;
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;


	if (_resetSelection) then {
		if (_ctrl) then {
			A3C_SELECTED_UNITS = [];
			A3C_SELECTED_HC_GROUPS_SETTINGS = [];
			["COLLAPSE",0.1] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
			[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
		};
	};
};


if (_exit) exitWith {};

// //-- LeftClick on A3-HC marker //~~??
// if (_isHighCommand) then {
// 	if (A3C_MAP_CommandMode == "HC") then {
// 		if (count (["HC_WP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos) > 0) then {
// 			systemchat "ALERT! PLEASE REPORT IF YOU SEE THIS ERROR: MAP_LEFTDOWN_OLD_HC";
// 			A3C_BOOL_MAP_MU = true;
// 			A3C_BOOL_MOUSEMOVING = true;
// 			A3C_BOOL_MOVINGHC = true;
// 			A3C_MMCode = {
// 				[A3C_HC_TOSWITCH,_this] spawn A3C_ui_mapOverlay_fnc_onDragMapHCWP
// 			};
// 			_exit = true;
// 		};
// 	};
// };






if (_exit) exitWith {};

A3C_MovedItem_ID = "";
if (A3C_TAB_BUILDING_BOOL) then {
	[] call A3C_ui_mapOverlay_fnc_squad_deleteBposMarkers;
	A3C_TAB_BUILDING_BOOL = false;
};

//-- Left Click on empty Area
if (((A3C_TEMP_ACTION select 0) == "GRENADE") && {count A3C_AI_GREN_ARRAY == 0}) exitWith {
	systemchat "A3C: No grenades available with current selection";
};


//-- Current Mode is HC
if (A3C_MAP_CommandMode == "HC" && !(_ctrl)) exitWith {
	if ((count A3C_SELECTED_UNITS) > 0) then {
		if !(ctrlShown (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCGP_Parent)) then {
			if (_alt) then {
				//-- clear all waypoints
				{
					{
						_x setVariable ["A3C_CLEARING",false,true];
					} foreach (units _x);
				} foreach A3C_SELECTED_UNITS;
				
				{
					_gp = _x;
					[_gp, "ALL"] call A3C_ai_highCommand_fnc_deleteAllWaypoints;
				} foreach A3C_SELECTED_UNITS;
				publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';
				
			};
			private _formDir = A3C_CLICKPOS_1 getDir (position (leader (A3C_SELECTED_UNITS select 0)));
			private _factor = 1;

			private _clickPos = +A3C_CLICKPOS_1;

			A3C_MULTIWAYPOINT = true;
			if (count A3C_SELECTED_UNITS > 2) then {
				A3C_MULTIWAYPOINT = false;
				["MULTIWAYPOINT"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
				waituntil {!ctrlShown (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent)};
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
						if ({[waypointPosition _x,_nearestB] call A3C_main_fnc_isPositionInsideBuilding} count _ref > 0) then {
							_addWP = false;
						};

						if ([_clickPos,_nearestB] call A3C_main_fnc_isPositionInsideBuilding) then {
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
						_wpParams call A3C_ai_highCommand_fnc_addWaypoint;
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
					[_refArray,_clickPos] spawn A3C_ai_highCommand_fnc_convoyMultigroup;
					
				};

				
			};
			A3C_BOOL_MAP_MU = true;
		};
	};
};

if (_ctrl) exitWith {
	[_sx,_sy] call A3C_ui_mapOverlay_fnc_HXT_OMBD_prepLoopOrSyncSQ;
};



//-- Current Mode is Non - HC

A3C_CLICKPOS_ORIG = A3C_CLICKPOS_1;
A3C_TAB_BUILDING = (nearestBuilding A3C_CLICKPOS_1);

if (A3C_MAP_CommandMode == "INF") then {
	if !(A3C_FORMMODE_TEMP == 5) then {
		if ([A3C_CLICKPOS_1,A3C_TAB_BUILDING] call A3C_main_fnc_isPositionInsideBuilding) then {
			if ((count A3C_SELECTED_UNITS) > ([A3C_TAB_BUILDING] call MCSS_fnc_getLastBuildingPosIndex)) then {
				if (A3C_TAB_BUILDING_BOOL) then {
					[] call A3C_ui_mapOverlay_fnc_squad_deleteBposMarkers;
					A3C_TAB_BUILDING_BOOL = false;
				};
				player groupchat "selection surpasses building capacity";
				_exit = true;
			};
			if !(_exit) then {
				A3C_CLICKPOS_1 = A3C_TAB_BUILDING buildingPos 0;
				A3C_CLICKPOS_ORIG = A3C_TAB_BUILDING buildingPos 0;
				A3C_TAB_BUILDING_BOOL = true;
				[] call A3C_ui_mapOverlay_fnc_squad_createBposMarkers;
			};
		} else {
			A3C_TAB_BUILDING = objnull;
		};
	};
};
if (_exit) exitWith {};

if ((count A3C_SELECTED_UNITS) == 0) exitWith {};

//-- precaution: if player is effectiveCommander of vehicle, ALT must be held down to prevent clash with engine-command
//if ( ({(player == (effectivecommander (vehicle _x)))  && (_x == (driver (vehicle _x)))} count (units group player - [player]) > 0) && !(_alt) && (_left)) exitWith {};



A3C_BOOL_MAP_MU = true;
if (A3C_TAB_TOGGLE_VAR == 0) then {
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow true;
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor  [1,1,1,1];
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
		_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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
	A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP)));
};





//~~WTF CLEAN THIS UP, move up in the swith block! :S
if ((A3C_TEMP_ACTION select 0) == 'CTRL_DET') then {

	if (count A3C_SELECTED_UNITS == 1) then {
		if (isNull objectParent (A3C_SELECTED_UNITS select 0)) then {
			A3C_STATE_CHECKING_PICKUP = true;
			A3C_PICKUP_OBJECTS = [A3C_SELECTED_UNITS select 0,A3C_CLICKPOS_ORIG,250,true] call A3C_main_fnc_getNearDetonationTargets;
			{
				if !(typeName _x == "OBJECT") then {
					A3C_PICKUP_OBJECTS = A3C_PICKUP_OBJECTS - [_x];
				};
			} forEach A3C_PICKUP_OBJECTS;
			if (count A3C_PICKUP_OBJECTS > 0) then {


				A3C_CONNECTING_MODE = "";
				A3C_MMCode = {
					_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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

	_packMode = [A3C_SELECTED_UNITS] call A3C_ai_shared_fnc_getWeaponAssemblyMode;
	if (_packMode in ["ASSEMBLE","DUAL"]) then {
		_packMode = "ASSEMBLE";
		_text = (getText (configfile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName"));
		A3C_TEMP_ACTION = ["STATIC",["ASSEMBLE",((A3C_STATIC_PACKS select 0) select 1)]];
		A3C_CONNECTING_MODE = "LOOKDIR";
		A3C_MMCode = {
			_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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
				_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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
			if ([A3C_SELECTED_UNITS select 0,-1,"SQ"] call A3C_ai_squad_fnc_willSlingLoadAtWaypoint) then {
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
						_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
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



A3C_ui_mapOverlay_fnc_UFSB_onUndoButton_MODE = 0;
[0] call A3C_ui_mapOverlay_fnc_setorderWIP;

