/*
	A3C_main_fnc_knowsAboutServerReceive
	Q: WHY SO COMPLICATED?
	A: Because knowsAbout is a local variable and can't be accessed remotely. Therefore, in order to sync KN values over the friendly forces,
	we need this hacky workaround that effectively broadcasts local KN-values from all clients to the server.
*/

params ["_client", "_knowsAboutData"];

// Merge the data into the global array
{
	_x params ["_target", "_knowsAbout"];

	private _found = false;
	{
		if (_x select 0 == _target) exitWith {
			_found = true;
			if (_knowsAbout > _x select 1) then {
				KNOWSABOUT_ARRAY set [_foreachIndex, [_target, _knowsAbout]];
			};
		};
	} forEach KNOWSABOUT_ARRAY;

	if (!_found) then {
		KNOWSABOUT_ARRAY set [count KNOWSABOUT_ARRAY, _x];
	};
} forEach _knowsAboutData;    
