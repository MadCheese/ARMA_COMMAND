// MCSS_fnc_correctDir
// Normalize direction to 0 <= dir < 360.

params ["_dir"];

((_dir % 360) + 360) % 360