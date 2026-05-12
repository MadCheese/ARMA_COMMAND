//-- this fnc does not need a dispatcher because there is no UI response
private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
private _leaderVic = vehicle (leader _gp);
[_leaderVic, 1] call A3C_FireCounterMeasures;