// A3C_main_fnc_getDismountData

//-- gets units for HC drivers/pilots to drop
//-- THIS FUNCTION ONLY DETERMINES WHAT UNITS CAN BE DISMOUNTED
params ["_vehicle","_pilot"];

private _dismountUnits = [];
private _groups = [];

private _pilotGroup = group _pilot;
private _pilotGroupLeader = leader _pilotGroup;
private _isPilotGroupLedByPlayer = isPlayer _pilotGroupLeader;

{
	private _unit = _x;
	private _unitGroup = group _unit;
	private _addToDismountList = false;

	_groups pushBackUnique _unitGroup;

	if (_unitGroup == _pilotGroup) then {
		//-- unit is in pilots group. only dismount if groupLeader is a player!
		if (_isPilotGroupLedByPlayer) then {
			private _assignedVehicleRole = assignedVehicleRole _unit;

			if (count _assignedVehicleRole > 0) then {
				private _roleType = _assignedVehicleRole select 0;

				if (_roleType == "CARGO") then {
					_addToDismountList = true;
				};

				if (_roleType == "Turret") then {
					private _turret = _assignedVehicleRole select 1;

					if (count (_vehicle weaponsTurret _turret) == 0) then {//-- FFV positions
						_addToDismountList = true;
					};

					if (_unit call MCSS_fnc_isUnitCopilot) then { //-- coPilot position
						_addToDismountList = true;
					};
				};
			} else {
				//-- no role assigned: treated as ejectable
				_addToDismountList = true;
			};
		};
	} else {
		//-- unit is not in pilot's group. definitely dismount
		_addToDismountList = true;
	};

	if (_addToDismountList) then {
		_dismountUnits pushBackUnique _unit;
	};
} forEach ((crew _vehicle) - [_pilot]);

[_dismountUnits,[]]