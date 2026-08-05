#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_onConfirmButton

disableSerialization;

private _display = findDisplay IDD_MAP_OVERLAY;
if (_display getVariable ["A3C_HCWP_MULTI_ACTIVE",false]) exitWith {
	[] call A3C_ui_mapOverlay_fnc_HCWP_onConfirmButtonMulti;
};

private _group = A3C_HC_ACTIVEGROUP;
private _wpMenuCtrlsGroup = _display displayCtrl IDC_MAP_HCWP_Parent;

private _tPos = [];
private _dirTo = 0;
private _timeout = if (A3C_HC_ACTIVE_PRE_COND_MODE == "TIMEOUT") then {A3C_HC_ACTIVE_PRE_COND_VAL} else {0};
private _actionCtrl = (_display displayCtrl IDC_MAP_HCWP_Type_Action);
private _actionText = _actionCtrl lbText (lbCurSel _actionCtrl);

_wpMenuCtrlsGroup ctrlShow false;
(findDisplay 12 displayCtrl 51) ctrlEnable true;

private _leader = leader _group;
private _wp = [_group, A3C_HC_ACTIVE_IND];
private _preCondition = switch (A3C_HC_ACTIVE_PRE_COND_MODE) do {
	case ("ARRIVAL") : {
		"true"
	};

	case ("GOCODE") : {
		[
			A3C_HC_ACTIVE_PRE_COND_VAL,
			side _group
		] call A3C_main_fnc_getGoCodeActivationVariableName
	};

	case ("TIMEOUT") : {
		//-- (count ['TIMEOUT'] == 1) returns true and is just there to include "TIMEOUT" in the condition
		"true && (count ['TIMEOUT'] == 1)"
	};

	case ("DAYTIME") : {
		//-- (count ['DAYTIME'] == 1) returns true and is just there to include "DAYTIME" in the condition
		private _str = A3C_HC_ACTIVE_PRE_COND_VAL splitString ":";

		format
		[
			"(([%1,%2,%3,%4,%5] call A3C_main_fnc_isDaytimeCompleted) && (count ['DAYTIME'] == 1))",
			parseNumber (_str select 0),
			parseNumber (_str select 1),
			parseNumber (_str select 2),
			parseNumber (_str select 3),
			parseNumber (_str select 4)
		];
	};
};

if (isPlayer _leader) exitWith { //&& {_leader != player}
	
	_wp setWaypointDescription A3C_HC_EDIT_ACTION;
	// #TODO: Add conditions to player waypoints
	// _wp setWaypointStatements [_preCondition, (waypointStatements _wp) select 1];
	// if (_leader != player) then {
		_group spawn {
			hint format ["A3C: Group %1 is controlled by a player. A description has been added to the player's waypoint, waypoint settings stay unchanged and actions currently need to be communicated via voice or chat..", groupID _this];
			sleep 4;
			hintSilent "";
		};
	// };	
};

//-- note to self: as this is called *PRECONDITION* - it is the condition for the ACTUAL waypoint, not the inserted one. INSERTED waypoints have condition within insert_wp fnc

private _dist = 50;
if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {
	_dist = 15;
};

private _statementsINS = [[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL],A3C_HC_EDIT_ACTION];



_tPos = (waypointPosition _wp);
_tPos = [_tPos,_dist,0] call BIS_fnc_relPos;
_dirTo = [(waypointPosition _wp),_tPos] call BIS_fnc_dirTo;
private _indSel = A3C_HC_ACTIVE_IND;

private _isCurrentWaypoint = A3C_HC_ACTIVE_IND == currentWaypoint _group;

//-- draw poly unless it already exists. Shared by all modes
private _var = _group getVariable ["A3C_UNIT_POLYS", []];
if (A3C_HC_EDIT_ACTION in ["SUPPRESSION","AMBUSH","ASSEMBLE WEAPON"]) then {
	private _prefix = switch (A3C_HC_EDIT_ACTION) do {
		case ("SUPPRESSION") : {'SUP'};
		case ("AMBUSH") : {'AMB'};
		case ("ASSEMBLE WEAPON") : {'ASS'}; //-- ASS stands for 'assemble' you cheeky little kitten.
	};
	
	_tPos set [2,0]; //==-- security mechanic: sometimes z-value is missing!
	if !(A3C_HC_PREVENT_POLY) then {
		private _polygon = [];
		if !(A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
			//-- action is NOT assembling weapon. create VISIBLE polygon
			_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ([_tPos,_dirTo,A3C_HC_EDIT_ACTION,true] call A3C_ai_shared_fnc_polygonAreaCreate));
		} else {
			//-- action IS assembling weapon. create INVISIBLE polygon
			//player setpos _tPos;
			_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ( [[_tPos,_tPos,_tPos,_tPos],["","","",""],0]) );
		};
		//systemChat str _polygon;
		A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
		_var pushBack _polygon;
	//} else {

		//{
		//	private ["_poly","_markerCol"];
		//	_poly = _x;
		//	_markerCol = "";
		//	if ( ((_x select 0) select 2) == A3C_HC_ACTIVE_IND) exitWith {
		//		_markerCol = switch (A3C_HC_EDIT_ACTION) do {
		//			case ("SUPPRESSION") : {"colorOpfor"};
		//			case ("AMBUSH") : {"colorBlack"};
		//		};
		//		((_poly select 0) select 1) setMarkerTypeLocal _markerType;
		//		{
		//			_x setMarkerColorLocal _markerCol;
		//		} foreach (_poly select 2);
		//
		//	};
		//} foreach _var;
	};
} else {
	private _refAIUnits = +A3C_SUPPRESSION_UNITS_AI;
	{
		private ["_poly"];
		_poly = _x;
		if ( ((_x select 0) select 2) == A3C_HC_ACTIVE_IND) exitWith {

			{
				private ["_soldier"];
				_soldier = _x;
				[_soldier,_poly] call A3C_ai_shared_fnc_polygonAreaRemove;
			} foreach (units _group);
			_var = _var - [_x];
		};
	} foreach _var;
	if !(_refAIUnits isEqualTo A3C_SUPPRESSION_UNITS_AI) then {
		publicVariable 'A3C_SUPPRESSION_UNITS_AI';
	};
};
private _statements = "";
private _waypointType = switch (true) do {
	case (A3C_HC_EDIT_ACTION in ["LOITER","CYCLE"]) : {A3C_HC_EDIT_ACTION};
	case (A3C_HC_EDIT_ACTION == "SEARCH / DESTROY") : {"SAD"};
	// case (A3C_HC_EDIT_ACTION == "TRANSPORT UNLOAD") : {"TR UNLOAD"};
	default {"MOVE"};
	//-- SCRIPTED waypointTypes will be assigned later
};

private _waypointBehaviour = switch (lbCurSel (_display displayCtrl IDC_MAP_HCWP_Behaviour_Combo)) do {
	case (0) : {"UNCHANGED"};
	case (1) : {"CARELESS"};
	case (2) : {"SAFE"};
	case (3) : {"AWARE"};
	case (4) : {"COMBAT"};
	case (5) : {"STEALTH"};
};

private _waypointCombatMode = switch (lbCurSel (_display displayCtrl IDC_MAP_HCWP_CombatMode_Combo)) do {
	case (0) : {"NO CHANGE"};
	case (1) : {"BLUE"};
	case (2) : {"GREEN"};
	case (3) : {"WHITE"};
	case (4) : {"YELLOW"};
	case (5) : {"RED"};
};

if (A3C_HC_EDIT_ACTION in ["SLING LOAD","SLING DROP"]) then {

	private _slingMode = [A3C_HC_ACTIVEGROUP] call A3C_ai_highCommand_fnc_getSlingMode;

	if (_slingMode == "HOOK") then {
		A3C_PICKUP_OBJECTS = [(vehicle (leader A3C_HC_ACTIVEGROUP)),A3C_HC_ACTIVE_WPOS] call MCSS_fnc_getNearSlingLoadObjects;
		_waypointType  = "MOVE";
	} else {
		_waypointType  = "UNHOOK";
		_statements = " 'SLING LOAD UNHOOK'; "; //-- just to have something for the UI to read
	};
};

private _completionRadius = if (A3C_HC_EDIT_ACTION in ["FULL LANDING","CAS-STRIKE"]) then {1000} else {0};

private _activeWaypointPosition = [];
if (A3C_HC_EDIT_ACTION == "CAS-STRIKE") then {

	_activeWaypointPosition = waypointPosition [_group,A3C_HC_ACTIVE_IND];
	
	if ([_group, A3C_HC_ACTIVE_IND, _activeWaypointPosition] call A3C_ai_highCommand_fnc_CASpreventAction ) then {
		A3C_HC_EDIT_ACTION = "MOVE";
		_statements = "";
		systemChat format ["A3C: Approach is not long enough for %1's CAS strike! Waypoint reverted to NO ACTION", groupID _group];
	};
};

if (A3C_HC_EDIT_ACTION == "FULL LANDING") then {
	private _vehicle = vehicle leader _group;
	private _runwayLanding = ((getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10);
	if (_vehicle isKindOf "PLANE" && {_runwayLanding}) then {
		private _airportData = [A3C_HC_ACTIVE_WPOS] call A3C_main_fnc_getNearestAirportData;
		_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
		A3C_HC_ACTIVE_WPOS = if (_airportID > -1) then {_airportTaxiIn} else {position _airportName}; //-- on dynamic airfields, 'airportName' is the actual object
		//systemChat str _airportData;
	};
};
if !(A3C_HC_EDIT_ACTION in ["DEMOLITION"]) then {

	private _statemCurr = waypointStatements _wp;
	private _condsCurr = (_statemCurr select 0) splitString "&&";
	private _wpScript = "";

	{
		if (["TIMEOUT",_x] call BIS_fnc_instring) then {
			_condsCurr = _condsCurr - [_x];
		};
		if (["GOCODE",_x] call BIS_fnc_instring) then {
			_condsCurr = _condsCurr - [_x];
		};
		if (["DAYTIME",_x] call BIS_fnc_instring) then {
			_condsCurr = _condsCurr - [_x];
		};
	} foreach _condsCurr;
	//systemChat str _condsCurr;
	_condsCurr pushBack _preCondition;
	private _condsFinal = "";
	//systemChat str _condsCurr;
	{
		_condsFinal = _condsFinal + _x;
		if (_foreachIndex < ((count _condsCurr)-1) ) then {
			_condsFinal = _condsFinal + " && ";
		};

	} foreach _condsCurr;
	//player commandchat str _condsFinal;
	private _funcsCurr = (_statemCurr select 1) splitString ";";
	{
		if (["SUPPRESSION",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["AMBUSH",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["TR_Unload",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["HELI_OVERWATCH",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x]; //-- necessary?
		};
		
		if (["REPAIR",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["setUnitPos",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["LAND",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["ASSEMBLE",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["CASdistribute",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["SLING LOAD",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["SLING DROP",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		if (["TR_Unload",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		
		if (["ASSEMBLE_UAV",_x] call BIS_fnc_instring) then {
			_funcsCurr = _funcsCurr - [_x];
		};

		private _stringCount = count (_x splitString " ");
		if (_stringCount < 2) then {
			_funcsCurr = _funcsCurr - [_x];
		};
		//systemChat str _x;

	} foreach _funcsCurr;

	switch (A3C_HC_EDIT_ACTION) do {
		case ("CLEAR BUILDING") : {
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_CLEARBUILDING.sqf ['%1',%2]",
				getPlayerUID player,
				["ARRIVAL",""]//[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};

		case ("PRECISION LANDING") : {
			//_scriptParams = ((waypointScript _wp) splitString " ") select 1; 
			_wpScript = (waypointScript _wp);
			//format 
			//[
			//	"A3C_CORE\waypointScripts\wpScript_groupGetInVehicle.sqf %1",
			//	_scriptParams
			//];
		};

		case ("GET IN (SYNC)") : {
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_groupGetInVehicle.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};
		
		case ("LOAD GROUP (SYNC)") : {
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_loadGroupInVehicle.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};
		case ("LOAD VIC (SYNC)") : {
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_loadVehicleInVehicle.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};
		case ("BOARD VIC (SYNC)") : {
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_groupGetVehicleInVehicle.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};
		case ("SUPPRESSION") : {
			_statements = format
			[
				"
					[['%1',this,%2,'%3',(currentWaypoint group this)],A3C_ai_highCommand_fnc_insertActionWaypoint] remoteExec ['bis_fnc_call',0];
				",
				getPlayerUID player,
				_statementsINS,
				A3C_HC_ACTIVE_FORM_POST,
				A3C_HC_ACTIVE_IND
			];
		};
		case ("AMBUSH") : {
			_statements = format
			[
				"

					[['%1',this,%2,'%3',(currentWaypoint group this)],A3C_ai_highCommand_fnc_insertActionWaypoint] remoteExec ['bis_fnc_call',0];

				",
				getPlayerUID player,
				_statementsINS,
				A3C_HC_ACTIVE_FORM_POST,
				A3C_HC_ACTIVE_IND
			];
		};
		case ("HELI OVERWATCH") : {
			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_heli_overwatch.sqf ['%1',%2,%3,%4,%5,'%6']",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL],
				A3C_HC_EDIT_COMBOSUBVAL_2,
				A3C_HC_EDIT_COMBOSUBVAL_1,
				A3C_HC_ACTIVE_FORM_POST
			];
		};
		case ("REPAIR") : {
			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_repair.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];

		};
		case ("ASSEMBLE UAV") : {
			_statements = format
			[
				"
					[this,%1,'%2'] spawn A3C_ai_highCommand_fnc_actionAssembleUAV;
				",
				A3C_HC_ACTIVE_WPOS,
				getPlayerUID player

			]; 
		};
		case ("FULL LANDING") : {
			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_Landing.sqf ['%1',%2,%3]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
			];
		};
		case ("COMBATLANDING") : {
			
			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_Landing_Combat.sqf ['%1',%2, %3]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
			];
		};

		case ("TRANSPORT UNLOAD") : {
			// systemChat str [A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL];
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_TR_Unload.sqf ['%1',%2, %3]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
			];
		};

		case ("ASSEMBLE WEAPON") : { //~~ A3C_ai_shared_fnc_actionStaticWeaponExecute may not be defined, move to insert fnc!

			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_AssembleWeapon.sqf ['%1',%2,%3,'']",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
				// -- #TODO: Add weapon classname
			]; 
		};

		case ("CAS-STRIKE") : {
			_statements = format
			[
				"
					[this,%1,%2,'%3'] remoteExec ['A3C_ai_highCommand_fnc_CASdistribute', this];
				",
				A3C_HC_ACTIVE_WPOS,
				A3C_HC_CASMODE_VAL,
				getPlayerUID player
			]; 
		};

		case ("RAPPELL") : {
			_statements = format
			[
				"
					[['%1',this,%2,'%3',(currentWaypoint group this),%5],A3C_ai_highCommand_fnc_insertActionWaypoint] remoteExec ['bis_fnc_call',0];
				",
				getPlayerUID player,
				_statementsINS,
				A3C_HC_ACTIVE_FORM_POST,
				(A3C_HC_ACTIVE_IND + 1),
				A3C_HC_CASMODE_VAL
			];

			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_Rappel.sqf ['%1',%2,'%3',4]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
				["NONE","NONE"],
				A3C_HC_ACTIVE_FORM_POST,
				A3C_HC_CASMODE_VAL
			]; 
			 
		};
		case ("PARADROP") : {

			_statements = "";
			_wpScript = format 
			[
				"A3C_CORE\waypointScripts\wpScript_Paradrop.sqf ['%1',%2]",
				getPlayerUID player,
				[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
			];
		};
	};

	{_funcsCurr pushBack _x} foreach (_statements splitString ";");
	private _funcsFinal = "";

	{
		_funcsFinal = _funcsFinal + _x;
		if (_foreachIndex < ((count _funcsCurr)-1) ) then {
			_funcsFinal = _funcsFinal + "; ";
		};

	} foreach _funcsCurr;

	_wp setWaypointPosition A3C_HC_ACTIVE_WPOS;

	if (_wpScript == "") then {
		if (_waypointType != (waypointType _wp)) then {
			_wp setWaypointType _waypointType;
		};
	} else {
		_wp setWaypointType "SCRIPTED";
	};
	_wp setWaypointScript _wpScript; //-- this has to be here to change to "" when type is not SCRIPTED
	_timeout = if (_wpScript == "") then {[_timeout,_timeout,_timeout]} else {[0,0,0]};
	_wp setWaypointStatements [_condsFinal,_funcsFinal];
	_wp setWaypointFormation A3C_HC_ACTIVE_FORM_PRE;
	_wp setWaypointTimeout _timeout;
	_wp setWaypointCompletionRadius _completionRadius;
	_wp setWaypointSpeed A3C_HC_ACTIVE_WPSPEED;

	[_wp,_waypointBehaviour] remoteExec ["setWaypointBehaviour",2];
	_wp setWaypointCombatMode _waypointCombatMode;

	_group setVariable ["A3C_UNIT_POLYS",_var,true];

	if (_waypointType == "LOITER") then {
		_wp setWaypointLoiterType A3C_HC_EDIT_COMBOSUBVAL_1;
		_wp setWaypointLoiterRadius A3C_HC_EDIT_COMBOSUBVAL_2;
	};
	if (isPlayer leader _group) then {
		[_wp,_actionText] remoteExec ["setWaypointDescription",leader _group];
	};

};

if (_isCurrentWaypoint) then {
	{
		private _vehicle = objectParent _x;
		//-- #FLYINHEIGHTASL
		if (!isNull _vehicle && {_x == driver _vehicle && {_vehicle isKindOf "AIR"}}) then {
			// The legacy ASL-height offset is intentionally not applied.
			private _flyInHeight = _vehicle getVariable ["A3C_FLYINHEIGHT", 75];
			[_vehicle, _flyInHeight] spawn {
				params ["_vehicle", "_flyInHeight"];
				sleep 2;
				// [_vehicle, [_flyInHeight, _flyInHeight, _flyInHeight]] remoteExec ["flyInHeightASL", _vehicle];
				[_vehicle, _flyInHeight] remoteExec ["flyInHeight", _vehicle];
			};
		};
			
	} foreach units _group;
};

[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0];
A3C_HC_ACTIVE_WPOS = [0,0,0];

if (A3C_HC_EDIT_ACTION == "TRANSPORT UNLOAD") then {
	[
		[
			A3C_HC_ACTIVEGROUP
		]
	] call A3C_ui_mapOverlay_fnc_HCWP_openCargoWaypointPrompt;
};