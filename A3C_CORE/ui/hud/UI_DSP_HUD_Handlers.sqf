


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

	if ([_key] call A3C_UI_Shared_blockKeyDownEvent) exitWith {};
	
	//-- RADIAL-ACTIONS
	if 
	(
		A3C_AI_HighCommand_Action_ID != ""
		&& {_key == 57} //-- SpaceBar
	) exitWith {
		//-- Confirm Action (#TODO - create dedicated function to save space)
		private _script = 0;


		

		switch (A3C_AI_HighCommand_Action_ID) do {
			case ("TANKSHOT") : {
				[] call A3C_AI_HighCommand_Action_remoteFire_TankShot;
			};
			case ("VTOL_CANNON") : {
				_script = ["CANNON"] spawn A3C_AI_HighCommand_Action_remoteFire_VTOL_Weapon;
			};
			case ("VTOL_GATLING") : {
				_script = ["GATLING"] spawn A3C_AI_HighCommand_Action_remoteFire_VTOL_Weapon;
			};
			case ("VTOL_AUTOCANNON") : {
				_script = ["AUTOCANNON"] spawn A3C_AI_HighCommand_Action_remoteFire_VTOL_Weapon;
			};

			case ("UGLSHOT") : { // #TODO: change velocity for UGLshots to a faster speed
				[] call A3C_AI_HighCommand_Action_remoteFire_UGLshot;
			};
			case ("ATSHOT") : {
				[] call A3C_AI_HighCommand_Action_remoteFire_ATshot;
			};
			case ("STATICSHOT") : {
				[] call A3C_AI_HighCommand_Action_remoteFire_StaticRocketShot;
			};


			
	
		};
		[_script] spawn {
			params ["_script"];
			if (typeName _script == "CODE") then {
				waitUntil {scriptDone _script};
			};
			private _flickerScript = [A3C_UI_HUD_3D_TAG_ICON_POS,'SUPPRESSION'] spawn A3C_UI_HUD_3D_TAG;
			waitUntil {scriptDone _flickerScript};
			[] call A3C_AI_HighCommand_Action_CancelPositionalProcess;
		};
		true
	};


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
			&& {_key in [200,203,205,208]}
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

	if (player != (leader group player)) exitWith {false};
	if ( !isNull(findDisplay 312) ) exitWith {false}; //-- ZEUS interface is open. Prevent most A3C stuff
	
	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

	if (_key == A3C_RadialMenu_KEY_ID select 0) exitWith {
		A3C_DISABLE_RADIAL = false;
		{inGameUISetEventHandler [_x, 'true']} foreach ['PrevAction','NextAction'];
		if (A3C_AI_HighCommand_Action_ID != "") then {
			[] call A3C_AI_HighCommand_Action_CancelPositionalProcess;
		};
	};

	switch (true) do {
		case 
		(
			a3c_is_HC_remote
			&& {_key in [200,203,205,208]}
		) :
		{
				_this call A3C_UI_SHARED_onKeyUp_remoteVehicle;
		};
		case (
			vehicle player isKindOf "HELICOPTER"
			&& {player == (gunner vehicle player)}
		) : {
			//#TODO: Why should this fire on EVERY keyup? 
			[] spawn A3C_UI_HUD_onKeyUp_heliGunner;	
		};
		
	};

	false
	
};





//-- HUD Main "MouseButtonDown"
A3C_UI_HUD_onMouseButtonDown = {
	params ["_display","_mouseButton","_sX","_sY","_shift","_ctrl", "_alt"];

	scopeName "main";

	// player commandChat format ["A3C_UI_HUD_onMouseButtonDown: %1", _this];

	private _curTar = cursorTarget;
	private _blockDefaultKey = false;

	if (A3C_DISABLE_RADIAL) exitWith {false}; //-- disable MB because user-action is expected from radial

	if (_mouseButton == 1) then {
		if (_ctrl) then {
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
		} else {
			//-- Regular RMB click

			//-- Cancel GTI-Grenade (Player)
			if (BR_A3C_GRENADEMODE && {A3C_GTI_UNIT == player}) then {
				A3C_GTI_UNIT = objNull;
				BR_A3C_GRENADEMODE = false;
				["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
			};
		};	
	};
	_blockDefaultKey
};



//-- HUD Main "MouseButtonDown" 
//#TODO: Clean up!
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

	private _exit = false;
	{
		if (!isnull _x) then {
			_exit = true;
			showCommandingMenu "";
			private _pos = position _x;
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
	if ((count A3C_HUD_UnitIndicators) == 0 && {isNull A3C_OBJECTPLACER}) exitWith {false};

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

// A3C_UI_HUD_onMouseMoving = { //-- placeholder for 3d draw movement
// 	params ["_display", "_xDeltaPos", "_yDeltaPos"];
// 	hint str _this;
// };






//---------------------------------------------------------------------------------------------
//---------- EH's FOR ADDITIONAL HUD ELEMENTS -------------------------------------------------
//---------------------------------------------------------------------------------------------



//------------------- OBJECT SELECTOR BINDS

A3C_UI_HUD_ObjectSelector_onKeyUp = {
	params ["_display", "_key"];
	// systemchat 'A3C_UI_HUD_ObjectSelector_onKeyUp';
	if (_key == (A3C_RadialMenu_KEY_ID select 0)) then {
		A3C_DISABLE_RADIAL = false;
		//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
		//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
		(findDisplay 100060) closeDisplay 0;
		A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];
		{player groupSelectUnit [_x,false]} foreach units player;
		showCommandingMenu "";
		A3C_UI_RADIAL_Current_Remfire_Units = [];
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";

		// //-- clarify if this is needed??
		// if ((count A3C_HUD_UnitIndicators) > 0) then {
		// 	{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];
		// } else {
		// 	{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
		// };
		{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
	};
};


//------------------- HUD MENU BINDS
//-- reminder: HUD_Menu split into visual and dialog, by default SHIFT makes UI interactive

A3C_UI_HUD_HudMenu_onKeyDown = {
	params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	private _refKey = ((['A3C', 'A3C_KeyFnc_Hud_Order_Reg'] call CBA_fnc_getKeybind) select 5) select 0;
	if (_refKey == _key) then {
		[false,false] spawn A3C_Setorder_HUD;
		_display closeDisplay 0;
	};
};

A3C_UI_HUD_HudMenu_onKeyUp = {
	params ["_display", "_key"];
	if (_key == (A3C_HUD_MENU_KEY_ID select 0)) then {
		_display closeDisplay 0;
		showCommandingMenu "";		
		if (profilenamespace getvariable ['A3C_HUD_MENUSHOW_VAR',true]) then {
			if !(profileNamespace getVariable 'A3C_HUD_isOpen') then {
				[] call A3C_HUD_OPEN_MENU;
			};
		} else {
			("A3C_HUD_MENU_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
			profileNamespace setVariable ['A3C_HUD_isOpen',false];
		};		
	};
};
