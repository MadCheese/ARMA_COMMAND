// A3C_ai_highCommand_fnc_actionRemoteFireVtolDispatch

params ["_weapon"];
private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
[_weapon, _aimpos] call A3C_ai_highCommand_fnc_actionRemoteFireVtol;
[] spawn A3C_ui_radialMenu_fnc_actionRemoteFireVtolUiResponse;



