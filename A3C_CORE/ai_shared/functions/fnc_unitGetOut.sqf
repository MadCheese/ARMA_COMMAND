// A3C_ai_shared_fnc_unitGetOut

params ["_unit"];

private _vehicle = objectParent _unit;

if (!isNull _vehicle) then {
	[
		[_unit, _vehicle],
		{
			params ["_unit", "_vehicle"];
			// Not using action ["Eject", _vehicle] because of helicopters.
			_unit leaveVehicle _vehicle;
			// Needs to be executed on every machine.
			_unit remoteExec ["unassignVehicle", 0];
			doGetOut _unit;
			[_unit] orderGetIn false;
		}
	] remoteExec ["bis_fnc_call", _unit];
};

_vehicle