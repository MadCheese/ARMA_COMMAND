#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

with uiNamespace do {
	//disableSerialization;
	A3C_HUD_OBS = findDisplay 46 createDisplay "HUD_SelectionPromptPanel";
};

private _displayIDD = if (!isNull findDisplay IDD_MAP_OVERLAY) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _display = findDisplay _displayIDD;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

A3C_SelectionPromptPanel_MODE = "STATIC_DISASSEMBLE_SQUAD";

_parent ctrlShow true;
_parent ctrlSetPosition [
	0.383108 * safeZoneW + safeZoneX,
	0.378986 * safeZoneH + safeZoneY
];
_parent ctrlCommit 0;

_text ctrlSetText "Pack Weapon";

A3C_UI_RADIAL_Current_Remfire_Vehicles = [];

{
	private _vehicle = vehicle _x;

	if (_x == gunner _vehicle && {_vehicle isKindOf "STATICWEAPON"}) then {
		A3C_UI_RADIAL_Current_Remfire_Vehicles pushBackUnique _vehicle;
	};
} forEach A3C_UI_RADIAL_Current_Remfire_Units;

private _vehicleCount = count A3C_UI_RADIAL_Current_Remfire_Vehicles;

if (_vehicleCount > 4) then {
	private _parentPos = ctrlPosition _parent;
	_parentPos set [
		3,
		(_parentPos select 3) + ((_vehicleCount - 4) * (0.0440051 * safeZoneH))
	];

	_parent ctrlSetPosition _parentPos;
	_parent ctrlCommit 0;
};

ctrlSetFocus _listBox;
lbClear _listBox;

{
	private _gunner = gunner _x;
	private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");

	private _entryText = if (_gunner in A3C_UI_RADIAL_Current_Remfire_Units) then {
		format ["%1 (%2)", _displayName, name _gunner]
	} else {
		format ["%1 (Empty)", _displayName]
	};

	[_listBox, _entryText] call A3C_ui_shared_fnc_addLbEntry;
} forEach (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics);