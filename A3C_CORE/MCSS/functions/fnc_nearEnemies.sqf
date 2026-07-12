// MCSS_fnc_nearEnemies
// Note: check if needed - appears similar to MCSS_fnc_nearEntities with hostile mode plus LOS filtering.

params ["_unit"];

private _returnMode = if ((count _this) > 1) then {
	_this select 1
} else {
	"ARRAY"
};

private _nearEnemies = [];

{
	private _entitySide = side _x;

	if ((_entitySide getFriend (side player)) < 0.6) then {
		if !([_x, _unit] call MCSS_fnc_lineOfSightSimple) then {
			_nearEnemies pushBack _x;
		};
	};
} forEach ((position _unit) nearEntities [["MAN", "CAR", "SHIP", "TANK", "AIR"], 200]);

if (_returnMode == "COUNT") then {
	_nearEnemies = count _nearEnemies;
};

_nearEnemies