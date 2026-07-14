#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_drawDot
//
// Records one raw stroke point and, when possible, creates a thick line
// segment from the previous point.
//
// Raw points remain authoritative for formation sampling and exact-stroke
// persistence. Normal live strokes do not create visible point markers.

params [
    "_gridX",
    "_gridY"
];

private _display = uiNamespace getVariable [
    QGVAR(display),
    displayNull
];

if (isNull _display) exitWith {};

private _relativeData = [
    _gridX,
    _gridY
] call FUNC(getRelativeData);

if !(
    [_relativeData] call FUNC(isValidFormationData)
) exitWith {};

_relativeData params [
    "_relativeDistance",
    "_relativeDirection"
];

private _controls = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Dots",
    []
];

private _poses = uiNamespace getVariable [
    "A3C_UI_CustomFormation_Poses",
    []
];

private _relativePoints = uiNamespace getVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    []
];

private _lineColor = uiNamespace getVariable [
    "A3C_C_FORM_LineColor",
    "#(argb,8,8,3)color(0.53,0.29,0.69,1)"
];

/*
    Connect the previous recorded point to the new point.

    The first point intentionally creates no visible control. It remains
    available as stroke data and becomes the beginning of the first segment.

    If the completed stroke never produces a valid segment, the restore
    function creates one marker so a click or zero-length stroke remains
    visible.
*/
if !(_relativePoints isEqualTo []) then {
    private _previousRelativePoint =
        _relativePoints select
            ((count _relativePoints) - 1);

    private _previousGridPosition = [
        _previousRelativePoint
    ] call FUNC(getGridPositionFromRelativeData);

    if ((count _previousGridPosition) >= 2) then {
        private _segmentControls = [
            _display,
            _previousGridPosition,
            [_gridX, _gridY],
            _lineColor
        ] call FUNC(createVisualLine);

        _controls append
            _segmentControls;
    };
};

/*
    Preserve the complete raw stroke in player-relative coordinates.
*/
_relativePoints pushBack
    +_relativeData;

private _relativePosition = player getRelPos [
    _relativeDistance,
    _relativeDirection
];

_relativePosition set [
    2,
    0
];

_poses pushBack
    _relativePosition;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Dots",
    _controls
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_Poses",
    _poses
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_RelativePoints",
    _relativePoints
];