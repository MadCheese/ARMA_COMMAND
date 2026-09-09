// A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue

/*
	Owns one temporary AI-leadership period.

	Requests added while the worker is waiting are processed before player
	leadership is restored. Queue completion states are released only after
	the player has reclaimed leadership and stationary units were restored.
*/

private _playerUnit = player;
private _playerGroup = group _playerUnit;
private _completedTasks = [];

private _standByShown = false;

private _sentencesEnabled = sentencesEnabled;



private _fnc_showStandBy = {
	if (
		_standByShown
		|| {!(shownHud select 6)}
	) exitWith {};

	"A3C_STANDBY" cutRsc [
		"RscTitleDisplayEmpty",
		"PLAIN",
		0,
		false
	];

	private _display = uiNamespace getVariable [
		"RscTitleDisplayEmpty",
		displayNull
	];

	if (isNull _display) exitWith {};

	private _ctrl = _display ctrlCreate [
		"RscStructuredText",
		-1
	];

	_ctrl ctrlSetPosition [
		safeZoneX + 0.02 * safeZoneW,
		safeZoneY + safeZoneH - 0.1 * safeZoneH,
		0.45 * safeZoneW,
		0.16 * safeZoneH
	];

	_ctrl ctrlSetStructuredText parseText
		"<t align='left' font='PuristaBold' size='4.8' shadow='2'>STAND BY</t>";

	_ctrl ctrlCommit 0;

	_standByShown = true;
};

private _fnc_hideStandBy = {
	if (!_standByShown) exitWith {};

	"A3C_STANDBY" cutFadeOut 0;

	_standByShown = false;
};

private _fnc_getTaskUnits = {
	params [
		["_unitsAndRoles", [], [[]]]
	];

	private _taskUnits = [];

	{
		if (_x isEqualType [] && {count _x > 0}) then {
			private _unit = _x select 0;

			if (
				_unit isEqualType objNull
				&& {!isNull _unit}
			) then {
				_taskUnits pushBackUnique _unit;
			};
		};
	} forEach _unitsAndRoles;

	_taskUnits
};

private _fnc_getLeaderCandidate = {
	params [
		["_preferredAssignments", [], [[]]]
	];

	private _candidate = objNull;
	private _preferredUnits = [
		_preferredAssignments
	] call _fnc_getTaskUnits;

	{
		if (
			alive _x
			&& {!isPlayer _x}
			&& {group _x == _playerGroup}
		) exitWith {
			_candidate = _x;
		};
	} forEach _preferredUnits;

	if (isNull _candidate) then {
		{
			if (
				alive _x
				&& {!isPlayer _x}
			) exitWith {
				_candidate = _x;
			};
		} forEach (units _playerGroup);
	};

	_candidate
};

private _firstAssignments = if (
	A3C_BOARDING_QUEUE isNotEqualTo []
) then {
	(A3C_BOARDING_QUEUE select 0) param [
		0,
		[],
		[[]]
	]
} else {
	[]
};

private _temporaryLeader = [
	_firstAssignments
] call _fnc_getLeaderCandidate;

private _stationaryUnits = [];

if (
	!isNull _temporaryLeader
	&& {!isNull _playerGroup}
) then {
	_stationaryUnits = (units _playerGroup) select {
		_x != _playerUnit
		&& {_x != _temporaryLeader}
		&& {alive _x}
		&& {isNull objectParent _x}
		&& {isNull assignedVehicle _x}
		&& {_x checkAIFeature "MOVE"}
		&& {currentCommand _x == ""}
		&& {
			private _expectedDestination =
				expectedDestination _x;

			private _destinationType = toLower (
				_expectedDestination param [1, ""]
			);

			!("form" in _destinationType)
		}
	};

	{
		_x disableAI "MOVE";
	} forEach _stationaryUnits;

	//-- prevent ai leader callouts
	if (_sentencesEnabled) then {
		enableSentences false;
	};

	_playerGroup selectLeader _temporaryLeader;

	[] call _fnc_showStandBy;
	
};

while {A3C_BOARDING_QUEUE isNotEqualTo []} do {
	private _task = A3C_BOARDING_QUEUE deleteAt 0;

	_task params [
		"_unitsAndRoles",
		"_vehicle",
		"_completionState"
	];

	//-- If the temporary leader died or leadership returned to a player,
	//-- choose another AI before processing the next queued request.
	private _currentLeader = leader _playerGroup;

	if (
		isNull _currentLeader
		|| {!alive _currentLeader}
		|| {isPlayer _currentLeader}
	) then {
		_temporaryLeader = [
			_unitsAndRoles
		] call _fnc_getLeaderCandidate;

		if (!isNull _temporaryLeader) then {
			//-- A later boarding request may select a unit that was originally
			//-- protected as stationary. It must no longer be restored.
			if (_temporaryLeader in _stationaryUnits) then {
				_temporaryLeader enableAI "MOVE";

				_stationaryUnits =
					_stationaryUnits - [_temporaryLeader];
			};

			//-- prevent ai leader callouts
			if (_sentencesEnabled) then {
				enableSentences false;
			};

			_playerGroup selectLeader _temporaryLeader;
			[] call _fnc_showStandBy;
		};
	};

	private _result = if (
		!isNull _playerGroup
		&& {_playerUnit in units _playerGroup}
		&& {!isNull leader _playerGroup}
		&& {!isPlayer leader _playerGroup}
	) then {
		[
			_unitsAndRoles,
			_vehicle,
			_playerGroup,
			_playerUnit,
			_temporaryLeader
		] call A3C_ai_squad_fnc_boarding_boardUnitsToVehicle
	} else {
		[
			[],
			[
				_unitsAndRoles
			] call _fnc_getTaskUnits,
			[]
		]
	};

	if !(
		_result isEqualType []
		&& {count _result >= 3}
	) then {
		_result = [
			[],
			[
				_unitsAndRoles
			] call _fnc_getTaskUnits,
			[]
		];
	};

	//-- boardUnitsToVehicle enabled MOVE for these units and actually issued
	//-- their boarding commands. Never apply stationary restoration to them.
	private _issuedUnits = _result param [
		2,
		[],
		[[]]
	];

	_stationaryUnits =
		_stationaryUnits - _issuedUnits;

	//-- Do not release completion yet. The completion contract guarantees
	//-- that player leadership has already been restored.
	_completedTasks pushBack [
		_completionState,
		_result
	];
};

//-- Restore player leadership once after the complete current queue burst.
if (
	!isNull _playerGroup
	&& {!isNull _playerUnit}
	&& {_playerUnit in units _playerGroup}
) then {
	_playerGroup selectLeader _playerUnit;
};

//-- Always restore the client's original sentence setting, including when
//-- the player died or changed groups during the transaction.
if (_sentencesEnabled) then {
	enableSentences true;
};

[] call _fnc_hideStandBy;

//-- Only units that never received a boarding order remain in this array.
{
	if (!isNull _x) then {
		if (
			alive _x
			&& {group _x == _playerGroup}
			&& {isNull objectParent _x}
			&& {isNull assignedVehicle _x}
		) then {
			_x doFSM [
				"A3C_CORE\fsm\doMove.fsm",
				position _x,
				_x
			];
		};

		_x enableAI "MOVE";
	};
} forEach _stationaryUnits;

//-- Now every completed request may safely release its waiting caller.
{
	_x params [
		"_completionState",
		"_result"
	];

	_completionState set [1, _result];
	_completionState set [0, true];
} forEach _completedTasks;

//-- Defensive UI cleanup.
[] call _fnc_hideStandBy;

A3C_BOARDING_QUEUE_ACTIVE = false;

/*
	A request can arrive after the loop observes an empty queue but before the
	active flag is cleared. Such a request begins a new leadership period.
*/
if (
	A3C_BOARDING_QUEUE isNotEqualTo []
	&& {!A3C_BOARDING_QUEUE_ACTIVE}
) then {
	A3C_BOARDING_QUEUE_ACTIVE = true;

	if (sentencesEnabled) then {
		player groupRadio "SentCmdGetIn";
	};

	[] spawn A3C_ai_squad_fnc_boarding_processBoardUnitsToVehicleQueue;
};