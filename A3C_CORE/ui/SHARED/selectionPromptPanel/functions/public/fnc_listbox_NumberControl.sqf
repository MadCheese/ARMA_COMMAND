// A3C_UI_SelectionPromptPanel_fnc_listbox_NumberControl

params ["_key", "_SelectionPromptPanelListbox"];

private _keyValueIndex = _key - 2;
if (_keyValueIndex >= 0 && {_keyValueIndex < lbSize _SelectionPromptPanelListbox}) then {
	sleep 0.1;
	[_SelectionPromptPanelListbox, _keyValueIndex, true] call A3C_ui_shared_fnc_lbSetCurSel;
};
