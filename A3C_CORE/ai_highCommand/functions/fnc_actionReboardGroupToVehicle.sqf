params ["_groups"];

private _vehicleBundles = [];

private _hcGroups = _groups select {
	private _group = _x;
	!isPlayer (leader _group) && {
		{
			!isNull objectParent _x && {
				!isNull (assignedVehicle _x)
			}
		} count (units _group) == 0 && {
			private _assignedVehicle = _group getVariable ["A3C_AssignedGroupVehicle", objNull];

			!isNull _assignedVehicle && {
				alive _assignedVehicle
			}
		}
	}
};

{
	private _group = _x;
	private _assignedVehicle = _group getVariable ["A3C_AssignedGroupVehicle", objNull];
	private _doAdd = true;

	{
		_x params ["_boardGroups", "_vehicle"];

		if (_assignedVehicle == _vehicle) exitWith {
			_doAdd = false;
			(_vehicleBundles select _forEachIndex) set [0, _boardGroups + [_group]];
		};
	} forEach _vehicleBundles;

	if (_doAdd) then {
		_vehicleBundles pushBack [[_group], _assignedVehicle];
	};
} forEach _hcGroups;

{
	_x params ["_boardGroups", "_selectedVehicle"];

	[_boardGroups, _selectedVehicle] call A3C_HC_AssignVehicle;
} forEach _vehicleBundles;