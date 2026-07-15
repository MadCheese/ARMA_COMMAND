#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_findCtrlSafePos

params [
	"_display",
	"_control",
	"_ctrlPos"
];

private _displayCtrl = findDisplay _display;

private _borders = [
	safeZoneW + safeZoneX,
	safeZoneH + safeZoneY
];

private _dimensions = ctrlPosition (
	_displayCtrl displayCtrl _control
);

if (_control == IDC_MAP_HCWP_Parent) then {
	private _confirmPosition = ctrlPosition (
		_displayCtrl displayCtrl IDC_MAP_HCWP_Confirm_BG
	);

	// Since the base position for the controls group is 0, y + h of
	// the confirm control gives the total effective height.
	private _realHeight =
		(_confirmPosition select 1)
			+ (_confirmPosition select 3);

	_dimensions set [
		3,
		_realHeight
	];
};

private _width = _dimensions select 2;
private _height = _dimensions select 3;

if ((_ctrlPos select 0) + _width > (_borders select 0)) then {
	_ctrlPos set [
		0,
		(_borders select 0) - _width
	];
};

if ((_ctrlPos select 1) + _height > (_borders select 1)) then {
	_ctrlPos set [
		1,
		(_borders select 1) - _height
	];
};

_ctrlPos