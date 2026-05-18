// A3C_ai_shared_fnc_getWeaponAssemblyMode

//-- used for squad level: find out if units would assemble or disassemble a weapon

params ["_units"];

[_units,"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

private _canDisassemble = ({backpack _x == ""} count _units >= 2); //-- at least 2 units have no backpack for disassembly
private _canAssemble = count A3C_STATIC_PACKS > 0; //-- units have weapons to assemble

switch (true) do {
	case (_canDisassemble && {!_canAssemble}) : {"DISASSEMBLE"};
	case (_canAssemble && {!_canDisassemble}) : {"ASSEMBLE"};
	case (_canDisassemble && {_canAssemble}) : {"DUAL"};
	default {"NONE"};
};