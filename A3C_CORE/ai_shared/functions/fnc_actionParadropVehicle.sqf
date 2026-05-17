// A3C_ai_shared_fnc_actionParadropVehicle

params ["_vehicle"];

{
	_vehicle animateDoor [_x,1];
} foreach ['door_rear','door_rear_source','Door_1_source'];
sleep 2;
_vehicle setVehicleCargo objNull; //-- this command ejects the loaded vehicles
sleep 4;
{
	_vehicle animateDoor [_x,0];
} foreach ['door_rear','door_rear_source','Door_1_source'];
_vehicle setVariable ["A3C_ParadropActive",false,true];
