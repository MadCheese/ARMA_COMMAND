#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"



// player sideChat "A3C_UI_MAP_onOnMouseMoving_Overlay";
params ["_display","_sX","_sY","_unUsed"];
private _a3c_dsp = 100020;
private _ctls = [
	IDC_MAP_UFSB_FRAME,
	IDC_MAP_TOP_EXTRAS_BACKGROUND,
	IDC_UI_SHARED_TEAMCOLOR_BG,
	IDC_SHARED_UI_TREE_SELECTOR,
	IDC_MAP_Order_GoCode_BG,
	IDC_MAP_UFSB_Subselection_01_Parent,
	IDC_MAP_UFSB_Subselection_02_Parent,
	IDC_MAP_SQWP_ControlsGroup,
	IDC_MAP_HCWP_Parent,
	IDC_MAP_HCGP_Parent
];

A3C_MAP_X = _this select 1;
A3C_MAP_Y = _this select 2;
if ({[[_sX,_sY],findDisplay _a3c_dsp displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctls > 0) then {
	(findDisplay 12 displayCtrl 51) ctrlEnable false;
	//hintSilent str [time, 'off'];
} else {
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	ctrlSetFocus (findDisplay 12 displayCtrl 51);
	//hintSilent str [time,'on'];
	if (A3C_MapSel_Field_Active) then {
		A3C_MapSel_Field_DEST = (findDisplay 12 displayCtrl 51) posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
	};
	if (A3C_BOOL_MOUSEMOVING) then {
		_this spawn A3C_MMCode;
	};
};	
