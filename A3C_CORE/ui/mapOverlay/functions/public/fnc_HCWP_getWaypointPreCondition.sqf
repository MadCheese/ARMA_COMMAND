// A3C_ui_mapOverlay_fnc_HCWP_getWaypointPreCondition

params ["_waypoint"];

private _preConditionMode = "ARRIVAL";
private _preConditionValue = 0;

if (waypointType _waypoint == "SCRIPTED") then {
	private _waypointScript = waypointScript _waypoint;
	private _argumentStart = _waypointScript find " ";

	if (_argumentStart > -1) then {
		private _scriptArguments = call compile (
			_waypointScript select [
				_argumentStart + 1
			]
		);

		if (
			_scriptArguments isEqualType []
			&& {count _scriptArguments > 1}
			&& {(_scriptArguments select 1) isEqualType []}
			&& {count (_scriptArguments select 1) > 1}
		) then {
			private _storedPreCondition =
				_scriptArguments select 1;

			_preConditionMode = toUpper (
				_storedPreCondition select 0
			);

			_preConditionValue =
				_storedPreCondition select 1;
		};
	};
} else {
	private _conditionData = [
		(waypointStatements _waypoint) select 0,
		waypointTimeout _waypoint
	] call A3C_ai_highCommand_fnc_getConditionFromStatements;

	_conditionData params [
		"_storedMode",
		"_storedValue"
	];

	if (_storedMode != "") then {
		_preConditionMode = toUpper _storedMode;
		_preConditionValue = _storedValue;
	};
};

[
	_preConditionMode,
	_preConditionValue
]