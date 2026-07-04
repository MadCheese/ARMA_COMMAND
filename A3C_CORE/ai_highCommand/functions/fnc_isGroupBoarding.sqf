// A3C_ai_highCommand_fnc_isGroupBoarding
params ["_group"];

if (isPlayer (leader _group)) exitWith {false};

private _return = false;
{
	if (isNull objectParent _x) then {
		private _assignedVehicle = assignedVehicle _x;
		if (
			!isNull _assignedVehicle
			&& {canMove _assignedVehicle}
			&& {!(_x in _assignedVehicle)}
		) exitWith {
			_return = true;
		};
	};
} foreach units _group;
_return
