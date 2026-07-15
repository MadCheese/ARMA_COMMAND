#include "..\dialog_defines.hpp" //-- MAP DEFINES
#include "..\script_component.hpp"
#include "..\..\SHARED\shared_ui_defines.hpp"  


if (isDedicated) exitWith {};


//------------------------------------------  M A P  P L A N N I N G  ----------------------------
//----------------------------------------  High Command Context Menu  ---------------------------
//------------------------------------------------------------------------------------------------



//~~ move to A3C_UI_MAP_Main_init.sqf

//A3C_HC_LB_IND = [1,1];
A3C_HC_ACTIVEGROUP = grpNull;
A3C_HC_ACTIVE_IND = 0;
A3C_HC_ACTIVE_IND_A = 0;

A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
A3C_HC_ACTIVE_PRE_COND_VAL = 0;
A3C_HC_ACTIVE_POST_COND_MODE = "NONE";
A3C_HC_ACTIVE_POST_COND_VAL = "NONE";

A3C_ACTIVE_HC_WP_ICON = -1;

A3C_HC_ACTIVE_FORM_PRE = "LINE";
A3C_HC_ACTIVE_FORM_POST = "LINE";

A3C_HC_PREVENT_POLY = false;
A3C_HC_ACTIVE_IND = 0;

A3C_HC_EDIT_ACTION = "MOVE";
A3C_HC_EDIT_TYPE = "MOVE";
A3C_HC_RC_LB_MODE = 0;
A3C_HC_EDIT_COMBOSUBVAL_1 = "CIRCLE_L";
A3C_HC_EDIT_COMBOSUBVAL_2 = 1000;  






A3C_UI_MAP_FNC_HCWPContext_OpenMenu = {


	params ["_gp","_wpiC","_mode","_a3c_dsp","_ctrlPosWPM"];
	private ["_act","_wpiA","_wpA","_wpMenu","_lbWpType","_condition","_actionScript","_lbV2","_lbV3","_lbV4","_lbV5","_lbV6","_lbArray2","_lbArra 0y4"];

	

	if (isPlayer (leader _gp) && (player != (leader _gp))) exitWith {
		systemchat format ["A3C: This waypoint is owned by player %1, no editing possible",name (leader _gp)];
	};
	if ([_gp,_wpIC] in A3C_BLACKLIST_WAYPOINT_EDIT) exitWith {
		systemchat  "A3C: It is too late to cancel this action - wait for completion";
	};

	


	private _wpMenuCtrlsGroup = findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent;
	
	_wpMenuCtrlsGroup ctrlShow true;

	

	_wpiA = -1;
	A3C_HC_ACTIVEGROUP = _gp;
	A3C_HC_ACTIVE_IND = _wpIC; 
	
	private _wp = [_gp,_wpIC];

	private _leaderVic = vehicle leader A3C_HC_ACTIVEGROUP;
	


	A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
	A3C_HC_ACTIVE_PRE_COND_VAL = 0;
	A3C_HC_ACTIVE_POST_COND_MODE = "NONE";
	A3C_HC_ACTIVE_POST_COND_VAL = "NONE";

	A3C_HC_ACTIVE_FORM_PRE = "LINE";
	A3C_HC_ACTIVE_FORM_POST = "LINE";

	A3C_HC_EDIT_ACTION = "MOVE";
	A3C_HC_EDIT_TYPE = "MOVE";

	A3C_HC_PREVENT_POLY = false;

	private _header3Text = "COMPLETION";
	private _preCondModeCtrl = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Type);


	//A3C_HC_LB_IND = [1,1];
	_lbWpType  = 0;

	//_lbV1 = 0;
	_lbV2 = 0;
	_lbV3 = 0;
	_lbV4 = 2;
	_lbV5 = 9;
	_lbV6 = 6;
	_lbVSpeed = 0;

	_lbArray2 = [];
	_lbArray4 = ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
	_actionscript = "";
	_condition = "true";
	private _wpHasPostCondition = false;
	private _wpHasSubSelection = false;
	private _isLimitedWP = false;

	// systemchat 'open menu wp';
	{
		(finddisplay _a3c_dsp displayCtrl _x) ctrlShow false;
	} foreach [
		IDC_MAP_HCWP_Condition_Pre_Mode,
		IDC_MAP_HCWP_Action_Parent_MAIN,
		IDC_MAP_HCWP_Action_Parent_ADD
	]; //-- default: hide precondition val,  actions group and extra selections
	


	{
		_id = _x;
		private _uictrl = (finddisplay _a3c_dsp displayCtrl _id);
		lbClear _uictrl;
		{
			[_uictrl, _x] call A3C_ui_shared_fnc_addLbEntry;
		} foreach ["COLUMN","STAG. COL.","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND","NO CHANGE"];
	} foreach [
		IDC_MAP_HCWP_Formation_Combo,
		IDC_MAP_HCWP_Action_Formation_Combo
	];



	private ["_waypoints","_form"];
	_waypoints = waypoints _gp;

	A3C_HC_ACTIVE_WPOS = waypointPosition _wP;
	A3C_HC_ACTIVE_WPOS set [2,0];
	_condition = if (waypointType _wP == "SCRIPTED" && {!("railed" in (waypointScript _wp))}) then {
		private _params = waypointScript _wp;
		
		
		_params = _params splitString " ";

		
		
		if (count _params > 1) then {
			
			_params deleteAt 0;
			
			

			_params params ["_uidAndPreCond","_postCond"];
			_uidAndPreCond = _uidAndPreCond splitString "";
			_uidAndPreCond deleteAt (count _uidAndPreCond - 1); //-- delete comma
			_uidAndPreCond set [count _uidAndPreCond, "]" ]; //-- add closing bracket to create a completed array
			_uidAndPreCond = _uidAndPreCond joinString ""; //-- rejoin the string 
			_uidAndPreCond = call compile  _uidAndPreCond; //-- convert to array

			
			if (!isNil '_postCond') then {
				// player groupchat str _postCond;
				_postCond = _postCond splitString "";
				_postCond deleteAt (count _postCond - 1); //-- delete excessive ']'
				_postCond = _postCond joinString ""; //-- rejoin the string 
				// player groupchat str _postCond;
				_postCond = call compile  _postCond; //-- convert to array

				
				// _postCond params ["",""];
			};
			

			_uidAndPreCond params ["_preCondType","_preCondMode"];

			// // player sidechat str _uidAndPreCond;
			// player commandchat str _preCondType;
			// player commandchat str _preCondMode;
			// player commandchat str _postCond;

			_params = _preCondMode; //-- overwrite _params as only precondition is required

			//-- select pre-condition
			if (_params select 0 == "GOCODE") then {
				_params = format ["A3C_GoCode_Activate_%1",_params select 1];
			} else {
				_params = str _params;
			};
			
			//systemchat str _params;
		} else {
			_params == ["ARRIVAL",""];
		};
		_params
	} else {
		(waypointstatements _WP) select 0
	};

	_wpType = waypointType _WP;
	_actionScript = switch (true) do {
		case (_wpType == "SCRIPTED") : {waypointScript _WP};

		case (_wpType == "SAD") : {"SEARCH / DESTROY"};
		case (_wpType in ["CYCLE","LOITER"]) : {_wpType};
		default {(waypointstatements _WP) select 1};
	};
	//systemchat str [_wp,_actionScript];
	if (_wpType != "SCRIPTED") then {
		_actionScript = _actionScript splitString ";";
		{
			
			if ("A3C_ai_highCommand_fnc_completeWaypoint" in _x) then {
				_actionScript = _actionScript - [_x];
			};
		} foreach _actionScript;

		_actionScript = _actionScript joinString ";";
	};

	

	_form = waypointFormation _wp;
	//		_lbWpType = switch (_wpType) do {
	//			case ("MOVE") : {1};
	//			case ("SAD") : {2};
	//			case ("LOITER") : {3};
	//			case ("CYCLE") : {4};
	//		};
	_lbVSpeed = switch (waypointSpeed _wP) do {
		case ("UNCHANGED") : {0};
		case ("LIMITED") : {1};
		case ("NORMAL") : {2};
		case ("FULL") : {3};
		default {"UNCHANGED"};
	};
	//A3C_HC_EDIT_TYPE = (_wpType);
	//A3C_HC_LB_IND set [0,_lbWpType];
	(findDisplay _a3c_dsp displayCtrl 709120) ctrlSetText (_wpType);
	//-- NO AIC: WP condition
	if (["GOCODE",_condition] call BIS_fnc_instring) then {
		_lbArray2 = ["A","B","C","D"];
		A3C_HC_ACTIVE_PRE_COND_MODE = "GOCODE";
		//A3C_HC_ACTIVE_PRE_COND_VAL = _condition;
		//_lbV1 = 1;
		//~~ put all these instring things in function
		//systemchat str _condition;
		if (["A3C_GoCode_Activate_A",_condition] call BIS_fnc_instring) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = "A";
			_lbV2 = 0;
		};
		if (["A3C_GoCode_Activate_B",_condition] call BIS_fnc_instring) then {
			
			A3C_HC_ACTIVE_PRE_COND_VAL = "B";
			_lbV2 = 1;
		};
		if (["A3C_GoCode_Activate_C",_condition] call BIS_fnc_instring) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = "C";
			_lbV2 = 2;
		};
		if (["A3C_GoCode_Activate_D",_condition] call BIS_fnc_instring) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = "D";
			_lbV2 = 3;
		};
	} else {
		
		if (["TIMEOUT",_condition] call BIS_fnc_instring) then {

			_timeOut = if (_wpType == "SCRIPTED") then {(call compile _condition) select 1} else {(waypointTimeout _WP) select 1};
			

			A3C_HC_ACTIVE_PRE_COND_MODE = "TIMEOUT";
			_lbArray2 = ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];

			if (_timeOut == 30) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 30;
				_lbV2 = 0;
			};
			if (_timeOut == 60) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 60;
				_lbV2 = 1;
			};
			if (_timeOut == 90) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 90;
				_lbV2 = 2;
			};
			if (_timeOut == 120) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 120;
				_lbV2 = 3;
			};
			if (_timeOut == 180) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 180;
				_lbV2 = 4;
			};
			if (_timeOut == 240) then {
				A3C_HC_ACTIVE_PRE_COND_VAL = 240;
				_lbV2 = 5;
			};

		} else {
			if (["DAYTIME",_condition] call BIS_fnc_instring) then {
				private _str = "";
				if (_wpType == "SCRIPTED") then {
					_str = (_condition splitString "[],") select 1;
					_str = call compile _str;;
					_str = _str splitstring ":";
					_str = ["_placeholder"] + _str;
				} else {
					_str = _condition splitstring " [],()&=";
					//-- remove unnecessary added 'true' conditionsm
					while {_str select 1 == "true"} do {
						_str deleteAt 1;
					};
				};
				A3C_HC_ACTIVE_PRE_COND_MODE = "DAYTIME";
				_str params ["_placeHolder","_wpY","_wpMo","_wpDay","_wpHour","_wpMin"];
				if (count _wpHour == 1) then {
					_wpHour =  ([parseNumber _wpHour] call A3C_daytimeZeroComp);
				};
				
				if (count _wpMin == 1) then {
					_wpMin =  ([parseNumber _wpMin] call A3C_daytimeZeroComp);
				};

				_h = date select 3;
				_m = date select 4;
				_m = if (((round (_m * 0.1) ) * 10) < _m) then {((floor (_m * 0.1) ) * 10)} else {((ceil (_m * 0.1) ) * 10)};
				
				_timeString = "";
				_lbV2 = 2;
				_lbArray2 = [];

				_wpTimeString =  _wpHour + ":" + _wpMin;
				
				A3C_HC_ACTIVE_PRE_COND_VAL = format ["%1:%2:%3:%4:%5",_wpY,_wpMo,_wpDay,_wpHour,_wpMin];
				for "_i" from 1 to 7 do {
					if (_m >= 60) then {
						_h = _h + 1;
						if (_h >= 24) then {_h = 00};
						_m = 0;
					};
					_timeString = format 
					[
						"%1:%2",
						[_h] call A3C_daytimeZeroComp,
						[_m] call A3C_daytimeZeroComp
					];
					_lbArray2 pushBack _timeString;
					
					if ( _wpTimeString == _timeString) then {

						_lbV2 = (_i - 1);
					};
					_m = _m + 5;
				};
			};
		};
	};

	private _casTypeCurrent = 0; //-- has to be fetched in advance
	//systemchat str _lbV2;

	//-- waypointexecutables
	//player commandchat str _actionScript;
	//systemchat str _actionscript;
	if (_wpType == "SCRIPTED") then {
		//-- remove pre-condition
		_actionScript = _actionScript splitString ",";
		for "_i" from 1 to 2 do {
			_actionScript deleteAt 1;
		};
		_actionScript = _actionScript joinString ",";
		
		//copyToClipboard str (_actionScript);
	};

		private ["_commandLines"];

		switch (true) do {

			case (["CLEARBUILDING",_actionscript] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "CLEAR BUILDING";
				_isLimitedWP = true;
			};

			
			
			case (["wpScript_groupGetInVehicle",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "GET IN (SYNC)";
				_isLimitedWP = true;
			};
			case (["wpScript_LoadGroupInVehicle",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "LOAD GROUP (SYNC)";
				_isLimitedWP = true;
			};
			case (["wpScript_LoadVehicleInVehicle",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "LOAD VIC (SYNC)";
				_isLimitedWP = true;
			};
			case (["wpScript_groupGetVehicleInVehicle",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "BOARD VIC (SYNC)";
				_isLimitedWP = true;
			};
			case (["SEARCH /",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "SEARCH / DESTROY";
			};
			case (["CYCLE",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "CYCLE";
			};
			case (["LOITER",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "LOITER";
				_wpHasSubSelection = true;
			};
			case (["SUPPRESSION",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "SUPPRESSION";
				A3C_HC_PREVENT_POLY = true;
				_wpHasPostCondition = true;
			};
			case (["AMBUSH",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "AMBUSH";
				A3C_HC_PREVENT_POLY = true;
				_wpHasPostCondition = true;
			};
			case (["HELI_OVERWATCH",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "HELI OVERWATCH";
				//A3C_HC_LB_IND set [1,3];
				_wpHasSubSelection = true;
				_wpHasPostCondition = true;
			};
			case (["AssembleWeapon",_actionScript] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "ASSEMBLE WEAPON";
				A3C_HC_PREVENT_POLY = true;
				_wpHasPostCondition = true;
			};
			case (["land",_actionScript] call BIS_fnc_instring) : {
				if ("railed" in _actionScript) then {
					_isLimitedWP = true;
					A3C_HC_EDIT_ACTION = "PRECISION LANDING";
				} else {
					if (["COMBAT",_actionScript] call BIS_fnc_instring) then {
						//A3C_HC_LB_IND set [1,3]; //~~
						A3C_HC_EDIT_ACTION = "COMBATLANDING";
						_wpHasPostCondition = true;
					} else {
						//A3C_HC_LB_IND set [1,2]; //~~
						A3C_HC_EDIT_ACTION = "FULL LANDING";
					};
				};
				
			};
			case (["RAPPELL",_actionScript ] call BIS_fnc_instring) : {
				//_flexLBpara = if ( (vehicle (leader _gp)) isKindOf "HELICOPTER" ) then {4} else {3};
				A3C_HC_EDIT_ACTION = "RAPPELL";
				//A3C_HC_LB_IND set [1,_flexLBpara]; //~~
			};
			case (["TR_Unload",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "TRANSPORT UNLOAD";
				//_isLimitedWP = true;
			};

			case (["SLING LOAD HOOK",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "SLING LOAD";
			};
			case (["ASSEMBLE UAV",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "ASSEMBLE UAV";
			};
			case (["PlantExplosive_HC",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "DEMOLITION";
			};
			case (["REPAIR",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "REPAIR";
			};
			case (["ASSEMBLE_UAV",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "ASSEMBLE UAV";
			};
			case (["SLING LOAD UNHOOK",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "SLING DROP";
			};
			case (["PARADROP",_actionScript ] call BIS_fnc_instring) : {
				A3C_HC_EDIT_ACTION = "PARADROP";
			};
			case (["CASdistribute",_actionScript ] call BIS_fnc_instring) : {
				private _pType = typeOf _leaderVic;
				A3C_HC_CASMODES = [_pType] call A3C_main_fnc_getCASmodes;
				
				_flexLBCAS = 3;
				if ( ({((assignedVehicleRole _x) select 0) == "cargo"} count crew (vehicle (leader _gp)) > 0) OR (count (getVehicleCargo (vehicle (leader _gp))) > 0) ) then {
					_flexLBCAS = 4;
				};

				_casTypeCurrent = parseNumber ((_actionscript splitstring ",") select 4);
				

				A3C_HC_EDIT_ACTION = "CAS-STRIKE";

			};
		};
		

		_commandLines = _actionScript  splitString ";";
		//systemchat str _commandlines;
		{
			_cL = _x;
			//systemchat str _x;
			if (["GOCODE",_cL] call BIS_fnc_instring) then {

				A3C_HC_ACTIVE_POST_COND_MODE = "GOCODE";
				//systemchat "hey";
				_lbV3 = 1;
				_lbArray4 = ["A","B","C","D"];
				if (["[""GOCODE"",""A""]",_x] call BIS_fnc_instring) then {
					A3C_HC_ACTIVE_POST_COND_VAL = "A";
					_lbV4 = 0;
				};
				if (["[""GOCODE"",""B""]",_x] call BIS_fnc_instring) then {
					A3C_HC_ACTIVE_POST_COND_VAL = "B";
					_lbV4 = 1;
				};
				if (["[""GOCODE"",""C""]",_x] call BIS_fnc_instring) then {
					A3C_HC_ACTIVE_POST_COND_VAL = "C";
					_lbV4 = 2;
				};
				if (["[""GOCODE"",""D""]",_x] call BIS_fnc_instring) then {
					A3C_HC_ACTIVE_POST_COND_VAL = "D";
					_lbV4 = 3;
				};


			} else {
				//systemchat "1";
				//_lbV3 = 0;
				//_lbArray4 = ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
				if (["TIME",_cL] call BIS_fnc_instring) then {
					if (["TIMEOUT",_cL] call BIS_fnc_instring) then {
						A3C_HC_ACTIVE_POST_COND_MODE = "TimeOut";
						_lbArray4 = ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
						if (["[""TIMEOUT"",30]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 30;
							_lbV4 = 0;
						};
						if (["[""TIMEOUT"",60]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 60;
							_lbV4 = 1;
						};
						if (["[""TIMEOUT"",90]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 90;
							_lbV4 = 2;
						};
						if (["[""TIMEOUT"",120]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 120;
							_lbV4 = 3;
						};
						if (["[""TIMEOUT"",180]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 180;
							_lbV4 = 4;
						};
						if (["[""TIMEOUT"",240]",_x] call BIS_fnc_instring) then {
							A3C_HC_ACTIVE_POST_COND_VAL = 240;
							_lbV4 = 5;
						};
					} else {
						private ["_str"];
						A3C_HC_ACTIVE_POST_COND_MODE = "DAYTIME";
						_str = [];
						if (_wpType == "SCRIPTED") then {
							_str = _cL splitString """[],"; //"[],"; //((_cL splitstring "1234567890") joinString "");
							// systemchat str _cl;
							_str = _str select 3;
							_str = _str splitstring ":";
							
						} else {
							_str = _cL splitString """[],";
							{
								if ("_" in _x) exitWith {};
								_str = _str - [_x];
							} foreach _str;
							_str = _str select 3;
							_str = _str splitString ":";
							//systemChat str _str;
						};
						_str params ["_wpY","_wpMo","_wpDay","_wpHour","_wpMin"];
						
						
						if (count _wpHour == 1) then {
							_wpHour =  ([parseNumber _wpHour] call A3C_daytimeZeroComp);
						};
						
						if (count _wpMin == 1) then {
							_wpMin =  ([parseNumber _wpMin] call A3C_daytimeZeroComp);
						};
						
						
						//format ["%1:%2",parseNumber (_str select 3), parseNumber (_str select 4)];
						

						_h = date select 3;
						_m = date select 4;
						_m = if (((round (_m * 0.1) ) * 10) < _m) then {((floor (_m * 0.1) ) * 10)} else {((ceil (_m * 0.1) ) * 10)};
						
						_timeString = "";
						_lbV3 = 2;
						_lbArray4 = [];

						
						
						_wpTimeString =  _wpHour + ":" + _wpMin;
						
						A3C_HC_ACTIVE_POST_COND_VAL = format ["%1:%2:%3:%4:%5",_wpY,_wpMo,_wpDay,_wpHour,_wpMin];
						for "_i" from 1 to 7 do {
							if (_m >= 60) then {
								_h = _h + 1;
								if (_h >= 24) then {_h = 00};
								_m = 0;
							};
							_timeString = format 
							[
								"%1:%2",
								[_h] call A3C_daytimeZeroComp,
								[_m] call A3C_daytimeZeroComp
							];
							_lbArray4 pushBack _timeString;
							//player groupchat str [_wpTimeString,_timeString];
							if ( _wpTimeString == _timeString) then {
								//A3C_HC_ACTIVE_POST_COND_VAL = format ["%1:%2:%3:%4:5",
								//systemchat str [_timeStrimng,A3C_HC_ACTIVE_POST_COND_VAL];
								_lbV4 = (_i - 1);
							};
							_m = _m + 5;
						};

					};
				};
			};
			if !(["CASdistribute",_actionscript] call BIS_fnc_instring) then {
				{
					if ([_x,_cL] call BIS_fnc_instring) then {
						//A3C_HC_ACTIVE_POST_COND_VAL = _x;
						A3C_HC_ACTIVE_FORM_POST = _x;
						_lbV6 = _forEachIndex;
					};
				} foreach ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND","NO CHANGE"];
			};
		} foreach _commandLines;

	{
		if (_x == _form) exitWith {
			_lbV5 = _forEachIndex;
		};
	} foreach ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND","NO CHANGE"];



	if (_wpHasPostCondition) then {
		(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN) ctrlShow true;
	};

	
	if (_isLimitedWP) then {

		
		_combo = (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Action);
		lbClear _combo;
		[_combo, A3C_HC_EDIT_ACTION] call A3C_ui_shared_fnc_addLbEntry;
		[_combo, 0, true] call A3C_ui_shared_fnc_lbSetCurSel;
	} else {
		[] call A3C_UI_MAP_WPMENU_ADDACTIONS;
	};



	//--------------------------- ADJUST CONTROL-POSITIONS
	//-- engage prevent lb action

	//-- HEADER: GROUP NAME
	(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_GROUPNAME_TXT) ctrlSetText (format ["%1 - [%2]",toUpper groupID _gp,_wpIC]);

	lbClear (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Speed_Combo);	
	
	if !(A3C_HC_EDIT_ACTION in ["CLEAR BUILDING", "CAS-STRIKE"]) then {
		{
			lbClear _x;
		} forEach (["map_hcwp_conditionCombos_clearable"] call FUNC(ctrlGroup));
	};
	
	{
		[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Speed_Combo, _x] call A3C_ui_shared_fnc_addLbEntry;
	} foreach ["UNCHANGED","LIMITED","NORMAL","FULL"];
	[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Speed_Combo, _lbVSpeed, true] call A3C_ui_shared_fnc_lbSetCurSel;

	_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Formation_Combo);
	_refH = _refPos select 3;
	_refY = (_refPos select 1) + _refH;

	//-- ADJUST TYPE-ACTION and PRE-COND / CAS boxes
	_ref1 = if (A3C_HC_EDIT_ACTION == "CAS-STRIKE") then {IDC_MAP_HCWP_Type_Parent} else {IDC_MAP_HCWP_Completion_Parent};
	_ref2 = if (A3C_HC_EDIT_ACTION == "CAS-STRIKE") then {IDC_MAP_HCWP_Completion_Parent} else {IDC_MAP_HCWP_Type_Parent};
		
	//-- box1
	_box =  (finddisplay _a3c_dsp displayCtrl _ref1);
	_ctrlPos = +(ctrlPosition _box);
	_ctrlPos set [1,_refY];
	_box ctrlSetPosition _ctrlPos;
	_box ctrlCommit 0;
	
	//-- box2
	_refY = _refY + (_ctrlPos select 3);
	_box =  (finddisplay _a3c_dsp displayCtrl _ref2);
	_ctrlPos = +(ctrlPosition _box);
	_ctrlPos set [1,_refY];
	_box ctrlSetPosition _ctrlPos;
	_box ctrlCommit 0;


	//-- adjust type controls
	private _condMacro = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Completion_Parent);
	//if (true) exitWith {};

	if (_wpHasSubSelection) then {
		
		private _box = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_ADD);
		_ctrlPos = ctrlPosition _box;

		_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Parent);
		_refH = _refPos select 3;
		_refY = (_refPos select 1) + _refH;
		_ctrlPos set [1,_refY];
		_box ctrlSetPosition _ctrlPos;
		_box ctrlCommit 0;
		_box ctrlShow true;

		_subTextCtrl1 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Formation_TXT);
		_subTextCtrl2 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Completion_TXT);
		_subCombo1 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo);
		_subCombo2 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo);
		private _lbSel1 = 0;
		private _lbSel2 = 0;
		_subText1 = "";
		_subText2 = "";
		_subArray1 = [];
		_subArray2 = [];
		switch (A3C_HC_EDIT_ACTION) do {
			case ("LOITER") : {
				_subText1 = "LOITER DIRECTION";
				_subText2 = "LOITER RADIUS";
				_subArray1 = ["CLOCKWISE","CNTR CLOCKWISE"];
				_subArray2 = ["100","500","1000","2000"];
				A3C_HC_EDIT_COMBOSUBVAL_1 = waypointLoiterType _wp;
				A3C_HC_EDIT_COMBOSUBVAL_2 = waypointLoiterRadius _wp;
				_lbSel1 = switch (A3C_HC_EDIT_COMBOSUBVAL_1) do {
					case ("CIRCLE") : {0};
					case ("CIRCLE_L") : {1};
				};
				_lbSel2 = switch (A3C_HC_EDIT_COMBOSUBVAL_2) do {
					case (100) : {0};
					case (500) : {1};
					case (1000) : {2};
					case (2000) : {3};
				};
			};
			case ("HELI OVERWATCH") : {
				_subText1 = "HOVER HEIGHT";
				_subText2 = "ORIENTATION";
				_subArray1 = ["100","200","500","1000"];
				_subArray2 = ["NORTH","NORTH-EAST","EAST","SOUTH-EAST","SOUTH","SOUTH-WEST","WEST","NORTH-WEST"];
				_scriptData = (waypointScript [_gp,_wpIC]) splitstring "[,]";
				
				_lbSel1Data = (_scriptData select 7);
				_lbSel2Data = (_scriptData select 6);
				{
					if (_x == _lbSel1Data) exitWith {
						_lbSel1 = _foreachIndex;
						A3C_HC_EDIT_COMBOSUBVAL_1 = parseNumber _x;
					};
				} foreach _subArray1;
				_lbSel2 = switch (_lbSel2Data) do {
					case ("0") : {0};
					case ("45") : {1};
					case ("90") : {2};
					case ("135") : {3};
					case ("180") : {4};
					case ("225") : {5};
					case ("270") : {6};
					case ("315") : {7};
				};
				A3C_HC_EDIT_COMBOSUBVAL_2 = parseNumber _lbSel2Data;
				//player groupchat str [_lbSel2Data,_lbSel2];
			};
		};
		_subTextCtrl1 ctrlSetText _subText1;
		_subTextCtrl2 ctrlSetText _subText2;

		lbClear _subCombo1;
		{
			[_subCombo1, _x] call A3C_ui_shared_fnc_addLbEntry;
		} foreach _subArray1;
		[_subCombo1, _lbSel1, true] call A3C_ui_shared_fnc_lbSetCurSel;

		lbClear _subCombo2;
		{
			[_subCombo2, _x] call A3C_ui_shared_fnc_addLbEntry;
		} foreach _subArray2;
		[_subCombo2, _lbSel2, true] call A3C_ui_shared_fnc_lbSetCurSel;


	};

	//-- ADJUST POSTCONDITION
	if (_wpHasPostCondition) then {
		_refCtrl = if (_wpHasSubSelection) then {IDC_MAP_HCWP_Action_Parent_ADD} else {IDC_MAP_HCWP_Type_Parent};
		_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl _refCtrl);
		_refH = _refPos select 3;
		_refY = (_refPos select 1) + _refH;
		_refPos set [1,_refY];
	
		_ctrl = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN);
		_ctrlPos = ctrlPosition _ctrl;
		

		
		_ctrlPos set [1,_refY]; // + _add
		_ctrl ctrlSetPosition _ctrlPos;
		_ctrl ctrlCommit 0;
	};

	

	

	//-- ADJUST CONFIRM / DELETE BUTTONS

	_refCtrl = switch (true) do {
		case (_wpHasPostCondition) : {IDC_MAP_HCWP_Action_Parent_MAIN};
		case (_wpHasSubSelection) : {IDC_MAP_HCWP_Action_Parent_ADD};
		default {if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {IDC_MAP_HCWP_Type_Parent} else {IDC_MAP_HCWP_Completion_Parent}};
	};

	
	_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl _refCtrl); 
	_refH = _refPos select 3;
	_refY = (_refPos select 1) + _refH;

	{
		private _ctrl = _x;
		private _ctrlPos = ctrlPosition _ctrl;

		_ctrlPos set [1, _refY];

		_ctrl ctrlSetPosition _ctrlPos;
		_ctrl ctrlCommit 0;
	} forEach (["map_hcwp_macro_confirmAndCancel"] call FUNC(ctrlGroup));


	//----------------------------------- APPLY LABELS
	
	if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {
		lbClear _preCondModeCtrl;
		{
			private _lbText = if (_x == "GOCODE") then {"GO-CODE"} else {_x};
			[_preCondModeCtrl, _lbText] call A3C_ui_shared_fnc_addLbEntry;
			if (_x == A3C_HC_ACTIVE_PRE_COND_MODE) then {
				[_preCondModeCtrl, _foreachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
			};
		} foreach ["ARRIVAL","GOCODE","TIMEOUT","DAYTIME"];
	};
	

	private _fullW = (ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_GROUPNAME_BG)) select 2;
	
	_refPos = ctrlPosition _preCondModeCtrl;
	_refPos params ["_refX","_refY","_refW","_refH"];
	_refY = _refY + _refH;
	if !(A3C_HC_ACTIVE_PRE_COND_MODE == "ARRIVAL") then {
		//-- reposition controls
		private _valueComboCtrl = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode);
		
		{
			[_valueComboCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
			_lbValue = _x;
			if (A3C_HC_ACTIVE_PRE_COND_MODE == "TIMEOUT") then {
				//["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
				_lbValue = switch (_lbValue) do {
					case ("30SEK") : {30};
					case ("60SEK") : {60};
					case ("90SEK") : {90};
					case ("2MIN") : {120};
					case ("3MIN") : {180};
					case ("4MIN") : {240};
				};
			};
			if (A3C_HC_ACTIVE_PRE_COND_MODE == "DAYTIME") then {
				[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, _lbV2, true] call A3C_ui_shared_fnc_lbSetCurSel;
			};
			
			
			//player groupchat str [_lbValue , A3C_HC_ACTIVE_PRE_COND_VAL];
			if (_lbValue == A3C_HC_ACTIVE_PRE_COND_VAL) then {
				//systemchat str ['open_',_lbValue,A3C_HC_ACTIVE_PRE_COND_VAL];
				[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, _foreachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
				//if (A3C_HC_ACTIVE_PRE_COND_MODE == "DAYTIME") then {
				//	//~~ currently this uses current date for re-opening UI - check if this creates trouble with date switch
				//	A3C_HC_ACTIVE_PRE_COND_VAL = (format ["%1:%2:%3:",date select 0,date select 1,date select 2]) + _lbValue; 
				//};
			};

			
		} foreach _lbArray2;
		_valueComboCtrl ctrlShow true;
		_refPos set [2,_fullW / 2];
	} else {
		_refPos set [2,_fullW];
	};

	
	


	_postConArray = ["TIMEOUT","GOCODE","DAYTIME"];
	if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {
		_postConArray = ["None"] + _postConArray;
	};
	lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type);
	{
		//if (_lbV3 > 0) then {
		//	_lbV3 = _lbV3 + 1;
		//};
		[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _x] call A3C_ui_shared_fnc_addLbEntry;
	} foreach _postConArray;
	//systemchat str A3C_HC_ACTIVE_POST_COND_MODE;
	_lbV3 = switch (toLower A3C_HC_ACTIVE_POST_COND_MODE) do {
		case ("none") : {
			0
		};
		case ("timeout") : {
			if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {1} else {0};
		};
		case ("gocode") : {
			if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {2} else {1};
		};
		case ("daytime") : {
			if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {3} else {2};
		};
	};

	[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _lbV3] call A3C_ui_shared_fnc_lbSetCurSel;

	lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
	{
		[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
	} foreach _lbArray4;

	_ctrlPosWPM = [_a3c_dsp,IDC_MAP_HCWP_Parent,_ctrlPosWPM] call A3C_UI_MAP_fnc_findCtrlSafePos;
	_wpMenuCtrlsGroup ctrlSetPosition _ctrlPosWPM;
	_wpMenuCtrlsGroup ctrlCommit 0;
	[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _lbV4] call A3C_ui_shared_fnc_lbSetCurSel;
	[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Formation_Combo, _lbV5] call A3C_ui_shared_fnc_lbSetCurSel;
	[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Formation_Combo, _lbV6] call A3C_ui_shared_fnc_lbSetCurSel;

	(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Completion_Header_TXT) ctrlSetText _header3Text;






	//-- wp behaviour
	private _comboCtrl = finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Behaviour_Combo;

	lbClear _comboCtrl;
	{
		[_comboCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
		if (_x == (waypointBehaviour [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND])) then {
			[_comboCtrl, _foreachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
		};
	} foreach 
	[
		"UNCHANGED",
		"CARELESS",
		"SAFE",
		"AWARE",
		"COMBAT",
		"STEALTH"
	];

	//-- wp combatmode
	private _comboCtrl = finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_CombatMode_Combo;
	lbClear _comboCtrl;
	{
		_translation = ["NO CHANGE","BLUE","GREEN","WHITE","YELLOW","RED"] select _foreachIndex;
		[_comboCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
		if (_translation == (waypointCombatMode [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND])) then {
			[_comboCtrl, _foreachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		_comboCtrl lbSetColor
		[
			_foreachIndex,
			[
				[0.5,0.5,0.5,1],
				A3C_UI_COLOR_BLUE,
				[0,1,0,1],
				[1,1,1,1],
				A3C_UI_COLOR_YELLOW,
				A3C_UI_COLOR_RED
			] select _foreachIndex
		];
	} foreach 
	[
		"NO CHANGE",
		"NEVER FIRE",
		"HOLD FIRE, DEFEND",
		"HOLD FIRE, ENGAGE",
		"OPEN FIRE",
		"FIRE & ENGAGE"
	];


	//-- set focus to ctrlsGroup parent 
	ctrlSetFocus _wpMenuCtrlsGroup;
	
};




A3C_Map_HC_waypointContext_ButtonFnc_Confirm = {
	private _a3c_dsp = IDD_MAP_OVERLAY;
	private ["_group","_wp","_condition","_statements","_statementsINS","_indSel","_indSelActive","_indAdd","_dirTo","_wpCount","_wpsActive","_wpCountActive","_wpA","_wpC","_wpS","_wpI","_polygon","_var","_tPos","_dirTo","_dist"];
	_group = A3C_HC_ACTIVEGROUP; //_this select 0;

	
	private _wpMenuCtrlsGroup = findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent;


	_tPos = [];
	_wp = [];
	_dirTo = 0;
	_timeout = if (A3C_HC_ACTIVE_PRE_COND_MODE == "TIMEOUT") then {A3C_HC_ACTIVE_PRE_COND_VAL} else {0};
	private _actionCtrl = (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Action);
	private _actionText = _actionCtrl lbText (lbCurSel _actionCtrl);

	_wpMenuCtrlsGroup ctrlShow false;
	(findDisplay 12 displayCtrl 51) ctrlEnable true;

	private _leader = leader _group;
	private _wp = [_group, A3C_HC_ACTIVE_IND];
	_preCondition = switch (A3C_HC_ACTIVE_PRE_COND_MODE) do {
		case ("ARRIVAL") : {"true"};
		case ("GOCODE") : {format ["A3C_GoCode_Activate_%1",A3C_HC_ACTIVE_PRE_COND_VAL]};
		case ("TIMEOUT") : {
			//-- (count ['TIMEOUT'] == 1) returns true and is just there to include "TIMEOUT" in the condition
			"true && (count ['TIMEOUT'] == 1)"
		};
		case ("DAYTIME") : {
			//-- (count ['DAYTIME'] == 1) returns true and is just there to include "DAYTIME" in the condition
			_str = A3C_HC_ACTIVE_PRE_COND_VAL splitString ":";
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
	



	_dist = 50;
	if (A3C_HC_EDIT_ACTION in ["ASSEMBLE WEAPON"]) then {
		_dist = 15;
	};


	

	_statements = "";
	_statementsINS = [[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL],A3C_HC_EDIT_ACTION];



	if (A3C_HC_ACTIVE_PRE_COND_MODE == "GOCODE") then {
		A3C_GOCODES_HC pushbackUnique A3C_HC_ACTIVE_PRE_COND_VAL;
		publicVariable 'A3C_GOCODES_HC';
	};



	
	_tPos = (waypointPosition _wp);
	_tPos = [_tPos,_dist,0] call BIS_fnc_relPos;
	_dirTo = [(waypointPosition _wp),_tPos] call BIS_fnc_dirTo;
	_indSel = A3C_HC_ACTIVE_IND;
	

	private _isCurrentWaypoint = A3C_HC_ACTIVE_IND == currentWaypoint _group;

	//-- draw poly unless it already exists. Shared by all modes
	_var = _group getvariable ["A3C_UNIT_POLYS",[]];
	if (A3C_HC_EDIT_ACTION in ["SUPPRESSION","AMBUSH","ASSEMBLE WEAPON"]) then {
		private _prefix = switch (A3C_HC_EDIT_ACTION) do {
			case ("SUPPRESSION") : {'SUP'};
			case ("AMBUSH") : {'AMB'};
			case ("ASSEMBLE WEAPON") : {'ASS'}; //-- ASS stands for 'assemble' you cheeky little kitten.
		};
		
		_tpos set [2,0]; //==-- security mechanic: sometimes z-value is missing!
		if !(A3C_HC_PREVENT_POLY) then {
			_polygon = [];
			if !(A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
				//-- action is NOT assembling weapon. create VISIBLE polygon
				_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ([_tPos,_dirTo,A3C_HC_EDIT_ACTION,true] call A3C_ai_shared_fnc_polygonAreaCreate));
			} else {
				//-- action IS assembling weapon. create INVISIBLE polygon
				//player setpos _tpos;
				_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ( [[_tPos,_tPos,_tPos,_tPos],["","","",""],0]) );
			};
			//systemChat str _polygon;
			A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
			_var pushback _polygon;
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
		_refAIunits = +(A3C_SUPPRESSION_UNITS_AI);
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

	private _waypointBehaviour = switch (lbCurSel (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Behaviour_Combo)) do {
		case (0) : {"UNCHANGED"};
		case (1) : {"CARELESS"};
		case (2) : {"SAFE"};
		case (3) : {"AWARE"};
		case (4) : {"COMBAT"};
		case (5) : {"STEALTH"};
	};

	private _waypointCombatMode = switch (lbCurSel (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_CombatMode_Combo)) do {
		case (0) : {"NO CHANGE"};
		case (1) : {"BLUE"};
		case (2) : {"GREEN"};
		case (3) : {"WHITE"};
		case (4) : {"YELLOW"};
		case (5) : {"RED"};
	};

	if (A3C_HC_EDIT_ACTION in ["SLING LOAD","SLING DROP"]) then {

		_slingMode = [A3C_HC_ACTIVEGROUP] call A3C_ai_highCommand_fnc_getSlingMode;

		if (_slingMode == "HOOK") then {
			A3C_PICKUP_OBJECTS = [(vehicle (leader A3C_HC_ACTIVEGROUP)),A3C_HC_ACTIVE_WPOS] call MCSS_fnc_getNearSlingLoadObjects;
			_waypointType  = "MOVE";
		} else {
			_waypointType  = "UNHOOK";
			_statements = " 'SLING LOAD UNHOOK'; "; //-- just to have something for the UI to read
		};
	};


	private _completionRadius = if (A3C_HC_EDIT_ACTION in ["FULL LANDING","CAS-STRIKE"]) then {1000} else {0};

	_activeWaypointPosition = [];
	if (A3C_HC_EDIT_ACTION == "CAS-STRIKE") then {

		_activeWaypointPosition = waypointPosition [_group,A3C_HC_ACTIVE_IND];
		
		if ([_group, A3C_HC_ACTIVE_IND, _activeWaypointPosition] call A3C_ai_highCommand_fnc_CASpreventAction ) then {
			A3C_HC_EDIT_ACTION = "MOVE";
			_statements = "";
			systemchat format ["A3C: Approach is not long enough for %1's CAS strike! Waypoint reverted to NO ACTION", groupID _group];
		};
	};
	
	if (A3C_HC_EDIT_ACTION == "FULL LANDING") then {
		_vehi = vehicle leader _group;
		private _runwayLanding = ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehi >> "landingSpeed")) > 10);
		if (_vehi isKindOf "PLANE" && {_runwayLanding}) then {
			private _airportData = [A3C_HC_ACTIVE_WPOS] call A3C_main_fnc_getNearestAirportData;
			_airportData params ["_airportID","_airportName","_airportTaxiIn","_airportTaxiOff","_airportIlsDir","_taxiInPoses","_taxiOffPoses"];
			A3C_HC_ACTIVE_WPOS = if (_airportID > -1) then {_airportTaxiIn} else {position _airportName}; //-- on dynamic airfields, 'airportName' is the actual object
			//systemchat str _airportData;
		};
	};
	if !(A3C_HC_EDIT_ACTION in ["DEMOLITION"]) then {

		_statemCurr = waypointStatements _wp;
		_condsCurr = (_statemCurr select 0) splitString "&&";
		_wpScript = "";

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
		//systemchat str _condsCurr;
		_condsCurr pushBack _preCondition;
		_condsFinal = "";
		//systemchat str _condsCurr;
		{
			_condsFinal = _condsFinal + _x;
			if (_foreachIndex < ((count _condsCurr)-1) ) then {
				_condsFinal = _condsFinal + " && ";
			};

		} foreach _condsCurr;
		//player commandchat str _condsFinal;
		_funcsCurr = (_statemCurr select 1) splitString ";";
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
			if (["PlantExplosive_HC",_x] call BIS_fnc_instring) then {
				_funcsCurr = _funcsCurr - [_x];
			};
			if (["ASSEMBLE_UAV",_x] call BIS_fnc_instring) then {
				_funcsCurr = _funcsCurr - [_x];
			};

			_stringCount = count (_x splitString " ");
			if (_stringCount < 2) then {
				_funcsCurr = _funcsCurr - [_x];
			};
			//systemchat str _x;


		} foreach _funcsCurr;
		switch (A3C_HC_EDIT_ACTION) do {
			case ("CLEAR BUILDING") : {
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_CLEARBUILDING.sqf ['%1',%2]",
					getPlayerUID player,
					["ARRIVAL",""]//[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
				];
			};

			case ("PRECISION LANDING") : {
				//_scriptParams = ((waypointScript _wp) splitString " ") select 1; 
				_wpScript = (waypointScript _wp);
				//format 
				//[
				//	"A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetInVehicle.sqf %1",
				//	_scriptParams
				//];
			};

			case ("GET IN (SYNC)") : {
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetInVehicle.sqf ['%1',%2]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
				];
			};
			
			case ("LOAD GROUP (SYNC)") : {
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_loadGroupInVehicle.sqf ['%1',%2]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
				];
			};
			case ("LOAD VIC (SYNC)") : {
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_loadVehicleInVehicle.sqf ['%1',%2]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
				];
			};
			case ("BOARD VIC (SYNC)") : {
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_groupGetVehicleInVehicle.sqf ['%1',%2]",
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
					"A3C_CORE\fnc_AI\wpFncs\wpScript_heli_overwatch.sqf ['%1',%2,%3,%4,%5,'%6']",
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
					"A3C_CORE\fnc_AI\wpFncs\wpScript_repair.sqf ['%1',%2]",
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
					"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing.sqf ['%1',%2,%3]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
					[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
				];
			};
			case ("COMBATLANDING") : {
				
				_statements = "";
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_Landing_Combat.sqf ['%1',%2, %3]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
					[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
				];
			};

			case ("TRANSPORT UNLOAD") : {
				// systemchat str [A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL];
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_TR_Unload.sqf ['%1',%2, %3]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
					[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
				];
			};

			case ("ASSEMBLE WEAPON") : { //~~ A3C_ai_shared_fnc_actionStaticWeaponExecute may not be defined, move to insert fnc!


				_statements = "";
				_wpScript = format 
				[
					"A3C_CORE\fnc_AI\wpFncs\wpScript_AssembleWeapon.sqf ['%1',%2,%3,'']",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL],
					[A3C_HC_ACTIVE_POST_COND_MODE,A3C_HC_ACTIVE_POST_COND_VAL]
					// -- #TODO: Add weapon classname
				]; 
			};

			case ("CAS-STRIKE") : {
				_casPos = [];
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
					"A3C_CORE\fnc_AI\wpFncs\wpScript_Rappel.sqf ['%1',%2,'%3',4]",
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
					"A3C_CORE\fnc_AI\wpFncs\wpScript_Paradrop.sqf ['%1',%2]",
					getPlayerUID player,
					[A3C_HC_ACTIVE_PRE_COND_MODE,A3C_HC_ACTIVE_PRE_COND_VAL]
				];
			};
		};

		{_funcsCurr pushBack _x} foreach (_statements splitString ";");
		_funcsFinal = "";

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
		_timeOut = if (_wpScript == "") then {[_timeOut,_timeOut,_timeOut]} else {[0,0,0]};
		_wp setWaypointStatements [_condsFinal,_funcsFinal];
		_wp setWaypointFormation A3C_HC_ACTIVE_FORM_PRE;
		_wp setWaypointTimeout _timeOut;
		_wp setWaypointCompletionRadius _completionRadius;
		_wp setWaypointSpeed A3C_HC_ACTIVE_WPSPEED;

		[_wp,_waypointBehaviour] remoteExec ["setWaypointBehaviour",2];
		_wp setWaypointCombatMode _waypointCombatMode;
		

		
		_group setvariable ["A3C_UNIT_POLYS",_var,true];

		if (_waypointType == "LOITER") then {
			_wp setWaypointLoiterType A3C_HC_EDIT_COMBOSUBVAL_1;
			_wp setWaypointLoiterRadius A3C_HC_EDIT_COMBOSUBVAL_2;
		};
		if (isPlayer leader _group) then {
			[_wp,_actionText] remoteExec ["setWaypointDescription",leader _group];
		};

	};

	if (_isCurrentWaypoint) then {
		private _wpPos = (waypointPosition _wp);
		private _aslHeight = if (surfaceIsWater _wpPos) then {0} else {(ATLtoASL _wpPos) select 2};
		{
			_v = objectParent _x;
			//-- #FLYINHEIGHTASL
			if (!isNull _v && {_x == driver _v && {_v isKindOf "AIR"}}) then {
				// _flyInHeight = _aslHeight + (_v getVariable ["A3C_FLYINHEIGHT",75]);
				_flyInHeight = (_v getVariable ["A3C_FLYINHEIGHT",75]);
				[_v,_flyInHeight] spawn {
					params ["_v","_flyInHeight"];
					sleep 2;
					// [_v,[_flyInHeight,_flyInHeight,_flyInHeight]] remoteExec ["flyInHeightASL",_v];
					[_v,_flyInHeight] remoteExec ["flyInHeight",_v];
				};
			};
				
		} foreach units _group;
	};

	[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];
	A3C_HC_ACTIVE_WPOS = [0,0,0];

	if (A3C_HC_EDIT_ACTION == "TRANSPORT UNLOAD") then {
		//-- extra TR Unload functionality: Request waypoints for cargo groups
		private _cargoGroups = ([A3C_HC_ACTIVEGROUP] call MCSS_fnc_getCargoGroups) select {private _gp = _x; (waypointPosition [_gp, currentWaypoint _gp]) distance2D [0,0,0] == 0};
		if !(_cargoGroups isEqualTo []) then { //-- here we check for existing cargo units that can have waypoints assigned.
			//-- Prompt user to select desired option
			_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
			_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
			_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

			ctrlSetFocus _listBox;
			
			lbClear _listBox;
			ctrlSetFocus _listBox;


			A3C_SelectionPromptPanel_MODE = "CARGO_WAYPOINTS";
			_text ctrlSetText "SET WAYPOINTS FOR CARGO GROUPS?";
			_parent ctrlShow true;
			_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
			_parent ctrlCommit 0;

			ctrlSetFocus _listBox;
			
			lbClear _listBox;
			{
				[_listBox, _x] call A3C_ui_shared_fnc_addLbEntry;
			} foreach ["YES", "NO"];

			[_parent, _listBox, 2] call A3C_ui_selectionPromptPanel_fnc_resizeBox;

		};
	};

};






A3C_HC_CASMODES = [];


A3C_UI_MAP_WPMENU_ADDACTIONS = {
	private _a3c_dsp = IDD_MAP_OVERLAY;
	private _actionTypeCombo = (findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Action);

	private _leader = leader A3C_HC_ACTIVEGROUP;
	private _leaderVic = vehicle _leader;
	private _isCargoOrInf = !(driver _leaderVic in (units A3C_HC_ACTIVEGROUP)) OR {isnull objectParent _leader};
	private _canCargo = !(_isCargoOrInf) && {count (fullcrew [_leaderVic,"cargo",true]) > 0};

	private _actionTypes = [];
	private _waypointTypes = if (_leaderVic isKindOf "AIR") then {["MOVE","SEARCH / DESTROY","LOITER","CYCLE"]} else {["MOVE","SEARCH / DESTROY","CYCLE"]}; 
	private _landingTypes = [];

	A3C_HC_CASMODES = [];
	_slingMode = "";

	
	
	
	if ( !(_isCargoOrInf) && {_leaderVic isKindOf "AIR"}) then {
		
		if !(A3C_HC_EDIT_ACTION in ["SLING LOAD","SLING DROP"]) then {
			_landingTypes = if (_leaderVic isKindOf "HELICOPTER") then {
				["FIRE SUPPORT","LAND","COMBAT LAND"] //,
			} else {
				["LAND"]
			};
			_bike = "C_Quadbike_01_F" createVehicle [0,0,1000 + (random 1000)];
			_canSling = _leaderVic canSlingLoad _bike;
			_canVIV = (_leaderVic canVehicleCargo _bike) select 1;
			deleteVehicle _bike;
			
			
			if (_leaderVic isKindOf "HELICOPTER") then {
				if ([_leaderVic] call A3C_main_fnc_isAttackHelicopter ) then { //-- unit with toolKit is required
					_landingTypes pushBackUnique "HELI OVERWATCH";
				};
				
				if (_canSling) then {
					_slingMode = [A3C_HC_ACTIVEGROUP] call A3C_ai_highCommand_fnc_getSlingMode;
					
				};
			};


			if (_leaderVic isKindOf "PLANE") then {
				_pType = typeOf _leaderVic;
				private _isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
				if !(_isRotor) then {
					A3C_HC_CASMODES = [_pType] call A3C_main_fnc_getCASmodes;
					if (count A3C_HC_CASMODES > 0) then {
						_landingTypes pushbackUnique "CAS-STRIKE";
					};
				};
			};
			if (_canCargo) then {
				_landingTypes pushBackUnique "TRANSPORT UNLOAD";
				_landingTypes pushBackUnique "PARADROP";
				if  ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10) then {
					if (A3C_IsRappel) then {
						_landingTypes pushBackUnique "RAPPELL";
					};
				};
			} else {
				if (_canVIV) then {
					_landingTypes pushBackUnique "PARADROP";
				};
			};
			
		} else {
			_waypointTypes = ["MOVE"];
			_slingMode = if (A3C_HC_EDIT_ACTION == "SLING LOAD") then {"HOOK"} else {"UNHOOK"}; 
			
		};
		
		switch (_slingMode) do {
			case ("HOOK") : {_landingTypes pushBack "SLING LOAD";};
			case ("UNHOOK") : {_landingTypes pushBack "SLING DROP";};
		};
		_actionTypes = [];

	} else {
		_actionTypes = ["FIRE SUPPORT","AMBUSH"];

		if (_isCargoOrInf) then {
			if ( (count ([units A3C_HC_ACTIVEGROUP,"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons) > 0) && {  {(markerType ((_x select 0) select 1)) == 'mil_dot'} count (A3C_HC_ACTIVEGROUP getVariable ["A3C_UNIT_POLYS",[]]) < 1    } ) then {
				_actionTypes = _actionTypes + ["ASSEMBLE WEAPON"];

			};
			if (count ([units A3C_HC_ACTIVEGROUP] call A3C_ai_shared_fnc_getUnitsWithExplosives) > 0) then {
				_actionTypes = _actionTypes + ["DEMOLITION"];
			};
			{
				_u = _x;
				_uavType = (getText (configfile >> "CfgVehicles" >> backpack _u >> "assembleInfo" >> "assembleTo"));
				private _exit = false;
				if (_uavType != "") then {
					_isUAV = (getText(configfile >> "CfgVehicles" >> _uavType >> "uavCameraDriverDir")) != "";
					if (_isUAV) then {
						_exit = true;
						_actionTypes = _actionTypes + ["ASSEMBLE UAV"];
					};
				};
				if (_exit) exitWith {};
			} foreach units A3C_HC_ACTIVEGROUP;
		} else {
			if ([_leaderVic] call MCSS_fnc_countVehicleCargoSeats > 0) then { //-- here we check for cargo abilities in general as the units may not have boarded
			// if ([A3C_HC_ACTIVEGROUP] call MCSS_fnc_getCargoGroups;) then {
				_landingTypes pushBackUnique "TRANSPORT UNLOAD";
			};
		};

		if ({[_x] call A3C_main_fnc_canRepair} count (units A3C_HC_ACTIVEGROUP) > 0) then { //-- unit with toolKit is required
			_actionTypes pushBackUnique "REPAIR";
		};
	};

	_sortedArray = [];
	_array = _landingTypes + _waypointTypes + _actionTypes;

	// hint str _array;

	{
		if (_x in _array) then {
			_sortedArray pushBack _x;
		};
	} foreach
	[
		"MOVE",
		"SEARCH / DESTROY",
		"FIRE SUPPORT",
		"AMBUSH",
		"CAS-STRIKE",
		"LOITER",
		"HELI OVERWATCH",
		"LAND",
		"TRANSPORT UNLOAD",
		"COMBAT LAND",
		"PARADROP",
		"RAPPELL",
		"SLING DROP",
		"SLING LOAD",
		"REPAIR",
		"ASSEMBLE WEAPON",
		"ASSEMBLE UAV",
		"DEMOLITION",
		"CYCLE"		
	];
	_array = _sortedArray;

	lbClear _actionTypeCombo;

	{
		[_actionTypeCombo, _x] call A3C_ui_shared_fnc_addLbEntry;		
	} foreach _array;


	{
		_lbText = (_actionTypeCombo lbText _forEachIndex);
		if (_lbText == "FIRE SUPPORT") then {
			_lbText = "SUPPRESSION";
		};
		if (_lbText == "COMBAT LAND") then {
			_lbText = "COMBATLANDING";
		};
		if (_lbText == "LAND") then {
			_lbText = "FULL LANDING";
		};
		if ((toLower _lbText) == (toLower A3C_HC_EDIT_ACTION)) then {
			[_actionTypeCombo, _foreachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
			
		};
	} foreach _array;
	//
};




A3C_daytimeZeroComp = {
	//-- unorthodox method: since formatted strings do not distinguish strings and number-strings, we add a '0' as a string when needReload
	//-- purpose: prevent ie 00:05 to be shown as 0:5
	params ["_inputVal"];
	if (_inputVal < 10) then {
		if (_inputVal == 0) then {
			_inputVal = "00";
		} else {
			_inputVal = format ["0%1",_inputVal];
		};
	};
	_inputVal
};



A3C_LB_HC = {
	params ["_mode","_lb"];
	
	if (isnil "_mode") exitWith {};

	private _a3c_dsp = IDD_MAP_OVERLAY;



	private _header3Text = "COMPLETION";
	
	private _preCondModeCtrl = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Type);
	private _preCondValCtrl = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode);

	private _fullW = (ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_GROUPNAME_BG)) select 2;


	if !(A3C_CurSel) then {
		//~~ Author Note: Shorten this stuff once it works!
		switch (_mode) do {

			case (IDC_MAP_HCWP_Condition_Pre_Type) : { //--pre-Condition Type Combo
				if (A3C_HC_EDIT_ACTION == "CAS-STRIKE") then {
					_header3Text = "CAS TYPE";
					_lbText = _preCondModeCtrl lbText _lb;
					A3C_HC_CASMODE_VAL = switch (_lbText) do {
						case ('GUN RUN') : {0};
						case ('MISSILES') : {1};
						case ('GUNS + MISSILES') : {2};
						case ('BOMBING RUN') : {3};
					};
				} else {

					lbClear _preCondValCtrl;
					_refY = 20; //-- default/arrival >> hidden
					
					private _refPos = ctrlPosition _preCondModeCtrl;

					A3C_HC_ACTIVE_PRE_COND_MODE = switch (_lb) do {
						case (0) : {
							_preCondValCtrl ctrlShow false;
							A3C_HC_ACTIVE_PRE_COND_VAL = 0;
							"ARRIVAL"
						};
						case (1) : {

							_preCondValCtrl ctrlShow true;
							{
								[_preCondValCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
							} foreach ["A","B","C","D"];
							
							[_preCondValCtrl, 0] call A3C_ui_shared_fnc_lbSetCurSel;
							
							A3C_HC_ACTIVE_PRE_COND_VAL = "A";

							"GOCODE"
						};
						case (2) : {
							_preCondValCtrl ctrlShow true;
							{
								[_preCondValCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
							} foreach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
							
							[_preCondValCtrl, 2] call A3C_ui_shared_fnc_lbSetCurSel;
							
							A3C_HC_ACTIVE_PRE_COND_VAL = 90;
							"TIMEOUT"
						};
						case (3) : {
							date params ["_year","_month","_day","_hour","_min"];
							_min = if (((round (_min * 0.1) ) * 10) < _min) then {((floor (_min * 0.1) ) * 10)} else {((ceil (_min * 0.1) ) * 10)};
							_preCondValCtrl ctrlShow true;
							for "_i" from 1 to 7 do {
								if (_min >= 60) then {
									_hour = _hour + 1;
									if (_hour >= 24) then {_hour = 00};
									_min = 0;
								};
								_timeString = format 
								[
									"%1:%2",
									[_hour] call A3C_daytimeZeroComp,
									[_min] call A3C_daytimeZeroComp
								]; 
									//-- timeString is UI only, does NOT need to include CURRENT year, month and day
								if (_i == 1) then {
									A3C_HC_ACTIVE_PRE_COND_VAL = format ["%1:%2:%3:%4:%5",_year,_month,_day,_hour,_min]; //-- condVal DOES need to include CURRENT year, month and day
								};
								[_preCondValCtrl, _timeString] call A3C_ui_shared_fnc_addLbEntry;
								_min = _min + 5;
							};
							
							[_preCondValCtrl, 0] call A3C_ui_shared_fnc_lbSetCurSel;
							
							"DAYTIME"
						};
					};
					
				};
				
			};
			case (IDC_MAP_HCWP_Condition_Pre_Mode) : { //--pre-Condition Value Combo
				// systemchat 'yeah yeah!';
				A3C_HC_ACTIVE_PRE_COND_VAL = switch (A3C_HC_ACTIVE_PRE_COND_MODE) do {
					case ("ARRIVAL") : {
						""
					};
					case ("GOCODE") : {
						switch (_lB) do {
							case (0) : {"A"};
							case (1) : {"B"};
							case (2) : {"C"};
							case (3) : {"D"};
						};
					};
					case ("TIMEOUT") : {
						switch (_lB) do {
							case (0) : {30};
							case (1) : {60};
							case (2) : {90};
							case (3) : {120};
							case (4) : {180};
							case (5) : {240};
						};
					};
					case ("DAYTIME") : {
						date params ["_year","_month","_day"];
						//-- actual condition string (behind the scenes), does need to include Currentyear, Currentmonth and Currentday
						_timeSelected = (format ["%1:%2:%3:",_year,_month,_day]) + (_preCondValCtrl lbText _lb);
						_timeSelected
					};
				};

			};

			case (IDC_MAP_HCWP_Condition_Post_Type) : {
				lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
				_lbText = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type) lbText _lb;
				A3C_HC_ACTIVE_POST_COND_MODE = switch (tolower _lbText) do {
					case ("none") : {
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 'NONE'] call A3C_ui_shared_fnc_addLbEntry;
						
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						A3C_HC_ACTIVE_POST_COND_VAL = "NONE";
						
						"NONE"
					};
					case ("timeout") : {
						{
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
						
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 2] call A3C_ui_shared_fnc_lbSetCurSel;
						A3C_HC_ACTIVE_POST_COND_VAL = 90;
						

						"TIMEOUT"
					};
					case ("gocode") : {
						{
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["A","B","C","D"];
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						
						A3C_HC_ACTIVE_POST_COND_VAL = "A";
						"GOCODE"
					}; //-- different settings for WP_Action
					case ("daytime") : {
						date params ["_year","_month","_day","_hour","_min"];
						_min = if (((round (_min * 0.1) ) * 10) < _min) then {((floor (_min * 0.1) ) * 10)} else {((ceil (_min * 0.1) ) * 10)};
						(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode) ctrlShow true;
						for "_i" from 1 to 7 do { //-- UI only: no need to include year, month and day
							if (_min >= 60) then {
								_hour = _hour + 1;
								if (_hour >= 24) then {
									_hour = 00;

								};
								_min = 0;
							};

							//-- timeString is UI only, does NOT need to include CURRENT year, month and day
							_timeString = format 
							[
								"%1:%2",
								[_hour] call A3C_daytimeZeroComp,
								[_min] call A3C_daytimeZeroComp
							];
							
							if (_i == 1) then {
								A3C_HC_ACTIVE_POST_COND_VAL = format ["%1:%2:%3:%4:%5",_year,_month,_day,_hour,_min]; //-- condVal DOES need to include CURRENT year, month and day
							};
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _timeString] call A3C_ui_shared_fnc_addLbEntry;
							_min = _min + 5;
						};
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						
						"DAYTIME"
					};
				};
			};
			case (IDC_MAP_HCWP_Condition_Post_Mode) : {
				A3C_HC_ACTIVE_POST_COND_VAL = switch (A3C_HC_ACTIVE_POST_COND_MODE) do {
					case ("NONE") : {"NONE"};
					case ("TIMEOUT") : {
						switch (_lB) do {
							case (0) : {30};
							case (1) : {60};
							case (2) : {90};
							case (3) : {120};
							case (4) : {180};
							case (5) : {240};
						};
					};
					case ("GOCODE") : {
						switch (_lB) do {
							case (0) : {"A"};
							case (1) : {"B"};
							case (2) : {"C"};
							case (3) : {"D"};
						};
					};

					case ("DAYTIME") : {
						date params ["_year","_month","_day"];
						//-- actual condition string (behind the scenes), does need to include Currentyear, Currentmonth and Currentday
						_timeSelected = (format ["%1:%2:%3:",_year,_month,_day]) + ((finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode) lbText _lb);
						_timeSelected
					};
				};
				//systemChat str A3C_CurSel;
			};

			case (IDC_MAP_HCWP_Formation_Combo) : {
				
				A3C_HC_ACTIVE_FORM_PRE = switch (_lb) do {
					case (0) : {"COLUMN"};
					case (1) : {"STAG COLUMN"};
					case (2) : {"WEDGE"};
					case (3) : {"ECH LEFT"};
					case (4) : {"ECH RIGHT"};
					case (5) : {"VEE"};
					case (6) : {"LINE"};
					case (7) : {"FILE"};
					case (8) : {"DIAMOND"};
					default {"NO CHANGE"};
				};
			};
			case (IDC_MAP_HCWP_Action_Formation_Combo) : {
				A3C_HC_ACTIVE_FORM_POST = switch (_lb) do {
					case (0) : {"COLUMN"};
					case (1) : {"STAG COLUMN"};
					case (2) : {"WEDGE"};
					case (3) : {"ECH LEFT"};
					case (4) : {"ECH RIGHT"};
					case (5) : {"VEE"};
					case (6) : {"LINE"};
					case (7) : {"FILE"};
					case (8) : {"DIAMOND"};
				};
			};
		
			
			// --  TYPE-ACTION COMBO
			
			case (IDC_MAP_HCWP_Type_Action) : {

				private ["_textCtrl","_ctrlText","_ctrl","_lbSelect"];

				_ctrlText = "";
				private _initActionType = A3C_HC_EDIT_ACTION;

				_lb3Val = -1;
				_lb4Val = -1;

				

				private _selectedAction = toUpper ((findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Action) lbText _lb);
				if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
					if (_selectedAction != "ASSEMBLE WEAPON") then { //== changing from assemble to other
						
						{lbClear (findDisplay _a3c_dsp displayCtrl _x)} foreach [IDC_MAP_HCWP_Condition_Post_Type,IDC_MAP_HCWP_Condition_Post_Mode];
						{
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["TIMEOUT","GO-CODE","DAYTIME"]; ///bbbbb
						{
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						A3C_HC_ACTIVE_POST_COND_MODE = "TIMEOUT";
						A3C_HC_ACTIVE_POST_COND_VAL = "90";
						
						_lb4Val = 0;
					};
				};
				if (A3C_HC_EDIT_ACTION in ["CAS-STRIKE"]) then {
					if !(_selectedAction in ["CAS-STRIKE"]) then { //== changing from CAS to other
						
						{lbClear (findDisplay _a3c_dsp displayCtrl _x)} foreach [IDC_MAP_HCWP_Condition_Pre_Type,IDC_MAP_HCWP_Condition_Pre_Mode];
						{
							[_preCondModeCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["ARRIVAL","GOCODE","TIMEOUT","DAYTIME"];
						[_preCondModeCtrl, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						A3C_HC_ACTIVE_POST_COND_MODE = "ARRIVAL";
						A3C_HC_ACTIVE_POST_COND_VAL = "NONE";
						

						//-- switch action and precond (cond first)
						_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Formation_Combo); //-- reference: formation combo
						private _refH = _refPos select 3;
						private _refY = (_refPos select 1) + _refH;
						//-- precond/castype box
						_box =  (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Completion_Parent);
						_ctrlPos = ctrlPosition _box;
						_ctrlPos set [1,_refY];
						_box ctrlSetPosition _ctrlPos;
						_box ctrlCommit 0;
						
						//-- type box
						_refY = _refY + (_ctrlPos select 3);
						_box =  (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Parent);
						_ctrlPos = ctrlPosition _box;
						_ctrlPos set [1,_refY];
						_box ctrlSetPosition _ctrlPos;
						_box ctrlCommit 0;
					};
				};

				//systemchat str _selectedAction;
				private _requiresPostData = false;
				private _requiresSubData = false;
				switch (_selectedAction) do {
					case ("SEARCH / DESTROY") : {
						A3C_HC_EDIT_ACTION = "SEARCH / DESTROY";
					};
					case ("LOITER") : {
						A3C_HC_EDIT_ACTION = "LOITER";
						_requiresSubData = true;
						
						//-- Needs condition - set go-code as default unless other is selected 
						if (A3C_HC_ACTIVE_POST_COND_MODE in ["NONE","ARRIVAL"]) then {
							// systemchat str _a3c_dsp;
							// 
							lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode);
							{
								[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
							} foreach ["A","B","C","D"];
							
							
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel;
							//-- Note = since we use true param, default post-cond values are already set here!
							(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode) ctrlShow true;
						};
					};
					case ("CYCLE") : {
						A3C_HC_EDIT_ACTION = "CYCLE";
					};
					case ("MOVE") : {
						A3C_HC_EDIT_ACTION = "MOVE";
						_ctrlText = "MOVE";
					};
					case ("REPAIR") : {
						A3C_HC_EDIT_ACTION = "REPAIR";
						_ctrlText = "REPAIR";
					};
					case ("FIRE SUPPORT") : {

						A3C_HC_EDIT_ACTION = "SUPPRESSION";
						_ctrlText = "SUPPRESSION";
						if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {
							
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 3, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code D
							//-- Note = since we use true param, default post-cond values are already set here!
						};
						_requiresPostData = true;
					};
					case ("AMBUSH") : {
						A3C_HC_EDIT_ACTION = "AMBUSH";
						_ctrlText = "AMBUSH";
						if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
							//-- Note = since we use true param, default post-cond values are already set here!
						};
						_requiresPostData = true;
					};

					case ("HELI OVERWATCH") : {
						A3C_HC_EDIT_ACTION = "HELI OVERWATCH";
						_ctrlText = "HELI OVERWATCH";
						if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {
							
							lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
							{
								[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
							} foreach ["A","B","C","D"];
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
							//-- Note = since we use true param, default post-cond values are already set here!
						};
						_requiresPostData = true;
						_requiresSubData = true;
					};


					
					case ("LAND") : {
						A3C_HC_EDIT_ACTION = "FULL LANDING";
						_ctrlText = "FULL LANDING";
					};
					case ("COMBAT LAND") : {
						A3C_HC_EDIT_ACTION = "COMBATLANDING";
						_ctrlText = "COMBAT LANDING";
						//_lbSelect = 0;
						if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {
							
							lbClear (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
							{
								[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
							} foreach ["A","B","C","D"];
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
							//-- Note = since we use true param, default post-cond values are already set here!
						};
						_requiresPostData = true;
					};
					case ("ASSEMBLE WEAPON") : {
						A3C_HC_EDIT_ACTION = "ASSEMBLE WEAPON";
						_ctrlText = "ASSEMBLE WEAPON";
						_lbSelect = 0;
						
						{lbClear (findDisplay _a3c_dsp displayCtrl _x)} foreach [IDC_MAP_HCWP_Condition_Post_Type,IDC_MAP_HCWP_Condition_Post_Mode];
						{
							[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach ["None","Timer","Go-Code","DayTime"]; ///bbbbb
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, "None"] call A3C_ui_shared_fnc_addLbEntry;
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;
						
						
						A3C_HC_ACTIVE_POST_COND_MODE = "NONE";
						A3C_HC_ACTIVE_POST_COND_VAL = "NONE";
						_requiresPostData = true;
					};
					case ("RAPPELL") : {
						A3C_HC_EDIT_ACTION = "RAPPELL";
						_ctrlText = "RAPPELL";
					};
					case ("TRANSPORT UNLOAD") : {
						A3C_HC_EDIT_ACTION = "TRANSPORT UNLOAD";
						_ctrlText = "TRANSPORT UNLOAD";
					};
					case ("PARADROP") : {
						A3C_HC_EDIT_ACTION = "PARADROP";
						_ctrlText = "PARADROP";
					};
					case ("SLING LOAD") : {
						A3C_HC_EDIT_ACTION = "SLING LOAD";
						_ctrlText = "SLING LOAD";
					};
					case ("SLING DROP") : {
						A3C_HC_EDIT_ACTION = "SLING LOAD";
						_ctrlText = "SLING DROP";
					};
					case ("ASSEMBLE UAV") : {
						A3C_HC_EDIT_ACTION = "ASSEMBLE UAV";
						_ctrlText = "ASSEMBLE UAV";
					};


					case ("DEMOLITION") : {
						A3C_HC_EDIT_ACTION = "DEMOLITION";
						_ctrlText = "DEMOLITION";
						(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent) ctrlShow false;
						(findDisplay 12 displayCtrl 51) ctrlEnable true;
						_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
						_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
						_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

						ctrlSetFocus _listBox;
						
						lbClear _listBox;
						ctrlSetFocus _listBox;

						private _allRemfireMagTypes = [];
						{
							_allRemfireMagTypes append ((magazines _x) select {
								getText (configFile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge", "mine"]
							});
						} forEach (units A3C_HC_ACTIVEGROUP);
						A3C_REMFIRE_MAGTYPES = _allRemfireMagTypes arrayIntersect _allRemfireMagTypes;

						A3C_SelectionPromptPanel_MODE = "PLACE_CHARGE_HC_MAP";
						_text ctrlSetText "Select Charge";
						_parent ctrlShow true;
						_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
						_parent ctrlCommit 0;

						if (count A3C_REMFIRE_MAGTYPES > 4) then {
							_parentPos = ctrlPosition _parent;
							_parentPos set[3,(_parentPos select 3) + (  ((count A3C_REMFIRE_MAGTYPES) - 4)   * (0.0440051 * safezoneH) )];
							_parent ctrlSetPosition _parentPos;
							_parent ctrlCommit 0;
						};



						ctrlSetFocus _listBox;
						
						lbClear _listBox;
						{
							private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
							[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
						} foreach A3C_REMFIRE_MAGTYPES;

						[_parent,_listBox, count A3C_REMFIRE_MAGTYPES] call A3C_ui_selectionPromptPanel_fnc_resizeBox;
					};
					case ("CAS-STRIKE") : {
						A3C_HC_EDIT_ACTION = "CAS-STRIKE";
						_ctrlText = "CAS-STRIKE";
						(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN) ctrlShow false;
						_header3Text = "CAS TYPE";
						lbClear _preCondModeCtrl;


						{
							_casMode = switch (true) do {
								case (_x isEqualTo ["machinegun"]) : {'GUN RUN'};
								case (_x isEqualTo ["missilelauncher"]) : {'MISSILES'};
								case (_x isEqualTo ["machinegun","missilelauncher"]) : {'GUNS + MISSILES'};
								case (_x isEqualTo ["bomblauncher"]) : {'BOMBING RUN'};
							};
							[_preCondModeCtrl, _casMode, true] call A3C_ui_shared_fnc_addLbEntry;
						} foreach A3C_HC_CASMODES;

						[_preCondModeCtrl, _casTypeCurrent] call A3C_ui_shared_fnc_lbSetCurSel;
						_preCondModeCtrl ctrlShow true;
						if (A3C_HC_ACTIVE_PRE_COND_MODE != "ARRIVAL") then { //-- reset any wp-conditions
							A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
							A3C_HC_ACTIVE_PRE_COND_VAL = 0;
							
							private _condValCtrl = finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;
							
							lbClear _condValCtrl;
							_condValCtrl ctrlShow false;
						};

						//-- switch action and precond (TYPE first)
						_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Formation_Combo); //-- reference: formation combo
						private _refH = _refPos select 3;
						private _refY = (_refPos select 1) + _refH;
						//-- type box
						_box =  (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Parent);
						_ctrlPos = ctrlPosition _box;
						_ctrlPos set [1,_refY];
						_box ctrlSetPosition _ctrlPos;
						_box ctrlCommit 0;
						//-- precond/castype box
						_refY = _refY + (_ctrlPos select 3);
						_box =  (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Completion_Parent);
						_ctrlPos = ctrlPosition _box;
						_ctrlPos set [1,_refY];
						_box ctrlSetPosition _ctrlPos;
						_box ctrlCommit 0;
					};
				};

				_IDC_MAP_HCWP_Action_Parent_ADD = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_ADD);
				if (_requiresSubData) then {
					_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Type_Parent);
					private _refH = _refPos select 3;
					private _refY = (_refPos select 1) + _refH;
					_box =  (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_ADD);
					_ctrlPos = ctrlPosition _box;
					_ctrlPos set [1,_refY];
					_box ctrlSetPosition _ctrlPos;
					_box ctrlCommit 0;

					if (_initActionType != A3C_HC_EDIT_ACTION) then {
						_subTextCtrl1 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Formation_TXT);
						_subTextCtrl2 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Completion_TXT);
						_subCombo1 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo);
						_subCombo2 = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo);
						_lbSel1 = 0;
						_lbSel2 = 0;
						_subText1 = "";
						_subText2 = "";
						_subArray1 = [];
						_subArray2 = [];
						switch (A3C_HC_EDIT_ACTION) do {
							case ("LOITER") : {
								_subText1 = "LOITER DIRECTION";
								_subText2 = "LOITER RADIUS";
								_subArray1 = ["CLOCKWISE","CNTR CLOCKWISE"];
								_subArray2 = ["100","500","1000","2000"];
								_lbSel1 = 1;
								_lbSel2 = 2;
								A3C_HC_EDIT_COMBOSUBVAL_1 = "CIRCLE_L";
								A3C_HC_EDIT_COMBOSUBVAL_2 = 1000;
							};
							case ("HELI OVERWATCH") : {
								_subText1 = "HOVER HEIGHT";
								_subText2 = "ORIENTATION";
								_subArray1 = ["100","200","500","1000"];
								_subArray2 = ["NORTH","NORTH-EAST","EAST","SOUTH-EAST","SOUTH","SOUTH-WEST","WEST","NORTH-WEST"];
								_lbSel1 = 1;
								_lbSel2 = 0;
								A3C_HC_EDIT_COMBOSUBVAL_1 = 200;
								A3C_HC_EDIT_COMBOSUBVAL_2 = 0;
							};
						};
						_subTextCtrl1 ctrlSetText _subText1;
						_subTextCtrl2 ctrlSetText _subText2;

						
						lbClear _subCombo1;
						{
							[_subCombo1, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach _subArray1;

						[_subCombo1, _lbSel1] call A3C_ui_shared_fnc_lbSetCurSel;
						

						lbClear _subCombo2;
						{
							[_subCombo2, _x] call A3C_ui_shared_fnc_addLbEntry;
						} foreach _subArray2;
						[_subCombo2, _lbSel2] call A3C_ui_shared_fnc_lbSetCurSel;
						
					};
					

					_IDC_MAP_HCWP_Action_Parent_ADD ctrlShow true;
				} else {
					_IDC_MAP_HCWP_Action_Parent_ADD ctrlShow false;
				};

				_IDC_MAP_HCWP_Action_Parent_MAIN = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN);
				if (_requiresPostData) then {
					_refCtrl = if (_requiresSubData) then {IDC_MAP_HCWP_Action_Parent_ADD} else {IDC_MAP_HCWP_Type_Parent};
						
					_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl _refCtrl);
					private _refH = _refPos select 3;
					private _refY = (_refPos select 1) + _refH;

					
					_ActionctrlPos = ctrlPosition _IDC_MAP_HCWP_Action_Parent_MAIN;	
					_ActionctrlPos set [1,_refY];
					
					_IDC_MAP_HCWP_Action_Parent_MAIN ctrlSetPosition _ActionctrlPos;
					_IDC_MAP_HCWP_Action_Parent_MAIN ctrlCommit 0;	
					_IDC_MAP_HCWP_Action_Parent_MAIN ctrlShow true;					
					//if !(ctrlShown (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN)) then { //-- postStuff is NOT shown
					//};		
				} else {
					_IDC_MAP_HCWP_Action_Parent_MAIN ctrlShow false;
				};
				
				_refCtrl = switch (true) do {
					case (_requiresPostData) : {IDC_MAP_HCWP_Action_Parent_MAIN};
					case (_requiresSubData) : {IDC_MAP_HCWP_Action_Parent_ADD};
					default {if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {IDC_MAP_HCWP_Type_Parent} else {IDC_MAP_HCWP_Completion_Parent}};
				};
				_refPos = ctrlPosition (finddisplay _a3c_dsp displayCtrl _refCtrl);
				private _refH = _refPos select 3;
				private _refY = (_refPos select 1) + _refH;

				{
					private _ctrl = _x;
					private _ctrlPos = ctrlPosition _ctrl;

					_ctrlPos set [1, _refY];

					_ctrl ctrlSetPosition _ctrlPos;
					_ctrl ctrlCommit 0;
				} forEach (["map_hcwp_macro_confirmAndCancel"] call FUNC(ctrlGroup));


				
				if (_lb4Val != -1) then {
					[finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _lb4Val] call A3C_ui_shared_fnc_lbSetCurSel;
				};
				
			};
			case (IDC_MAP_HCWP_Speed_Combo) : {
				_lbText = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Speed_Combo) lbText _lb;
				A3C_HC_ACTIVE_WPSPEED = _lbText;
			};
			case (IDC_MAP_HCWP_Action_Add_Formation_Combo) : {
				_lbText = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo) lbText _lb;
				switch (A3C_HC_EDIT_ACTION) do {
					case ("LOITER") : {
						A3C_HC_EDIT_COMBOSUBVAL_1 = switch (_lb) do {
							case (0) : {"CIRCLE"};
							case (1) : {"CIRCLE_L"};
						};
					};
					case ("HELI OVERWATCH") : {
						A3C_HC_EDIT_COMBOSUBVAL_1 = parseNumber _lbText;
					};
				};
			};
			case (IDC_MAP_HCWP_Action_Add_Completion_Combo) : {
				_lbText = (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo) lbText _lb;
				switch (A3C_HC_EDIT_ACTION) do {
					case ("LOITER") : {
						A3C_HC_EDIT_COMBOSUBVAL_2 = parseNumber _lbText;
					};
					case ("HELI OVERWATCH") : {
						A3C_HC_EDIT_COMBOSUBVAL_2 = switch (_lb) do {
							case (0) : {0};
							case (1) : {45};
							case (2) : {90};
							case (3) : {135};
							case (4) : {180};
							case (5) : {225};
							case (6) : {270};
							case (7) : {315};
						};
					};
				};
			};
		};
		//-- security: make sure menu does not bleed out of screen after resizing
		[_a3c_dsp,_ctrlPosWPM] spawn {
			params ["_a3c_dsp","_ctrlPosWPM"];
			sleep 0.1;
			_ctrlPosWPM = ctrlPosition (finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent);
			_ctrlPosWPM = [_a3c_dsp,IDC_MAP_HCWP_Parent,_ctrlPosWPM] call A3C_UI_MAP_fnc_findCtrlSafePos;
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent) ctrlSetPosition _ctrlPosWPM;
			(findDisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Parent) ctrlCommit 0;
		};
		
	};
	_preCondModeCtrlPos = ctrlPosition _preCondModeCtrl;
	if (A3C_HC_EDIT_ACTION == "CAS-STRIKE" OR {A3C_HC_ACTIVE_PRE_COND_MODE == "ARRIVAL"}) then {
		
		_preCondModeCtrlPos set [2,_fullW];
		
	} else {
		_preCondModeCtrlPos set [2,_fullW / 2];
	};
	_preCondModeCtrl ctrlSetPosition _preCondModeCtrlPos;
	_preCondModeCtrl ctrlCommit 0;
	
	(finddisplay _a3c_dsp displayCtrl IDC_MAP_HCWP_Completion_Header_TXT) ctrlSetText _header3Text;
};