// A3C_main_fnc_isVehicleDamaged

params ["_callerSide", "_entity"];

if (isNull _entity) exitWith {
	false
};

if !((side _entity) in [_callerSide, civilian]) exitWith {
	false
};

if ([_entity] call MCSS_fnc_isObjectFlipped) exitWith {
	true
};

if ((speed _entity) >= 1) exitWith {
	false
};

private _hitPointData = getAllHitPointsDamage _entity;

if (_hitPointData isEqualTo []) exitWith {
	false
};

private _hitPointDamageValues = _hitPointData select 2;

(_hitPointDamageValues findIf {
	_x > 0.15
}) >= 0