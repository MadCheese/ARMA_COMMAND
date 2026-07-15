#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_isCursorOverControl

params ["_controlId"];

private _cursorPosition = [
	A3C_MAP_X,
	A3C_MAP_Y,
	0
];

private _display = findDisplay IDD_MAP_OVERLAY;
private _control = _display displayCtrl _controlId;
private _controlPosition = ctrlPosition _control;

private _height = _controlPosition select 3;
private _width = _controlPosition select 2;

private _controlOrigin = [
	_controlPosition select 0,
	_controlPosition select 1,
	0
];

private _verticalCorner = [
	_controlOrigin,
	_height,
	180
] call BIS_fnc_relPos;

private _horizontalCorner = [
	_controlOrigin,
	_width,
	90
] call BIS_fnc_relPos;

_cursorPosition inPolygon [
	_controlOrigin,
	_verticalCorner,
	_horizontalCorner
]