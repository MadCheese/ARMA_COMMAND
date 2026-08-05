#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_onDeleteButton

disableSerialization;

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {};

private _menu =
	_display displayCtrl IDC_MAP_HCWP_Parent;

private _isMultiMode =
	_display getVariable [
		"A3C_HCWP_MULTI_ACTIVE",
		false
	];

if (_isMultiMode) then {
	private _selection = +(
		_display getVariable [
			"A3C_HCWP_MULTI_SELECTION",
			[]
		]
	);

	{
		_x params [
			"_group",
			"_wpIndex"
		];

		while {
			_x in waypoints _group
		} do {
			_x call A3C_ai_highCommand_fnc_removeWaypoint;
		};
	} forEach _selection;

	A3C_Selection_MultiWaypoint = [];

	_display setVariable [
		"A3C_HCWP_MULTI_ACTIVE",
		false
	];

	_display setVariable [
		"A3C_HCWP_MULTI_INITIALIZING",
		false
	];

	_display setVariable [
		"A3C_HCWP_MULTI_SELECTION",
		[]
	];

	_display setVariable [
		"A3C_HCWP_MULTI_GROUPS",
		[]
	];
} else {
	[
		A3C_HC_ACTIVEGROUP,
		A3C_HC_ACTIVE_IND
	] call A3C_ai_highCommand_fnc_removeWaypoint;
};

_menu ctrlShow false;

(findDisplay 12 displayCtrl 51) ctrlEnable true;