// A3C_ai_squad_fnc_boarding_boardUnitsToVehicle

/*
	This is a 'hack' to fix a limitation within A3:

	These commands can only work for AI-commanded groups:

	1. Assign vehicle and role to unit (ie assignAsCargoIndex)
	2. _unitArray orderGetIn true;

	This fnc hacks its way around that issue by joining the player to a
	temporary group, having an AI leader take over and issue the commands,
	then joining the player back to the original group.

	It does NOT work the other way around: units will cancel boarding as
	soon as they are joined back into the player group.

	Switching the player between groups also prevents unwanted mutation
	of the original player group.
*/

params ["_unitsAndRoles", "_vehicle"];


private _playerGroup = group player;

private _unitArray = _unitsAndRoles apply {
	_x select 0
};

private _tempGroup = createGroup [side _playerGroup, true];

[player] joinSilent _tempGroup;


private _fakeGroupUnits = if (shownHUD select 6) then {
	_playerGroup call A3C_ai_squad_fnc_boarding_createPlayerGroupUIProxy
} else {
	[]
};

if (a3c_debug) then {
	systemChat format [
		"created _fakeGroupUnits: %1",
		count _fakeGroupUnits
	];
};


{
	_x params ["_unit", "_role", "_roleIndex"];

	//-- TEST
	switch (_role) do {
		case ("DRIVER"): {
			_unit assignAsDriver _vehicle;
		};

		case ("CARGO"): {
			_unit assignAsCargo _vehicle;
		};

		case ("TURRET"): {};
	};

} forEach _unitsAndRoles;


//-- Override any previous command which prevented these units
//-- from entering vehicles.
_unitArray allowGetIn true;

_unitArray orderGetIn true;


//-- Wait until every relevant unit has accepted GET IN at least once,
//-- entered the target vehicle, died or ceased to exist.
//
//-- This is a stall watchdog rather than an overall timeout. As long
//-- as additional units continue accepting the order, the routine may
//-- take as long as necessary.
private _acceptanceStallTimeout = 10;

private _pendingUnits = _unitArray select {
	!isNull _x
	&& {alive _x}
	&& {vehicle _x != _vehicle}
};

private _previousPendingCount = count _pendingUnits;
private _lastProgressAt = diag_tickTime;

private _boardingOrderAccepted = false;
private _boardingOrderFailed = false;

waitUntil {
	//-- Units removed from this array remain accepted. This avoids
	//-- requiring every unit to report GET IN during the same frame.
	_pendingUnits = _pendingUnits select {
		!isNull _x
		&& {alive _x}
		&& {vehicle _x != _vehicle}
		&& {currentCommand _x != "GET IN"}
	};

	private _pendingCount = count _pendingUnits;

	if (_pendingCount < _previousPendingCount) then {
		_previousPendingCount = _pendingCount;
		_lastProgressAt = diag_tickTime;
	};

	_boardingOrderAccepted = _pendingCount == 0;

	_boardingOrderFailed =
		!_boardingOrderAccepted
		&& {
			isNull _vehicle
			|| {!alive _vehicle}
			|| {
				diag_tickTime - _lastProgressAt
				>= _acceptanceStallTimeout
			}
		};

	_boardingOrderAccepted || _boardingOrderFailed
};


if (_boardingOrderFailed && {a3c_debug}) then {
	systemChat format [
		"GET IN acceptance stalled for units: %1",
		_pendingUnits
	];
};


[player] joinSilent _playerGroup;

{
	deleteVehicle _x;
} forEach _fakeGroupUnits;


_playerGroup selectLeader player;

deleteGroup _tempGroup;


if (a3c_debug) then {
	sleep 0.5;

	systemChat format [
		"remaining _fakeGroupUnits: %1",
		{!isNull _x} count _fakeGroupUnits
	];
};


/*
[
	[
		[u1, "CARGO"]
	],
	cursorTarget
] spawn A3C_ai_squad_fnc_boarding_boardUnitsToVehicle;
*/