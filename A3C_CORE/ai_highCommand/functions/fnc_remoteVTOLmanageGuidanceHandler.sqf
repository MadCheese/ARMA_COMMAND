// A3C_ai_highCommand_fnc_remoteVTOLmanageGuidanceHandler

/*
    Adds or removes a local Fired EH on a remote-controlled Blackfish VTOL.

    The Fired EH must exist on every machine because VTOL projectiles are not
    replaced like other guided rounds. Server-side guidance alone can produce
    correct impacts while clients still see unguided tracers. Therefore, each
    machine guides its locally observed projectile instance toward the assigned
    remote target.
*/

params [
    ["_action", "", [""]],
    ["_id", "", [""]],
    ["_vehicleNetID", "", [""]]
];

private _vtol = objectFromNetId _vehicleNetID;

if (isNull _vtol) exitWith {};
if !((typeOf _vtol) in [
    "B_T_VTOL_01_armed_fixed_F",
    "B_T_VTOL_01_armed_F"
]) exitWith {};

private _handlerVar = "A3C_VTOL_GUIDANCE_FIRED_EHS";
private _existingHandlers = _vtol getVariable [_handlerVar, []];

switch (toUpper _action) do {
    case "ADD": {
        // Prevent duplicate handlers for the same logical ID.
        if ((_existingHandlers findIf { (_x # 0) isEqualTo _id }) == -1) then {
            private _handlerIndex = _vtol addEventHandler [
                "Fired",
                {
                    params [
                        "_vehicle",
                        "_weapon",
                        "_muzzle",
                        "_mode",
                        "_ammo",
                        "_magazine",
                        "_projectile",
                        "_gunner"
                    ];

                    private _remoteHandle = _vehicle getVariable [
                        "A3C_VTOL_REMOTE_HANDLE",
                        ["", objNull, ""]
                    ];

                    _remoteHandle params [
                        ["_targetNetID", "", [""]],
                        ["_snapObject", objNull, [objNull]],
                        ["_behaviour", "", [""]]
                    ];

                    if (_targetNetID isEqualTo "") exitWith {};

                    private _target = objectFromNetId _targetNetID;
                    if (isNull _target) exitWith {};

                    // Optional type guard. Keep this if only CBA invisible air targets are valid.
                    if !(_target isKindOf "CBA_O_InvisibleTargetAir") exitWith {};

                    [_vehicle, _projectile, 0, _target, objNull] spawn A3C_ai_shared_fnc_guideProjectileVTOL;
                }
            ];

            _existingHandlers pushBack [_id, _handlerIndex];
        };
    };

    case "REMOVE": {
        private _index = _existingHandlers findIf {
            (_x # 0) isEqualTo _id
        };

        if (_index != -1) then {
            private _handlerIndex = (_existingHandlers # _index) # 1;
            _vtol removeEventHandler ["Fired", _handlerIndex];
            _existingHandlers deleteAt _index;
        };
    };

    default {
        // Unknown action; intentionally do nothing.
    };
};

_vtol setVariable [_handlerVar, _existingHandlers, false];