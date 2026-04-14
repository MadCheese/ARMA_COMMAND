

A3C_UI_SettingsMenu_FNC_ChangeSettings = {
	_var = _this select 0;
	_val = 0;
	_mode = "OFF";




	switch (_var) do {
		case ("A3C_SKILL_VAR") : {_val = 100};
		case ("A3C_NUM_VAR") : {_val = 101};
		case ("A3C_HUD_RES_VAR") : {_val = 102};
		case ("A3C_FORCERAIL_VAR") : {_val = 103};
		case ("A3C_HUD_LAYOUT_CORNER") : {_val = 104};
		case ("A3C_HUD_OBJECTS") : {_val = 105};
		case ("HC_GROUP_RESPONSE") : {_val = 106};
		
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

	};
};

A3C_UI_SETTINGS_FNC_OpenSettings = {
    [] call A3C_settingsMenu_fnc_open;
};