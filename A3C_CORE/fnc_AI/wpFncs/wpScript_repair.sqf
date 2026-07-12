

params ["_group", "_pos", "_target","_callerUID","_preCondition"];

//-- #TODO: While it works now, anims scripting is sort of messy right now. Double check everything and m,ake sure unit is not trying to move anywhere


if ([_callerUID,_group] call A3C_ai_highCommand_fnc_isWpScriptBlocked) exitWith {};

[_group] call A3C_ai_highCommand_fnc_reInitGroupMovement;


private _wpIndex = currentWaypoint _group;

//private _waypointPositions =  [_pos,units _group,count units _group, (_pos getDir (leader _group)) + 180,100 ] call A3C_main_fnc_generateWpWedgePositions;

private _assignedIndex = 0;

private _leader = leader _group;
private _leaderVic = vehicle _leader;

//-- wait for arrival
private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _leaderVic) >> "precision")) * 1.3) + 20;
_t = str (floor random 9);  //~~ ??
sleep 1;
while {_leaderVic distance2d _pos >= _precision} do {
	[_group,_pos] call A3C_ai_shared_fnc_approachWaypointRegular;
	sleep 10;
};


/*
TO DO:
we should only do long repair with animations for certain very perceivable hitpoints:
hull glass track wheel engine turret gun  light (only if dark?)

>> (getAllHitPointsDamage cursortarget select 0) select {'glass' in tolower _x}
>> we could instantly repair all other hitpoints and focus on the stuff that can be visually observed

*/

// "WAYPOINT REACHED" remoteexec ["systemchat", 0];

// if (vehicle leader _group distance2d _pos > _precision) exitWith {}; //-- waypoint was not reached

//-- compose pre- and post conditions, wait for pre-condition
// systemchat str [_preCondition];



private _fnc_repairAnim = {
	params ["_unit"];

	if ((_unit getVariable ["A3C_HandlerID_AnimDone", [false, -1]]) select 0) exitWith {};

	private _anims = [
		"Acts_carFixingWheel",
		"inbasemoves_assemblingvehicleerc",
		"inbasemoves_repairvehicleknl",
		"ainvpknlmstpslaywrfldnon_medic"
	];

	private _anim = selectRandom _anims;

	_unit disableAI "ANIM";
	_unit switchMove _anim;

	private _handler = _unit addEventHandler ["AnimDone", {
		params ["_unit", "_anim"];

		if !((_unit getVariable ["A3C_HandlerID_AnimDone", [false, -1]]) select 0) exitWith {};

		private _anims = [
			"Acts_carFixingWheel",
			"inbasemoves_assemblingvehicleerc",
			"inbasemoves_repairvehicleknl",
			"ainvpknlmstpslaywrfldnon_medic"
		];

		private _nextAnim = selectRandom _anims;

		_unit switchMove _nextAnim;
	}];

	_unit setVariable ["A3C_HandlerID_AnimDone", [true, _handler], true];
};


private _exitCondition = {};
{
	_x params ["_condType","_condVal"];
	_exitCondition = switch (toUpper _condType) do {
		case ("TIMEOUT") : {
			_timeAtCompletion = time + _condVal;
			compile format ["time > %1",_timeAtCompletion];
		};
		case ("GOCODE") : {
			compile format ["A3C_GoCode_Activate_%1",_condVal];
		};
		case ("DAYTIME") : {
			_str = _condVal splitString ":";
			_checkParams = [];
			{
				_checkParams pushBack (parseNumber _X)
			} foreach _str;
			compile format ["%1 call A3C_main_fnc_isDaytimeCompleted",_checkParams];
		};
		default {{true}};
	};
	if (_foreachIndex == 0) then {
		//systemchat str _exitCondition;
		waitUntil {[] call _exitCondition}; //-- _foreachIndex == 0 is for pre-condition
		if !((_preCondition select 0) in ["ARRIVAL",""]) then {
			[_group,_wpIndex] setWaypointScript format 
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_repair.sqf ['%1',%2,%3]",
				_callerUID,
				["ARRIVAL",""]
			];
			[_group,_wpIndex] setWaypointPosition [_pos,0];
			private _statements = waypointStatements [_group,_wpIndex];
			_statements set [0,"true"];
			[_group,_wpIndex] setWaypointStatements _statements;
		};
	};
} foreach [_preCondition];

_repairUnits = units _group select {[_x] call A3C_main_fnc_canRepair};

// (format ["_repairUnits: %1", _repairUnits]) remoteexec ["systemchat", 0];

_behaviour = behaviour _leader; //-- save current group behaviour
_group setBehaviourStrong "SAFE"; //-- set units to safe


{
	sleep 0.2;
	[_x,_foreachIndex, _pos,_wpIndex,_callerUID] spawn {
		params ["_unit","_unitIndex", "_pos","_wpIndex","_callerUID"];
		private _repairVic = vehicle _unit;

		

		_toolsWheels = ["Land_TankRoadWheels_01_single_F","Land_TankSprocketWheels_01_single_F"];
		_toolsSmall = ["Item_ToolKit","Land_DrillAku_F","Land_ButaneTorch_F","Land_Wrench_F"];

		_toolsPeriphery =
		[
			"Land_CarBattery_01_F",
			"Land_CarBattery_02_F",
			"Land_ExtentionCord_F",
			"Land_Portable_generator_F",
			"Land_CarBattery_02_F",
			"Land_PowerCable_01_Roll_F",
			"Land_BatteryPack_01_open_Black_F"
		];

		_toolsPeriphery = _toolsPeriphery + _toolsWheels + _toolsSmall;

		_soundsRepairVehicle = 
		[
			["Land_Carrier_01_blast_deflector_down_sound",2.031],
			["Land_Carrier_01_blast_deflector_up_sound",2.171],
			["Land_Carrier_01_wire_snap_sound",3.28],
			["UAV_05_tailhook_down_sound",2.609],
			["UAV_05_tailhook_up_sound",2.711],
			["UAV_05_foldwing_sound",4.712],
			["bobcat_engine_start",3.928],
			["assemble_target",2.76]
		];

		_soundsRepairSmall = 
		[
			["vr_goggles",5.76],
			["Acts_CarFixingWheel",21.72],
			["electricity_loop",3]
		];

		_soundsRepairFinal = _soundsRepairSmall;


		_soundsUAV = 
		[
			["uav_01",6.058],
			["uav_02",11.772],
			["uav_03",5.72099],
			["uav_04",8.787],
			["uav_05",4.42601],
			["uav_06",18.061],
			["uav_07",10.682]
		];

		private _soundsCarpet = 
		[
			//["VTOL_01_int_engine_rotor",20],
			["DataTerminalLoop",10]
		];
		
		

		_unit disableAI "AUTOCOMBAT";
		// (format ["unit: %1 is starting loop", name _unit]) remoteexec ["systemchat", 0];
		// [_unit,"AmovPercMstpSrasWrflDnon"] remoteExec ["switchMove",0];

		

		while {alive _unit} do {
			//systemchat str _unit;
			if !([_unit] call A3C_main_fnc_canRepair) exitWith {};
			_entities = (_pos nearEntities [["Car","Motorcycle","Tank","AIR"], 100]) select {[side _unit, _x] call A3C_main_fnc_isVehicleDamaged};
			// (format ["Need treatment: %1 ", _entities]) remoteexec ["systemchat", 0];
			if (_entities isEqualTo []) exitWith {};
			private _quit = false;
			
			_entities = 
			[
				_entities,
				[],
				{
					_factor = if ((_x getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0) then {1} else {5};
					(_x distance2D (vehicle _unit))  * _factor
				},
				"ASCEND"
			] call BIS_fnc_sortBy; //-- sort repair-candiates by distance to unit

			_repairPatient = _entities select 0;

			_unit setVariable ["A3C_isRepairing",[true,_repairPatient],true];
			
			if (!isNull objectParent _unit) then {
				//-- trucks need to move up to the vehicle. Soldiers will later move directly to the fixed hitpoint
				_unit lookAt _repairPatient;
				_unit domove (position _repairPatient);
				_unit moveTo (position _repairPatient);
				waitUntil {!alive _unit OR {unitReady _unit}};
			};
			// (format ["unit: %1 is repearing", name _unit]) remoteexec ["systemchat", 0];

			// if (_unitIndex == 0) then {  // << CONDITION NOT NEEDED. CAN FIRE MULTIPLE TIMES / BETTER THAN UNIT DYING EN ROUTE
				// systemchat 'TESTING AUTO REPAIR';
				private _visualRepairStrings = ["hull", "glass", "track", "wheel", "engine", "turret", "gun", "light", "body"];
				private _hitPointDamage = getAllHitPointsDamage _repairPatient;
				_hitPointDamage params ['_hpNames', '_hpValues'];
				{
					private _hitPointNameLower = toLower _x;
					private _fi = _forEachIndex;
					if ({_x in _hitPointNameLower} count _visualRepairStrings == 0) then {
						_repairPatient setHitPointDamage [_x, 0];
					};
				} forEach _hpNames;
			// };
			
			
			_fnc_feedback = compile format
			[
				"if ('%1' == getPlayerUID player) then {systemchat ""A3C: %2 (%3) has started repairing a %4 %5""};",
				_callerUID,
				name _unit,
				groupID group _unit,
				getText (configFile >> "CfgVehicles" >> typeOf _repairPatient >> "displayName"),
				if (count crew _repairPatient > 0) then {format ["from %1",groupID (group ((crew _repairPatient) select 0))]} else {""}		
			]; 
			_fnc_feedback remoteExec ["bis_fnc_call",0];

			_movers = [vehicle _unit,_unit];
			{_x disableAI "MOVE"} foreach _movers;


			private _coneObjects = [_repairPatient];
			if ((_repairPatient getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0 ) then {
				//-- vehicle is already being treated! remove it from cone-objects so we don't get a messy site
				_coneObjects = _coneObjects - [_repairPatient];
			};



			_repairPatient setVariable 
			[
				"A3C_isBeingRepaired",
				[
					true, //-- bool - repaired or not
					0, //-- value of average damage (for icon display, we don't want to calculate this on each frame)
					[] //-- array of currently repaired hitpoints
				],
				true
			];


			//-- create scene
			
			private _soundLoop = {
				params ["_engineer","_repairPatient","_soundArray"];

				if (isNull player || {player distance2D _engineer > 100}) exitWith {};
				private _soundSource = objNull;
				while {(_repairPatient getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0} do {
					_soundSource = "Land_HelipadEmpty_F" createVehicle position _engineer;
					private _sound = selectRandom _soundArray;
					_soundSource say3D (_sound select 0);
					_timer = time;
					while {time - _timer < (_sound select 1)} do {
						if !((_repairPatient getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0) exitWith {};
						sleep 1;
					};
					deletevehicle _soundSource;
				};
				if (!isNull _soundSource) then {deletevehicle _soundSource};
			};
			

			private _ambientObjects = [];

			

			if (!isNull objectParent _unit) then {
				// Repair-Man Scene
				
				//--- sound carpet loop
				[[vehicle _unit,_repairPatient,_soundsCarpet],_soundLoop] remoteExec ['bis_fnc_spawn',0];
				[[vehicle _unit,_repairPatient,_soundsUAV],_soundLoop] remoteExec ['bis_fnc_spawn',0];
				

				
				_coneObjects pushBack (vehicle _unit);

		
				_soundsRepairFinal = _soundsRepairFinal + _soundsRepairVehicle;

				[[_repairPatient,_repairPatient,_soundsRepairFinal],_soundLoop] remoteExec ['bis_fnc_spawn',0];
				


			} else {
				
				
			};
			//-- standard repair sounds

			[[vehicle _unit,_repairPatient,_soundsRepairFinal],_soundLoop] remoteExec ['bis_fnc_spawn',0];
			
			

			
			
			//-- create roadCone area
			{
				_vic = _x;
				_boxPositions = ([_x,0] call MCSS_fnc_getBoundingBox);
				{
					_obj = "RoadCone_L_F" createVehicle _x;
					_obj setPos _x;
					_obj setDir (random 360); //(getDir _vic);
					_ambientObjects pushBack _obj;
					sleep (random 1);
				} foreach _boxPositions;
			} foreach _coneObjects;

			if ([_repairPatient] call MCSS_fnc_isObjectFlipped) then {
				//_unit action ["repairVehicle", _repairPatient];
				if (isNull objectParent _unit) then {_unit switchMove "Acts_carFixingWheel"};
				for "_t" from 1 to 7 do {
					if (alive _unit) then {sleep 0.25}
				};
				_repairPatient setPos (((getPosASL _repairPatient) select [0,2]) + [0]);
			};

			_allHitPoints = getAllHitPointsDamage _repairPatient; //-- #TODO: sort hitpoints by priority. FUEL/Turret/Wheel/Track/HULL/Glass. tricky because of the 3 array dimensions
			
			_hitPointNames = (_allHitPoints select 0);
			_selectionNames = (_allHitPoints select 1);
			_hitPointValues = (_allHitPoints select 2);

			_healUp = true;
			{
				if (_quit) exitWith {
					_healUp = false;
					if (isNull objectParent _unit) then {
						// _unit switchMove "";
						[_unit,""] remoteExec ["switchMove",0];
						_unit enableAI "ANIM";
					};
				};
				_hitPointName = _hitPointNames select _foreachIndex; //(_allHitPoints select 0) select _foreachIndex;
				_selectionName = _selectionNames select _foreachIndex; //(_allHitPoints select 0) select _foreachIndex;

				// player commandchat format ["Repairing %1",_hitPointName];
				_doRepairHitpoint = false;
				_data = _repairPatient getVariable ["A3C_isBeingRepaired",[false,0,[]]];
				if (_data select 0) then {
					_treatedHitpoints = _data select 2;
					if !(_hitPointName in _treatedHitpoints && {_x > 0.15}) then {
						_doRepairHitpoint = true;
						_treatedHitpoints pushBack _hitPointName;
						_data set [2,_treatedHitpoints];
						_repairPatient setVariable ["A3C_isBeingRepaired",_data];
					};	
				};
				if (_doRepairHitpoint) then {
					if (isNull objectParent _unit && (_foreachIndex == 0)) then { //-- _foreachindex: only walk towards first hitpoint
						_selPos = _repairPatient selectionPosition _selectionName;
						if !(_selPos isEqualTo [0,0,0]) then {
							_unit setUnitPos "UP";
							{_unit enableAI _x} foreach ["MOVE","ANIM"];
							_selPos = _repairPatient modelToWorld _selPos;
							_unit domove _selPos;
							_unit moveTo _selPos;
							waitUntil {!alive _unit OR {unitReady _unit}};
							{_unit disableAI _x} foreach ["MOVE","ANIM"];
						};
					};

					_doCanMoveCheck = !canMove _repairPatient;

					_prop = objNull;

					_ambientAnim = false;
					_backPackData = ["",[]];
					
					_sleepTime = 1; //-- default hitpoint treatment time (vehicles)
					if (isNull objectParent _unit) then {
						_unit disableAI "ANIM";
						_sleepTime = if ("wheel" in _hitPointName) then {5} else {1.5}; //-- longer hitpoint treatment for man-engineer
						_propType = if ("wheel" in _hitPointName) then {
							// _sleepTime = 3; //-- slightly longer time for wheels, coz it looks nice :)
							_toolsWheels call BIS_fnc_selectRandom;
						} else {
							_toolsSmall call BIS_fnc_selectRandom;
						};
						_prop = _propType createVehicle (_unit getPos [1,getDir _unit]);

						
						
						[_unit] spawn _fnc__repairAnim;
						_unit setDir (_unit getDir _repairPatient);
					} else {
						(vehicle _unit) engineOn false;
					};

					if (!isNull _prop) then {_prop attachTo [_unit,[0,1,0]]; };

					_isWaypointCancelled = false;

					for "_t" from 1 to _sleepTime do {
						if (!alive _unit) exitWith {_quit = true};
						if (speed _repairPatient > 2 OR {_repairPatient distance _unit > 100}) exitWith { _quit = true;};
						_isWaypointCancelled = (_pos distance (waypointPosition [group _unit, currentWaypoint group _unit])) > 3;
						if (_isWaypointCancelled) exitWith { _quit = true};
						sleep 1;
					};
					

					_newHitpointDamage = 0.1;
					_repairPatient setHitPointDamage [_hitPointName,_newHitPointDamage];
					
					if (_doCanMoveCheck) then {
						if (canmove _repairPatient) then {
							_repairPatient setPos (((getPosASL _repairPatient) select [0,2]) + [0]);
							_repairPatient setVelocity [0,0,0];
						};
					};
					if (!isNull _prop) then {deletevehicle _prop};
					_currentDamageStatus = (getAllHitPointsDamage _repairPatient) select 2;
					_damageAVG = 0;
					{_damageAVG = _damageAVG + _x} foreach _currentDamageStatus;
					_healthStatus = 1 - (_damageAVG / (count _currentDamageStatus));
					_healthStatus = ([_healthStatus,1] call BIS_fnc_cutDecimals);
					_data = _repairPatient getVariable ["A3C_isBeingRepaired",[false,0,[]]];
					if (_data select 0) then {
						_data set [1,_healthStatus];
						_treatedHitpoints = _data select 2;
						_treatedHitpoints = _treatedHitpoints - [_hitPointName];
						_data set [2,_treatedHitpoints];
						_repairPatient setVariable ["A3C_isBeingRepaired",_data];
					};
				};
			} foreach _hitPointValues;

			// player commandchat "REPAIR LOOP DONE";

			_repairPatient setVariable ["A3C_isBeingRepaired",[false,0,[]],true];
			{_x enableAI "MOVE"} foreach _movers;
			{deletevehicle _x} foreach _ambientObjects;
			_unit enableAI "ANIM";
			if (_quit) exitWith {};
			
			if (_healUp) then {
				_repairPatient setDamage (0.1 min (damage _repairPatient));
			};
			
			_fnc_feedback = compile format
			[
				"if ('%1' == getPlayerUID player) then {systemchat ""A3C: %2 (%3) has finished repairing a %4 %5""};",
				_callerUID,
				name _unit,
				groupID group _unit,
				getText (configFile >> "CfgVehicles" >> typeOf _repairPatient >> "displayName"),
				if (count crew _repairPatient > 0) then {format ["from %1",groupID (group ((crew _repairPatient) select 0))]} else {""}		
			]; 
			_fnc_feedback remoteExec ["bis_fnc_call",0];
		};
		_unit setVariable ["A3C_isRepairing",[false,objNull],true];
		_unit lookAt objNull;
		{_unit enableAI _x} foreach ["MOVE","ANIM","AUTOCOMBAT"];

		//systemchat 'EXITED LOOP';
	};
	sleep 0.2;
} foreach _repairUnits;
sleep 1;
// (format ["End Loop: A3C_isRepairing: %1 ", {(_x getVariable ["A3C_isRepairing",[false,objNull]]) select 0} count units _group == 0]) remoteexec ["systemchat", 0];
while {true} do {
	if ({(_x getVariable ["A3C_isRepairing",[false,objNull]]) select 0} count units _group == 0) exitWith {};
	sleep 1;
};

{

	[_x,"ANIM"] remoteExec ["enableAI",0];
	[_x,""] remoteExec ["switchMove",0];
	[_x,"AUTO"] remoteExec ["setUnitPos",_x];
	private _animHandler = _x getVariable ["A3C_HandlerID_AnimDone", -1];
	if (_animHandler != -1) then {
		_x removeEventhandler ["AnimDone", _animHandler];
		_x setVariable ["A3C_HandlerID_AnimDone", nil, true];	
	};
	
} foreach units _group;

// "END LOOP FINISHED" remoteexec ["systemchat", 0];

_group setBehaviourStrong _behaviour; //-- set group back to their initial behaviour


true


