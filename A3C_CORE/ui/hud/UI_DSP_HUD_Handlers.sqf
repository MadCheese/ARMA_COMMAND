//---------------------------------------  HANDLER-FUNCTIONS  ------------------------------------
//------------------------------------------------------------------------------------------------
//-- HUD Main "KeyDown"
A3C_UI_HUD_onKeyDown = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	//-- exit if keystroke is not allowed
	if (_key == 1) exitWith {false}; //-- nothing should happen if ESC is pressed
	if !(player isEqualTo leader group player) exitWith {false};
	if !(isNull findDisplay 312) exitWith {false}; // ZEUS interface is open
	if (_alt && {_key == 15}) exitWith {// safety if user alt-tabs out of the game
		A3C_UI_DOWNKEYS = [];
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

	if ([_key] call A3C_UI_Shared_shouldBlockKeyRepeat) exitWith {};

	private _keyControlsMap = (inputAction "showMap") > 0;

	if !(_keyControlsMap) then {
		[_key] call A3C_UI_Shared_FNC_AddDownkey;
		A3C_LASTUSED_KD = time;
	};

	player sideChat format["HUD KEY-DOWN: %1 (%2)",_key, keyname _key];

	if (inputAction "revealTarget" > 0) then {
		// reveal target
		[cameraOn, screenToWorld [0.5, 0.5]] call MCSS_fnc_RevealCursorPos;
	};

	private _blockDefaultKey = nil;

	switch (true) do {
		
		case (_keyControlsMap) : {
			
			//-- Safety precaution: clear downkeys while player opens map
			//-- Hud's keyUp will NOT fire once map is entered.
			A3C_UI_DOWNKEYS = [];

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

		case 
		(
			a3c_is_HC_remote
			&& {_key in [17,30,31,32,200,203,205,208]}
		) :
		{
			_this call A3C_UI_SHARED_onKeyDown_remoteVehicle;
			_blockDefaultKey = true;
		};



		//-- Player is remote-controling UAV 'gunner' : 'W' and "Up  Arrow' can make UAV
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
			_this call A3C_UI_HUD_onKeyDown_heliGunner;
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

		case (
			//-- NUM-key check
			profileNamespace getVariable "A3C_NUM_VAR"
			&& {
				_key in  [71, 72, 73, 75, 76, 77, 79, 80, 81,103, 104, 105, 106];
			}
		) : {
			[_key] call A3C_UI_HUD_onKeyDown_NUM;
		};
		default {};
	};

	if (count A3C_HUD_UNITS == 0) then {
		A3C_MODIFIER_LOCK = false;
	};

	if (isNil '_blockDefaultKey') then {
		_blockDefaultKey = [_key, [_shift, _ctrl, _alt]] call A3C_GET_KEY_BOOL; //<< #Clarify: is there a cleaner way here?
	};
	_blockDefaultKey
};


//-- HUD Main "KeyUp"
A3C_UI_HUD_onKeyUp = {
	params ["_display", "_key"];
	
	player commandchat format ["HUD KEY-UP: %1 (%2)", _key, keyName _key];

	if (player != (leader group player)) exitwith {false};
	if ( !isNull(findDisplay 312) ) exitWith {false}; //-- ZEUS interface is open. Prevent most A3C stuff
	
	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

	if (_key == A3C_RadialMenu_KEY_ID select 0) then {
		A3C_DISABLE_RADIAL = false;
	};

	switch (true) do {
		case 
		(
			a3c_is_HC_remote
			&& {_key in [17,30,31,32,200,203,205,208]}
		) :
		{
				_this call A3C_UI_SHARED_onKeyUp_remoteVehicle;
		};
		case (
			vehicle player isKindOf "HELICOPTER"
			&& {player == (gunner vehicle player)}
		) : {
				(vehicle player) spawn {
				sleep 1;
				_this flyInHeight((getPosATL _this) select 2);
			};
		};
		
	};

	false
	
};





//-- HUD Main "MouseButtonDown"
A3C_UI_HUD_onMouseButtonDown = {
	params ["_display","_button","_sX","_sY","_shift","_ctrl", "_alt"];

	scopeName "main";

	player commandChat format ["A3C_UI_HUD_onMouseButtonDown: %1", _this];

	private _curTar = cursorTarget;
	private _blockDefaultKey = false;

	if (A3C_DISABLE_RADIAL) exitWith {
		if (_button == 1 && {!isNil "A3C_GRENADEHANDLER"}) then {
			A3C_DISABLE_RADIAL = false;
			["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
			(findDisplay 46) displayRemoveEventHandler ["MouseButtonUP", A3C_GRENADEHANDLER];
		};
		false
	};

	if (_button == 1 && {_ctrl}) then {
		if (a3c_is_HC_remote) then {
			_this call A3C_UI_SHARED_OnMouseButtonDown_remoteVehicle;
		} else {
			if (count A3C_HUD_UNITS > 0) then {
				[_alt, _shift] call A3C_Setorder_HUD;
				_blockDefaultKey = true;
			} else {
				if (!isNull _curTar) then {
					if (_curTar in units group player) then {
						if (_alt) then {
							_blockDefaultKey = true;
							if (_curTar in A3C_HUD_UNITS) then {
								[_curTar] call A3C_HUD_REMOVE_SELECTED;
							} else {
								[_curTar, _curTar getVariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
								
								if (count groupSelectedUnits player > 0) then {
									{ player groupSelectUnit [_x, false] } forEach units group player;
								};
							};
							breakOut "main";
						} else {
							if (count A3C_HUD_UNITS == 0) then {
								_blockDefaultKey = true;

								if (_curTar in groupSelectedUnits player) then {
									player groupSelectUnit [_curTar, false];
								} else {
									player groupSelectUnit [_curTar, true];
								};

								if (count groupSelectedUnits player == 0) then {
									showCommandingMenu "";
								};
								breakOut "main";
							};
						};	
					};

					if (count groupSelectedUnits player == 0) then {
						showCommandingMenu "";
					};
				} else {
					if (!(_ctrl) && {count A3C_HUD_UnitIndicators > 0}) then {
						{ [_x] call A3C_HUD_REMOVE_SELECTED } forEach +A3C_HUD_UNITS;
					};
				};
			};
		};	
	};
	_blockDefaultKey
};



//-- HUD Main "MouseButtonDown"
//~~ NOTE: RE WRITE ALL THESE DOUBLE FUNCTIONS INTO SINGLE ONES
A3C_UI_HUD_onMouseZChanged = {

	// systemchat format ["A3C_UI_HUD_onMouseZChanged: %1", _this];

	private _ctrl = 29 in A3C_UI_DOWNKEYS;
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

	if (_ctrl) exitWith {
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