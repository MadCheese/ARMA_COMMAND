A3C_UI_SETTINGS_FNC_ChangeSettings = {
	_var = _this select 0;
	_val = 0;
	_mode = "OFF";




	switch (_var) do {
		case ("A3C_NUM_VAR") : {_val = 1601};
		case ("A3C_SKILL_VAR") : {_val = 1600};
		case ("A3C_HUD_RES_VAR") : {_val = 1602};
		case ("A3C_FORCERAIL_VAR") : {_val = 1603};
		//case ("A3C_TABLET_IMG") : {_val = 1604};
		case ("A3C_HUD_LAYOUT_CORNER") : {_val = 1605};
		case ("A3C_HUD_OBJECTS") : {_val = 1606};
		case ("HC_GROUP_RESPONSE") : {_val = 1607};
		
	};
	if (profileNameSpace getVariable _var) then {
		profilenamespace setvariable [_var,false];
		_mode = "OFF";
	} else {
		profilenamespace setvariable [_var,true];
		_mode ="ON";
	};
	(findDisplay 100010 displayCtrl _val) ctrlSetText _mode;
	switch (_var) do {
		case ("A3C_NUM_VAR") : {
			if (_mode == "ON") then {
			} else {
			};
		};
		case ("A3C_SKILL_VAR") : {
			if (_mode == "ON") then {
				{
					_x setskill 1
				} foreach units group player;
				if (isServer) then {
					A3C_isHCSkillMaxed = true;
					publicVariable 'A3C_isHCSkillMaxed';
				};
			} else {
				if (isServer) then {
					A3C_isHCSkillMaxed = false;
					publicVariable 'A3C_isHCSkillMaxed';
				};
			};
		};
		case ("A3C_HUD_RES_VAR") : {
			if (_mode == "ON") then {
			} else {
			};
		};
		case ("A3C_HUD_OBJECTS") : {
			if (_mode == "ON") then {
			} else {
			};
		};
		//case ("A3C_TABLET_IMG") : {
		//	if (_mode == "ON") then {
		//	} else {
		//	};
		//};

	};
	//profilenamespace setvariable [_val,_return];
};

A3C_Open_SETTINGS = {

	[] call A3C_RADIAL_CloseDisplay;
	A3C_DOWNKEYS = A3C_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];

	with uiNameSpace do {
		A3C_DG_SETTINGS = (finddisplay 46) createDisplay "A3C_DSP_SettingsMenu";
	};

	(findDisplay 100010 displayCtrl 1000) ctrlSetText format
	[
		"A3C SETTINGS (%1):",
		profileNameSpace getvariable "A3C_CHECKVERSION"
	];

	if (profileNameSpace getVariable "A3C_NUM_VAR") then {
		(findDisplay 100010 displayCtrl 1601) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1601) ctrlSetText "OFF";
	};

	if (profileNameSpace getVariable "A3C_SKILL_VAR") then {
		(findDisplay 100010 displayCtrl 1600) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1600) ctrlSetText "OFF";
	};

	if (profileNameSpace getVariable "A3C_HUD_RES_VAR") then {
		(findDisplay 100010 displayCtrl 1602) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1602) ctrlSetText "OFF";
	};
	if (profileNameSpace getVariable "A3C_FORCERAIL_VAR") then {
		(findDisplay 100010 displayCtrl 1603) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1603) ctrlSetText "OFF";
	};

	if (profileNameSpace getVariable "A3C_HUD_LAYOUT_CORNER") then {
		(findDisplay 100010 displayCtrl 1605) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1605) ctrlSetText "OFF";
	};
	if (profileNameSpace getVariable "A3C_HUD_OBJECTS") then {
		(findDisplay 100010 displayCtrl 1606) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1606) ctrlSetText "OFF";
	};


	if ((profileNameSpace getVariable "A3C_TABLET_IMG") == "A3C_CORE\ui\pictures\BG_Tablet_Tough.paa") then {
		(findDisplay 100010 displayCtrl 1604) ctrlSetText "REG";
	} else {
		(findDisplay 100010 displayCtrl 1604) ctrlSetText "SMALL";
	};

	if (profileNameSpace getVariable "HC_GROUP_RESPONSE") then {
		(findDisplay 100010 displayCtrl 1607) ctrlSetText "ON";
	} else {
		(findDisplay 100010 displayCtrl 1607) ctrlSetText "OFF";
	};

	[
		100010,
		'RADIAL',
		{true},
		{},
		{
			(findDisplay 100010) closeDisplay 0;
			showCommandingMenu "";
			(findDisplay 100010) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
		},
		true
	] call A3C_UI_RADIAL_ADD_EH_MACROS;


	while {!isnull (findDisplay 100010)} do {
		sleep 0.5;
	};
};
