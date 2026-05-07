#include "..\script_component.hpp"

params ["_units"];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;

	if (
		!isNull _vehicle
		&& {_unit isEqualTo driver _vehicle}
		&& {isEngineOn _vehicle}
		&& {
			_vehicle isKindOf "Ship"
			|| {((getPosATL _vehicle) # 2) < 5}
		}
	) then {
		[_unit, ["engineOff", _vehicle]] remoteExec ["action", _unit];
	};
} forEach _units;