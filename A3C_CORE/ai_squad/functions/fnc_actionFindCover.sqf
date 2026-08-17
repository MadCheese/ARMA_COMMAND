// A3C_ai_squad_fnc_actionFindCover


params ["_units"];

if (isNil '_units') exitWith {};

if (typeName _units == "STRING") then {
	_units = call compile _units;
};

_units = _units select {
	isNull objectParent _x && {!isPlayer _x}
};

private _mode = if (count _this > 1) then {
	_this select 1
} else {
	0
};

if ((count _units) == 0) exitWith {};

if (_mode == 0) then {
	private _busyUnits = _units select {
		count (_x getVariable ["A3C_PLOT", []]) > 0
	};

	if (count _busyUnits > 0) then {
		[_busyUnits, true, false] spawn A3C_ai_shared_fnc_cancelUnitPlot;
		sleep 1;
	};

	player groupRadio "SentCmdHide";
};

private _unitClusters = []; // Positions

{
	private _unit = _x;
	private _createNew = true;

	{
		if ((getPosASL _unit) distance2D (getPosASL (_x select 0)) < 20) exitWith {
			_createNew = false;
			_x pushBack _unit;
		};
	} forEach _unitClusters;

	if (_createNew) then {
		_unitClusters pushBack [_unit];
	};
} forEach _units;

{
	private _xCenter = 0;
	private _yCenter = 0;

	{
		private _aslPos = getPosASL _x;
		_xCenter = _xCenter + (_aslPos select 0);
		_yCenter = _yCenter + (_aslPos select 1);
	} forEach _x;

	if (_xCenter > 0) then {
		_xCenter = _xCenter / (count _x);
	};

	if (_yCenter > 0) then {
		_yCenter = _yCenter / (count _x);
	};

	_unitClusters set [_forEachIndex, [_x, [_xCenter, _yCenter, 0]]];
} forEach _unitClusters;

private _dispersion = 4;
private _side = side (_units select 0);


// Step 1: Find enemies to take cover from.
// Note: change this to units that are known to player side?
private _enemies = [];

private _enemyUnits = allUnits select {
	private _soldier = _x;

	((_side getFriend (side _soldier)) < 0.5) &&
	{
		(({(vehicle _soldier) distance _x < 300} count _units) > 0)
	}
};

{
	_enemies pushBackUnique (vehicle _x);
} forEach _enemyUnits;


private _isClassFnc = {
	params ["_obj"];

	!isNull _obj
};

private _checkedObjects = [];

{
	_x params ["_unitsCluster", "_center"];

	private _radius = 50;

	private _coverObjects = (nearestObjects [_center, [], _radius]) select {
		[_x] call _isClassFnc
	};

	private _terrainRocks = (nearestTerrainObjects [_center, ["ROCK", "ROCKS", "HIDE"], _radius]) select {
		[_x] call _isClassFnc
	};

	private _terrainWalls = (nearestTerrainObjects [_center, ["WALL"], _radius]) select {
		[_x] call _isClassFnc
	};

	private _terrainBushes = (nearestTerrainObjects [_center, ["BUSH"], _radius]) select {
		[_x] call _isClassFnc
	};

	private _terrainTrees = (nearestTerrainObjects [_center, ["TREE", "SMALL TREE"], _radius]) select {
		[_x] call _isClassFnc
	};

	_coverObjects = _coverObjects select {
		private _checkedObject = _x;

		!((typeOf _x) in A3C_COVER_BLACKLIST) &&
		{
			!(_x in (_terrainRocks + _terrainWalls + _terrainBushes + _terrainTrees)) &&
			{
				private _checkString = if (typeOf _checkedObject == "") then {
					str _checkedObject
				} else {
					typeOf _checkedObject
				};

				_checkString = toLower _checkString;

				private _idStrings = [
					"noid ",
					": cl_",
					"dummyweapon",
					": pavement_",
					": garbage_",
					"line",
					"sign",
					"light",
					"runway",
					"fence",
					"gate",
					"indfnc",
					"land_woodenwall_02",
					"honeybee.p3d",
					"fly.p3d",
					"mosquito.p3d",
					"bee.p3d",
					" b_ficusc2d_f.p3d"
				];

				({_checkString find _x > -1} count _idStrings == 0) &&
				{
					({_checkedObject isKindOf _x} count ["EmptyDetector"] == 0) &&
					{
						({_checkedObject isKindOf _x && {alive _checkedObject}} count ["Animal", "Animals", "MAN"] == 0) &&
						{
							!(_checkedObject in (_center nearRoads 50)) &&
							{
								(((boundingBoxReal _checkedObject select 1) select 2) > 0.5)
							}
						}
					}
				}
			}
		}
	};

	private _hardCover = _coverObjects select {
		private _armor = getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "armor");
		_armor > 30
	};

	_coverObjects = _coverObjects + _terrainBushes - _hardCover;

	if (!isNil "A_HELPERS") then {
		{
			deleteVehicle _x;
		} forEach A_HELPERS;
	} else {
		A_HELPERS = [];
	};

	private _assignmentFull = [];
	private _positionsAssigned = [];
	private _positionsBlacklisted = [];

	if (count _coverObjects > 0) then {
		{
			private _soldier = _x;

			_hardCover = _hardCover - _assignmentFull;
			_terrainRocks = _terrainRocks - _assignmentFull;
			_terrainWalls = _terrainWalls - _assignmentFull;
			_terrainTrees = _terrainTrees - _assignmentFull;
			_coverObjects = _coverObjects - _assignmentFull;

			_hardCover = [_hardCover, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;
			_terrainRocks = [_terrainRocks, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;
			_terrainWalls = [_terrainWalls, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;
			_terrainTrees = [_terrainTrees, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _closeRadius = 30;

			private _closeHardCover = _hardCover select {
				_x distance2D _soldier <= _closeRadius
			};
			_closeHardCover = [_closeHardCover, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _closeRocks = _terrainRocks select {
				_x distance2D _soldier <= _closeRadius
			};
			_closeRocks = [_closeRocks, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _closeWalls = _terrainWalls select {
				_x distance2D _soldier <= _closeRadius
			};
			_closeWalls = [_closeWalls, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _closeTrees = _terrainTrees select {
				_x distance2D _soldier <= _closeRadius
			};
			_closeTrees = [_closeTrees, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _closePreferred = _closeHardCover + _closeRocks;
			_closePreferred = [_closePreferred, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			private _coverObjectsRest =
				(
					(_hardCover - _closeHardCover) +
					(_terrainRocks - _closeRocks) +
					(_terrainWalls - _closeWalls) +
					(_terrainTrees - _closeTrees) +
					_coverObjects
				);

			_coverObjectsRest = [_coverObjectsRest, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

			// To do: further sort close cover including size and other factors.
			private _coverObjectsFinal =
				(
					_closePreferred +
					_closeWalls +
					_closeTrees +
					_coverObjectsRest
				) select {
					!isNull _x &&
					{
						private _size = _x call BIS_fnc_objectHeight;
						_size > 1
					}
				};

			private _unitCoverPos = [];

			{
				if (count _unitCoverPos > 0) exitWith {};

				private _coverObject = _x;
				private _bBox2d = [];

				// Check if object was checked before.
				{
					if ((_x select 0) == _coverObject) exitWith {
						_bBox2d = _x select 1;
					};
				} forEach _checkedObjects;

				// If no bbox data exists, create it.
				if (count _bBox2d == 0) then {
					_bBox2d = [_coverObject, 1] call MCSS_fnc_getBoundingBox;

					private _refPos2 = (getPosASL _coverObject) vectorAdd [0, 0, 0.4];

					{
						private _refPos1 = (ATLToASL _x) vectorAdd [0, 0, 0.4];

						private _intersections = lineIntersectsSurfaces [
							_refPos1,
							_refPos2,
							objNull,
							objNull,
							true,
							-1,
							"GEOM",
							"NONE"
						];

						_intersections = _intersections select {
							private _intersectionObject = _x select 2;
							_intersectionObject == _coverObject
						};

						if (count _intersections > 0) then {
							private _intersectionPos = ((_intersections select 0) select 0) select [0, 2];
							_bBox2d set [_forEachIndex, _intersectionPos + [0]];
						};
					} forEach _bBox2d;

					_checkedObjects pushBack [_coverObject, _bBox2d];
				};

				_bBox2d = _bBox2d - (_positionsAssigned + _positionsBlacklisted);
				_bBox2d = [_bBox2d, [], {_soldier distance _x}, "ASCEND"] call BIS_fnc_sortBy;

				{
					_bBox2d set [_forEachIndex, _x getPos [1, _coverObject getDir _x]];
				} forEach _bBox2d;

				if (count _bBox2d > 0) then {
					{
						private _targetPos = [(_x select 0), (_x select 1), 1]; // Add 1m to guarantee some kind of cover.

						private _condition = (
							({_targetPos distance _x < _dispersion} count _positionsAssigned) == 0
						) && {
							(({[_targetPos, _x, _coverObject] call MCSS_fnc_lineOfSightCover} count _enemies) == 0)
						};

						if (_condition) exitWith {
							_unitCoverPos = _targetPos;
							_positionsAssigned pushBack _unitCoverPos;

							[_soldier, _targetPos] spawn {
								params ["_soldier", "_unitCoverPos"];

								[_soldier, _unitCoverPos] call A3C_ai_shared_fnc_doMove;
								sleep 1;

								waitUntil {
									unitReady _soldier
								};

								_soldier setUnitPos "MIDDLE";
							};
						};

						// Position not suitable, add to blacklisted.
						_positionsBlacklisted pushBack _targetPos;

						// No cover pos was found - blacklist cover object.
						if (_forEachIndex == ((count _bBox2d) - 1)) then {
							_assignmentFull pushBack _coverObject;
						};
					} forEach _bBox2d;
				} else {
					// No available positions - add to blacklist.
					_assignmentFull pushBack _coverObject;
				};
			} forEach _coverObjectsFinal;

			if (count _unitCoverPos == 0) then {
				// No cover.
				_soldier setUnitPos "DOWN";
				[_soldier, position _soldier] call A3C_ai_shared_fnc_doMove;
			};
		} forEach _unitsCluster;
	};
} forEach _unitClusters;