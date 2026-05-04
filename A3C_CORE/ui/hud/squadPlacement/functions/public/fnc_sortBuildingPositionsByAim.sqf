#include "..\..\script_component.hpp"

params ["_unit", "_building", "_bPosAmount", "_aimPosASL"];

private _aimPosATL = ASLToATL _aimPosASL;
private _buildingType = typeOf _building;
private _prohibitedPositions = [];

{
    if ((_x select 0) == _buildingType) exitWith {
        _prohibitedPositions = _x select 1;
    };
} forEach (profileNamespace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]);

private _positionIndices = [];

for "_i" from 0 to _bPosAmount do {
    if !(_i in _prohibitedPositions) then {
        _positionIndices pushBack _i;
    };
};

private _positionCount = count _positionIndices;
private _sortedByATLHeight = [];
private _positionsAdded = 0;
private _testedHeight = 0;

while {_positionsAdded < _positionCount} do {
    private _currentHeightBand = [];

    {
        private _buildingPos = _building buildingPos _x;

        if ({_buildingPos in _x} count _sortedByATLHeight == 0) then {
            private _bPosHeight = _buildingPos select 2;

            if ((_bPosHeight <= (_testedHeight + 0.5)) && {_bPosHeight >= (_testedHeight - 0.5)}) then {
                _currentHeightBand pushBackUnique _buildingPos;
                _positionsAdded = _positionsAdded + 1;
            };
        };
    } forEach _positionIndices;

    if !(_currentHeightBand isEqualTo []) then {
        _sortedByATLHeight pushBack _currentHeightBand;
    };

    _testedHeight = _testedHeight + 0.5;
};

private _heightBandsSortedByDistance = [];

{
    private _heightBand = [_x, [], {_aimPosATL distance _x}, "ASCEND"] call BIS_fnc_sortBy;
    _heightBandsSortedByDistance pushBack _heightBand;
} forEach _sortedByATLHeight;

_heightBandsSortedByDistance = [
    _heightBandsSortedByDistance,
    [],
    {_aimPosATL distance (_x select 0)},
    "ASCEND"
] call BIS_fnc_sortBy;

private _return = [];

{
    {
        _return pushBack _x;
    } forEach _x;
} forEach _heightBandsSortedByDistance;

_return