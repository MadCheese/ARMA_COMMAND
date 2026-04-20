
//------------------------------------  A3C  M E D I C A L  F U N C T I O N S  -----------------------------------------
//---------------------------------------------------------------------------------------------------------------------







A3C_MEDICAL_itemStrings =
[
	//Regular
	
	"firstaid",
	"fak",
	"fielddressing",
	"morphine",
	
	
	//--ACE stuff
	//"ACE_fieldDressing", //-- not necessary, fielddressing is already checked
	"ace_morphine",
	"ace_surgicalkit",
	"ace_personalaidkit",
	"ace_elasticbandage",
	"ace_quikclot",
	"ace_packingbandage",
	"medi",
	"medkit",
	"medikit",
	"biofoam"
];







//-- Find active medics or units with FAK's etc
A3C_FINDMEDICS = {
	params ["_unitArray"];
	private ["_img"];
	_img = "";
	
	
	private _medics = [];

	
	{
		_u = _x;
		private _isMedic =   ({[_x] call TAG_fnc_baseWeapon == "Medikit"} count (items _u) > 0);
		//systemchat str _isMedic;
		//(getNumber ( configFile >> "CfgVehicles" >> typeOf _x >> "attendant" ) isEqualTo 1);
		//if !(_x in A3C_MEDICS) then {
			//if !(_x in A3C_MEDICS_ACTIVE) then {
				//if (count (_x getVariable ["A3C_PLOT",[]]) == 0) then {
					if (isNull objectParent _x) then {
						if (alive _x && {!isplayer _x}) then {
							if !([_x] call A3C_isUnconscious) then {
								if (({_it = toLower _x; ({[_x,_it] call MCSS_fnc_isInString} count A3C_MEDICAL_itemStrings) > 0} count items _u) > 0 ) then {
									_add = true;
									if (_add) then {
										if (_isMedic) then {
											_medics = [_x] + _medics;
										} else {
											_medics pushbackUnique _x;
										};
									};
								};
							};
						};
					//};
				};
			//};
		//};
	} foreach _unitArray;
	_medics
};




A3C_Unit_Requires_Heal = {
	params ["_unit"];

	(_unit isKindOf "MAN")
	&& !(_unit isKindOf "ANIMAL")
	&& { isNull objectParent _unit }
	&& {
		(_unit getVariable ["vn_revive_bleeding", false])
		|| { (lifeState _unit) isEqualTo "INJURED" }
		|| { isBleeding _unit }
		|| { !canMove _unit }
		|| { !(isNil "f_wound_extraFAK") && { (_unit getVariable ["f_wound_bleeding", false]) || (_unit getVariable ["f_wound_down", false]) } }
		|| { !(isNil "BTC_REVIVE_TIME_MIN") && { (_unit getVariable ["r3_unitIsDown", 0]) > 0 } }
		|| { [_unit] call A3C_isUnconscious }
		|| { A3C_IsAce3 && { { _unit getVariable [_x, false] } count ["ACE_MEDICAL_isBleeding", "ACE_MEDICAL_hasPain", "ACE_isUnconscious"] > 0 } }
		|| { A3C_IsAce3 && { { (_unit getVariable [_x, 0]) > 0 } count ["ACE_MEDICAL_pain", "ACE_MEDICAL_hasLostBlood"] > 0 } }
		|| { { _unit getHitPointDamage _x > 0.2 } count A3C_HUMAN_HITPOINTS > 0 }
	}
};


A3C_FINDPATIENTS = {
	params ["_group"];

	private _patients = [];

	{
		private _u = _x;
		private _array = (units _group) - [_u];

		{
			private _p = _x;

			if (((side _p) getFriend (side _u)) > 0.6) then {
				if ([_p] call A3C_Unit_Requires_Heal) then {
					_patients pushBackUnique _p;
				};
			};
		} forEach _array;

	} forEach (units _group);

	_group setVariable ["A3C_PATIENTS", _patients];
	_patients
};

A3C_MEDICAL_START = {


	if !(isClass(configFile/"CfgPatches"/"A3C_OBJECTS")) exitWith {}; //-- exit if run on a machine that does not run A3C

	params ["_group","_mode"]; //-- 0: from dialog || 1: from script
	private ["_healMode"];
	//A3C_MEDICS_ACTIVE = (A3C_MEDICS_ACTIVE + A3C_MEDICS_LB);

	//-- clean up arrays
	//-- medics
	private _medics_lb = _group getVariable ["A3C_MEDICS_LB", [] ];
	if (count _medics_lb == 0) exitWith {systemchat "A3C: Medic selection empty"};

	private _patients_lb = _group getVariable ["A3C_PATIENTS_LB", [] ];
	if (count _patients_lb == 0) exitWith {systemchat "A3C: No units selected for treatment"};
	_patients_lb = _patients_lb - ((_group getVariable ["A3C_PATIENTS_DESIGNATED", []]) + (_group getVariable["A3C_PATIENTS_ASSIGNED", [] ]));
	_group setVariable ["A3C_PATIENTS_LB", _patients_lb ];
	if (count _patients_lb == 0) exitWith {systemchat "A3C: Selected Patients are already scheduled for treatment"};


	player groupradio "SentCmdHealSomeone";
	_healMode = if ((count (_group getVariable ["A3C_PATIENTS",[]])) > 1) then {1} else {0};


	//-- update designated targets
	private _patients_designated = _group getVariable ["A3C_PATIENTS_DESIGNATED", []];

	if (count ((_group getVariable ["A3C_MEDICS_ACTIVE", [] ]) + (_group getVariable ["A3C_MEDICS_LB", [] ])) > 0) then {
		
		{
			if !(_x in (_group getVariable["A3C_PATIENTS_ASSIGNED", [] ])) then {
				//systemchat "unit added to healing cue";
				// (_group getVariable ["A3C_PATIENTS_DESIGNATED", []]) pushBackUnique _x; //-- Active patients can be updated immideately. Only active medics have to be added individually since they may outnumber patients
				_patients_designated pushBackUnique _x;

			};
		} foreach _patients_lb;
	};
	// player sidechat str _patients_designated;


	
	{
		_u = _x;
		if (currentCommand _u == "STOP") then {
			_pu = false;

			if (_u in _patients_designated) then {
				_pu = true;
				_patients_designated = _patients_designated - [_u];
			};
			private _medics_lb = (group _u) getVariable ["A3C_MEDICS_LB", [] ];
			_medics_lb = _medics_lb - [_u];
			_u = [_u] call A3C_Replace_Unit;
			_medics_lb pushBackUnique _u;
			(group _u) setVariable ["A3C_MEDICS_LB", _medics_lb ];
			if (_pu) then {
				_patients_designated pushBackUnique _u;
			};

			sleep 0.1;
		};
	} foreach _medics_lb;

	


	_medics_lb = _group getVariable ["A3C_MEDICS_LB", [] ]; //-- update
	//-- sort medics: if medic(s) is also patient(s), have him in front of array so he will then chose himself as nearest patient
	_medics_lb = [_medics_lb,[],{_i = if (_x in _patients_designated) then {1} else {0}; _i},"DESCEND"] call BIS_fnc_sortBy;
	_group setVariable ["A3C_MEDICS_LB", _medics_lb ];

	{

		private ["_medic","_patient"];
		_medic = _x;
		//systemChat format ["%1-1",_foreachINdex];
		if ((count _patients_designated) == 0) exitwith {
			private _medics_active = (_group getVariable ["A3C_MEDICS_ACTIVE", [] ]);
			_medics_active = _medics_active - [_medic];
			_group setVariable ["A3C_MEDICS_ACTIVE", _medics_active ];
		};
		//systemChat format ["%1-2",_foreachINdex];
		//if ((count A3C_MEDICS_ACTIVE) == 0) exitwith {};
		_patients_designated = [_patients_designated,[],{_x distance2d _medic},"ASCEND"] call BIS_fnc_sortBy;
		if (_medic in _patients_designated) then {
			_patient = _medic;
		} else {
			_patient = (_patients_designated select 0);
		};

		_patients_designated = _patients_designated - [_patient]; //-- patient is being healed >> remove from active patient list
		[_medic,_patient,_healmode,(expecteddestination _medic),_forEachIndex] spawn {

			params ["_healer","_patient","_hm","_expDest","_index"];
			private ["_script","_dir"];


			//_expP = if (((_expDest select 0) distance2d [0,0,0] ) == 0) then {(position _healer)} else {(_expDest select 0)};
			[_healer] call A3C_UNIT_STORE_DESTINATION;
			_array = [];
			_dir = getdir _healer;
			_script = {};
			sleep (1 * _index);
			private _medics_active = (group _healer getVariable ["A3C_MEDICS_ACTIVE", [] ]);
			_medics_active pushBackUnique _healer;
			(group _healer) setVariable ["A3C_MEDICS_ACTIVE", _medics_active];
			private _patients_designated = group _healer getVariable ["A3C_PATIENTS_DESIGNATED", [] ]; 
			_patients_designated = _patients_designated - [_patient]; //~~ needed?
			group _healer setVariable ["A3C_PATIENTS_DESIGNATED", _patients_designated ]; 

			//systemchat str _healer;

			if (_hm == 1) then {
				//-- HEAL ALL
				while {alive _healer} do {
					_script = [_healer,_patient] spawn A3C_HEAL;
					sleep 0.1;
					if (group _healer == group player) then {
						//-- update UI PRE HEAL
						[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
					};
					
					waituntil {scriptDone _script};
					if (group _healer == group player) then {
						//-- update UI POST HEAL
						[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
					};

					if (currentcommand _healer == "STOP" && {!( ((expectedDestination _healer ) select 1) == "LEADER PLANNED")}) exitwith {
						//systemchat 'medi stop';
					};
					_patients_designated = group _healer getVariable ["A3C_PATIENTS_DESIGNATED", [] ]; 
					if (({_it = _x; ({[_x,_it] call MCSS_fnc_isInString} count ["Medi","FirstAid","FAK"] ) > 0} count items _healer) == 0 ) exitWith {
						if (count _patients_designated > 0) then {
							if (count ((group _healer) getVariable ["A3C_MEDICS_ACTIVE", [] ]) == 1) then {
								_healer groupChat format ["I am out of supplies, can not attend to %1 units", count ((group _healer) getVariable ["A3C_PATIENTS_DESIGNATED", []])];
								_patients_designated = [];
							};
						};
					};
					if ((count _patients_designated) == 0) exitwith {};
					if (({_x distance2d _healer < 80} count _patients_designated) == 0) exitwith {};
					_patients_designated = [_patients_designated,[],{_x distance2d _healer},"ASCEND"] call BIS_fnc_sortBy;
					_patient = _patients_designated select 0;
					_patients_designated = _patients_designated - [_patient];
					group _healer setVariable ["A3C_PATIENTS_DESIGNATED", _patients_designated ]
				};
			} else {
				_script = [_healer,_patient] spawn A3C_HEAL;
				sleep 0.1;
				if (group _healer == group player) then {
					//-- update UI PRE HEAL
					[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
				};
				waituntil {scriptDone _script};
				//-- update UI POST HEAL
				if (group _healer == group player) then {
					//-- update UI POST HEAL
					[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
				};

			};

			[_healer] call A3C_UNIT_RESUME_DESTINATION;



			//-- last unit has cancelled >> reset designated patients
			if (count _patients_designated > 0) then {
				if (((group _healer) getVariable ["A3C_MEDICS_ACTIVE", [] ]) isEqualTo [_healer]) then {
					(group _healer) setVariable ["A3C_MEDICS_ACTIVE", [] ];
				};
			};

			private _medics_active = (group _healer getVariable ["A3C_MEDICS_ACTIVE", [] ]);
			_medics_active = _medics_active - [_healer];
			(group _healer) setVariable ["A3C_MEDICS_ACTIVE", _medics_active ]; 
			//-- update UI
			if (A3C_LBR_1 == 'MEDICAL') then {
				if (ctrlShown (findDisplay 100040 displayCtrl 8056)) then {
					[] spawn {
						sleep 0.5;
						[] call A3C_UI_RADIAL_UPDATE_MEDICAL;
					};
				};

			};
		};
		_group setVariable ["A3C_PATIENTS_DESIGNATED", _patients_designated ];
		sleep 0.2;
	} foreach _medics_lb;

	
};



A3C_isUnconscious = {
	params ["_unit"];

	(lifeState _unit) in ["UNCONSCIOUS", "INCAPACITATED"]
	|| { A3C_IsAce3 && { _unit getVariable ["ACE_isUnconscious", false] } }
	|| { _unit getVariable ["ais_unconscious", false] }
	|| { _unit getVariable ["unit_is_unconscious", false] }
	|| { _unit getVariable ["tcb_ais_agony", false] }
	|| { !(isNil "f_wound_extraFAK") && { _unit getVariable ["f_wound_down", false] } }
	|| { _unit getVariable ["vn_revive_bleeding", false] }
	|| { _unit getVariable ["vn_revive_incapacitated", false] }
	|| { !(isNil "BTC_REVIVE_TIME_MIN") && { (_unit getVariable ["r3_unitIsDown", 0]) > 0 } }
};


//-- requires (_unit getvariable "A3C_PLOT") and A3C_AI_Shared_executeUnitPlot
A3C_HEAL = {
	private ["_unit","_patient","_scr","_expDest","_pos","_objs","_formUnits"];
	_unit = _this select 0;
	_patient = _this select 1;
	
	private _objParentUnit = objectParent _unit;
	private _objParentPatient = objectParent _patient;
	private _vehicleHeal = _objParentUnit == _objParentPatient;
	if (isplayer _unit) exitwith {};
	_isPlayer = (_patient == player);
	_expDest = [_patient] call A3C_UNIT_STORE_DESTINATION; //expectedDestination _patient;
	_objs = [];
	_patientStance = switch (stance _patient) do {
		case ("STAND") : {"AUTO"};
		case ("CROUCH") : {"MIDDLE"};
		case ("PRONE") : {"DOWN"};
		default {"AUTO"};
	};


	//systemchat str [name _unit,name _patient];
	private _patients_assigned = group _unit getVariable ["A3C_PATIENTS_ASSIGNED", []];
	_patients_assigned pushBackUnique _patient;
	group _unit setVariable ["A3C_PATIENTS_ASSIGNED", _patients_assigned];
	//[_unit,position _unit] call A3C_DoMove;
//	_unit doMove position _unit;
//	_unit moveTo position _unit;
	
	//sleep 2;
	_pos = position _patient; //-- add meeting point
	if (!(_unit == _patient) && {!(_vehicleHeal)}) then {
		if (_isPlayer) then {
			A3C_Mpos = position player;
			_unit groupchat "Get Support!";
			A3C_MEDICAL_INDICATOR = A3C_Mpos;
			//['A3C_MEDICAL_INDICATOR', 'onEachFrame', { drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Actions\heal_ca.paa", [0,0,1,0.7],A3C_Mpos, 1, 1, 0, 'Meet Medic',0,0.05,"PuristaLight","center",true]; }] call BIS_fnc_addStackedEventHandler;
		} else {
			_patient forcespeed 0;
		};
		//~~ keeping this for future AI meet up position tweaks
		if (_patient getHitpointDamage "Hitlegs" < 0.5) then {
			if !([_patient] call A3C_isUnconscious) then {
				_objs = nearestObjects [_patient, ["HOUSE","THING","CAR","TANK","HELICOPTER","PLANE"], 15];
				if (count _objs == 0) then {
					_objs = (nearestTerrainObjects [player, ["Tree","Bush","Rocks"], 15]);
				};

				if (count _objs > 0) then {
					_objs = [_objs,[],{_x distance player},"ASCEND"] call BIS_fnc_sortBy;
					_bb = [_objs select 0] call MCSS_fnc_BBOX;
					_bb = [_bb,[],{_x distance player},"ASCEND"] call BIS_fnc_sortBy;
					if (_isPlayer) then {
						A3C_Mpos = (_bb select 0);
						_pos = (_bb select 0);
					};

				};
			};
		};
	};

	_formunits = [];
	if !(_isPLayer) then {
		if !(_unit == _patient) then {
			//[_patient,_pos] call A3C_DoMove;
		};
	} else {
		
		if (player == leader group player && {!(_vehicleHeal)}) then {
			
			{
				_expDest = expectedDestination _x;
				if ((_expDest select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
					if !(_x in (group player getVariable ["A3C_MEDICS_ACTIVE", [] ])) then {
						_formunits pushback _x;
					};
				};
			} foreach units group player - [player];
			_formunits commandFollow player;
		};
	};
	if (stance _patient == "STAND") then {
		_patient setunitpos "MIDDLE";
	};
	// [[units player select 2],true,false] call A3C_AI_Shared_cancelUnitPlot;
	// waitUntil {(_unit getvariable 'A3C_PLOT') isEqualTo []};

	if (!(_vehicleHeal) && {_unit distance _patient < 3}) then {
		_data =
		[
			[
				[_pos,_pos], //-- positions
				["","",""], //-- markers
				["None",[]], //-- wp action
				["NONE","NONE"], //--WP Condition
				["UP","MIDDLE"], //-- WP Stances
				[[0,false]], // WP Sync Data
				true, //-- isWPCompleted
				0, //-- Combat Mode
				-1, //-- WP SPeed
				25, //-- WP Flying Height
				-1, //-- WP Loop Value
				0 // -- radius (for circle, not completion)
			]
		];

		private _exit = false;
		// systemchat str [_unit, _patient, _vehicleHeal];
		if !(_vehicleHeal) then {
			_unit setvariable ["A3C_PLOT",_data,true];
			_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_AI_Shared_executeUnitPlot);
			//#WIP
			while {!isNull _patient} do {
				

				if (_patient getVariable ["A3C_AbortHealing", false]) exitWith {
					//-- player aborted action with doubleclick
				};



				if ( [_unit] call A3C_isUnconscious) exitWith {
					//-- healer is unconscious - need to skip
				};



				//-- #WIP note: we might want to include self healing if not unconscious - but without re-calling the same fnc obviously.
				//-- That means moving healing stuff into a fnc (logical anyways)

				if !(({alive _x} count [_unit,_patient]) > 0) exitwith {
					//terminate _scr;
					if (count (_unit getVariable ["A3C_PLOT",[]]) > 0) then {
						_unit setvariable ["A3C_ABORT_Data",[true,false],true];
						waitUntil {count (_unit getVariable ["A3C_PLOT",[]]) == 0};
					};
				};
				if (count (_unit getVariable ["A3C_PLOT",[]]) == 0) exitwith {
					// systemchat "AAAAA";
				};
				//if (unitReady _unit) exitWith {
				//	terminate _scr;
				//};
				if ((_unit distance2d _pos) <= 2) exitWith {
					//terminate _scr;
					if (count (_unit getVariable ["A3C_PLOT",[]]) > 0) then {
						_unit setvariable ["A3C_ABORT_Data",[true,false],true];
						waitUntil {count (_unit getVariable ["A3C_PLOT",[]]) == 0};
					};
				};
				sleep 0.1;
			};
		};
	};
	
	// systemchat "healing route loop done";
	
	
	//A3C_PATIENTS_ASSIGNED = A3C_PATIENTS_ASSIGNED - [_patient];
	{
		_x setVariable ["A3C_PLOT",[],true];
	} forEach [_unit,_patient];

	private _skip = true;
	if ((_unit distance2d _patient) < 9 OR {_vehicleHeal}) then {
		_skip = false;
	} else {
		if (_isPlayer) then {
			//dostop _unit;
			[_unit, position _unit] call A3C_DoMove;
			for "_i" from 1 to 30 do {
				if (_patient getVariable ["A3C_AbortHealing", false]) exitWith {};
				if ((player distance2d _unit) < 5) exitwith {_skip = false};
				sleep 1;
			};
		};
		if ((_unit distance2d _patient) < 5 && {!((_patient getVariable ["A3C_AbortHealing", false]))}) then {
			(group player getVariable ["A3C_PATIENTS_DESIGNATED", []]) pushBackUnique _patient;
		};
	};
	if (_patient getVariable ["A3C_AbortHealing", false]) then {
		// systemchat "A3C_HEAL: unit healing was aborted";
		_patient setVariable ["A3C_AbortHealing", false]
	};

	if (_isPlayer) then {
		A3C_MEDICAL_INDICATOR = [];

		//['A3C_MEDICAL_INDICATOR', "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	} else {
		_patient doWatch _unit;
	};


	if (!(alive _unit) OR _skip) then {
		if !(profileNameSpace getVariable "A3C_AUTOMEDIC") then {
			systemchat format ["A3C: Patient %1 not healed, please repeat action",name _patient];
		};
	} else {
		//-- HEAL!
		if !(_vehicleHeal) then {
			if (_unit == _patient) then {
				_unit action ["HealSoldierSelf",_unit];
				//sleep 3;
			} else {
				_unit doWatch _patient;
				//sleep 1;
				_unit action ["HealSoldier",_patient];
			};
			sleep 3;
			//waituntil {!((animationstate _unit) ==  "ainvpknlmstpslaywrfldnon_medicother")};
			waituntil {!(["medic", animationState _unit] call BIS_fnc_inString)};
			sleep 1;
		};
		
		//if ( !(isNil "TCB_AIS_PATH")) then {
			if ( !(isNil "AIS_System_fnc_ReviveAI")) then {
				if ([_patient] call A3C_isUnconscious) then {
					[_unit, _patient] spawn AIS_System_fnc_ReviveAI;
				};
			};
			_patient setVariable ["ais_unconscious",false,true];
			_patient setVariable ["ais_stabilized", true, true];
			_patient setVariable ["ais_fireDamage", 0];
			_patient setVariable ["tcb_ais_agony",false,true];
			_patient setVariable ["unit_is_unconscious",false,true];

		//};
		_patient setVariable ["vn_revive_bleeding",false,true];
		_patient setVariable ["vn_revive_incapacitated",false,true];
		if !(isNil "f_wound_extraFAK") then {
			_patient setVariable ["f_wound_down",false];
			_patient setVariable ["f_wound_bleeding",false];
			_patient setVariable ["f_wound_blood",100]; // other player dont need know this
			_patient setVariable ["f_wound_dragging",nil];
		};
		if !(isnil "BTC_REVIVE_TIME_MIN") then {
			_patient setVariable ["r3_unitIsDown", 0, true];
			_patient setVariable ["r3_unitIsStabi", 0, true];
			_patient setVariable ["r3_unitPrivateMedic", objNull, true];
			_patient setVariable ["r3_unitGetRevive", 0, true];
		};
		if !(isnil "TFFG_fnc_ReviveSuccess") then {
			_patient setVariable ["TFFG_Incapacitated", false, true];
			_patient setVariable ["TFFG_Incapacitated_Dam", false, true];
			_patient setVariable ["TFFG_Incapacitated_CanBeDragged", false, true];
		};
		if (A3C_IsAce3) then {

			[objNull, _patient] call ace_medical_treatment_fnc_fullHeal;

	   	} else {
			_patient setUnconscious false;
		};
		_patient setdamage 0;
		_patient dowatch objnull;
	};
	_patients_assigned = (group _unit) getVariable["A3C_PATIENTS_ASSIGNED", [] ];
	_patients_assigned = _patients_assigned - [_patient];
	(group _unit) setVariable["A3C_PATIENTS_ASSIGNED", _patients_assigned ];
	_patient forceSpeed -1;
	_patient setunitpos "AUTO";
	_patient lookAt objnull;

	_patient setunitpos _patientStance;




	//if (!(_patient == _unit) && !(_isPlayer)) then {
	//	if ((_expDest select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
	//		if ((group _patient) == (group player)) then {
	//			_patient doFollow player;
	//		};
	//	} else {
	//		_patient lookAt objnull;
	//		_patient domove (_expDest select 0);
	//		_patient moveTo (_expDest select 0);
	//	};
	//	_patient forcespeed -1;
	//};
	waituntil {!(['medic',animationState _unit] call BIS_fnc_inString) };
	_patient forcespeed -1;
	if (!(_patient == _unit) && !(_isPlayer)) then {
		[_unit] call A3C_UNIT_RESUME_DESTINATION;
	};
};

A3C_AI_HIGHCOMMAND_fnc_groupHeal = {
	params ["_group"];

	
	private _medics = [(units _group)] call A3C_FINDMEDICS;
	_group setVariable ["A3C_MEDICS", _medics];
	_patients = [_group] call A3C_FINDPATIENTS;
	// systemchat str _patients;
	_group setVariable ["A3C_MEDICS_LB", _medics];
	_group setVariable ["A3C_PATIENTS_LB", _patients];
	if (count _patients > 0) then {
		if (count (_group getVariable ["A3C_MEDICS_LB", [] ]) > 0) then {
			[[_group, 1],A3C_MEDICAL_START] remoteExec ["bis_fnc_spawn", leader _group];
			// systemchat 'wyt';
			// sleep 2;
			// while {true} do {
			// 	if ( {count _x > 0} count [group player getVariable ["A3C_PATIENTS_DESIGNATED", []],group player getVariable ["A3C_PATIENTS_ASSIGNED", []]] == 0) exitWith {
			// 		//systemchat "loopxit";
			// 	};
			// 	sleep 1;
			// };
		};
	};
};



if (isDedicated) exitWith {};




A3C_HEAL_AUTOLOOP = {
	private _selectedAutoHealers = [A3C_RD_UNITS]; //[units player - [player]]
	//systemchat str _selectedAutoHealers;
	while {profileNameSpace getVariable "A3C_AUTOMEDIC"} do {
		//systemchat "search medics";
		private _medics = _selectedAutoHealers call A3C_FINDMEDICS;
		group player setVariable ["A3C_MEDICS", _medics];

		_patients = [group player] call A3C_FINDPATIENTS;


		(group player) setVariable ["A3C_MEDICS_LB", _medics];
		(group player) setVariable ["A3C_PATIENTS_LB", _patients];
		if (count _patients > 0) then {
			if (count ((group player) getVariable ["A3C_MEDICS_LB", [] ]) > 0) then {
				[group player, 1] spawn A3C_MEDICAL_START;
				//[] call A3C_UI_RADIAL_UPDATE_MEDICAL;  //-- no need since you will not see UI
				sleep 2;
				while {true} do {
					if ( {count _x > 0} count [group player getVariable ["A3C_PATIENTS_DESIGNATED", []],group player getVariable ["A3C_PATIENTS_ASSIGNED", []]] == 0) exitWith {
						//systemchat "loopxit";
					};
					sleep 1;
				};
			};
		};
		sleep 3;
	};
};
//-- Send a medic to heal a patient

A3C_MEDICAL_INDICATOR = [];
