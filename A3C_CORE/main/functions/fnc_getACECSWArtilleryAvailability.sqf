// A3C_main_fnc_getACECSWArtilleryAvailability

/*
	Returns reservation-aware ACE CSW artillery ammunition availability.

	Physical state comes from:
		A3C_main_fnc_getACECSWArtillerySnapshot

	Reservation variables:

		Vehicle:
			A3C_ARTY_CSW_LOADED_RESERVATIONS

			[
				[orderId, carryMagazine, amount],
				...
			]

		Physical reload source:
			A3C_ARTY_CSW_SOURCE_RESERVATIONS

			[
				[orderId, vehicle, carryMagazine, amount],
				...
			]

		Transit reservations are deliberately not subtracted here.
		Once ACE removes a shell from its physical source, that shell is no
		longer part of the physical snapshot and therefore must not also be
		subtracted as a reservation.

	Return family format:

		[
			carryMagazine,
			displayName,

			physicalTotal,
			reservedTotal,
			availableTotal,

			physicalLoaded,
			reservedLoaded,
			availableLoaded,

			physicalExternal,
			reservedExternal,
			availableExternal,

			pieces,
			sources
		]

	Piece format:

		[
			vehicle,
			turretPath,
			physicalLoaded,
			reservedLoaded,
			availableLoaded,
			compatibleVehicleMagazines,
			inRangeVehicleMagazines
		]

	Source format:

		[
			source,
			physicalAmmo,
			reservedAmmo,
			availableAmmo,
			vehiclesThatCanUseSource
		]
*/

params [
	["_vehicles", [], [[]]],
	["_targetPos", [], [[]]]
];

private _snapshot = [
	_vehicles,
	_targetPos
] call A3C_main_fnc_getACECSWArtillerySnapshot;

private _return = [];

{
	_x params [
		"_carryMag",
		"_displayName",
		"_physicalLoaded",
		"_physicalExternal",
		"_physicalTotal",
		"_pieces",
		"_sources"
	];

	private _reservedLoaded = 0;
	private _availableLoaded = 0;
	private _pieceAvailability = [];

	{
		_x params [
			"_vehicle",
			"_turretPath",
			"_piecePhysicalLoaded",
			"_vehicleMags",
			"_inRangeVehicleMags"
		];

		private _pieceReservedLoaded = 0;

		{
			if (
				_x isEqualType []
				&& {count _x >= 3}
			) then {
				_x params [
					"_orderId",
					"_reservationFamily",
					"_reservationAmount"
				];

				if (
					_reservationFamily == _carryMag
					&& {_reservationAmount isEqualType 0}
					&& {_reservationAmount > 0}
				) then {
					_pieceReservedLoaded =
						_pieceReservedLoaded
						+ _reservationAmount;
				};
			};
		} forEach (
			_vehicle getVariable [
				"A3C_ARTY_CSW_LOADED_RESERVATIONS",
				[]
			]
		);

		private _pieceAvailableLoaded = (
			_piecePhysicalLoaded
			- _pieceReservedLoaded
		) max 0;

		_reservedLoaded =
			_reservedLoaded
			+ _pieceReservedLoaded;

		_availableLoaded =
			_availableLoaded
			+ _pieceAvailableLoaded;

		_pieceAvailability pushBack [
			_vehicle,
			_turretPath,
			_piecePhysicalLoaded,
			_pieceReservedLoaded,
			_pieceAvailableLoaded,
			+_vehicleMags,
			+_inRangeVehicleMags
		];

	} forEach _pieces;


	private _reservedExternal = 0;
	private _availableExternal = 0;
	private _sourceAvailability = [];

	{
		_x params [
			"_source",
			"_sourcePhysicalAmmo",
			"_sourceUsers"
		];

		private _sourceReservedAmmo = 0;

		{
			if (
				_x isEqualType []
				&& {count _x >= 4}
			) then {
				_x params [
					"_orderId",
					"_reservationVehicle",
					"_reservationFamily",
					"_reservationAmount"
				];

				if (
					_reservationFamily == _carryMag
					&& {_reservationAmount isEqualType 0}
					&& {_reservationAmount > 0}
				) then {
					_sourceReservedAmmo =
						_sourceReservedAmmo
						+ _reservationAmount;
				};
			};
		} forEach (
			_source getVariable [
				"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
				[]
			]
		);

		private _sourceAvailableAmmo = (
			_sourcePhysicalAmmo
			- _sourceReservedAmmo
		) max 0;

		_reservedExternal =
			_reservedExternal
			+ _sourceReservedAmmo;

		_availableExternal =
			_availableExternal
			+ _sourceAvailableAmmo;

		_sourceAvailability pushBack [
			_source,
			_sourcePhysicalAmmo,
			_sourceReservedAmmo,
			_sourceAvailableAmmo,
			+_sourceUsers
		];

	} forEach _sources;


	private _reservedTotal =
		_reservedLoaded
		+ _reservedExternal;

	private _availableTotal =
		_availableLoaded
		+ _availableExternal;

	_return pushBack [
		_carryMag,
		_displayName,

		_physicalTotal,
		_reservedTotal,
		_availableTotal,

		_physicalLoaded,
		_reservedLoaded,
		_availableLoaded,

		_physicalExternal,
		_reservedExternal,
		_availableExternal,

		_pieceAvailability,
		_sourceAvailability
	];

} forEach _snapshot;

_return