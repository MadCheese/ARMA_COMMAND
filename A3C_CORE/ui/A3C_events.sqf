
if (isDedicated) exitwith {};

//----------------------------------  K E Y -  A N D  M O U S E B I N D S  -----------------------


//-- HUD Main "KeyDown"


//--------------------------------------------  UI-HELPER FUNCTIONS  -----------------------------
//------------------------------------------------------------------------------------------------

//-- Function to return a flat array of keys that are bound to given inputAction
//-- Currently unused but could end up useful.
A3C_fnc_flattenNumericLeaves = {
	params ["_value"];
	private _out = [];

	if (_value isEqualType 0) exitWith {
		[_value]
	};

	if (_value isEqualType []) then {
		{
			_out append ([_x] call A3C_fnc_flattenNumericLeaves);
		} forEach _value;
	};

	_out
};

//---------------------------------------  HANDLER-FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------

A3C_UI_HUD_HandlerFNC_KeyDown = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	//-- exit if keystroke is not allowed
	if (_key == 1) exitWith {false}; //-- nothing should happen if ESC is pressed
	if !(player isEqualTo leader group player) exitWith {false};
	if !(isNull findDisplay 312) exitWith {false}; // ZEUS interface is open
	if (_alt && {_key == 15}) exitWith {// safety if user alt-tabs out of the game
		A3C_MODIFIER_CTRL = false;
		A3C_DOWNKEYS = [];
		false
	};

	//-- allowed
	if (
		A3C_IsTAO
		&& {
			private _taoBind = (["Tao Folding Map", "toggle"] call CBA_fnc_getKeybind) select 5;
			_taoBind isEqualTo [_key, [_shift, _ctrl, _alt]]
		}
	) exitWith {
		false
	};	
	private _isNewKey = !(_key in A3C_DOWNKEYS);
	if (_isNewKey) then {


		private _keyControlsMap = (inputAction "showMap") > 0;

		if !(_keyControlsMap) then {
			A3C_DOWNKEYS set [count A3C_DOWNKEYS, _key];
			A3C_LASTUSED_KD = time;
		};

		player sideChat format["HUD KEY-DOWN: %1 (%2)",_key, keyname _key];

		
		if (inputAction "revealTarget" > 0) then {
			// reveal target
			[cameraOn, screenToWorld [0.5, 0.5]] call MCSS_fnc_RevealCursorPos;
		};

		switch (true) do {
			
			case (_keyControlsMap) : {
				
				//-- Safety precaution: clear downkeys while player opens map
				//-- Hud's keyUp will NOT fire once map is entered.
				A3C_DOWNKEYS = [];

				private _keyIsNotGPS = (inputAction "miniMapToggle") == 0;
				if (
					_keyIsNotGPS
					&& {profileNamespace getVariable "A3C_MAP_OVERLAY_SHOWN"}
				) then {
					// open map / overlay
					A3C_WeaponCurr = currentWeapon player;
					nul = [100020] execVM "A3C_CORE\ui\MapOverlay\UI_DSP_MAP_OpenOverlay.sqf";

					private _groupUnits = (units group player) - [player];
					if (count _groupUnits > 0) then {
						if (({(_x == driver vehicle _x) && {typeOf vehicle _x isKindOf "AIR"}} count _groupUnits) >= ((count _groupUnits) / 2)) then {
							A3C_MAP_CommandMode = "AIR";
						} else {
							A3C_MAP_CommandMode = "INF";
						};
					} else {
						A3C_MAP_CommandMode = "HC";
					};

					A3C_SELECTED_UNITS = [];
				};
			};
			case (
				!(a3c_is_HC_remote)
				&& {_key in [17, 200]}
				&& {unitIsUAV cameraOn}
				&& {(remoteControlled (driver cameraOn)) != player}
			) : {
				//-- UAV Gunner > W and Up Arrow make driver move to looket-at position
				private _driver = driver cameraOn;
				[_driver, screenToWorld [0.5, 0.5]] remoteExec ["doMove", _driver];
			};
			case (
				//-- Purposely AFTER the uav check, since UAV's can be helicopters
				player isEqualTo gunner vehicle player
				&& {currentPilot vehicle player != player} 
				&& {vehicle player isKindOf "HELICOPTER"}
			) : {
				// Helicopter gunner bonus controls
				private _flareKeysArray = actionKeys "launchCM";
				private _raiseCollectiveKeysArray = actionKeys "HeliCollectiveRaise";
				private _lowerCollectiveKeysArray = actionKeys "HeliCollectiveLower";
				private _handled = false;
				private _atlHeight = (getPosATL vehicle player) select 2;

				// countermeasures
				if ({_x in A3C_DOWNKEYS} count _flareKeysArray == count _flareKeysArray) then {
					if (behaviour driver vehicle player == "CARELESS") then {
						private _wpnsTurret = vehicle player weaponsTurret [-1];

						{
							private _weapon = _x;
							private _mags = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");

							{
								private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
								private _aiUsageFlags = getNumber (configFile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");

								if (_aiUsageFlags == 8) then {
									private _mode = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) select 0;
									(driver vehicle player) forceWeaponFire [_weapon, _mode];
								};
							} forEach _mags;
						} forEach _wpnsTurret;

						[vehicle player] call A3C_Evasive;
						_handled = true;
					};
				};

				// raise collective
				if (!_handled && {{_x in A3C_DOWNKEYS} count _raiseCollectiveKeysArray == count _raiseCollectiveKeysArray}) then {
					A3C_DOWNKEYS = A3C_DOWNKEYS - [_key];
					vehicle player flyInHeight (_atlHeight + 20);
					_handled = true;
				};

				// lower collective
				if (!_handled && {{_x in A3C_DOWNKEYS} count _lowerCollectiveKeysArray == count _lowerCollectiveKeysArray}) then {
					vehicle player flyInHeight (_atlHeight - 20);
					A3C_DOWNKEYS = A3C_DOWNKEYS - [_key];
					_handled = true;
				};

				// rotate / rudder
				if (!_handled && {speed vehicle player < 25} && {_key in [203, 205, 30, 32]}) then {
					private _twist = if (_key in [205, 32]) then {0.5} else {-0.5};
					vehicle player setDir (getDir vehicle player + _twist);
					A3C_DOWNKEYS = A3C_DOWNKEYS - [_key];
					// _handled = true; // -- NOTE: uncomment this if you happen to add any more mechanics here
				};
			};
			case (
				!isNil "A3C_FORM_KEY_ID"
				&& {[_key, _shift, _ctrl, _alt] isEqualTo A3C_FORM_KEY_ID}
			) : {
				[] call A3C_UI_CustomFormation_FNC_spawnDialog;
			};
			//-- #NOTE: Commented this out until I understand what F1-F5 were supposed to do with teamcolors
			//-- F1-F5 are unit selectors by default...
			// case (_key in [59, 60, 61, 62, 63]): { //-- F1-F5
			// 	// refresh teamColor var
			// 	if (player == cameraOn) then {
			// 		[] spawn {
			// 			sleep 0.3;
			// 			{
			// 				private _assignedTeam = assignedTeam _x;
			// 				private _assignedTeamVar = _x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"];
			// 				if (_assignedTeam != _assignedTeamVar) then {
			// 					_x setVariable ["A3C_ASSIGNEDTEAM", _assignedTeam];
			// 				};
			// 			} forEach ((units player) - [player]);
			// 		};
			// 	};
			// };
			case (_key == 29) : {
				A3C_MODIFIER_CTRL = true;
			};
			case (
				//-- NUM-key check
				profileNamespace getVariable "A3C_NUM_VAR"
				&& {
					_key in  [71, 72, 73, 75, 76, 77, 79, 80, 81,103, 104, 105, 106];
				}
			) : {
				[] call A3C_UI_HUD_HandlerFNC_KeyDown_NUM;
			};
			default {};
		};

		if (count A3C_HUD_UNITS == 0) then {
			A3C_MODIFIER_LOCK = false;
		};
	};

	private _blockDefaultKey = [_key, [_shift, _ctrl, _alt]] call A3C_GET_KEY_BOOL;
	_blockDefaultKey
};


//-- HUD Main "KeyUp"
A3C_UI_HUD_HandlerFNC_KeyUp = {
	params ["_display", "_key"];
	
	player commandchat format ["HUD KEY-UP: %1 (%2)", _key, keyName _key];

	if !(player == (leader group player)) exitwith {};
	if ( !isNull(findDisplay 312) ) exitWith {}; //-- ZEUS interface is open. Prevent most A3C stuff
	
	A3C_DOWNKEYS = A3C_DOWNKEYS - [_key];
	if (vehicle player isKindOf "HELICOPTER" && {player == (gunner vehicle player)}) then {
		[] spawn {sleep 1; (vehicle player) flyInHeight((getPosATL (vehicle player)) select 2)};
	};
	if (_key == 29) exitwith {
		A3C_MODIFIER_CTRL = false;
	};
	//-- protection: also set SHIFT to false?
};






A3C_UI_HUD_HandlerFNC_MouseButtonDown = {
	private ["_bttn","_shft","_alt","_ctrl","_divisor","_exit"];
	_bttn = (_this select 1);
	_shft = (_this select 4);
	_ctrl = (_this select 5);
	_alt = (_this select 6);

	//if (!isNull A3C_OBJECTPLACER && _bttn == 1) exitWith {
	//	deleteVehicle A3C_OBJECTPLACER;
		//BR_A3C_DISABLE_RADIAL = false;
	//};




	_exit = false;




	_curTar = cursorTarget;

	if (BR_A3C_DISABLE_RADIAL) exitwith {
		if (_bttn == 1) then {
			if (!isNil 'A3C_GRENADEHANDLER') then {
				BR_A3C_DISABLE_RADIAL = false;
				["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
				(findDisplay 46) displayRemoveEventHandler ["MouseButtonUP",A3C_GRENADEHANDLER];
			};
		};
	};
	//if ((count A3C_HUD_UNITS) == 0) exitwith {};
	if (_bttn == 1) then {
		if !(isnull _curTar) then {
			if (_curTar in (units group player)) then {
				if (_ctrl) then {
					_exit = true;
					if (_alt) then {
						if (_curTar in A3C_HUD_UNITS) then {
							[_curTar] call A3C_HUD_REMOVE_SELECTED;
						} else {
							[_curTar,_curTar getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
							if ((count (groupSelectedUnits player)) > 0) then {
								{player groupSelectUnit [_x, false]} foreach units group player;
							};
						};
					} else {
						if ( (count A3C_HUD_UNITS) == 0) then {
							if (_curTar in (groupSelectedUnits player)) then {
								player groupSelectUnit [_curTar, false];
							} else {
								player groupSelectUnit [_curTar, true];
							};
						} else {
							_exit = false;
						};
					};
				};
			};
			if ((count (groupSelectedUnits player)) == 0) then {
				showCommandingMenu "";
			};
		} else {
			//systemchat "remove from select";

			if !(A3C_MODIFIER_CTRL) then {
				if ((count A3C_HUD_UnitIndicators) > 0) then {
					{[_x] call A3C_HUD_REMOVE_SELECTED} foreach A3C_HUD_UNITS;
					//systemchat "cancelled";
				};
			};

		};
	};
	if (_exit) exitwith {};
	_unitAmount = (count A3C_HUD_UNITS);
	if (_unitAmount == 0) exitwith {};

	//-- Execute HUD-Order (Ctrl + RMB)
	if (_bttn == 1) then {
		if (_ctrl) then {
			[_alt,_shft] call A3C_Setorder_HUD;
		};
	};
};



// Wheel
//~~ NOTE: RE WRITE ALL THESE DOUBLE FUNCTIONS INTO SINGLE ONES
A3C_UI_HUD_HandlerFNC_MouseZChanged = {
	private _return = false;
	if (!isNull A3C_GTI_UNIT) exitWith {
		if ((_this select 1) > 0) then {
			BR_A3C_TACV_throwTheta_Add = BR_A3C_TACV_throwTheta_Add + 1;
		} else {
			BR_A3C_TACV_throwTheta_Add = BR_A3C_TACV_throwTheta_Add - 1;
		};
		BR_A3C_TACV_throwTheta_Add = BR_A3C_TACV_throwTheta_Add max 0.01;
		BR_A3C_TACV_throwTheta_Add = BR_A3C_TACV_throwTheta_Add min 89.99;
		true
	};
	//systemchat str _this;
	_pos = 0;
	private _exit = false;
	{
		if (!isnull _x) then {
			_exit = true;
			showCommandingMenu "";
			_pos = position _x;
			if ((_this select 1) > 0) then {
				A3C_SUPPRESSIONHEIGHT = A3C_SUPPRESSIONHEIGHT + 0.2;
			} else {
				if ((_pos select 2) > 0) then {
					A3C_SUPPRESSIONHEIGHT = A3C_SUPPRESSIONHEIGHT - 0.2;
				};
			};
		};
	} foreach [A3C_SUPPRESSION_INDICATOR,A3C_SQ_REM_INDICATOR,A3C_HC_REM_INDICATOR];
	if (_exit) exitWith {true};
	if ((count A3C_HUD_UnitIndicators) == 0 && {isNull A3C_OBJECTPLACER}) exitwith {false};

	if ( A3C_MODIFIER_CTRL) exitWith {
		if (A3C_HUD_FORM == 7) then {
			if ((_this select 1)  > 0) then {
				A3C_HUD_RADIUS = A3C_HUD_RADIUS + 1;
			} else {
				A3C_HUD_RADIUS = A3C_HUD_RADIUS - 1;
			};
			if (A3C_HUD_RADIUS < A3C_HUD_RADIUS_MIN) then {A3C_HUD_RADIUS = A3C_HUD_RADIUS_MIN};
		} else {
			if ((_this select 1)  > 0) then {
				A3C_HUD_SPACING = A3C_HUD_SPACING + 1;
			} else {
				A3C_HUD_SPACING = A3C_HUD_SPACING - 1;
			};
			if (A3C_HUD_SPACING < 2) then {A3C_HUD_SPACING = 2};
		};
		true
	};

	A3C_FORMATION_DIR = [A3C_FORMATION_DIR] call MCSS_fnc_CorrectDir;

	_factor = 1;

	_speed = (_this select 1);
	if (_speed < 0) then {_speed = (_speed * -1)};
	switch (true) do {
		case (_speed == 1.2) : {_factor = 1};
		case (_speed == 2.4) : {_factor = 5};
		case (_speed >= 3.6) : {_factor = 25};
	};

	if (!isNull A3C_OBJECTPLACER) exitWith {
		//systemchat str _factor;

		if ((_this select 1) < 0 ) then {
			A3C_OBJECTPLACER_DIR = A3C_OBJECTPLACER_DIR - (1 *_factor);
		} else {
			A3C_OBJECTPLACER_DIR = A3C_OBJECTPLACER_DIR + (1 *_factor);
		};
		true
	};


	if ((_this select 1) < 0 ) then {

		if (A3C_HUD_FORM == 7) then {
			A3C_360_out = true;
		} else {
			_factor = (_factor * -1);
		};


	} else {

		if (A3C_HUD_FORM == 7) then {
			A3C_360_out = false;
		};
	};

	A3C_HUD_Snap_DIR = [A3C_HUD_Snap_DIR] call MCSS_fnc_CorrectDir;
	if !(A3C_HUD_Snap) then {A3C_FORMATION_DIR = A3C_FORMATION_DIR + _factor;};

	A3C_SCROLLTIME = time;
	A3C_FORMATION_DIR = [A3C_FORMATION_DIR] call MCSS_fnc_CorrectDir;
	true
};



//---------------------------------  OTHER KEYBIND FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------

A3C_FNC_UAV_KEY = {
	params ["_eventType","_props"];
	_props params ["_display","_key","_shift","_ctrl","_alt"];
	private _playerHasTerminal = {getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "type") == 621} count (assignedItems player) > 0;
	if !(_playerHasTerminal) exitWith {
		hint "YOU HAVE NO UAV TERMINAL";
	};
	
	if (!(_ctrl) && {isNull (getConnectedUAV player)}) exitWith {
		["DOWN",[_display,_key,false, true,false]] spawn A3C_FNC_UAV_KEY;
	};
	
	// A3C_LAST_USED_UAV = if (isUnitUAV cameraOn) then {cameraOn} else {objNull};

	A3C_getSideName = {
		params ["_sideNumber"];
		private _sideName = switch (_sideNumber) do {
			case 0 : {EAST};
			case 1 : {WEST};
			case 2 : {resistance};
			case 3 : {civilian};
			default {"UNKNOWN"};
		};
		_sideName
	};

	if (_ctrl) then {
		
		private _playerSide = side player;
		private _uavWhitelist = allUnitsUAV select
		{
			private _isAvailable = isNull ((UAVControl _x) select 0);

			_isAvailable && {
				private _uavSideNumber = getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side");
				private _uavSide = [_uavSideNumber] call A3C_getSideName;
				private _isFriendly = _playerSide == _uavSide;
				_isFriendly
			}
		};

		

		[_uavWhitelist] spawn
		{
			disableSerialization;
			params ["_uavs"];

			if (_uavs isEqualTo []) exitWith {
				systemChat "No connectable UAVs found.";
			};

			// Close previous instance if it exists
			private _oldDisplay = uiNamespace getVariable ["TAG_UAV_PICKER_DISPLAY", displayNull];
			if (!isNull _oldDisplay) then {
				_oldDisplay closeDisplay 1;
			};

			private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
			uiNamespace setVariable ["TAG_UAV_PICKER_DISPLAY", _display];

			private _count = count _uavs;

			// Compact centered layout
			private _w = 0.34;
			private _rowH = 0.032;
			private _pad = 0.006;
			private _titleH = 0.04;
			private _closeH = 0.03;
			private _iconW = 0.028;

			private _visibleRows = (_count max 1);
			private _h = _titleH + (_visibleRows * _rowH) + ((_visibleRows + 1) * _pad) + _closeH + _pad;

			private _posX = safeZoneX + safeZoneW * 0.5 - (_w * 0.5);
			private _posY = safeZoneY + safeZoneH * 0.5 - (_h * 0.5);

			// Background
			private _bg = _display ctrlCreate ["RscText", 1000];
			_bg ctrlSetPosition [_posX, _posY, _w, _h];
			_bg ctrlSetBackgroundColor [0, 0, 0, 0.8];
			_bg ctrlCommit 0;

			// Title
			private _title = _display ctrlCreate ["A3C_RscText", 1001];
			_title ctrlSetPosition [_posX + _pad, _posY + _pad, _w - (2 * _pad), _titleH - _pad];
			_title ctrlSetText format ["Available UAVs (%1)", _count];
			_title ctrlSetBackgroundColor [0.85, 0.40, 0.00, 1.00];
			_title ctrlSetTextColor [1, 1, 1, 1];
			_title ctrlSetFontHeight 0.035;
			// _title ctrlSetTextAlignment "center";
			_title ctrlCommit 0;

			// Entries
			{
				private _uav = _x;
				private _ctrlIDC = 1100 + _forEachIndex;
				private _picIDC = 2100 + _forEachIndex;
				private _rowY = _posY + _titleH + _pad + (_forEachIndex * _rowH);

				uiNamespace setVariable [format ["TAG_UAV_PICKER_%1", _ctrlIDC], _uav];

				private _name = getText (configFile >> "CfgVehicles" >> typeOf _uav >> "displayName");
				private _grp = group driver _uav;
				private _grpText = if (isNull _grp) then {"NO GROUP"} else {groupId _grp};
				private _label = format ["%1 (%2)", _name, _grpText];
				private _flyinHeight = round ((getPos _uav) select 2);
				private _labelHeight = if (_flyinHeight == 0) then {""} else {format [" - %1m", _flyinHeight]};
				_label = _label + _labelHeight;

				private _picPath = getText (configFile >> "CfgVehicles" >> typeOf _uav >> "picture");
				if (_picPath isEqualTo "") then {
					_picPath = getText (configFile >> "CfgVehicles" >> typeOf _uav >> "icon");
				};

				// Icon background
				private _iconBg = _display ctrlCreate ["RscText", 3000 + _forEachIndex];
				_iconBg ctrlSetPosition [_posX + _pad, _rowY, _iconW, _rowH - _pad];
				_iconBg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.8];
				_iconBg ctrlCommit 0;

				// Icon picture
				private _pic = _display ctrlCreate ["RscPicture", _picIDC];
				_pic ctrlSetPosition [_posX + _pad + 0.001, _rowY + 0.001, _iconW - 0.002, (_rowH - _pad) - 0.002];
				if !(_picPath isEqualTo "") then {
					_pic ctrlSetText _picPath;
				};
				_pic ctrlCommit 0;

				// Button
				private _btn = _display ctrlCreate ["RscButton", _ctrlIDC];
				_btn ctrlSetPosition [_posX + _pad + _iconW + _pad, _rowY, _w - (3 * _pad) - _iconW, _rowH - _pad];
				_btn ctrlSetText _label;
				_btn ctrlSetTooltip "LMB - CONNECT / RMB - CONNECT AND CONTROL";
				_btn ctrlCommit 0;

				_btn ctrlAddEventHandler ["MouseButtonDown", {
					disableSerialization;
					params ["_ctrl", "_button"];

					private _uav = uiNamespace getVariable [format ["TAG_UAV_PICKER_%1", ctrlIDC _ctrl], objNull];
					if (isNull _uav) exitWith {
						systemChat "UAV lookup failed.";
						(ctrlParent _ctrl) closeDisplay 1;
						true
					};

					private _name = getText (configFile >> "CfgVehicles" >> typeOf _uav >> "displayName");

					switch (_button) do {
						case 0: {
							// systemChat format ["LMB on %1 | obj=%2", _name, _uav];
							[_uav, 0] spawn A3C_ConnectUAV;
							(ctrlParent _ctrl) closeDisplay 1;
						};
						case 1: {
							// systemChat format ["RMB on %1 | obj=%2", _name, _uav];
							[_uav, 1] spawn A3C_ConnectUAV;
							(ctrlParent _ctrl) closeDisplay 1;
						};
					};

					true
				}];
			} forEach _uavs;

			// Close button
			private _close = _display ctrlCreate ["RscButton", 1999];
			_close ctrlSetPosition [_posX + _pad, _posY + _h - _closeH, _w - (2 * _pad), _closeH - _pad];
			_close ctrlSetText "Close";
			_close ctrlCommit 0;
			_close ctrlAddEventHandler ["ButtonClick", {
				(ctrlParent (_this select 0)) closeDisplay 1;
			}];
		};


	} else {
		
		if !(unitIsUAV cameraOn) then {
			//-- Take UAV control
			[] spawn A3C_TakeUAVControl
		} else {
			//-- Release UAV control
			player switchCamera "Internal";
		};
	};


	

};





//-- Main CBA Keybind
//-- input: example ["SHIFT","DOWN",_buttonData]

A3C_HUD_DRAW_BOOL = false;
A3C_HUD_DRAW_POSARRAY = [];

A3C_PREVENT_DOUBLE_EXEC = [];


A3C_FNC_CBA_KEY = {
	private ["_btn","_refPos"];
	//systemchat 'cba';
	//if (true) exitWith {};
	_function = _this select 0;
	_mode = _this select 1;
	_btnData = if (count _this > 2) then {(_this select 2)} else {0};
	_btn = 0;
	_unitNumber = if ((count _this) > 2) then {_this select 2} else {objNull};
	_unit = objnull;
	_targetUnits = [];
	_refPos = [];
	

	if (player != (units player select 0) ) exitwith {}; // && {!([player] call A3C_isUnconscious)}//-- #NOTE: seems incomplete. this could enable keybind when player is not


	if ( !isNull(findDisplay 312) ) exitWith {}; //-- ZEUS interface is open. Prevent most A3C stuff
	switch (_function) do {
		case ("HUD_DRAW") : {
			if (_mode == "DOWN") then {
				if ((count groupSelectedUnits player) == 1) then {
					A3C_HUD_DRAW_SHOWNHUD = shownHud;
					_newHud = +(shownHud);
					_newHUD set [0,false];
					//showhud _newHUD;
					A3C_HUD_DRAW_Action = player addaction
					[
						"",
						{
							//systemchat "fire disabled";
						},
						"",
						0,
						false,
						true,
						"DefaultAction"
					];
					A3C_HUD_DRAW_EH_MM = (findDisplay 46) displayAddEventHandler
					[
						"mouseMoving",
						{
							if (A3C_HUD_DRAW_BOOL) then {
								private _unit = (groupSelectedUnits player) select 0;
								private _vehicle = vehicle _unit;
								private _pos = [player,objNull] call MCSS_fnc_posIntersect;
								if (!isNull A3C_SNAP_OBJECT) then {
									_prms = [ATLtoASL _pos,A3C_SNAP_OBJECT] call A3C_HUD_SNAP_FORMATION;
									//systemchat str [_pos,_prms];
									_pos = _prms select 0;
								};
								private _count = (count A3C_HUD_DRAW_POSARRAY);
								if (_count > 0) then {
									private _lastPos = A3C_HUD_DRAW_POSARRAY select (_count -1);
									private _variDist = switch (true) do {
										case (_vehicle isKindOf "MAN") : {2};
										case (_vehicle isKindOf "AIR") : {150};
										default {15};
									};
									private _precision = ((getNumber (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "precision")) + _variDist);
									if (_pos distance2D _lastPos > _precision) then {
										if (_pos distance2D _lastPos < 10) then {
											_pos set [2,0];
											A3C_HUD_DRAW_POSARRAY pushBack _pos;
											//playsound 'A3C_MenuSound1';
											//hint str _pos;
										};
									};
								};
							};

						}
					];
					A3C_HUD_DRAW_EH_MD = (findDisplay 46) displayAddEventHandler
					[
						"mouseButtonDown",
						{
							//systemchat str _this;
							if  (_this select 1 == 1) exitWith {};
							if ((count groupSelectedUnits player) == 1) then {
								A3C_HUD_DRAW_BOOL = true;
								_pos = [player,objNull] call MCSS_fnc_posIntersect;
								_pos set [2,0];
								A3C_HUD_DRAW_POSARRAY = [_pos];
							};

						}
					];
					A3C_HUD_DRAW_EH_MU = (findDisplay 46) displayAddEventHandler
					[
						"mouseButtonUP",
						{
							//player sidechat str _this;

							//systemchat str A3C_HUD_DRAW_POSARRAY;
							if  (_this select 1 == 1) exitWith {};
							//-- insert action
							if (!isNil 'A3C_HUD_DRAW_EH_MU') then {
								(findDisplay 46) displayRemoveEventHandler ["mouseButtonUp",A3C_HUD_DRAW_EH_MU];
								A3C_HUD_DRAW_EH_MU = nil;
							};
							if (!isNil 'A3C_HUD_DRAW_EH_MM') then {
								(findDisplay 46) displayRemoveEventHandler ["mouseMoving",A3C_HUD_DRAW_EH_MM];
								A3C_HUD_DRAW_EH_MM = nil;
							};
							if (!isNil 'A3C_HUD_DRAW_EH_MD') then {
								(findDisplay 46) displayRemoveEventHandler ["mouseButtonDown",A3C_HUD_DRAW_EH_MD];
								A3C_HUD_DRAW_EH_MD = nil;
							};
							private _unit = (groupSelectedUnits player) select 0; showCommandingMenu "";

							private _tVar = [];
							if (!isNil 'A3C_HUD_DRAW_Action') then {
								//_x getPos [50,0]
								{
									//systemchat str _foreachindex;
									private _mark = format ['A3C_Mark_P%1',A3C_MARKER_COUNT]; //[(format ['A3C_Mark_P%1',A3C_MARKER_COUNT]),_x,"ICON","mil_dot",[0.5,0.5],"","ColorWhite",1] call MCSS_fnc_createMarker;
									_mark setMarkerAlphaLocal 0.5;
									A3C_MARKERS pushBackUnique _mark;
									A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
									_tVar pushBack
									[
										[_x,[]],
										[_mark,"",""],
										["NONE","NONE"],
										["NONE","NONE"],
										["UP","UP"],
										[[0,false]],
										false,
										0,
										-1,
										0,
										-1,
										0
									];
								} foreach A3C_HUD_DRAW_POSARRAY;
								//player commandChat str _tVar;
								 _unit setVariable ["A3C_PLOT",_tVar,true];
								private _script = [_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_MOVE;
							} else {


							};

							{player groupSelectUnit [_x,false]} foreach units player;
							A3C_HUD_DRAW_BOOL = false;
							A3C_HUD_DRAW_POSARRAY = [];
						}
					];
				} else {
					A3C_HUD_DRAW_Action = nil;
				};

			} else {
				if (!isNil 'A3C_HUD_DRAW_EH_MU') then {
					(findDisplay 46) displayRemoveEventHandler ["mouseButtonUp",A3C_HUD_DRAW_EH_MU];
					A3C_HUD_DRAW_EH_MU = nil;
				};
				if (!isNil 'A3C_HUD_DRAW_EH_MM') then {
					(findDisplay 46) displayRemoveEventHandler ["mouseMoving",A3C_HUD_DRAW_EH_MM];
					A3C_HUD_DRAW_EH_MM = nil;
				};
				if (!isNil 'A3C_HUD_DRAW_EH_MD') then {
					(findDisplay 46) displayRemoveEventHandler ["mouseButtonDown",A3C_HUD_DRAW_EH_MD];
					A3C_HUD_DRAW_EH_MD = nil;
				};

				if (A3C_HUD_DRAW_BOOL) then {

					[] spawn {
						private _t = A3C_HUD_DRAW_POSARRAY;
						for "_i" from 1 to 3 do {
							A3C_HUD_DRAW_POSARRAY = [];
							sleep 0.05;
							A3C_HUD_DRAW_POSARRAY = _t;
							sleep 0.05;
						};
						A3C_HUD_DRAW_POSARRAY = [];
					};

				} else {
					{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
				};
				if (!isNil 'A3C_HUD_DRAW_Action') then {
					player removeaction A3C_HUD_DRAW_Action;
					//systemchat "fire enabled";
					//showHUD A3C_HUD_DRAW_SHOWNHUD; A3C_HUD_DRAW_SHOWNHUD = nil;
				};
				A3C_HUD_DRAW_Action = nil;
			};
		};
		case ("SUPPRESSION") : {

			if (_mode == "DOWN") then {
				if (!visibleMap && (isNull (findDisplay 100030))) then {
					if (player == (leader group player)) then {
						if !(!isNull objectParent player && cameraView == "INTERNAL") then {
							if ((count (groupSelectedUnits player)) == 0) then {
								{
									if (!isPlayer _x) then {
										player groupSelectUnit [_x,true];
									};
								} foreach ((units group player) - [player]);
							};
							if ((count (groupSelectedUnits player)) > 0) then {
								A3C_SUPPRESSION_UNITS_SQ_TEMP = (groupselectedunits player);
								{
									if (isPlayer _x) then {A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x]};
								} foreach A3C_SUPPRESSION_UNITS_SQ_TEMP;
								if ( ({_x in A3C_SUPPRESSION_UNITS_SQ_TEMP} count A3C_SUPPRESSION_UNITS_SQ) == 0) then {
									//-- spawn suppression indicator
									A3C_SUPPRESSIONHEIGHT = 0;
									A3C_SUPPRESSION_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
									A3C_SUPPRESSION_INDICATOR setObjectTextureGlobal[0,'#(argb,8,8,3)color(1,0,0,0.5)'];
									//[A3C_SUPPRESSION_INDICATOR] spawn A3C_MOVE_SUPPRESSION_INDICATOR;
								} else {
									{
										if !(_x in A3C_SUPPRESSION_UNITS_SQ) then {
											A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x];
										};
									} foreach A3C_SUPPRESSION_UNITS_SQ_TEMP;
									[A3C_SUPPRESSION_UNITS_SQ_TEMP,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
									// turn off
								};
								showCommandingMenu "";
								{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];
							};
						} else {
							systemchat "A3C: Switch camera view to order Suppression";
						};
					};
				};
			} else {
				if !(isnull A3C_SUPPRESSION_INDICATOR) then {
					//A3C_SUP_MARKER1 = [(format ['A3C_SUP_MAIN_Mark_%1',A3C_SUP_POLY_IND_MARK]),(getpos A3C_SUPPRESSION_INDICATOR),"Icon","selector_selectedMission",[1,1],"","ColorOpfor",1] call MCSS_fnc_createMarker;
					//A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
					//A3C_MARKERS pushback A3C_SUP_MARKER1;
					[A3C_SUPPRESSION_UNITS_SQ_TEMP,[(getposATL A3C_SUPPRESSION_INDICATOR),""],'SUPPRESSION',true] spawn A3C_POLY_ACTION_ON;
					deletevehicle A3C_SUPPRESSION_INDICATOR;
				};
				{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
			};
		};

		// Grenade player WTF IS THIS
		case ("GRENADE") : {
			if (_mode == "DOWN") then {
				//-- prevent grenade throw when unit is unconscious
				if !([player] call A3C_isUnconscious) then {
					//-- prevent grenade throw when planning
					if (!visibleMap && (isNull (findDisplay 100030))) then {
						//systemchat 'oi';
						BR_A3C_DISABLE_RADIAL = true;
						showCommandingMenu "";
						A3C_GREN_ALLOW_UNITSWITCH = if (count A3C_RD_UNITS == 1) then {false} else {true};
						BR_A3C_TACV_oefId = ["BR_A3C_TACV_oefId", "onEachFrame", "BR_A3C_OEFControl"] call BIS_fnc_addStackedEventHandler;
					};
				};
			} else {
				if !(A3C_BOOL_REMFIRE) then {
					_cun = ((groupselectedunits player) select 0);
					if !(isPlayer _cun) then {
						if (BR_A3C_DISABLE_RADIAL) then {
							BR_A3C_DISABLE_RADIAL = false;
							BR_A3C_TEMP_gfeh = _cun addEventHandler ["fired",
							{
								_unit = _this select 0;
								if (_this select 1 == "THROW") then {
									(_this select 6) setVelocity BR_A3C_TACV_throwVel;
								};
								if ((side _unit) == WEST) then {
									[_unit] call A3C_Gren_Phrase;
								};
								_unit removeEventHandler ["fired", BR_A3C_TEMP_gfeh];
								_add = if (BR_A3C_TACV_throwV0 <= BR_A3C_TACV_GV0MaxS) then {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd} else {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd * 2};
								_unit setFatigue ((getFatigue _unit) + _add);
							}];
							_cun forceWeaponFire ["SmokeShellMuzzle","SmokeShellMuzzle"];
							["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
						};
					};
				} else {

				};
			};
		};
		case ("LOCK") : {
			if (_mode == "DOWN") then {
				if (A3C_MODIFIER_LOCK) then {
					A3C_MODIFIER_LOCK = false;
				} else {
					A3C_MODIFIER_LOCK = true;
				};
			};
		};
		
		//-- REAL BUTTON GRENADE PLAYER
		case ("GREN_P") : {
		//systemchat str _this;
			//-- prevent grenade throw when planning
			if (!visibleMap && (isNull (findDisplay 100030))) then {

				if (_mode == "DOWN") then {

					if (count (groupselectedunits player) == 0) then {
						//-- prevent grenade throw when player is unconscious
						if !([player] call A3C_isUnconscious) then {
							[_mode] call A3C_GRENADE_PLAYER;
						};
					} else {
						_targetUnits = (groupselectedunits player);
						{
							if (isPlayer _x) then {
								_targetUnits = _targetUnits - [_x];
							};
						} foreach _targetUnits;
						A3C_BOOL_REMFIRE = true;
						//-- remove units if they do not have GL, reAdd them if they do have AT.
						//-- this is to make sure that at this point, GL is preferred over AT.
						//-- if the unit has GL and AT, he will later prefer AT
						{
							_targetUnits = _targetUnits - [_x];
							if ( ( count (getArtilleryAmmo [vehicle _x]) > 0) && {_x == (gunner vehicle _x)}) then {
								if !(_x in _targetUnits) then {
									_targetUnits = [_x] + _targetUnits;
								};
							};
							if ([_x] call A3C_HasGL) then {
								_targetUnits pushBackUnique _x;
							};
							if ([_x] call A3C_HasAT) then {
								_targetUnits pushBackUnique _x;
							};
							if ((vehicle _x isKindOf "TANK") && {_x == (gunner vehicle _x)}) then {
								_targetUnits pushBackUnique _x;
							};


						} foreach _targetUnits;

						if ((count _targetUnits) > 0) then {

							A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = _targetUnits;
							A3C_SQ_REM_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
							A3C_SQ_REM_INDICATOR setObjectTextureGlobal[0,'#(argb,8,8,3)color(1,1,0,0.5)'];
							//[A3C_SQ_REM_INDICATOR] spawn A3C_MOVE_SUPPRESSION_INDICATOR;
							showCommandingMenu "";
						};
					};
				} else {
					if (A3C_BOOL_REMFIRE) then {
						A3C_BOOL_REMFIRE = false;
						if !(isnull A3C_SQ_REM_INDICATOR) then {



							A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units,getPosASL A3C_SQ_REM_INDICATOR] call A3C_UI_SHARED_FIND_BEST_SHOOTERS;
							if ((count A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units) > 0) then {
								[A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units select 0,(getposASL A3C_SQ_REM_INDICATOR),"FIND"] spawn A3C_ORDER_REMOTE_LAUNCH;
							};
							A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [];
							deletevehicle A3C_SQ_REM_INDICATOR;
						};
					} else {
						[_mode] call A3C_GRENADE_PLAYER;
					};
				};
			};
		};
		case ("HC_REMOTE") : {
			//--Shorten this!!! merge with gren_p
			if (_mode == "DOWN") then {
				if !(A3C_HC_FocusGroup isEqualTo grpNull) then {
					_targetUnits = units A3C_HC_FocusGroup;
					{
						if (isPlayer _x) then {
							_targetUnits = _targetUnits - [_x];
						};
					} foreach _targetUnits;
					A3C_BOOL_REMFIRE = true;
					//-- remove units if they do not have GL, reAdd them if they do have AT.
					//-- this is to make sure that at this point, GL is preferred over AT.
					//-- if the unit has GL and AT, he will later prefer AT
					{
						_targetUnits = _targetUnits - [_x];
						if ( ( count (getArtilleryAmmo [vehicle _x]) > 0) && {_x == (gunner vehicle _x)}) then {
							if !(_x in _targetUnits) then {
								_targetUnits = [_x] + _targetUnits;
							};
						};
						if ([_x] call A3C_HasGL) then {
							_targetUnits pushBackUnique _x;
						};
						if ([_x] call A3C_HasAT) then {
							_targetUnits pushBackUnique _x;
						};
						if ((vehicle _x isKindOf "TANK") && {_x == (gunner vehicle _x)}) then {
							_targetUnits pushBackUnique _x;
						};
						if (([vehicle _x] call A3C_isStaticMissileLauncher) && {_x == (gunner vehicle _x)}) then {
							_targetUnits pushBackUnique _x;
						};
					} foreach _targetUnits;

					if ((count _targetUnits) > 0) then {
						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = _targetUnits;
						A3C_HC_REM_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
						A3C_HC_REM_INDICATOR setObjectTextureGlobal[0,'#(argb,8,8,3)color(0,0.3,0.6,0.5)'];
						//[A3C_HC_REM_INDICATOR] spawn A3C_MOVE_SUPPRESSION_INDICATOR;
						showCommandingMenu "";
					};
				} else {
					systemchat "A3C: No HC-focus group selected!";
				};
			} else {

				if (A3C_BOOL_REMFIRE) then {
					A3C_BOOL_REMFIRE = false;
					if !(isnull A3C_HC_REM_INDICATOR) then {
						{
							if (isNull objectParent _x) then {
								_refPos = _x getRelPos [((_x distance A3C_HC_REM_INDICATOR) - 10),(_x getRelDir A3C_HC_REM_INDICATOR)];
								if (lineintersects [eyepos _x,_refPos,_x,objnull]) then {
										A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units - [_x];
								};
							} else {
								_vehPos = getPosASL (vehicle _x);
								_vehPos set [2,(_vehPos select 2) + 1.8];
								_refPos = _vehPos getPos [((_x distance A3C_HC_REM_INDICATOR) - 10),(_x getRelDir A3C_HC_REM_INDICATOR)];
								//-- take away units with no LOS
								if (lineintersects [_vehPos,_refPos,_x,(vehicle _x)]) then {
									if (count (getArtilleryAmmo [vehicle _x]) == 0) then {
										A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units - [_x];
									};
								};
								if (count A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units == 0) then {systemchat "A3C: No shot on target"};
							};
						} foreach A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units;
						if ((count A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units) > 0) then {
							[A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units select 0,(getposASL A3C_HC_REM_INDICATOR),"FIND"] spawn A3C_ORDER_REMOTE_LAUNCH;
						};
						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [];
						deletevehicle A3C_HC_REM_INDICATOR;
					};
				};
			};
		};
		case ("HC_SUPPRESS") : {
			//--Shorten this!!! merge with gren_p
			if (_mode == "DOWN") then {
				if !(A3C_HC_FocusGroup isEqualTo grpNull) then {
					_targetUnits = units A3C_HC_FocusGroup;
					if !({_x in A3C_SUPPRESSION_UNITS_AI} count _targetUnits > 0) then {
						{
							if (isPlayer _x) then {
								_targetUnits = _targetUnits - [_x];
							};
						} foreach _targetUnits;
						A3C_BOOL_REMFIRE_SUP = true;

						if ((count _targetUnits) > 0) then {
							A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = _targetUnits;
							A3C_HC_SUP_INDICATOR = "MCSS_ASM_SUPRESSION_INDICATOR_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
							A3C_HC_SUP_INDICATOR setObjectTextureGlobal[0,'#(argb,8,8,3)color(0.73,0.47,0.7,0.5)'];
							//[A3C_HC_REM_INDICATOR] spawn A3C_MOVE_SUPPRESSION_INDICATOR;
							showCommandingMenu "";
						};
					} else {
						_currentlySuppressingUnits = [];
						{
							if (_x in A3C_SUPPRESSION_UNITS_AI) then {
								_currentlySuppressingUnits pushBackUnique _x;
							};
						} foreach (units A3C_HC_FocusGroup);
						if (count _currentlySuppressingUnits > 0) then {
							[_currentlySuppressingUnits,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
						};
						//systemchat "A3C: Selection is already suppressing! Please adjust polygon (overriding currently not possible)";
					};
				} else {
					systemchat "A3C: No HC-focus group selected!";
				};
			} else {
				if (A3C_BOOL_REMFIRE_SUP) then {
					A3C_BOOL_REMFIRE_SUP = false;
					_currentlySuppressingUnits = [];
					{
						if (_x in A3C_SUPPRESSION_UNITS_AI) then {
							_currentlySuppressingUnits pushBackUnique _x;
						};
					} foreach A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units;
					if (count _currentlySuppressingUnits > 0) then {
						[_currentlySuppressingUnits,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
					};

					if !(isnull A3C_HC_SUP_INDICATOR) then {

						if ((count A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units) > 0) then {
							[A3C_HC_FocusGroup,(getpos A3C_HC_SUP_INDICATOR)] call A3C_HC_Suppression_Immediate;
						};
						A3C_UI_SPPRSSN_FCS_RMT_Current_Remfire_Units = [];
						deletevehicle A3C_HC_SUP_INDICATOR;
					};
				};
			};
		};
		case ("FORM") : {
			if (_mode == "DOWN" && !visibleMap) then {
				if (isnil "A3C_FORM_KEY_ID") then {
					[] spawn {
						hint "initialized...please repeat";
						sleep 5;
						hint "";
					};
				};
					A3C_FORM_KEY_ID = [(_btnData select 1),(_btnData select 2),(_btnData select 3),(_btnData select 4)];
					//[] call A3C_UI_CustomFormation_FNC_spawnDialog;
					setMousePosition [0.5, 0.5];

			};
		};
		case ("MAP") : {
			//-- This bind controls the toggle of the map-overlay. 
			profilenamespace setvariable ["A3C_MAP_KEY_ID",[(_btnData select 1),[(_btnData select 2),(_btnData select 3),(_btnData select 4)]]];
			if !(A3C_MAP_BOOL_CT_EDIT_ACTIVE) then  {
				if (visibleMap) then {
					if (_mode == "DOWN") then {
						if (isnull (findDisplay 100020)) then {
							profilenamespace setvariable ["A3C_MAP_OVERLAY_SHOWN",true];
							A3C_OPACITY = 0.8;
							nul = [100020] execVM "A3C_CORE\ui\MapOverlay\UI_DSP_MAP_OpenOverlay.sqf";

						} else {
							A3C_OPACITY = 0;
							[] spawn {
								sleep 0.1;
								(findDisplay 100020) closeDisplay 2;
								A3C_SELECTED_UNITS = [];
								{_x setvariable ["A3C_PLOT_TEMP",[],true];} foreach units group player;
								profilenamespace setvariable ["A3C_MAP_OVERLAY_SHOWN",false];
							};
						};
					};
				};
			};
		};
		case ("ZEUS") : {
			selectplayer A3C_ZEUS_UNIT;
		};
		case ("HUD") : {
			if (commandingMenu == "" && !visibleMap) then {
				if ((count (groupSelectedUnits player)) == 0) then {
					if ((typeName _unitNumber) == "STRING") then {
						_targetUnits = (profileNamespace getvariable "A3C_GROUPUNITS") - [player];
						if !(_unitNumber == "ALL") then {
							{
								private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
								if (_assignedTeam != _unitNumber) then {
									_targetUnits = _targetUnits - [_x];
								};
								if (isPlayer _x) then {
									_targetUnits = _targetUnits - [_x];
								};
							} foreach _targetUnits;
						};

						if ((count A3C_HUD_UNITS) == 0) then {
							{
								[_x,_x getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
							} foreach _targetUnits;
						} else {
							//- bug prevention
							if (_unitNumber == "ALL") then {
								terminate A3C_HUD_L;
							};
							//- remove units from selection
							//_targetUnits spawn {
								{
									if (alive _x) then {
										[_x] call A3C_HUD_REMOVE_SELECTED;
										//sleep 0.001;

									};
								} foreach _targetUnits;
							//};
						};

					} else {
						_unit = (profileNamespace getvariable "A3C_GROUPUNITS") select (_unitNumber - 1);
						if ( (count A3C_SELECTED_UNITS) == 0 ) then {
							A3C_HUD_FORM = 0;
							A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";;
							A3C_HUD_FORM_ICON_COLOR = [0,0,0,0.2];
							A3C_HUD_FORM_ICON_SIZE = 0.8;
						};
						if (!isPlayer _unit) then {
							if (_unit in A3C_HUD_UNITS) then {
								[_unit] call A3C_HUD_REMOVE_SELECTED;
							} else {
								if (alive _unit) then {
									[_unit,_unitNumber] call A3C_HUD_ADD_SELECTED;
								};
							};
						};
					};
					//systemchat str commandingmenu;
					[] spawn {sleep 0.1; showCommandingMenu "";};
				};
			};
		};
		case ("ORDER_REG") : {
			//systemchat str _btnData;
			profilenamespace setvariable ["A3C_ORDER_REG_KEY_ID",[(_btnData select 1),[(_btnData select 2),(_btnData select 3),(_btnData select 4)]]];

		};
		case ("ORDER_FW") : {
			profilenamespace setvariable ["A3C_ORDER_FW_KEY_ID",[(_btnData select 1),[(_btnData select 2),(_btnData select 3),(_btnData select 4)]]];

		};
		case ("GoCode_A") : {
			['A'] call A3C_ACTIVATEGOCODE;
		};
		case ("GoCode_B") : {
			['B'] call A3C_ACTIVATEGOCODE;
		};
		case ("GoCode_C") : {
			['C'] call A3C_ACTIVATEGOCODE;
		};
		case ("GoCode_D") : {
			['D'] call A3C_ACTIVATEGOCODE;
		};

		case ("COMMAND_LEVEL") : {
			// systemchat str time;
			if (count A3C_HC_getAllGroups_Player_Current > 0 OR {[player] call A3C_isUnconscious}) then {
				{player groupSelectUnit [_x,false]} foreach (units player - [player]);
				showCommandingMenu "";
				A3C_RD_UNITS = [];
				_shownHud = +(shownHud);

				if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
					A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
					_shownHud set [6,A3C_SHOWNHUD];
				} else {
					A3C_CURRENT_COMMAND_LEVEL = "HIGHCOMMAND";
					A3C_SHOWNHUD = _shownHud select 6;
					_shownHud set [6,false];

				};
				showHud _shownHud;
				if (!isNull findDisplay 100040) then {
					[A3C_CURRENT_COMMAND_LEVEL] call A3C_UI_RADIAL_LABEL_INNER_RING;
					//[] call A3C_RD_LABEL_SELECTORS;
				};
			} else {
				A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
			};

		};


		case ("Voice_Medic_All") : {
			A3C_RD_UNITS = ((units player) - [player]);
			{
				if (isPlayer _x) then {A3C_RD_UNITS = A3C_RD_UNITS - [_x]};
			} foreach A3C_RD_UNITS;
			private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
			_group setVariable ["A3C_MEDICS", _medics];

			(group player) setVariable ["A3C_MEDICS_LB", _medics];
			_patients = [group player] call A3C_FINDPATIENTS;
			(group player) setVariable ["A3C_PATIENTS_LB", _patients];
			[group player, 0] spawn A3C_MEDICAL_START;
		};
		case ("Voice_AUTOCOMBAT") : {
			[(groupSelectedUnits player)] spawn A3C_TOGGLEDANGER;
		};
		case ("Voice_REFRESH") : {
			[(units group player) - [player]] call A3C_GROUP_RESET;
		};
		case ("Voice_LookDir") : {
			{_x lookAt objNull; _x doTarget objNull} foreach (groupSelectedUnits player);
		};
		case ("Voice_Stance_Auto") : {
			A3C_HUD_STANCE_MODE_TRAVEL = 3;
			//A3C_HUD_STANCE_FINAL = "AUTO";
			[] call A3C_HUD_SETSTANCE;
		};
		case ("Voice_Stance_STAND") : {
			A3C_HUD_STANCE_MODE_TRAVEL = 2;
			//A3C_HUD_STANCE_FINAL = "STAND";
			[] call A3C_HUD_SETSTANCE;
		};
		case ("Voice_Stance_CROUCH") : {
			A3C_HUD_STANCE_MODE_TRAVEL = 1;
			//A3C_HUD_STANCE_FINAL = "CROUCH";
			[] call A3C_HUD_SETSTANCE;
		};
		case ("Voice_Stance_PRONE") : {
			A3C_HUD_STANCE_MODE_TRAVEL = 0;
			//A3C_HUD_STANCE_FINAL = "PRONE";
			[] call A3C_HUD_SETSTANCE;
		};
		case ("Voice_Stance_NOCHANGE") : {
			A3C_HUD_STANCE_MODE_TRAVEL = 4;
			//A3C_HUD_STANCE_FINAL = "";
			[] call A3C_HUD_SETSTANCE;
		};
		case ("Voice_Hold") : {
			(groupSelectedUnits player) call A3C_UNIT_HOLD;
		};
		case ("Voice_Cont") : {
			(groupSelectedUnits player) call A3C_UNIT_CONTINUE;
		};
		case ("Voice_Unload") : {
			systemchat format ["%1:'GET OUT!'",name player];
			private _vehicle = vehicle player;

			if (!isNull objectParent player) then {
				if (player == driver _vehicle) then {
					//-- find other groups (cargo groups)
					private _dismountGroups = [];
					{
						_gp = group _x;
						if (_gp != group player) then {
							if ([_gp,player] call A3C_isCargoGroupEjectable) then { //-- only add groups to dismount groups if some of it's units are cargo!!
								_dismountGroups pushBackUnique _gp;
							};
						} else {
							if ([_x, _vehicle] call A3C_isCargoUnitEjectable) then {
								// //unassignVehicle _x;
								// //_x leaveVehicle _vehicle;
								// unassignVehicle _x;
								// doGetOut _x;
								[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
							};
						};
					} foreach (crew _vehicle);
					{
						_dismountingGroup = _x;
						[_dismountingGroup, vehicle player] remoteExec ["leaveVehicle", leader _dismountingGroup];
					} foreach _dismountGroups;

				};
			};
		};

	};
};

//--------------------------------------------  UI-FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------


//-- determine if keyBind returns true or false (overwrite yes or no)
A3C_GET_KEY_BOOL = {
	private ["_key","_modifiers","_return","_array"];
	_key = _this select 0;
	_modifiers = _this select 1;
	_return = false;
	//systemchat str _key;

	if (_key in [71,72,73,75,76,77,79,80,81]) then {
		if (profileNameSpace getVariable "A3C_NUM_VAR") then {
			_return = true;
		};
	};


	//systemchat 'trigger bool';


	//_array =
	if !(isnil "A3C_FORM_KEY_ID") then {
		if ( ([_key] + _modifiers) isEqualTo A3C_FORM_KEY_ID ) then {
			_return = true;
			//systemchat 'oi';
		};
	};

	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_REG_KEY_ID") ) then {
		if (count A3C_HUD_UnitIndicators> 0 ) then {
			_return = true;
			[false,false] spawn A3C_Setorder_HUD;

		} else {
			if (!isNull A3C_OBJECTPLACER) then {
				_return = true;
			};
		};
	};
	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_FW_KEY_ID") ) then {
		if (count A3C_HUD_UnitIndicators> 0 ) then {
			_return = true;
			[false,true] spawn A3C_Setorder_HUD;
			//systemchat 'fwd';
		};

	};
	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_BW_KEY_ID") ) then {

		if (count A3C_HUD_UnitIndicators> 0 ) then {
			//systemchat 'bwd';
			[true,false] spawn A3C_Setorder_HUD;
		};
	};
	if (_key == 57) then {
		if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "" OR {count A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS > 0 OR {!isNull A3C_GTI_UNIT}}) then {
			_return = true;
		};
	};
//systemchat str _key;
	_return
};


//--------------------------------------------  UI-FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------

A3C_Setorder_HUD = {
	params ["_alt","_shft"];
	private ["_arrow","_activeUnits","_movingUnits","_storeData","_dest","_runningOrder","_delay","_timeOut","_counter","_exit","_exitLoop"];
	_arrow = 0;
	_activeUnits = [];
	_movingUnits = [];
	_storeData = [];
	_dest = [];
	_runningOrder = "ASCEND";
	_delay = false;
	_timeOut = 0;
	_counter = 0;
	_exit = false;
	_exitLoop = false;
	{
		if (isNull _x) then {A3C_HUD_UNITS = A3C_HUD_UNITS - [_x]};
	} foreach A3C_HUD_UNITS;

	if (({_x getvariable "A3C_PEEL_ACTIVE"} count A3C_HUD_UNITS) > 0) then {
		{_x setvariable ["A3C_PEEL_ACTIVE",false,false]} foreach A3C_HUD_UNITS;
		sleep 0.1;
		waituntil {(({_x getvariable "A3C_PEEL_ACTIVE"} count A3C_HUD_UNITS) > 0)};
	};
	if (_alt || _shft) then {
		{_x setvariable ["A3C_PEEL_ACTIVE",true,false]} foreach A3C_HUD_UNITS;
	} else {
		{_x setvariable ["A3C_PEEL_ACTIVE",false,false]} foreach A3C_HUD_UNITS;
	};
	A3C_PEEL_ACTIVE = true;

 	
	 
	//-- take data from arrows
	{
		//if (_x in A3C_ROE3_UNITS) then {
		//	//-- security for FireOnMyLead
		//	[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
		//};

		_arrow = ((_x getvariable 'A3C_HUD_DATA') select 0);
		_storeData pushback [_x,(_arrow getvariable "A3C_ARROW_BPOS"),(getposATL _arrow),(getdir _arrow)];

	} foreach A3C_HUD_UNITS;


	
	if (_alt) then {
		_runningOrder = "DESCEND";
		_delay = true;
		_timeout = 2;
		A3C_PEELING = true;
	};
	if (_shft) then {
		_runningOrder = "ASCEND";
		_delay = true;
		_timeout = 2;
		A3C_PEELING = true;
	};

	_storeData = [_storeData,[],{(_x select 0) distance (A3C_HUD_UnitIndicators select 0)},_runningOrder] call BIS_fnc_sortBy;
	{_movingUnits pushback (_x select 0)} foreach _storeData;

	
	


	//-- remove indicators or spawn blink 
	if (profilenamespace getvariable ['A3C_HUD_MENUOVERRIDE_VAR',true]) then {
		//-- hide UI 
		terminate A3C_HUD_L; //-- terminate positioning loop
		{deletevehicle _x} foreach A3C_HUD_UnitIndicators;
		{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
		A3C_HUD_UNITS = [];
		A3C_HUD_UnitIndicators= [];
		//['A3C_HUD_ICONS', "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		("A3C_HUD_MENU_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
		profileNamespace setVariable ['A3C_HUD_isOpen',false];
		{_x hideobject true} foreach A3C_HUD_UnitIndicators;
		{_x setvariable ["A3C_HUD_DATA",[],true]} foreach A3C_HUD_UNITS;
		
	} else {
		playsound 'A3C_MenuSound1';
		{
			_x spawn {
				for "_i" from 1 to 3 do {
					_this hideobject true;
					sleep 0.1;
					_this hideobject false;
					sleep 0.1;
				};
			};
		} foreach A3C_HUD_UnitIndicators;
	};

	

	//-- this is the bit that can take time, so we execute it after data is fetched
	if (profilenamespace getvariable ["A3C_HUD_MENUOVERRIDE_VAR",true])then {
		{
			if ( (count (_x getvariable "A3C_PLOT")) > 0 ) then {
				_activeUnits pushback _x;
				//sleep 0.1;
			};
			//[((_x getvariable 'A3C_HUD_DATA') select 1), "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		} foreach A3C_HUD_UNITS;


		[_activeUnits,true,false] call A3C_CANCELPLANS;
		while {({(count(_x getvariable "A3C_PLOT")) > 0} count _activeUnits) > 0} do {sleep 0.1};
	};

	// spawn moving function
	
	
	

	




	//systemchat str _storeData;
	{
		//if ((count((_x select 0) getvariable "A3C_PLOT")) == 0) then {
			if (_alt) then {
				(_x select 0) disableAI "AUTOTARGET";
				(_x select 0) dotarget objnull;
			};
			_x pushback A3C_HUD_FORM;
			_x spawn A3C_HUD_MOVE;
		//};
		if (_timeout > 0) then {
			sleep 0.1;
			_dest = ((expectedDestination (_x select 0)) select 0);
			while {true} do {
				if !((_x select 0) getvariable "A3C_PEEL_ACTIVE") exitwith {
					_exit = true;
					(_x select 0) setvariable ["A3C_PEEL_ACTIVE",true,false];
				};
				if (_forEachIndex <= ((count _storeData) - 2)) then {
					if (_alt) then {
						//systemchat str [((_x select 0) distance ((_storeData select ((count _storeData)  -1)) select 2) ),( ((_storeData select ((count _storeData)  -1) ) select 0) distance ((_storeData select ((count _storeData)  -1)) select 2)  ) ];
						if ( ((_x select 0) distance (_x select 2)) < 5) then {
							_exitLoop = true;
						};
					};
					if (_shft) then {
						if ( ((_x select 0) distance ((_storeData select 0) select 0) ) < ( ((_storeData select (_forEachIndex + 1) ) select 0) distance ((_storeData select 0) select 0) ) ) then {
							_exitLoop = true;
						};
					};
				} else {
					_exitLoop = true;
				};
				if !(alive (_x select 0)) then {_exitLoop = true};
				if ((count((_x select 0) getvariable "A3C_PLOT")) > 0) then {_exitLoop = true};
				//hint str (((expectedDestination (_x select 0)) select 0) distance _dest);
				if ((((expectedDestination (_x select 0)) select 0) distance _dest) > 1) then {_exitLoop = true};
				if (currentcommand (_x select 0) == "STOP") then {_exitLoop = true;};
				if (_exitLoop) exitwith {
					_exitLoop = false;
					(_x select 0) setvariable ["A3C_PEEL_ACTIVE",false,false];
					_movingUnits = _movingUnits - [(_x select 0)];
					(_x select 0) disableAI "AUTOTARGET";
				};
				sleep 0.1;
			};
		};
		if (_exit) exitwith {};
		_counter = 1;
		while {_counter < (_timeout / 0.1)} do {
			if (({!(_x getvariable "A3C_PEEL_ACTIVE")} count _movingUnits) > 0) exitwith {};
			sleep 0.1;
			_counter = _counter +1;
		};
		(_x select 0) setvariable ["A3C_PEEL_ACTIVE",false,false];
		//sleep 0.1;
	} foreach _storeData;
	A3C_HUD_FORM = 0;
	A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
	A3C_HUD_FORM_ICON_COLOR = [0,0,0,0.2];
	A3C_HUD_FORM_ICON_SIZE = 0.8;
};







