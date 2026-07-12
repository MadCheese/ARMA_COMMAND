// MCSS_fnc_nearEntities
// Find nearby entities that are friendly or hostile to a reference side.
// Example: [west, 100, "FRIENDLY", position player] call MCSS_fnc_nearEntities;

params ["_reference", "_distance", "_mode"];

private _position = if ((count _this) > 3) then {
	_this select 3
} else {
	position _reference
};

private _referenceSide = if (typeName _reference == "OBJECT") then {
	side _reference
} else {
	_reference
};

private _entityTypes = if ((count _this) > 4) then {
	_this select 4
} else {
	["MAN", "CAR", "SHIP", "TANK", "AIR"]
};

private _nearbyEntities = [];

{
	if (_mode == "FRIENDLY") then {
		if (((side _x) getFriend _referenceSide) >= 0.6) then {
			_nearbyEntities pushBack _x;
		};
	} else {
		if !(side _x == civilian) then {
			if (((side _x) getFriend _referenceSide) < 0.6) then {
				_nearbyEntities pushBack _x;
			};
		};
	};
} forEach (_position nearEntities [_entityTypes, _distance]);

_nearbyEntities