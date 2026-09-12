// A3C_main_fnc_getArtilleryAmmo

// -- _includeOrders: boolean to include planned orders or not
// -- _getDisplayName: boolean to convert/bundle array into display names
// -- _targetPos: optional target position used to filter ammo by artillery range

params [
	["_includeOrders", false],
	["_getDisplayName", false],
	["_targetPos", []]
];

private _availableMagsAll = [];

{
	private _artyPiece = _x;
	private _artyMagTypes = getArtilleryAmmo [_artyPiece];

	private _availableMagsVehicle = magazinesAllTurrets _artyPiece select {
		_x params ["_magType", "_turretPath", "_magAmount"];

		private _inRange = if (_targetPos isEqualTo []) then {
			true
		} else {
			_targetPos inRangeOfArtillery [[_artyPiece], _magType]
		};

		_inRange && {_magType in _artyMagTypes}
	};

	{
		_x params ["_magType", "_turretPath", "_magAmount"];

		private _existingIndex = _availableMagsAll findIf {
			_x select 0 == _magType
		};

		if (_existingIndex == -1) then {
			_availableMagsAll pushBack [_magType, _magAmount];
		} else {
			private _availableMagData = _availableMagsAll select _existingIndex;
			_availableMagData set [1, (_availableMagData select 1) + _magAmount];
		};
	} forEach _availableMagsVehicle;

	if (_includeOrders) then {
		private _artyOrdersPlanned = _artyPiece getVariable ["A3C_ARTY_ORDERS", []];

		{
			_x params ["_firePos", "_magType", "_orderCount"];

			private _existingIndex = _availableMagsAll findIf {
				_x select 0 == _magType
			};

			if (_existingIndex != -1) then {
				private _availableMagData = _availableMagsAll select _existingIndex;
				_availableMagData set [1, (_availableMagData select 1) - _orderCount];
			};
		} forEach _artyOrdersPlanned;
	};
} forEach MCSS_REMOTE_ARTILLERY_ARRAY;

_availableMagsAll = _availableMagsAll select {
	_x select 1 > 0
}; // -- keep only those mags that can be shot

if (!_getDisplayName) exitWith {
	_availableMagsAll
};

private _displayNameArray = [];

{
	_x params ["_magType", "_magAmount"];

	private _displayName = getText (configFile >> "CfgMagazines" >> _magType >> "displayName");

	private _existingIndex = _displayNameArray findIf {
		_x select 0 == _displayName
	};

	if (_existingIndex == -1) then {
		_displayNameArray pushBack [_displayName, _magAmount];
	} else {
		private _displayNameData = _displayNameArray select _existingIndex;
		_displayNameData set [1, (_displayNameData select 1) + _magAmount];
	};
} forEach _availableMagsAll;

_displayNameArray