#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onActionMouseZ

params ["_mode", "_shift", "_doExecute"];

if (_mode < 0) then {
	_mode = 0;
};

if (_mode > 1) then {
	_mode = 1;
};

if (count A3C_SELECTED_UNITS == 0) exitWith {};

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _waypointActionImage =
	_display displayCtrl IDC_MAP_UFSB_WPACTION_IMG;

private _waypointActionButton =
	_display displayCtrl IDC_MAP_UFSB_WPACTION_BTN;

_waypointActionImage ctrlSetTextColor [1, 1, 1, 1];

private _actions = [
	A3C_SELECTED_UNITS
] call A3C_ui_mapOverlay_fnc_squad_getActionsArray;

if (!_doExecute) exitWith {};

private _index = [
	A3C_TEMP_ACTION select 0,
	_actions
] call MCSS_fnc_getArrayIndex;

if (_mode == 0) then {
	if (_index == ((count _actions) - 1)) then {
		_index = 0;
	} else {
		_index = _index + 1;
	};
} else {
	if (_index == 0) then {
		_index = (count _actions) - 1;
	} else {
		_index = _index - 1;
	};
};

private _selection = if (_index >= 0) then {
	_actions select _index
} else {
	"NONE"
};

switch (_selection) do {
	case "NONE": {
		// Switches to off.
		_waypointActionImage ctrlSetText
			"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

		_waypointActionButton ctrlSetToolTip
			"No Action || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["NONE", "NONE"];
	};

	case "GRENADE": {
		// Switches grenade on.
		A3C_TEMP_ACTION = ["GRENADE", A3C_GREN_MUZZLE];

		[0] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;
	};

	case "SUPPRESSION": {
		// Switches to suppression.
		A3C_TEMP_ACTION = ["SUPPRESSION", ""];

		_waypointActionImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";

		_waypointActionImage ctrlSetTextColor [1, 0, 0, 1];

		_waypointActionButton ctrlSetToolTip
			"Suppress Area || Use LMB to open settings or mousewheel to cycle";
	};

	case "CARGO_IN": {
		// Switches to cargo in.
		_waypointActionImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

		_waypointActionButton ctrlSetToolTip
			"Load Vehicle || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["CARGO_IN", "PICKUP"];
	};

	case "CARGO_OUT": {
		// Switches to cargo out.
		_waypointActionImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

		_waypointActionButton ctrlSetToolTip
			"Unload Vehicle || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["CARGO_OUT", ""];
	};

	case "CTRL_DET": {
		// Switches to controlled detonation.
		_waypointActionImage ctrlSetText
			"\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";

		_waypointActionButton ctrlSetToolTip
			"Plant Explosive (Trigger via Radial) || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = [
			"CTRL_DET",
			[
				objNull,
				""
			]
		];
	};

	case "STATIC": {
		// Switches to static weapon, smart-detected.
		_waypointActionImage ctrlSetText
			"\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";

		_waypointActionButton ctrlSetToolTip
			"Deploy or Pack Static Weapon || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["STATIC", []];
	};
};

_actions