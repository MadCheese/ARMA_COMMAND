#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

private _groups = createHashMap;

if !(isNull _display) then {
    _groups set [
        "panelControls",
        [
            _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_BG,
            _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT,
            _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox
        ] select {!isNull _x}
    ];
};

uiNamespace setVariable [QGVAR(groups), _groups];