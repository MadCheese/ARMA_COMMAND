// MCSS_fnc_isClickPosInCtrlArea

params ["_clickPos", "_ctrl"];

if (isNull _ctrl) exitWith {
	false
};

if !(ctrlShown _ctrl) exitWith {
	false
};

_clickPos params ["_clickX", "_clickY"];
ctrlPosition _ctrl params ["_ctrlX", "_ctrlY", "_ctrlW", "_ctrlH"];

(
	_clickX >= _ctrlX &&
	{ _clickX <= (_ctrlX + _ctrlW) } &&
	{ _clickY >= _ctrlY } &&
	{ _clickY <= (_ctrlY + _ctrlH) }
)