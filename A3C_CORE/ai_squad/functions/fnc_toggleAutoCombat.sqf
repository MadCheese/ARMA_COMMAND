// A3C_ai_squad_fnc_toggleAutoCombat

params ["_units"];

//-- Exclude pilots from re-enabling.
private _eligibleUnits = _units select {
	!(
		_x == driver vehicle _x
		&& {_x in A3C_AutoCombatDisabledUnits}
		&& {(typeOf vehicle _x) isKindOf "AIR"}
	)
};

if (_eligibleUnits isEqualTo []) exitWith {["NONE", ""]};

private _unitNames = "";

{
	_unitNames = _unitNames + ([_x] call MCSS_fnc_NAMESTRING);
} forEach _eligibleUnits;

private _hasAnyDisabledUnit = {
	_x in A3C_AutoCombatDisabledUnits
} count _eligibleUnits > 0;

if !(_hasAnyDisabledUnit) then {
	{
		private _unit = _x;

		private _script = [_unit] spawn {
			params ["_unit"];

			_unit doWatch objNull;

			while {alive _unit} do {
				_unit disableAI "AUTOCOMBAT";
				sleep 5;
			};
		};

		_unit setVariable ["A3C_AutoCombatDisableLoop", _script, true];
		A3C_AutoCombatDisabledUnits pushBackUnique _unit;
	} forEach _eligibleUnits;

	["DISABLED", _unitNames]
} else {
	{
		private _unit = _x;

		if (_unit in A3C_AutoCombatDisabledUnits) then {
			terminate (_unit getVariable ["A3C_AutoCombatDisableLoop", scriptNull]);

			_unit enableAI "AUTOCOMBAT";

			A3C_AutoCombatDisabledUnits = A3C_AutoCombatDisabledUnits - [_unit];
		};
	} forEach _eligibleUnits;

	["ENABLED", _unitNames]
};