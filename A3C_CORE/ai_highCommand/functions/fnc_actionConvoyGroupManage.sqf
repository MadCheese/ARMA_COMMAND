if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
	//-- rejoin Convoy to former groups
	{
		private _entry = _x;

		if ((A3C_SELECTED_HC_GROUPS_SETTINGS select 0) == (_entry select 0)) exitWith {

			A3C_ConvoyGroups = A3C_ConvoyGroups - [_entry];

			private _groupArrays = [];

			{
				private _subgroupUnits = _x;

				if ({alive _x} count _subgroupUnits > 0) then {
					_groupArrays pushBackUnique _subgroupUnits;
				};
			} forEach (_entry select 1);

			{
				private _unitArray = _x;
				private _group = createGroup (side (_unitArray select 0));

				{
					private _unit = _x;

					[_unit] joinSilent _group;

					if (!isNull objectParent _unit && {_unit == driver vehicle _unit}) then {
						(vehicle _unit) setUnloadInCombat [true, false];
					};
				} forEach _unitArray;
			} forEach _groupArrays;

			{
				private _unitArray = _x;
				private _firstUnit = _unitArray select 0;
				private _group = group _firstUnit;
				private _convoyData = _firstUnit getVariable "A3C_CONVOYDATA";

				[
					_group,
					[(_convoyData select 3)]
				] remoteExec ["setGroupIDGlobal", leader _group];
			} forEach _groupArrays;

			deleteGroup (_entry select 0);
		};
	} forEach A3C_ConvoyGroups;
} else {
	//-- create new convoy in order
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS >= 2) then {
		private _drivers = [];

		A3C_CONVOY_GROUPORDER = [];

		//-- driver leadvic needs to be in group
		//-- no units can have no assigned vehicle
		private _refUnits = A3C_SELECTED_HC_GROUPS_SETTINGS select {
			private _group = _x;
			private _leader = leader _group;
			private _leaderVehicle = vehicle _leader;

			!isPlayer _leader &&
			{
				(driver _leaderVehicle) in (units _group)
			}
		};

		//-- Step 1: fetch drivers and footunits
		{
			private _group = _x;
			private _groupUnits = units _group;

			A3C_CONVOY_GROUPORDER pushBackUnique _groupUnits;

			{
				private _unit = _x;

				if (!isNull objectParent _unit && {_unit == driver (objectParent _unit)}) then {
					_drivers pushBackUnique _unit;
					(vehicle _unit) setUnloadInCombat [false, false];
				};
			} forEach _groupUnits;

			if (count _groupUnits == 0) then {
				deleteGroup _group;
			};
		} forEach _refUnits;

		//-- create refposition of averages (positions and direction):
		private _avg = 0;

		{
			_avg = _avg + (getDir (vehicle _x));
		} forEach _drivers;

		_avg = if (count _drivers == 0) then {
			0
		} else {
			_avg / (count _drivers)
		};

		private _mapSize = 2000; //(getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize")) / 2;
		private _avgX = 0;
		private _avgY = 0;

		if (count _drivers > 0) then {
			_avgX = (_drivers apply {(getPos (vehicle _x)) select 0}) call BIS_fnc_arithmeticMean;
			_avgY = (_drivers apply {(getPos (vehicle _x)) select 1}) call BIS_fnc_arithmeticMean;
		};

		private _center = [_avgX, _avgY, 0];
		private _refPos = _center getPos [_mapSize, _avg];

		//-- get leader (closest to refpos)
		_drivers = [_drivers, [], {(vehicle _x) distance2D _refPos}, "ASCEND"] call BIS_fnc_sortBy;

		private _leader = if (count _drivers > 0) then {
			_drivers select 0
		} else {
			leader (_refUnits select 0)
		};

		if (count _drivers == 0) exitWith {
			systemChat "A3C: Convoy can not be created without drivers :)";
		};

		//-- sort remaining vehicles by distance to leader, then rejoin _leader
		_drivers = _drivers - [_leader];
		_drivers = [_drivers, [], {(vehicle _x) distance2D (vehicle _leader)}, "ASCEND"] call BIS_fnc_sortBy;
		_drivers = [_leader] + _drivers;

		//-- create order of units
		private _A3C_ConvoyUnits = [];

		{
			private _driver = _x;

			//-- add vehicle crew to group as well
			{
				private _unit = _x;

				_A3C_ConvoyUnits pushBackUnique _unit;
			} forEach (units _driver);
		} forEach _drivers;

		//-- set groupData variable
		{
			private _unit = _x;
			private _group = group _unit;

			_unit setVariable [
				"A3C_CONVOYDATA",
				[
					_group,
					units _group,
					"BLUE",
					groupID _group
				],
				true
			]; //~~ do not move this
		} forEach _A3C_ConvoyUnits;

		//-- create new group
		private _newGroup = createGroup (side player);

		_A3C_ConvoyUnits = _A3C_ConvoyUnits - [_leader];

		[_leader] joinSilent _newGroup;
		_newGroup selectLeader _leader;
		_A3C_ConvoyUnits joinSilent _newGroup;

		A3C_ConvoyGroups pushBackUnique [_newGroup, A3C_CONVOY_GROUPORDER];
		A3C_HC_DISBANDED pushBackUnique _newGroup;

		_newGroup setGroupIDGlobal [format ["Convoy-%1", count A3C_ConvoyGroups]];
		_newGroup setFormation "COLUMN";
		_newGroup setFormDir (getDir (vehicle _leader));
		_newGroup enableAttack false;
		_newGroup setBehaviourStrong "SAFE";

		{
			private _unit = _x;
			private _vehicle = vehicle _unit;

			if (!isNull objectParent _unit && {_unit == driver _vehicle} && {!(_vehicle isKindOf "AIR")}) then {
				_vehicle setConvoySeparation 20;
			};
		} forEach units _newGroup;

		private _leadVehicle = objNull;

		systemChat "A3C: New convoy group created";

		A3C_MAP_CommandMode = "HC";
		A3C_SELECTED_UNITS = [_newGroup];

		["HC"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode; //-- refresh table if open

		A3C_SELECTED_HC_GROUPS_SETTINGS = [];

		while {!isNull _newGroup} do {
			private _group = _newGroup;
			private _leaderUnit = leader _group;

			_leadVehicle = vehicle _leaderUnit;

			private _vehicles = [];

			//-- assist stuck vehicles
			{
				private _unit = _x;
				private _vehicle = vehicle _unit;

				if (_vehicle != _leadVehicle && {!isNull objectParent _unit} && {_unit == driver _vehicle}) then {
					_vehicles pushBack _vehicle;

					if (speed _vehicle == 0 && {speed vehicle _leaderUnit > 0}) then {
						_unit doFollow _leaderUnit;
						[_unit, _leaderUnit] remoteExec ["doFollow", _unit];
					};
				};
			} forEach units _newGroup;

			//-- leadVic speed
			[_leadVehicle, false] remoteExec ["limitSpeed", _leadVehicle];

			private _maxDistance = (count _vehicles) * 70;

			if (_maxDistance != 0 && {{!(_x isKindOf "LAND")} count (_vehicles + [_leadVehicle]) == 0} && {{_x distance _leadVehicle > _maxDistance} count _vehicles > 0}) then {
				[_leadVehicle, 10] remoteExec ["limitSpeed", _leadVehicle];
			};

			sleep 5;
		};

		[_leadVehicle, false] remoteExec ["limitSpeed", _leadVehicle];
	};
};