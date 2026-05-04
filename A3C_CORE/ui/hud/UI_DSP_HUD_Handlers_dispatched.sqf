/*//---------------------------------  HANDLER-DISPATCHERS [HUD]  ----------------------------------

These functions are dispatched from the main binds in UI_DSP_HUD_Handlers.sqf.

UI_DSP_HUD_Handlers.sqf handles the events and dispatches recognized keybinds here.

*///------------------------------------------------------------------------------------------------


//-- Helicopter gunner bonus controls
A3C_UI_HUD_onKeyDown_heliGunner = {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    private _helicopter = vehicle player;

	private _isCounterMeasures = (inputAction "launchCM") > 0;
	private _isCollectiveRaise = (inputAction "HeliCollectiveRaise") > 0;
	private _isCollectiveLower = (inputAction "HeliCollectiveLower") > 0;
	private _isRudderLeft = (inputAction "HeliRudderLeft") > 0;
	private _isRudderRight = (inputAction "HeliRudderRight") > 0;

	private _params = [_helicopter];
	private _code = {};
	private _shouldExec = false;

    switch (true) do {
        case (
			_isCounterMeasures
			//-- NOTE: Removed careless check until we know exactly that it is relevant.
            // && {behaviour driver _helicopter == "CARELESS"}

        ): {
			_params = [_helicopter, A3C_AI_Fnc_Command_Helicopter_evasiveMove];
			_code = {
				params ["_helicopter", "_evasiveFnc"];

				private _driver = driver _helicopter;
				private _cfg = configFile;
				private _wpnsTurret = _helicopter weaponsTurret [-1];
				private _fired = false;

				{
					private _weapon = _x;
					private _weaponCfg = _cfg >> "CfgWeapons" >> _weapon;

					private _modes = getArray (_weaponCfg >> "modes");
					if (_modes isEqualTo []) then { continue };

					private _mode = _modes select 0;
					private _mags = getArray (_weaponCfg >> "magazines");

					{
						private _magCfg = _cfg >> "CfgMagazines" >> _x;
						private _ammoCfg = _cfg >> "CfgAmmo" >> getText (_magCfg >> "ammo");

						if (
							getText (_ammoCfg >> "simulation") == "shotCM"
							&& {getText (_ammoCfg >> "effectsSmoke") in ["CounterMeasureFlare", "CounterMeasureChaff"]}
						) exitWith {
							_driver forceWeaponFire [_weapon, _mode];
							_fired = true;
						};
					} forEach _mags;

					if (_fired) exitWith {};
				} forEach _wpnsTurret;

				[_helicopter] call _evasiveFnc;
			};
			_shouldExec = true;    
        };

        case (_isCollectiveRaise): {
			_params = [_helicopter];
			_code = {
				params ["_helicopter"];
				_helicopter flyInHeight (((getPosATL _helicopter) select 2) + 20);
			};
			_shouldExec = true;
		};

		case (_isCollectiveLower): {
			_params = [_helicopter];
			_code = {
				params ["_helicopter"];
				_helicopter flyInHeight (((getPosATL _helicopter) select 2) - 20);
			};
			_shouldExec = true;
		};

        case
		(
			speed _helicopter < 25
			&& {_isRudderLeft || {_isRudderRight}}
		): {
			private _adjust = if (_ctrl) then {0.5} else {0.2};
            private _twist = if (_isRudderLeft) then {_adjust * -1} else {_adjust};
			_params = [_helicopter, _twist];
			_code = {
				params ["_helicopter", "_twist"];

				private _vel = velocity _helicopter;
				private _dir = vectorDir _helicopter;
				private _up = vectorUp _helicopter;

				private _c = cos _twist;
				private _s = sin _twist;

				private _newDir = [
					((_dir select 0) * _c) + ((_dir select 1) * _s),
					-((_dir select 0) * _s) + ((_dir select 1) * _c),
					_dir select 2
				];

				_helicopter setVectorDirAndUp [_newDir, _up];
				_helicopter setVelocity _vel;
			};
			_shouldExec = true;    
        };
    };

	if (_shouldExec) then {
		[_params, _code] remoteExec ["bis_fnc_call", _helicopter];
	};
};


A3C_UI_HUD_onKeyUp_heliGunner = {
	private _isCollectiveRaise = (inputAction "HeliCollectiveRaise") > 0;
	private _isCollectiveLower = (inputAction "HeliCollectiveLower") > 0;

	if (_isCollectiveRaise || {_isCollectiveLower}) then {
		private _helicopter = vehicle player;

		private _params = [_helicopter];
		private _code = {
			params ["_helicopter"];

			private _token = (_helicopter getVariable ["A3C_collectiveReleaseToken", 0]) + 1;
			_helicopter setVariable ["A3C_collectiveReleaseToken", _token];

			[_helicopter, _token] spawn {
				params ["_helicopter", "_token"];

				waitUntil {
					sleep 0.05;

					isNull _helicopter
					|| {!local _helicopter}
					|| {(_helicopter getVariable ["A3C_collectiveReleaseToken", -1]) != _token}
					|| {abs ((velocity _helicopter) select 2) < 1}
				};
				if (
					!isNull _helicopter
					&& {local _helicopter}
					&& {(_helicopter getVariable ["A3C_collectiveReleaseToken", -1]) == _token}
				) then {
					_helicopter flyInHeight ((getPosATL _helicopter) select 2);
					_helicopter setVariable ["A3C_collectiveReleaseToken", nil];
				};
			};
		};

		[_params, _code] remoteExec ["BIS_fnc_call", _helicopter];
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
			if (count A3C_UI_squadPlacement_units == 0) then {
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
				if (_x in A3C_UI_squadPlacement_units) then {
					[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
				};
				if (_x in _colorTeamUnits) then {
					[_x, _key] call A3C_UI_squadPlacement_fnc_addUnitGhost;
				};
			} forEach (_gpUnits select {!isNull _x});
		};

		case ((_key in [71, 72, 73, 75, 76, 77, 79, 80, 81])): {
			if (A3C_FORMATION_DIR > 360) then {A3C_FORMATION_DIR = A3C_FORMATION_DIR - 360};
			if (A3C_FORMATION_DIR < 0) then {A3C_FORMATION_DIR = A3C_FORMATION_DIR + 360};

			if (count A3C_UI_squadPlacement_units == 0) then {
				A3C_NUM_DIR = 0;

				for "_i" from 0 to (_unitCount - 1) do {
					private _unit = _gpUnits select _i;
					if
					(
						!isNull _unit
						&& {alive _unit}
						&& {!isPlayer _unit} //-- in case there's a fellow human in squad
					) then {
						[_unit, _i] call A3C_UI_squadPlacement_fnc_addUnitGhost;
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

