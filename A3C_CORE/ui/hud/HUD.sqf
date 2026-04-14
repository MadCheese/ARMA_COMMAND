
if (isDedicated) exitwith {};


A3C_HUD_COLLIDER = objnull;
A3C_HUD_Snap_DIR = 0;
A3C_HUD_Snap = false;
A3C_HUD_FormDir_Old = 0;


//--------------------------------------  H U D   M O D E   F U N C T I O N S  ------------------------------------
//-----------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------




//A3C_HUD_OBJECTS

//-----------------------------  U I  -  F U N C T I O N S  ------------------------------------
//----------------------------------------------------------------------------------------------

A3C_HUD_CAM_MoveCam_Time = time;
A3C_HUD_CAM_MoveCam_Pos = [0,0,0];
A3C_HUD_CAM_MoveCam_Dir = 0;

A3C_HUD_CAM_MoveCam = {
	private ["_input","_mousePos","_mX","_mY"];
	_input = _this;
	_mX = _input select 1;
	_mY = _input select 2;
	systemchat str A3C_HUD_CAM_MoveCam_Dir;
	if (_mX > 0) then {
		A3C_HUD_CAM_MoveCam_Dir = (A3C_HUD_CAM_MoveCam_Dir + 1);
		//if (A3C_HUD_CAM_MoveCam_Dir > 170) then {A3C_HUD_CAM_MoveCam_Dir = 170};
	} else {
		A3C_HUD_CAM_MoveCam_Dir = (A3C_HUD_CAM_MoveCam_Dir - 1);
		//if (A3C_HUD_CAM_MoveCam_Dir > 170) then {
		//	if (A3C_HUD_CAM_MoveCam_Dir < 190) then {
		//		A3C_HUD_CAM_MoveCam_Dir = 190;
		//	};
		//};
	};
	A3C_HUD_CAM_MoveCam_Dir = [A3C_HUD_CAM_MoveCam_Dir] call MCSS_fnc_CorrectDir;
	_pos = [player,objNull,(screenToWorld[_mX,_mY])] call MCSS_fnc_posIntersect;
	if (!isNull A3C_SNAP_OBJECT) then {
		_prms = [ATLtoASL _pos,A3C_SNAP_OBJECT] call A3C_HUD_SNAP_FORMATION;
		//systemchat str [_pos,_prms];
		_pos = _prms select 0;
	};
	ball setposASL _pos;
	systemchat str _pos;
	if ( (inputAction 'lookAround') > 0) then {
		if ((time - A3C_HUD_CAM_MoveCam_Time) > 0.1) then {
			A3C_HUD_CAM camPrepareTarget (A3C_HUD_CAM_MoveCam_Pos getPos [50, A3C_HUD_CAM_MoveCam_Dir]);
			A3C_HUD_CAM_MoveCam_Time = time;
			//A3C_HUD_CAM camPrepareTarget (screentoworld [_mX,_mY]);
			A3C_HUD_CAM camCommitPrepared 0.1;
		};
	};
};

A3C_HUD_CAM_Moving = false;

A3C_HUD_CAM_RefocusCam = {

	if ( (inputAction 'lookAround') > 0) then {
		if !(A3C_HUD_CAM_Moving) then {
			A3C_HUD_CAM_Moving = true;
			_refPos = screenToWorld getMousePosition;
			A3C_HUD_CAM_MoveCam_Dir = (vehicle player) getDir _refPos;
			if ((time - A3C_HUD_CAM_MoveCam_Time) > 0.1) then {
				A3C_HUD_CAM camPrepareTarget (A3C_HUD_CAM_MoveCam_Pos getPos [50, A3C_HUD_CAM_MoveCam_Dir]);
				A3C_HUD_CAM_MoveCam_Time = time;
				//A3C_HUD_CAM camPrepareTarget (screentoworld [_mX,_mY]);
				A3C_HUD_CAM camCommitPrepared 0.1;
			};
		};
	};
};




//-- Changes stance icon and data for HUD-mode stances
A3C_HUD_SETSTANCE = {
	params ["_mode"];
	private ["_data","_check","_toolTip"];
	_data = []; // [_icon,_stance,_iconColor,_stanceBool (false == no change)]
	_check = if (_mode == 0) then {A3C_HUD_STANCE_MODE_TRAVEL} else {A3C_HUD_STANCE_MODE_DESTINATION};
	_toolTip = "";
	switch (_check) do {
		case (0) : {
			_toolTip = "Stance: Prone";
			_data =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa",
				"DOWN",
				[1,1,1,1],
				true
			];
		};
		case (1) : {
			_toolTip = "Stance: Crouch";
			_data =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa",
				"MIDDLE",
				[1,1,1,1],
				true
			];
		};
		case (2) : {
			_toolTip = "Stance: Stand";
			_data =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
				"UP",
				[1,1,1,1],
				true
			];
		};
		case (3) : {
			_toolTip = "Stance: Auto";
			_data =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
				"AUTO",
				[1,1,1,1],
				true
			];
		};
		case (4) : {
			_toolTip = "Stance: No Change";
			_data =
			[
				"A3C_CORE\ui\pictures\icon_menu_stance_NoChange.paa",
				"",
				[1,1,1,1],
				false
			];
		};
	};
	if (A3C_HUD_FORM == 8) then {(_data select 2) set [2,0.1]}; //-- if EHM is active, lowe Opac for better vision
	//-- assign data
	if (_mode == 0) then {
		_toolTip = "Travel " + _toolTip;
		A3C_HUD_STANCE_ICON_TRAVEL = _data select 0;
		//if !(_data select 1 == "") then {A3C_HUD_STANCE_FINAL = _data select 1};
		A3C_HUD_STANCE_ICON_COLOR_TRAVEL= _data select 2;
		A3C_BOOL_STANCE_ICON_TRAVEL = _data select 3;
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 10) ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 10) ctrlSetTextColor [1,1,1,1]; //A3C_HUD_STANCE_ICON_COLOR_TRAVEL;
		(findDisplay 100050 displayCtrl 16) ctrlSetTooltip _toolTip;
	} else {
		_toolTip = "End " + _toolTip;
		A3C_HUD_STANCE_ICON_DESTINATION= _data select 0;
		//if !(_data select 1 == "") then {A3C_HUD_STANCE_FINAL = _data select 1};
		A3C_HUD_STANCE_ICON_COLOR_DESTINATION= _data select 2;
		A3C_BOOL_STANCE_ICON_DESTINATION = _data select 3;
		(findDisplay 100050 displayCtrl 17) ctrlSetTooltip _toolTip;
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 11) ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 11) ctrlSetTextColor [1,1,1,1]; //A3C_HUD_STANCE_ICON_COLOR_DESTINATION;
	};
	{
		_arrow = _x;
		{
			_var = _x getVariable ["A3C_HUD_DATA",[objNull,-1]];
			if (_var select 0 == _arrow) exitWith {
				[_arrow,_x] call A3C_HUD_OBJECT_SWITCHSTANCE;
			};
		} foreach (units player - [player]);

	} foreach A3C_HUD_UnitIndicators;
};

{[_x] call A3C_HUD_SETSTANCE} foreach [0,1];


A3C_SWITCHSTANCE = {
	private ["_units","_mode","_unitNames","_stmnt","_snt"];
	_units = _this select 0;
	_mode = _this select 1;
	//_unitNames = "";
	_stmnt = "";
	_snt = "";
	switch (_mode) do {
		case ("AUTO") : {
			_stmnt = "SentBehaviourSafe";
			_snt = "A3C_RELAX";
		};
		case ("DOWN") : {
			_stmnt = "SentUnitPosDown";
			_snt = "A3C_STAYDOWN";
		};
		case ("MIDDLE") : {
			_stmnt = "SentUnitPosMiddle";
			_snt = "A3C_StayLow";
		};
		case ("UP") : {
			_stmnt = "SentUnitPosUp";
			_snt = "A3C_OYF";
		};
	};
	{
		//-- spawn unitpos to add random delay to each unit (anti robot feel)
		[_x,_mode] spawn {
			params ["_u","_mode"];
			sleep (random 1.5);
			_u setunitPos _mode;
		};
	//	_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING);
	} foreach _units;
	player groupRadio _stmnt;
	//if !(_snt == "") then {player  _snt};
};
//(A3C_HUD_UnitIndicators select 0)
//screenToWorld [0.4,0.4]
A3C_DRAW_3D_ICONS = { //-- no longer used, replaced with drawHudUI
	/*
	if ((profilenamespace getvariable ['A3C_HUD_MENUSHOW_VAR',true]) OR (!isnull (findDIsplay 100050))) then {
		drawIcon3D
		[
			A3C_HUD_STANCE_ICON_TRAVEL,
			A3C_HUD_STANCE_ICON_COLOR_TRAVEL,
			screenToWorld [0.4,0.4],
			3,
			3,
			0,
			'',
			0,
			0.05
		];
		drawIcon3D
		[
			A3C_HUD_STANCE_ICON_DESTINATION,
			A3C_HUD_STANCE_ICON_COLOR_DESTINATION,
			screenToWorld [0.6,0.4],
			3,
			3,
			0,
			'',
			0,
			0.05
		];
		drawIcon3D
		[
			A3C_HUD_FORM_ICON,
			A3C_HUD_FORM_ICON_COLOR,
			screenToWorld [0.5,0.36],
			A3C_HUD_FORM_ICON_SIZE,
			A3C_HUD_FORM_ICON_SIZE,
			0,
			'',
			0,
			0.05
		];
		drawIcon3D
		[
			A3C_HUD_SPEED_ICON,
			A3C_HUD_SPEED_ICON_COLOR,
			screenToWorld [0.5,0.42],
			A3C_HUD_SPEED_ICON_SIZE,
			A3C_HUD_SPEED_ICON_SIZE,
			0,
			'',
			0,
			0.05
		];
	};
	*/
	{
		drawIcon3D
		[
			'',
			[1,1,1,0.7],
			(_x getvariable ['A3C_HUD_DATA', [objNull,-1] ]) select 0,
			0,
			0,
			0,
			str (_x getvariable 'A3C_FORMATION_INDEX'),
			1,
			0.05
		];
	} foreach A3C_HUD_UNITS;
};



A3C_HUD_OBJECT_SWITCHSTANCE = {
	params ["_arrow","_unit"];
	private _noChangeAnim = switch (stance _unit) do {
		case ("STAND") : {"A3C_anim_stand"};
		case ("CROUCH") : {"A3C_anim_crouch"};
		case ("PRONE") : {"A3C_anim_prone"};
	};

	private _anim = switch (A3C_HUD_STANCE_MODE_DESTINATION) do {
		case (4) : {_noChangeAnim};
		case (3) : {"A3C_anim_stand"};
		case (2) : {"A3C_anim_stand"};
		case (1) : {"A3C_anim_crouch"};
		case (0) : {"A3C_anim_prone"};
	};

	_arrow enableSimulation true;
	_arrow switchMove _anim;
	_arrow enableSimulation false;
};

//--- create visible indicator and assign to unit
A3C_HUD_ADD_SELECTED = {
	private ["_unit","_arrowIndex","_btn"];
	if (isNil 'A3C_is_Initialized') exitWith {
		hint "ARMA COMMAND IS INITIALIZING - STAND BY";
		waituntil {!isNil 'A3C_is_Initialized'};
		hint "ARMA COMMAND INITIALIZED";
		sleep 3;
		hint "";
	};
	_unit = (_this select 0);
	if (!alive _unit) exitwith {
		player reveal [_unit,4]; //-- unit is dead - exit and inform player
	};
	if (isPlayer _unit) exitWith {};
	if !(_unit == driver (vehicle _unit)) exitwith {};
	_btn = (_this select 1);
	A3C_HUD_UNITS pushback _unit;

	A3C_HUD_OBJECT_TYPE = if !(profileNameSpace getVariable ['A3C_HUD_OBJECTS',false]) then {'MCSS_ASM_INDICATOR_F'} else {'C_Soldier_VR_F'};
	_camVic = vehicle cameraOn;
	[_camVic] call MCSS_fnc_setVehicleVarname;
	call compile format
	[
		"

			A3C_HUD_UnitIndicator_%1 = A3C_HUD_OBJECT_TYPE createVehicleLocal (position %2);
			A3C_HUD_UnitIndicator_%1 disableCollisionWith %6;
			%6 disableCollisionWith A3C_HUD_UnitIndicator_%1;
			A3C_HUD_UnitIndicator_%1 enableSimulation false;
			if (profileNameSpace getVariable ['A3C_HUD_OBJECTS',false]) then {
				A3C_HUD_UnitIndicator_%1 addWeapon (primaryWeapon %2);
				A3C_HUD_UnitIndicator_%1 addWeapon (secondaryWeapon %2);
				A3C_HUD_UnitIndicator_%1 addBackPack (backPack %2);
				A3C_HUD_UnitIndicator_%1 addHeadgear (headgear %2);
				A3C_HUD_UnitIndicator_%1 addVest (vest %2);
				[A3C_HUD_UnitIndicator_%1,%2] call A3C_HUD_OBJECT_SWITCHSTANCE;
				A3C_HUD_UnitIndicator_%1 disableCollisionWith cameraOn;
			};
			A3C_HUD_UnitIndicator_%1 allowDamage false;

			A3C_HUD_UnitIndicator_%1 setvariable ['A3C_ARROW_BPOS',[0,0],true];
			A3C_HUD_UnitIndicators pushback A3C_HUD_UnitIndicator_%1;
			%2 setvariable ['A3C_HUD_DATA',[A3C_HUD_UnitIndicator_%1,'%4'],true];
			if ((count A3C_HUD_UNITS) == 1) then {
				if (profileNameSpace getVariable 'A3C_HUD_RES_VAR') then {
					private _p1 = AGLToASL positionCameraToWorld [0,0,0];
					private _p2 = AGLToASL positionCameraToWorld [0,0,10];
					private _startDir = _p1 getDir _p2;
					A3C_FORMATION_DIR = [(_startDir - 180)] call MCSS_fnc_CorrectDir;
					A3C_HUD_FORM = 0;
					[0] call A3C_UI_HUD_FORM_BUTTON;
				};
				if (A3C_HUD_OBJECT_TYPE == 'MCSS_ASM_INDICATOR_F') then {
					A3C_HUD_UnitIndicator_%1 setObjectTextureGlobal[0,'#(argb,8,8,3)color(0,1,0,0.1)'];
				};


			} else {
				if (A3C_HUD_OBJECT_TYPE == 'MCSS_ASM_INDICATOR_F') then {
					A3C_HUD_UnitIndicator_%1 setObjectTextureGlobal[0,'#(argb,8,8,3)color(0.9,0.8,0,0.1)'];
				};

			};

		",
		A3C_HUD_UnitIndicatorINDEX,
		_unit,
		_btn,
		A3C_HUD_UnitIndicator_TEXTCOUNT,
		(_unit getvariable 'A3C_FORMATION_INDEX'),
		_camVic
	];
	if ((count A3C_HUD_UNITS) == 1) then {
		A3C_HUD_L = [] spawn A3C_HUD_LOOP;
		A3C_NUM_DIR = 0;
		//-- spawn HUD Icons
		////[
		////	'A3C_HUD_ICONS',
		////	'onEachFrame',
		////	A3C_DRAW_3D_ICONS
		////] call BIS_fnc_addStackedEventHandler;
		if (profilenamespace getvariable ['A3C_HUD_MENUSHOW_VAR',true]) then {
			[] call A3C_HUD_OPEN_MENU;
		};



	};
	A3C_HUD_UnitIndicator_TEXTCOUNT = A3C_HUD_UnitIndicator_TEXTCOUNT + 1;
	A3C_HUD_UnitIndicatorINDEX = A3C_HUD_UnitIndicatorINDEX + 1;
};

A3C_HUD_OPEN_MENU = {
	if !(profileNamespace getVariable 'A3C_HUD_isOpen') then {
		("A3C_HUD_MENU_UI" call BIS_fnc_rscLayer) cutRsc ["A3C_HUD_MENU_UI","PLAIN"];
	};

	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 10) ctrlSetText A3C_HUD_STANCE_ICON_TRAVEL;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 10) ctrlSetTextColor [1,1,1,1]; //A3C_HUD_STANCE_ICON_COLOR_TRAVEL;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 11) ctrlSetText A3C_HUD_STANCE_ICON_DESTINATION;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 11) ctrlSetTextColor [1,1,1,1]; //A3C_HUD_STANCE_ICON_COLOR_DESTINATION;

	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 12) ctrlSetText A3C_HUD_FORM_ICON;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 13) ctrlSetText A3C_HUD_SPEED_ICON;
	//if (true) exitWith {};
	if (profileNameSpace getVariable ["A3C_HUD_LAYOUT_CORNER", false]) then {
		//-- Corner UI
		//-- Set all Controls to new positions
		{
			private ["_ctrl","_ctrlPos"];

			_ctrl = (uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl (_x select 0);
			_ctrlPos = ctrlPosition _ctrl;
			_ctrlPos set [0,(_x select 1) select 0];
			_ctrlPos set [1,(_x select 1) select 1];
			if (_x select 0 == 15) then {
				_ctrlPos =
				[
					0.585951 * safezoneW + safezoneX,
					0.335032 * safezoneH + safezoneY,
					0.412564 * safezoneW,
					0.660103 * safezoneH
				];
			};
			_ctrl ctrlSetPosition _ctrlPos;
			_ctrl ctrlCommit 0;
		} foreach [
				[10,[0.752122 * safezoneW + safezoneX,0.906921 * safezoneH + safezoneY]],
				[11,[0.832343 * safezoneW + safezoneX,0.906921 * safezoneH + safezoneY]],
				[12,[0.867525 * safezoneW + safezoneX,0.784845 * safezoneH + safezoneY]],
				[13,[0.792233 * safezoneW + safezoneX,0.906921 * safezoneH + safezoneY]],
				[14,[0.946944 * safezoneW + safezoneX, 0.65397 * safezoneH + safezoneY]],
				[15,[0.585951 * safezoneW + safezoneX,0.335032 * safezoneH + safezoneY]],
				[16,[0.946944 * safezoneW + safezoneX,0.719957 * safezoneH + safezoneY]],
				[17,[0.946944 * safezoneW + safezoneX,0.587983 * safezoneH + safezoneY]]

			];
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 15) ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu_Corner.paa";
	} else {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 15) ctrlSetText "A3C_CORE\ui\pictures\BG_HUD_Menu.paa";
	};


	if (profilenamespace getvariable ['A3C_HUD_MENUOVERRIDE_VAR',true]) then {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
		(findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Override Plans";
	} else {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
		(findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Add To Plans";
	};
	if (profilenamespace getvariable ['A3C_HUD_MENUSHOW_VAR',true]) then {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
		(findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Shown";
	} else {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
		(findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Hidden";
	};
	["HUD_MENU"] call A3C_GET_UI_BG_COLOR;
	[1] call A3C_HUD_GoCode_BUTTON;

};



//--- remove indicator / unassign unit
A3C_HUD_REMOVE_SELECTED = {
	private ["_unit"];

	_unit = (_this select 0);
	if !(_unit in A3C_HUD_UNITS) exitWith {};
	call compile format ["
		if (%1 == (A3C_HUD_UNITS select 0)) then {
			(((A3C_HUD_UNITS select 1) getvariable 'A3C_HUD_DATA') select 0) setObjectTextureGlobal [0,'#(argb,8,8,3)color(0,1,0,0.1)'];
		};
	",_unit];
	_unit = _this select 0;
	_teamMembers = A3C_HUD_UNITS;
	_switchOn = false;
	_data = [];
	//if ((count (_unit getvariable 'A3C_HUD_DATA') ) > 0) then {

		//if ((count A3C_HUD_UNITS) == 1) then {

		//};
	//};
	private _hudData = (_unit getvariable 'A3C_HUD_DATA');
	_hudData params ["_indicator"];
	deletevehicle _indicator;
	A3C_HUD_UnitIndicators= A3C_HUD_UnitIndicators- [_indicator];
	A3C_HUD_UNITS = A3C_HUD_UNITS - [_unit];
	_unit setvariable ["A3C_HUD_DATA",[],true];

	if ((count A3C_HUD_UNITS) == 1) then {
		(((A3C_HUD_UNITS select 0) getvariable 'A3C_HUD_DATA') select 0) setObjectTextureGlobal [0,'#(argb,8,8,3)color(0,1,0,0.1)'];
	};
	if ((count A3C_HUD_UNITS) == 0) then {

		{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
		profileNamespace setVariable ['A3C_HUD_isOpen',false];
		("A3C_HUD_MENU_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
		// remove stack
		////if ({(_x select 0) == 'A3C_HUD_ICONS'} count (missionNamespace getVariable ["BIS_stackedEventHandlers_ONEACHFRAME",[]]) > 0) then {
		////	['A3C_HUD_ICONS', "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		////	("A3C_HUD_MENU_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
		////	profileNamespace setVariable ['A3C_HUD_isOpen',false];
		////};
	};
};



A3C_HUD_SNAP_FORMATION = {

	private _cursorPos = +(_this select 0); 
	_cursorPos set [2,0];	
	private _object = _this select 1; //-- cursorpos is where the player is pointing at, with z==0

	private _objectHeight = (_object call BIS_fnc_objectHeight) * 0.3;
	private _normalDirAZM =  [0,0] getDir (A3C_HUD_NORMAL select [0,2]);
	private _watchOverDir = [_normalDirAZM + 180] call MCSS_fnc_CorrectDir;
	if (A3C_HUD_FORM == 7 OR {visibleMap}) exitWith {
		_cursorPos = 
		[
			_cursorPos,
			A3C_HUD_RADIUS + 1.2,
			_normalDirAZM
		] call BIS_fnc_RelPos;
		private _return =
		[
			_cursorPos,
			A3C_FORMATION_DIR,
			_watchOverDir
		];
		_return
	};
	_cursorPos = [_cursorPos,1,_normalDirAZM] call BIS_fnc_relPos;
	private _objectDir = getDir _object;
	private _directionOption1 = [_normalDirAZM + 90] call MCSS_fnc_CorrectDir; //+ A3C_HUD_Snap_DIR
	private _directionOption2 = [_directionOption1 + 180] call MCSS_fnc_CorrectDir;
	private _endUnitSpacingCount = count A3C_HUD_UnitIndicators;
	_endUnitSpacingCount = switch (true) do {
		case (A3C_HUD_FORM in [0,1,2,8]) : {_endUnitSpacingCount};
		case (A3C_HUD_FORM in [3,4]) : {(ceil (_endUnitSpacingCount/2)) + 1};
		case (A3C_HUD_FORM in [5,6]) : {ceil (_endUnitSpacingCount/2)};
	};
	

	if (A3C_DEBUG) then {
		RED_LINES = [];
		GREEN_LINES = [];
	};
	private _A3C_FORMATION_DIR = 0;



	//-- STEP 1: GET MAIN FORMATION DIRECTION

	private _excludeObjects = nearestTerrainObjects [_cursorPos, ["BUSH"], _endUnitSpacingCount * A3C_HUD_SPACING];
	_coverFnc = {
		params ["_object","_cursorPos","_objectHeight","_testDir","_endUnitSpacingCount","_watchOverDir","_excludeObjects","_mode"];
		private _allCovered = [true,0];
		_objectHeight = _objectHeight min 2;
		private _refPos = (getposASL (A3C_HUD_UnitIndicators select 0)) vectorAdd [0,0,0.5]; //_objectHeight
		if (_mode != 0) then {
			_refPos = _refPos vectorAdd [0,0,0.2];
		};
		for "_i" from 0 to (_endUnitSpacingCount -1) do {
			private _refPos1 = 
			[
				_refPos,
				A3C_HUD_SPACING * _i,
				_testDir
			] call BIS_fnc_RelPos;
			private _refPos2 = 
			[
				_refPos1,
				1.5,
				_watchOverDir
			] call BIS_fnc_RelPos;

			if (A3C_DEBUG) then {
				if (_mode != 0) then {
					GREEN_LINES pushBack
					[
						_refPos1,
						_refPos2
					];
				} else {
					RED_LINES pushBack
					[
						_refPos1,
						_refPos2
					];
				};
			};
			private _ins = lineIntersectsSurfaces
			[
				_refPos1,
				_refPos2,
				player,
				objNull,
				true,
				-1,
				"GEOM",
				"NONE"
			];
			_ins = _ins select {
				_object = _x select 2;
				!(_object in _excludeObjects) && {!(_object isKindOf "MAN")}
			};
			//if !(_object in _intersectsOBJS) exitWith {
			if (count _ins > 0) then {
				_allCovered = [false,(_endUnitSpacingCount - _i) max 0];
			};	
		};
		_allCovered
	};
	private _dir1IsCovered = [_object,_cursorPos,_objectHeight,_directionOption1,_endUnitSpacingCount,_watchOverDir,_excludeObjects,0] call _coverFnc;
	private _dir2IsCovered = [_object,_cursorPos,_objectHeight,_directionOption2,_endUnitSpacingCount,_watchOverDir,_excludeObjects,1] call _coverFnc;
	//systemChat str [(_dir1IsCovered select 1) , (_dir2IsCovered select 1)];
	if ((_dir1IsCovered select 1) <= (_dir2IsCovered select 1)) then {
		_A3C_FORMATION_DIR = _directionOption1;
	} else {
		_A3C_FORMATION_DIR = _directionOption2;
	};

	//-- Finally repeaat above priority 1 check to flip formation if direction intersects with building

	_refPos = (getposASL (A3C_HUD_UnitIndicators select 0)) vectorAdd [0,0,_objectHeight];

	_ins = lineIntersectsSurfaces [
		_refPos,
		[
			_refPos,
			(A3C_HUD_SPACING * (_endUnitSpacingCount - 1)) + 1.2,
			_A3C_FORMATION_DIR
		] call BIS_fnc_RelPos,
		player,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	_ins = _ins select {
		_object = _x select 2;
		!(_object in _excludeObjects) && {!(_object isKindOf "MAN")}
	};
	if (count _ins > 0) then {
		//systemChat str ['switch',[(_ins select 0 select 2)] call BIS_fnc_objectType];
		_A3C_FORMATION_DIR = [_A3C_FORMATION_DIR + 180] call MCSS_fnc_CorrectDir;
	};


	//-- STEP 2: ADJUST MAIN FORMATION DIRECTION AND FORMATION-VARIATION RELATIVE TO SNAP-DATA
	private _adjustFormLine = 0;
	private _adjustFormL = 3;
	private _adjustFormStag = 5;
	private _relDir = [round (_normalDirAZM - _objectDir)] call MCSS_fnc_CorrectDir;
	private _relFormDir = [ round ( (_A3C_FORMATION_DIR - _objectDir))] call MCSS_fnc_CorrectDir; 
	//systemChat str [_relFormDir,_relDir];
	switch (true) do {
		case (_relDir < 90) : {
			switch (true) do {
				case (A3C_HUD_FORM in [0,1]) : {
					if (_relFormDir == 270) then {
						_adjustFormLine = 1;
					};
				};
				case (A3C_HUD_FORM in [3,4]) : {
					if (_relFormDir == 270) then {
						_adjustFormL = 4;
					};
				};
				case (A3C_HUD_FORM in [5,6]) : {
					if (_relFormDir == 270) then {
						_adjustFormStag = 6;
					};
				};
			};
		};
		case (_relDir >= 90 && _relDir < 180) : {
			switch (true) do {
				case (A3C_HUD_FORM in [0,1]) : {
					if (_relFormDir == 0) then {
						_adjustFormLine = 1;
					};

				};
				case (A3C_HUD_FORM in [3,4]) : {
					if (_relFormDir == 0) then {
						_adjustFormL = 4;
					};	
				};
				case (A3C_HUD_FORM in [5,6]) : {
					if (_relFormDir == 0) then {
						_adjustFormStag = 6;
					};
				};
			};
		};
		case (_relDir >= 180 && _relDir < 270) : {
			switch (true) do {
				case (A3C_HUD_FORM in [0,1]) : {
					if (_relFormDir == 90) then {
						_adjustFormLine = 1;
					};
				};
				case (A3C_HUD_FORM in [3,4]) : {
					if (_relFormDir == 90) then {
						_adjustFormL = 4;
					};
				};
				case (A3C_HUD_FORM in [5,6]) : {
					if (_relFormDir == 90) then {
						_adjustFormStag = 6;
					};
				};
			};
		};
		case (_relDir >= 270) : {
			switch (true) do {
				case (A3C_HUD_FORM in [0,1]) : {
					if (_relFormDir == 180) then {
						_adjustFormLine = 1;
					};
				};
				case (A3C_HUD_FORM in [3,4]) : {
					if (_relFormDir == 180) then {
						_adjustFormL = 4;
					};
				};
				case (A3C_HUD_FORM in [5,6]) : {
					if (_relFormDir == 180) then {
						_adjustFormStag = 6;
					};
				};
			};
		};
	};

	if (A3C_HUD_FORM in [3,4]) then {
		//-- we need to subtract 2 as we were currently scanning ahead of the formation and exclude the leader
		_endUnitSpacingCount = _endUnitSpacingCount - 2; 
		private _testDir = [_A3C_FORMATION_DIR + 180] call MCSS_fnc_CorrectDir;
		_refPos = (getposASL (A3C_HUD_UnitIndicators select 0)) vectorAdd [0,0,_objectHeight];
		private _refPos1 = 
		[
			_refPos,
			A3C_HUD_SPACING * (_endUnitSpacingCount max 0),
			_testDir //[_testDir + 180] call MCSS_fnc_CorrectDir
		] call BIS_fnc_RelPos;
		private _refPos2 = 
		[
			_refPos1,
			5,
			_watchOverDir
		] call BIS_fnc_RelPos;
		_intersectsOBJS = lineIntersectsObjs
		[
			_refPos1,
			_refPos2,
			objnull,
			objnull,
			false
		];

		if !(_object in _intersectsOBJS) then {
			_A3C_FORMATION_DIR = _testDir;
		};
		A3C_HUD_FORM = _adjustFormL;
		A3C_HUD_FORM_ICON = switch (A3C_HUD_FORM) do {
			case (3) : {"A3C_CORE\ui\pictures\icon_formSec_L_Right.paa"};
			case (4) : {"A3C_CORE\ui\pictures\icon_formSec_L_Left.paa"};
		};		
	};

	switch (true) do {
		case (A3C_HUD_FORM in [0,1]) : {
			A3C_HUD_FORM = _adjustFormLine;
			A3C_HUD_FORM_ICON = switch (A3C_HUD_FORM) do {
				case (0) : {"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa"};
				case (1) : {"A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa"};
			};
		};
		case (A3C_HUD_FORM in [5,6]) : {
			A3C_HUD_FORM = _adjustFormStag;
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";
		};
	};
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 12) ctrlSetText A3C_HUD_FORM_ICON;

	//-- Finally assign FOrmation Direction (has to happen at the end so that formation does not flicker)
	A3C_FORMATION_DIR = _A3C_FORMATION_DIR;

	//-- return data
	private _return =
	[
		_cursorPos,
		A3C_FORMATION_DIR,
		_watchOverDir
	];
	_return
};

A3C_HUD_NORMAL = [0,0,0];

//-- Positioning of indicators
A3C_HUD_LOOP = {
	private ["_cursorPos","_useCursorPos","_objectCollision","_aimingHeight","_exit","_prms","_aimPos"];
	_cursorPos = true;
	_useCursorPos = 0;
	_objectCollision  = [];
	//_arrowASL = [];
	_aimingHeight = 0;
	_aimingHeighThresh = 1;
	_exit = false;
	A3C_HUD_Snap = false;
	A3C_HUD_POS_PAST = (screenToWorld [0.5,0.5]);
	A3C_HUD_POS_NOW = A3C_HUD_POS_PAST;
	A3C_HUD_TRAVEL_DIR = 0;
	A3C_HUD_CHECKPOS = A3C_HUD_POS_PAST;
	{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];
	while {(count A3C_HUD_UnitIndicators) > 0} do {
		_useCursorPos = true;
		_exit = false;
		_aimingHeight = 0;
		A3C_HUD_COLLIDER = objnull;
		if ((count A3C_HUD_UnitIndicators) == 0) exitwith {};
		private _excludeObjects = nearestTerrainObjects [position (A3C_HUD_UnitIndicators select 0), ["BUSH"], (count A3C_HUD_UnitIndicators) * A3C_HUD_SPACING];
		//hintsilent str _excludeObjects;
		if !(A3C_MODIFIER_LOCK) then {
			//////~~~~~~ THIS WHOLE THING IS A MESS, STRUCTURE THE LINEINTERSECTSSURFACES COMMANDS AND USE AIMPOS /AIMINGHEIGHT ACCORDINGLY
			_objectCollision = lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],vehicle player,objNull,true,-1,"GEOM","NONE"];
			_objectCollision = _objectCollision select {
				private _obj = _x select 2;
				!(_obj in (_excludeObjects + A3C_HUD_UnitIndicators))
			};

			//hintSilent str (_objectCollision);
			if (count _objectCollision > 0) then {
				if !(isnull cursortarget) then {
					//systemchat str time;
					//hintsilent str cursortarget;
					if ( ([cursortarget] call MCSS_fnc_countBPos) > 0) then {
						//_aimPos = ASLtoATL ([cameraOn,objnull] call MCSS_fnc_posIntersect);
						_aimPos = (_objectCollision select 0) select 0;
						_aimingHeight = if (!isNil '_aimPos') then {( ASLtoATL _aimPos) select 2} else {((boundingboxReal Cursortarget) select 1) select 2};
						//_aimingHeight = ([cameraOn,cursortarget] call MCSS_fnc_HeightAtTarget);
						//hintsilent str _aimingHeight;


						//

						//systemchat str _aimpos;
						//_aimingHeight = _aimPos select 2;
						//hintsilent str _aimingheight;
						if !(A3C_MODIFIER_LOCK) then {
							if (_aimingHeight < _aimingHeighThresh) then {
								_useCursorPos = true;
							} else {
								_useCursorPos = false;
								A3C_HUD_UnitIndicators_IN_BUILDING = true;

								[cursorTarget,_aimPos] call A3C_HUD_CREATEFORMATION_BUILDING;
							};
						};
					} else{
						//-- future option for cursortargets other than buildings
						//_useCursorPos = false;
					};
				};
			};
			if (_useCursorPos) then {
				A3C_HUD_UnitIndicators_IN_BUILDING = false;
				(A3C_HUD_UnitIndicators select 0) setdir ([(A3C_FORMATION_DIR + 180)] call MCSS_fnc_CorrectDir);
				{
					_x setvariable ['A3C_ARROW_BPOS',[0,0],true];
				} foreach A3C_HUD_UnitIndicators;
				//-- default: player looking in the open, sensor searches for Objects
				if !(A3C_MODIFIER_LOCK) then {
					//-- Security Deadzone for object sensor
					if (((screenToWorld [0.5,0.5]) distance A3C_HUD_POS_NOW) > 0.04) then {
						A3C_HUD_POS_NOW = (screenToWorld [0.5,0.5]);
						A3C_HUD_TRAVEL_DIR = [A3C_HUD_POS_PAST,A3C_HUD_POS_NOW]call bis_fnc_dirto;

					};
					A3C_HUD_POS_PAST = (screenToWorld [0.5,0.5]);
			////		_objectCollision = lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],vehicle player,(A3C_HUD_UnitIndicators select 0),true,1,"GEOM","NONE"];
					
					A3C_HUD_COLLIDER = (_objectCollision select 0) select 2;
					if (!isnil 'A3C_HUD_COLLIDER' && {!isnull A3C_HUD_COLLIDER && {speed A3C_HUD_COLLIDER < 0.2}}) then {
						A3C_HUD_Snap_DIR = 0;
						A3C_HUD_Snap = true;
						A3C_HUD_FormDir_Old = A3C_FORMATION_DIR;
						while {(count A3C_HUD_UnitIndicators) > 0} do {
							private _excludeObjects = nearestTerrainObjects [position (A3C_HUD_UnitIndicators select 0), ["BUSH"], (count A3C_HUD_UnitIndicators) * A3C_HUD_SPACING];
							_objectCollision = lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],vehicle player,objNull,true,-1,"GEOM","NONE"];
							_objectCollision = _objectCollision select {
								private _obj = _x select 2;
								!(_obj in (_excludeObjects + A3C_HUD_UnitIndicators))

							};
							if (count _objectCollision > 0) then {
								//helper setPosASL (_objectCollision select 0 select 1);
								
								A3C_HUD_NORMAL = (_objectCollision select 0 select 1);
								A3C_HUD_COLLIDER = (_objectCollision select 0) select 2;
								//helper setVectorUp A3C_HUD_NORMAL;
								if (!isnull cursortarget) then {
									
									
									
									for "_i" from 0 to 2 do {
										A3C_HUD_NORMAL set [_i,if (A3C_HUD_NORMAL select _i == 0) then {0} else {[A3C_HUD_NORMAL select _i,2] call BIS_fnc_cutDecimals}];
									};
									
									//A3C_HUD_NORMAL = +_normal;
									
									if (([cursortarget] call MCSS_fnc_countBPos) > 0) then {
										_collisionPos = (_objectCollision select 0) select 0;
										_aimingHeight = ( ASLtoATL _collisionPos) select 2;
										//_aimingHeight = ([cameraOn,cursortarget] call MCSS_fnc_HeightAtTarget);
										if (_aimingHeight > _aimingHeighThresh) then {
											_exit = true;
										};
									};
								};
							};


							[] call A3C_HUD_Orient_Indicators;
							//_arrowASL = (getposASL (A3C_HUD_UnitIndicators select 0));

							if ((count _objectCollision) == 0) then {_exit = true};
							if (!isNil 'A3C_HUD_COLLIDER' && {speed A3C_HUD_COLLIDER > 1}) then {_exit = true};
							if (count _objectCollision > 0) then {
								if !(isnull cursorTarget) then {
									if !(isnil "A3C_HUD_COLLIDER") then {
										if !(isnull A3C_HUD_COLLIDER) then {
											if (cursorTarget == A3C_HUD_COLLIDER) then {
												if (([cursortarget] call MCSS_fnc_countBPos) > 0) then {
													_collisionPos = (_objectCollision select 0) select 0;
													_aimingHeight = ( ASLtoATL _collisionPos) select 2;
													//_aimingHeight = ([cameraOn,cursortarget] call MCSS_fnc_HeightAtTarget);
													if (_aimingHeight > _aimingHeighThresh) then {
														_exit = true;
													};
												};
											};
										};
									};
								};
							};
							if (_exit) exitwith {};

							if !(isnull A3C_HUD_COLLIDER) then {
								//systemchat str time;
								_prms = [((_objectCollision select 0) select 0),A3C_HUD_COLLIDER] call A3C_HUD_SNAP_FORMATION;
								//-- dir facing object (_shiftDir + 180)
								if (A3C_HUD_Form in [2,8]) then {
									profileNamespace setvariable ["A3C_EHM_DIR",(_prms select 2)];	//-- dir facing object
								};
								[(_prms select 0)] call A3C_HUD_CREATEFORMATION;
							} else {
								_exit = true;
							};
							sleep 0.1;
						};
						A3C_FORMATION_DIR = A3C_HUD_FormDir_Old;
						A3C_HUD_Snap = false;
						A3C_HUD_COLLIDER = objnull;
						_exit = false;
						_useCursorPos = false;
					} else {
						A3C_HUD_Snap = false;
					};
					//--
					if (_useCursorPos) then {
						[A3C_HUD_POS_NOW] call A3C_HUD_CREATEFORMATION;
					};
					_objectCollision= [];
				};
			};
			//if ((count A3C_HUD_UnitIndicators) > 0) then {
				[] call A3C_HUD_Orient_Indicators;

			//};
			sleep 0.05;
		} else {
			if !(A3C_HUD_UnitIndicators_IN_BUILDING) then {
				[(screenToWorld [0.5,0.5])] call A3C_HUD_CREATEFORMATION;
			};
		};

	};
	//systemchat "hey";

	// "loop done";
};

A3C_HUD_Orient_Indicators = {
	_divisor = 0;
	_altAmount = 0;
	_arrow = objnull;
	_count = (count A3C_HUD_UNITS);
	if (_count == 0) exitwith {};
	_altAmount = (_count - 1);
	_watchdir = 0;
	//if (_altAmount == 0) then {
	//	_watchdir = ((A3C_FORMATION_DIR + 180) + A3C_HUD_Snap_DIR);
	//} else {
		_watchdir = (A3C_FORMATION_DIR + 180);
	//};
	_watchDir = [_watchDir] call MCSS_fnc_CorrectDir;
	switch (A3C_HUD_FORM) do {
		if (_count == 1) then {
			_arrow = (((A3C_HUD_UNITS select 0) getvariable 'A3C_HUD_DATA') select 0);
			if !(A3C_HUD_FORM == 7) then {
				if !(isnil "_arrow") then {_arrow setdir _watchdir};
			};
		};
		//-- Line Left
		case (0) : {
			if (_count > 1) then {
				_divisor = (180 / _altAmount);
				for "_i" from 0 to _altAmount do {
					if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
						if (_count >= _i) then {
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir + (_divisor * _i))};
						};
					};
				};
			};
		};
		//-- Line Right
		case (1) : {
			if (_count > 1) then {
				_divisor = (180 / _altAmount);
				for "_i" from 0 to _altAmount do {
					if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir - (_divisor * _i))};
						};
					};
				};
			};
		};
		//-- 2: Line Front
		//-- Line Front
		case (2) : {
			//if (_count > 1) then {
				for "_i" from 0 to _altAmount do {
					//if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							//_watchDir = [_arrow,A3C_HUD_COLLIDER] call BIS_fnc_dirTo;
							//_watchDir = profileNamespace getvariable "A3C_EHM_DIR";
							_watchDir1 = if (A3C_HUD_SNAP) then {profileNamespace getvariable "A3C_EHM_DIR"} else {_watchDir + 90};
							if !(isnil "_arrow") then {_arrow setdir _watchdir1};
						};
					//};
				};
			//};
		};
		//-- L Form Right (as in: lower serif ofL goes right)
		case (3) : {
			if (_count > 1) then {
				_divisor = (270 / _altAmount);
				for "_i" from 0 to _altAmount do {
					if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir - (_divisor * _i))};
						};
					};
				};
			};
		};
		//-- L Form Left (as in: lower serif ofL goes left)
		case (4) : {
			if (_count > 1) then {
				_divisor = (270 / _altAmount);
				for "_i" from 0 to _altAmount do {
					if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir + (_divisor * _i))};
						};
					};
				};
			};
		};
		//-- Stag Col Left (as in: formation leader is leading left row)
		case (5) : {
			if (_count > 1) then {
				_divisor = 0;
				for "_i" from 0 to _altAmount do {
					if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir + (_divisor * _i))};
						};
					};
				};
			};
		};
		//-- Stag Col Right (as in: formation leader is leading right row)
		case (6) : {
			if (_count > 1) then {
				_divisor = 0;
				for "_i" from 0 to _altAmount do {
					if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							if !(isnil "_arrow") then {_arrow setdir (_watchdir + (_divisor * _i))};
						};
					};
				};
			};
		};

		//-- skip 7 : circle formation

		//-- 8: only available when "Enhanced Movement" is running
		case (8) : {
			//if (_count > 1) then {
				for "_i" from 0 to _altAmount do {
					//if (_count >= _i) then {
						if (count A3C_HUD_UNITS > 0) then { //-- prevent script error when HUD was closed / order given
							_arrow = (((A3C_HUD_UNITS select _i) getvariable 'A3C_HUD_DATA') select 0);
							//_watchDir = [_arrow,A3C_HUD_COLLIDER] call BIS_fnc_dirTo;
							_watchDir = profileNamespace getvariable "A3C_EHM_DIR";
							if !(isnil "_arrow") then {_arrow setdir _watchdir};
						};
					//};
				};
			//};
		};
	};

	//-- rotate UI icon
	if !(A3C_HUD_FORM in [7,8]) then {
		if (count A3C_HUD_UnitIndicators> 0) then {
			//_relPos =
			//[
			//	A3C_HUD_UnitIndicators select 0,
			//	50000,
			//	A3C_FORMATION_DIR //([(getDir (A3C_HUD_UnitIndicators select 0)) + 90] call MCSS_fnc_CorrectDir)
			//] call BIS_fnc_relPos;
			//_relDir = (cameraon getRelDir _relPos); // - 90;
			private _p1 = AGLToASL positionCameraToWorld [0,0,0];
			private _p2 = AGLToASL positionCameraToWorld [0,0,10];
			private _playerDir = _p1 getDir _p2;
			if (A3C_HUD_FORM == 2) then {
				_playerDir = _playerDir - 90;
			};
			private _relDir = [A3C_FORMATION_DIR + 180 - _playerDir] call MCSS_fnc_CorrectDir;
			//systemchat str [_playerDir,_relDir];
			//_rela = ([] call BIS_fnc_dirTo) - (getDir (A3C_HUD_UnitIndicators select 0)) ;
			//if (_relDir > 180) then {_relDir = (360 - _relDir) * -1};
			//hint str _reldir;
			((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 12) ctrlSetAngle [_relDir, 0.5, 0.5];
		};
	} else {
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 12) ctrlSetAngle [0, 0.5, 0.5];
	};
};

//----------------------- F U N C T I O N S   T O   C A L C U L A T E   I N D I C A T E D   F O R M A T I O N S  ---------------
//------------------------------------------------------------------------------------------------------------------------------



//-- Function to set indicators in formations (outside of buildings)
A3C_HUD_CREATEFORMATION = {
	private ["_cursorPos","_offset","_amount"];
	_cursorPos = _this select 0;
	if (A3C_MODIFIER_LOCK) then {
		_cursorPos = (position (A3C_HUD_UnitIndicators select 0));
	};
	_offset = A3C_HUD_SPACING;
	_amount = count A3C_HUD_UnitIndicators;
	_watchdir = ((A3C_FORMATION_DIR + A3C_NUM_DIR) + 180);
	_dirParams = 0;
	_switchMode = 0;
	switch (A3C_HUD_FORM) do {
		case (0) : {
			//-- Line Formation Right
			for "_i" from 0 to ((count A3C_HUD_UnitIndicators) -1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i == 0) then {
						(A3C_HUD_UnitIndicators select _i) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
					} else {
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select 0), (_offset * _i), (A3C_FORMATION_DIR + A3C_NUM_DIR)] call BIS_fnc_relPos);
						//(A3C_HUD_UnitIndicators select _i) setpos ((A3C_HUD_UnitIndicators select 0) getRelPos [(_offset * _i),(A3C_FORMATION_DIR + A3C_NUM_DIR)]);
					};
				};
			};
		};
		case (1) : {
			//-- Line Formation Left
			for "_i" from 0 to ((count A3C_HUD_UnitIndicators) -1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i == 0) then {
						(A3C_HUD_UnitIndicators select _i) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
					} else {
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select 0), (_offset * _i), (A3C_FORMATION_DIR + A3C_NUM_DIR)] call BIS_fnc_relPos);
						//(A3C_HUD_UnitIndicators select _i) setpos ((A3C_HUD_UnitIndicators select 0) getRelPos [(_offset * _i),(A3C_FORMATION_DIR + A3C_NUM_DIR)]);
					};
				};
			};
		};
		//-- Line Front
		case (2) : {
			for "_i" from 0 to ((count A3C_HUD_UnitIndicators) -1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i == 0) then {
						(A3C_HUD_UnitIndicators select _i) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
					} else {
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select 0), (_offset * _i), (A3C_FORMATION_DIR + A3C_NUM_DIR)] call BIS_fnc_relPos);
						//(A3C_HUD_UnitIndicators select _i) setpos ((A3C_HUD_UnitIndicators select 0) getRelPos [(_offset * _i),(A3C_FORMATION_DIR + A3C_NUM_DIR)]);
					};
				};
			};
		};
		case (3) : {
			//-- L Formation Right
			(A3C_HUD_UnitIndicators select 0) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
			for "_i" from 1 to (_amount - 1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i >= (_amount /2)) then {_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR) - 90)} else {_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR))};
					(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 1)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
				};
			};
		};
		case (4) : {
			//-- L Formation Left
			(A3C_HUD_UnitIndicators select 0) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
			for "_i" from 1 to (_amount - 1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i >= (_amount /2)) then {_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR) + 90)} else {_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR))};
					(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 1)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
				};
			};
		};
		case (5) : {
			//-- Cube Formation Right
			(A3C_HUD_UnitIndicators select 0) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
			for "_i" from 1 to (_amount - 1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_switchMode == 0) then {
						_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR) - 90);
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 1)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
						_switchMode = 1;
					} else {
						_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR));
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 2)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
						_switchMode = 0;
					};
				};
			};
		};
		case (6) : {
			//-- Cube Formation Left
			(A3C_HUD_UnitIndicators select 0) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
			for "_i" from 1 to (_amount - 1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_switchMode == 0) then {
						_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR) + 90);
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 1)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
						_switchMode = 1;
					} else {
						_dirParams = ((A3C_FORMATION_DIR + A3C_NUM_DIR));
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select (_i - 2)), (_offset * 1), _dirParams] call BIS_fnc_relPos);
						_switchMode = 0;
					};
				};
			};
		};
		case (7) : {
			//-- 360 Security || Circle Formation
			_pos = [(_cursorPos select 0),(_cursorPos select 1),0];
			_step = 360 / (count A3C_HUD_UnitIndicators);
			_count = 360 / _step;
			A3C_HUD_RADIUS_MIN = 1;
			if (count A3C_HUD_UnitIndicators> 1) then {
				while {true} do {
					if ((([_pos,A3C_HUD_RADIUS_MIN,0] call BIS_fnc_RelPos) distance2D ([_pos,A3C_HUD_RADIUS_MIN,_step] call BIS_fnc_RelPos)) > 2) exitwith {};
					A3C_HUD_RADIUS_MIN = A3C_HUD_RADIUS_MIN + 1;
				};
			};
			if (A3C_HUD_RADIUS < A3C_HUD_RADIUS_MIN) then {A3C_HUD_RADIUS = A3C_HUD_RADIUS_MIN};
			//_range = 2*pi*r;
			//(A3C_HUD_UnitIndicators select 0) setpos ([_pos,A3C_HUD_RADIUS,0] call BIS_fnc_RelPos);
			for "_i" from 0 to (_amount - 1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					_acPos = ([_pos,A3C_HUD_RADIUS,(_i * _step)] call BIS_fnc_RelPos);
					_arr = if (A3C_360_out) then {[_pos,_acPos]} else {[_acPos,_pos]};
					(A3C_HUD_UnitIndicators select _i) setpos _acPos;
					(A3C_HUD_UnitIndicators select _i) setdir 	(_arr call BIS_fnc_dirTo);
				};
			};
		};

		case (8) : {
			//-- Enhanced Movement: Units will move to position, face the object and climb ontop or over it
			for "_i" from 0 to ((count A3C_HUD_UnitIndicators) -1) do {
				if (_i < (count A3C_HUD_UnitIndicators)) then {
					if (_i == 0) then {
						(A3C_HUD_UnitIndicators select _i) setpos [(_cursorPos select 0),(_cursorPos select 1),0];
					} else {
						(A3C_HUD_UnitIndicators select _i) setpos ([(A3C_HUD_UnitIndicators select 0), (_offset * _i), (A3C_FORMATION_DIR + A3C_NUM_DIR)] call BIS_fnc_relPos);
						//(A3C_HUD_UnitIndicators select _i) setpos ((A3C_HUD_UnitIndicators select 0) getRelPos [(_offset * _i),(A3C_FORMATION_DIR + A3C_NUM_DIR)]);
					};
				};
			};
		};
	};
};


//-- Function to set indicators on building positions
A3C_HUD_CREATEFORMATION_BUILDING = {
	private ["_fea","_building","_aimPos"];
	_building = _this select 0;
	_aimPos = _this select 1;


	_outSidePositions = [_building,1] call MCSS_fnc_BBOX;
	//systemchat str (count _outSidePositions);
	_availablePositions = ([_building] call MCSS_fnc_countBPos);
	_positionArray = [player,_building,_availablePositions,_aimPos] call A3C_fnc_SmartBpos;
	_availablePositions = count _positionArray;
	//systemchat str (_positionArray select 0);
	//systemchat str _positionArray;
	//if (true) exitWith {};


	{
		_fea = _forEachIndex;
		//if !( ((_building buildingpos _forEachIndex) distance [0,0,0]) == 0 ) then { //-- because building cant hold more units than it has positions
		if (_foreachIndex < count _positionArray) then {
			_x setposATL (_positionArray select _forEachIndex);
			_x setvariable ["A3C_ARROW_BPOS",[(_positionArray select _forEachIndex),([_building,(_positionArray select _forEachIndex)] call BIS_fnc_dirTo)],true];
			//_x setposATL (_building buildingpos (_positionArray select _forEachIndex));
			//_x setvariable ["A3C_ARROW_BPOS",[(_building buildingpos (_positionArray select _forEachIndex)),([_building,_x] call BIS_fnc_dirTo)],true];
		} else {
			if !( (typename ((_x getvariable "A3C_ARROW_BPOS") select 0)) == "ARRAY" ) then {
				if ( ((_x getvariable "A3C_ARROW_BPOS") select 0) == 0) then {
					if (_fea <= (_availablePositions + 8) ) then {
						_x setpos (_outSidePositions select ((_fea - _availablePositions) -0));
					} else {
						_x setpos (_building getRelPos [(random ((sizeof (typeOf cursortarget))) / 2),(random 360)]);
					};
					_x setvariable ["A3C_ARROW_BPOS",[1,(_building getRelDir _x)],true];

				};
			};
		};
	} foreach A3C_HUD_UnitIndicators;
};

//-- Function to find building-positions on the floor that player is looking at
//-- Author Note: Change function to use position of lineIntersectSurfaces
A3C_fnc_SmartBpos = {
	private ["_unit","_building","_bPosAmount","_aimPos","_unsorted","_sorted","_return","_posi"];
	_unit = _this select 0;
	_building = _this select 1;
	_bPosAmount = _this select 2;
	_aimPos = ASLtoATL (_this select 3); //-- or AGL?
	//tunit setpos _aimpos; tunit enablesimulation false;
	//_unsorted = [];
	_return = [];
	_onFloor = [];
	_buildingType = typeOf _building;
	_prohibitedPositions = [];
	{
		if (_x select 0 == _buildingType) exitWith {
			_prohibitedPositions = _x select 1;

		};
	} foreach (profileNameSpace getVariable ["A3C_PROFILEVAR_BUILDINGS_DEFUNCT", []]);

	_posesIndexed = [];
	for "_i" from 0 to _bPosAmount do {
		if !(_i in _prohibitedPositions) then {
			_posesIndexed pushBack _i;
		};
	};
	_bPosAmount = count _posesIndexed; //-- corrected bposAmount

	//_bPosAmount = (_bPosAmount - (count _prohibitedPositions)) max 0;


	//systemchat str _prohibitedPositions;

	//for "_i" from 0 to (_bPosAmount - 1) do {
	//	if !(_i in _prohibitedPositions) then {
	//		_unsorted pushback (_building buildingpos _i);
	//	};

	//};
	//_sorted = [];
	//_sorted = [_unsorted,[],{_x distance _aimPos},"ASCEND"] call BIS_fnc_sortBy;
	private _sortedByATLHeight = [];
	_bposesAdded = 0;
	_testedHeight = 0;
	while {_bposesAdded < _bPosAmount} do {
		//systemchat str _i;
		//-- _i is currently checked ATL height
		private _currentATLArray = [];
		{
			private _testedBpos = (_building buildingPos _x);
			if ({_testedBpos in _x} count _sortedByATLHeight == 0) then {
				private _bPosHeight = _testedBpos select 2;
				if ((_bPosHeight <= (_testedHeight + 0.5)) && {_bPosHeight >= (_testedHeight - 0.5)}) then {
					_currentATLArray pushBackUnique _testedBpos;
					_bposesAdded = _bposesAdded + 1;
				};
			};
		} foreach _posesIndexed;


		/*
		for "_c" from 0 to _bPosAmount do {

			if !(_c in _prohibitedPositions) then {
				private _testedBpos = (_building buildingPos _c);
				if ({_testedBpos in _x} count _sortedByATLHeight == 0) then {
					private _bPosHeight = _testedBpos select 2;
					if ((_bPosHeight <= (_testedHeight + 0.5)) && {_bPosHeight >= (_testedHeight - 0.5)}) then {
						_currentATLArray pushBackUnique _testedBpos;
						_bposesAdded = _bposesAdded + 1;
					};
				};
			} else {
				_bposesAdded = _bposesAdded + 1;
			};
		};
		*/
		_sortedByATLHeight pushBack _currentATLArray;
		_testedHeight = _testedHeight + 0.5;
	};

	{
		if (_x isEqualTo []) then {
			_sortedByATLHeight = _sortedByATLHeight - [_x];
		};
	} foreach _sortedByATLHeight;
	//systemchat str _aimPos;

	_sortedATLsortedByDistance = [];
	{
		_checkArray = _x;
		_checkArray = [_checkArray,[],{_aimPos distance _x},"ASCEND"] call BIS_fnc_sortBy;
		_sortedATLsortedByDistance pushBack _checkArray;
	} foreach _sortedByATLHeight;

	_sortedATLsortedByDistance = [_sortedATLsortedByDistance,[],{_aimPos distance (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
	_return = [];
	{
		_floorArray = _x;
		{
			_return pushBack _x;
		} foreach _floorArray;
	} foreach _sortedATLsortedByDistance;
	//systemchat str (_return);
	_return

	/*
	if (true) exitWith {_return};

	//systemchat str [_bposesAdded,_bPosAmount,count _sortedByATLHeight];
	{
		_dif = abs ( (_x select 2) - (_aimPos select 2) );
		if (_dif < 1.5) then {
			_sorted = _sorted - [_x];
			_onFloor pushback _x; //-- note: already sorted by distance to aimpos!
		};
	} foreach _sorted;
	_sorted = _onFloor + _sorted;
	{
		_posi = _x;
		for "_i" from 0 to (_bPosAmount - 1) do {
			if !(_i in _prohibitedPositions) then {
				if ((_posi distance (_building buildingpos _i)) < 0.2) then {
					_return pushback _i;
				};
			};
		};
	} foreach _sorted;
	systemchat str ( _return);
	_return
	*/
};

/*
//-- Function to set indicators on building positions
A3C_HUD_CREATEFORMATION_BUILDING_OLD = {
	private ["_fea"];
	_building = _this select 0;
	_aimingHeight = _this select 1;
	_outSidePositions = [_building] call MCSS_fnc_BBOX;
	_availablePositions = ([_building] call MCSS_fnc_countBPos);
	_positionArray = [player,_building,_availablePositions,_aimingHeight] call A3C_fnc_SmartBpos;

	{
		_fea = _forEachIndex;
		if !( ((_building buildingpos _forEachIndex) distance [0,0,0]) == 0 ) then {
			_x setposATL (_building buildingpos (_positionArray select _forEachIndex));
			_x setvariable ["A3C_ARROW_BPOS",[(_building buildingpos (_positionArray select _forEachIndex)),([_building,_x] call BIS_fnc_dirTo)],true];
		} else {
			if !( (typename ((_x getvariable "A3C_ARROW_BPOS") select 0)) == "ARRAY" ) then {
				if ( ((_x getvariable "A3C_ARROW_BPOS") select 0) == 0) then {
					if (_fea <= (_availablePositions + 4) ) then {
						_x setpos (_outSidePositions select ((_fea - _availablePositions) -1));
					} else {
						//_x setpos ([(position _building),(random ((sizeof (typeOf cursortarget))) / 2),(random 360)] call BIS_fnc_Relpos);
						_x setpos (_building getRelPos [(random ((sizeof (typeOf cursortarget))) / 2),(random 360)]);
					};
					//_x setvariable ["A3C_ARROW_BPOS",[1,([(position _building),(position _x)] call BIS_fnc_dirTo)],true];
					_x setvariable ["A3C_ARROW_BPOS",[1,(_building getRelDir _x)],true];

				};
			};
		};
	} foreach A3C_HUD_UnitIndicators;
};


//-- Function to find building-positions on the floor that player is looking at
//-- Author Note: Change function to use position of lineIntersectSurfaces
A3C_fnc_SmartBpos_OLD = {
	_unit = _this select 0;
	_building = _this select 1;
	_bPosAmount = _this select 2;
	_heightAtBuilding = _this select 3;
	_unsorted = [];
	_return = [];
	for "_i" from 0 to (_bPosAmount - 1) do {_unsorted pushback (_building buildingpos _i)};
	_sorted = [];
	_sorted = [_unsorted,[],{[(_x select 2),_heightAtBuilding] call MCSS_fnc_FindDifference},"ASCEND"] call BIS_fnc_sortBy;
	{
		_posi = _x;
		for "_i" from 0 to (_bPosAmount - 1) do {
			if ((_posi distance (_building buildingpos _i)) < 0.2) then {
				_return pushback _i;
			};
		};
	} foreach _sorted;
	_return
};
*/

//---------------------------------------  G E N E R A L  F U N C T I O N S  ------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
	

//-- Send units to the positions of their indicators
A3C_HUD_MOVE = {
	private ["_arrow","_ehm","_dest","_exit","_goCode","_mType","_script","_condition"];
	params ["_unit", "_bPos", "_ATLpos", "_watchDir"];
	if (isNull _unit) exitWith {};
	if (isPlayer _unit) exitWith {};
	//systemchat str _this;
	_ehm = if (count _this > 4) then {_this select 4} else {0};
	_bpos = _atlPos;

	//_WatchDir = _data select 1;
	if (!alive _unit) exitWith {};
	_unit stop false;
	_dest = _ATLpos;
	_goCode = profilenamespace getvariable ["A3C_HUD_GOCODE_VAR","NONE"];
	_condition = if (_goCode == "NONE") then {["NONE","NONE"]} else {["GOCODE",_goCode]};

	private _action = if (_ehm == 8) then {["EHM",[]]} else {["NONE",[]]};

	//if (A3C_HUD_UnitIndicators_IN_BUILDING) then {

	//	if ( (typename _bpos) == "ARRAY" ) then {
	//		_dest = _bPos;
	//	};

	//};
	_mType = switch (_goCode) do {
		case ("A") : {'A3C_Marker_GoCode_A'};
		case ("B") : {'A3C_Marker_GoCode_B'};
		case ("C") : {'A3C_Marker_GoCode_C'};
		case ("D") : {'A3C_Marker_GoCode_D'};
		default {"mil_dot"};
	};
	_hudStance1 = switch (A3C_HUD_STANCE_MODE_TRAVEL) do {
		case 0 : {"DOWN"};
		case 1 : {"MIDDLE"};
		case 2 : {"UP"};
		case 3 : {"AUTO"};
		case 4 : {""};
	};
	_hudStance2 = switch (A3C_HUD_STANCE_MODE_DESTINATION) do {
		case 0 : {"DOWN"};
		case 1 : {"MIDDLE"};
		case 2 : {"UP"};
		case 3 : {"AUTO"};
		case 4 : {""};
	};
	A3C_TEMP_WP_ID_SUB = (format ['A3C_Mark_P%1',A3C_MARKER_COUNT]); //[(format ['A3C_Mark_P%1',A3C_MARKER_COUNT]),_dest,"ICON",_mType,[0.5,0.5],"","ColorWhite",1] call MCSS_fnc_createMarker;
	A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
	A3C_MARKERS pushback A3C_TEMP_WP_ID_SUB;
	_tVar = [];
	_speed = profilenamespace getvariable ["A3C_HUD_SPEED_VAR",-1];

	_wpData =
	[
		[_dest,([_dest, 100,_WatchDir] call BIS_fnc_relPos)], //-- positions
		[A3C_TEMP_WP_ID_SUB,A3C_TEMP_WP_ID_SUB], //-- markers
		_action, //-- wp action
		_condition, //--WP Condition
		[_hudStance1,_hudStance2], //-- WP Stances
		[[0,false]], // WP Sync Data
		false, //-- isWPCompleted
		0, //-- Combat Mode
		_speed, //-- WP SPeed
		25, //-- WP Flying Height
		-1, //-- WP Loop Value
		-1.5 // -- radius (for circle, not completion)
	];
	//if (true) exitWith {};
	if ( (profilenamespace getvariable ["A3C_HUD_MENUOVERRIDE_VAR",true]) OR (count (_unit getVariable "A3C_PLOT") == 0)) then {
		_tVar = [_wpData];
		_unit setVariable ["A3C_PLOT",_tVar,true];
		_script = [_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_MOVE;
	} else {
		_tVar = _unit getVariable ["A3C_PLOT",[]];
		_tVar pushBack _wpData;
		_unit setVariable ["A3C_PLOT",_tVar,true];
	};



	if (true) exitWith {};

	//player commandchat str _ehm;

	//~~ stance solution not good
	//_stance = if (A3C_BOOL_STANCE_ICON_TRAVEL) then {_unit setunitpos A3C_HUD_STANCE_FINAL};

	//-- precaution to snap units out of STOP command pre-order, for HOLD compatibility
	//if (_unit getvariable ["A3C_HOLD",false]) then {
	//	_unit domove (position vehicle _unit);
	//	_unit moveTO (position vehicle _unit);
	//};
	_exit = false;

	//while {alive _unit} do {
	//	if !(_unit getvariable ["A3C_HOLD",false]) exitwith {};
	//	if (currentcommand _unit == "STOP") exitWith {_exit = true};
	//	if ( ((expectedDestination _unit) select 1) in ["DoNotPlanFormation","FORMATION PLANNED"]) exitwith {_exit = true};
	//	sleep 0.1 + (random 0.9);
	//};


	//-- exit if plans have changed after "HOLD"





	//_unit forcespeed -1;


	if (A3C_HUD_UnitIndicators_IN_BUILDING) then {
		//[_unit,_dest] spawn A3C_DOMOVE;
		//_unit lookat ([_ATLpos, 100,_WatchDir] call BIS_fnc_relPos);
	} else {
		//_unit lookat ([_ATLpos, 100,_dir] call BIS_fnc_relPos);
		//[_unit,_ATLpos] spawn A3C_DOMOVE;
		//_stance = switch (A3C_HUD_STANCE_FINAL) do {
		//};

		if (_ehm  == 8) then { //~~ THIS IS PROLLY GONNA CLASH
			_exit = false;
			//systemchat "1";

			//while {alive _unit} do {
			//	_order = ((expectedDestination _unit) select 1);
			//	if (_unit distance _atlPos < 3) exitwith {};
			//	if (currentcommand _unit == "STOP") then {
			//		if !( _order == "LEADER PLANNED") then {
			//			_exit = true;
			//		};
			//		// ~ Author Note: Add formation exit!!
			//	};
			//	if (["formation",_order] call MCSS_fnc_isInString ) exitwith {};
			//	if (_exit) exitwith {};
			//	sleep 0.1;
			//};

			//systemchat str _unit;
			waituntil {count (_unit getVariable ["A3C_PLOT",[]]) == 0};
			if (!isNull _unit) then {
				//sleep 1;
				systemchat str _unit;
				if !(_exit) then {
					while {alive _unit} do {
						if (speed _unit < 0.1) exitwith {};
						sleep 0.1;
					};
					//systemchat "3";
					//sleep random 1;
					_takeOff = position _unit;
					//_unit spawn {
					//	params ["_unit"];
						//_unit call Babe_EM_fnc_detect;
					//};
					_unit call A3C_Babe_fnc_detect;
					sleep 1;
					for "_i" from 1 to 2 do {
						if (_unit distance _takeOff < 0.2) then {
							_unit call A3C_Babe_fnc_detect;
							//	_unit call Babe_EM_fnc_detect;
							sleep 1;
						};
					};
					sleep 2;
					if (animationState _unit in ["afalpercmstpsraswrfldnon"]) then {
						_unit switchmove "";
						_unit setposASL ([(getposASL _unit),0.5,(getDir _unit)] call BIS_fnc_RelPos);
					};
				};
				//systemchat "oi";

			};


		};
	};
};