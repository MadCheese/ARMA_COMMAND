//with uiNameSpace do {
	KEYVIEWER_VAL = 0;
//};





A3C_UI_ARSENAL_CREATELB = {
	params ["_unit","_doFade"];
	if (_doFade) then {
		titlecut ["","black out",0.2];
		sleep.2;
	};

	A3C_CurrentPlayerObject = player;
	[] call A3C_RADIAL_CloseDisplay;
	A3C_DISABLE_RADIAL = true;
	if (15 in A3C_UI_DOWNKEYS) then {
		("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["A3C_KEY_VIEWER_UI","PLAIN"];
		((uiNamespace getVariable "A3C_KEY_VIEWER_UI") displayCtrl 11) ctrlSetText "Please release TAB";
		waitUntil {!(15 in A3C_UI_DOWNKEYS)};
		("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];

	};

	A3C_DISABLE_RADIAL = false;
	{[_x] call A3C_UNIT_STORE_DESTINATION} foreach (units player);
	selectPlayer _unit;
	(group player) selectLeader player;
	{[_x] call A3C_UNIT_RESUME_DESTINATION} foreach (units player);
	["Open",true] spawn BIS_fnc_arsenal;
	waituntil {_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]); !isNull _arsenalDisplay};
	titlecut ["","black in",0.2];
	_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]);
	_refControl = _arsenalDisplay displayCtrl 995;



	private _lbHeight = (0.033 * safezoneH) ;
	_box1 = _arsenalDisplay ctrlCreate ["A3C_RscCombo",1928];
	_boxPos = ctrlPosition _refControl;
	_boxWidth = _boxPos select 2;
	_boxX = 0.5 - (_boxWidth / 2);
	_boxPos set [0,_boxX];
	_boxPos set [3,_lbHeight];
	_box1 ctrlSetPosition _boxPos;
	_box1 ctrlCommit 0;
	{
		[_box1, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
		if (_x == _unit) then {
			[_box1, _foreachIndex] call A3C_setCurSel;
		};
	} foreach units player;
	_box1 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			_originalUnit = player;
			_newUnit = (units player) select (_this select 1);
			(uiNamespace getVariable ["RscDisplayArsenal", displayNull]) closeDisplay 0;
			[_newUnit,_originalUnit] spawn {
				params ["_newUnit","_originalUnit"];
				titlecut ["","black out",0.2];
				sleep .2;
				waitUntil {player == A3C_CurrentPlayerObject};
				sleep 0.1;

				[_newUnit,false] spawn A3C_UI_ARSENAL_CREATELB;
			};


		}
	];


	waituntil {_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]); isNull _arsenalDisplay};
	{[_x] call A3C_UNIT_STORE_DESTINATION} foreach (units player);
	selectPlayer A3C_CurrentPlayerObject;
	(group player) selectLeader player;
	{[_x] call A3C_UNIT_RESUME_DESTINATION} foreach (units player);


};



MCSS_fnc_CBA_KEYBIND_TRANSLATION = {
	//-- returns a readable string, ie "CTRL + SHIFT + F"
	params ["_addonID","_keyID"];
	_keyData = ([_addonID, _keyID] call CBA_fnc_getKeybind) select 5;
	_keyData params ["_key","_mods"];
	_mods params ["_shift","_ctrl","_alt"];
	private _returnString = "";
	private _modDetected = false;
	{
		if (_x) then {
			switch (_foreachIndex) do {
				case (0) : {
					_returnString = "SHIFT";
					_modDetected = true;
				};
				case (1) : {
					if (_modDetected) then {
						_returnString = _returnString + "+";
					};
					_returnString = _returnString + "CTRL";
					_modDetected = true;
				};
				case (2) : {
					if (_modDetected) then {
						_returnString = _returnString + "+ ";
					};
					_returnString = _returnString + "ALT";
					_modDetected = true;
				};
			};
		};
	} foreach _mods;
	if (_modDetected) then {
		_returnString = _returnString + "+";
	};
	_returnString = call compile format ["parseText '%1 %2'", _returnString, (keyName _key)];
	//_returnString = _returnString + (keyName _key);
	_returnString
};



A3C_TOGGLE_KEYVIEWER = {
	//with uiNameSpace do {
		if (KEYVIEWER_VAL == 0) then {
			("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["A3C_KEY_VIEWER_UI","PLAIN"];
			KEYVIEWER_VAL = 1;
			//
			while {KEYVIEWER_VAL == 1} do {
				_downKeys = A3C_UI_DOWNKEYS;
				_MODIFIERS = [];
				_text = "";
				if (29 in _downKeys) then {_MODIFIERS pushBack "CTRL"};
				if (42 in _downKeys) then {_MODIFIERS pushBack "SHIFT"};
				if (56 in _downKeys) then {_MODIFIERS pushBack "ALT"};
				{
					_text = _text + _x + " + ";
				} foreach _modifiers;
				{
					_addendum = if (_foreachIndex == 0) then {""} else {" + "};
					_text = _text + _addendum + keyName _x;
				} foreach (_downKeys - [29,42,56]);
				((uiNamespace getVariable "A3C_KEY_VIEWER_UI") displayCtrl 11) ctrlSetText _text;
				sleep 0.1;
			};


		} else {
			KEYVIEWER_VAL = 0;
			("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
		};
	//};
};


A3C_UI_HUD_FORM_BUTTON = {
	params ["_mode","_btn"];
	if (_mode == 1) then {
		private ["_handled"];
		//_handled = false;
		_form = A3C_HUD_FORM;
		switch (true) do {
			case (A3C_HUD_Snap && {_form in [0,1]}) : { //-- LINE L/R - changing in open ground allowed 
				if (_btn == 0) then {
					A3C_HUD_FORM = 2;
				} else {
					A3C_HUD_FORM = 8;
				};
			};
			case (_form in [3,4]) : { //-- L-FORM L/R - changing in open ground NOT allowed 
				if (_btn == 0) then {
					A3C_HUD_FORM = 5;
				} else {
					A3C_HUD_FORM = 2;
				};
			};
			case (_form in [5,6]) : { //-- STAG COL L/R - changing in open ground NOT allowed 
				if (_btn == 0) then {
					A3C_HUD_FORM = 7;
				} else {
					A3C_HUD_FORM = 3;
				};
			};
			case (_form == 7) : {
				if (_btn == 0) then {
					A3C_HUD_FORM = 8;
				} else {
					A3C_HUD_FORM = 5;
				};
			};
			default {
				if (_btn == 0) then {
					A3C_HUD_FORM = A3C_HUD_FORM + 1;
				} else {
					A3C_HUD_FORM = A3C_HUD_FORM - 1;
				};
			};
		};
	
		
		_limit = if (A3C_EHM) then {8} else {7};

		if (A3C_HUD_FORM < 0) then {A3C_HUD_FORM = _limit};
		if (A3C_HUD_FORM > _limit) then {A3C_HUD_FORM = 0};
	};
	A3C_HUD_FORM_ICON_COLOR = [0,0,0,0.2];
	A3C_HUD_FORM_ICON_SIZE = 0.8;
	switch (A3C_HUD_FORM) do {
		case (0) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
		};
		case (1) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
		};
		case (2) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Front.paa";
		};
		case (3) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_L_Right.paa";
		};
		case (4) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_L_Left.paa";
		};
		case (5) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";
		};
		case (6) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_StagCol.paa";

		};
		case (7) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Circle.paa";
		};
		case (8) : {
			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\EHM.paa";
			A3C_HUD_FORM_ICON_COLOR = [1,1,1,1];
			A3C_HUD_FORM_ICON_SIZE = 2;
		};

	};
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 12) ctrlSetText A3C_HUD_FORM_ICON;
};



A3C_HUD_STANCE_BUTTONS = {
	params ["_mode","_btn"];
	if (_mode == 0) then {
		if (_btn == 0) then {
			A3C_HUD_STANCE_MODE_TRAVEL = A3C_HUD_STANCE_MODE_TRAVEL - 1;
		} else {
			A3C_HUD_STANCE_MODE_TRAVEL = A3C_HUD_STANCE_MODE_TRAVEL + 1;
		};
		if (A3C_HUD_STANCE_MODE_TRAVEL < 0) then {A3C_HUD_STANCE_MODE_TRAVEL = 4};
		if (A3C_HUD_STANCE_MODE_TRAVEL > 4) then {A3C_HUD_STANCE_MODE_TRAVEL = 0};
	} else {
		if (_btn == 0) then {
			A3C_HUD_STANCE_MODE_DESTINATION = A3C_HUD_STANCE_MODE_DESTINATION - 1;
		} else {
			A3C_HUD_STANCE_MODE_DESTINATION = A3C_HUD_STANCE_MODE_DESTINATION + 1;
		};

		if (A3C_HUD_STANCE_MODE_DESTINATION < 0) then {A3C_HUD_STANCE_MODE_DESTINATION = 4};
		if (A3C_HUD_STANCE_MODE_DESTINATION > 4) then {A3C_HUD_STANCE_MODE_DESTINATION = 0};
	};
	profilenamespace setvariable ["A3C_HUD_STANCE_MODE_TRAVEL",A3C_HUD_STANCE_MODE_TRAVEL];
	profilenamespace setvariable ["A3C_HUD_STANCE_MODE_DESTINATION",A3C_HUD_STANCE_MODE_DESTINATION];

	[_mode] call A3C_HUD_SETSTANCE;
};


A3C_HUD_WPMODE_BUTTON = {
	if (profilenamespace getvariable ['A3C_HUD_MENUOVERRIDE_VAR',true]) then {
		profilenamespace setvariable ['A3C_HUD_MENUOVERRIDE_VAR',false];
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_Add.paa";
		(findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Add To Plans";
	} else {
		profilenamespace setvariable ['A3C_HUD_MENUOVERRIDE_VAR',true];
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 16) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_WPWritingMode_OverWrite.paa";
		(findDisplay 100050 displayCtrl 11) ctrlSetTooltip "MODE: Override Plans";
	};
	[1] call A3C_HUD_GoCode_BUTTON;
};

A3C_UI_HUD_BUTTON = {

	if (profilenamespace getvariable ['A3C_HUD_MENUSHOW_VAR',true]) then {
		profilenamespace setvariable ['A3C_HUD_MENUSHOW_VAR',false];
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_false.paa";
		(findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Hidden";
	} else {
		profilenamespace setvariable ['A3C_HUD_MENUSHOW_VAR',true];
		((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 17) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
		(findDisplay 100050 displayCtrl 13) ctrlSetTooltip "UI: Shown";

	};
};

A3C_HUD_SPEED_BUTTON = {
	if (profilenamespace getvariable ["A3C_HUD_SPEED_VAR",-1] == -1) then {
		A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
		profilenamespace setvariable ["A3C_HUD_SPEED_VAR",2];
		(findDisplay 100050 displayCtrl 15) ctrlSetTooltip "PACE: LIMITED";
	} else {
		A3C_HUD_SPEED_ICON = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
		profilenamespace setvariable ["A3C_HUD_SPEED_VAR",-1];
		(findDisplay 100050 displayCtrl 15) ctrlSetTooltip "PACE: FULL";
	};
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 13) ctrlSetText A3C_HUD_SPEED_ICON;
};

A3C_HUD_GoCode_BUTTON = {
	params ["_mode","_btn"];
	private ["_toolTip"];
	_toolTip = "";
	if !(profilenamespace getvariable ['A3C_HUD_MENUOVERRIDE_VAR',true]) then {
		A3C_HUD_GOCODE_ICON_COLOR = [1,1,1,0.7];
		if (_mode == 0) then {
			if (_btn == 0) then {
				switch (profilenamespace getvariable ["A3C_HUD_GOCODE_VAR","NONE"]) do {
					case ("A") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","B"]};
					case ("B") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","C"]};
					case ("C") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","D"]};
					case ("D") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","NONE"]};
					default {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","A"]};
				};
			} else {
				switch (profilenamespace getvariable ["A3C_HUD_GOCODE_VAR","NONE"]) do {
					case ("A") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","NONE"]};
					case ("B") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","A"]};
					case ("C") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","B"]};
					case ("D") : {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","C"]};
					default {profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","D"]};
				};
			};
		};
		switch (profilenamespace getvariable ["A3C_HUD_GOCODE_VAR","NONE"]) do {
			case ("A") : {A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa"; _toolTip = "GoCode A";};
			case ("B") : {A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa"; _toolTip = "GoCode B";};
			case ("C") : {A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa"; _toolTip = "GoCode C";};
			case ("D") : {A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"; _toolTip = "GoCode D";};
			default {A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa"; _toolTip = "No Condition";};
		};
	} else {
		profilenamespace setvariable ["A3C_HUD_GOCODE_VAR","NONE"];
		A3C_HUD_GOCODE_ICON = "A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";
		A3C_HUD_GOCODE_ICON_COLOR = [1,1,1,0.2];
		_toolTip = "Conditions not available in Override-Mode";
	};
	(findDisplay 100050 displayCtrl 18) ctrlSetTooltip _toolTip;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 14) ctrlSetText A3C_HUD_GOCODE_ICON;
	((uiNamespace getVariable "A3C_HUD_MENU_UI") displayCtrl 14) ctrlSetTextColor A3C_HUD_GOCODE_ICON_COLOR;
};

A3C_UI_RADIAL_OBJECTSELECTOR_START_CHARGEDIALOG = {
	A3C_OBJECTSELECTOR_MODE = "DETONATE_SELECTED_CHARGE_SHARED";
	with uiNamespace do {
		//disableSerialization;
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		// #CURRENTBUG

	};
	
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
	_parent = findDisplay _a3c_dsp displayCtrl 8008;
	_text = findDisplay _a3c_dsp displayCtrl 800802;
	_listBox = findDisplay _a3c_dsp displayCtrl 800803;

	_parent ctrlShow true;
	_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
	_parent ctrlCommit 0;
	_text ctrlSetText "Detonate Charges";
	[] call A3C_UI_RADIAL_OBJECTSELECTOR_LABEL_DETONATIONTARGETS;
};

//-- charge is null object in "A3C_UNIT_EXPLOSIVES" variable
A3C_UI_RADIAL_OBJECTSELECTOR_LABEL_DETONATIONTARGETS = {
	_parent = (findDisplay 100060 displayCtrl 8008);
	_listBox = findDisplay 100060 displayCtrl 800803;
	private _hcAll = A3C_HC_getAllGroups_Player_Current;
	_hcAll pushBackUnique (group player);
	A3C_UI_RADIAL_Current_Remfire_Units = [];
	{
		if (!isPlayer leader _x OR {player == leader _x}) then {
			{
				_u = _x;
				_var = _u getvariable ["A3C_UNIT_EXPLOSIVES",[]];
				if (count _var > 0) then {
					{
						A3C_UI_RADIAL_Current_Remfire_Units pushbackUnique [_u,_x];
					} foreach _var;
				};
			} foreach units _x;
		};

	} foreach _hcAll;
	
	//if (count A3C_UI_RADIAL_Current_Remfire_Units > 4) then {
	//	_parentPos = ctrlPosition _parent;
	//	_parentPos set[3,(_parentPos select 3) + (( count A3C_UI_RADIAL_Current_Remfire_Units)   * (0.0440051 * safezoneH) )];
	//	_parent ctrlSetPosition _parentPos;
	//	_parent ctrlCommit 0;
	//};



	ctrlSetFocus _listBox;
	
	lbClear _listBox;
	private _count = 0;
	//systemchat str A3C_UI_RADIAL_Current_Remfire_Units;
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		[_listBox, "DETONATE ALL CHARGES"] call A3C_addLbEntry;
		_count = 1;
		{
			_x params ["_unit","_charge"];
			//systemchat str _charge;
			_displayName = "";
			{

				if ((typeOf _charge) in _x) exitWith {
					_displayName = _x select 1;
				};
			} foreach A3C_DATA_REMOTE_AMMO;
			_mapGridString = mapgridPosition player;
			_mapGridString = _mapGridString splitString "";
			_mapGridString =
			[
				(_mapGridString select [0,3] joinString ""),
				(_mapGridString select [3,5] joinString "")
			];
			_mapGridString = _mapGridString joinString "-";
			private _lbText = format
			[
				"%1 | %2 | %3",
				_displayName,
				if (group _unit == group player) then {name _unit} else {groupID (group _unit)},
				_mapGridString
			];
			[_listBox, _lbText] call A3C_addLbEntry;
			_count = _count + 1;
		} foreach A3C_UI_RADIAL_Current_Remfire_Units;
	};
	[_parent,_listBox, _count] call A3C_OBJECTSEL_RESIZE;
	
};


A3C_OBJECTSELECTOR_MODE = "DISASSEMBLE";
A3C_HC_FOCUS_ARTY_AMMO = "";
A3C_HC_FOCUS_ARTY_POS = [0,0,0];

A3C_MAP_CONNECTING_ID = "";

A3C_isArtyAwaitingSuborder = false;


A3C_ObjectSelector_LB_Change = {
	params ["_lb"];
	private ["_doubleClick","_tickTime"];
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
	//_vehicle = if (count _this > 1) then {_this select 1) else {};
	_doubleClick = false;
	_tickTime = (time - A3C_LB_TICKTIME);
	_parent = findDisplay _a3c_dsp displayCtrl 8008;
	_text = findDisplay _a3c_dsp displayCtrl 800802;
	_listBox = findDisplay _a3c_dsp displayCtrl 800803;
	if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
		_doubleClick = true;
	};
	//if !(A3C_OBJECTSELECTOR_MODE == "DISASSEMBLE") then {_doubleClick = true;}; //~~ MAY HAVE TO CHANGE THIS!!
	_doubleClick = true; //~~ ??
	A3C_LB_TICKTIME = time;

	if (_doubleClick) then {
		switch (A3C_OBJECTSELECTOR_MODE) do {

			case ("DELETE") : {

				switch (_lb) do {
					case (0) : {
						{
							_gp = _x;
							if ({isPlayer _x} count(units _gp) == 0) then {
								[_gp] call A3C_DeleteGroup;
							} else {
								systemchat format ["A3C: Group %1 was not deleted. Players detected", groupID _gp];
							};
							
						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

						A3C_SELECTED_HC_GROUPS_SETTINGS = [];
					};
				};

				_parent ctrlShow false;
				(findDisplay _a3c_dsp displayCtrl 8008) ctrlShow false;
				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};
				

				

				
			};

			case ("CARGO_WAYPOINTS") : {
				
				
				switch (_lb) do {
					case (0) : {
						//-- YES: fetch cargo groups and prompt to place waypoints
						//-- save unit selection to reestablish later
						
						private _cargoGroups = ([A3C_HC_ACTIVEGROUP] call MCSS_fnc_getCargoGroups) select {private _gpRef = _x; (waypointPosition [_gpRef, currentWaypoint _gpRef]) distance2D [0,0,0] == 0};
						[_cargoGroups] spawn {
							params ["_cargoGroups"];
							private _storedSelection = +(A3C_SELECTED_UNITS); //A3C_SELECTED_HC_GROUPS_SETTINGS
							private _storedMode = A3C_MAP_CommandMode;
							// systemchat str _cargoGroups;
							private _doExit = false;
							{
								private _gpRef = _x;
								A3C_MAP_CommandMode = "HC";
								A3C_SELECTED_HC_GROUPS_SETTINGS = [_gpRef];
								A3C_SELECTED_UNITS = [_gpRef];
								private _str = format ["PLACE WAYPOINT FOR %1  %2", groupID _gpRef, A3C_SELECTED_HC_GROUPS_SETTINGS];
								hint _str;
								waitUntil {hintSilent _str; !visibleMap || {(waypointPosition [_gpRef, currentWaypoint _gpRef]) distance2D [0,0,0] > 0}};
								// systemChat "PROCEED" ;
								if (!visibleMap) exitWith {
									systemchat "MAP CLOSED";
									_doExit = true;
									hintSilent "";
								};
							} foreach _cargoGroups;
							if !(_doExit) then {
								A3C_SELECTED_UNITS = _storedSelection; //-- only override if map was not closed
								A3C_SELECTED_HC_GROUPS_SETTINGS = _storedSelection; //-- only override if map was not closed
								A3C_MAP_CommandMode = _storedMode;
								hint "Done!";
								sleep 2;
								hintSilent "";
							};
							
						};
					};
					case (1) : {
						//-- NO: do nothing
					};
				};
				_parent ctrlShow false;
			};


			


			case ("SPEEDLIMIT") : {
				_gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
				_leaderVic = vehicle leader _gp;
				_speed = switch (_lb) do {
					case (0) : {1000};
					case (1) : {14};
					case (2) : {11};
					case (3) : {5};
				};
				[_leaderVic,_speed] remoteExec ["limitSpeed",_leaderVic];
				_parent ctrlShow false;
			};


			case ("CAS") : {
				_casPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);
				_lbText = _listBox lbText _lb;
				//systemchat str _lbText;
				_casModeNumeric = switch (_lbText) do {
					case ('GUN RUN') : {0};
					case ('MISSILES') : {1};
					case ('GUNS + MISSILES') : {2};
					case ('BOMBING RUN') : {3};
				};



				[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
				private _groups = +(A3C_SELECTED_HC_GROUPS_SETTINGS);
				//systemchat str _groups;
				(findDisplay _a3c_dsp displayCtrl 8008) ctrlShow false;

				if (_groups isEqualTo []) exitWith {};

				player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];
				private _commsOperator = (leader (_groups select 0));
				A3C_CUSTOMRADIO_ID radioChannelAdd [_commsOperator];
				_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];




				//player setpos _casPos;


				{
					_gp = _x;
					_leaderVic = (vehicle leader _gp);
					private _isGroupOnFinalWP = currentWaypoint _gp >= count waypoints _gp;
					private _createReturnWP = _isGroupOnFinalWP && {_casPos distance2D _leaderVic > 50};
					private _landOnReturn  = _createReturnWP && {!isEngineOn _leaderVic};


					//systemchat str [_isGroupOnFinalWP,_createReturnWP,_landOnReturn];
					_wpi = currentWaypoint _gp;
					private _wp =
					[
						_gp,
						_casPos,
						[],
						'MOVE',
						[0,1000,'AUTO','AUTO',-1,'NONE'],
						false,
						_wpi + 1
					] call A3C_HC_ADD_WP;

					//private _wp = _gp addWaypoint [_casPos,0];

					if (_createReturnWP) then {
						private _startPos = position _leaderVic;
						private _wp2 = _gp addWaypoint [_startPos,0];
						if (_landOnReturn) then {
							//-- land with default Arma mechanic upon return
							private _stmts = format
							[
								"
									[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
								",
								_startPos,
								getPlayerUID player

							];
							_wpStm = waypointStatements _wp2;
							_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _stmts];
						};
					};

					private _statements = format
					[
						"
							[this,%1,%2,'%3'] remoteExec ['A3C_HC_distribute_CAS', this];
						",
						A3C_UI_HUD_3D_TAG_ICON_POS,
						_casModeNumeric,
						getPlayerUID player
					];

					_wpStm = waypointStatements _wp;
					_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
				} foreach _groups;







			};





			case ("MULTIWAYPOINT") : {
				A3C_MULTIWAYPOINT = if (_lb == 0) then {true} else {false};
				(findDisplay _a3c_dsp displayCtrl 8008) ctrlShow false;
			};

			case ("DETONATE_SELECTED_CHARGE_SHARED") : {
				//player groupChat "Fire in the hole!";
				player customRadio [A3C_CUSTOMRADIO_ID, "SentCmdDetonate"];
				if (_listBox lbText _lb == "DETONATE ALL CHARGES") then {
					[] spawn {
						sleep 1;
						{
							_x params ["_unit","_charge"];
							private _var = _unit getvariable ["A3C_UNIT_EXPLOSIVES",[]];
							
							//-- AI-Unit radio response
							A3C_CUSTOMRADIO_ID radioChannelAdd [_unit];
							_unit customRadio [A3C_CUSTOMRADIO_ID, "SentConfirmAttack"];

							sleep (1 + (random 1.5));
							detach _charge; //-- detach is global
							sleep 0.1;
							_var = _var - [_charge];
							_unit setvariable ["A3C_UNIT_EXPLOSIVES",_var,if (isPlayer leader group _unit) then {false} else {true}];
							_charge setdamage 1;
						} foreach A3C_UI_RADIAL_Current_Remfire_Units;
						A3C_UI_RADIAL_Current_Remfire_Units = [];
					};
				} else {
					_target = A3C_UI_RADIAL_Current_Remfire_Units select (_lb - 1);
					A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_target];
					_target spawn {
						params ["_unit","_charge"];
						//player commandchat str (typeof _charge);
						//systemchat str (local _charge);

						//-- AI-Unit radio response
							
						A3C_CUSTOMRADIO_ID radioChannelAdd [_unit];
						_unit customRadio [A3C_CUSTOMRADIO_ID, "SentConfirmAttack"];
						sleep 1;
						private _var = _unit getvariable ["A3C_UNIT_EXPLOSIVES",[]];
						sleep (1 + (random 1.5));
						detach _charge;
						sleep 0.1;
						_var = _var - [_charge];
						for "_i" from 1 to 10 do {
							_charge setdamage 1;
						};

						_unit setvariable ["A3C_UNIT_EXPLOSIVES",_var,if (isPlayer leader group _unit) then {false} else {true}];

						[] call A3C_UI_RADIAL_OBJECTSELECTOR_LABEL_DETONATIONTARGETS;
					};
				};

			};
			/*
			case ("HELI_OVERWATCH_1") : {
				//-- ask for details
				A3C_Heli_Overwatch_Height = parseNumber (_listBox lbText _lb);
				_text ctrlSetText "Select Overwatch Direction";
				{
					_ctrlPos = ctrlPosition _x;
					_ctrlPos set [3,(_ctrlPos select 3) + (  (1)   * (0.0440051 * safezoneH) )];
					_x ctrlSetPosition _ctrlPos;
					_x ctrlCommit 0;
				} foreach [_parent,_listBox];
				
				lbClear _listBox;
				{
					[_listBox, _x] call A3C_addLbEntry;
				} foreach ["NORTH","NORTH-EAST","EAST","SOUTH-EAST","SOUTH","SOUTH-WEST","WEST","NORTH-WEST"];
				
				A3C_OBJECTSELECTOR_MODE = "HELI_OVERWATCH_2";
			};
			case ("HELI_OVERWATCH_2") : {
				//_direction = ["NORTH","NORTHEAST","EAST","SOUTHEAST","SOUTH","SOUTHWEST","WEST","NORTHWEST"] select _lb;

				
				
				_direction = switch (_lb) do {
					case (0) : {0};
					case (1) : {45};
					case (2) : {90};
					case (3) : {135};
					case (4) : {180};
					case (5) : {225};
					case (6) : {270};
					case (7) : {315};
				};
				private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

				private _var = (vehicle leader A3C_HC_ACTIVEGROUP ) getVariable ["A3C_Freeze_helicopter",[false,0]];
				private _calledFromWaypointMenu = if (_var select 1 == -1) then {true} else {false}; //-- rather unconventional method of knowing if the action was called from wp-menu

				if (_a3c_dsp in [100020,100030]) then {
					_parent ctrlShow false;
					if (_calledFromWaypointMenu) then {
						
						_group = A3C_HC_ACTIVEGROUP;
						_wp = [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND];
						_wp setWaypointtype "SCRIPTED";
						_wp setWaypointStatements ["true",""]; //[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND]
						private _cond = _var select 2;
						_wpScript = format 
						[
							"A3C_CORE\fnc_AI\wpFncs\wpScript_heli_overwatch.sqf ['%1',%2,%3,%4,'%5']",
							getPlayerUID player,
							_direction,
							A3C_Heli_Overwatch_Height,
							_cond,
							A3C_HC_ACTIVE_FORM_POST
						];
						_wp setWaypointScript _wpScript;
						[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];
					} else {

						

						[_group,A3C_Heli_Overwatch_Height,_direction] spawn {
							params ["_group","_overwatch_height","_direction"];
							
							//-- start action
							{
								_vehicle = vehicle _x;
								if (_x == driver _vehicle && {[_vehicle] call A3C_isAttackHelicopter}) then {
									//00 disable movement
									{_vehicle disableAI _x; } foreach ["TARGET","PATH"]; //,  ["ALL"] ,,"AUTOTARGET","FSM","SUPPRESSION","COVER","AUTOCOMBAT","MOVE"
									//-- rotate chopper
									private _targetPos = _vehicle getPos [1000,_direction];
									_vehicle domove _targetPos;
									_vehicle setVariable ["A3C_Freeze_helicopter",[true,_direction],true];
									_heliHeight = (getPosVisual _vehicle) select 2;

									_adjustZvelocity = if (_heliHeight < _overwatch_height) then {7} else {-7};
									//-- adjust altitude
									[_vehicle,_overwatch_height,_adjustZvelocity] spawn {
										params ["_vehicle","_overwatch_height","_adjustZvelocity"];
										while {abs ((getposATL _vehicle select 2) - _overwatch_height) > 20} do {
											_vehicle setVelocity [0,0,_adjustZvelocity];
											private _var = _vehicle getVariable ["A3C_Freeze_helicopter",[false,0]];
											if !(_var select 0) exitWith {};
										};
									}; //-- after action is done, heli automatically adjusts altitude
								};
							} foreach (units _group);
						
							
						};
					};

					
				} else {

				};
				A3C_OBJECTSELECTOR_MODE = "";
				
			};
			//["TARGET","AUTOTARGET","FSM","SUPPRESSION","COVER","AUTOCOMBAT","PATH"] //"MOVE",
			*/
			case ("ARTY_0") : {
				
				A3C_OBJECTSELECTOR_MODE = "ARTY_1";

				private _lbText = _listBox lbText _lb;
				

				A3C_HC_FOCUS_ARTY_AMMO_ARRAY = (getArtilleryAmmo MCSS_REMOTE_ARTILLERY_ARRAY) select
				{
					private _displayName = getText (configfile >> "CfgMagazines" >> _x >> "displayName");
					_displayName == _lbText
				};
				//{} foreach ;
				lbClear _listBox;
				//if (true) exitWith {};
				_text ctrlSetText "Select amount of shells";
				ctrlSetFocus _listBox;


				_ammoAmount = 0;
				private _shellDSPs = ([true,true,A3C_HC_FOCUS_ARTY_POS] call A3C_getArtilleryAmmo) select {_x select 0 == _lbText};

				if !(_shellDSPs isEqualTo []) then {
					_selectedShell = _shellDSPs select 0;
					_ammoAmount = (_selectedShell select 1) min 100;

					// systemChat format ["Ammo Amount arty_0 (HUD_UI): %1", _ammoAmount];

					private _candidates = [1,2,3,4,8,10,20,30,40,50,75,100];
					private _lbEntries = [];

					{
						if (_x <= _ammoAmount) then {
							_lbEntries pushBack _x;
						};
					} forEach _candidates;

					// Always ensure the full available amount is the last option.
					if (_ammoAmount > 0 && !(_ammoAmount in _lbEntries)) then {
						_lbEntries pushBack _ammoAmount;
					};

					{
						[_listBox, str _x] call A3C_addLbEntry;
					} forEach _lbEntries;

					[_parent, _listBox, count _lbEntries] call A3C_OBJECTSEL_RESIZE;
				};




				

			};

			case ("ARTY_1") : {
				A3C_HC_FOCUS_ARTY_AmmoCount = call compile (_listBox lbText _lb);
				(findDisplay _a3c_dsp displayCtrl 8008) ctrlShow false;
			

				
				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};


				[A3C_HC_FOCUS_ARTY_POS,false] spawn A3C_ORDER_ARTILLERY

				

				
			};

			case ("CTRL_DET") : {
				private _chargeDisplayName = _listBox lbText _lb;
				private _chargeMagName = "";
				_parent ctrlShow false;
				//_parent ctrlsetposition [100,100];
				 (findDisplay 12 displayCtrl 51) ctrlEnable true;
				 _parent spawn { //-- no idea why it has to be like this. some executing thing i don't grasp. After drop on targetvehicle, parent will not close otherwise.
					 for "_i" from 1 to 10 do {
						_this ctrlShow false;
						sleep 0.1;
					};
				};

				//(findDIsplay 100020 displayCtrl 8008) ctrlSHow false;
				{
					private _soldier = _x;
					{
						if ((getText (configfile >> "CfgMagazines" >> _x >> "displayName")) == _chargeDisplayName) exitWith {
							_chargeMagName = _x; //-- dirty workaround to retrieve classname from displayname. has to happen first so all units receive same data

						};
					} foreach (magazines _soldier);
				} foreach A3C_SELECTED_UNITS;
				{
					private _soldier = _x;
					private _var = _soldier getVariable ["A3C_PLOT_TEMP",[]];
					{
						_mainMarkerID = format ['%1',parseText ((_x select 1) select 0)]; ;// +;
						_wpAction = _x select 2;
						if (_mainMarkerID == A3C_MAP_CONNECTING_ID) exitWith {
							if (_wpAction select 0 == "CTRL_DET") then {
								(_wpAction select 1) set [1,_chargeMagName];
							};
						};
					} foreach _var;
					_soldier setVariable ["A3C_PLOT_TEMP",_var,true];

				} foreach A3C_SELECTED_UNITS;
				A3C_MAP_CONNECTING_ID = "";

			};
			case ("PARALOAD") : {
				private ["_vehicle","_cargoObjects"];
				_vehicle = vehicle (leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0));
				_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
				_vicToLoad = _cargoObjects select _lb;
				[_vehicle,_vicToLoad] call A3C_LoadVehicleCargo;
				_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
				lbClear _listBox;
				if (count _cargoObjects > 0) then {
					
					{
						private _lbText = getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName");
						[_listBox, _lbText] call A3C_addLbEntry;
					} foreach _cargoObjects;
					
				} else {
					_parent ctrlShow false;
				};
			};
			case ("PARALOAD_SQ") : { //~~SLOPPY!
				private ["_vehicle","_cargoObjects"];
				_vehicle = vehicle A3C_SQ_CLICKED_UNIT;
				_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
				_vicToLoad = _cargoObjects select _lb;
				[_vehicle,_vicToLoad] call A3C_LoadVehicleCargo;
				_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
				lbClear _listBox;
				if (count _cargoObjects > 0) then {
					
					{
						private _lbText = (getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName"));
						[_listBox, _lbText] call A3C_addLbEntry;
					} foreach _cargoObjects;
					
				} else {
					_parent ctrlShow false;
				};
			};
			case ("flyInHeight") : {
				private _gp =  (A3C_SELECTED_HC_GROUPS_SETTINGS select 0);
				
				
				private _wpCurr = [_gp, currentWaypoint _gp];
				private _wpType = waypointType _wpCurr;
				private _wpPos = if (_wpType != "") then {waypointPosition _wpCurr} else {
					((getPosASL (vehicle leader _gp)) select [0,2]) + [0]
				}; //-- avoid [0,0,0] clash
				
				//-- #FLYINHEIGHTASL
				private _height = parseNumber (_listBox lbtext _lb);
				
				// _height = if (surfaceIsWater _wpPos) then {_height} else {((ATLtoASL _wpPos) select 2) + _height};
				//systemchat str (( _height));
				{
					private _v = (vehicle _x);
					if (_x == driver _v && {_v isKindOf "AIR"}) then {
						// //if (waypointType _wpCurr == "LOITER") then {
						// 	//systemchat str _height;
						// 	[_v,[_height,_height,_height]] remoteExec ["flyInHeightASL", _v];
						// //} else {
						// //	[_v,_height] remoteExec ["flyInHeight", _v];
						// //};
						[_v, _height] remoteExec ["flyInHeight", _v];
						_v setVariable ["A3C_FLYINHEIGHT",_height,true];
						// systemchat format ["A3C_ObjectSelector_LB_Change: FlyinHeight :%1", _height];
					};
				} foreach (units _gp);
				_parent ctrlShow false;
				//with uiNamespace do {
				//	(findDisplay 100060) closeDisplay 0;
				//};
			};
			case ("LOITER_DIR") : {
				A3C_OBJECTSELECTOR_MODE = "LOITER_RAD";
				_text ctrlSetText "Select Loiter Radius";
				switch (_lb) do {
					case (0) : {A3C_LoiterDir = "CIRCLE"};
					case (1) : {A3C_LoiterDir = "CIRCLE_L"};
				};
				ctrlSetFocus _listBox;
				
				lbClear _listBox;
				_textSize = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
				{
					_ctrlPos = ctrlPosition _x;
					if (_foreachIndex == 0) then {
						_ctrlPos set [0,0.383108 * safezoneW + safezoneX];
						_ctrlPos set [1,0.378986 * safezoneH + safezoneY];
					};
					
					_ctrlPos set [3,_textSize * 6];
					
					_x ctrlSetPosition _ctrlPos;
					_x ctrlCommit 0;
				} foreach [_parent,_listBox];

				{
					[_listBox, _x] call A3C_addLbEntry;
				} foreach ["100","500","1000","2000"];
				
			};
			case ("LOITER_RAD") : {
				switch (_lb) do {
					case (0) : {A3C_LoiterRadius = 100};
					case (1) : {A3C_LoiterRadius = 500};
					case (2) : {A3C_LoiterRadius = 1000};
					case (3) : {A3C_LoiterRadius = 2000};
				};
				_parent ctrlShow false;
			};
			case ("SECU_REJOIN") : {
				_parent ctrlShow false;
				switch (_lb) do {
					case (0) : {A3C_LoiterRadius = 100};
					case (1) : {
						[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_REJOIN_GROUPS
					};

				};
			};

			case ("STATIC_ASSEMBLE_SQUAD") : {
				_weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {(getText (configfile >> "CfgVehicles" >> (A3C_STATIC_PACKS select 0) select 1 >> "displayName"))} else {_listBox lbText _lb};
				[] call A3C_RADIAL_CloseDisplay;
				{player groupSelectUnit [_x,false]} foreach units player;
				showCommandingMenu "";

				{
					_weapon = _x select 1;
					if ((getText (configfile >> "CfgVehicles" >> _weapon >> "displayName")) == _weaponToAssemble) exitWith {
						A3C_STATIC_PACKS = [_x];
						A3C_OBJECTPLACER_DIR = getDir cameraOn;
						A3C_OBJECTPLACER = _weapon createVehicleLocal (screenToWorld [0.5,0.5]);
						A3C_OBJECTPLACER enablesimulation false;
						A3C_OBJECTPLACER disableCollisionWith (vehicle cameraOn);
						if (!isNull A3C_OBJECTPLACER) then {
							A3C_DISABLE_RADIAL = true;
						};
					};
				} foreach A3C_STATIC_PACKS;

				_parent ctrlShow false;
				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};

			};
			case ("STATIC_DISASSEMBLE_SQUAD") : {
				_chargeDisplayName = _listBox lbText _lb;
				_weapon = (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics) select _lb;

				[
					A3C_UI_RADIAL_Current_Remfire_Units,
					_weapon
				] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;
				
				A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  typeOf _weapon >> "picture");
				A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
				[position _weapon,""] spawn A3C_UI_HUD_3D_TAG;

				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};

			};
			case ("STATIC_ASSEMBLE_HC") : {

				_weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {(getText (configfile >> "CfgVehicles" >> (A3C_STATIC_PACKS select 0) select 1 >> "displayName"))} else {_listBox lbText _lb};
				//systemchat str _weaponToAssemble;
				[] call A3C_RADIAL_CloseDisplay;
				{player groupSelectUnit [_x,false]} foreach units player;
				showCommandingMenu "";
				{
					_weapon = _x select 1;

					if ((getText (configfile >> "CfgVehicles" >> _weapon >> "displayName")) == _weaponToAssemble) exitWith {


						A3C_STATIC_PACKS = [_x];
						A3C_OBJECTPLACER_DIR = getDir cameraOn;
						A3C_OBJECTPLACER = _weapon createVehicleLocal (screenToWorld [0.5,0.5]);

						A3C_OBJECTPLACER enablesimulation false;
						A3C_OBJECTPLACER disableCollisionWith (vehicle cameraOn);


						if (!isNull A3C_OBJECTPLACER) then {
							A3C_DISABLE_RADIAL = true;
						};

					};
				} foreach A3C_STATIC_PACKS;

				_parent ctrlShow false;
				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};

			};
			case ("STATIC_DISASSEMBLE_HC") : {
				[1,(A3C_HC_NearStatics select _lb)] spawn A3C_HC_UnassembleWeapon;
				_parent ctrlShow false;
				player commandRadio "SentDisAssemble";
				systemchat format
				[
					"%1 is packing up a %2",
					groupId (A3C_SELECTED_HC_GROUPS_SETTINGS select 0),
					(getText (configfile >> "CfgVehicles" >> (typeOf (A3C_HC_NearStatics select _lb)) >> "displayName"))
				];
			};
			case ("PLACE_CHARGE_SQUAD") : {
				_chargeDisplayName = _listBox lbText _lb;
				_demoUnits = [];
				private _magName = "";
				{
					private _soldier = _x;
					{
						private _testedMagName = _x;
						if ((getText (configfile >> "CfgMagazines" >> _testedMagName >> "displayName")) == _chargeDisplayName) exitWith {
							_demoUnits pushbackUnique _soldier;
							_magName = _testedMagName;
						};
					} foreach magazines _x;
				} foreach A3C_RD_UNITS;

				private _unit = _demoUnits select 0;

				player groupradio "SentCmdPlaceCharge";
				[[_unit],true,false] call A3C_CANCELPLANS;



				private _expD = [_unit] call A3C_UNIT_STORE_DESTINATION;


				_detoObject = if ({cursorTarget isKindOf _x} count ["AIR","CAR","TANK","WHEELED","ARMORED","MOTORCYCLE"] > 0) then {cursorTarget} else {objNull};
				_detoPosition =  A3C_UI_HUD_3D_TAG_ICON_POS;//if (!isNull cursorTarget) then {position cursortarget} else {screentoWorld [0.5,0.5]};
				
				
				/////////////////////////////////////////////

				_detoObject = cursorTarget; //-- either object or objNull
				_detoInfo = [];
				//-- prevent accidental attachment to moving soldiers
				if (_detoObject isKindOf "MAN") then {
					_detoObject = objNull;
				};
				_ins = lineIntersectsSurfaces [
					AGLToASL positionCameraToWorld [0,0,0],
					AGLToASL positionCameraToWorld [0,0,1000],
					player,
					objNull,
					true,
					1,
					"GEOM",
					"NONE"
				];

				_ins = _ins select {!(_x select 2 isKindOf "MAN")}; //-- ignore accidental men running by

				if !(_ins isEqualTo []) then {
					_ins = _ins select 0; //-- limit to first intersect
					_ins params ["_insPos","_surfaceNormal","_intersectObject"];
					_detoObject = _intersectObject;
					_detoInfo = [_insPos, _surfaceNormal];
				};

				/////////////////////////////////////////////



				_mainMark = "A3C_SQ_" + (str (random 10000000000));
				_data =
				[
					[
						[_detoPosition,_detoPosition getPos [50,0]], //-- positions
						[_mainMark,"",""], //-- markers
						["CTRL_DET",[_detoObject,_magName, _detoInfo]], //-- wp action
						["NONE","NONE"], //--WP Condition
						["UP","UP"], //-- WP Stances
						[[0,false]], // WP Sync Data
						true, //-- isWPCompleted
						0, //-- Combat Mode
						-1, //-- WP SPeed
						25, //-- WP Flying Height
						-1, //-- WP Loop Value
						0 // -- radius (for circle, not completion)
					]
				];


				_parent ctrlShow false;
				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};

				[_unit,_data] spawn {
					params ["_unit","_data"];
					waitUntil {count (_unit getvariable 'A3C_PLOT') == 0};
					_unit setvariable ["A3C_PLOT",_data,true];
					_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_MOVE);
					private _hasReached = false;
					private _exit = false;
					private _doReturnToOrders = true;
					while {alive _unit} do {
						if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {_hasReached = true};
						if (scriptDone _scr) exitWith {};
						if (_hasReached) then {
							if ( animationState _unit != "ainvpknlmstpslaywrfldnon_medic") then {
								sleep 3;
								_exit = true;
								if ( count (_unit getvariable 'A3C_PLOT') > 0 ) then {
									_doReturnToOrders = false;
								};
							};
						};
						if (_exit) exitWith {};
						sleep 1;
					};
					if (_doReturnToOrders) then {
						[_unit] call A3C_UNIT_RESUME_DESTINATION;
					};
				};
				private _magPic = getText (configfile >> "CfgMagazines" >>  _magName >> "picture");
				//systemchat str [_magPic];
				A3C_UI_HUD_3D_TAG_ICON_TYPE = if (_magPic == "") then {A3C_UI_HUD_3D_TAG_ICON_TYPE} else {_magPic};
				[ _detoPosition,"DEMOLITION"] spawn A3C_UI_HUD_3D_TAG; //A3C_UI_HUD_3D_TAG_ICON_POS
			};
			case ("PLACE_CHARGE_HC") : {
				private _magName = "";
				private _chargeDisplayName = _listBox lbText _lb;
				{

					private _testedMagName = _x;
					if ((getText (configfile >> "CfgMagazines" >> _testedMagName >> "displayName")) == _chargeDisplayName) exitWith {
						_magName = _testedMagName;
					};
				} foreach A3C_REMFIRE_MAGTYPES;

				{
					private _gp = _x;
					_gp setvariable ["A3C_UNIT_POLYS",[],true];

					//-- clear all waypoints
					{
						{
							_x setVariable ["A3C_CLEARING",false,true];
						} foreach (units _x);
					} foreach A3C_SELECTED_UNITS;


					_gp = A3C_RD_UNITS select 0;
					while {(count (waypoints _gp)) > 1} do {
						{
							if (_forEachIndex > 0) then {
								deletewaypoint _x;
							};
						} foreach waypoints _gp;
					};


					_wp =
					[
						_gp,
						ASLtoATL A3C_UI_HUD_3D_TAG_ICON_POS
					] call A3C_HC_ADD_WP;

					_cursorObject = if (!isNull cursortarget && {{cursorTarget isKindOf _x} count ["CAR","TANK","SHIP","AIR","MOTORCYCLE"] > 0}) then {cursorTarget} else {objNull};
					[_cursorObject] call MCSS_fnc_setVehicleVarname;
					_statements = format
					[
						"
							[[group this,'%1'], A3C_WP_ACTION_PlantExplosive_HC] remoteExec ['bis_fnc_call',0];
						",
						_magName
					];

					_wpStm = waypointStatements _wp;
					_wp waypointAttachVehicle _cursorObject;
					_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];

					_wp2 =
					[
						_gp,
						getpos (vehicle leader _gp)
					] call A3C_HC_ADD_WP;
				} foreach A3C_RD_UNITS;

				player groupradio "SentCmdPlaceCharge";
				private _magPic = getText (configfile >> "CfgMagazines" >>  _magName >> "picture");
				A3C_UI_HUD_3D_TAG_ICON_TYPE = if (_magPic == "") then {A3C_UI_HUD_3D_TAG_ICON_TYPE} else {_magPic};
				[A3C_UI_HUD_3D_TAG_ICON_POS,"DEMOLITION"] spawn A3C_UI_HUD_3D_TAG; //A3C_UI_HUD_3D_TAG_ICON_POS

				with uiNamespace do {
					(findDisplay 100060) closeDisplay 0;
				};
			};
			case ("PLACE_CHARGE_HC_MAP") : {
				private _chargeDisplayName = _listBox lbText _lb;
				private _magName = "";
				{

					private _testedMagName = _x;
					if ((getText (configfile >> "CfgMagazines" >> _testedMagName >> "displayName")) == _chargeDisplayName) exitWith {
						_magName = _testedMagName;
					};
				} foreach A3C_REMFIRE_MAGTYPES;
				private _statements = [];

				A3C_HC_DETONATION_BOOL = true;
				[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] waypointAttachVehicle objNull;
				//-- step 1: set deto on waypoint (no target)
				_statements = waypointStatements [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND];
				_statements =
				[
					_statements select 0,
					format
					[
						"
							[(group this)] call A3C_HC_FNC_CompleteWaypoint;
							[[group this,'%1'], A3C_WP_ACTION_PlantExplosive_HC] remoteExec ['bis_fnc_call',0];
						",
						_magName
					]
				];
				[A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND] setWaypointStatements _statements;
				
				(findDisplay _a3c_dsp displayCtrl 8008) ctrlShow false;
			};

			case ("HELI_LANDING_HC_TYPE") : {
				_hideParent = true;
				_landingRailType = "";
				_landingRailType = _listBox lbText _lb;
				switch (_landingRailType) do {
					case ("COMBAT LANDING") : {
						//A3C_RADIALACTION_landingRailType = "COMBATLANDING";
						A3C_OBJECTSELECTOR_MODE = "HELI_LANDING_GOCODE";
						_hideParent = false;
						_text ctrlSetText "SELECT GO-CODE";

						ctrlSetFocus _listBox;
						
						lbClear _listBox;
						{
							[_listBox, _x] call A3C_addLbEntry;
						} foreach ["GO-CODE A","GO-CODE B","GO-CODE C","GO-CODE D"];
						


					};
				};
				if (_hideParent) then {
					_parent ctrlShow false;
					[_landingRailType,""] spawn A3C_RADIAL_ACTION_HC_LANDING_FNC;
				};
			};
			case ("HELI_LANDING_GOCODE") : {
				_parent ctrlShow false;
				//systemchat str A3C_SELECTED_HC_GROUPS_SETTINGS;
				_condition = _listBox lbText _lb;
				["COMBAT LANDING",_condition] spawn A3C_RADIAL_ACTION_HC_LANDING_FNC; //-- condition is goCOde type a,b,c,d
			};
		};
	};
};

A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

//A3C_UI_HUD_3D_TAG_ICON_TYPE = "";

A3C_RADIAL_ACTION_HC_LANDING_FNC = {
	params ["_landingRailType","_condition"];
	//player commandchat str (!isNull A3C_OBJECTPLACER);

	_landingData = +(A3C_RADIAL_ACTION_HC_LANDINGDATA);
	A3C_RADIAL_ACTION_HC_LANDINGDATA = [];
	_landingData params ["_landingPosRoot","_landingVector","_forceDefaultLanding"];

	A3C_UI_HUD_3D_TAG_ICON_TYPE =  "\a3c_ui\markers\HeliPad.paa";
	[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
	private _groups = +(A3C_SELECTED_HC_GROUPS_SETTINGS);

	_distributedPositions = [_landingPosRoot,_groups,count _groups,_landingPosRoot getDir (leader (_groups select 0)),100 ] call A3C_create_wpWedgePositions;

	private _occupiedLandingPoses = [_landingPosRoot]; //[A3C_UI_HUD_3D_TAG_ICON_POS];
	//private _landingPosRoot = +(A3C_UI_HUD_3D_TAG_ICON_POS);
	{
		private _gp = _x;
		private _leader = leader _gp;

		_leaderVic = vehicle _leader;

		private _groupForeachIndex = _forEachIndex;

		if (_groupForeachIndex > 0) then {
			_forceDefaultLanding = true; //-- make sure that only one vehicle can land precisely (obsolete checkl?)
		};

		// make specific landingpos available only for single group selections and only leadvic. multiple group selections revert to arma landing

		//-- for full landings, delete all other waypoints
		if (_landingRailType == "FULL LANDING") then {

			_gp setvariable ["A3C_UNIT_POLYS",[],true];
			//-- clear all waypoints
			{
				{
					_x setVariable ["A3C_CLEARING",false,true];
				} foreach (units _x);
			} foreach A3C_SELECTED_UNITS;

			//_gp = A3C_RD_UNITS select 0;
			while {(count (waypoints _gp)) > 1} do {
				{
					if (_forEachIndex > 0) then {
						deletewaypoint _x;
					};
				} foreach waypoints _gp;
			};
		};




		//-- add new waypoints
		private _leaderVic = (vehicle _leader);
		private _landingWPos = _distributedPositions select _groupForeachIndex; //([_landingPosRoot,[0,100]] call MCSS_fnc_getSafePos)

		private _isGroupOnFinalWP = currentWaypoint _gp >= count waypoints _gp;
		private _createReturnWP = (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) && {_isGroupOnFinalWP && {_landingWPos distance2D _leaderVic > 50}};
		private _landOnReturn  = _createReturnWP && {!isEngineOn _leaderVic};



		_wpi = currentWaypoint _gp;

		//private _wp =
		//[
		//	_gp,
		//	_landingWPos,
		//  [],
		//	'MOVE',
		//	[0,1000,'AUTO','AUTO',-1,'NONE'],
		//	false,
		//	_wpi + 1
		//] call A3C_HC_ADD_WP;
		private _wp = _gp addWaypoint [_landingWPos,0];


		if (_createReturnWP) then {
			private _startPos = position _leaderVic;
			private _wp2 = _gp addWaypoint [_startPos,0];
			//private _wp2 =
			//[
			//	_gp,
			//	_startPos,
			//  [],
			//	'MOVE',
			//	[0,1000,'AUTO','AUTO',-1,'NONE'],
			//	false,
			//	_wpi + 2
			//] call A3C_HC_ADD_WP;
			if (_landOnReturn) then {
				//-- land with default Arma mechanic upon return
				private _stmts = format
				[
					"
						[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
					",
					_startPos,
					getPlayerUID player

				];
				_wpStm = waypointStatements _wp2;
				_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _stmts];
			};
		};

		private _statements = "";


		if (_groupForeachIndex == 0 && {!(_forceDefaultLanding)}) then {
			_subCondition = if (_landingRailType == "COMBAT LANDING") then {format ["A3C_GoCode_Activate_%1",((_condition splitstring "") select 8)]} else {""};

			//-- assumption: waypointScript gets executed on every machine - if the script is present
			//-- assumption 2: a function can be remo tely executed from the machine that executed the script (needs to be determined?
			_wp setWaypointType "SCRIPTED";
			//_wp setWayPointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_railedHeliLanding.sqf [1,2,3]";
			_wp setWayPointScript format
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_railedHeliLanding.sqf ['%1',%2,%3,'%4',%5,'%6']",
				getPlayerUID player,
				["ARRIVAL",""],
				["ARRIVAL",""],
				_landingRailType,
				_landingData,
				_subCondition
			];
		} else {
			switch (_landingRailType) do {
				case ("COMBAT LANDING") : {
					_subCondition = ((_condition splitstring "") select 8);
					//;
					_statements = format
					[
						"
							[['%1',this,[['GoCode','%2'],'COMBATLANDING'],'LINE',(currentwaypoint (group this))],A3C_HC_INSERT_ACTION_WP,nil,false] remoteExec ['bis_fnc_call',0];
							[(group this)] call A3C_HC_FNC_CompleteWaypoint
						",
						getPlayerUID player,
						_subCondition
					];
					A3C_GOCODES_HC pushbackUnique _subCondition;
					publicVariable 'A3C_GOCODES_HC';
					[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];

				};
				case ("TRANSPORT UNLOAD") : {
					_wp setWaypointType "TR UNLOAD";
					_statements = "[(group this)] call A3C_HC_FNC_CompleteWaypoint;  ";
				};//deleteWaypoint [group this, currentWaypoint group this];
				case ("FULL LANDING") : {
					//systemchat str (_landingData select 0);
					_statements = format
					[
						"
							[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
							[(group this)] call A3C_HC_FNC_CompleteWaypoint;
						",
						_landingData select 0,
						getPlayerUID player

					];
				};
			};

		};
		if (_statements != "") then {
			_wpStm = waypointStatements _wp;
			_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
		};


		sleep 1;
	} foreach _groups;
};


A3C_UI_HUD_3D_TAGGING = false;
A3C_UI_HUD_3D_TAG = {
	params ["_pos","_mode"];
	A3C_UI_HUD_3D_TAGGING = true;
	_iconType = A3C_UI_HUD_3D_TAG_ICON_TYPE;
	//private _iconType = switch (_mode) do {
	//	case ("DEMOLITION") : {"\a3\ui_f\data\IGUI\Cfg\Cursors\explosive_ca.paa"};
	//	default {A3C_UI_HUD_3D_TAG_ICON_TYPE};
	//};
	A3C_UI_HUD_3D_TAG_ICON_COL = switch (_mode) do {
		case ("DEMOLITION") : {[1,1,1,0.7]};
		//case ("HC_WP") : {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_Color_setOpacity};
		case ("BOARD") : {[A3C_UI_COLOR_YELLOW,0.7] call A3C_UI_Color_setOpacity};
		case ("SUPPRESSION") : {[A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity};
		default {A3C_UI_HUD_3D_TAG_ICON_COL};
	};
	if (!isNull cursorTarget && {(_mode in ["DEMOLITION","BOARD"])}) then {
		_pos = getPos cursorTarget;
		_pos set [2,((boundingbox cursortarget select 1) select 2) / 2];
	};

//	A3C_UI_HUD_3D_TAG_ICON_POS = _pos;
//	private _max = 50;
//	private _sz = 5;
	//if (_mode in ["HC_WP","SUPPRESSION"]) then {
	//	_sz = 3;
//
//		while {A3C_UI_HUD_3D_TAG_ICON_SIZE < _sZ} do {
//			A3C_UI_HUD_3D_TAG_ICON_SIZE = A3C_UI_HUD_3D_TAG_ICON_SIZE + 0.2;
//			sleep 0.01;
//		};
//	};

	//-- animate icon zoom
	if !(_mode in ["HC_WP","SUPPRESSION"]) then {
		_timer = time;
		_animLength = 3;
		while {time - _timer < _animLength} do {
			A3C_UI_HUD_3D_TAG_ICON_POS = _pos;
			_t = (_animLength - (time - _timer)) / _animLength;
			A3C_UI_HUD_3D_TAG_ICON_SIZE = (4 * _t) max 2;
			if (A3C_UI_HUD_3D_TAG_ICON_SIZE == 2) exitWith {};
			//hintSilent str A3C_UI_HUD_3D_TAG_ICON_SIZE;
		};
	};

	//if !(_mode in ["HC_WP","SUPPRESSION"]) then {
	//	for "_i" from 1 to _max do {
	//		sleep 0.01;
	//		A3C_UI_HUD_3D_TAG_ICON_SIZE = _sz - ((_sZ - 2) * (_i / _max));
	//
	//	};
	//};
	
	//-- end flicker
	for "_i" from 1 to 4 do {
		A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
		sleep 0.1;
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
		sleep 0.1;
	};
	//-- reset vars to default
	A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
	A3C_UI_HUD_3D_TAG_ICON_SIZE = 3;
	A3C_UI_HUD_3D_TAG_ICON_POS = [0,0,0];
	A3C_UI_HUD_3D_TAG_ICON_MOD = "NONE";
	A3C_UI_HUD_3D_TAGGING = false;
};

