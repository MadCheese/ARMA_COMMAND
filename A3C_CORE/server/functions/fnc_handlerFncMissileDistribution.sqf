
// A3C_server_fnc_handlerFncMissileDistribution

//-- EH function for MISSILE-DISTRIBUTION Fired-Eventhandlers
params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

(_unit getVariable ["A3C_Mon_Server_Var",[-1,objNull,""]]) params ["_handle","_target","_ammo"];

waituntil {!alive _projectile};

_unit removeEventhandler ["FIRED",_handle];

A3C_Mon_Server_EH_units = A3C_Mon_Server_EH_units - [_unit];
publicVariable 'A3C_Mon_Server_EH_units';

_unit setVariable [
	"A3C_Mon_Server_Var",
	[-1,objNull,""],
	true
];

_unit enableAI "AUTOTARGET";
