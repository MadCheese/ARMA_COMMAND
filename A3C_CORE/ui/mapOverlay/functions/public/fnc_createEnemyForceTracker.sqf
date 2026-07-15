// A3C_ui_mapOverlay_fnc_createEnemyForceTracker

// Simple force tracker based on targets known to the local player.
if (A3C_DISABLE_TRACKER) exitWith {};

private _factionGroups = [];
private _friendlyGroups = [];

A3C_TRACKER_Groups = [];

private _nearTargets = player nearTargets 1300;
private _playerSide = side player;

{
	private _group = _x;
	private _groupSide = side _group;
	private _groupLeader = leader _group;
	private _leaderVehicle = vehicle _groupLeader;

	private _color = switch (_groupSide) do {
		case west: {
			[A3C_UI_COLOR_BLUE, 1] call A3C_UI_fnc_setOpacity
		};

		case east: {
			[A3C_UI_COLOR_RED, 1] call A3C_UI_fnc_setOpacity
		};

		case resistance: {
			[0, 0.5, 0, 1]
		};

		case civilian: {
			[0.4, 0, 0.5, 1]
		};

		default {
			[0.4, 0, 0.5, 1]
		};
	};

	// WIP/issue: _color has previously been observed as a Boolean.
	// Use red to make the affected tracker entry easy to identify.
	if (typeName _color != "ARRAY") then {
		_color = [1, 0, 0, 1];
	};

	_color set [3, 0.5];

	if (_groupSide getFriend _playerSide >= 0.6) then {
		// Friendly non-civilian groups are drawn by other map-UI systems.
		if (_groupSide == civilian) then {
			A3C_TRACKER_GROUPS pushBackUnique [
				_group,
				position _leaderVehicle,
				"CIVILIAN",
				_color
			];
		};
	} else {
		private _foundNearTarget = false;

		{
			private _perceivedPosition = _x select 0;
			private _targetObject = _x select 4;

			if (
				{
					_x == _targetObject
				} count [
					_groupLeader,
					_leaderVehicle
				] > 0
			) exitWith {
				_foundNearTarget = true;

				A3C_TRACKER_GROUPS pushBackUnique [
					_group,
					_perceivedPosition,
					"ENEMY",
					_color
				];
			};
		} forEach _nearTargets;

		if (!_foundNearTarget) then {
			A3C_TRACKER_GROUPS pushBackUnique [
				_group,
				position _leaderVehicle,
				"ENEMY",
				_color
			];
		};
	};
} forEach allGroups;