// MCSS_fnc_getUnitNameString
// Get a display name using formation index and unit name parts, or player name when applicable.

private _argCount = count _this;

params ["_unit"];

private _disableComma = if (_argCount > 1) then {
	_this select 1
} else {
	false
};

private _addPlayerBracket = if (_argCount > 2) then {
	_this select 2
} else {
	false
};

if (isNil "_unit" or { isNull _unit }) exitWith {
	"N/A"
};

private _unitName = name _unit;
private _nameParts = [_unitName, "' "] call BIS_fnc_splitString;

private _formationIndex = _unit getVariable "A3C_FORMATION_INDEX";

if (isNil "_formationIndex") exitWith {
	"N/A"
};

private _displayName = "";

if ((count _nameParts) > 1) then {
	{
		if (_forEachIndex > 0) then {
			_displayName = _displayName + _x;
		};
	} forEach _nameParts;
} else {
	_displayName = _nameParts select 0;
};

if (isPlayer _unit) then {
	_displayName = format ["%1: %2", _formationIndex, _unitName];

	if (_addPlayerBracket) then {
		_displayName = _displayName + " (Player)";
	};
} else {
	if (_argCount == 1) then {
		_displayName = (str _formationIndex) + ": " + _displayName;

		if ((getResolution select 5) == 0.7) then {
			if ((count _displayName) >= 11) then {
				_displayName = (_displayName splitString "") select [0, 7];
				_displayName = (_displayName joinString "") + "...";
			};
		};
	} else {
		if !(_disableComma) then {
			_displayName = _displayName + ",";
		};
	};
};

_displayName