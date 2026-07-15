#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_applyPageMode

// Sets the map overlay squad-bar layout according to the command mode.
params ["_mode"];

private _display = findDisplay IDD_MAP_OVERLAY;

private _timeoutPopup =
	_display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP;

private _waypointConditionImage =
	_display displayCtrl IDC_MAP_UFSB_WPCONDITION_IMG;

private _waypointConditionButton =
	_display displayCtrl IDC_MAP_UFSB_WPCONDITION_BTN;

private _waypointActionImage =
	_display displayCtrl IDC_MAP_UFSB_WPACTION_IMG;

private _waypointActionButton =
	_display displayCtrl IDC_MAP_UFSB_WPACTION_BTN;

{
	_x ctrlShow false;
} forEach (
	["map_ufsb_subSet_parentMacros"] call FUNC(ctrlGroup)
);

private _stanceTravelIcon = "";
private _stanceArrivalIcon =
	"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";

private _stanceArrivalColor = [];
private _showWaypointActionImage = true;

private _pageButtonIcon =
	"A3C_CORE\ui\pictures\icon_menu_page_INF.paa";

private _stanceTravelTooltip = "stance while en route";
private _stanceArrivalTooltip = "set stance upon arrival";
private _pageTooltip = "switch page to AIRCRAFT";

// Reset timeout.
_timeoutPopup ctrlSetText str A3C_TIMEOUT_VAL;

(
	_display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT
) ctrlShow false;

A3C_HELIHEIGHT = 0;

private _showUFSBControls = _mode != "HC";

_waypointActionButton ctrlSetToolTip
	"No Action || Use LMB to open settings or mousewheel to cycle";

switch (_mode) do {
	case "INF": {
		if (typeName A3C_WP_SPEED_TEMP == "STRING") then {
			A3C_WP_SPEED_TEMP = -1;
		};

		_stanceArrivalColor = [1, 1, 1, 0.3];

		if (hcShownBar) then {
			hcShowBar false;
		};

		{
			(_display displayCtrl _x) ctrlShow true;
		} forEach [
			IDC_MAP_UFSB_WPCONDITION_IMG,
			IDC_MAP_UFSB_WPCONDITION_BTN
		];

		if (A3C_MAP_CommandMode == "HC") then {
			_timeoutPopup ctrlShow false;
		};

		if (
			(A3C_TEMP_ACTION select 0) in [
				"LANDING",
				"SLINGLOAD"
			]
		) then {
			A3C_TEMP_ACTION = ["NONE", "NONE"];
		};

		if (
			{
				!isNull objectParent _x
			} count A3C_SELECTED_UNITS > 0
		) then {
			A3C_TEMP_ACTION = ["NONE", "NONE"];
		};

		// Adjust waypoint-action button.
		switch (A3C_TEMP_ACTION select 0) do {
			case "GRENADE": {
				[0] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;
			};

			case "STATIC": {
				[
					A3C_SELECTED_UNITS,
					"PLANNING"
				] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

				private _canDeployStatic = (
					{
						isNull objectParent _x
						&& {backpack _x == ""}
					} count A3C_SELECTED_UNITS >= 2
				);

				private _hasPackedStatic =
					count A3C_STATIC_PACKS > 0;

				if (_canDeployStatic || _hasPackedStatic) then {
					A3C_TEMP_ACTION = ["STATIC", []];

					_waypointActionImage ctrlSetText
						"\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";

					_waypointActionButton ctrlSetToolTip
						"Deploy or Pack Static Weapon || Use LMB to open settings or mousewheel to cycle";
				} else {
					A3C_TEMP_ACTION = ["NONE", "NONE"];

					_waypointActionImage ctrlSetTextColor
						[1, 1, 1, 1];

					_waypointActionImage ctrlSetText
						"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				};
			};

			default {
				A3C_TEMP_ACTION = ["NONE", "NONE"];

				_waypointActionImage ctrlSetTextColor
					[1, 1, 1, 1];

				_waypointActionImage ctrlSetText
					"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			};
		};
	};

	case "AIR": {
		if (typeName A3C_WP_SPEED_TEMP == "STRING") then {
			A3C_WP_SPEED_TEMP = -1;
		};

		A3C_HELIHEIGHT = 25;

		_stanceTravelIcon =
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";

		_stanceArrivalIcon =
			"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

		_stanceArrivalColor = [1, 1, 1, 0.8];
		_showWaypointActionImage = false;

		if (
			(A3C_TEMP_ACTION select 0) in [
				"GRENADE",
				"SUPPRESSION"
			]
		) then {
			A3C_TEMP_ACTION = ["NONE", "NONE"];
		};

		_pageButtonIcon =
			"A3C_CORE\ui\pictures\icon_Menu_page_aircraft.paa";

		_stanceTravelTooltip = "Aircraft flying height";
		_stanceArrivalTooltip = "MOVE";
		_pageTooltip = "switch page to HIGH COMMAND";

		if (hcShownBar) then {
			hcShowBar false;
		};

		{
			(_display displayCtrl _x) ctrlShow true;
		} forEach [
			IDC_MAP_UFSB_WPCONDITION_IMG,
			IDC_MAP_UFSB_WPCONDITION_BTN
		];

		if (A3C_MAP_CommandMode == "HC") then {
			_timeoutPopup ctrlShow false;
		};
	};

	case "HC": {
		if (A3C_UI_MAP_Overlay_VAR_isUnFolded) then {
			[
				"COLLAPSE",
				0.1
			] call A3C_ui_mapOverlay_fnc_UFSB_onToggleBar;
		};

		if (typeName A3C_WP_SPEED_TEMP == "SCALAR") then {
			A3C_WP_SPEED_TEMP = "UNCHANGED";
		};

		_stanceArrivalColor = [1, 1, 1, 0.6];

		_pageButtonIcon =
			"\a3\ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";

		_pageTooltip = "switch page to GROUND TROOPS";

		if (
			{
				typeOf _x in [
					"HighCommand",
					"AdvancedAICommand_Commanders"
				]
			} count synchronizedObjects player > 0
		) then {
			hcShowBar true; //~~ ??? WHY DO WE NEED THAT?!
		};

		_showWaypointActionImage = false;

		onHCGroupSelectionChanged {};

		{
			(_display displayCtrl _x) ctrlShow false;
		} forEach [
			IDC_MAP_UFSB_TIMEOUT_POPUP,
			IDC_MAP_UFSB_WPCONDITION_IMG, //~~ WHY ONLY IMAGE????
			IDC_MAP_UFSB_SPACING
		];

		if (
			(A3C_TEMP_ACTION select 0) in [
				"GRENADE",
				"SUPPRESSION",
				"LANDING"
			]
		) then {
			A3C_TEMP_ACTION = ["NONE", "NONE"];
		};
	};
};

// Show or hide all UFSB controls.
{
	_x ctrlShow _showUFSBControls;
} forEach (
	["map_ufsb_ctrlsAll"] call FUNC(ctrlGroup)
);

if (_mode == "AIR") then {
	{
		(_display displayCtrl _x) ctrlShow false;
	} forEach [
		IDC_MAP_UFSB_WPACTION_IMG,
		IDC_MAP_UFSB_WPACTION_BTN
	];
} else {
	_stanceTravelIcon = switch (A3C_STANCE1_TEMP) do {
		case "AUTO": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa"
		};

		case "UP": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa"
		};

		case "MIDDLE": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa"
		};

		case "DOWN": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
		};
	};

	_stanceArrivalIcon = switch (A3C_STANCE2_TEMP) do {
		case "AUTO": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa"
		};

		case "UP": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa"
		};

		case "MIDDLE": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa"
		};

		case "DOWN": {
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
		};
	};
};

[_mode] call A3C_ui_mapOverlay_fnc_UFSB_refreshControlBar;

A3C_TEMP_CONDITION = ["NONE", "NONE"];

_waypointConditionImage ctrlSetText
	"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";

_waypointConditionButton ctrlSetToolTip
	"WP Condition: NONE (LMB to cycle through options)";

(
	_display displayCtrl IDC_MAP_UFSB_COMBATMODE_IMG
) ctrlSetText "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";

(
	_display displayCtrl IDC_MAP_UFSB_UNDO_IMG
) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_undo.paa";

(
	_display displayCtrl IDC_MAP_UFSB_CANCEL_IMG
) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_cancel.paa";

(
	_display displayCtrl IDC_MAP_UFSB_HOLD_IMG
) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";

(
	_display displayCtrl IDC_MAP_UFSB_CONTINUE_IMG
) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";

(
	_display displayCtrl IDC_MAP_UFSB_STANCE_TRAVEL_IMG
) ctrlSetText _stanceTravelIcon;

(
	_display displayCtrl IDC_MAP_UFSB_STANCE_TRAVEL_BTN
) ctrlSetToolTip _stanceTravelTooltip;

(
	_display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_IMG
) ctrlSetText _stanceArrivalIcon;

(
	_display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_IMG
) ctrlSetTextColor _stanceArrivalColor;

(
	_display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_BTN
) ctrlSetToolTip _stanceArrivalTooltip;

(
	_display displayCtrl IDC_MAP_UFSB_COMBATMODE_IMG
) ctrlSetTextColor [1, 1, 1, 1];

_waypointActionImage ctrlShow _showWaypointActionImage;

(_display displayCtrl 7067) ctrlSetText _pageButtonIcon;
(_display displayCtrl 7068) ctrlSetToolTip _pageTooltip;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_UFSB_TIMEOUT_POPUP,
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
]; // Hide timeout popup and context menus.

(
	_display displayCtrl IDC_MAP_UFSB_UNDO_BTN
) ctrlShow false;

(
	_display displayCtrl IDC_MAP_UFSB_UNDO_IMG
) ctrlSetTextColor [1, 1, 1, 0.2];

(
	_display displayCtrl IDC_MAP_UFSB_WP_SPEED_IMG
) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";

if (count A3C_SELECTED_UNITS > 0) then {
	private _referenceItem = A3C_SELECTED_UNITS select 0;

	private _referenceArray = if (_mode != "HC") then {
		profileNamespace getVariable "A3C_GROUPUNITS"
	} else {
		A3C_HC_allGroupsClient_Current
	};

	// On squad level, buttons exclude the player. One is therefore
	// subtracted from the reference index.
	private _referenceDifference = if (_mode != "HC") then {
		-1
	} else {
		0
	};

	private _referenceIndex = [
		_referenceItem,
		_referenceArray
	] call MCSS_fnc_getArrayIndex;

	A3C_BUTTONPAGE_TABLET = (
		floor (
			(_referenceIndex + _referenceDifference) / 16
		)
	) max 0;
};