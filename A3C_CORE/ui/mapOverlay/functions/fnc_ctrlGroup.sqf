#include "..\script_component.hpp"

params ["_name"];

switch (_name) do {

    case "map_ufsb_ctrlsBottom": {
        [
            ["ufsbCommitAll"] call FUNC(ctrl),
            ["ufsbCommitSelected"] call FUNC(ctrl),
            ["ufsbExit"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_hcgp_imgs_Stance": {
        [
            ["hcgpStanceAutoImg"] call FUNC(ctrl),
            ["hcgpStanceStandImg"] call FUNC(ctrl),
            ["hcgpStanceCrouchImg"] call FUNC(ctrl),
            ["hcgpStanceProneImg"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    default { [] };
};