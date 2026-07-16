#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_onLbChange

params [
	"_box",
	"_lb",
	"_display"
];

if (A3C_CurSel) exitWith {};

private _immediateAction = [];

switch (_box) do {
	case IDC_MAP_HCGP_LISTBOX_BEHAVIOUR: {
		A3C_Map_HC_groupContext_Behaviour = [
			"Careless",
			"Safe",
			"Aware",
			"Combat",
			"Stealth"
		] select _lb;

		_immediateAction = [
			"setBehaviourStrong",
			A3C_Map_HC_groupContext_Behaviour
		];
	};

	case IDC_MAP_HCGP_LISTBOX_COMBATMODE: {
		A3C_Map_HC_groupContext_CMode = [
			"BLUE",
			"GREEN",
			"WHITE",
			"YELLOW",
			"RED"
		] select _lb;

		_immediateAction = [
			"setCombatMode",
			A3C_Map_HC_groupContext_CMode
		];
	};

	case IDC_MAP_HCGP_LISTBOX_FORMATION: {
		A3C_Map_HC_groupContext_Form = [
			"Column",
			"Stag Column",
			"Wedge",
			"Ech Left",
			"Ech Right",
			"Vee",
			"Line",
			"File",
			"Diamond"
		] select _lb;

		_immediateAction = [
			"setFormation",
			A3C_Map_HC_groupContext_Form
		];
	};

	case IDC_MAP_HCGP_LISTBOX_TEAMCOLOR: {
		A3C_Map_HC_groupContext_Color = [
			"Red",
			"Blue",
			"Green",
			"Black",
			"White"
		] select _lb;
	};
};

// Potential immediate response.
if (
	profileNamespace getVariable [
		"HC_GROUP_RESPONSE",
		false
	]
) then {
	{
		private _group = _x;

		if (_box == IDC_MAP_HCGP_LISTBOX_TEAMCOLOR) then {
			_group setVariable [
				"A3C_HC_GroupColor",
				A3C_Map_HC_groupContext_Color,
				true
			];
		} else {
			[
				_group,
				_immediateAction select 1
			] remoteExec [
				_immediateAction select 0,
				leader _group
			];
		};
	} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;
};