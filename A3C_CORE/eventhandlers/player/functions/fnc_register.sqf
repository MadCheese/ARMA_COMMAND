#include "..\script_component.hpp"

if (!hasInterface) exitWith {};

if (isNil "A3C_PLAYER_UNIT_MONITOR_EH") then {
	A3C_PLAYER_UNIT_MONITOR_EH = [
		"unit",
		{
			_this spawn A3C_playerEventhandler_fnc_unitChanged;
		},
		true
	] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "A3C_PLAYER_GROUP_MONITOR_EH") then {
	A3C_PLAYER_GROUP_MONITOR_EH = [
		"group",
		{
			_this call A3C_playerEventhandler_fnc_groupChanged;
		},
		true
	] call CBA_fnc_addPlayerEventHandler;
};