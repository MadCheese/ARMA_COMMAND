// A3C_ai_squad_fnc_releaseFOML

{
	private  _target = assignedTarget _x;
	[_x,["COMBATMODE","YELLOW"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
	if (isnull _target) then {
		_x dotarget _target;
	};
} foreach A3C_fireOnMyLeadUnits;

A3C_fireOnMyLeadUnits = [];
