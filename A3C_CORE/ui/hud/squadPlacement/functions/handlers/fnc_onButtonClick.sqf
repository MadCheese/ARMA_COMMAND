#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

switch (ctrlIDC _control) do {
    case IDC_SQUAD_PLACEMENT_SPEED_BTN: {
        [] call FUNC(speedButton);
    };
    case IDC_SQUAD_PLACEMENT_WPMODE_BTN: {
        [] call FUNC(wpModeButton);
    };
    case IDC_SQUAD_PLACEMENT_HIDE_BTN: {
        [] call FUNC(toggleUIControls);
    };
};