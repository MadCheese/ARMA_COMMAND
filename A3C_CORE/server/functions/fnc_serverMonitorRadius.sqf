// A3C_server_fnc_serverMonitorRadius

//-- codeblock for the waypointRadius block that runs every two seconds.

params [
	["_slingEvents", [], [[]]]
];

//-- remove sling vehicles that no longer have an active sling load
_slingEvents = _slingEvents select {
	!isNull _x
	&& {!isNull (getSlingLoad _x)}
};

{
	private _gp = _x;

	if (!isNull _gp) then {

		private _leader = leader _gp;

		if (!isNull _leader) then {

			private _vehicle = vehicle _leader;

			private _currentWpIndex = currentWaypoint _gp;
			private _currentWaypoint = [_gp, _currentWpIndex];
			private _currentWpType = waypointType _currentWaypoint;
			private _currentWpPos = waypointPosition _currentWaypoint;
			private _actionScript = (waypointStatements _currentWaypoint) param [1, ""];
			private _actionType = "";

			if (["CASdistribute", _actionScript] call BIS_fnc_instring) then {
				if !(["CAS-STRIKE_ACTIVE", _actionScript] call BIS_fnc_instring) then {
					if (
						_currentWpPos distance2D _vehicle < 3000
						&& {(getPosVisual _vehicle) select 2 > 50}
					) then {
						_actionType = "ActionCas";
					} else {
						//-- vehicle approaching the target: make him fly high enough
						private _flyInHeight = (getTerrainHeightASL _currentWpPos) + 1000;

						if (!isNull _vehicle) then {
							[_vehicle, _flyInHeight] remoteExec ["flyInHeight", _vehicle];
						};
					};
				};
			};

			private _isRotor =
				(getNumber (
					configFile
					>> "CfgVehicles"
					>> typeOf _vehicle
					>> "landingSpeed"
				)) < 10;

			if (
				_isRotor
				&& {{!(_x in _vehicle)} count (assignedCargo _vehicle) == 0}
			) then {

				if (["RAPPEL", _actionScript] call BIS_fnc_instring) then { //-- looking for FNC name, not wp landing type

					private _slowDownDistance =
						if (_vehicle isKindOf "HELICOPTER") then {
							1200
						} else {
							2500
						};

					if !(["RAPPELL_ACTIVE", _actionScript] call BIS_fnc_instring) then {
						if (_currentWpPos distance2D _vehicle < _slowDownDistance) then {
							_actionType = "HeliRappell";
						};
					};
				};
			};

			//-- give leader a varname so we can convert the actionscript later
			if (_actionType != "") then {
				if ((vehicleVarName _leader) == "") then {
					while {
						!isNull _leader
						&& {(vehicleVarName _leader) == ""}
					} do {
						//systemchat 'varname loop';
						call compile format
							[
								"
									_leader setvehicleVarName 'A3C_MEMBER_%1_%2';
									A3C_MEMBER_%1_%2 = _leader;
								",
								"Server_UID",
								A3C_VARNAME_INDEX_HC
							];
					};
				} else {
					call compile format
					[
						"
							%1 = _leader;
							publicVariable '%1';
						",
						(vehicleVarName _leader)
					];
				};

				A3C_VARNAME_INDEX_HC = A3C_VARNAME_INDEX_HC + 1;
				publicVariable "A3C_VARNAME_INDEX_HC";
			};

			switch _actionType do {
				case ("ActionCas") : {
					_actionScript = [_actionScript, "this", str _leader] call A3C_main_fnc_editString; //-- convert to something we can execute
					call (compile _actionScript);
					[_gp, _currentWpIndex, "ACTIONSCRIPT", "'CAS_STRIKE_ACTIVE'; "] call A3C_ai_highCommand_fnc_changeWaypointData;
				};

				case ("PlaneLand") : {
					_actionScript = [_actionScript, "this", str _leader] call A3C_main_fnc_editString; //-- convert to something we can execute
					call (compile _actionScript);
					[_gp, _currentWpIndex, "ACTIONSCRIPT", "'FULL LANDING ACTIVE'; "] call A3C_ai_highCommand_fnc_changeWaypointData;
				};

				case ("HeliRappell") : {
					_actionScript = [_actionScript, "this", str _leader] call A3C_main_fnc_editString; //-- convert to something we can execute
					call (compile _actionScript);
					[_gp, _currentWpIndex, "ACTIONSCRIPT", "'A3C_RAPPELL_ACTIVE'; "] call A3C_ai_highCommand_fnc_changeWaypointData;
				};
			};

			if (_currentWpType == "LOITER") then {
				[_currentWaypoint] call A3C_main_fnc_isLoiterCompleted;
			};

			if (_currentWpType != "HOOK") then {
				{
					private _v = objectParent _x;

					if (!isNull _v && {_x == driver _v}) then {
						private _slingCargo = getSlingLoad _v;

						if (!isNull _slingCargo && {!(_v in _slingEvents)}) then {
							_slingEvents pushBack _v;

							[_v, _slingCargo] spawn {
								params ["_v", "_slingCargo"];

								if (!isNull _slingCargo) then {
									private _originalMass = getMass _slingCargo;

									[_slingCargo, 2000] remoteExec ["setMass", _slingCargo];

									while {
										!isNull (getSlingLoad _v)
										&& {canMove _v}
									} do {
										sleep 2;
									};

									if (!isNull _slingCargo) then {
										[_slingCargo, _originalMass] remoteExec ["setMass", _slingCargo];
									};
								};
							};
						};
					};
				} forEach units _gp;
			};

			//-- Since currentCommand only works where unit is local, execute where the current group leader is local
			if (!isNull _gp) then {

				private _boardingLeader = leader _gp;

				if (!isNull _boardingLeader) then {

					[_gp] remoteExecCall [
						"A3C_ai_highCommand_fnc_updateGroupBoardingState",
						_boardingLeader
					];

				} else {

					//-- leaderless group cannot be boarding
					if (_gp getVariable ["A3C_isBoarding", false]) then {
						_gp setVariable ["A3C_isBoarding", false, true];
					};
				};
			};

		} else {

			//-- leaderless group cannot be boarding
			if (_gp getVariable ["A3C_isBoarding", false]) then {
				_gp setVariable ["A3C_isBoarding", false, true];
			};
		};
	};

} forEach A3C_MON_SERVER_checkGroups;

_slingEvents