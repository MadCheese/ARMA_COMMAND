// A3C_ai_shared_fnc_polygonAreaRemove

params ["_unit", "_polygon"];

if (_polygon isEqualTo []) exitWith {};

private _unitGroup = group _unit;
private _isPlayerGroup = _unitGroup == group player;

private _markers = [(_polygon select 0) select 1] + (_polygon select 2);

A3C_SUPPRESSION_UNITS_SQ = A3C_SUPPRESSION_UNITS_SQ - [_unit]; 
// Leave this here. Removing AI-array units is handled by functions calling remove_poly.

private _units = if (_isPlayerGroup) then {
	A3C_SUPPRESSION_UNITS_SQ
} else {
	A3C_SUPPRESSION_UNITS_AI
};

private _deletePolygonMarkers = true;

{
	private _unitPolys = _x getVariable ["A3C_UNIT_POLYS", []];

	if !(_unitPolys isEqualTo []) then {
		private _polyMarkers = (_unitPolys select 0) select 2;

		if ((_markers select 0) in _polyMarkers) then {
			_deletePolygonMarkers = false;
		};
	};
} forEach (_units - [_unit]);

if (_deletePolygonMarkers) then {
	{
		A3C_POLYEDGE_MARKERS = A3C_POLYEDGE_MARKERS - [_x];
		deleteMarkerLocal _x;
	} forEach _markers;

	if (!_isPlayerGroup) then {
		private _groupPolys = _unitGroup getVariable "A3C_UNIT_POLYS";
		private _polyID = (_polygon select 0) select 1;

		{
			private _refID = (_x select 0) select 1;

			if (_polyID == _refID) exitWith {
				_groupPolys = _groupPolys - [_x];
			};
		} forEach _groupPolys;

		_unitGroup setVariable ["A3C_UNIT_POLYS", _groupPolys, true];
	};
};

if (_isPlayerGroup) then {
	private _unitPolys = _unit getVariable "A3C_UNIT_POLYS";
	_unitPolys = _unitPolys - [_polygon];

	_unit setVariable ["A3C_UNIT_POLYS", _unitPolys, true];
};

_unit setVariable ["A3C_SUPPRESSION_TARGET", [0, false, -1], true];