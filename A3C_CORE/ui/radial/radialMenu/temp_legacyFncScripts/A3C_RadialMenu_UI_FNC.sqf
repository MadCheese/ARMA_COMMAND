#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

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
	_boxPos = ctrlPosition (findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP);
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
				private _teamBox = (findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX);

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
					_add = {_x in A3C_UI_squadPlacement_units} count A3C_RD_UNITS == 0;
					{
						if (_add) then {
							if !(_x in A3C_UI_squadPlacement_units) then {
								[_x,_x getvariable "A3C_FORMATION_INDEX"] call A3C_UI_squadPlacement_fnc_addUnitGhost;
							};
						} else {
							if (_x in A3C_UI_squadPlacement_units) then {
								[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
							};
						};
					} foreach A3C_RD_UNITS;
				} else {
					if !((_unitArray select _unitIndex) in A3C_UI_squadPlacement_units) then {
						[(_unitArray select _unitIndex),(_unitArray select _unitIndex) getvariable "A3C_FORMATION_INDEX"] call A3C_UI_squadPlacement_fnc_addUnitGhost;
					} else {
						[(_unitArray select _unitIndex)] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
					};
				};
			};
		};
	};
};


///////////////////////////////////////////////////////////////////////

///////////////// STUFF THAT REQUIRES CARE BECAUSE CONTROLS ARE EDITED IN FOR-LOOPS

A3C_UI_Shared_GetBackgroundColor = {
    params ["_mode"];

    private _radialBackgrounds = [];
    private _hudBackground = controlNull;

    switch (_mode) do {
        case "RADIAL": {
            _radialBackgrounds = (
                (["radial_extendedBackgrounds"] call FUNC(ctrlGroup))
                + [
                    ["bgCore"] call FUNC(ctrl)
                ]
            ) select {!isNull _x};
        };

        case "HUD_MENU": {
            private _hudDisplay = uiNamespace getVariable ["A3C_UI_squadPlacement_overlay", displayNull];
            if (!isNull _hudDisplay) then {
                _hudBackground = _hudDisplay displayCtrl 15;
            };
        };
    };

    if (sunOrMoon < 1) then {
        switch (_mode) do {
            case "RADIAL": {
                {
                    _x ctrlSetTextColor [0,0.5,0.8,0.6];
                } forEach _radialBackgrounds;
            };

            case "HUD_MENU": {
                if (!isNull _hudBackground) then {
                    _hudBackground ctrlSetTextColor [0,0.5,0.8,0.4];
                };
            };
        };
    } else {
        switch (_mode) do {
            case "RADIAL": {
                {
                    _x ctrlSetTextColor [0,0,0,0.6];
                } forEach _radialBackgrounds;
            };

            case "HUD_MENU": {
                if (!isNull _hudBackground) then {
                    _hudBackground ctrlSetTextColor [0,0,0,0.4];
                };
            };
        };
    };

    if (_mode == "HUD_MENU" && {(currentVisionMode player) == 1}) then {
        if (!isNull _hudBackground) then {
            _hudBackground ctrlSetTextColor [0,0.5,0.8,0.4];
        };
    };
};

A3C_UI_RADIAL_TOGGLE_OUTER_RING = {

    params ["_bool"];

	// Outer ring backgrounds/buttons/images
	{
		_x ctrlShow _bool;
	} forEach (
		(["radial_outerButtonMacros"] call FUNC(ctrlGroup))
		+ (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
	);
};
A3C_UI_RADIAL_LABEL_INNER_RING = {
	params ["_commandLevel"];

	//-- Clean wipe: hide all radial UI elements (inner ring, outer ring buttons, and outer backgrounds)
	{
		_x ctrlShow false;
	} forEach (
		(["radial_innerButtonMacros"] call FUNC(ctrlGroup))
		+ (["radial_outerButtonMacros"] call FUNC(ctrlGroup))
		+ (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
	);




	{
		_x ctrlShow false;
	} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));


	//-- no need to reset formation stuff. WHen switched, RD_UNITS is [] anyways

	A3C_RADIAL_HOVER = true;

	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_FORMATION_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_form_Wedge.Paa";
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_FORMATION_BTN) ctrlSetToolTip "FORMATIONS"; //-- move unstuck to it's own action
	
	//-- hide formation button ( #UNCLEAR not sure why?)
	{
		_x ctrlShow true;
	} forEach ([
		["innerFormationImg"] call FUNC(ctrl),
		["innerFormationBtn"] call FUNC(ctrl)
	] select {!isNull _x});

	private _teamColorMode = "INF";
	if (_commandLevel == "SQUAD") then {
		
		showHud ([false] + (shownhud select [1,10]));

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_CORE_REFRESHDATA_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_CORE_REFRESHDATA_BTN) ctrlShow true;


		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG) ctrlSetText  "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN) ctrlSetToolTip "AI Actions";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_ROE_main.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_BTN) ctrlSetToolTip "RULES OF ENGAGEMENT";

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_groupManagement.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN) ctrlSetToolTip "AI AUTO_FUNCTIONS";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN) ctrlSetToolTip "AI STANCES (RMB: TOGGLE GOCODES)";

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";// ((getText (configfile >> "CfgWeapons" >> (primaryWeapon (A3C_RD_UNITS select 0)) >> "picture")));
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN) ctrlSetToolTip "WEAPON ITEMS";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN) ctrlSetToolTip "LMB: TOGGLE VEHICLE OPTIONS || RMB: DISMOUNT SELECTED UNITS";

		
		{
			_x ctrlShow true;
		} forEach (["radial_innerButtonMacros"] call FUNC(ctrlGroup));



		[0] call A3C_GREN_DATA;
		[] call A3C_UI_RADIAL_populateOuterRing_Grenades;

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;

	} else {
		showHud ([true] + (shownhud select [1,10]));

		[] call A3C_UI_SHARED_createDashBoard;

		

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_CORE_REFRESHDATA_IMG) ctrlShow false;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_CORE_REFRESHDATA_BTN) ctrlShow false;
		
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_pin.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN) ctrlSetToolTip format ["MOVE - CONFIRM WITH 'Spacebar', CANCEL BY RELEASING %1",["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION];

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_IMG) ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ROE_BTN) ctrlSetToolTip "HC-ACTIONS";

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN) ctrlSetToolTip "HC STANCES";

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN) ctrlSetToolTip "GO CODES";



		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG) ctrlSetText "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\attack_ca.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN) ctrlSetToolTip "HC BEHAVIOUR";

		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG) ctrlSetText "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN) ctrlShow true;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN) ctrlSetToolTip "HC COMBAT-MODE";


		A3C_RD_BOOL_UNITS = true;

		{
			_x ctrlShow true;
		} forEach (["radial_holdContinueMacros"] call FUNC(ctrlGroup));

		
	};

	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false; //-- teamcolor listbox - has to happen after UNIT SELECTOR group is opened
	[IDD_RADIAL_MENU] call A3C_UI_MAP_TREE_LABEL; 
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

	{
		_x ctrlSetTextColor [1,1,1,0.6];
	} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));
};

A3C_UI_RADIAL_BTN_FNC_RING_INNER = { //-- the inner ring functions. must assign fncs and images to buttons
	private ["_bv"];

	_mode = _this select 0;
	_btn = if ((count _this) > 1) then {(_this select 1)} else {-1};
	_shift = if ((count _this) > 2) then {(_this select 2)} else {false};
	_doToggle = if ((count _this) > 3) then {(_this select 3)} else {true};

	
	
	
	A3C_RD_BOOL_UNITS = true;


	//-- define outer ring buttons:
	private _outerButtonMacros = ["radial_outerButtonMacros"] call FUNC(ctrlGroup);
	private _outerImages = ["radial_outerImages"] call FUNC(ctrlGroup);
	private _outerButtons = ["radial_outerButtons"] call FUNC(ctrlGroup);


	
	//-- exit if fnc-area was defined
	if (!(_mode == 'FORM') && !(A3C_RADIAL_HOVER) && (_btn == -1)) exitWith {};

	if (_mode == 'FORM' && {A3C_CURRENT_COMMAND_LEVEL == "SQUAD"}) then {A3C_RADIAL_HOVER = true} else {A3C_RADIAL_HOVER = false};
	if !(_mode == "FORM") then {
		playsound "ReadOutHideClick1";
	};
	_bv = "";

	private _doRefreshGroupSelected = true;
	{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;

	[] call A3C_UI_RADIAL_RESET_DYNAMIC_BTNS; //-- reset outer ring buttons

	A3C_LBR_1 = "";


	//-- Vehicle buttons - idc's are numeric because they are dynamically created with ctrlCreate
	for "_i" from 0 to 45 do {
		if (ctrlType (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i)) != -1) then {
			ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i));
			ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i + 1));
		};
	};

	for "_i" from 11101 to 11104 do {
		ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl _i);
	};

	


	switch (_mode) do {

		case ("RINGFORM") : {
			_bv = "BV_RINGFORM";
			A3C_RADIALMODE = "RINGFORM";

			if (_btn == 1) exitWith {
				//-- RMB on inner circle formation button >> adjust group formation direction
				(group player) setFormDir (getDir (vehicle player));
				player groupRadio "VehicleWatchPos";
			};
			
			if (BV_RINGFORM == 0) then {
				if (_btn != -1) then {
					BV_RINGFORM = 1;
				};

				//-- Outer ring reset: hide all, clear images and tooltips
				{
					_x ctrlShow false;
				} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

				{
					_x ctrlSetText "";
				} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

				{
					_x ctrlSetToolTip "";
				} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));

				private _formations = [
					"COLUMN",
					"STAG COLUMN",
					"WEDGE",
					"ECH LEFT",
					"ECH RIGHT",
					"VEE",
					"LINE",
					"FILE",
					"DIAMOND"
				];

				private _outerRingBackgroundIDs = ["PlaceHolder", "Left", "bottom", "Right", "Top"];
				private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);

				{
					private _ind = _forEachIndex + 1;

					if (_ind <= ((ceil ((count _formations) / 4)) min 3)) then {
						_x ctrlShow true;
						_x ctrlSetText format [
							"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
							_outerRingBackgroundIDs select _ind
						];
					} else {
						_x ctrlShow false;
					};
				} forEach _outerRingBackgrounds;

				private _imageStrings = [
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

				private _formationSlots = [
					[16, "outerLeft4Img", "outerLeft4Btn"],
					[15, "outerLeft3Img", "outerLeft3Btn"],
					[14, "outerLeft2Img", "outerLeft2Btn"],
					[13, "outerLeft1Img", "outerLeft1Btn"],

					[12, "outerBottom4Img", "outerBottom4Btn"],
					[11, "outerBottom3Img", "outerBottom3Btn"],
					[10, "outerBottom2Img", "outerBottom2Btn"],
					[9,  "outerBottom1Img", "outerBottom1Btn"],

					[8,  "outerRight4Img", "outerRight4Btn"],
					[7,  "outerRight3Img", "outerRight3Btn"],
					[6,  "outerRight2Img", "outerRight2Btn"],
					[5,  "outerRight1Img", "outerRight1Btn"],

					[4,  "outerTop4Img", "outerTop4Btn"],
					[3,  "outerTop3Img", "outerTop3Btn"],
					[2,  "outerTop2Img", "outerTop2Btn"],
					[1,  "outerTop1Img", "outerTop1Btn"]
				];

				//-- Label button images and functions.
				{
					private _slot = _formationSlots param [_forEachIndex, []];
					if (_slot isEqualTo []) exitWith {};

					_slot params ["_buttonItem", "_btnImageKey", "_btnClickerKey"];

					private _btnImage = [_btnImageKey] call FUNC(ctrl);
					private _btnClicker = [_btnClickerKey] call FUNC(ctrl);

					if (isNull _btnImage || {isNull _btnClicker}) exitWith {};

					{
						_x ctrlShow true;
					} forEach [_btnImage, _btnClicker];

					private _btnImagePath = format [
						"A3C_CORE\ui\pictures\icon_menu_form_%1.paa",
						_imageStrings select _forEachIndex
					];

					_btnImage ctrlSetText _btnImagePath;
					_btnClicker ctrlSetToolTip _x;

					call compile format [
						"
							A3C_OUTER_RING_BTN_fnc_%1 =
							[
								[],
								{
									private _mb = (_this select 0) select 1;

									['%2'] spawn A3C_Shared_setFormation;

									if (_mb == 1) then {
										(group player) setFormDir (getDir (vehicle player));

										[] spawn {
											hint 'FORMATION-DIR ADJUSTED';
											sleep 1;
											player groupRadio 'VehicleWatchPos';
											sleep 1;
											hintSilent '';
										};
									};
								}
							];
						",
						_buttonItem,
						_x
					];
				} forEach _formations;
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
					

					//-- RIGHT EXTENSION: hide all controls
					{
						_x ctrlShow false;
					} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));
					
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

					//-- RIGHT EXTENSION: hide all controls
					{
						_x ctrlShow false;
					} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

					[IDD_RADIAL_MENU,A3C_RD_UNITS] call A3C_UI_RADIAL_SQUAD_DISTRIBUTE_MENU_ACTIONS;
					
					_outerRingBackGroundIDs = ["Placeholder","Top","Right","bottom"];
					private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);
					//-- Update outer ring backgrounds for available action pages
					{
						private _ind = _forEachIndex + 1;

						if (_ind <= ((ceil ((count A3C_DYNAMIC_BUTTON_ACTIONS) / 4)) min 3)) then {
							_x ctrlShow true;
							_x ctrlSetText format [
								"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
								_outerRingBackGroundIDs select _ind
							];
						} else {
							_x ctrlShow false;
						};
					} forEach _outerRingBackgrounds;

					//-- Reset outer ring button/image color
					{
						_x ctrlSetTextColor [1,1,1,0.6];
					} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));
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
					//-- Hide outer ring buttons/images and backgrounds
					{
						_x ctrlShow false;
					} forEach (
						(["radial_outerButtonMacros"] call FUNC(ctrlGroup))
						+ (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
					);
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

						//-- show top and right ring 
						{
							_x ctrlShow true;
						} forEach ([
							["bgTop"] call FUNC(ctrl),
							["bgRight"] call FUNC(ctrl)
						] select {!isNull _x});
						
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_TOP) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Top.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right_Var1.paa";
						
						//-- TOP RING
						{
							_x ctrlShow true;
						} forEach (["radial_outerTopMacros"] call FUNC(ctrlGroup));

						private _topIcons = [
							"A3C_CORE\ui\pictures\icon_menu_ROE_FAW.paa",
							"A3C_CORE\ui\pictures\icon_menu_ROE_FOT.paa",
							"A3C_CORE\ui\pictures\icon_menu_ROE_FOML.paa",
							if ({_x in A3C_DANGER_UNITS} count A3C_RD_UNITS == 0) then {
								"A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa"
							} else {
								"A3C_CORE\ui\pictures\icon_menu_autocombat_disabled.paa"
							}
						];

						private _topTooltips = [
							"TARGET SELECTION: AUTONOMOUS",
							"TARGET SELECTION: DESIGNATED ONLY",
							"FIRE ON MY LEAD",
							if ({_x in A3C_DANGER_UNITS} count A3C_RD_UNITS == 0) then {
								"DISABLE AUTOCOMBAT"
							} else {
								"ENABLE AUTOCOMBAT"
							}
						];

						{
							_x ctrlSetTextColor [1,1,1,0.6];
							_x ctrlSetText (_topIcons select _forEachIndex);
						} forEach (["radial_outerTopImages"] call FUNC(ctrlGroup));

						{
							_x ctrlSetTooltip (_topTooltips select _forEachIndex);
						} forEach (["radial_outerTopButtons"] call FUNC(ctrlGroup));

						private _behaviorIcon = "\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa";
						private _combatModeIcon ="\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa";

						//"\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\Cursors\attack_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\f100_ca.paa"
						//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\defend_ca.paa"
						//"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
						//"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"

						//-- RIGHT RING: hide all controls (images + buttons)
						{
							_x ctrlShow false;
						} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));


						// //-- RIGHT RING - COMBAT MODES / BEHAVIOUR MACRO SELECTOR
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlShow true;
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText _combatModeIcon;
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetTextColor [1,1,1,0.4];

						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlShow true;
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "COMBAT MODES AND BEHAVIOUR";
						
						
						//-- HIDE RIGHT EXTENSION (all controls)
						{
							_x ctrlShow false;
						} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

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

				_actions = [_doToggle] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;

				private _outerRingBackgrounds = ["radial_outerRingBackgrounds"] call FUNC(ctrlGroup);

				{
					_x ctrlShow false;
				} forEach _outerRingBackgrounds;

				if (count _actions > 0) then {
					{
						private _imgString = switch (_forEachIndex + 1) do {
							case 1: { "Top" };
							case 2: { "Right" };
							case 3: { "Bottom" };
							case 4: { "Left" };
						};

						_x ctrlSetText format [
							"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
							_imgString
						];

						if (_doToggle) then {
							_x ctrlShow true;
						};
					} forEach (_outerRingBackgrounds select [0, ceil (count _actions / 4)]);
				};

				//-- Outer ring buttons/images: reset text color
				{
					_x ctrlSetTextColor [1,1,1,0.6];
				} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

			};

		};
		case ("BRAIN") : {
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
				A3C_RADIALMODE = 'BRAIN';
				BV_LB1 = 6;
				BV_LB2 = 7;
				BV_GREN = 0;
				_bv = "BV_BRAIN";

				{
					_x ctrlSetTextColor [1,1,1,0.6];
				} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

				if (_btn == 1) then {
					//-- right click macro unit lookdir+unitpos reset
					 player groupRadio "SentBehaviourSafe";
					{_x dowatch objnull; _x lookat objnull; _x setUnitPos 'AUTO';} foreach (groupSelectedUnits player);
				} else {
					//-- left click: toggle right outer ring
					[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
					if (BV_BRAIN == 0) then {

						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
						if (_btn != -1) then {
							BV_BRAIN = 1;
						};

						//-- hide outer ring BG's except RIGHT
						{
							_x ctrlShow false;
						} forEach (
							(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
							- [
								["bgRight"] call FUNC(ctrl)
							]
						);

						//-- RIGHT RING: show all controls (images + buttons)
						{
							_x ctrlShow true;
						} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

						//-- RIGHT EXTENSION: hide all controls
						{
							_x ctrlShow false;
						} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

						BV_MEDICAL = 0;
						BV_CBMODE = 0;

						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_resetWatchdir.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "RESET WATCHDIR";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
						if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
						} else {
							if ( {_u = _x; {_u getHitPointDamage _x > 0.2} count A3C_HUMAN_HITPOINTS > 0 } count (units player) > 0 ) then {
								(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,0.3,0.3,0.6];
								(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. || SHIFT+LMB: Closest Medic Heal Player || RMB: AUTO-MEDICS";
							} else {
								(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
								(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "No units wounded";
							};
						};

						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"; //"A3C_CORE\ui\pictures\icon_menu_takeCover.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "Behaviour & CombatMode";//"FIND COVER";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_reArm.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "RE-ARM (LMB: choose target, RMB: find target)";

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
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,0.3,0.3,0.6];
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "AI Healing: LMB: open medical controls. SHIFT+LMB: Closest Medic Heal Player (AUTO-mode coming soon)";
										} else {
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "No units wounded";
										};
									};
									//--
									if !(_shift) then {
										BV_CBMODE = 0;
										//-- no Shift: bring up healing menu
										if (BV_MEDICAL == 0) then {
											BV_MEDICAL = 1;
											A3C_LBR_1 = "MEDICAL";
											(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
											
											// clear right extension listboxes
											{
												lbClear _x;
											} forEach ([
												["extensionRightLbSourcesBox"] call FUNC(ctrl),
												["extensionRightLbSubselBox"] call FUNC(ctrl)
											] select {!isNull _x});

											["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
										} else {
											BV_MEDICAL = 0;

											//-- RIGHT EXTENSION: hide all controls
											{
												_x ctrlShow false;
											} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));
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
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_medic_auto.paa";
										(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetTextColor [1,1,1,0.6];
										
										//-- RIGHT EXTENSION: hide all controls
										{
											_x ctrlShow false;
										} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

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



								//-- RIGHT EXTENSION: hide all controls
								{
									_x ctrlShow false;
								} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));


								BV_MEDICAL = 0; //-- reset MedicalButton value to 0 (for closing/opening extension)
								if (BV_CBMODE == 0) then {
									BV_CBMODE = 1;
									A3C_LBR_1 = "CBMODE";
									BV_LB1 = 12;
									BV_LB2 = 13;
									//-- open right extension: combat mode
									(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
									
									//-- clear right extension listboxes
									{
										lbClear _x;
									} forEach ([
										["extensionRightLbSourcesBox"] call FUNC(ctrl),
										["extensionRightLbSubselBox"] call FUNC(ctrl)
									] select {!isNull _x});

									["CBMODE"] call A3C_UI_RADIAL_LABEL_LB;
								} else {
									//-- combat mode
									BV_CBMODE = 0;
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

								//-- RIGHT EXTENSION: hide all controls
								{
									_x ctrlShow false;
								} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

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
					_x ctrlShow false;
				} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));
				//-- Reset outer ring action buttons
				{
					_x ctrlShow false;
				} forEach _outerButtonMacros;

				{
					_x ctrlSetText "";
				} forEach _outerImages;

				{
					_x ctrlSetToolTip "";
				} forEach _outerButtons;

				_img = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				_color = [1,1,1,0.5];
				
				//-- RIGHT RING: show all controls (images + buttons)
				{
					_x ctrlShow true;
				} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

				//-- RIGHT RING: set icons + color (images)
				private _rightIcons = [
					"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
					"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
					"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
					"A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa"
				];

				{
					_x ctrlSetText (_rightIcons select _forEachIndex);
					_x ctrlSetTextColor _color;
				} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

				//-- RIGHT RING: set tooltips (buttons)
				private _rightTooltips = [
					"AUTO",
					"UP",
					"CROUCH",
					"PRONE"
				];

				{
					_x ctrlSetTooltip (_rightTooltips select _forEachIndex);
				} forEach (["radial_outerRightButtons"] call FUNC(ctrlGroup));

				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
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
				private _bgRight = ["bgRight"] call FUNC(ctrl);

				_bgRight ctrlShow true;
				_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";

				{
					_x ctrlShow false;
				} forEach (
					[
						["bgTop"] call FUNC(ctrl),
						["bgBottom"] call FUNC(ctrl),
						["bgLeft"] call FUNC(ctrl)
					] select {!isNull _x}
				);
				
				//-- RIGHT RING: show all controls (images + buttons)
				{
					_x ctrlShow true;
				} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));
				
				//-- OUTER RING: hide all non-right segments (top, bottom, left)
				{
					_x ctrlShow false;
				} forEach (
					(["radial_outerTopMacros"] call FUNC(ctrlGroup)) +
					(["radial_outerBottomMacros"] call FUNC(ctrlGroup)) +
					(["radial_outerLeftMacros"] call FUNC(ctrlGroup))
				);

				//-- RIGHT EXTENSION: hide all controls
				{
					_x ctrlShow false;
				} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

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
						//-- note - some non existing main img was set to "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "GoCode A";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "GoCode B";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "GoCode C";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "GoCode D";
						[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];

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
						
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";

						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_auto.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_1_BTN) ctrlSetTooltip "AUTO";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_2_BTN) ctrlSetTooltip "STAND";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_3_BTN) ctrlSetTooltip "CROUCH";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Stance_Prone_RAD.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERRIGHT_4_BTN) ctrlSetTooltip "PRONE";
						
						{
							_x ctrlSetTextColor [1,1,1,0.6];
						} forEach (
							[
								["innerStancesImg"] call FUNC(ctrl)
							]
							+ (["radial_outerRightImages"] call FUNC(ctrlGroup))
						);

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
						//-- RIGHT RING: hide all controls (images + buttons)
						{
							_x ctrlShow false;
						} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow false;
					};
				};
			} else {
				//-- HC GO CODE SECTION
				A3C_RADIALMODE = "HC GOCODE";
				//-- wipe outer ring
				{
					_x ctrlShow false;
				} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));
				
				//-- Reset outer ring action buttons
				{
					_x ctrlShow false;
				} forEach _outerButtonMacros;

				{
					_x ctrlSetText "";
				} forEach _outerImages;

				{
					_x ctrlSetToolTip "";
				} forEach _outerButtons;

				_img = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";

				//-- RIGHT RING: show all controls (images + buttons)
				{
					_x ctrlShow true;
				} forEach (["radial_outerRightMacros"] call FUNC(ctrlGroup));

				//-- RIGHT RING: set icons
				private _rightIcons = [
					"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa",
					"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa",
					"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa",
					"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"
				];

				{
					_x ctrlSetText (_rightIcons select _forEachIndex);
				} forEach (["radial_outerRightImages"] call FUNC(ctrlGroup));

				//-- RIGHT RING: set tooltips
				private _rightTooltips = [
					"GOCODE A",
					"GOCODE B",
					"GOCODE C",
					"GOCODE D"
				];

				{
					_x ctrlSetTooltip (_rightTooltips select _forEachIndex);
				} forEach (["radial_outerRightButtons"] call FUNC(ctrlGroup));

				[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0]; //-- check gocodes and assign color

				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa"; //-- aiai
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
				//-- Hide all outer ring buttons/images
				{
					_x ctrlShow false;
				} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));

				
				{
					_x ctrlShow false;
				} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

				if (count _itemCategories == 0) exitWith {};

				if (BV_ITEMS == 0) then {
					if (_btn != -1) then {
						BV_ITEMS = 1;
					};

					private _bgBottom = ["bgBottom"] call FUNC(ctrl);
					_bgBottom ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
					_bgBottom ctrlShow true;

					//-- RIGHT EXTENSION: hide all controls
					{
						_x ctrlShow false;
					} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

					private _itemSlots = [
						[12, "outerBottom4Img", "outerBottom4Btn"],
						[11, "outerBottom3Img", "outerBottom3Btn"],
						[10, "outerBottom2Img", "outerBottom2Btn"],
						[9,  "outerBottom1Img", "outerBottom1Btn"],

						[8,  "outerRight4Img", "outerRight4Btn"],
						[7,  "outerRight3Img", "outerRight3Btn"],
						[6,  "outerRight2Img", "outerRight2Btn"],
						[5,  "outerRight1Img", "outerRight1Btn"],

						[4,  "outerTop4Img", "outerTop4Btn"],
						[3,  "outerTop3Img", "outerTop3Btn"],
						[2,  "outerTop2Img", "outerTop2Btn"],
						[1,  "outerTop1Img", "outerTop1Btn"]
					];

					{
						private _slot = _itemSlots param [_forEachIndex, []];
						if (_slot isEqualTo []) exitWith {};

						_slot params ["_buttonID", "_buttonImgKey", "_buttonClickerKey"];

						if (_buttonID == 8) then {
							private _bgRight = ["bgRight"] call FUNC(ctrl);
							_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
							_bgRight ctrlShow true;
						};

						private _currentCategory = _x;

						private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
						private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

						if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

						private _fnc = {};
						private _prms = [str A3C_RD_UNITS, _buttonImgKey, _buttonClickerKey];

						switch (_currentCategory) do {
							case "SWITCHWEAPON": {
								private _SwitchWeaponImage = "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
								private _SwitchWeaponToolTip = "Switch To Handgun";

								if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0) then {
									_SwitchWeaponImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
									_SwitchWeaponToolTip = "Switch To Rifle";
								};

								_buttonImg ctrlSetText _SwitchWeaponImage;
								_buttonImg ctrlSetTextColor [1,1,1,0.3];
								_buttonImg ctrlShow true;

								_buttonClicker ctrlSetToolTip _SwitchWeaponToolTip;
								_buttonClicker ctrlShow true;

								_fnc = {
									params ["_btnData", "_inputParams"];
									_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
									_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									_units = call compile _units;

									private _btnImage = "";
									private _tooltip = "";
									A3C_Prevent_SwitchWeapon = true;
									private _totalStandBy = 0;

									_buttonImg ctrlSetTextColor [1,1,1,0.3];

									{
										if ({(currentWeapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS > 0) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
											_tooltip = "Switch To Handgun";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x, _delay] spawn {
												params ["_unit", "_delay"];
												sleep _delay;
												_unit selectWeapon (primaryWeapon _unit);
											};
										} else {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa";
											_tooltip = "Switch To Rifle";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x, _delay] spawn {
												params ["_unit", "_delay"];
												sleep _delay;
												_unit selectWeapon (handGunWeapon _unit);
											};
										};
									} forEach _units;

									_buttonImg ctrlSetText _btnImage;
									_buttonClicker ctrlSetToolTip _tooltip;

									sleep _totalStandBy;

									A3C_Prevent_SwitchWeapon = false;

									if (ctrlShown _buttonImg && {"switch" in ctrlText _buttonImg}) then {
										_buttonClicker ctrlShow true;
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgKey, _buttonClickerKey] spawn {
									params ["_buttonImgKey", "_buttonClickerKey"];

									waitUntil {!(A3C_Prevent_SwitchWeapon)};

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									if (ctrlShown _buttonImg && {"switch" in ctrlText _buttonImg}) then {
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
										_buttonClicker ctrlShow true;
									};
								};
							};

							case "IR_STROBE": {
								private _strobeImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
								private _strobeToolTip = "Attach IR-Strobe";

								if ({(count (_x getVariable ["A3C_STROBE", []])) > 0} count A3C_RD_UNITS > 0) then {
									_strobeImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
									_strobeToolTip = "Remove IR-Strobe";
								};

								_buttonImg ctrlSetText _strobeImage;
								_buttonImg ctrlSetTextColor [1,1,1,0.3];
								_buttonImg ctrlShow true;

								_buttonClicker ctrlSetToolTip _strobeToolTip;
								_buttonClicker ctrlShow true;

								_fnc = {
									params ["_btnData", "_inputParams"];
									_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
									_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									_units = call compile _units;

									private _btnImage = "";
									private _tooltip = "";
									A3C_Prevent_attach_IR = true;
									private _totalStandBy = 0;

									_buttonImg ctrlSetTextColor [1,1,1,0.3];

									{
										private _u = _x;

										if ({(count (_x getVariable ["A3C_STROBE", []])) > 0} count A3C_RD_UNITS > 0) then {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
											_tooltip = "Attach IR-Strobe";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											[_x, _delay] spawn {
												params ["_unit", "_delay"];
												sleep _delay;

												private _var = _unit getVariable ["A3C_STROBE", []];
												if (count _var > 0) then {
													_var params ["_strobeObject", "_strobeType"];
													deleteVehicle _strobeObject;
													_unit addMagazine _strobeType;
												};

												_unit setVariable ["A3C_STROBE", [], true];
											};
										} else {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
											_tooltip = "Remove IR-Strobe";

											private _delay = random 1;
											_totalStandBy = _totalStandBy max _delay;

											if ((count (_u getVariable ["A3C_STROBE", []])) == 0) then {
												{
													private _it = _x;
													private _am = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
													private _array = "true" configClasses (configFile >> "CfgAmmo" >> _am >> "NVGMarkers");

													if (count _array > 0) exitWith {
														_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
														_tooltip = "";

														[_u, _it, _delay] spawn {
															params ["_u", "_it", "_delay"];
															sleep _delay;

															_u removeMagazine _it;

															private _st = "NVG_TargetC" createVehicle getPos _u;
															_u setVariable ["A3C_STROBE", [_st, _it], true];

															[_u, _st] spawn A3C_AI_action_irStrobeLoop;
														};
													};
												} forEach magazines _u;
											};
										};
									} forEach _units;

									_buttonImg ctrlSetText _btnImage;
									_buttonClicker ctrlSetToolTip _tooltip;

									sleep _totalStandBy;

									A3C_Prevent_attach_IR = false;

									if (ctrlShown _buttonImg && {"IRstrobe" in ctrlText _buttonImg}) then {
										_buttonClicker ctrlShow true;
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgKey, _buttonClickerKey] spawn {
									params ["_buttonImgKey", "_buttonClickerKey"];

									waitUntil {!(A3C_Prevent_attach_IR)};

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									if (ctrlShown _buttonImg && {"IRstrobe" in ctrlText _buttonImg}) then {
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
										_buttonClicker ctrlShow true;
									};
								};
							};

							case "NVG": {
								private _nvgImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
								private _nvgToolTip = "Turn NVG ON";

								if ({{private _item = _x; [_item] call A3C_fnc_isNVGoggles} count assignedItems _x > 0} count A3C_RD_UNITS > 0) then {
									_nvgImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
									_nvgToolTip = "Turn NVG OFF";
								};

								_buttonImg ctrlSetText _nvgImage;
								_buttonImg ctrlSetTextColor [1,1,1,0.3];
								_buttonImg ctrlShow true;

								_buttonClicker ctrlSetToolTip _nvgToolTip;
								_buttonClicker ctrlShow true;

								_fnc = {
									params ["_btnData", "_inputParams"];
									_btnData params ["_display", "_button", "_sX", "_sY", "_shift", "_ctrl", "_alt"];
									_inputParams params ["_units", "_buttonImgKey", "_buttonClickerKey"];

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									_units = call compile _units;

									private _btnImage = "";
									private _tooltip = "";
									A3C_Prevent_attach_NVG = true;
									private _totalStandBy = 0;

									_buttonImg ctrlSetTextColor [1,1,1,0.3];

									{
										if ({{private _item = _x; [_item] call A3C_fnc_isNVGoggles} count assignedItems _x > 0} count A3C_RD_UNITS > 0) then {
											private _nvgs = "";

											{
												if ([_x] call A3C_fnc_isNVGoggles) exitWith {
													_nvgs = _x;
												};
											} forEach assignedItems _x;

											if (_nvgs != "") then {
												_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_OFF.paa";
												_tooltip = "Turn NVG ON";

												private _delay = random 1;
												_totalStandBy = _totalStandBy max _delay;

												[_x, _delay, _nvgs] spawn {
													params ["_unit", "_delay", "_nvgs"];
													sleep _delay;

													_unit playActionNow "GestureHi";
													sleep 0.834;

													if (!(_unit canAddItemToUniform _nvgs) && {!(_unit canAddItemToVest _nvgs) && {!(_unit canAddItemToBackPack _nvgs)}}) exitWith {
														_unit groupChat "I am out of storage - keeping NVG's equipped!";
													};

													_unit unAssignItem _nvgs;
												};
											};
										} else {
											private _nvgs = "";

											{
												if ([_x] call A3C_fnc_isNVGoggles) exitWith {
													_nvgs = _x;
												};
											} forEach items _x;

											if (_nvgs != "") then {
												_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_NVG_ON.paa";
												_tooltip = "Turn NVG OFF";

												private _delay = random 1;
												_totalStandBy = _totalStandBy max _delay;

												[_x, _delay, _nvgs] spawn {
													params ["_unit", "_delay", "_nvgs"];
													sleep _delay;

													_unit playActionNow "GestureHi";
													sleep 0.834;

													_unit assignItem _nvgs;
												};
											};
										};
									} forEach _units;

									_buttonImg ctrlSetText _btnImage;
									_buttonClicker ctrlSetToolTip _tooltip;

									sleep (_totalStandBy + 2);

									A3C_Prevent_attach_NVG = false;

									if (ctrlShown _buttonImg && {"NVG" in ctrlText _buttonImg}) then {
										_buttonClicker ctrlShow true;
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
									};
								};

								[_buttonImgKey, _buttonClickerKey] spawn {
									params ["_buttonImgKey", "_buttonClickerKey"];

									waitUntil {!(A3C_Prevent_attach_NVG)};

									private _buttonImg = [_buttonImgKey] call FUNC(ctrl);
									private _buttonClicker = [_buttonClickerKey] call FUNC(ctrl);

									if (isNull _buttonImg || {isNull _buttonClicker}) exitWith {};

									if (ctrlShown _buttonImg && {"NVG" in ctrlText _buttonImg}) then {
										_buttonImg ctrlSetTextColor [1,1,1,0.6];
										_buttonClicker ctrlShow true;
									};
								};
							};
						};

						call compile format [
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
					} forEach _itemCategories;
				} else {
					BV_ITEMS = 0;
				};
			} else {
				//-- HC-BEHAVIOUR
				A3C_RADIALMODE = "HC BEHAVIOUR";

				//-- Hide Outer Ring BG's except BOTTOM:
				{
					_x ctrlShow false;
				} forEach (
					(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
					- [
						["bgBottom"] call FUNC(ctrl)
					]
				);
				
				//-- Reset outer ring action buttons
				{
					_x ctrlShow false;
				} forEach _outerButtonMacros;

				{
					_x ctrlSetText "";
				} forEach _outerImages;

				{
					_x ctrlSetToolTip "";
				} forEach _outerButtons;
				
				_img = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\attack_ca.paa";
				_color = [1,1,1,0]; //momo

				//-- BOTTOM RING: show all controls (images + buttons)
				{
					_x ctrlShow true;
				} forEach (["radial_outerBottomMacros"] call FUNC(ctrlGroup));

				//-- BOTTOM RING: set icons + colors
				private _bottomColors = [
					[0,1,0,0.5],
					[1,1,0,0.5],
					[1,0,0,0.5],
					[0.17,0.86,0.92,0.5]
				];

				{
					_x ctrlSetText _img;
					_x ctrlSetTextColor (_bottomColors select _forEachIndex);
				} forEach (["radial_outerBottomImages"] call FUNC(ctrlGroup));

				//-- BOTTOM RING: set tooltips
				private _bottomTooltips = [
					"SAFE",
					"AWARE",
					"COMBAT",
					"STEALTH"
				];

				{
					_x ctrlSetTooltip (_bottomTooltips select _forEachIndex);
				} forEach (["radial_outerBottomButtons"] call FUNC(ctrlGroup));

				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
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
					//-- Hide all outer ring backgrounds
					{
						_x ctrlShow false;
					} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));

					//-- Hide all outer ring controls (buttons + images)
					{
						_x ctrlShow false;
					} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

					//-- Reset visual state of outer ring images (text color used as tint)
					{
						_x ctrlSetTextColor [1,1,1,0.6];
					} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

					BV_MEDICAL = 0;
					BV_CBMODE = 0;
					if (BV_VEHS == 0) then {
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
						if (_btn != -1) then {
							BV_VEHS = 1;
						};

						//-- hide outer ring BG's except BOTTOM
						{
							_x ctrlShow false;
						} forEach (
							(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
							- [
								["bgBottom"] call FUNC(ctrl)
							]
						);
						private _classes = [];
						private _classArray = ["CAR", "TANK", "HELICOPTER", "PLANE", "SHIP", "STATICWEAPON"];

						{
							private _soldier = _x;

							{
								private _entities = (_soldier nearEntities [_x, 220]) select {
									canMove _x &&
									{
										(side _x == civilian) || {((side _x) getFriend (side player)) > 0.6}
									}
								};

								if (count _entities > 0) then {
									_classes pushBackUnique _x;
								};
							} forEach (_classArray - _classes);
						} forEach A3C_RD_UNITS;

						private _classCount = count _classes;

						if (_classCount > 0) then {
							(["bgBottom"] call FUNC(ctrl)) ctrlShow true;

							if (_classCount > 4) then {
								private _bgRight = ["bgRight"] call FUNC(ctrl);
								_bgRight ctrlShow true;
								_bgRight ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
							};

							private _vehicleClassSlots = [
								[["outerBottom4Img"] call FUNC(ctrl), ["outerBottom4Btn"] call FUNC(ctrl), 12],
								[["outerBottom3Img"] call FUNC(ctrl), ["outerBottom3Btn"] call FUNC(ctrl), 11],
								[["outerBottom2Img"] call FUNC(ctrl), ["outerBottom2Btn"] call FUNC(ctrl), 10],
								[["outerBottom1Img"] call FUNC(ctrl), ["outerBottom1Btn"] call FUNC(ctrl), 9],
								[["outerRight4Img"] call FUNC(ctrl), ["outerRight4Btn"] call FUNC(ctrl), 8],
								[["outerRight3Img"] call FUNC(ctrl), ["outerRight3Btn"] call FUNC(ctrl), 7]
							];

							{
								private _currentClass = _x;
								private _slot = _vehicleClassSlots select _forEachIndex;
								_slot params ["_btnImg", "_btnClicker", "_btnId"];

								private _btnData = switch (_currentClass) do {
									case "CAR": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa", "WHEELED"]
									};
									case "TANK": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa", "TRACKED"]
									};
									case "HELICOPTER": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa", "HELICOPTERS"]
									};
									case "PLANE": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa", "JETS"]
									};
									case "SHIP": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\naval_ca.paa", "SHIPS"]
									};
									case "STATICWEAPON": {
										["\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\static_ca.paa", "STATIC WEAPONS"]
									};
								};

								call compile format [
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
								_btnClicker ctrlSetTooltip (_btnData select 1);

								{
									_x ctrlShow true;
								} forEach [_btnImg, _btnClicker];
							} forEach (_classes select [0, count _vehicleClassSlots]);
						};

					} else {
						BV_VEHS = 0;
					};
				};
			} else {
				//-- HC COMBATMODE
				A3C_RADIALMODE = "HC COMBAT";
				//-- Hide outer Ring BG's
				{
					_x ctrlShow false;
				} forEach (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup));
				
				//-- Reset outer ring action buttons
				{
					_x ctrlShow false;
				} forEach _outerButtonMacros;

				{
					_x ctrlSetText "";
				} forEach _outerImages;

				{
					_x ctrlSetToolTip "";
				} forEach _outerButtons;

				_img = "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
				_color = [1,1,1,0];

				//-- RIGHT/BOTTOM RING: show ROE controls
				private _roeMacros = [
					["outerRight4Img"] call FUNC(ctrl),
					["outerRight4Btn"] call FUNC(ctrl)
				] + (["radial_outerBottomMacros"] call FUNC(ctrlGroup));

				{
					_x ctrlShow true;
				} forEach (_roeMacros select {!isNull _x});

				//-- RIGHT/BOTTOM RING: set ROE icons + colors
				private _roeImages = [
					["outerRight4Img"] call FUNC(ctrl)
				] + (["radial_outerBottomImages"] call FUNC(ctrlGroup));

				private _roeColors = [
					[1,0,0,0.5],
					[1,1,0,0.5],
					[1,1,1,0.5],
					[0,1,0,0.5],
					[0,0,1,0.5]
				];

				{
					_x ctrlSetText _img;
					_x ctrlSetTextColor (_roeColors select _forEachIndex);
				} forEach (_roeImages select {!isNull _x});

				//-- RIGHT/BOTTOM RING: set ROE tooltips
				private _roeButtons = [
					["outerRight4Btn"] call FUNC(ctrl)
				] + (["radial_outerBottomButtons"] call FUNC(ctrlGroup));

				private _roeTooltips = [
					"RED || Fire at will, engage at will",
					"YELLOW || Fire at will",
					"WHITE || Hold fire, engage at will",
					"GREEN || Hold fire - defend only",
					"BLUE || Never fire"
				];

				{
					_x ctrlSetTooltip (_roeTooltips select _forEachIndex);
				} forEach (_roeButtons select {!isNull _x});

				//-- hide right and bottom outer ring backgrounds
				{
					_x ctrlShow false;
				} forEach ([
					["bgRight"] call FUNC(ctrl),
					["bgBottom"] call FUNC(ctrl)
				] select {!isNull _x});

				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlShow true;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_RIGHT) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlShow true;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_BG_BOTTOM) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
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

	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlShow true;
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) ctrlShow true;

	


	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER) ctrlShow true;
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER) ctrlShow true;

	
	

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

			{
				_x ctrlShow true;
			} forEach ([
				["extensionRightLbSubselBox"] call FUNC(ctrl),
				["extensionRightGoBtn"] call FUNC(ctrl),
				["extensionRightLbSourcesHeader"] call FUNC(ctrl)
			] select {!isNull _x});

			//-- clear right extension listboxes
			{
				lbClear _x;
			} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

			private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
			(group player) setVariable ["A3C_MEDICS", _medics];
			private _multiMedic = (count _medics) > 1;
			
			if (_multiMedic) then {
				[["ALL MEDICS","",objnull,(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),"A3C_CORE\ui\pictures\icon_menu_Medical.paa"]] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [0, [0, 1, 0, 1]];
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
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
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
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [_foreachIndex + _add, _c];

			} foreach _medics; // _squadAI

			_patients = [group player] call A3C_FINDPATIENTS;
			private _multiPatient = (count _patients) > 1;
			if (_multiPatient) then {
				[["HEAL ALL","",objnull,(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),""]] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [0, [0, 1, 0, 1]];
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
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),
						""
					]
				] call A3C_UI_RADIAL_LB_ADD;
				private _add = if (_multiPatient) then {1} else {0};
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [_foreachIndex + _add, _c];
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
			[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX, _mSel, true] call A3C_setCurSel;
			[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX, _pSel, true] call A3C_setCurSel;	
		};
		case ("CBMODE") : {
			_orderText = "Unit States";
			_lbText1 = "Behaviour";
			_lbText2 = "Combat Mode";
			{
				_x ctrlShow true;
			} forEach (
				(["radial_extensionRightListboxes"] call FUNC(ctrlGroup))
				+ [
					["extensionRightLbSourcesHeader"] call FUNC(ctrl)
				]
			); 
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
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
						"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
					]
				] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [_foreachIndex, _c];
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
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),
						"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"
					]
				] call A3C_UI_RADIAL_LB_ADD;
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [_foreachIndex, _c];
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
				[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX, _lbBehaviour] call A3C_setCurSel;
				[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX, _lbCBMode] call A3C_setCurSel;
				sleep 0.1;
				
			};

		};


		case ("VEHICLES") : {
			_lbText1 = "SELECT VEHICLE";

			

			//-- idc's stay numeric here as they were created dynamically with ctrlCreate
			for "_i" from 0 to 45 do {
				if (ctrlType (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i)) != -1) then {
					ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i));
					ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i + 1));
				};
			};

			for "_i" from 11101 to 11104 do {
				ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl _i);
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
					private _btnImg  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscPicture", 10101 + (_fei * 2)];
					private _btnClicker  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscButton_Invisible", 10101 + (_fei * 2) + 1];
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
					//-- NOTE: ctrlAddEventhandler is allowed as button is created with ctrlCreate 
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

						private _btnImg  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscPicture", 11101 + (_i * 2)];
						private _btnClicker  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscButton_Invisible", 11101 + (_i * 2) + 1];

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
						
						//-- NOTE: ctrlAddEventhandler is allowed as button is created with ctrlCreate 
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
							(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
							""
							]
						] call A3C_UI_RADIAL_LB_ADD;
					} foreach A3C_VEHSAV;
				};
			};

			
		};
	};

	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN) ctrlSetText _orderText;
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER) ctrlSetText _lbText1;
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER) ctrlSetText _lbText2;
};

A3C_UI_RADIAL_BTN_REINIT = {

	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};

	} foreach A3C_RD_UNITS;


	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";

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
		case ("ITEMS") : {
			_w = "";
			_t = "";
			if (({(currentweapon _x) == (handGunWeapon _x)} count A3C_RD_UNITS) > 0) then {
				_w = (primaryWeapon (A3C_RD_UNITS select 0));
				_t = "Main Weapon";
			} else {
				_w = (handGunWeapon (A3C_RD_UNITS select 0));
				_t = "Hand Gun";
			};

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_3_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_3_BTN) ctrlSetToolTip (format ["Switch to %1",_t]);

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG) ctrlSetText "";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN) ctrlSetToolTip "";
			BV_MEDICAL = 0;
			BV_CBMODE = 0;

			_laserImage = if ({_x isIRLaserOn (currentWeapon _x) OR {_x isFlashLightOn (currentWeapon _x)}} count (A3C_RD_UNITS - [player]) > 0) then {
				"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa"
			} else {
				"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa"
			};
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_2_IMG) ctrlSetText _laserImage;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_2_BTN) ctrlSetToolTip "LMB: ENABLE IR (requires 'DANGER') , RMB: DISABLE IR";

			_strobeImage = if ({count (_x getvariable "A3C_STROBE") > 0} count (A3C_RD_UNITS - [player]) > 0) then {
				"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa"
			} else {
				"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa"
			};

			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG) ctrlSetText _strobeImage;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN) ctrlSetToolTip "LMB: ATTACH IR-STROBES , RMB: DETACH IR-STROBES";

		};
		case ("VEHS") : { //~~unused

			BV_MEDICAL = 0;
			BV_CBMODE = 0;


			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_1_IMG) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_1_BTN) ctrlSetToolTip "JET";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_2_IMG) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_2_BTN) ctrlSetToolTip "HELI";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_3_IMG) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_3_BTN) ctrlSetToolTip "TRACKED";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG) ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa";
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN) ctrlSetToolTip "WHEELED";

			//-- BOTTOM RING: reset icon color
			{
				_x ctrlSetTextColor [1,1,1,0.6];
			} forEach (["radial_outerBottomImages"] call FUNC(ctrlGroup));
		};
	};
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

A3C_UI_RADIAL_CloseDisplay = {
	showHud ([true]  + (shownhud select [1,10]));
	findDisplay IDD_RADIAL_MENU closeDisplay 0;
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
			} foreach (allControls findDisplay IDD_RADIAL_MENU);
		};
		
	} else {
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false; //-- hide HC-dashboard
		A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;
		{
			_x ctrlShow true;
		} foreach A3C_UI_RADIAL_CTRLS_SHOWN;
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;
		A3C_UI_RADIAL_CTRLS_SHOWN = [];
		if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
			[] call A3C_UI_SHARED_createDashBoard;
		};
	};
	_bool
};



A3C_UI_RADIAL_TOGGLE_LEFT_EXT = {
	params ["_mode"];
	if (_mode == "OPEN") then {
		if (A3C_RD_BOOL_UNITS) then {
			if !(ctrlShown (findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP)) then {
				playsound "ReadOutHideClick1"; 
				A3C_RD_BOOL_UNITS = false;
				{
					_x ctrlShow true;
				} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));
				(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;
				[IDD_RADIAL_MENU,if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {"INF"} else {"HC"}] call A3C_UI_MAP_Overlay_ResizeTeamColorsXWH;
				[0] call A3C_UI_MAP_RESIZE_TEAMCOLORS_Y;
				[IDD_RADIAL_MENU,IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP] execFSM "A3C_CORE\FSM\A3C_MON_RADIAL.fsm";
			}
		};
	} else {
		if (ctrlShown(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP)) then {
			playsound "ReadOutHideClick1"; 
			{
				_x ctrlShow false;
			} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));
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
		[["NO VEHICLES","",objnull,(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),""]] call A3C_UI_RADIAL_LB_ADD;
	};
	//-- clear right extension listboxes
	{
		lbClear _x;
	} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

	
	
	
	[] spawn {
		["VEHICLES"] call A3C_UI_RADIAL_LABEL_LB;	
		sleep 0.1;
		
		if (cursortarget in A3C_VEHSAV) then {
			[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX, [cursorTarget,A3C_VEHSAV] call MCSS_fnc_GetArrayIndex, true] call A3C_setCurSel;
		} else {
			{
				[_x, 0] call A3C_setCurSel;
			} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));
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
	

	private _CT_TREE = findDisplay IDD_RADIAL_MENU displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
	_CT_TREE tvSetCurSel [-1];

	A3C_RD_UNITS = groupselectedUnits player;
	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};
	} foreach A3C_RD_UNITS;

	_unitArray = (profileNamespace getvariable "A3C_GROUPUNITS");

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
		if (ctrlShown (findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN)) then {
			//-- clear right extension listboxes
			{
				lbClear _x;
			} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));
			["MEDICAL"] call A3C_UI_RADIAL_LABEL_LB;
		};
	};
};

A3C_UI_RADIAL_INV_LB_CREATE = {
	//-- this fnc uses numeric idc's as they refer to the inventory dialog 
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


	//-- NOTE: ctrlAddEventhandler is allowed as listbox is created with ctrlCreate 
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