/*
 * Local ownership of Helicopter Overwatch resources. All mutations are atomic
 * (isNil code), including handover. No targeting runs in the EachFrame monitor.
 * A3C_OW_DevExclusiveFire and A3C_OW_LifecycleDebug are local, default false.
 * This deliberately owns vehicle PATH only, never the pilot's PATH feature.
 */
params ["_action", "_state", ["_argument", ""], ["_self", scriptNull]];
private _result = false;
isNil {
	private _log = {
		params ["_session", "_message"];
		if (_session getOrDefault ["debug", false]) then {
			diag_log format ["A3C OW lifecycle run=%1 vehicle=%2 phase=%3: %4",
				_session get "id", _session get "vehicle", _session get "phase", _message];
		};
	};
	private _signature = {
		params ["_wp"];
		[waypointScript _wp, waypointStatements _wp, waypointFormation _wp,
			waypointSpeed _wp, waypointBehaviour _wp, waypointCombatMode _wp, waypointTimeout _wp,
			waypointName _wp, waypointDescription _wp, waypointCompletionRadius _wp]
	};
	switch (_action) do {
		case "signature": {_result = [_state] call _signature;};
		case "reason": {
			private _run = _state;
			private _group = _run get "group";
			private _wp = _run get "wp";
			_result = switch (true) do {
				case (_run getOrDefault ["ended", false]): {"run released"};
				case (isNull _group): {"group deleted"};
				case (!local _group): {"group locality changed"};
				case (leader _group != (_run get "leader") || {!alive (_run get "leader")}
					|| {vehicle (_run get "leader") != (_run get "leaderVehicle")}
					|| {!canMove (_run get "leaderVehicle")}): {"leader changed or invalid"};
				case (!((_group getVariable ["A3C_OW_Run", createHashMap]) getOrDefault ["id", []]
					isEqualTo (_run get "id"))): {"run replaced"};
				case (!(_wp in waypoints _group)): {"waypoint deleted"};
				case (currentWaypoint _group != (_wp select 1)): {"current waypoint changed"};
				case (waypointType _wp != "SCRIPTED"): {"waypoint type changed"};
				case ((waypointPosition _wp) distance2D (_run get "pos") > 1): {"waypoint moved"};
				case (!(([_wp] call _signature) isEqualTo (_run get "signature"))): {"waypoint settings changed"};
				case ((_run get "hasMainHandle") && {scriptDone (_run get "mainHandle")}): {"main script ended"};
				case (time - (_run get "heartbeat") > 10): {"main heartbeat expired"};
				default {""};
			};
		};
		case "current": {
			private _vehicle = _state get "vehicle";
			private _pilot = _state get "pilot";
			_result = !(_state get "released") && {!isNull _vehicle} && {alive _vehicle}
				&& {canMove _vehicle} && {local _vehicle} && {alive _pilot} && {local _pilot}
				&& {!isPlayer _pilot} && {driver _vehicle == _pilot}
				&& {group _pilot == ((_state get "run") get "group")}
				&& {((_vehicle getVariable ["A3C_OW_Session", createHashMap]) getOrDefault ["id", []])
					isEqualTo (_state get "id")}
				&& {_argument == "monitor" || {(["reason", _state get "run"] call A3C_main_fnc_heliOverwatchLifecycle) == ""}};
			if (_result && {_argument != "monitor"}) then {
				private _run = _state get "run";
				_result = !(_run get "conditionsReady") || {!(call (_run get "condition"))};
				if (_state get "freezeOwned") then {
					_result = _result && {(_vehicle getVariable ["A3C_Freeze_helicopter", [false,0]]) select 0};
				};
			};
		};
		case "pulse": {
			// Only the main waypoint script renews this, never a spawned worker.
			_state set ["heartbeat", time];
			_result = (["reason", _state] call A3C_main_fnc_heliOverwatchLifecycle) == "";
		};
		case "begin": {
			_state params ["_group", "_wp", "_pilots", "_mainHandle", "_hasMainHandle"];
			private _oldRun = _group getVariable ["A3C_OW_Run", createHashMap];
			if (count _oldRun > 0) then {
				["end", _oldRun, "replacement run"] call A3C_main_fnc_heliOverwatchLifecycle;
			};
			private _serial = (missionNamespace getVariable ["A3C_OW_RunSerial", 0]) + 1;
			missionNamespace setVariable ["A3C_OW_RunSerial", _serial];
			private _run = createHashMapFromArray [
				["id", [clientOwner, _serial]], ["group", _group], ["wp", _wp],
				["leader", leader _group], ["leaderVehicle", vehicle leader _group],
				["pos", +(waypointPosition _wp)], ["signature", [_wp] call _signature],
				["mainHandle", _mainHandle], ["hasMainHandle", _hasMainHandle],
				["heartbeat", time], ["ended", false], ["conditionsReady", false],
				["condition", {false}], ["vehicles", []]
			];
			private _sessions = [];
			_group setVariable ["A3C_OW_Run", _run];
			{
				private _pilot = _x;
				private _vehicle = vehicle _pilot;
				// A helicopter can also arrive from an old, different group.
				private _old = _vehicle getVariable ["A3C_OW_Session", createHashMap];
				if (count _old > 0) then {
					["release", _old, "vehicle handover"] call A3C_main_fnc_heliOverwatchLifecycle;
				};
				if (local _vehicle && {local _pilot}) then {
					private _session = createHashMapFromArray [
						["id", _run get "id"], ["run", _run], ["vehicle", _vehicle], ["pilot", _pilot],
						["phase", "TRAVEL"], ["released", false], ["ownsPATH", true], ["ownsFIREWEAPON", false],
						["savedPATH", _vehicle checkAIFeature "PATH"],
						["savedFIREWEAPON", _vehicle checkAIFeature "FIREWEAPON"],
						["exclusiveFire", _vehicle getVariable ["A3C_OW_DevExclusiveFire", false]],
						["debug", _vehicle getVariable ["A3C_OW_LifecycleDebug", false]],
						["freezeOwned", false], ["worker", scriptNull], ["hasWorker", false],
						["rotation", scriptNull], ["rotationOwnsSpeed", false],
						["delayedWorkers", []], ["lasers", []], ["firedEH", -1], ["monitor", -1]
					];
					_vehicle setVariable ["A3C_OW_Session", _session];
					(_run get "vehicles") pushBack _vehicle;
					_sessions pushBack _session;
					// Temporary travel PATH is owned too; pre-disabled PATH is still saved.
					_vehicle enableAIFeature ["PATH", true];
					private _monitor = addMissionEventHandler ["EachFrame", {
						private _key = format ["A3C_OW_Monitor_%1", _thisEventHandler];
						private _session = missionNamespace getVariable [_key, createHashMap];
						if (count _session == 0) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler];};
						["monitor", _session] call A3C_main_fnc_heliOverwatchLifecycle;
					}];
					_session set ["monitor", _monitor];
					missionNamespace setVariable [format ["A3C_OW_Monitor_%1", _monitor], _session];
					[_session, format ["created; saved PATH=%1 FIREWEAPON=%2; monitor=%3",
						_session get "savedPATH", _session get "savedFIREWEAPON", _monitor]] call _log;
				};
			} forEach _pilots;
			// Return sessions to the caller without a run -> session -> run cycle.
			_result = [_run, _sessions];
		};
		case "phase": {
			if (["current", _state] call A3C_main_fnc_heliOverwatchLifecycle) then {
				private _vehicle = _state get "vehicle";
				// ACTIVE is admitted only after the real ATL height reaches tolerance.
				if (_argument != "ACTIVE" || {abs ((getPosATL _vehicle select 2) - (_state get "height")) <= 20}) then {
					private _transition = (_state get "phase") != _argument;
					_state set ["phase", _argument];
					_vehicle enableAIFeature ["PATH", _argument in ["TRAVEL", "ROTATION"]];
					if (_transition) then {
						[_state, format ["phase %1; PATH=%2 FIREWEAPON=%3", _argument,
							_vehicle checkAIFeature "PATH", _vehicle checkAIFeature "FIREWEAPON"]] call _log;
					};
					if (_transition && {_argument == "ACTIVE"} && {_state get "exclusiveFire"}) then {
						_state set ["ownsFIREWEAPON", true];
						_vehicle enableAIFeature ["FIREWEAPON", false];
						[_state, format ["acquired vehicle FIREWEAPON control; actual=%1",
							_vehicle checkAIFeature "FIREWEAPON"]] call _log;
					};
					_result = true;
				};
			};
		};
		case "rotate": {
			if (["current", _state] call A3C_main_fnc_heliOverwatchLifecycle) then {
				private _vehicle = _state get "vehicle";
				_state set ["rotationOwnsSpeed", !(_vehicle getVariable ["A3C_LIMIT_SPEED", false])];
				private _rotation = [_state, _vehicle, _argument] spawn {
					params ["_session", "_vehicle", "_position"];
					if !(["current", _session] call A3C_main_fnc_heliOverwatchLifecycle) exitWith {};
					// Same helper/algorithm, inside the owned script handle. Do not let
					// a not-yet-started helper forward itself to a new locality owner.
					[_vehicle, _position] call A3C_ai_shared_fnc_rotateVehicleTowardsPos;
				};
				_state set ["rotation", _rotation];
				_result = _rotation;
			} else {_result = scriptNull;};
		};
		case "monitor": {
			private _run = _state get "run";
			private _reason = ["reason", _run] call A3C_main_fnc_heliOverwatchLifecycle;
			if (_reason != "") exitWith {
				["end", _run, _reason] call A3C_main_fnc_heliOverwatchLifecycle;
				// A stolen vehicle may no longer expose this old session in its
				// variable. Its monitor still owns and must remove its own resources.
				["release", _state, _reason] call A3C_main_fnc_heliOverwatchLifecycle;
			};
			if (_run get "conditionsReady" && {call (_run get "condition")}) then {_reason = "postcondition complete";};
			if (_reason == "" && {!( ["current", _state, "monitor"] call A3C_main_fnc_heliOverwatchLifecycle)}) then {
				_reason = "helicopter/pilot/ownership invalid";
			};
			if (_reason == "" && {_state get "freezeOwned"}
				&& {!(((_state get "vehicle") getVariable ["A3C_Freeze_helicopter", [false,0]]) select 0)}) then {_reason = "hover released";};
			if (_reason == "" && {_state get "hasWorker"} && {scriptDone (_state get "worker")}) then {_reason = "worker ended";};
			if (_reason != "") then {["release", _state, _reason] call A3C_main_fnc_heliOverwatchLifecycle;};
		};
		case "release": {
			if !(_state get "released") then {
				// Mark dead before terminating children or restoring anything.
				_state set ["released", true];
				[_state, format ["invalidated: %1", _argument]] call _log;
				private _vehicle = _state get "vehicle";
				private _owned = !isNull _vehicle && {
					((_vehicle getVariable ["A3C_OW_Session", createHashMap]) getOrDefault ["id", []]) isEqualTo (_state get "id")
				};
				private _rotation = _state get "rotation";
				private _rotationPending = !scriptDone _rotation;
				{
					if (!(_x isEqualTo _self) && {!scriptDone _x}) then {terminate _x;};
				} forEach ([_state get "worker", _rotation] + (_state get "delayedWorkers"));
				// IDs and objects belong to this session, never look up a new run's EH.
				private _eh = _state get "firedEH";
				if (_eh >= 0 && {!isNull _vehicle}) then {_vehicle removeEventHandler ["FIRED", _eh];};
				{if (!isNull _x) then {deleteVehicle _x;};} forEach (_state get "lasers");
				_state set ["lasers", []];
				if (_owned) then {
					private _restored = local _vehicle;
					if (_restored) then {
						if (_state get "ownsPATH") then {_vehicle enableAIFeature ["PATH", _state get "savedPATH"];};
						if (_state get "ownsFIREWEAPON") then {_vehicle enableAIFeature ["FIREWEAPON", _state get "savedFIREWEAPON"];};
						if (_rotationPending && {_state get "rotationOwnsSpeed"}
							&& {!(_vehicle getVariable ["A3C_LIMIT_SPEED", false])}) then {_vehicle limitSpeed false;};
						_vehicle flyInHeight ((_state get "pilot") getVariable ["A3C_FLYINHEIGHT", 100]);
						// Public compatibility flags may belong to a new machine after
						// locality migration. Never clear them from the former owner.
						_vehicle setVariable ["A3C_Guided_Projectile", nil, true];
						_vehicle setVariable ["A3C_fireComplete", nil, true];
						_vehicle setVariable ["A3C_Freeze_helicopter", [false,0], true];
					};
					_vehicle setVariable ["A3C_OW_Ranking", nil];
					_state set ["phase", "RELEASED"];
					_state set ["reason", _argument];
					_state set ["restoreLocal", _restored];
					_state set ["actualPATH", _vehicle checkAIFeature "PATH"];
					_state set ["actualFIREWEAPON", _vehicle checkAIFeature "FIREWEAPON"];
					_state set ["ownsPATH", false]; _state set ["ownsFIREWEAPON", false];
					// Keep last-result state compact, without retaining the complete run.
					_vehicle setVariable ["A3C_OW_LastLifecycle", [
						_state get "id", _argument, _state get "savedPATH", _state get "savedFIREWEAPON",
						_state get "actualPATH", _state get "actualFIREWEAPON", _restored
					]];
					_vehicle setVariable ["A3C_OW_Session", nil];
					[_state, format ["restored local=%1; saved PATH/FIREWEAPON=%2/%3 actual=%4/%5",
						_restored, _state get "savedPATH", _state get "savedFIREWEAPON",
						_state get "actualPATH", _state get "actualFIREWEAPON"]] call _log;
				};
				private _monitor = _state get "monitor";
				if (_monitor >= 0) then {
					removeMissionEventHandler ["EachFrame", _monitor];
					missionNamespace setVariable [format ["A3C_OW_Monitor_%1", _monitor], nil];
					_state set ["monitor", -1];
					[_state, "cleanup monitor removed"] call _log;
				};
			};
			_result = true;
		};
		case "end": {
			_state set ["ended", true];
			{
				private _session = _x getVariable ["A3C_OW_Session", createHashMap];
				if (count _session > 0 && {(_session get "id") isEqualTo (_state get "id")}) then {
					["release", _session, _argument, _self] call A3C_main_fnc_heliOverwatchLifecycle;
				};
			} forEach (_state get "vehicles");
			private _group = _state get "group";
			if (!isNull _group && {((_group getVariable ["A3C_OW_Run", createHashMap]) getOrDefault ["id", []]) isEqualTo (_state get "id")}) then {
				_group setVariable ["A3C_OW_LastRunID", _state get "id"];
				_group setVariable ["A3C_OW_Run", nil];
			};
			_result = true;
		};
		case "releaseGroup": {
			private _run = _state getVariable ["A3C_OW_Run", createHashMap];
			if (count _run > 0) then {["end", _run, _argument] call A3C_main_fnc_heliOverwatchLifecycle;};
		};
		case "releaseInvalidGroup": {
			private _run = _state getVariable ["A3C_OW_Run", createHashMap];
			if (count _run > 0) then {
				private _reason = ["reason", _run] call A3C_main_fnc_heliOverwatchLifecycle;
				if (_reason != "") then {["end", _run, _reason] call A3C_main_fnc_heliOverwatchLifecycle;};
			};
		};
		case "inspect": {
			private _vehicle = _state;
			private _session = _vehicle getVariable ["A3C_OW_Session", createHashMap];
			_result = createHashMapFromArray [
				["vehicle", _vehicle], ["local", local _vehicle],
				["actualPATH", _vehicle checkAIFeature "PATH"],
				["actualFIREWEAPON", _vehicle checkAIFeature "FIREWEAPON"],
				["phase", _session getOrDefault ["phase", "RELEASED"]],
				["runID", _session getOrDefault ["id", []]],
				["ownsPATH", _session getOrDefault ["ownsPATH", false]],
				["ownsFIREWEAPON", _session getOrDefault ["ownsFIREWEAPON", false]],
				["savedPATH", _session getOrDefault ["savedPATH", "see lastRelease"]],
				["savedFIREWEAPON", _session getOrDefault ["savedFIREWEAPON", "see lastRelease"]],
				["monitor", _session getOrDefault ["monitor", -1]],
				["worker", _session getOrDefault ["worker", scriptNull]],
				["monitorCount", {private _entry = missionNamespace getVariable [_x, createHashMap];
					count _entry > 0 && {(_entry get "vehicle") == _vehicle}} count
					((allVariables missionNamespace) select {(toLower _x) find "a3c_ow_monitor_" == 0})],
				["lastRelease", _vehicle getVariable ["A3C_OW_LastLifecycle", []]]
			];
		};
	};
};
_result
