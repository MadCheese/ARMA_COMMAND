// A3C_ai_shared_fnc_getOut
// Dismount unit.

params ["_unit"];

// Why the loop? Something can pull the unit back into the vehicle and leave it there
// with no assigned vehicleRole. Keep retrying until the unit is actually dismounted.
while { alive _unit } do {
	if (isNull _unit) exitWith {};

	if (!isNull objectParent _unit) then {
		[_unit, vehicle _unit] remoteExec ["leaveVehicle", _unit];
		_unit remoteExec ["unassignVehicle", 0];
		_unit remoteExec ["doGetOut", _unit];
	};

	if (isNull objectParent _unit) exitWith {};

	sleep 0.1;
};

sleep 2;

if ((_unit getVariable ["A3C_PLOT", []]) isEqualTo []) then {
	[_unit, leader group _unit] remoteExec ["doFollow", _unit];
};

// Instead of doStop, pass an optional destination position into this function for 360 security.
_unit setVariable ["A3C_PAUSE_PLAN", false, false];