#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

with uiNamespace do {
	//disableSerialization;
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _display = findDisplay _displayId;

private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

_text ctrlSetText "SELECT CAS-TYPE";

A3C_SelectionPromptPanel_MODE = "CAS";

lbClear _listBox;

{
	private _leaderVehicle = vehicle leader _x;
	private _casModes = [typeOf _leaderVehicle] call A3C_main_fnc_getCASmodes;

	if (count _casModes > 0) exitWith {
		{
			private _casModeName = switch (true) do {
				case (_x isEqualTo ["machinegun"]): {
					"GUN RUN"
				};
				case (_x isEqualTo ["missilelauncher"]): {
					"MISSILES"
				};
				case (_x isEqualTo ["machinegun", "missilelauncher"]): {
					"GUNS + MISSILES"
				};
				case (_x isEqualTo ["bomblauncher"]): {
					"BOMBING RUN"
				};
			};

			[_listBox, _casModeName] call A3C_addLbEntry;
		} forEach _casModes;
	};
} forEach A3C_RD_UNITS;

private _heightIncrease = 3 * (0.0440051 * safeZoneH);

{
	private _ctrlPos = ctrlPosition _x;
	_ctrlPos set [3, (_ctrlPos select 3) + _heightIncrease];

	_x ctrlSetPosition _ctrlPos;
	_x ctrlCommit 0;
} forEach [_parent, _listBox];