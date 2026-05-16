// A3C_ai_shared_fnc_actionFireArtillery

//-- Stack fire orders.
//-- While _fireCount is > 0, units are distributed shots one by one.
//-- Meaning: unit 1 takes shot 1, unit 2 takes shot 2.
//-- Unit needs to check if it can take the shot:
//-->> unit needs to have more mags of allowed types than existing fire orders of matching types.
//-- Unit gets a shot assigned with the ammo that it has left.
//-->> take all existing ammo.

params ["_pos", "_shift"];

MCSS_REMOTE_ARTILLERY_ARRAY = MCSS_REMOTE_ARTILLERY_ARRAY select {
	private _artyAmmo = getArtilleryAmmo [_x];
	{_x in A3C_HC_FOCUS_ARTY_AMMO_ARRAY} count _artyAmmo > 0
};

if (MCSS_REMOTE_ARTILLERY_ARRAY isEqualTo []) exitWith {
	systemChat "A3C: No artillery available";
};

private _fireCount = A3C_HC_FOCUS_ARTY_AmmoCount; //-- copy number
private _artyLeaderVic = MCSS_REMOTE_ARTILLERY_ARRAY select 0;
private _artyLeader = gunner _artyLeaderVic;

{
	[_x] call A3C_ai_highCommand_fnc_addArtyToRadioChannel;
} forEach MCSS_REMOTE_ARTILLERY_ARRAY;

//-- Create data.
private _canNotFire = true;
private _artyOrdersCurrent = []; //[vehicle, pos, mag, amount] >> array handling CURRENT artillery order. Carries _vehicle.

while {_fireCount > 0} do {
	{
		//-- This step distributes shells of the currently requested order throughout the available vehicles.
		private _artyPiece = _x;

		if (_fireCount == 0) exitWith {};

		private _availableMags = (magazinesAmmoFull _artyPiece) select {
			_x params ["_magType", "_magAmount"];
			(_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY) && {_pos inRangeOfArtillery [[_artyPiece], _magType]}
		};

		private _artyOrdersPlanned = _artyPiece getVariable ["A3C_ARTY_ORDERS", []];

		private _artyOrdersFiltered = _artyOrdersPlanned select {
			//-- Filter for matching mag type.
			_x params ["_firePos", "_magType", "_orderCount"];
			_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY
		};

		private _foundReservedMag = false;

		{
			_x params ["_firePos", "_magType", "_orderCount"];

			{
				_x params ["_magTypeRef", "_magAmount"];

				if (_magTypeRef == _magType) exitWith {
					(_availableMags select _forEachIndex) set [1, _magAmount - _orderCount];
					_foundReservedMag = true;
				};
			} forEach _availableMags;

			if (_foundReservedMag) exitWith {};
		} forEach _artyOrdersFiltered;

		_availableMags = _availableMags select {_x select 1 > 0};

		if (_availableMags isNotEqualTo []) then {
			private _selectedMag = (_availableMags select 0) select 0;

			if ({
				_x params ["_orderVehicle", "_orderPos", "_orderMag", "_orderAmount"];
				_orderVehicle == _artyPiece && {_orderMag == _selectedMag && {_orderPos isEqualTo _pos}}
			} count _artyOrdersCurrent == 0) then {
				//-- Create new entry.
				_artyOrdersCurrent set [count _artyOrdersCurrent, [_artyPiece, _pos, _selectedMag, 1]];
			} else {
				//-- Add to existing entry.
				{
					_x params ["_orderVehicle", "_orderPos", "_orderMag", "_orderAmount"];

					if (_orderVehicle == _artyPiece && {_orderMag == _selectedMag && {_orderPos isEqualTo _pos}}) exitWith {
						_x set [3, _orderAmount + 1];
					};
				} forEach _artyOrdersCurrent;
			};

			if ({
				_x params ["_orderPos", "_orderMag", "_orderAmount"];
				_orderMag == _selectedMag && {_orderPos isEqualTo _pos}
			} count _artyOrdersPlanned == 0) then {
				//-- Create new entry.
				_artyOrdersPlanned set [count _artyOrdersPlanned, [_pos, _selectedMag, 1]];
				_canNotFire = false;
				_fireCount = _fireCount - 1;
			} else {
				//-- Add to existing entry.
				{
					_x params ["_orderPos", "_orderMag", "_orderAmount"];

					if (_orderMag == _selectedMag && {_orderPos isEqualTo _pos}) exitWith {
						_x set [2, _orderAmount + 1];
						_canNotFire = false;
						_fireCount = _fireCount - 1;
					};
				} forEach _artyOrdersPlanned;
			};

			_artyPiece setVariable ["A3C_ARTY_ORDERS", _artyOrdersPlanned, true];
		};
	} forEach MCSS_REMOTE_ARTILLERY_ARRAY;

	if (_canNotFire) exitWith {
		hint "ARTILLERY PROBLEM: SOME GUNS ARE NOT IN RANGE";
	};
};

if !(_canNotFire) then {
	hint "";

	//-- Comms: REQUESTING SUPPORT.
	player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];

	[_artyLeader] spawn {
		params ["_artyLeader"];

		sleep (3 + (random 2));
		_artyLeader customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];
	};

	// _artyOrdersCurrent carries data for executed strikes of MULTIPLE vehicles.
	// We now cycle through those orders and reference them to existing orders.
	{
		//-- This step checks for pre-existing orders. If none exist, we add the management event handlers.
		sleep random 2;

		_x params ["_vehicle", "_pos", "_magType", "_shellAmount"];

		//-- Slightly messy: determine if this is first or added order. Manage accordingly.
		private _artyOrdersPlanned = _vehicle getVariable ["A3C_ARTY_ORDERS", []];
		private _currentOrder = [_pos, _magType, _shellAmount]; //-- current order in format of "A3C_ARTY_ORDERS" variable.
		private _ordersPreExist = _artyOrdersPlanned - [_currentOrder];

		if (_ordersPreExist isEqualTo []) then {
			//-- No orders exist: distribute management event handlers.
			private _spread = if (_shellAmount > 7) then {random 50} else {1};

			//-- Problem: we only want one "SPLASH" message for the first shell per order.
			//-- We need extra EH because later we cannot identify the order index.

			_vehicle setVariable ["A3C_ARTY_TARGETPOS", _pos, true];

			private _splashHandler = _vehicle addEventHandler [
				"FIRED",
				{
					params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

					_vehicle removeEventHandler [_thisEvent, _thisEventHandler];

					private _targetPos = _vehicle getVariable ["A3C_ARTY_TARGETPOS", []];

					if (_targetPos isNotEqualTo []) then {
						private _artyShellETA = _vehicle getArtilleryETA [_targetPos, _magazine];
						_artyShellETA = _artyShellETA max 0;

						private _commsOperator = gunner _vehicle;

						[_artyShellETA, _commsOperator] spawn {
							//-- SPLASH only relates to the first shell.
							params ["_artyShellETA", "_commsOperator"];

							sleep ((_artyShellETA - 7) max 0);
							_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAccomplishedSGArty"];
						};
					};

					_vehicle setVariable ["A3C_ARTY_TARGETPOS", nil, true];
				}
			];

			private _eventHandlers = _vehicle getVariable ["A3C_ARTY_EH", []];
			private _ehFired = -1;
			private _ehReloaded = -1;

			if (_eventHandlers isEqualTo []) then {
				_ehFired = _vehicle addEventHandler [
					"FIRED",
					{
						params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

						_vehicle setVariable ["A3C_ARTY_LAST", time, true];

						//-- Security: remove all remaining orders if gun stops shooting.
						[_vehicle] spawn {
							params ["_vehicle"];

							sleep 15;

							private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST", nil];
							private _shouldClearOrders = !isNil "_lastShot" && {
								(time - _lastShot) > 14 && {
									private _artyOrders = _vehicle getVariable ["A3C_ARTY_ORDERS", []];
									_artyOrders isNotEqualTo []
								}
							};

							if (_shouldClearOrders) then {
								//-- Remove EHs.
								private _artyEventHandlers = _vehicle getVariable ["A3C_ARTY_EH", []];

								if (_artyEventHandlers isNotEqualTo []) then {
									_artyEventHandlers params ["_firedHandlerData", "_reloadedHandlerData"];

									_vehicle removeEventHandler [_firedHandlerData select 0, _firedHandlerData select 1];
									_vehicle removeEventHandler [_reloadedHandlerData select 0, _reloadedHandlerData select 1];
								};

								//-- Reset main orders var.
								_vehicle setVariable ["A3C_ARTY_ORDERS", nil, true];

								//-- Reset current order var.
								_vehicle setVariable ["A3C_ARTYORDER_CURRENT", nil, true];

								//-- Remove last fired var.
								_vehicle setVariable ["A3C_ARTY_LAST", nil, true];

								//-- Delete EH object namespace var.
								_vehicle setVariable ["A3C_ARTY_EH", nil];

								//-- Radio feedback: ROUNDS COMPLETE.
								private _commsOperator = gunner _vehicle;

								[_vehicle] call A3C_ai_highCommand_fnc_addArtyToRadioChannel;

								_commsOperator spawn {
									sleep (1 + (random 2));
									_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
								};
							};
						};

						private _artyOrders = _vehicle getVariable ["A3C_ARTY_ORDERS", []];

						private _orderCurrent = _vehicle getVariable ["A3C_ARTYORDER_CURRENT", []];
						_orderCurrent params ["_currentFirePos", "_currentFireMag", "_currentShellAmount"];

						if (_currentFireMag == _magazine) then {
							_currentShellAmount = (_currentShellAmount - 1) max 0;

							if (_currentShellAmount > 0) then {
								//-- Current order not yet complete.
								//-- Remove shot from current order.
								_vehicle setVariable ["A3C_ARTYORDER_CURRENT", [_currentFirePos, _currentFireMag, _currentShellAmount], true];

								//-- Remove shot from main variable.
								{
									_x params ["_firePos", "_magType", "_orderCount"];

									if (_magType == _magazine) exitWith {
										//-- Assumption: last shot will always be from current order.
										_x set [2, _orderCount - 1];
									};
								} forEach _artyOrders; //-- Note: just using (_artyOrders select 0) does not work if one mag type is used in multiple orders.
							} else {
								//-- Current order complete: move to next or delete variables.

								//-- Remove order from main variable.
								_artyOrders = _artyOrders - [_orderCurrent];

								if (_artyOrders isEqualTo []) then {
									//-- No more orders: remove EHs.
									_vehicle removeEventHandler [_thisEvent, _thisEventHandler];

									private _artyEventHandlers = _vehicle getVariable ["A3C_ARTY_EH", []];

									if (_artyEventHandlers isNotEqualTo []) then {
										_artyEventHandlers params ["_firedHandlerData", "_reloadedHandlerData"];

										_vehicle removeEventHandler [_reloadedHandlerData select 0, _reloadedHandlerData select 1];
									};

									//-- MAIN var will be reset after the current parenting if statement is completed.

									//-- Reset current order var.
									_vehicle setVariable ["A3C_ARTYORDER_CURRENT", nil, true];

									//-- Remove last fired var.
									_vehicle setVariable ["A3C_ARTY_LAST", nil, true];

									//-- Delete EH object namespace var.
									_vehicle setVariable ["A3C_ARTY_EH", nil];

									//-- Radio feedback: ROUNDS COMPLETE.
									private _commsOperator = gunner _vehicle;

									[_vehicle] call A3C_ai_highCommand_fnc_addArtyToRadioChannel;

									_commsOperator spawn {
										sleep (1 + (random 2));
										_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
									};
								} else {
									//-- Still more orders lined up.
									private _nextOrder = _artyOrders select 0;
									_nextOrder params ["_nextTargetPos", "_nextMagType", "_nextShellAmount"];

									_vehicle setVariable ["A3C_ARTYORDER_CURRENT", _nextOrder, true];

									[_vehicle, [_nextTargetPos getPos [5, random 360], _nextMagType, _nextShellAmount]] remoteExec ["commandArtilleryFire", _vehicle];
								};
							};
						};

						_vehicle setVariable ["A3C_ARTY_ORDERS", _artyOrders];
					}
				];

				//-- ISSUE: commandArtilleryFire gets cancelled if the vehicle reloads. We add a reloaded EH that reissues remaining arty orders.
				_ehReloaded = _vehicle addEventHandler [
					"RELOADED",
					{
						params ["_vehicle", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];

						_newMagazine = _newMagazine select 0;
						_oldMagazine = if (isNil "_oldMagazine" || {_oldMagazine isEqualTo []}) then {
							"rndm"
						} else {
							_oldMagazine select 0
						};

						private _artyOrders = _vehicle getVariable ["A3C_ARTY_ORDERS", []];

						if (_newMagazine == _oldMagazine) then {
							//-- Canceled orders due to reload >> engine bug: reissue remaining artillery orders.
							private _targetPos = [];
							private _shellAmount = 0;

							{
								_x params ["_firePos", "_magType", "_orderCount"];

								if (_magType == _oldMagazine) then {
									_targetPos = _firePos; //-- Will use last one. Note: will not matter once orders are made stackable.
									_shellAmount = _shellAmount + _orderCount;
								};
							} forEach _artyOrders;

							if (_targetPos isNotEqualTo []) then {
								[_vehicle, [_targetPos getPos [5, random 360], _oldMagazine, _shellAmount]] remoteExec ["commandArtilleryFire", _vehicle];
							};
						} else {
							//-- Vehicle changed mags.
						};
					}
				];

				_vehicle setVariable [
					"A3C_ARTY_EH",
					[
						["FIRED", _ehFired],
						["RELOADED", _ehReloaded]
					]
				];
			};

			_vehicle setVariable ["A3C_ARTYORDER_CURRENT", _currentOrder, true];

			[_vehicle, [_pos getPos [_spread, random 360], _magType, _shellAmount]] remoteExec ["commandArtilleryFire", _vehicle];

			//-- Safety: if unit does not react to order, delete variables.
			_vehicle setVariable ["A3C_ARTY_LAST", time, true]; //-- Precaution to be sure to have a reference.

			[_vehicle, _splashHandler, _ehFired, _ehReloaded] spawn {
				params ["_vehicle", "_splashHandler", "_ehFired", "_ehReloaded"];

				sleep 15;

				private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST", nil];
				private _shouldClearOrders = !isNil "_lastShot" && {
					(time - _lastShot) > 14 && {
						private _artyOrders = _vehicle getVariable ["A3C_ARTY_ORDERS", []];
						_artyOrders isNotEqualTo []
					}
				};

				if (_shouldClearOrders) then {
					//-- Remove EHs.
					private _artyEventHandlers = _vehicle getVariable ["A3C_ARTY_EH", []];

					if (_artyEventHandlers isNotEqualTo []) then {
						_artyEventHandlers params ["_firedHandlerData", "_reloadedHandlerData"];

						_vehicle removeEventHandler [_firedHandlerData select 0, _firedHandlerData select 1];
						_vehicle removeEventHandler [_reloadedHandlerData select 0, _reloadedHandlerData select 1];
					};

					//-- Reset main orders var.
					_vehicle setVariable ["A3C_ARTY_ORDERS", nil, true];

					//-- Reset current order var.
					_vehicle setVariable ["A3C_ARTYORDER_CURRENT", nil, true];

					//-- Remove last fired var.
					_vehicle setVariable ["A3C_ARTY_LAST", nil, true];

					//-- Delete EH object namespace var.
					_vehicle setVariable ["A3C_ARTY_EH", nil];

					//-- Radio feedback: ROUNDS COMPLETE.
					private _commsOperator = gunner _vehicle;

					[_vehicle] call A3C_ai_highCommand_fnc_addArtyToRadioChannel;

					_commsOperator spawn {
						sleep (1 + (random 2));
						_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYCannotExecuteAdjustCoordinates"];
						hint "hint: sometimes vehicles become unresponsive. Try to move the vehicle(s) a bit and make sure that they face the target";
					};

					//-- Remove splash handler.
					_vehicle removeEventHandler ["FIRED", _splashHandler];
				};
			};
		};
	} forEach _artyOrdersCurrent;
};