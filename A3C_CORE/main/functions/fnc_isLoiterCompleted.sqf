// A3C_main_fnc_isLoiterCompleted

params ["_wp"];

private _group = _wp select 0;

private _precond = [
	(waypointStatements _wp) select 0,
	waypointTimeout _wp
] call A3C_ai_highCommand_fnc_getConditionFromStatements;

_precond params ["_condMode", "_condVal"];

private _leaderVehicle = vehicle leader _group;

private _tolerance = 20;
private _exitCondition = canMove _leaderVehicle &&
{
	_leaderVehicle distance2D waypointPosition _wp < waypointLoiterRadius _wp + _tolerance
};

if (_exitCondition) then {
	_exitCondition = switch (_condMode) do {
		case "TIMEOUT": {
			private _loiterStartTime = _group getVariable ["A3C_LOITER_TIMEOUT", -1];
			private _return = false;

			if (_loiterStartTime != -1) then {
				if (time > (_loiterStartTime + _condVal)) then {
					_return = true;
				};
			} else {
				_group setVariable ["A3C_LOITER_TIMEOUT", time, true];
			};

			_return
		};

		case "GOCODE": {
			call compile format ["A3C_GoCode_Activate_%1", _condVal]
		};

		case "DAYTIME": {
			private _timeParts = _condVal splitString ":";
			private _checkParams = [];

			{
				_checkParams pushBack parseNumber _x;
			} forEach _timeParts;

			call compile format ["%1 call A3C_main_fnc_isDaytimeCompleted", _checkParams]
		};

		default {
			true
		};
	};
};

if (_exitCondition) then {
	_group setVariable ["A3C_LOITER_TIMEOUT", nil, true];
	_group setCurrentWaypoint [_group, (currentWaypoint _group) + 1];

	if ((currentWaypoint _group) == (_wp select 1)) then {
		_wp call A3C_ai_highCommand_fnc_removeWaypoint;
	};
};