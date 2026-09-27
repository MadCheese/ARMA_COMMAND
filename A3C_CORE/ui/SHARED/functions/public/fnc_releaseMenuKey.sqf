#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\hud\squadPlacement\dialog_defines.hpp"

// A3C_ui_shared_fnc_releaseMenuKey

/*
	Unified key-release cleanup for:

	- Radial menu
	- Selection Prompt Panel
	- Squad-placement interaction display
	- Main display
*/
params [
	["_display", displayNull, [displayNull]]
];

if (isNull _display) exitWith {};

private _radialDisplay = findDisplay IDD_RADIAL_MENU;

/*
	Legacy squad-placement interaction display IDD.

	Replace this with its named IDD macro once the owning dialog definitions
	are available within the shared component without introducing another
	component header.
*/
private _squadPlacementDisplay = findDisplay IDD_SQUAD_PLACEMENT_INTERACTION;

private _mainDisplay = findDisplay 46;

private _isRadialDisplay = _display isEqualTo _radialDisplay;
private _isSquadPlacementDisplay = _display isEqualTo _squadPlacementDisplay;
private _isMainDisplay = _display isEqualTo _mainDisplay;


//-- HC-boarding abortion in HUD
A3C_UI_MAPICONS_HC_VICS = [];

/*
	Close or clean up the input display.

	The radial menu uses its own close function. Other custom displays are
	closed directly. The main display itself must never be closed.
*/
if (_isRadialDisplay) then {
	[] call A3C_ui_radialMenu_fnc_closeDisplay;
} else {
	if (_isMainDisplay) then {
		/*
			Cancel the active grenade interaction, when present.
		*/
		private _grenadeUnit = missionNamespace getVariable [
			"A3C_GTI_UNIT",
			objNull
		];

		if (!isNull _grenadeUnit) then {
			private _firedEventHandlerId = missionNamespace getVariable [
				"BR_A3C_TEMP_gfeh",
				-1
			];

			if (_firedEventHandlerId >= 0) then {
				_grenadeUnit removeEventHandler [
					"Fired",
					_firedEventHandlerId
				];
			};

			A3C_GREN_MUZZLE = "";
			A3C_GTI_UNIT = objNull;
			A3C_AI_GREN_ARRAY = [];

			[
				"BR_A3C_TACV_oefId",
				"onEachFrame"
			] call BIS_fnc_removeStackedEventHandler;
		};
	} else {
		_display closeDisplay 0;
	};
};

if (_isSquadPlacementDisplay) then {
	/*
		Squad-placement HUD cleanup.
	*/
	private _showInteraction = profileNamespace getVariable [
		"A3C_UI_squadPlacement_interactionSHOW_VAR",
		true
	];

	if (_showInteraction) then {
		private _overlayIsOpen = profileNamespace getVariable [
			"A3C_UI_squadPlacement_overlayIsOpen",
			false
		];

		if (!_overlayIsOpen) then {
			[] call A3C_UI_squadPlacement_fnc_refreshOverlay;
		};
	} else {
		(
			"A3C_UI_squadPlacement_overlay"
			call BIS_fnc_rscLayer
		) cutText [
			"",
			"PLAIN"
		];

		profileNamespace setVariable [
			"A3C_UI_squadPlacement_overlayIsOpen",
			false
		];
	};
} else {
	/*
		Radial-menu and Selection Prompt Panel cleanup.
	*/
	private _actionId = missionNamespace getVariable [
		"A3C_AI_HighCommand_Action_ID",
		""
	];

	private _isHud3dTag = missionNamespace getVariable [
		"A3C_isHud3dTag",
		false
	];

	if (
		_actionId != ""
		&& {!_isHud3dTag}
	) then {
		[] call A3C_UI_mainDisplay_fnc_cancelPositionalActionProcess;

		A3C_AI_HighCommand_Action_ID = "";
	};

	A3C_DISABLE_RADIAL = false;

	private _objectPlacer = missionNamespace getVariable [
		"A3C_OBJECTPLACER",
		objNull
	];

	if (!isNull _objectPlacer) then {
		deleteVehicle _objectPlacer;
	};

	//-- reset any tag icons unless flicker is active
	if !(A3C_UI_HUD_3D_TAGGING) then {
		A3C_UI_RADIAL_Current_Remfire_Units = [];
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
		A3C_UI_HUD_3D_TAG_reposition = false;
	};
	
};

/*
	General commanding-menu cleanup.
*/
{
	player groupSelectUnit [
		_x,
		false
	];
} forEach units group player;

showCommandingMenu "";

"ENABLE" call A3C_ui_shared_fnc_toggleActionMenuAbility;