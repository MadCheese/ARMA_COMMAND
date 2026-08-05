//-- A3C_ai_shared_fnc_actionExecuteUnitPlot

//-- #TODO : Optimize - this fnc was not optimized during migration

//---------------------------------------  M A I N  M O V E M E N T  F U C T I O N     ----------------------------------------------
//-------------------------------- sends unit on a route, monitors and creates group/ui-data ----------------------------------------
//---------------------------- requires unit to have data in (_unit getvariable "A3C_PLOT") ---------------------------------
//------------------------------------ used by Planning Mode, ReArm, BuildingClear, Medical -----------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

params ["_unit","_data"];

private _count = count _data;


private _abort = false;
private _exit = false;
private _SyncComplete = false;
private _SyncCompleteMain = false;
private _hubComplete = false;

private _inBuilding = false;
private _inside = false;
private _syncData = [];
private _switchData = [];
private _otherUnits = [];
private _crew = [];
private _vectorup = [];
private _abortData = [];
private _wpos = [];
private _pickUpUnits = [];
private _movePos = [];
private _timer = time;
private _counter = 0;
private _threshold = 50;
private _cycle = 0;
private _pause = 0;

private _syncIndex = 0;
private _completionRadius = 5;
private _maxdist = 20;
private _maxSpeed = -1;
private _comparedWP = 0;
private _dataCompared = 0;
private _syncDataCompared = 0;
private _testedSyncSubArray = 0;
private _landingpos = [];
private _landingdir = 0;
private _timeNow = 0;
private _velo = 0;
private _varidist = 0;
private _muzzle = "";

private _vehicle = vehicle _unit;

private _landingdata = "NONE";

private _unitNumber = _unit getvariable "A3C_VVNI";

private _precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision"));

if (isPlayer _unit) exitWith {
	{
		_unit setVariable [_x,[],true];
	} foreach ["A3C_PLOT","A3C_PLOT_TEMP"];
};

if (count _data == 0) exitWith {};


if (currentCommand _unit == "STOP") then {
	if (player == leader group _unit) then {
		_unit = [_unit] call A3C_ai_shared_fnc_replaceUnit;
	};
};


//-- reset unit's planning stage array
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if (!alive _unit) exitWith {_abort = true};

_unit setVariable ["A3C_unitIsOnMainRoute",true,true];

_unit setVariable ["A3C_FORM_MEMBER",false,false]; //-- take away from custom form!
_unit setvariable ["A3C_PLOT_TEMP",[],true];
_unit setvariable ["A3C_BOOL_WP_DELETED",false,true];
_unit setvariable ["A3C_WAITCARGO",false,true];
_unit setvariable ["A3C_ABORT_Data",[false,false],true];
_unit setvariable ["A3C_SKILLDATA",[(_unit skill "commanding"),(_unit skill "spotDistance"),(_unit skill "spotTime")],true];

private _origDest = [0,0,0];
if (_vehicle isKindOf "AIR") then {
	_unit setvariable ["A3C_CREWCOUNT",(count crew _vehicle),true];
} else {
	if ((effectivecommander _vehicle) != player) then {
		_origDest = (expectedDestination (effectiveCommander _vehicle) select 0);
	} else {
		_origDest = ((expectedDestination _unit) select 0);
	};
};
if (isNil '_origDest') then {
	_origDest = position _unit;
};



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////   M A I N  L O O P   /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
while {!isNull _unit} do {


	_vehicle = vehicle _unit; //-- refresh to monitor changes

	_data = (_unit getvariable ["A3C_PLOT",[]]);

	if (_cycle >= count _data) exitWith {};

	if (_cycle >= (count (_unit getvariable "A3C_PLOT")) ) exitWith {};


	_vehicle = vehicle _unit;
	private _wpData = (_data select _cycle);

	_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

	_wPos = _wpPositions select 0;
	private _wPosOriginal = +_wPos;
	private _lookAtPos = _wpPositions select 1;
	private _wpMarkerMain = _wpMarkers select 0;
	private _wpMarkerXtra = _wpMarkers select 1;

	private _unitPosTravel = _wpStances select 0;
	private _unitPosDest = _wpStances select 1;
	_movePos = if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) then {position _unit} else {_wPos};
	_landingdata = if ((_wpAction select 0) == "LANDING") then {_wpAction select 1} else {""};
	private _wpTimeoutValue = if ((_wpAction select 0) == "TIMEOUT") then {_wpAction select 1} else {0};

	_precision = (getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision"));


	if (_unit in A3C_SUPPRESSION_UNITS_SQ) then {
		[[_unit],"SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
	};

	//-- Check if abort data was given via dialog
	_abortData = _unit getvariable "A3C_ABORT_Data";

	
	if (_abortdata select 1) then {
		//-- Player skipped current waypoint:
		_unit setvariable ["A3C_ABORT_Data",[false,false],true];
		_abort = false;
		if (_unit getvariable "A3C_BOOL_WP_DELETED") then {

			_data deleteAt (_cycle - 1);
			_unit setvariable ["A3C_PLOT",_data,true];
			_unit setvariable ["A3C_BOOL_WP_DELETED",false,true];
			_cycle = _cycle - 1;
			_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",(_cycle + 1),true];
		};
	};

	//-- default: switch default unit behavior on for each WP
	{_unit enableAI _x} foreach ["TARGET","AUTOTARGET","FSM"];

	_unit dowatch objnull;
	_unit lookat objnull;
	//-- exit function if required (_abort returns true), delete lines/markers and reset values
	if (_abort) exitWith {
		{_unit enableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"];
		_unit forcespeed -1;
		_vehicle forcespeed -1;
		if !(_vehicle == _unit) then {
			_vehicle limitspeed 1000;
		};
		[_unit] call A3C_ai_shared_fnc_resetUnit;
	};

	if (isNull _unit) exitWith {};

	

	//-- refuel RTB planes
	if (_vehicle isKindOf "PLANE") then {
		if (_unit == (driver _vehicle)) then {
			if ( ((getposATL _vehicle) select 2) < 5) then {

				{_vehicle animateDoor [_x, 0]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
				if ((getNumber (configfile >> "CfgVehicles" >> typeOf _vehicle >> "landingSpeed")) > 10) then {
					[_unit] spawn A3C_ai_shared_fnc_planeTakeOff;
				};
			};
		};
	};

	//-- help out the helpless guys in stranded boats
	//-- here we use the GENERAL depth of the ocean at the position. not the depth od the vehicle
	if (_vehicle isKindOf "SHIP") then {
		private _vicPos = getpos _vehicle;
		private _refPos = ATLtoASL ((_vicPos select [0,2]) + [0]);

		private _shoreAction = false;
		if (surfaceIsWater _refPos) then {
			private _depth = _refPos select 2;
			if (_depth >= -3) then {
				_shoreAction = true;
			};
		} else {
			_shoreAction = true;
		};
		if (_shoreAction) then {
			if (abs (speed _vehicle) < 2 ) then {
				[_vehicle] call A3C_ai_shared_fnc_startBoat;
			};
		};
		//-- next line, pay attention: the true/false may seem counter intuitive. We are looking for ZERO units WITHOUT rebreathers (meaning all have one)
		if ( { private _c = count (getArray (configfile >> "CfgWeapons" >> vest _x >> "hiddenUnderwaterSelections")); if (_c > 0) then {false} else {true};  } count (crew _vehicle) == 0      ) then {
			_vehicle swimInDepth -30;
		} else {
			_vehicle swimInDepth 0;
		};

	};


	//-- Throw Grenade
	if ((_wpAction select 0) == "GRENADE") then {
		_muzzle = (_wpAction select 1);
		if (_muzzle in (magazines _unit)) then {_muzzle = ([_muzzle] call MCSS_fnc_getThrowMuzzleForMagazine) } else {_muzzle = ""};
		if !(_muzzle == "") then {
			[_unit,position _vehicle ] call A3C_ai_shared_fnc_doMove;
			_unit lookat _wPos;
			if ((_wPos distance2D (getPosASL _unit)) > 70) then {
				_wPos = _unit getPos [70,_unit getDir _wPos];
			};
			_velo = [_unit,_wPos,300] call A3C_ai_shared_fnc_gtiGrenade_getLaunchVelocity;
			sleep 2;
			_unit setvariable ["A3C_GRENADE_VEL",_velo,true];
			private _handlerID = _unit addEventHandler ["fired",
			{
				private _shooter = _this select 0;
				private _vel = _shooter getvariable "A3C_GRENADE_VEL";
				
				if (_this select 1 == "THROW") then
					{
						(_this select 6) setVelocity _vel;

					};
					
					_shooter removeEventHandler ["fired", _thisEventHandler];
					_unit setvariable ["A3C_REMOTE_HANDLE",[-1,objNull]];
			}];
			_unit setvariable ["A3C_REMOTE_HANDLE",[_handlerID,objNull]];
			_unit forceWeaponFire [_muzzle,_muzzle];

			if ((side _unit) == WEST) then {
				[_unit] call A3C_ai_shared_fnc_gtiGrenade_callout;
			};
			sleep 1;
		};
	};

	


	//-- Activate Suppression
	if ((_wpAction select 0) == "SUPPRESSION") then {
		if (!isnull gunner _vehicle) then {
			sleep 1;
			A3C_SUPPRESSION_UNITS_SQ pushback _unit;
			[[gunner _vehicle],(_unit getVariable "A3C_UNIT_POLYS") select 0,'SUPPRESSION',false] spawn A3C_ai_shared_fnc_polygonAreaActionOn;
		};

	};

	//-- additional data for helicopters (not relevant for ground vehicles)
	if (_vehicle isKindOf "AIR") then {
		if (_vehicle isKindOf "PLANE") then {
			//-- adjust lower heights for planes
			if (_wpFlyInHeight == 25) then {_wpFlyInHeight = 150};
			if (_wpFlyInHeight == 5) then {_wpFlyInHeight = 25};
		} else {
			_unit setvariable ["A3C_REDUCE_SPEED",true,true];
		};
		if (_wpFlyInHeight == 1000) then {
			//-- weird fix for pilots bugging out in high altitudes
			private _h = (getpos _vehicle) select 2;
			while {_h < 1000} do {
				_h = _h + 100;
				_vehicle flyinHeight _h;
				sleep 10;
			};
			_v flyinHeight 1000;
		} else {
			_vehicle flyinheight _wpFlyInHeight;
		};
		{_vehicle animateDoor [_x, 0]} foreach ['door_R','door_L','door_rear','door_rear_source','Door_L_source','Door_R_source','DoorL_Front_Open','DoorR_Front_Open','DoorL_Back_Open','DoorR_Back_Open','Door_1_source'];
		_unit enableAI "move";
		_vehicle enableAI "move";
	};

	if ([_movePos, (nearestBuilding _movePos)] call A3C_main_fnc_isPositionInsideBuilding) then {_inBuilding = true} else {_inBuilding = false};

	if (_unit == driver _vehicle) then {
		if (!(_unit getvariable ["A3C_HOLD",false])) then {
			
			if !((_wpAction select 0) in ["SUPPRESSION","GRENADE"]) then {
				[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
			} else {
				[_unit,position _vehicle] call A3C_ai_shared_fnc_doMove;
			};
		} else {
			[_unit,position _vehicle ] call A3C_ai_shared_fnc_doMove;
		};
	};

	if (_vehicle isKindOf "Man") then {
		_varidist = 5;
	} else {
		if (_vehicle isKindOf "Air") then {
			if (_landingdata == "NONE") then {
				_variDist = if (_wpAction select 0 == "PARADROP") then {50} else {150};
			} else {
				_variDist = 150;
			};
		} else {
			_variDist = 15;
		};	
	};

	if !((_wpAction select 0) in ["SUPPRESSION","GRENADE"]) then {
		if !(_vehicle == _unit) then {
			if !(player == (effectivecommander _vehicle)) then {
				private _moving = false;
				while {_unit == driver _vehicle} do {
					if (isNil '_unit') exitWith {};
					if (isNull _unit) exitWith {};
					if (!alive _unit) exitWith {};
					private _commDest = (expectedDestination (effectivecommander _vehicle) select 0);

					if (_vehicle distance2D _movePos <= _variDist) then {
						_moving = true;
					} else {
						if ((_commDest distance2D _movePos ) < 2 ) then {
							if ((_commDest distance2D _origDest ) > 20 ) then {
								_moving = true;
							};
						};
					};

					if (_moving) exitWith {};
					sleep 2;
					_data = (_unit getvariable ["A3C_PLOT",[]]);
					_wpData = (_data select _cycle);
					_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
					_movePos  = _wpPositions select 0;
					if ([_unit,_movePos,_data,_cycle,0] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom) exitWith {
						_abort = true;
					};
					[_unit,_movePos ] call A3C_ai_shared_fnc_doMove;
				};
			};
		};
	};

	



	//-- set WP-details (speed/stance)
	_unit setunitpos _unitPosTravel;
	if !(_wpSpeed == -1) then {
		if (_vehicle == _unit) then {
			_maxSpeed = 2;
		} else {
			_maxSpeed = if (_vehicle iskindof "AIR") then {60} else {15};
		};
	} else {
		if (isnull objectParent _unit) then {
			_maxSpeed = -1;
		} else {
			_maxSpeed = 1000;
		};
	};
	if (isnull objectparent _unit) then {
		_unit forcespeed _maxSpeed;
	} else {
		_vehicle limitspeed _maxSpeed;
	};
	_unit setvariable ["A3C_PLOT_ACTIVE",true,true];


	

	if !(_vehicle == _unit) then {_vehicle = vehicle _unit};


	
	private _complete = false;
	//THIS BIT CAN GET STUCK!
	if (_unit == driver _vehicle && {!((_wpAction select 0) in ["GRENADE","SUPPRESSION"])}) then {
		//-- wait until exit-conditions can be considered
		if (_vehicle isKindOf "AIR") then {
			if (_vehicle distance2d _movePos < 200) then {
				if (((getPosATL _vehicle) select 2) < 3) then {
					_vehicle engineOn true;
					[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
					//-- wait until aircraft has gained altitude
					while {(canMove _vehicle) && (alive driver _vehicle)} do {
						if (((getPosATL _vehicle) select 2) > 15) exitWith {};
						sleep 1;
					};
				};
			};
			sleep 2;
		} else {
			private _threshHold = 0;
			
			if (isPlayer leader group _unit) then {
				while {alive _unit} do {
					if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {
						_abort = true;
					};
					if ( (toLower((expectedDestination _unit ) select 1)) in ["leader planned","vehicle planned"]) exitWith {};
					_variDist = switch (true) do {
						case (_vehicle isKindOf "MAN") : {5};
						case (_vehicle isKindOf "AIR") : {150};
						default {15};
					};
					if (_vehicle distance _movePos <= (_precision + _variDist)) exitWith {_complete = true};
					_threshHold = _threshHold + 1;
					if (_threshHold >= 20) then {
						_threshHold = 0;
						if (!(_unit getvariable ["A3C_HOLD",false] ) && {_unit == driver _vehicle}) then {
							[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
						};
					};
					sleep 0.1;
				};
			};
		};
	};



	//////////////////////////////////
	//-- WAIT FOR UNIT TO REACH WP
	//////////////////////////////////




	_timer = time;
	private _ct = 0;
	private _conPos = [0,0,0];
	private _checkTime = 5;

	if ((effectivecommander _vehicle) == player) then {sleep 1};

	private _stuckCycles = 0;
	
	//////////////////////////////////
	//-- MAIN TRAVEL LOOP
	//////////////////////////////////

	while {alive _unit} do { 
		
		

		//-- Update Waypoint Data
		waituntil {!A3C_REFRESHING};
		_data = (_unit getvariable ["A3C_PLOT",[]]);


		if (_cycle >= count _data) exitWith {};
		if (_cycle >= (count (_unit getvariable ["A3C_PLOT",[]])) ) exitWith {
			if (A3C_DEBUG) then {
				systemchat format ["%1 exit no more data",name _unit];
			};
		};
		_wpData = (_data select _cycle);
		_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
		_wPos = _wpPositions select 0;

		if (A3C_DEBUG) then {
			private _debugMessage = format ["unitPlot Main Travel Loop (%1 / %2), unitReady: %3, distance: %4", _unit, round time, unitReady _unit, round (_unit distance2d _wpos)];
			_debugMessage remoteExec ["systemchat", 0];
		};


		_lookAtPos = _wpPositions select 1;
		_wpMarkerMain = _wpMarkers select 0;
		_wpMarkerXtra = _wpMarkers select 1;
		_unitPosTravel = _wpStances select 0;
		_unitPosDest = _wpStances select 1;
		_vehicle = vehicle _unit; //-- refresh
		_movePos = _wPos;
		private _doExit = false;
		_landingdata = if ((_wpAction select 0) == "LANDING") then {_wpAction select 1} else {""};
		_wpTimeoutValue = if ((_wpAction select 0) == "TIMEOUT") then {_wpAction select 1} else {0};
		if (_complete) exitWith {};
		if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) exitWith {};
		
		if (_unit == driver _vehicle) then {
			
			//-- re-adjust variDist
			if ((_wpAction select 0) in ["CTRL_DET"]) then {
				(_wpAction select 1) params ["_targetObject","_magType"];
				if (!isNull _targetObject) then {
					if (unitReady _unit) then {//-- only if unit is not moving anymore, we want him to get as close as possible
						_variDist = (sizeof typeOf _targetObject);
					};

				};
			};


			//-- NON NEGOTIOABLE EXIT CONDITIONS
			//-- check if wp is completed (first because STOPPED and BREAK are subordinate and share conditions).
			if ([_unit,_movePos,_variDist,_inBuilding,_wpRadius,_wpTimeoutValue] call A3C_ai_shared_fnc_unitRouteIsWpComplete) exitWith {
				_doExit = true;
				_unit setunitpos _unitPosDest;
				if (_inBuilding) then {
					_unit dowatch ([(getPosATL (nearestBuilding _wPos)),100, ([(nearestBuilding _wPos),_wPos] call BIS_fnc_DirTo)] call BIS_fnc_RelPos);
					_unit lookat ([(getPosATL (nearestBuilding _wPos)),100, ([(nearestBuilding _wPos),_wPos] call BIS_fnc_DirTo)] call BIS_fnc_RelPos);
				} else {
					if !(_lookAtPos isEqualTo []) then {
						_unit dowatch _lookAtPos;
						_unit lookat _lookAtPos;
					};
				};
			};


			if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {_abort = true};
			



			if !(A3C_BOOL_MOVINGMARKER) then {
				//-- exit stop
				if ([_unit,_movePos,0] call A3C_ai_shared_fnc_unitRouteIsUnitStopped) then {
					_abort = true;
				};
			};

			private ["_hold"];
			_hold = _unit getvariable ["A3C_HOLD",false];


			//-- HOLD Dependent CONDITIONS
			if !(_hold) then {

				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- unstucker
					if (time > (_timer + _checkTime)) then {
						_timer = time;
						if (_checkTime == 1) then {
							_checkTime = 5;
						};

						
						if ( (speed _vehicle) < 1) then {
													
							[_unit,_movePos] call A3C_ai_shared_fnc_doMove;

							_unit setunitpos _unitPosTravel;
							if (isnull objectparent _unit) then {
								_unit forcespeed _maxSpeed;
							} else {
								_vehicle limitspeed _maxSpeed;
							};
						};

						
					};
					_conPos = position _unit;
					if (_ct > 0) then {
						if (isnull objectparent _unit) then {
							if (_unit in A3C_BOARD_UNITS_ACTIVE) then {
								if ( (_vehicle distance _movePos) < 20) then {
									_abort = true;
									if (A3C_DEBUG) then {
										systemchat format ["%1 exit ct (move)",name _unit];
									};
								};
							};
						};
					};
					if (_ct > 8) then {
						if (isnull objectparent _unit) then {
							if (_maxSpeed == -1) then {
								_abort = true;
								
								if (A3C_DEBUG) then {
									systemchat format ["%1 exit ct2 (move)",name _unit];
								};
							} else {
								_ct = 0;
							};
						};
					};
				};
				if ( _vehicle == _unit) then { //-- different radius for inf and cars
					_completionRadius = 5;
					_pause = 2;

				} else {
					_completionRadius = 20;
					_pause = 0;
				};

				if !(_abort) then {
					sleep 0.5; //~~ formerly #UNCLEAR :: why is this needed? - removing causes waypoint plans to abort
				};

				if (!(A3C_BOOL_MOVINGMARKER) && !(_wpAction select 0 == "REARM")) then { //~~ Temp Fix!!
					if ([_unit,_origdest,_data,_cycle,0] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom) then {
						_abort = true;					
					};
				};
			} else {
				if !(_unit getVariable "A3C_HOLD_COVER") then {
					
					_unit setVariable ["A3C_HOLD_COVER",true,false];
					if (speed _unit > 1) then { //~~ not ideal
						[[_unit],1] spawn A3C_ai_squad_fnc_actionFindCover;
					};
					
				};
				_checkTime = 1;
			};

			//\\-- WHAT IS THIS BELOW?? can it even be executed??
			private _expD = (expectedDestination _unit);
			if ( !(_expD isEqualTo []) && {  (_expD select 1) == "DoNotPlan" }  ) then {
				if !(currentcommand _unit == "STOP") then {
					if (((expectedDestination _unit) select 1) == "Leader Planned") then {
						//-- low level move command has failed
						_unit groupchat format ["I can not reach Waypoint No. %1. Proceeding with plans",(_cycle + 1)];
						[_unit,position _vehicle ] call A3C_ai_shared_fnc_doMove;
						_unit setvariable ["A3C_ABORT_Data",[false,true],true];
					};
				};
			};

			if (_abort && {!(_unit getVariable ["A3C_PAUSE_PLAN",false])}) exitWith {};

			//-- switch of default behavior if ordered. done in the loop to prevent loss during saveGame/loadGame
			if (_wpCombatMode == 1) then {
				{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"];
				if !(combatmode _unit == "BLUE") then {
					[_unit,["COMBATMODE","BLUE"]] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
				};
			};

			private _getDistance = if (_vehicle == _unit) then {
				(_unit distance _movePos)
			} else {
				(((getposASL _vehicle) select [0,2]) distance (_movePos select [0,2]))
			};



			private _speedDist = 1200;
			if (_landingData == "RAPPEL") then {_speedDist = 300};
			if (_vehicle isKindOf "Helicopter") then {
				if ((_wpAction select 0) == "NONE") then {
					if (_cycle == (count _data - 1)) then {
						_speedDist = 300;
					};
				};
			};
			if ( (_vehicle iskindof "AIR") && !(_abort)) then {
				if ( (((getposASL _vehicle) select [0,2]) distance (((expecteddestination _unit) select 0) select [0,2])) < _speedDist ) then {
					if ( (speed _vehicle) > 150) then {
						if !(_landingdata == "NONE") then {
							if (_unit getvariable "A3C_REDUCE_SPEED") then {
								_unit setvariable ["A3C_REDUCE_SPEED",false,true];
								[_unit,150] spawn A3C_ai_shared_fnc_reduceSpeed;
							};
						};
					};
				};
				if (_wpTimeoutValue > 0) then {
					_wpRadius = 50;
					_varidist = 10;
				};
				{_unit disableAI _x} foreach ["TARGET","AUTOTARGET","FSM","AUTOCOMBAT"];
				_unit dotarget objnull; _unit dowatch objnull;
				{_unit setskill [_x,0]} foreach ["commanding","spotTime","spotDistance"];
				_vehicle land "NONE";
			};
			sleep 0.2;
		} else {
			sleep 0.2;
			//-- unit has just exited vehicle -> send to BIS_fnc_moduleTaskSetDestination
			if (_unit == driver vehicle _unit) then {
				if (isNull objectParent _unit) then {
					sleep 2; //-- allow some time for unit to complete engine dismount-routine
					waituntil {unitReady _unit};
				} else {
					sleep 3;
				};
				//-- we have to do a loop to make sure the dismount routine does not harm us!
				//-- sometimes (ie with editor placed cargo units) the dismount triggers the unit to run somewhere,
				//-- we have to overwrtie this
				//-- KEEP IN MIND: since varidist is currently calculated before while loop, first waypoint will probably have 15m radius
				while {_movepos distance2d ( (expectedDestination _unit) select 0) > 0} do {
					[_unit,_movePos] call A3C_ai_shared_fnc_doMove; //-- boost
					sleep 1;
				};
			};
		};
		if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true; }; 
		if (_unit getVariable ["A3C_PAUSE_PLAN",false]) then {_abort = false};
		if (_abort OR {_doExit}) exitWith {};
	};

	//////////////////////////////////
	//-- UNIT HAS ARRIVED
	//////////////////////////////////
	if !(isPlayer (leader group _unit)) then { //-- prevent High COmmand units from immediately returning to formation
		[_unit,_movePos] call A3C_ai_shared_fnc_doMove; //#MONITOR
	};

	//-- refresh data (current waypoint settings may have been changed)
	_data = (_unit getvariable ["A3C_PLOT",[]]);
	if (_cycle >= count _data) exitWith {};
	_wpData = (_data select _cycle);
	if (isNil '_wpData') exitWith {};
	_wpData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

	///////////////////////////////////////////////////
	//-- wp complete
	///////////////////////////////////////////////////

	if (isnull _unit) exitWith {};
	if !(_abort) then {
		//-- Spawn AI Rail
		if !((_wpAction select 0) in ["GRENADE","SUPPRESSION","REARM"]) then {
			if (profileNameSpace getVariable ["A3C_FORCERAIL_VAR", false]) then {
				if (isnull objectparent _unit && {_cycle == ((count _data) - 1)}) then { //~~ ONLY DO THIS IF IT'S FINAL WAYPOINT OR UNIT HAS TO WAIT
					private _aslP = +(getPosASL _unit);
					private _aslRef = ATLtoASL _wPos;
					{
						_x set [2,(_x select 2) + 0.3];
					} foreach [_aslP,_aslRef];
					if (count (lineIntersectsObjs [_aslP, _aslRef, _unit, objnull, false]) == 0) then {
						waituntil {speed _unit < 1};
						if !(_lookAtPos isEqualTo []) then {
							private _rail = [_unit,_wPos] spawn A3C_ai_rail_fnc_infantryForceDestination;
							waituntil {scriptDone _rail};
							_unit dowatch _lookAtPos;
							_unit lookat _lookAtPos;
						};
					};
				};
			};
		};

		if (_vehicle isKindOf "TANK") then {
			if ( ((_wpCondition select 0) != "NONE") OR ((_cycle + 1) == count (_unit getVariable ["A3C_PLOT",[]])) ) then {
				if !(_lookAtPos isEqualTo []) then {
					waituntil {unitReady _unit && speed _vehicle == 0};
					private _spawnBehaviour = [_vehicle,_lookAtPos] spawn A3C_ai_shared_fnc_rotateVehicleTowardsPos;
					waitUntil {scriptDone _spawnBehaviour};
				};
			};
		};


		switch (_wpAction select 0) do {
			case ("EHM") : {
				_unit setPos _movePos;
				_unit setDir (_movePos getDir _lookAtPos);
				_unit call A3C_ai_shared_fnc_ehmDetect;

				waitUntil {!(_unit getVariable ["A3C_EM_ACTIVE",false])};
				[_unit,position _unit] call A3C_ai_shared_fnc_doMove;
			};
			case ("REARM") : {
				private _spawnBehaviour = [_unit,(_wpAction select 1)] spawn A3C_ai_shared_fnc_reArm_plotBehaviour;
				waitUntil {scriptDone _spawnBehaviour};
				[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
				sleep 2;
			};
			case ("SLINGLOAD") : {
				private _slingMode = if (isnull (getSlingLoad _vehicle)) then {0} else {1};
				waitUntil {(getPosATL _vehicle select 2) > 5};
				waitUntil {speed _vehicle < 50};
				private _spawnBehaviour = {};
				if (_slingMode == 0) then {
					_spawnBehaviour = [_slingMode,_vehicle,_wpAction select 1] spawn A3C_ai_squad_fnc_actionHeliSling;
					waitUntil {scriptDone _spawnBehaviour};
				} else {
					private _slingCargo = getSlingLoad _vehicle;
					if !(isnull _slingCargo) then {
						private _cargoHeight = (((boundingBoxreal _slingCargo) select 1) select 2) + 10;
						waitUntil {speed _vehicle < 50};
						[_unit,position _vehicle] call A3C_ai_shared_fnc_doMove;
						sleep 1;

						private _slingPos = +(_movePos);
						_slingPos set [2,_cargoHeight];
						_spawnBehaviour = [_slingMode,_vehicle, ATLtoASL _slingPos] spawn A3C_ai_squad_fnc_actionHeliSling;
						waitUntil {scriptDone _spawnBehaviour};
						_unit doMove (position _vehicle); _unit moveTo (position _vehicle);
						_unit moveTo _movePos;
						sleep 2;
					};
				};
			};
			case ("CTRL_DET") : {
				private _spawnBehaviour = [_unit,_movePos,(_wpAction select 1)] spawn A3C_AI_Shared_fnc_wpActionPlantExplosive;
				waitUntil {scriptDone _spawnBehaviour};
				sleep 0.5;
			};
		};
		//-- Spawn Landing Behaviour for choppers
		if ( !(_vehicle == _unit) && !(_landingdata == "NONE") )then {
			_unit setvariable ["A3C_CREWCOUNT",(count crew _vehicle),true];
			switch (true) do {
				case (_landingdata in ["PICKUP","DROPOFF"]) : {
					private _spawnBehaviour = [_unit,(leader group _unit),_movePos,_landingData,_landingdata] spawn A3C_ai_squad_fnc_actionHeliPickupAndDrop; 
					waitUntil {scriptDone _spawnBehaviour};
				};
				case (_landingdata == "LANDFINAL") : {
					private _spawnBehaviour = [_unit,(leader group _unit),_movePos] spawn A3C_ai_squad_fnc_actionHeliLandFinal;
					waitUntil {scriptDone _spawnBehaviour};
				};
				case (_landingdata == "RAPPEL") : {
					private _spawnBehaviour = [_unit,(leader group _unit),_movePos] spawn A3C_ai_shared_fnc_actionAircraftRappell;
					waitUntil {scriptDone _spawnBehaviour};
				};
			};
		};
		if (_vehicle isKindOf "Helicopter") then {
			if ((_wpAction select 0) == "NONE") then {
				if (_cycle == (count _data - 1)) then {
					private _subBehaviour =
					[
						_vehicle,
						getPosASL _vehicle,
						ATLtoASL ((_movePos select [0,2]) + [_wpFlyInHeight]),
						50
					] spawn A3C_ai_rail_fnc_helicopter;
					waituntil {scriptDone _subBehaviour};
					doStop _unit;
				};
			};
		};
	};

	private _hubUnits = [];
	private _otherUnits = [];
	private _hubLeader = false;
	if (group _unit == group player) then {
		//-- gather HUD units
		/////////////////////
		_otherUnits = (units _unit) - [player,_unit];
		{
			private _soldier = _x;
			private _unitData = (_soldier getvariable ["A3C_PLOT",[]]);
			if (alive _soldier) then {
				{
					if (_wpMarkerMain == ((_x select 1) select 0)) then {
						_hubUnits pushBackUnique _soldier;
					};
				} foreach _unitData;
			};
		} foreach _otherUnits;
		//-- sort hubUnits by formIndex and find out if unit is the highest in chain
		_hubUnits = [([_unit] + _hubUnits),[],{_x getvariable "A3C_FORMATION_INDEX"},"ASCEND"] call BIS_fnc_sortBy;
		_hubLeader = (_unit == (_hubUnits select 0));


		///////////////////////////////////////////
		//-- MARK WP AS COMPLETED
		///////////////////////////////////////////
		_switchdata = if !(isnull _unit) then {(_unit getvariable ["A3C_PLOT",[]])} else {[]};
		if (count _switchData > 0) then {
			//-- remember: hubLeaders of waypoints with STATICWEAPON action will be completed after action is completed.
			if !(_hubLeader && {(_wpAction select 0) in ["STATIC"]}) then {
				(_switchdata select _cycle) set [6,true];
				_unit setvariable ["A3C_PLOT",_switchdata,true];
			};
		};


		///////////////////////////////////////////
		//-- WAIT FOR OTHER UNITS TO REACH WP (HUB)
		///////////////////////////////////////////
		while {true} do {
			if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) exitWith {};


			if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {
				_abort = true;
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {
				_abort = true;
			};
			if !(A3C_BOOL_MOVINGMARKER) then {
				//-- exit stop
				if ([_unit,_movePos,1] call A3C_ai_shared_fnc_unitRouteIsUnitStopped) then {
					_abort = true;
				};
			};
			if !((_wpAction select 0) == "STATIC") then { // << TEMP SOLUTION!
				if ([_unit,_origdest,_data,_cycle,1] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom) then {
					_abort = true;
				};
			};

			if (_abort) exitWith {};
			_otherUnits = units group player - [player,_unit];
			_hubComplete = true;
			{
				private _soldier = _x;
				private _unitData = (_soldier getvariable ["A3C_PLOT",[]]);
				if (alive _soldier) then {
					{
						if (_wpMarkerMain == ((_x select 1) select 0) && {!(_wpMarkerMain == "")}) then {
							if !(_x select 6) then {
								_hubComplete = false;
							};
						};
					} foreach _unitData;
				};
			} foreach _otherUnits;
			if (_hubComplete) exitWith {};
			sleep 1; //~~ #UNCLEAR  is this needed? [might be irrelevant for single units - CONFIRMED]
		};
	};
	_vehicle = vehicle _unit; //-- refresh

	//-- WP ACTION: STATIC WEAPONS (had to wait unitil HUB is complete
	if (_wpAction select 0 == "STATIC" && {!(_abort)}) then {
		sleep 0.2;
		private _staticData = _wpAction select 1;

		//-- bundle HUB units into one function
		if (_hubLeader) then {
			private _spawnBehaviour =
			[
				_hubUnits,
				_staticData,
				_wPosOriginal,
				if !(_lookAtPos isEqualTo []) then {[_movePos,_lookAtPos] call BIS_fnc_dirTo} else {0}
			] spawn A3C_ai_shared_fnc_actionStaticWeaponExecute;
			waitUntil {scriptDone _spawnBehaviour};
			//-- remember: hubLeader's wp is completed.
			_switchdata = if !(isnull _unit) then {(_unit getvariable ["A3C_PLOT",[]])} else {[]};
			if (count _switchData > 0) then {
				(_switchdata select _cycle) set [6,true];
				_unit setvariable ["A3C_PLOT",_switchdata,true];
			};
		} else {
			private _formLeader = (_hubUnits select 0);
			_hubComplete = true;
		};
		sleep 0.5;
		[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
		sleep 1;

	};


	//-- WAIT FOR WP-SYNC
	_pickUpUnits = [];
	_syncIndex = 0;
	private ["_otherUnits"];
	_otherUnits = units group player - [player,_unit];
	if !(((_wpSyncData select 0) select 0) == 0) then {
		//-- SYNCDATA DETECTED
		while {true} do {

			//~~ Authors note: WRITE ALL THESE _ABORT CHECKS INTO A FUNC!!!!!
			if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {_abort = true};
			if !(A3C_BOOL_MOVINGMARKER) then {
				//-- exit stop
				if ([_unit,_movePos,1] call A3C_ai_shared_fnc_unitRouteIsUnitStopped) then {
					_abort = true;
				};
			};
			if !((_wpAction select 0) == "SUPPRESSION") then {
				if ([_unit,_origdest,_data,_cycle,1] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom) then {
					_abort = true;
				};
			};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {
				_abort = true;
			};
			if (_abort) exitWith {};
			private ["_syncComplete","_pickUp"];
			_syncComplete = true;
			_data = (_unit getvariable ["A3C_PLOT",[]]);
			_wpSyncData = ((_data select _cycle) select 5);
			_pickUp = if (_wpAction select 1 == "PICKUP") then {true} else {false};
			_pickUpUnits = [];
			{
				private _soldier = _x;
				if (alive _soldier) then {
					_dataCompared = ((_soldier getvariable ["A3C_PLOT",[]]));
					{
						private ["_comparedWP","_isComp"];
						_comparedWP = _x;
						_isComp = (_comparedWP select 6);
						if !( ((_x select 1) select 0) == _wpMarkerMain ) then { //-- exclude HUB units
							_syncDataCompared = (_comparedWP select 5);
							{
								private ["_syncIndex"];
								_syncIndex = (_x select 0);
								{
									private _fi = _foreachIndex;
									if !(_syncIndex == 0) then {
										if ((_x select 0) == _syncIndex) then {
											if !(_isComp) then {
												_syncComplete = false;
												_syncCompleteMain= false;
											} else {
												(_syncDataCompared select _fi) set [1,true];
												_comparedWP set [5,_syncDataCompared];
												if ({!(_x select 1)} count _syncDataCompared > 0) then {
													//-- if no compared wp is complete
													if !(_abort) then {
														_syncComplete = false;
														_SyncCompleteMain = false;
													};
												};

											};
										};
									};
								} foreach _syncDataCompared;
								if (_syncComplete && {_pickUp}) then {
									_pickUpUnits pushBackUnique _soldier;
								};
							} foreach _wpSyncData;
						};
					} foreach _dataCompared;
					_soldier setVariable ["A3C_PLOT",_dataCompared,true];
				};
			} foreach _otherUnits;
			if (_syncComplete) exitWith {
				if (_pickup) then {

					if (_vehicle isKindOf "HELICOPTER") then {
						[_unit,position _vehicle] call A3C_ai_shared_fnc_doMove;
						sleep 0.2;
						_vehicle flyInHeight 1;
						_vehicle limitSpeed 0;
						private _spawnBehaviour = [_vehicle,"all",0,_pickUpUnits] spawn A3C_ai_squad_fnc_boarding_assignVehicleSeatMacro ;
						waituntil {scriptDone _spawnBehaviour};

						while {({(_x in _pickUpUnits)} count A3C_BOARD_UNITS_ACTIVE > 0) OR ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player > 0) } do {
							if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
							[_unit,(position _vehicle)] call A3C_ai_shared_fnc_doMove;
							sleep 0.01;
							_vehicle setvelocity [0,0,0];
						};
					};
					if !(_vehicle isKindOf "AIR") then {
						private _spawnBehaviour = [_vehicle,"all",0,_pickUpUnits] spawn A3C_ai_squad_fnc_boarding_assignVehicleSeatMacro ;
						waituntil {scriptDone _spawnBehaviour};
					};
				};
			};
			sleep 0.1;
		};
	};

	_vehicle = vehicle _unit; //-- refresh

	/////////////////////
	//-- WAIT FOR Ground CARGO


	if (_unit == driver _vehicle && {!(_vehicle isKindOf "AIR") && {!(_abort) && {(_wpAction select 0) == "CARGO_IN"}}}) then {
		while {canmove _vehicle} do {
			if (isNull _unit) exitWith {_abort = true};
			if ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player == 0) exitWith {};
			if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
			_unit dowatch objnull;
			sleep 1;
		};
		_vehicle limitSpeed 1000;
		[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
		sleep 1;
		_vehicle = vehicle _unit; //-- refresh
	};
	
	
	
	
	
	if ( !(_abort) && {(_wpAction select 0) == "CARGO_OUT" && {{_vehicle isKindOf _x} count ["AIR","MAN"] == 0}} ) then {
		_vehicle limitSpeed 0;
		{
			if ((assignedVehicleRole _x) select 0 == "CARGO") then {
				[_x] spawn A3C_ai_shared_fnc_getOut;
				[_x ,position (vehicle _x)] call A3C_ai_shared_fnc_doMove;
				sleep 0.2;

				if (player in _vehicle) then {
					player action ["eject",_vehicle];
				};
			};
		} foreach crew _vehicle;
		while {canMove _vehicle} do {
			private _ex = true;
			{
				if !(_x in [driver _vehicle,gunner _vehicle, commander _vehicle]) then {
					_ex = false;
					[_x] spawn A3C_ai_shared_fnc_getOut;
					sleep 0.1;
				};
			} foreach (crew _vehicle);
			if (_ex) exitWith {sleep 2};
			sleep 0.1;
		};
		_vehicle limitSpeed 1000;
		[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
		_vehicle = vehicle _unit; //-- refresh
	};
	

	//-- WAIT FOR Helicopter CARGO
	_landingpos = position _vehicle;
	_vectorup = vectorup _vehicle;
	private _isGoCode = (
		toUpper (_wpCondition param [0, ""])
	) == "GOCODE";

	private _goCode = if (_isGoCode) then {
		toUpper (
			_wpCondition param [
				1,
				"NONE"
			]
		)
	} else {
		"NONE"
	};

	private _hasActiveGoCode = (
		_isGoCode
		&& {
			_goCode in [
				"A",
				"B",
				"C",
				"D"
			]
		}
	);

	private _goCodeActivationVariableName = if (_hasActiveGoCode) then {
		[
			_goCode,
			side (group _unit)
		] call A3C_main_fnc_getGoCodeActivationVariableName
	} else {
		""
	};

	private _goCodeConditionSatisfied = false;

	if ( (_vehicle isKindOf "HELICOPTER") && (_landingdata in ["PICKUP","DROPOFF"]) && !(_abort) ) then {
		{_x disableAI "MOVE"} foreach [_unit,_vehicle];
		_vehicle limitSpeed 0;
		sleep 0.2;
		_exit = false;

		while {canmove _vehicle} do {
			if (isNull _unit) exitWith {_abort = true};

			_vehicle = vehicle _unit;
			_unit dowatch objnull;
			_vehicle limitspeed 0;

			_vehicle flyinheight 0;
			private _velocity = [0,0,0];

			if ((velocity _vehicle) select 2 > 0) then {
				_velocity set [2,-2];
			};

			_vehicle setvelocity _velocity;

			if (_landingdata == "DROPOFF") then {
				//~~ WHAT IS THIS??	AUTHORNOTE
				if (({(( ((_x select 2) getfriend (side _unit)) < 0.6)) && (_unit knowsabout (_x select 4) > 1.5)} count (_unit neartargets viewdistance)) > 0) then {
					[_unit,(position _vehicle)] call A3C_ai_shared_fnc_doMove;
				};
			};

			if (_hasActiveGoCode) then {
				if (
					missionNamespace getVariable [
						_goCodeActivationVariableName,
						false
					]
				) then {
					_goCodeConditionSatisfied = true;
					_exit = true;
				};
			} else {
				if (_landingdata == "PICKUP") then {
					if ({(assignedvehicle _x == _vehicle) && !(_x in _vehicle) && (alive _x)} count units group player > 0) then {
						_exit = false;
						[_unit,(position _vehicle)] call A3C_ai_shared_fnc_doMove;
						_vehicle setvelocity [0,0,0];
					} else {
						_exit = true;
					};
				};

				if (_landingdata == "DROPOFF") then {
					if !( {[_x] call A3C_main_fnc_shouldEjectFromHeli} count crew _vehicle == 0) then {
						_exit = false;
					} else {
						_exit = true;
					};
				};

				if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {
					_abort = true;
					_exit = true;
					_vehicle land "NONE";
				};
			};

			if !(_unit == (driver _vehicle)) then {
				_exit = true;
			};

			if (_exit) exitWith {};

			if !(_exit) then {
				sleep 0.01;
			};
		};

		_vehicle limitspeed 1000;
		_vehicle flyinheight 3;
		_vehicle = vehicle _unit; //-- refresh
	};


	_SyncComplete= false;
	_data = _unit getVariable ["A3C_PLOT",[]];
	(_data select _cycle) set [5,[[0,true]]];
	_unit setVariable ["A3C_PLOT",_data,true];

	{_x enableAI "MOVE"} foreach [_unit,_vehicle];

	if ( (_landingdata == "LANDFINAL") && !(_abort) ) then {
		_timenow = (time + 10);
		while {time < _timenow} do {
			if (isNull _unit) exitWith {_abort = true};
			_vehicle flyinheight 0;
			sleep 0.05;
			if (({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) OR !(_unit == (driver _vehicle)) ) exitWith {  //~~ TO DO: CHECK EXACTLY WHAT THIS DOES (relates to new UI setup / non driver planning)
				_abort = true;
				_vehicle land "NONE";
			};
		};
		_vehicle = vehicle _unit; //-- refresh
	};
	_exit = false;
	_unit Setvariable ["A3C_WAITCARGO",false,true];
	_vehicle setvariable ["A3C_CHOPPER_ASSG_ACTIVE",false,true];
	if ( (_vehicle iskindof "AIR") && !(_landingdata == "LANDFINAL") && !(_abort) ) then {
		[_unit,_movePos] call A3C_ai_shared_fnc_doMove;
		sleep 0.5;
		_vehicle land "NONE";
	};


	//-- WAYPOINT TIMEOUT?
	if ((_wpCondition select 0) == "TIMEOUT") then {
		//-- wait for timeout
		_wpTimeoutValue = (_wpCondition select 1);
		_threshold = 0;
		_counter = 0;
		if (_wpTimeoutValue > 0) then {_threshold = (_wpTimeoutValue / 0.1)};
		while {_counter < _threshold} do {
			if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {_abort = true};
			_vehicle = vehicle _unit; //-- refresh
			if !(A3C_BOOL_MOVINGMARKER) then {
				//-- exit stop
				if ((_wpAction select 0) in ["SUPPRESSION"]) then {
				} else {
					if ([_unit,_movePos,1] call A3C_ai_shared_fnc_unitRouteIsUnitStopped) then {
						_abort = true;
					};
				};
			};
			if ((_wpAction select 0) in ["SUPPRESSION"]) then {
				if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {_abort = true};
			} else {

				if ([_unit,_origdest,_data,_cycle,1] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom) then {
					_abort = true;
					{
						[_x ,position (vehicle _x)] call A3C_ai_shared_fnc_doMove;
					} foreach [_unit,effectivecommander _vehicle];
				};
			};
			_otherUnits = [];
			{
				private _soldier = _x;
				private _unitData = (_soldier getvariable ["A3C_PLOT",[]]);
				if (alive _soldier) then {
					{
						if (_wpMarkerMain == ((_x select 1) select 0)) then {
							_otherUnits pushback _soldier;
						};
					} foreach _unitData;
				};
			} foreach (units group player);
			if (_unit == (_otherUnits select ((count _otherUnits) - ( if ((count _otherUnits) > 0) then {1} else {0})    )) ) then {
				_wpMarkerMain setmarkerTextLocal str (ceil (_wpTimeoutValue - (_counter * 0.1)) );
			};

			if (_abort) exitWith {};
			if (_vehicle isKindOf "AIR") then {
				if (_landingdata in ["PICKUP","DROPOFF"]) then {
					_vehicle setvelocity [0,0,0];
					_vehicle flyinheight 0;
				};
			};
			sleep 0.1;
			_counter = _counter + 1;
		};
	};


	if (isnull _unit) exitWith {};

	///////////////////////////////////////////
	//-- CHECK FOR GO-CODES

	if (_isGoCode) then {
		/*
			PICKUP and DROPOFF helicopter waypoints may already have consumed
			the GoCode while holding the aircraft on the ground. Do not require
			the same short activation pulse to be detected a second time.
		*/
		if (
			_hasActiveGoCode
			&& {
				!_goCodeConditionSatisfied
			}
		) then {
			while {true} do {
				if ([_unit] call A3C_ai_shared_fnc_unitRouteIsWpAborted) exitWith {
					_abort = true;
				};

				if !(A3C_BOOL_MOVINGMARKER) then {
					//-- exit stop
					if ([_unit,_movePos,1] call A3C_ai_shared_fnc_unitRouteIsUnitStopped) then {
						_abort = true;
					};
				};

				if (
					!((_wpAction select 0) in ["SUPPRESSION"])
					&& {
						[
							_unit,
							_origdest,
							_data,
							_cycle,
							1
						] call A3C_ai_shared_fnc_unitRouteIsBrokenFrom
					}
				) then {
					_abort = true;
				};

				if (_abort) exitWith {};

				if (
					missionNamespace getVariable [
						_goCodeActivationVariableName,
						false
					]
				) exitWith {
					_goCodeConditionSatisfied = true;
				};

				sleep 0.1;
			};
		};

		/*
			The completed or inactive GoCode is removed from the waypoint
			condition so the UI availability scan no longer considers this
			plot entry.

			Waypoint data index 3 is _wpCondition. Index 2 is _wpAction.
		*/
		((_data select _cycle) select 3) set [
			1,
			"NONE"
		];

		_unit setVariable [
			"A3C_PLOT",
			_data,
			true
		];

		[] remoteExec [
			"A3C_ui_shared_fnc_toggleGocodeCtrls",
			0
		];
	};

	_vehicle = vehicle _unit; //-- refresh


	if (_wpAction select 0 == "PARADROP") then {
		private _spawnBehaviour = [getPlayerUID player,_vehicle] call A3C_ai_shared_fnc_paradropManage;
		waitUntil {scriptDone _spawnBehaviour};
		sleep 2;
		[_unit ,_movePos] call A3C_ai_shared_fnc_doMove;
		sleep 1;
	};




	sleep 0.1;



	_counter = 0;
	if (_wpLoopValue > -1) then {
		_cycle = _wpLoopValue;
	} else {
		_cycle = _cycle + 1;
	};
	_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",(_cycle + 1),true];
	sleep 0.1; 

	if (_cycle == (count _data)) then {
		while {(alive _unit)} do {
			if (isnull _unit) then {_abort = true};
			if ((count(_unit getvariable ["A3C_PLOT_TEMP",[]])) == 0) exitWith {};
			sleep 0.5;
		};

	};

	while {alive _unit} do {
		if !(_unit getVariable ["A3C_PAUSE_PLAN",false]) exitWith {};
		if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) exitWith {_abort = true};
		sleep 1;
	};

	if (!isPLayer (leader group _unit)) then {
		doStop _unit
	};


};

_unit setVariable ["A3C_unitIsOnMainRoute",false,true];

_unit setvariable ["A3C_ABORT_Data",[false,false],true];

//-- disable suppression if last waypoint action had it 
private _unitPolygons = _unit getVariable ["A3C_UNIT_POLYS", []];
if !(_unitPolygons isEqualTo []) then {
	[[_unit],"SUPPRESSION"] call A3C_ai_shared_fnc_polygonAreaActionOff;
};

//-- reset defaults
{_unit enableAI _x} foreach ["MOVE","TARGET","AUTOTARGET","FSM","AUTOCOMBAT"];
{_unit setskill [_x,((_unit getvariable "A3C_SKILLDATA") select _foreachindex)]} foreach ["commanding","spotDistance","spotTime"];
_unit forcespeed -1;
_vehicle = vehicle _unit; //-- refresh
if (!isnull objectparent _unit && {_unit ==  driver vehicle _unit}) then {
	_vehicle limitSpeed 1000;
};
if !(_unit in A3C_AutoCombatDisabledUnits) then {
	_unit enableAI "AUTOCOMBAT";
};

_unit setvariable ["A3C_PLOT_ACTIVE",false,true];

_unit setvariable ["A3C_CURRENTWAYPOINT_INDEX",1,true];
if !(alive _unit) then {sleep 5}; // safety for reassigning vars when clearing buildings
_unit setvariable ["A3C_PLOT",[],true];









