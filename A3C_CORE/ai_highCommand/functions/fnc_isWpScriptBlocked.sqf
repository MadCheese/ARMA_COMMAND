params ["_callerUID","_group"];
!(isClass(configFile/"CfgPatches"/"A3C_OBJECTS")) ||
{
	!([_callerUID,_group] call A3C_HC_findExecutingMachine)
}