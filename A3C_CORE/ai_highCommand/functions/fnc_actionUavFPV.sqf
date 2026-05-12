// A3C_ai_highCommand_fnc_actionUavFPV

private _group = A3C_RD_UNITS select 0;
private _wpPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);


//-- delete current waypoints
[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;

private _cursorTarget = cursortarget; //-- #TODO: make this work regardless of cursortarget?


if (!isNull _cursorTarget) then {
	private _wp = _group addWaypoint [_wpPos,0];
	_wp setWaypointType "SCRIPTED";
	_wp waypointAttachVehicle _cursorTarget;
	_wp setWaypointSpeed "FULL";
	_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_UAV_FPV.sqf [getPlayerUID player]"; 
} else {
	[] spawn {
		hint "NO TARGET SELECTED!";
		sleep 3;
		hintSilent "";
	};
};
