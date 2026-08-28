// A3C_ai_highCommand_fnc_actionGroupHealDispatch

[] spawn A3C_ui_shared_fnc_mapRadial_actionStandardResponse;

private _group = A3C_SELECTED_HC_GROUPS_SETTINGS param [
	0,
	grpNull
];

if (isNull _group) exitWith {};

private _groupLeader =
	leader _group;

if (isNull _groupLeader) exitWith {};

[
	_group
] remoteExec [
	"A3C_ai_highCommand_fnc_actionGroupHeal",
	_groupLeader
];