// A3C_ui_mapOverlay_fnc_adjustPolygonMain

// Moves (0), resizes (1), or rotates (2) a polygon.

params [
	"_unit",
	"_polygonId",
	"_workingPosition",
	"_mode", // 0: Normal | 1: CTRL | 2: ALT
	["_rotation", 0]
];

private _polygons = _unit getVariable ["A3C_UNIT_POLYS", []];

// When rotating, reset the working position to the polygon center and
// determine the new rotation from the center-to-mouse direction.
if (_mode == 2) then {
	{
		private _polygonMetadata = _x select 0;

		if (_polygonId == (_polygonMetadata select 1)) exitWith {
			private _centerPosition = _polygonMetadata select 0;

			_rotation = [
				_centerPosition,
				_workingPosition
			] call BIS_fnc_dirTo;

			// Keep the polygon center in place while rotating.
			_workingPosition = _centerPosition;
		};
	} forEach A3C_ALL_POLYS;
};

// Remove malformed top-level entries.
{
	if !(_x isEqualType []) then {
		_polygons = _polygons - [_x];
	};
} forEach _polygons;

{
	private _polygon = _x;
	private _polygonMetadata = _polygon select 0;
	private _centerPosition = _polygonMetadata select 0;

	private _storedDirection = if (count _polygon > 3) then {
		_polygon select 3
	} else {
		0
	};

	if (_polygonId in _polygonMetadata) then {
		// Fetch polygon features.
		private _cornerPositions = _polygon select 1;
		private _waypointMarkers = _polygon select 2;

		private _rotationDelta = if (_mode == 2) then {
			_rotation - _storedDirection
		} else {
			0
		};

		private _corner1 = [
			_cornerPositions select 0,
			_centerPosition distance2D (_cornerPositions select 0),
			(
				[
					_centerPosition,
					_cornerPositions select 0
				] call BIS_fnc_dirTo
			) + _rotationDelta
		];

		private _corner2 = [
			_cornerPositions select 1,
			_centerPosition distance2D (_cornerPositions select 1),
			(
				[
					_centerPosition,
					_cornerPositions select 1
				] call BIS_fnc_dirTo
			) + _rotationDelta
		];

		private _corner3 = [
			_cornerPositions select 2,
			_centerPosition distance2D (_cornerPositions select 2),
			(
				[
					_centerPosition,
					_cornerPositions select 2
				] call BIS_fnc_dirTo
			) + _rotationDelta
		];

		private _corner4 = [
			_cornerPositions select 3,
			_centerPosition distance2D (_cornerPositions select 3),
			(
				[
					_centerPosition,
					_cornerPositions select 3
				] call BIS_fnc_dirTo
			) + _rotationDelta
		];

		switch (_mode) do {
			case 0: {
				_corner1 = [
					_workingPosition,
					_corner1 select 1,
					_corner1 select 2
				] call BIS_fnc_relPos;

				_corner2 = [
					_workingPosition,
					_corner2 select 1,
					_corner2 select 2
				] call BIS_fnc_relPos;

				_corner3 = [
					_workingPosition,
					_corner3 select 1,
					_corner3 select 2
				] call BIS_fnc_relPos;

				_corner4 = [
					_workingPosition,
					_corner4 select 1,
					_corner4 select 2
				] call BIS_fnc_relPos;

				_polygonMetadata set [0, _workingPosition];
			};

			case 1: {
				private _referenceDistance =
					_workingPosition distance2D _centerPosition;

				if (_referenceDistance > 5) then {
					// Above the 5 m center-distance threshold, resize the polygon.
					private _referenceFactor1 =
						_referenceDistance / (_corner1 select 1);

					private _referenceFactor2 =
						_referenceDistance / (_corner2 select 1);

					private _referenceFactor3 =
						_referenceDistance / (_corner3 select 1);

					private _referenceFactor4 =
						_referenceDistance / (_corner4 select 1);

					_corner1 = [
						_centerPosition,
						(_corner1 select 1) * _referenceFactor1,
						_corner1 select 2
					] call BIS_fnc_relPos;

					_corner2 = [
						_centerPosition,
						(_corner2 select 1) * _referenceFactor2,
						_corner2 select 2
					] call BIS_fnc_relPos;

					_corner3 = [
						_centerPosition,
						(_corner3 select 1) * _referenceFactor3,
						_corner3 select 2
					] call BIS_fnc_relPos;

					_corner4 = [
						_centerPosition,
						(_corner4 select 1) * _referenceFactor4,
						_corner4 select 2
					] call BIS_fnc_relPos;
				} else {
					// Below the threshold, recreate the unchanged polygon.
					_corner1 = [
						_centerPosition,
						_corner1 select 1,
						_corner1 select 2
					] call BIS_fnc_relPos;

					_corner2 = [
						_centerPosition,
						_corner2 select 1,
						_corner2 select 2
					] call BIS_fnc_relPos;

					_corner3 = [
						_centerPosition,
						_corner3 select 1,
						_corner3 select 2
					] call BIS_fnc_relPos;

					_corner4 = [
						_centerPosition,
						_corner4 select 1,
						_corner4 select 2
					] call BIS_fnc_relPos;
				};
			};

			case 2: {
				// Recreate the polygon around its existing center and store
				// the new polygon direction.
				_corner1 = [
					_workingPosition,
					_corner1 select 1,
					_corner1 select 2
				] call BIS_fnc_relPos;

				_corner2 = [
					_workingPosition,
					_corner2 select 1,
					_corner2 select 2
				] call BIS_fnc_relPos;

				_corner3 = [
					_workingPosition,
					_corner3 select 1,
					_corner3 select 2
				] call BIS_fnc_relPos;

				_corner4 = [
					_workingPosition,
					_corner4 select 1,
					_corner4 select 2
				] call BIS_fnc_relPos;

				_polygonMetadata set [0, _workingPosition];
				_polygon set [3, _rotation];
			};
		};

		// Replace the polygon corner-position array.
		_polygon set [
			1,
			[
				_corner1,
				_corner2,
				_corner3,
				_corner4
			]
		];
	};
} forEach _polygons;

// Override the unit's polygon variable and broadcast the updated value.
_unit setVariable ["A3C_UNIT_POLYS", _polygons, true];