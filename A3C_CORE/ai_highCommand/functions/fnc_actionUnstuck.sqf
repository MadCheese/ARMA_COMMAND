
// A3C_ai_highCommand_fnc_actionUnstuck

if (count A3C_SELECTED_HC_GROUPS_SETTINGS != 1) exitWith {
	systemChat "A3C: Unstuck is only available for single selections";
};

private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

(units _gp) spawn A3C_ai_shared_fnc_actionUnstuck;

