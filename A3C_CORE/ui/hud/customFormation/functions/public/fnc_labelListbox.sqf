#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_labelListbox

private _listbox = ["savedFormations"] call FUNC(ctrl);
if (isNull _listbox) exitWith {};

lbClear _listbox;

[_listbox, "CUSTOM"] call A3C_addLbEntry;

private _savedFormations = profileNamespace getVariable [
    "A3C_C_FORMATIONS_SAVED",
    []
];

{
    [_listbox, _x select 0] call A3C_addLbEntry;
} forEach _savedFormations;

private _selectedIndex = uiNamespace getVariable [
    "A3C_UI_CustomFormation_saveLB",
    0
];

[_listbox, _selectedIndex] call A3C_setCurSel;