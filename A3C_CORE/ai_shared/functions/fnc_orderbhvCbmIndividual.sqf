// A3C_ai_shared_fnc_orderbhvCbmIndividual

params ["_unit", "_data"];
_data params ["_command", "_value"];

if (isNull _unit) exitWith {};
if (isPlayer _unit) exitWith {};

// Unit-level AI commands should run where the unit is local.
// If this function is already always called on the unit owner, this guard is harmless.
if (!local _unit) exitWith {
	[[_unit, _data], A3C_ai_shared_fnc_orderbhvCbmIndividual] remoteExec ["bis_fnc_call", _unit];
};

switch (_command) do {
	case "COMBATMODE": {
		if (_value in ["YELLOW", "RED"]) then {
			A3C_fireOnMyLeadUnits = A3C_fireOnMyLeadUnits - [_unit];

			if (A3C_fireOnMyLeadUnits isEqualTo []) then {
				A3C_fireOnMyLeadUnits = [];
			};
		};

		_unit setUnitCombatMode _value;
	};

	case "BEHAVIOUR": {
		_unit setCombatBehaviour _value;

		// Security for FIRE ON MY LEAD:
		// Behaviour changes must not accidentally release the unit to fire.
		if (_unit in A3C_fireOnMyLeadUnits) then {
			_unit setUnitCombatMode "BLUE";
		};
	};
};