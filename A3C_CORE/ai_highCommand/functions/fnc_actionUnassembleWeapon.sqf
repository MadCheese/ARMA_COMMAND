params ["_mode", "_group", ["_wpn", objNull]];

private _groupUnits = units _group;

if (isNull _wpn) then {
	{
		if ((vehicle _x) isKindOf "staticweapon") exitWith {
			_wpn = vehicle _x;
		};
	} forEach _groupUnits;
};

if (isNull _wpn) exitWith {};

if !([_groupUnits, _wpn, true] call A3C_ai_highCommand_fnc_canSelectionPickUpStatic) exitWith {};

private _weaponPos = position _wpn;
private _weaponDir = getDir _wpn;

{
	[[_x], A3C_AIGetOut] remoteExec ["bis_fnc_call", _x];
} forEach crew _wpn;

sleep 3;

[
	_groupUnits,
	["DISASSEMBLE", _wpn],
	_weaponPos,
	_weaponDir
] spawn A3C_ai_shared_fnc_actionStaticWeaponExecute;