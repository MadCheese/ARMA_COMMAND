// A3C_ai_highCommand_fnc_getArtilleryCapacity

params ["_group"];

private _return = false;

{
	private _vehicle = objectParent _x;
	if (
		!isNull _vehicle
		&& {_x == gunner _vehicle}
		&& {count (getArtilleryAmmo [_vehicle]) > 0}
	) exitWith {
		_return = true;
	};
} foreach (units _group);

_return
