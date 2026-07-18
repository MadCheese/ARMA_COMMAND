#include "..\script_component.hpp"

// A3C_Debug_fnc_visualizeBoundingBox

private _intersections = lineIntersectsSurfaces [
	AGLToASL (
		positionCameraToWorld [0, 0, 0]
	),
	AGLToASL (
		positionCameraToWorld [
			0,
			0,
			viewDistance
		]
	),
	vehicle player,
	objNull,
	true,
	1,
	"GEOM",
	"NONE"
];

if (_intersections isEqualTo []) exitWith {
	-1
};

private _object =
	(_intersections select 0) select 2;

if (isNull _object) exitWith {
	-1
};

private _getBoundingBoxCorners = {
	params [
		["_object", objNull, [objNull]],
		["_boundingBox", [], [[]]]
	];

	_boundingBox params [
		["_minimumBounds", [], [[]]],
		["_maximumBounds", [], [[]]]
	];

	private _xBounds = [
		_minimumBounds select 0,
		_maximumBounds select 0
	];

	private _yBounds = [
		_minimumBounds select 1,
		_maximumBounds select 1
	];

	private _zBounds = [
		_minimumBounds select 2,
		_maximumBounds select 2
	];

	private _corners = [];

	{
		private _y = _x;

		{
			private _z = _x;

			{
				private _xPosition = _x;

				_corners pushBack (
					_object modelToWorld [
						_xPosition,
						_y,
						_z
					]
				);
			} forEach _xBounds;
		} forEach _zBounds;

		reverse _zBounds;
	} forEach _yBounds;

	/*
		Repeat the first two corners because the legacy drawing order
		addresses indices 8 and 9 when closing the final edges.
	*/
	_corners pushBack (
		_corners select 0
	);

	_corners pushBack (
		_corners select 1
	);

	_corners
};

private _boundingBoxCorners = [
	_object,
	boundingBox _object
] call _getBoundingBoxCorners;

private _boundingBoxRealCorners = [
	_object,
	boundingBoxReal _object
] call _getBoundingBoxCorners;

A3C_Debug_boundingBoxDrawData = [
	_boundingBoxCorners,
	_boundingBoxRealCorners
];

if (
	A3C_Debug_boundingBoxDrawHandler
	!= -1
) then {
	removeMissionEventHandler [
		"Draw3D",
		A3C_Debug_boundingBoxDrawHandler
	];

	A3C_Debug_boundingBoxDrawHandler = -1;
};

A3C_Debug_boundingBoxDrawHandler =
	addMissionEventHandler [
		"Draw3D",
		{
			A3C_Debug_boundingBoxDrawData params [
				"_boundingBoxCorners",
				"_boundingBoxRealCorners"
			];

			for "_index" from 0 to 7 step 2 do {
				drawLine3D [
					_boundingBoxCorners
						select _index,
					_boundingBoxCorners
						select (_index + 2),
					[0, 0, 1, 1]
				];

				drawLine3D [
					_boundingBoxRealCorners
						select _index,
					_boundingBoxRealCorners
						select (_index + 2),
					[0, 1, 0, 1]
				];

				drawLine3D [
					_boundingBoxCorners
						select (_index + 2),
					_boundingBoxCorners
						select (_index + 3),
					[0, 0, 1, 1]
				];

				drawLine3D [
					_boundingBoxRealCorners
						select (_index + 2),
					_boundingBoxRealCorners
						select (_index + 3),
					[0, 1, 0, 1]
				];

				drawLine3D [
					_boundingBoxCorners
						select (_index + 3),
					_boundingBoxCorners
						select (_index + 1),
					[0, 0, 1, 1]
				];

				drawLine3D [
					_boundingBoxRealCorners
						select (_index + 3),
					_boundingBoxRealCorners
						select (_index + 1),
					[0, 1, 0, 1]
				];
			};
		}
	];

A3C_Debug_boundingBoxDrawHandler