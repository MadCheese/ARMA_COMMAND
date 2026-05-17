
// A3C_ai_shared_fnc_planeDynamicLandingOnHandleDamage


params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];


if (_projectile != "") exitWith {
	private _explosive = getNumber (configfile >> "CfgAmmo" >> _projectile >> "explosive");
	_unit setDamage (damage _unit + _explosive);
};

if ( !(side _source in [civilian,sideUnknown,sideFriendly,sideEmpty]) && { (side _source) getFriend (side _unit) <= 0.6  }) exitWith {
	_unit setDamage (damage _unit + _damage);
};

0
