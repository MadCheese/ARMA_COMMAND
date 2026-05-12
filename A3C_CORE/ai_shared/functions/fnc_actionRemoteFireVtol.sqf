// A3C_ai_shared_fnc_actionRemoteFireVtol 

/*
	INFO:

	_weaponID - possible values: "GATLING", "CANNON"
	>> NOTE: "AUTOCANNON" does not work with forceWeaponFire on both vehicle types

	TURRETS:
	- Main Gunner: [1] >> Gatliung and Big Cannon 
	- Secondary Gunner: [2] >> Small Cannon 
*/

if !(isClass(configFile/"CfgPatches"/"A3C_OBJECTS")) exitWith {};

params ["_side", "_vehicle","_targetPosASL","_weaponID","_targetVehicle"];

// if (true) exitWith {};
private _group = group (driver _vehicle);
private _wpType = waypointType [_group, currentWaypoint _group];
private _vehicleType = typeOf _vehicle;

private _weaponIDArray = ["GATLING", "CANNON", "AUTOCANNON"]; //if (_vehicleType == "B_T_VTOL_01_armed_F") then {["GATLING", "CANNON"]} else {["GATLING", "CANNON","AUTOCANNON"]};

if !(_weaponID in _weaponIDArray) exitWith { 
	"INCORRECT WEAPON TYPE" spawn MCSS_fnc_ShortHint;
};

if !(_vehicleType in ["B_T_VTOL_01_armed_F", "B_T_VTOL_01_armed_fixed_F"]) exitWith {
	"SELECTED VEHICLE IS NOT A ARMED BLACKFISH" spawn MCSS_fnc_ShortHint;
};

if (_wpType != "LOITER") exitWith {
	"VEHICLE IS NOT ON A LOITER WAYPOINT" spawn MCSS_fnc_ShortHint;
};



private _unitTurret = [1]; //if (_weaponID in ["GATLING", "CANNON"]) then {[1]} else {[2]};
private _unit = _vehicle turretUnit _unitTurret;

private _weapons = _vehicle weaponsTurret _unitTurret;

// private _targetType = switch (_side) do {
// 	case (WEST): {"CBA_O_InvisibleTargetAir"};
// 	case (EAST): {"CBA_B_InvisibleTargetAir"};
// };

private _targetType = if (_side getFriend WEST >= 0.6) then {"CBA_O_InvisibleTargetAir"} else {"CBA_B_InvisibleTargetAir"};


private _target = _targetType createVehicle [0,0,0]; //-- can not be local as EH needs to address it
_target setposASL _targetPosASL;
_unit reveal [_target, 4];

if (!isNull _targetVehicle) then {
	_target attachTo [_targetVehicle, [0,0,0]];
};

private _weapon = "";

if (_vehicleType == "B_T_VTOL_01_armed_fixed_F") then {
	_weapon = switch (_weaponID) do {
		case ("GATLING"): {"gatling_25mm_V44"};
		case ("CANNON"): {"cannon_105mm_V44"};
		case ("AUTOCANNON"): {"autocannon_40mm_V44"};
	};
} else {
	_weapon = switch (_weaponID) do {
		case ("GATLING"): {"gatling_20mm_VTOL_01"};
		case ("CANNON"): {"cannon_105mm_VTOL_01"};
		case ("AUTOCANNON"): {"autocannon_40mm_VTOL_01"};
	};
};



_vehicle selectWeaponTurret [_weapon, _unitTurret];

sleep 1; //-- give time to switch weapon, not sure if needed
if (a3c_debug) then {
	systemchat format ["selected weapon: %1", _weapon];
	systemchat format ["current weapon turret: %1", _vehicle currentWeaponTurret _unitTurret];
};


_fnc_isAimed = {
	params ["_vehicle", "_target","_weapons"];
	{_vehicle aimedAtTarget [_target, _x] > 0.4} count _weapons > 0
};

_unit doTarget _target;
_unit lookAt _target;

_vehicle lockCameraTo [_target, _unitTurret, false];

private _doFire = true;
private _timer = time;

private _mode = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) select 0;


while {alive _vehicle} do {

	private _aimed = [_vehicle, _target,_weapons] call _fnc_isAimed;

	if ( (time - _timer) > 2 || {_aimed}) exitWith {
		if ((time - _timer) < 2) then {
			_doFire = true;
		};
	};
	sleep 0.1;
};

// systemchat str [_doFire, round time];

if (_doFire) then {
	
	

	_id = format ["BLCKFSH_HNDL_%1", A3C_REMOTE_BLACKFISH_HandlerIndex];
	A3C_REMOTE_BLACKFISH_HandlerIndex = A3C_REMOTE_BLACKFISH_HandlerIndex + 1;
	publicVariable 'A3C_REMOTE_BLACKFISH_HandlerIndex';

	// //-- add EH on every machine
	[ ["ADD", _id, netID _vehicle], A3C_REMOTE_VTOL_HandlerFNC] remoteExec ["bis_fnc_call", 0];

	_vehicle setvariable ["A3C_VTOL_REMOTE_HANDLE", [netID _target,  objNull, ""], true];

	// private _shellAmount = if ('gatling' in (toLower _weapon)) then {20} else {1};
	private _shellAmount = switch (_weaponID) do {
		case ("GATLING"): {25};
		case ("AUTOCANNON"): {10};
		// case ("CANNON"): {1};	
		default {1};
	};

	if (a3c_debug) then {
		systemchat format ["FIRING: %1, %2 Shells", _weapon, _shellAmount];
	};

	sleep 1; //-- required because it seems that EH takes a little to be added 
	private _sleep = 0.05;
	for "_i" from 1 to _shellAmount do {
		if (_weaponID == "AUTOCANNON") then {
			_sleep = 0.3;
			private _shot = [_vehicle, _weapon] call BIS_fnc_fire;
		} else {
			_unit forceWeaponFire [_weapon, _mode];
		};
		sleep _sleep;
		private _relPosASL = [_targetPosASL, random 10, random 360] call BIS_fnc_RelPos;
		_target setPosASL _relPosASL; //-- RE_ADD THIS FOR SPREAD!!!!
	};
	sleep 5;
	//-- remove EH on every machine
	[ ["REMOVE", _id, netID _vehicle], A3C_REMOTE_VTOL_HandlerFNC] remoteExec ["bis_fnc_call", 0];
	


} else {
	"VEHICLE COULD NOT FIRE - TRY AGAIN" spawn MCSS_fnc_ShortHint;
};
sleep 5;
deletevehicle _target;
