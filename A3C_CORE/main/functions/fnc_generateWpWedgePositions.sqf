// A3C_main_fnc_generateWpWedgePositions

params [
	"_pos",
	"_refGroups",
	"_amount",
	"_dir",
	"_spacing"
];

private _positions = [
	_pos
];

private _useWedge = true;

if (
	isOnRoad _pos
	&& {!(_refGroups isEqualTo [])}
) then {
	_useWedge = false;

	/*
	 * _refGroups is already supplied in permanent convoy order.
	 * Do not reorder it according to current physical distance.
	 */
	private _orderedRefGroups =
		+_refGroups;

	/*
	 * The first group is the convoy's leading group. Its vehicle or
	 * final existing waypoint establishes the approach reference.
	 */
	private _refGroup =
		_orderedRefGroups select 0;

	private _refWaypoints =
		waypoints _refGroup;

	private _isGroupOnFinalWP =
		currentWaypoint _refGroup
			>= count _refWaypoints;

	private _refPosStart =
		if (
			_isGroupOnFinalWP
			|| {_refWaypoints isEqualTo []}
		) then {
			position vehicle leader _refGroup
		} else {
			private _lastWaypoint =
				_refWaypoints select (
					(count _refWaypoints) - 1
				);

			waypointPosition [
				_refGroup,
				_lastWaypoint select 1
			]
		};

	private _roadPositions = [
		_pos,
		_orderedRefGroups,
		_refPosStart
	] call A3C_main_fnc_generateRoadWpPositions;

	if (_roadPositions isEqualTo []) then {
		_useWedge = true;
	} else {
		_positions =
			_roadPositions;
	};
};

if (_useWedge) then {
	_positions = [
		_pos
	];

	private _currentSpacing =
		_spacing;

	/*
	 * _positions already contains the leading position. Generate
	 * only the remaining _amount - 1 positions.
	 */
	if (_amount > 1) then {
		for "_i" from 0 to (_amount - 2) do {
			private _stepAngle =
				if ((_i % 2) == 0) then {
					(_dir + 180) + 45
				} else {
					(_dir + 180) - 45
				};

			if (
				_i != 0
				&& {(_i % 2) == 0}
			) then {
				_currentSpacing =
					_currentSpacing + _spacing;
			};

			_positions pushBack (
				[
					_pos,
					_currentSpacing,
					_stepAngle
				] call BIS_fnc_relPos
			);
		};
	};
};

_positions