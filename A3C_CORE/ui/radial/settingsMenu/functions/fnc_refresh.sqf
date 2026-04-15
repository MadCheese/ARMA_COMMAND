#include "..\script_component.hpp"

private _skill = ["skill"] call FUNC(ctrl);
private _num = ["num"] call FUNC(ctrl);
private _hudReset = ["hudReset"] call FUNC(ctrl);
private _aiRail = ["aiRail"] call FUNC(ctrl);
private _hudLayout = ["hudLayout"] call FUNC(ctrl);
private _hudObjects = ["hudObjects"] call FUNC(ctrl);
private _hcResponse = ["hcResponse"] call FUNC(ctrl);

if !(isNull _skill) then {
    _skill ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_SKILL_VAR", false]));
};

if !(isNull _num) then {
    _num ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_NUM_VAR", false]));
};

if !(isNull _hudReset) then {
    _hudReset ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_RES_VAR", false]));
};

if !(isNull _aiRail) then {
    _aiRail ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_FORCERAIL_VAR", false]));
};

if !(isNull _hudLayout) then {
    _hudLayout ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false]));
};

if !(isNull _hudObjects) then {
    _hudObjects ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["A3C_HUD_OBJECTS", false]));
};

if !(isNull _hcResponse) then {
    _hcResponse ctrlSetText (["OFF", "ON"] select (profileNamespace getVariable ["HC_GROUP_RESPONSE", false]));
};