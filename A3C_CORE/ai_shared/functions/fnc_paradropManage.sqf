// A3C_ai_shared_fnc_paradropManage

params ["_callerUID","_vehicle"];

private _exit = false;

if (count (getVehicleCargo _vehicle) > 0) then {
	//-- ship is dropping vehicle load
	[_vehicle] spawn A3C_ai_shared_fnc_actionParadropVehicle;
} else {
	//-- ship is dropping personnel load
	[_vehicle] spawn A3C_ai_shared_fnc_actionParadropPersonnel;
};
