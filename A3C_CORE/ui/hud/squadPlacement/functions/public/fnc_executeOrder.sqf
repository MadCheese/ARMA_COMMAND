#include "..\..\script_component.hpp"

params ["_alt", "_shft"];

private [
    "_arrow",
    "_activeUnits",
    "_movingUnits",
    "_storeData",
    "_dest",
    "_runningOrder",
    "_delay",
    "_timeOut",
    "_counter",
    "_exit",
    "_exitLoop"
];

_arrow = 0;
_activeUnits = [];
_movingUnits = [];
_storeData = [];
_dest = [];
_runningOrder = "ASCEND";
_delay = false;
_timeOut = 0;
_counter = 0;
_exit = false;
_exitLoop = false;

// Remove invalid unit references before taking snapshots.
A3C_UI_squadPlacement_units = A3C_UI_squadPlacement_units select {!isNull _x};

// Snapshot current state before UI cleanup can clear globals.
private _orderedUnits = +A3C_UI_squadPlacement_units;
private _orderedGhosts = +A3C_UI_squadPlacement_unitGhosts;
private _overrideMode = profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true];

if ((count _orderedUnits) == 0) exitWith {};

if (({_x getVariable ["A3C_PEEL_ACTIVE", false]} count _orderedUnits) > 0) then {
    {
        _x setVariable ["A3C_PEEL_ACTIVE", false, false];
    } forEach _orderedUnits;

    sleep 0.1;

    waitUntil {
        ({_x getVariable ["A3C_PEEL_ACTIVE", false]} count _orderedUnits) > 0
    };
};

if (_alt || _shft) then {
    {
        _x setVariable ["A3C_PEEL_ACTIVE", true, false];
    } forEach _orderedUnits;
} else {
    {
        _x setVariable ["A3C_PEEL_ACTIVE", false, false];
    } forEach _orderedUnits;
};

A3C_PEEL_ACTIVE = true;

// Take data from unit ghosts.
{
    private _hudData = _x getVariable ["A3C_HUD_DATA", []];

    if ((count _hudData) > 0) then {
        _arrow = _hudData select 0;

        if !(isNull _arrow) then {
            _storeData pushBack [
                _x,
                _arrow getVariable ["A3C_ARROW_BPOS", [0, 0]],
                getPosATL _arrow,
                getDir _arrow
            ];
        };
    };
} forEach _orderedUnits;

if ((count _storeData) == 0) exitWith {};

if (_alt) then {
    _runningOrder = "DESCEND";
    _delay = true;
    _timeOut = 2;
    A3C_PEELING = true;
};

if (_shft) then {
    _runningOrder = "ASCEND";
    _delay = true;
    _timeOut = 2;
    A3C_PEELING = true;
};

private _sortReference = if ((count _orderedGhosts) > 0) then {
    _orderedGhosts select 0
} else {
    (_storeData select 0) select 0
};

_storeData = [
    _storeData,
    [],
    {(_x select 0) distance _sortReference},
    _runningOrder
] call BIS_fnc_sortBy;

{
    _movingUnits pushBack (_x select 0);
} forEach _storeData;

// Remove indicators or spawn blink.
if (_overrideMode) then {
    if (!isNil "A3C_UI_squadPlacement_positionLoopHandle") then {
        terminate A3C_UI_squadPlacement_positionLoopHandle;
    };

    {
        if !(isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _orderedGhosts;

    {
        inGameUISetEventHandler [_x, "false"];
    } forEach ["PrevAction", "NextAction"];

    ("A3C_UI_squadPlacement_overlay" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
    profileNamespace setVariable ["A3C_UI_squadPlacement_overlayIsOpen", false];

    {
        _x setVariable ["A3C_HUD_DATA", [], true];
    } forEach _orderedUnits;

    A3C_UI_squadPlacement_units = [];
    A3C_UI_squadPlacement_unitGhosts = [];
} else {
    playSound "A3C_MenuSound1";

    {
        if !(isNull _x) then {
            _x spawn {
                for "_i" from 1 to 3 do {
                    _this hideObject true;
                    sleep 0.1;
                    _this hideObject false;
                    sleep 0.1;
                };
            };
        };
    } forEach _orderedGhosts;
};

// This can take time, so execute it after data is fetched.
if (_overrideMode) then {
    {
        if ((count (_x getVariable ["A3C_PLOT", []])) > 0) then {
            _activeUnits pushBack _x;
        };
    } forEach _orderedUnits;

    [_activeUnits, true, false] call A3C_AI_Shared_cancelUnitPlot;

    while {
        ({(count (_x getVariable ["A3C_PLOT", []])) > 0} count _activeUnits) > 0
    } do {
        sleep 0.1;
    };
};

{
    if (_alt) then {
        (_x select 0) disableAI "AUTOTARGET";
        (_x select 0) doTarget objNull;
    };

    _x pushBack A3C_HUD_FORM;
    _x spawn FUNC(executeUnitPlacement);

    if (_timeOut > 0) then {
        sleep 0.1;
        _dest = (expectedDestination (_x select 0)) select 0;

        while {true} do {
            if !((_x select 0) getVariable ["A3C_PEEL_ACTIVE", false]) exitWith {
                _exit = true;
                (_x select 0) setVariable ["A3C_PEEL_ACTIVE", true, false];
            };

            if (_forEachIndex <= ((count _storeData) - 2)) then {
                if (_alt) then {
                    if (((_x select 0) distance (_x select 2)) < 5) then {
                        _exitLoop = true;
                    };
                };

                if (_shft) then {
                    if (((_x select 0) distance ((_storeData select 0) select 0)) < (((_storeData select (_forEachIndex + 1)) select 0) distance ((_storeData select 0) select 0))) then {
                        _exitLoop = true;
                    };
                };
            } else {
                _exitLoop = true;
            };

            if !(alive (_x select 0)) then {
                _exitLoop = true;
            };

            if ((count ((_x select 0) getVariable ["A3C_PLOT", []])) > 0) then {
                _exitLoop = true;
            };

            if ((((expectedDestination (_x select 0)) select 0) distance _dest) > 1) then {
                _exitLoop = true;
            };

            if (currentCommand (_x select 0) == "STOP") then {
                _exitLoop = true;
            };

            if (_exitLoop) exitWith {
                _exitLoop = false;
                (_x select 0) setVariable ["A3C_PEEL_ACTIVE", false, false];
                _movingUnits = _movingUnits - [(_x select 0)];
                (_x select 0) disableAI "AUTOTARGET";
            };

            sleep 0.1;
        };
    };

    if (_exit) exitWith {};

    _counter = 1;

    while {_counter < (_timeOut / 0.1)} do {
        if (({!(_x getVariable ["A3C_PEEL_ACTIVE", false]} count _movingUnits) > 0) exitWith {};
        sleep 0.1;
        _counter = _counter + 1;
    };

    (_x select 0) setVariable ["A3C_PEEL_ACTIVE", false, false];
} forEach _storeData;

showCommandingMenu "RscGroupRootMenu";
showCommandingMenu "";

A3C_HUD_FORM = 0;
A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
A3C_HUD_FORM_ICON_SIZE = 0.8;