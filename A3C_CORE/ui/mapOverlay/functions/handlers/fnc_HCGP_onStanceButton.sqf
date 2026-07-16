#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_onStanceButton

params [
	"_stance",
	"_mode" //~~ #TODO: _mode is always 1
];

A3C_GROUP_STANCE_Selected = _stance;

if (
	profileNamespace getVariable [
		"HC_GROUP_RESPONSE",
		false
	]
) then {
	{
		private _group = _x;

		{
			private _unit = _x;

			[
				_unit,
				_stance
			] remoteExec [
				"setUnitPos",
				_unit
			];
		} forEach units _group;

		_group setVariable [
			"A3C_GROUP_STANCE",
			_stance,
			true
		];
	} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

{
	_x ctrlSetTextColor [1, 1, 1, 0.1];
} forEach (
	[
		"map_hcgp_imgs_Stance"
	] call FUNC(ctrlGroup)
);

private _modeButtonId = switch (_stance) do {
	case "AUTO": {
		IDC_MAP_HCGP_STANCES_AUTO_IMG
	};

	case "UP": {
		IDC_MAP_HCGP_STANCES_STAND_IMG
	};

	case "MIDDLE": {
		IDC_MAP_HCGP_STANCES_CROUCH_IMG
	};

	case "DOWN": {
		IDC_MAP_HCGP_STANCES_PRONE_IMG
	};
};

(
	findDisplay IDD_MAP_OVERLAY
		displayCtrl _modeButtonId
) ctrlSetTextColor [1, 1, 1, 0.7];