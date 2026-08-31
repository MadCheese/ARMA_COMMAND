// A3C_ai_highCommand_fnc_updateGroupBoardingState

params [
	["_group", grpNull, [grpNull]]
];

if (isNull _group) exitWith {};

if (!local _group) exitWith {};

private _isBoarding = false;

{
	if (
		alive _x
		&& {isNull objectParent _x}
		&& {currentCommand _x isEqualTo "GET IN"}
	) then {

		private _assignedVehicle = assignedVehicle _x;

		if (
			!isNull _assignedVehicle
			&& {alive _assignedVehicle}
			&& {canMove _assignedVehicle}
		) exitWith {
			_isBoarding = true;
		};
	};
} forEach units _group;

if (
	(_group getVariable ["A3C_isBoarding", false])
	!= _isBoarding
) then {
	_group setVariable [
		"A3C_isBoarding",
		_isBoarding,
		true
	];
};