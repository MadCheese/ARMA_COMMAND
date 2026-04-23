#include "..\script_component.hpp"

params ["_name"];

switch (_name) do {
    case "backgrounds": {
        [
            ["bgCore"] call FUNC(ctrl),
            ["bgTop"] call FUNC(ctrl),
            ["bgRight"] call FUNC(ctrl),
            ["bgBottom"] call FUNC(ctrl),
            ["bgLeft"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "extendedBackgrounds": {
        [
            ["bgCore"] call FUNC(ctrl),
            ["bgTop"] call FUNC(ctrl),
            ["bgRight"] call FUNC(ctrl),
            ["bgBottom"] call FUNC(ctrl),
            ["bgLeft"] call FUNC(ctrl)
			// add more (8053,8072)
        ] select {!isNull _x}
    };

    default { [] };
};