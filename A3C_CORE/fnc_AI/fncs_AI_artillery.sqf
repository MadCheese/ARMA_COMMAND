A3C_GroupHasArtilleryCapacity = {
	params ["_group"];
	private _return = false;
	{
		private _v = objectParent _x;
		private _cond = !isNull _v && {
			_x == gunner _v && {
				count (getArtilleryAmmo [_v]) > 0
			}
		};
		if (_cond) exitWith {
			_return = true;
		};
	} foreach (units _group);
	_return
};

A3C_AddToArtyRadio = {
	params ["_vehicle"];
	private _commsOperator = gunner _vehicle;
	if (!isNull _commsOperator && {alive _commsOperator}) then {
		A3C_CUSTOMRADIO_ID radioChannelAdd [player,_commsOperator];
		if ("ItemRadio" in assignedItems _commsOperator) then {
			_commsOperator addItem "itemRadio"; 
			_commsOperator assignItem "itemRadio";
		};
	};
};

A3C_getArtilleryAmmo = {
	//-- _includeOrders: bolean to include planned orders or not
	//-- _getDisplayName : bolean to convert/bundle array into displayName
	params ["_includeOrders","_getDisplayName","_targetPos"]; 
	
	private _availableMagsAll= [];
	{
		private _artyPiece = _x;
		private _artyMagTypes = getArtilleryAmmo [_artyPiece];
		private _availableMagsVehicle = (magazinesAmmoFull _artyPiece) select
		{
			_x params ["_magType","_magAmount"];
			_inRange = if (isNil '_targetPos' OR {_targetPos isEqualTo []}) then {true} else {_targetPos inRangeOfArtillery [[_artyPiece], _magType]};
			_inRange && {_magType in _artyMagTypes}
		};
		{
			_x params ["_magType","_magAmount"];
			if ({_x select 0 == _magType} count _availableMagsAll == 0) then {
				//-- create new entry
				_availableMagsAll set
				[
					count _availableMagsAll,
					[_magType,_magAmount]
				];
			} else {
				//-- add to existing entry
				{
					_x params ["_magTypeRef","_magAmountRef"];
					if (_magType == _magTypeRef) exitWith {
						_x set [1, _magAmountRef + _magAmount];
					};
				} foreach _availableMagsAll;
			};	
		} foreach _availableMagsVehicle;
		if (_includeOrders) then {
			private _artyOrdersPlanned = _artyPiece getvariable ["A3C_ARTY_ORDERS",[]];
			{
				//-- filter for matching magtype
				_x params ["_firePos","_magType","_orderCount"];
				{
					_x params ["_magTypeRef","_orderCountRef"];
					if (_magTypeRef == _magType) exitWith {
						(_availableMagsAll select _foreachIndex) set [1,_orderCountRef - _orderCount];
					};
				} foreach _availableMagsAll;
			} foreach _artyOrdersPlanned;
		};
	} foreach MCSS_REMOTE_ARTILLERY_ARRAY;

	
	
	_availableMagsAll = _availableMagsAll select {_x select 1 > 0}; //-- keep only those mags that can be shot
	private _return = _availableMagsAll;
	if (_getDisplayName) then {
		
		private _displayNameArray = [];
		{
			_x params ["_magType","_magAmount"];
			private _displayName = getText (configfile >> "CfgMagazines" >> _magType >> "displayName");

			if ({_x select 0 == _displayName} count _displayNameArray == 0) then {
				//-- create new entry
				_displayNameArray set
				[
					count _displayNameArray,
					[_displayName,_magAmount]
				];
			} else {
				//-- add to existing entry
				{
					_x params ["_displayNameRef","_magAmountRef"];
					private _dspn = getText (configfile >> "CfgMagazines" >> _magType >> "displayName");
					if (_displayNameRef == _displayName) exitWith {
						_x set [1, _magAmountRef + _magAmount];
					};
				} foreach _displayNameArray;
			};	
		} foreach _availableMagsAll;
		_return = _displayNameArray;
	};	
	_return
};



A3C_ORDER_ARTILLERY = {
	params ["_pos","_shift"];
	MCSS_REMOTE_ARTILLERY_ARRAY = MCSS_REMOTE_ARTILLERY_ARRAY select
	{
		_artyAmmo = getArtilleryAmmo [_x];
		{_x in A3C_HC_FOCUS_ARTY_AMMO_ARRAY} count _artyAmmo > 0
	};
	_fireCount = A3C_HC_FOCUS_ARTY_AmmoCount; //-- copy number
	//systemchat str [count MCSS_REMOTE_ARTILLERY_ARRAY,A3C_HC_FOCUS_ARTY_AMMO_ARRAY,_fireCount];
	//private _fireOrders = [];
	//-- stack fireorders
	//--  while _fireCount is > 0, units are distributed shots one by one 
	//-- meaning: unit1 takes shot 1, unit 2 takes shot 2 
	//-- unit needs to check if it can take the shot:
	//-->> unit needs to have more mags of allowed types than existing fireorders of matching types 
	//-- unit gets a shot assigned with the ammo that is has left 
	//-->> take all existing ammo


	private _artyLeaderVic = MCSS_REMOTE_ARTILLERY_ARRAY select 0;
	private _artyLeader = gunner _artyLeaderVic;
	{
		[_x] call A3C_AddToArtyRadio;
	} foreach MCSS_REMOTE_ARTILLERY_ARRAY;

	
	//A3C_CUSTOMRADIO_ID radioChannelAdd [player];
	
	
	//-- create data
	private _canNotFire = true;
	private _artyOrdersCurrent = []; //[vehicle, pos, mag, amount] >> array handling CURRENT artillery order. carries _vehicle
	while {_fireCount > 0} do {
		
		{
			//-- THIS STEP DISTRIBUTES SHELLS OF THE CURRENTLY REQUESTED ORDER THROUGHOUT THE AVAILABLE VEHICLES
			private _artyPiece = _x;
			if (_fireCount == 0) exitWith {};
			
			private _availableMags = (magazinesAmmoFull _artyPiece) select
			{
				_x params ["_magType","_magAmount"];
				(_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY) && {_pos inRangeOfArtillery [[_artyPiece], _magType]}
			};
			private _artyOrdersPlanned = _artyPiece getvariable ["A3C_ARTY_ORDERS",[]];
			//player sidechat str _artyOrdersPlanned;
			_artyOrdersFiltered = _artyOrdersPlanned select
			{
				//-- filter for matching magtype
				_x params ["_firePos","_magType","_orderCount"];
				_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY
			};
			private _exit = false;
			{
				_x params ["_firePos","_magType","_orderCount"];
				{
					private _magData = _x;
					_magData params ["_magTypeRef","_magAmount"];
					//systemchat str [_magTypeRef , _magType];
					if (_magTypeRef == _magType) exitWith {
						(_availableMags select _foreachIndex) set [1,_magAmount - _orderCount];
						//_x set [1,_magAmount - _orderCount];
						_exit = true;
						//systemchat str (_magAmount - _orderCount);
					};
				} foreach _availableMags;
				if (_exit) exitWith {};
			} foreach _artyOrdersFiltered;
			_availableMags = _availableMags select {_x select 1 > 0};

			if !(_availableMags isEqualTo []) then {
				private _selectedMag = (_availableMags select 0) select 0;
				

				if ({_x select 0 == _artyPiece && {_x select 2 == _selectedMag && {_x select 1 isEqualTo _pos}}} count _artyOrdersCurrent == 0) then {
					//-- create new entry
					_artyOrdersCurrent set [count _artyOrdersCurrent,[_artyPiece,_pos,_selectedMag,1]];
				} else {
					//-- add to existing entry
					{
						if (_x select 0 == _artyPiece && {_x select 2 == _selectedMag && {_x select 1 isEqualTo _pos}}) exitWith {
							_x set [3,(_x select 3) + 1];
						};
					} foreach _artyOrdersCurrent;
				};
				
				if ({_x select 1 == _selectedMag && {_x select 0 isEqualTo _pos}} count _artyOrdersPlanned == 0) then {
					//-- create new entry
					_artyOrdersPlanned set [count _artyOrdersPlanned,[_pos,_selectedMag,1]];
					_canNotFire = false;
					_fireCount = _fireCount - 1;
				} else {
					//-- add to existing entry
					{
						if (_x select 1 == _selectedMag && {_x select 0 isEqualTo _pos}) exitWith {
							_x set [2,(_x select 2) + 1];
							_canNotFire = false;
							_fireCount = _fireCount - 1;
						};
					} foreach _artyOrdersPlanned;
				};
				_artyPiece setvariable ["A3C_ARTY_ORDERS",_artyOrdersPlanned,true];
			};

		} foreach MCSS_REMOTE_ARTILLERY_ARRAY;
		if (_canNotFire) exitWith {
			hint "ARTILLERY PROBLEM: SOME GUNS ARE NOT IN RANGE";	
		};
	};

	if !(_canNotFire) then {
		hint "";
		//-- comms: REQUESTING SUPPORT
		player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];


		[_artyLeader] spawn {
			params ["_artyLeader"];
			sleep (3 + (random 2));
			_artyLeader customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];
		};
		//systemchat str _artyOrdersCurrent;
		// _artyOrdersCurrent carries data for executed strikes of MULTIPLE vehicles
		// we now cycle through those orders and reference them to existing orders
		{
			//-- THIS STEP CHECKS FOR PRE-EXISTING ORDERS. IF NONE EXIST, WE ADD THE MANAGEMENT EVENTHANDLERS
			sleep random 2;
			_x params ["_vehicle","_pos","_magType","_shellAmount"];

			//-- slightly messy, maybe :) determine if this is first or added order. Manage accordingly
			private _artyOrdersPlanned = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
			private _currentOrder = _x - [_x select 0]; //-- current order instance (_x) in format of "A3C_ARTY_ORDERS" variable
			private _ordersPreExist = _artyOrdersPlanned - [_currentOrder];

			//systemchat str _currentOrder;

			if (_ordersPreExist isEqualTo []) then {

				//systemchat "INITIAL ORDER";


				//-- NO ORDERS EXIST: DISTRIBUTE MANAGEMENT EVENTHANDLERS
				private _spread = if (_shellAmount > 7) then {random 50} else {1};
				

				//-- problem: we only want one 'SPLASH' message for the first shell per order
				//-- we need extra EH because later we can not identify the order-index 
				
				_vehicle setVariable ["A3C_ARTY_TARGETPOS",_pos,true];
				_splashHandler = _vehicle addEventHandler
				[
					"FIRED",
					{
						params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

						_vehicle removeEventHandler [_thisEvent,_thisEventHandler];

						_targetPos = _vehicle getVariable ["A3C_ARTY_TARGETPOS",[]];

						if !(_targetPos isEqualTo []) then {
							private _artyShellETA = _vehicle getArtilleryETA [_targetPos, _magazine];
							_artyShellETA = _artyShellETA max 0;
							private _commsOperator = gunner _vehicle;
							[_artyShellETA,_commsOperator] spawn { //-- SPLASH only relates to the first shell
								params ["_artyShellETA","_commsOperator"];
								//sleep 2;
								//systemchat format ["SPLASH ETA: %1sec", round _artyShellETA];
								sleep (_artyShellETA - 7);
								_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAccomplishedSGArty"];
							};
						};
						_vehicle setVariable ["A3C_ARTY_TARGETPOS",nil,true];	
					}
				];

				private _eventHandlers = _vehicle getVariable ["A3C_ARTY_EH",[]];
				private _ehFired = -1;
				private _ehReloaded = -1;
				if (_eventHandlers isEqualTo []) then {
					_ehFired = _vehicle addEventHandler
					[
						"FIRED",
						{
							params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

							//systemchat format ["A UNIT HAS FIRED (%1)",(round time)];

							_vehicle setVariable ["A3C_ARTY_LAST",time,true];

							//-- SECURITY: REMOVE ALL REMAINING ORDERS IF GUN STOPS SHOOTING
							[_vehicle] spawn {
								params ["_vehicle"];
								sleep 15;
								private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST",nil];
								private _cond = !isNil '_lastShot' &&
								{
									(time - _lastShot) > 14 &&
									{
										private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
										!(_artyOrders isEqualTo [])
									}
								};
								if (_cond) then {

									// systemchat "SAFETY >> fired";
									//-- remove EHs
									private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
									if !(_varData isEqualTo []) then {
										_varData params ["_dataFired","_dataReloaded"];
										_vehicle removeEventHandler [_dataFired select 0,_dataFired select 1];
										_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
									};
									
									//-- reset main orders var
									_vehicle setvariable ["A3C_ARTY_ORDERS",nil,true];
									
									//-- reset currentOrder var
									_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

									//-- remove last fired var
									_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

									//-- delete EH objectNameSpace var 
									_vehicle setVariable ["A3C_ARTY_EH",nil];

									//-- radio feedback: ROUNDS COMPLETE
									private _commsOperator = gunner _vehicle;
									[_vehicle] call A3C_AddToArtyRadio;
									_commsOperator spawn {
										sleep (1 + (random 2));
										_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
									};
								};
							};

							

							
							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
							

							private _orderCurrent = _vehicle getVariable ["A3C_ARTYORDER_CURRENT",[]];
							_orderCurrent params ["_currentFirePos","_currentFireMag","_currentShellAmount"];

							if (_currentFireMag == _magazine) then {
								
								_currentShellAmount = (_currentShellAmount - 1) max 0;
								if (_currentShellAmount > 0) then {
									//-- CURRENT ORDER NOT YET COMPLETE
									//-- remove shot from current order
									_vehicle setVariable ["A3C_ARTYORDER_CURRENT",[_currentFirePos,_currentFireMag,_currentShellAmount], true];
									//-- remove shot from main variable
									{
										_x params ["_firePos","_magType","_orderCount"];
										if (_magType == _magazine) exitWith { //-- assumption: last shot will always be from current order
											_x set [2, _orderCount - 1];
										};
									} foreach _artyOrders; //-- note: just using (_artyOrders select 0) does not work if one magtype is used in multiple orders
									

									//systemchat "removing shell from current orders";
								} else {

									//-- CURRENT ORDER COMPLETE: MOVE TO NEXT OR DELETE VARIABLES

									//-- remove order from main variable
									_artyOrders = _artyOrders - [_orderCurrent];

									
									if (_artyOrders isEqualTo []) then {
										

										//-- No more orders: remove EHs
										_vehicle removeEventHandler [_thisEvent,_thisEventHandler];
										//systemchat "eh's removed REG FIRED";
										private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
										if !(_varData isEqualTo []) then {
											_varData params ["_dataFired","_dataReloaded"];
											_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
											
											//systemchat "eh's removed REG RELOAD";	
											
										};

										//-- MAIN var will be reset after the current parenting if statement is completed

										//-- reset currentOrder var
										_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

										//-- remove last fired var
										_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

										//-- delete EH objectNameSpace var 
										_vehicle setVariable ["A3C_ARTY_EH",nil];

										//-- radio feedback: ROUNDS COMPLETE
										private _commsOperator = gunner _vehicle;
										[_vehicle] call A3C_AddToArtyRadio;
										// systemchat "ARTY ORDERS COMPLETE";
										_commsOperator spawn {
											sleep (1 + (random 2));
											_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
										};
									} else {
										//-- still more orders lined up
										//systemchat "executing next order";
										_nextOrder = _artyOrders select 0;
										_nextOrder params ["_nextTargetPos","_nextMagType","_nextShellAmount"];
										_vehicle setVariable ["A3C_ARTYORDER_CURRENT",_nextOrder, true];
										[_vehicle,[_nextTargetPos getPos [5,random 360],_nextMagType,_nextShellAmount]] remoteExec ["commandArtilleryFire",_vehicle];
									};
								};
							};
							_vehicle setvariable ["A3C_ARTY_ORDERS",_artyOrders];
						}
					];

					//-- ISSUE: commandArtilleryFire gets cancelled if the vehicle reloads. We add a reloaded-EH that cancels all Arty Data
					_ehReloaded = _vehicle addEventHandler
					[
						"RELOADED",
						{
							params ["_vehicle", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];

							_newMagazine = _newMagazine select 0;
							_oldMagazine = if (isNil '_oldMagazine' OR {_oldMagazine isEqualTo []}) then {"rndm"} else {_oldMagazine select 0};

							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];


							if (_newMagazine == _oldMagazine) then {
								//-- canceled orders due to reload >> (engine bug) reissue remaining artillery orders!
								// systemchat "A VEHICLE IS RELOADING MID ORDER";
								private _targetPos = [];
								private _shellAmount = 0;
								{
									_x params ["_firePos","_magType","_orderCount"];
									//systemchat str [_magazine,_magType];
									if (_magType == _oldMagazine) then {
										_targetPos = _firePos; //-- will use last one (note: will not matter once orders are made stack-able)
										_shellAmount = _shellAmount + _orderCount;
									};
								} foreach _artyOrders;
								
								if !(_targetPos isEqualto []) then {
									[_vehicle,[_targetPos getPos [5,random 360],_oldMagazine,_shellAmount]] remoteExec ["commandArtilleryFire",_vehicle];
								};
							} else {
								// systemchat "A VEHICLE HAS CHANGED MAGS";
							};
						}
					];

					_vehicle setVariable
					[
						"A3C_ARTY_EH",
						[
							["FIRED",_ehFired],
							["RELOADED",_ehReloaded]
						]
					];
				};

				_vehicle setVariable ["A3C_ARTYORDER_CURRENT",_currentOrder,true];
				
				[_vehicle,[_pos getPos [_spread,random 360],_magType,_shellAmount]] remoteExec ["commandArtilleryFire",_vehicle];

				//-- SAFTEY: IF UNIT DOES NOT REACT TO ORDER, DELETE VARIABLES
				_vehicle setVariable ["A3C_ARTY_LAST",time,true]; //-- precaution to be sure to have a reference.
				[_vehicle,_splashHandler,_ehFired,_ehReloaded] spawn {
					params ["_vehicle","_splashHandler","_ehFired","_ehReloaded"];
					sleep 15;
					private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST",nil];
					private _cond = !isNil '_lastShot' &&
					{
						(time - _lastShot) > 14 &&
						{
							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
							!(_artyOrders isEqualTo [])
						}
					};
					if (_cond) then {
						// systemchat "SAFETY >> unresponsive";
						//-- remove EHs
						private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
						if !(_varData isEqualTo []) then {
							_varData params ["_dataFired","_dataReloaded"];
							_vehicle removeEventHandler [_dataFired select 0,_dataFired select 1];
							_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
						};

						//-- reset main orders var
						_vehicle setvariable ["A3C_ARTY_ORDERS",nil,true];

						//-- reset currentOrder var
						_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

						//-- remove last fired var
						_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

						//-- delete EH objectNameSpace var 
						_vehicle setVariable ["A3C_ARTY_EH",nil];

						//-- radio feedback: ROUNDS COMPLETE
						private _commsOperator = gunner _vehicle;
						[_vehicle] call A3C_AddToArtyRadio;
						_commsOperator spawn {
							sleep (1 + (random 2));
							_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYCannotExecuteAdjustCoordinates"];
							hint "hint: sometimes vehicles become unresponsive. Try to move the vehicle(s) a bit and make sure that they face the target";
						};

						//-- remove splash handler
						_vehicle removeEventHandler ["FIRED",_splashHandler];
					};
				};
			};	
		} foreach _artyOrdersCurrent;


	};


};

