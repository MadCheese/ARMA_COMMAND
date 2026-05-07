#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

private _controls = createHashMap;

if !(isNull _display) then {
    _controls set ["parent", _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent];
    _controls set ["descriptionBackground", _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_BG];
    _controls set ["descriptionText", _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT];
    _controls set ["listBox", _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox];
};

uiNamespace setVariable [QGVAR(controls), _controls];