// A3C_ai_shared_fnc_actionRappelStart

params ["_group", "_cargoGroups", "_selectedPosition", "_inside"];

private _vehicle = vehicle leader _group;

if (_selectedPosition isEqualTo []) exitWith {};

[_vehicle, 25, _selectedPosition] call AR_Rappel_All_Cargo;

{
	[_x, _vehicle] spawn {
		params ["_rappelGroup", "_vehicle"];

		waitUntil {
			sleep 1;

			{
				vehicle _x != _x
			} count units _rappelGroup == 0
		};

		[_rappelGroup, _vehicle] remoteExec ["leaveVehicle", leader _rappelGroup];
	};
} forEach _cargoGroups;