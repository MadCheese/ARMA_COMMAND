#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
// #include "..\..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"


params ["_group", "_nearStatics"];

private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

/*
	The shared standard response already closed the radial if needed.

	If this action was triggered outside the map overlay, we need to create
	the HUD SelectionPromptPanel display.
*/
if (_a3c_dsp == IDD_SELECTION_PROMPT_PANEL) then {
	with uiNamespace do {
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
	};
};

private _display = findDisplay _a3c_dsp;
if (isNull _display) exitWith {};

private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

A3C_SelectionPromptPanel_MODE = "STATIC_DISASSEMBLE_HC";

lbClear _listBox;

_parent ctrlShow true;
[_parent, _listBox, count _nearStatics] call A3C_ui_selectionPromptPanel_fnc_resizeBox;

_text ctrlSetText "Select Static Weapon";

{
	private _lbText = getText (
		configFile >> "CfgVehicles" >> typeOf vehicle _x >> "displayName"
	);

	[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
} forEach _nearStatics;