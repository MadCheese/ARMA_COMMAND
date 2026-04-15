
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////       THESE FUNCTIONS ARE SHARED BY SQUAD-LEVEL AND HIGH COMMAND LEVEL      ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



A3C_isCargoUnitEjectable = { //-- shared by player squad and HC
	params ["_unit","_vehicle"];
	private ["_return"];
	_return = false;
	if ((assignedVehicleRole _x) select 0 == "CARGO") then {
		_return = true;
	};
	if ((assignedVehicleRole _x) select 0 == "Turret") then {
		private _turret = (assignedVehicleRole _x) select 1;
		if (count (_vehicle weaponsTurret _turret) == 0 ) then {
			_return = true;
		};
		if (_unit call MCSS_fnc_isUnitCopilot && ((_vehicle isKindOf 'HELICOPTER'))) then {
			_return = true;
		};

	};
	_return
};
A3C_isCargoGroupEjectable = {
	params ["_gp","_refUnit"];
	private ["_return"];
	_return = false;
	{
		private _veh = vehicle _x;
		if (_veh == vehicle _refUnit) then { //-- this is necessary to not dismount units in other vehicles
			if ([_x, _veh] call A3C_isCargoUnitEjectable) then {
				_return = true;
			};
		};
	} foreach units _gp;

	//-- overRide options for non player/pilot groups
	{
		//-- overRide TRUE if one or more units of cargo group DO have turret weapons
		private _veh = vehicle _x;
		if (_veh == vehicle _refUnit) then { //-- this is necessary to not dismount units in other vehicles
			if ((assignedVehicleRole _x) select 0 == "Turret") then {
				private _turret = (assignedVehicleRole _x) select 1;
				if !(_x call MCSS_fnc_isUnitCopilot) then {
					if (count (_veh weaponsTurret _turret) > 0 ) then {
						_return = false;
					};
				};
			};
		};
	} foreach units _gp;
	_return
};