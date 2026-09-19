#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"


// A3C_ui_shared_fnc_mapRadial_actionStandardResponse

private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;

//-- UI-Reaction
if (_isRadial) then {
	//-- no actual action - just close menu
	//-- note: we still disable radial so that player needs to let go of key
	A3C_DISABLE_RADIAL = true;
	[] call A3C_ui_radialMenu_fnc_closeDisplay;
} else {
	sleep 0.1;
	[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
};