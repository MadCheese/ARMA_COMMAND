#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"
	
private ["_exit","_sX","_sY","_sPos","_marker","_veh","_unit","_wpData"];

A3C_BOOL_MAP_MD = false;
A3C_BOOL_MOUSEMOVING = false;

// #TODO: Optimize



_sX = _this select 2;
_sY = _this select 3;
private _shift = _this select 4;
private _ctrl = _this select 5;
disableserialization;



private _map1 = findDisplay 12 displayCtrl 51;
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


	[] call A3C_ui_shared_fnc_refreshUnitSelectionUi;
	// systemchat format ["HC Select WP-CLick: %1", [A3C_UI_MAP_BOOL_isHCWaypointPosEdit, A3C_SELECTED_UNITS]];

	//~~
	//-- #TODO: #HuiHui -- streamline this duplicate code for visualizing selection change in tree-UI
	private _CT_TREE = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
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
						findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR,
						_button select [0,(count _button) - 1]
					],
					"OPEN",
					false,
					0.1
				] spawn A3C_ui_shared_fnc_Tree_openOrCollapse
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
				[leader A3C_HC_ACTIVEGROUP,_sPos] call A3C_ai_shared_fnc_doMove; //~~ #MONITOR
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
		_wp_Icons = (["HC_WP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
		A3C_HC_WP_SYNC_ROOT params ["_rootGroup","_rootWPI"];
		if (count _wp_Icons > 0) then {
			_wp_Icon = _wp_Icons select 0;
			_gp = _wp_Icon select 0;
			_wp_Index = _wp_Icon select 3;
			
			if (A3C_HC_WP_SYNC_ROOT select 0 != _gp) then {
				// systemchat str (synchronizedWaypoints A3C_HC_WP_SYNC_ROOT);
				private _updatedSyncWaypoints = (synchronizedWaypoints A3C_HC_WP_SYNC_ROOT) + [ [_gp,_wp_Index] ];
				[[A3C_HC_WP_SYNC_ROOT, _updatedSyncWaypoints],A3C_ai_highCommand_fnc_syncWaypoint] remoteExec ["bis_fnc_call",0];
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
						
						private _btnBG  = findDisplay IDD_MAP_OVERLAY ctrlCreate ["A3C_RscPicture", _bgID];
						private _btnImg  = findDisplay IDD_MAP_OVERLAY ctrlCreate ["A3C_RscPicture", _imgID];
						private _btnClicker  = findDisplay IDD_MAP_OVERLAY ctrlCreate ["A3C_RscButton_Invisible", _clickerID];

						_btnBG ctrlSetText "A3C_UI\markers\icon_marker_vehicleHexagon.paa";
						_btnImg ctrlSetTextColor ([A3C_UI_COLOR_BLUE,1] call A3C_ui_shared_fnc_getColorArrayWithOpacity);
						//systemchat str [_bgID,_imgID,_clickerID];
						private _btnFnc = {};
						switch (_x) do {
							case ("SYNC") : {
								_btnImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_sync.paa";
							};
							case ("GET IN") : {
								_btnImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
								_btnFnc = {[] call A3C_ui_mapOverlay_fnc_sync_loadGroupInVehicle;};
							};

							case ("VEHICLE GET IN") : {
								_btnImg ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa";
								_btnFnc = {[] call A3C_ui_mapOverlay_fnc_sync_loadVehicleInVehicle;};
							};
						};

						_btnClicker buttonSetAction format
						[
							"

								[%1] call A3C_ui_mapOverlay_fnc_closeSyncCircleMenu;
								[] spawn %2;

							",
							IDD_MAP_OVERLAY,
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
								"if !(false) then {[(group this)] call A3C_ai_highCommand_fnc_completeWaypoint}; "
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
	} foreach A3C_HC_allGroupsClient_Current;

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
		private _CT_TREE = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
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
							findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_TREE_SELECTOR,
							_button select [0,(count _button) - 1]
						],
						"OPEN",
						false,
						0.1
					] spawn A3C_ui_shared_fnc_Tree_openOrCollapse
				};
			};
		};
		A3C_MAP_CommandMode = _pageMode;
		//-- toggle or collapse wpsettings bar
		_foldMode = if (count A3C_SELECTED_UNITS > 0 && {_pageMode != "HC"}) then {"OPEN"} else {"COLLAPSE"};
		[_foldMode,0.1] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
		[_pageMode] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
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
	
	_gpIcons = (["HC_GP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
	_drawBoardIcons = (["BOARDING_DRAW",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
	if (typeName A3C_SQ_CLICKED_UNIT == "OBJECT") then {
		if (count _drawBoardIcons > 0) then {
			private _drawBoardIcon = _drawBoardIcons select 0;
			private _vehi = _drawBoardIcon select 0;
			[A3C_SELECTED_UNITS,true,true] call A3C_ai_shared_fnc_cancelUnitPlot;
			
			_vehi spawn {
				sleep 1;
				_boardingUnits = (A3C_SELECTED_UNITS) select {isNull objectParent _x};
				[_this,'all',0,_boardingUnits] spawn A3C_ai_squad_fnc_boarding_assignVehicleSeatMacro ;				
			};
		} else {
			if (count A3C_SELECTED_UNITS == 1) then {
				private _unit = A3C_SELECTED_UNITS select 0;
				if ( (_unit == A3C_SQ_CLICKED_UNIT) && (A3C_MAP_CommandMode == "INF") ) then {
					if (count (_unit getVariable ["A3C_PLOT",[]]) > 0 ) then {
						[[_unit],true,true] call A3C_ai_shared_fnc_cancelUnitPlot;
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
					_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot);
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
								[_x,_vehi] call A3C_ai_highCommand_fnc_assignGroupToVehicle;
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
							[_x,vehicle leader _gp] call A3C_ai_highCommand_fnc_assignGroupToVehicle;
						//};
					} foreach _groupsToAssign;
					//systemchat format ["A3C: %1 is connected to %2",A3C_SELECTED_UNITS,_gp];
				} else {
					//-- Not dragged on vehicle icon: check for vehicle drag
					if (A3C_UI_MAPICONS_BOARDING_DRAW isEqualTo []) then {
						//-- dragged without vehicle modifier: delete all waypoints
						private _gp = A3C_SELECTED_UNITS select 0;

						//-- add actual waypoint
						//-- clear all waypoints
						{
							{
								_x setVariable ["A3C_CLEARING",false,true];
							} foreach (units _x);
						} foreach A3C_SELECTED_UNITS;
						
						{
							_gp = _x;
							[_gp, "ALL"] call A3C_ai_highCommand_fnc_deleteAllWaypoints;
							{
								_x remoteExec ["unassignVehicle",0];
								moveOut _x;
							} foreach (units _gp);
						} foreach A3C_SELECTED_UNITS;
						publicVariable 'A3C_BLACKLIST_WAYPOINT_EDIT';
						[_gp, _sPos] call A3C_ai_highCommand_fnc_addWaypoint;
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
	[] call A3C_ui_mapOverlay_fnc_squad_deleteBposMarkers;
	//A3C_TAB_BUILDING = objnull;
	[] spawn {
		sleep 0.1;
		A3C_TAB_BUILDING_BOOL = false;
	};
};

if (A3C_BOOL_DISABLEMAPCTRL && !((typename (_this select 0)) == "SCALAR") ) exitWith {};



if !(A3C_BOOL_MAP_MU) exitWith {};

if !(getmarkerColor "A3C_RADIMARK" == "") then {deletemarkerLocal "A3C_RADIMARK"};
if (A3C_BOOL_LOOPING) exitWith {
	_this spawn A3C_ui_mapOverlay_fnc_HXT_OMBU_setLoopOrSyncSQ;
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

					//private _slingIcons =(["SLINGLOAD",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
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
							[] call A3C_ui_mapOverlay_fnc_UFSB_onUndoButton;
							systemchat "A3C: No Cargo Selected";
						};
					};

				};
				case ("CTRL_DET") : {
					//systemchat 'go';
					A3C_MAP_CONNECTING_ID = A3C_TEMP_WP_ID_MAIN;
					_attachPos = _sPos;
					if ( _veh distance2d _sPos < 20) then {

						_attachPos = ([_veh,1] call MCSS_fnc_getBoundingBox) select 1;
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
						["A3C_CTRL_DET_SELECT"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
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
							[] call A3C_ui_mapOverlay_fnc_UFSB_onUndoButton;
							systemchat "A3C: No Static Weapon Selected";
						};
					};
				};
			};


			A3C_MovedItem_ID = "";
		} else {
			if ( ((A3C_TEMP_ACTION select 0) in ["CTRL_DET"])) then {
				//-- bbb
				["A3C_CTRL_DET_SELECT"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;

			};
		};
		A3C_PICKUP_OBJECTS = [];


	};
};






_exit = false;

A3C_BOOL_MAP_MU = false;


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
			
			if ([_releasePos, _build] call A3C_main_fnc_isPositionInsideBuilding) then {

				_wpToEdit setWaypointPosition [(_build buildingPos 0),0];
				_wpToEdit setWaypointType "SCRIPTED";
				_wpToEdit setWaypointScript (format ["A3C_CORE\waypointScripts\wpScript_CLEARBUILDING.sqf ['%1',['ARRIVAL','']]",getPlayerUID player]);

				_statementsExec = "if !(false) then {[(group this)] call A3C_ai_highCommand_fnc_completeWaypoint};"; //format
				//[
				//	"
				//		if !(false) then {[(group this)] call A3C_ai_highCommand_fnc_completeWaypoint};
				//		['%1',this,[['NONE','NONE'],'CLEARBUILDING'],'NO CHANGE',%2] call A3C_ai_highCommand_fnc_insertActionWaypoint;
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
					_wpToEdit setWaypointStatements ["true","if !(false) then {[(group this)] call A3C_ai_highCommand_fnc_completeWaypoint};"];
				};
				if (_wpID == _activeWPindex) then {
					{
						_x setVariable ["A3C_CLEARING",false,true];
					} foreach (units _hcGroup);
				};
			};
		};
	};

	if ("plantExplosives" in (waypointScript [_hcGroup,_wpID])) then {
		_demoIcons = (["DEMO",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
		if (count _demoIcons > 0) then {
			_hoverIcon = _demoIcons select 0;
			_hoverVic = _hoverIcon select 0;
			if ((vehicleVarName _hoverVic) == "") then {
				_hoverVic = missionNameSpace getVariable ([_hoverVic] call A3C_main_fnc_setVehicleVarname);
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
if (A3C_BOOL_MOVINGHC) exitWith {
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
if (typeName A3C_MovedItem_ID == "STRING" && {!(A3C_MovedItem_ID == "")}) exitWith {
	A3C_BOOL_MAP_MU = false;
	A3C_BOOL_MOUSEMOVING = false;
	A3C_MovedItem_ID = "";

	if (count A3C_MV_MARKERDATA > 0 ) then {
		A3C_MV_MARKERDATA params ["_soldier","_wPos","_varName"];
		_soldier setDestination [_wPos,"LEADER PLANNED",true];
		if !(_soldier getvariable ["A3C_HOLD",true]) then {
			if (_varName == "A3C_PLOT") then {
				[_soldier,_wPos] call A3C_ai_shared_fnc_doMove;
			};
		};
		A3C_MV_MARKERDATA = [];
	};
	[] spawn {sleep 0.5; A3C_BOOL_MOVINGMARKER = false;};
};


_left = true;

if (_this select 1 == 1) then {_left = false};
if !(_left) exitWith {};






//-- exit: No units selected
if ((count A3C_SELECTED_UNITS) == 0) exitWith {
	A3C_BOOL_MAP_MU = false;
};


_pos = _sPos; // ((getposASL A3C_DUMMY) select [0,2]) + [0];

//-- exit if DragLine does not exist
if !(A3C_BOOL_DRAGLINE) exitWith {};
A3C_BOOL_DRAGLINE = false;


if (A3C_TAB_TOGGLE_VAR == 0) then {
	{
		(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow true;
	} foreach [IDC_MAP_UFSB_CommitAll, IDC_MAP_UFSB_WPCONDITION_IMG, IDC_MAP_UFSB_UNDO_BTN];
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor [1,1,1,1];
};

A3C_DIR = [A3C_CLICKPOS_1,_pos] call bis_fnc_dirto;

A3C_CLICKPOS_2 = _pos;
A3C_USERACTION pushback [A3C_USERACTION_ID,0,0];
A3C_USERACTION_ID = A3C_USERACTION_ID + 1;

[1] call A3C_ui_mapOverlay_fnc_setorderWIP;
//systemchat 'yep';

if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION"]) then {  //"GRENADE",
	A3C_BOOL_MOUSEMOVING = false;
};

//-- streamline UI: Suppression and Grenade Plans by resetting Condition
if ((A3C_TEMP_ACTION select 0) in ["SUPPRESSION","GRENADE"]) then {
	if ((A3C_TEMP_CONDITION select 0) in ["TIMEOUT","GOCODE"]) then {
		A3C_TEMP_CONDITION = ["GOCODE","D"]; //~~ THIS CAN BE PRETTIER. DON"T PURPOSELY SET VALUE TO BE OVERRIDEN BY FUNC
		[0] call A3C_ui_mapOverlay_fnc_UFSB_onConditionButton;
	};
};




if ((A3C_TEMP_ACTION select 0) == "SUPPRESSION") then { //~~this can also be prettier, combine this and ove "SUPPRESSION" checks
	private ["_polygon","_dirTo","_countInd","_root","_u"];
	_u = A3C_SELECTED_UNITS select 0;
	_countIn = (count (_u getvariable "A3C_PLOT_TEMP")  ) -1;
	_root = [_u,0,_countIn] call A3C_ui_mapOverlay_fnc_squad_findLastWaypointWithoutPolygon;
	_dirTo = [_root,A3C_CLICKPOS_ORIG] call BIS_fnc_dirTo; //~~ get last smokeless WP of A3C_SELECTED_UNITS select 0

	_polygon = ([[A3C_CLICKPOS_ORIG,A3C_TEMP_WP_ID_MAIN]] + ([A3C_CLICKPOS_ORIG,_dirTo,"SUPPRESSION",true] call A3C_ai_shared_fnc_polygonAreaCreate));

	A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
	{
		private ["_var"];

			_var = _x getvariable ["A3C_UNIT_POLYS",[]];
			_var pushback _polygon;
			_x setvariable ["A3C_UNIT_POLYS",_var,true];
	} foreach A3C_SELECTED_UNITS;
};



(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_WPACTION_IMG) ctrlSetTextColor [1,1,1,1];
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
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_WPACTION_IMG) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_WPACTION_BTN) ctrlSetToolTip "No Action || Use LMB to open settings or mousewheel to cycle";
	//};
};

