// MCSS_fnc_getNearSlingLoadObjects

params [
	"_vehicle",
	"_position",
	["_radius", 250]
];

if (isNull _vehicle) exitWith {
	[]
};

nearestObjects [_position, [], _radius] select {
	_x != _vehicle &&
	{ _vehicle canSlingLoad _x }
}