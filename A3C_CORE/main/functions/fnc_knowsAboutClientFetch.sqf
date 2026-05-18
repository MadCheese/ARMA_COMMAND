// A3C_main_fnc_knowsAboutClientFetch

params ["_groups", "_targetDistance", "_fncEntities"];

private _localGroups = _groups select {
	local _x
};

private _targetTypes = ["MAN", "CAR", "TANK", "AIR", "SHIP", "STATICWEAPON"];

private _allTargets = [];
private _targetIndexes = createHashMap;

{
	private _group = _x;
	private _leader = leader _group;
	private _leaderVehicle = vehicle _leader;

	private _targets = [
		side _leader,
		_targetDistance,
		"ENEMY",
		position _leaderVehicle,
		_targetTypes
	] call _fncEntities;

	{
		private _target = _x;
		private _knowsAbout = _leader knowsAbout _target;

		if (_knowsAbout > 0) then { //-- exclude unknown targets
			private _targetIndex = _targetIndexes getOrDefault [_target, -1];

			if (_targetIndex == -1) then {
				_targetIndexes set [_target, count _allTargets];
				_allTargets pushBack [_target, _knowsAbout];
			} else {
				private _knownTargetEntry = _allTargets select _targetIndex;

				if (_knowsAbout > _knownTargetEntry select 1) then {
					_allTargets set [_targetIndex, [_target, _knowsAbout]];
				};
			};
		};
	} forEach _targets;
} forEach _localGroups;

if (isServer) then {
	KNOWSABOUT_ARRAY = _allTargets;
} else {
	// Send the results back to the server
	[clientOwner, _allTargets] remoteExecCall ["A3C_main_fnc_knowsAboutServerReceive", 2]; // Send to server only
};