
// A3C_main_fnc_isGroupOnFinalWP

params ["_group"];
{(_x select 1) > (currentWaypoint _group)} count (waypoints _group) == 0
