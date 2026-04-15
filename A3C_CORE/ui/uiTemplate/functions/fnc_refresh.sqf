#include "..\script_component.hpp"

private _primary = ["primary"] call FUNC(ctrl);
private _secondary = ["secondary"] call FUNC(ctrl);

if !(isNull _primary) then {
    _primary ctrlSetText "BTN";
};

if !(isNull _secondary) then {
    _secondary ctrlSetText "BTN";
};