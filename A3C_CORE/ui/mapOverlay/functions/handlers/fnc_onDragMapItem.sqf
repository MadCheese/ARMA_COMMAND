#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_onDragMapItem

if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};

params [
	"_dragData",
	"_item",
	"_mode",
	"_ctrlPressed",
	"_altPressed"
];

disableSerialization;

private _screenX = _dragData select 1;
private _screenY = _dragData select 2;

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _markerDir = 0;
private _screenWorldPos = [];
private _exit = false;

private _referenceUnit = objNull;

if (_item isEqualType []) then {
	_referenceUnit = _item select 0;
	_item = _item select 3;
};

// _item is usually an icon. When coming from squad-level suppression,
// the marker is treated as an icon.
if (
	{
		((_x select 0) select 1) == _item
	} count A3C_ALL_POLYS > 0
) then {
	// Rewrite this: make general function that can be called by unit or group.
	// Add suppression marker check for unit-marker arrays.
	{
		private _entity = _x;
		private _polygons =
			_entity getVariable [
				"A3C_UNIT_POLYS",
				[]
			];

		if (
			{
				_item == ((_x select 0) select 1)
			} count _polygons > 0
		) then {
			_screenWorldPos =
				_mapControl posScreenToWorld [
					_screenX,
					_screenY
				];

			if (!_ctrlPressed) then {
				if (_altPressed) then {
					[
						_entity,
						_item,
						_screenWorldPos,
						2
					] call A3C_ui_mapOverlay_fnc_adjustPolygonMain;
				} else {
					[
						_entity,
						_item,
						_screenWorldPos,
						0
					] call A3C_ui_mapOverlay_fnc_adjustPolygonMain;
				};
			} else {
				{
					private _polygon = _x;

					if (
						((_polygon select 0) select 1)
							== A3C_MovedItem_ID
					) exitWith {
						[
							_entity,
							A3C_MovedItem_ID,
							_screenWorldPos,
							1
						] call A3C_ui_mapOverlay_fnc_adjustPolygonMain;
					};
				} forEach _polygons;
			};
		};
	} forEach (
		A3C_HC_allGroupsClient_Current
		+ (units player - [player])
	);
};

if (_exit) exitWith {};

private _unitArray =
	profileNamespace getVariable "A3C_GROUPUNITS";

{
	private _soldier = _x;

	private _polygons =
		_soldier getVariable [
			"A3C_UNIT_POLYS",
			[]
		];

	{
		private _plotVar = _x;

		private _plotData =
			_soldier getVariable [
				_plotVar,
				[]
			];

		{
			private _waypointData = _x;
			private _waypointIndex = _forEachIndex;

			_waypointData params [
				"_wpPositions",
				"_wpMarkers",
				"_wpAction",
				"_wpCondition",
				"_wpStances",
				"_wpSyncData",
				"_wpCompleted",
				"_wpCombatMode",
				"_wpSpeed",
				"_wpFlyInHeight",
				"_wpLoopValue",
				"_wpRadius"
			];

			private _isTargetWP = false;

			if (_item in _wpMarkers) then {
				if ((_wpMarkers select 1) == "") then {
					if ((_wpMarkers select 0) == _item) then {
						_isTargetWP = true;
					};
				} else {
					if ((_wpMarkers select 1) == _item) then {
						_isTargetWP = true;
					};
				};
			};

			if (_isTargetWP) exitWith {
				_screenWorldPos =
					_mapControl posScreenToWorld [
						_screenX,
						_screenY
					];

				if (_mode == "WP") then {
					if (!_ctrlPressed) then {
						if (!_altPressed) then {
							if (
								{
									((_x select 0) select 1) == _item
								} count A3C_ALL_POLYS > 0
							) then {
								[
									_soldier,
									_item,
									_screenWorldPos,
									0
								] call A3C_ui_mapOverlay_fnc_adjustPolygonMain;
							};
						};

						/*
						 * nearestBuilding was too expensive and caused UI lag.
						 * This vertical line-intersection approach is the
						 * retained alternative.
						 */
						private _screenWorldPosASL =
							ATLToASL _screenWorldPos;

						private _intersections =
							lineIntersectsObjs [
								_screenWorldPosASL vectorAdd [
									0,
									0,
									30
								],
								_screenWorldPosASL,
								objNull,
								objNull
							];

						_intersections = _intersections select {
							[
								_x
							] call MCSS_fnc_getLastBuildingPosIndex > 0
						};

						private _nearestBuilding =
							if (count _intersections > 0) then {
								_intersections select 0
							} else {
								objNull
							};

						if (!isNull _nearestBuilding) then {
							private _buildingPositions = [];

							for "_i" from 0 to (
								[
									_nearestBuilding
								] call MCSS_fnc_getLastBuildingPosIndex
							) do {
								_buildingPositions pushBack (
									_nearestBuilding buildingPos _i
								);
							};

							_buildingPositions = [
								_buildingPositions,
								[],
								{
									_x distance2D _screenWorldPos
								},
								"ASCEND"
							] call BIS_fnc_sortBy;

							_screenWorldPos =
								_buildingPositions select 0;
						};

						if (!_altPressed) then {
							_wpPositions set [
								0,
								_screenWorldPos
							];
						};

						_soldier setVariable [
							_plotVar,
							_plotData,
							true
						];
					} else {
						if (
							{
								((_x select 0) select 1) == _item
							} count A3C_ALL_POLYS > 0
						) then {
							{
								private _polygon = _x;

								if (
									((_polygon select 0) select 1)
										== A3C_MovedItem_ID
								) exitWith {
									[
										_soldier,
										_item,
										_screenWorldPos,
										1
									] call A3C_ui_mapOverlay_fnc_adjustPolygonMain;
								};
							} forEach _polygons;
						};
					};

					// Re-order units to move.
					if (
						(
							_soldier getVariable
								"A3C_CURRENTWAYPOINT_INDEX"
						) == (_waypointIndex + 1)
					) then {
						if (
							_soldier
								== driver vehicle _soldier
						) then {
							A3C_MV_MARKERDATA = [
								_soldier,
								_screenWorldPos,
								_plotVar
							];

							if !(
								player
									== effectiveCommander vehicle _soldier
							) then {
								if !(
									_soldier
										in A3C_SUPPRESSION_UNITS_SQ
								) then {
									if !(
										_soldier getVariable [
											"A3C_HOLD",
											false
										]
									) then {
										if (_plotVar == "A3C_PLOT") then {
											if !(
												(_wpAction select 0)
													in [
														"GRENADE",
														"SUPPRESSION"
													]
											) then {
												if (
													(time - A3C_TICKTIME_MoveMark)
														> 1.5
												) then {
													A3C_TICKTIME_MoveMark =
														time;

													_soldier setDestination [
														_screenWorldPos,
														"LEADER PLANNED",
														true
													];

													[
														_soldier,
														_screenWorldPos
													] call A3C_ai_shared_fnc_doMove;
												};
											};
										};
									};
								};
							};
						};
					};
				} else {
					_markerDir = [
						A3C_DIR_POS,
						_screenWorldPos
					] call BIS_fnc_dirTo;

					if (_soldier == _referenceUnit) then {
						_wpPositions set [
							1,
							[
								_wpPositions select 0,
								100,
								_markerDir
							] call BIS_fnc_relPos
						];

						_soldier setVariable [
							_plotVar,
							_plotData,
							true
						];
					};
				};
			};
		} forEach _plotData;
	} forEach [
		"A3C_PLOT",
		"A3C_PLOT_TEMP"
	];
} forEach _unitArray;