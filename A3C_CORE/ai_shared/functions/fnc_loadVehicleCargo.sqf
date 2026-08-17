// A3C_ai_shared_fnc_loadVehicleCargo

//-- executes on client with remoteExec because client needs to see the chat message

params ["_vehicle","_cargoVehicle"];

private _cfgVehicles = configFile >> "CfgVehicles";

private _vehicleDisplayName = getText (_cfgVehicles >> typeOf _vehicle >> "displayName");
private _cargoVehicleDisplayName = getText (_cfgVehicles >> typeOf _cargoVehicle >> "displayName");

[_vehicle,true] remoteExec ["enableVehicleCargo",_vehicle];

if !((_vehicle canVehicleCargo _cargoVehicle) select 0) exitWith {
	if (!isDedicated) then {
		systemChat format [
			"A3C: %1 [%2] has no space to load this %3.",
			_vehicleDisplayName,
			_vehicle,
			_cargoVehicleDisplayName
		];
	};
};

[_vehicle,_cargoVehicle] remoteExec ["setVehicleCargo",_vehicle];

if (isDedicated) exitWith {};

private _chat = format [
	"A3C: %1 [%2] was loaded with a %3.",
	_vehicleDisplayName,
	_vehicle,
	_cargoVehicleDisplayName
];

// if !((_vehicle canVehicleCargo player) select 0) then {
// 	_chat = _chat + " Vehicle is now full";
// };

systemChat _chat;