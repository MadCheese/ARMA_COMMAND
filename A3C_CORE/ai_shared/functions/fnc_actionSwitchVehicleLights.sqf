// A3C_ai_shared_fnc_actionSwitchVehicleLights

params ["_vehicle","_mode"];

private _hitpointNames = (getAllHitPointsDamage _vehicle) select 0;
private _lightHitPoints = _hitpointNames select {"light" in toLower _x};



private _remoteFnc = {
	params ["_vehicle","_lightHitPoints","_mode"];

	_vehicle setVariable [
		"A3C_VehicleLights",
		if (_mode == 1) then {1} else {nil},
		true
	];

	sleep (random 2); //-- random delay to make reaction look more human
	
	{
		private _selectionName = _x;
		_vehicle sethitPointDamage [_selectionName, _mode];
	} foreach _lightHitPoints;	
};

[
	[_vehicle,_lightHitPoints,_mode],
	_remoteFnc
] remoteExec ["bis_fnc_spawn",_vehicle];

