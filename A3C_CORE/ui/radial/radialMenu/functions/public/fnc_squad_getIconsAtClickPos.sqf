// A3C_ui_radialMenu_fnc_squad_getIconsAtClickPos

params ["_clickPos"];

_clickPos params ["_clickPosX", "_clickPosY"];

private _iconsAtPosition = [];
private _resolutionAspectRatio = getResolution select 4;
private _iconYDivisor = 50 / _resolutionAspectRatio;

{
	_x params ["_group", "_sizeArray", "_iconPos"];
	_sizeArray params ["_iconScreenWidth", "_iconScreenHeight"];

	if (count _iconPos > 0) then {
		_iconScreenWidth = _iconScreenWidth / 50;
		_iconScreenHeight = _iconScreenHeight / _iconYDivisor;

		private _clickDifX = abs ((_iconPos select 0) - _clickPosX);
		private _clickDifY = abs ((_iconPos select 1) - _clickPosY);

		if (_clickDifX < _iconScreenWidth && {_clickDifY < _iconScreenHeight}) then {
			_iconsAtPosition pushBackUnique _x;
		};
	};
} forEach A3C_UI_HUDICONS_HC_GROUP;

_iconsAtPosition