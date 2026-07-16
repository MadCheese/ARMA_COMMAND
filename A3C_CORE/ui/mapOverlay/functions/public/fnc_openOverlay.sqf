#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_openOverlay

/*
 * This function is spawned each time the map overlay is opened.
 *
 * The function requires a scheduled environment because it uses
 * waitUntil and sleep.
 */

params ["_displayId"];

//---------------------------------------------------------------------------------------------
// Exit conditions
//---------------------------------------------------------------------------------------------

if (!isNull findDisplay _displayId) exitWith {};

if (isNil "A3C_is_Initialized") exitWith {
	hint "ARMA COMMAND IS INITIALIZING - STAND BY";

	waitUntil {
		!isNil "A3C_is_Initialized"
	};

	hint "ARMA COMMAND INITIALIZED";

	sleep 3;

	hint "";
};

if (isDedicated) exitWith {};

if (
	isMultiplayer
	&& {isServer}
	&& {!hasInterface}
) exitWith {};

if (player != leader group player) exitWith {};

/*
 * Prevent opening the overlay while the radial menu is awaiting an
 * action. Otherwise opening the map can consume the corresponding
 * key-up event.
 *
 * This should eventually also be handled by the primary HUD key-down
 * handler so that the map itself cannot open in this state.
 */
if (A3C_DISABLE_RADIAL) exitWith {};

if (
	!isNil "A3C_disableMapPlanning"
	&& {A3C_disableMapPlanning}
) exitWith {};

if (
	!isNil "A3C_restrictMapPlanning"
	&& {A3C_restrictMapPlanning}
	&& {
		{
			[
				"A3C_Terminal",
				_x
			] call BIS_fnc_inString
		} count (
			items player
			+ assignedItems player
		) == 0
	}
) exitWith {};

// Exit if another dialog is open.
if (
	dialog
	&& {_displayId == 12}
) exitWith {};

// Display 12 is only allowed while the map is visible.
if (
	!visibleMap
	&& {_displayId == 12}
) exitWith {};

//---------------------------------------------------------------------------------------------
// Preparation
//---------------------------------------------------------------------------------------------

// Hide the HUD squad-unit bar.
private _modifiedHud = +shownHUD;

_modifiedHud set [
	0,
	true
];

_modifiedHud set [
	6,
	false
];

showHUD _modifiedHud;

// Clear any active HUD unit-selection ghosts.
{
	[
		_x
	] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
} forEach A3C_UI_squadPlacement_units;

{
	_x setMarkerAlphaLocal 0.5;
} forEach A3C_HC_MARKERS;

{
	_x setMarkerAlphaLocal 1;
} forEach A3C_MARKERS;

//---------------------------------------------------------------------------------------------
// Per-open state reset
//---------------------------------------------------------------------------------------------

// Closed selection tree because no units are currently selected.
A3C_UI_MAP_Overlay_VAR_isUnFolded = false;

A3C_TRACKER_MARKERS = [];
A3C_USERACTION = [];

A3C_DIR = 0;
A3C_OBSV = 0;

A3C_TEMP_ACTION = [
	"NONE",
	"NONE"
];

A3C_TEMP_CONDITION = [
	"NONE",
	"NONE"
];

A3C_SELECTED_UNITS = [];

A3C_CMODE_TEMP = 0;
A3C_FORMMODE_TEMP = 0;
A3C_UNIT_01_BV = 0;
A3C_WP_SPEED_TEMP = -1;
A3C_DIAG_SPACING = 4;

A3C_UNITCOUNT =
	count units group player - 1;

A3C_OFFSET_MARKERPOS = [];
A3C_MARKERS_TEMP = [];
A3C_WAYPOINTS_TEMP = [];
A3C_DIED_IN_PLANNING = [];
A3C_TAB_MARKERS = [];
A3C_ORDER_UNITS = [];

A3C_CLICKPOS_1 = [
	0,
	0,
	0
];

A3C_CLICKPOS_2 = [
	0,
	0,
	0
];

A3C_CLICKPOS_ROOT = [
	0,
	0,
	0
];

A3C_LINECOLOR_DIAG = [
	A3C_UI_COLOR_BLUE,
	1
] call A3C_UI_fnc_setOpacity;

A3C_LINECOLOR_MAP = [
	A3C_UI_COLOR_BLUE,
	A3C_OPACITY
] call A3C_UI_fnc_setOpacity;
//~~ Check which of these color variables are no longer needed.

A3C_GROUP_NAMING_ACTIVE = nil;

A3C_EXITLOOP = false;
A3C_BOOL_DISABLEMAPCTRL = false;

A3C_HC_DETONATION_BOOL = false;
A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE = false;

A3C_TEMP_WP_ID_MAIN = "";
A3C_TEMP_WP_ID_SUB = "";

A3C_MAP_X = 0.5;
A3C_MAP_Y = 0.5;

A3C_DIAG_ACTIVE = true;

// Force the diary/briefing interface back to the map page.
processDiaryLink createDiaryLink [
	"Map",
	player,
	""
];

//---------------------------------------------------------------------------------------------
// Create and initialize the overlay
//---------------------------------------------------------------------------------------------

with uiNamespace do {
	A3C_DSP_MapOverlay =
		(findDisplay 46) createDisplay "A3C_DSP_MapOverlay";

	(
		findDisplay 12 displayCtrl 51
	) ctrlMapCursor [
		"Track",
		"Arrow"
	];
};

private _overlayDisplay =
	findDisplay _displayId;

// Hide controls that are not visible in the initial overlay state.
{
	(
		_overlayDisplay displayCtrl _x
	) ctrlShow false;
} forEach [
	IDC_MAP_HCGP_STARTUP_BAR,
	IDC_MAP_HCGP_STARTUP_TEXT,
	IDC_MAP_SQWP_Parent,
	IDC_MAP_HCWP_Parent,
	IDC_MAP_HCGP_Parent,
	IDC_SHARED_UI_SelectionPromptPanel_Parent,
	IDC_MAP_UFSB_Subselection_01_Parent,
	IDC_MAP_UFSB_Subselection_02_Parent,
	IDC_MAP_UFSB_Subselection_01_BG,
	IDC_MAP_UFSB_Subselection_02_BG
];

private _highestUnitPage =
	ceil (
		count A3C_SELECTED_UNITS
		/ A3C_UI_MAP_UNITBUTTONCEIL
	) - 1;

if (_highestUnitPage > A3C_BUTTONPAGE_TABLET) then {
	A3C_BUTTONPAGE_TABLET = 0;
	//~~ No longer needed?
};

// Can take considerable time with many commanded units.
[
	_displayId
] call A3C_UI_MAP_TREE_LABEL;

/*
 * Overlay step 1:
 * Initialize the selector box.
 */
if (
	_displayId == IDD_MAP_OVERLAY
	&& {!visibleMap}
) exitWith {
	_overlayDisplay closeDisplay 0;
};

[
	_displayId,
	"INF"
] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;

sleep 0.1;

/*
 * Overlay step 2:
 * Start with the waypoint-settings sidebar collapsed.
 */
[
	"COLLAPSE",
	0
] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;

sleep 0.1;

/*
 * Overlay steps 3 and 4:
 * Adjust the upper tree controls and initialize the unit-page mode.
 */
if (A3C_SELECTED_UNITS isEqualTo []) then {
	[
		"INF"
	] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
};

[
	0
] call A3C_ui_mapOverlay_fnc_resetMapClick;

// Create the enemy-force tracker.
[] spawn A3C_ui_mapOverlay_fnc_createEnemyForceTracker;

// Disable action-menu scrolling while the overlay is open.
{
	inGameUISetEventHandler [
		_x,
		"true"
	];
} forEach [
	"PrevAction",
	"NextAction"
];

// Synchronize go-code control state on all machines.
[] remoteExec [
	"A3C_UI_Shared_fnc_toggleGocodeCtrls",
	0
];

// Clear stale synchronization relationships for the player's group.
{
	_x setVariable [
		"A3C_SYNC_PARTNERS",
		[],
		true
	];
} forEach units group player;

[
	_displayId
] execFSM "A3C_CORE\FSM\A3C_MON_MAPTAB.fsm";