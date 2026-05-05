#include "..\script_component.hpp"

private _groups = createHashMap;

_groups set [
    "typePictures",
    [
        ["typePicUnlimited"] call FUNC(ctrl),
        ["typePicPercentage"] call FUNC(ctrl),
        ["typePicMagazine"] call FUNC(ctrl),
        ["typePicTime"] call FUNC(ctrl)
    ] select {!isNull _x}
];

_groups set [
    "typeButtons",
    [
        ["buttonUnlimited"] call FUNC(ctrl),
        ["buttonPercentage"] call FUNC(ctrl),
        ["buttonMagazine"] call FUNC(ctrl),
        ["buttonTime"] call FUNC(ctrl)
    ] select {!isNull _x}
];

_groups set [
    "editControls",
    [
        ["percentageEdit"] call FUNC(ctrl),
        ["magazineEdit"] call FUNC(ctrl),
        ["timeEdit"] call FUNC(ctrl)
    ] select {!isNull _x}
];

uiNamespace setVariable [QGVAR(groups), _groups];