private _droneTypeNamePart = if (isClass (configFile >> "CfgVehicles" >> "mavic_3_BLU")) then {
	"mavic"
} else {
	"mavik"
};

private _isTargetDrone = {
	params ["_object", "_typeNamePart"];

	!isNull _object && {
		_typeNamePart in toLowerANSI typeOf _object
	}
};

private _cursorTarget = cursorTarget;
private _selectedDrone = objNull;

if ([_cursorTarget, _droneTypeNamePart] call _isTargetDrone) then {
	_selectedDrone = _cursorTarget;
} else {
	private _nearDrones = nearestObjects [
		player,
		[],
		2
	] select {
		[_x, _droneTypeNamePart] call _isTargetDrone
	};

	if !(_nearDrones isEqualTo []) then {
		_selectedDrone = _nearDrones select 0;
	};
};

if (!isNull _selectedDrone) then {
	[_selectedDrone, player] call mavic_fnc_changeBattery;
};