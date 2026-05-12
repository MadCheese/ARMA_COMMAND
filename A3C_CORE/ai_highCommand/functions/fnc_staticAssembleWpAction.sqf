params [
	["_leader", objNull],
	["_weaponClass", ""]
];

if (isNull _leader) exitWith {};

private _group = group _leader;

private _weaponData = [units _leader, "PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;
private _polygonData = +(_group getVariable ["A3C_UNIT_POLYS", []]);
private _dir = 0;

{
	private _poly = _x;
	private _polyID = (_poly select 0) select 1;

	if (["ASS", _polyID] call BIS_fnc_inString) then {
		_dir = [_leader, (_poly select 0) select 0] call BIS_fnc_dirTo;
		_polygonData = _polygonData - [_poly];
	};
} forEach _polygonData;

private _selectedWeaponData = [];

if (_weaponClass != "") then {
	private _idx = _weaponData findIf {
		(toLower (_x param [1, ""])) == _weaponClass
	};

	if (_idx > -1) then {
		_selectedWeaponData = _weaponData select _idx;
	};
} else {
	if !(_weaponData isEqualTo []) then {
		_selectedWeaponData = _weaponData select 0;
	};
};

if !(_selectedWeaponData isEqualTo []) then {
	private _assemblyUnits = _selectedWeaponData select 0;
	private _selectedWeaponClass = _selectedWeaponData select 1;

	[
		_assemblyUnits,
		["ASSEMBLE", _selectedWeaponClass],
		position _leader,
		_dir
	] spawn A3C_ai_shared_fnc_actionStaticWeaponExecute;
};

_group setVariable ["A3C_UNIT_POLYS", _polygonData, true];
