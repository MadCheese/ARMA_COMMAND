// A3C_ui_mapOverlay_fnc_drawIconVehicleMacro

params ["_ctrl", "_vehicle", "_size", "_color", "_text"];

private _iconType = getText (
	configFile >> "CfgVehicles" >> typeOf _vehicle >> "Icon"
);
private _iconPos = getPos _vehicle;
private _backgroundAlpha = _color select 3;

_text = if (isNil "_text") then {
	""
} else {
	_text
};

_ctrl drawIcon [
	"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
	[1, 1, 1, _backgroundAlpha],
	_iconPos,
	_size * 1.5,
	_size * 1.5,
	0
];

_ctrl drawIcon [
	_iconType,
	_color,
	_iconPos,
	_size,
	_size,
	0,
	_text
];