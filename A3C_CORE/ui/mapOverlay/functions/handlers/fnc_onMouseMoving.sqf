#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"



// player sideChat "A3C_UI_MAP_onOnMouseMoving_Overlay";
params ["_display","_sX","_sY","_unUsed"];

A3C_MAP_X = _sX;
A3C_MAP_Y = _sY;

private _ctls = [
	IDC_MAP_UFSB_FRAME,
	IDC_MAP_TOP_EXTRAS_BACKGROUND,
	IDC_UI_SHARED_TEAMCOLOR_BG,
	IDC_SHARED_UI_TREE_SELECTOR,
	IDC_MAP_Order_GoCode_BG,
	IDC_MAP_UFSB_Subselection_01_Parent,
	IDC_MAP_UFSB_Subselection_02_Parent,
	IDC_MAP_SQWP_Parent,
	IDC_MAP_HCWP_Parent,
	IDC_MAP_HCGP_Parent
];


if ({[[_sX,_sY],findDisplay IDD_MAP_OVERLAY displayCtrl _x] call MCSS_fnc_isClickPosInCTRLArea} count _ctls > 0) then {
	(findDisplay 12 displayCtrl 51) ctrlEnable false;
} else {
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	ctrlSetFocus (findDisplay 12 displayCtrl 51);
	if (A3C_MapSel_Field_Active) then {
		A3C_MapSel_Field_DEST = (findDisplay 12 displayCtrl 51) posscreentoworld [A3C_MAP_X,A3C_MAP_Y];
	};
	if (A3C_BOOL_MOUSEMOVING) then {
		_this spawn A3C_MMCode;
	};
};	
