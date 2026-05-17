// A3C_ai_shared_fnc_actionParadropPersonnel

params ["_dropVehicle"];

private _pilot = driver _dropVehicle;

private _doorSources = [
	"door_R",
	"door_L",
	"door_rear",
	"door_rear_source",
	"Door_L_source",
	"Door_R_source",
	"DoorL_Front_Open",
	"DoorR_Front_Open",
	"DoorL_Back_Open",
	"DoorR_Back_Open",
	"Door_1_source"
];

{
	_dropVehicle animateDoor [_x,1];
} forEach _doorSources;

sleep 2;

private _dismountData = [_dropVehicle,_pilot] call A3C_main_fnc_getDismountData;
_dismountData params ["_dropUnits","_nonDismountAIgroups"];

{
	private _dropUnit = _x;

	[
		[_dropUnit],
		{
			params ["_unit"];

			private _dropVehicle = vehicle _unit;

			unAssignVehicle _unit;
			_unit remoteExec ["unAssignVehicle",0];

			_unit allowDamage false; //-- disable damage for drop
			_unit disableCollisionWith _dropVehicle; //-- disable collision for drop

			[_unit] orderGetIn false;

			moveOut _unit; //-- move unit out of chopper (no anim, immediate)

			waitUntil {
				isNull objectParent _unit
			};

			if (((getPosVisual _unit) select 2) > 40) then {
				sleep 1;
			} else {
				sleep 0.5;
			};

			unAssignVehicle _unit; //-- unAssign 2, outside
			_unit remoteExec ["unAssignVehicle",0];
			[_unit] orderGetIn false;

			waitUntil {
				(getPosVisual _unit) select 2 < 150
			};

			sleep (random 2);

			//-- spawn chute
			private _chuteType = "Steerable_Parachute_F";
			private _chute = createVehicle [_chuteType, getPos _unit, [], 0, "NONE"];

			_chute setPos (getPos _unit);

			_unit moveInDriver _chute;

			sleep 1;

			_unit allowDamage true; //-- re-enable damage during flight
			_unit enableCollisionWith _dropVehicle; //-- re-enable collision with heli

			//-- wait for safe touchdown
			while {alive _unit} do {
				unAssignVehicle _unit;
				_unit remoteExec ["unAssignVehicle",0];

				if ((getPosATL _unit) select 2 < 2.5) then {
					_unit allowDamage false; //-- disable damage for landing
				};

				if (isTouchingGround _unit) exitWith {
					for "_i" from 1 to 10 do {
						unAssignVehicle _unit;
						_unit remoteExec ["unAssignVehicle",0];
						sleep 0.1;
					};
				};

				sleep 0.1;
			};

			unAssignVehicle _unit;
			_unit remoteExec ["unAssignVehicle",0];

			sleep 2;

			_unit allowDamage true; //-- re-enable damage after landing
		}
	] remoteExec ["BIS_fnc_spawn", _dropUnit];

	sleep 1;
} forEach _dropUnits;

waitUntil {
	{
		alive _x && {_x in _dropVehicle}
	} count _dropUnits == 0
};

{
	if (group _x != group driver _dropVehicle) then { //--really AIC dependant?
		[group _x,_dropVehicle] remoteExec ["leaveVehicle",leader group _x];
	};
} forEach _dropUnits;

sleep 1;

{
	_dropVehicle animateDoor [_x,0];
} forEach _doorSources;

_dropVehicle setVariable ["A3C_ParadropActive",false,true];