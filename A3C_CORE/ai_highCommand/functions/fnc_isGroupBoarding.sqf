// A3C_ai_highCommand_fnc_isGroupBoarding

params [
	["_group", grpNull, [grpNull]]
];

if (isNull _group) exitWith {
	false
};

if (isPlayer leader _group) exitWith {
	false
};

_group getVariable ["A3C_isBoarding", false]