// A3C_ui_mapOverlay_fnc_isWaypointLoop

params ["_data","_wpIndex"];

private _return = false;
for "_i" from 0 to _wpIndex do {
	if ( ((_data select _i) select 10) == -2) exitWith {
		_return = true;
	};
};
_return
