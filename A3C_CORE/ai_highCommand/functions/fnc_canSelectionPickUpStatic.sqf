// A3C_ai_highCommand_fnc_canSelectionPickUpStatic

//-- #TODO: Clarify if this conflicts with another fnc we have to choose units for disassembly (based on backpack score)

params ["_units","_weapon","_distanceRelevant"];

private _canPickUpStatic = false;

private _cfgVehicles = configFile >> "CfgVehicles";
private _cfgWeapons = configFile >> "CfgWeapons";

private _weaponType = typeOf _weapon;

private _vehicleParts = getArray (_cfgVehicles >> _weaponType >> "assembleInfo" >> "dissasembleTo"); //-- equals [] when nothing is found

//-- units in vehicles can not disassemble things. EXCEPT the vehicle is the static weapon itself
private _availableUnits = _units select {
	isNull objectParent _x || {vehicle _x == _weapon}
};

//-- check for IFA parts
if (count _vehicleParts == 0) then {
	_vehicleParts = getArray (_cfgVehicles >> _weaponType >> "assembleInfo" >> "LIB_dissasembleTo");

	if (count _vehicleParts > 0) then {
		_vehicleParts set [1,getText (_cfgVehicles >> (_vehicleParts select 1) >> "LIB_Equipped_Tripod_Name")];
	};
};

if (count _vehicleParts == 0) exitWith {_canPickUpStatic};

private _assignedUnits = [];
private _exitAll = false;

{
	private _part = _x;
	private _exitSub = false;

	if (_exitAll) exitWith {};

	{
		private _unit = _x;

		if (!_distanceRelevant || {_unit distance _weapon <= 30}) then {
			switch (true) do {
				case (_part isKindOf ["Rifle", _cfgWeapons]) : {
					if !(_unit in _assignedUnits) then {
						_assignedUnits pushBack _unit;
						_exitSub = true;

						//-- trick: unit has no secondary, so we can just exit and use him twice
						if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) then {
							_assignedUnits pushBack _unit;
							_exitAll = true;
						};
					};
				};

				case (_part isKindOf ["Launcher", _cfgWeapons]) : {
					if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) then {
						if !(_unit in _assignedUnits) then {
							_assignedUnits pushBack _unit;
							_exitSub = true;
						};
					};
				};

				default {
					if !(_unit in _assignedUnits) then {
						_assignedUnits pushBack _unit;
						_exitSub = true;
					};
				};
			};
		};

		if (count _assignedUnits == 2) exitWith { //-- capable units have been found - exit!
			_exitAll = true;
			_canPickUpStatic = true;
		};

		if (_exitSub) exitWith {}; //-- stop searching for units to carry this part
	} forEach _availableUnits;
} forEach _vehicleParts;

_canPickUpStatic