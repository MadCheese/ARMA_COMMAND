A3C_UI_RADIAL_LB_ADD = {
	DISABLESERIALIZATION;
	{
		_x params["_label","_class","_obj","_cbo","_img"];
		_index = [_cbo, _label] call A3C_addLbEntry;

		_cbo lbSetData [(lbSize _cbo)-1,  _class];
		switch (A3C_RADIALMODE) do {
			case ("BRAIN") : {
				//_array = "true" configClasses (configFile>>"CfgRanks");
				//{
				//	if ((getText (configfile >> "CfgRanks" >> (configname _x) >> "displayName")) == (rank _obj)) exitWith {
				//		_picture = (getText (configfile >> "CfgRanks" >> (configname _x) >> "texture"));
				//	};
				//} foreach _array;
			};
			case ("VEHS") : {
				_img = ((getText (configfile >> "CfgVehicles" >> _class >> "picture")));
			};
		};
		_cbo lbSetPicture [(lbSize _cbo)-1,_img];
	} forEach _this;
};


//-- UI HANDLER FNCS 
// -- HANDLER FNCS
A3C_UI_RADIAL_TREE_MouseDown = {
	params ["_ctrl","_btn","_sX","_sY","_shift","_ctrl","_alt"];
	_boxPos = ctrlPosition (findDisplay 100040 displayCtrl 8071);
	_sX = _sX - (_boxPos select 0);
	_sY = _sY - (_boxPos select 1);
	if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
		if (_btn == 1) then {
			//-- Precaution: rClick deselects groupSelectedUnits. >> re-select!
			[] spawn {
				for "_i" from 1 to 2 do {
					sleep (0.1 * _i);
					{
						if (!isPlayer _x) then {
							player groupSelectUnit [_x,true];
							A3C_RD_UNITS pushbackUnique _x;
						};
					} foreach A3C_RD_UNITS;
				};
			};
			if (_shift) then {
				private _teamBox = (findDisplay 100040 displayCtrl 8095);

				lbClear _teamBox;
				_teamBox ctrlShow true;
				ctrlsetfocus _teamBox;
				A3C_LB_MODE = 3;
				_listBoxPos = 
				[
					_sX min ((_boxPos select 2) * 0.59),
					_sY min ((_boxPos select 3) * 0.59)
				];
				
				[_teamBox, "TEAM RED"] call A3C_addLbEntry;
				_teamBox lbSetColor [0, [1, 0, 0, 1]];
				[_teamBox, "TEAM GREEN"] call A3C_addLbEntry;
				_teamBox lbSetColor [1, [0, 1, 0, 1]];
				[_teamBox, "TEAM BLUE"] call A3C_addLbEntry;
				_teamBox lbSetColor [2, [0, 0, 1, 1]];
				[_teamBox, "TEAM YELLOW"] call A3C_addLbEntry;
				_teamBox lbSetColor [3, [1, 1, 0, 1]];
				[_teamBox, "TEAM WHITE"] call A3C_addLbEntry;
				_teamBox lbSetColor [4, [1, 1, 1, 1]];
				_teamBox ctrlSetPosition _listBoxPos;
				_teamBox ctrlCommit 0;
				
				private _assignedTeam = if (player == cameraOn) then {assignedTeam (_unitArray select _unitIndex)} else {(_unitArray select _unitIndex) getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};	
				switch (_assignedTeam) do {
					case ('RED') : {
						[_teamBox, 0] call A3C_setCurSel;
						_teamBox lbSetSelectColor [0, [1, 0, 0, 1]];
					};
					case ('GREEN') : {
						[_teamBox, 1] call A3C_setCurSel;
						_teamBox lbSetSelectColor [1, [0, 1, 0, 1]];
					};
					case ('BLUE') : {
						[_teamBox, 2] call A3C_setCurSel;
						_teamBox lbSetSelectColor [2, [0, 0, 1, 1]];
					};
					case ('YELLOW') : {
						[_teamBox, 3] call A3C_setCurSel;
						_teamBox lbSetSelectColor [3, [1, 1, 0, 1]];
					};
					case ('MAIN') : {
						[_teamBox, 4] call A3C_setCurSel;
						// _teamBox lbSetColor [4, [1, 1, 1, 1]];
						_teamBox lbSetSelectColor [4, [1, 1, 1, 1]];
					};
				};	
			} else {
				if ( ((_unitArray select _unitIndex) in A3C_RD_UNITS) && {count A3C_RD_UNITS > 1}) then {
					_add = {_x in A3C_HUD_UNITS} count A3C_RD_UNITS == 0;
					{
						if (_add) then {
							if !(_x in A3C_HUD_UNITS) then {
								[_x,_x getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
							};
						} else {
							if (_x in A3C_HUD_UNITS) then {
								[_x] call A3C_HUD_REMOVE_SELECTED;
							};
						};
					} foreach A3C_RD_UNITS;
				} else {
					if !((_unitArray select _unitIndex) in A3C_HUD_UNITS) then {
						[(_unitArray select _unitIndex),(_unitArray select _unitIndex) getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
					} else {
						[(_unitArray select _unitIndex)] call A3C_HUD_REMOVE_SELECTED;
					};
				};
			};
		};
	};
};


///////////////////////////////////////////////////////////////////////

///////////////// STUFF THAT REQUIRES CARE BECAUSE CONTROLS ARE EDITED IN FOR-LOOPS

//-- HARDCODED RADIAL BUTTON DATA FOR DIFFERENT INNER RING PARENTS
A3C_UI_RADIAL_BTN_DATA_OUTER_RING = []; //-- all avaliable outer ring buttons. ACTIONS uses all if necessary
for "_i" from 10008 to 10039 step 2 do {
	A3C_UI_RADIAL_BTN_DATA_OUTER_RING pushBack [_i, _i + 1];
};
A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED = []; //-- outer ring buttons for RadialHC Actions
for "_i" from 10008 to 10039 step 2 do {
	A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED pushBack [-2,_i, _i + 1];
};


A3C_UI_RADIAL_BTN_DATA_ROE = [];
for "_i" from 10008 to 10015 step 2 do {
	A3C_UI_RADIAL_BTN_DATA_ROE pushBack [_i, _i + 1];
};

A3C_UI_RADIAL_BTN_DATA_BRAIN_STANCE_GOCODE = [];
for "_i" from 10016 to 10023 step 2 do {
	A3C_UI_RADIAL_BTN_DATA_BRAIN_STANCE_GOCODE pushBack [_i, _i + 1];
};
A3C_UI_RADIAL_BTN_DATA_ITEM_VEHICLE = [];
for "_i" from 10024 to 10031 step 2 do {
	A3C_UI_RADIAL_BTN_DATA_BRAIN_STANCE_GOCODE pushBack [_i, _i + 1];
};


for "_i" from 9001 to 9028 do { //-- inner ring buttons
	if (_i % 2 == 0) then {
		A3C_RADIAL_GAMEUI_AllButtonAreas pushBack _i;
	};
};
for "_i" from 10008 to 10039 do { //-- outer ring buttons
	if (_i % 2 == 0) then {
		A3C_RADIAL_GAMEUI_AllButtonAreas pushBack _i;
	};
};

A3C_UI_RADIAL_TOGGLE_OUTER_RING = {

	params ["_bool"];
	for "_i" from 10008 to 10039 do {
		((findDisplay 100040) displayCtrl _i) ctrlShow _bool;
	};
	for "_i" from 8001 to 8004 do {
		((findDisplay 100040) displayCtrl _i) ctrlShow _bool;
	};
};

A3C_UI_RADIAL_LABEL_INNER_RING = {
	params ["_commandLevel"];

	//-- clean wipe
	for "_i" from 9001 to 9028 do { //-- inner ring buttons
		(findDisplay 100040 displayCtrl _i) ctrlShow false;
	};
	for "_i" from 8001 to 8004 do { //-- outer ring backgrounds
		(findDisplay 100040 displayCtrl _i) ctrlShow false;
	};
	for "_i" from 10008 to 10039 do { //-- outer ring buttons
		(findDisplay 100040 displayCtrl _i) ctrlShow false;
	};




	{(findDisplay 100040 displayCtrl _x) ctrlShow false} foreach [8071,8096,8097,8098,8099,9000];


	//-- no need to reset formation stuff. WHen switched, RD_UNITS is [] anyways

	A3C_RADIAL_HOVER = true;

	(findDisplay 100040 displayCtrl 9013) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_form_Wedge.Paa";
	(findDisplay 100040 displayCtrl 9014) ctrlSetToolTip "FORMATIONS"; //-- move unstuck to it's own action
	{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [9013,9014];
	private _teamColorMode = "INF";
	if (_commandLevel == "SQUAD") then {
		showHud ([false] + (shownhud select [1,10]));

		(findDisplay 100040 displayCtrl 21000) ctrlShow true;
		(findDisplay 100040 displayCtrl 21001) ctrlShow true;


		(findDisplay 100040 displayCtrl 9001) ctrlSetText  "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
		(findDisplay 100040 displayCtrl 9002) ctrlSetToolTip "AI Actions";
		(findDisplay 100040 displayCtrl 9003) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_ROE_main.paa";
		(findDisplay 100040 displayCtrl 9004) ctrlSetToolTip "RULES OF ENGAGEMENT";

		(findDisplay 100040 displayCtrl 9005) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_groupManagement.paa";
		(findDisplay 100040 displayCtrl 9006) ctrlSetToolTip "AI AUTO_FUNCTIONS";
		(findDisplay 100040 displayCtrl 9007) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
		(findDisplay 100040 displayCtrl 9008) ctrlSetToolTip "AI STANCES (RMB: TOGGLE GOCODES)";

		((findDisplay 100040) displayctrl 9009) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";// ((getText (configfile >> "CfgWeapons" >> (primaryWeapon (A3C_RD_UNITS select 0)) >> "picture")));
		(findDisplay 100040 displayCtrl 9010) ctrlSetToolTip "WEAPON ITEMS";
		(findDisplay 100040 displayCtrl 9011) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
		(findDisplay 100040 displayCtrl 9012) ctrlSetToolTip "LMB: TOGGLE VEHICLE OPTIONS || RMB: DISMOUNT SELECTED UNITS";

		




		for "_i" from 9001 to 9028 do {
			(findDisplay 100040 displayCtrl _i) ctrlShow true;
		};


		(findDisplay 100040 displayCtrl 8005) ctrlSetText (toUpper (groupID group player));

		[0] call A3C_GREN_DATA;
		[] call A3C_UI_RADIAL_populateOuterRing_Grenades;

		(findDisplay 100040 displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;

	} else {
		showHud ([true] + (shownhud select [1,10]));

		[] call A3C_UI_SHARED_createDashBoard;

		

		(findDisplay 100040 displayCtrl 21000) ctrlShow false;
		(findDisplay 100040 displayCtrl 21001) ctrlShow false;
		
		(findDisplay 100040 displayCtrl 9001) ctrlShow true;
		(findDisplay 100040 displayCtrl 9001) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_pin.paa";
		(findDisplay 100040 displayCtrl 9002) ctrlShow true;
		(findDisplay 100040 displayCtrl 9002) ctrlSetToolTip format ["MOVE - CONFIRM WITH 'Spacebar', CANCEL BY RELEASING %1",["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION];

		(findDisplay 100040 displayCtrl 9003) ctrlShow true;
		(findDisplay 100040 displayCtrl 9003) ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
		(findDisplay 100040 displayCtrl 9004) ctrlShow true;
		(findDisplay 100040 displayCtrl 9004) ctrlSetToolTip "HC-ACTIONS";

		(findDisplay 100040 displayCtrl 9005) ctrlShow true;
		(findDisplay 100040 displayCtrl 9005) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
		(findDisplay 100040 displayCtrl 9006) ctrlShow true;
		(findDisplay 100040 displayCtrl 9006) ctrlSetToolTip "HC STANCES";

		(findDisplay 100040 displayCtrl 9007) ctrlShow true;
		(findDisplay 100040 displayCtrl 9007) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
		(findDisplay 100040 displayCtrl 9008) ctrlShow true;
		(findDisplay 100040 displayCtrl 9008) ctrlSetToolTip "GO CODES";



		(findDisplay 100040 displayCtrl 9009) ctrlShow true;
		(findDisplay 100040 displayCtrl 9009) ctrlSetText "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\attack_ca.paa";
		(findDisplay 100040 displayCtrl 9010) ctrlShow true;
		(findDisplay 100040 displayCtrl 9010) ctrlSetToolTip "HC BEHAVIOUR";

		(findDisplay 100040 displayCtrl 9011) ctrlShow true;
		(findDisplay 100040 displayCtrl 9011) ctrlSetText "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
		(findDisplay 100040 displayCtrl 9012) ctrlShow true;
		(findDisplay 100040 displayCtrl 9012) ctrlSetToolTip "HC COMBAT-MODE";


		A3C_RD_BOOL_UNITS = true;

		{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8097,8098,8099,9000]; //8071,8096,

		
	};

	(findDisplay 100040 displayCtrl 8095) ctrlShow false; //-- teamcolor listbox - has to happen after UNIT SELECTOR group is opened
	[100040] call A3C_UI_MAP_TREE_LABEL; 
};



A3C_UI_RADIAL_BTN_FNC_RING_INNER = { //-- the inner ring functions. must assign fncs and images to buttons
	private ["_bv"];

	_mode = _this select 0;
	_btn = if ((count _this) > 1) then {(_this select 1)} else {-1};
	_shift = if ((count _this) > 2) then {(_this select 2)} else {false};
	_doToggle = if ((count _this) > 3) then {(_this select 3)} else {true};

	A3C_RD_BOOL_UNITS = true;
	
	//-- exit if fnc-area was defined
	if (!(_mode == 'FORM') && !(A3C_RADIAL_HOVER) && (_btn == -1)) exitwith {};

	if (_mode == 'FORM' && {A3C_CURRENT_COMMAND_LEVEL == "SQUAD"}) then {A3C_RADIAL_HOVER = true} else {A3C_RADIAL_HOVER = false};
	if !(_mode == "FORM") then {
		playsound "ReadOutHideClick1";
	};
	_bv = "";

	private _doRefreshGroupSelected = true;
	{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;

	[] call A3C_UI_RADIAL_RESET_DYNAMIC_BTNS; //-- reset outer ring buttons

	A3C_LBR_1 = "";
	for "_i" from 0 to 45 do {
		if (ctrlType (findDisplay 100040 displayCtrl (10101 + _i)) != -1) then {
			ctrlDelete (findDisplay 100040 displayCtrl (10101 + _i));
			ctrlDelete (findDisplay 100040 displayCtrl (10101 + _i + 1));
		};
	};

	for "_i" from 11101 to 11104 do {
		ctrlDelete (findDisplay 100040 displayCtrl _i);
	};

	


	switch (_mode) do {

		case ("RINGFORM") : {
			_bv = "BV_RINGFORM";
			A3C_RADIALMODE = 'RINGFORM';
			if (_btn == 1) exitWith {
				//-- RMB on inner circle formation button >> adjust group formation direction
				(group player) setFormDir (getDir (vehicle player));
				
				player groupradio "VehicleWatchPos"	
			};
		
			if (BV_RINGFORM == 0) then {

				if (_btn != -1) then {
					BV_RINGFORM = 1;
				};
				//-- reset outer ring buttons
				for "_i" from 10008 to 10039 do { //BBBBBBB
					(findDisplay 100040 displayCtrl _i) ctrlShow false;
					if (_i % 2 == 0) then {
						(findDisplay 100040 displayCtrl _i) ctrlSetText "";
					} else {
						(findDisplay 100040 displayCtrl _i) ctrlSetTooltip "";
					};
				};

				_outerRingBackGroundIDs = ["PlaceHolder","Left","bottom","Right","Top"];
				_formations = ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"];
				//-- outer ring backgrounds
				for "_i" from 8001 to 8004 do {
					_ind = _i - 8000;

					if ( _ind <= ((ceil ((count _formations) / 4) ) min 3)    ) then {
						(findDisplay 100040 displayCtrl _i) ctrlShow true; //-- outer circle backgroud shown
						(findDisplay 100040 displayCtrl _i) ctrlSetText (format ["A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",_outerRingBackGroundIDs select _ind]);
					} else {
						(findDisplay 100040 displayCtrl _i) ctrlShow false; //-- outer circle backgroud hidden
					};
				};
				
				_imageStrings = 
				[
					"Column",
					"StaggColumn",
					"Wedge",
					"Ech_Left",
					"Ech_Right",
					"Vee",
					"Line",
					"File",
					"Diamond"
				];
				//
				//-- label buttons-images and fncs
				{
					_btnID = (10039 - (_foreachIndex * 2));
					_imgID = ((10039 - (_foreachIndex * 2)) - 1);
					_buttonitem = 16 - _foreachIndex;
					//systemchat str _btnID;
					_btnClicker = findDisplay 100040 displayCtrl _btnID;
					_btnImage = findDisplay 100040 displayCtrl _imgID;
					{_x ctrlShow true} foreach [_btnImage,_btnClicker];
					_btnImagePath = format ["A3C_CORE\ui\pictures\icon_menu_form_%1.Paa",_imageStrings select _foreachIndex];
					_btnImage ctrlSetText _btnImagePath;
					_btnClicker ctrlSetToolTip _x;
					call compile format
					[
						"
							A3C_OUTER_RING_BTN_fnc_%1 =
							[
								[],
								{
									
									private _mb = (_this select 0) select 1;
									['%2'] spawn A3C_FNC_FORMMENU;
									if (_mb == 1) then {
										(group player) setFormDir (getDir (vehicle player));
										[] spawn {
											hint 'FORMATION-DIR ADJUSTED';
											sleep 1;
											player groupradio 'VehicleWatchPos';
											sleep 1;
											hintSilent '';
										};
									};
								}
							];
						",
						_buttonitem,
						_x
					];
				} foreach _formations;
   
			} else {
				BV_RINGFORM = 0;
				[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
			};
		};
		case ("GRENADE") : {
			if (A3C_RADIALMODE != "GRENADE") then {
				BV_GREN = 0;
			};
			_bv = "BV_GREN";
			A3C_RADIALMODE = 'GRENADE';
			
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				if (BV_GREN == 0) then {

					if (_btn != -1) then {
						BV_GREN = 1;
					};
					BV_ACT = 0;
					BV_MEDICAL = 0;
					BV_CBMODE = 0;

					[0] call A3C_GREN_DATA;
					//-- hide right extension buttons - does this happen here??
					for "_i" from 8053 to 8068 do {
						(findDisplay 100040 displayCtrl _i) ctrlShow false;
					};
				} else {
					BV_GREN = 0;
					[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
				};
			};
		};
		case ("ACTIONS") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				A3C_RADIALMODE = 'ACT';
				_bv = "BV_ACT";
				BV_ROE = 0;
				if (BV_ACT == 0) then {
					if (_btn != -1) then {
						BV_ACT = 1;
					};
					BV_MEDICAL = 0;
					BV_CBMODE = 0;
					BV_GREN = 0;

					//-- hide right extension buttons - does this happen here??
					for "_i" from 8053 to 8068 do {
						(findDisplay 100040 displayCtrl _i) ctrlShow false;
					};
					[100040,A3C_RD_UNITS,A3C_UI_RADIAL_BTN_DATA_OUTER_RING] call A3C_UI_SQUAD_DISTRIBUTE_MENU_ACTIONS;
					_outerRingBackGroundIDs = ["Placeholder","Top","Right","bottom"];
					for "_i" from 8001 to 8004 do {
						_ind = _i - 8000;
						if ( _ind <= ((ceil ((count A3C_DYNAMIC_BUTTON_ACTIONS) / 4) ) min 3)    ) then {
							(findDisplay 100040 displayCtrl _i) ctrlShow true; //-- outer circle backgroud shown
							(findDisplay 100040 displayCtrl _i) ctrlSetText (format ["A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",_outerRingBackGroundIDs select _ind]);
						} else {
							(findDisplay 100040 displayCtrl _i) ctrlShow false; //-- outer circle backgroud hidden
						};
					};
					for "_i" from 10008 to 10039 do { //-- outer ring buttons
						(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
					};
				} else {
					BV_ACT = 0;
					[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
				};
			} else {
				if (_btn == 0) then {
					[
						false, //-- isBusy
						"HC_Waypoint", //-- actionID
						'\a3c_ui\hud\icon_HUD_movePos.paa', //-- Hud-Icon-class  "\a3\ui_f\data\IGUI\Cfg\Cursors\waypointMark_ca.paa"
						[1,1,1,0.7], //-- Hud-Icon-color
						"", //-- placer class
						"" //-- placer color-params
					] call A3C_AI_SHARED_Action_StartPositionalProcess;	
				} else {
					for "_i" from 10008 to 10039 do {
						(findDisplay 100040 displayCtrl _i) ctrlShow false;
					};
					//-- outer ring backgrounds
					for "_i" from 8001 to 8004 do {
						(findDisplay 100040 displayCtrl _i) ctrlShow false; //-- outer circle backgroud hidden
					};
				};
				
			};

		};
		case ("ROE") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				if (_btn == 1) then {
					[] call A3C_UI_Radial_SQ_ROE_MAIN;
				} else {
					A3C_RADIALMODE = 'ROE';
					_bv = "BV_ROE";
					BV_ACT = 0;
					if (BV_ROE == 0) then {
						if (_btn != -1) then {
							BV_ROE = 1;
						};

						{((findDisplay 100040) displayCtrl _x) ctrlShow true} foreach [8001,8002]; //,8003,8004
						((findDisplay 100040) displayCtrl 8001) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Top.paa";
						((findDisplay 100040) displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right_Var1.paa";
						//-- TOP RING
						for "_i" from 10008 to 10015 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow true;
							if (_i % 2 == 0) then {
								//-- ICONS
								((findDisplay 100040) displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
								private _ico = switch _i do {
									case (10008) : {"A3C_CORE\ui\pictures\icon_menu_ROE_FAW.paa"};
									case (10010) : {"A3C_CORE\ui\pictures\icon_menu_ROE_FOT.paa"};
									case (10012)  : {"A3C_CORE\ui\pictures\icon_menu_ROE_FOML.paa"};
									case (10014) : {
										if ({_x in A3C_DANGER_UNITS} count A3C_RD_UNITS == 0) then {
											"A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa"
										} else {
											"A3C_CORE\ui\pictures\icon_menu_autocombat_disabled.paa"
										}
									};
								};
								((findDisplay 100040) displayCtrl _i) ctrlSetText _ico;
							} else {
								//-- BUTTONS
								private _toolTip = switch _i do {
									case (10009) : {"TARGET SELECTION: AUTONOMOUS"};
									case (10011) : {"TARGET SELECTION: DESIGNATED ONLY"};
									case (10013)  : {"FIRE ON MY LEAD"};
									case (10015) : {
										if ({_x in A3C_DANGER_UNITS} count A3C_RD_UNITS == 0) then {
											"DISABLE AUTOCOMBAT"
										} else {
											"ENABLE AUTOCOMBAT"
										}
									};
								};
								((findDisplay 100040) displayCtrl _i) ctrlSetTooltip _toolTip;
							};
						};

						private _behaviorIcon = "\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa";
						private _combatModeIcon ="\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa";

						//"\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\Cursors\attack_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa"
						//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\defend_ca.paa"
						//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"

						for "_i" from 10016 to 10023 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow false;
						};


						// //-- RIGHT RING - COMBAT MODES / BEHAVIOUR MACRO SELECTOR
						((findDisplay 100040) displayCtrl 10016) ctrlShow true;
						((findDisplay 100040) displayCtrl 10017) ctrlShow true;
						((findDisplay 100040) displayCtrl 10016) ctrlSetText _combatModeIcon;
						((findDisplay 100040) displayCtrl 10017) ctrlSetTooltip "COMBAT MODES AND BEHAVIOUR";
						((findDisplay 100040) displayCtrl 10016) ctrlSetTextColor [1,1,1,0.4];
						//-- HIDE RIGHT EXTENTION
						for "_i" from 8053 to 8068 do {
							(findDisplay 100040 displayCtrl _i) ctrlShow false;
						};
						BV_MEDICAL = 0;
						BV_CBMODE = 0;
						BV_GREN = 0;

						//-- BUTTON FUNCTIONS 
						//-- Upper Ring: Custom ROE's
						A3C_OUTER_RING_BTN_fnc_1 =
						[
							[],
							{[0] spawn A3C_RadialMenu_ROE;}
						];
						A3C_OUTER_RING_BTN_fnc_2 =
						[
							[],
							{[1] spawn A3C_RadialMenu_ROE;} 
						];
						A3C_OUTER_RING_BTN_fnc_3 =
						[
							[],
							{[2] spawn A3C_RadialMenu_ROE;}
						];
						A3C_OUTER_RING_BTN_fnc_4 =
						[
							str (groupSelectedUnits player),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button"];
								_units = call compile _units;
								[_units] spawn A3C_TOGGLEDANGER;
							}
						];
						//-- Right Ring: Combat Modes | Behaviours Macro
						A3C_OUTER_RING_BTN_fnc_5 =
						[
							[],
							{
								[] call A3C_UI_Radial_SQ_ROE_MAIN;
							}
						];
					} else {
						BV_ROE = 0;
						[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
					};
				};
				
			} else {
				A3C_RADIALMODE = "HC ACTIONS";
				A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;

				_actions = [A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED,_doToggle] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;

				for "_i" from 8001 to 8004 do {
					(findDisplay 100040 displayCtrl _i) ctrlShow false;
				};

				for "_i" from 10008 to 10039 do { //-- outer ring buttons
					(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
				};

				if (count _actions > 0) then {
					for "_i" from 1 to  (ceil (count _actions / 4)) do {
						_imgString = switch (_i) do {
							case (1) : {"Top"};
							case (2) : {"Right"};
							case (3) : {"Bottom"};
							case (4) : {"Left"};
						};
						(findDisplay 100040 displayCtrl (8000 + _i)) ctrlSetText format ["A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",_imgString];
						if (_doToggle) then {
							(findDisplay 100040 displayCtrl (8000 + _i)) ctrlShow true;
						};
					};

				};

			};

		};
		case ("BRAIN") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				A3C_RADIALMODE = 'BRAIN';
				BV_LB1 = 6;
				BV_LB2 = 7;
				BV_GREN = 0;
				_bv = "BV_BRAIN";
				{((findDisplay 100040) displayCtrl _x) ctrlSetTextColor [1,1,1,0.6]} foreach [10016,10018,10020,10022];
				if (_btn == 1) then {
					//-- right click macro unit lookdir+unitpos reset
					 player groupRadio "SentBehaviourSafe";
					{_x dowatch objnull; _x lookat objnull; _x setUnitPos 'AUTO';} foreach (groupSelectedUnits player);
				} else {
					//-- left click: toggle right outer ring
					[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
					if (BV_BRAIN == 0) then {

						((findDisplay 100040) displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
						((findDisplay 100040) displayCtrl 8002) ctrlShow true;
						if (_btn != -1) then {
							BV_BRAIN = 1;
						};
						{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8003,8004];
						for "_i" from 10016 to 10023 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow true;
						};
						for "_i" from 8053 to 8068 do {
							(findDisplay 100040 displayCtrl _i) ctrlShow false;
						};
						BV_MEDICAL = 0;
						BV_CBMODE = 0;

						((findDisplay 100040) displayCtrl 10016) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_resetWatchdir.paa";
						((findDisplay 100040) displayCtrl 10017) ctrlSetTooltip "RESET WATCHDIR";
						((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
						if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
							((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
							((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,1,1,0.6];
							((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
						} else {
							if ( {_u = _x; {_u getHitPointDamage _x > 0.2} count A3C_HUMAN_HITPOINTS > 0 } count (units player) > 0 ) then {
								((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,0.3,0.3,0.6];
								((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
							} else {
								((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,1,1,0.6];
								((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "No units wounded";
							};
						};

						((findDisplay 100040) displayCtrl 10020) ctrlSetText "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"; //"A3C_CORE\ui\pictures\icon_menu_takeCover.paa";
						((findDisplay 100040) displayCtrl 10021) ctrlSetTooltip "Behaviour & CombatMode";//"FIND COVER";
						((findDisplay 100040) displayCtrl 10022) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_reArm.paa";
						((findDisplay 100040) displayCtrl 10023) ctrlSetTooltip "RE-ARM (LMB: choose target, RMB: find target)";

						A3C_OUTER_RING_BTN_fnc_5 =
						[
							str (groupSelectedUnits player),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button"];
								_units = call compile _units;

								//-- toggle right extension modes off
								BV_MEDICAL = 0;
								BV_CBMODE = 0;

								{
									_x dowatch objnull;
									_x lookat objnull;
								} foreach _units;
								player groupchat 'STAY ALERT (looking dir)';
							}
						];
						A3C_OUTER_RING_BTN_fnc_6 =
						[
							str (groupSelectedUnits player),
							{
								//-- medical menu toggle button
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;


								if (_button == 0) then {
									//-- left click: toggle medical menu

									//-- if automedic is on and menu is opened, auto medic is turned off
									if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
										profileNameSpace setVariable ["A3C_AUTOMEDIC", false];
										if ( {_u = _x; {_u getHitPointDamage _x > 0.2} count A3C_HUMAN_HITPOINTS > 0 } count (units player) > 0 ) then {
											((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,0.3,0.3,0.6];
											((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "AI Healing: LMB: open medical controls. SHIFT+LMB: Closest Medic Heal Player (AUTO-mode coming soon)";
										} else {
											((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
											((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,1,1,0.6];
											((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "No units wounded";
										};
									};
									//--
									if !(_shift) then {
										BV_CBMODE = 0;
										//-- no Shift: bring up healing menu
										if (BV_MEDICAL == 0) then {
											BV_MEDICAL = 1;
											A3C_LBR_1 = "MEDICAL";
											(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
											{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
											["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
										} else {
											BV_MEDICAL = 0;
											for "_i" from 8053 to 8058 do {
												(findDisplay 100040 displayCtrl _i) ctrlShow false;
											};
										};
									} else {
										//-- shift: shortCut to heal only player
										private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
										
										(group player) setVariable ["A3C_MEDICS", _medics];
										[group player] call A3C_FINDPATIENTS;
										private _medics_lb = +(_medics);

										if (player in (group player getVariable ["A3C_PATIENTS",[]])) then {
											(group player) setVariable ["A3C_PATIENTS", [player]];
											(group player) setVariable ["A3C_PATIENTS_LB", [player]];
											
											//-- #TODO: filter closest medic 
											(group player) setVariable ["A3C_MEDICS", [(_medics select 0)]];
											_medics_lb = [(_medics select 0)];
											
											[group player, 0] spawn A3C_MEDICAL_START;
										} else {
											(group player) setVariable ["A3C_PATIENTS",[]];
										};
										
										(group player) setVariable ["A3C_MEDICS_LB", _medics_lb];
									};

								} else {
									//-- right click: toggle auto-medic
									if !(profileNameSpace getVariable "A3C_AUTOMEDIC") then {
										profileNameSpace setVariable ["A3C_AUTOMEDIC", true];
										((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
										((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [1,1,1,0.6];
										for "_i" from 8053 to 8068 do {
											(findDisplay 100040 displayCtrl _i) ctrlShow false;
										};
										[] spawn A3C_HEAL_AUTOLOOP;
									};
								};
							}
						];
						A3C_OUTER_RING_BTN_fnc_7 =
						[
							str (groupSelectedUnits player),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;



								for "_i" from 8053 to 8058 do {
									(findDisplay 100040 displayCtrl _i) ctrlShow false;
								};


								BV_MEDICAL = 0; //-- reset MedicalButton value to 0 (for closing/opening extension)
								if (BV_CBMODE == 0) then {
									BV_CBMODE = 1;
									A3C_LBR_1 = "CBMODE";
									BV_LB1 = 12;
									BV_LB2 = 13;
									//-- open right extension: combat mode
									(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
									{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
									["CBMODE"] call A3C_UI_RADIAL_LABEL_LB;
								} else {
									//-- close right extension: combat mode
									BV_CBMODE = 0;
									for "_i" from 8053 to 8058 do {
										(findDisplay 100040 displayCtrl _i) ctrlShow false;
									};
								};
							}
						];
						A3C_OUTER_RING_BTN_fnc_8 =
						[
							str (groupSelectedUnits player),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button"];
								_units = call compile _units;

								BV_MEDICAL = 0; //-- reset button values for functions that spawn extensions, close extension
								BV_CBMODE = 0;
								for "_i" from 8053 to 8058 do {
									(findDisplay 100040 displayCtrl _i) ctrlShow false;
								};
								A3C_LBR_1 = "REARM";
								if (_button == 0) then {
									A3C_ReArm_options = [];
									[] call A3C_ReArm_OpenUI;

								} else {
									{[_x] spawn A3C_ReArm_Auto_Evaluate} foreach _units;
									player groupradio "SentCmdRearm";	
								};
							}
						];

					} else {
						BV_BRAIN = 0;
						//-- !!! HIDE THE RIGHT SIDE EXTENSION!!
					};
				};
			} else {
				//-- HC - stances here
				A3C_RADIALMODE = "HC STANCES";
				//-- wipe outer ring
				{
					(findDisplay 100040 displayCtrl _x) ctrlShow false;
				} foreach [8001,8002,8003,8004];
				{
					(findDisplay 100040 displayCtrl (_x select 0)) ctrlSetText "";
					(findDisplay 100040 displayCtrl (_x select 1)) ctrlSetToolTip "";
					{(finddisplay 100040 displayCtrl _x) ctrlShow false} foreach _x;
				} foreach A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED;
				_img = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				_color = [1,1,1,0.5];
				for "_i" from 10016 to 10023 do {

					if (_i % 2 == 0) then {
						_img = switch (_i - 10016) do {
							case 0 : {"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa"};
							case 2 : {"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa"};
							case 4 : {"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa"};
							case 6 : {"A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa"};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetText _img;
						(finddisplay 100040 displayCtrl _i) ctrlSetTextColor _color;
					} else {
						_toolTip = switch (_i - 10016) do {
							case 1 : {"AUTO"};
							case 3 : {"UP"};
							case 5 : {"CROUCH"};
							case 7 : {"PRONE"};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetTooltip _toolTip;

					};
					(finddisplay 100040 displayCtrl _i) ctrlShow true;
				};

				(findDisplay 100040 displayCtrl 8002) ctrlShow true;
				(findDisplay 100040 displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
				A3C_OUTER_RING_BTN_fnc_5 =
				[
					"AUTO",
					{
						params ["_clickData","_stance"];
						{
							{
								[_x,_stance] remoteExec ["setUnitPos",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
						player groupRadio "SentBehaviourSafe";
					}
				];
				A3C_OUTER_RING_BTN_fnc_6 =
				[
					"UP",
					{
						params ["_clickData","_stance"];
						{
							{
								[_x,_stance] remoteExec ["setUnitPos",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
						player groupRadio "SentUnitPosUp";
					}
				];
				A3C_OUTER_RING_BTN_fnc_7 =
				[
					"MIDDLE",
					{
						params ["_clickData","_stance"];
						{
							{
								[_x,_stance] remoteExec ["setUnitPos",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
						player groupRadio "SentUnitPosMiddle";
					}
				];
				A3C_OUTER_RING_BTN_fnc_8 =
				[
					"DOWN",
					{
						params ["_clickData","_stance"];
						{
							{
								[_x,_stance] remoteExec ["setUnitPos",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
						player groupRadio "SentUnitPosDown";
					}
				];
			};
		};

		case ("STANCE") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				_bv = "BV_STANCES";
				((findDisplay 100040) displayCtrl 8002) ctrlShow true;
				((findDisplay 100040) displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
				{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8003,8004];
				for "_i" from 10016 to 10023 do {
					((findDisplay 100040) displayCtrl _i) ctrlShow true;
				};
				for "_i" from 10008 to 10015 do {
					((findDisplay 100040) displayCtrl _i) ctrlShow false;
				};

				for "_i" from 10024 to 10039 do {
					((findDisplay 100040) displayCtrl _i) ctrlShow false;
				};
				for "_i" from 8053 to 8068 do {
					(findDisplay 100040 displayCtrl _i) ctrlShow false;
				};
				BV_MEDICAL = 0;
				BV_CBMODE = 0;
				BV_GREN = 0;
				A3C_RADIALMODE = 'STANCE'; //-- 'Stance', being the default layer, will be used as parent for sublayers (goCode)

				if (_btn == 1) then {
					A3C_RADIALMODE = "GOCODE";
					if (BV_STANCES == 3) then {
						BV_STANCES = 0;
						["STANCE",0] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
					} else {
						BV_STANCES = 3;
						((findDisplay 100040) displayctrl 10007) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
						((findDisplay 100040) displayCtrl 10016) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
						((findDisplay 100040) displayCtrl 10017) ctrlSetTooltip "GoCode A";
						((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
						((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "GoCode B";
						((findDisplay 100040) displayCtrl 10020) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
						((findDisplay 100040) displayCtrl 10021) ctrlSetTooltip "GoCode C";
						((findDisplay 100040) displayCtrl 10022) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
						((findDisplay 100040) displayCtrl 10023) ctrlSetTooltip "GoCode D";
						[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0];

						A3C_OUTER_RING_BTN_fnc_5 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								//_units = call compile _units;


								['A'] call A3C_ACTIVATEGOCODE;

							}
						];
						A3C_OUTER_RING_BTN_fnc_6 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								//_units = call compile _units;

								['B'] call A3C_ACTIVATEGOCODE;

							}
						];
						A3C_OUTER_RING_BTN_fnc_7 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								['C'] call A3C_ACTIVATEGOCODE;

							}
						];
						A3C_OUTER_RING_BTN_fnc_8 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								['D'] call A3C_ACTIVATEGOCODE;
							}
						];
					};
				} else {
					_bv = "BV_STANCES";
					if (BV_STANCES == 0) then {
						if (_btn != -1) then {
							BV_STANCES = 1;
						};
						
						((findDisplay 100040) displayctrl 9007) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";

						((findDisplay 100040) displayCtrl 10016) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_auto.paa";
						((findDisplay 100040) displayCtrl 10017) ctrlSetTooltip "AUTO";
						((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
						((findDisplay 100040) displayCtrl 10019) ctrlSetTooltip "STAND";
						((findDisplay 100040) displayCtrl 10020) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
						((findDisplay 100040) displayCtrl 10021) ctrlSetTooltip "CROUCH";
						((findDisplay 100040) displayCtrl 10022) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa";
						((findDisplay 100040) displayCtrl 10023) ctrlSetTooltip "PRONE";
						{
							((findDisplay 100040) displayCtrl _x)ctrlSetTextColor [1,1,1,0.6];
						} foreach [9007,10016,10018,10020,10022];

						A3C_OUTER_RING_BTN_fnc_5 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;
								[A3C_RD_UNITS,'AUTO'] call A3C_SWITCHSTANCE; //~~??
							}
						];
						A3C_OUTER_RING_BTN_fnc_6 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;
								[A3C_RD_UNITS,'UP'] call A3C_SWITCHSTANCE;
							}
						];
						A3C_OUTER_RING_BTN_fnc_7 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;
								[A3C_RD_UNITS,'MIDDLE'] call A3C_SWITCHSTANCE;
							}
						];
						A3C_OUTER_RING_BTN_fnc_8 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								_units = call compile _units;
								[A3C_RD_UNITS,'DOWN'] call A3C_SWITCHSTANCE;
							}
						];


					} else {
						BV_STANCES = 0;
						for "_i" from 10016 to 10023 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow false;
						};
						((findDisplay 100040) displayCtrl 8002) ctrlShow false;
					};
				};
			} else {
				//-- HC GO CODE SECTION
				A3C_RADIALMODE = "HC GOCODE";
				//-- wipe outer ring
				{
					(findDisplay 100040 displayCtrl _x) ctrlShow false;
				} foreach [8001,8002,8003,8004];
				{
					(findDisplay 100040 displayCtrl (_x select 0)) ctrlSetText "";
					(findDisplay 100040 displayCtrl (_x select 1)) ctrlSetToolTip "";
					{(finddisplay 100040 displayCtrl _x) ctrlShow false} foreach _x;
				} foreach A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED;
				_img = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";

				for "_i" from 10016 to 10023 do {

					if (_i % 2 == 0) then {


						_img = switch (_i - 10016) do {
							case 0 : {"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa"};
							case 2 : {"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa"};
							case 4 : {"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa"};
							case 6 : {"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"};
						};

						(finddisplay 100040 displayCtrl _i) ctrlSetText _img;
					} else {
						_toolTip = switch (_i - 10016) do {
							case 1 : {"GOCODE A"};
							case 3 : {"GOCODE B"};
							case 5 : {"GOCODE C"};
							case 7 : {"GOCODE D"};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetTooltip _toolTip;

					};
					(finddisplay 100040 displayCtrl _i) ctrlShow true;
				};
				[] remoteExec ["A3C_TOGGLE_GOCODE_CTRLS",0]; //-- check gocodes and assign color

				(findDisplay 100040 displayCtrl 8002) ctrlShow true;
				(findDisplay 100040 displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa"; //-- aiai
				A3C_OUTER_RING_BTN_fnc_5 =
				[
					"A",
					{
						['A'] call A3C_ACTIVATEGOCODE;
					}
				];
				A3C_OUTER_RING_BTN_fnc_6 =
				[
					"B",
					{
						['B'] call A3C_ACTIVATEGOCODE;
					}
				];
				A3C_OUTER_RING_BTN_fnc_7 =
				[
					"C",
					{
						['C'] call A3C_ACTIVATEGOCODE;
					}
				];
				A3C_OUTER_RING_BTN_fnc_8 =
				[
					"D",
					{
						['D'] call A3C_ACTIVATEGOCODE;
					}
				];


			};
		};

		case ("ITEMS") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				A3C_RADIALMODE = "ITEMS";
				_bv = "BV_ITEMS";

				private _itemCategories = [];
				private _grunts = A3C_RD_UNITS;
				BV_GREN = 0;

				if ({handgunWeapon _x != ""} count _grunts > 0) then {
					_itemCategories pushBack "SWITCHWEAPON";
				};

				if ( (   {count (_x getvariable ["A3C_STROBE",[]]) > 0 } count _grunts > 0)   OR {{{_item = _x; [_item] call A3C_fnc_isIRMagazine } count (magazines _x) > 0} count _grunts > 0}) then {
					_itemCategories pushBack "IR_STROBE";
				};

				if ({{_item = _x; [_item] call A3C_fnc_isNVGoggles } count (assigneditems _x + items _x) > 0} count _grunts > 0) then {
					_itemCategories pushBack "NVG";
				};
				private _sunData = [] call BIS_fnc_sunriseSunsetTime;
				_sunData params ["_sunRise","_sunDown"];
				private _isDark = if (dayTime < _sunRise OR {dayTime > _sunDown }) then {true} else {false};
				{
					private _itemString = _x;
					_add = true;
					//-- if it is NOT dark, do not add light/laser actions unless someone is actually using it
					//-- this is important so that you can still turn off the actions after sunrise
					if !(_isDark) then {
						switch (_foreachIndex) do {
							case (0) : {
								if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "FLASHLIGHT"} count A3C_RD_UNITS == 0) then {
									_add = false;
								};
							};
							case (1) : {
								if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "LASER"} count A3C_RD_UNITS == 0) then {
									_add = false;
								};
							};
						};
					};

					if (_add && {{[_x,_itemString] call A3C_fnc_hasWeaponItem} count _grunts > 0}) then {
						_itemCategories pushBack _itemString;
					};

				} foreach ["FLASHLIGHT","LASER","SILENCER"];

				if (!("SILENCER" in _itemCategories) && {{count ([_x,"MuzzleSlot",0,(currentWeapon _x)] call MCSS_fnc_getWeaponItems) > 0} count A3C_RD_UNITS > 0}) then {
					_itemCategories pushBack "SILENCER";
				};
				{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8002,8003,8004]; //-- hide all outer curcle bg's

				for "_i" from 10008 to 10039 do {
					((findDisplay 100040) displayCtrl _i) ctrlShow false; //-- hide all outer curcle buttons
				};

				if (count _itemCategories == 0) exitWith {};

				if (BV_ITEMS == 0) then {
					if (_btn != -1) then {
						BV_ITEMS = 1;
					};
					
					((findDisplay 100040) displayCtrl 8003) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
					((findDisplay 100040) displayCtrl 8003) ctrlShow true;

					for "_i" from 8053 to 8068 do {
						(findDisplay 100040 displayCtrl _i) ctrlShow false; //-- hide other UI if shown
					};
					{


						switch (true) do {
							case (_foreachIndex == 4) : {
								(findDisplay 100040 displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
								(findDisplay 100040 displayCtrl 8002) ctrlShow true;
							};
						};

						private _currentCategory =  _x;
						_buttonID = 12 - _foreachIndex; //-- 12 is the highest button value (bottom row, most left button) - from here we add buttons backwards
						_buttonImgID = 10030 - (_foreachIndex * 2);
						_buttonClickerID = 10031 - (_foreachIndex * 2);

						private _fnc  = {};
						private _prms = [str (A3C_RD_UNITS),_buttonImgID,_buttonClickerID];
						switch (_currentCategory) do {
							case ("SWITCHWEAPON") : {
								//-- label SwitchWeapon Button
								_SwitchWeaponImage =  "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
								_SwitchWeaponToolTip = "Switch To Handgun";

								if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0) then {
									_SwitchWeaponImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
									_SwitchWeaponToolTip = "Switch To Rifle";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _SwitchWeaponImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _SwitchWeaponToolTip;
								
								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									A3C_Prevent_SwitchWeapon = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									{
										_u = _x;

										if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0 ) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
											_tooltip = "Switch To Handgun";
											_delay = random 1;
											_totalStandBy = _totalStandBy max _delay;
											[_x,_delay] spawn {
												params ["_unit","_delay"];
												sleep _delay;
												//_this playActionNow "mountSide";
												//sleep 1.2;
												_unit selectWeapon (primaryWeapon _unit);
											};
										} else {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
											_tooltip = "Switch To Rifle";
											_delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x,_delay] spawn {
												params ["_unit","_delay"];
												sleep _delay;
												//_this playActionNow "mountSide";
												//sleep 1.2;
												_unit selectWeapon (handGunWeapon _unit);
											};
										};
									} foreach _units;



									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									sleep (_totalStandBy);
									A3C_Prevent_SwitchWeapon = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"switch" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_SwitchWeapon)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"switch" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};


							};
							case ("IR_STROBE") : {
								//-- label STROBE Button
								_strobeImage =  "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
								_strobeToolTip = "Attach IR-Strobe";

								if ({(count (_x getvariable "A3C_STROBE")) > 0} count A3C_RD_UNITS > 0 ) then {
									_strobeImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
									_strobeToolTip = "Remove IR-Strobe";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _strobeImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _strobeToolTip;

								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									
									A3C_Prevent_attach_IR = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									{
										_u = _x;

										if ({(count (_x getvariable "A3C_STROBE")) > 0} count A3C_RD_UNITS > 0 ) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
											_tooltip = "Attach IR-Strobe";
											_delay = random 1;
											_totalStandBy = _totalStandBy max _delay;
											
											[_x,_delay] spawn {
												params ["_unit","_delay"];
												sleep _delay;
												//_this playActionNow "mountSide";
												//sleep 1.2;
												_var = _unit getvariable ["A3C_STROBE",[]];
												if (count _var > 0) then {
													_var params ["_strobeObject","_strobeType"];
													deleteVehicle _strobeObject;
													_unit addmagazine _strobeType;
												};
												_unit setvariable ["A3C_STROBE",[],true];
											};
										} else {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
											_tooltip = "Remove IR-Strobe";
											_delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											if ((count (_u getvariable "A3C_STROBE")) == 0 ) then {
												{
													private ["_am","_array"];
													_it = _x;
													_am = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
													_array = "true" configClasses (configfile >> "CfgAmmo" >> _am >> "NVGMarkers");
													if (count _array > 0) exitwith {
														_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
														_tooltip = "";
														[_u,_it,_delay] spawn {
															params ["_u","_it","_delay"];
															sleep _delay;
															_u removeMagazine _it;
															_st = "NVG_TargetC" createVehicle getPos _u;
															_u setvariable ["A3C_STROBE",[_st,_it],true];
															[_u,_st] spawn A3C_AI_action_irStrobeLoop;

														};
													};
												} foreach (magazines _u);
											};
										};
									} foreach _units;


									
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									sleep (_totalStandBy);
									A3C_Prevent_attach_IR = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"IRstrobe" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_attach_IR)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"IRstrobe" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};

							};
							case ("NVG") : {
								//-- label NVG Button
								_nvgImage =  "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
								_nvgToolTip = "Turn NVG ON";

								if ({{_item = _x; [_item] call A3C_fnc_isNVGoggles } count (assigneditems _x) > 0} count A3C_RD_UNITS > 0) then {
									_nvgImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
									_nvgToolTip = "Turn NVG OFF";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _nvgImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _nvgToolTip;

								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									A3C_Prevent_attach_NVG = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									{
										_u = _x;

										if ({{_item = _x; [_item] call A3C_fnc_isNVGoggles } count (assigneditems _x) > 0} count A3C_RD_UNITS > 0) then {

											_nvgs = "";
											{
												if ([_x] call A3C_fnc_isNVGoggles ) exitWith {
													_nvgs = _x;
												};
											} foreach (assigneditems _x);

											if (_nvgs != "") then {
												_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
												_tooltip = "Turn NVG ON";
												_delay = random 1;
												_totalStandBy = _totalStandBy max _delay;
												[_x,_delay,_nvgs] spawn {
													params ["_unit","_delay","_nvgs"];
													sleep _delay;
													//_this playActionNow "mountSide";
													//sleep 1.2;
													_unit playActionNow "GestureHi";
													sleep 0.834;
													if (!(_unit canAddItemToUniform _nvgs) && {!(_unit canAddItemToVest _nvgs) && {!(_unit canAddItemToBackPack _nvgs)}}) exitWith {
														_unit groupChat "I am out of storage - keeping NVG's equipped!";
													};
													_unit unAssignItem _nvgs;

												};
											};

										} else {
											_nvgs = "";
											{
												if ([_x] call A3C_fnc_isNVGoggles ) exitWith {
													_nvgs = _x;
												};
											} foreach (items _x);

											if (_nvgs != "") then {
												_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
												_tooltip = "Turn NVG OFF";
												_delay = random 1;
												_totalStandBy = _totalStandBy max _delay;
												[_x,_delay,_nvgs] spawn {
													params ["_unit","_delay","_nvgs"];
													sleep _delay;
													//_this playActionNow "mountSide";
													//sleep 1.2;
													_unit playActionNow "GestureHi";
													sleep 0.834;
													_unit AssignItem _nvgs;
												};
											};
										};
									} foreach _units;

									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;

									sleep (_totalStandBy + 2);
									A3C_Prevent_attach_NVG = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"NVG" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};
								};
								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_attach_NVG)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"NVG" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};
							};

							case ("FLASHLIGHT") : {
								//-- label Flashlight Button
								_flashlightImage =  "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
								_flashlightToolTip = "Turn Flashlight ON";
								

								//if ({_x isFlashlightOn (currentWeapon _x)} count A3C_RD_UNITS > 0) then {
								if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "FLASHLIGHT"} count A3C_RD_UNITS > 0) then {

									_flashlightImage = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa";
									_flashlightToolTip = "Turn Flashlight OFF";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _flashlightImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _flashlightToolTip;


								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									private _phrase = "SentLightsOn";
									A3C_Prevent_attach_Flashlight = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									{
										_u = _x;

										if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "FLASHLIGHT"} count A3C_RD_UNITS > 0) then {
											_phrase = "SentLightsOff";
											_sl = [_x,"PointerSlot",1] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_attachment = _x weaponAccessories currentMuzzle _x param [1, ""]; //_sl select 0;
												if (getNumber (configfile >> "CfgWeapons" >> _attachment >> "ItemInfo" >> "FlashLight" >> "intensity") != 0) then {
													_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
													_tooltip = "Turn Flashlight ON";
													_delay = (0.2 * _foreachIndex) + random 1;
													_totalStandBy = _totalStandBy max _delay;
													[_x,_delay] spawn {
														params ["_unit","_delay"];
														sleep _delay;
														//_this playActionNow "mountSide";
														_unit playActionNow "GestureHiC";
														sleep 1.2;
														//_unit setbehaviour "AWARE";
														[_unit,["BEHAVIOUR","AWARE"]] call MCSS_fnc_orderIndividual;
														_unit enablegunlights "forceOff";
														_unit setVariable ["A3C_isGunPoiterSlotOn",""];
													};
												};
											};
										} else {
											_sl = [_x,"PointerSlot",1] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_attachment = _x weaponAccessories currentMuzzle _x param [1, ""];  //_sl select 0;
												_doExecute = false;
												if (getNumber (configfile >> "CfgWeapons" >> _attachment >> "ItemInfo" >> "FlashLight" >> "intensity") != 0) then {
													_doExecute = true;
												} else {
													//-- current item is not gunlight - check for switchable attachment
													_rhsText = toLower (getText (configfile >> "cfgWeapons" >> _attachment >> "rhs_acc_combo_text"));
													if ('light' in _rhsText) then {
														_switchAttachment = getText (configfile >> "CfgWeapons" >> _attachment >> "rhs_acc_combo");
														_doExecute = true;
														_x addPrimaryWeaponItem _switchAttachment;
													} else {
														_smaText = toLower (getText (configfile >> "cfgWeapons" >> _attachment >> "MRT_switchItemHintText"));
														//systemchat str _smaText;
														if ('laser' in _smaText) then {
															_switchAttachment = getText (configfile >> "CfgWeapons" >> _attachment >> "MRT_SwitchItemNextClass");
															_doExecute = true;
															_x addPrimaryWeaponItem _switchAttachment;
														};
													};
												};
												if (_doExecute) then {
													//-- current pointerSlot item is LAser Pointer
													_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa";
													_tooltip = "Turn Flashlight OFF";
													_delay = (0.2 * _foreachIndex) + random 1;
													_totalStandBy = _totalStandBy max _delay;
													[_x,_delay] spawn {
														params ["_unit","_delay"];
														sleep _delay;
														//_this playActionNow "dismountSide";
														_unit playActionNow "GestureHiC";
														sleep 1.2;
														[_unit,["BEHAVIOUR","COMBAT"]] call MCSS_fnc_orderIndividual;
														_unit enablegunlights "ForceOn";
														_unit setVariable ["A3C_isGunPoiterSlotOn","FLASHLIGHT"];
													};
												};
											};
										};
									} foreach _units;
									player groupradio _phrase; 




									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;

									sleep (_totalStandBy);
									A3C_Prevent_attach_Flashlight = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"FlashLight" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};

									//-- switch LASER icon if necessary
									if ({_x isIRLaserOn (currentWeapon _x)} count _units == 0) then {
										for "_i" from 10031 to 10008 step - 1 do {
											if ("IRlaser" in ctrlText (findDisplay 100040 displayCtrl _i)) then {
												(findDisplay 100040 displayCtrl _i) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
											};
										};
									};


								};
								
								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_attach_Flashlight)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"FlashLight" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};

							};
							case ("LASER") : {

								//-- label Laser Button
								_LaserImage =  "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
								_LaserToolTip = "Turn IR-LASER ON";

								if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "LASER"} count A3C_RD_UNITS > 0) then {
									_LaserImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
									_LaserToolTip = "ITurn IR-LASER OFF";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _LaserImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _LaserToolTip;


								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									A3C_Prevent_attach_IR_Laser = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									private _phrase = "SentPointersOn";
									{
										_u = _x;

										if ({_x getVariable ["A3C_isGunPoiterSlotOn",""] == "LASER"} count A3C_RD_UNITS > 0) then {
											_phrase = "SentPointersOff";
											_sl = [_x,"PointerSlot",1] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_attachment = _x weaponAccessories currentMuzzle _x param [1, ""];  //_sl select 0;
												if (getNumber (configfile >> "CfgWeapons" >> _attachment >> "ItemInfo" >> "Pointer" >> "irDistance") != 0) then {
													_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
													_tooltip = "Turn IR-LASER ON";
													_delay = (0.2 * _foreachIndex) + random 1;
													_totalStandBy = _totalStandBy max _delay;
													[_x,_delay] spawn {
														params ["_unit","_delay"];
														sleep _delay;
														//_this playActionNow "mountSide";
														_unit playActionNow "GestureHiC";
														sleep 1.2;
														//_unit setbehaviour "AWARE";
														[_unit,["BEHAVIOUR","AWARE"]] call MCSS_fnc_orderIndividual;
														(group _unit) enableIRLasers false;
														_unit setVariable ["A3C_isGunPoiterSlotOn",""];
													};
												};
											};
										} else {
											_sl = [_x,"PointerSlot",1] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_attachment = _x weaponAccessories currentMuzzle _x param [1, ""];  //_sl select 0;
												_doExecute = false;

												if (getNumber (configfile >> "CfgWeapons" >> _attachment >> "ItemInfo" >> "Pointer" >> "irDistance") != 0) then {
													_doExecute = true;
												} else {
													//-- current item is not pointer - check for switchable attachment
													_rhsText = toLower (getText (configfile >> "cfgWeapons" >> _attachment >> "rhs_acc_combo_text"));
													if ('laser' in _rhsText) then {
														_switchAttachment = getText (configfile >> "CfgWeapons" >> _attachment >> "rhs_acc_combo");
														_doExecute = true;
														_x addPrimaryWeaponItem _switchAttachment;
													} else {
														_smaText = toLower (getText (configfile >> "cfgWeapons" >> _attachment >> "MRT_switchItemHintText"));
														if ('light' in _smaText) then {
															_switchAttachment = getText (configfile >> "CfgWeapons" >> _attachment >> "MRT_SwitchItemNextClass");
															_doExecute = true;
															_x addPrimaryWeaponItem _switchAttachment;
														};
													};
												};
												if (_doExecute) then {

													//-- current pointerSlot item is LAser Pointer
													_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
													_tooltip = "Turn IR-LASER OFF";
													_delay = (0.2 * _foreachIndex) + random 1;
													_totalStandBy = _totalStandBy max _delay;
													[_x,_delay] spawn {
														params ["_unit","_delay"];
														sleep _delay;
														_unit playActionNow "GestureHiC";
														sleep 1.2;
														[_unit,["BEHAVIOUR","COMBAT"]] call MCSS_fnc_orderIndividual;
														(group _unit) enableIRLasers true;
														_unit setVariable ["A3C_isGunPoiterSlotOn","LASER"];
													};
												};
											};
										};

									} foreach _units;

									player groupradio _phrase; 
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;

									sleep (_totalStandBy + 1.2);

									A3C_Prevent_attach_IR_Laser = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"IRlaser" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};

									//-- switch FLASHLIGHT icon if necessary
									if ({_x isFlashlightOn (currentWeapon _x)} count _units == 0) then {
										for "_i" from 10031 to 10008 step - 1 do {
											if ("FlashLight" in ctrlText (findDisplay 100040 displayCtrl _i)) then {
												(findDisplay 100040 displayCtrl _i) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
											};
										};
									};
								};
								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_attach_IR_Laser)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"IRlaser" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};

							};
							case ("SILENCER") : {


								//-- label Silencer Button
								_silencerImage =  "A3C_CORE\ui\pictures\icon_menu_item_Silencer_OFF.paa";
								_silencerToolTip = "Attach Suppressor";

								if ({[_x,"SILENCER"] call A3C_fnc_hasWeaponItem} count (A3C_RD_UNITS - [player]) > 0) then {
									_silencerImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_ON.paa";
									_silencerToolTip = "Remove Suppressor";
								};

								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _silencerImage;
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
								(findDisplay 100040 displayCtrl _buttonImgID) ctrlShow true;
								((findDisplay 100040) displayCtrl _buttonClickerID) ctrlSetToolTip _silencerToolTip;

								_fnc = {
									params ["_btnData","_inputParams"];
									_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
									_inputParams params ["_units","_buttonImgID","_buttonClickerID"];
									_units = call compile _units;
									_btnImage = "";
									_tooltip = "";
									A3C_Prevent_attach_Silencer = true;
									_totalStandBy = 0;
									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.3];
									{

										if ({[_x,"SILENCER"] call A3C_fnc_hasWeaponItem} count A3C_RD_UNITS > 0) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_OFF.paa";
											_tooltip = "Attach Suppressor";
											_sl = [_x,"MuzzleSlot",1,(currentWeapon _x)] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_delay = random 1;
												_totalStandBy = _totalStandBy max _delay;
												[_button,_sL,_x,_delay] spawn {
													params ["_mb","_sl","_u","_delay"];
													sleep _delay;
													//if !(stance _u =="STAND") then {sleep 1};
													if ((currentWeapon _u) == (handgunWeapon _u)) then {
														_u playActionNow "gestureDismountMuzzle";
														if (A3C_LaxMount) then {

														};
														sleep 1.2;
														_u removeHandgunItem (_sl select 0);
													} else {
														_u playActionNow "gestureDismountMuzzle";
														if (A3C_LaxMount) then {

														};
														sleep 1.2;
														_u removePrimaryWeaponItem (_sl select 0);
													};
													_u additem (_sl select 0);
												};
											};
										} else {
											_sl = [_x,"MuzzleSlot",0,(currentWeapon _x)] call MCSS_fnc_getWeaponItems;
											if (count _sl > 0) then {
												_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_Silencer_ON.paa";
												_tooltip = "Remove Suppressor";
												_delay = random 1;
												_totalStandBy = _totalStandBy max _delay;
												[_button,_sL,_x,_delay] spawn {
													params ["_mb","_sl","_u","_delay"];

													sleep _delay;

													if ((currentWeapon _u) == (handgunWeapon _u)) then {
														_u playActionNow "gestureMountMuzzle";
														if (A3C_LaxMount) then {

														};
														sleep 1.2;
														_u addHandgunItem (_sl select 0);
													} else {
														_u playActionNow "gestureMountMuzzle";
														if (A3C_LaxMount) then {

														};
														sleep 1.2;
														_u addPrimaryWeaponItem (_sl select 0);
													};
													_u removeitem (_sl select 0);
												};
											};
										};
									} foreach _units;


									(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
									(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;

									sleep (_totalStandBy + 1.2);
									A3C_Prevent_attach_Silencer = false;
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"Silencer" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgID,_buttonClickerID] spawn {
									params ["_buttonImgID","_buttonClickerID"];
									waituntil {!(A3C_Prevent_attach_Silencer)};
									if (ctrlShown (findDisplay 100040 displayCtrl _buttonImgID) && {"Silencer" in (ctrlText (findDisplay 100040 displayCtrl _buttonImgID))}) then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetTextColor [1,1,1,0.6];
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlShow true;
									};
								};

							};
						};
						//-- create Button
						call compile format
						[
							"
								A3C_OUTER_RING_BTN_fnc_%1 =
								[
									%2,
									%3
								];
							",
							_buttonID,
							_prms,
							_fnc
						];
					} foreach _itemCategories;
				} else {
					BV_ITEMS = 0;
				};
			} else {
				//-- HC-BEHAVIOUR
				A3C_RADIALMODE = "HC BEHAVIOUR";

				{
					(findDisplay 100040 displayCtrl _x) ctrlShow false;
				} foreach [8001,8002,8004];
				{
					(findDisplay 100040 displayCtrl (_x select 0)) ctrlSetText "";
					(findDisplay 100040 displayCtrl (_x select 1)) ctrlSetToolTip "";
					{(finddisplay 100040 displayCtrl _x) ctrlShow false} foreach _x;
				} foreach A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED;
				_img = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\attack_ca.paa";
				_color = [1,1,1,0]; //momo

				for "_i" from 10024 to 10031 do {

					if (_i % 2 == 0) then {
						_color = switch (_i - 10024) do {
							case 0 : {[0,1,0,0.5]};
							case 2 : {[1,1,0,0.5]};
							case 4 : {[1,0,0,0.5]};
							case 6 : {[0.17,0.86,0.92,0.5]};
							default {[1,1,1,0.5]};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetText _img;
						(finddisplay 100040 displayCtrl _i) ctrlSetTextColor _color;
					} else {
						_toolTip = switch (_i - 10024) do {
							case 1 : {"SAFE"};
							case 3 : {"AWARE"};
							case 5 : {"COMBAT"};
							case 7 : {"STEALTH"};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetTooltip _toolTip;

					};
					(finddisplay 100040 displayCtrl _i) ctrlShow true;
				};

				(findDisplay 100040 displayCtrl 8003) ctrlShow true;
				(findDisplay 100040 displayCtrl 8003) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
				A3C_OUTER_RING_BTN_fnc_9 =
				[
					"SAFE",
					{
						params ["_clickData","_behaviour"];
						{
							{
								[_x,_behaviour] remoteExec ["setBehaviour",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_10 =
				[
					"AWARE",
					{
						params ["_clickData","_behaviour"];
						{
							{
								[_x,_behaviour] remoteExec ["setBehaviour",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_11 =
				[
					"COMBAT",
					{
						params ["_clickData","_behaviour"];
						{
							{
								[_x,_behaviour] remoteExec ["setBehaviour",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_12 =
				[
					"STEALTH",
					{
						params ["_clickData","_behaviour"];
						{
							{
								[_x,_behaviour] remoteExec ["setBehaviour",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
			};

		};

		case ("VEHICLES") : {

			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				A3C_RADIALMODE = 'VEHS';
				BV_LB1 = 8;
				BV_LB2 = 9;
				_bv = "BV_VEHS";
				if (_btn == 1) then {
					// RCLICK
					{
						if (!isPlayer _x) then {
							[_x] spawn MCSS_fnc_GetOut;
							
							A3C_BOARD_UNITS pushbackUnique _x;
						};
					} foreach A3C_RD_UNITS;
					player groupradio "SentCmdGetOut"; 
				} else {
					for "_i" from 8001 to 8004 do { //-- outer ring backgrounds
						(findDisplay 100040 displayCtrl _i) ctrlShow false;
					};
					for "_i" from 10008 to 10039 do {
						((findDisplay 100040) displayCtrl _i) ctrlShow false;
						((findDisplay 100040) displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
					};
					BV_MEDICAL = 0;
					BV_CBMODE = 0;
					if (BV_VEHS == 0) then {
						((findDisplay 100040) displayCtrl 8003) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
						((findDisplay 100040) displayCtrl 8003) ctrlShow true;
						if (_btn != -1) then {
							BV_VEHS = 1;
						};
						{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8002,8004];
						{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8002,8004];

						private _classes = [];
						private _classArray = ["CAR","TANK","HELICOPTER","PLANE","SHIP","STATICWEAPON"];
						{
							private _soldier = _x;
							{
								private _entities = (_soldier nearentities [_x,220]) select {
									canMove _x && 
									{
										(side _x == civilian) OR {((side _x) getfriend (side player)) > 0.6} 
									}
								};
								if (count _entities > 0) then {
									_classes pushBackUnique _x;
								};
							} foreach (_classArray - _classes);
						} foreach A3C_RD_UNITS;
						private _classCount = count _classes;
						private _btnId = 12;
						private _classIndex = 0;
						if (_classCount > 0) then {
							(findDisplay 100040 displayCtrl 8003) ctrlShow true;
							if (_classCount > 4) then {
								(findDisplay 100040 displayCtrl 8002) ctrlShow true;
								(findDisplay 100040 displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
							};
							for "_i" from 10031 to (10031 - ((_classCount - 1) * 2)) step - 2 do {
								private _btClicker = (findDisplay 100040 displayCtrl _i);
								private _btnImg = (findDisplay 100040 displayCtrl (_i - 1));
								private _currentClass = _classes select _classIndex;
								private _btnData = switch (_currentClass) do { //-- [_icon,_toolTip]
									case ("CAR") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa","WHEELED"]
									};
									case ("TANK") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa","TRACKED"]
									};
									case ("HELICOPTER") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa","HELICOPTERS"]
									};
									case ("PLANE") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa","JETS"]
									};
									case ("SHIP") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\naval_ca.paa","SHIPS"]
									};
									case ("STATICWEAPON") : {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\static_ca.paa","STATIC WEAPONS"]
									};
								};
								call compile format 
								[
									"
										A3C_OUTER_RING_BTN_fnc_%1 =
										[
											'%2',
											{
												A3C_RADIAL_VEH_KIND = '%3';
												[A3C_RD_UNITS] call A3C_UI_RADIAL_FINDVEHS;
											}
										];
									",
									_btnId,
									A3C_RD_UNITS,
									_currentClass
								];
								_btnImg ctrlSetText (_btnData select 0);
								_btClicker ctrlSetTooltip (_btnData select 1);
								{_x ctrlShow true} foreach [_btnImg,_btClicker];

								_btnId = _btnId - 1;
								_classIndex = _classIndex + 1;
							};
						};
					} else {
						BV_VEHS = 0;
					};
				};
			} else {
				//-- HC COMBATMODE
				A3C_RADIALMODE = "HC COMBAT";
				{
					(findDisplay 100040 displayCtrl _x) ctrlShow false;
				} foreach [8001,8002,8003,8004];
				{
					(findDisplay 100040 displayCtrl (_x select 0)) ctrlSetText "";
					(findDisplay 100040 displayCtrl (_x select 1)) ctrlSetToolTip "";
					{(finddisplay 100040 displayCtrl _x) ctrlShow false} foreach _x;
				} foreach A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED;
				_img = "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
				_color = [1,1,1,0]; //momo

				for "_i" from 10022 to 10031 do {
					if (_i % 2 == 0) then {
						_color = switch (_i - 10022) do {
							case 0 : {[1,0,0,0.5]};
							case 2 : {[1,1,0,0.5]};
							case 4 : {[1,1,1,0.5]};
							case 6 : {[0,1,0,0.5]};
							case 8 : {[0,0,1,0.5]};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetText _img;
						(finddisplay 100040 displayCtrl _i) ctrlSetTextColor _color;
					} else {
						_toolTip = switch (_i - 10022) do {
							case 1 : {"RED || Fire at will, engage at will"};
							case 3 : {"YELLOW || Fire at will"};
							case 5 : {"WHITE || Hold fire, engage at will"};
							case 7 : {"GREEN || Hold fire - defend only"};
							case 9 : {"BLUE || Never fire"};
						};
						(finddisplay 100040 displayCtrl _i) ctrlSetTooltip _toolTip;

					};

					(finddisplay 100040 displayCtrl _i) ctrlShow true;
				};
				{
					(findDisplay 100040 displayCtrl _x) ctrlShow false;
				} foreach [8002,8003];
				(findDisplay 100040 displayCtrl 8002) ctrlShow true;
				(findDisplay 100040 displayCtrl 8002) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
				(findDisplay 100040 displayCtrl 8003) ctrlShow true;
				(findDisplay 100040 displayCtrl 8003) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
				A3C_OUTER_RING_BTN_fnc_8 =
				[
					"RED",
					{
						params ["_clickData","_combatMode"];
						{
							{
								[_x,_combatMode] remoteExec ["setCombatMode",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];

				A3C_OUTER_RING_BTN_fnc_9 =
				[
					"YELLOW",
					{
						params ["_clickData","_combatMode"];
						{
							{
								[_x,_combatMode] remoteExec ["setCombatMode",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_10 =
				[
					"WHITE",
					{
						params ["_clickData","_combatMode"];
						{
							{
								[_x,_combatMode] remoteExec ["setCombatMode",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_11 =
				[
					"GREEN",
					{
						params ["_clickData","_combatMode"];
						{
							{
								[_x,_combatMode] remoteExec ["setCombatMode",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
				A3C_OUTER_RING_BTN_fnc_12 =
				[
					"BLUE",
					{
						params ["_clickData","_combatMode"];
						{
							{
								[_x,_combatMode] remoteExec ["setCombatMode",_x];
							} foreach (units _x);
						} foreach A3C_RD_UNITS;
					}
				];
			};
		};

		case ("REFRESH") : {
			BV_MEDICAL = 0;
			BV_CBMODE = 0;
			private _tickTime = (time - A3C_LB_TICKTIME);
			private _doubleClick = false;
			if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
				_doubleClick = true;
			};
			A3C_LB_TICKTIME = time;
			if !(_shift) then {
				if (_btn == 1) then {
					_playerGrp = group player;
					if (_doubleClick) then {
						{
							_x doWatch objNull;
							_x lookAt objNull;
							_x setUnitPos "AUTO";
						} foreach A3C_RD_UNITS;
						player groupRadio "SentBehaviourSafe";
					} else {
						//~~ why is this?? #unclear
						private _tempGrp = createGroup (side player);
						[player] joinSilent _tempGrp;
						[player] joinSilent _playerGrp;
						_playerGrp selectLeader player;
						deleteGroup _tempGrp;

						player doMove (position vehicle player);
						player moveTo (position vehicle player);
						player doFollow player;
						A3C_RD_UNITS commandFollow player;
					};
					
				} else {
					[(units group player) - [player]] call A3C_GROUP_RESET;
				};
			};
			A3C_RADIAL_HOVER = true;
		};
	};



	{
		call compile format
		[
			"
				%1 = 0;
			",
			parseText _x
		];
	} foreach ["BV_ROE","BV_BRAIN","BV_FORM","BV_STANCES","BV_ITEMS","BV_VEHS"] - [_bv];//
	if !(_mode in ["REFRESH","FORM"]) then {
		A3C_RADIAL_HOVER = _btn == -1;
	};
	if (_doRefreshGroupSelected) then {
		[] spawn {sleep 0.1; {player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS; };
	};
};

A3C_UI_RADIAL_RESET_DYNAMIC_BTNS = {
	A3C_DYNAMIC_BUTTON_ACTIONS = [];
	A3C_OUTER_RING_BTN_fnc_1 = [[],{}]; //-- Top Ring Button 1
	A3C_OUTER_RING_BTN_fnc_2 = [[],{}]; //-- Top Ring Button 2
	A3C_OUTER_RING_BTN_fnc_3 = [[],{}]; //-- Top Ring Button 3
	A3C_OUTER_RING_BTN_fnc_4 = [[],{}]; //-- Top Ring Button 4

	A3C_OUTER_RING_BTN_fnc_5 = [[],{}]; //-- Right Ring Button 1
	A3C_OUTER_RING_BTN_fnc_6 = [[],{}]; //-- Right Ring Button 2
	A3C_OUTER_RING_BTN_fnc_7 = [[],{}]; //-- Right Ring Button 3
	A3C_OUTER_RING_BTN_fnc_8 = [[],{}]; //-- Right Ring Button 4

	A3C_OUTER_RING_BTN_fnc_9 = [[],{}];  //-- Bottom Ring Button 1
	A3C_OUTER_RING_BTN_fnc_10 = [[],{}]; //-- Bottom Ring Button 2
	A3C_OUTER_RING_BTN_fnc_11 = [[],{}]; //-- Bottom Ring Button 3
	A3C_OUTER_RING_BTN_fnc_12 = [[],{}]; //-- Bottom Ring Button 4

	A3C_OUTER_RING_BTN_fnc_13 = [[],{}]; //-- Left Ring Button 1 //-- this entire last section is currently placeholder only
	A3C_OUTER_RING_BTN_fnc_14 = [[],{}]; //-- Left Ring Button 2
	A3C_OUTER_RING_BTN_fnc_15 = [[],{}]; //-- Left Ring Button 3
	A3C_OUTER_RING_BTN_fnc_16 = [[],{}]; //-- Left							 Ring Button 4

	for "_i" from 10008 to 10039 do { //BBBBBBB
		if (_i % 2 == 0) then {
			(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
		};
	};
};
//#TODO: Check if this is Radial only or used by others
A3C_UI_RADIAL_LABEL_LB = {
	private ["_isCategorySwitch"];
	
	_mode = _this select 0;
	_isCategorySwitch = if (count _this > 1) then {_this select 1} else {0};
	_orderText = "";
	_lbText1 = "";
	_lbText2 = "";
	_array1 = [];
	_array2 = [];
	(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
	{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8053,8054];
	for "_i" from 8057 to 8058 do {
		(findDisplay 100040 displayCtrl _i) ctrlShow true;
	};
	for "_i" from 8059 to 8068 do {
		(findDisplay 100040 displayCtrl _i) ctrlShow false;
	};
	
	

	switch (_mode) do {
		case ("MEDICAL") : {
			_orderText =  "Order";
			_lbText1 = "Healers";
			_lbText2 = "Patients";
			_img = "";

			_selectedMedic = objNull;
			_selectedPatient = objNull;

			private _medics_lb = (group player) getVariable ["A3C_MEDICS_LB", [] ];
			if (count _medics_lb == 1) then {
				_selectedMedic = (_medics_lb select 0);
			};
			private _patients_lb = (group player) getVariable ["A3C_PATIENTS_LB", [] ];
			if (count _patients_lb == 1) then {
				_selectedPatient = (_patients_lb select 0);
			};

			{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8055,8056,8057];
			{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];

			private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
			(group player) setVariable ["A3C_MEDICS", _medics];
			private _multiMedic = (count _medics) > 1;
			
			if (_multiMedic) then {
				[["ALL MEDICS","",objnull,(findDisplay 100040 displayCtrl 8054),"A3C_CORE\ui\pictures\icon_menu_Medical.paa"]] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay 100040 displayCtrl 8054) lbSetColor [0, [0, 1, 0, 1]];
			};

			{
				private _isMedic =   ({[_x] call TAG_fnc_baseWeapon == "Medikit"} count (items _x) > 0);
				_img = if (_isMedic) then {
					"A3C_CORE\ui\pictures\icon_menu_Medical.paa"
				} else {
					""
				};
				[
					[
						(format ["%1 (%2)",([_x] call MCSS_fnc_NAMESTRING),if (_x == player) then {""} else {getText (configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName")}]),
						(typeOf _x),
						_x,
						(findDisplay 100040 displayCtrl 8054),
						_img
					]
				] call A3C_UI_RADIAL_LB_ADD;
				private _c = [1,1,1,1];
				if (_x in (group player getVariable ["A3C_MEDICS_ACTIVE", [] ])) then {
					_c = [0.99,0.5,0.49,1];

				} else {
					if (_x in ((group player) getVariable ["A3C_MEDICS",[]])) then {
						if (_isMedic) then {
							_c = [0,1,0,1];
						} else {
							_c = [0.68,0.99,0.63,1];
						};
					};
				};
				private _add = if (_multiMedic) then {1} else {0};
				(findDisplay 100040 displayCtrl 8054) lbSetColor [_foreachIndex + _add, _c];

			} foreach _medics; // _squadAI

			_patients = [group player] call A3C_FINDPATIENTS;
			private _multiPatient = (count _patients) > 1;
			if (_multiPatient) then {
				[["HEAL ALL","",objnull,(findDisplay 100040 displayCtrl 8055),""]] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay 100040 displayCtrl 8055) lbSetColor [0, [0, 1, 0, 1]];
			};
			{
				private _c = [0.99,0.5,0.49,1];
				if (_x in (group player getVariable ["A3C_PATIENTS_DESIGNATED", []])) then {
					_c = [0.99,0.7,0.44,1];
				};
				if (_x in ((group player) getVariable["A3C_PATIENTS_ASSIGNED", [] ])) then {
					_c = [0.99,0.95,0.67,1];
				};
				[
					[
						(format ["%1 (%2)",([_x] call MCSS_fnc_NAMESTRING),getText (configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName")]),
						(typeOf _x),
						_x,
						(findDisplay 100040 displayCtrl 8055),
						""
					]
				] call A3C_UI_RADIAL_LB_ADD;
				private _add = if (_multiPatient) then {1} else {0};
				(findDisplay 100040 displayCtrl 8055) lbSetColor [_foreachIndex + _add, _c];
			} foreach _patients;

			_mSel = 0;
			_pSel = 0;
			if (!isNull _selectedMedic) then { //~~ maybe try your array index function here?
				{
					if (_x == _selectedMedic) exitWith {
						_mSel = _forEachIndex;
						if (count ((group player) getVariable ["A3C_MEDICS",[]]) > 1) then {
							_mSel = _mSel + 1;
						};

					};
				} foreach ((group player) getVariable ["A3C_MEDICS",[]]);
			};
			if (!isNull _selectedPatient) then { //~~ maybe try your array index function here?
				{
					if (_x == _selectedPatient) exitWith {
						_pSel = _forEachIndex;
						//systemchat "hey";
						if (count _patients > 1) then {
							_pSel = _pSel + 1;
						};

					};
				} foreach _patients;
			};
			[findDisplay 100040 displayCtrl 8054, _mSel, true] call A3C_setCurSel;
			[findDisplay 100040 displayCtrl 8055, _pSel, true] call A3C_setCurSel;	
		};
		case ("CBMODE") : {
			_orderText = "Unit States";
			_lbText1 = "Behaviour";
			_lbText2 = "Combat Mode";
			{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8054,8055,8057]; // ,8056
			{
				_c = switch _forEachINdex do {
					case 0 : {[0.5,0.5,0.5,1]};
					case 1 : {[0,1,0,1]};
					case 2 : {[1,1,0,1]};
					case 3 : {[1,0,0,1]};
					case 4 : {[0.17,0.86,0.92,1]};
				};
				[
					[
						_x,
						'',
						objnull,
						(findDisplay 100040 displayCtrl 8054),
						"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
					]
				] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay 100040 displayCtrl 8054) lbSetColor [_foreachIndex, _c];
			} foreach ["CARELESS","SAFE","AWARE","COMBAT","STEALTH"];
												;
			{
				_c = switch _forEachINdex do {
					case 0 : {[0,0,1,1]};
					case 1 : {[0,1,0,1]};
					case 2 : {[1,1,1,1]};
					case 3 : {[1,1,0,1]};
					case 4 : {[1,0,0,1]};
				};
				[
					[
						_x,
						'',
						objNull,
						(findDisplay 100040 displayCtrl 8055),
						"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"
					]
				] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay 100040 displayCtrl 8055) lbSetColor [_foreachIndex, _c];
			} foreach ["Never Fire","Hold fire, defend only","Hold fire, engage at will","Fire At Will","Fire at will, engage at will"];


			_lbBehaviour = switch ([A3C_RD_UNITS,"BEHAVIOUR"] call A3C_FIND_PROMINENT_UnitMode) do {
				case ("CARELESS") : {0};
				case ("SAFE") : {1};
				case ("AWARE") : {2};
				case ("COMBAT") : {3};
				case ("STEALTH") : {4};
			};
			_lbCBMode = switch ([A3C_RD_UNITS,"COMBATMODE"] call A3C_FIND_PROMINENT_UnitMode) do {
				case ("BLUE") : {0};
				case ("GREEN") : {1};
				case ("WHITE") : {2};
				case ("YELLOW") : {3};
				case ("RED") : {4};
			};
			[_lbBehaviour,_lbCBMode] spawn {
				params ["_lbBehaviour","_lbCBMode"];
				
				sleep 0.1;
				[findDisplay 100040 displayCtrl 8054, _lbBehaviour] call A3C_setCurSel;
				[findDisplay 100040 displayCtrl 8055, _lbCBMode] call A3C_setCurSel;
				sleep 0.1;
				
			};

		};


		case ("VEHICLES") : {
			_lbText1 = "SELECT VEHICLE";

			


			for "_i" from 0 to 45 do {
				if (ctrlType (findDisplay 100040 displayCtrl (10101 + _i)) != -1) then {
					ctrlDelete (findDisplay 100040 displayCtrl (10101 + _i));
					ctrlDelete (findDisplay 100040 displayCtrl (10101 + _i + 1));
				};
			};

			for "_i" from 11101 to 11104 do {
				ctrlDelete (findDisplay 100040 displayCtrl _i);
			};

			if (!isNil 'A3C_TARGETVEH') then {
				private _vehicleSeatData = [];
				//-- re-arrange
				{
					private _testedRole = _x;
					{
						if (_x select 1 == _testedRole) then {
							if (_testedRole != "driver" OR {!(A3C_TARGETVEH isKindOf "STATICWEAPON")}) then {
								_vehicleSeatData pushBackUnique _x;
							};		
						};
					} foreach (fullcrew [A3C_TARGETVEH,"",true]);
				} foreach ["driver","gunner","commander","Turret","cargo"];


				private _rowEntries = 0;
				private _rowAmount = 0;
				_GUI_GRID_X = 0;
				_GUI_GRID_Y = 0;
				_GUI_GRID_W = 0.025;
				_GUI_GRID_H = 0.04;

				private _btnH = if (count _vehicleSeatData > 15) then {1} else {2}; //-- 15 seats is threshold instead of 20 because we need the last row for 'board all'
				private _btnW = _btnH * 1.25;
				_rowThreshold = if (count _vehicleSeatData > 15) then {10} else {5};

				_btnW = _btnW * _GUI_GRID_W;
				_btnH = _btnH * _GUI_GRID_H;
				_spacingFactor = 0.1;


				private _allCrewImgIdc = [];
				private _allCargoAndFFVImgIdc = [];


				private _vehicleType = typeOf A3C_TARGETVEH;


				{
					_roleData = _x;
					_roleData params ["_occupyingUnit","_role","_cargoIndex","_turretPath","_isFFV"];

					private _buttonColor = [1,1,1,1];

					private _fei = _foreachIndex;
					private _btnImg  = (findDisplay 100040) ctrlCreate ["A3C_RscPicture", 10101 + (_fei * 2)];
					private _btnClicker  = (findDisplay 100040) ctrlCreate ["A3C_RscButton_Invisible", 10101 + (_fei * 2) + 1];
					_btnIcon = "";
					_btnTooltip = "";

					_allCrewImgIdc pushBack (10101 + (_fei * 2));
					if (_role == 'cargo' || {_isFFV}) then {_allCargoAndFFVImgIdc pushBack (10101 + (_fei * 2));};


					private _positionName = ""; //-- can not use 'role' as default value - ends up being lower case and that's not purdy
					
					switch (toLower _role) do {
						case ("driver") : {
							_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_driver_ca.paa";
							_positionName = "Driver";
						};
						case ("turret") : {
							private _cfgPath = configFile >> "CfgVehicles" >> _vehicleType;
							{
								_cfgPath = ( _cfgPath >> "turrets" ) select _x;
							}forEach _turretPath; //-- teacher: Larrow
							_positionName = getText( _cfgPath >> "gunnerName" );
							
							// systemchat str [_role, _vehicleType];
							switch (_positionName) do {
								case ("Commander") : {
									_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";

								};
								case ("Copilot") : {
									_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";
								};
								default {
									_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa";
								};
							};
							if (_isFFV) then {
								_positionName = _positionName + " - FFV";
							};
						};
						case ("gunner") : {
							_positionName = "Gunner";
							_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa";
						};
						case ("commander") : {
							_positionName = "Commander";
							_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";
						};
						case ("cargo") : {
							_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa";
							_positionName = format ["Cargo Seat %1",_cargoIndex + 1];
						};
					};


					if (!isNull _occupyingUnit && {alive _occupyingUnit}) then {
						_buttonColor = if (_occupyingUnit in units player) then {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_fnc_setOpacity} else {[A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity};

						if (_occupyingUnit in units player) then {
							_positionName = _positionName + " (" + (name _occupyingUnit) + ")";
						} else {
							_positionName = _positionName + " (occupied by " + (groupID (group _occupyingUnit)) + ")";
						};
					} else {


						private _nameAdd = " (Available)";

						_vicVar = A3C_TARGETVEH getVariable ["A3C_AssignedVehicleCrew",[]];

						private _refArray = _roleData select [1,3]; //[_roleData select 1,_roleData select _checkIndex];
						{
							_boardingData = _x;
							if ({_x in _boardingData} count _refArray >= 2) exitWith {
								_occupyingUnit = _x select 0;
								_buttonColor = if (group _occupyingUnit == group player) then {[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity} else {[A3C_UI_COLOR_RED,0.3] call A3C_UI_fnc_setOpacity};
								_nameAdd = " (Currently Boarded)";
							};
						} foreach _vicVar;
						_positionName = _positionName + _nameAdd;

					};
					_btnImg ctrlSetTextColor _buttonColor;
					_btnClicker ctrlSetTooltip _positionName;
					//-- when looking at this fnc, keep in mind that it requires vehicleVarname or an !isNull object. Hence the format (Player units have vehicleVarname
					_btnClicker ctrlAddEventHandler
					[
						"MouseButtonDown",
						compile format
						[
							"
								_roleArray = [%1] + %2;
								[_roleArray,_this select 1,%3,objNull] call A3C_AssignVehicleSeat;
							",
							if (_occupyingUnit in units player) then {_occupyingUnit} else {if (isNull _occupyingUnit OR {!alive _occupyingunit}) then {0} else {1}},
							_roleData select [1,4],
							10101 + (_fei * 2)
						]
					];


					{
						_x ctrlSetPosition
						[
							(35.5 * _GUI_GRID_W + _GUI_GRID_X) + (_rowEntries * (_btnW + (_btnW * _spacingFactor))),
							(11.5 * _GUI_GRID_H + _GUI_GRID_Y) + (_rowAmount * (_btnH + (_btnH * _spacingFactor)) ),
							_btnW,
							_btnH
						];
						_x ctrlCommit 0;
					} foreach [_btnImg,_btnClicker];

					_btnImg ctrlSetText _btnIcon;


					_rowEntries = _rowEntries + 1;
					if (_rowEntries == _rowThreshold) then {
						_rowEntries = 0;
						if (_foreachIndex < ((count _vehicleSeatData) - 1)) then {
							_rowAmount = _rowAmount + 1;
						};
					};
				} foreach _vehicleSeatData;

				_rowAmount = _rowAmount + 1;
				if (!isNull A3C_TARGETVEH && {count A3C_RD_UNITS > 1 && {count _vehicleSeatData > 1}}) then {
					//-- macro buttons
					for "_i" from 0 to 1 do {

						private _btnImg  = (findDisplay 100040) ctrlCreate ["A3C_RscPicture", 11101 + (_i * 2)];
						private _btnClicker  = (findDisplay 100040) ctrlCreate ["A3C_RscButton_Invisible", 11101 + (_i * 2) + 1];

						_btnIcon = switch (_i) do {
							case (0) : {"\a3\ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa"};
							case (1) : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"};
						};
						_btnImg ctrlSetText _btnIcon;

						_btnTooltip = switch (_i) do {
							case (0) : {"BOARD ALL POSITIONS"};
							case (1) : {"BOARD CARGO & FFV"};
						};
						_btnClicker ctrlSetTooltip _btnTooltip;
						{
							_x ctrlSetPosition
							[
								(39  * _GUI_GRID_W + _GUI_GRID_X) + (_i * (_btnW + (_btnW * _spacingFactor))),
								(11.5 * _GUI_GRID_H + _GUI_GRID_Y) + (_rowAmount  * (_btnH + (_btnH * _spacingFactor)) ),
								_btnW,
								_btnH
							];
							_x ctrlCommit 0;
						} foreach [_btnImg,_btnClicker];

						private _units = +(A3C_RD_UNITS);
						_btnClicker ctrlAddEventHandler
						[
							"MouseButtonDown",
							compile format
							[
								"
									[A3C_TARGETVEH,'%1',_this select 1,%2] spawn A3C_AssignVehicleSeatMacro;
								",
								if (_i == 0) then {'all'} else {'cargoFFV'},
								_units
							]
						];
					};
				};
				
				//-- add macro options: getIn all, all cargoFFV

				if (_isCategorySwitch == 0) then {
					{
						_c = (crew _x) - [player];
						_n = "";
						{
							if ((group _x) == (group player)) then {
								_n = _n + ([_x,1,true,if (_foreachindex == ((count _c) - 1)) then {true} else {false}] call MCSS_fnc_NAMESTRING);
							} else {
								_c = _c - [_x];
							};
						} foreach _c;
						if !(_n == "") then {
							_n = "(" + _n + ")";
						};
						[
							[
								format
								[
									"%1 %2",
									(getText (configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName")),
									_n
								],
							(typeOf _x),
							_x,
							(findDisplay 100040 displayCtrl 8054),
							""
							]
						] call A3C_UI_RADIAL_LB_ADD;
					} foreach A3C_VEHSAV;
				};
			};

			
		};
	};

	(findDisplay 100040 displayCtrl 8056) ctrlSetText _orderText;
	(findDisplay 100040 displayCtrl 8057) ctrlSetText _lbText1;
	(findDisplay 100040 displayCtrl 8058) ctrlSetText _lbText2;
};

A3C_UI_RADIAL_BTN_REINIT = {

	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};

	} foreach A3C_RD_UNITS;


	((findDisplay 100040) displayctrl 9009) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";

	[0] call A3C_GREN_DATA;
	{
		{
			if (_x call BIS_fnc_IsThrowable) then {
				if !(_x in A3C_AI_GREN_ARRAY) then {
					A3C_AI_GREN_ARRAY pushback _x;
				};
			};
		} foreach (magazines _x);
	} foreach A3C_RD_UNITS;

	switch (A3C_RADIALMODE) do {
		case ("ITEMSS") : {
			_w = "";
			_t = "";
			if (({(currentweapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS) > 0) then {
				_w = (primaryWeapon (A3C_RD_UNITS select 0));
				_t = "Main Weapon";
			} else {
				_w = (handGunWeapon (A3C_RD_UNITS select 0));
				_t = "Hand Gun";
			};

			((findDisplay 100040) displayCtrl 10028) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
			((findDisplay 100040) displayCtrl 10029) ctrlSetToolTip (format ["Switch to %1",_t]);

			((findDisplay 100040) displayCtrl 10030) ctrlSetText "";
			((findDisplay 100040) displayCtrl 10031) ctrlSetToolTip "";
			BV_MEDICAL = 0;
			BV_CBMODE = 0;

			_laserImage = if ({_x isIRLaserOn (currentWeapon _x) OR {_x isFlashLightOn (currentWeapon _x)}} count (A3C_RD_UNITS - [player]) > 0) then {
				"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa"
			} else {
				"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa"
			};
			((findDisplay 100040) displayCtrl 10026) ctrlSetText _laserImage;
			((findDisplay 100040) displayCtrl 10027) ctrlSetToolTip "LMB: ENABLE IR (requires 'DANGER') , RMB: DISABLE IR";

			_strobeImage = if ({count (_x getvariable "A3C_STROBE") > 0} count (A3C_RD_UNITS - [player]) > 0) then {
				"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa"
			} else {
				"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa"
			};

			((findDisplay 100040) displayCtrl 10030) ctrlSetText _strobeImage;
			((findDisplay 100040) displayCtrl 10031) ctrlSetToolTip "LMB: ATTACH IR-STROBES , RMB: DETACH IR-STROBES";

		};
		case ("VEHS") : { //~~unused

			BV_MEDICAL = 0;
			BV_CBMODE = 0;


			((findDisplay 100040) displayCtrl 10024) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa";
			((findDisplay 100040) displayCtrl 10025) ctrlSetToolTip "JET";
			((findDisplay 100040) displayCtrl 10026) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa";
			((findDisplay 100040) displayCtrl 10027) ctrlSetToolTip "HELI";
			((findDisplay 100040) displayCtrl 10028) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa";
			((findDisplay 100040) displayCtrl 10029) ctrlSetToolTip "TRACKED";
			((findDisplay 100040) displayCtrl 10030) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa";
			((findDisplay 100040) displayCtrl 10031) ctrlSetToolTip "WHEELED";

			for "_i"from 10024 to 10031 step 2 do {
				((findDisplay 100040) displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
			};

		};
	};

};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

A3C_UI_RADIAL_CloseDisplay = {
	showHud ([true]  + (shownhud select [1,10]));
	(findDisplay 100040) closeDisplay 0;
};



A3C_UI_RADIAL_CTRLS_QUICKTOGGLE = {
	params ["_mode"];
	private _bool = false;

	if (_mode == 0) then {
		_bool = true;
		if (!A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED) then {

			A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = true;
			A3C_UI_RADIAL_CTRLS_SHOWN = [];

			{
				if (ctrlShown _x) then {
					A3C_UI_RADIAL_CTRLS_SHOWN pushBackUnique _x;
					_x ctrlShow false;
				};
			} foreach (allControls findDisplay 100040);
		};
		
	} else {
		(findDisplay 100040 displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false; //-- hide HC-dashboard
		A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;
		{
			_x ctrlShow true;
		} foreach A3C_UI_RADIAL_CTRLS_SHOWN;
		(findDisplay 100040 displayCtrl 8095) ctrlShow false;
		A3C_UI_RADIAL_CTRLS_SHOWN = [];
		if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
			[] call A3C_UI_SHARED_createDashBoard;
		};
	};
	_bool
};



A3C_UI_RADIAL_LABEL_SELECTORS = { //~~ currently unused
	
	systemchat'alert lbselectorradial';

	private ["_mode","_limit","_text","_textCol","_backCol","_u","_unitIndex"];
	//_mode = _this select 0;  //~~??
	_text = "";
	_textCol = [];
	_backCol = [1,1,1,0.7];
	_u = objnull;
	_unitIndex = -1;
	_a3c_dsp = 100040;
	_sub = 8000;
	_from = 8073;
	_to = 8090;
	private _unitArray = A3C_RD_UNITS; //if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {A3C_RD_UNITS} else {A3C_HC_getAllGroups_Player_Current};

	private _referenceArray1 = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {((profileNamespace getvariable "A3C_GROUPUNITS") - [player])} else {_r = A3C_HC_getAllGroups_Player_Current_ORGANIZED; A3C_HC_MENU_REFERENCE_UNITS = _r; _r};
	private _referenceArray2 = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {(profileNamespace getvariable "A3C_GROUPUNITS")} else {_referenceArray1};

	_showHOLDCONT = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {true} else {false};
	for "_i" from 8097 to 9000 do {
		(findDisplay 100040 displayCtrl _i) ctrlShow _showHOLDCONT;
	};

	_limit = 72 + ((count _referenceArray1) - (A3C_BUTTONPAGE_TABLET * 18));
	if (_limit > 90) then {_limit = 90};
	for "_i" from 73 to 90  do {
		if (_i <= _limit) then {
			_unitIndex = ( (_i - 72) + (A3C_BUTTONPAGE_TABLET * 18) );
			if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
				_unitindex = _unitindex - 1;
			};
			_u = (_referenceArray2 select _unitIndex);
			if ((typename _u == "OBJECT" && {isNull _u}) OR (typename _u == "GROUP" && {{!isNull _x} count units _u == 0})) then {
				_text = 'N/A';
				_textCol = [0,0,0,0.2];
				_backCol = [1,0,0,0.2];
			} else {
				_backCol = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {[_u] call A3C_GET_UB_COLOR} else {[A3C_UI_COLOR_BLUE,0.8] call A3C_UI_fnc_setOpacity};

				call compile format
				[
					"
						if (_u in _unitArray) then {
							_textCol = [1,1,1,1];
							A3C_UNIT_%1_BV = 1;
						} else {
							_textCol = [1,1,1,0.5];
							A3C_UNIT_%1_BV = 0;
						};
					",
					_unitIndex
				];
				if ((typename _u == "OBJECT" && {!alive _u}) OR (typename _u == "GROUP" && {{alive _x} count units _u == 0})) then {
					_text = 'N/A';
					_textCol =  [0.5,0.5,0.5,0.2];
				} else {
					if (typename _u == "OBJECT") then {
						_text = [_u] call MCSS_fnc_NAMESTRING;
					} else {
						_text = groupID _u;
					};
				};
				if (typename _u == "OBJECT") then {
					if (isPlayer _u) then {
						_backCol = [0.86,0.47,0.56,1];
					} else {

						[_u,_i] spawn {
							private ['_unit','_control'];
							_unit = _this select 0;
							_control = _this select 1;
							_unit setvariable ['A3C_Unt_Btn',_control,true];
						};
					};
				};
			};
			(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlShow true;
			(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlsettext _text;
			(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlSetTextColor _textCol;
			(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlSetBackgroundColor _backCol;
		} else {
			//-- no unit for button
			(findDisplay _a3c_dsp displayCtrl (_sub + _i)) ctrlShow false;
		};
	};
	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
		if (count A3C_RD_UNITS > 0 ) then {
			if (ctrlShown (findDisplay 100040 displayCtrl 8001)) then {
				["ROE",0] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
			};
		};
	};

};




A3C_UI_RADIAL_TOGGLE_LEFT_EXT = {
	params ["_mode"];
	if (_mode == "OPEN") then {
		if (A3C_RD_BOOL_UNITS) then {
			if !(ctrlShown (findDisplay 100040 displayCtrl 8071)) then {
				playsound "ReadOutHideClick1"; 
				A3C_RD_BOOL_UNITS = false;
				{
					(findDisplay 100040 displayCtrl _x) ctrlShow true
				} foreach [8071,8096,8097,8098,8099,9000];
				(findDisplay 100040 displayCtrl 8095) ctrlShow false;
				[100040,if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {"INF"} else {"HC"}] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
				[0] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;
				[100040,8071] execFSM "A3C_CORE\FSM\A3C_MON_RADIAL.fsm";
			}
		};
	} else {
		if (ctrlShown(findDisplay 100040 displayCtrl 8071)) then {
			playsound "ReadOutHideClick1"; 
			{
				(findDisplay 100040 displayCtrl _x) ctrlShow false;
			} foreach [8071,8096,8097,8098,8099,9000];
			A3C_RD_BOOL_UNITS = false;
		};
	};
};



A3C_UI_RADIAL_FINDVEHS = {
	params ["_units"];
	private _entities = if (count _this > 1) then {_this select 1} else {[A3C_RADIAL_VEH_KIND]};
	A3C_VEHSAV= [];
	A3C_BOARD_UNITS = [];
	{
		{
			_v = _x;
			if (canMove _v) then {
				if ( (side _x == civilian) OR ( ((side _x) getfriend (side player)) > 0.6)  ) then {
					A3C_VEHSAV pushbackUnique _v;
				};
			};

		} foreach (_x nearentities [_entities,220]);
		if ((vehicle _x) isKindOf A3C_RADIAL_VEH_KIND) then {
			A3C_VEHSAV pushbackUnique (vehicle _x);
		};
	} foreach _units;
	if (count A3C_VEHSAV > 0) then {
		A3C_TARGETVEH = A3C_VEHSAV select 0;
		{
			if (isnull objectParent _x) then {
				if !(_x in A3C_BOARD_UNITS) then {
					if !(_x in A3C_BOARD_UNITS_ACTIVE) then {
						A3C_BOARD_UNITS pushbackUnique _x;
					};
				};
			};
		} foreach _units;
	} else {
		A3C_TARGETVEH = objnull;
	};


	if ((count A3C_VEHSAV) == 0) then { //~~ probably no longer used
		[["NO VEHICLES","",objnull,(findDisplay 100040 displayCtrl 8054),""]] call A3C_UI_RADIAL_LB_ADD;
	};
	{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];

	
	
	
	[] spawn {
		["VEHICLES"] call A3C_UI_RADIAL_LABEL_LB;	
		sleep 0.1;
		
		if (cursortarget in A3C_VEHSAV) then {
			[findDisplay 100040 displayCtrl 8054, [cursorTarget,A3C_VEHSAV] call MCSS_fnc_GetArrayIndex, true] call A3C_setCurSel;
		//ashash
		} else {
			//
			{
				[findDisplay 100040 displayCtrl _x, 0] call A3C_setCurSel;
			} foreach [8054,8055];
		};	
	};
};








A3C_UI_RADIAL_FNC_TEAMCOLOR = {
	_color = _this select 0;
	_btn = _this select 1;
	_ctrl = _this select 2;
	_units = [];

	{
		private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		if (_assignedTeam == _color) then {
			_units pushback _x;
		};
	} foreach units group player - [player];
	if (_color == "PURPLE") then {
		_units = (units group player) - [player];
	};
	if (A3C_RADIAL_VAL ==0) then {
		A3C_RADIAL_VAL = 1;
		if !(_color == "PURPLE") then {
			{player groupSelectUnit [_x, false]} foreach units group player;
		};
	};

	_count = ({_x in (groupSelectedUnits player)} count _units);
	if (_btn == 1) then {
		_units commandFollow player;
	} else {
		if (_count == (count _units)) then {
			{
				player groupSelectUnit [_x, false];
			} forEach _units;
		} else {
			{
				if !(_x in (groupSelectedUnits player)) then {
					player groupSelectUnit [_x, true];
				};
			} forEach _units;
		};
	};
	

	private _CT_TREE = findDisplay 100040 displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
	_CT_TREE tvSetCurSel [-1];

	A3C_RD_UNITS = groupselectedUnits player;
	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};
	} foreach A3C_RD_UNITS;

	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");
	for "_t" from 8073 to 8090 do {
		_index = ((_t - 8072) + (A3C_BUTTONPAGE_TABLET * 18));
		if (_index < (count _unitArray)) then {
			if ((_unitArray select _index) in A3C_RD_UNITS) then {
				(findDisplay 100040 displayCtrl _t) ctrlSetTextColor [1,1,1,0.6];
			} else {
				(findDisplay 100040 displayCtrl _t) ctrlSetTextColor [1,1,1,0.5];
			};
		};
	};
	A3C_BOARD_UNITS = [];
	{
			if (isnull objectParent _x) then {
				if !(_x in A3C_BOARD_UNITS) then {
					A3C_BOARD_UNITS pushbackUnique _x;
				};
			};
	} foreach A3C_RD_UNITS;
	if (BV_MEDICAL == 1) then {
		["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
	};
	[] call A3C_UI_RADIAL_BTN_REINIT;
};


A3C_UI_RADIAL_UPDATE_MEDICAL = {
	// player sidechat 'update UI';
	if (A3C_LBR_1 == 'MEDICAL') then {
		if (ctrlShown (findDisplay 100040 displayCtrl 8056)) then {

			{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
			["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
		};
	};
};

A3C_UI_RADIAL_INV_LB_CREATE = {
	params ["_target","_source"];

	if (isNull _target) exitWith {};
	A3C_DISABLE_RADIAL = true;
	(findDisplay 602) closeDisplay 0;
	waitUntil {isNull (findDisplay 602)};
	sleep 0.2;
	A3C_UI_INV_CONTAINERS = [];
	if (_source == _target) then {
		_source = "GroundWeaponHolder" createVehicle (position _target);

	};


	_target action ['GEAR',_source];

	_nearCrates =  (_target nearObjects 5) - (units player);
	{
		if (_x distance _target < 5 && {_x isKindOf "MAN"}) then {
			if (!captive _x OR {(side _x != side player) OR {isplayer leader group _x}}) then {
				_nearCrates = _nearCrates - [_x];
			};
		} else {
			_cargo =( magazineCargo _x) + (weaponCargo _x);

			if (count _cargo == 0) then {

				_nearCrates = _nearCrates - [_x];
			} else {

			};
		};
	} foreach _nearCrates;


	A3C_UI_INV_TARGETS = (units player);


	{
		//if (_x distance _target < 4) then {
			A3C_UI_INV_CONTAINERS pushBackUnique _x;
		//};
		
	} foreach ((((units player) select {_target distance2D _x < 5})  - [_target]) + _nearCrates + [_target]); // -- no better idea how to shuffle the target to the end


	waitUntil { !(isNull (findDisplay 602)) };
	sleep 0.1;
	A3C_DISABLE_RADIAL = false;

	_box1 = (findDisplay 602) ctrlCreate ["A3C_RscCombo",1928]; //-- A3C_RscXListBox
	_box2 = (findDisplay 602) ctrlCreate ["A3C_RscCombo",1929];
	private _lbHeight = (0.033 * safezoneH) ; // times x?

	{
		_x params ["_box","_refCtrl"];
		_ctrlPos = ctrlPosition (findDisplay 602 displayCtrl _refCtrl);
		_box ctrlSetPosition [_ctrlPos select 0, (_ctrlPos select 1) - _lbHeight,_ctrlPos select 2,_lbHeight];
		_box ctrlCommit 0;
	} foreach [[_box1,1001],[_box2,1020]];
	{
		[_box2, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
	} foreach A3C_UI_INV_TARGETS;
	{

		switch (true) do {
			case (typeOf _x == "GroundWeaponHolder" OR {_x == A3C_UI_INV_TARGET_UNIT}) : {

				[_box1, "Ground"] call A3C_addLbEntry;
			};
			case (_x in units player) : {
				[_box1, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
			};
			default {
				private _lbText = gettext(configFile >> "CfgVehicles" >> typeof _x >> "displayName");
				[_box1, _lbText] call A3C_addLbEntry;
			};
		};


	} foreach A3C_UI_INV_CONTAINERS;

	{

		if (_x == _source OR {_x == A3C_UI_INV_TARGET_UNIT && {typeOf _source == "GroundWeaponHolder"}}) then {
			[_box1, _foreachIndex] call A3C_setCurSel;
		};
	} foreach A3C_UI_INV_CONTAINERS;
	{
		if (_x == _target) then {
			[_box2, _foreachIndex] call A3C_setCurSel;
		};
	} foreach A3C_UI_INV_TARGETS;



	_box1 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			_container = A3C_UI_INV_CONTAINERS select (_this select 1);
			[A3C_UI_INV_TARGET_UNIT,_container] spawn A3C_UI_RADIAL_INV_LB_CREATE;
		}
	];
	_box2 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			A3C_UI_INV_TARGET_UNIT = A3C_UI_INV_TARGETS select (_this select 1);
			[A3C_UI_INV_TARGET_UNIT,A3C_UI_INV_TARGET_UNIT] spawn A3C_UI_RADIAL_INV_LB_CREATE;
		}
	];


};