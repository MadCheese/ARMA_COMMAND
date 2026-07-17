#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"

// A3C_UI_mainDisplay_fnc_cbaKeyManager

// Main CBA keybind.
// Input example: ["SHIFT", "DOWN", _buttonData]

params [
	"_function",
	"_mode",
	["_buttonData", 0]
];

private _unitNumber = if ((count _this) > 2) then {
	_this select 2
} else {
	objNull
};

private _unit = objNull;
private _targetUnits = [];

if (player != ((units player) select 0)) exitWith {};
// #NOTE: seems incomplete. This could enable keybind when player is not.

// ZEUS interface is open. Prevent most A3C stuff.
if (!isNull findDisplay 312) exitWith {};

switch (_function) do {
	case "SUPPRESSION": {
		if (_mode == "DOWN") then {
			if (!visibleMap) then {
				if (player == leader group player) then {
					if !((!isNull objectParent player) && { cameraView == "INTERNAL" }) then {
						if ((count groupSelectedUnits player) == 0) then {
							{
								if (!isPlayer _x) then {
									player groupSelectUnit [_x, true];
								};
							} forEach ((units group player) - [player]);
						};

						if ((count groupSelectedUnits player) > 0) then {
							A3C_SUPPRESSION_UNITS_SQ_TEMP = groupSelectedUnits player;

							{
								if (isPlayer _x) then {
									A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x];
								};
							} forEach A3C_SUPPRESSION_UNITS_SQ_TEMP;

							if (({ _x in A3C_SUPPRESSION_UNITS_SQ_TEMP } count A3C_SUPPRESSION_UNITS_SQ) == 0) then {
								// Spawn suppression indicator.
								A3C_SUPPRESSIONHEIGHT = 0;
								A3C_SUPPRESSION_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
								A3C_SUPPRESSION_INDICATOR setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,0.5)"];
							} else {
								{
									if !(_x in A3C_SUPPRESSION_UNITS_SQ) then {
										A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x];
									};
								} forEach A3C_SUPPRESSION_UNITS_SQ_TEMP;

								[A3C_SUPPRESSION_UNITS_SQ_TEMP, "SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
							};

							showCommandingMenu "";

							{
								inGameUISetEventHandler [_x, "true"];
							} forEach ["PrevAction", "NextAction"];
						};
					} else {
						systemChat "A3C: Switch camera view to order Suppression";
					};
				};
			};
		} else {
			if !(isNull A3C_SUPPRESSION_INDICATOR) then {
				[
					A3C_SUPPRESSION_UNITS_SQ_TEMP,
					[getPosATL A3C_SUPPRESSION_INDICATOR, ""],
					"SUPPRESSION",
					true
				] spawn A3C_ai_shared_fnc_polygonAreaActionOn;

				deleteVehicle A3C_SUPPRESSION_INDICATOR;
			};

			{
				inGameUISetEventHandler [_x, "false"];
			} forEach ["PrevAction", "NextAction"];
		};
	};

	case "LOCK": {
		if (_mode == "DOWN") then {
			if (A3C_MODIFIER_LOCK) then {
				A3C_MODIFIER_LOCK = false;
			} else {
				A3C_MODIFIER_LOCK = true;
			};
		};
	};

	case "GREN_P": {
		// Real button grenade player.
		// Prevent grenade throw when planning.
		if (!visibleMap) then {
			if (_mode == "DOWN") then {
				if ((count groupSelectedUnits player) == 0) then {
					// Prevent grenade throw when player is unconscious.
					if !([player] call A3C_ai_shared_fnc_medical_isUnitUnconscious) then {
						[_mode] call A3C_ai_shared_fnc_gtiGrenade_throwPlayer;
					};
				} else {
					_targetUnits = groupSelectedUnits player;

					{
						if (isPlayer _x) then {
							_targetUnits = _targetUnits - [_x];
						};
					} forEach _targetUnits;

					A3C_BOOL_REMFIRE = true;

					// Remove units if they do not have GL, re-add them if they do have AT.
					// This makes GL preferred over AT at this point.
					// If the unit has GL and AT, he will later prefer AT.
					{
						_targetUnits = _targetUnits - [_x];

						if ((count (getArtilleryAmmo [vehicle _x]) > 0) && { _x == gunner vehicle _x }) then {
							if !(_x in _targetUnits) then {
								_targetUnits = [_x] + _targetUnits;
							};
						};

						if ([_x] call A3C_main_fnc_unitHasUGL) then {
							_targetUnits pushBackUnique _x;
						};

						if ([_x] call A3C_main_fnc_unitHasAT) then {
							_targetUnits pushBackUnique _x;
						};

						if ((vehicle _x isKindOf "Tank") && { _x == gunner vehicle _x }) then {
							_targetUnits pushBackUnique _x;
						};
					} forEach _targetUnits;

					if ((count _targetUnits) > 0) then {
						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = _targetUnits;
						A3C_SQ_REM_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
						A3C_SQ_REM_INDICATOR setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,1,0,0.5)"];
						showCommandingMenu "";
					};
				};
			} else {
				if (A3C_BOOL_REMFIRE) then {
					A3C_BOOL_REMFIRE = false;

					if !(isNull A3C_SQ_REM_INDICATOR) then {
						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [
							A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units,
							getPosASL A3C_SQ_REM_INDICATOR
						] call A3C_ui_shared_fnc_findBestShooters;

						if ((count A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units) > 0) then {
							[
								A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units select 0,
								getPosASL A3C_SQ_REM_INDICATOR,
								"FIND"
							] spawn A3C_ai_shared_fnc_orderRemoteLaunch;
						};

						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [];
						deleteVehicle A3C_SQ_REM_INDICATOR;
					};
				} else {
					[_mode] call A3C_ai_shared_fnc_gtiGrenade_throwPlayer;
				};
			};
		};
	};

	case "FORM": {
		if (_mode == "DOWN" && { !visibleMap }) then {
			if (isNil "A3C_FORM_KEY_ID") then {
				[] spawn {
					hint "initialized...please repeat";
					sleep 5;
					hint "";
				};
			};

			A3C_FORM_KEY_ID = [
				_buttonData select 1,
				_buttonData select 2,
				_buttonData select 3,
				_buttonData select 4
			];

			setMousePosition [0.5, 0.5];
		};
	};

	case "MAP": {
		// This bind controls the toggle of the map overlay.
		profileNamespace setVariable [
			"A3C_MAP_KEY_ID",
			[
				_buttonData select 1,
				[
					_buttonData select 2,
					_buttonData select 3,
					_buttonData select 4
				]
			]
		];

		if !(A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE) then {
			if (visibleMap) then {
				if (_mode == "DOWN") then {
					if (isNull findDisplay IDD_MAP_OVERLAY) then {
						profileNamespace setVariable ["A3C_MAP_OVERLAY_SHOWN", true];
						A3C_OPACITY = 0.8;
						[IDD_MAP_OVERLAY] spawn A3C_ui_mapOverlay_fnc_openOverlay;
					} else {
						A3C_OPACITY = 0;

						[] spawn {
							sleep 0.1;

							(findDisplay IDD_MAP_OVERLAY) closeDisplay 2;
							A3C_SELECTED_UNITS = [];

							{
								_x setVariable ["A3C_PLOT_TEMP", [], true];
							} forEach units group player;

							profileNamespace setVariable ["A3C_MAP_OVERLAY_SHOWN", false];
						};
					};
				};
			};
		};
	};

	case "ZEUS": {
		selectPlayer A3C_ZEUS_UNIT;
	};

	case "HUD": {
		if (commandingMenu == "" && { !visibleMap }) then {
			if ((count groupSelectedUnits player) == 0) then {
				if (_unitNumber isEqualType "") then {
					_targetUnits = (profileNamespace getVariable "A3C_GROUPUNITS") - [player];

					if !(_unitNumber == "ALL") then {
						{
							private _assignedTeam = if (player == cameraOn) then {
								assignedTeam _x
							} else {
								_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
							};

							if (_assignedTeam != _unitNumber) then {
								_targetUnits = _targetUnits - [_x];
							};

							if (isPlayer _x) then {
								_targetUnits = _targetUnits - [_x];
							};
						} forEach _targetUnits;
					};

					if ((count A3C_UI_squadPlacement_units) == 0) then {
						{
							[
								_x,
								_x getVariable "A3C_FORMATION_INDEX"
							] call A3C_UI_squadPlacement_fnc_addUnitGhost;
						} forEach _targetUnits;
					} else {
						// Bug prevention.
						if (_unitNumber == "ALL") then {
							if (!isNil "A3C_UI_squadPlacement_positionLoopHandle") then {
								terminate A3C_UI_squadPlacement_positionLoopHandle;
							};
						};

						// Remove units from selection.
						{
							if (alive _x) then {
								[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
							};
						} forEach _targetUnits;
					};
				} else {
					_unit = (profileNamespace getVariable "A3C_GROUPUNITS") select (_unitNumber - 1);

					if ((count A3C_SELECTED_UNITS) == 0) then {
						A3C_HUD_FORM = 0;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
						A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
						A3C_HUD_FORM_ICON_SIZE = 0.8;
					};

					if (!isPlayer _unit) then {
						if (_unit in A3C_UI_squadPlacement_units) then {
							[_unit] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
						} else {
							if (alive _unit) then {
								[_unit, _unitNumber] call A3C_UI_squadPlacement_fnc_addUnitGhost;
							};
						};
					};
				};

				[] spawn {
					sleep 0.1;
					showCommandingMenu "";
				};
			};
		};
	};

	case "ORDER_REG": {
		profileNamespace setVariable [
			"A3C_ORDER_REG_KEY_ID",
			[
				_buttonData select 1,
				[
					_buttonData select 2,
					_buttonData select 3,
					_buttonData select 4
				]
			]
		];
	};

	case "ORDER_FW": {
		profileNamespace setVariable [
			"A3C_ORDER_FW_KEY_ID",
			[
				_buttonData select 1,
				[
					_buttonData select 2,
					_buttonData select 3,
					_buttonData select 4
				]
			]
		];
	};

	case "GoCode_A": {
		["A"] call A3C_ui_shared_fnc_activateGoCode;
	};

	case "GoCode_B": {
		["B"] call A3C_ui_shared_fnc_activateGoCode;
	};

	case "GoCode_C": {
		["C"] call A3C_ui_shared_fnc_activateGoCode;
	};

	case "GoCode_D": {
		["D"] call A3C_ui_shared_fnc_activateGoCode;
	};

	case "COMMAND_LEVEL": {
		if ((count A3C_HC_allGroupsClient_Current > 0) OR { [player] call A3C_ai_shared_fnc_medical_isUnitUnconscious }) then {
			{
				player groupSelectUnit [_x, false];
			} forEach ((units player) - [player]);

			showCommandingMenu "";
			A3C_RD_UNITS = [];

			private _shownHud = +(shownHud);

			if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
				A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
				_shownHud = A3C_ShownHud;
			} else {
				A3C_CURRENT_COMMAND_LEVEL = "HIGHCOMMAND";
				_shownHud set [6, false];
			};

			showHUD _shownHud;

			if (!isNull findDisplay IDD_RADIAL_MENU) then {
				[A3C_CURRENT_COMMAND_LEVEL] call A3C_ui_radialMenu_fnc_labelInnerRing;
			};
		} else {
			A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
		};
	};

	case "Voice_Medic_All": {
		A3C_RD_UNITS = (units player) - [player];

		{
			if (isPlayer _x) then {
				A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			};
		} forEach A3C_RD_UNITS;

		private _medics = [A3C_RD_UNITS] call A3C_ai_shared_fnc_medical_findMedics;
		_group setVariable ["A3C_MEDICS", _medics];

		(group player) setVariable ["A3C_MEDICS_LB", _medics];

		private _patients = [group player] call A3C_ai_shared_fnc_medical_findPatients;
		(group player) setVariable ["A3C_PATIENTS_LB", _patients];

		[group player, 0] spawn A3C_ai_shared_fnc_medical_giveHealingOrder;
	};

	case "Voice_AUTOCOMBAT": {
		[groupSelectedUnits player] spawn A3C_ai_squad_fnc_toggleAutoCombat;
	};

	case "Voice_REFRESH": {
		[(units group player) - [player]] call A3C_ui_shared_fnc_resetPlayerGroup;
	};

	case "Voice_LookDir": {
		{
			_x lookAt objNull;
			_x doTarget objNull;
		} forEach groupSelectedUnits player;
	};

	case "Voice_Stance_Auto": {
		A3C_HUD_STANCE_MODE_TRAVEL = 3;
		[] call A3C_UI_squadPlacement_fnc_setStance;
	};

	case "Voice_Stance_STAND": {
		A3C_HUD_STANCE_MODE_TRAVEL = 2;
		[] call A3C_UI_squadPlacement_fnc_setStance;
	};

	case "Voice_Stance_CROUCH": {
		A3C_HUD_STANCE_MODE_TRAVEL = 1;
		[] call A3C_UI_squadPlacement_fnc_setStance;
	};

	case "Voice_Stance_PRONE": {
		A3C_HUD_STANCE_MODE_TRAVEL = 0;
		[] call A3C_UI_squadPlacement_fnc_setStance;
	};

	case "Voice_Stance_NOCHANGE": {
		A3C_HUD_STANCE_MODE_TRAVEL = 4;
		[] call A3C_UI_squadPlacement_fnc_setStance;
	};

	case "Voice_Hold": {
		(groupSelectedUnits player) call A3C_ai_squad_fnc_unitRouteHold;
	};

	case "Voice_Cont": {
		(groupSelectedUnits player) call A3C_ai_squad_fnc_unitRouteContinue;
	};

	case "Voice_Unload": {
		systemChat format ["%1:'GET OUT!'", name player];

		private _vehicle = vehicle player;

		if (!isNull objectParent player) then {
			if (player == driver _vehicle) then {
				private _dismountGroups = [];

				{
					private _crewUnit = _x;
					private _crewGroup = group _crewUnit;

					if (_crewGroup != group player) then {
						if ([_crewGroup, player] call A3C_main_fnc_isCargoGroupEjectable) then {
							_dismountGroups pushBackUnique _crewGroup;
						};
					} else {
						if ([_crewUnit, _vehicle] call A3C_main_fnc_isCargoUnitEjectable) then {
							[[_crewUnit], A3C_ai_shared_fnc_unitGetOut] remoteExec ["BIS_fnc_call", _crewUnit];
						};
					};
				} forEach crew _vehicle;

				{
					private _dismountingGroup = _x;

					[
						_dismountingGroup,
						vehicle player
					] remoteExec ["leaveVehicle", leader _dismountingGroup];
				} forEach _dismountGroups;
			};
		};
	};
};