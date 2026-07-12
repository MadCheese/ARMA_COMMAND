// MCSS_fnc_findOverwatchNear
// Idea: optional parameter: polygon. If polygon is given, check for lineIntersectsSurfaces and check if it is in polygon.

params ["_input", "_targetPos"];

private _searchCenter = _input;

if (typeName _searchCenter == "OBJECT") then {
	_searchCenter = position _searchCenter;
};

private _returnPos = _pos;
private _candidatePositions = [];

private _sampleCount = 300;
private _minCandidateSpacing = 5;

for "_i" from 1 to _sampleCount do {
	private _candidatePos = [_searchCenter, 0, 100, 2, 0, 50, 0, [], []] call BIS_fnc_findSafePos;

	_candidatePos pushBack 0;

	if (({ _x distance _candidatePos < _minCandidateSpacing } count _candidatePositions) == 0) then {
		_candidatePositions pushBack _candidatePos;
	};
};

_candidatePositions = [
	_candidatePositions,
	[],
	{ _x distance2D _searchCenter },
	"ASCEND"
] call BIS_fnc_sortBy;

private _targetPosASL = ATLtoASL _targetPos;

{
	private _refPos = +_x;
	_refPos set [2, (_refPos select 2) + 1];

	private _refPosASL = ATLtoASL _refPos;

	if ([_refPosASL, _targetPosASL] call MCSS_fnc_lineOfSightSimple) exitWith {
		_returnPos = _x;
	};
} forEach _candidatePositions;

_returnPos