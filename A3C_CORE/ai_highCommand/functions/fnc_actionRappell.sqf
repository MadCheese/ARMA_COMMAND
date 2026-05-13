// A3C_ai_highCommand_fnc_actionRappell
{
	private _group = _x;

	_group setVariable ["A3C_UNIT_POLYS", [], true];

	//-- clear all waypoints
	{
		{
			_x setVariable ["A3C_CLEARING", false, true];
		} forEach units _x;
	} forEach A3C_SELECTED_UNITS;

	[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;

	//-- add new waypoints
	private _leaderVehicle = vehicle leader _group;
	private _rappelWorldPos = +A3C_UI_HUD_3D_TAG_ICON_POS;
	private _startPos = getPos _leaderVehicle;
	private _landOnReturn = !isEngineOn _leaderVehicle;

	private _rappelWaypoint = [
		_group,
		_rappelWorldPos
	] call A3C_ai_highCommand_fnc_addWaypoint;

	if (A3C_UI_HUD_3D_TAG_ICON_POS distance2D _leaderVehicle > 50) then {
		private _returnWaypoint = [
			_group,
			_startPos
		] call A3C_ai_highCommand_fnc_addWaypoint;

		if (_landOnReturn) then {
			private _landingStatement = format [
				"
					[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
				",
				_startPos,
				getPlayerUID player
			];

			private _returnWaypointStatements = waypointStatements _returnWaypoint;
			_returnWaypoint setWaypointStatements [
				_returnWaypointStatements select 0,
				(_returnWaypointStatements select 1) + _landingStatement
			];
		};
	};

	//-- #TODO this bit might require some investigation - seems like a saftey mechanic if the vehicle is very close when action is issued
	if (_leaderVehicle distance2D _rappelWorldPos < 800) then {
		waitUntil {
			speed _leaderVehicle > 80 || {
				_leaderVehicle distance2D _rappelWorldPos < 300
			}
		};
	};

	private _rappelStatement = format [
		"
			[['%1',this,[['NONE','NONE'],'RAPPELL'],'LINE',(currentWaypoint group this),0],A3C_HC_INSERT_ACTION_WP] remoteExec ['bis_fnc_call',0];
		",
		getPlayerUID player
	];

	private _rappelWaypointStatements = waypointStatements _rappelWaypoint;
	_rappelWaypoint setWaypointStatements [
		_rappelWaypointStatements select 0,
		(_rappelWaypointStatements select 1) + _rappelStatement
	];
} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;