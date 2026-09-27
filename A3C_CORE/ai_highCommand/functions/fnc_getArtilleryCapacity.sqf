// A3C_ai_highCommand_fnc_getArtilleryCapacity

params ["_group"];

private _return = false;

{
	private _vehicle = objectParent _x;

	if (
		!isNull _vehicle
		&& {_x == gunner _vehicle}
	) then {
		private _isACECSW = [_vehicle] call A3C_main_fnc_isEffectiveACECSW;

		private _hasArtilleryAmmo = if (_isACECSW) then {
			private _availability = [
				[_vehicle],
				[]
			] call A3C_main_fnc_getACECSWArtilleryAvailability;

			_availability findIf {
				(_x select 4) > 0
			} >= 0
		} else {
			count (getArtilleryAmmo [_vehicle]) > 0
		};

		if (_hasArtilleryAmmo) exitWith {
			_return = true;
		};
	};
} forEach units _group;

_return