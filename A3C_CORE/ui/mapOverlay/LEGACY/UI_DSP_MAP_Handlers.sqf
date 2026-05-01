#include "..\..\SHARED\shared_ui_defines.hpp"








A3C_UI_MAP_onOnMouseMoving_Main = {
	
	if (isNull findDisplay 100020) then {
		// player commandChat "A3C_UI_MAP_onOnMouseMoving_Main";
		A3C_MAP_X = _this select 1;
		A3C_MAP_Y = _this select 2;
	};
};




A3C_UI_MAP_onKeyDown_Map = { //-- This handler is needed because ESC behaves differently than ALL other keys
	params ["_mapControl","_key","_shift","_ctrl","_alt"];

	/*-------------------------------------------------------------
	This keybind is my current fix for what I believe to be Arma 3 quirks:

	1.  Arrow keys used for vehicle remote do not seem to register at all in keyDown event attached to dialog itself.
		They do register in the main map display.
		>> Strangely enough, keyUp registers fine. So for arrows (and the block with pageUp/Down) only triggers
		>> For the record, it's totally possible that I create this circumstance somewhere :)

	2.  In order to be able to use ESC key when closing popup menus (GP/WP Context menu) without closing entire map
		has to be added to the map directly. 'if (_key == 1) exitWith {true};' only works on main map
	
	The reason why I still keep _Map and _Overlay handlers separate is simply organization, and might be merged into the _Map addEventHandler

	*///-----------------------------------------------------------

	

	// player sidechat format ["Display %1, A3C_UI_MAP_onKeyDown_Map - %2 %3",_mapControl, keyName (_this select 1), round time];

	
	private _blockDefault = false;

	//-- Note: So far we do not need to check if keybind is allowed, might change later.
	//-- Reason: Vehicle remote allows repeated bind firing.

	switch (true) do {
		case (_key == 1) : {
			private _display = findDisplay 100020;
			private _groupContextmenuHC = _display displayCtrl IDC_MAP_HCGP_Parent;
			private _groupDashboardHC = _display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT;
			private _wpContextmenuHC = _display displayCtrl IDC_MAP_HCGP_WP_Parent;
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
		};
		case 
		(
			a3c_is_HC_remote
			&& {_key in [200,203,205,208]}
		) :
		{
				_this call A3C_UI_SHARED_onKeyDown_remoteVehicle;
				_blockDefaultKey = true;
		};
	};
	_blockDefault
};




///--- RELATED HELPERS / EXTENSIONS

//-- A3C_MMCode Helpers:
A3C_UI_MAP_onMouseDrag = {
	if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};


	_sx = _this select 1;
	_sy = _this select 2;
	private _a3c_dsp = 100020;
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


	if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};



	private _a3c_dsp = 100020;
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

	if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};
	params ["_data","_item","_mode","_ctrl","_alt"];
	private ["_mode","_cI","_markerDir","_rPos","_dMark","_polygon","_var","_t","_exit"];


	//systemchat str _item;
	_sx = _data select 1;
	_sy = _data select 2;

	private _a3c_dsp = 100020;
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
						if (((_x select 0) select 1) == A3C_MovedItem_ID) exitWith {
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

				if (_isTargetWP) exitWith {
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
										if (((_x select 0) select 1) == A3C_MovedItem_ID) exitWith {
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
	private _a3c_dsp = 100020;
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


	if ((_this select 1) == 1) exitWith {}; //-- exit if rmb was used to enable mapdrag
	_sx = _this select 2;
	_sy = _this select 3;
	_isLoop = false;
	_units = [];
	_checkVar = "A3C_PLOT_TEMP";
	_dragMode = "LOOP";
	private _a3c_dsp = 100020;
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

	if (_exit) exitWith {};


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
