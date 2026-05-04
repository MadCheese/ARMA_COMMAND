#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_mode", "_btn"];

if (_mode == 1) then {
    private _form = A3C_HUD_FORM;

    switch (true) do {
        case (A3C_HUD_Snap && {_form in [0, 1]}): {
            if (_btn == 0) then {
                A3C_HUD_FORM = 2;
            } else {
                A3C_HUD_FORM = 8;
            };
        };
        case (_form in [3, 4]): {
            if (_btn == 0) then {
                A3C_HUD_FORM = 5;
            } else {
                A3C_HUD_FORM = 2;
            };
        };
        case (_form in [5, 6]): {
            if (_btn == 0) then {
                A3C_HUD_FORM = 7;
            } else {
                A3C_HUD_FORM = 3;
            };
        };
        case (_form == 7): {
            if (_btn == 0) then {
                A3C_HUD_FORM = 8;
            } else {
                A3C_HUD_FORM = 5;
            };
        };
        default {
            if (_btn == 0) then {
                A3C_HUD_FORM = A3C_HUD_FORM + 1;
            } else {
                A3C_HUD_FORM = A3C_HUD_FORM - 1;
            };
        };
    };

    private _limit = if (A3C_EHM) then {8} else {7};

    if (A3C_HUD_FORM < 0) then {
        A3C_HUD_FORM = _limit;
    };

    if (A3C_HUD_FORM > _limit) then {
        A3C_HUD_FORM = 0;
    };
};

A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
A3C_HUD_FORM_ICON_SIZE = 0.8;

switch (A3C_HUD_FORM) do {
    case 0: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
    };
    case 1: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
    };
    case 2: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Front.paa";
    };
    case 3: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_L_Right.paa";
    };
    case 4: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_L_Left.paa";
    };
    case 5: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";
    };
    case 6: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";
    };
    case 7: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Circle.paa";
    };
    case 8: {
        A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\EHM.paa";
        A3C_HUD_FORM_ICON_COLOR = [1, 1, 1, 1];
        A3C_HUD_FORM_ICON_SIZE = 2;
    };
};

private _formImage = ["overlayFormImage"] call FUNC(ctrl);
if !(isNull _formImage) then {
    _formImage ctrlSetText A3C_HUD_FORM_ICON;
};