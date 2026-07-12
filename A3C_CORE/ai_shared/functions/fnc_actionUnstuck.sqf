#include "..\script_component.hpp"

//-- Teleport stuck ground units / vehicles / ships into a nearby safe position.
//
//-- General rules:
//-- - Aircraft are ignored by design.
//-- - Men are moved only by the general empty-position search.
//-- - Ships use ASL positions, must remain on water, and preserve their original ASL height.
//-- - Ground vehicles first get a general collision-free fallback position.
//-- - If a ground vehicle is near a bridge, bridge handling takes priority over normal road handling.
//-- - If a ground vehicle is near a normal road, prefer a safe road position and align to the road graph.
//-- - Road object direction is not trusted. Some roads may be rotated/flipped by map authors.
//--   Road direction is derived from connected road positions instead.
//-- - Final road-aligned vehicle direction is chosen using the vehicle's current direction as reference.
//-- - Bridge roads are detected via getRoadInfo instead of model-name string matching.
//-- - Bridge exit selection uses raw bridge-to-road geometry, because using corrected/flipped road
//--   direction there can accidentally make backwards bridge exits look valid.
//-- - Open-ground vehicles without a road heading intentionally face toward their driver destination.

private _fnc_angleDiff = {
	params ["_dirA", "_dirB"];

	_dirA = [_dirA] call MCSS_fnc_correctDir;
	_dirB = [_dirB] call MCSS_fnc_correctDir;

	private _diff = abs (_dirA - _dirB);

	if (_diff > 180) then {
		360 - _diff
	} else {
		_diff
	};
};

private _fnc_selectRoadDirClosestToVehicleDir = {
	params ["_vehicleDir", "_roadAxisDir"];

	//-- A road segment has two valid travel directions.
	//-- Choose the one closest to how the vehicle was already facing.
	private _roadDirA = [_roadAxisDir] call MCSS_fnc_correctDir;
	private _roadDirB = [_roadAxisDir + 180] call MCSS_fnc_correctDir;

	if (
		[_vehicleDir, _roadDirB] call _fnc_angleDiff
		<
		[_vehicleDir, _roadDirA] call _fnc_angleDiff
	) then {
		_roadDirB
	} else {
		_roadDirA
	};
};

private _fnc_getRoadDirClosestToVehicleDir = {
	params ["_road", "_vehicleDir"];

	//-- Do not use getDir on the road object itself.
	//-- Road object orientation can be arbitrary or flipped by terrain composition.
	//-- Instead, derive possible road axes from connected road positions.
	private _connectedRoads = roadsConnectedTo _road;

	if (_connectedRoads isEqualTo []) exitWith {
		-1
	};

	private _bestDir = -1;
	private _bestDiff = 999;

	{
		private _roadAxisDir = position _road getDir position _x;
		private _candidateDir = [_vehicleDir, _roadAxisDir] call _fnc_selectRoadDirClosestToVehicleDir;
		private _candidateDiff = [_vehicleDir, _candidateDir] call _fnc_angleDiff;

		if (_candidateDiff < _bestDiff) then {
			_bestDiff = _candidateDiff;
			_bestDir = _candidateDir;
		};
	} forEach _connectedRoads;

	_bestDir
};

private _units = _this;

private _vehicles = [];
{
	private _vehicle = vehicle _x;

	//-- Aircraft are intentionally ignored. This function handles ground and water unstuck only.
	if !(_vehicle isKindOf "AIR") then {
		_vehicles pushBackUnique _vehicle;
	};
} forEach _units;

//-- Process vehicles with useful/valid destinations first.
//-- Invalid or effectively missing destinations are pushed to the end.
_vehicles =
[
	_vehicles,
	[],
	{
		private _driver = driver _x;
		private _driverDestination = (expectedDestination _driver) select 0;

		if ({_driverDestination distance2D _x < 1} count [[0,0,0], getPosASL _x] == 0) then {
			10000000
		} else {
			_x distance2D _driverDestination
		};
	},
	"ASCEND"
] call BIS_fnc_sortBy;

{
	private _vehicle = _x;
	private _driver = driver _vehicle;
	private _vehicleType = typeOf _vehicle;
	private _isShip = _vehicle isKindOf "SHIP";
	private _isMan = _vehicle isKindOf "MAN";
	private _currentVehicleDir = getDir _vehicle;
	private _driverDestination = (expectedDestination _driver) select 0;

	private _dir = -1;
	private _emptyPosition = [];

	if (!isPlayer _driver) then {
		private _pos = if (!_isShip) then {getPosATL _vehicle} else {getPosASL _vehicle};
		private _dist = 10;

		//-- Ships that are not currently on water get a wider initial search radius.
		if (_isShip) then {
			if !(surfaceIsWater _pos) then {
				_dist = 50;
			};
		};

		//-- General collision-free fallback search.
		//-- For ships, only accept positions on water and later preserve original ASL height.
		//-- For ground vehicles/men, this gives a safe fallback if no better road/bridge position is found.
		for "_i" from 1 to 5 do {
			private _candidateEmptyPosition = _pos findEmptyPosition [5, _dist, _vehicleType];

			if (
				_candidateEmptyPosition isNotEqualTo []
				&&
				{!_isShip || {surfaceIsWater _candidateEmptyPosition}}
			) then {
				_emptyPosition = _candidateEmptyPosition;
			};

			if (_emptyPosition isNotEqualTo []) exitWith {};

			_dist = _dist + 5;
		};

		if (_isShip) then {
			//-- Ships use setPosASL later, so preserve the original ASL height.
			//-- Do not write Z into an empty result; that would create an invalid partial position.
			if (_emptyPosition isNotEqualTo []) then {
				_emptyPosition set [2, _pos select 2];
			};
		} else {
			if (!_isMan) then {

				//-- Bridge handling takes priority over normal road handling.
				//-- Vehicles in Arma 3 often get stuck on/near bridge road segments.
				//-- getRoadInfo identifies bridge road segments directly, avoiding model-name heuristics.
				//-- The goal is to move the vehicle across the bridge, not merely to the nearest road node.
				private _nearBridgeRoads = (position _vehicle nearRoads 30) select {
					private _roadInfo = getRoadInfo _x;

					(count _roadInfo > 8) && {_roadInfo select 8}
				};

				if (_nearBridgeRoads isNotEqualTo []) then {
					_nearBridgeRoads =
					[
						_nearBridgeRoads,
						[],
						{position _x distance2D _vehicle},
						"ASCEND"
					] call BIS_fnc_sortBy;

					private _nearestBridgeRoad = _nearBridgeRoads select 0;
					private _bridgeConnectedRoads = roadsConnectedTo _nearestBridgeRoad;

					if (_bridgeConnectedRoads isNotEqualTo []) then {
						private _vehicleDistanceToDestination = _vehicle distance2D _driverDestination;

						//-- expectedDestination can be useful, but when a vehicle is stationary/stuck it may be
						//-- very close to the vehicle or otherwise misleading. Use it only as a weak hint.
						private _driverDestinationIsUseful = _vehicleDistanceToDestination > 5;

						//-- Choose the bridge exit using raw bridge geometry.
						//-- Important: do NOT apply the 180-degree road-direction correction here.
						//-- For placement, the raw direction from bridge road to connected exit road determines
						//-- whether the exit is physically ahead or behind the vehicle.
						//-- The 180 correction is only used later for final vehicle orientation.
						private _bridgeExitCandidates =
						[
							_bridgeConnectedRoads,
							[],
							{
								private _bridgeExitDir = position _nearestBridgeRoad getDir position _x;
								private _headingDiff = [_currentVehicleDir, _bridgeExitDir] call _fnc_angleDiff;

								private _destinationBonus = if (_driverDestinationIsUseful && {_x distance2D _driverDestination < _vehicleDistanceToDestination}) then {
									-20
								} else {
									0
								};

								//-- Prefer the connected road farther from the stuck vehicle as a tie-breaker.
								//-- This helps select the opposite side of the bridge without overpowering heading.
								private _oppositeSideBonus = -((position _x distance2D _vehicle) min 30);

								_headingDiff + _destinationBonus + _oppositeSideBonus
							},
							"ASCEND"
						] call BIS_fnc_sortBy;

						private _bridgeExitRoad = _bridgeExitCandidates select 0;
						private _previousBridgeRoad = _nearestBridgeRoad;
						private _bridgeSearchLimit = 12;
						private _bridgeSearchStep = 0;

						while {_bridgeSearchStep < _bridgeSearchLimit} do {
							_bridgeSearchStep = _bridgeSearchStep + 1;

							private _candidateEmptyPosition = position _bridgeExitRoad findEmptyPosition [0, 5, _vehicleType];

							if (_candidateEmptyPosition isNotEqualTo []) exitWith {
								_emptyPosition = _candidateEmptyPosition;

								//-- Final orientation is road-aligned, but corrected using the vehicle's original heading.
								//-- This avoids trusting arbitrary road object rotation.
								private _roadDirClosestToVehicle = [_bridgeExitRoad, _currentVehicleDir] call _fnc_getRoadDirClosestToVehicleDir;

								if (_roadDirClosestToVehicle != -1) then {
									_dir = _roadDirClosestToVehicle;
								} else {
									_dir = _currentVehicleDir;
								};
							};

							private _nextBridgeRoads = roadsConnectedTo _bridgeExitRoad;
							_nextBridgeRoads = _nextBridgeRoads select {_x != _previousBridgeRoad};

							if (_nextBridgeRoads isEqualTo []) exitWith {};

							//-- Continue walking away from the bridge using the same raw-geometry principle:
							//-- raw direction for bridge traversal, corrected road graph direction only for final heading.
							_nextBridgeRoads =
							[
								_nextBridgeRoads,
								[],
								{
									private _nextRoadDir = position _bridgeExitRoad getDir position _x;
									private _headingDiff = [_currentVehicleDir, _nextRoadDir] call _fnc_angleDiff;

									private _destinationBonus = if (_driverDestinationIsUseful && {_x distance2D _driverDestination < _bridgeExitRoad distance2D _driverDestination}) then {
										-15
									} else {
										0
									};

									private _awayFromBridgeBonus = -((position _x distance2D _nearestBridgeRoad) min 30);

									_headingDiff + _destinationBonus + _awayFromBridgeBonus
								},
								"ASCEND"
							] call BIS_fnc_sortBy;

							_previousBridgeRoad = _bridgeExitRoad;
							_bridgeExitRoad = _nextBridgeRoads select 0;
						};
					};
				} else {
					private _vehicleSize = sizeOf _vehicleType;

					//-- Normal road handling:
					//-- If roads are nearby, prefer a road position over the general fallback position.
					//-- The search radius scales with vehicle size.
					private _nearRoads = position _vehicle nearRoads (_vehicleSize * 2);

					//-- Prefer roads that are closer to the driver's destination than the vehicle is.
					//-- This helps select a road node in the likely travel direction.
					private _roadsInTravelDirection = _nearRoads select {
						private _roadToDestination = _x distance2D _driverDestination;
						private _roadToVehicle = _x distance2D _vehicle;

						_roadToDestination < _roadToVehicle
					};

					private _flatDriverDestination = +_driverDestination;
					_flatDriverDestination set [2, 0];

					if (_roadsInTravelDirection isNotEqualTo []) then {
						_nearRoads = _roadsInTravelDirection;
					};

					//-- Avoid selecting a road node that is inside or too close to the current vehicle footprint.
					private _roadsOutsideVehicleRadius = _nearRoads select {_x distance _vehicle > _vehicleSize};

					if (_roadsOutsideVehicleRadius isNotEqualTo []) then {
						_nearRoads = _roadsOutsideVehicleRadius;
					};

					_nearRoads =
					[
						_nearRoads,
						[],
						{
							_x distance2D _vehicle
						},
						"ASCEND"
					] call BIS_fnc_sortBy;

					if (_nearRoads isNotEqualTo []) then {
						{
							private _candidateEmptyPosition = position _x findEmptyPosition [0, 5, _vehicleType];

							if (_candidateEmptyPosition isNotEqualTo []) exitWith {
								_emptyPosition = _candidateEmptyPosition;

								//-- Align with the road graph, then choose the direction closest to current vehicle heading.
								//-- This avoids flipped vehicles caused by arbitrary road object rotation.
								private _roadDirClosestToVehicle = [_x, _currentVehicleDir] call _fnc_getRoadDirClosestToVehicleDir;

								if (_roadDirClosestToVehicle != -1) then {
									_dir = _roadDirClosestToVehicle;
								};
							};

							_dist = _dist + 5;
						} forEach _nearRoads;
					};

					//-- If no road graph heading was found but the driver has a valid destination,
					//-- intentionally face the vehicle toward that destination.
					//-- This is useful for open-ground unstuck because there is no road axis to preserve,
					//-- and destination-facing helps AI continue moving after recovery.
					if (_dir == -1) then {
						if ({_driverDestination distance2D _x > 1} count [[0,0,0], position _vehicle] > 0) then {
							_dir = _vehicle getDir _driverDestination;
						};
					};
				};
			};
		};

		//-- Reset driver AI state before moving.
		//-- This is intentionally before the MP anti-abuse teleport check so AI recovery still happens.
		_driver lookAt objNull;
		_driver enableAI "FSM";
		_driver enableAI "MOVE";
		_driver enableSimulation true;
		_driver forceSpeed -1;

		//-- Special case for stuck/prone man units.
		//-- BIS_fnc_RelPos is used because source ASL Z must be preserved.
		if (_driver == _vehicle) then {
			if ((animationState _vehicle) in ["afalpercmstpsraswrfldnon"]) then {
				private _relPos = [getPosASL _driver, 0.5, getDir _driver] call BIS_fnc_RelPos;

				[_vehicle, ""] remoteExec ["switchMove", _vehicle];
				[_vehicle, _relPos] remoteExec ["setPosASL", _vehicle];
			};
		};

		if (_emptyPosition isEqualTo []) exitWith {};

		private _allowUnstuck = true;

		//-- Prevent abusing unstuck in MP as a defensive measure.
		//-- Kept late on purpose: nearby enemy players block teleporting, but do not block AI recovery above.
		if (isMultiplayer) then {
			private _enemies = [_driver, "ARRAY"] call MCSS_fnc_nearEnemies;

			if ({isPlayer _x} count _enemies > 0) then {
				_allowUnstuck = false;
			};
		};

		if (_allowUnstuck) then {
			if (!_isShip) then {
				[_vehicle, _emptyPosition] remoteExec ["setPos", _vehicle];
			} else {
				[_vehicle, _emptyPosition] remoteExec ["setPosASL", _vehicle];
			};

			if (!_isMan) then {
				if (_dir != -1) then {
					_vehicle setDir _dir;
				};
			};
		};
	};

	sleep 0.2;
} forEach _vehicles;