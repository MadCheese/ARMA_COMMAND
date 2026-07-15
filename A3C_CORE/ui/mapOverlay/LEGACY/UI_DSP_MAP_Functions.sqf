#include "..\..\SHARED\shared_ui_defines.hpp"


#include "..\dialog_defines.hpp"
#include "..\script_component.hpp"

if (isDedicated) exitWith {};




















//--------------------------  I N T E R F A C E   O P E R A T I O N :   C O N T R O L   ---------
//---------------------------------------------------------------------------------------------------
//--------------------------    functions for changing circumstances    -----------------------



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
	private _a3c_dsp = IDD_MAP_OVERLAY;
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

			_formdir = [_formdir] call MCSS_fnc_correctDir;

			if (A3C_FORMMODE_TEMP == 4) then {
				if (A3C_SPLIT_UNITS isEqualTo A3C_Selected_Units) then {
					A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1;
				};
				_wpSyncData = [[A3C_SYNC_INDEX,false]];
				A3C_WAYPOINTS_TEMP = A3C_WAYPOINTS_TEMP + [[[(A3C_SPLIT_UNITS select 0)],A3C_TEMP_WP_ID_MAIN,A3C_TEMP_WP_ID_SUB,A3C_FORMMODE_TEMP]];
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
			A3C_TEMP_CONDITION set [1,(parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP)))];
			A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP)));
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
						A3C_CLICKPOS_1 = A3C_TAB_BUILDING buildingPos ([_x,A3C_SELECTED_UNITS] call MCSS_fnc_getArrayIndex);
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
											_prms = [((_cl select 0) select 0),_collider] call A3C_UI_squadPlacement_fnc_snapFormation;
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
		A3C_DIAG_SPACING = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_SPACING)));
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
		[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
	} else {
		[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
	};

};

//-- function for the execute button. Assigns all orders created in planning stage
A3C_Btn_fnc_Execute = {
	params ["_mode"];

	private _addressedUnits = if (_mode == "ALL") then {A3C_ORDER_UNITS} else {A3C_SELECTED_UNITS};
	//A3C_MARKERS = A3C_MARKERS + A3C_MARKERS_TEMP;
	//A3C_MARKERS_TEMP = [];
	A3C_DIAG_ACTIVE = false;
	A3C_ui_mapOverlay_fnc_UFSB_onUndoButton_MODE = 0; // 0 means undo WP, 1 means undo SYNC
	//-- A3C_USERACTION: Array to contain data input information used in Undo function. passed as [_inputIndex,_InputType,_syncWPindex]
	//-- _inputType: 0 == Waypoint Entry , 1 == Sync Entry
	A3C_USERACTION = [];
	A3C_USERACTION_ID = 0;
	private _a3c_dsp = IDD_MAP_OVERLAY;

	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow false;
	(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor  [1,1,1,0.2];
	{
		private ["_data"];
		_u = _x;
		_data = (_u getvariable ['A3C_PLOT_TEMP',[]]);


		if !(isplayer _u) then {
			if ((count (_u getvariable ["A3C_PLOT",[]])) == 0) then {
				_x setvariable ["A3C_PLOT",((_x getvariable "A3C_PLOT") + _data),true];

				_script = [_u,(_u getvariable ['A3C_PLOT',[]])] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

			} else {
				_u setvariable ["A3C_PLOT",((_x getvariable "A3C_PLOT") + _data),true];
			};
			_x setvariable ["A3C_PLOT_TEMP",[],true];
		};
	} foreach _addressedUnits;
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
	private _a3c_dsp = IDD_MAP_OVERLAY;
	

	private _units = [];
	private _data = [];
	private _funcSQ = {
		private ["_soldier","_mode","_marker","_return","_data"];
		_soldier = _this select 0;
		_mode = _this select 1;
		_marker = _this select 2;
		_return = false;
		_data = [];
		private _a3c_dsp = IDD_MAP_OVERLAY;

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
							case "DOWN" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
							case "MIDDLE" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
							case "UP" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
						};
						switch (_wpStances select 1) do {
							case "DOWN" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";};
							case "MIDDLE" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";};
							case "UP" : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";};
						};

					};
					if (_mode == "HELI") then {
						switch (_wpFlyInHeight) do {
							case (200) : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";};
							case (75) : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";};
							case (25) : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";};
							case (5) : {(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";};
						};
						switch (_wpAction select 1) do {
							case "NONE" : {
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.8] call A3C_UI_fnc_setOpacity);
							};
							case "PICKUP" : {
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
							};
							case "DROPOFF" : {
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
							};
							case "RAPPEL" :{
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
							};
							case "LANDFINAL" : {
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
							};
							case "PARADROP" : {
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
							};
						};
					};
					if (_wpSpeed == 2) then {
						(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Speed_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
					} else {
						(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Speed_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
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
	lbClear (findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo);
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlSetPosition [_sx, _sy];
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlCommit 0;
	if (_mode == "HELI") then {
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlShow true;
		A3C_LB_MODE = 0;
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlSetPosition [_sx, _sy];
		(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlCommit 0;

		[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "NONE"] call A3C_ui_shared_fnc_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "PICKUP"] call A3C_ui_shared_fnc_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "DROPOFF"] call A3C_ui_shared_fnc_addLbEntry;
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "LANDFINAL"] call A3C_ui_shared_fnc_addLbEntry;
		if (A3C_IsRappel) then {
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "RAPPEL"] call A3C_ui_shared_fnc_addLbEntry;
		};
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "PARADROP"] call A3C_ui_shared_fnc_addLbEntry;

		

		_paraSel = if (A3C_IsRappel) then {5} else {4};
		
		switch (markertype A3C_MARKERTOSWITCH) do {
			case ('A3C_Marker_WAYPOINT') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 0] call A3C_ui_shared_fnc_lbSetCurSel;};
			case ('A3C_Marker_PICKUP_AIR') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 1] call A3C_ui_shared_fnc_lbSetCurSel;};
			case ('A3C_Marker_DROPOFF_AIR') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 2] call A3C_ui_shared_fnc_lbSetCurSel;};
			case ('A3C_Marker_LANDING') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 3] call A3C_ui_shared_fnc_lbSetCurSel;};
			case ('A3C_Marker_RAPPEL') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 4] call A3C_ui_shared_fnc_lbSetCurSel;};
			case ('A3C_Marker_Paradrop') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, _paraSel] call A3C_ui_shared_fnc_lbSetCurSel;};

		};
		
	};
	A3C_CHECKVAR = "A3C_PLOT_TEMP";
	

	


	if (_mode == "INF") then {
		if ((count _units) > 0) then {
			A3C_GCUNITS = _units;
			A3C_MARKERTOSWITCH = _marker;
			lbClear (findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo);
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlShow true;
			A3C_LB_MODE = 2;
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlSetPosition [_sx, _sy];
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlCommit 0;

			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "NONE"] call A3C_ui_shared_fnc_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "A"] call A3C_ui_shared_fnc_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "B"] call A3C_ui_shared_fnc_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "C"] call A3C_ui_shared_fnc_addLbEntry;
			[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, "D"] call A3C_ui_shared_fnc_addLbEntry;

			if ( (markertype A3C_MARKERTOSWITCH) == "A3C_Marker_BUILDING") then {
				A3C_TAB_BUILDING = (nearestBuilding (getmarkerpos A3C_MARKERTOSWITCH));
				for "_i" from 0 to ([A3C_TAB_BUILDING] call MCSS_fnc_getLastBuildingPosIndex) do {
					[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, format ["BPos %1",_i]] call A3C_ui_shared_fnc_addLbEntry;
				};
			};
			
			switch (_markertype) do { //~~ #BUG - markertype always, "", will ALWAYS use default :S
				case ('A3C_Marker_GoCode_A') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 1] call A3C_ui_shared_fnc_lbSetCurSel;};
				case ('A3C_Marker_GoCode_B') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 2] call A3C_ui_shared_fnc_lbSetCurSel;};
				case ('A3C_Marker_GoCode_C') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 3] call A3C_ui_shared_fnc_lbSetCurSel;};
				case ('A3C_Marker_GoCode_D') : {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 4] call A3C_ui_shared_fnc_lbSetCurSel;};
				default {[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 0] call A3C_ui_shared_fnc_lbSetCurSel;};
			};
			
		};
	};
	lbClear (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent);
	if ((count _units) == 1) then {
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent, "NONE"] call A3C_ui_shared_fnc_addLbEntry;
		_data =  (_units select 0) getvariable A3C_CHECKVAR;
		_wpInd = ( ((_units select 0) getvariable "A3C_CURRENTWAYPOINT_INDEX") - 1 );
		[findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent, 1] call A3C_ui_shared_fnc_lbSetCurSel;
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
		private _a3c_dsp = IDD_MAP_OVERLAY;
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
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Speed_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
							} else {
								_x set [8,-1];
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Speed_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
							};
						};
						case ("STANCE1") : {
							switch (_wpStances select 0) do {
								case ("DOWN") : {
									(_x select 4) set [0,"UP"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											_unit SetUnitPos "UP";
									};
								};
								case ("MIDDLE") : {
									(_x select 4) set [0,"DOWN"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											_unit SetUnitPos "DOWN";
									};
								};
								case ("UP") : {
									(_x select 4) set [0,"MIDDLE"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
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
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
									};
								case ("MIDDLE") : {
									(_x select 4) set [1,"DOWN"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
								};
								case ("UP") : {
									(_x select 4) set [1,"MIDDLE"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
								};
							};
						};
						case ("HEIGHT") : {
							switch (_wpFlyInHeight) do {
								case (200) : {
									_x set [9,75];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 75;
									};
								};
								case (75) : {
									_x set [9,25];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 25;
									};
								};
								case (25) : {
									_x set [9,5];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
									if ([_unit,_var,_forEachIndex] call _isCurrent) then {
											(vehicle _unit) flyInHeight 5;
									};
								};
								case (5) : {
									_x set [9,200];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
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
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_PICKUP_AIR","DEFAULT"] call MCSS_fnc_SwitchMarker;

									[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 1] call A3C_ui_shared_fnc_lbSetCurSel;
								};
								case ("PICKUP") : {
									(_x select 2) set [1,"DROPOFF"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_DROPOFF_AIR","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 2] call A3C_ui_shared_fnc_lbSetCurSel;
								};

								case ("DROPOFF") : {
									if (A3C_IsRappel) then {
										(_x select 2) set [1,"RAPPEL"];
										(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
										(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
										[A3C_MARKERTOSWITCH,"A3C_Marker_Rappel","DEFAULT"] call MCSS_fnc_SwitchMarker;
										[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 4] call A3C_ui_shared_fnc_lbSetCurSel;
									} else {
										(_x select 2) set [1,"LANDFINAL"];
										(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
										(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
										[A3C_MARKERTOSWITCH,"A3C_Marker_LANDING","DEFAULT"] call MCSS_fnc_SwitchMarker;
										[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 3] call A3C_ui_shared_fnc_lbSetCurSel;
									};

								};
								case ("RAPPEL") : {
									(_x select 2) set [1,"LANDFINAL"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor [1,1,1,1];
									[A3C_MARKERTOSWITCH,"A3C_Marker_LANDING","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 3] call A3C_ui_shared_fnc_lbSetCurSel;
								};
								case ("LANDFINAL") : {
									(_x select 2) set [1,"NONE"];
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlsettext "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
									(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG) ctrlSetTextColor ([A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_fnc_setOpacity);
									[A3C_MARKERTOSWITCH,"A3C_Marker_WAYPOINT","DEFAULT"] call MCSS_fnc_SwitchMarker;
									[findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Combo, 0] call A3C_ui_shared_fnc_lbSetCurSel;
								};
							};
						};
						case ("DELETE") : {

							if !((markertype A3C_MARKERTOSWITCH) == 'A3C_Marker_HCWP') then { //~~ is this condition still needed since no more HC markers are used??
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;
								if ([_unit,_var,_forEachIndex] call _isCurrent) then {
									[[_unit],false,true,true] spawn A3C_AI_Shared_cancelUnitPlot;
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



A3C_UI_MAP_FNC_CTEDIT_ACTIVATE_DASHBOARD = {
	params ["_mode"];



	if (isNull (findDisplay IDD_MAP_OVERLAY)) exitWith {}; //-- only map variant has CT Edit

	private _textCtrl = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPNAME;
	private _editCtrl = findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT;
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
	
	if (isNull (findDisplay IDD_MAP_OVERLAY)) exitWith {}; //-- only map variant has CT Edit
	
	if (_mode == "ON") then {
		A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = true;
		A3C_BOOL_CT_SPACING = true; A3C_BOOL_DISABLEMAPCTRL = true; (findDisplay 12 displayCtrl 51) ctrlEnable false;
	} else {
		A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = false;
		A3C_BOOL_CT_SPACING = false; A3C_BOOL_DISABLEMAPCTRL = false; (findDisplay 12 displayCtrl 51) ctrlEnable true;
		switch (_controlType) do {
			case ("TIMEOUT") : {
				if ((A3C_TEMP_CONDITION select 0) == "TIMEOUT") then {
					A3C_TIMEOUT_VAL = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP)));
				};
			};
			case ("SPACING") : {
				//systemchat 'spacingf';
				switch (A3C_MAP_CommandMode) do {
					case ("INF") : {
						A3C_SPACING_INF = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_SPACING))) max 2;
					};
					case ("AIR") : {
						A3C_SPACING_AIR = (parsenumber (ctrlText (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_SPACING))) max 30;
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
	private _a3c_dsp = IDD_MAP_OVERLAY;

	private _map1 = findDisplay 12 displayCtrl 51;
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

//-- ABORT ALL EXISTING ORDERS
//-- REMINDER: IN ORDER TO CONTINUE WITH NEW PLOT, YOU FIRST NEED TO WAITUNTIL PLOT IS EMPTY
//-->> so after [xy] call A3C_AI_Shared_cancelUnitPlot, you need waituntil {_unit getvariable ["A3C_PLOT", []] isEqualTo []}
A3C_AI_Shared_cancelUnitPlot = {
	private ["_data"];
	if (A3C_MAP_CommandMode == "HC") exitWith {};
	_selectedUnits = _this select 0;
	_shift = _this select 1;
	_ctrl = _this select 2;
	
	private _a3c_dsp = IDD_MAP_OVERLAY;
	

	_data = [];

	if ( !(_shift) && !(_ctrl)  ) exitWith {
		{
			_x setvariable ["A3C_PLOT_TEMP",[],true];
		} foreach _selectedUnits;
		A3C_USERACTION = [];
		A3C_USERACTION_ID = 0;
		A3C_WAYPOINTS_TEMP = [];
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow false;
		(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor  [1,1,1,0.2];
		[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
	};
	
	if (_shift) then {

		{
			
			_x setvariable ["A3C_PLOT_TEMP",[],true];
			A3C_USERACTION = [];
			A3C_USERACTION_ID = 0;
			A3C_WAYPOINTS_TEMP = [];
			(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_BTN) ctrlShow false;
			(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_UFSB_UNDO_IMG) ctrlSetTextColor  [1,1,1,0.2];

			[_x,(position _x)] call A3C_ai_shared_fnc_doMove;
			[_x] spawn {
				params ["_unit"];
				private ["_mainMark","_subMark","_dirMark"];
				private _a3c_dsp = IDD_MAP_OVERLAY;

				private _unitPlot = _unit getVariable ["A3C_PLOT",[]];
				if (count _unitPlot > 0) then {
					_unit setvariable ["A3C_ABORT_Data",[true,false],true];
					waitUntil {count (_unit getVariable ["A3C_PLOT",[]]) == 0};
				};
				//-- reset abort variable after clearing
				_unit setvariable ["A3C_ABORT_Data",[false,false],true];
			
				//
				_unit setvariable ["A3C_PLOT_TEMP",[],true];
				{_unit enableAI _x} foreach ["MOVE","TARGET","AUTOTARGET","FSM","AUTOCOMBAT"]; //,"THREAT_PATH","PATHPLAN"
				[(vehicle _unit),"UNLOCKED"] remoteExec ["setvehicleLock", (vehicle _unit)];
				_unit forceSpeed -1;
				if !(isnull objectparent _unit) then {(vehicle _unit) limitspeed 1000;};
			};
		} foreach _selectedUnits;
	};
	//_sleep = 0;
	if (_ctrl) then {
		{

			private ["_isLoop","_unit","_data"];
			_unit = _x;
			_data = (_x getVariable "A3C_PLOT");

			{
				private ["_wpData"];
				_wpData = _x;
				if ( _forEachIndex ==  ((_unit getVariable "A3C_CURRENTWAYPOINT_INDEX") -1)) then {
					if !([_data,_forEachIndex] call A3C_ui_mapOverlay_fnc_isWaypointLoop) then {
						{deleteMarkerLocal _x} foreach (_wpData select 1);
					};
				};
			} foreach _data;
			/*
			_isLoop = false;
			if ((_data select ((_x getVariable "A3C_CURRENTWAYPOINT_INDEX") -1) select 10) > -1) then {
				{
					if ((_x select 10) < -1) then {_isLoop = true};

					if (_isLoop) then {
						{
							deleteMarkerLocal _x
						} foreach (_x select 1);
					};
					if ((_x select 10) > -1) then {_isLoop = false};
					_x set [8,-1]; //-- reset unit speed??
				} foreach _data;
				_x setVariable ["A3C_PLOT",_data,true];
			};
			*/
			_x setvariable ["A3C_ABORT_Data",[false,true],true]; //-- this will make the unit skip wp
		} foreach _selectedUnits;
		//_sleep = 0.5;
	};
	[] spawn {
		sleep 0.5;
		[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;
	};
	
};


//-- author note: move to A3C_UI_MAP_Main_init.sqf
A3C_GET_OPAC = {
	_return = _this select 0;
	_obj = _this select 1;
	_index = _this select 2;
	_return = _return select [0,3];
	_op = 1;
	if (visibleMap) then {
		if (isNull (findDisplay IDD_MAP_OVERLAY)) then {
			_op = 0;
		};
	};

	if (_op == 0) then {
		if (difficulty <=1) then {
			_op = 1;
		};
	};

	_return pushback _op;
	_return

};


