#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

//-- charge is null object in "A3C_UNIT_EXPLOSIVES" variable


private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;


A3C_UI_RADIAL_Current_Remfire_Units = [] call A3C_ai_shared_fnc_getDetonatableCharges;

ctrlSetFocus _listBox;

lbClear _listBox;

private _count = 0;

if ((count A3C_UI_RADIAL_Current_Remfire_Units) > 0) then {
	[_listBox, "DETONATE ALL CHARGES"] call A3C_addLbEntry;
	_count = 1;

	{
		_x params ["_unit", "_charge"];

		private _displayName = "";

		{
			if ((typeOf _charge) in _x) exitWith {
				_displayName = _x select 1;
			};
		} forEach A3C_DATA_REMOTE_AMMO;

		private _mapGridString = mapGridPosition player;
		_mapGridString = _mapGridString splitString "";
		_mapGridString = [
			(_mapGridString select [0, 3]) joinString "",
			(_mapGridString select [3, 5]) joinString ""
		];
		_mapGridString = _mapGridString joinString "-";

		private _lbText = format [
			"%1 | %2 | %3",
			_displayName,
			if ((group _unit) == (group player)) then {name _unit} else {groupID (group _unit)},
			_mapGridString
		];

		[_listBox, _lbText] call A3C_addLbEntry;

		_count = _count + 1;
	} forEach A3C_UI_RADIAL_Current_Remfire_Units;
};

[_parent, _listBox, _count] call A3C_OBJECTSEL_RESIZE;
