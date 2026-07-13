// A3C_ai_highCommand_fnc_reArmRequest
// Very performance-heavy because of A3C_FINDMEDICS; do not call too often.

params ["_group"];

private _units = units _group;

private _hasRearmingUnit = (_units findIf {
	_x getVariable ["A3C_REARMING", false]
}) != -1;

if (_hasRearmingUnit) exitWith {
	false
};

private _medics = [_units] call A3C_FINDMEDICS;

if (_medics isEqualTo []) exitWith {
	true
};

private _needsRearm = (_units findIf {
	private _unit = _x;
	private _primaryWeapon = primaryWeapon _unit;

	_primaryWeapon isEqualTo "" ||
	{
		private _primaryCompatibleMagazines = compatibleMagazines [_primaryWeapon, "this"];
		private _unitPrimaryMagazines = (magazines _unit) + (primaryWeaponMagazine _unit);
		private _primaryMagazineCount = {
			_x in _primaryCompatibleMagazines
		} count _unitPrimaryMagazines;

		_primaryMagazineCount < 2 ||
		{
			private _secondaryWeapon = secondaryWeapon _unit;

			_secondaryWeapon != "" &&
			{
				private _secondaryCompatibleMagazines = compatibleMagazines [_secondaryWeapon, "this"];
				private _unitSecondaryMagazines = (magazines _unit) + (secondaryWeaponMagazine _unit);
				private _secondaryMagazineCount = {
					_x in _secondaryCompatibleMagazines
				} count _unitSecondaryMagazines;

				_secondaryMagazineCount == 0
			}
		}
	}
}) != -1;

_needsRearm