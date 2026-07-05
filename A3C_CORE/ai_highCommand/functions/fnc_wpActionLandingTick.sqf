// A3C_ai_highCommand_fnc_wpActionLandingTick

//-- currently unused

params ["_group", "_vehiclesLanding"];

private _groupVehicles = [];

{
	private _vehicle = vehicle _x;

	if (_x == effectiveCommander _vehicle) then {
		if !(isTouchingGround _vehicle) then {

			if !(_vehicle in _vehiclesLanding) then {
				// (format ["%1 (%2) has started landing",  typeOf _vehicle, groupID _group]) remoteExec ["systemchat", 0];
				_vehicle land "GET IN";
				_vehiclesLanding pushBack _vehicle;
				//-- safety glue
				if ( (getPosATL _vehicle) select 2 < 3) then {
					_vehicle flyInHeight 0;
				};
			};
		} else {
			// (format ["%1 (%2) is glued to ground",  typeOf _vehicle, groupID _group]) remoteExec ["systemchat", 0];
			_vehicle flyInHeight 0;
			_vehiclesLanding = _vehiclesLanding - [_vehicle];
		};

		_groupVehicles pushBack _vehicle;
	};
} forEach units _group;

_vehiclesLanding = _vehiclesLanding arrayIntersect _groupVehicles;

_vehiclesLanding