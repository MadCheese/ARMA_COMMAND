private _count = count A3C_UI_squadPlacement_units;
if (_count == 0) exitWith {};

private _altAmount = _count - 1;
private _watchDir = [A3C_FORMATION_DIR + 180] call MCSS_fnc_CorrectDir;

private _setUnitGhostDir = {
    params ["_index", "_dir"];

    if ((count A3C_UI_squadPlacement_units) == 0) exitWith {};
    if (_index >= (count A3C_UI_squadPlacement_units)) exitWith {};

    private _unit = A3C_UI_squadPlacement_units select _index;
    private _hudData = _unit getVariable ["A3C_HUD_DATA", []];

    if ((count _hudData) == 0) exitWith {};

    private _unitGhost = _hudData select 0;

    if !(isNull _unitGhost) then {
        _unitGhost setDir _dir;
    };
};

if (_count == 1) then {
    if !(A3C_HUD_FORM == 7) then {
        [0, _watchDir] call _setUnitGhostDir;
    };
} else {
    switch (A3C_HUD_FORM) do {
        case 0: {
            // Line left.
            private _divisor = 180 / _altAmount;

            for "_i" from 0 to _altAmount do {
                [_i, _watchDir + (_divisor * _i)] call _setUnitGhostDir;
            };
        };

        case 1: {
            // Line right.
            private _divisor = 180 / _altAmount;

            for "_i" from 0 to _altAmount do {
                [_i, _watchDir - (_divisor * _i)] call _setUnitGhostDir;
            };
        };

        case 2: {
            // Line front.
            private _lineFrontDir = if (A3C_HUD_SNAP) then {
                profileNamespace getVariable ["A3C_EHM_DIR", _watchDir + 90]
            } else {
                _watchDir + 90
            };

            for "_i" from 0 to _altAmount do {
                [_i, _lineFrontDir] call _setUnitGhostDir;
            };
        };

        case 3: {
            // L form right.
            private _divisor = 270 / _altAmount;

            for "_i" from 0 to _altAmount do {
                [_i, _watchDir - (_divisor * _i)] call _setUnitGhostDir;
            };
        };

        case 4: {
            // L form left.
            private _divisor = 270 / _altAmount;

            for "_i" from 0 to _altAmount do {
                [_i, _watchDir + (_divisor * _i)] call _setUnitGhostDir;
            };
        };

        case 5;
        case 6: {
            // Staggered column left/right.
            for "_i" from 0 to _altAmount do {
                [_i, _watchDir] call _setUnitGhostDir;
            };
        };

        // Skip 7: circle formation handles direction in createFormation.

        case 8: {
            // Enhanced movement.
            private _ehmDir = profileNamespace getVariable ["A3C_EHM_DIR", _watchDir];

            for "_i" from 0 to _altAmount do {
                [_i, _ehmDir] call _setUnitGhostDir;
            };
        };
    };
};

// Rotate UI icon.
private _overlayDisplay = uiNamespace getVariable ["A3C_UI_squadPlacement_overlay", displayNull];
if (isNull _overlayDisplay) exitWith {};

private _formImage = _overlayDisplay displayCtrl 12;
if (isNull _formImage) exitWith {};

if !(A3C_HUD_FORM in [7, 8]) then {
    if ((count A3C_UI_squadPlacement_unitGhosts) > 0) then {
        private _p1 = AGLToASL positionCameraToWorld [0, 0, 0];
        private _p2 = AGLToASL positionCameraToWorld [0, 0, 10];
        private _playerDir = _p1 getDir _p2;

        if (A3C_HUD_FORM == 2) then {
            _playerDir = _playerDir - 90;
        };

        private _relDir = [A3C_FORMATION_DIR + 180 - _playerDir] call MCSS_fnc_CorrectDir;
        _formImage ctrlSetAngle [_relDir, 0.5, 0.5];
    };
} else {
    _formImage ctrlSetAngle [0, 0.5, 0.5];
};