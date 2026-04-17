/*//---------------------------------  HANDLER-DISPATCHERS [HUD]  ----------------------------------

These functions are dispatched from the main binds in UI_DSP_HUD_Handlers.sqf.

UI_DSP_HUD_Handlers.sqf handles the events and dispatches recognized keybinds here.

*///------------------------------------------------------------------------------------------------


//-- Helicopter gunner bonus controls
A3C_UI_HUD_onKeyDown_heliGunner = {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    
    private _flareKeysArray = actionKeys "launchCM";
    private _raiseCollectiveKeysArray = actionKeys "HeliCollectiveRaise";
    private _lowerCollectiveKeysArray = actionKeys "HeliCollectiveLower";
    private _handled = false;
    private _atlHeight = (getPosATL vehicle player) select 2;

    // countermeasures
    if ({_x in A3C_UI_DOWNKEYS} count _flareKeysArray == count _flareKeysArray) then {
        if (behaviour driver vehicle player == "CARELESS") then {
            private _wpnsTurret = vehicle player weaponsTurret [-1];

            {
                private _weapon = _x;
                private _mags = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");

                {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    private _aiUsageFlags = getNumber (configFile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");

                    if (_aiUsageFlags == 8) then {
                        private _mode = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) select 0;
                        (driver vehicle player) forceWeaponFire [_weapon, _mode];
                    };
                } forEach _mags;
            } forEach _wpnsTurret;

            [vehicle player] call A3C_Evasive;
            _handled = true;
        };
    };

    // raise collective
    if (!_handled && {{_x in A3C_UI_DOWNKEYS} count _raiseCollectiveKeysArray == count _raiseCollectiveKeysArray}) then {
        vehicle player flyInHeight (_atlHeight + 20);
        _handled = true;
    };

    // lower collective
    if (!_handled && {{_x in A3C_UI_DOWNKEYS} count _lowerCollectiveKeysArray == count _lowerCollectiveKeysArray}) then {
        vehicle player flyInHeight (_atlHeight - 20);
        _handled = true;
    };

    // rotate / rudder
    if (!_handled && {speed vehicle player < 25} && {_key in [203, 205, 30, 32]}) then {
        private _twist = if (_key in [205, 32]) then {0.5} else {-0.5};
        vehicle player setDir (getDir vehicle player + _twist);
        // _handled = true; // -- NOTE: uncomment this if you happen to add any more mechanics here
    };
};

//-- NUM-Pad SQ-HUD unit selections
A3C_UI_HUD_onKeyDown_NUM = {
	params ["_key"];
	private _colorTeamUnits = [];
	private _teamColor = "";
	// private _gpUnits = (units group player) - [player]; //-- NOTE: JUst a reminder that I changed things - if it turns out to need (units player) we re-adjust
	private _gpUnits = (profileNamespace getVariable "A3C_GROUPUNITS") - [player];
	private _unitCount = count _gpUnits;

	switch (true) do {
		case ((_key in [103, 104, 105, 106])): {
			if (count A3C_HUD_UNITS == 0) then {
				A3C_HUD_FORM = 0;
			};

			A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
			A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
			A3C_HUD_FORM_ICON_SIZE = 0.8;

			switch (_key) do {
				case 103: {_teamColor = "RED"};
				case 104: {_teamColor = "GREEN"};
				case 105: {_teamColor = "BLUE"};
				case 106: {_teamColor = "YELLOW"};
			};

			for "_i" from 0 to (_unitCount - 1) do {
				private _unit = _gpUnits select _i;
				if (!isNull _unit && {alive _unit}) then {
					private _assignedTeam = if (player == cameraOn) then {
						assignedTeam _unit
					} else {
						_unit getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
					};
					if (_assignedTeam == _teamColor) then {
						_colorTeamUnits set [count _colorTeamUnits, _unit];
					};
				};
			};

			{
				//--#TODO: clarify if this is intentional or sloppy coding
				if (_x in A3C_HUD_UNITS) then {
					[_x] call A3C_HUD_REMOVE_SELECTED;
				};
				if (_x in _colorTeamUnits) then {
					[_x, _key] call A3C_HUD_ADD_SELECTED;
				};
			} forEach (_gpUnits select {!isNull _x});
		};

		case ((_key in [71, 72, 73, 75, 76, 77, 79, 80, 81])): {
			if (A3C_FORMATION_DIR > 360) then {A3C_FORMATION_DIR = A3C_FORMATION_DIR - 360};
			if (A3C_FORMATION_DIR < 0) then {A3C_FORMATION_DIR = A3C_FORMATION_DIR + 360};

			if (count A3C_HUD_UNITS == 0) then {
				A3C_NUM_DIR = 0;

				for "_i" from 0 to (_unitCount - 1) do {
					private _unit = _gpUnits select _i;
					if
					(
						!isNull _unit
						&& {alive _unit}
						&& {!isPlayer _unit} //-- in case there's a fellow human in squad
					) then {
						[_unit, _i] call A3C_HUD_ADD_SELECTED;
					};
				};

				if (A3C_HUD_FORM == 0) then {
					A3C_HUD_FORM = 1;
					A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
					A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
					A3C_HUD_FORM_ICON_SIZE = 0.8;
				};
			};

			A3C_FORMATION_DIR = [A3C_FORMATION_DIR] call MCSS_fnc_CorrectDir;
			A3C_HUD_FORM_ICON_COLOR = [0, 0, 0, 0.2];
			A3C_HUD_FORM_ICON_SIZE = 0.8;
			switch (_key) do {
				case 71: {
					A3C_NUM_DIR = 180;
					A3C_HUD_FORM = 4;
					A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					
				};
				case 72: {
					if (A3C_HUD_FORM == 0) then {
						A3C_HUD_FORM = 1;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
					} else {
						A3C_HUD_FORM = 0;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					};
					A3C_NUM_DIR = 0;
				};
				case 73: {
					A3C_NUM_DIR = 180;
					A3C_HUD_FORM = 3;
					A3C_HUD_FORM_ICON = "\a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_left_ca.paa";
				};
				case 75: {
					if (A3C_HUD_FORM == 0) then {
						A3C_HUD_FORM = 1;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
					} else {
						A3C_HUD_FORM = 0;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					};
					A3C_NUM_DIR = 90;
				};
				case 77: {
					if (A3C_HUD_FORM == 0) then {
						A3C_HUD_FORM = 1;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
					} else {
						A3C_HUD_FORM = 0;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					};
					A3C_NUM_DIR = -90;
				};
				case 79: {
					A3C_NUM_DIR = 0;
					A3C_HUD_FORM = 3;
					A3C_HUD_FORM_ICON = "\a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_left_ca.paa";
				};
				case 80: {
					if (A3C_HUD_FORM == 0) then {
						A3C_HUD_FORM = 1;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
					} else {
						A3C_HUD_FORM = 0;
						A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					};
					A3C_NUM_DIR = 180;
				};
				case 81: {
					A3C_NUM_DIR = 0;
					A3C_HUD_FORM = 4;
					A3C_HUD_FORM_ICON = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
				};
			};
		};
		
	};
};

