
//-- spawn ambient objects
			for "_i" from 1 to (5 + (floor random 10)) do {
				_objectType = selectRandom _toolsPeriphery;
				_objectPos = (getPosATL _repairPatient) findEmptyPosition [(sizeOf typeOf _repairPatient) / 2,sizeOf typeOf  _repairPatient,_objectType];
				if (count _objectPos > 0) then {
					_peripheryObject = _objectType createVehicle _objectPos;
					_peripheryObject setDir (random 360);
					_ambientObjects pushBack _peripheryObject;
				};	
			};

//// before [_unit] spawn A3C_REPAIR_ANIMS;
// private _anims =
						// [
						// 	"Acts_carFixingWheel",
						// 	"inbasemoves_assemblingvehicleerc",
						// 	"inbasemoves_repairvehicleknl",
						// 	"ainvpknlmstpslaywrfldnon_medic"
						// ];
						// _anim = _anims call BIS_fnc_SelectRandom;
						
						// _unitPos = if (_anim == "inbasemoves_assemblingvehicleerc") then {"UP"} else {"MIDDLE"};
						// _unitStance = if (_anim == "inbasemoves_assemblingvehicleerc") then {"STAND"} else {"CROUCH"};
						//if ("inbase" in _anim) then {
						// if !((animationState _unit) in _anims) then {
							// [_unit,""] remoteExec ["switchMove",0];
							// _unit enableAI "ANIM";
							// _unit setUnitPos _unitPos;
							// waitUntil {!alive _unit or stance _unit == _unitStance};
							// _unit disableAI "ANIM";
							// _unit switchMove _anim;
							// [_unit,_anim] remoteExec ["switchMove",0];
						//} else {
						//	_unit switchMove _anim;
						// };


/*

[] spawn {
	_soundConfigs = "true" configClasses (configFile >> "cfgSounds");
	speaker1 = objNull;
	{
		_sound = configName _x;
		//if ({_x in tolower _sound} count ["tool","repair"] > 0  ) then {
			speaker1 = "Land_HelipadEmpty_F" createVehicle position player;
			///playSound _sound;
			speaker1 say3d _sound;
			systemchat str _sound;
			waituntil {isNull speaker1};
		//};
	} foreach _soundConfigs;
};

moduleName_keyDownEHId = findDisplay 46 displayAddEventHandler ["KeyDown", {deletevehicle speaker1}];


////////////////

sds = ["Orange_PeriodSwitch_Post_01","Orange_PeriodSwitch_Pre_01","Land_Carrier_01_blast_deflector_down_sound","Land_Carrier_01_blast_deflector_up_sound","Land_Carrier_01_wire_snap_sound","UAV_05_tailhook_down_sound","UAV_05_tailhook_up_sound","UAV_05_foldwing_sound","DataTerminalLoop","vr_goggles","bobcat_engine_start","VTOL_01_int_engine_rotor","Acts_CarFixingWheel","electricity_loop","assemble_target"];

lengths = [2.903,3.861,2.031,2.171,3.28,2.609,2.711,4.712,11.472,5.76,3.928,45.036,21.72,5.582,2.76,4.851,1.38899,5.80699,8.48,8.491,17.681,11.004,2.71199,1.661];





sds1 = [];
{
	sds1 pushBack [_x,lengths select _foreachIndex];
} foreach sds;

copytoclipboard str sds1;
if (true) exitwith {};



sds = [];

for "_i" from 1 to 9 do {
	sds pushBack format ["uav_0%1",_i];
};



time_array = [];
[] spawn {
	_soundConfigs = "true" configClasses (configFile >> "cfgSounds");
	speaker1 = objNull;
	{
		_sound =  _x;
		//if ({_x in tolower _sound} count ["tool","repair"] > 0  ) then {
			speaker1 = "Land_HelipadEmpty_F" createVehicle position player;
			///playSound _sound;
			speaker1 say3d _sound;
			systemchat str _sound;
			timer1 = time;
			waituntil {isNull speaker1};
		//};
	} foreach sds;
	systemchat "done";
	copytoclipboard str time_array;
};

moduleName_keyDownEHId = findDisplay 46 displayAddEventHandler ["KeyDown", {time_array pushBack (time - timer1); systemchat str (time - timer1); deletevehicle speaker1; }];

/////////////////////////


sds = 
[
	["Orange_PeriodSwitch_Post_01",2.903],
	["Orange_PeriodSwitch_Pre_01",3.861],
	["Land_Carrier_01_blast_deflector_down_sound",2.031],
	["Land_Carrier_01_blast_deflector_up_sound",2.171],
	["Land_Carrier_01_wire_snap_sound",3.28],
	["UAV_05_tailhook_down_sound",2.609],
	["UAV_05_tailhook_up_sound",2.711],
	["UAV_05_foldwing_sound",4.712],
	["vr_goggles",5.76],
	["bobcat_engine_start",3.928],
	["Acts_CarFixingWheel",21.72],
	["electricity_loop",5.582],
	["assemble_target",2.76]
];


[] spawn {
	_soundConfigs = "true" configClasses (configFile >> "cfgSounds");
	{
		_x params ["_sound","_length"];
		speaker1 = "Land_HelipadEmpty_F" createVehicle position player;
		speaker1 say3d _sound;
		systemchat str _sound;
		sleep _length;
		deleteVehicle speaker1;
	} foreach sds;
	systemchat "done";
};




sds = [];

for "_i" from 1 to 9 do {
	sds pushBack format ["uav_0%1",_i];
};
uavarray = [];
uavlengths = [6.058,11.772,5.72099,8.787,4.42601,18.061,10.682,3.588,1.507];
{
	uavarray pushback [_x,uavlengths select _foreachINdex];
} foreach sds;

copytoclipboard str uavarray;