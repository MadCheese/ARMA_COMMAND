#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

A3C_UI_HUD_3D_TAG_reposition = false;

private _units = +A3C_UI_RADIAL_Current_Remfire_Units;

if (_units isEqualTo []) exitWith {};

private _mags = [];

{
	_mags append ([_x] call A3C_ai_shared_fnc_getExplosiveUnitMagazines);
} forEach _units;

_mags = _mags arrayIntersect _mags;

private _magCount = count _mags;

if (_magCount == 0) exitWith {};

with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};

private _display = if (!isNull findDisplay IDD_MAP_OVERLAY) then {
	findDisplay IDD_MAP_OVERLAY
} else {
	findDisplay IDD_SELECTION_PROMPT_PANEL
};

if (isNull _display) exitWith {};

private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

if (isNull _parent || {isNull _text} || {isNull _listBox}) exitWith {};

A3C_SelectionPromptPanel_MODE = "PLACE_CHARGE_SQUAD";

_parent ctrlShow true;
_parent ctrlSetPosition [
	0.383108 * safezoneW + safezoneX,
	0.378986 * safezoneH + safezoneY
];

if (_magCount > 4) then {
	private _parentPos = ctrlPosition _parent;
	_parentPos set [3, (_parentPos # 3) + ((_magCount - 4) * (0.0440051 * safezoneH))];
	_parent ctrlSetPosition _parentPos;
};

_parent ctrlCommit 0;

_text ctrlSetText "Place Charge";

lbClear _listBox;

{
	private _lbText = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
	[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;
} forEach _mags;

[_parent, _listBox, _magCount] call A3C_ui_selectionPromptPanel_fnc_resizeBox;

ctrlSetFocus _listBox;