#include "..\..\script_component.hpp"

private _useCursorPos = true;
private _objectCollision = [];
private _aimingHeight = 0;
private _aimingHeightThreshold = 1;
private _exit = false;
private _params = [];
private _aimPos = [];

A3C_HUD_Snap = false;
A3C_HUD_POS_PAST = screenToWorld [0.5, 0.5];
A3C_HUD_POS_NOW = A3C_HUD_POS_PAST;
A3C_HUD_TRAVEL_DIR = 0;
A3C_HUD_CHECKPOS = A3C_HUD_POS_PAST;

{
    inGameUISetEventHandler [_x, "true"];
} forEach ["PrevAction", "NextAction"];

while {(count A3C_UI_squadPlacement_unitGhosts) > 0} do {
    _useCursorPos = true;
    _exit = false;
    _aimingHeight = 0;
    A3C_HUD_COLLIDER = objNull;

    if ((count A3C_UI_squadPlacement_unitGhosts) == 0) exitWith {};

    private _excludeObjects = nearestTerrainObjects [
        position (A3C_UI_squadPlacement_unitGhosts select 0),
        ["BUSH"],
        (count A3C_UI_squadPlacement_unitGhosts) * A3C_HUD_SPACING
    ];

    if !(A3C_MODIFIER_LOCK) then {
        _objectCollision = lineIntersectsSurfaces [
            AGLToASL positionCameraToWorld [0, 0, 0],
            AGLToASL positionCameraToWorld [0, 0, viewDistance],
            vehicle cameraOn,
            objNull,
            true,
            -1,
            "GEOM",
            "NONE"
        ];

        _objectCollision = _objectCollision select {
            private _obj = _x select 2;
            !(_obj in (_excludeObjects + A3C_UI_squadPlacement_unitGhosts))
        };

        if ((count _objectCollision) > 0) then {
            if !(isNull cursorTarget) then {
                if (([cursorTarget] call MCSS_fnc_countBPos) > 0) then {
                    _aimPos = (_objectCollision select 0) select 0;
                    _aimingHeight = if !(isNil "_aimPos") then {
                        (ASLToATL _aimPos) select 2
                    } else {
                        (boundingBoxReal cursorTarget select 1) select 2
                    };

                    if (_aimingHeight < _aimingHeightThreshold) then {
                        _useCursorPos = true;
                    } else {
                        _useCursorPos = false;
                        A3C_UI_squadPlacement_unitGhostsInBuilding = true;

                        [cursorTarget, _aimPos] call FUNC(createBuildingFormation);
                    };
                };
            };
        };

        if (_useCursorPos) then {
            A3C_UI_squadPlacement_unitGhostsInBuilding = false;

            (A3C_UI_squadPlacement_unitGhosts select 0) setDir ([A3C_FORMATION_DIR + 180] call MCSS_fnc_CorrectDir);

            {
                _x setVariable ["A3C_ARROW_BPOS", [0, 0], true];
            } forEach A3C_UI_squadPlacement_unitGhosts;

            if !(A3C_MODIFIER_LOCK) then {
                if (((screenToWorld [0.5, 0.5]) distance A3C_HUD_POS_NOW) > 0.04) then {
                    A3C_HUD_POS_NOW = screenToWorld [0.5, 0.5];
                    A3C_HUD_TRAVEL_DIR = [A3C_HUD_POS_PAST, A3C_HUD_POS_NOW] call BIS_fnc_dirTo;
                };

                A3C_HUD_POS_PAST = screenToWorld [0.5, 0.5];

                if ((count _objectCollision) > 0) then {
                    A3C_HUD_COLLIDER = (_objectCollision select 0) select 2;
                } else {
                    A3C_HUD_COLLIDER = objNull;
                };

                if !(isNull A3C_HUD_COLLIDER) then {
                    if ((speed A3C_HUD_COLLIDER) < 0.2) then {
                        A3C_HUD_Snap_DIR = 0;
                        A3C_HUD_Snap = true;
                        A3C_HUD_FormDir_Old = A3C_FORMATION_DIR;

                        while {(count A3C_UI_squadPlacement_unitGhosts) > 0} do {
                            private _snapExcludeObjects = nearestTerrainObjects [
                                position (A3C_UI_squadPlacement_unitGhosts select 0),
                                ["BUSH"],
                                (count A3C_UI_squadPlacement_unitGhosts) * A3C_HUD_SPACING
                            ];

                            _objectCollision = lineIntersectsSurfaces [
                                AGLToASL positionCameraToWorld [0, 0, 0],
                                AGLToASL positionCameraToWorld [0, 0, viewDistance],
                                vehicle player,
                                objNull,
                                true,
                                -1,
                                "GEOM",
                                "NONE"
                            ];

                            _objectCollision = _objectCollision select {
                                private _obj = _x select 2;
                                !(_obj in (_snapExcludeObjects + A3C_UI_squadPlacement_unitGhosts))
                            };

                            if ((count _objectCollision) > 0) then {
                                A3C_HUD_NORMAL = (_objectCollision select 0) select 1;
                                A3C_HUD_COLLIDER = (_objectCollision select 0) select 2;

                                if !(isNull cursorTarget) then {
                                    for "_i" from 0 to 2 do {
                                        A3C_HUD_NORMAL set [
                                            _i,
                                            if ((A3C_HUD_NORMAL select _i) == 0) then {
                                                0
                                            } else {
                                                [A3C_HUD_NORMAL select _i, 2] call BIS_fnc_cutDecimals
                                            }
                                        ];
                                    };

                                    if (([cursorTarget] call MCSS_fnc_countBPos) > 0) then {
                                        private _collisionPos = (_objectCollision select 0) select 0;
                                        _aimingHeight = (ASLToATL _collisionPos) select 2;

                                        if (_aimingHeight > _aimingHeightThreshold) then {
                                            _exit = true;
                                        };
                                    };
                                };
                            };

                            [] call FUNC(orientUnitGhosts);

                            if ((count _objectCollision) == 0) then {
                                _exit = true;
                            };

                            if !(isNull A3C_HUD_COLLIDER) then {
                                if ((speed A3C_HUD_COLLIDER) > 1) then {
                                    _exit = true;
                                };
                            };

                            if ((count _objectCollision) > 0) then {
                                if !(isNull cursorTarget) then {
                                    if !(isNull A3C_HUD_COLLIDER) then {
                                        if (cursorTarget == A3C_HUD_COLLIDER) then {
                                            if (([cursorTarget] call MCSS_fnc_countBPos) > 0) then {
                                                private _collisionPos = (_objectCollision select 0) select 0;
                                                _aimingHeight = (ASLToATL _collisionPos) select 2;

                                                if (_aimingHeight > _aimingHeightThreshold) then {
                                                    _exit = true;
                                                };
                                            };
                                        };
                                    };
                                };
                            };

                            if (_exit) exitWith {};

                            if !(isNull A3C_HUD_COLLIDER) then {
                                _params = [
                                    (_objectCollision select 0) select 0,
                                    A3C_HUD_COLLIDER
                                ] call FUNC(snapFormation);

                                if (A3C_HUD_FORM in [2, 8]) then {
                                    profileNamespace setVariable ["A3C_EHM_DIR", _params select 2];
                                };

                                [_params select 0] call FUNC(createFormation);
                            } else {
                                _exit = true;
                            };

                            sleep 0.1;
                        };

                        A3C_FORMATION_DIR = A3C_HUD_FormDir_Old;
                        A3C_HUD_Snap = false;
                        A3C_HUD_COLLIDER = objNull;
                        _exit = false;
                        _useCursorPos = false;
                    } else {
                        A3C_HUD_Snap = false;
                    };
                } else {
                    A3C_HUD_Snap = false;
                };

                if (_useCursorPos) then {
                    [A3C_HUD_POS_NOW] call FUNC(createFormation);
                };

                _objectCollision = [];
            };
        };

        [] call FUNC(orientUnitGhosts);

        sleep 0.05;
    } else {
        if !(A3C_UI_squadPlacement_unitGhostsInBuilding) then {
            [screenToWorld [0.5, 0.5]] call FUNC(createFormation);
        };
    };
};