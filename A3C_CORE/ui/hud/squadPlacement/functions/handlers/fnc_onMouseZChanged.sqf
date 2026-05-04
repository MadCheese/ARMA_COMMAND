#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_control", "_scroll"];

private _direction = [1, 0] select (_scroll < 0);

switch (ctrlIDC _control) do {
    case IDC_SQUAD_PLACEMENT_FORM_BTN: {
        [1, _direction] call A3C_UI_HUD_FORM_BUTTON;
    };
    case IDC_SQUAD_PLACEMENT_TRAVEL_BTN: {
        [0, _direction] call A3C_HUD_STANCE_BUTTONS;
    };
    case IDC_SQUAD_PLACEMENT_DESTINATION_BTN: {
        [1, _direction] call A3C_HUD_STANCE_BUTTONS;
    };
    case IDC_SQUAD_PLACEMENT_GOCODE_BTN: {
        [0, _direction] call A3C_HUD_GOCODE_BUTTON;
    };
};