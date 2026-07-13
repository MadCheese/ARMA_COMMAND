private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
{[_x] spawn A3C_ai_shared_fnc_reArm_autoEvaluated} foreach (units _group);
player groupradio 'SentCmdRearm';
