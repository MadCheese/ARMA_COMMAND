// A3C_ai_highCommand_fnc_getHeliWaypointSleep

params ["_leaderVehicle", "_distance2D"];


private _sleep = 5; //-- default

if !(isTouchingGround _leaderVehicle) then {
	_sleep = switch (true) do {
		case (_distance2D < 1000) : {1};
		case (_distance2D < 500) : {0.5};
		default {5}
	};
};

_sleep