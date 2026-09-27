// A3C_ai_shared_fnc_reserveACECSWArtilleryOrder

params [
	["_vehicles", [], [[]]],
	["_targetPos", [], [[]]],
	["_allowedFamilies", [], [[]]],
	["_requestedCount", 0, [0]]
];

if (
	_requestedCount <= 0
	|| {_allowedFamilies isEqualTo []}
) exitWith {
	["", 0, []]
};

if !(
	missionNamespace getVariable [
		"A3C_IsAce3",
		false
	]
) exitWith {
	["", 0, []]
};

_vehicles = (
	_vehicles arrayIntersect _vehicles
) select {
	!isNull _x
	&& {alive _x}
	&& {!isNull gunner _x}
	&& {
		[_x] call A3C_main_fnc_isEffectiveACECSW
	}
};

if (_vehicles isEqualTo []) exitWith {
	["", 0, []]
};

private _availability = [
	_vehicles,
	_targetPos
] call A3C_main_fnc_getACECSWArtilleryAvailability;

_availability = _availability select {
	(_x select 0) in _allowedFamilies
	&& {(_x select 4) > 0}
};

if (_availability isEqualTo []) exitWith {
	["", 0, []]
};

private _counter = (
	missionNamespace getVariable [
		"A3C_ARTY_CSW_ORDER_UID_COUNTER_LOCAL",
		0
	]
) + 1;

missionNamespace setVariable [
	"A3C_ARTY_CSW_ORDER_UID_COUNTER_LOCAL",
	_counter
];

private _orderId = format [
	"A3C_CSW_ARTY_%1_%2",
	clientOwner,
	_counter
];

private _remaining =
	_requestedCount;

private _plannedShots = [];

while {_remaining > 0} do {
	private _assignedThisCycle = false;

	{
		private _vehicle = _x;

		if (_remaining == 0) exitWith {};

		private _selectedFamilyData = [];
		private _selectedPieceData = [];
		private _useLoaded = false;
		private _usedSource = objNull;

		private _vehicleAlreadyQueued = (
			_vehicle getVariable [
				"A3C_ARTY_CSW_ORDERS",
				[]
			]
		) isNotEqualTo [];

		if (!_vehicleAlreadyQueued) then {
			{
				private _familyData = _x;
				private _pieces =
					_familyData select 11;

				private _pieceIndex =
					_pieces findIf {
						(_x select 0)
							isEqualTo _vehicle
						&& {
							(_x select 6)
								isNotEqualTo []
						}
						&& {
							(_x select 4) > 0
						}
					};

				if (_pieceIndex >= 0) exitWith {
					_selectedFamilyData =
						_familyData;

					_selectedPieceData =
						_pieces select _pieceIndex;

					_useLoaded = true;
				};

			} forEach _availability;
		};

		if (_selectedFamilyData isEqualTo []) then {
			{
				private _familyData = _x;
				private _pieces =
					_familyData select 11;

				private _pieceIndex =
					_pieces findIf {
						(_x select 0)
							isEqualTo _vehicle
						&& {
							(_x select 6)
								isNotEqualTo []
						}
					};

				if (_pieceIndex >= 0) then {
					private _sources =
						_familyData select 12;

					private _sourceIndex =
						_sources findIf {
							(_x select 3) > 0
							&& {
								_vehicle in (
									_x select 4
								)
							}
						};

					if (_sourceIndex >= 0) exitWith {
						_selectedFamilyData =
							_familyData;

						_selectedPieceData =
							_pieces select _pieceIndex;

						_usedSource = (
							_sources select
							_sourceIndex
						) select 0;
					};
				};

			} forEach _availability;
		};

		if !(
			_selectedFamilyData
				isEqualTo []
		) then {
			private _carryMag =
				_selectedFamilyData select 0;

			if (_useLoaded) then {
				_selectedPieceData set [
					4,
					(
						_selectedPieceData
							select 4
					) - 1
				];
			} else {
				private _sources =
					_selectedFamilyData select 12;

				private _sourceIndex =
					_sources findIf {
						(_x select 0)
							isEqualTo _usedSource
					};

				if (_sourceIndex >= 0) then {
					private _sourceData =
						_sources select
						_sourceIndex;

					_sourceData set [
						3,
						(
							_sourceData
								select 3
						) - 1
					];
				};
			};

			_plannedShots pushBack [
				_vehicle,
				_carryMag,
				_usedSource
			];

			_remaining =
				_remaining - 1;

			_assignedThisCycle = true;
		};

	} forEach _vehicles;

	if (!_assignedThisCycle) exitWith {};
};

if (_remaining > 0) exitWith {
	["", 0, []]
};


private _orderSummary = [];

{
	_x params [
		"_vehicle",
		"_carryMag",
		"_source"
	];

	private _summaryIndex =
		_orderSummary findIf {
			(_x select 0)
				isEqualTo _vehicle
			&& {
				(_x select 1)
					== _carryMag
			}
		};

	if (_summaryIndex < 0) then {
		_orderSummary pushBack [
			_vehicle,
			_carryMag,
			1,
			[]
		];

		_summaryIndex =
			(count _orderSummary) - 1;
	} else {
		private _summary =
			_orderSummary select
			_summaryIndex;

		_summary set [
			2,
			(_summary select 2) + 1
		];
	};

	if (!isNull _source) then {
		private _summary =
			_orderSummary select
			_summaryIndex;

		private _sourceSummary =
			_summary select 3;

		private _sourceIndex =
			_sourceSummary findIf {
				(_x select 0)
					isEqualTo _source
			};

		if (_sourceIndex < 0) then {
			_sourceSummary pushBack [
				_source,
				1
			];
		} else {
			private _sourceEntry =
				_sourceSummary select
				_sourceIndex;

			_sourceEntry set [
				1,
				(
					_sourceEntry
						select 1
				) + 1
			];
		};
	};

} forEach _plannedShots;


{
	_x params [
		"_vehicle",
		"_carryMag",
		"_source"
	];

	if (isNull _source) then {
		private _reservations =
			_vehicle getVariable [
				"A3C_ARTY_CSW_LOADED_RESERVATIONS",
				[]
			];

		private _reservationIndex =
			_reservations findIf {
				(_x select 0)
					== _orderId
				&& {
					(_x select 1)
						== _carryMag
				}
			};

		if (_reservationIndex < 0) then {
			_reservations pushBack [
				_orderId,
				_carryMag,
				1
			];
		} else {
			private _reservation =
				_reservations select
				_reservationIndex;

			_reservation set [
				2,
				(
					_reservation
						select 2
				) + 1
			];
		};

		_vehicle setVariable [
			"A3C_ARTY_CSW_LOADED_RESERVATIONS",
			_reservations,
			true
		];

	} else {
		private _reservations =
			_source getVariable [
				"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
				[]
			];

		private _reservationIndex =
			_reservations findIf {
				(_x select 0)
					== _orderId
				&& {
					(_x select 1)
						isEqualTo _vehicle
				}
				&& {
					(_x select 2)
						== _carryMag
				}
			};

		if (_reservationIndex < 0) then {
			_reservations pushBack [
				_orderId,
				_vehicle,
				_carryMag,
				1
			];
		} else {
			private _reservation =
				_reservations select
				_reservationIndex;

			_reservation set [
				3,
				(
					_reservation
						select 3
				) + 1
			];
		};

		_source setVariable [
			"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
			_reservations,
			true
		];
	};

} forEach _plannedShots;


{
	_x params [
		"_vehicle",
		"_carryMag",
		"_shellCount",
		"_reservedSources"
	];

	private _orders =
		_vehicle getVariable [
			"A3C_ARTY_CSW_ORDERS",
			[]
		];

	_orders pushBack [
		_orderId,
		+_targetPos,
		_carryMag,
		_shellCount,
		_reservedSources,
		clientOwner
	];

	_vehicle setVariable [
		"A3C_ARTY_CSW_ORDERS",
		_orders,
		true
	];

} forEach _orderSummary;

[
	_orderId,
	_requestedCount,
	_orderSummary
]