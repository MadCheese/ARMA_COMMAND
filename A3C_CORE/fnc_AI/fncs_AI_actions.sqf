
//---------------------------------------------------------------------------------------------
//---------- ACTIONS: functions that make AI do stuff -----------------------------------------
//---------------------------------------------------------------------------------------------


A3C_AI_action_resumeDestination = {
	params ["_unit"];
	_expCurrent = (expectedDestination _unit);
	if ( count _expCurrent > 0 &&  {(_expCurrent select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]  } ) exitWith {}; //-- units are already in formation
	private _expD = _unit getvariable ["A3C_DEST",[]];
	//systemchat str _expD;
	if (!isPLayer _unit) then {
		if (count _expD > 0) then {
			_expP = _expD select 0;
			if (player == leader group _unit) then { // isPlayer leader group _unit && {
				if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
					//-- unit was in formation
					_unit doFollow player;
				} else {
					if !(currentcommand _unit == "STOP") then {
						//-- units had a destination or stationary position and was NOT ordered to stop in meantime
						//sleep 1;
						_unit dowatch objnull;
						_unit lookAt objnull;
						_unit setunitpos "UP";
						if !(A3C_C_FORM_ACTIVE) then {
							if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
								_unit doFollow player;
							} else {
								[_unit,_expP] call A3C_DOMOVE;
								if (count _expD > 3) then {
									_unit lookAt (_expP getPos [100,_expD select 3]);
								};
							};
						} else {
							//systemchat 'yao';
							//if !(_unit getVariable ["A3C_FORM_MEMBER",false]) then {
								[_unit] spawn {
									params ["_unit"];
									private ["_var","_formDist","_formDir","_formPos"];
									_var = _unit getVariable "A3C_FORM";
									_formDist = (_var select 0);
									_formDir = (getDir player) + (_var select 1);
									_formPos = (player getpos [_formDist,_formDir]);
									_unit setVariable ["A3C_FORM_MEMBER",true,false];
									doStop _unit;
									sleep 0.2;
									[_unit,_formPos] call A3C_DOMOVE;
									
									if !(isMultiplayer) then {
										_unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit,_unit];
									};
								};
							//};
						};
					};
				};
			} else {
				if ((_expD select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {
					[_unit,(leader _unit)] remoteExec ["doFollow",_unit];
					[_unit,objNull] remoteExec ["lookAt",_unit];
					[_unit,"AUTO"] remoteExec ["setUnitPos",_unit];
				} else {
					if (_expP distance2D [0,0,0] > 0) then {
						[_unit,_expP] call A3C_DOMOVE;
						if (count _expD > 3) then {
							_unit lookAt (_expP getPos [100,_expD select 3]);
						};
					};
				};
			};
		};
	};
	//systemchat str _expD;

	_unit setVariable ["A3C_DEST",_expD,true];
};

A3C_AI_action_repairAnim = {
	params ["_unit"];
	if ( (_unit getVariable ["A3C_ANIM", [false, -1]]) select 0) exitWith {};

	private _anims =
	[
		"Acts_carFixingWheel",
		"inbasemoves_assemblingvehicleerc",
		"inbasemoves_repairvehicleknl",
		"ainvpknlmstpslaywrfldnon_medic"
	];
	_anim = _anims call BIS_fnc_SelectRandom;
	[_unit,"ANIM"] remoteExec ["disableAI",0];
	[_unit,_anim] remoteExec ["switchMove",0];

	private _handler = _unit addEventHandler [ "AnimDone", {
		params[ "_unit", "_anim" ];
		if !( (_unit getVariable ["A3C_ANIM", [false, -1]]) select 0) exitWith {};
		private _anims =
		[
			"Acts_carFixingWheel",
			"inbasemoves_assemblingvehicleerc",
			"inbasemoves_repairvehicleknl",
			"ainvpknlmstpslaywrfldnon_medic"
		];
		_anim = _anims call BIS_fnc_SelectRandom;
		[_unit,_anim] remoteExec ["switchMove",0];
	}];

	_unit setVariable ["A3C_ANIM", [true, _handler], true];	
};

A3C_AI_action_engineOff = {
	params ["_units"];

	{
		_unit = _x;
		if (!isNull objectParent _unit) then {
			if (_unit == driver vehicle _unit) then {
				if ( vehicle _unit isKindOf "SHIP" OR  (((getPosATL vehicle _unit) select 2) < 5)   ) then {
					[_unit,["engineOff",vehicle _unit]] remoteExec ["action",_unit];
				};
			};
		};
	} foreach _units;
};


A3C_AI_action_toggleIrStrobeHC = { //-- only for HC!
	params ["_mode"];
	_referenceArray = if (_mode == "ON") then {A3C_HC_IROnUnits} else {A3C_HC_IROffUnits};
	_strobeType = switch (side cameraOn) do {
		case (WEST) : {"NVG_TargetE"};
		case (EAST) : {"NVG_TargetW"};
		default {"NVG_TargetC"};
	};
	_randomSleepMax = 0;
	A3C_Prevent_attach_IR = true;
	{
		_gp = _x;
		_randomSleepGroup = random 5;
		if (_randomSleepGroup > _randomSleepMax) then {
			_randomSleepMax = _randomSleepGroup;
		};
		if (!isPlayer (leader _gp) && {player != leader _gp}) then {
			{
				private _unit = _x;
				if (_mode == "ON") then {
					[_unit,_strobeType,_randomSleepGroup] spawn {
						params ["_unit","_strobeType","_randomSleepGroup"];
						_unit setvariable ["A3C_STROBE",[objNull,""],true];
						sleep (_randomSleepGroup + (random 1));
						_strobeObject = _strobeType createVehicle [0,0,0];
						_unit setvariable ["A3C_STROBE",[_strobeObject,_strobeType],true];

						[[_unit,_strobeObject],A3C_AI_action_irStrobeLoop] remoteExec ['bis_fnc_spawn',_unit];

						// [_unit,_strobeObject] spawn A3C_AI_action_irStrobeLoop;
					};

				} else {
					[_unit,_randomSleepGroup] spawn {
						params ["_unit","_randomSleepGroup"];
						sleep (_randomSleepGroup + (random 1));
						_irData = _unit getvariable ["A3C_STROBE",[]];
						if (count _irData > 0) then {
							deleteVehicle (_irData select 0);
							_unit setvariable ["A3C_STROBE",[],true];
						};
					};

				};
			} foreach units _gp;
		};

	} foreach _referenceArray;
	[_randomSleepMax] spawn {
		params ["_randomSleepMax"];
		sleep (_randomSleepMax + 1);
		A3C_Prevent_attach_IR = false;
		_targetArray = if (!isNull findDisplay 100040) then {A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED} else {A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS};
		//systemchat str _targetArray;
		[_targetArray] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
	};

};

A3C_AI_action_irStrobeLoop = {
	params ["_unit","_strobeObject"];
	private _currentMode = "UNIT";
	_t = 0;
	_fnc_detach = {
		params ["_strobeObject"];
		for "_i" from 1 to 5 do {
			detach _strobeObject; //-- attachment and setpos commands are GLOBAL, no remote needed
		};
	};
	while {!isNull _strobeObject} do {
		private _vehicle = vehicle _unit;
		if (_unit != driver _vehicle) then {
			//-- unit is not driver
			[_strobeObject, true] remoteExec ["hideObjectGlobal",2];
			sleep 0.1;
			_t = 0; //-- re-enable unit pickcup
			private _currentMode = "UNIT";
			while {_unit != driver _vehicle && !isNull _strobeObject} do {
				if (!alive _unit) exitWith {
					_currentMode == "NONE";
					_t = 1; //-- prevent dead unit from being picked up again
				};

				sleep 1;
			};
			[_strobeObject, false] remoteExec ["hideObjectGlobal",2];

		};
		if (!isNull objectParent _unit ) then { //&& {_unit == driver _vehicle}
			if (_currentMode == "UNIT") then {
				//-- requires vehicle adjustment
				_currentMode = "VEHICLE";
				[_strobeObject,true] call _fnc_detach;

				_vehicleLength = ((boundingboxreal _vehicle) select 1) select 1;
				_targetPos = [];
				private _exit = false;
				private _attachPosFound = false;

				for "_i" from 1.5 to 3 step 0.5 do {

					_c = 1;
					while {alive _vehicle} do {
						_targetPos = getposASL  _vehicle;
						_h = _targetPos select 2;
						_targetPos = _targetPos getPos [_vehicleLength / _i, (getDir _vehicle) + 180];
						_targetPos set [2,_h];
						_refPos = +(_targetPos);
						_refPos set [2,(_targetPos select 2) + (  (((boundingBoxReal _vehicle) select 1) select 2)    * 2  )];
						_targetPos = (lineintersectsSurfaces [_refPos,_targetPos]); //,objnull, objnull, true, 1, "GEOM", "FIRE"
						if (count _targetPos > 0) then {
							if ( (_targetPos select 0) select 2 == _vehicle ) then {
								_exit = true;
								_targetPos = ASLtoATL ((_targetPos select 0) select 0);
								_attachPosFound = true;
							};
						};
						if (_exit) exitWith {};
						if (_c >  20) exitWith {};
						_c = _c + 1;
						sleep 0.1;
					};
					if (isNull _strobeObject OR _attachPosFound) exitWith {};
				};

				if (_attachPosFound) then {
					_targetPos = _vehicle worldToModel _targetPos;
					for "_i" from 1 to 5 do {
						_strobeObject attachTo [_vehicle,_targetPos];
					};
				} else {
					/*
					while {!isNull _strobeObject} do {
						if (_unit != driver _vehicle) exitWith {
							_currentMode == "UNIT";
							_t = 0;
						};
						if (!alive _unit) exitWith {
							_currentMode == "NONE";
							_t = 1; //-- prevent dead unit from being picked up again
						};

						sleep 1;
					};
					*/
				};
			};
		} else {
			if (_currentMode == "VEHICLE" OR {_t == 0}) then {
				//-- requires unit adjustment
				_currentMode = "UNIT";
				[_strobeObject,false] call _fnc_detach;
				_attachArray = if (isPlayer _unit) then {[0.034,-0.2,0.02]} else {[0.094,-0.1,0.02]};
				for "_i" from 1 to 5 do {
					_strobeObject attachTo [_unit,_attachArray,"neck"];
				};
			};
		};
		if (!alive _unit) exitWith {
			if (_unit != driver _vehicle) then {
				deleteVehicle _strobeObject;
				_unit setvariable ["A3C_STROBE",[],true];
			};
		};
		_t = 1;
		sleep 1;
	};
	//systemchat 'loop exit';
};
