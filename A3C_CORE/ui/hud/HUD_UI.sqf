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
	[] call A3C_UI_RADIAL_CloseDisplay;
	A3C_DISABLE_RADIAL = true;
	if (15 in A3C_UI_DOWNKEYS) then {
		("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["A3C_KEY_VIEWER_UI","PLAIN"];
		((uiNamespace getVariable "A3C_KEY_VIEWER_UI") displayCtrl 11) ctrlSetText "Please release TAB";
		waitUntil {!(15 in A3C_UI_DOWNKEYS)};
		("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutText ["","PLAIN"];

	};

	A3C_DISABLE_RADIAL = false;
	{[_x] call A3C_fnc_setDestination} foreach (units player);
	selectPlayer _unit;
	(group player) selectLeader player;
	{[_x] call A3C_AI_action_resumeDestination} foreach (units player);
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

	//-- NOTE: This EH actually needs to be added each time since it only exists during display lifetime.
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
	{[_x] call A3C_fnc_setDestination} foreach (units player);
	selectPlayer A3C_CurrentPlayerObject;
	(group player) selectLeader player;
	{[_x] call A3C_AI_action_resumeDestination} foreach (units player);


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



//-- charge is null object in "A3C_UNIT_EXPLOSIVES" variable
A3C_UI_RADIAL_OBJECTSELECTOR_LABEL_DETONATIONTARGETS = {
	_parent = (findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_Parent);
	_listBox = findDisplay 100060 displayCtrl IDC_SHARED_UI_ObjectSelector_ListBox;
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



A3C_RADIAL_ACTION_HC_LANDING_FNC = {
	params ["_landingRailType","_condition"];
	//player commandchat str (!isNull A3C_OBJECTPLACER);

	_landingData = +(A3C_RADIAL_ACTION_HC_LANDINGDATA);
	A3C_RADIAL_ACTION_HC_LANDINGDATA = [];
	_landingData params ["_landingPosRoot","_landingVector","_forceDefaultLanding"];

	A3C_UI_HUD_3D_TAG_ICON_TYPE =  "\a3c_ui\markers\HeliPad.paa";
	[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
	private _groups = +(A3C_SELECTED_HC_GROUPS_SETTINGS);

	_distributedPositions = [_landingPosRoot,_groups,count _groups,_landingPosRoot getDir (leader (_groups select 0)),100 ] call A3C_fnc_generateWpWedgePositions;

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

			[_gp, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
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
					[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];

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
		//case ("HC_WP") : {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_fnc_setOpacity};
		case ("BOARD") : {[A3C_UI_COLOR_YELLOW,0.7] call A3C_UI_fnc_setOpacity};
		case ("SUPPRESSION") : {[A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity};
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

