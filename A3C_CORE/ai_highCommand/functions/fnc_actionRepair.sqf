// A3C_ai_highCommand_fnc_actionRepair

private _group = A3C_RD_UNITS select 0;
private _waypointPosition = +(A3C_UI_HUD_3D_TAG_ICON_POS);

[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
private _wp = _group addWaypoint [_waypointPosition,0];
_wp setWaypointType "SCRIPTED";
_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_repair.sqf [getPlayerUID player, ['ARRIVAL', 0]]";
