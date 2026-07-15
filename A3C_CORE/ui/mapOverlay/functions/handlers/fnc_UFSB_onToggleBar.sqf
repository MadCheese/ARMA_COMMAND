#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onToggleBar

params ["_mode", "_animTime"];

private _isOpen = _mode == "OPEN";
private _doExit = false;

if (_isOpen) then {
	if (A3C_UI_MAP_Overlay_VAR_isUnFolded) then {
		if (A3C_SELECTED_UNITS isEqualTo []) then {
			A3C_UI_MAP_Overlay_VAR_isUnFolded = false;
		};

		_doExit = true;
	} else {
		A3C_UI_MAP_Overlay_VAR_isUnFolded = true;
	};
} else {
	A3C_UI_MAP_Overlay_VAR_isUnFolded = false;
};

if (_doExit) exitWith {};

private _padding = A3C_MAP_GAMEUI_PADDING_Y / 2;

private _newSettingsBackgroundWidth = if (_isOpen) then {
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_EXPANDED
} else {
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_W_COLLAPSED
};

private _macroWidth = A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W + _padding;
private _xPosition = (
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X
	- _padding
	- _macroWidth
);

// Animate settings buttons.
{
	private _buttonPair = _x;

	{
		private _buttonControl = findDisplay IDD_MAP_OVERLAY displayCtrl _x;
		private _doShow = true;

		if (_isOpen) then {
			_buttonControl ctrlSetPosition [
				_xPosition,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y + A3C_MAP_GAMEUI_PADDING_Y,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_W,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
			];
		} else {
			_doShow = false;

			_buttonControl ctrlSetPosition [
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
				0,
				A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
			];
		};

		_buttonControl ctrlCommit _animTime;

		[_buttonControl, _animTime, _doShow] spawn {
			params ["_buttonControl", "_animTime", "_doShow"];

			sleep _animTime;
			_buttonControl ctrlShow _doShow;
		};
	} forEach _buttonPair;

	sleep 0.0001;
	_xPosition = _xPosition - _macroWidth;
} forEach A3C_UI_MAP_UFSQB_SettingsButtonPairs;

// Animate execute and cancel buttons.
// 11.5 includes the half-button offset to the final CONTINUE button.
_xPosition = (
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X
	- _padding
	- (11.5 * _macroWidth)
);

private _fullButtonWidth = 3 * _macroWidth;

{
	if (_forEachIndex > 0) then {
		_xPosition = _xPosition + (4 * _macroWidth);
	};

	private _buttonControl = _x;

	_buttonControl ctrlSetPosition [
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X,
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
		0,
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
	];

	if (_isOpen) then {
		_buttonControl ctrlSetPosition [
			_xPosition,
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y
				+ (
					(
						A3C_MAP_GAMEUI_PADDING_Y
						+ A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_BUTTON_H
					) * 1.25
				),
			_fullButtonWidth,
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_COMMITBUTTON_H
		];
	};

	_buttonControl ctrlCommit _animTime;

	sleep 0.0001;
} forEach (["map_ufsb_ctrlsBottom"] call FUNC(ctrlGroup));

// Animate the waypoint-settings background frame.
{
	private _settingsControl = findDisplay IDD_MAP_OVERLAY displayCtrl _x;

	_settingsControl ctrlSetPosition [
		A3C_MAP_OVERLAY_GAMEUI_TREEX - _newSettingsBackgroundWidth,
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y,
		_newSettingsBackgroundWidth,
		A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_H
	];

	_settingsControl ctrlCommit _animTime;
} forEach [
	IDC_MAP_INPUT_BLOCKER,
	IDC_MAP_UFSB_BACKGROUND,
	IDC_MAP_UFSB_FRAME
];

if (_mode == "COLLAPSE") then {
	{
		_x ctrlShow false;
	} forEach (
		(["map_ufsb_subSet_parentMacros"] call FUNC(ctrlGroup))
		+ [
			["ufsbTimeoutPopup"] call FUNC(ctrl)
		]
	);
};