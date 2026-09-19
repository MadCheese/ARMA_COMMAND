#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"

// A3C_ui_shared_fnc_actionDeleteGroupsUiResponse

private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
//-- UI-Reaction
if (_isRadial) then {
	A3C_DISABLE_RADIAL = true;
	[] call A3C_ui_radialMenu_fnc_closeDisplay;
	//-- if +1 groups in selection, we first need to open the selectionPromptPanel and prompt for confirmation
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
		with uiNamespace do {
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
		};
	};
	
} else {
	[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
};






