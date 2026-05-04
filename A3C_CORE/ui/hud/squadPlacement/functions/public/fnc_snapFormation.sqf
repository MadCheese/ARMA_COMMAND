#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_cursorPos", "_object"];

_cursorPos = +_cursorPos;
_cursorPos set [2, 0];

private _objectHeight = (_object call BIS_fnc_objectHeight) * 0.3;
private _normalDirAZM = [0, 0] getDir (A3C_HUD_NORMAL select [0, 2]);
private _watchOverDir = [_normalDirAZM + 180] call MCSS_fnc_CorrectDir;

if ((A3C_HUD_FORM == 7) || {visibleMap}) exitWith {
    _cursorPos = [
        _cursorPos,
        A3C_HUD_RADIUS + 1.2,
        _normalDirAZM
    ] call BIS_fnc_relPos;

    [
        _cursorPos,
        A3C_FORMATION_DIR,
        _watchOverDir
    ]
};

_cursorPos = [_cursorPos, 1, _normalDirAZM] call BIS_fnc_relPos;

private _objectDir = getDir _object;
private _directionOption1 = [_normalDirAZM + 90] call MCSS_fnc_CorrectDir;
private _directionOption2 = [_directionOption1 + 180] call MCSS_fnc_CorrectDir;

private _endUnitSpacingCount = count A3C_UI_squadPlacement_unitGhosts;
_endUnitSpacingCount = switch (true) do {
    case (A3C_HUD_FORM in [0, 1, 2, 8]): {
        _endUnitSpacingCount
    };
    case (A3C_HUD_FORM in [3, 4]): {
        (ceil (_endUnitSpacingCount / 2)) + 1
    };
    case (A3C_HUD_FORM in [5, 6]): {
        ceil (_endUnitSpacingCount / 2)
    };
    default {
        _endUnitSpacingCount
    };
};

if (A3C_DEBUG) then {
    RED_LINES = [];
    GREEN_LINES = [];
};

private _formationDir = 0;

// Step 1: get main formation direction.
private _excludeObjects = nearestTerrainObjects [_cursorPos, ["BUSH"], _endUnitSpacingCount * A3C_HUD_SPACING];

private _coverFnc = {
    params [
        "_object",
        "_cursorPos",
        "_objectHeight",
        "_testDir",
        "_endUnitSpacingCount",
        "_watchOverDir",
        "_excludeObjects",
        "_mode"
    ];

    private _allCovered = [true, 0];

    _objectHeight = _objectHeight min 2;

    private _refPos = (getPosASL (A3C_UI_squadPlacement_unitGhosts select 0)) vectorAdd [0, 0, 0.5];

    if (_mode != 0) then {
        _refPos = _refPos vectorAdd [0, 0, 0.2];
    };

    for "_i" from 0 to (_endUnitSpacingCount - 1) do {
        private _refPos1 = [
            _refPos,
            A3C_HUD_SPACING * _i,
            _testDir
        ] call BIS_fnc_relPos;

        private _refPos2 = [
            _refPos1,
            1.5,
            _watchOverDir
        ] call BIS_fnc_relPos;

        if (A3C_DEBUG) then {
            if (_mode != 0) then {
                GREEN_LINES pushBack [_refPos1, _refPos2];
            } else {
                RED_LINES pushBack [_refPos1, _refPos2];
            };
        };

        private _intersections = lineIntersectsSurfaces [
            _refPos1,
            _refPos2,
            player,
            objNull,
            true,
            -1,
            "GEOM",
            "NONE"
        ];

        _intersections = _intersections select {
            private _intersectObject = _x select 2;
            !(_intersectObject in _excludeObjects) && {!(_intersectObject isKindOf "MAN")}
        };

        if ((count _intersections) > 0) then {
            _allCovered = [false, (_endUnitSpacingCount - _i) max 0];
        };
    };

    _allCovered
};

private _dir1IsCovered = [
    _object,
    _cursorPos,
    _objectHeight,
    _directionOption1,
    _endUnitSpacingCount,
    _watchOverDir,
    _excludeObjects,
    0
] call _coverFnc;

private _dir2IsCovered = [
    _object,
    _cursorPos,
    _objectHeight,
    _directionOption2,
    _endUnitSpacingCount,
    _watchOverDir,
    _excludeObjects,
    1
] call _coverFnc;

if ((_dir1IsCovered select 1) <= (_dir2IsCovered select 1)) then {
    _formationDir = _directionOption1;
} else {
    _formationDir = _directionOption2;
};

// Repeat priority check to flip formation if direction intersects with building.
private _refPos = (getPosASL (A3C_UI_squadPlacement_unitGhosts select 0)) vectorAdd [0, 0, _objectHeight];

private _intersections = lineIntersectsSurfaces [
    _refPos,
    [
        _refPos,
        (A3C_HUD_SPACING * (_endUnitSpacingCount - 1)) + 1.2,
        _formationDir
    ] call BIS_fnc_relPos,
    player,
    objNull,
    true,
    1,
    "GEOM",
    "NONE"
];

_intersections = _intersections select {
    private _intersectObject = _x select 2;
    !(_intersectObject in _excludeObjects) && {!(_intersectObject isKindOf "MAN")}
};

if ((count _intersections) > 0) then {
    _formationDir = [_formationDir + 180] call MCSS_fnc_CorrectDir;
};

// Step 2: adjust main formation direction and formation variation relative to snap data.
private _adjustFormLine = 0;
private _adjustFormL = 3;
private _adjustFormStag = 5;

private _relDir = [round (_normalDirAZM - _objectDir)] call MCSS_fnc_CorrectDir;
private _relFormDir = [round (_formationDir - _objectDir)] call MCSS_fnc_CorrectDir;

switch (true) do {
    case (_relDir < 90): {
        switch (true) do {
            case (A3C_HUD_FORM in [0, 1]): {
                if (_relFormDir == 270) then {
                    _adjustFormLine = 1;
                };
            };
            case (A3C_HUD_FORM in [3, 4]): {
                if (_relFormDir == 270) then {
                    _adjustFormL = 4;
                };
            };
            case (A3C_HUD_FORM in [5, 6]): {
                if (_relFormDir == 270) then {
                    _adjustFormStag = 6;
                };
            };
        };
    };

    case ((_relDir >= 90) && {_relDir < 180}): {
        switch (true) do {
            case (A3C_HUD_FORM in [0, 1]): {
                if (_relFormDir == 0) then {
                    _adjustFormLine = 1;
                };
            };
            case (A3C_HUD_FORM in [3, 4]): {
                if (_relFormDir == 0) then {
                    _adjustFormL = 4;
                };
            };
            case (A3C_HUD_FORM in [5, 6]): {
                if (_relFormDir == 0) then {
                    _adjustFormStag = 6;
                };
            };
        };
    };

    case ((_relDir >= 180) && {_relDir < 270}): {
        switch (true) do {
            case (A3C_HUD_FORM in [0, 1]): {
                if (_relFormDir == 90) then {
                    _adjustFormLine = 1;
                };
            };
            case (A3C_HUD_FORM in [3, 4]): {
                if (_relFormDir == 90) then {
                    _adjustFormL = 4;
                };
            };
            case (A3C_HUD_FORM in [5, 6]): {
                if (_relFormDir == 90) then {
                    _adjustFormStag = 6;
                };
            };
        };
    };

    case (_relDir >= 270): {
        switch (true) do {
            case (A3C_HUD_FORM in [0, 1]): {
                if (_relFormDir == 180) then {
                    _adjustFormLine = 1;
                };
            };
            case (A3C_HUD_FORM in [3, 4]): {
                if (_relFormDir == 180) then {
                    _adjustFormL = 4;
                };
            };
            case (A3C_HUD_FORM in [5, 6]): {
                if (_relFormDir == 180) then {
                    _adjustFormStag = 6;
                };
            };
        };
    };
};

if (A3C_HUD_FORM in [3, 4]) then {
    // Subtract 2 because this scans ahead of formation and excludes leader.
    _endUnitSpacingCount = _endUnitSpacingCount - 2;

    private _testDir = [_formationDir + 180] call MCSS_fnc_CorrectDir;

    _refPos = (getPosASL (A3C_UI_squadPlacement_unitGhosts select 0)) vectorAdd [0, 0, _objectHeight];

    private _refPos1 = [
        _refPos,
        A3C_HUD_SPACING * (_endUnitSpacingCount max 0),
        _testDir
    ] call BIS_fnc_relPos;

    private _refPos2 = [
        _refPos1,
        5,
        _watchOverDir
    ] call BIS_fnc_relPos;

    private _intersectObjects = lineIntersectsObjs [
        _refPos1,
        _refPos2,
        objNull,
        objNull,
        false
    ];

    if !(_object in _intersectObjects) then {
        _formationDir = _testDir;
    };

    A3C_HUD_FORM = _adjustFormL;

    A3C_HUD_FORM_ICON = switch (A3C_HUD_FORM) do {
        case 3: {"A3C_CORE\ui\pictures\icon_formSec_L_Right.paa"};
        case 4: {"A3C_CORE\ui\pictures\icon_formSec_L_Left.paa"};
        default {"A3C_CORE\ui\pictures\icon_formSec_L_Right.paa"};
    };
};

switch (true) do {
    case (A3C_HUD_FORM in [0, 1]): {
        A3C_HUD_FORM = _adjustFormLine;

        A3C_HUD_FORM_ICON = switch (A3C_HUD_FORM) do {
            case 0: {"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa"};
            case 1: {"A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa"};
            default {"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa"};
        };
    };

    case (A3C_HUD_FORM in [5, 6]): {
        A3C_HUD_FORM = _adjustFormStag;
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";
    };
};

private _formImage = ["overlayFormImage"] call FUNC(ctrl);
if !(isNull _formImage) then {
    _formImage ctrlSetText A3C_HUD_FORM_ICON;
};

// Assign formation direction at the end so formation does not flicker.
A3C_FORMATION_DIR = _formationDir;

[
    _cursorPos,
    A3C_FORMATION_DIR,
    _watchOverDir
]