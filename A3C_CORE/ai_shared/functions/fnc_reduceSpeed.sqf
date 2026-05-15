// A3C_ai_shared_fnc_reduceSpeed

// -- Reduce speed of driving vehicle.
// -- Used to slow down helicopters before landing to avoid the typical pull-up.

// -- #NOTE / #TODO:
// -- Legacy function. Should eventually be replaced with either the shared heli mechanic or another dedicated approach.

params ["_unit", "_maxSpeed"];

private _vehicle = vehicle _unit;
private _decelerationStep = 0.1;

while {speed _vehicle > _maxSpeed} do {
	private _velocity = velocity _vehicle;
	private _direction = direction _vehicle;

	private _newVelocity = [
		(_velocity select 0) - (sin _direction * _decelerationStep),
		(_velocity select 1) - (cos _direction * _decelerationStep),
		_velocity select 2
	];

	[_vehicle, _newVelocity] remoteExec ["setVelocity", _vehicle];

	sleep 0.01;
};

{
	[_x, _maxSpeed] remoteExec ["limitSpeed", _x];
} forEach [_unit, _vehicle];

_unit setVariable ["A3C_REDUCE_SPEED", true, true]; //-- note: this variable also seems weird.