#include "..\script_component.hpp"

params [["_newGroup", grpNull], ["_oldGroup", grpNull]];

if (isNull _newGroup) then {
	private _player = player;

	if (isNull _player) exitWith {};

	_newGroup = group _player;
};

if (isNull _newGroup) exitWith {};

private _groupUnits = units _newGroup;

A3C_PLAYERGROUP = _newGroup;

profileNamespace setVariable ["A3C_GROUPUNITS", _groupUnits];

{
	[_x] call A3C_UNIT_INIT;
} forEach _groupUnits;

{
	_x setVariable ["A3C_FORMATION_INDEX", [_x] call A3C_GETUNITINDEX, true];
} forEach _groupUnits;