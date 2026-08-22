#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

private _mode = _this select 0;
private _btn = if (count _this > 1) then {_this select 1} else {-1};
private _shift = if (count _this > 2) then {_this select 2} else {false};
private _doToggle = if (count _this > 3) then {_this select 3} else {true};
private _bv = "";

A3C_RD_BOOL_UNITS = true;


//-- define outer ring buttons:
private _outerButtonMacros = ["radial_outerButtonMacros"] call FUNC(ctrlGroup);
private _outerImages = ["radial_outerImages"] call FUNC(ctrlGroup);
private _outerButtons = ["radial_outerButtons"] call FUNC(ctrlGroup);



//-- exit if fnc-area was defined
if (!(_mode == 'FORM') && !(A3C_RADIAL_HOVER) && (_btn == -1)) exitWith {};

if (_mode == 'FORM' && {A3C_CURRENT_COMMAND_LEVEL == "SQUAD"}) then {A3C_RADIAL_HOVER = true} else {A3C_RADIAL_HOVER = false};
if !(_mode == "FORM") then {
	playsound "ReadOutHideClick1";
};

private _doRefreshGroupSelected = true;
{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;

[] call A3C_ui_radialMenu_fnc_resetDynamicButtons; //-- reset outer ring buttons

A3C_LBR_1 = "";


//-- Vehicle buttons - idc's are numeric because they are dynamically created with ctrlCreate
for "_i" from 0 to 45 do {
	if (ctrlType (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i)) != -1) then {
		ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i));
		ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i + 1));
	};
};

for "_i" from 11101 to 11104 do {
	ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl _i);
};




switch (_mode) do {

	case ("RINGFORM") : {
		_bv = "BV_RINGFORM";
		A3C_RADIALMODE = "RINGFORM";

		if (_btn == 1) exitWith {
			//-- RMB on inner circle formation button >> adjust group formation direction
			(group player) setFormDir (getDir (vehicle player));
			player groupRadio "VehicleWatchPos";
		};

		if (BV_RINGFORM == 0) then {
			if (_btn != -1) then {
				BV_RINGFORM = 1;
			};

			//-- Outer ring reset: hide all, clear images and tooltips
			{
				_x ctrlShow false;
			} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

			{
				_x ctrlSetText "";
			} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

			{
				_x ctrlSetToolTip "";
			} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));

			private _formations = [
				"COLUMN",
				"STAG COLUMN",
				"WEDGE",
				"ECH LEFT",
				"ECH RIGHT",
				"VEE",
				"LINE",
				"FILE",
				"DIAMOND"
			];

			private _outerRingBackgroundIDs = ["PlaceHolder", "Left", "bottom", "Right", "Top"];
			private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);

			{
				private _ind = _forEachIndex + 1;

				if (_ind <= ((ceil ((count _formations) / 4)) min 3)) then {
					_x ctrlShow true;
					_x ctrlSetText format [
						"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
						_outerRingBackgroundIDs select _ind
					];
				} else {
					_x ctrlShow false;
				};
			} forEach _outerRingBackgrounds;

			private _imageStrings = [
				"Column",
				"StaggColumn",
				"Wedge",
				"Ech_Left",
				"Ech_Right",
				"Vee",
				"Line",
				"File",
				"Diamond"
			];

			private _formationSlots = [
				[16, "outerLeft4Img", "outerLeft4Btn"],
				[15, "outerLeft3Img", "outerLeft3Btn"],
				[14, "outerLeft2Img", "outerLeft2Btn"],
				[13, "outerLeft1Img", "outerLeft1Btn"],

				[12, "outerBottom4Img", "outerBottom4Btn"],
				[11, "outerBottom3Img", "outerBottom3Btn"],
				[10, "outerBottom2Img", "outerBottom2Btn"],
				[9,  "outerBottom1Img", "outerBottom1Btn"],

				[8,  "outerRight4Img", "outerRight4Btn"],
				[7,  "outerRight3Img", "outerRight3Btn"],
				[6,  "outerRight2Img", "outerRight2Btn"],
				[5,  "outerRight1Img", "outerRight1Btn"],

				[4,  "outerTop4Img", "outerTop4Btn"],
				[3,  "outerTop3Img", "outerTop3Btn"],
				[2,  "outerTop2Img", "outerTop2Btn"],
				[1,  "outerTop1Img", "outerTop1Btn"]
			];

			//-- Label button images and functions.
			{
				private _slot = _formationSlots param [_forEachIndex, []];
				if (_slot isEqualTo []) exitWith {};

				_slot params ["_buttonItem", "_btnImageKey", "_btnClickerKey"];

				private _btnImage = [_btnImageKey] call FUNC(ctrl);
				private _btnClicker = [_btnClickerKey] call FUNC(ctrl);

				if (isNull _btnImage || {isNull _btnClicker}) exitWith {};

				{
					_x ctrlShow true;
				} forEach [_btnImage, _btnClicker];

				private _btnImagePath = format [
					"A3C_CORE\ui\pictures\icon_menu_form_%1.paa",
					_imageStrings select _forEachIndex
				];

				_btnImage ctrlSetText _btnImagePath;
				_btnClicker ctrlSetToolTip _x;

				call compile format [
					"
						A3C_OUTER_RING_BTN_fnc_%1 =
						[
							[],
							{
								private _mb = (_this select 0) select 1;

								['%2'] spawn A3C_ai_shared_fnc_setFormation;

								if (_mb == 1) then {
									(group player) setFormDir (getDir (vehicle player));

									[] spawn {
										hint 'FORMATION-DIR ADJUSTED';
										sleep 1;
										player groupRadio 'VehicleWatchPos';
										sleep 1;
										hintSilent '';
									};
								};
							}
						];
					",
					_buttonItem,
					_x
				];
			} forEach _formations;
		} else {
			BV_RINGFORM = 0;
			[false] call A3C_ui_radialMenu_fnc_toggleOuterRing;
		};
	};
	case ("GRENADE") : {
		if (A3C_RADIALMODE != "GRENADE") then {
			BV_GREN = 0;
		};
		_bv = "BV_GREN";
		A3C_RADIALMODE = 'GRENADE';

		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			if (BV_GREN == 0) then {

				if (_btn != -1) then {
					BV_GREN = 1;
				};
				BV_ACT = 0;
				BV_MEDICAL = 0;
				BV_CBMODE = 0;

				[0] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;


				//-- RIGHT EXTENSION: hide all controls
				{
					_x ctrlShow false;
				} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

			} else {
				BV_GREN = 0;
				[false] call A3C_ui_radialMenu_fnc_toggleOuterRing;
			};
		};
	};
	case ("ACTIONS") : {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RADIALMODE = 'ACT';
			_bv = "BV_ACT";
			BV_ROE = 0;
			if (BV_ACT == 0) then {
				if (_btn != -1) then {
					BV_ACT = 1;
				};
				BV_MEDICAL = 0;
				BV_CBMODE = 0;
				BV_GREN = 0;

				//-- RIGHT EXTENSION: hide all controls
				{
					_x ctrlShow false;
				} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

				[IDD_RADIAL_MENU,A3C_RD_UNITS] call A3C_ui_radialMenu_fnc_squad_actionsDistribute;

				private _outerRingBackgroundIDs = ["Placeholder", "Top", "Right", "bottom"];
				private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);
				//-- Update outer ring backgrounds for available action pages
				{
					private _ind = _forEachIndex + 1;

					if (_ind <= ((ceil ((count A3C_DYNAMIC_BUTTON_ACTIONS) / 4)) min 3)) then {
						_x ctrlShow true;
						_x ctrlSetText format [
							"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
							_outerRingBackgroundIDs select _ind
						];
					} else {
						_x ctrlShow false;
					};
				} forEach _outerRingBackgrounds;

				//-- Reset outer ring button/image color
				{
					_x ctrlSetTextColor [1,1,1,0.6];
				} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));
			} else {
				BV_ACT = 0;
				[false] call A3C_ui_radialMenu_fnc_toggleOuterRing;
			};
		} else {
			if (_btn == 0) then {
				[
					false, //-- isBusy
					"HC_Waypoint", //-- actionID
					'\a3c_ui\hud\icon_HUD_movePos.paa', //-- Hud-Icon-class  "\a3\ui_f\data\IGUI\Cfg\Cursors\waypointMark_ca.paa"
					[1,1,1,0.7], //-- Hud-Icon-color
					"", //-- placer class
					"" //-- placer color-params
				] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;	
			} else {
				//-- Hide outer ring buttons/images and backgrounds
				{
					_x ctrlShow false;
				} forEach (
					(["radial_outerButtonMacros"] call FUNC(ctrlGroup))
					+ (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
				);
			};

		};

	};
	case ("ROE") : {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			if (_btn == 1) then {
				[] call A3C_ui_radialMenu_fnc_squad_openROE;
			} else {
				A3C_RADIALMODE = 'ROE';
				_bv = "BV_ROE";
				BV_ACT = 0;
				if (BV_ROE == 0) then {
					if (_btn != -1) then {
						BV_ROE = 1;
					};

					//-- show top and right ring 
					{
						_x ctrlShow true;
					} forEach ([
						["bgTop"] call FUNC(ctrl),
						["bgRight"] call FUNC(ctrl)
					] select {!isNull _x});

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_TOP) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Top.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right_Var1.paa";

					//-- TOP RING
					{
						_x ctrlShow true;
					} forEach (["radial_outerTopMacros"] call FUNC(ctrlGroup));

					private _topIcons = [
						"A3C_CORE\ui\pictures\icon_menu_ROE_FAW.paa",
						"A3C_CORE\ui\pictures\icon_menu_ROE_FOT.paa",
						"A3C_CORE\ui\pictures\icon_menu_ROE_FOML.paa",
						if ({_x in A3C_AutoCombatDisabledUnits} count A3C_RD_UNITS == 0) then {
							"A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa"
						} else {
							"A3C_CORE\ui\pictures\icon_menu_autocombat_disabled.paa"
						}
					];

					private _topTooltips = [
						"TARGET SELECTION: AUTONOMOUS",
						"TARGET SELECTION: DESIGNATED ONLY",
						"FIRE ON MY LEAD",
						if ({_x in A3C_AutoCombatDisabledUnits} count A3C_RD_UNITS == 0) then {
							"DISABLE AUTOCOMBAT"
						} else {
							"ENABLE AUTOCOMBAT"
						}
					];

					{
						_x ctrlSetTextColor [1,1,1,0.6];
						_x ctrlSetText (_topIcons select _forEachIndex);
					} forEach (["radial_outerTopImages"] call FUNC(ctrlGroup));

					{
						_x ctrlSetTooltip (_topTooltips select _forEachIndex);
					} forEach (["radial_outerTopButtons"] call FUNC(ctrlGroup));

					private _behaviorIcon = "\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa";
					private _combatModeIcon ="\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa";

					//"\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa"
					//"\a3\ui_f\data\IGUI\Cfg\Cursors\attack_ca.paa"
					//"\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa"
					//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\defend_ca.paa"
					//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
					//"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"

					//-- RIGHT RING: hide all controls (images + buttons)
					{
						_x ctrlShow false;
					} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));


					// //-- RIGHT RING - COMBAT MODES / BEHAVIOUR MACRO SELECTOR
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlShow true;
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText _combatModeIcon;
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetTextColor [1,1,1,0.4];

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlShow true;
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "COMBAT MODES AND BEHAVIOUR";


					//-- HIDE RIGHT EXTENSION (all controls)
					{
						_x ctrlShow false;
					} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

					BV_MEDICAL = 0;
					BV_CBMODE = 0;
					BV_GREN = 0;

					//-- BUTTON FUNCTIONS 
					//-- Upper Ring: Custom ROE's
					A3C_OUTER_RING_BTN_fnc_1 =
					[
						[],
						{[0] spawn A3C_ai_squad_fnc_setROE;}
					];
					A3C_OUTER_RING_BTN_fnc_2 =
					[
						[],
						{[1] spawn A3C_ai_squad_fnc_setROE;} 
					];
					A3C_OUTER_RING_BTN_fnc_3 =
					[
						[],
						{[2] spawn A3C_ai_squad_fnc_setROE;}
					];
					A3C_OUTER_RING_BTN_fnc_4 =
					[
						str (groupSelectedUnits player),
						{
							params ["_btnData", "_units"];

							_btnData params ["_display", "_button"];

							_units = call compile _units;

							[_units] spawn FUNC(toggleAutoCombatButton);
						}
					];
					//-- Right Ring: Combat Modes | Behaviours Macro
					A3C_OUTER_RING_BTN_fnc_5 =
					[
						[],
						{
							[] call A3C_ui_radialMenu_fnc_squad_openROE;
						}
					];
				} else {
					BV_ROE = 0;
					[false] call A3C_ui_radialMenu_fnc_toggleOuterRing;
				};
			};

		} else {
			A3C_RADIALMODE = "HC ACTIONS";
			A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;

			private _actions = [_doToggle] call A3C_ui_shared_fnc_highCommand_actionsLabel;

			private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);

			{
				_x ctrlShow false;
			} forEach _outerRingBackgrounds;

			if (count _actions > 0) then {
				{
					private _imgString = switch (_forEachIndex + 1) do {
						case 1: { "Top" };
						case 2: { "Right" };
						case 3: { "Bottom" };
						case 4: { "Left" };
					};

					_x ctrlSetText format [
						"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
						_imgString
					];

					if (_doToggle) then {
						_x ctrlShow true;
					};
				} forEach (_outerRingBackgrounds select [0, ceil (count _actions / 4)]);
			};

			//-- Outer ring buttons/images: reset text color
			{
				_x ctrlSetTextColor [1,1,1,0.6];
			} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

		};

	};
	case ("BRAIN") : {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RADIALMODE = 'BRAIN';
			BV_LB1 = 6;
			BV_LB2 = 7;
			BV_GREN = 0;
			_bv = "BV_BRAIN";

			{
				_x ctrlSetTextColor [1,1,1,0.6];
			} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

			if (_btn == 1) then {
				//-- right click macro unit lookdir+unitpos reset
				 player groupRadio "SentBehaviourSafe";
				{_x dowatch objnull; _x lookat objnull; _x setUnitPos 'AUTO';} foreach (groupSelectedUnits player);
			} else {
				//-- left click: toggle right outer ring
				[false] call A3C_ui_radialMenu_fnc_toggleOuterRing;
				if (BV_BRAIN == 0) then {

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
					if (_btn != -1) then {
						BV_BRAIN = 1;
					};

					//-- hide outer ring BG's except RIGHT
					{
						_x ctrlShow false;
					} forEach (
						(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
						- [
							["bgRight"] call FUNC(ctrl)
						]
					);

					//-- RIGHT RING: show all controls (images + buttons)
					{
						_x ctrlShow true;
					} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

					//-- RIGHT EXTENSION: hide all controls
					{
						_x ctrlShow false;
					} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

					BV_MEDICAL = 0;
					BV_CBMODE = 0;

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_resetWatchdir.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "RESET WATCHDIR";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
					if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
					} else {
						// if ({private _unit = _x; {_unit getHitPointDamage _x > 0.2} count A3C_HUMAN_HITPOINTS > 0} count (units player) > 0) then {
						if (([group player] call A3C_ai_shared_fnc_medical_findPatients) isNotEqualTo []) then {
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,0.3,0.3,0.6];
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
						} else {
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "No units wounded";
						};
					};

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"; //"A3C_CORE\ui\pictures\icon_menu_takeCover.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "Behaviour & CombatMode";//"FIND COVER";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_reArm.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "RE-ARM (LMB: choose target, RMB: find target)";

					A3C_OUTER_RING_BTN_fnc_5 =
					[
						str (groupSelectedUnits player),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button"];
							_units = call compile _units;

							//-- toggle right extension modes off
							BV_MEDICAL = 0;
							BV_CBMODE = 0;

							{
								_x dowatch objnull;
								_x lookat objnull;
							} foreach _units;
							player groupchat 'STAY ALERT (looking dir)';
						}
					];
					A3C_OUTER_RING_BTN_fnc_6 =
					[
						str (groupSelectedUnits player),
						{
							//-- medical menu toggle button
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;


							if (_button == 0) then {
								//-- left click: toggle medical menu

								//-- if automedic is on and menu is opened, auto medic is turned off
								if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
									profileNameSpace setVariable ["A3C_AUTOMEDIC", false];
									if ({private _unit = _x; {_unit getHitPointDamage _x > 0.2} count A3C_HUMAN_HITPOINTS > 0} count (units player) > 0) then {
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,0.3,0.3,0.6];
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. SHIFT+LMB: Closest Medic Heal Player (AUTO-mode coming soon)";
									} else {
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "No units wounded";
									};
								};
								//--
								if !(_shift) then {
									BV_CBMODE = 0;
									//-- no Shift: bring up healing menu
									if (BV_MEDICAL == 0) then {
										BV_MEDICAL = 1;
										A3C_LBR_1 = "MEDICAL";
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";

										// clear right extension listboxes
										{
											lbClear _x;
										} forEach ([
											["extensionRightLbSourcesBox"] call FUNC(ctrl),
											["extensionRightLbSubselBox"] call FUNC(ctrl)
										] select {!isNull _x});

										["MEDICAL"] call A3C_ui_radialMenu_fnc_labelListbox;
									} else {
										BV_MEDICAL = 0;

										//-- RIGHT EXTENSION: hide all controls
										{
											_x ctrlShow false;
										} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));
									};
								} else {
									//-- shift: shortCut to heal only player
									private _medics = [A3C_RD_UNITS] call A3C_ai_shared_fnc_medical_findMedics;

									(group player) setVariable ["A3C_MEDICS", _medics];
									[group player] call A3C_ai_shared_fnc_medical_findPatients;
									private _medics_lb = +(_medics);

									if (player in (group player getVariable ["A3C_PATIENTS",[]])) then {
										(group player) setVariable ["A3C_PATIENTS", [player]];
										(group player) setVariable ["A3C_PATIENTS_LB", [player]];

										//-- #TODO: filter closest medic 
										(group player) setVariable ["A3C_MEDICS", [(_medics select 0)]];
										_medics_lb = [(_medics select 0)];

										[group player, 0] spawn A3C_ai_shared_fnc_medical_giveHealingOrder;
									} else {
										(group player) setVariable ["A3C_PATIENTS",[]];
									};

									(group player) setVariable ["A3C_MEDICS_LB", _medics_lb];
								};

							} else {
								//-- right click: toggle auto-medic
								if !(profileNameSpace getVariable "A3C_AUTOMEDIC") then {
									profileNameSpace setVariable ["A3C_AUTOMEDIC", true];
									(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
									(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];

									//-- RIGHT EXTENSION: hide all controls
									{
										_x ctrlShow false;
									} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

									[] spawn A3C_ai_shared_fnc_medical_startAutoHeal;
								};
							};
						}
					];
					A3C_OUTER_RING_BTN_fnc_7 =
					[
						str (groupSelectedUnits player),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;



							//-- RIGHT EXTENSION: hide all controls
							{
								_x ctrlShow false;
							} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));


							BV_MEDICAL = 0; //-- reset MedicalButton value to 0 (for closing/opening extension)
							if (BV_CBMODE == 0) then {
								BV_CBMODE = 1;
								A3C_LBR_1 = "CBMODE";
								BV_LB1 = 12;
								BV_LB2 = 13;
								//-- open right extension: combat mode
								(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";

								//-- clear right extension listboxes
								{
									lbClear _x;
								} forEach ([
									["extensionRightLbSourcesBox"] call FUNC(ctrl),
									["extensionRightLbSubselBox"] call FUNC(ctrl)
								] select {!isNull _x});

								["CBMODE"] call A3C_ui_radialMenu_fnc_labelListbox;
							} else {
								//-- combat mode
								BV_CBMODE = 0;
							};
						}
					];
					A3C_OUTER_RING_BTN_fnc_8 =
					[
						str (groupSelectedUnits player),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button"];
							_units = call compile _units;

							BV_MEDICAL = 0; //-- reset button values for functions that spawn extensions, close extension
							BV_CBMODE = 0;

							//-- RIGHT EXTENSION: hide all controls
							{
								_x ctrlShow false;
							} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

							A3C_LBR_1 = "REARM";
							if (_button == 0) then {
								A3C_ReArm_options = [];
								[] call A3C_ui_radialMenu_fnc_reArm_openUi;

							} else {
								{[_x] spawn A3C_ai_shared_fnc_reArm_autoEvaluated} foreach _units;
								player groupradio "SentCmdRearm";	
							};
						}
					];

				} else {
					BV_BRAIN = 0;
					//-- !!! HIDE THE RIGHT SIDE EXTENSION!!
				};
			};
		} else {
			//-- HC - stances here
			A3C_RADIALMODE = "HC STANCES";
			//-- wipe outer ring
			{
				_x ctrlShow false;
			} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));
			//-- Reset outer ring action buttons
			{
				_x ctrlShow false;
			} forEach _outerButtonMacros;

			{
				_x ctrlSetText "";
			} forEach _outerImages;

			{
				_x ctrlSetToolTip "";
			} forEach _outerButtons;

			private _img = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
			private _color = [1, 1, 1, 0.5];

			//-- RIGHT RING: show all controls (images + buttons)
			{
				_x ctrlShow true;
			} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

			//-- RIGHT RING: set icons + color (images)
			private _rightIcons = [
				"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
				"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
				"A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa"
			];

			{
				_x ctrlSetText (_rightIcons select _forEachIndex);
				_x ctrlSetTextColor _color;
			} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

			//-- RIGHT RING: set tooltips (buttons)
			private _rightTooltips = [
				"AUTO",
				"UP",
				"CROUCH",
				"PRONE"
			];

			{
				_x ctrlSetTooltip (_rightTooltips select _forEachIndex);
			} forEach (["radial_outerRightButtons"] call FUNC(ctrlGroup));

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
			A3C_OUTER_RING_BTN_fnc_5 =
			[
				"AUTO",
				{
					params ["_clickData","_stance"];
					{
						{
							[_x,_stance] remoteExec ["setUnitPos",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
					player groupRadio "SentBehaviourSafe";
				}
			];
			A3C_OUTER_RING_BTN_fnc_6 =
			[
				"UP",
				{
					params ["_clickData","_stance"];
					{
						{
							[_x,_stance] remoteExec ["setUnitPos",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
					player groupRadio "SentUnitPosUp";
				}
			];
			A3C_OUTER_RING_BTN_fnc_7 =
			[
				"MIDDLE",
				{
					params ["_clickData","_stance"];
					{
						{
							[_x,_stance] remoteExec ["setUnitPos",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
					player groupRadio "SentUnitPosMiddle";
				}
			];
			A3C_OUTER_RING_BTN_fnc_8 =
			[
				"DOWN",
				{
					params ["_clickData","_stance"];
					{
						{
							[_x,_stance] remoteExec ["setUnitPos",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
					player groupRadio "SentUnitPosDown";
				}
			];
		};
	};

	case ("STANCE") : {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			_bv = "BV_STANCES";
			private _bgRight = ["bgRight"] call FUNC(ctrl);

			_bgRight ctrlShow true;
			_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";

			{
				_x ctrlShow false;
			} forEach (
				[
					["bgTop"] call FUNC(ctrl),
					["bgBottom"] call FUNC(ctrl),
					["bgLeft"] call FUNC(ctrl)
				] select {!isNull _x}
			);

			//-- RIGHT RING: show all controls (images + buttons)
			{
				_x ctrlShow true;
			} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

			//-- OUTER RING: hide all non-right segments (top, bottom, left)
			{
				_x ctrlShow false;
			} forEach (
				(["radial_outerTopMacros"] call FUNC(ctrlGroup)) +
				(["radial_outerBottomMacros"] call FUNC(ctrlGroup)) +
				(["radial_outerLeftMacros"] call FUNC(ctrlGroup))
			);

			//-- RIGHT EXTENSION: hide all controls
			{
				_x ctrlShow false;
			} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

			BV_MEDICAL = 0;
			BV_CBMODE = 0;
			BV_GREN = 0;
			A3C_RADIALMODE = 'STANCE'; //-- 'Stance', being the default layer, will be used as parent for sublayers (goCode)

			if (_btn == 1) then {
				A3C_RADIALMODE = "GOCODE";
				if (BV_STANCES == 3) then {
					BV_STANCES = 0;
					["STANCE",0] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;
				} else {
					BV_STANCES = 3;
					//-- note - some non existing main img was set to "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "GoCode A";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "GoCode B";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "GoCode C";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "GoCode D";
					[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0];

					A3C_OUTER_RING_BTN_fnc_5 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							//_units = call compile _units;


							['A'] call A3C_ui_shared_fnc_activateGoCode;

						}
					];
					A3C_OUTER_RING_BTN_fnc_6 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							//_units = call compile _units;

							['B'] call A3C_ui_shared_fnc_activateGoCode;

						}
					];
					A3C_OUTER_RING_BTN_fnc_7 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							['C'] call A3C_ui_shared_fnc_activateGoCode;

						}
					];
					A3C_OUTER_RING_BTN_fnc_8 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							['D'] call A3C_ui_shared_fnc_activateGoCode;
						}
					];
				};
			} else {
				_bv = "BV_STANCES";
				if (BV_STANCES == 0) then {
					if (_btn != -1) then {
						BV_STANCES = 1;
					};

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";

					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_auto.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "AUTO";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "STAND";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "CROUCH";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "PRONE";

					{
						_x ctrlSetTextColor [1,1,1,0.6];
					} forEach (
						[
							["innerStancesImg"] call FUNC(ctrl)
						]
						+ (["radial_outerRightImages"] call FUNC(ctrlGroup))
					);

					A3C_OUTER_RING_BTN_fnc_5 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;
							[A3C_RD_UNITS,'AUTO'] call A3C_ai_shared_fnc_setUnitPos; //~~??
						}
					];
					A3C_OUTER_RING_BTN_fnc_6 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;
							[A3C_RD_UNITS,'UP'] call A3C_ai_shared_fnc_setUnitPos;
						}
					];
					A3C_OUTER_RING_BTN_fnc_7 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;
							[A3C_RD_UNITS,'MIDDLE'] call A3C_ai_shared_fnc_setUnitPos;
						}
					];
					A3C_OUTER_RING_BTN_fnc_8 =
					[
						str (A3C_RD_UNITS),
						{
							params ["_btnData","_units"];
							_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
							_units = call compile _units;
							[A3C_RD_UNITS,'DOWN'] call A3C_ai_shared_fnc_setUnitPos;
						}
					];


				} else {
					BV_STANCES = 0;
					//-- RIGHT RING: hide all controls (images + buttons)
					{
						_x ctrlShow false;
					} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow false;
				};
			};
		} else {
			//-- HC GO CODE SECTION
			A3C_RADIALMODE = "HC GOCODE";
			//-- wipe outer ring
			{
				_x ctrlShow false;
			} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));

			//-- Reset outer ring action buttons
			{
				_x ctrlShow false;
			} forEach _outerButtonMacros;

			{
				_x ctrlSetText "";
			} forEach _outerImages;

			{
				_x ctrlSetToolTip "";
			} forEach _outerButtons;

			private _img = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";

			//-- RIGHT RING: show all controls (images + buttons)
			{
				_x ctrlShow true;
			} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

			//-- RIGHT RING: set icons
			private _rightIcons = [
				"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa",
				"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"
			];

			{
				_x ctrlSetText (_rightIcons select _forEachIndex);
			} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

			//-- RIGHT RING: set tooltips
			private _rightTooltips = [
				"GOCODE A",
				"GOCODE B",
				"GOCODE C",
				"GOCODE D"
			];

			{
				_x ctrlSetTooltip (_rightTooltips select _forEachIndex);
			} forEach (["radial_outerRightButtons"] call FUNC(ctrlGroup));

			[] remoteExec ["A3C_ui_shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa"; //-- aiai
			A3C_OUTER_RING_BTN_fnc_5 =
			[
				"A",
				{
					['A'] call A3C_ui_shared_fnc_activateGoCode;
				}
			];
			A3C_OUTER_RING_BTN_fnc_6 =
			[
				"B",
				{
					['B'] call A3C_ui_shared_fnc_activateGoCode;
				}
			];
			A3C_OUTER_RING_BTN_fnc_7 =
			[
				"C",
				{
					['C'] call A3C_ui_shared_fnc_activateGoCode;
				}
			];
			A3C_OUTER_RING_BTN_fnc_8 =
			[
				"D",
				{
					['D'] call A3C_ui_shared_fnc_activateGoCode;
				}
			];


		};
	};

	case ("ITEMS") : {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RADIALMODE = "ITEMS";
			_bv = "BV_ITEMS";

			private _itemCategories = [];
			private _grunts = A3C_RD_UNITS;
			BV_GREN = 0;

			if ({handgunWeapon _x != ""} count _grunts > 0) then {
				_itemCategories pushBack "SWITCHWEAPON";
			};

			if ( (   {count (_x getvariable ["A3C_STROBE",[]]) > 0 } count _grunts > 0)   OR {{private _item = _x; [_item] call A3C_main_fnc_isIRMagazine} count (magazines _x) > 0} count _grunts > 0) then {
				_itemCategories pushBack "IR_STROBE";
			};

			if ({{private _item = _x; [_item] call A3C_main_fnc_isNVGoggles} count (assignedItems _x + items _x) > 0} count _grunts > 0) then {
				_itemCategories pushBack "NVG";
			};
			private _sunData = [] call BIS_fnc_sunriseSunsetTime;
			_sunData params ["_sunRise","_sunDown"];
			private _isDark = if (dayTime < _sunRise OR {dayTime > _sunDown }) then {true} else {false};
			{
				private _itemString = _x;
				private _add = true;
				//-- if it is NOT dark, do not add light/laser actions unless someone is actually using it
				//-- this is important so that you can still turn off the actions after sunrise
				if !(_isDark) then {
					switch (_foreachIndex) do {
						case (0) : {
							if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "FLASHLIGHT"} count A3C_RD_UNITS == 0) then {
								_add = false;
							};
						};
						case (1) : {
							if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "LASER"} count A3C_RD_UNITS == 0) then {
								_add = false;
							};
						};
					};
				};

				if (_add && {{[_x,_itemString] call A3C_main_fnc_hasWeaponItem} count _grunts > 0}) then {
					_itemCategories pushBack _itemString;
				};

			} foreach ["FLASHLIGHT","LASER","SILENCER"];

			if (!("SILENCER" in _itemCategories) && {{count ([_x,"MuzzleSlot",0,(currentWeapon _x)] call MCSS_fnc_getWeaponItems) > 0} count A3C_RD_UNITS > 0}) then {
				_itemCategories pushBack "SILENCER";
			};
			//-- Hide all outer ring buttons/images
			{
				_x ctrlShow false;
			} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));


			{
				_x ctrlShow false;
			} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));



			if (count _itemCategories == 0) exitWith {};

			if (BV_ITEMS == 0) then {
				if (_btn != -1) then {
					BV_ITEMS = 1;
				};

				private _bgBottom = ["bgBottom"] call FUNC(ctrl);
				_bgBottom ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
				_bgBottom ctrlShow true;

				//-- RIGHT EXTENSION: hide all controls
				{
					_x ctrlShow false;
				} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

				private _itemSlots = [
					[12, "outerBottom4Img", "outerBottom4Btn"],
					[11, "outerBottom3Img", "outerBottom3Btn"],
					[10, "outerBottom2Img", "outerBottom2Btn"],
					[9,  "outerBottom1Img", "outerBottom1Btn"],

					[8,  "outerRight4Img", "outerRight4Btn"],
					[7,  "outerRight3Img", "outerRight3Btn"],
					[6,  "outerRight2Img", "outerRight2Btn"],
					[5,  "outerRight1Img", "outerRight1Btn"],

					[4,  "outerTop4Img", "outerTop4Btn"],
					[3,  "outerTop3Img", "outerTop3Btn"],
					[2,  "outerTop2Img", "outerTop2Btn"],
					[1,  "outerTop1Img", "outerTop1Btn"]
				];

				{
					private _slot = _itemSlots param [_forEachIndex, []];


					if (_slot isEqualTo []) exitWith {};

					_slot params ["_buttonID", "_buttonImgKey", "_buttonClickerKey"];

					if (_buttonID == 8) then {
						private _bgRight = ["bgRight"] call FUNC(ctrl);
						_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
						_bgRight ctrlShow true;
					};

					private _currentCategory = _x;

					private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
					private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

					if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

					private _fnc = {};
					private _prms = [str A3C_RD_UNITS, _buttonImgKey, _buttonClickerKey];

					switch (_currentCategory) do {
						case "SWITCHWEAPON": {
							private _SwitchWeaponImage = "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
							private _SwitchWeaponToolTip = "Switch To Handgun";

							if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0) then {
								_SwitchWeaponImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
								_SwitchWeaponToolTip = "Switch To Rifle";
							};

							_buttonImg ctrlSetText _SwitchWeaponImage;
							_buttonImg ctrlSetTextColor [1,1,1,0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _SwitchWeaponToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];
								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;

								private _btnImage = "";
								private _tooltip = "";
								A3C_Prevent_SwitchWeapon = true;
								private _totalStandBy = 0;

								_buttonImg ctrlSetTextColor [1,1,1,0.3];

								{
									if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0) then {
										_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
										_tooltip = "Switch To Handgun";

										private _delay = random 1;
										_totalStandBy = _totalStandBy max _delay;

										[_x, _delay] spawn {
											params ["_unit", "_delay"];
											sleep _delay;
											_unit selectWeapon (primaryWeapon _unit);
										};
									} else {
										_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
										_tooltip = "Switch To Rifle";

										private _delay = random 1;
										_totalStandBy = _totalStandBy max _delay;

										[_x, _delay] spawn {
											params ["_unit", "_delay"];
											sleep _delay;
											_unit selectWeapon (handGunWeapon _unit);
										};
									};
								} forEach _units;

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep _totalStandBy;

								A3C_Prevent_SwitchWeapon = false;

								if (ctrlShown _buttonImg && {"switch" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_SwitchWeapon)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"switch" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};

						case "IR_STROBE": {
							private _strobeImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
							private _strobeToolTip = "Attach IR-Strobe";

							if ({(count (_x getVariable ["A3C_STROBE", []])) > 0} count A3C_RD_UNITS > 0) then {
								_strobeImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
								_strobeToolTip = "Remove IR-Strobe";
							};

							_buttonImg ctrlSetText _strobeImage;
							_buttonImg ctrlSetTextColor [1,1,1,0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _strobeToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];

								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;
								_units = _units select {!isNull _x};

								_units pushBackUnique player;

								private _btnImage = "";
								private _tooltip = "";
								private _totalStandBy = 0;

								private _anyUnitHasStrobe = {
									count (_x getVariable ["A3C_STROBE", []]) > 0
								} count _units > 0;

								private _mode = if (_anyUnitHasStrobe) then {"OFF"} else {"ON"};

								private _requestId = format ["%1_%2_%3", clientOwner, diag_tickTime, random 1];

								A3C_Prevent_attach_IR = true;

								_buttonImg ctrlSetTextColor [1, 1, 1, 0.3];

								if (_mode == "OFF") then {
									_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
									_tooltip = "Attach IR-Strobe";

									{
										private _unit = _x;
										private _delay = random 1;

										_totalStandBy = _totalStandBy max _delay;

										_unit setVariable [
											"A3C_IR_STROBE_REQUEST",
											["OFF", _requestId],
											true
										];

										[
											_unit,
											"OFF",
											"",
											_delay,
											_requestId
										] spawn A3C_ai_shared_fnc_actionIrStrobeSet;
									} forEach _units;
								} else {
									_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
									_tooltip = "Remove IR-Strobe";

									{
										private _unit = _x;

										if (count (_unit getVariable ["A3C_STROBE", []]) == 0) then {
											private _magazineClass = "";

											{
												private _itemClass = _x;
												private _ammoClass = getText (configFile >> "CfgMagazines" >> _itemClass >> "ammo");
												private _nvgMarkers = "true" configClasses (
													configFile >> "CfgAmmo" >> _ammoClass >> "NVGMarkers"
												);

												if (count _nvgMarkers > 0) exitWith {
													_magazineClass = _itemClass;
												};
											} forEach magazines _unit;

											if (_magazineClass != "") then {
												private _delay = random 1;

												_totalStandBy = _totalStandBy max _delay;

												_unit setVariable [
													"A3C_IR_STROBE_REQUEST",
													["ON", _requestId],
													true
												];

												[
													_unit,
													"ON",
													"NVG_TargetC",
													_delay,
													_requestId,
													_magazineClass,
													true
												] spawn A3C_ai_shared_fnc_actionIrStrobeSet;
											};
										};
									} forEach _units;
								};

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep (_totalStandBy + 1);

								A3C_Prevent_attach_IR = false;

								if (ctrlShown _buttonImg && {"IRstrobe" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1, 1, 1, 0.6];
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_attach_IR)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"IRstrobe" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};

						case "NVG": {
							private _nvgImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
							private _nvgToolTip = "Turn NVG ON";

							if ({{private _item = _x; [_item] call A3C_main_fnc_isNVGoggles} count assignedItems _x > 0} count A3C_RD_UNITS > 0) then {
								_nvgImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
								_nvgToolTip = "Turn NVG OFF";
							};

							_buttonImg ctrlSetText _nvgImage;
							_buttonImg ctrlSetTextColor [1,1,1,0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _nvgToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];
								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;

								private _btnImage = "";
								private _tooltip = "";
								A3C_Prevent_attach_NVG = true;
								private _totalStandBy = 0;

								_buttonImg ctrlSetTextColor [1,1,1,0.3];

								{
									if ({{private _item = _x; [_item] call A3C_main_fnc_isNVGoggles} count assignedItems _x > 0} count A3C_RD_UNITS > 0) then {
										private _nvgs = "";

										{
											if ([_x] call A3C_main_fnc_isNVGoggles) exitWith {
												_nvgs = _x;
											};
										} forEach assignedItems _x;

										if (_nvgs != "") then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
											_tooltip = "Turn NVG ON";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x, _delay, _nvgs] spawn {
												params ["_unit", "_delay", "_nvgs"];
												sleep _delay;

												_unit playActionNow "GestureHi";
												sleep 0.834;

												if (!(_unit canAddItemToUniform _nvgs) && {!(_unit canAddItemToVest _nvgs) && {!(_unit canAddItemToBackPack _nvgs)}}) exitWith {
													_unit groupChat "I am out of storage - keeping NVG's equipped!";
												};

												_unit unAssignItem _nvgs;
											};
										};
									} else {
										private _nvgs = "";

										{
											if ([_x] call A3C_main_fnc_isNVGoggles) exitWith {
												_nvgs = _x;
											};
										} forEach items _x;

										if (_nvgs != "") then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
											_tooltip = "Turn NVG OFF";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x, _delay, _nvgs] spawn {
												params ["_unit", "_delay", "_nvgs"];
												sleep _delay;

												_unit playActionNow "GestureHi";
												sleep 0.834;

												_unit assignItem _nvgs;
											};
										};
									};
								} forEach _units;

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep (_totalStandBy + 2);

								A3C_Prevent_attach_NVG = false;

								if (ctrlShown _buttonImg && {"NVG" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_attach_NVG)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"NVG" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};
						case "FLASHLIGHT": {
							private _flashlightImage = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
							private _flashlightToolTip = "Turn Flashlight ON";

							if ({_x getVariable ["A3C_isGunPoiterSlotOn", ""] == "FLASHLIGHT"} count A3C_RD_UNITS > 0) then {
								_flashlightImage = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa";
								_flashlightToolTip = "Turn Flashlight OFF";
							};

							_buttonImg ctrlSetText _flashlightImage;
							_buttonImg ctrlSetTextColor [1, 1, 1, 0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _flashlightToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];

								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;
								_units = _units select {!isNull _x};

								private _type = "FLASHLIGHT";
								private _stateValue = "FLASHLIGHT";

								private _mode = if ({
									_x getVariable ["A3C_isGunPoiterSlotOn", ""] == _stateValue
								} count _units > 0) then {
									"OFF"
								} else {
									"ON"
								};



								private _btnImage = if (_mode == "ON") then {
									"A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa"
								} else {
									"A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa"
								};

								private _tooltip = if (_mode == "ON") then {
									"Turn Flashlight OFF"
								} else {
									"Turn Flashlight ON"
								};

								private _phrase = if (_mode == "ON") then {
									"SentLightsOn"
								} else {
									"SentLightsOff"
								};

								private _requestId = format ["%1_%2_%3", clientOwner, diag_tickTime, random 1];
								private _requestVar = format ["A3C_ATTACHMENT_REQUEST_%1", _type];

								private _totalStandBy = 0;

								A3C_Prevent_attach_Flashlight = true;

								_buttonImg ctrlSetTextColor [1, 1, 1, 0.3];

								{
									private _unit = _x;
									private _execute = false;


									if (_mode == "ON") then {
										_execute = [_unit, _type] call A3C_ai_shared_fnc_preparePointerAttachmentMode;
									} else {
										_execute = (_unit getVariable ["A3C_isGunPoiterSlotOn", ""] == _stateValue);
									};

									if (_execute) then {
										private _delay = (0.2 * _forEachIndex) + random 1;
										_totalStandBy = _totalStandBy max _delay;

										_unit setVariable [
											_requestVar,
											[_mode, _requestId],
											true
										];

										[
											_unit,
											_type,
											_mode,
											_delay,
											_requestId
										] spawn A3C_ai_squad_fnc_actionToggleWeaponAttachment;
									};
								} forEach _units;

								player groupRadio _phrase;

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep (_totalStandBy + 1.2);

								A3C_Prevent_attach_Flashlight = false;

								if (ctrlShown _buttonImg && {"FlashLight" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1, 1, 1, 0.6];
								};

								// Switch LASER icon if necessary.
								if ({_x isIRLaserOn currentWeapon _x} count _units == 0) then {
									{
										if ("IRlaser" in ctrlText _x) then {
											_x ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
										};
									} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_attach_Flashlight)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"FlashLight" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1, 1, 1, 0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};

						case "LASER": {
							private _laserImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
							private _laserToolTip = "Turn IR-LASER ON";

							if ({_x getVariable ["A3C_isGunPoiterSlotOn", ""] == "LASER"} count A3C_RD_UNITS > 0) then {
								_laserImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
								_laserToolTip = "Turn IR-LASER OFF";
							};

							_buttonImg ctrlSetText _laserImage;
							_buttonImg ctrlSetTextColor [1, 1, 1, 0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _laserToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];

								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;
								_units = _units select {!isNull _x};

								private _type = "LASER";
								private _stateValue = "LASER";

								private _mode = if ({
									_x getVariable ["A3C_isGunPoiterSlotOn", ""] == _stateValue
								} count _units > 0) then {
									"OFF"
								} else {
									"ON"
								};

								private _btnImage = if (_mode == "ON") then {
									"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa"
								} else {
									"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa"
								};

								private _tooltip = if (_mode == "ON") then {
									"Turn IR-LASER OFF"
								} else {
									"Turn IR-LASER ON"
								};

								private _phrase = if (_mode == "ON") then {
									"SentPointersOn"
								} else {
									"SentPointersOff"
								};

								private _requestId = format ["%1_%2_%3", clientOwner, diag_tickTime, random 1];
								private _requestVar = format ["A3C_ATTACHMENT_REQUEST_%1", _type];

								private _totalStandBy = 0;

								A3C_Prevent_attach_IR_Laser = true;

								_buttonImg ctrlSetTextColor [1, 1, 1, 0.3];

								{
									private _unit = _x;
									private _execute = false;

									if (_mode == "ON") then {
										_execute = [_unit, _type] call A3C_ai_shared_fnc_preparePointerAttachmentMode;
									} else {
										_execute = (_unit getVariable ["A3C_isGunPoiterSlotOn", ""] == _stateValue);
									};



									if (_execute) then {
										private _delay = (0.2 * _forEachIndex) + random 1;
										_totalStandBy = _totalStandBy max _delay;

										_unit setVariable [
											_requestVar,
											[_mode, _requestId],
											true
										];

										[
											_unit,
											_type,
											_mode,
											_delay,
											_requestId
										] spawn A3C_ai_squad_fnc_actionToggleWeaponAttachment;
									};
								} forEach _units;

								player groupRadio _phrase;

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep (_totalStandBy + 1.2);

								A3C_Prevent_attach_IR_Laser = false;

								if (ctrlShown _buttonImg && {"IRlaser" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1, 1, 1, 0.6];
								};

								// Switch FLASHLIGHT icon if necessary.
								if ({_x isFlashlightOn currentWeapon _x} count _units == 0) then {
									{
										if ("FlashLight" in ctrlText _x) then {
											_x ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
										};
									} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_attach_IR_Laser)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"IRlaser" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1, 1, 1, 0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};

						case "SILENCER": {
							private _silencerImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_OFF.paa";
							private _silencerToolTip = "Attach Suppressor";

							if ({[_x, "SILENCER"] call A3C_main_fnc_hasWeaponItem} count A3C_RD_UNITS > 0) then {
								_silencerImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_ON.paa";
								_silencerToolTip = "Remove Suppressor";
							};

							_buttonImg ctrlSetText _silencerImage;
							_buttonImg ctrlSetTextColor [1,1,1,0.3];
							_buttonImg ctrlShow true;

							_buttonClicker ctrlSetToolTip _silencerToolTip;
							_buttonClicker ctrlShow true;

							_fnc = {
								params ["_btnData", "_inputParams"];
								_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
								_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								_units = call compile _units;

								private _btnImage = "";
								private _tooltip = "";
								private _totalStandBy = 0;

								A3C_Prevent_attach_Silencer = true;

								_buttonImg ctrlSetTextColor [1,1,1,0.3];

								private _removeMuzzleItems = _units findIf {
									[_x, "SILENCER"] call A3C_main_fnc_hasWeaponItem
								} != -1;

								{
									if (_removeMuzzleItems) then {
										_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_OFF.paa";
										_tooltip = "Attach Suppressor";

										private _unit = _x;
										private _weapon = currentWeapon _unit;

										private _weaponSlot = switch (true) do {
											case (_weapon isEqualTo primaryWeapon _unit): {
												"PRIMARY"
											};

											case (_weapon isEqualTo handgunWeapon _unit): {
												"HANDGUN"
											};

											case (_weapon isEqualTo secondaryWeapon _unit): {
												"SECONDARY"
											};

											default {
												""
											};
										};

										private _slotItems = [
											_unit,
											"MuzzleSlot",
											1,
											_weapon
										] call MCSS_fnc_getWeaponItems;

										if (
											_weaponSlot isNotEqualTo ""
											&& {count _slotItems > 0}
										) then {
											private _muzzleItem = _slotItems select 0;
											private _gesture = [
												_unit,
												_weapon,
												true
											] call A3C_main_fnc_getMuzzleSwitchGesture;

											private _delay = random 1;

											_totalStandBy = _totalStandBy max _delay;

											[
												_muzzleItem,
												_unit,
												_weapon,
												_weaponSlot,
												_gesture,
												_delay
											] spawn {
												params [
													"_muzzleItem",
													"_unit",
													"_weapon",
													"_weaponSlot",
													"_gesture",
													"_delay"
												];

												sleep _delay;

												private _weaponStillEquipped = switch (_weaponSlot) do {
													case "PRIMARY": {
														primaryWeapon _unit isEqualTo _weapon
													};

													case "HANDGUN": {
														handgunWeapon _unit isEqualTo _weapon
													};

													case "SECONDARY": {
														secondaryWeapon _unit isEqualTo _weapon
													};

													default {
														false
													};
												};

												if (!_weaponStillEquipped) exitWith {};

												_unit selectWeapon _weapon;

												if (_gesture isNotEqualTo "") then {
													_unit playActionNow _gesture;
												};

												sleep 1.2;

												_weaponStillEquipped = switch (_weaponSlot) do {
													case "PRIMARY": {
														primaryWeapon _unit isEqualTo _weapon
													};

													case "HANDGUN": {
														handgunWeapon _unit isEqualTo _weapon
													};

													case "SECONDARY": {
														secondaryWeapon _unit isEqualTo _weapon
													};

													default {
														false
													};
												};

												if (!_weaponStillEquipped) exitWith {};

												private _attachedMuzzleItem = (
													_unit weaponAccessories _weapon
												) param [0, ""];

												if (_attachedMuzzleItem isNotEqualTo _muzzleItem) exitWith {};
												if !(_unit canAdd _muzzleItem) exitWith {};

												switch (_weaponSlot) do {
													case "PRIMARY": {
														_unit removePrimaryWeaponItem _muzzleItem;
													};

													case "HANDGUN": {
														_unit removeHandgunItem _muzzleItem;
													};

													case "SECONDARY": {
														_unit removeSecondaryWeaponItem _muzzleItem;
													};
												};

												_attachedMuzzleItem = (
													_unit weaponAccessories _weapon
												) param [0, ""];

												if (_attachedMuzzleItem isNotEqualTo _muzzleItem) then {
													_unit addItem _muzzleItem;
												};
											};
										};
									} else {
										private _unit = _x;
										private _weapon = currentWeapon _unit;

										private _weaponSlot = switch (true) do {
											case (_weapon isEqualTo primaryWeapon _unit): {
												"PRIMARY"
											};

											case (_weapon isEqualTo handgunWeapon _unit): {
												"HANDGUN"
											};

											case (_weapon isEqualTo secondaryWeapon _unit): {
												"SECONDARY"
											};

											default {
												""
											};
										};

										private _slotItems = [
											_unit,
											"MuzzleSlot",
											0,
											_weapon
										] call MCSS_fnc_getWeaponItems;

										if (
											_weaponSlot isNotEqualTo ""
											&& {count _slotItems > 0}
										) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_ON.paa";
											_tooltip = "Remove Suppressor";

											private _muzzleItem = _slotItems select 0;
											private _gesture = [
												_unit,
												_weapon,
												false
											] call A3C_main_fnc_getMuzzleSwitchGesture;

											private _delay = random 1;

											_totalStandBy = _totalStandBy max _delay;

											[
												_muzzleItem,
												_unit,
												_weapon,
												_weaponSlot,
												_gesture,
												_delay
											] spawn {
												params [
													"_muzzleItem",
													"_unit",
													"_weapon",
													"_weaponSlot",
													"_gesture",
													"_delay"
												];

												sleep _delay;

												private _weaponStillEquipped = switch (_weaponSlot) do {
													case "PRIMARY": {
														primaryWeapon _unit isEqualTo _weapon
													};

													case "HANDGUN": {
														handgunWeapon _unit isEqualTo _weapon
													};

													case "SECONDARY": {
														secondaryWeapon _unit isEqualTo _weapon
													};

													default {
														false
													};
												};

												if (!_weaponStillEquipped) exitWith {};

												if !(_muzzleItem in items _unit) exitWith {};

												_unit selectWeapon _weapon;

												if (_gesture isNotEqualTo "") then {
													_unit playActionNow _gesture;
												};

												sleep 1.2;

												_weaponStillEquipped = switch (_weaponSlot) do {
													case "PRIMARY": {
														primaryWeapon _unit isEqualTo _weapon
													};

													case "HANDGUN": {
														handgunWeapon _unit isEqualTo _weapon
													};

													case "SECONDARY": {
														secondaryWeapon _unit isEqualTo _weapon
													};

													default {
														false
													};
												};

												if (!_weaponStillEquipped) exitWith {};
												if !(_muzzleItem in items _unit) exitWith {};

												private _attachedMuzzleItem = (
													_unit weaponAccessories _weapon
												) param [0, ""];

												if (_attachedMuzzleItem isNotEqualTo "") exitWith {};

												switch (_weaponSlot) do {
													case "PRIMARY": {
														_unit addPrimaryWeaponItem _muzzleItem;
													};

													case "HANDGUN": {
														_unit addHandgunItem _muzzleItem;
													};

													case "SECONDARY": {
														_unit addSecondaryWeaponItem _muzzleItem;
													};
												};

												_attachedMuzzleItem = (
													_unit weaponAccessories _weapon
												) param [0, ""];

												if (_attachedMuzzleItem isEqualTo _muzzleItem) then {
													_unit removeItem _muzzleItem;
												};
											};
										};
									};
								} forEach _units;

								_buttonImg ctrlSetText _btnImage;
								_buttonClicker ctrlSetToolTip _tooltip;

								sleep (_totalStandBy + 1.2);

								A3C_Prevent_attach_Silencer = false;

								if (ctrlShown _buttonImg && {"Silencer" in ctrlText _buttonImg}) then {
									_buttonClicker ctrlShow true;
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
								};
							};

							[_buttonImgKey, _buttonClickerKey] spawn {
								params ["_buttonImgKey", "_buttonClickerKey"];

								waitUntil {!(A3C_Prevent_attach_Silencer)};

								private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
								private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

								if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

								if (ctrlShown _buttonImg && {"Silencer" in ctrlText _buttonImg}) then {
									_buttonImg ctrlSetTextColor [1,1,1,0.6];
									_buttonClicker ctrlShow true;
								};
							};
						};

					};

					call compile format [
						"
							A3C_OUTER_RING_BTN_fnc_%1 =
							[
								%2,
								%3
							];
						",
						_buttonID,
						_prms,
						_fnc
					];
				} forEach _itemCategories;
			} else {
				BV_ITEMS = 0;
			};
		} else {
			//-- HC-BEHAVIOUR
			A3C_RADIALMODE = "HC BEHAVIOUR";

			//-- Hide Outer Ring BG's except BOTTOM:
			{
				_x ctrlShow false;
			} forEach (
				(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
				- [
					["bgBottom"] call FUNC(ctrl)
				]
			);

			//-- Reset outer ring action buttons
			{
				_x ctrlShow false;
			} forEach _outerButtonMacros;

			{
				_x ctrlSetText "";
			} forEach _outerImages;

			{
				_x ctrlSetToolTip "";
			} forEach _outerButtons;

			private _img = "A3C_CORE\ui\pictures\icon_menu_behaviour.paa";
			private _color = [1, 1, 1, 0];

			//-- BOTTOM RING: show all controls (images + buttons)
			{
				_x ctrlShow true;
			} forEach (["radial_outerBottomMacros"] call FUNC(ctrlGroup));

			//-- BOTTOM RING: set icons + colors
			private _bottomColors = [
				[0,1,0,0.5],
				[1,1,0,0.5],
				[1,0,0,0.5],
				[0.17,0.86,0.92,0.5]
			];

			{
				_x ctrlSetText _img;
				_x ctrlSetTextColor (_bottomColors select _forEachIndex);
			} forEach (["radial_outerBottomImages"] call FUNC(ctrlGroup));

			//-- BOTTOM RING: set tooltips
			private _bottomTooltips = [
				"SAFE",
				"AWARE",
				"COMBAT",
				"STEALTH"
			];

			{
				_x ctrlSetTooltip (_bottomTooltips select _forEachIndex);
			} forEach (["radial_outerBottomButtons"] call FUNC(ctrlGroup));

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
			A3C_OUTER_RING_BTN_fnc_9 =
			[
				"SAFE",
				{
					params ["_clickData","_behaviour"];
					{
						{
							[_x,_behaviour] remoteExec ["setBehaviour",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_10 =
			[
				"AWARE",
				{
					params ["_clickData","_behaviour"];
					{
						{
							[_x,_behaviour] remoteExec ["setBehaviour",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_11 =
			[
				"COMBAT",
				{
					params ["_clickData","_behaviour"];
					{
						{
							[_x,_behaviour] remoteExec ["setBehaviour",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_12 =
			[
				"STEALTH",
				{
					params ["_clickData","_behaviour"];
					{
						{
							[_x,_behaviour] remoteExec ["setBehaviour",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
		};

	};

	case ("VEHICLES") : {

		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RADIALMODE = 'VEHS';
			BV_LB1 = 8;
			BV_LB2 = 9;
			_bv = "BV_VEHS";
			if (_btn == 1) then {
				// RCLICK
				{
					if (
						!isPlayer _x
						&& {!isNull objectParent _x}
					) then {
						[_x] spawn A3C_ai_shared_fnc_getOut;

						A3C_BOARD_UNITS pushBackUnique _x;
					};
				} forEach A3C_RD_UNITS;
				player groupradio "SentCmdGetOut"; 
			} else {
				//-- Hide all outer ring backgrounds
				{
					_x ctrlShow false;
				} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));

				//-- Hide all outer ring controls (buttons + images)
				{
					_x ctrlShow false;
				} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

				//-- Reset visual state of outer ring images (text color used as tint)
				{
					_x ctrlSetTextColor [1,1,1,0.6];
				} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

				BV_MEDICAL = 0;
				BV_CBMODE = 0;
				if (BV_VEHS == 0) then {
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
					if (_btn != -1) then {
						BV_VEHS = 1;
					};

					//-- hide outer ring BG's except BOTTOM
					{
						_x ctrlShow false;
					} forEach (
						(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
						- [
							["bgBottom"] call FUNC(ctrl)
						]
					);
					private _classes = [];
					private _classArray = ["CAR", "TANK", "HELICOPTER", "PLANE", "SHIP", "STATICWEAPON"];

					{
						private _soldier = _x;

						{
							private _entities = (_soldier nearEntities [_x, 220]) select {
								canMove _x &&
								{!(unitIsUAV _x)} &&
								{
									(side _x == civilian) || {((side _x) getFriend (side player)) > 0.6}
								}
							};

							if (count _entities > 0) then {
								_classes pushBackUnique _x;
							};
						} forEach (_classArray - _classes);
					} forEach A3C_RD_UNITS;

					private _classCount = count _classes;

					if (_classCount > 0) then {
						(["bgBottom"] call FUNC(ctrl)) ctrlShow true;

						if (_classCount > 4) then {
							private _bgRight = ["bgRight"] call FUNC(ctrl);
							_bgRight ctrlShow true;
							_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
						};

						private _vehicleClassSlots = [
							[["outerBottom4Img"] call FUNC(ctrl), ["outerBottom4Btn"] call FUNC(ctrl), 12],
							[["outerBottom3Img"] call FUNC(ctrl), ["outerBottom3Btn"] call FUNC(ctrl), 11],
							[["outerBottom2Img"] call FUNC(ctrl), ["outerBottom2Btn"] call FUNC(ctrl), 10],
							[["outerBottom1Img"] call FUNC(ctrl), ["outerBottom1Btn"] call FUNC(ctrl), 9],
							[["outerRight4Img"] call FUNC(ctrl), ["outerRight4Btn"] call FUNC(ctrl), 8],
							[["outerRight3Img"] call FUNC(ctrl), ["outerRight3Btn"] call FUNC(ctrl), 7]
						];

						{
							private _currentClass = _x;
							private _slot = _vehicleClassSlots select _forEachIndex;
							_slot params ["_btnImg", "_btnClicker", "_btnId"];

							private _btnData = switch (_currentClass) do {
								case "CAR": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa", "WHEELED"]
								};
								case "TANK": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa", "TRACKED"]
								};
								case "HELICOPTER": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa", "HELICOPTERS"]
								};
								case "PLANE": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa", "JETS"]
								};
								case "SHIP": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\naval_ca.paa", "SHIPS"]
								};
								case "STATICWEAPON": {
									["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\static_ca.paa", "STATIC WEAPONS"]
								};
							};

							call compile format [
								"
									A3C_OUTER_RING_BTN_fnc_%1 =
									[
										'%2',
										{
											A3C_RADIAL_VEH_KIND = '%3';
											[A3C_RD_UNITS] call A3C_ui_radialMenu_fnc_squad_findVehicles;
										}
									];
								",
								_btnId,
								A3C_RD_UNITS,
								_currentClass
							];

							_btnImg ctrlSetText (_btnData select 0);
							_btnClicker ctrlSetTooltip (_btnData select 1);

							{
								_x ctrlShow true;
							} forEach [_btnImg, _btnClicker];
						} forEach (_classes select [0, count _vehicleClassSlots]);
					};

				} else {
					BV_VEHS = 0;
				};
			};
		} else {
			//-- HC COMBATMODE
			A3C_RADIALMODE = "HC COMBAT";
			//-- Hide outer Ring BG's
			{
				_x ctrlShow false;
			} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));

			//-- Reset outer ring action buttons
			{
				_x ctrlShow false;
			} forEach _outerButtonMacros;

			{
				_x ctrlSetText "";
			} forEach _outerImages;

			{
				_x ctrlSetToolTip "";
			} forEach _outerButtons;

			private _img = "A3C_CORE\ui\pictures\icon_menu_combatMode.paa";
			private _color = [1, 1, 1, 0];

			//-- RIGHT/BOTTOM RING: show ROE controls
			private _roeMacros = [
				["outerRight4Img"] call FUNC(ctrl),
				["outerRight4Btn"] call FUNC(ctrl)
			] + (["radial_outerBottomMacros"] call FUNC(ctrlGroup));

			{
				_x ctrlShow true;
			} forEach (_roeMacros select {!isNull _x});

			//-- RIGHT/BOTTOM RING: set ROE icons + colors
			private _roeImages = [
				["outerRight4Img"] call FUNC(ctrl)
			] + (["radial_outerBottomImages"] call FUNC(ctrlGroup));

			private _roeColors = [
				[1,0,0,0.5],
				[1,1,0,0.5],
				[1,1,1,0.5],
				[0,1,0,0.5],
				[0,0,1,0.5]
			];

			{
				_x ctrlSetText _img;
				_x ctrlSetTextColor (_roeColors select _forEachIndex);
			} forEach (_roeImages select {!isNull _x});

			//-- RIGHT/BOTTOM RING: set ROE tooltips
			private _roeButtons = [
				["outerRight4Btn"] call FUNC(ctrl)
			] + (["radial_outerBottomButtons"] call FUNC(ctrlGroup));

			private _roeTooltips = [
				"RED || Fire at will, engage at will",
				"YELLOW || Fire at will",
				"WHITE || Hold fire, engage at will",
				"GREEN || Hold fire - defend only",
				"BLUE || Never fire"
			];

			{
				_x ctrlSetTooltip (_roeTooltips select _forEachIndex);
			} forEach (_roeButtons select {!isNull _x});

			//-- hide right and bottom outer ring backgrounds
			{
				_x ctrlShow false;
			} forEach ([
				["bgRight"] call FUNC(ctrl),
				["bgBottom"] call FUNC(ctrl)
			] select {!isNull _x});

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
			A3C_OUTER_RING_BTN_fnc_8 =
			[
				"RED",
				{
					params ["_clickData","_combatMode"];
					{
						{
							[_x,_combatMode] remoteExec ["setCombatMode",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];

			A3C_OUTER_RING_BTN_fnc_9 =
			[
				"YELLOW",
				{
					params ["_clickData","_combatMode"];
					{
						{
							[_x,_combatMode] remoteExec ["setCombatMode",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_10 =
			[
				"WHITE",
				{
					params ["_clickData","_combatMode"];
					{
						{
							[_x,_combatMode] remoteExec ["setCombatMode",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_11 =
			[
				"GREEN",
				{
					params ["_clickData","_combatMode"];
					{
						{
							[_x,_combatMode] remoteExec ["setCombatMode",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
			A3C_OUTER_RING_BTN_fnc_12 =
			[
				"BLUE",
				{
					params ["_clickData","_combatMode"];
					{
						{
							[_x,_combatMode] remoteExec ["setCombatMode",_x];
						} foreach (units _x);
					} foreach A3C_RD_UNITS;
				}
			];
		};
	};

	case ("REFRESH") : {
		BV_MEDICAL = 0;
		BV_CBMODE = 0;
		private _tickTime = (time - A3C_LB_TICKTIME);
		private _doubleClick = false;
		if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
			_doubleClick = true;
		};
		A3C_LB_TICKTIME = time;
		if !(_shift) then {
			if (_btn == 1) then {
				private _playerGrp = group player;
				if (_doubleClick) then {
					{
						_x doWatch objNull;
						_x lookAt objNull;
						_x setUnitPos "AUTO";
					} foreach A3C_RD_UNITS;
					player groupRadio "SentBehaviourSafe";
				} else {
					//~~ why is this?? #unclear
					private _tempGrp = createGroup (side player);
					[player] joinSilent _tempGrp;
					[player] joinSilent _playerGrp;
					_playerGrp selectLeader player;
					deleteGroup _tempGrp;

					player doMove (position vehicle player);
					player moveTo (position vehicle player);
					player doFollow player;
					A3C_RD_UNITS commandFollow player;
				};

			} else {
				[(units group player) - [player]] call A3C_ui_shared_fnc_resetPlayerGroup;
			};
		};
		A3C_RADIAL_HOVER = true;
	};
};



{
	call compile format
	[
		"
			%1 = 0;
		",
		parseText _x
	];
} foreach ["BV_ROE","BV_BRAIN","BV_FORM","BV_STANCES","BV_ITEMS","BV_VEHS"] - [_bv];//
if !(_mode in ["REFRESH","FORM"]) then {
	A3C_RADIAL_HOVER = _btn == -1;
};
if (_doRefreshGroupSelected) then {
	[] spawn {sleep 0.1; {player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS; };
};
