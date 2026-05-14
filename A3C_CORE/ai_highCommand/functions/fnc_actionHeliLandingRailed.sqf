// A3C_ai_highCommand_fnc_actionHeliLandingRailed

params ["_landingRailType", "_condition"];

private _landingData = +A3C_RADIAL_ACTION_HC_LANDINGDATA;
A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

_landingData params ["_landingPosRoot", "_landingVector", "_forceDefaultLanding"];

deleteVehicle A3C_OBJECTPLACER;
A3C_OBJECTPLACER = objNull;

A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3c_ui\markers\HeliPad.paa";
[A3C_UI_HUD_3D_TAG_ICON_POS, ""] spawn A3C_UI_HUD_3D_TAG;

private _groups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

if (_groups isEqualTo []) exitWith {};

private _playerUID = getPlayerUID player;

private _distributedPositions = [
	_landingPosRoot,
	_groups,
	count _groups,
	_landingPosRoot getDir leader (_groups select 0),
	100
] call A3C_fnc_generateWpWedgePositions;

{
	private _group = _x;
	private _leader = leader _group;
	private _groupIndex = _forEachIndex;

	if (_groupIndex > 0) then {
		_forceDefaultLanding = true; //-- make sure that only one vehicle can land precisely (obsolete check?)
	};

	// make specific landingpos available only for single group selections and only leadvic. multiple group selections revert to arma landing

	//-- for full landings, delete all other waypoints
	if (_landingRailType == "FULL LANDING") then {
		_group setVariable ["A3C_UNIT_POLYS", [], true];

		//-- clear all waypoints
		{
			{
				_x setVariable ["A3C_CLEARING", false, true];
			} forEach units _x;
		} forEach A3C_SELECTED_UNITS;

		[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
	};

	//-- add new waypoints
	private _leaderVehicle = vehicle _leader;
	private _landingWPos = _distributedPositions select _groupIndex;

	private _isGroupOnFinalWP = currentWaypoint _group >= count waypoints _group;
	private _createReturnWP = (_landingRailType in ["COMBAT LANDING", "TRANSPORT UNLOAD"]) && {
		_isGroupOnFinalWP && {
			_landingWPos distance2D _leaderVehicle > 50
		}
	};
	private _landOnReturn = _createReturnWP && {!isEngineOn _leaderVehicle};

	private _landingWaypoint = _group addWaypoint [_landingWPos, 0];

	if (_createReturnWP) then {
		private _startPos = position _leaderVehicle;
		private _returnWaypoint = _group addWaypoint [_startPos, 0];

		if (_landOnReturn) then {
			//-- land with default Arma mechanic upon return
			private _statements = format [
				"
					[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
				",
				_startPos,
				_playerUID
			];

			private _wpStatements = waypointStatements _returnWaypoint;
			_returnWaypoint setWaypointStatements [
				_wpStatements select 0,
				(_wpStatements select 1) + _statements
			];
		};
	};

	private _statements = "";

	if (_groupIndex == 0 && {!_forceDefaultLanding}) then {
		private _subCondition = if (_landingRailType == "COMBAT LANDING") then {
			format ["A3C_GoCode_Activate_%1", (_condition splitString "") select 8]
		} else {
			""
		};

		//-- assumption: waypointScript gets executed on every machine - if the script is present
		//-- assumption 2: a function can be remotely executed from the machine that executed the script (needs to be determined?)
		_landingWaypoint setWaypointType "SCRIPTED";

		_landingWaypoint setWaypointScript format [
			"A3C_CORE\fnc_AI\wpFncs\wpScript_railedHeliLanding.sqf ['%1',%2,%3,'%4',%5,'%6']",
			_playerUID,
			["ARRIVAL", ""],
			["ARRIVAL", ""],
			_landingRailType,
			_landingData,
			_subCondition
		];
	} else {
		switch (_landingRailType) do {
			case "COMBAT LANDING": {
				private _subCondition = (_condition splitString "") select 8;

				_statements = format [
					"
						[['%1',this,[['GoCode','%2'],'COMBATLANDING'],'LINE',(currentWaypoint (group this))],A3C_HC_INSERT_ACTION_WP,nil,false] remoteExec ['bis_fnc_call',0];
						[(group this)] call A3C_HC_FNC_CompleteWaypoint
					",
					_playerUID,
					_subCondition
				];

				A3C_GOCODES_HC pushBackUnique _subCondition;
				publicVariable "A3C_GOCODES_HC";
				[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0];
			};

			case "TRANSPORT UNLOAD": {
				_landingWaypoint setWaypointType "TR UNLOAD";
				_statements = "[(group this)] call A3C_HC_FNC_CompleteWaypoint;  ";
			};

			case "FULL LANDING": {
				_statements = format [
					"
						[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
						[(group this)] call A3C_HC_FNC_CompleteWaypoint;
					",
					_landingData select 0,
					_playerUID
				];
			};
		};
	};

	if (_statements != "") then {
		private _wpStatements = waypointStatements _landingWaypoint;
		_landingWaypoint setWaypointStatements [
			_wpStatements select 0,
			(_wpStatements select 1) + _statements
		];
	};

	sleep 1;
} forEach _groups;