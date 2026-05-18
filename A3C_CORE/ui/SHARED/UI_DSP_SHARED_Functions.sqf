#include "shared_ui_defines.hpp"
#include "..\radial\radialMenu\script_component.hpp"
#include "..\radial\radialMenu\dialog_defines.hpp"

#include "..\mapOverlay\dialog_defines.hpp"
#include "..\mapOverlay\script_component.hpp"

#include "..\SHARED\selectionPromptPanel\dialog_defines.hpp"





A3C_LB_Change = {
	// systemchat "A3C_LB_Change";
	if (A3C_CurSel) exitWith {};

	params ["_mode","_lb","_a3c_dsp"];
	
	/*
		Currently a shared function between map and Radial.
		Radial uses it for Right Extension- and teamcolor-listboxes
		Map uses it for target assignment, Teamcolor assignment and the Squad waypoint context menu
		ToDo: Split them up For radial and Map :)

	*/

	
	//~~ #TODO: rearrange to have logical order
	//-- modes:
	//-- 0: SQ-WPContext-Heli
	//-- 1: Assign Target | Attack/Ignore (Shared by SQ & HC)
	//-- 2: SQ-WPContext-Infantry
	//-- 3: Squad-Level Teamcolor assignment
	//-- 4: used to be highcommand rejoin - removed 
	//-- 5: used to be something related to medic but never used


	private _doubleClick = false;
	if (isnil "_mode") exitWith {};





	private _btn = 0;
	private _gp = objnull;
	private _targetUnits = A3C_SELECTED_UNITS;
	if (_mode isEqualType []) then {
		_btn = _mode select 1;
		_mode = _mode select 0;
	};

	private _tickTime = (time - A3C_LB_TICKTIME);
	if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
		_doubleClick = true;
	};
	A3C_LB_TICKTIME = time;
	private _dest = switch (_mode) do {
		case (1) : {A3C_TRACKED_ENEMYGROUP};
		case (2) : {A3C_GCUNITS};
		default {objnull}; //-- for _mode in [1,3]
	};


		
	switch (_mode) do {
		case (0) : {
			[_lb] call A3C_SWITCHMARKER;
		};
		case (1) : {
			{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [IDC_MAP_DynamicCombo,IDC_MAP_SQWP_Parent];
			if (count A3C_SELECTED_UNITS > 0) then {
				if (typeName (A3C_SELECTED_UNITS select 0) == "GROUP") then {

					{
						{
							_soldier = _x;
							_target = objNull;
							if ((count units _dest) >= (_foreachIndex + 1)) then {
								_target = ((units _dest) select _forEachIndex);
							} else {
								_target = ((units _dest) select 0);
							};
							if (_lb == 1) then {
								[
									[_soldier, _target],
									{
										params ["_soldier","_target"];
										_soldier reveal [_target,4];
										_soldier commandTarget _target;
										_soldier commandFire _target;
									}
								] remoteExec ['bis_fnc_spawn', _soldier];
								
								
							};

						} foreach (units _x);
						player groupChat format ["%1 - target that enemy!",groupID _x];
					} foreach A3C_SELECTED_UNITS;
				} else {
					{
						_un = _x;

						if (   ({_un in (vehicle _x)} count A3C_SELECTED_UNITS) > 0) then {
							if !(_x in _targetUnits) then {
								if ( ((assignedVehicleRole _x) select 0) == "Turret") then {
									if ((count ((vehicle _un) weaponsTurret ((assignedVehicleRole _un) select 1))) > 0) then {
										_targetUnits pushback _x;
									};
								};
							};
						};
					} foreach units group player;
					{
						_soldier = _x;
						_target = objnull;
						if ((count units _dest) >= (_foreachIndex + 1)) then {
							_target = ((units _dest) select _forEachIndex);
						} else {
							_target = ((units _dest) select 0);
						};
						_soldier reveal [_target,4];
						if (_lb == 0) then {
							if ((assignedTarget _soldier) in (units _dest)) then {
								_soldier dotarget _objnull;
								_soldier lookAt objnull;
								_soldier doWatch objnull;
							};
						} else {
							_soldier commandtarget (vehicle _target);
							_soldier lookAt (vehicle _target);
							_soldier doWatch (vehicle _target);
						};
					} foreach _targetUnits;
				};
			};
		};
		case (2) :{
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;
			_lb call A3C_GoCode_Switch;
		};
		case (3) : {
			_units = [_dest];
			_color = "MAIN";
			
			_backCol = [1,1,1,1];
			_isMap = (!isNull (findDisplay IDD_MAP_OVERLAY));



			_compare = if (_isMap) then {A3C_SELECTED_UNITS} else {A3C_RD_UNITS};
			if (_dest in _compare) then {
				{_units pushback _x} foreach _compare - [_dest];
			};
			switch (_lb) do {
				case (0) : {
					_color = "RED";
					_backCol = [A3C_UI_COLOR_RED,1] call A3C_UI_fnc_setOpacity;
				};
				case (1) : {
					_color = "GREEN";
					_backCol = [0,1,0,1];
				};
				case (2) : {
					_color = "BLUE";
					_backCol = [A3C_UI_COLOR_BLUE,1] call A3C_UI_fnc_setOpacity;
				};
				case (3) : {
					_color = "YELLOW";
					_backCol = [A3C_UI_COLOR_YELLOW,1] call A3C_UI_fnc_setOpacity;
				};
				case (4) : {
					_color = "MAIN";
					_backCol = [1,1,1,1];
				};
			};

			{

				_x assignTeam _color;
				_x setVariable ["A3C_ASSIGNEDTEAM",_color];
				private _treeVar = _x getVariable ["A3C_TREESEL_INDEX",[]];
				if (count _treeVar > 0) then {
					private _btn = _treeVar select ((count _treeVar) -1); //-- make sure we fetch the sub-button
					private _ct_tree1 = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
					_ct_tree1 tvSetColor [_btn,_backCol];
				};
			} foreach _compare;

			if (_isMap) then {
				{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [IDC_MAP_DynamicCombo,IDC_MAP_SQWP_Parent];
			} else {
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;
				//-- to do: update tree!
			};
			[_a3c_dsp,A3C_MAP_CommandMode] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
			[] spawn {
				sleep 0.1;
				[0] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;
			};
		};

		//-- 4 and 5 removed

		case (6) : {
			//-- medic
			//systemchat "triggered";
			private _medics = (group player) getVariable ["A3C_MEDICS",[]];
			if (_lb >= 0) then {
				private _medics_lb = [];
				if ((_lb == 0) && ((count _medics) > 1) ) then {
					_medics_lb = _medics
				} else {
					if ((count _medics) > 1) then {
						_medics_lb = [(_medics select (_lb - 1))];
					} else {
						_medics_lb = [(_medics select 0)];
					};
				};
				(group player) setVariable ["A3C_MEDICS_LB",_medics_lb];
			};
		};
		case (7) : {
			//-- patient
			//-- default: all patients - to be overridden by single selections
			private _patients = (group player) getVariable ["A3C_PATIENTS",[]];
			
			if (_lb >= 0) then {
				private _patients_lb = [];
				if ((_lb == 0) && ((count _patients) > 1) ) then {
					_patients_lb = _patients;
				} else {
					if ((count _patients) > 1) then {
						_patients_lb = [(_patients select (_lb - 1))];
					} else {
						_patients_lb = [(_patients select 0)];
					};
				};
				private _lbMin = if (lbSize (findDisplay _a3c_dsp displayCtrl 8055) == 1) then {0} else {1};
				
				if (_doubleClick && (_lb >= _lbMin)) then { //-- lb > 0 means 'heal all' was not selected :)
					//-- double click: cancel for individual unit
					private _patient = _patients select (_lb - 1);
					// systemchat format ["Double click - patients: %1", _patient];
					_patient setVariable ["A3C_AbortHealing", true];
					
					{
						private _evaluatedPatients = (group player) getVariable[_x, [] ];
						_evaluatedPatients = _evaluatedPatients - [_patient];
						(group player) setVariable [_x, _evaluatedPatients];
						
					} foreach ["A3C_PATIENTS_ASSIGNED", "A3C_PATIENTS_DESIGNATED"]; //"A3C_PATIENTS_LB", 
					systemchat format ["HEALING CANCELLED FOR %1", name _patient];
					[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
					
					

				} else {
					//-- single click: select individual unit
					(group player) setVariable ["A3C_PATIENTS_LB", _patients_lb];
				};
				
			};
		};
		case (8) : {
			//-- LB 1
			if (_lb >= 0) then {
				
					//systemchat '11';
					A3C_TARGETVEH = A3C_VEHSAV select _lb;
					
					["VEHICLES",1] call A3C_UI_RADIAL_LABEL_LB;
					
					
				
			};
		};
		case (9) : {
			//-- LB 2
			if (_lb >= 0) then {
				
					// insert function here
				
			};
		};
		case (10) : {
			[_lb] call A3C_Rearm_LBChange_Source;
		};
		case (11) : {
			[_lb, _doubleClick] call A3C_Rearm_LBChange_SourceContent;
		};
		case (12) : {
			
				_mode = switch _lb do {
					case 0 : {"CARELESS"};
					case 1 : {"SAFE"};
					case 2 : {"AWARE"};
					case 3 : {"COMBAT"};
					case 4 : {"STEALTH"};
				};
				{
					[_x,["BEHAVIOUR",_mode]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			
		};
		case (13) : {
			
				_mode = switch _lb do {
					case 0 : {"BLUE"};
					case 1 : {"GREEN"};
					case 2 : {"WHITE"};
					case 3 : {"YELLOW"};
					case 4 : {"RED"};
				};
				{
					[_x,["COMBATMODE",_mode]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			
		};
	};
};

//-- Activate a GoCode
//-- Used by Radial and Tablet
A3C_ACTIVATEGOCODE = {
	_code = _this select 0;
	private _a3c_dsp = IDD_MAP_OVERLAY;
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [IDC_MAP_DynamicCombo,IDC_MAP_SQWP_Parent];
	_ctrls = switch (_code) do {
		case ("A") : {[IDC_MAP_Order_GoCode_A_IMG,IDC_MAP_Order_GoCode_A_BTN]};
		case ("B") : {[IDC_MAP_Order_GoCode_B_IMG,IDC_MAP_Order_GoCode_B_BTN]};
		case ("C") : {[IDC_MAP_Order_GoCode_C_IMG,IDC_MAP_Order_GoCode_C_BTN]};
		case ("D") : {[IDC_MAP_Order_GoCode_D_IMG,IDC_MAP_Order_GoCode_D_BTN]};
	};
	call compile format
	[
		"
			[] spawn {
				A3C_GoCode_Activate_%1 = true;
				if (%2) then {
					publicVariable 'A3C_GoCode_Activate_%1';
				};
				sleep 2.1;
				A3C_GoCode_Activate_%1 = false;
				publicVariable 'A3C_GoCode_Activate_%1';
				if (%2) then {
					publicVariable 'A3C_GoCode_Activate_%1';
				};
			};
		",
		(parseText _code),
		{["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) > 0
	];
	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach _ctrls;
	if (!isNil 'A3C_GOCODES_HC') then {
		//-- #TODO: find out why 'A3C_GOCODES_HC' is sometimes not defined anymore (overridden by server somehow where it's not defined? we are exiting if isDedicated above)
		A3C_GOCODES_HC = A3C_GOCODES_HC - [_code];
		publicVariable 'A3C_GOCODES_HC';
	};
	
	[] spawn {
		sleep 0.5;
		[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
		sleep 2;
		[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
	};
};


//-- RESET ALL GROUP SETTINGS

A3C_GROUP_RESET = {
	if (is3DEN) exitWith {};
	setGroupIconsVisible [false,false];
	private ["_units","_knowData","_recreateLogic"];
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};


	//////////////////////
	//-- EXTRAS FIRST: unflip all vehicles
	//////////////////////
	private _flipVehicles = [];
	{
		{
			if (!isNull objectParent _x) then {
				_vU = vectorUp (vehicle _x);
				_stable = (({(abs _x) > 0.5} count [(_vU select 0),(_vU select 1)] == 0) && (_vu select 2 > 0));
				if !(_stable) then {
					if !(vehicle _x isKindOf "AIR") then {
						_flipVehicles pushBackUnique (vehicle _x);
					};
				};
			};
		} foreach (units _x);
	} foreach ([(group player)] + A3C_HC_getAllGroups_Player_Current);
	{
		if (isTouchingGround _x) then {
			_x setPosASL (getPosASL _x);
			//systemchat '1';
			//_x setPos ( ((getposASL _x) select [0,2]) + [0]);
		};
	} foreach _flipVehicles;
	//////////////////////
	//////////////////////




	
	if !(player == leader group player) exitWith {};

	{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false} foreach [IDC_MAP_DynamicCombo,IDC_MAP_SQWP_Parent];
	
	private _units = (units player) - [player];
	
	A3C_REFRESHING = true;
	_hud = shownHud;
	_hud set [0,true]; //-- fix for AIS etc hiding the main game's hood

	_groupInitial = group player;
	_gpID = groupID _groupInitial;
	private _groupVarnames = _groupInitial call KK_fnc_objectVarNames;
	//systemchat str _groupVarnames;

	//-- store all things that we know about as this will be reset when unjoining units
	_knowData = [];

	{
		private _target = _x select 1;
		private _knowledge = player knowsAbout _target;

		if (_knowledge > 0) then {
			_knowData pushBack [_target, _knowledge];
		};
	} forEach (player targetsQuery [objNull, sideUnknown, "", [], 0]);





	_stayLeader = true; //if (player == (leader group player)) then {true} else {false}; //~~ assumption: entire fnc is only ever run on player group and exits if player is not leader. will always be true
	{player reveal [_x,4]} foreach units group player; //~~ why this? dying units somehow a problem
	_side = side player;
	
	_leader = leader _groupInitial;  //~~ !! given that we exit above if leader is not a player, this seems to be code residue. player will always be leader if this gets reached.


	_groupTemporary = creategroup _side;
	
	{
		[vehicle _x,"LOCKED"] remoteExec ["setvehicleLock", vehicle _x];
		private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		_x setvariable ["A3C_REFRESH_DATA",[_assignedTeam,(expecteddestination _x),(assignedvehicle _x),_x getVariable ["A3C_PLOT_TEMP",[]],_x getVariable ["A3C_PLOT",[]]],true];
		[_x] joinSilent _groupTemporary;
	} foreach _units;


	//-- Put Player back into the UNIT-1 slot
	if (_stayLeader) then {
		//if !(isMultiPlayer) then { //-- ~~ WHY NOT IN MP? Did it crash things??
			if !((player getvariable "A3C_FORMATION_INDEX") == 1) then {
				_groupNew = createGroup (side player);
				[player] joinSilent _groupNew;
				_groupNew setGroupIDGlobal [_gpID];
				deletegroup _groupInitial;
			};
		//};
	};
	

	_units joinSilent (group _leader); //-- (group _leader) is used as it could either be _groupNew or _groupInitial, depending on reshuffle occurrence
	deletegroup _groupTemporary;
	A3C_DISABLE_RADIAL = false;

	{
		_u = _x;
		_x assignTeam ((_x getvariable "A3C_REFRESH_DATA") select 0);
		_x setVariable ["A3C_ASSIGNEDTEAM",((_x getvariable "A3C_REFRESH_DATA") select 0)];

		switch (((_x getvariable "A3C_REFRESH_DATA") select 1) select 1) do {
			case ("LEADER PLANNED") : {
				if (_x == (driver (vehicle _x))) then {
					if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(((_x getvariable "A3C_REFRESH_DATA") select 1) select 0)] call A3C_ai_shared_fnc_doMove;
					};
				};
			};
			case ("DoNotPlan") : {
				if (_x == (driver (vehicle _x))) then {
					//if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(position (vehicle _x))] call A3C_ai_shared_fnc_doMove;
					//};
				};
			};
			case ("VEHICLE PLANNED") : {
				if (_x == (driver (vehicle _x))) then {
					[(vehicle _x),"LOCKED"] remoteExec ["setvehicleLock",(vehicle _x)];
					if !(_x getvariable ["A3C_HOLD",false]) then {
						[_x,(((_x getvariable "A3C_REFRESH_DATA") select 1) select 0)] call A3C_ai_shared_fnc_doMove;
					};
					_x assignasdriver (vehicle _x);
					(vehicle _x) spawn {
						sleep 5;
						[_this,"UNLOCKED"] remoteExec ["setvehicleLock", _this];
					};
				};
			};
		};


		_x setdestination ((_x getvariable "A3C_REFRESH_DATA") select 1);
		if !(isnull ((_x getvariable "A3C_REFRESH_DATA") select 2)) then {
			if !(_x in ((_x getvariable "A3C_REFRESH_DATA") select 2)) then {
				_x assignAsCargo ((_x getvariable "A3C_REFRESH_DATA") select 2);
				[_x] allowGetIn true;
				[_x] ordergetin true;
				//if ( (_x == (driver (vehicle _x))) && !(isnull objectparent _x) ) then {
				//	player commandchat "ALARM";
				//};
			};
		};
		[_u] call A3C_main_fnc_setVehicleVarname;
		//_x spawn {
		//	sleep 1;
		//	systemchat str ((_this getvariable "A3C_REFRESH_DATA") select 4);
		//	_this setVariable ["A3C_PLOT_TEMP",(_this getvariable "A3C_REFRESH_DATA") select 3,true];
		//	_this setVariable ["A3C_PLOT",(_this getvariable "A3C_REFRESH_DATA") select 4,true];
		//};
		//_x setVariable ["A3C_PLOT_TEMP",(_x getvariable "A3C_REFRESH_DATA") select 3,true];
		//_x setVariable ["A3C_PLOT",(_x getvariable "A3C_REFRESH_DATA") select 4,true];

	} foreach _units;
	{
		//if (isNull (_x getVariable [")) then {
			[_x] call A3C_UNIT_INIT;
		//};
		if (profileNameSpace getVariable "A3C_SKILL_VAR") then {_x setskill 1};
	} foreach (units group player);
	profileNamespace setvariable ["A3C_GROUPUNITS",(units group player)];
	

	{_x setvariable ["A3C_FORMATION_INDEX", [_x] call A3C_GETUNITINDEX, true];} foreach (units group player);
	
	if (_stayLeader) then {(group player) selectLeader player};


	
	if (A3C_MAP_CommandMode == "HC") then {
		if ((count A3C_HC_getAllGroups_Player_Current ) > 0) then {
		} else {
			A3C_MAP_CommandMode = "INF";
			["INF"] call A3C_UI_MAP_UFSB_ApplyMode;
		};
	};

	{
		player reveal [(_x select 0),(_x select 1)];
	} foreach _knowData;
	_units spawn {
		sleep 3;
		{
			[(vehicle _x),"UNLOCKED"] remoteExec ["setvehicleLock", (vehicle _x)];
		} foreach _this;
	};
	{
		_marker = _x;
		_delete = true;
		{
			_vari = _x;
			{
				_soldier = _x;
				_data = _soldier getvariable _vari;
				{
					if (_marker in (_x select 1)) then {
						_delete = false
					};
				} foreach _data;
		 	} foreach ((units group player) - [player]);
		} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
		if ({_marker in (_x select 2)} count A3C_ALL_POLYS > 0) then {_delete = false};
		if (_delete) then {
			deleteMarkerLocal _x;
		};
	} foreach A3C_MARKERS;

	

	
	//-- re-issue group varnames
	{
		call compile format ["%1 = group player",_x]
	} foreach _groupVarnames;

	A3C_UNITCOUNTER = count (units player);

	if (isMultiPlayer) then {
		{
			[_x,(_x getvariable "A3C_REFRESH_DATA") select 0] spawn {
				params ["_unit","_c"];
				sleep 0.5;
				_unit assignTeam _c;
				_unit setVariable ["A3C_ASSIGNEDTEAM",_c];
			};
		} foreach _units;
	}; //~~ this bit seems like a security residue from the rockapes mp-crashes??

	{
		{
			private _veh = (vehicle _x);
			private _vU = vectorUp _veh;
			private _stable = {(abs _x) > 0.5} count [(_vU select 0),(_vU select 1)] == 0;

			if !(_stable) exitWith {
				//_veh setPos (((position _veh) select [0,2]) + [0]);
				if (isTouchingGround _veh) then {
					_veh setPosASL (getPosASL _veh);
				};
			};
		} foreach (units _x);
	} foreach ([group player] +  A3C_HC_getAllGroups_Player_Current);
	if (player == driver vehicle player) then {
		[] spawn {
			sleep 1;
			player doFollow player;
			if (currentCommand player == "STOP") then {
				player doMove (position vehicle player); //-- what does this do again?
				player moveTo (position vehicle player);
			};
		};
	};

	[] call A3C_UI_FNC_ADD_KEYBINDS;

	[_a3c_dsp] call A3C_UI_MAP_TREE_LABEL; 

	if (behaviour player != "AWARE") then {
		player setBehaviour "AWARE";
	};
	if (combatMode player != "YELLOW") then {
		player setCombatMode "YELLOW";
	};

	//systemchat 'hey';
	
	//-- refresh map UI and HUD UI
	[] execVM "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_drawMapUI.sqf";
	[] execVM "A3C_CORE\ui\HUD\A3C_fnc_drawHudUI.sqf";



	[] spawn {
		sleep 0.5;
		A3C_REFRESHING = false;
	};
};



A3C_UI_Shared_FNC_AddDownkey = {
	//-- purpose: exclude ALT from downkey collection in order to prevent lingering in A3C_UI_DOWNKEYS
	params ["_key"];
	if (_key != 56) then {
		A3C_UI_DOWNKEYS set [count A3C_UI_DOWNKEYS, _key];
	};
};


A3C_UI_Shared_blockKeyDownEvent = {
    params ["_key"];

    if (a3c_is_HC_remote && {_key in [200,203,205,208]}) exitWith {false};
    if !(_key in A3C_UI_DOWNKEYS) exitWith {false};

    private _ob = objectParent player;
    if (
		!isNull _ob
		&& {_ob isKindOf "Helicopter"}
		&& {player == gunner _ob}
		&& {
			(inputAction "HeliCollectiveRaise") > 0
			|| {(inputAction "HeliCollectiveLower") > 0}
			|| {(inputAction "HeliRudderLeft") > 0}
			|| {(inputAction "HeliRudderRight") > 0}
		}
	) exitWith {false};

    true
};

A3C_UI_Shared_fnc_ReleaseMenuKey = {
	//-- unified function for all KeyUp handlers for RADIAL/SelectionPromptPanel Key-Release
	params ["_display"];

	private _radialDisplay = findDisplay IDD_RADIAL_MENU;
	private _hudDisplay = findDisplay 100050;
	private _mainDisplay = findDisplay 46;

	private _isRadialDisplay = _display == _radialDisplay;
	private _isHudDisplay = _display == _hudDisplay;
	private _isMainDisplay = _display == _mainDisplay;

	//-- remove key from downkeys array


	//-- close input display
	if (_isRadialDisplay) then {
		[] call A3C_UI_RADIAL_CloseDisplay;
	} else {
		if (!_isMainDisplay) then {
			_display closeDisplay 0;
		} else {
			//-- cancel grenade action if currently used
			if (!isNull A3C_GTI_UNIT) then {
				A3C_GTI_UNIT removeEventHandler ["fired", BR_A3C_TEMP_gfeh];
				A3C_GREN_MUZZLE = "";
				A3C_GTI_UNIT = objnull;
				A3C_AI_GREN_ARRAY = [];
				["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;    
			};
		};
	};

	if (_isHudDisplay) then {
		//-- HUD-Menu
		if (profileNamespace getVariable ["A3C_UI_squadPlacement_interactionSHOW_VAR", true]) then {
			if !(profileNamespace getVariable ["A3C_UI_squadPlacement_overlayIsOpen", false]) then {
				[] call A3C_UI_squadPlacement_fnc_refreshOverlay;
			};
		} else {
			("A3C_UI_squadPlacement_overlay" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
			profileNamespace setVariable ["A3C_UI_squadPlacement_overlayIsOpen", false];
		};
	} else {

		//-- Radial / SelectionPromptPanel
		if (A3C_AI_HighCommand_Action_ID != "" && { !(A3C_isHud3dTag) }) then {
			[] call A3C_UI_mainDisplay_fnc_cancelPositionalActionProcess;
			A3C_AI_HighCommand_Action_ID = "";
		};

		A3C_DISABLE_RADIAL = false;

		if (!isNull A3C_OBJECTPLACER) then {
			deleteVehicle A3C_OBJECTPLACER;
		};

		A3C_UI_RADIAL_Current_Remfire_Units = [];
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
		A3C_UI_HUD_3D_TAG_reposition = false;
	};

	//-- General
	{ player groupSelectUnit [_x, false] } forEach units player;
	showCommandingMenu "";
	{ inGameUISetEventHandler [_x, "false"] } forEach ["PrevAction", "NextAction"];
};

A3C_UI_Shared_SelectionPromptPanel_Listbox_NumberControl = {
	params ["_key", "_SelectionPromptPanelListbox"];

	private _keyValueIndex = _key - 2;
	if (_keyValueIndex >= 0 && {_keyValueIndex < lbSize _SelectionPromptPanelListbox}) then {
		sleep 0.1;
		[_SelectionPromptPanelListbox, _keyValueIndex, true] call A3C_setCurSel;
	};
};

// #TODO: Dashboard fnc could do with optimization for speed

A3C_UI_SHARED_createDashBoard = {
	
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};

	(findDisplay _a3c_dsp displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT) ctrlSetTextColor [1,1,1,0]; //-- hide ct-edit box because of it's frame
	
	_ref_selected_units = A3C_SELECTED_HC_GROUPS_SETTINGS; 


	if (count _ref_selected_units == 1) then {

		//--reset box and structured text
		{
			ctrlDelete _x;
		} foreach A3C_UI_SHARED_createDashBoard_ExtraControls;
		A3C_UI_SHARED_createDashBoard_ExtraControls = [];


		_parent = (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT);

		_parent ctrlSetPosition 
		[
			(ctrlPosition _parent) select 0,
			0.414993 * safezoneH + safezoneY,
			0.240009 * safezoneW,
			0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];
		

		_backGround = (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_BG);
		_backGround ctrlSetPosition 
		[
			4.9593e-007 * safezoneW,
			0 * safezoneH,
			0.240009 * safezoneW,
			0.221018 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];
		

		_structuredText = (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED);
		_structuredText ctrlSetPosition 
		[
			0.104004 * safezoneW,
			0.136011 * safezoneH,
			0.136005 * safezoneW,
			0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];

		

		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_HEALTH_TXT) ctrlSetTextColor [1,1,1,1];
		
		if (_a3c_dsp == IDD_MAP_OVERLAY) then {

			_mapBarDims = ctrlPosition (findDisplay 12 displayctrl 1020);
			_mapBarDims params ["_mapBarX","_mapBarY","_mapBarW","_mapBarH"];
			_mapBarY = _mapBarY + _mapBarH;

			(ctrlPosition (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent)) params ["_gpX","_gpY","_gpW","_gpH"];


			_parentPos = ctrlPosition _parent;
			_parentPos set [0, _gpX - (_parentPos select 2) ];
			_parentPos set [1,_gpY]; 
			_parent ctrlSetPosition _parentPos;
		};
		_parent ctrlCommit 0;
		_backGround ctrlCommit 0;
		_structuredText ctrlCommit 0;
	
		//-- fetch group Info

		private _group = _ref_selected_units select 0;
		private _leaderVic = vehicle leader _group;
		private _isCargo = !(driver _leaderVic in units _group);
		private _groupIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\SI_stand_ca.paa";
		if (!isNull objectParent (leader _group)) then {
			_groupIcon = if (_isCargo) then {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"} else {gettext (configfile >> "CfgVehicles" >> typeof _leaderVic >> "picture")};
		};			
		private _groupID = groupID _group;
		private _location = text (((nearestLocations [position player, ["NameLocal","NameCity","NameMarine","NameVillage","StrongpointArea","NameCityCapital"], 5000]) select {!("000" in text _x)}) select 0); //((nearestLocations [position _leaderVic, ["NameLocal","NameCity","NameMarine","NameVillage","StrongpointArea","NameCityCapital"], 5000]) select {!("000" in text _x)}) select 0;
		_location = if (isNil '_location') then {
			"UNKNOWN LOCATION"
		} else {
			format ["Location: Near %1 at %2", _location, mapGridPosition (position _leaderVic)];
		};
		private _unitSize = format ["Unitsize: %1",count units _group];
		

		_bgColor = if (_a3c_dsp == IDD_RADIAL_MENU && {sunOrMoon < 1}) then {[0,0.5,0.8,0.6]} else {[0,0,0,0.6]};
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_BG) ctrlSetTextColor _bgColor;	
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED) ctrlSetBackGroundColor [0,0,0,0.2];
		
		private _currentTask = "Idle";
		
		private _actionScript = wayPointScript [_group, currentWaypoint _group];
		if (_actionScript == "") then {
			_actionScript = (waypointStatements [_group, currentWaypoint _group]) select 1;
		};
		switch (true) do {
			
			
			case ("transport unload" in toLower _actionScript) : {
				_currentTask = "Deliver Troops";
			};
			case (!(_isCargo) && {{group _x != _group} count crew _leaderVic > 0}) : {
				_currentTask = "Transporting units";
			};
			case (_isCargo) : {
				_currentTask = "In Transport";
			};
			case ("landing" in toLower _actionScript) : {
				_currentTask = "Landing Aircraft";
			};
			case ("rappel" in toLower _actionScript) : {
				_currentTask = "Rappeling Cargo";
			};
			case ("repair" in toLower _actionScript) : {
				_currentTask = "Repairing Vehicles";
			};
			case ("assemble" in toLower _actionScript) : {
				_currentTask = "Assembling Static Weapon";
			};
			case ("cas-strike" in toLower _actionScript) : {
				_currentTask = "Preparing CAS-Strike";
			};
			case ("sling load hook" in toLower _actionScript) : {
				_currentTask = "Preparing Sling-Load Hook";
			};
			case ("sling load unhook" in toLower _actionScript) : {
				_currentTask = "Preparing Sling-Load Unhook";
			};
			case ("paradrop" in toLower _actionScript) : {
				_currentTask = "Preparing Paradrop";
			};
			case ("plantexplosive" in toLower _actionScript) : {
				_currentTask = "Planting Explosives";
			};
			case ("clearbuilding" in toLower _actionScript) : {
				_currentTask = "Clearing Building";
			};
			
			case ("assemble_uav" in toLower _actionScript) : {
				_currentTask = "Setting Up UAV";
			};
			case ("overwatch" in toLower _actionScript) : {
				_currentTask = "En Route For Overwatch";
			};
			default {
				if (waypointtype [_group,currentWaypoint _group] == "MOVE") then {
					_currentTask = "Moving";
				};
			};
		};

		_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
		if (_var select 0) then {
			_currentTask = "Providing Overwatch";
		};

		_currentTask = format ["Current Task: %1",_currentTask];

		private _vehicles = [];
		private _damages_MAN = [];
		private _damages_VEHICLE = [];
		private _ammoValuesInfPrimary = [];
		private _ammoValuesInfSecondary = [];
		private _ammoValuesVehicle_General = [];
		private _ammoValuesVehicle_Pylon = [];
		private _throwableValues = [];
		private _staminaValues = [];

		{
			if (isNull objectParent _x OR {assignedvehiclerole _x select 0 == "cargo"}) then {
				_damages_MAN pushBack (damage _x);
				_unitLoadOut = getUnitLoadout (configFile >> "CfgVehicles" >> typeof _x);
				_loadOutMagArray_MAN = [];

				_isLauncherUnit = (secondaryWeapon _x) isKindOf ["Launcher", configFile >> "CfgWeapons"];
				_launcherAllowedMags = (getArray(configfile >> "CfgWeapons" >> secondaryweapon _x >> "magazines"));

				//-- loadout weapon magazines
				for "_i" from 0 to 2 do {
					_weaponData = _unitLoadOut select _i;
					if (count _weaponData >= 5) then {
							_loadOutMagArray_MAN pushBack [(_weaponData select 4) select 0,1];
					};
				};

				//-- loadout container magazines
				for "_i" from 3 to 5 do {
					_containerData = _unitLoadOut select _i;
					if (count _containerData > 0) then {
						{
							if (   (([_x select 0] call BIS_fnc_itemType) select 0) == "Magazine") then {
								_loadOutMagArray_MAN pushBack [_x select 0, _x select 1];
							};
						} foreach (_containerData select 1);
					};
				};

				_totalMadArray_Primary = [];
				_totalThrowableArray = [];
				_totalMagArray_Secondary = [];
				{
					_x params ["_magName","_magCount"];
					if (!isNil '_magName') then {
						for "_i" from 1 to _magCount do {
							if (_magName call BIS_fnc_isThrowable) then {
								_totalThrowableArray pushBack _magName;
							} else {
								if (_magName in _launcherAllowedMags) then {
									_totalMagArray_Secondary pushBack _magName;
								} else {
									_totalMadArray_Primary pushBack _magName;
								};	
							};	
						};
					};
					
				} foreach _loadOutMagArray_MAN;

				_currentMags = magazines _x + (primaryweaponMagazine _x) + (secondaryweaponMagazine _x) + (handgunMagazine _x);
				_currentThrowables = [];
				_currentSecondaryMags = [];

				while {{(_x call BIS_fnc_isThrowable)} count _currentMags > 0} do {
					{
						if (_x call BIS_fnc_isThrowable) exitWith {
							_currentMags deleteAt _foreachIndex;
							_currentThrowables pushBack _x;
						};
					} foreach _currentMags;
				};

				while {{(_x in _totalMagArray_Secondary)} count _currentMags > 0} do {
					{
						if (_x in _launcherAllowedMags) exitWith {
							_currentMags deleteAt _foreachIndex;
							_currentSecondaryMags pushBack _x;
						};
					} foreach _currentMags;
				};

				if (count _totalMadArray_Primary > 0) then {
					_ammoValuesInfPrimary pushBack ( ( (count _currentMags) / (count _totalMadArray_Primary) ) min 1);
				};

				if (count _totalThrowableArray > 0) then {
					_throwableValues pushBack ( ( (count _currentThrowables) / (count _totalThrowableArray) ) min 1);
				};

				if (count _totalMagArray_Secondary > 0) then {
					_ammoValuesInfSecondary pushBack ( ( (count _currentSecondaryMags) / (count _totalMagArray_Secondary) ) min 1);
				};

				_staminaValues pushBack (1 - (getFatigue _x));

			} else {
				_vehicles pushBackUnique (vehicle _x);
			};
		} foreach units _group;



		private _fuelValues = [];
		
		{
			_vehicle = _x;
			_damages_VEHICLE pushBack (damage _vehicle);
			_fuelValues pushBack (fuel _vehicle);
			_vehicleDefaultMags = (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "magazines"));
			_turretMags = [];
			_turrets = "true" configClasses (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets");
			{
				_turretMags = _turretMags + (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets" >> (configName _x) >> "magazines"));
			} foreach _turrets;

			_vehicleDefaultMags = _vehicleDefaultMags  + _turretMags;
				
			_vehicleDefaultPylons = (getPylonMagazines _vehicle);

			_vehicleDefaultMags = _vehicleDefaultMags - _vehicleDefaultPylons;

			_currentVehicleMags = (magazinesAmmoFull _vehicle) select {_mag = _x select 0; {(_x in toLower _mag)} count ["laser"] == 0 };
			_vehicleMagPercentages = [];
			_vehiclePylonPercentages = [];
			{
				_x params ["_magName","_ammoCount"];
				private _ammoCountFullMag = getNumber (configfile >> "CfgMagazines" >> _magName >> "count");
				_percentage = if (_ammoCount > 0) then {_ammoCount / _ammoCountFullMag} else {0};
				_vehicleDefaultMags = _vehicleDefaultMags - [_magName];
				_currentVehicleMags =  _currentVehicleMags - [_magName];
				if (_magName in _vehicleDefaultPylons) then {
					{
						if (_x == _magName) exitWith {
							_vehicleDefaultPylons deleteAt _foreachIndex;
						};
					} foreach _vehicleDefaultPylons;
					_vehiclePylonPercentages pushBack _percentage;
					
				} else {
					_vehicleMagPercentages pushBack _percentage;
				};
				
			} foreach _currentVehicleMags;

			_finalVehicleMagPercentage = 0;
			{_finalVehicleMagPercentage = _finalVehicleMagPercentage + _x} foreach _vehicleMagPercentages;
			_finalVehicleMagPercentage = if (count _vehicleMagPercentages > 0) then {_finalVehicleMagPercentage / count _vehicleMagPercentages} else {0};
			
			
			_finalVehiclePylonPercentage = 0;
			{_finalVehiclePylonPercentage = _finalVehiclePylonPercentage + _x} foreach _vehiclePylonPercentages;
			_finalVehiclePylonPercentage = if (count _vehiclePylonPercentages > 0) then {_finalVehiclePylonPercentage / count _vehiclePylonPercentages} else {0};

	
			
			_ammoValuesVehicle_General pushBack _finalVehicleMagPercentage;
			_ammoValuesVehicle_Pylon pushBack _finalVehiclePylonPercentage;
			
		
		} foreach _vehicles;

		//-- get Progress Bar Values
		private _groupDamage_MAN = 0;
		{_groupDamage_MAN = _groupDamage_MAN + _x} foreach _damages_MAN;
		if (count _damages_MAN > 0) then {
			_groupDamage_MAN = _groupDamage_MAN / (count _damages_MAN);
			_groupDamage_MAN = [_groupDamage_MAN,1] call BIS_fnc_cutDecimals;
		};
		_groupDamage_MAN = 1 - _groupDamage_MAN; //-- convert damage to health

		_groupDamage_VEHICLE = 0;
		{_groupDamage_VEHICLE = _groupDamage_VEHICLE + _x} foreach _damages_VEHICLE;
		if (count _damages_VEHICLE > 0) then {
			_groupDamage_VEHICLE = _groupDamage_VEHICLE / (count _damages_VEHICLE);
			_groupDamage_VEHICLE = [_groupDamage_VEHICLE,1] call BIS_fnc_cutDecimals;
		};
		_groupDamage_VEHICLE = 1 - _groupDamage_VEHICLE; //-- convert damage to health

		private _groupMagazines_Man_Primary = 0;
		{_groupMagazines_Man_Primary = _groupMagazines_Man_Primary + _x} foreach _ammoValuesInfPrimary;
		if (count _ammoValuesInfPrimary > 0) then {
			_groupMagazines_Man_Primary = _groupMagazines_Man_Primary / (count _ammoValuesInfPrimary);
			_groupMagazines_Man_Primary = [_groupMagazines_Man_Primary,1] call BIS_fnc_cutDecimals;
		};


		private _groupMagazines_Man_Secondary = 0;
		{_groupMagazines_Man_Secondary = _groupMagazines_Man_Secondary + _x} foreach _ammoValuesInfSecondary;
		if (count _ammoValuesInfSecondary > 0) then {
			_groupMagazines_Man_Secondary = _groupMagazines_Man_Secondary / (count _ammoValuesInfSecondary);
			_groupMagazines_Man_Secondary = [_groupMagazines_Man_Secondary,1] call BIS_fnc_cutDecimals;
		};


		private _groupMagazines_Vehicle = 0;
		{_groupMagazines_Vehicle = _groupMagazines_Vehicle + _x} foreach _ammoValuesVehicle_General;
		if (count _ammoValuesVehicle_General > 0) then {
			_groupMagazines_Vehicle = _groupMagazines_Vehicle / (count _ammoValuesVehicle_General);
			_groupMagazines_Vehicle = [_groupMagazines_Vehicle,1] call BIS_fnc_cutDecimals;
		};

		private _groupPylons_Vehicle = 0;
		{_groupPylons_Vehicle = _groupPylons_Vehicle + _x} foreach _ammoValuesVehicle_Pylon;
		if (count _ammoValuesVehicle_Pylon > 0) then {
			_groupPylons_Vehicle = _groupPylons_Vehicle / (count _ammoValuesVehicle_Pylon);
			_groupPylons_Vehicle = [_groupPylons_Vehicle,1] call BIS_fnc_cutDecimals;
		};



		private _groupThrowables = 0;
		{_groupThrowables = _groupThrowables + _x} foreach _throwableValues;
		if (count _throwableValues > 0) then {
			_groupThrowables = _groupThrowables / (count _throwableValues);
			_groupThrowables = [_groupThrowables,1] call BIS_fnc_cutDecimals;
		};


		
		private _groupFuel = 0;
		if (count _fuelValues > 0) then {
			{_groupFuel = _groupFuel + _x} foreach _fuelValues;
			_groupFuel = _groupFuel / (count _fuelValues);
			_groupFuel = [_groupFuel,1] call BIS_fnc_cutDecimals;
		};

		private _groupStamina = 0;
		if (count _staminaValues > 0) then {
			{
				_groupStamina = _groupStamina + _x;
			} foreach _staminaValues;
		};
		
		//-- set images and text(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPNAME) ctrlSetText _groupID;
		{(findDisplay _a3c_dsp displayCtrl _x) ctrlSetText _groupID;} foreach [IDC_SHARED_UI_DASHBOARD_GROUPNAME,IDC_MAP_DASHBOARD_GROUPNAME_EDIT];
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_GROUPICON) ctrlSetText _groupIcon;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_UNITSIZE) ctrlSetText _unitSize;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_LOCATION) ctrlSetText _location;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_TXT_TASK) ctrlSetText _currentTask;

		_macroIndex = 1;

		_fnc_createProgressMacro = {
			params ["_macroIndex","_descriptionText","_progress","_a3c_dsp"];
			//-- adjust parent
			if (_macroIndex > 3) then { //-- first three extra bars do not require resize!
				{
					_ctrl = (findDisplay _a3c_dsp displayCtrl _x);
					_ctrlPos = ctrlPosition _ctrl;
					_ctrlPosH = (_ctrlPos select 3) + (1.5 * (0.021 / (getResolution select 5)));
					_ctrlPos set [3,_ctrlPosH];
					if (_foreachindex == 0 && {_a3c_dsp == IDD_RADIAL_MENU}) then {
						//-- adjust parent Y
						_ctrlPosY = (_ctrlPos select 1) - (0.75 * (0.021 / (getResolution select 5)));
						_ctrlPos set [1,_ctrlPosY];
					};
					_ctrl ctrlSetPosition _ctrlPos;
					_ctrl ctrlCommit 0;
				} foreach [IDC_SHARED_UI_DASHBOARD_PARENT,IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED,IDC_SHARED_UI_DASHBOARD_BG];
			};
			
			//-- generate ctrl positions
			_ctrlPosBar = 
			[
				(0.00800027 - 0.002) * safezoneW,
				(0.136011 * safezoneH) + (_macroIndex * (1.5 * (0.021 / (getResolution select 5)))),
				0.0800031 * safezoneW,
				0.0085007 * safezoneH
			];
			
			_ctrlPosText = 
			[
				-3.81485e-008 * safezoneW,
				(_ctrlPosBar select 1) - ( 0.021 / (getResolution select 5)),
				0.0800031 * safezoneW,
				0.021 / (getResolution select 5)
			];

			//-- create new progress bar macro
			_bg_ProgressBar  = findDisplay _a3c_dsp ctrlCreate ["RscPicture",12003 + _macroIndex + 2, findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT];
			_bg_ProgressBar ctrlSetPosition _ctrlPosBar;
			_bg_ProgressBar ctrlSetText "#(argb,8,8,3)color(0.5,0.5,0.5,0.5)";

			
			_actualProgressBar  = findDisplay _a3c_dsp ctrlCreate ["RscProgress",12003 + _macroIndex + 1, findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT];
			_actualProgressBar ctrlSetPosition _ctrlPosBar;

			_progressCol = switch (true) do {
				case (_progress <= 0.3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_fnc_setOpacity};
				case (_progress < 0.7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_fnc_setOpacity};
				//case (_progress == 0) : { [A3C_UI_COLOR_RED,0.1] call A3C_UI_fnc_setOpacity};
				default {[0,1,0,0.6]};
			};
			
			_actualProgressBar progressSetPosition _progress;
			_actualProgressBar ctrlSetTextColor _progressCol; //;
			

			_barTextCtrl = findDisplay _a3c_dsp ctrlCreate ["A3C_RscText_GroupDashboard",12003 + _macroIndex, findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT]; //--12003 is the 'ammunition'-bar idc, we build up from here
			_barTextCtrl ctrlSetText _descriptionText;
			
			_barTextCtrl ctrlSetPosition _ctrlPosText;

			if (_progress == 0) then {
				_barTextCtrl ctrlSetTextColor [1,0,0,1]; //([A3C_UI_COLOR_RED,0.9] call A3C_UI_fnc_setOpacity);
			};
			{_x ctrlCommit 0} foreach [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			_macro = [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			A3C_UI_SHARED_createDashBoard_ExtraControls = A3C_UI_SHARED_createDashBoard_ExtraControls + _macro;
			_macro
			
		};

		//-- set fixed Progress Bars
		{
			_txtctrl = switch (_foreachIndex) do {
				case (0) : {findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_HEALTH_TXT};
				case (1) : {findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PGBARS_BG};
			};
			_ctrl = switch (_foreachIndex) do {
				case (0) : {findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_HEALTH_BAR};
				case (1) : {findDisplay _a3c_dsp displayCtrl 12003};
			};
			_progressCol = switch (true) do {
				case (_x <= 0.3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_fnc_setOpacity};
				case (_x < 0.7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_fnc_setOpacity};
				default {[0,1,0,0.6]};
			};
			private _prog = _x;
			if (_prog == 0) then {
				_txtctrl ctrlSetTextColor [1,0,0,1]; //([A3C_UI_COLOR_RED,0.9] call A3C_UI_fnc_setOpacity);
			};
			_ctrl progressSetPosition _prog;
			_ctrl ctrlSetTextColor _progressCol;
		} foreach [_groupDamage_MAN]; //,

		
		
		//-- HEALTH: SHow vehicle health for groups with any units in vehicle (warning: will consider drivers and cargo groups)
		if ({!isnull objectParent _x} count units _group > 0) then {							

			//-- >> create VEHICLE DAMAGE progress macro
			_macro = [_macroIndex,"Health (Vehicles)",_groupDamage_VEHICLE,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			
			if ({count (weapons _x select {_wpn = _x; {_x in toLower _wpn} count ["horn","smoke","laser"] == 0}) > 0} count _vehicles > 0) then {
				
				//-- >> create VEHICLE MAG progress macro
				_macro = [_macroIndex,"Ammo (Vehicles)",_groupMagazines_Vehicle,_a3c_dsp] call _fnc_createProgressMacro;
				_macroIndex = _macroIndex + 1;
				
				if ({count (getPylonMagazines _x) > 0} count _vehicles > 0) then {
					
					//-- >> create VEHICLE PYLON progress macro
					_macro = [_macroIndex,"Pylons",_groupPylons_Vehicle,_a3c_dsp] call _fnc_createProgressMacro;
					_macroIndex = _macroIndex + 1;
				};
			};	
		};
		
		if ({isNull objectParent _x OR {(assignedVehicleRole _x) select 0 == "cargo"}} count units _group > 0) then {
		
			//-- >> create group Magazines progress macro
			_macro = [_macroIndex,"Mags  (Soldiers)",_groupMagazines_Man_Primary,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			//-- >> create THROWABLES progress macro
			_macro = [_macroIndex,"Throwables",_groupThrowables,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			if ({(secondaryWeapon _x) isKindOf ["Launcher", configFile >> "CfgWeapons"]} count units _group > 0) then {
				//-- >> create LAUNCHER progress macro
				_macro = [_macroIndex,"Launchers",_groupMagazines_Man_Secondary,_a3c_dsp] call _fnc_createProgressMacro;
				_macroIndex = _macroIndex + 1;
			};

			//-- some units are on foot >> create STAMINA progress macro
			_macro = [_macroIndex,"Stamina",_groupStamina,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;
		};
		//systemchat str [_a3c_dsp];
		if ({!isNull objectParent _x && {_x == driver vehicle _x}} count units _group > 0) then {
			//-- some units are NOT on foot 
			//-- >> create FUEL progress macro
			_macro = [_macroIndex,"Fuel",_groupFuel,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;		
		};

		//-- Medical / Repair Icons:
		_supportButtons = 0;
		_supportButtonBasePos =
		[
			0.150315 * safezoneW,
			3.09064e-006 * safezoneH,
			0.0159271 * safezoneW,
			0.0340016 * safezoneH
		];
		
		if (count ([units _group] call A3C_FINDMEDICS) > 0) then {
			_healingCapableIcon  = findDisplay _a3c_dsp ctrlCreate ["RscPicture",13000, findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT];
			_healingCapableIcon ctrlSetPosition _supportButtonBasePos;
			_healingCapableIcon ctrlSettext "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
			_healingCapableIcon ctrlSetTextColor [1,1,1,0.6];
			_healingCapableIcon ctrlSetTooltipColorBox [1,1,1,0.3]; //[0,1,0,0.6];
			_healingCapableIcon ctrlSetTooltipColorShade [1,1,1,0.3];
			_healingCapableIcon ctrlSetToolTip "Units in this group are capable of healing";
			_healingCapableIcon ctrlCommit 0;
			_supportButtons = 1;
		};
		if ({[_x] call A3C_fnc_canRepair} count units _group > 0) then {
			if (_supportButtons == 1) then {
				//_supportButtonBasePos set [0,0.134387 * safezoneW];
				_supportButtonBasePos set [1,(3.09064e-006 * safezoneH) + (0.0340016 * safezoneH)];
			};
			_repairingCapableIcon  = findDisplay _a3c_dsp ctrlCreate ["RscPicture",13001, findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT];
			_repairingCapableIcon ctrlSetPosition _supportButtonBasePos;
			_repairingCapableIcon ctrlSettext "A3C_CORE\ui\pictures\icon_menu_action_repair_noBG.paa"; // "\a3c_ui\menu\icon_menu_action_repair.paa";
			_repairingCapableIcon ctrlSetTextColor [1,1,1,0.6];
			
			_repairingCapableIcon ctrlSetToolTip "Units in this group are capable of repairing";
			_repairingCapableIcon ctrlSetTooltipColorBox [1,1,1,0.3];
			_repairingCapableIcon ctrlSetTooltipColorShade [1,1,1,0.3];

			
			_repairingCapableIcon ctrlCommit 0;
		};
		
		
		//-- create Structured text
		_structuredVehicles = [];
		_structuredUnits = [];

		{
			_add = true;
			_vehicleName = typeOf _x; //getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
			{
				if (_vehicleName == _x select 0) then {
					_x set [1,(_x select 1) + 1];
					_add = false;
				};
			} foreach _structuredVehicles;
			if (_add) then {
				_structuredVehicles pushBack [_vehicleName,1];
			};
		} foreach _vehicles;
		{
			_add = true;
			_vehicleName = typeOf _x; //getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
			{
				if (_vehicleName == _x select 0) then {
					_x set [1,(_x select 1) + 1];
					_add = false;
				};
			} foreach _structuredUnits;
			if (_add) then {
				_structuredUnits pushBack [_vehicleName,1];
			};
		} foreach (units _group);

		_structuredText = ""; 
		if (count _structuredVehicles > 0) then {
			_structuredText = "<br/>";
			_structuredText = "<t size='.7' align='left'>VEHICLES: </t>";
			{
				_vehicleClass = _x select 0;
				_amount = _x select 1;
				_str = format 
				[
					
					"<br/> <img align='left' image='%1'/> <t size='.6' align='left'>%2 (%3x) </t>",
					getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "picture"),
					getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "displayName"),
					_amount
				]; //
				_structuredText = _structuredText + _str;
			} foreach _structuredVehicles;
			_structuredText = _structuredText + "<br/>";
		};
		_structuredText = _structuredText + "<t size='.7' align='left'>UNITS: </t><br/>";
		{
			_vehicleClass = _x select 0;
			_amount = _x select 1;
			
			_str = format 
			[
				"<t size='.6' align='left'>%1 (%2x)</t>",
				getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "displayName"),
				_amount
			];
			if (_foreachIndex < (count _structuredUnits - 1)) then {
				_str = _str + "<t size='.6' align='left'>, </t>";
			};
			if ((_foreachIndex + 1) % 2 == 0) then {
				_str = _str + "<br/>";
			};
			_structuredText = _structuredText + _str;
		} foreach _structuredUnits;

		_structuredText = parseText _structuredText; 
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED) ctrlSetStructuredText _structuredText;
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow true;

	} else {
		(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
	};
};


A3C_UI_Shared_fnc_toggleGocodeCtrls = {
	//-- Enables goCode UI buttons for clients
	if (isDedicated) exitWith {};

	
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	if (isnull findDisplay _a3c_dsp) exitWith {};

	private _rootPos = if (isnull findDisplay _a3c_dsp) then {[]} else {//-- only for tablet
		[
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X,
			A3C_MAP_GAMEUI_MENU_Y,
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W,
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H
		]
	};
	private _findGoCode = {
		params ["_mode"];
		private _cond1 = false;
		{
			private ["_u"];
			_u = _x;
			{
				private ["_var"];
				_var = _x;

				{
					if ((_x select 3) isEqualto ["GOCODE",_mode]) then {
						if (_var == "A3C_PLOT") then {
							if ( ((_u getvariable "A3C_CURRENTWAYPOINT_INDEX") - 1 ) <= _forEachIndex) then {
								_cond1 = true;
							};
						} else {
							_cond1 = true;
						};
					};
				} foreach (_u getvariable [_var,[]]);
			} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
		} foreach (profileNamespace getvariable "A3C_GROUPUNITS");

		private _cond2 = false;
		{
			_gp = _x;
			private _wpts = (waypoints _gp);

			{
				if ((_x select 1) < currentWaypoint _gp) then {
					_wpts = _wpts - [_x];
				};
			} foreach _wpts;


			{
				private _wpCond = "";
				private _actionScript = "";

				if (waypointType _x == "SCRIPTED") then {
					_wpCond = waypointScript _x;
					_actionScript = "";
				} else {
					_wpCond = (waypointStatements _x) select 0;
					_actionScript = (waypointStatements _x) select 1;
				};

			
				//-- check if "GoCode" and "X" are in condition or actionscript
				{
					private _checkString = _x;
					if (["GoCode",_checkString] call BIS_fnc_inString) then {
						//if ([str _mode,_checkString] call BIS_fnc_inString) then {
						if ({[_x,_checkString] call BIS_fnc_inString} count [format ["Activate_%1",_mode],str _mode] > 0) then {
							_cond2 = true;
						};
					};
				} foreach [_wpCond,_actionScript];
			} foreach _wpts;
		} foreach A3C_HC_getAllGroups_Player_Current;
		[_cond1,_cond2]
	};

	private _ctrls = [];
	private _buttonsPlaced = 0; //-- only for tablet
	{
		private _mode = _x;
		private _btnPos = +(_rootPos);

			
	

		
		([_mode] call _findGoCode) params ["_cond1","_cond2"];
		
		if (_a3c_dsp == IDD_RADIAL_MENU) then {
			private _ctrl = switch (_mode) do {
				case ("A") : {IDC_RADIAL_OUTERRIGHT_1_IMG};
				case ("B") : {IDC_RADIAL_OUTERRIGHT_2_IMG};
				case ("C") : {IDC_RADIAL_OUTERRIGHT_3_IMG};
				case ("D") : {IDC_RADIAL_OUTERRIGHT_4_IMG};
			};
			if (_cond1 OR _cond2) then {
				(findDisplay IDD_RADIAL_MENU displayctrl _ctrl) ctrlSetTextColor [0.8,0.6,0,0.6];
			} else {
				(findDisplay IDD_RADIAL_MENU displayctrl _ctrl) ctrlSetTextColor [1,1,1,0.2];
			};

		} else {
			(findDisplay 12 displayCtrl 51) ctrlEnable true;
			private _ctrls = switch (_mode) do {
				case ("A") : {[IDC_MAP_Order_GoCode_A_IMG,IDC_MAP_Order_GoCode_A_BTN]};
				case ("B") : {[IDC_MAP_Order_GoCode_B_IMG,IDC_MAP_Order_GoCode_B_BTN]};
				case ("C") : {[IDC_MAP_Order_GoCode_C_IMG,IDC_MAP_Order_GoCode_C_BTN]};
				case ("D") : {[IDC_MAP_Order_GoCode_D_IMG,IDC_MAP_Order_GoCode_D_BTN]};
			};
			if (_cond1 OR _cond2) then {
				if !(isnull findDisplay _a3c_dsp) then {
					_btnPos set [0, A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X - (A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W * _buttonsPlaced)];
					{
						_btnItem = findDisplay _a3c_dsp displayCtrl _x;
						_btnItem ctrlSetPosition _btnPos;
						_btnItem ctrlCommit 0;
						_btnItem ctrlShow true;
					} foreach _ctrls;
					_buttonsPlaced = _buttonsPlaced + 1;
				} else {
					{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlSetTextColor [0.8,0.6,0,0.6]} foreach _ctrls;
				}
			} else {
				if !(isnull findDisplay _a3c_dsp) then {
					_btnPos set [1,safeZoneY -A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H];
					{
						_btnItem = findDisplay _a3c_dsp displayCtrl _x;
						_btnItem ctrlShow false;
						_btnItem ctrlSetPosition _btnPos;
						_btnItem ctrlCommit 0;
					} foreach _ctrls;
				} else {
					{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlSetTextColor [1,1,1,0.2]} foreach _ctrls;
				};
			};
			if ( !isnull findDisplay _a3c_dsp) then {
				private _bgControl = findDisplay _a3c_dsp displayCtrl IDC_MAP_Order_GoCode_BG;
				if (_buttonsPlaced > 0) then {		
					private _bgWidth = A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W * _buttonsPlaced;
					private _bgPos = 
					[
						A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X - (_bgWidth - A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W),
						A3C_MAP_GAMEUI_MENU_Y,
						_bgWidth,
						A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H
					];
					_bgControl ctrlSetPosition _bgPos;
					_bgControl ctrlCommit 0;
					_bgControl ctrlShow true; // -- default
				} else {
					_bgControl ctrlShow false;
				};	
			};
		};
	} foreach ["D","C","B","A"]; //-- reverse so that they rear ABCD from left to right
};



A3C_UI_MAP_Overlay_ResizeTeamColorsXWH = {
	params ["_a3c_dsp","_mode"];
	

	//-- DYNAMIC TEAMCOLOR BOXES

	
	if (_mode == "HC") exitWith {}; //~~ TEMPORARY: Exit for HC after removing teamcolor Boxes. TO DO: Align HC Teamcolors with Default-Colors and add funtionality


	//-- Hardcoded Values (from .hpp)
	_ctrlX = if (_a3c_dsp == IDD_RADIAL_MENU) then {0} else {A3C_MAP_OVERLAY_GAMEUI_TREEX}; 
	
	_ctrlH = 0.0110018 * safezoneH; //-- HARDCODED h value of first teamcolor box

	_totalW = (ctrlPosition (findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_TREE_SELECTOR)) select 2; 

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
			case ("RED") : {[IDC_SHARED_UI_TCBOX_RED_IMG,IDC_SHARED_UI_TCBOX_RED_BTN]};
			case ("GREEN") : {[IDC_SHARED_UI_TCBOX_GREEN_IMG,IDC_SHARED_UI_TCBOX_GREEN_BTN]};
			case ("BLUE") : {[IDC_SHARED_UI_TCBOX_BLUE_IMG,IDC_SHARED_UI_TCBOX_BLUE_BTN]};
			case ("YELLOW") : {[IDC_SHARED_UI_TCBOX_YELLOW_IMG,IDC_SHARED_UI_TCBOX_YELLOW_BTN]};
			case ("MAIN") : {[IDC_SHARED_UI_TCBOX_WHITE_IMG,IDC_SHARED_UI_TCBOX_WHITE_BTN]};
			case ("PURPLE") : {[IDC_SHARED_UI_TCBOX_PURPLE_IMG,IDC_SHARED_UI_TCBOX_PURPLE_BTN]};
		};
		{
			_ctrl = (findDisplay _a3c_dsp displayCtrl _x);
			_ctrlY = if (_a3c_dsp == IDD_RADIAL_MENU) then {(ctrlPosition _ctrl) select 1} else {safeZoneY + safezoneH};
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





A3C_UNITSEL_REFRESH_UI = {

	// if (true) exitWith {};

	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	
	private _commandMode = if (_a3c_dsp == IDD_RADIAL_MENU) then {
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

	if (_a3c_dsp == IDD_RADIAL_MENU) then {
		private _radialHoverReal = A3C_RADIAL_HOVER;
		A3C_RADIAL_HOVER = true;
		if (_commandMode == "SQUAD") then {
			//-- radial squad

			if ("act" in tolower A3C_RADIALMODE) then {	
				BV_ACT = 0;
				["ACTIONS",-1] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
			};



			//-- Medical controls opened: reset Listbox entries and medical data  uuu
			if (BV_MEDICAL == 1) then {
				["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
			};
			if (A3C_LBR_1 == "REARM") then {
				A3C_ReArm_options = [];
				[] call A3C_ReArm_OpenUI;
			};
			

			if (A3C_RADIALMODE == "VEHS") then {
				[A3C_RD_UNITS] call A3C_UI_RADIAL_FINDVEHS;
			};
			[] call A3C_UI_RADIAL_BTN_REINIT;	
		} else {
			//-- radial highCommand
			if ("act" in tolower A3C_RADIALMODE) then {
				["ROE",-1,false,true] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
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
				[_infModeTo] call A3C_UI_MAP_UFSB_RefreshControlBar;
			};
			[_mode,0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;

			
		} else {
			//-- map/tablet - high command
			["COLLAPSE",0.1] call A3C_UI_MAP_Overlay_TOGGLE_FoldSquadControls;
		};

	};
};



//-- HC GROUP ACTIONS (MIGHT NEED IT"S OWN SCRIPT OR FOLDER LATER)

A3C_MAP_fnc_GroupMenu_LabelActionButtons = {
	params [["_doToggle", true]];
	



	private _display = displayNull;
	private _displayIdd = -1;
	private _uiContext = "";

	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		_display = findDisplay IDD_RADIAL_MENU;
		_displayIdd = IDD_RADIAL_MENU;
		_uiContext = "RADIAL";
	} else {
		if (!isNull findDisplay IDD_MAP_OVERLAY) then {
			_display = findDisplay IDD_MAP_OVERLAY;
			_displayIdd = IDD_MAP_OVERLAY;
			_uiContext = "MAP";
		};
	};

	if (isNull _display) exitWith {};

	private _a3c_dsp = _displayIdd; // Legacy compatibility inside this function.

	//-- define button arrays - NOTE: We can not use groups ( FUNC(xyz) ) here since it's shared
	private _btnArray = switch (_uiContext) do {
		case "RADIAL": {
			[
				[-1, IDC_RADIAL_OUTERTOP_1_IMG, IDC_RADIAL_OUTERTOP_1_BTN],
				[-1, IDC_RADIAL_OUTERTOP_2_IMG, IDC_RADIAL_OUTERTOP_2_BTN],
				[-1, IDC_RADIAL_OUTERTOP_3_IMG, IDC_RADIAL_OUTERTOP_3_BTN],
				[-1, IDC_RADIAL_OUTERTOP_4_IMG, IDC_RADIAL_OUTERTOP_4_BTN],

				[-1, IDC_RADIAL_OUTERRIGHT_1_IMG, IDC_RADIAL_OUTERRIGHT_1_BTN],
				[-1, IDC_RADIAL_OUTERRIGHT_2_IMG, IDC_RADIAL_OUTERRIGHT_2_BTN],
				[-1, IDC_RADIAL_OUTERRIGHT_3_IMG, IDC_RADIAL_OUTERRIGHT_3_BTN],
				[-1, IDC_RADIAL_OUTERRIGHT_4_IMG, IDC_RADIAL_OUTERRIGHT_4_BTN],

				[-1, IDC_RADIAL_OUTERBOTTOM_1_IMG, IDC_RADIAL_OUTERBOTTOM_1_BTN],
				[-1, IDC_RADIAL_OUTERBOTTOM_2_IMG, IDC_RADIAL_OUTERBOTTOM_2_BTN],
				[-1, IDC_RADIAL_OUTERBOTTOM_3_IMG, IDC_RADIAL_OUTERBOTTOM_3_BTN],
				[-1, IDC_RADIAL_OUTERBOTTOM_4_IMG, IDC_RADIAL_OUTERBOTTOM_4_BTN],

				[-1, IDC_RADIAL_OUTERLEFT_1_IMG, IDC_RADIAL_OUTERLEFT_1_BTN],
				[-1, IDC_RADIAL_OUTERLEFT_2_IMG, IDC_RADIAL_OUTERLEFT_2_BTN],
				[-1, IDC_RADIAL_OUTERLEFT_3_IMG, IDC_RADIAL_OUTERLEFT_3_BTN],
				[-1, IDC_RADIAL_OUTERLEFT_4_IMG, IDC_RADIAL_OUTERLEFT_4_BTN]
			]
		};

		case "MAP": {
			A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS
			// missionNamespace getVariable ["A3C_UI_MAP_BTN_DATA_GROUPMENU_ACTIONS", []] // placeholder until map dialog is refactored
		};

		default { [] };
	};

	// systemchat format ["LabelActionButtons _btnArray: %1", _btnArray];
	
	//-- wipe action controls

	[] call A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE;

	{
		_x params ["_bgIDC", "_imgIDC", "_btnIDC"];

		(_display displayCtrl _imgIDC) ctrlSetText "";
		(_display displayCtrl _btnIDC) ctrlSetToolTip "";

		{
			if (_x >= 0) then {
				(_display displayCtrl _x) ctrlShow false;
			};
		} forEach [_bgIDC, _imgIDC, _btnIDC];
	} forEach _btnArray;

	A3C_REMFIRE_MAGTYPES = [];


	A3C_HC_engineOffUnits = [];
	A3C_HC_IROnUnits = [];
	A3C_HC_IROffUnits = [];
	A3C_HC_IR_Laser_On_Units = [];
	A3C_HC_IR_Laser_Off_Units = [];
	A3C_HC_LightsOnUnits = []; //-- since vehicle lights are not a real option, this only goes for INFANTRY
	A3C_HC_LightsOffUnits = [];

	A3C_REMFIRE_TankShot_Units = [];
	A3C_REMFIRE_UGLShot_Units = [];
	A3C_REMFIRE_ATShot_Units = [];
	A3C_REMFIRE_StaticShot_Units = [];

	A3C_HC_DetoShot_Units = [];


	// private _disableHeal = false; //-- disable heal if action is currently executed. wait until finished before allowing again

	//-- gather actions
	private _actions = [];
	//private _isArty = false;

	private _nearObjects = player nearobjects 2;
	private _nearObjectsTypes = _nearObjects apply {typeOf _x};

	if !(A3C_GROUP_CONVOYS isEqualTo []) then {
		_actions pushBack "CONVOY HALT";
	};

	

	private _playerHasBatteries = [player, "Laserbatteries"] call BIS_fnc_hasItem;

	if (_playerHasBatteries) then {
		private _droneSearchName = if (isClass (configFile >> "CfgVehicles" >> "mavic_3_BLU")) then {
			"mavic"
		} else {
			"mavik"
		};

		private _isDroneNear =
			(player nearObjects 2) findIf {
				_droneSearchName in toLower (typeOf _x)
			} > -1;

		if (_isDroneNear) then {
			_actions pushBack "CHARGE_MAVIC";
		};
	};

	private _allSelectedGroupVehicles = [];
	{
		private _groupVehicles = [_x] call A3C_main_fnc_getGroupVehicles;
		{
			if !(_x in _allSelectedGroupVehicles) then {
				_allSelectedGroupVehicles set [count _allSelectedGroupVehicles, _x];
			};
		} foreach _groupVehicles;
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;


	


	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {

		private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
		_leaderVic = vehicle (leader _gp);
		

		if (_a3c_dsp == IDD_RADIAL_MENU && {typeOf _leaderVic in ["B_T_VTOL_01_armed_F", "B_T_VTOL_01_armed_fixed_F"]}) then {
			_actions PushBack "VTOL_CANNON";
			_actions PushBack "VTOL_GATLING";
			if (typeOf _leaderVic == "B_T_VTOL_01_armed_fixed_F") then {
				_actions PushBack "VTOL_AUTOCANNON";
			};
			
		};
		
	
		if ( {isClass (configOf (_x) >> "AnimationSources" >> "moveplow")} count _allSelectedGroupVehicles > 0 ) then {
			
			if ((_leaderVic animationSourcePhase 'moveplow') == 0) then {
				_actions PushBack "PLOW_DEPLOY";
			} else {
				if ((_leaderVic animationSourcePhase 'moveplow') == 1) then {
					_actions PushBack "PLOW_RAISE";
				};
			};
		};

		
		if ( 
			{
				private _vehicleType = typeOf _x;
				_vehicleType in ["B_APC_Tracked_01_CRV_F_Fixed", "B_T_APC_Tracked_01_CRV_F_Fixed"]
				&& {(_leaderVic getVariable ['MCSS_MCLC_MAGCOUNT', 4]) > 0}
				&& {!(_leaderVic getVariable['MCSS_MCLC_RELOADING', false])}
			} count _allSelectedGroupVehicles > 0 
		) then {
			_actions PushBack "LINE_CHARGE";
		};
		

		private _isInfOnly = {!isNull objectParent _x} count (units _gp) == 0;

		private _isConvoyGroup = false;
		if (count (A3C_CONVOYGROUPS select {_gp == _x select 0}) == 1) then {
			_actions pushBack "CONVOY_REJOIN";
			_isConvoyGroup = true;
		};

		if (isMultiplayer && {!(isServer)}) then {
			_actions PushBack "OWNERSHIP";
		};

		// 
		if (_gp getVariable ["A3C_MEDICS_ACTIVE", [] ] isEqualTo []) then {
			private _healersAvailable = [units _gp] call A3C_FINDMEDICS;
			private _patients = [_gp] call A3C_FINDPATIENTS;
			// _disableHeal = true;
			if ( { _x isEqualTo [] } count [_healersAvailable, _patients] == 0 ) then {
				//-- there is both healers and patients, so we can add the heal action
				_actions pushBack "HEAL";
			};
		};


		if (_isInfOnly && {[_gp] call A3C_Rearm_Req_HC}) then {
			_actions PushBack "RE-ARM";
		};
		

		if !(_isConvoyGroup) then {
			if (_a3c_dsp == IDD_MAP_OVERLAY) then {
				_actions PushBack "JOIN GROUP";
			};
		};

		

		

		if ({_leaderVic isKindOf _x} count ["CAR","TANK"] > 0) then {
			_actions PushBack "SPEEDLIMIT";
		};

		if (A3C_ALLOW_HCrEFRESH) then {
			_actions pushBackUnique "REFRESH_HC_GROUP";
		};

		


		//-- add FPV drone to 3D Menu   /// unitIsUAV _leaderVic
		if ( ( (typeOf _leaderVic) in ["B_Crocus_AT", "B_Crocus_AP"]) && {_a3c_dsp == IDD_RADIAL_MENU}) then {
			if !("uav_fpv" in (toLower (waypointScript [_gp, currentwaypoint _gp]))) then {
				_actions pushBackUnique "UAV_FPV";
			};
			
		};

		if (_leaderVic isKindOf "AIR") then { //-- para: works for player controlled groups too
			
			private _isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
			if (((getPosATL _leaderVic) select 2) > 1 && {!(_leaderVic getVariable ["A3C_ParadropActive",false])}) then {
				//-- vehicle is airborne
				if ( ({((assignedVehicleRole _x) select 0) == "cargo"} count crew _leaderVic > 0) OR {count (getVehicleCargo _leaderVic) > 0} ) then {
					//-- vehicle has Cargo
					_actions pushBackUnique "PARADROP";
					if (A3C_IsRappel) then {
						
						if (_isRotor && {isPlayer (leader _gp) OR {{group _x != _gp} count (crew _leaderVic) > 0}}) then {
							_actions pushBackUnique "RAPPEL";

						};
					};
				};
			} else {
				//-- vehicle is on ground
				if ((count ([_leaderVic] call A3C_main_fnc_getNearCargoLoadObjects) > 0) OR (count getVehicleCargo _leaderVic > 0)) then {
					//-- vehicle can load an object(s)
					_actions pushBackUnique "PARALOAD";
				};
				if (!isNull findDisplay IDD_RADIAL_MENU && {A3C_israppel}) then {
					if (_isRotor && {{((assignedVehicleRole _x) select 0) == "cargo"} count crew _leaderVic > 0}) then {
						_actions pushBackUnique "RAPPEL";
					};
				};
			};
			if (!(_isRotor) && {_leaderVic isKindOf "PLANE"}) then {
				_casModes = [typeof _leaderVic] call A3C_main_fnc_getCASmodes;
				if (count _casModes > 0 && {_a3c_dsp == IDD_RADIAL_MENU}) then {
					_actions pushBackUnique "CAS-STRIKE";
				};
			};
			
		} else {

			


			if ({_leaderVic isKindOf _x} count ["TANK","CAR"] > 0 && {canMove _leaderVic} ) then {
				_actions pushBackUnique "VEHICLE-REMOTE";
			};
			
			


			if (!isNull findDisplay IDD_RADIAL_MENU) then {

				

				//-- radial menu only
				_testedUnits = units _gp;
				{
					if ([_x] call A3C_fnc_canRepair) then {
						_actions pushBackUnique "REPAIR";
					};
					if (!isNull objectParent _x) then {
						_testedUnits = _testedUnits - [_x];
					};
				} foreach _testedUnits;
				if (count units _gp > 1) then {
					if (count ([_testedUnits,"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons) > 0) then {
						_actions pushBackUnique "STATIC_ASSEMBLE_HC";

					};
				};

				private _allExplosiveTypes = [];

				{
					_allExplosiveTypes append ([_x] call A3C_ai_shared_fnc_getExplosiveUnitMagazines);
				} forEach _testedUnits;

				A3C_REMFIRE_MAGTYPES = _allExplosiveTypes arrayIntersect _allExplosiveTypes;

				A3C_HC_DetoShot_Units = [units _gp] call A3C_ai_shared_fnc_getUnitsWithExplosives;
			};

		};

		//--2: Actions accessible ONLY to AI groups  (hide buttons for player controlled groups)
		if (!isPlayer leader _gp) then { //-- following actions are AI only!

			




			_vehicleType = "GROUND";
			if (_leaderVic isKindOf "AIR") then {
				_vehicleType = "AIR";
			};
			if (_vehicleType == "GROUND") then {

				if (count units _gp > 1) then {
					if ({_x == (gunner vehicle _x) && {(vehicle _x) isKindOf "staticweapon" && {typeOf (vehicle _x) != "A3C_Supression_Target_F" }} } count (units _gp) > 0 ) then {
						_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
					} else {
						//if ( {backPack _x == ""} count (units _gp) >= 2) then {
							A3C_HC_NearStatics = ( (position leader _gp) nearObjects ["staticweapon", 50]);
							A3C_HC_NearStatics = A3C_HC_NearStatics select {
								count crew _x == 0 && 
								{
									(typeOf _x) != "A3C_Supression_Target_F" &&
									{
										[units _gp,_x,true] call A3C_ai_highCommand_fnc_canSelectionPickUpStatic
									}
								}
							};
							if (count A3C_HC_NearStatics > 0) then {
								_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
							};
						//};
					};
				};
			} else {
				_actions pushBackUnique "FLYINGHEIGHT";
			};

		};
		private _addUnstuck = false;
		if ({_v = vehicle leader _x; (_v isKindOf "AIR" && {((getPosATL _v) select 2) > 2})} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
			if ({(vehicle leader _x) isKindOf "SHIP"} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
				_addUnstuck = true;
			};
		};
		if (_addUnStuck) then {
			_actions pushBackUnique "UNSTUCK";
		};
		if (!isNull findDisplay IDD_MAP_OVERLAY) then {
			(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT) ctrlSetText toUpper (groupID _gp);
		};
		

		
	} else {
		if (!isNull findDisplay IDD_MAP_OVERLAY) then {
			(findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT) ctrlSetText "Multiple Groups";
		};
	};


	if (_allSelectedGroupVehicles isNotEqualTo []) then {
		if ( {_x getVariable ["A3C_VehicleLights", 0] == 1} count _allSelectedGroupVehicles > 0) then {
			_actions pushBackUnique "VEHICLE_LIGHTS_ON";
		} else {
			_actions pushBackUnique "VEHICLE_LIGHTS_OFF";
		};
	};
	

	_actions pushBackUnique "DELETEGROUP";

	if ({unitIsUAV (vehicle (leader _x))} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
		_actions pushBack "VEHICLE";  //-- TO DO: add vehicle boarding for all-selected once working
	};
	
	
	private _actionExit = false; //-- to be re-used by multiple actions
	
	
	_reBoardFnc = {
		params ["_group"];
		_return = {!isNull (assignedVehicle _x)} count (units _group) == 0 && //-- units-in-vehicle DEFINITELY have assignedV so we know it's foot soldiers only
		{
			_v = (_group getVariable ["A3C_AssignedGroupVehicle",objNull]);
			!isNull _v && {alive _v}
		};

		_return
	};
	{
		
		if ([_x] call _reBoardFnc) then {
			_actions pushBackUnique "VEHICLE_REBOARD";
		};

		if ([_x] call A3C_ai_highCommand_fnc_getArtilleryCapacity) then {
			_actions pushBackUnique "ARTY";
		};

		//-- exit if both actions are already available
		if ({_x in _actions} count ["VEHICLE_REBOARD", "ARTY"] == 2) exitWith {};
		
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	
	{
		private _gp = _x;
		_gpDrivers = (units _gp) select {
			_oP = objectParent _x;
			!isNull _oP && {
				_x == driver _oP
			};
		};
		_gpVehicles = _gpDrivers apply {objectParent _x};
		{
			if ([_x, 0] call A3C_ai_shared_fnc_fireCounterMeasures) exitWith {
				_actions PushBack "VEHICLESMOKE";
				_actionExit = true;
			};
		} foreach _gpVehicles;
		
		if (_actionExit) exitWith {};
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	_actionExit = false; //-- reset bool for re-use



	


	private _suppressionCondition =
	(count A3C_SELECTED_HC_GROUPS_SETTINGS <= 5) &&
	{
		{
			_x == gunner vehicle _x &&
			{
				(getArtilleryAmmo [vehicle _x]) isEqualTo [] &&
				{
					!(vehicle _x isKindOf "PLANE") //!! change this when working out VTOL GUNSHIPS
				}
			}
		} count units _x > 0
	} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0;

	if (
		{
			_leaderVic = vehicle leader _x;
			(_leaderVic isKindOf "AIR") &&
			{
				!(_leaderVic getVariable ["A3C_ParadropActive",false])
			} &&
			{
				_a3c_dsp == IDD_RADIAL_MENU OR {((getPosATL _leaderVic) select 2) > 1}
			}
		} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0
	) then {
		if (_a3c_dsp == IDD_RADIAL_MENU) then {
			_actions pushBackUnique "LANDING_PRECISION"; //-- aircraft landings: further evaluation is to be made when action is CALLED
		};
	};

	if (_suppressionCondition) then { 
		_actions pushBackUnique "SUPPRESSION"; //-- SUPPRESSION is ALWAYS added when possible, even when units are suppressing, so that you can change the suppressed position on the fly
		if ({{_x in A3C_SUPPRESSION_UNITS_AI} count (units _x) > 0} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then {
			_actions pushBackUnique "SUPPRESSION_STOP";
		};
	};

	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		private _HCunits = units player - [player];
		private _hc_detoTriggerUnits = [];
		{
			{
				_HCunits pushbackUnique _x;
			} foreach units _x;
		} foreach A3C_HC_getAllGroups_Player_Current;
		{

			if ((count (_x getvariable ["A3C_UNIT_EXPLOSIVES",[]])) > 0) then {
				_hc_detoTriggerUnits pushbackUnique _x;
			};
		} foreach _HCunits;

		if (count _hc_detoTriggerUnits > 0) then {
			_actions pushbackUnique "ORDER_DETO";
		};
	};


	if (count (A3C_CONVOYGROUPS select {(_x select 0) in A3C_SELECTED_HC_GROUPS_SETTINGS}) == 0) then { //-- exclude convoy groups
		_actions pushBack "JOINPLAYER";
		if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
			if ({{isNull vehicle _x OR {vehicle _x isKindOf "AIR"}} count units _x > 0} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
				_actions pushBack "CONVOY_CREATE";
			};
		};
	};
	

	// systemchat str (count _actions < 10);
	if (count _actions < 13) then {
		{
			_gp = _x;
			_addGrouptoIR_Strobe = true;
			_addGrouptoEngine_Off = false;

			{
				private _u = _x;
				private _v = vehicle _u;
				_irData = _u getvariable ["A3C_STROBE",[]];
				if (count _irData > 0) then {
					_addGrouptoIR_Strobe = false;
				};
				if ({[_x,faction _u] call BIS_fnc_instring} count (["BLU_F","BLU_T","BLU_W","IND_F","OPF_F","OPF_T","OPF_V","rhs_faction_us"] ) > 0) then {
					if (!isNull objectParent _u) then {
						if (speed _v < 0.1 && {speed _v > -0.1}) then {
							if (_x == driver _v) then {
								if (isEngineOn _v) then {
									if !(_v isKindOf "AIR" && (getPosATL _v select 2) > 2) then {
										_addGrouptoEngine_Off = true;
									};
								};
							};
						};
					};
				};

			} foreach units _gp;
			if (_addGrouptoIR_Strobe) then {
				private _cond = {
					{
						private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
						private _nvgMarkers = "true" configClasses (configFile >> "CfgAmmo" >> _ammo >> "NVGMarkers") apply {configName _x};
						!(_nvgMarkers isEqualTo [])
					} count (magazines _x) > 0;
				} count (units _gp) > 0;
				if (_cond) then {
					A3C_HC_IROnUnits pushBackUnique _gp;
				};
				
			} else {
				A3C_HC_IROffUnits pushBackUnique _gp;
			};
			if (_addGrouptoEngine_Off) then {
				A3C_HC_engineOffUnits pushBackUnique _gp;
			};
			//-- following is not included in above loop as it has to effect the ENTIRE group.
			{
				_u = _x;
				_hasPointer = [_u,"LASER"] call A3C_fnc_hasWeaponItem;
				_hasFlashLight = [_u,"FLASHLIGHT"] call A3C_fnc_hasWeaponItem;

				if (_hasPointer) then {
					if ({_x isIRLaserOn (currentWeapon _x)} count units (group _u) > 0) then {
						A3C_HC_IR_Laser_Off_Units pushBackUnique (group _u);
					} else {
						A3C_HC_IR_Laser_On_Units pushbackUnique (group _u);
					};
				};
				if (_hasFlashLight) then {
					if ({_x isFlashlightOn (currentWeapon _x)} count units (group _u) > 0) then {
						A3C_HC_LightsOffUnits pushBackUnique (group _u);
					} else {
						A3C_HC_LightsOnUnits pushbackUnique (group _u);
					};
				};
				if ((!isNull findDisplay IDD_RADIAL_MENU) && {_x == (gunner vehicle _x)}) then {
					if (isNull objectParent _x) then {
						if ([_x] call A3C_main_fnc_unitHasAT) then {
							A3C_REMFIRE_ATShot_Units pushBackUnique _x;
						};
						if ([_x] call A3C_main_fnc_unitHasUGL) then {
							A3C_REMFIRE_UGLShot_Units pushBackUnique _x;
						};

					} else {
						if ([vehicle _x] call A3C_main_fnc_isStaticMissileLauncher) then {
							A3C_REMFIRE_StaticShot_Units pushbackUnique _x;
						} else {
							if ((count (getArtilleryAmmo [vehicle _x])) == 0 && {vehicle _x isKindOf "LAND"}) then { //-- exclude artillery and aircraft
								_isCannonVic = false;
								_isMissileVic = false;
								{
									_weapon = _x;
									_parent = getText (configfile >> "CfgWeapons" >> _weapon >> "nameSound"); //configName (inheritsFrom (configfile >> "CfgWeapons" >> _weapon));
									if ("cannon" in toLower _parent) then {
										_isCannonVic = true;
									} else {
										if ({_x in toLower _parent} count ["missile","rocket"] > 0) exitWith {
											_isMissileVic = true;
										};
									};
									
								} forEach (weapons (vehicle _x));
								
								//if (vehicle _x isKindOf "TANK") then {
								if (_isCannonVic) then {
									A3C_REMFIRE_TankShot_Units pushbackUnique _x;
								} else {
									if (_isMissileVic) then {
										A3C_REMFIRE_StaticShot_Units pushbackUnique _x;
									};
								};
							};
						};
					};
				};

				{
					//private ["_am","_array"];
					//_it = _x;
					//_am = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
					//_array = "true" configClasses (configfile >> "CfgAmmo" >> _am >> "NVGMarkers");

					//if (count _array > 0) exitWith {
				//		A3C_HC_IROnUnits pushBackUnique _u; //-- drivers added to IR
					//};
				} foreach (magazines _u);
			} foreach units _gp;

		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;


		if (count A3C_HC_DetoShot_Units > 0) then {
			_actions pushBackUnique "PLACE_CHARGE_HC";
		};


		if (count A3C_REMFIRE_TankShot_Units > 0) then {
			_actions pushBackUnique "TANKSHOT";
		};
		if (count A3C_REMFIRE_StaticShot_Units > 0) then {
			_actions pushBackUnique "STATICSHOT";
		};
		if (count A3C_REMFIRE_ATShot_Units > 0) then {
			_actions pushBackUnique "ATSHOT";
		};
		if (count A3C_REMFIRE_UGLShot_Units > 0) then {
			_actions pushBackUnique "UGLSHOT";
		};



		if (count A3C_HC_engineOffUnits > 0) then {
			_actions pushBackUnique "ENGINE_OFF";
		};
		A3C_HC_IROnUnits = A3C_HC_IROnUnits - A3C_HC_IROffUnits;

		if (count A3C_HC_IROffUnits > 0) then {
			_actions pushBackUnique "IR_OFF";
			A3C_HC_IROnUnits = [];
		};

		if (count A3C_HC_IROnUnits > 0) then {
			_actions pushBackUnique "IR_ON";

		};

		//systemchat str (A3C_HC_IROnUnits - A3C_HC_IROffUnits);

		if (count A3C_HC_IR_Laser_Off_Units > 0) then {
			_actions pushBackUnique "IR_POINTER_OFF";
			A3C_HC_IR_Laser_On_Units = [];
		};

		if (count A3C_HC_IR_Laser_On_Units > 0) then {
			_actions pushBackUnique "IR_POINTER_ON";
		};

		if (count A3C_HC_LightsOffUnits > 0) then {
			_actions pushBackUnique "FLASHLIGHT_OFF";
			A3C_HC_LightsOnUnits = [];
		};
		if (count A3C_HC_LightsOnUnits > 0) then {
			_actions pushBackUnique "FLASHLIGHT_ON";
		};

	};

	_sortedActions = [];

	{
		if (_x in _actions) then {
			_sortedActions pushBack _x;
		};
	} foreach
	[
		"UAV_FPV",
		"CONVOY HALT",
		"CHARGE_MAVIC",
		"VEHICLE",
		"VEHICLE_REBOARD",
		"VEHICLE-REMOTE",
		"SUPPRESSION",
		"SUPPRESSION_STOP",
		"CAS-STRIKE",
		"LANDING_PRECISION",
		"PARADROP",
		"RAPPEL",
		"PARALOAD",
		"FLYINGHEIGHT",
		"REPAIR",
		"ATSHOT",
		"UGLSHOT",
		"STATICSHOT",
		"ARTY",
		"PLOW_DEPLOY",
		"PLOW_RAISE",
		"LINE_CHARGE",
		"TANKSHOT",
		"VTOL_CANNON",
		"VTOL_GATLING",
		"VTOL_AUTOCANNON",
		"VEHICLESMOKE",
		"PLACE_CHARGE_HC",
		"ORDER_DETO",
		"STATIC_ASSEMBLE_HC",
		"STATIC_DISASSEMBLE_HC",
		"IR_OFF",
		"IR_ON",
		"IR_POINTER_OFF",
		"IR_POINTER_ON",
		"FLASHLIGHT_OFF",
		"FLASHLIGHT_ON",
		"ENGINE_OFF",
		"VEHICLE_LIGHTS_ON",
		"VEHICLE_LIGHTS_OFF",
		"SPEEDLIMIT",
		"CONVOY_REJOIN",
		"CONVOY_CREATE",
		"HEAL",
		"RE-ARM",
		"JOIN GROUP",
		// "JOINPLAYER", //-- not needed because we can just use mergegroups
		"UNSTUCK",
		"REFRESH_HC_GROUP",
		"OWNERSHIP",
		"DELETEGROUP"	
	];

	//-- player controlled groups in selection: No actions allowed:
	if ({private _ld = leader _x; isPlayer _ld } count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then { //&& {_ld != player}
		
		[] spawn {
			
			hint "A3C: Player Group(s) detected. No actions allowed. ";
			sleep 2;
			hintSilent "";
		};
		_sortedActions = [];
	};
	// systemchat "hint from LabelActionButtons";
	// hint str _sortedActions;

	_actions = _sortedActions;


	{

		// if (_foreachIndex < 10) then {
		if (_forEachIndex < ((count _btnArray) min 10)) then {
			_actionName = _x;
			private _params = [];
			private _button_IMG = "";
			private _button_toolTip = "";
			private _buttonFnc = {};
			private _actionAvailable = true;
			_imageColorCode = [1,1,1,1];


			switch (_actionName) do {

				//----------- NON-POSITIONAL ACTIONS

				case ("CONVOY HALT") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoyStop.paa";
					_button_toolTip = "HALT ALL CURRENT CONVOYS";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionConvoyHaltDispatch;
					};
				};
				case ("DELETEGROUP") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_trash.paa";
					_button_toolTip = "Delete Group And Vehicles";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionDeleteGroupsDispatch;	
					};
				};
				case ("VEHICLE-REMOTE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remote.paa";
					_button_toolTip = "Remote Control Vehicle";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionVehicleRemoteDispatch;
					};
				};
				case ("REFRESH_HC_GROUP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
					_button_toolTip = "Refresh Unresponsive HC-Group";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionRefreshGroupDispatch;
					};
				};
				case ("CONVOY_CREATE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoy_create.paa";
					_button_toolTip = "Create Convoy-Group";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionConvoyGroupManageDispatch;						
					};
				};
				case ("CONVOY_REJOIN") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoy_reJoin.paa";
					_button_toolTip = "Re-Establish Convoy Groups";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionConvoyRejoinDispatch;
					};
				};
				case ("JOINPLAYER") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_rejoinToPlayer.paa";
					_button_toolTip = "Merge with player group";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionJoinPlayerGroupDispatch;
					};
				};
				case ("JOIN GROUP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_joinGroup.paa";
					_button_toolTip = "Merge with other group";
					_buttonFnc = {
						//-- note: no dispatch since this action is map only
						//-- note: there's no action script because Map-onMouseButtonDown executes the 'action'.
						[] spawn A3C_ui_mapOverlay_fnc_actionMergeGroupsUiResponse;
					};
				};
				case ("SPEEDLIMIT") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_groupSpeed.paa";
					_buttonFnc = {
						[] call A3C_ui_selectionPromptPanel_fnc_actionLimitSpeedStartPrompt;
						
						
					};
					_button_toolTip = "Limit Group Speed";
				};
				case ("ORDER_DETO") : {
					_params = [];
					_button_IMG = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
					_button_toolTip = "MANAGE EXPLOSIVES";

					_buttonFnc = {
						[] call A3C_UI_SelectionPromptPanel_fnc_actionChargeDetonatePromptStart;
					};
				};
				case ("VEHICLE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
					_button_toolTip = "ASSIGN AND UNASSIGN VEHICLES. LMB to ASSIGN. RMB TO UNASSIGN. CTRL+RMB TO UNLOAD CARGO GROUPS";
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[_clickData select 1,_clickData select 5] call A3C_AI_HighCommand_ActionDistribute_boardGroupsToVehicle;	
					};	
				};
				case ("VEHICLE_REBOARD") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_reBoard.paa";
					_button_toolTip = "Re-Board group(s) to previous vehicle(s)";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionReboardGroupToVehicleDispatch;
					};				
				};
				case ("CHARGE_MAVIC") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_changeBattery.paa";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionPlayerChargeMavicDispatch;	
					};
					_button_toolTip = "Change Mavic-3 Batteries";
				};
				case ("VEHICLESMOKE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_counterSmoke.paa";
					_button_toolTip =  "FIRE COUNTER MEASURES / CONCEALMENT";
					_imageColorCode = [1,1,1,1];
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionVehicleSmoke;
					};	
				};
				case ("PARALOAD") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[objNull] call A3C_AI_HIGHCOMMAND_fnc_paraLoadAndDrop;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_loadVehicle.paa";
					_button_toolTip = "LOAD VEHICLES IN CARGO";
				};
				case ("PARADROP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
					_button_toolTip = "DISCHARGE CARGO (PARA)";
					_buttonFnc = {
						[objNull] call A3C_AI_HIGHCOMMAND_fnc_paraLoadAndDrop;
					};
				};
				case ("FLYINGHEIGHT") : {
					_params = []; 
					_buttonFnc = {
						[] call A3C_ui_selectionPromptPanel_fnc_actionFlyInHeightStartPrompt;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_flyInHeight.paa";
					_button_toolTip = "Change Flying Height";
				};
				case ("SUPPRESSION_STOP") : {
					_params = [];
					_button_IMG = "\a3\ui_f\data\IGUI\Cfg\Actions\ico_OFF_ca.paa";
					_button_toolTip =  "STOP SUPPRESSING"; 
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionSuppressionStop;	
					};		
				};
				case ("RE-ARM") : {
					_params = [];
					_imageColorCode = [1,1,1,1];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_reArm.paa";
					_button_toolTip = "RESUPPLY NEARBY";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionReArmDispatch;
					};
				};
				case ("HEAL") : {
					_params = [];
					_imageColorCode = [1,1,1,1]; //if (_disableHeal) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
					_button_toolTip = "MEDICAL ATTENTION";
					_buttonFnc = {
						[] call A3C_ai_highCommand_fnc_actionGroupHealDispatch;
					};
				};
				case ("OWNERSHIP") : {
					_params = [];
					_imageColorCode = [1,1,1,1]; //if (_disableHeal) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_transferOwner.paa";
					_button_toolTip = if (local (A3C_SELECTED_HC_GROUPS_SETTINGS select 0)) then {"TRANSFER OWNERSHIP TO SERVER"} else {"CLAIM OWNERSHIP"};
					_buttonFnc = {
						[] call A3C_ai_highCommand_actionTransferOwnershipDispatch;
					};
				};
				case ("UNSTUCK") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					_button_toolTip = "Unstuck/Unflip units and vehicles";
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[] call A3C_AI_HIGHCOMMAND_fnc_Unstuck;
					};
				};
				case ("STATIC_DISASSEMBLE_HC") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_STATIC_Packing.paa";
					_button_toolTip = "Pack Static Weapon";
					_buttonFnc = {
						[0] spawn A3C_ai_highCommand_fnc_actionUnAssembleWeaponDispatch;
					};
				};
				case ("PLOW_DEPLOY") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_LowerPlow.paa";
					_button_toolTip = "Deploy Mine-Plow";
					_buttonFnc = {
						[A3C_SELECTED_HC_GROUPS_SETTINGS select 0, 0] call A3C_ai_shared_fnc_actionAnimateVehiclePlow;
					};
				};
				case ("PLOW_RAISE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_RaisePlow.paa";
					_button_toolTip = "Raise Mine-Plow";
					_buttonFnc = {
						[A3C_SELECTED_HC_GROUPS_SETTINGS select 0, 1] call A3C_ai_shared_fnc_actionAnimateVehiclePlow;
					};
				};
				case ("LINE_CHARGE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_LineCharge.paa";
					_button_toolTip = "Pack Static Weapon";
					_buttonFnc = {
						[A3C_SELECTED_HC_GROUPS_SETTINGS select 0] call A3C_ai_shared_fnc_actionLineCharge;
					};
				};
				case ("ENGINE_OFF") : {
					_params = [];
					_button_IMG = "\a3\ui_f\data\IGUI\Cfg\Actions\engine_off_ca.paa";
					_button_toolTip = "Engine Off";
					_buttonFnc = {
						{
							[units _x] call A3C_ai_shared_fnc_actionEngineOff;
						} foreach A3C_HC_engineOffUnits;
					};
				};
				case ("VEHICLE_LIGHTS_OFF") : { 
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_headlight_OFF.paa";
					_button_toolTip = "Vehicle Lights Off";
					_buttonFnc = {
						[1] call A3C_ai_highCommand_fnc_actionSwitchVehicleLights;
					};
				};
				case ("VEHICLE_LIGHTS_ON") : { 
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_headlight_ON.paa";
					_button_toolTip = "Vehicle Lights On";
					_buttonFnc = {
						[0] call A3C_ai_highCommand_fnc_actionSwitchVehicleLights;
					};
				};
				case ("IR_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR) then {"IR-strobes ON - stand by for last order instance to complete"} else {"IR-strobes ON"};
					_buttonFnc = {
						if !(A3C_Prevent_attach_IR) then {
							["ON"] spawn A3C_ai_highCommand_fnc_actionToggleIrStrobe;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
				};
				case ("IR_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR) then {"IR-strobes OFF - stand by for last order instance to complete"} else {"IR-strobes OFF"};
					_buttonFnc = {
						if !(A3C_Prevent_attach_IR) then {
							["OFF"] spawn A3C_ai_highCommand_fnc_actionToggleIrStrobe;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};			
				};

				case ("IR_POINTER_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR_Laser) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR_Laser) then {
						"IR-LASERS ON - stand by for last order instance to complete"
					} else {
						"IR-LASERS ON"
					};

					_buttonFnc = {
						if !(A3C_Prevent_attach_IR_Laser) then {
							["LASER", "ON"] call A3C_ai_shared_fnc_actionWeaponAttachmentToggle;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
				};

				case ("IR_POINTER_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR_Laser) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR_Laser) then {
						"IR-LASERS OFF - stand by for last order instance to complete"
					} else {
						"IR-LASERS OFF"
					};

					_buttonFnc = {
						if !(A3C_Prevent_attach_IR_Laser) then {
							["LASER", "OFF"] call A3C_ai_shared_fnc_actionWeaponAttachmentToggle;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
				};

				case ("FLASHLIGHT_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_Flashlight) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_Flashlight) then {
						"FLASHLIGHT ON - stand by for last order instance to complete"
					} else {
						"FLASHLIGHT ON"
					};

					_buttonFnc = {
						if !(A3C_Prevent_attach_Flashlight) then {
							["FLASHLIGHT", "ON"] call A3C_ai_shared_fnc_actionWeaponAttachmentToggle;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
				};

				case ("FLASHLIGHT_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_Flashlight) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_Flashlight) then {
						"FLASHLIGHT OFF - stand by for last order instance to complete"
					} else {
						"FLASHLIGHT OFF"
					};

					_buttonFnc = {
						if !(A3C_Prevent_attach_Flashlight) then {
							["FLASHLIGHT", "OFF"] call A3C_ai_shared_fnc_actionWeaponAttachmentToggle;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
				};

				
				//----------- POSITIONAL ACTIONS

				//----- Remote-Fire Actions (use )

				//["TANKSHOT", '\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa',[1,0,0,1], "A3C_HeliPad","(0.5,0.1,1,1)"] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;

				case ("TANKSHOT") : {
					_imageColorCode = if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
					_button_toolTip =  format
					[
						"FIRE TANK SHELL - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							A3C_Prevent_TANKSHOT, //-- isBusy
							"TANKSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
				};

				case ("VTOL_CANNON") : {
					_imageColorCode = [1,1,1,1];
					_params = [];

					_button_IMG = "\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP CANNON - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							false, //-- isBusy
							"VTOL_CANNON", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};				
				};

				case ("VTOL_GATLING") : {
					_imageColorCode = [1,1,1,1];
					_params = [];

					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_Railgun.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP GATLING - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];
					_buttonFnc = {
						[
							false, //-- isBusy
							"VTOL_GATLING", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_CAS.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};	
				};

				case ("VTOL_AUTOCANNON") : {
					_imageColorCode = [1,1,1,1];
					_params = [];

					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP AUTOCANNON - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							false, //-- isBusy
							"VTOL_AUTOCANNON", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
				};							
				case ("UGLSHOT") : {


					_imageColorCode = if (A3C_Prevent_UGLSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_button_IMG = "\a3c_ui\menu\icon_menu_action_remote_UGL.paa";
					_button_toolTip =  format
					[
						"FIRE UGL GRENADE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							A3C_Prevent_UGLSHOT, //-- isBusy
							"UGLSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_UGL.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};


				};
				case ("ATSHOT") : {
					_imageColorCode = if (A3C_Prevent_ATSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_remote_AT.paa";
					_button_toolTip =  format
					[
						"FIRE AT-ROCKET - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							A3C_Prevent_ATSHOT, //-- isBusy
							"ATSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_AT.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};


				};
				case ("STATICSHOT") : {
					_imageColorCode = if (A3C_Prevent_STATICSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_remote_StaticAT.paa";
					_button_toolTip =  format
					[
						"FIRE STATIC ROCKET LAUNCHER - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];
					_buttonFnc = {
						[
							A3C_Prevent_STATICSHOT, //-- isBusy
							"STATICSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
				};
				
					
				
				case ("UAV_FPV") : {
					_imageColorCode = [1,1,1,1];
					_params = [];
					_button_IMG = 'A3C_CORE\ui\pictures\icon_menu_action_UAV_FPV.paa';
					_button_toolTip =  format
					[
						"FPV ATTACK - KEEP %1 PRESSED. CONFIRM TARGET WITH 'Spacebar' OR CANCEL BY RELEASING %1.",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];

					_buttonFnc = {
						[
							false, //-- isBusy //#TODO: do we need a condition to prevent double assignment?
							"UAV_FPV", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
				};
			

				case ("REPAIR") : {
					_imageColorCode = [1,1,1,1];
					_params = [];
					_button_IMG = '\a3c_ui\menu\icon_menu_action_repair.paa';
					_button_toolTip =  format
					[
						"REPAIR VEHICLES - KEEP %1 PRESSED. CONFIRM LOCATION WITH 'Spacebar' OR CANCEL BY RELEASING %1. REPAIR RADIUS: 100m",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];
					_buttonFnc = {
						[
							false, //-- isBusy
							"REPAIR", //-- actionID
							'\a3c_ui\menu\icon_menu_action_repair.paa', //-- Hud-Icon-class
							[1,1,1,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
				};


				case ("LANDING_PRECISION") : {
					_params = [] ;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
					_button_toolTip = "LAND AIRCRAFT (PRECISION)";
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _doSpecifyLandingPos = (
							{
								private _gp = _x;
								_leaderVic = vehicle leader _gp;
								_isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
								_isRotor
							} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0
						);

						if (_doSpecifyLandingPos) then {
							if (!isNull findDisplay IDD_RADIAL_MENU) then {

								private _vehicleType = "A3C_HeliPad";
								private _colorString = "";
								{
									_leaderVic = vehicle leader _x;
									if (_leaderVic isKindOf "Helicopter") exitWith {
										_vehicleType = typeOf _leaderVic;
										_colorString = "(0.5,0.1,1,1)";
									};
								} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

								[
									false, //-- isBusy
									"LANDING_PRECISION", //-- actionID
									'', //-- Hud-Icon-class
									[1,1,1,1], //-- Hud-Icon-color
									_vehicleType, //-- placer class
									_colorString //-- placer color-params
								] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
							} else {
								//-- specify mapclick
							};
						} else {
							{
								{
									_v = vehicle _x;
									if (_x == driver _v && {_v isKindof "AIR"}) then {
										if ((getPosATL _v) select 2 > 1) then {
											[_v,"LAND"] remoteExec ["land",_v];
										};
									};
								} foreach units _x;
							} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
						};
					};
					
				};

				case ("CAS-STRIKE") : {
					_params = [] ;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_CAS.paa";
					_button_toolTip =  format
					[
						"ORDER CAS-STRIKE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];
					_buttonFnc = {					
						if (!isNull findDisplay IDD_RADIAL_MENU) then {
							[
								false, //-- isBusy
								"CAS-STRIKE", //-- actionID
								'\a3c_ui\crosshairs\icon_crosshair_CAS.paa', //-- Hud-Icon-class
								[1,1,1,0.7], //-- Hud-Icon-color
								"", //-- placer class
								"" //-- placer color-params
							] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
						} else {
							//-- specify mapclick
						};
					};
				};
				case ("RAPPEL") : {
					_params = [] ;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
					_button_toolTip = "";
					if (_a3c_dsp == IDD_RADIAL_MENU) then {
						_button_toolTip =  format
						[
							"RAPPEL CARGO - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1. Creates wp on destination and origin.",
							["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
						];
					} else {
						_button_toolTip = "RAPPEL CARGO";
					};

					_buttonFnc = {
						
						if (!isNull findDisplay IDD_RADIAL_MENU) then {
							[
								false, //-- isBusy
								"RAPPEL", //-- actionID
								'', //-- Hud-Icon-class
								[1,1,1,0.7], //-- Hud-Icon-color
								"A3C_HeliPad", //-- placer class
								"" //-- placer color-params
							] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;

							
						} else {
							//-- map mode: immideate rappel for stationary vics (change to mapclick)
							{
								private _leader = leader _x;
								private _leaderVic = vehicle _leader;
								{
									_v = vehicle _x;
									if (_x == driver _v && { abs (speed _v) < 2 && {_v isKindof "HELICOPTER"}}) then {
										if ((getPosATL _v) select 2 > 1) then {
											if ((abs speed _v) < 1) then {
												[_v] call AR_Rappel_All_Cargo
											};
										};
									};
								} foreach units _x;
							} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
						};
					};
					
				};
				
				
				case ("SUPPRESSION") : {
					_params = []; 
					_buttonFnc = {
						//params ["_clickData","_buttonArray","_specialParams"];

						[] spawn A3C_HC_GroupMenu_fnc_SUPPRESSION;

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
					_button_toolTip = "";
					if (_a3c_dsp == IDD_RADIAL_MENU) then {
						_button_toolTip =  format
						[
							"SUPPRESSIVE FIRE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
							["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
						];
					} else {
						_button_toolTip = "SUPPRESSIVE FIRE - RELAY COORDINATES VIA MAPCLICK";
					};

				};
				

				case ("ARTY") : {
					_params = [];
					_button_IMG = "a3c_ui\menu\icon_menu_action_Artillery.paa";
					_button_toolTip = "";
					if (_a3c_dsp == IDD_RADIAL_MENU) then {
						_button_toolTip =  format
						[
							"FIRE ARTILLERY - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
							["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
						];
					} else {
						_button_toolTip = "FIRE ARTILLERY - RELAY COORDINATES VIA MAPCLICK";
					}; 
					_buttonFnc = {
						
						private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};


						if (_a3c_dsp == IDD_RADIAL_MENU) then {

							[
								false, //-- isBusy
								"ARTY", //-- actionID
								'\a3c_ui\crosshairs\icon_crosshair_remote_Artillery.paa', //-- Hud-Icon-class
								A3C_UI_COLOR_RED, //-- Hud-Icon-color
								"", //-- placer class
								"" //-- placer color-params
							] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
						} else {
							[_a3c_dsp] spawn {
								params ["_a3c_dsp"];
								(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
								(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
								hintSilent "A3C: Please relay map-coordinates via mapclick!";
								playsound "TacticalPing4";
								sleep 0.5;
								if (visibleMap) then {
									A3C_isArtyAwaitingSuborder = true;
									
									
									private _currentSelection = +(A3C_SELECTED_UNITS);
									[
										"A3C_ARTY_MAPCLICK",
										"onMapSingleClick",
										{
											//-- test for right mouse button?
											_shift = _this select 3;
											A3C_HC_FOCUS_ARTY_POS = _pos;

											if !(_shift) then {
												A3C_isArtyAwaitingSuborder = false;
											};
											["ARTY"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
											
										} 
									] call BIS_fnc_addStackedEventHandler;

									waitUntil {!(A3C_isArtyAwaitingSuborder) OR {!visibleMap OR {!(_currentSelection isEqualTo A3C_SELECTED_UNITS)}}};
									A3C_isArtyAwaitingSuborder = false;
									["A3C_ARTY_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
								};
							};
						};
					};	
				};

				
				case ("PLACE_CHARGE_HC") : {

					_params = [];
					_buttonFnc = {
						A3C_UI_RADIAL_Current_Remfire_Units = +(A3C_HC_DetoShot_Units);
						[
							false, //-- isBusy
							"PLACE_CHARGE_HC", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa', //-- Hud-Icon-class
							[1,1,1,0.7], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_explosives_Place.paa";
					_button_toolTip =  format
					[
						"PLACE EXPLOSIVE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];


				};
				case ("STATIC_ASSEMBLE_HC") : {
					_params = [];
					_buttonFnc = {

						//-- Note: Here we select type first, then position 
						//--> This means, A3C_UI_mainDisplay_fnc_startPositionalActionProcess is called in A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared!
						
						A3C_SelectionPromptPanel_MODE = "STATIC_ASSEMBLE_HC";
						private _staticData = [units (A3C_RD_UNITS select 0),"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;
						if (count _staticData == 1) then {
							[0] call A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared;
						} else {
							with uiNamespace do {
								//disableSerialization;
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
							};

							private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
							private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
							private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
							private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

							
							_parent ctrlShow true;
							_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
							_parent ctrlCommit 0;
							_text ctrlSetText "Select Static Weapon";
							ctrlSetFocus _listBox;
							
							
							lbClear _listBox;
							{
								private _lbText = (getText (configfile >> "CfgVehicles" >> _x select 1 >> "displayName"));
								[_listBox, _lbText] call A3C_addLbEntry;
							} foreach _staticData;
							
						};	
					};
					_button_IMG = (gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "picture"));
					_button_toolTip =  format
					[
						"ASSEMBLE %1 - KEEP %2 PRESSED. SELECT A WEAPON, POSITION AND ROTATE IT (MOUSEWHEEL). PRESS 'SpaceBar' TO CONFIRM OR RELEASE %1 TO CANCEL ",
						(gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")),
						["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
					];
				};

				

			};



			_buttonData = _btnArray select _forEachIndex;
			_buttonData params ["_btnBackgroundCtrl", "_btnImageCtrl", "_btnClickerCtrl"];

			if (_btnBackgroundCtrl >= 0) then {
				(_display displayCtrl _btnBackgroundCtrl) ctrlSetText "#(argb,8,8,3)color(0,0,0,0.4)";
			};

			

			(_display displayCtrl _btnImageCtrl) ctrlSetText _button_IMG;
			(_display displayCtrl _btnImageCtrl) ctrlSetTextColor _imageColorCode;
			(_display displayCtrl _btnClickerCtrl) ctrlSetToolTip _button_toolTip;

			if (_doToggle) then {
				{
					if (_x >= 0) then {
						(_display displayCtrl _x) ctrlShow true;
					};
				} forEach _buttonData;
			};

			if (_a3c_dsp == IDD_RADIAL_MENU) then {

				_buttonFnc = (str _buttonFnc) splitString "";
				_buttonFnc deleteAt 0;
				_buttonFnc deleteAt ((count _buttonFnc) -1);
				_buttonFnc = _buttonFnc joinString "";

				_buttonFnc = _buttonFnc + " [] spawn { sleep 0.1; [true] call A3C_MAP_fnc_GroupMenu_LabelActionButtons; }; ";



				_buttonFnc = compile _buttonFnc;
				_val =  _foreachIndex + 1;
				call compile format
				[
					"
						A3C_OUTER_RING_BTN_fnc_%1 = [%2,%3];
					",
					_val,
					_params, //-- ~~ !!!!! is ALWAYS [], did not work with formatted stuff. does not hurt for now, but at some point clean up and remove params
					_buttonFnc
				];
			} else {
				call compile format
				[
					"
						A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_%1 = ['%2',%3];
					",
					_foreachIndex,
					_params, //-- ~~ !!!!! is ALWAYS [], did not work with formatted stuff. does not hurt for now, but at some point clean up and remove params
					_buttonFnc
				];
				{(_display displayCtrl _x) ctrlShow true} foreach _buttonData;
			};


		};
	} foreach _actions;
	_actions
};

A3C_HC_GroupMenu_fnc_SUPPRESSION = {

	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};


	

	 //~~ has to be RD becasue it can also be called on squad units (subideal, maybe just have one array for everything. A3C_SELECTED_UNITS)
	private _refUnits = if (_a3c_dsp == IDD_RADIAL_MENU) then {A3C_RD_UNITS} else {A3C_SELECTED_UNITS};
	private _remFire_units = [];
	if (!isNull findDisplay IDD_RADIAL_MENU) then {
		_a3c_dsp = IDD_RADIAL_MENU;
		_refUnits = A3C_RD_UNITS;
	};
	private _chatMessageParts = [];
	private _currentlySuppressingUnits = [];

	{
		private _group = _x;
		private _leaderVic = (vehicle leader _group);

		if (_a3c_dsp == IDD_MAP_OVERLAY) then {
			if (_group in _refUnits) then { //~~ ?? what does this do ecxactly? making sure that group menu switches the button pages?
				["HC"] call A3C_UI_MAP_UFSB_ApplyMode;
			};
		};

		{

			if (_x == gunner vehicle _x && {(getArtilleryAmmo [vehicle _x]) isEqualTo []}) then {
				_canSuppress = true;
				switch (true) do {
					case (vehicle _x isKindOf "PLANE") : {
						_chatMessageParts pushBackUnique "Planes can not suppress. ";
						_canSuppress = false;
					};
					case (speed  (vehicle _x) > 1 && {vehicle _x isKindOf "HELICOPTER"}) : {
						_chatMessageParts pushBackUnique "Helicopters need to be stationary to suppress. ";
						_canSuppress = false;
					};
				};
				if (_x in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) then {
					_currentlySuppressingUnits pushBackUnique _x;
				};
				if (_canSuppress) then {
					_remFire_units pushBackUnique _x;
				};

			};
		} foreach (units _group);
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	private _chatMessageString = "";
	{
		_chatMessageString = _chatMessageString + _x;
	} foreach _chatMessageParts;
	systemchat _chatMessageString;

	//-- stop current suppression order before ordering a new one:
	if (count _currentlySuppressingUnits > 0) then {
		[_currentlySuppressingUnits,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
	};

	waituntil {{_x in A3C_SUPPRESSION_UNITS_AI} count _currentlySuppressingUnits == 0};

	A3C_UI_RADIAL_Current_Remfire_Units = []; //-- this time, remfire units are passed as GROUPS rather than UNITS.
	{
		A3C_UI_RADIAL_Current_Remfire_Units pushBackUnique (group _x);
	} foreach _remFire_units;

	//-- give new suppression order via the appropriate medium

	if (_a3c_dsp == IDD_MAP_OVERLAY) then {

		systemchat "A3C: Please relay map-coordinates via mapclick!";
		sleep 0.5; //~~ small delay needed for mapclick
		A3C_HC_GroupMenu_SuppressionRequested = true;
		{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
		[
			"A3C_SUP_MAPCLICK",
			"onMapSingleClick",
			{
				//_btn = _this select
				//systemchat str _this;
				_shift = _this select 3;
				A3C_HC_GroupMenu_SuppressionRequested = false;
				{
					[_x,_pos] call A3C_ai_highCommand_fnc_suppressionImmediate;
				} foreach A3C_UI_RADIAL_Current_Remfire_Units;
				["A3C_SUP_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
			}
		] call BIS_fnc_addStackedEventHandler;
	} else {

		[
			false, //-- isBusy
			"SUPPRESSION", //-- actionID
			'\a3c_ui\menu\icon_menu_action_suppression.paa', //-- Hud-Icon-class
			A3C_UI_COLOR_RED, //-- Hud-Icon-color
			"", //-- placer class
			"" //-- placer color-params
		] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
	};
};


A3C_AI_HighCommand_ActionDistribute_boardGroupsToVehicle = {
	params ["_button","_ctrl"];
	private ["_group","_a3c_dsp"];
	//if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {systemchat 'A3C: Boarding/Dismount function is only compatible with single selections'};
	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
	
	

	//-- Boarding HC-units via map-ui pt 1
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false;
	(findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
	if (_button == 0) then {
		A3C_UI_MAPICONS_HC_VICS = [A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_main_fnc_getBoardableVehicles;
		if (_a3c_dsp == IDD_RADIAL_MENU) then {

			A3C_UI_HUD_ASSIGNVEHICLE = true;
			[
				false, //-- isBusy
				"BoardVehicle_HC", //-- actionID
				'', //-- Hud-Icon-class
				[1,0,0,1], //-- Hud-Icon-color
				"", //-- placer class
				"" //-- placer color-params
			] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
		} else {
			if !(A3C_Boarding_ACTIVE) then {
				A3C_BOARDING_GROUPS = +(A3C_SELECTED_HC_GROUPS_SETTINGS);
				
				A3C_BOOL_MOUSEMOVING = true;
				A3C_MMCode = {
					_this spawn A3C_UI_MAP_onMouseDrag;
				};
				A3C_BOOL_DRAGLINE = true;
				A3C_CONNECTING_MODE = "HCBOARD";
				A3C_Boarding_ACTIVE = true;
			};
		};
	} else {
		private _dismountFnc = {
			params ["_group"];
			private _vehicles = [];
			// _group setVariable ["a3c_assignedgroupvehicle",nil];
			{
				_v = [_x] call A3C_AIGetOut; //-- in this case, we do not use remoteExec as we already know we are on the unit's machine. Instead, we return the vehicle
				if (!isNull _v) then {
					_vehicles pushBackUnique _v;
				};
			} foreach (units _group);
			{
				private _var = _x getVariable ["a3c_assignedvehiclecrew",[]];
				_var = _var select {!(_x select 0 in (units _group))};
				_x setVariable ["a3c_assignedvehiclecrew",_var];
			} foreach _vehicles;
		};
		_aiGroups = A3C_SELECTED_HC_GROUPS_SETTINGS select {!isPlayer leader _x};
		// right MB: dismount vehicle
		{
			private _group = _x;
			private _groupsToDismount = if (_ctrl) then {[]} else {[_group]};
			if (_ctrl) then {
				{
					_u = _x;
					if (!isNull objectParent _u) then {
						{
							if (group _x != group _u) then {
								_groupsToDismount pushBackUnique (group _x);
							};
						} foreach (crew (vehicle _u));
					};
					
				} foreach (units _group);
			};
			_groupsToDismount = _groupsToDismount - [group player]; //-- precation: We do not want the player accidentally dismounting his own troops (would dismount every single unit from his vehicle)
			//systemchat str _groupsToDismount;
			{
				_testedgroup = _x;
				[[_testedgroup],_dismountFnc] remoteExec ["bis_fnc_call",leader _testedgroup];	
			} foreach _groupsToDismount;

			if (count _groupsToDismount > 0) then {
				
				if (_ctrl) then {
					_groupString = "";
					_dismountCount = count _groupsToDismount;
					{
						_prestring = "";
						_postString = "";
						if (_foreachIndex == (_dismountCount -1)) then {
							if (_dismountCount > 1) then {
								_preString = " and ";
							};
						} else {
							if (_foreachIndex < (_dismountCount -2)) then {
								_postString = ", ";
							};
						};
						_groupString = _groupString + _preString + groupID _x + _postString;
					} foreach _groupsToDismount;
					systemchat format ["A3C: %1 is dismounting %2", groupID _group,_groupString];
				} else {
					systemchat format ["A3C: %1 was unassigned from all vehicles", groupID _group];
					
				};
				
			};
		} foreach _aiGroups;
		
	};
};






A3C_UI_SHARED_FIND_BEST_SHOOTERS = {
	params ["_units","_inputPosASL"];

	{
		//private _unitDistance = (eyePos _x) distance _inputPosASL;
		if (isNull objectParent _x) then {
			//_refPos = _x getRelPos [((_x distance A3C_SQ_REM_INDICATOR) - 10),(_x getRelDir A3C_SQ_REM_INDICATOR)];
			if (lineintersects [eyepos _x,_inputPosASL,_x,A3C_SQ_REM_INDICATOR]) then {_units = _units - [_x]};
		} else {
			_vehPos = getPosASL (vehicle _x);
			_vehPos set [2,(_vehPos select 2) + 1.8];
			if (lineintersects [_vehPos,_inputPosASL,_x,(vehicle _x)]) then {
				if (count (getArtilleryAmmo [vehicle _x]) == 0) then { //-- artillery does not require vision
					_units = _units - [_x];
				};
			};
		};
	} foreach _units;
	if (count _units == 0) exitWith {
		systemchat "A3C: No shot on target";
		[]
	};
	_units
};
