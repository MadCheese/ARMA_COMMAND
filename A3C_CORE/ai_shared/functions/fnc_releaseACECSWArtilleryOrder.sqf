// A3C_ai_shared_fnc_releaseACECSWArtilleryOrder

params [
	["_vehicle", objNull, [objNull]],
	["_orderId", "", [""]],
	["_carryMag", "", [""]]
];

if (
	isNull _vehicle
	|| {_orderId == ""}
) exitWith {
	false
};

private _orders =
	_vehicle getVariable [
		"A3C_ARTY_CSW_ORDERS",
		[]
	];

private _matchingOrders =
	_orders select {
		(_x select 0) == _orderId
		&& {
			_carryMag == ""
			|| {
				(_x select 2)
					== _carryMag
			}
		}
	};

private _sources = [];

{
	private _reservedSources =
		_x param [
			4,
			[]
		];

	{
		private _source =
			_x param [
				0,
				objNull
			];

		if (!isNull _source) then {
			_sources pushBackUnique
				_source;
		};

	} forEach _reservedSources;

} forEach _matchingOrders;


private _loadedReservations =
	_vehicle getVariable [
		"A3C_ARTY_CSW_LOADED_RESERVATIONS",
		[]
	];

_loadedReservations =
	_loadedReservations select {
		(_x select 0) != _orderId
		|| {
			_carryMag != ""
			&& {
				(_x select 1)
					!= _carryMag
			}
		}
	};

_vehicle setVariable [
	"A3C_ARTY_CSW_LOADED_RESERVATIONS",
	if (
		_loadedReservations
			isEqualTo []
	) then {
		nil
	} else {
		_loadedReservations
	},
	true
];


private _transitReservations =
	_vehicle getVariable [
		"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
		[]
	];

_transitReservations =
	_transitReservations select {
		(_x select 0) != _orderId
		|| {
			_carryMag != ""
			&& {
				(_x select 1)
					!= _carryMag
			}
		}
	};

_vehicle setVariable [
	"A3C_ARTY_CSW_TRANSIT_RESERVATIONS",
	if (
		_transitReservations
			isEqualTo []
	) then {
		nil
	} else {
		_transitReservations
	},
	true
];


{
	private _source = _x;

	private _reservations =
		_source getVariable [
			"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
			[]
		];

	_reservations =
		_reservations select {
			!(
				(_x select 0)
					== _orderId
				&& {
					(_x select 1)
						isEqualTo _vehicle
				}
				&& {
					_carryMag == ""
					|| {
						(_x select 2)
							== _carryMag
					}
				}
			)
		};

	_source setVariable [
		"A3C_ARTY_CSW_SOURCE_RESERVATIONS",
		if (
			_reservations
				isEqualTo []
		) then {
			nil
		} else {
			_reservations
		},
		true
	];

} forEach _sources;


_orders = _orders select {
	!(
		(_x select 0) == _orderId
		&& {
			_carryMag == ""
			|| {
				(_x select 2)
					== _carryMag
			}
		}
	)
};

_vehicle setVariable [
	"A3C_ARTY_CSW_ORDERS",
	if (_orders isEqualTo []) then {
		nil
	} else {
		_orders
	},
	true
];

true