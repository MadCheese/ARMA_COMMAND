// A3C_ui_mapOverlay_fnc_resetUnitLoopState

params ["_unit"];

private _variableName = "A3C_PLOT_TEMP";
private _alternateVariableName = "A3C_PLOT";

{
	if ((_x select 10) != -1) then {
		_variableName = "A3C_PLOT";
		_alternateVariableName = "A3C_PLOT_TEMP";
	};
} forEach (
	_unit getVariable "A3C_PLOT"
);

private _alternateData =
	_unit getVariable _alternateVariableName;

{
	_x set [10, -1];
} forEach _alternateData;

if (_variableName == "A3C_PLOT_TEMP") then {
	_unit setVariable [
		_alternateVariableName,
		_alternateData,
		true
	];
};

private _data =
	_unit getVariable _variableName;

{
	_x set [10, -1];
} forEach _data;

_unit setVariable [
	_variableName,
	_data,
	true
];

if (A3C_BOOL_DRAGLINE) then {
	A3C_BOOL_DRAGLINE = false;
};