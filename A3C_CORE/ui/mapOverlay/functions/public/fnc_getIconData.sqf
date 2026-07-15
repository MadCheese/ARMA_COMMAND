// A3C_ui_mapOverlay_fnc_getIconData

params ["_buildingPosition"];

private _height = _buildingPosition select 2;
private _color = [A3C_UI_COLOR_BLUE, 1] call A3C_UI_fnc_setOpacity;
private _size = 4;
private _textSize = 0.03;

if (_height > 2) then {
	_color = [0, 1, 0, 1];
	_size = 6;
	_textSize = 0.0415;
};

if (_height > 8) then {
	_color = [1, 1, 0, 1];
	_size = 7;
	_textSize = 0.047;
};

[_color, _size, _textSize]