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

	[
		false
	] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
};