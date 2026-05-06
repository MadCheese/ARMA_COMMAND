#include "..\script_component.hpp"

params [["_newUnit", objNull], ["_oldUnit", objNull]];

private _player = player;

if (isNull _player) exitWith {};
if !(alive _player) exitWith {};

// Player is authoritative here. _newUnit is only the CBA event payload.
// Your ZEUS remote-control path handles remote units separately.

// Avoid expensive state rebuilds for duplicate notifications.
if (_player isEqualTo (missionNamespace getVariable ["A3C_CURRENT_PLAYER_UNIT", objNull])) exitWith {};

A3C_CURRENT_PLAYER_UNIT = _player;

[_player, _oldUnit] call A3C_playerEventhandler_fnc_issueEventhandlers;

A3C_ZEUS_UNIT = _player;

private _syncedObjects = synchronizedObjects _player;
private _curatorIndex = _syncedObjects findIf {
	typeOf _x isEqualTo "ModuleCurator_F"
};

if (_curatorIndex > -1) then {
	private _curatorModule = _syncedObjects select _curatorIndex;

	A3C_ZEUS_UNIT = _player;
	publicVariable "A3C_ZEUS_UNIT";
	[_player, _curatorModule] execFSM "A3C_CORE\FSM\A3C_ZEUS.fsm";
};

sleep 0.5;

private _currentPlayer = player;

if !(isNull _currentPlayer) then {
	private _currentGroup = group _currentPlayer;

	if (_currentPlayer isEqualTo leader _currentGroup) then {
		[(units _currentGroup) - [_currentPlayer]] call A3C_GROUP_RESET;
	};
};