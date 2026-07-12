// MCSS_fnc_SwitchMarker
//-- switch marker visualisation

(_this select 0) setMarkerTypeLocal (_this select 1);
if ((count _this) > 2) then {(_this select 0) setMarkerColorLocal (_this select 2)};
