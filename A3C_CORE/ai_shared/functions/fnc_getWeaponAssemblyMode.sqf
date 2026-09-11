// A3C_ai_shared_fnc_getWeaponAssemblyMode

//-- Used at squad level to determine whether static assembly/disassembly should be checked.

params ["_units"];

[_units, "PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

private _canAssemble = A3C_STATIC_PACKS isNotEqualTo [];

/*
	This is only a target-independent precheck.

	Legacy statics require two workers.
	ACE PRIMARY-slot CSWs can require only one worker when one unit can carry both components, but that worker must at least have
	a free secondary slot for the packed tripod.

	Actual target-specific suitability is checked later through
	A3C_ai_highCommand_fnc_canSelectionPickUpStatic.
*/
private _canDisassemble = (
	count _units >= 2
	|| {
		_units findIf {
			alive _x
			&& {!isPlayer _x}
			&& {secondaryWeapon _x == ""}
		} >= 0
	}
);

switch (true) do {
	case (_canDisassemble && {!_canAssemble}) : {"DISASSEMBLE"};
	case (_canAssemble && {!_canDisassemble}) : {"ASSEMBLE"};
	case (_canDisassemble && {_canAssemble}) : {"DUAL"};
	default {"NONE"};
};