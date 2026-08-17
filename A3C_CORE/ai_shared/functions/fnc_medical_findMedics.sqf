// A3C_ai_shared_fnc_medical_findMedics

params ["_unitArray"];

// Find active AI medics or units carrying recognized medical supplies.
private _medics = [];

//-- ACE exit
if (A3C_IsAce3) exitWith {
	{
		private _unit = _x;

		private _hasMedicalCapability = (
			[
				"@bandage",
				"@iv",
				"tourniquet",
				"splint",
				"morphine",
				"epinephrine"
			] findIf {
				(
					[_unit, _x]
					call ace_medical_ai_fnc_itemCheck
				) param [0, false]
			}
		) != -1;

		if (
			isNull objectParent _unit
			&& {alive _unit}
			&& {!isPlayer _unit}
			&& {
				!([
					_unit
				] call A3C_ai_shared_fnc_medical_isUnitUnconscious)
			}
			&& {_hasMedicalCapability}
		) then {
			if (
				[_unit]
				call ace_medical_treatment_fnc_isMedic
			) then {
				_medics pushBackUnique _unit;
				_medics = [_unit] + (_medics - [_unit]);
			} else {
				_medics pushBackUnique _unit;
			};
		};
	} forEach _unitArray;

	_medics
};

{
	private _unit = _x;
	private _isMedic = (
		{
			[_x] call A3C_main_fnc_getBaseWeapon == "Medikit"
		} count items _unit
	) > 0;

	if (
		isNull objectParent _unit
		&& {alive _unit}
		&& {!isPlayer _unit}
		&& {!([_unit] call A3C_ai_shared_fnc_medical_isUnitUnconscious)}
		&& {
			(
				{
					private _itemNameLower = toLower _x;

					(
						{
							[_x, _itemNameLower] call MCSS_fnc_isInString
						} count A3C_MEDICAL_itemStrings
					) > 0
				} count items _unit
			) > 0
		}
	) then {
		if (_isMedic) then {
			_medics = [_unit] + _medics;
		} else {
			_medics pushBackUnique _unit;
		};
	};
} forEach _unitArray;

_medics