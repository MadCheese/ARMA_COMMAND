#include "..\script_component.hpp"

// A3C_playerEventhandler_fnc_issueEventhandlers

params [["_unit", objNull], ["_oldUnit", objNull]];

if (isNull _unit) exitWith {};
if !(local _unit) exitWith {};

private _currentHandlerUnit = missionNamespace getVariable ["A3C_EVENTHANDLER_UNIT", objNull];

if (_unit isEqualTo _currentHandlerUnit) exitWith {};

if !(isNull _currentHandlerUnit) then {
	if !(isNil "A3C_HandlerID_KilledPlayer") then {
		_currentHandlerUnit removeEventHandler ["KILLED", A3C_HandlerID_KilledPlayer];
		A3C_HandlerID_KilledPlayer = nil;
	};

	if !(isNil "A3C_HandlerID_FiredPlayer") then {
		_currentHandlerUnit removeEventHandler ["FIRED", A3C_HandlerID_FiredPlayer];
		A3C_HandlerID_FiredPlayer = nil;
	};

	if !(isNil "A3C_HandlerID_SlotItemChangedPlayer") then {
		_currentHandlerUnit removeEventHandler ["SlotItemChanged", A3C_HandlerID_SlotItemChangedPlayer];
		A3C_HandlerID_SlotItemChangedPlayer = nil;
	};
};

A3C_EVENTHANDLER_UNIT = _unit;

A3C_HandlerID_KilledPlayer = _unit addEventHandler [
	"KILLED",
	{
		[_this select 0] spawn A3C_playerEventhandler_fnc_killed;
	}
];

A3C_HandlerID_FiredPlayer = _unit addEventHandler [
	"FIRED",
	{
		_this spawn A3C_playerEventhandler_fnc_fired;
	}
];

A3C_HandlerID_SlotItemChangedPlayer = _unit addEventHandler [
	"SlotItemChanged",
	{
		_this spawn A3C_playerEventhandler_fnc_slotItemChanged;
	}
];

//-- ANTISTASI - give tablet to commander
if (
	A3C_IsA3CServer
	&& {"antistasi" in (toLower missionName)}
	&& {player isEqualTo (missionNamespace getVariable ["theBoss", objNull])}
	&& {{"A3C_Terminal" in _x} count ((assignedItems player) + (items player)) == 0}
) then {
	[player] call A3C_main_fnc_issueCommandingTablet;
};