//---------------------------- SHARED POSITIONAL STARTUP FUNCTION
A3C_AI_SHARED_Action_StartPositionalProcess = { //-- THIS MIGHT BE REQUIRED TO BE USED MY SQUAD -LEVEL TOO: IF SO, RENAME AND MOVE
	params ["_isBusy", "_actionID", "_iconType","_iconColor","_objectPlacerClass", "_objectPlacerColorString"];
	
	if (_isBusy) exitWith {
		systemchat 'A3C: Plase wait for your last order to complete';
	};
	//-- UI-Reaction
	A3C_DISABLE_RADIAL = true;
	[] call A3C_UI_RADIAL_CloseDisplay;

	{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu '';

	//-- Positional UI 
	A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
	A3C_UI_HUD_3D_TAG_ICON_COL = [_iconColor,0.7] call A3C_UI_fnc_setOpacity;
	A3C_UI_HUD_3D_TAG_reposition = true;

	if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
		A3C_AI_Squad_Action_ID = _actionID;
	} else {
		A3C_AI_HighCommand_Action_ID = _actionID;
	};
	

	//-- Spawn object placer
	if (_objectPlacerClass != "") then {
		
		private _placer = _objectPlacerClass createvehicleLocal [0,0,100]; //
		_placer allowdamage false;
		_placer enableSimulation false;
		_placer disableCollisionWith player;
		_placer hideObject true;
		private _safePos = ([screenToWorld [0.5,0.5],[0,100]] call MCSS_fnc_getSafePos);
		if (!isNil '_safePos' && {count _safePos > 0}) then {
			_placer setpos _safePos;
		};
		_placer disableCollisionWith cursortarget;
		//-- Color Object
		if (_objectPlacerColorString != "") then {
			private _colorStringFinal = "#(rgb,8,8,3)color" + _objectPlacerColorString;
			for "_i" from 0 to 10 do {
				_placer setObjectTexture [0, _colorStringFinal];
			};
		};

		_placer spawn { //-- spawn because we need the slight delay
			sleep 0.2;
			_this hideObject false;
			A3C_OBJECTPLACER = _this; //-- naming delay is necessary so object does not get moved by HUDdraw script immediately to be destroyed
			
		};
	};
};


//---------------------------- SHARED POSITIONAL CANCEL FUNCTION
A3C_AI_SHARED_Action_CancelPositionalProcess = {
	A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
	A3C_UI_HUD_3D_TAG_reposition = false;
	A3C_UI_HUD_3D_TAG_ICON_COL = [0.5,0.5,0.5,1]; //-- probably not needed, using grey to spot it happens :)
	if (!isNull A3C_OBJECTPLACER) then {
		deleteVehicle A3C_OBJECTPLACER;
	};
	// A3C_DISABLE_RADIAL = false; // -- not needed (Handled by keyup)

	if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
		A3C_AI_Squad_Action_ID = "";
	} else {
		A3C_AI_HighCommand_Action_ID = "";
	};
	A3C_UI_HUD_3D_TAG_ICON_POS = [0,0,0];
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		A3C_UI_RADIAL_Current_Remfire_Units = [];
	};
};



//---------------------------------------------------------------------------------------------
//---------- 1. Non positional actions --------------------------------------------------------
//---------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------
//---------- 2. Positional actions ------------------------------------------------------------
//---------------------------------------------------------------------------------------------

//----- Remote-Fire Actions 

A3C_AI_SHARED_Action_remoteFire_TankShot = {
	[A3C_REMFIRE_TankShot_Units, "TANKSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_SHARED_Action_remoteFire_UGLshot = {
	[A3C_REMFIRE_UGLShot_Units, "UGLSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};


A3C_AI_SHARED_Action_remoteFire_ATshot = {
	[A3C_REMFIRE_ATShot_Units, "ATSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_SHARED_Action_remoteFire_StaticRocketShot = {
	[A3C_REMFIRE_StaticShot_Units, "STATICSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};


