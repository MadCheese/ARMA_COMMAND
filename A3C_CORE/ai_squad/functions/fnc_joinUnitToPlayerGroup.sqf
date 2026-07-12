// A3C_ai_squad_fnc_joinUnitToPlayerGroup
// New unit(s) joining the player's group - updates A3C group data.

private _playerGroup = group player;
private _playerUnits = units _playerGroup;

private _unitArray = +(profileNamespace getVariable ["A3C_GROUPUNITS", []]);
private _initArray = [];

_playerGroup setVariable ["TCL_Disabled", true];
_playerGroup setVariable ["asr_ai_exclude", true];

// Remove units no longer in the player's group.
// Keep their array slot as objNull so newly joined units can reuse the slot.
{
	private _storedUnit = _x;

	if !(_storedUnit in _playerUnits) then {
		_unitArray set [_forEachIndex, objNull];

		if (_storedUnit in A3C_UI_squadPlacement_units) then {
			[_storedUnit] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
		};
	};
} forEach _unitArray;

// Add new units to _unitArray.
{
	private _soldier = _x;

	if !(_soldier in _unitArray) then {
		private _freeIndex = _unitArray findIf {
			!alive _x &&
			{ !(_x in _playerUnits) }
		};

		if (_freeIndex == -1) then {
			_unitArray pushBack _soldier;
		} else {
			_unitArray set [_freeIndex, _soldier];
		};

		_initArray pushBackUnique _soldier;
	};
} forEach _playerUnits;

A3C_UNITCOUNTER = count _playerUnits;
profileNamespace setVariable ["A3C_GROUPUNITS", _unitArray];

{
	[_x] call A3C_ai_squad_fnc_initializeUnit;
} forEach _initArray;

[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_ApplyMode;