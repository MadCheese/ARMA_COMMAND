/*
A3C_SYNC_DOWN1 = {
	_sx = _this select 0;
	_sy = _this select 1;
	A3C_LOOPSYNC_START = "";
	_pos = ((findDisplay 6999 displayCtrl 7043) posscreentoworld [_sx,_sy]);
	_clickedItem = (ctrlMapMouseOver (findDisplay 6999 displayCtrl 7043));
	if ((_clickedItem select 0) == "marker") then {
		if ((_clickedItem select 1) in A3C_MARKERS_TEMP) then {			
			A3C_LOOPSYNC_START_TEMP = (_clickedItem select 1); 
			if ((markerType A3C_LOOPSYNC_START_TEMP) in A3C_INF_MARKERS) then {				
				A3C_LOOPSYNC_START = A3C_LOOPSYNC_START_TEMP;
				A3C_DUMMY = 'Sign_Sphere10cm_F' createVehicleLocal _pos;
				A3C_DUMMY allowdamage false;
				A3C_DUMMY hideobjectGlobal true;
				A3C_DUMMY disableCollisionWith player;
				A3C_BU2 = (findDisplay 6999 displayCtrl 7043) ctrlAddEventHandler ["MouseMovIng","_this spawn A3C_MouseMoving"];
				call compile format ["
					SyncLine_TEMP_diag = (findDisplay 6999 displayCtrl 7043) ctrlAddEventHandler ['Draw','(_this select 0) drawline [%1, (getpos A3C_DUMMY), [0,0.74,0.14,1]];'];
				",_pos];
			};
		};
	};
};

A3C_SYNC_UP1 = {
	private ["_unit","_markerPos","_abort","_SwitchData","_wpIndex","_markerPosStart","_markerPosEnd","_data","_startPosUnits","_endPosUnits","_abort","_wpCouples"];
	_sx = _this select 0;
	_sy = _this select 1;
	_pos = ((findDisplay 6999 displayCtrl 7043) posscreentoworld [_sx,_sy]);
	_clickedItem = (ctrlMapMouseOver (findDisplay 6999 displayCtrl 7043));
	_markerPosStart = [0,0,0];
	_markerPosEnd = [0,0,0];
	_startPosUnits = [];
	_endPosUnits = [];
	_switchData = [];
	_wpCouples = [];
	_wpIndex = 0;
	A3C_SYNC_ABORT = false;	
	_data = [];
	A3C_SHARED_SYNC_IDS = [];
	A3C_SYNC_UNITS = [];
	if (A3C_LOOPSYNC_START in A3C_MARKERS_TEMP) then {
		deletevehicle A3C_DUMMY;
		(findDisplay 6999 displayCtrl 7043) ctrlRemoveEventHandler ['MouseMoving',A3C_BU2];
		(findDisplay 6999 displayCtrl 7043) ctrlRemoveEventHandler ['Draw',SyncLine_TEMP_Diag];
		_markerPosStart = markerpos A3C_LOOPSYNC_START;		
		if ((_clickedItem select 0) == "marker") then {
			if ((_clickedItem select 1) in A3C_MARKERS_TEMP) then {
				A3C_SYNC_END_TEMP = (_clickedItem select 1); 
				if (markerType A3C_SYNC_END_TEMP in A3C_INF_MARKERS) then {						
					A3C_SYNC_END = A3C_SYNC_END_TEMP;
					_markerPosEnd = markerpos A3C_SYNC_END;					
					{
						_unit = _x;
						_data = _unit getvariable "A3C_PLOT_TEMP";
						for "_i" from 0 to ((count _data) -1) do {
							if ( (_markerPosStart distance (getmarkerpos ((_data select _i) select 2))) < 1 ) then {
								A3C_SYNC_UNITS pushback _unit;
								_startPosUnits pushback _unit;
								_unit setvariable ["A3C_SYNC_WPINDEX",(_i +1),true];
							};
							if ((_markerPosEnd distance (getmarkerpos ((_data select _i) select 2)) ) < 1 ) then {
								if !(_unit in A3C_SYNC_UNITS) then {
									A3C_SYNC_UNITS pushback _unit;
									_endPosUnits pushback _unit;
									_unit setvariable ["A3C_SYNC_WPINDEX",(_i +1),true];
								} else {
									A3C_SYNC_ABORT = true;
								};										
							};
			
						};														
					} foreach (profileNamespace getvariable "A3C_GROUPUNITS");
					if ({!alive _x} count A3C_SYNC_UNITS > 0) exitwith  {};

					{
							_soldier = _x;
							_switchdata = (_soldier getvariable "A3C_PLOT_TEMP"); 		
							if (count _switchData > 0) then {
								for "_i" from 0 to ((count _switchData) -1) do {
									if ( (( (getmarkerpos ((_switchData select _i) select 2)) distance _markerPosStart) < 1) OR (((getmarkerpos ((_switchData select _i) select 2)) distance _markerPosEnd) < 1) ) then {
										// CLEAN THIS UP				
									};
								};
							};
					} foreach A3C_SYNC_UNITS;
					
					if (A3C_SYNC_ABORT) then {	
					} else {
						{
							_soldier = _x;
							_switchdata = (_soldier getvariable "A3C_PLOT_TEMP"); 		
							if (count _switchData > 0) then {
								for "_i" from 0 to ((count _switchData) -1) do {
									if ( (( (getmarkerpos ((_switchData select _i) select 2)) distance _markerPosStart) < 1) OR (((getmarkerpos ((_switchData select _i) select 2)) distance _markerPosEnd) < 1) ) then {
											if ((count ((_switchdata  select _i) select 6) > 1)) then {
												((_switchdata  select _i) select 6) pushback [A3C_SYNC_INDEX,false];

											} else {
												if  ( ((((_switchdata  select _i) select 6) select 0) select 0) == 0 ) then {
													(((_switchdata  select _i) select 6) select 0) set [0,A3C_SYNC_INDEX];
												} else {
													((_switchdata  select _i) select 6) pushback [A3C_SYNC_INDEX,false];
													
												};
											};											
											_soldier setvariable ["A3C_PLOT_TEMP",_switchData,true];
											_soldier setvariable ["A3C_SYNC_ITEMS",((_soldier getvariable "A3C_SYNC_ITEMS") + [A3C_SYNC_INDEX]),true];
											{
												_entry = _x;
												if !(_entry in (_soldier getvariable "A3C_SYNC_PARTNERS")) then {
													_soldier setvariable ["A3C_SYNC_PARTNERS",((_soldier getvariable "A3C_SYNC_PARTNERS") + [_entry]),true];
												};												
											} foreach A3C_SYNC_UNITS - [player,_soldier];						
									};
								};
							};
						} foreach A3C_SYNC_UNITS;
						
						
						if (A3C_SYNC_ABORT) then {
						} else {
							call compile format ["
								SyncLine_%1 = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler ['Draw','(_this select 0) drawline [%2, %3, [0,0.74,0.14,A3C_OPACITY]];'];
								SyncLine_%1_diag = (findDisplay 6999 displayCtrl 7043) ctrlAddEventHandler ['Draw','(_this select 0) drawline [%2, %3, [0,0.74,0.14,1]];'];
							",A3C_SYNC_INDEX,_markerPosStart,_markerPosEnd];						
							A3C_UNDO_MODE = 1;
							A3C_USERACTION pushback [A3C_USERACTION_ID,1,A3C_SYNC_INDEX]; 
							A3C_USERACTION_ID = A3C_USERACTION_ID + 1;
							A3C_SYNC_INDEX = A3C_SYNC_INDEX + 1; 
						};	
					};				
				};
			};
		};
	} else {
		//player sidechat "No Sync Start given";
	};
			
};


// FROM _MOVE FUNCTION

		//-- wait until sync is considered complete
		_SyncDataOrig = ((_data select _cycle) select 6);
		_syncIndex = 0; // ?
		_SyncData= (_unit getvariable "A3C_PLOT");
		_otherUnits = units group player - [player,_unit];		
		if !(((_syncDataOrig select 0) select 0) == 0) then {
			while {true} do {
				//if (_smokeMode < 3) exitwith {};
				if !(alive _unit) then {_abort = true};
				if ({_x} count (_unit getvariable "A3C_ABORT_Data") > 0) then {_abort = true};
				if (currentcommand _unit == "STOP") then {
					if !( ((expectedDestination _unit ) select 1) == "LEADER PLANNED") then {
						if !( (effectivecommander (vehicle _unit)) == _unit) then {
							if !( ((expectedDestination (effectivecommander (vehicle _unit))) select 1) == "LEADER PLANNED") then {
								_abort = true;
							};
						} else {	
							_abort = true;
						};
					};
				};
				if !(_unit == (driver vehicle _unit)) then {_abort = true};	
				if (((expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) then {_abort = true}; 
				if !(_smokemode == 3) then {
					if ([_unit,_origdest,_data,_cycle] call A3C_ExitRoute_isBrokenFrom) then {
						_abort = true;
						{dostop _x} foreach [_unit,effectivecommander (vehicle _unit)];
					};
				};
				if (_abort) exitwith {};
				_syncComplete = true;
				_SyncCompleteMain = true;
				{
					if ( (count (_x getvariable "A3C_PLOT")) == 0 ) then {
						_otherUnits= _otherUnits - [_x];
					};
				} foreach _otherUnits;			
				{
					_syncIndex = (_x select 0);					
					if !(_syncIndex == 0) then {
						{
							_soldier = _x;							
							_dataCompared = (_soldier getvariable "A3C_PLOT");
							if (alive _soldier) then {
								{									
									_comparedWP = _x;
									if !( (_comparedWP select 2) == ((_data select _cycle) select 2) ) then {
										_syncDataCompared = (_comparedWP select 6);																		
										{
											_testedSyncSubArray = _x;
											_syncComplete = true;
											if ( (_testedSyncSubArray select 0) == _syncIndex ) then {
												if !((_comparedWP select 7)) then {
													// -targeted unit has NOT reached this destination
													if !(_abort) then {
														_syncComplete = false;
														_SyncCompleteMain = false;
													};
												} else {
													// -targeted unit HAS reached this destination
													(_syncDataCompared select _forEachIndex) set [1,true];
													//_comparedWP set [6,_syncDataCompared];											
													if ({!(_x select 1)} count _syncDataCompared > 0) then {
														if !(_abort) then {
															_syncComplete = false;
															_SyncCompleteMain = false;
														};
													};
												};
											};
										} foreach _syncDataCompared;
									};
								} foreach _dataCompared;
							};
						} foreach _otherUnits;
					};
				} foreach _SyncDataOrig;
				if (_syncCompleteMain) exitwith {};
				sleep 0.1;
			};
			if ( !(_syncIndex == 0) && !(_abort) ) then {
				call compile format ["
					(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ['Draw',SyncLine_%1];	
					(findDisplay 6999 displayCtrl 7043) ctrlRemoveEventHandler ['Draw',SyncLine_%1_Diag];
				",_syncIndex];
			};
		};




//-- ANTI BUG TRIGGER FUNCTION FOR HELICOPTER DURING PICKUP/DROPOFF
A3C_fnc_CrewTrig = {
	if (true) exitwith {};
	_unit = _this select 0;
	_movePos = [((position (vehicle _unit)) select 0),((position (vehicle _unit)) select 1),0];
	[_unit,_movePos] call A3C_DOMOVE;
	if (_unit getvariable "A3C_WAITCARGO") then {
		(vehicle _unit) flyinheight 0; 
		(vehicle _unit) setvelocity [0,0,0];
		_unit disableai "move";	
	};
	_unit setvariable ['A3C_CREWCOUNT',(count crew (vehicle _unit)),true]; 
};


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

A3C_INFANTRY_SUPPRESS = {
	_unit = _this select 0;
	_target = _this select 1;
	if ((count (_unit getvariable "A3C_PLOT"))  == 0) then {dostop _unit;};
	_unit dotarget _target;
	_amount = 0;
	_burst = true;
	//_modes = (getArray (configFile >> "CfgWeapons" >> currentWeapon _unit >> "modes"));
	//_modeFinal = _modes select 1;
	_unit selectWeapon (primaryWeapon _unit);
	sleep 2;
	while {alive _unit} do {
		_unit dotarget _target;
		_unit dowatch _target;
		_unit lookat _target;
		if ((assignedtarget _unit) == _target) then {
			if !(weaponLowered _unit) then {
				if (speed _unit < 1) then {									
					if ([_target, _unit] call MCSS_fnc_LOF) then {						
						if ([_unit] call A3C_NOBLUEONBLUE) then {						
							_burst = [true,false] call BIS_fnc_selectRandom;
							_amount = 1 + (round random 5);
							for "_i" from 1 to _amount do {
								//_unit forceWeaponFire [(primaryWeapon _unit),_modeFinal];
								_unit forceWeaponFire [ weaponState _unit select 1, weaponState _unit select 2];
								if (_burst) then {
									sleep 0.1;
								} else {
									sleep 0.1 + (random 0.5);
								};
							};						
						};						
					};
				};
			};
		};	
		sleep 0.5 + (random 1);
	};
	
};

A3C_SUPPRESSION_LOOP = {
	private ["_aslpos","_aslpos1"];
	_unit = _this select 0;
	_target = _this select 1;
	_targetpos = _this select 2;
	_origin = _this select 3;
	_mode = _this select 4;
	_veh = vehicle _unit;
	_aslpos = [((getposASL _veh) select 0),((getposASL _veh) select 1),2];
	_weapons = (weapons _veh - A3C_SUPPRESSION_FORBIDDEN); 
	_neartargets = [];
	_realtargetsPre = [];
	_realtargetsPOST = [];
	_pos = position _unit;	
	while {((_unit getvariable "A3C_SUPPRESSION_TARGET") select 1)} do {
		_neartargets = [];
		_realtargetsPre = [];
		_realtargetsPOST = [];		
		{
			if ( ((side _x) getfriend (side _unit)) < 0.6) then {_neartargets = _neartargets + [_x]}
		} foreach (_veh nearObjects ["ALLVEHICLES",500]);  //(_veh neartargets 500);
		{
			_item = _x;
			if ({_item iskindof _x} count ["TANK","MAN","CAR"] == 0) then {
				_neartargets = _neartargets - [_item];
			};
		} foreach _neartargets;		
		if ((count _neartargets) > 0) then {			
			{
				if (_mode == "INF") then {
					if ([_x, _unit,"AREA"] CALL MCSS_fnc_LOS_INF) then {
						_realtargetsPRE pushback _x;
						_unit reveal [_x,4];
					};
					
				} else {
					if ([_unit,_x] call MCSS_fnc_LOS_SIMPLE) then {
						_realtargetsPRE pushback _x; // &&  !
						_unit reveal [_x,4];
					};
				};
			} foreach _neartargets;
			{
				if ((_x aimedAtTarget [_veh]) > 0) then {_realtargetsPOST pushback _x; _realtargetsPRE = _realtargetsPRE -[_x]};
			} foreach _realtargetsPRE;			
			_realtargetsPOST = _realtargetsPOST + _realtargetsPRE;			
			if (count _realtargetsPOST > 0) then {				
				_origin setpos (_unit getRelPos [(viewdistance + 500),(getdir _unit)]);
				if (_mode == "INF") then {
					terminate (_unit getvariable "A3C_SUPPRESSION_SCRIPT");
					_unit dowatch objnull; _unit dotarget (_realtargetsPOST select 0); _unit dofire (_realtargetsPOST select 0);
					
				} else {
					
					//{_x dowatch objnull; _x dotarget (_realtargetsPOST select 0)} foreach crew vehicle _unit;
					//_unit dotarget (_realtargetsPOST select 0);
					//_unit dofire (_realtargetsPOST select 0);
					////_Unit dowatch position (_realtargetsPOST select 0);
					//if (_Unit aimedAtTarget [(_realtargetsPOST select 0)] > 0) then {
					//	//{_veh fireAtTarget [(_realtargetsPOST select 0),_x]} forEach _weapons;
					//	_veh fireAtTarget [(_realtargetsPOST select 0),(_weapons select 0)];
					//	sleep (0.1 + (random 0.4));
					//};
					
				};
			} else {
				_origin setpos _targetpos;
				if (_mode == "INF") then {
					_unit dowatch objnull;
					_unit dotarget _target;
					_unit dofire _target;
					if (isnull (_unit getvariable "A3C_SUPPRESSION_SCRIPT")) then {
						_script = [_unit,_target] spawn A3C_INFANTRY_SUPPRESS;
						 _unit setvariable ["A3C_SUPPRESSION_SCRIPT",_script,false];
					};
				} else {
					{_x dowatch objnull; _x dotarget _target} foreach crew vehicle _unit;
					_unit dotarget _target;
					_unit dowatch _target;
					_unit dofire _target;
					if (_Unit aimedAtTarget [_target] > 0) then {
						{_veh fireAtTarget [_target,_x]} forEach _weapons;
						sleep (0.1 + (random 0.4));
					};
				};
			};
		} else {
			if ((_origin distance _targetpos) > 500) then {
				_origin setpos _targetpos;
			};
			if (_mode == "INF") then {					
				_unit dowatch objnull; 
				_unit dotarget _target; 
				_unit dofire _target;
				if (isnull (_unit getvariable "A3C_SUPPRESSION_SCRIPT")) then {
					_script = [_unit,_target] spawn A3C_INFANTRY_SUPPRESS;
					 _unit setvariable ["A3C_SUPPRESSION_SCRIPT",_script,false];
				};
			} else {
					_unit dotarget _target;
					_unit dofire _target;
					if (_Unit aimedAtTarget [_target] > 0) then {
						{_veh fireAtTarget [_target,_x]} forEach _weapons;
						sleep (0.1 + (random 0.4));
					};					
			};

		};
		//hintsilent format ["Targets: %1 , activetarget: %2, snakepos :%3", (_realtargetsPOST),assignedtarget _unit, position _origin];
		sleep 0.1;
	};	
};

//-- prevent suppressing units firing on friendlies (fps-cost)
A3C_NOBLUEONBLUE = {
	_unit = _this select 0;
	_result = true;
	_otherunits = [];
	{
		if ( ((side _x) getfriend (side _unit)) >= 0.6 ) then {
			_otherunits pushback _x;
		};
	} foreach (_unit nearEntities ["Man", 150]) - [_unit];		
	if ( { ([_x, _unit] call MCSS_fnc_LOF) } count _otherunits > 0) then {_result = false};
	_array = [];
	{
		if ([_x, _unit] call MCSS_fnc_LOF) then {
			_array pushback _x;
		};
	} foreach _otherunits;
	_result
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

*/