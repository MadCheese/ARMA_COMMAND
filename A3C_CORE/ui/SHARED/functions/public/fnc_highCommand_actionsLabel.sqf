#include "..\..\script_component.hpp"
#include "..\..\shared_ui_defines.hpp"
#include "..\..\selectionPromptPanel\dialog_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_highCommand_actionsLabel

/*
	Resolves the active high-command UI, clears its current action slots,
	fetches the available actions, and labels/binds the corresponding controls.

	Action discovery and preparation of action-specific execution data are
	owned by A3C_ui_shared_fnc_highCommand_actionsFetch.
*/
params [
	["_doToggle", true, [true]]
];

private _radialDisplay = findDisplay IDD_RADIAL_MENU;
private _mapDisplay = findDisplay IDD_MAP_OVERLAY;

private _display = if (!isNull _radialDisplay) then {
	_radialDisplay
} else {
	_mapDisplay
};

if (isNull _display) exitWith {
	[]
};

private _displayId = if (!isNull _radialDisplay) then {
	IDD_RADIAL_MENU
} else {
	IDD_MAP_OVERLAY
};

private _isRadial = _displayId == IDD_RADIAL_MENU;
private _isMap = _displayId == IDD_MAP_OVERLAY;

/*
	Legacy local alias retained because several action definitions use this
	name when choosing radial versus map behavior.
*/
private _a3c_dsp = _displayId;

private _buttonArray = if (_isRadial) then {
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
} else {
	+A3C_ui_mapOverlay_GROUPMENU_ACTIONBUTTONS
};

[] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_WIPE;

/*
	Clear and hide all action slots before applying the newly fetched set.
*/
{
	_x params [
		"_backgroundIdc",
		"_imageIdc",
		"_buttonIdc"
	];

	private _imageControl = _display displayCtrl _imageIdc;
	private _buttonControl = _display displayCtrl _buttonIdc;

	if (!isNull _imageControl) then {
		_imageControl ctrlSetText "";
	};

	if (!isNull _buttonControl) then {
		_buttonControl ctrlSetTooltip "";
	};

	{
		if (_x >= 0) then {
			private _control = _display displayCtrl _x;

			if (!isNull _control) then {
				_control ctrlShow false;
			};
		};
	} forEach [
		_backgroundIdc,
		_imageIdc,
		_buttonIdc
	];
} forEach _buttonArray;

/*
	The map dashboard group-name edit field is UI state and therefore remains
	in this labeling function rather than the action collector.
*/
if (_isMap) then {
	private _groupNameEditControl =
		_display displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT;

	if (!isNull _groupNameEditControl) then {
		private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

		private _groupNameText = if (count _selectedGroups == 1) then {
			toUpper groupID (_selectedGroups select 0)
		} else {
			"Multiple Groups"
		};

		_groupNameEditControl ctrlSetText _groupNameText;
	};
};

private _actions = [
	_displayId
] call FUNC(highCommand_actionsFetch);




	{

		if (_forEachIndex < count _buttonArray) then {
			private _actionName = _x;
			private _params = [];
			private _button_IMG = "";
			private _button_toolTip = "";
			private _buttonFnc = {};
			private _imageColorCode = [1,1,1,1];


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
					_button_IMG = "A3C_UI\icons\icon_menu_action_groupSpeed.paa";
					_buttonFnc = {
						[] call A3C_ui_selectionPromptPanel_fnc_actionLimitSpeedStartPrompt;
					};
					_button_toolTip = "Limit Group Speed";
				};
				case ("ORDER_DETO") : {
					_params = [];
					_button_IMG = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
					_button_toolTip = "DETONATE EXPLOSIVES";

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
						[_clickData select 1,_clickData select 5] call A3C_ui_shared_fnc_highCommand_actionDispatchBoardGroupsToVehicle;	
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
						[objNull] call A3C_ui_mapOverlay_fnc_HCGP_actionParaLoadAndDrop;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_loadVehicle.paa";
					_button_toolTip = "LOAD VEHICLES IN CARGO";
				};
				
				case ("UNLOADVEHICLECARGO") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[] spawn A3C_ai_highCommand_fnc_unloadVehicleCargo;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_unloadVehicle.paa";
					_button_toolTip = "UNLOAD VEHICLE CARGO";
				};
				case ("PARADROP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
					_button_toolTip = "DISCHARGE CARGO (PARA)";
					_buttonFnc = {
						[objNull] call A3C_ui_mapOverlay_fnc_HCGP_actionParaLoadAndDrop;
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
						[] call A3C_ai_highCommand_fnc_actionTransferOwnershipDispatch;
					};
				};
				case ("UNSTUCK") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					_button_toolTip = "Unstuck/Unflip units and vehicles";
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[] call A3C_ai_highCommand_fnc_actionUnstuck;
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
					_button_toolTip = "Deploy Mine-Clearing Line Charge";
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
								private _leaderVic = vehicle leader _gp;
								private _isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
								_isRotor
							} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0
						);

						if (_doSpecifyLandingPos) then {
							if (!isNull findDisplay IDD_RADIAL_MENU) then {

								private _vehicleType = "A3C_HeliPad";
								private _colorString = "";
								{
									private _leaderVic = vehicle leader _x;
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
									private _v = vehicle _x;
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
							["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
									private _v = vehicle _x;
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

						[] spawn A3C_ui_shared_fnc_highCommand_actionSuppressionStart;

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
					_button_toolTip = "";
					if (_a3c_dsp == IDD_RADIAL_MENU) then {
						_button_toolTip =  format
						[
							"SUPPRESSIVE FIRE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
							["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
							["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
								[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
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

											if ( ctrlShown (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent) ) exitWith {};
											private _ctrl = _29 in A3C_UI_DOWNKEYS;

											A3C_HC_FOCUS_ARTY_POS = _pos;



											if !(_ctrl) then {
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
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
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
								[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
							} foreach _staticData;
							
						};	
					};
					_button_IMG = (gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "picture"));
					_button_toolTip =  format
					[
						"ASSEMBLE %1 - KEEP %2 PRESSED. SELECT A WEAPON, POSITION AND ROTATE IT (MOUSEWHEEL). PRESS 'SpaceBar' TO CONFIRM OR RELEASE %1 TO CANCEL ",
						(gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")),
						["A3C","A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
					];
				};

				

			};



			private _buttonData = _buttonArray select _forEachIndex;
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

			if (_isRadial) then {
				/*
					Preserve the legacy radial behavior: run the action and then
					refresh the HC action labels shortly afterward.
				*/
				private _buttonFncSource = str _buttonFnc;
				_buttonFncSource = _buttonFncSource select [
					1,
					(count _buttonFncSource) - 2
				];

				_buttonFncSource = _buttonFncSource + (
					" [] spawn {"
					+ " sleep 0.1;"
					+ " [true] call A3C_ui_shared_fnc_highCommand_actionsLabel;"
					+ " };"
				);

				_buttonFnc = compile _buttonFncSource;

				private _handlerVariableName = format [
					"A3C_OUTER_RING_BTN_fnc_%1",
					_forEachIndex + 1
				];

				missionNamespace setVariable [
					_handlerVariableName,
					[
						_params,
						_buttonFnc
					]
				];
			} else {
				private _handlerVariableName = format [
					"A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_%1",
					_forEachIndex
				];

				missionNamespace setVariable [
					_handlerVariableName,
					[
						str _params,
						_buttonFnc
					]
				];

				{
					private _control = _display displayCtrl _x;

					if (!isNull _control) then {
						_control ctrlShow true;
					};
				} forEach _buttonData;
			};


		};
	} foreach _actions;
	_actions
