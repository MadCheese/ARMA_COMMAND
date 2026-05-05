#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

switch (ctrlIDC _control) do {
    case IDC_SUPPRESSION_AREA_BTN_UNLIMITED: {
        ["UNLIMITED", true] call FUNC(setRestrictionMode);
    };

    case IDC_SUPPRESSION_AREA_BTN_PERCENTAGE: {
        ["PERCENTAGE", true] call FUNC(setRestrictionMode);
    };

    case IDC_SUPPRESSION_AREA_BTN_MAGAZINE: {
        ["MAGAZINE", true] call FUNC(setRestrictionMode);
    };

    case IDC_SUPPRESSION_AREA_BTN_TIME: {
        ["TIME", true] call FUNC(setRestrictionMode);
    };

    case IDC_SUPPRESSION_AREA_BTN_CONFIRM: {
        A3C_SUP_DRAW_TOGGLE = false;
        A3C_DRAW_ORDER_RELEASE = true;

        [] call FUNC(confirmDraw);
    };

    case IDC_SUPPRESSION_AREA_BTN_CANCEL: {
        [] call FUNC(closeDisplay);
    };
};