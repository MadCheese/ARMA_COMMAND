#include "..\script_component.hpp"

params ["_name"];

switch (_name) do {
    //-- UFSB (Unfoldable Squad Bar)
    case "map_ufsb_ctrlsWaypointSettings": {
        [
            ["ufsbStanceTravelImg"] call FUNC(ctrl),
            ["ufsbStanceTravelBtn"] call FUNC(ctrl),
            ["ufsbWpSpeedImg"] call FUNC(ctrl),
            ["ufsbWpSpeedBtn"] call FUNC(ctrl),
            ["ufsbStanceArrivalImg"] call FUNC(ctrl),
            ["ufsbStanceArrivalBtn"] call FUNC(ctrl),
            ["ufsbCombatModeImg"] call FUNC(ctrl),
            ["ufsbCombatModeBtn"] call FUNC(ctrl),
            ["ufsbWpActionImg"] call FUNC(ctrl),
            ["ufsbWpActionBtn"] call FUNC(ctrl),
            ["ufsbWpFormationImg"] call FUNC(ctrl),
            ["ufsbWpFormationBtn"] call FUNC(ctrl),
            ["ufsbSpacing"] call FUNC(ctrl),
            ["ufsbWpConditionImg"] call FUNC(ctrl),
            ["ufsbWpConditionBtn"] call FUNC(ctrl),
            ["ufsbTimeoutPopup"] call FUNC(ctrl),
            ["ufsbUndoImg"] call FUNC(ctrl),
            ["ufsbUndoBtn"] call FUNC(ctrl),
            ["ufsbCancelImg"] call FUNC(ctrl),
            ["ufsbCancelBtn"] call FUNC(ctrl),
            ["ufsbHoldImg"] call FUNC(ctrl),
            ["ufsbHoldBtn"] call FUNC(ctrl),
            ["ufsbContinueImg"] call FUNC(ctrl),
            ["ufsbContinueBtn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };
    case "map_ufsb_ctrlsBottom": {
        [
            ["ufsbCommitAll"] call FUNC(ctrl),
            ["ufsbCommitSelected"] call FUNC(ctrl),
            ["ufsbExit"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_ufsb_ctrlsAll": {
        (
            (["map_ufsb_ctrlsWaypointSettings"] call FUNC(ctrlGroup))
            + (["map_ufsb_ctrlsBottom"] call FUNC(ctrlGroup))
        ) select {!isNull _x}
    };

    //-- ufsb Subsets
    case "map_ufsb_subSet_1_images": {
        [
            ["ufsbSubselection01Img01"] call FUNC(ctrl),
            ["ufsbSubselection01Img02"] call FUNC(ctrl),
            ["ufsbSubselection01Img03"] call FUNC(ctrl),
            ["ufsbSubselection01Img04"] call FUNC(ctrl),
            ["ufsbSubselection01Img05"] call FUNC(ctrl),
            ["ufsbSubselection01Img06"] call FUNC(ctrl),
            ["ufsbSubselection01Img07"] call FUNC(ctrl),
            ["ufsbSubselection01Img08"] call FUNC(ctrl),
            ["ufsbSubselection01Img09"] call FUNC(ctrl),
            ["ufsbSubselection01Img10"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_ufsb_subSet_1_buttons": {
        [
            ["ufsbSubselection01Btn01"] call FUNC(ctrl),
            ["ufsbSubselection01Btn02"] call FUNC(ctrl),
            ["ufsbSubselection01Btn03"] call FUNC(ctrl),
            ["ufsbSubselection01Btn04"] call FUNC(ctrl),
            ["ufsbSubselection01Btn05"] call FUNC(ctrl),
            ["ufsbSubselection01Btn06"] call FUNC(ctrl),
            ["ufsbSubselection01Btn07"] call FUNC(ctrl),
            ["ufsbSubselection01Btn08"] call FUNC(ctrl),
            ["ufsbSubselection01Btn09"] call FUNC(ctrl),
            ["ufsbSubselection01Btn10"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_ufsb_subSet_1_all": {
        (
            (["map_ufsb_subSet_1_images"] call FUNC(ctrlGroup))
            + (["map_ufsb_subSet_1_buttons"] call FUNC(ctrlGroup))
        ) select {!isNull _x}
    };

    case "map_ufsb_subSet_2_images": {
        [
            ["ufsbSubselection02Img01"] call FUNC(ctrl),
            ["ufsbSubselection02Img02"] call FUNC(ctrl),
            ["ufsbSubselection02Img03"] call FUNC(ctrl),
            ["ufsbSubselection02Img04"] call FUNC(ctrl),
            ["ufsbSubselection02Img05"] call FUNC(ctrl),
            ["ufsbSubselection02Img06"] call FUNC(ctrl),
            ["ufsbSubselection02Img07"] call FUNC(ctrl),
            ["ufsbSubselection02Img08"] call FUNC(ctrl),
            ["ufsbSubselection02Img09"] call FUNC(ctrl),
            ["ufsbSubselection02Img10"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_ufsb_subSet_2_buttons": {
        [
            ["ufsbSubselection02Btn01"] call FUNC(ctrl),
            ["ufsbSubselection02Btn02"] call FUNC(ctrl),
            ["ufsbSubselection02Btn03"] call FUNC(ctrl),
            ["ufsbSubselection02Btn04"] call FUNC(ctrl),
            ["ufsbSubselection02Btn05"] call FUNC(ctrl),
            ["ufsbSubselection02Btn06"] call FUNC(ctrl),
            ["ufsbSubselection02Btn07"] call FUNC(ctrl),
            ["ufsbSubselection02Btn08"] call FUNC(ctrl),
            ["ufsbSubselection02Btn09"] call FUNC(ctrl),
            ["ufsbSubselection02Btn10"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_ufsb_subSet_2_all": {
        (
            (["map_ufsb_subSet_2_images"] call FUNC(ctrlGroup))
            + (["map_ufsb_subSet_2_buttons"] call FUNC(ctrlGroup))
        ) select {!isNull _x}
    };

    //-- HCGP groups
    case "map_hcgp_imgs_Stance": {
        [
            ["hcgpStanceAutoImg"] call FUNC(ctrl),
            ["hcgpStanceStandImg"] call FUNC(ctrl),
            ["hcgpStanceCrouchImg"] call FUNC(ctrl),
            ["hcgpStanceProneImg"] call FUNC(ctrl)
        ] select {!isNull _x}
    };
    //-- HCWP groups
    case "map_hcwp_macro_confirmAndCancel": {
        [
            ["hcwpConfirmBg"] call FUNC(ctrl),
            ["hcwpConfirmText"] call FUNC(ctrl),
            ["hcwpDeleteBg"] call FUNC(ctrl),
            ["hcwpDeleteText"] call FUNC(ctrl)
        ] select {!isNull _x}
    };
    case "map_hcwp_conditionCombos": {
        [
            ["hcwpConditionPreType"] call FUNC(ctrl),
            ["hcwpConditionPreMode"] call FUNC(ctrl),
            ["hcwpConditionPostType"] call FUNC(ctrl),
            ["hcwpConditionPostMode"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "map_hcwp_conditionCombos_clearable": {
        [
            ["hcwpConditionPreMode"] call FUNC(ctrl),
            ["hcwpConditionPostType"] call FUNC(ctrl),
            ["hcwpConditionPostMode"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    default { [] };
};