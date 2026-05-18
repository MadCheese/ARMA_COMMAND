// A3C_main_fnc_canUnitCarryIFAstatic

params ["_unit"];

private _canCarryStatic = true;
private _secondaryWeapon = secondaryWeapon _unit;

if (_secondaryWeapon != "") then {
	if (A3C_IsIFA) then {
		private _cfgVehicles = configFile >> "CfgVehicles";

		{
			private _parts = _x select 1;
			private _weaponPart = _parts select 0;
			private _tripodPart = getText (_cfgVehicles >> (_parts select 1) >> "LIB_Equipped_Tripod_Name");

			if (_secondaryWeapon in [_weaponPart,_tripodPart]) exitWith {
				_canCarryStatic = false;
			};
		} forEach A3C_IFA_StaticPartPairs;
	};

	if (_canCarryStatic) then {
		//-- no IFA parts found: check for secondary Magazines
		private _launcherMags = getArray (configFile >> "CfgWeapons" >> _secondaryWeapon >> "magazines");

		if ({_x in _launcherMags} count (magazines _unit + secondaryWeaponMagazine _unit) > 0) then {
			//-- unit has launcher with mags - do NOT allow static pickup
			_canCarryStatic = false;
		};
	};
};

_canCarryStatic