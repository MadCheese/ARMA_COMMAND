
//-- THIS FUNCTION IS REQUIRED REGARDLESS OF AIC!!
A3C_AIC_fnc_rappelActionHandler = {
	params ["_group","_cargoGroups","_selectedPosition","_inside"];
	_vehicle = (vehicle leader _group);
	if(count _selectedPosition > 0) then {
		[_vehicle,25, _selectedPosition] call AR_Rappel_All_Cargo; //-- AGLtoASL   //ATLtoASL _selectedPosition
		{
			[_x,_vehicle] spawn {
				params ["_groupRappelling","_vehicle"];
				_unitsInVehicle = true;
				while {_unitsInVehicle} do {
					_unitsInVehicle = false;
					{
						if(vehicle _x != _x) then {
							_unitsInVehicle = true;
						};
					} forEach (units _groupRappelling);
					sleep 1;
				};
				[_groupRappelling,_vehicle] remoteExec ["leaveVehicle", leader _groupRappelling]; //~~ _x
			};
		} foreach _cargoGroups;
	};
};

A3C_AIC_DRAGPOS = [];



