// A3C_ai_shared_fnc_setDestination

params ["_unit"];

private _expectedDestination = expectedDestination _unit;
_expectedDestination params ["_destinationPos", "_destinationType"];

private _direction = -1;

if !(["form", toLower _destinationType] call BIS_fnc_inString) then {
	_direction = getDir _unit;
	_expectedDestination = [getPosATL _unit, "LEADER PLANNED", false]; // -- make sure the unit will run back to a previous idle position
};

_expectedDestination pushBack _direction;

_unit setVariable ["A3C_DEST", _expectedDestination, true];

_expectedDestination