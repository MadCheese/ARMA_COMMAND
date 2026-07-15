#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_spawnTimeoutCtBox

params ["_mode"];

private _display = findDisplay IDD_MAP_OVERLAY;
private _timeoutBox = _display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP;

if (_mode == "OPEN") then {
	private _conditionImage =
		_display displayCtrl IDC_MAP_UFSB_WPCONDITION_IMG;

	private _conditionImagePosition = ctrlPosition _conditionImage;

	_timeoutBox ctrlSetPosition [
		_conditionImagePosition select 0,
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y
			- A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H,
		A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W,
		A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
	];

	_timeoutBox ctrlCommit 0;
	_timeoutBox ctrlShow true;
} else {
	_timeoutBox ctrlShow false;
};