// A3C_ai_squad_fnc_setROE

//-- Fire at will / Fire only on target / Fire On My Lead (FOML)

params ["_mode"];

private _selectedUnits = groupSelectedUnits player;

if (count _selectedUnits == 0) exitWith {};

private _roeUnits = A3C_RD_UNITS;
private _unitNames = "";

{
	_unitNames = _unitNames + ([_x] call MCSS_fnc_NAMESTRING);
} forEach _roeUnits;

switch (_mode) do {
	case 0: { //-- target selection: Autonomous
		{
			_x setVariable ["A3C_ROE",false,true];
			_x enableAI "AUTOTARGET";
		} forEach _roeUnits;

		player groupChat (_unitNames + " Fire At Will!");
		player groupRadio "SentNoTarget";
		player groupRadio "SentOpenFire";
	};

	case 1: { //-- target selection: Autonomous
		{
			private _unit = _x;

			_unit setVariable ["A3C_ROE",true,true];

			[_unit] spawn {
				params ["_unit"];

				while {alive _unit} do {
					if !(_unit getVariable ["A3C_ROE",false]) exitWith {
						_unit enableAI "AUTOTARGET";
					};

					_unit disableAI "AUTOTARGET";

					sleep 5;
				};
			};
		} forEach _roeUnits;

		player groupRadio "SentHoldFireInCombat";
		player groupRadio "SentEngageNoTarget";
		player groupChat (_unitNames + " Hold Fire! (Hold Fire Unless Ordered)");
	};

	case 2: { //-- Fire on my lead (FOML)
		if (count A3C_fireOnMyLeadUnits > 0) then {
			{
				private _unit = _x;

				if !(_unit in A3C_fireOnMyLeadUnits) then {
					A3C_fireOnMyLeadUnits pushBack _unit;
				};

				[_unit,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
			} forEach _roeUnits;
		} else {
			player groupChat (_unitNames + " Hold Fire! (Fire On My Lead)");
			player groupRadio "SentHoldFireInCombat";

			A3C_fireOnMyLeadUnits = _selectedUnits select {
				!isPlayer _x
			};

			{
				[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
			} forEach A3C_fireOnMyLeadUnits;
		};
	};
};