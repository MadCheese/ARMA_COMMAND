// A3C_ui_shared_fnc_getColorArrayWithOpacity

/*
	Returns a copy of a color array with its alpha component replaced.

	The input array is copied so shared color constants such as
	A3C_UI_COLOR_RED are not modified by reference.
*/
params [
	["_colorArray", [1, 1, 1, 1], [[]]],
	["_opacity", 1, [0]]
];

if (count _colorArray < 3) exitWith {
	diag_log format [
		"A3C_ui_shared_fnc_getColorArrayWithOpacity: Invalid color array: %1",
		_colorArray
	];

	[1, 1, 1, _opacity]
};

private _result = +_colorArray;

_result set [
	3,
	_opacity
];

_result