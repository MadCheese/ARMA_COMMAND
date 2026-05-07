#include "..\script_component.hpp"

params ["_units"];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;

	if (
		!isNull _vehicle
		&& {_unit isEqualTo driver _vehicle}
		&& {!isEngineOn _vehicle}
		&& {((getPosATL _vehicle) # 2) < 5}
	) then {
		[
			[_unit, _vehicle],
			{
				params ["_unit", "_vehicle"];
				_unit action ["engineOn", _vehicle];
			}
		] remoteExecCall ["BIS_fnc_call", _vehicle];
	};
} forEach _units;