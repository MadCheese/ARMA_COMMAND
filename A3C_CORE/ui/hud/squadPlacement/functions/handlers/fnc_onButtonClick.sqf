#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control"];

switch (ctrlIDC _control) do {
    case IDC_SQUAD_PLACEMENT_SPEED_BTN: {
        [] call A3C_HUD_SPEED_BUTTON;
    };
    case IDC_SQUAD_PLACEMENT_WPMODE_BTN: {
        [] call A3C_HUD_WPMODE_BUTTON;
    };
    case IDC_SQUAD_PLACEMENT_HIDE_BTN: {
        [] call A3C_UI_HUD_BUTTON;
    };
};