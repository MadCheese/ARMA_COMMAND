#include "..\shared_ui_defines.hpp"
#include "..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\mapOverlay\dialog_defines.hpp"


private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_RADIAL_MENU};
private _isRadial = _a3c_dsp == IDD_RADIAL_MENU;
//-- UI-Reaction
if !(_isRadial) then {
	{(findDisplay IDD_MAP_OVERLAY displayCtrl _x) ctrlShow false} foreach [IDC_MAP_HCGP_Parent,IDC_SHARED_UI_DASHBOARD_PARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
} else {
	//-- no actual action - just close menu
	A3C_DISABLE_RADIAL = true;
	[] call A3C_UI_RADIAL_CloseDisplay;
};