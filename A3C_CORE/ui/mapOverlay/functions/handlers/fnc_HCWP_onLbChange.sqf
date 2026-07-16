#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_onLbChange

disableSerialization;

params [
	"_mode",
	"_lb"
];

if (isNil "_mode") exitWith {};

private _a3c_dsp = IDD_MAP_OVERLAY;
private _display = findDisplay _a3c_dsp;

private _header3Text = "COMPLETION";

private _preCondModeCtrl =
	_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Type;

private _preCondValCtrl =
	_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;

private _groupNameBackground =
	_display displayCtrl IDC_MAP_HCWP_GROUPNAME_BG;

private _fullW = (ctrlPosition _groupNameBackground) select 2;

private [
	"_lbText",
	"_refY",
	"_timeString",
	"_timeSelected",
	"_ctrlText",
	"_lb4Val",
	"_refPos",
	"_box",
	"_ctrlPos",
	"_parent",
	"_text",
	"_listBox",
	"_parentPos",
	"_casMode",
	"_actionAddParent",
	"_actionMainParent",
	"_actionCtrlPos",
	"_subTextCtrl1",
	"_subTextCtrl2",
	"_subCombo1",
	"_subCombo2",
	"_lbSel1",
	"_lbSel2",
	"_subText1",
	"_subText2",
	"_subArray1",
	"_subArray2",
	"_refCtrl",
	"_preCondModeCtrlPos"
];


if (!A3C_CurSel) then {
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
						} forEach ["A","B","C","D"];

						[_preCondValCtrl, 0] call A3C_ui_shared_fnc_lbSetCurSel;

						A3C_HC_ACTIVE_PRE_COND_VAL = "A";

						"GOCODE"
					};
					case (2) : {
						_preCondValCtrl ctrlShow true;
						{
							[_preCondValCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
						} forEach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];

						[_preCondValCtrl, 2] call A3C_ui_shared_fnc_lbSetCurSel;

						A3C_HC_ACTIVE_PRE_COND_VAL = 90;
						"TIMEOUT"
					};
					case (3) : {
						date params ["_year", "_month", "_day", "_hour", "_min"];
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
								[_hour] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp,
								[_min] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp
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
					date params ["_year", "_month", "_day"];
					//-- actual condition string (behind the scenes), does need to include Currentyear, Currentmonth and Currentday
					_timeSelected = (format ["%1:%2:%3:",_year,_month,_day]) + (_preCondValCtrl lbText _lb);
					_timeSelected
				};
			};

		};

		case (IDC_MAP_HCWP_Condition_Post_Type) : {
			lbClear (_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
			_lbText = (_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type) lbText _lb;
			A3C_HC_ACTIVE_POST_COND_MODE = switch (toLower _lbText) do {
				case ("none") : {
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 'NONE'] call A3C_ui_shared_fnc_addLbEntry;

					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;
					A3C_HC_ACTIVE_POST_COND_VAL = "NONE";

					"NONE"
				};
				case ("timeout") : {
					{
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];

					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 2] call A3C_ui_shared_fnc_lbSetCurSel;
					A3C_HC_ACTIVE_POST_COND_VAL = 90;


					"TIMEOUT"
				};
				case ("gocode") : {
					{
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["A","B","C","D"];
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;

					A3C_HC_ACTIVE_POST_COND_VAL = "A";
					"GOCODE"
				}; //-- different settings for WP_Action
				case ("daytime") : {
					date params ["_year", "_month", "_day", "_hour", "_min"];
					_min = if (((round (_min * 0.1) ) * 10) < _min) then {((floor (_min * 0.1) ) * 10)} else {((ceil (_min * 0.1) ) * 10)};
					(_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode) ctrlShow true;
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
							[_hour] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp,
							[_min] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp
						];

						if (_i == 1) then {
							A3C_HC_ACTIVE_POST_COND_VAL = format ["%1:%2:%3:%4:%5",_year,_month,_day,_hour,_min]; //-- condVal DOES need to include CURRENT year, month and day
						};
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _timeString] call A3C_ui_shared_fnc_addLbEntry;
						_min = _min + 5;
					};
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;

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
					date params ["_year", "_month", "_day"];
					//-- actual condition string (behind the scenes), does need to include Currentyear, Currentmonth and Currentday
					_timeSelected = (format ["%1:%2:%3:",_year,_month,_day]) + ((_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode) lbText _lb);
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

			_lb4Val = -1;



			private _selectedAction = toUpper ((_display displayCtrl IDC_MAP_HCWP_Type_Action) lbText _lb);
			if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
				if (_selectedAction != "ASSEMBLE WEAPON") then { //== changing from assemble to other

					{lbClear (_display displayCtrl _x)} forEach [IDC_MAP_HCWP_Condition_Post_Type,IDC_MAP_HCWP_Condition_Post_Mode];
					{
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["TIMEOUT","GO-CODE","DAYTIME"]; ///bbbbb
					{
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["30SEK","60SEK","90SEK","2MIN","3MIN","4MIN"];
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 0] call A3C_ui_shared_fnc_lbSetCurSel;
					A3C_HC_ACTIVE_POST_COND_MODE = "TIMEOUT";
					A3C_HC_ACTIVE_POST_COND_VAL = "90";

					_lb4Val = 0;
				};
			};
			if (A3C_HC_EDIT_ACTION in ["CAS-STRIKE"]) then {
				if !(_selectedAction in ["CAS-STRIKE"]) then { //== changing from CAS to other

					{lbClear (_display displayCtrl _x)} forEach [IDC_MAP_HCWP_Condition_Pre_Type,IDC_MAP_HCWP_Condition_Pre_Mode];
					{
						[_preCondModeCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["ARRIVAL","GOCODE","TIMEOUT","DAYTIME"];
					[_preCondModeCtrl, 0] call A3C_ui_shared_fnc_lbSetCurSel;
					A3C_HC_ACTIVE_POST_COND_MODE = "ARRIVAL";
					A3C_HC_ACTIVE_POST_COND_VAL = "NONE";


					//-- switch action and precond (cond first)
					_refPos = ctrlPosition (_display displayCtrl IDC_MAP_HCWP_Formation_Combo); //-- reference: formation combo
					private _refH = _refPos select 3;
					private _refY = (_refPos select 1) + _refH;
					//-- precond/castype box
					_box =  (_display displayCtrl IDC_MAP_HCWP_Completion_Parent);
					_ctrlPos = ctrlPosition _box;
					_ctrlPos set [1,_refY];
					_box ctrlSetPosition _ctrlPos;
					_box ctrlCommit 0;

					//-- type box
					_refY = _refY + (_ctrlPos select 3);
					_box =  (_display displayCtrl IDC_MAP_HCWP_Type_Parent);
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
						lbClear (_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode);
						{
							[_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} forEach ["A","B","C","D"];


						[_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
						[_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel;
						//-- Note = since we use true param, default post-cond values are already set here!
						(_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode) ctrlShow true;
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

						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 3, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code D
						//-- Note = since we use true param, default post-cond values are already set here!
					};
					_requiresPostData = true;
				};
				case ("AMBUSH") : {
					A3C_HC_EDIT_ACTION = "AMBUSH";
					_ctrlText = "AMBUSH";
					if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
						//-- Note = since we use true param, default post-cond values are already set here!
					};
					_requiresPostData = true;
				};

				case ("HELI OVERWATCH") : {
					A3C_HC_EDIT_ACTION = "HELI OVERWATCH";
					_ctrlText = "HELI OVERWATCH";
					if (A3C_HC_ACTIVE_POST_COND_MODE == "NONE") then {

						lbClear (_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
						{
							[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} forEach ["A","B","C","D"];
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
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

						lbClear (_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode);
						{
							[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _x] call A3C_ui_shared_fnc_addLbEntry;
						} forEach ["A","B","C","D"];
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 1, true] call A3C_ui_shared_fnc_lbSetCurSel;
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0, true] call A3C_ui_shared_fnc_lbSetCurSel; //-->> Go-Code A
						//-- Note = since we use true param, default post-cond values are already set here!
					};
					_requiresPostData = true;
				};
				case ("ASSEMBLE WEAPON") : {
					A3C_HC_EDIT_ACTION = "ASSEMBLE WEAPON";
					_ctrlText = "ASSEMBLE WEAPON";
					_lbSelect = 0;

					{lbClear (_display displayCtrl _x)} forEach [IDC_MAP_HCWP_Condition_Post_Type,IDC_MAP_HCWP_Condition_Post_Mode];
					{
						[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["None","Timer","Go-Code","DayTime"]; ///bbbbb
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, "None"] call A3C_ui_shared_fnc_addLbEntry;
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type, 0] call A3C_ui_shared_fnc_lbSetCurSel;
					[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, 0] call A3C_ui_shared_fnc_lbSetCurSel;


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
					(_display displayCtrl IDC_MAP_HCWP_Parent) ctrlShow false;
					(findDisplay 12 displayCtrl 51) ctrlEnable true;
					_parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
					_text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
					_listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

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
					_parent ctrlSetPosition [0.383108 * safeZoneW + safeZoneX, 0.378986 * safeZoneH + safeZoneY];
					_parent ctrlCommit 0;

					if (count A3C_REMFIRE_MAGTYPES > 4) then {
						_parentPos = ctrlPosition _parent;
						_parentPos set [3, (_parentPos select 3) + (  ((count A3C_REMFIRE_MAGTYPES) - 4)   * (0.0440051 * safeZoneH) )];
						_parent ctrlSetPosition _parentPos;
						_parent ctrlCommit 0;
					};



					ctrlSetFocus _listBox;

					lbClear _listBox;
					{
						private _lbText = (getText (configFile >> "CfgMagazines" >> _x >> "displayName"));
						[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
					} forEach A3C_REMFIRE_MAGTYPES;

					[_parent,_listBox, count A3C_REMFIRE_MAGTYPES] call A3C_ui_selectionPromptPanel_fnc_resizeBox;
				};
				case ("CAS-STRIKE") : {
					A3C_HC_EDIT_ACTION = "CAS-STRIKE";
					_ctrlText = "CAS-STRIKE";
					(_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN) ctrlShow false;
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
					} forEach A3C_HC_CASMODES;

					// Intentionally inherited from HCWP_openMenu while the existing
					// CAS waypoint is initialized.
					[_preCondModeCtrl, _casTypeCurrent] call A3C_ui_shared_fnc_lbSetCurSel;
					_preCondModeCtrl ctrlShow true;
					if (A3C_HC_ACTIVE_PRE_COND_MODE != "ARRIVAL") then { //-- reset any wp-conditions
						A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
						A3C_HC_ACTIVE_PRE_COND_VAL = 0;

						private _condValCtrl = _display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;

						lbClear _condValCtrl;
						_condValCtrl ctrlShow false;
					};

					//-- switch action and precond (TYPE first)
					_refPos = ctrlPosition (_display displayCtrl IDC_MAP_HCWP_Formation_Combo); //-- reference: formation combo
					private _refH = _refPos select 3;
					private _refY = (_refPos select 1) + _refH;
					//-- type box
					_box =  (_display displayCtrl IDC_MAP_HCWP_Type_Parent);
					_ctrlPos = ctrlPosition _box;
					_ctrlPos set [1,_refY];
					_box ctrlSetPosition _ctrlPos;
					_box ctrlCommit 0;
					//-- precond/castype box
					_refY = _refY + (_ctrlPos select 3);
					_box =  (_display displayCtrl IDC_MAP_HCWP_Completion_Parent);
					_ctrlPos = ctrlPosition _box;
					_ctrlPos set [1,_refY];
					_box ctrlSetPosition _ctrlPos;
					_box ctrlCommit 0;
				};
			};

			_actionAddParent = (_display displayCtrl IDC_MAP_HCWP_Action_Parent_ADD);
			if (_requiresSubData) then {
				_refPos = ctrlPosition (_display displayCtrl IDC_MAP_HCWP_Type_Parent);
				private _refH = _refPos select 3;
				private _refY = (_refPos select 1) + _refH;
				_box =  (_display displayCtrl IDC_MAP_HCWP_Action_Parent_ADD);
				_ctrlPos = ctrlPosition _box;
				_ctrlPos set [1,_refY];
				_box ctrlSetPosition _ctrlPos;
				_box ctrlCommit 0;

				if (_initActionType != A3C_HC_EDIT_ACTION) then {
					_subTextCtrl1 = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Formation_TXT);
					_subTextCtrl2 = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Completion_TXT);
					_subCombo1 = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo);
					_subCombo2 = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo);
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
					} forEach _subArray1;

					[_subCombo1, _lbSel1] call A3C_ui_shared_fnc_lbSetCurSel;


					lbClear _subCombo2;
					{
						[_subCombo2, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach _subArray2;
					[_subCombo2, _lbSel2] call A3C_ui_shared_fnc_lbSetCurSel;

				};


				_actionAddParent ctrlShow true;
			} else {
				_actionAddParent ctrlShow false;
			};

			_actionMainParent = (_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN);
			if (_requiresPostData) then {
				_refCtrl = if (_requiresSubData) then {IDC_MAP_HCWP_Action_Parent_ADD} else {IDC_MAP_HCWP_Type_Parent};

				_refPos = ctrlPosition (_display displayCtrl _refCtrl);
				private _refH = _refPos select 3;
				private _refY = (_refPos select 1) + _refH;


				_actionCtrlPos = ctrlPosition _actionMainParent;
				_actionCtrlPos set [1,_refY];

				_actionMainParent ctrlSetPosition _actionCtrlPos;
				_actionMainParent ctrlCommit 0;
				_actionMainParent ctrlShow true;
				//if !(ctrlShown (_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN)) then { //-- postStuff is NOT shown
				//};
			} else {
				_actionMainParent ctrlShow false;
			};

			_refCtrl = switch (true) do {
				case (_requiresPostData) : {IDC_MAP_HCWP_Action_Parent_MAIN};
				case (_requiresSubData) : {IDC_MAP_HCWP_Action_Parent_ADD};
				default {if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {IDC_MAP_HCWP_Type_Parent} else {IDC_MAP_HCWP_Completion_Parent}};
			};
			_refPos = ctrlPosition (_display displayCtrl _refCtrl);
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
				[_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode, _lb4Val] call A3C_ui_shared_fnc_lbSetCurSel;
			};

		};
		case (IDC_MAP_HCWP_Speed_Combo) : {
			_lbText = (_display displayCtrl IDC_MAP_HCWP_Speed_Combo) lbText _lb;
			A3C_HC_ACTIVE_WPSPEED = _lbText;
		};
		case (IDC_MAP_HCWP_Action_Add_Formation_Combo) : {
			_lbText = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo) lbText _lb;
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
			_lbText = (_display displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo) lbText _lb;
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
	[_a3c_dsp] spawn {
		params ["_displayId"];
		sleep 0.1;

		private _display = findDisplay _displayId;
		private _menuPosition = ctrlPosition (
			_display displayCtrl IDC_MAP_HCWP_Parent
		);

		_menuPosition = [
			_displayId,
			IDC_MAP_HCWP_Parent,
			_menuPosition
		] call A3C_ui_mapOverlay_fnc_findCtrlSafePos;

		private _menuControl =
			_display displayCtrl IDC_MAP_HCWP_Parent;

		_menuControl ctrlSetPosition _menuPosition;
		_menuControl ctrlCommit 0;
	};

};
_preCondModeCtrlPos = ctrlPosition _preCondModeCtrl;
if (A3C_HC_EDIT_ACTION == "CAS-STRIKE" || {A3C_HC_ACTIVE_PRE_COND_MODE == "ARRIVAL"}) then {

	_preCondModeCtrlPos set [2,_fullW];

} else {
	_preCondModeCtrlPos set [2,_fullW / 2];
};
_preCondModeCtrl ctrlSetPosition _preCondModeCtrlPos;
_preCondModeCtrl ctrlCommit 0;

(_display displayCtrl IDC_MAP_HCWP_Completion_Header_TXT) ctrlSetText _header3Text;
