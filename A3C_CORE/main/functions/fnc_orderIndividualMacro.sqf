
// A3C_main_fnc_orderIndividualMacro

//-- Assign global group-state to individual units within player's group
//-- Ungroups the unit, assigns state, regroups the unit
//-- can be used to assign individual combatMode and behaviour
//-- Also used by Fire On My Lead - Function


params ["_mode", "_value"];

// Determine the radio message based on mode and value
private _radioMsg = if (_mode == "BEHAVIOUR") then {
	switch (_value) do {
		case "CARELESS": {"SentBehaviourSafe"};
		case "SAFE": {"SentBehaviourSafe"};
		case "STEALTH": {"SentBehaviourStealth"};
		case "AWARE": {"SentBehaviourAware"};
		case "COMBAT": {"SentBehaviourCombat"};
	}
} else {
	switch (_value) do {
		case "BLUE": {"SentHoldFire"};
		case "GREEN": {"SentHoldFire"};
		case "WHITE": {"SentEngageNoTarget"};
		case "YELLOW": {"SentOpenFire"};
		case "RED": {"SentOpenFireInCombat"};
	}
};

// Execute the radio call
player groupradio _radioMsg;

// Execute the function for each unit
{
	[_x, [_mode, _value]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
} foreach A3C_RD_UNITS;
