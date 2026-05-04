params ["_mode", ["_btn", 0]];

private _toolTip = "";

if !(profileNamespace getVariable ["A3C_UI_squadPlacement_interactionOVERRIDE_VAR", true]) then {
    A3C_HUD_GOCODE_ICON_COLOR = [1, 1, 1, 0.7];

    if (_mode == 0) then {
        if (_btn == 0) then {
            switch (profileNamespace getVariable ["A3C_HUD_GOCODE_VAR", "NONE"]) do {
                case "A": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "B"];};
                case "B": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "C"];};
                case "C": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "D"];};
                case "D": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "NONE"];};
                default {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "A"];};
            };
        } else {
            switch (profileNamespace getVariable ["A3C_HUD_GOCODE_VAR", "NONE"]) do {
                case "A": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "NONE"];};
                case "B": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "A"];};
                case "C": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "B"];};
                case "D": {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "C"];};
                default {profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "D"];};
            };
        };
    };

    switch (profileNamespace getVariable ["A3C_HUD_GOCODE_VAR", "NONE"]) do {
        case "A": {
            A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
            _toolTip = "GoCode A";
        };
        case "B": {
            A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
            _toolTip = "GoCode B";
        };
        case "C": {
            A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
            _toolTip = "GoCode C";
        };
        case "D": {
            A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
            _toolTip = "GoCode D";
        };
        default {
            A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";
            _toolTip = "No Condition";
        };
    };
} else {
    profileNamespace setVariable ["A3C_HUD_GOCODE_VAR", "NONE"];
    A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";
    A3C_HUD_GOCODE_ICON_COLOR = [1, 1, 1, 0.2];
    _toolTip = "Conditions not available in Override-Mode";
};

(findDisplay 100050 displayCtrl 18) ctrlSetTooltip _toolTip;

((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 14) ctrlSetText A3C_HUD_GOCODE_ICON;
((uiNamespace getVariable "A3C_UI_squadPlacement_overlay") displayCtrl 14) ctrlSetTextColor A3C_HUD_GOCODE_ICON_COLOR;