// A3C_main_fnc_getBoardableVehicles
//
// Finds nearby vehicles that can be boarded by the given groups.
//
// A vehicle is considered boardable when:
// - it is alive;
// - it has at least one empty position;
// - and it is either empty or has no alive hostile crew.
//
// Returns:
// [
//	vehicle,
//	[map hitbox width, map hitbox height],
//	cached map position,
//	vehicle icon path
// ]

params [
	["_groups", [], [[]]],
	["_radius", 500, [0]]
];

private _playerSide =
	side player;

private _cfgVehicles =
	configFile >> "CfgVehicles";

private _units = [];

{
	private _group = _x;

	if (!isNull _group) then {
		_units append (
			(units _group) select {
				alive _x
			}
		);
	};
} forEach _groups;

private _vehicleTypes = [
	"Car",
	"Tank",
	"Air",
	"StaticWeapon",
	"Ship"
];

private _vehicles = [];

{
	private _unit = _x;

	{
		_vehicles pushBackUnique _x;
	} forEach (
		_unit nearEntities [
			_vehicleTypes,
			_radius
		]
	);
} forEach _units;

private _isBoardable = {
	params [
		["_vehicle", objNull, [objNull]],
		["_friendlySide", sideUnknown, [sideUnknown]]
	];

	if (!alive _vehicle) exitWith {
		false
	};

	private _hasEmptySeat = {
		_vehicle emptyPositions _x > 0
	} count [
		"driver",
		"gunner",
		"commander",
		"cargo"
	] > 0;

	if (!_hasEmptySeat) exitWith {
		false
	};

	private _aliveCrew = (
		crew _vehicle
	) select {
		alive _x
	};

	if (_aliveCrew isEqualTo []) exitWith {
		true
	};

	private _hasHostileCrew = {
		(side _x) getFriend _friendlySide < 0.6
	} count _aliveCrew > 0;

	!_hasHostileCrew
};

_vehicles = _vehicles select {
	[
		_x,
		_playerSide
	] call _isBoardable
};

_vehicles apply {
	private _vehicle = _x;
	private _vehicleType = typeOf _vehicle;

	[
		_vehicle,
		[25, 25],
		getPos _vehicle,
		getText (
			_cfgVehicles
				>> _vehicleType
				>> "Icon"
		)
	]
}