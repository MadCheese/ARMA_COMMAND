#include "..\script_component.hpp"

// A3C_UI_customFormation_fnc_sampleFormationStroke
//
// Samples a stored relative stroke into exactly one formation position per
// requested unit.
//
// Input stroke points:
//     [
//         [relativeDistance, relativeDirection],
//         ...
//     ]
//
// Returns:
//     [
//         [formationDistance, relativeDirection],
//         ...
//     ]
//
// The result count either exactly matches _sampleCount or is empty.

params [
    ["_relativePoints", [], [[]]],
    ["_sampleCount", 0, [0]]
];

if (_sampleCount <= 0) exitWith {
    []
};

if (_relativePoints isEqualTo []) exitWith {
    []
};

private _invalidPointIndex =
    _relativePoints findIf {
        !(
            [_x] call FUNC(isValidFormationData)
        )
    };

if (_invalidPointIndex >= 0) exitWith {
    []
};

/*
    Preserve the existing one-unit drawing behavior: the first stroke point
    is assigned to the only unit.
*/
if (_sampleCount isEqualTo 1) exitWith {
    [
        +(_relativePoints select 0)
    ]
};

/*
    Convert polar formation data into local Cartesian coordinates.

    Local positive Y is forward.
    Local positive X is right.
*/
private _localPoints = _relativePoints apply {
    _x params [
        "_distance",
        "_direction"
    ];

    [
        (sin _direction) * _distance,
        (cos _direction) * _distance
    ]
};

private _pointCount =
    count _localPoints;

if (_pointCount isEqualTo 1) exitWith {
    private _singlePoint =
        +(_relativePoints select 0);

    private _result = [];

    for "_index" from 0 to (_sampleCount - 1) do {
        _result pushBack
            +_singlePoint;
    };

    _result
};

/*
    Calculate the length of every Cartesian stroke segment.
*/
private _segmentLengths = [];
private _totalLength = 0;

for "_pointIndex" from 1 to (_pointCount - 1) do {
    private _previousPoint =
        _localPoints select (_pointIndex - 1);

    private _currentPoint =
        _localPoints select _pointIndex;

    private _segmentLength =
        _previousPoint distance2D
            _currentPoint;

    _segmentLengths pushBack
        _segmentLength;

    _totalLength =
        _totalLength
        + _segmentLength;
};

/*
    A point-only or zero-length stroke assigns every unit to the same slot.
*/
if (_totalLength <= 0.001) exitWith {
    private _singlePoint =
        +(_relativePoints select 0);

    private _result = [];

    for "_index" from 0 to (_sampleCount - 1) do {
        _result pushBack
            +_singlePoint;
    };

    _result
};

private _spacing =
    _totalLength
    / (_sampleCount - 1);

private _result = [];

for "_sampleIndex" from 0 to (_sampleCount - 1) do {
    private _targetDistance =
        _spacing
        * _sampleIndex;

    /*
        Ensure the final unit receives the exact final stroke point.
    */
    if (
        _sampleIndex
        isEqualTo
        (_sampleCount - 1)
    ) then {
        _targetDistance =
            _totalLength;
    };

    private _samplePoint =
        +(_localPoints select (_pointCount - 1));

    private _distanceBeforeSegment = 0;

    for "_segmentIndex" from 0 to ((count _segmentLengths) - 1) do {
        private _segmentLength =
            _segmentLengths select
                _segmentIndex;

        private _segmentEndDistance =
            _distanceBeforeSegment
            + _segmentLength;

        if (
            (_targetDistance <= _segmentEndDistance)
            || {
                _segmentIndex
                isEqualTo
                ((count _segmentLengths) - 1)
            }
        ) exitWith {
            private _startPoint =
                _localPoints select
                    _segmentIndex;

            private _endPoint =
                _localPoints select
                    (_segmentIndex + 1);

            private _segmentProgress = if (
                _segmentLength <= 0.001
            ) then {
                0
            } else {
                (
                    _targetDistance
                    - _distanceBeforeSegment
                )
                / _segmentLength
            };

            _samplePoint = [
                (_startPoint select 0)
                + (
                    (
                        (_endPoint select 0)
                        - (_startPoint select 0)
                    )
                    * _segmentProgress
                ),

                (_startPoint select 1)
                + (
                    (
                        (_endPoint select 1)
                        - (_startPoint select 1)
                    )
                    * _segmentProgress
                )
            ];
        };

        _distanceBeforeSegment =
            _segmentEndDistance;
    };

    private _formationDistance =
        [0, 0] distance2D
            _samplePoint;

    private _relativeDirection =
        [0, 0] getDir
            _samplePoint;

    _result pushBack [
        _formationDistance,
        _relativeDirection
    ];
};

if (
    (count _result)
    isNotEqualTo
    _sampleCount
) exitWith {
    []
};

_result