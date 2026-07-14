#include "..\..\script_component.hpp"

params ["_control", "_button", "_posX", "_posY"];

if !(A3C_UI_CustomFormation_BOOL_isMouseUp) exitWith {};
if (_button isEqualTo 1) exitWith {};

A3C_UI_CustomFormation_BOOL_isMouseUp = false;
A3C_UI_CustomFormation_BOOL_DRAW = false;
A3C_UI_CustomFormation_BOOL_ALLOW = true;

private _selectedUnits = uiNamespace getVariable [
    "A3C_UI_CustomFormation_selectedUnits",
    []
];

if (_selectedUnits isEqualTo []) exitWith {};

[] spawn {
    sleep 2;
    A3C_UI_CustomFormation_BOOL_ALLOW = false;
};

with uiNamespace do {
    private _dotCollectionName = switch (A3C_C_FORM_LineColor) do {
        case "#(argb,8,8,3)color(1,0,0,1)": {
            "A3C_UI_CustomFormation_Dots_RED"
        };
        case "#(argb,8,8,3)color(0,1,0,1)": {
            "A3C_UI_CustomFormation_Dots_GREEN"
        };
        case "#(argb,8,8,3)color(0,0,1,1)": {
            "A3C_UI_CustomFormation_Dots_BLUE"
        };
        case "#(argb,8,8,3)color(1,1,0,1)": {
            "A3C_UI_CustomFormation_Dots_YELLOW"
        };
        case "#(argb,8,8,3)color(1,1,1,1)": {
            "A3C_UI_CustomFormation_Dots_MAIN"
        };
        case "#(argb,8,8,3)color(0.53,0.29,0.69,1)": {
            "A3C_UI_CustomFormation_Dots_ALL"
        };
        default {
            ""
        };
    };

    if !(_dotCollectionName isEqualTo "") then {
        uiNamespace setVariable [
            _dotCollectionName,
            +A3C_UI_CustomFormation_Dots
        ];
    };

    A3C_UI_CustomFormation_Dots = [];

    private _poses = A3C_UI_CustomFormation_Poses;
    private _poseCount = count _poses;
    private _selectedUnitCount = count A3C_UI_CustomFormation_selectedUnits;

    A3C_UI_CustomFormation_lineLength = 0;

    {
        if (_forEachIndex > 0) then {
            private _previousPos = _poses select (_forEachIndex - 1);

            A3C_UI_CustomFormation_lineLength =
                A3C_UI_CustomFormation_lineLength
                + (_x distance _previousPos);
        };
    } forEach _poses;

    private _spacing =
        A3C_UI_CustomFormation_lineLength
        / _selectedUnitCount;

    private _realPoses = [_poses select 0];

    {
        if (_forEachIndex > 0) then {
            private _previousAcceptedPos = _realPoses select ((count _realPoses) - 1);
            private _distanceFromPrevious = _x distance _previousAcceptedPos;

            if (_distanceFromPrevious >= _spacing) then {
                _realPoses pushBack _x;
            } else {
                private _isLastPose = (_forEachIndex + 1) isEqualTo _poseCount;
                private _needsFinalPose = (count _realPoses) != _selectedUnitCount;

                if (_isLastPose && {_needsFinalPose}) then {
                    _realPoses pushBack _x;
                };
            };
        };
    } forEach _poses;

    {
        private _formationPos = _realPoses select _forEachIndex;
        private _formationDistance = player distance _formationPos;
        private _formationDirection = player getRelDir _formationPos;

        _x setVariable [
            "A3C_FORM",
            [_formationDistance, _formationDirection],
            false
        ];
    } forEach A3C_UI_CustomFormation_selectedUnits;
};