#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown

params [
	"_data",
	"_mode",
	"_buttonArray"
];

_buttonArray params [
	"_buttonImage",
	"_buttonClicker"
];

private _functionArray = call compile format [
	"A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown_FNC_%1",
	_mode
];

[
	_data,
	_buttonArray,
	_functionArray select 0
] spawn (
	_functionArray select 1
);

[] spawn {
	sleep 0.1;

	private _mapDisplay = findDisplay IDD_MAP_OVERLAY;

	if (!isNull _mapDisplay) then {
		private _actionParent = _mapDisplay displayCtrl IDC_MAP_HCGP_Parent;

		if (!isNull _actionParent && {ctrlShown _actionParent}) then {
			[false] call A3C_ui_shared_fnc_highCommand_actionsLabel;
		};
	};
};