#include "..\script_component.hpp"

params ["_name"];

switch (_name) do {
    case "radial_outerRingBackgrounds": {
        [
            ["bgTop"] call FUNC(ctrl),
            ["bgRight"] call FUNC(ctrl),
            ["bgBottom"] call FUNC(ctrl),
            ["bgLeft"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_extendedBackgrounds": {
        [
            ["bgTop"] call FUNC(ctrl),
            ["bgRight"] call FUNC(ctrl),
            ["bgBottom"] call FUNC(ctrl),
            ["bgLeft"] call FUNC(ctrl)
            // add more (8053,8072)
        ] select {!isNull _x}
    };

    case "radial_innerButtonMacros": {
        [
            ["innerActionsImg"] call FUNC(ctrl),
            ["innerActionsBtn"] call FUNC(ctrl),
            ["innerRoeImg"] call FUNC(ctrl),
            ["innerRoeBtn"] call FUNC(ctrl),
            ["innerAutoImg"] call FUNC(ctrl),
            ["innerAutoBtn"] call FUNC(ctrl),
            ["innerStancesImg"] call FUNC(ctrl),
            ["innerStancesBtn"] call FUNC(ctrl),
            ["innerItemsImg"] call FUNC(ctrl),
            ["innerItemsBtn"] call FUNC(ctrl),
            ["innerVehiclesImg"] call FUNC(ctrl),
            ["innerVehiclesBtn"] call FUNC(ctrl),
            ["innerFormationImg"] call FUNC(ctrl),
            ["innerFormationBtn"] call FUNC(ctrl),
            ["innerGrenadesImg"] call FUNC(ctrl),
            ["innerGrenadesBtn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_innerImages": {
        [
            ["innerActionsImg"] call FUNC(ctrl),
            ["innerRoeImg"] call FUNC(ctrl),
            ["innerAutoImg"] call FUNC(ctrl),
            ["innerStancesImg"] call FUNC(ctrl),
            ["innerItemsImg"] call FUNC(ctrl),
            ["innerVehiclesImg"] call FUNC(ctrl),
            ["innerFormationImg"] call FUNC(ctrl),
            ["innerGrenadesImg"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_innerButtons": {
        [
            ["innerActionsBtn"] call FUNC(ctrl),
            ["innerRoeBtn"] call FUNC(ctrl),
            ["innerAutoBtn"] call FUNC(ctrl),
            ["innerStancesBtn"] call FUNC(ctrl),
            ["innerItemsBtn"] call FUNC(ctrl),
            ["innerVehiclesBtn"] call FUNC(ctrl),
            ["innerFormationBtn"] call FUNC(ctrl),
            ["innerGrenadesBtn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerButtonMacros": {
        [
            ["outerTop1Img"] call FUNC(ctrl),
            ["outerTop1Btn"] call FUNC(ctrl),
            ["outerTop2Img"] call FUNC(ctrl),
            ["outerTop2Btn"] call FUNC(ctrl),
            ["outerTop3Img"] call FUNC(ctrl),
            ["outerTop3Btn"] call FUNC(ctrl),
            ["outerTop4Img"] call FUNC(ctrl),
            ["outerTop4Btn"] call FUNC(ctrl),

            ["outerRight1Img"] call FUNC(ctrl),
            ["outerRight1Btn"] call FUNC(ctrl),
            ["outerRight2Img"] call FUNC(ctrl),
            ["outerRight2Btn"] call FUNC(ctrl),
            ["outerRight3Img"] call FUNC(ctrl),
            ["outerRight3Btn"] call FUNC(ctrl),
            ["outerRight4Img"] call FUNC(ctrl),
            ["outerRight4Btn"] call FUNC(ctrl),

            ["outerBottom1Img"] call FUNC(ctrl),
            ["outerBottom1Btn"] call FUNC(ctrl),
            ["outerBottom2Img"] call FUNC(ctrl),
            ["outerBottom2Btn"] call FUNC(ctrl),
            ["outerBottom3Img"] call FUNC(ctrl),
            ["outerBottom3Btn"] call FUNC(ctrl),
            ["outerBottom4Img"] call FUNC(ctrl),
            ["outerBottom4Btn"] call FUNC(ctrl),

            ["outerLeft1Img"] call FUNC(ctrl),
            ["outerLeft1Btn"] call FUNC(ctrl),
            ["outerLeft2Img"] call FUNC(ctrl),
            ["outerLeft2Btn"] call FUNC(ctrl),
            ["outerLeft3Img"] call FUNC(ctrl),
            ["outerLeft3Btn"] call FUNC(ctrl),
            ["outerLeft4Img"] call FUNC(ctrl),
            ["outerLeft4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerImages": {
        [
            ["outerTop1Img"] call FUNC(ctrl),
            ["outerTop2Img"] call FUNC(ctrl),
            ["outerTop3Img"] call FUNC(ctrl),
            ["outerTop4Img"] call FUNC(ctrl),

            ["outerRight1Img"] call FUNC(ctrl),
            ["outerRight2Img"] call FUNC(ctrl),
            ["outerRight3Img"] call FUNC(ctrl),
            ["outerRight4Img"] call FUNC(ctrl),

            ["outerBottom1Img"] call FUNC(ctrl),
            ["outerBottom2Img"] call FUNC(ctrl),
            ["outerBottom3Img"] call FUNC(ctrl),
            ["outerBottom4Img"] call FUNC(ctrl),

            ["outerLeft1Img"] call FUNC(ctrl),
            ["outerLeft2Img"] call FUNC(ctrl),
            ["outerLeft3Img"] call FUNC(ctrl),
            ["outerLeft4Img"] call FUNC(ctrl)
        ] select {!isNull _x}
    };
    
    case "radial_outerButtons": {
        [
            ["outerTop1Btn"] call FUNC(ctrl),
            ["outerTop2Btn"] call FUNC(ctrl),
            ["outerTop3Btn"] call FUNC(ctrl),
            ["outerTop4Btn"] call FUNC(ctrl),

            ["outerRight1Btn"] call FUNC(ctrl),
            ["outerRight2Btn"] call FUNC(ctrl),
            ["outerRight3Btn"] call FUNC(ctrl),
            ["outerRight4Btn"] call FUNC(ctrl),

            ["outerBottom1Btn"] call FUNC(ctrl),
            ["outerBottom2Btn"] call FUNC(ctrl),
            ["outerBottom3Btn"] call FUNC(ctrl),
            ["outerBottom4Btn"] call FUNC(ctrl),

            ["outerLeft1Btn"] call FUNC(ctrl),
            ["outerLeft2Btn"] call FUNC(ctrl),
            ["outerLeft3Btn"] call FUNC(ctrl),
            ["outerLeft4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    

    case "radial_outerTopMacros": {
        [
            ["outerTop1Img"] call FUNC(ctrl),
            ["outerTop1Btn"] call FUNC(ctrl),
            ["outerTop2Img"] call FUNC(ctrl),
            ["outerTop2Btn"] call FUNC(ctrl),
            ["outerTop3Img"] call FUNC(ctrl),
            ["outerTop3Btn"] call FUNC(ctrl),
            ["outerTop4Img"] call FUNC(ctrl),
            ["outerTop4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerTopImages": {
        [
            ["outerTop1Img"] call FUNC(ctrl),
            ["outerTop2Img"] call FUNC(ctrl),
            ["outerTop3Img"] call FUNC(ctrl),
            ["outerTop4Img"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerTopButtons": {
        [
            ["outerTop1Btn"] call FUNC(ctrl),
            ["outerTop2Btn"] call FUNC(ctrl),
            ["outerTop3Btn"] call FUNC(ctrl),
            ["outerTop4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerRightMacros": {
        [
            ["outerRight1Img"] call FUNC(ctrl),
            ["outerRight1Btn"] call FUNC(ctrl),
            ["outerRight2Img"] call FUNC(ctrl),
            ["outerRight2Btn"] call FUNC(ctrl),
            ["outerRight3Img"] call FUNC(ctrl),
            ["outerRight3Btn"] call FUNC(ctrl),
            ["outerRight4Img"] call FUNC(ctrl),
            ["outerRight4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerRightImages": {
        [
            ["outerRight1Img"] call FUNC(ctrl),
            ["outerRight2Img"] call FUNC(ctrl),
            ["outerRight3Img"] call FUNC(ctrl),
            ["outerRight4Img"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerRightButtons": {
        [
            ["outerRight1Btn"] call FUNC(ctrl),
            ["outerRight2Btn"] call FUNC(ctrl),
            ["outerRight3Btn"] call FUNC(ctrl),
            ["outerRight4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerBottomMacros": {
        [
            ["outerBottom1Img"] call FUNC(ctrl),
            ["outerBottom1Btn"] call FUNC(ctrl),
            ["outerBottom2Img"] call FUNC(ctrl),
            ["outerBottom2Btn"] call FUNC(ctrl),
            ["outerBottom3Img"] call FUNC(ctrl),
            ["outerBottom3Btn"] call FUNC(ctrl),
            ["outerBottom4Img"] call FUNC(ctrl),
            ["outerBottom4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerBottomImages": {
        [
            ["outerBottom1Img"] call FUNC(ctrl),
            ["outerBottom2Img"] call FUNC(ctrl),
            ["outerBottom3Img"] call FUNC(ctrl),
            ["outerBottom4Img"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerBottomButtons": {
        [
            ["outerBottom1Btn"] call FUNC(ctrl),
            ["outerBottom2Btn"] call FUNC(ctrl),
            ["outerBottom3Btn"] call FUNC(ctrl),
            ["outerBottom4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerLeftMacros": {
        [
            ["outerLeft1Img"] call FUNC(ctrl),
            ["outerLeft1Btn"] call FUNC(ctrl),
            ["outerLeft2Img"] call FUNC(ctrl),
            ["outerLeft2Btn"] call FUNC(ctrl),
            ["outerLeft3Img"] call FUNC(ctrl),
            ["outerLeft3Btn"] call FUNC(ctrl),
            ["outerLeft4Img"] call FUNC(ctrl),
            ["outerLeft4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerLeftImages": {
        [
            ["outerLeft1Img"] call FUNC(ctrl),
            ["outerLeft2Img"] call FUNC(ctrl),
            ["outerLeft3Img"] call FUNC(ctrl),
            ["outerLeft4Img"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_outerLeftButtons": {
        [
            ["outerLeft1Btn"] call FUNC(ctrl),
            ["outerLeft2Btn"] call FUNC(ctrl),
            ["outerLeft3Btn"] call FUNC(ctrl),
            ["outerLeft4Btn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_clickBlockAreas": {
        (
            (["radial_innerButtons"] call FUNC(ctrlGroup))
            + (["radial_outerButtons"] call FUNC(ctrlGroup))
            + [
                ["extensionLeftCtrlsGroup"] call FUNC(ctrl),
                ["dashboardParent"] call FUNC(ctrl)
            ]
        ) select {!isNull _x}
    };
    
    case "radial_holdContinueMacros": {
        [
            ["extensionLeftHoldImg"] call FUNC(ctrl),
            ["extensionLeftHoldBtn"] call FUNC(ctrl),
            ["extensionLeftContinueImg"] call FUNC(ctrl),
            ["extensionLeftContinueBtn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    case "radial_extensionRight": {
        [
            ["extensionRightBackground"] call FUNC(ctrl),
            ["extensionRightLbSourcesHeader"] call FUNC(ctrl),
            ["extensionRightLbSourcesBox"] call FUNC(ctrl),
            ["extensionRightLbSubselHeader"] call FUNC(ctrl),
            ["extensionRightLbSubselBox"] call FUNC(ctrl),
            ["extensionRightGoBtn"] call FUNC(ctrl)
        ] select {!isNull _x}
    };

    

    default { [] };
};


