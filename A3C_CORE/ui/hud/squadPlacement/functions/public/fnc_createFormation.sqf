params ["_cursorPos"];

if ((count A3C_UI_squadPlacement_unitGhosts) == 0) exitWith {};

if (A3C_MODIFIER_LOCK) then {
    _cursorPos = position (A3C_UI_squadPlacement_unitGhosts select 0);
};

private _offset = A3C_HUD_SPACING;
private _amount = count A3C_UI_squadPlacement_unitGhosts;
private _formationDir = A3C_FORMATION_DIR + A3C_NUM_DIR;

switch (A3C_HUD_FORM) do {
    case 0;
    case 1;
    case 2;
    case 8: {
        for "_i" from 0 to (_amount - 1) do {
            private _unitGhost = A3C_UI_squadPlacement_unitGhosts select _i;

            if (_i == 0) then {
                _unitGhost setPos [_cursorPos select 0, _cursorPos select 1, 0];
            } else {
                _unitGhost setPos ([
                    A3C_UI_squadPlacement_unitGhosts select 0,
                    _offset * _i,
                    _formationDir
                ] call BIS_fnc_relPos);
            };
        };
    };

    case 3: {
        // L formation right.
        (A3C_UI_squadPlacement_unitGhosts select 0) setPos [_cursorPos select 0, _cursorPos select 1, 0];

        for "_i" from 1 to (_amount - 1) do {
            private _dirParams = if (_i >= (_amount / 2)) then {
                _formationDir - 90
            } else {
                _formationDir
            };

            (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                A3C_UI_squadPlacement_unitGhosts select (_i - 1),
                _offset,
                _dirParams
            ] call BIS_fnc_relPos);
        };
    };

    case 4: {
        // L formation left.
        (A3C_UI_squadPlacement_unitGhosts select 0) setPos [_cursorPos select 0, _cursorPos select 1, 0];

        for "_i" from 1 to (_amount - 1) do {
            private _dirParams = if (_i >= (_amount / 2)) then {
                _formationDir + 90
            } else {
                _formationDir
            };

            (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                A3C_UI_squadPlacement_unitGhosts select (_i - 1),
                _offset,
                _dirParams
            ] call BIS_fnc_relPos);
        };
    };

    case 5: {
        // Staggered column / cube formation right.
        (A3C_UI_squadPlacement_unitGhosts select 0) setPos [_cursorPos select 0, _cursorPos select 1, 0];

        private _switchMode = 0;

        for "_i" from 1 to (_amount - 1) do {
            if (_switchMode == 0) then {
                (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                    A3C_UI_squadPlacement_unitGhosts select (_i - 1),
                    _offset,
                    _formationDir - 90
                ] call BIS_fnc_relPos);

                _switchMode = 1;
            } else {
                (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                    A3C_UI_squadPlacement_unitGhosts select (_i - 2),
                    _offset,
                    _formationDir
                ] call BIS_fnc_relPos);

                _switchMode = 0;
            };
        };
    };

    case 6: {
        // Staggered column / cube formation left.
        (A3C_UI_squadPlacement_unitGhosts select 0) setPos [_cursorPos select 0, _cursorPos select 1, 0];

        private _switchMode = 0;

        for "_i" from 1 to (_amount - 1) do {
            if (_switchMode == 0) then {
                (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                    A3C_UI_squadPlacement_unitGhosts select (_i - 1),
                    _offset,
                    _formationDir + 90
                ] call BIS_fnc_relPos);

                _switchMode = 1;
            } else {
                (A3C_UI_squadPlacement_unitGhosts select _i) setPos ([
                    A3C_UI_squadPlacement_unitGhosts select (_i - 2),
                    _offset,
                    _formationDir
                ] call BIS_fnc_relPos);

                _switchMode = 0;
            };
        };
    };

    case 7: {
        // 360 security / circle formation.
        private _pos = [_cursorPos select 0, _cursorPos select 1, 0];
        private _step = 360 / _amount;

        A3C_HUD_RADIUS_MIN = 1;

        if (_amount > 1) then {
            while {true} do {
                if ((([_pos, A3C_HUD_RADIUS_MIN, 0] call BIS_fnc_relPos) distance2D ([_pos, A3C_HUD_RADIUS_MIN, _step] call BIS_fnc_relPos)) > 2) exitWith {};
                A3C_HUD_RADIUS_MIN = A3C_HUD_RADIUS_MIN + 1;
            };
        };

        if (A3C_HUD_RADIUS < A3C_HUD_RADIUS_MIN) then {
            A3C_HUD_RADIUS = A3C_HUD_RADIUS_MIN;
        };

        for "_i" from 0 to (_amount - 1) do {
            private _unitGhost = A3C_UI_squadPlacement_unitGhosts select _i;
            private _actualPos = [_pos, A3C_HUD_RADIUS, _i * _step] call BIS_fnc_relPos;
            private _dirArray = if (A3C_360_out) then {
                [_pos, _actualPos]
            } else {
                [_actualPos, _pos]
            };

            _unitGhost setPos _actualPos;
            _unitGhost setDir (_dirArray call BIS_fnc_dirTo);
        };
    };
};