#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_addLbEntry
// Adds a listbox entry while suppressing selection-related handling.
//-- note: comes from misunderstanding of lbSetCursel command - remains until cleanup

params ["_control", "_text"];

A3C_CurSel = true;

private _index = _control lbAdd _text;

A3C_CurSel = false;

_index

