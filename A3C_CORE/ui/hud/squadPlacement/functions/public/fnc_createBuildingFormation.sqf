#include "..\..\script_component.hpp"

params ["_building", "_aimPos"];

if (isNull _building) exitWith {};
if ((count A3C_UI_squadPlacement_unitGhosts) == 0) exitWith {};

private _outsidePositions = [_building, 1] call MCSS_fnc_BBOX;
private _availablePositions = [_building] call MCSS_fnc_countBPos;
private _positionArray = [player, _building, _availablePositions, _aimPos] call FUNC(sortBuildingPositionsByAim);

_availablePositions = count _positionArray;

{
    private _unitGhost = _x;
    private _index = _forEachIndex;

    if (!isNull _unitGhost) then {
        if (_index < (count _positionArray)) then {
            private _buildingPos = _positionArray select _index;

            _unitGhost setPosATL _buildingPos;
            _unitGhost setVariable [
                "A3C_ARROW_BPOS",
                [
                    _buildingPos,
                    [_building, _buildingPos] call BIS_fnc_dirTo
                ],
                true
            ];
        } else {
            private _arrowBPos = _unitGhost getVariable ["A3C_ARROW_BPOS", [0, 0]];

            if !((_arrowBPos select 0) isEqualType []) then {
                if ((_arrowBPos select 0) == 0) then {
                    private _outsideIndex = _index - _availablePositions;

                    if (
                        (_outsideIndex >= 0)
                        && {_outsideIndex < (count _outsidePositions)}
                        && {_index <= (_availablePositions + 8)}
                    ) then {
                        _unitGhost setPos (_outsidePositions select _outsideIndex);
                    } else {
                        _unitGhost setPos (_building getRelPos [
                            random ((sizeOf (typeOf cursorTarget)) / 2),
                            random 360
                        ]);
                    };

                    _unitGhost setVariable [
                        "A3C_ARROW_BPOS",
                        [
                            1,
                            _building getRelDir _unitGhost
                        ],
                        true
                    ];
                };
            };
        }; 
    };

    
} forEach A3C_UI_squadPlacement_unitGhosts;