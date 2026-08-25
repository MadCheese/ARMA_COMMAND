#include "..\..\script_component.hpp"
#include "..\..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_UI_SelectionPromptPanel_fnc_onKeyDown

params ["_display", "_key", "_shift", "_ctrl", "_alt"];
private _SelectionPromptPanelListbox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
if (_key >= 2 && _key <= 10) then {
	[_key, _SelectionPromptPanelListbox] spawn A3C_UI_SelectionPromptPanel_fnc_listbox_NumberControl;
};
true
