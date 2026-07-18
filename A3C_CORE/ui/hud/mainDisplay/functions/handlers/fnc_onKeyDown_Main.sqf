#include "..\..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\..\SHARED\selectionPromptPanel\dialog_defines.hpp"

// A3C_UI_mainDisplay_fnc_onKeyDown_Main

params [
	["_display", displayNull, [displayNull]],
	["_key", -1, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

/*
	Input restrictions.
*/
if (_key == 1) exitWith {
	false
};

if (player != leader group player) exitWith {
	false
};

if (!isNull findDisplay 312) exitWith {
	false
};

/*
	ALT + TAB can prevent the matching KeyUp event from firing.
*/
if (
	_alt
	&& {_key == 15}
) exitWith {
	A3C_UI_DOWNKEYS = [];

	false
};

/*
	Allow the Tao Folding Map keybind to pass through.
*/
if (
	A3C_IsTAO
	&& {
		private _taoKeybind = (
			[
				"Tao Folding Map",
				"toggle"
			] call CBA_fnc_getKeybind
		) select 5;

		_taoKeybind isEqualTo [
			_key,
			[
				_shift,
				_ctrl,
				_alt
			]
		]
	}
) exitWith {
	false
};

/*
	Skip repeated A3C KeyDown processing without blocking the engine's
	continuous input handling.
*/
if (
	[_key] call A3C_ui_shared_fnc_blockKeyDownEvent
) exitWith {
	false
};

/*
	Confirm an active positional action with Spacebar.
*/
if (
	_key == 57
	&& {
		A3C_AI_HighCommand_Action_ID != ""
		|| {A3C_AI_Squad_Action_ID != ""}
	}
) exitWith {
	private _actionScript = scriptNull;
	private _flickerMode = "SUPPRESSION";
	private _oneTimeAction = true;

	if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
		switch A3C_AI_Squad_Action_ID do {
			case "ATSHOT": {
				[
					A3C_REMFIRE_ATShot_Units,
					"ATSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "UGLSHOT": {
				[
					A3C_REMFIRE_UGLShot_Units,
					"UGLSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "STATICSHOT": {
				[
					A3C_REMFIRE_StaticShot_Units,
					"STATICSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "TANKSHOT": {
				[
					A3C_REMFIRE_TankShot_Units,
					"TANKSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "SUPPRESSION": {
				[] call A3C_ai_squad_fnc_actionSuppression;
			};

			case "PLACE_CHARGE_SQUAD": {
				[] call A3C_UI_selectionPromptPanel_fnc_actionChargeSelectSquad;
			};

			case "STATIC_ASSEMBLE_SQUAD": {
				[] spawn A3C_ai_squad_fnc_actionAssembleWeapon;
			};

			case "GTI_GRENADE_SQUAD": {
				[] spawn A3C_ai_squad_fnc_actionThrowGTIgrenade;
			};
		};
	} else {
		switch A3C_AI_HighCommand_Action_ID do {
			case "TANKSHOT": {
				[
					A3C_REMFIRE_TankShot_Units,
					"TANKSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "VTOL_CANNON": {
				_actionScript = [
					"CANNON"
				] spawn A3C_ai_highCommand_fnc_actionRemoteFireVtolDispatch;
			};

			case "VTOL_GATLING": {
				_actionScript = [
					"GATLING"
				] spawn A3C_ai_highCommand_fnc_actionRemoteFireVtolDispatch;
			};

			case "VTOL_AUTOCANNON": {
				_actionScript = [
					"AUTOCANNON"
				] spawn A3C_ai_highCommand_fnc_actionRemoteFireVtolDispatch;
			};

			case "UGLSHOT": {
				[
					A3C_REMFIRE_UGLShot_Units,
					"UGLSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "ATSHOT": {
				[
					A3C_REMFIRE_ATShot_Units,
					"ATSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "STATICSHOT": {
				[
					A3C_REMFIRE_StaticShot_Units,
					"STATICSHOT"
				] spawn A3C_ai_shared_fnc_structureRemoteLaunch;
			};

			case "UAV_FPV": {
				[] call A3C_ai_highCommand_fnc_actionUavFPV;
			};

			case "REPAIR": {
				[] call A3C_ai_highCommand_fnc_actionRepair;

				_flickerMode = "";
			};

			case "LANDING_PRECISION": {
				[] call A3C_ui_selectionPromptPanel_fnc_actionLandingPrecisionPromptStart;

				_flickerMode = "DEMOLITION";
			};

			case "CAS-STRIKE": {
				[] call A3C_ui_selectionPromptPanel_fnc_actionCasStrikePromptStart;

				_flickerMode = "DEMOLITION";
			};

			case "RAPPEL": {
				[] spawn A3C_ai_highCommand_fnc_actionRappell;

				_flickerMode = "";
			};

			case "SUPPRESSION": {
				[] call A3C_ai_highCommand_fnc_actionSuppression;
			};

			case "ARTY": {
				[] call A3C_ui_selectionPromptPanel_fnc_actionArtilleryPromptStart;

				_oneTimeAction = false;
			};

			case "PLACE_CHARGE_HC": {
				[] call A3C_UI_selectionPromptPanel_fnc_actionChargeSelectHighCommand;

				_flickerMode = "DEMOLITION";
			};

			case "STATIC_ASSEMBLE_HC": {
				[] call A3C_ai_highCommand_fnc_actionAssembleWeapon;

				_flickerMode = "DEMOLITION";
			};

			case "BoardVehicle_HC": {
				[] call A3C_ai_highCommand_fnc_actionBoardGroupToVehicle;

				_flickerMode = "BOARD";
			};

			case "HC_Waypoint": {
				[] call A3C_ai_highCommand_fnc_actionAddWaypoint;

				_oneTimeAction = false;
			};
		};
	};

	[
		_actionScript,
		_oneTimeAction,
		_flickerMode
	] spawn {
		params [
			"_actionScript",
			"_oneTimeAction",
			"_flickerMode"
		];

		/*
			spawn returns a script handle. The original CODE type check
			could never succeed.
		*/
		if !(_actionScript isEqualTo scriptNull) then {
			waitUntil {
				uiSleep 0.05;

				scriptDone _actionScript
			};
		};

		waitUntil {
			uiSleep 0.05;

			isNull findDisplay IDD_SELECTION_PROMPT_PANEL
		};

		if (_oneTimeAction) then {
			[
				_flickerMode
			] spawn A3C_UI_mainDisplay_fnc_confirmPositionalActionProcess;
		} else {
			private _iconType =
				A3C_UI_HUD_3D_TAG_ICON_TYPE;

			for "_index" from 1 to 2 do {
				A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
				sleep 0.1;

				A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
				sleep 0.1;
			};
		};
	};

	true
};

private _keyControlsMap =
	inputAction "showMap" > 0;

/*
	The Main Display does not receive the corresponding KeyUp after the map
	opens, so map input must not be stored as held.
*/
if (!_keyControlsMap) then {
	[
		_key
	] call A3C_ui_shared_fnc_addDownkey;

	A3C_LASTUSED_KD = time;
};

if (inputAction "revealTarget" > 0) then {
	[
		cameraOn,
		screenToWorld [0.5, 0.5]
	] call A3C_main_fnc_revealCursorPos;
};

private _blockDefaultKey = nil;

switch true do {
	case _keyControlsMap: {
		/*
			Safety precaution: KeyUp will not fire after entering the map.
		*/
		A3C_UI_DOWNKEYS = [];

		private _keyIsNotGPS =
			inputAction "miniMapToggle" == 0;

		if (
			_keyIsNotGPS
			&& {
				profileNamespace getVariable "A3C_MAP_OVERLAY_SHOWN"
			}
		) then {
			A3C_WeaponCurr =
				currentWeapon player;

			[
				IDD_MAP_OVERLAY
			] spawn A3C_ui_mapOverlay_fnc_openOverlay;

			private _groupUnits =
				(units group player) - [player];

			if (_groupUnits isNotEqualTo []) then {
				private _airDriverCount = {
					_x == driver vehicle _x
					&& {
						vehicle _x isKindOf "AIR"
					}
				} count _groupUnits;

				if (
					_airDriverCount
					>= (
						count _groupUnits / 2
					)
				) then {
					A3C_MAP_CommandMode = "AIR";
				} else {
					A3C_MAP_CommandMode = "INF";
				};
			} else {
				A3C_MAP_CommandMode = "HC";
			};

			A3C_SELECTED_UNITS = [];
		};
	};

	case (
		a3c_is_HC_remote
		&& {
			_key in [
				200,
				203,
				205,
				208
			]
		}
	): {
		_this call A3C_ui_shared_fnc_onKeyDown_remoteVehicle;

		_blockDefaultKey = true;
	};

	/*
		UAV gunner: W and Up Arrow command the AI pilot to move toward the
		position beneath the screen center.
	*/
	case (
		!a3c_is_HC_remote
		&& {
			_key in [
				17,
				200
			]
		}
		&& {unitIsUAV cameraOn}
		&& {
			remoteControlled driver cameraOn
			!= player
		}
	): {
		private _driver =
			driver cameraOn;

		if (!isNull _driver) then {
			[
				_driver,
				screenToWorld [0.5, 0.5]
			] remoteExec [
				"doMove",
				_driver
			];
		};
	};

	/*
		This intentionally follows the UAV check because UAVs can also be
		helicopters.
	*/
	case (
		player == gunner vehicle player
		&& {
			currentPilot vehicle player
			!= player
		}
		&& {
			vehicle player isKindOf "HELICOPTER"
		}
	): {
		_this call A3C_UI_mainDisplay_fnc_onKeyDown_heliGunner;
	};

	case (
		!isNil "A3C_FORM_KEY_ID"
		&& {
			[
				_key,
				_shift,
				_ctrl,
				_alt
			] isEqualTo A3C_FORM_KEY_ID
		}
	): {
		[] call A3C_ui_customFormation_fnc_spawnDialog;
	};

	case (
		profileNamespace getVariable "A3C_NUM_VAR"
		&& {
			_key in [
				71,
				72,
				73,
				75,
				76,
				77,
				79,
				80,
				81,
				103,
				104,
				105,
				106
			]
		}
	): {
		[
			_key
		] call A3C_UI_mainDisplay_fnc_onKeyDown_NUM;
	};
};

if (A3C_UI_squadPlacement_units isEqualTo []) then {
	A3C_MODIFIER_LOCK = false;
};

if (isNil "_blockDefaultKey") then {
	_blockDefaultKey = [
		_key,
		[
			_shift,
			_ctrl,
			_alt
		]
	] call A3C_ui_shared_fnc_getKeyBool;
};

_blockDefaultKey