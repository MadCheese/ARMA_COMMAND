// A3C_main_fnc_buildConvoyVehicleOrder

/*
 * Creates a permanent vehicle-level convoy order from an already
 * ordered group array.
 *
 * Group order is never changed. Inside each group, the vehicle that
 * contains the group leader is placed first, provided its driver
 * belongs to the group. Remaining driven vehicles retain the order
 * of their drivers in units _group.
 *
 * The returned order is a snapshot. It must not be rebuilt merely
 * because vehicles later change position, driver or operational
 * state.
 *
 * Returns:
 *
 * [
 *     [_vehicle, _owningGroup],
 *     ...
 * ]
 */

params [
	["_orderedGroups", [], [[]]]
];

private _orderedVehicleEntries = [];
private _registeredVehicles = [];

{
	private _group =
		_x;

	if (
		_group isEqualType grpNull
		&& {!isNull _group}
	) then {
		private _groupUnits =
			units _group;

		private _groupVehicles = [];

		private _groupLeader =
			leader _group;

		private _leaderVehicle =
			vehicle _groupLeader;

		/*
		 * A leader may occupy a commander or cargo position. The
		 * vehicle still leads this group as long as its driver belongs
		 * to the same group.
		 */
		if (
			!isNull _groupLeader
			&& {!isNull objectParent _groupLeader}
			&& {
				driver _leaderVehicle
					in _groupUnits
			}
		) then {
			_groupVehicles pushBack
				_leaderVehicle;
		};

		/*
		 * units _group is the stable logical squad/formation order.
		 * Only drivers introduce vehicles into the convoy order.
		 */
		{
			private _unit =
				_x;

			private _vehicle =
				objectParent _unit;

			if (
				!isNull _vehicle
				&& {
					_unit
						isEqualTo driver _vehicle
				}
			) then {
				_groupVehicles pushBackUnique
					_vehicle;
			};
		} forEach _groupUnits;

		{
			private _vehicle =
				_x;

			if !(
				_vehicle
					in _registeredVehicles
			) then {
				_registeredVehicles pushBack
					_vehicle;

				_orderedVehicleEntries pushBack [
					_vehicle,
					_group
				];
			};
		} forEach _groupVehicles;
	};
} forEach _orderedGroups;

_orderedVehicleEntries
