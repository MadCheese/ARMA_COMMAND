params ["_weapon","_aimpos"];

private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
private _leaderVic = vehicle (leader _group);

[
	[side player, _leaderVic, _aimpos, _weapon, objNull],
	A3C_ai_shared_fnc_actionRemoteFireVtol
] remoteExec ['bis_fnc_spawn', _leaderVic];