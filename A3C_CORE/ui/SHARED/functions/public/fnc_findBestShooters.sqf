// A3C_ui_shared_fnc_findBestShooters

/*
	Filters a unit array to units that have a viable direct line of fire to
	the supplied ASL position.

	Artillery vehicles are retained without a direct-vision requirement.
*/
params [
	["_units", [], [[]]],
	["_inputPosASL", [0, 0, 0], [[]], 3]
];

private _eligibleUnits = _units select {
	private _unit = _x;
	private _vehicle = objectParent _unit;

	if (isNull _vehicle) then {
		/*
			On-foot units fire from eye position.

			The unit and the remote-fire indicator are ignored by the
			line-intersection test.
		*/
		!lineIntersects [
			eyePos _unit,
			_inputPosASL,
			_unit
		]
	} else {
		/*
			Artillery does not require direct vision. Checking this first
			also avoids an unnecessary lineIntersects call.
		*/
		if (
			(getArtilleryAmmo [_vehicle]) isNotEqualTo []
		) then {
			true
		} else {
			private _vehicleFirePosition = getPosASL _vehicle;

			_vehicleFirePosition set [
				2,
				(_vehicleFirePosition select 2) + 1.8
			];

			!lineIntersects [
				_vehicleFirePosition,
				_inputPosASL,
				_unit,
				_vehicle
			]
		}
	}
};

if (_eligibleUnits isEqualTo []) then {
	systemChat "A3C: No shot on target";
};

_eligibleUnits