#include "..\..\script_component.hpp"
#include "..\..\..\..\SHARED\shared_ui_defines.hpp"


params ["_display", "_key", "_shift", "_ctrl", "_alt"];
private _SelectionPromptPanelListbox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
if (_key >= 2 && _key <= 10) then {
	[_key, _SelectionPromptPanelListbox] spawn A3C_UI_Shared_SelectionPromptPanel_Listbox_NumberControl;
};
true
