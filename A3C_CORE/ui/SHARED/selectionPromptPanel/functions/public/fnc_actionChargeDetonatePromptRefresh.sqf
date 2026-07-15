#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

//-- Charge is null object in "A3C_UNIT_EXPLOSIVES" variable

private _display = if (!isNull findDisplay IDD_MAP_OVERLAY) then {
	findDisplay IDD_MAP_OVERLAY
} else {
	findDisplay IDD_SELECTION_PROMPT_PANEL
};

if (isNull _display) exitWith {};

private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

if (isNull _parent || {isNull _listBox}) exitWith {};

private _charges = [] call A3C_ai_shared_fnc_getDetonatableCharges;
A3C_UI_RADIAL_Current_Remfire_Units = _charges;

lbClear _listBox;

private _count = 0;

if (_charges isNotEqualTo []) then {
	[_listBox, "DETONATE ALL CHARGES"] call A3C_ui_shared_fnc_addLbEntry;
	_count = 1;

	private _playerGroup = group player;

	{
		_x params ["_unit", "_charge"];

		private _chargeType = typeOf _charge;
		private _displayName = _chargeType;

		{
			if (_chargeType in _x) exitWith {
				_displayName = _x # 1;
			};
		} forEach A3C_DATA_REMOTE_AMMO;

		private _gridChars = (mapGridPosition _charge) splitString "";
		private _mapGridString = format [
			"%1-%2",
			(_gridChars select [0, 3]) joinString "",
			(_gridChars select [3, 5]) joinString ""
		];

		private _unitGroup = group _unit;

		private _lbText = format [
			"%1 | %2 | %3",
			_displayName,
			if (_unitGroup isEqualTo _playerGroup) then {
				name _unit
			} else {
				groupID _unitGroup
			},
			_mapGridString
		];

		[_listBox, _lbText] call A3C_ui_shared_fnc_addLbEntry;

		_count = _count + 1;
	} forEach _charges;
};

[_parent, _listBox, _count] call A3C_ui_selectionPromptPanel_fnc_resizeBox;

ctrlSetFocus _listBox;