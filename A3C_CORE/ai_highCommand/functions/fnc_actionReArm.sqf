private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
{[_x] spawn A3C_ReArm_Auto_Evaluate} foreach (units _group);
player groupradio 'SentCmdRearm';
