#include "..\script_component.hpp"

params ["_body"];

private _groupUnits = profileNamespace getVariable ["A3C_GROUPUNITS", []];

if (A3C_UI_squadPlacement_unitGhosts isNotEqualTo []) then {
	{
		[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
	} forEach A3C_UI_squadPlacement_units;
};

A3C_SELECTED_UNITS = [];

[] call A3C_ui_mapOverlay_fnc_UFSB_onCancelButton;

{
	_x setVariable ["A3C_PLOT_TEMP", []];
} forEach _groupUnits;

if !(_body isEqualTo A3C_ZEUS_UNIT) exitWith {
	selectPlayer A3C_ZEUS_UNIT;
};

if !(isNil "A3C_HandlerID_KilledPlayer") then {
	_body removeEventHandler ["KILLED", A3C_HandlerID_KilledPlayer];
	A3C_HandlerID_KilledPlayer = nil;
};

if !(isNil "A3C_HandlerID_FiredPlayer") then {
	_body removeEventHandler ["FIRED", A3C_HandlerID_FiredPlayer];
	A3C_HandlerID_FiredPlayer = nil;
};

if !(isNil "A3C_HandlerID_SlotItemChangedPlayer") then {
	_body removeEventHandler ["SlotItemChanged", A3C_HandlerID_SlotItemChangedPlayer];
	A3C_HandlerID_SlotItemChangedPlayer = nil;
};

if (_body isEqualTo (missionNamespace getVariable ["A3C_EVENTHANDLER_UNIT", objNull])) then {
	A3C_EVENTHANDLER_UNIT = objNull;
};

if (_body isEqualTo (missionNamespace getVariable ["A3C_CURRENT_PLAYER_UNIT", objNull])) then {
	A3C_CURRENT_PLAYER_UNIT = objNull;
};