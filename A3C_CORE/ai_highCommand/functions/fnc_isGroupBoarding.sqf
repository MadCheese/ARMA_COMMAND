// A3C_ai_highCommand_fnc_isGroupBoarding

params [
	["_group", grpNull, [grpNull]]
];

if (isNull _group) exitWith {
	false
};

if (isPlayer leader _group) exitWith {
	false
};

private _return =
	false;

{
	private _unit =
		_x;

	if (
		alive _unit
		&& {isNull objectParent _unit}
		&& {
			currentCommand _unit
				isEqualTo "GET IN"
		}
	) then {
		private _assignedVehicle =
			assignedVehicle _unit;

		if (
			!isNull _assignedVehicle
			&& {alive _assignedVehicle}
			&& {canMove _assignedVehicle}
		) exitWith {
			_return = true;
		};
	};
} forEach units _group;

_return