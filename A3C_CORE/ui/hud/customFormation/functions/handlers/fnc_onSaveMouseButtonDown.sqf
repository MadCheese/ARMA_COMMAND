#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_onSaveMouseButtonDown

params [
    "_control",
    "_button"
];

/*
    saveButton may delete the dynamically created save-name edit control.
    Execute it outside this UI event handler.
*/
[_button] spawn FUNC(saveButton);