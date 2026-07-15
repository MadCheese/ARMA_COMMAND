// A3C_ui_mapOverlay_fnc_adjustPolygonEdge

// Adjusts the selected edge marker of a polygon.
private _screenX = _this select 1;
private _screenY = _this select 2;

private _mapControl = findDisplay 12 displayCtrl 51;
private _worldPosition = _mapControl posScreenToWorld [_screenX, _screenY];

private _movedPolygonId = A3C_MovedItem_ID select 0;
private _movedEdgeIndex = A3C_MovedItem_ID select 1;

private _targets = A3C_HC_allGroupsClient_Current + (units player - [player]);

{
	private _entity = _x;
	private _polygons = _entity getVariable ["A3C_UNIT_POLYS", []];

	{
		private _polygonEntry = _x;

		if (((_polygonEntry select 0) select 1) == _movedPolygonId) exitWith {
			private _polygonPositions = _polygonEntry select 1;

			// Replace the selected polygon edge position with the dragged map position.
			_polygonPositions set [_movedEdgeIndex, _worldPosition];

			_entity setVariable ["A3C_UNIT_POLYS", _polygons, true];
		};
	} forEach _polygons;
} forEach _targets;