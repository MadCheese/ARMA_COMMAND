// A3C_ui_mapOverlay_fnc_drawThiccLine

params ["_ctrl", "_root", "_wPos", "_thickness", "_color"];

private _direction = _root getDir _wPos;
private _leftDirection = _direction - 90;
private _rightDirection = _direction + 90;

private _positions = [
	_root getPos [_thickness, _leftDirection],
	_wPos getPos [_thickness, _leftDirection],
	_wPos getPos [_thickness, _rightDirection],
	_root getPos [_thickness, _rightDirection]
];

_ctrl drawTriangle [
	[
		_positions select 0,
		_positions select 1,
		_positions select 2,
		_positions select 2,
		_positions select 3,
		_positions select 0
	],
	_color,
	"#(rgb,1,1,1)color(1,1,1,1)"
];