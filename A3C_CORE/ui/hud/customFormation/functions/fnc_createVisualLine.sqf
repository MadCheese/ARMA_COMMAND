#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_createVisualLine
//
// Creates a thick visual line between two dialog-grid positions.
//
// ST_LINE has no configurable thickness. Thickness is emulated by creating
// five parallel ST_LINE controls offset perpendicular to the segment.
//
// Returns:
//     Array of created controls.
//     An empty array is returned when the segment is invalid.

disableSerialization;

params [
    ["_display", displayNull, [displayNull]],
    ["_startPosition", [], [[]]],
    ["_endPosition", [], [[]]],
    ["_colorTexture", "", [""]]
];

if (isNull _display) exitWith {
    []
};

if (
    (count _startPosition) < 2
    || {
        (count _endPosition) < 2
    }
) exitWith {
    []
};

private _startX =
    _startPosition select 0;

private _startY =
    _startPosition select 1;

private _endX =
    _endPosition select 0;

private _endY =
    _endPosition select 1;

private _width =
    _endX - _startX;

private _height =
    _endY - _startY;

if (
    (abs _width) < 0.00001
    && {
        (abs _height) < 0.00001
    }
) exitWith {
    []
};

private _color = switch (_colorTexture) do {
    case "#(argb,8,8,3)color(1,0,0,1)": {
        [1, 0, 0, 0.8]
    };

    case "#(argb,8,8,3)color(0,1,0,1)": {
        [0, 1, 0, 0.8]
    };

    case "#(argb,8,8,3)color(0,0,1,1)": {
        [0, 0, 1, 0.8]
    };

    case "#(argb,8,8,3)color(1,1,0,1)": {
        [1, 1, 0, 0.8]
    };

    case "#(argb,8,8,3)color(1,1,1,1)": {
        [1, 1, 1, 0.8]
    };

    case "#(argb,8,8,3)color(0.53,0.29,0.69,1)": {
        [0.53, 0.29, 0.69, 0.8]
    };

    default {
        [1, 1, 1, 0.8]
    };
};

/*
    These dimensions match the visual dot dimensions.

    The segment is normalized in dot-coordinate units so the perpendicular
    offset remains visually consistent across screen aspect ratios.
*/
private _dotWidth =
    0.005 * (safeZoneH / safeZoneW);

private _dotHeight =
    0.005 * safeZoneH;

if (
    (_dotWidth <= 0)
    || {_dotHeight <= 0}
) exitWith {
    []
};

private _normalizedX =
    _width / _dotWidth;

private _normalizedY =
    _height / _dotHeight;

private _normalizedLength = sqrt (
    (_normalizedX * _normalizedX)
    + (_normalizedY * _normalizedY)
);

if (_normalizedLength <= 0.00001) exitWith {
    []
};

/*
    Unit-length vector perpendicular to the segment in normalized screen
    space.
*/
private _perpendicularX =
    -_normalizedY
    / _normalizedLength;

private _perpendicularY =
    _normalizedX
    / _normalizedLength;

/*
    Five parallel lines spanning roughly 60 percent of the dot diameter.

    To reduce the brush to three lines later, use:
        [-0.22, 0, 0.22]
*/
private _brushOffsets = [
    -0.30,
    -0.15,
    0,
    0.15,
    0.30
];

private _lines = [];

{
    private _offsetX =
        _perpendicularX
        * _dotWidth
        * _x;

    private _offsetY =
        _perpendicularY
        * _dotHeight
        * _x;

    private _line = _display ctrlCreate [
        "A3C_CustomFormation_Line",
        -1
    ];

    if !(isNull _line) then {
        _line ctrlSetTextColor
            _color;

        _line ctrlSetPosition [
            _startX + _offsetX,
            _startY + _offsetY,
            _width,
            _height
        ];

        _line ctrlCommit 0;

        _lines pushBack
            _line;
    };
} forEach _brushOffsets;

_lines