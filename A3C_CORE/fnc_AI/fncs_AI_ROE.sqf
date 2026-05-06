#include "..\ui\radial\radialMenu\script_component.hpp"
#include "..\ui\radial\radialMenu\dialog_defines.hpp"


//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------  R U L E S  O F  E N G A G E M E N T     ------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------





//-- Fire at will / Fire only on target
A3C_RadialMenu_ROE = {
	params ["_mode"];

	if (count (groupSelectedUnits player) == 0) exitWith {};

	private _unitNames = "";
	switch (_mode) do {
		case (0) : { //-- target selection: Autonomous
			{
				private _unit = _x;
				_unit setvariable ["A3C_ROE",false,true];
				_unit enableAI "AUTOTARGET";
				_unitNames = _unitNames + ([_unit,1] call MCSS_fnc_NAMESTRING);
			} foreach A3C_RD_UNITS;
			player groupchat _unitNames + " Fire At Will!";
			player groupradio "SentNoTarget"; 
			player groupradio "SentOpenFire";
		};
		case (1) : { //-- target selection: Autonomous
			{
				private _unit = _x;
				_unitNames = _unitNames + ([_unit,1] call MCSS_fnc_NAMESTRING);
				_unit setvariable ["A3C_ROE",true,true];
				[_unit] spawn {
					_unit = _this select 0;
					while {alive _unit} do {
						if !(_unit getvariable "A3C_ROE") exitWith {_unit enableAI "AUTOTARGET"};
						_unit disableAI "AUTOTARGET";
						sleep 5;
					};
				};
			} foreach A3C_RD_UNITS;
			player groupradio "SentHoldFireInCombat";
			player groupradio "SentEngageNoTarget";
			player groupchat _unitNames  + " Hold Fire! (Hold Fire Unless Ordered)";
		};
		case (2) : { //-- Fire on my lead (FOML)
			if (count A3C_fireOnMyLeadUnits > 0) then {
				{
					if !(_x in A3C_fireOnMyLeadUnits) then {
						A3C_fireOnMyLeadUnits set [count A3C_fireOnMyLeadUnits, _x];
					};
					[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			} else {
				{_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING)} foreach A3C_RD_UNITS;
				player groupchat  _unitNames + " Hold Fire! (Fire On My Lead)";
				player groupradio "SentHoldFireInCombat";
				A3C_fireOnMyLeadUnits = (groupSelectedUnits player);
				{
					if (isPlayer _x) then {A3C_fireOnMyLeadUnits = A3C_fireOnMyLeadUnits - [_x]};
				} foreach A3C_fireOnMyLeadUnits;

				{[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual} foreach A3C_fireOnMyLeadUnits;
			};
		};
	};
};


A3C_AI_ROE_releaseFOML = {
	{
		private  _target = assignedTarget _x;
		[_x,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual;
		if (isnull _target) then {
			_x dotarget _target;
		};
	} foreach A3C_fireOnMyLeadUnits;
	A3C_fireOnMyLeadUnits = [];
};


// //-- toggle "AUTOCOMBAT" fsm-ability
A3C_AI_ROE_fnc_toggleAutoCombat = {
    params ["_units"];

    //-- Exclude pilots from re-enabling.
    _units = _units select {
        !(
			_x == driver vehicle _x
			&& {_x in A3C_AutoCombatDisabledUnits}
            && {(typeOf vehicle _x) isKindOf "AIR"}    
        )
    };

    if (_units isEqualTo []) exitWith {["NONE", ""]};

    private _unitNames = "";

    if ({_x in A3C_AutoCombatDisabledUnits} count _units == 0) then {
        {
            private _script = [_x] spawn {
                params ["_unit"];

                _unit doWatch objNull;

                while {alive _unit} do {
                    _unit disableAI "AUTOCOMBAT";
                    sleep 5;
                };
            };

            _x setVariable ["A3C_AutoCombatDisableLoop", _script, true];

            _unitNames = _unitNames + ([_x, 1] call MCSS_fnc_NAMESTRING);
            A3C_AutoCombatDisabledUnits pushBackUnique _x;
        } forEach _units;

        ["DISABLED", _unitNames]
    } else {
        {
            if (_x in A3C_AutoCombatDisabledUnits) then {
                terminate (_x getVariable ["A3C_AutoCombatDisableLoop", scriptNull]);
                _x enableAI "AUTOCOMBAT";

                _unitNames = _unitNames + ([_x, 1] call MCSS_fnc_NAMESTRING);
                A3C_AutoCombatDisabledUnits = A3C_AutoCombatDisabledUnits - [_x];
            };
        } forEach _units;

        ["ENABLED", _unitNames]
    };
};