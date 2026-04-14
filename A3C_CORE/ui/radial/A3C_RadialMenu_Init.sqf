
if (isDedicated) exitwith {};

A3C_UI_GRID_SIZE = 1;

A3C_UI_Radial_SQ_ROE_MAIN = {
    BR_A3C_DISABLE_RADIAL = true;
    [] call A3C_RADIAL_CloseDisplay;

    with uiNamespace do {
        A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_BHV_CBM";
    };

    setMousePosition [0.5, 0.5];

    // Button properties
    _buttonsPerRow = 5;
    _rows = 2;

    (findDisplay 100100) displayAddEventhandler
    [
        "KeyUp",
        {
            [_this] spawn {
                _button = _this select 0;
                _button = _button - [(_button select 0)];
                if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
                    BR_A3C_DISABLE_RADIAL = false;
                    A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
                    (findDisplay 100100) closeDisplay 0;
                    A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
                    {player groupSelectUnit [_x,false]} foreach units player; 
                    showCommandingMenu "";
                };
            };
        }
    ];

    // Scaling factor to control the size of the entire dialog
    private _scaleFactor = 4; // Adjust this value to resize the dialog proportionally

    // Adjusted grid size based on scaling factor
    _grid = 12 * _scaleFactor;

    private _controlsGroup = (findDisplay 100100) ctrlCreate ["RscControlsGroup", 100];
    _controlsGroup ctrlSetPosition
    [
        (safeZoneX + (safeZoneW / 2)) - ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelW * 2 )),
        (safeZoneY + (safeZoneH / 2)) - ( (A3C_UI_GRID_SIZE * (_grid / 4)) * ( pixelGridNoUIScale * pixelH * 2 )),
        ( (A3C_UI_GRID_SIZE * _grid) * ( pixelGridNoUIScale * pixelW * 2 )), 
        ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelH * 2 ))
    ];
    _controlsGroup ctrlCommit 0;

    private _ctrlImageG = (findDisplay 100100) ctrlCreate ["RscPicture", 101, _controlsGroup];
    _ctrlImageG ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_CombatBehaviour.paa";
    _ctrlImageG ctrlSetPosition 
    [
        0, 
        0, 
        ( (A3C_UI_GRID_SIZE * _grid) * ( pixelGridNoUIScale * pixelW * 2 )), 
        ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelH * 2 ))
    ];

    _bgColor = if (sunOrMoon < 1) then {[0,0.5,0.8,0.6]} else {[0,0,0,0.6]};
    _ctrlImageG ctrlSetTextColor _bgColor;
    _ctrlImageG ctrlCommit 0;

    // Define adjustable boundaries for button placement
    private _horizontalBoundary = 0.1; // Percentage of the background width to leave as horizontal margin
    private _verticalBoundary = 0.29;   // Percentage of the background height to leave as vertical margin

    // Calculate button placement boundaries
    private _backgroundWidth = (A3C_UI_GRID_SIZE * _grid) * (pixelGridNoUIScale * pixelW * 2);
    private _backgroundHeight = (A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelH * 2);
    private _usableWidth = _backgroundWidth * (1 - 2 * _horizontalBoundary);
    private _usableHeight = _backgroundHeight * (1 - 2 * _verticalBoundary);

    // Button dimensions based on usable space
    private _buttonDim = _usableHeight / _rows; // Square buttons, sized to fit rows
    private _horizontalSpacing = (_usableWidth - (_buttonsPerRow * _buttonDim)) / (_buttonsPerRow - 1);

    // Starting offsets for button placement
    private _horizontalOffset = _horizontalBoundary * _backgroundWidth;
    private _verticalOffset = _verticalBoundary * _backgroundHeight;

    // Define button labels and tooltips
    _behaviours = ["CARELESS", "SAFE", "STEALTH", "AWARE", "COMBAT"];
    _behaviourTooltips = ["SET BEHAVIOUR: CARELESS", "SET BEHAVIOUR: SAFE", "SET BEHAVIOUR: STEALTH", "SET BEHAVIOUR: AWARE", "SET BEHAVIOUR: COMBAT"];
    _combatModes = ["BLUE", "GREEN", "WHITE", "YELLOW", "RED"];
    _combatModeTooltips = [
        "SET ROE: NEVER FIRE, KEEP FORMATION",
        "SET ROE: HOLD FIRE, KEEP FORMATION",
        "SET ROE: HOLD FIRE, ENGAGE AT WILL",
        "SET ROE: FIRE AT WILL, KEEP FORMATION",
        "SET ROE: FIRE AT WILL, ENGAGE AT WILL"
    ];
    _colorPalettes = [
        [0.17, 0.86, 0.92, 0.6],  
        [0, 1, 0, 0.4],            
        [1, 1, 1, 0.4],            
        [1, 1, 0, 0.4],            
        [0.5, 0, 0, 0.4]           
    ];

	_awareButtonX = 0.5;
	_awareButtonY = 0.5;
	

    // Loop through rows and buttons
    for "_i" from 0 to (_rows - 1) do {
        _yPos = _verticalOffset + (_i * _buttonDim); // Adjust Y position for centering

        for "_t" from 0 to (_buttonsPerRow - 1) do {
            _xPos = _horizontalOffset + (_t * (_buttonDim + _horizontalSpacing)); // Adjust X position

            private _ctrlImg = (findDisplay 100100) ctrlCreate ["RscPicture", -1, _controlsGroup];
            _ctrlImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_ROE_OPT.paa";
			// "\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\AssignedTarget_ca.paa";
            _ctrlImg ctrlSetTextColor (_colorPalettes select _t);
            _ctrlImg ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];
            _ctrlImg ctrlCommit 0;

            private _ctrlBtn = (findDisplay 100100) ctrlCreate ["A3C_RscButton_Invisible", -1, _controlsGroup];
            _ctrlBtn ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];
            private _tooltip = if (_i == 0) then {_behaviourTooltips select _t} else {_combatModeTooltips select _t};
            private _mode = if (_i == 0) then {"BEHAVIOUR"} else {"COMBATMODE"};
            private _value = if (_i == 0) then {_behaviours select _t} else {_combatModes select _t};
            private _buttonAction = format ["['%1', '%2'] call A3C_BHV_CBM_MACRO;", _mode, _value];
            _ctrlBtn ctrlSetTooltip _tooltip;
            _ctrlBtn buttonSetAction _buttonAction;
            _ctrlBtn ctrlCommit 0;

			//-- Save the position of the "AWARE" button (Row 0, Column 3)
            if (_i == 0 && _t == 2) then {
                _awareButtonX = _xPos; // + (_buttonDim / 2);
                _awareButtonY = _yPos; // + (_buttonDim / 2);
            };
        }
    };

	setMousePosition [_awareButtonX, _awareButtonY];
};




A3C_TempNVGLASER_TOGGLE = {
	params ["_mode"];
	_btnImage = "";
	if (_mode == "ON") then {
		_btnImage = ctrlsetText '\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\nvgs_ca.paa';
	} else {
		if ({_x isIRLaserOn (currentWeapon _x)} count (A3C_RD_UNITS - [player]) > 0) then {
			_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
		} else {
			_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
		};
	};
	if (_btnImage != "") then {
		(findDisplay 100040 displayCtrl 10026) ctrlSetText _btnImage;
	};
};



A3C_UI_RADIAL_iconsAtClickPos = {
	params ["_clickPos"];
	_clickPos params ["_clickPosX","_clickPosY"];
	private _iconsAtPosition = [];

	

	{
		_x params ["_group","_sizeArray","_iconPos"];
		_sizeArray params ["_iconScreenWidth","_iconScreenHeight"];

		if (count _iconPos > 0) then {


			_iconScreenWidth =  _iconScreenWidth / 50;
			_iconYDivisor = 50 / (getResolution select 4);
			_iconScreenHeight = _iconScreenHeight / _iconYDivisor;

			_clickDifX = abs ((_iconPos select 0) - (_clickPos select 0));
			_clickDifY = abs ((_iconPos select 1) - (_clickPos select 1));

			if (_clickDifX < _iconScreenWidth && {_clickDifY < _iconScreenHeight}) then {
				_iconsAtPosition pushBackUnique _x;
			};

		};

	} foreach A3C_UI_HUDICONS_HC_GROUP;
	_iconsAtPosition
};



A3C_CURRENT_COMMAND_LEVEL = "SQUAD";

A3C_UI_RADIAL_CTRLS_SHOWN = [];
A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;



A3C_UI_RADIAL_CTRLS_QUICKTOGGLE = {
	params ["_mode"];
	private _bool = false;
	//if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
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
				[] call A3C_Radial_DashBoard;
			};
		};
	//};

	_bool
};


A3C_Radial_DashBoard_ExtraControls = [];

A3C_Radial_DashBoard = {

	
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};


	(findDisplay _a3c_dsp displayCtrl 800713) ctrlSetTextColor [1,1,1,0]; //-- hide ct-edit box because of it's frame
	

	_ref_selected_units = if (_a3c_dsp == 100040) then {A3C_RD_UNITS} else {A3C_SELECTED_HC_GROUPS_SETTINGS};


	if (count _ref_selected_units == 1) then {
		//if (true) exitWith {};


		//--reset box and structured text

		//player globalchat str A3C_Radial_DashBoard_ExtraControls;
		//(findDisplay _a3c_dsp displayCtrl 11010) ctrlSetText "Fuel";
		{
			//systemchat str (ctrlShown _x);
			ctrlDelete _x;
		} foreach A3C_Radial_DashBoard_ExtraControls;
		A3C_Radial_DashBoard_ExtraControls = [];


		_parent = (findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT);

		_parent ctrlSetPosition 
		[
			(ctrlPosition _parent) select 0,
			0.414993 * safezoneH + safezoneY,
			0.240009 * safezoneW,
			0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];
		

		_backGround = (findDisplay _a3c_dsp displayCtrl 11015);
		_backGround ctrlSetPosition 
		[
			4.9593e-007 * safezoneW,
			0 * safezoneH,
			0.240009 * safezoneW,
			0.221018 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];
		

		_structuredText = (findDisplay _a3c_dsp displayCtrl 11014);
		_structuredText ctrlSetPosition 
		[
			0.104004 * safezoneW,
			0.136011 * safezoneH,
			0.136005 * safezoneW,
			0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)))
		];

		

		{(findDisplay _a3c_dsp displayCtrl _x) ctrlSetTextColor [1,1,1,1]} foreach [12000,12002];
		
		if (_a3c_dsp == 100020) then {

			_mapBarDims = ctrlPosition (findDisplay 12 displayctrl 1020);
			_mapBarDims params ["_mapBarX","_mapBarY","_mapBarW","_mapBarH"];
			_mapBarY = _mapBarY + _mapBarH;

			(ctrlPosition (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT)) params ["_gpX","_gpY","_gpW","_gpH"];


			_parentPos = ctrlPosition _parent;
			_parentPos set [0, _gpX - (_parentPos select 2) ]; //[0,(safeZoneX + safeZoneW) - (_parentPos select 2) - A3C_MAP_GAMEUI_PADDING_X]; //
			_parentPos set [1,_gpY]; //safeZoneH + (_parentPos select 3)
			_parent ctrlSetPosition _parentPos;
		};
		_parent ctrlCommit 0;
		_backGround ctrlCommit 0;
		_structuredText ctrlCommit 0;
	
		//-- fetch group Info

		private _group = _ref_selected_units select 0;
		private _leaderVic = vehicle leader _group;
		private _isCargo = !(driver _leaderVic in units _group);
		private _groupIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\SI_stand_ca.paa";
		if (!isNull objectParent (leader _group)) then {
			_groupIcon = if (_isCargo) then {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"} else {gettext (configfile >> "CfgVehicles" >> typeof _leaderVic >> "picture")};
		};			
		private _groupID = groupID _group;
		private _location = text (((nearestLocations [position player, ["NameLocal","NameCity","NameMarine","NameVillage","StrongpointArea","NameCityCapital"], 5000]) select {!("000" in text _x)}) select 0); //((nearestLocations [position _leaderVic, ["NameLocal","NameCity","NameMarine","NameVillage","StrongpointArea","NameCityCapital"], 5000]) select {!("000" in text _x)}) select 0;
		_location = if (isNil '_location') then {
			"UNKNOWN LOCATION"
		} else {
			format ["Location: Near %1 at %2", _location, mapGridPosition (position _leaderVic)];
		};
		private _unitSize = format ["Unitsize: %1",count units _group];
		

		_bgColor = if (_a3c_dsp == 100040 && {sunOrMoon < 1}) then {[0,0.5,0.8,0.6]} else {[0,0,0,0.6]};
		(findDisplay _a3c_dsp displayCtrl 11015) ctrlSetTextColor _bgColor;
		//systemchat str _bgColor;
		
		(findDisplay _a3c_dsp displayCtrl 11014) ctrlSetBackGroundColor [0,0,0,0.2];
		
		private _currentTask = "Idle";
		
		private _actionScript = wayPointScript [_group, currentWaypoint _group];
		if (_actionScript == "") then {
			_actionScript = (waypointStatements [_group, currentWaypoint _group]) select 1;
		};
		switch (true) do {
			
			
			case ("transport unload" in toLower _actionScript) : {
				_currentTask = "Deliver Troops";
			};
			case (!(_isCargo) && {{group _x != _group} count crew _leaderVic > 0}) : {
				_currentTask = "Transporting units";
			};
			case (_isCargo) : {
				_currentTask = "In Transport";
			};
			case ("landing" in toLower _actionScript) : {
				_currentTask = "Landing Aircraft";
			};
			case ("rappel" in toLower _actionScript) : {
				_currentTask = "Rappeling Cargo";
			};
			case ("repair" in toLower _actionScript) : {
				_currentTask = "Repairing Vehicles";
			};
			case ("assemble" in toLower _actionScript) : {
				_currentTask = "Assembling Static Weapon";
			};
			case ("cas-strike" in toLower _actionScript) : {
				_currentTask = "Preparing CAS-Strike";
			};
			case ("sling load hook" in toLower _actionScript) : {
				_currentTask = "Preparing Sling-Load Hook";
			};
			case ("sling load unhook" in toLower _actionScript) : {
				_currentTask = "Preparing Sling-Load Unhook";
			};
			case ("paradrop" in toLower _actionScript) : {
				_currentTask = "Preparing Paradrop";
			};
			case ("plantexplosive" in toLower _actionScript) : {
				_currentTask = "Planting Explosives";
			};
			case ("clearbuilding" in toLower _actionScript) : {
				_currentTask = "Clearing Building";
			};
			
			case ("assemble_uav" in toLower _actionScript) : {
				_currentTask = "Setting Up UAV";
			};
			case ("overwatch" in toLower _actionScript) : {
				_currentTask = "En Route For Overwatch";
			};
			default {
				if (waypointtype [_group,currentWaypoint _group] == "MOVE") then {
					_currentTask = "Moving";
				};
			};
		};

		_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
		if (_var select 0) then {
			_currentTask = "Providing Overwatch";
		};

		_currentTask = format ["Current Task: %1",_currentTask];

		private _vehicles = [];
		private _damages_MAN = [];
		private _damages_VEHICLE = [];
		private _ammoValuesInfPrimary = [];
		private _ammoValuesInfSecondary = [];
		private _ammoValuesVehicle_General = [];
		private _ammoValuesVehicle_Pylon = [];
		private _throwableValues = [];
		private _staminaValues = [];

		{
			if (isNull objectParent _x OR {assignedvehiclerole _x select 0 == "cargo"}) then {
				_damages_MAN pushBack (damage _x);
				//_defaultMagazines = getArray (configfile >> "CfgVehicles" >> typeOf _x >> "magazines");
				
				_unitLoadOut = getUnitLoadout (configFile >> "CfgVehicles" >> typeof _x); //getUnitLoadout _x;
				_loadOutMagArray_MAN = [];

				_isLauncherUnit = (secondaryWeapon _x) isKindOf ["Launcher", configFile >> "CfgWeapons"];
				_launcherAllowedMags = (getArray(configfile >> "CfgWeapons" >> secondaryweapon _x >> "magazines"));

				//-- loadout weapon magazines
				for "_i" from 0 to 2 do {
					_weaponData = _unitLoadOut select _i;
					if (count _weaponData >= 5) then {
							_loadOutMagArray_MAN pushBack [(_weaponData select 4) select 0,1];
					};
				};

				//-- loadout container magazines
				for "_i" from 3 to 5 do {
					_containerData = _unitLoadOut select _i;
					if (count _containerData > 0) then {
						{
							if (   (([_x select 0] call BIS_fnc_itemType) select 0) == "Magazine") then {
								_loadOutMagArray_MAN pushBack [_x select 0, _x select 1];
							};
						} foreach (_containerData select 1);
					};
				};

				_totalMadArray_Primary = [];
				_totalThrowableArray = [];
				_totalMagArray_Secondary = [];
				{
					_x params ["_magName","_magCount"];
					if (!isNil '_magName') then {
						for "_i" from 1 to _magCount do {
							if (_magName call BIS_fnc_isThrowable) then {
								_totalThrowableArray pushBack _magName;
							} else {
								if (_magName in _launcherAllowedMags) then {
									_totalMagArray_Secondary pushBack _magName;
								} else {
									_totalMadArray_Primary pushBack _magName;
								};	
							};	
						};
					};
					
				} foreach _loadOutMagArray_MAN;

				//systemchat str _totalThrowableArray;
				_currentMags = magazines _x + (primaryweaponMagazine _x) + (secondaryweaponMagazine _x) + (handgunMagazine _x);
				_currentThrowables = [];
				_currentSecondaryMags = [];

				while {{(_x call BIS_fnc_isThrowable)} count _currentMags > 0} do {
					{
						if (_x call BIS_fnc_isThrowable) exitWith {
							_currentMags deleteAt _foreachIndex;
							_currentThrowables pushBack _x;
						};
					} foreach _currentMags;
				};

				while {{(_x in _totalMagArray_Secondary)} count _currentMags > 0} do {
					{
						if (_x in _launcherAllowedMags) exitWith {
							_currentMags deleteAt _foreachIndex;
							_currentSecondaryMags pushBack _x;
						};
					} foreach _currentMags;
				};


				//systemchat str [(count _currentSecondaryMags) , (count _totalMagArray_Secondary)];



				if (count _totalMadArray_Primary > 0) then {
					_ammoValuesInfPrimary pushBack ( ( (count _currentMags) / (count _totalMadArray_Primary) ) min 1);
				};

				if (count _totalThrowableArray > 0) then {
					_throwableValues pushBack ( ( (count _currentThrowables) / (count _totalThrowableArray) ) min 1);
				};

				if (count _totalMagArray_Secondary > 0) then {
					_ammoValuesInfSecondary pushBack ( ( (count _currentSecondaryMags) / (count _totalMagArray_Secondary) ) min 1);
				};

				_staminaValues pushBack (1 - (getFatigue _x));

			} else {
				_vehicles pushBackUnique (vehicle _x);
			};
		} foreach units _group;



		private _fuelValues = [];
		
		{
			_vehicle = _x;
			_damages_VEHICLE pushBack (damage _vehicle);
			_fuelValues pushBack (fuel _vehicle);
			_vehicleDefaultMags = (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "magazines"));
			_turretMags = [];
			_turrets = "true" configClasses (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets");
			{
				_turretMags = _turretMags + (getArray (configfile >> "CfgVehicles" >> typeof _vehicle >> "Turrets" >> (configName _x) >> "magazines"));
			} foreach _turrets;

			_vehicleDefaultMags = _vehicleDefaultMags  + _turretMags;
				
			
				
			//_vehicleDefaultMags = _vehicleDefaultMags + _vehiclePylons;	
			_vehicleDefaultPylons = (getPylonMagazines _vehicle);

			_vehicleDefaultMags = _vehicleDefaultMags - _vehicleDefaultPylons;

			_currentVehicleMags = (magazinesAmmoFull _vehicle) select {_mag = _x select 0; {(_x in toLower _mag)} count ["laser"] == 0 };
			_vehicleMagPercentages = [];
			_vehiclePylonPercentages = [];
			{
				_x params ["_magName","_ammoCount"];
				private _ammoCountFullMag = getNumber (configfile >> "CfgMagazines" >> _magName >> "count");
				_percentage = if (_ammoCount > 0) then {_ammoCount / _ammoCountFullMag} else {0};
				_vehicleDefaultMags = _vehicleDefaultMags - [_magName];
				_currentVehicleMags =  _currentVehicleMags - [_magName];
				if (_magName in _vehicleDefaultPylons) then {
					{
						if (_x == _magName) exitWith {
							_vehicleDefaultPylons deleteAt _foreachIndex;
						};
					} foreach _vehicleDefaultPylons;
					_vehiclePylonPercentages pushBack _percentage;
					
				} else {
					_vehicleMagPercentages pushBack _percentage;
				};
				
			} foreach _currentVehicleMags;

			_finalVehicleMagPercentage = 0;
			{_finalVehicleMagPercentage = _finalVehicleMagPercentage + _x} foreach _vehicleMagPercentages;
			_finalVehicleMagPercentage = if (count _vehicleMagPercentages > 0) then {_finalVehicleMagPercentage / count _vehicleMagPercentages} else {0};
			
			
			_finalVehiclePylonPercentage = 0;
			{_finalVehiclePylonPercentage = _finalVehiclePylonPercentage + _x} foreach _vehiclePylonPercentages;
			_finalVehiclePylonPercentage = if (count _vehiclePylonPercentages > 0) then {_finalVehiclePylonPercentage / count _vehiclePylonPercentages} else {0};

	
			
			_ammoValuesVehicle_General pushBack _finalVehicleMagPercentage;
			_ammoValuesVehicle_Pylon pushBack _finalVehiclePylonPercentage;
			
			//systemchat str [[count _vehicleMagPercentages],_finalVehicleMagPercentage];
			//systemchat str [[count _vehiclePylonPercentages],_finalVehiclePylonPercentage];
			

			
		
		} foreach _vehicles;

		//-- get Progress Bar Values
		private _groupDamage_MAN = 0;
		{_groupDamage_MAN = _groupDamage_MAN + _x} foreach _damages_MAN;
		if (count _damages_MAN > 0) then {
			_groupDamage_MAN = _groupDamage_MAN / (count _damages_MAN);
			_groupDamage_MAN = [_groupDamage_MAN,1] call BIS_fnc_cutDecimals;
		};
		_groupDamage_MAN = 1 - _groupDamage_MAN; //-- convert damage to health



		_groupDamage_VEHICLE = 0;
		{_groupDamage_VEHICLE = _groupDamage_VEHICLE + _x} foreach _damages_VEHICLE;
		if (count _damages_VEHICLE > 0) then {
			_groupDamage_VEHICLE = _groupDamage_VEHICLE / (count _damages_VEHICLE);
			_groupDamage_VEHICLE = [_groupDamage_VEHICLE,1] call BIS_fnc_cutDecimals;
		};
		_groupDamage_VEHICLE = 1 - _groupDamage_VEHICLE; //-- convert damage to health


		

		private _groupMagazines_Man_Primary = 0;
		{_groupMagazines_Man_Primary = _groupMagazines_Man_Primary + _x} foreach _ammoValuesInfPrimary;
		if (count _ammoValuesInfPrimary > 0) then {
			_groupMagazines_Man_Primary = _groupMagazines_Man_Primary / (count _ammoValuesInfPrimary);
			_groupMagazines_Man_Primary = [_groupMagazines_Man_Primary,1] call BIS_fnc_cutDecimals;
		};


		private _groupMagazines_Man_Secondary = 0;
		{_groupMagazines_Man_Secondary = _groupMagazines_Man_Secondary + _x} foreach _ammoValuesInfSecondary;
		if (count _ammoValuesInfSecondary > 0) then {
			_groupMagazines_Man_Secondary = _groupMagazines_Man_Secondary / (count _ammoValuesInfSecondary);
			_groupMagazines_Man_Secondary = [_groupMagazines_Man_Secondary,1] call BIS_fnc_cutDecimals;
		};


		private _groupMagazines_Vehicle = 0;
		{_groupMagazines_Vehicle = _groupMagazines_Vehicle + _x} foreach _ammoValuesVehicle_General;
		if (count _ammoValuesVehicle_General > 0) then {
			_groupMagazines_Vehicle = _groupMagazines_Vehicle / (count _ammoValuesVehicle_General);
			_groupMagazines_Vehicle = [_groupMagazines_Vehicle,1] call BIS_fnc_cutDecimals;
		};

		private _groupPylons_Vehicle = 0;
		{_groupPylons_Vehicle = _groupPylons_Vehicle + _x} foreach _ammoValuesVehicle_Pylon;
		if (count _ammoValuesVehicle_Pylon > 0) then {
			_groupPylons_Vehicle = _groupPylons_Vehicle / (count _ammoValuesVehicle_Pylon);
			_groupPylons_Vehicle = [_groupPylons_Vehicle,1] call BIS_fnc_cutDecimals;
		};



		private _groupThrowables = 0;
		{_groupThrowables = _groupThrowables + _x} foreach _throwableValues;
		if (count _throwableValues > 0) then {
			_groupThrowables = _groupThrowables / (count _throwableValues);
			_groupThrowables = [_groupThrowables,1] call BIS_fnc_cutDecimals;
		};


		
		private _groupFuel = 0;
		if (count _fuelValues > 0) then {
			{_groupFuel = _groupFuel + _x} foreach _fuelValues;
			_groupFuel = _groupFuel / (count _fuelValues);
			_groupFuel = [_groupFuel,1] call BIS_fnc_cutDecimals;
		};






		private _groupStamina = 0;
		//systemchat str _staminaValues;
		if (count _staminaValues > 0) then {
			{
				_groupStamina = _groupStamina + _x;
			} foreach _staminaValues;
			//_groupStamina = 1 - (_groupStamina / (count _staminaValues)); //-- convert fatigue to stamina
		};
		
		//-- set images and text(findDisplay _a3c_dsp displayCtrl 11001) ctrlSetText _groupID;
		{(findDisplay _a3c_dsp displayCtrl _x) ctrlSetText _groupID;} foreach [11001,800713];
		(findDisplay _a3c_dsp displayCtrl 11002) ctrlSetText _groupIcon;
		(findDisplay _a3c_dsp displayCtrl 11003) ctrlSetText _unitSize;
		(findDisplay _a3c_dsp displayCtrl 11004) ctrlSetText _location;
		(findDisplay _a3c_dsp displayCtrl 11005) ctrlSetText _currentTask;

		//_barControls = [_groupDamage_MAN,_groupMagazines_Man_Primary,_groupThrowables,_groupFuel];
		_macroIndex = 1;

		_fnc_createProgressMacro = {
			params ["_macroIndex","_descriptionText","_progress","_a3c_dsp"];
			//-- adjust parent
			if (_macroIndex > 3) then { //-- first three extra bars do not require resize!
				{
					_ctrl = (findDisplay _a3c_dsp displayCtrl _x);
					_ctrlPos = ctrlPosition _ctrl;
					_ctrlPosH = (_ctrlPos select 3) + (1.5 * (0.021 / (getResolution select 5)));
					_ctrlPos set [3,_ctrlPosH];
					if (_foreachindex == 0 && {_a3c_dsp == 100040}) then {
						//-- adjust parent Y
						_ctrlPosY = (_ctrlPos select 1) - (0.75 * (0.021 / (getResolution select 5)));
						_ctrlPos set [1,_ctrlPosY];
					};
					_ctrl ctrlSetPosition _ctrlPos;
					_ctrl ctrlCommit 0;
				} foreach [A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT,11014,11015];
			};
			

			//-- generate ctrl positions
			_ctrlPosBar = 
			[
				(0.00800027 - 0.002) * safezoneW,
				(0.136011 * safezoneH) + (_macroIndex * (1.5 * (0.021 / (getResolution select 5)))),
				0.0800031 * safezoneW,
				0.0085007 * safezoneH
			];
			
			_ctrlPosText = 
			[
				-3.81485e-008 * safezoneW,
				(_ctrlPosBar select 1) - ( 0.021 / (getResolution select 5)),
				0.0800031 * safezoneW,
				0.021 / (getResolution select 5)
			];

			//-- create new progress bar macro
			_bg_ProgressBar  = (findDisplay _a3c_dsp) ctrlCreate ["RscPicture",12003 + _macroIndex + 2, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
			_bg_ProgressBar ctrlSetPosition _ctrlPosBar;
			_bg_ProgressBar ctrlSetText "#(argb,8,8,3)color(0.5,0.5,0.5,0.5)";

			
			_actualProgressBar  = (findDisplay _a3c_dsp) ctrlCreate ["RscProgress",12003 + _macroIndex + 1, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
			_actualProgressBar ctrlSetPosition _ctrlPosBar;
			//_actualProgressBar ctrlSetText "#(argb,8,8,3)color(1,1,1,1)";
			
			_progressCol = switch (true) do {
				case (_progress <= 0.3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_Color_setOpacity};
				case (_progress < 0.7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_Color_setOpacity};
				//case (_progress == 0) : { [A3C_UI_COLOR_RED,0.1] call A3C_UI_Color_setOpacity};
				default {[0,1,0,0.6]};
			};
			
			//_sText = parseText "First line<img image=\a3\ui_f\data\Map\Markers\Military\dot_ca.paa /><br />Second line";

			//if (_progress == 0) then {
			//	_progress = 1;
			//};
			_actualProgressBar progressSetPosition _progress;
			_actualProgressBar ctrlSetTextColor _progressCol; //;
			
			//_toolTip = "Turns out...\n Progressbars have tooltips...\nand those tooltips...\ncan have linebreaks!";
			//_actualProgressBar ctrlSetTooltip _toolTip;
			//_actualProgressBar ctrlSetTooltipColorBox _progressCol;
			//_actualProgressBar ctrlSetTooltipColorShade [1,1,1,0.3];

			_barTextCtrl = (findDisplay _a3c_dsp) ctrlCreate ["A3C_RscText_GroupDashboard",12003 + _macroIndex, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT]; //--12003 is the 'ammunition'-bar idc, we build up from here
			_barTextCtrl ctrlSetText _descriptionText;
			
			_barTextCtrl ctrlSetPosition _ctrlPosText;

			if (_progress == 0) then {
				_barTextCtrl ctrlSetTextColor [1,0,0,1]; //([A3C_UI_COLOR_RED,0.9] call A3C_UI_Color_setOpacity);
			};
			{_x ctrlCommit 0} foreach [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			_macro = [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			A3C_Radial_DashBoard_ExtraControls = A3C_Radial_DashBoard_ExtraControls + _macro;
			_macro
			
		};

		//-- set fixed Progress Bars
		{
			_txtctrl = switch (_foreachIndex) do {
				case (0) : {findDisplay _a3c_dsp displayCtrl 12000};
				case (1) : {findDisplay _a3c_dsp displayCtrl 12002};
			};
			_ctrl = switch (_foreachIndex) do {
				case (0) : {findDisplay _a3c_dsp displayCtrl 12001};
				case (1) : {findDisplay _a3c_dsp displayCtrl 12003};
			};
			_progressCol = switch (true) do {
				case (_x <= 0.3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_Color_setOpacity};
				case (_x < 0.7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_Color_setOpacity};
				default {[0,1,0,0.6]};
			};
			private _prog = _x;
			if (_prog == 0) then {
				_txtctrl ctrlSetTextColor [1,0,0,1]; //([A3C_UI_COLOR_RED,0.9] call A3C_UI_Color_setOpacity);
			};
			_ctrl progressSetPosition _prog;
			_ctrl ctrlSetTextColor _progressCol;
		} foreach [_groupDamage_MAN]; //,

		
		
		//-- HEALTH: SHow vehicle health for groups with any units in vehicle (warning: will consider drivers and cargo groups)
		if ({!isnull objectParent _x} count units _group > 0) then {							

			//-- >> create VEHICLE DAMAGE progress macro
			_macro = [_macroIndex,"Health (Vehicles)",_groupDamage_VEHICLE,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			
			if ({count (weapons _x select {_wpn = _x; {_x in toLower _wpn} count ["horn","smoke","laser"] == 0}) > 0} count _vehicles > 0) then {
				
				//-- >> create VEHICLE MAG progress macro
				_macro = [_macroIndex,"Ammo (Vehicles)",_groupMagazines_Vehicle,_a3c_dsp] call _fnc_createProgressMacro;
				_macroIndex = _macroIndex + 1;
				
				if ({count (getPylonMagazines _x) > 0} count _vehicles > 0) then {
					
					//-- >> create VEHICLE PYLON progress macro
					_macro = [_macroIndex,"Pylons",_groupPylons_Vehicle,_a3c_dsp] call _fnc_createProgressMacro;
					_macroIndex = _macroIndex + 1;
				};
			};	
		};
		
		if ({isNull objectParent _x OR {(assignedVehicleRole _x) select 0 == "cargo"}} count units _group > 0) then {
		
			//-- >> create group Magazines progress macro
			_macro = [_macroIndex,"Mags  (Soldiers)",_groupMagazines_Man_Primary,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			//-- >> create THROWABLES progress macro
			_macro = [_macroIndex,"Throwables",_groupThrowables,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;

			if ({(secondaryWeapon _x) isKindOf ["Launcher", configFile >> "CfgWeapons"]} count units _group > 0) then {
				//-- >> create LAUNCHER progress macro
				_macro = [_macroIndex,"Launchers",_groupMagazines_Man_Secondary,_a3c_dsp] call _fnc_createProgressMacro;
				_macroIndex = _macroIndex + 1;
			};

			//-- some units are on foot >> create STAMINA progress macro
			_macro = [_macroIndex,"Stamina",_groupStamina,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;
		};
		//systemchat str [_a3c_dsp];
		if ({!isNull objectParent _x && {_x == driver vehicle _x}} count units _group > 0) then {
			//-- some units are NOT on foot 
			//-- >> create FUEL progress macro
			_macro = [_macroIndex,"Fuel",_groupFuel,_a3c_dsp] call _fnc_createProgressMacro;
			_macroIndex = _macroIndex + 1;		
		};

		//-- Medical / Repair Icons:
		_supportButtons = 0;
		_supportButtonBasePos =
		[
			0.150315 * safezoneW,
			3.09064e-006 * safezoneH,
			0.0159271 * safezoneW,
			0.0340016 * safezoneH
		];
		
		if (count ([units _group] call A3C_FINDMEDICS) > 0) then {
			_healingCapableIcon  = (findDisplay _a3c_dsp) ctrlCreate ["RscPicture",13000, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
			_healingCapableIcon ctrlSetPosition _supportButtonBasePos;
			_healingCapableIcon ctrlSettext "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
			_healingCapableIcon ctrlSetTextColor [1,1,1,0.6];
			_healingCapableIcon ctrlSetTooltipColorBox [1,1,1,0.3]; //[0,1,0,0.6];
			_healingCapableIcon ctrlSetTooltipColorShade [1,1,1,0.3];
			_healingCapableIcon ctrlSetToolTip "Units in this group are capable of healing";
			_healingCapableIcon ctrlCommit 0;
			_supportButtons = 1;
		};
		if ({[_x] call A3C_canUnitRepair} count units _group > 0) then {
			if (_supportButtons == 1) then {
				//_supportButtonBasePos set [0,0.134387 * safezoneW];
				_supportButtonBasePos set [1,(3.09064e-006 * safezoneH) + (0.0340016 * safezoneH)];
			};
			_repairingCapableIcon  = (findDisplay _a3c_dsp) ctrlCreate ["RscPicture",13001, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
			_repairingCapableIcon ctrlSetPosition _supportButtonBasePos;
			_repairingCapableIcon ctrlSettext "A3C_CORE\ui\pictures\icon_menu_action_repair_noBG.paa"; // "\a3c_ui\menu\icon_menu_action_repair.paa";
			_repairingCapableIcon ctrlSetTextColor [1,1,1,0.6];
			
			_repairingCapableIcon ctrlSetToolTip "Units in this group are capable of repairing";
			_repairingCapableIcon ctrlSetTooltipColorBox [1,1,1,0.3];
			_repairingCapableIcon ctrlSetTooltipColorShade [1,1,1,0.3];

			
			_repairingCapableIcon ctrlCommit 0;
		};
		
		
		//-- create Structured text
		_structuredVehicles = [];
		_structuredUnits = [];

		{
			_add = true;
			_vehicleName = typeOf _x; //getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
			{
				if (_vehicleName == _x select 0) then {
					_x set [1,(_x select 1) + 1];
					_add = false;
				};
			} foreach _structuredVehicles;
			if (_add) then {
				_structuredVehicles pushBack [_vehicleName,1];
			};
		} foreach _vehicles;
		{
			_add = true;
			_vehicleName = typeOf _x; //getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
			{
				if (_vehicleName == _x select 0) then {
					_x set [1,(_x select 1) + 1];
					_add = false;
				};
			} foreach _structuredUnits;
			if (_add) then {
				_structuredUnits pushBack [_vehicleName,1];
			};
		} foreach (units _group);

		_structuredText = ""; 
		if (count _structuredVehicles > 0) then {
			_structuredText = "<br/>";
			_structuredText = "<t size='.7' align='left'>VEHICLES: </t>";
			{
				_vehicleClass = _x select 0;
				_amount = _x select 1;
				_str = format 
				[
					
					"<br/> <img align='left' image='%1'/> <t size='.6' align='left'>%2 (%3x) </t>",
					getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "picture"),
					getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "displayName"),
					_amount
				]; //
				_structuredText = _structuredText + _str;
			} foreach _structuredVehicles;
			_structuredText = _structuredText + "<br/>";
		};
		_structuredText = _structuredText + "<t size='.7' align='left'>UNITS: </t><br/>";
		{
			_vehicleClass = _x select 0;
			_amount = _x select 1;
			
			_str = format 
			[
				"<t size='.6' align='left'>%1 (%2x)</t>",
				getText (configFile >> "CfgVehicles" >>  _vehicleClass >> "displayName"),
				_amount
			];
			if (_foreachIndex < (count _structuredUnits - 1)) then {
				_str = _str + "<t size='.6' align='left'>, </t>";
			};
			if ((_foreachIndex + 1) % 2 == 0) then {
				_str = _str + "<br/>";
			};
			_structuredText = _structuredText + _str;
		} foreach _structuredUnits;

		_structuredText = parseText _structuredText; 
		(findDisplay _a3c_dsp displayCtrl 11014) ctrlSetStructuredText _structuredText;



		(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow true;

	} else {
		(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
	};
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

A3C_RADIAL_CloseDisplay = {
	showHud ([true]  + (shownhud select [1,10]));
	(findDisplay 100040) closeDisplay 0;
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

	//if (true) exitWith {};


	{(findDisplay 100040 displayCtrl _x) ctrlShow false} foreach [8071,8096,8097,8098,8099,9000];


	//-- no need to reset formation stuff. WHen switched, RD_UNITS is [] anyways
	//A3C_RADIAL_HOVER = false;
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
		[] call A3C_GREN_VISUAL;

		(findDisplay 100040 displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;

	} else {
		showHud ([true] + (shownhud select [1,10]));

		[] call A3C_Radial_DashBoard;

		

		(findDisplay 100040 displayCtrl 21000) ctrlShow false;
		(findDisplay 100040 displayCtrl 21001) ctrlShow false;
		

		//(findDisplay 100040 displayCtrl 8005) ctrlSetText "SELECT UNIT";

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

		//[] call A3C_TOGGLE_GOCODE_CTRLS;
		//[] call A3C_RD_LABEL_SELECTORS;
		
	};

	(findDisplay 100040 displayCtrl 8095) ctrlShow false; //-- teamcolor listbox - has to happen after UNIT SELECTOR group is opened
	[100040] call A3C_MAPTAB_TREE_LABEL; 
};





A3C_HCALLGROUPS_ORGANIZED = {
	private _hcAll = +A3C_HCALLGROUPS_Current;
	_hcAll = [_hcAll,[],{vehicle leader _x distance2D player},"ASCEND"] call BIS_fnc_sortBy;
	_closestUnits = _hcAll select [0,4];
	_hcAll = _hcAll - _closestUnits;
	_tankGroups = [];
	_infantryGroups = [];
	_wheeledGroups = [];
	_heliGroups = [];
	_jetGroups = [];
	_boatGroups = [];
	_staticGroups = [];
	{
		_leaderVic = vehicle leader _x;
		switch (true) do {
			case (_leaderVic isKindOf "MAN") : {_infantryGroups pushBack _x};
			case (_leaderVic isKindOf "CAR") : {_wheeledGroups pushBack _x};
			case (_leaderVic isKindOf "SHIP") : {_boatGroups pushBack _x};
			case (_leaderVic isKindOf "TANK") : {_tankGroups pushBack _x};
			case (_leaderVic isKindOf "HELICOPTER") : {_heliGroups pushBack _x};
			case (_leaderVic isKindOf "PLANE") : {_jetGroups pushBack _x};
			case (_leaderVic isKindOf "STATICWEAPON") : {_staticGroups pushBack _x};
		};
	} foreach _hcAll;

	_hcAll = _closestUnits + _infantryGroups + _staticGroups + _wheeledGroups + _boatGroups + _tankGroups + _heliGroups + _jetGroups;
	_hcAll 
};

	
A3C_UI_RADIAL_TOGGLE_LEFT_EXT = {
	params ["_mode"];
	//systemchat str [_mode,A3C_RD_BOOL_UNITS,!(ctrlShown (findDisplay 100040 displayCtrl 8071))];
	
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
				[0] call A3C_MAPTAB_RESIZE_TEAMCOLORS_Y;
				[100040,8071] execFSM "A3C_CORE\FSM\A3C_MON_RADIAL.fsm";

				//[] call A3C_RD_LABEL_SELECTORS;
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



A3C_HC_MENU_REFERENCE_UNITS = [];
A3C_RD_LABEL_SELECTORS = { //~~ currently unused
	
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
	private _unitArray = A3C_RD_UNITS; //if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {A3C_RD_UNITS} else {A3C_HCALLGROUPS_Current};

	private _referenceArray1 = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {((profileNamespace getvariable "A3C_GROUPUNITS") - [player])} else {_r = A3C_HCALLGROUPS_Current_ORGANIZED; A3C_HC_MENU_REFERENCE_UNITS = _r; _r};
	private _referenceArray2 = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {(profileNamespace getvariable "A3C_GROUPUNITS")} else {_referenceArray1};

	_showHOLDCONT = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {true} else {false};
	for "_i" from 8097 to 9000 do {
		(findDisplay 100040 displayCtrl _i) ctrlShow _showHOLDCONT;
	};



	/*
	if !(isnull (findDisplay 100020)) then {
		_a3c_dsp = 100020;
		_sub = 8000;
		_from = 7025;
		_to = 7040;
	};
	if !(isnull (findDisplay 100030)) then {
		_a3c_dsp = 100030;
		_sub = 8000;
		_from = 7025;
		_to = 7040;
	};
	for "_i" from _from to _to do {
		call compile format ["(findDisplay _a3c_dsp displayCtrl %1) ctrlShow false;",_i];
	};
	*/
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
				//systemchat str _u;
				//_op = if (_u getvariable ["A3C_HOLD",false]) then {0.3} else {0.5};
				//_mC = if (_u getvariable ["A3C_HOLD",false]) then {0.5} else {1};

				_backCol = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {[_u] call A3C_GET_UB_COLOR} else {[A3C_UI_COLOR_BLUE,0.8] call A3C_UI_Color_setOpacity};

				//if (_u getvariable ["A3C_HOLD",false]) then { //~~ Experiment: mix more white into color
				//	_backCol = [0.5,0.5,0.5,_op];
				//	{
				//		if (_forEachIndex < 3) then {
				//			_x = (_x * 1.2) min 1;
				//		};
				//	} foreach _backCol;
				//};
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
				["ROE",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
			};
		};
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

A3C_RADIALMODE = "";

A3C_RADIAL_BTN_FNC_RING_INNER = { //-- the inner ring functions. must assign fncs and images to buttons
	private ["_bv"];

	_mode = _this select 0;
	_btn = if ((count _this) > 1) then {(_this select 1)} else {-1};
	_shift = if ((count _this) > 2) then {(_this select 2)} else {false};
	_doToggle = if ((count _this) > 3) then {(_this select 3)} else {true};
	//systemchat str [_btn,A3C_RADIAL_HOVER,_mode];
	//systemchat str _doToggle;
	//systemchat str _mode;


	A3C_RD_BOOL_UNITS = true;
	
	//-- exit if fnc-area was defined
	if (!(_mode == 'FORM') && !(A3C_RADIAL_HOVER) && (_btn == -1)) exitwith {};

	if (_mode == 'FORM' && {A3C_CURRENT_COMMAND_LEVEL == "SQUAD"}) then {A3C_RADIAL_HOVER = true} else {A3C_RADIAL_HOVER = false};
	if !(_mode == "FORM") then {
		playsound "ReadOutHideClick1"; //"A3C_MenuSound1"
	};
	_bv = "";
	//systemchat str time;
	private _doRefreshGroupSelected = true;
	{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;

	[] call A3C_RADIAL_RESET_DYNAMIC_BTNS; //-- reset outer ring buttons


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
		//case ("GRENMAIN") : {
		//	BV_GREN = 1;
		//	[2] call A3C_GREN_DATA;
			//systemchat str time;
		//};
		case ("RINGFORM") : {
			_bv = "BV_RINGFORM";
			A3C_RADIALMODE = 'RINGFORM';
			if (_btn == 1) exitWith {
				//-- RMB on inner circle formation button >> adjust group formation direction
				(group player) setFormDir (getDir (vehicle player));
				
				player groupradio "VehicleWatchPos"	
			};
			//if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
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


					//////////      
				} else {
					BV_RINGFORM = 0;
					[false] call A3C_UI_RADIAL_TOGGLE_OUTER_RING;
				};
			//} else {
				//HC STUFF
			//};

		};
		case ("GRENADE") : {
			//BV_GREN = 1;

			if (A3C_RADIALMODE != "GRENADE") then {
				BV_GREN = 0;
			};
			//player sidechat str [BV_GREN,A3C_RADIALMODE];
			_bv = "BV_GREN";
			//A3C_RADIAL_HOVER = false;
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
			//systemchat str BV_GREN;
		};
		case ("ACTIONS") : {
			//A3C_RADIAL_HOVER = false;
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
					[100040,A3C_RD_UNITS,A3C_UI_RADIAL_BTN_DATA_OUTER_RING] call A3C_UI_SHARED_DISTRIBUTE_MENU_ACTIONS;

					//systemchat str A3C_DYNAMIC_BUTTON_ACTIONS;
					_outerRingBackGroundIDs = ["Placeholder","Top","Right","bottom"];
					for "_i" from 8001 to 8004 do {
						_ind = _i - 8000;
						if ( _ind <= ((ceil ((count A3C_DYNAMIC_BUTTON_ACTIONS) / 4) ) min 3)    ) then {
							//if (_doToggle) then {
								(findDisplay 100040 displayCtrl _i) ctrlShow true; //-- outer circle backgroud shown
								(findDisplay 100040 displayCtrl _i) ctrlSetText (format ["A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",_outerRingBackGroundIDs select _ind]);
							//};
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
					BR_A3C_DISABLE_RADIAL = true;
					[] call A3C_RADIAL_CloseDisplay;
					A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3c_ui\hud\icon_HUD_movePos.paa"; //"\a3\ui_f\data\IGUI\Cfg\Cursors\waypointMark_ca.paa";
					A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_BLUE,0] call A3C_UI_Color_setOpacity;
					A3C_UI_HUD_3D_TAG_reposition = true;
					[
						46,
						'SPACE',
						{count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""}},
						{
							if (count A3C_RD_UNITS > 1) then {
								
								private _units = +(A3C_RD_UNITS);
								[_units,A3C_UI_HUD_3D_TAG_ICON_POS] spawn A3C_FNCS_CONVOY_MULTIGROUP;
							} else {
								{
									private _gp = _x;
									private _wpParams = [_gp,A3C_UI_HUD_3D_TAG_ICON_POS];
									private _eligibleForBuildingSearch = A3C_UI_HUD_3D_TAG_ICON_TYPE == "a3c_ui\markers\building.paa"; //({!isNull objectParent _x && {(assignedVehicleRole _x) select 0 != "cargo"}} count (units _gp) == 0);
									if (_eligibleForBuildingSearch) then {// && {cursorTarget isKindOf "HOUSE" && {([cursortarget] call MCSS_fnc_countBPos) > 0}}) then {
										_wpParams set [1, cursorTarget buildingPos 0];
										_wpParams set [2,[]];
										_wpParams = _wpParams +
										[
											"MOVE",
											[0,0,"AUTO","AUTO","NORMAL","CLEARBUILDING"]
										];
									};
									_wpParams call A3C_HC_ADD_WP;
								} foreach A3C_RD_UNITS;
							};
						},
						{
							private _iconType = "\a3c_ui\hud\icon_HUD_movePos.paa";
							A3C_UI_HUD_3D_TAG_reposition = false;
							//-- mini flicker
							for "_i" from 1 to 2 do {
								A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								sleep 0.1;
								A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
								sleep 0.1;
							};
							if (BR_A3C_DISABLE_RADIAL) then {
								//-- Radial key not released - reIssue the icon for repeated orders
								A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
								A3C_UI_HUD_3D_TAG_reposition = true;
							} else {
								//-- Radial key released - abort
								A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								A3C_UI_HUD_3D_TAG_reposition = false;
							}

							
						},
						false
					] call A3C_UI_RADIAL_ADD_EH_MACROS;
					[
						46,
						'RADIAL',
						{true},
						{},
						{
							//-- here, we need to remove the keybind upon release of TAB, not the main thingy
							(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
							if (A3C_UI_HUD_3D_TAG_reposition) then {
								A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								A3C_UI_HUD_3D_TAG_reposition = false;
							};
						},
						true
					] call A3C_UI_RADIAL_ADD_EH_MACROS;

					
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
			//A3C_RADIAL_HOVER = false;
			if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {

				// hint str _btn;
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
						// ((findDisplay 100040) displayCtrl 8003) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom_Var1.paa";
						// ((findDisplay 100040) displayCtrl 8004) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Left.paa";

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
						// SYSTEMCHAT STR time;


						// for "_i" from 10016 to 10023 do {
						// 	((findDisplay 100040) displayCtrl _i) ctrlShow true;
						// 	if (_i % 2 == 0) then {
						// 		//-- ICONS

						// 		private _col = [0,0,0,0];

						// 		_col = switch _i do {
						// 			case (10016) : {[0.5,0,0,0.4]};
						// 			case (10018) : {[1,1,0,0.4]};
						// 			case (10020) : {[1,1,1,0.4]};
						// 			case (10022) : {[0,1,0,0.4]};
						// 		};
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetText _combatModeIcon;
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetTextColor _col;

						// 	} else {
						// 		//-- BUTTONS
						// 		private _toolTip = switch _i do {
						// 			case (10017) : {"ROE: Fire at will, engage at will"};
						// 			case (10019) : {"ROE: Fire At Will"};
						// 			case (10021)  : {"ROE: Hold fire, engage at will"};
						// 			case (10023) : {"ROE: Hold fire, defend only"};
						// 		};
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetTooltip _toolTip;
						// 	};
						// };


						// //-- BOTTOM RING - SPLIT USAGE
						// {(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [10024,10025,10030,10031]; //-- used buttons (1 and 4)
						// {(findDisplay 100040 displayCtrl _x) ctrlShow false} foreach [10026,10027,10028,10029]; //-- unused buttons (2 and 3)
						// //-- combat mode: blue
						// ((findDisplay 100040) displayCtrl 10024) ctrlSetText _combatModeIcon;
						// ((findDisplay 100040) displayCtrl 10024) ctrlSetTextColor [0.17,0.86,0.92,0.6];
						// ((findDisplay 100040) displayCtrl 10025) ctrlSetTooltip "ROE: Never Fire";
						// //-- behaviour: careless
						// ((findDisplay 100040) displayCtrl 10030) ctrlSetText _behaviorIcon;
						// ((findDisplay 100040) displayCtrl 10030) ctrlSetTextColor [0.17,0.86,0.92,0.6];
						// ((findDisplay 100040) displayCtrl 10031) ctrlSetTooltip "BEHAVIOR: CARELESS";


						// //-- LEFT RING - BEHAVIOUR
						// for "_i" from 10032 to 10039 do {
						// 	((findDisplay 100040) displayCtrl _i) ctrlShow true;
						// 	if (_i % 2 == 0) then {
						// 		//-- ICONS
						// 		private _col = [0,0,0,0];
						// 		private _ico = _behaviorIcon;
						// 		_col = switch _i do {
						// 			case (10032) : {[0,1,0,0.4]};
						// 			case (10034) : {[1,1,1,0.4]};
						// 			case (10036) : {[1,1,0,0.4]};
						// 			case (10038) : {[0.5,0,0,0.4]};

						// 		};
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetText _ico;
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetTextColor _col;
						// 	} else {
						// 		//-- BUTTONS
						// 		private _toolTip = switch _i do {
						// 			case (10033) : {"BEHAVIOR: STEALTH"};
						// 			case (10035) : {"BEHAVIOR: SAFE"};
						// 			case (10037)  : {"BEHAVIOR: AWARE"};
						// 			case (10039) : {"BEHAVIOR: COMBAT"};
						// 		};
						// 		((findDisplay 100040) displayCtrl _i) ctrlSetTooltip _toolTip;
						// 	};
						// };

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
								// {[_x,["COMBATMODE","RED"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
								// player groupradio "SentOpenFireInCombat";
								// systemchat "open diag";


								


								[] call A3C_UI_Radial_SQ_ROE_MAIN;





							}
						];
						// A3C_OUTER_RING_BTN_fnc_6 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentOpenFire";
						// 	}
						// ];
						// A3C_OUTER_RING_BTN_fnc_7 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["COMBATMODE","WHITE"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentHoldFire";
						// 		player groupradio "SentEngageNoTarget";  

						// 	}
						// ];
						// A3C_OUTER_RING_BTN_fnc_8 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["COMBATMODE","GREEN"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentHoldFire";
						// 	}
						// ];
						// //-- Bottom Ring: Split Functions
						// A3C_OUTER_RING_BTN_fnc_9 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentHoldFire";
						// 	}
						// ];
						// //-- [] skipping buttons 10 & 11
						// A3C_OUTER_RING_BTN_fnc_12 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["BEHAVIOR","CARELESS"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentBehaviourSafe";
						// 	}
						// ];

						// //-- Right Ring: Combat Modes
						// A3C_OUTER_RING_BTN_fnc_13 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["BEHAVIOR","STEALTH"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentBehaviourStealth";
						// 	}
						// ];
						// A3C_OUTER_RING_BTN_fnc_14 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["BEHAVIOR","SAFE"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentBehaviourSafe";
						// 	}
						// ];
						// A3C_OUTER_RING_BTN_fnc_15 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["BEHAVIOR","AWARE"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentBehaviourAware";
						// 	}
						// ];
						// A3C_OUTER_RING_BTN_fnc_16 =
						// [
						// 	[],
						// 	{
						// 		{[_x,["BEHAVIOR","COMBAT"]] call MCSS_fnc_orderIndividual} foreach A3C_RD_UNITS;
						// 		player groupradio "SentBehaviourCombat";
						// 	}
						// ];




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
			//A3C_RADIAL_HOVER = false;

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
						
						//if ((currentVisionMode player) == 1) then {
						//	{((findDisplay 100040) displayCtrl _x) ctrlSetTextColor [0,0.3,0.6,0.5]} foreach [10025,8049,8051,8053];
						//};
						((findDisplay 100040) displayCtrl 10016) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_resetWatchdir.paa";
						((findDisplay 100040) displayCtrl 10017) ctrlSetTooltip "RESET WATCHDIR";
						((findDisplay 100040) displayCtrl 10018) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
						//if (({getdammage _x > 0.1} count (units group player)) > 0) then {
						if (profileNameSpace getVariable ["A3C_AUTOMEDIC", false]) then {
							//((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [0,1,0,0.6];
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
										//if (_overRide) then {
										// (group player) setVariable ["A3C_MEDICS_LB", []] ];
										// (group player) setVariable ["A3C_PATIENTS_LB", []] ];
										//};
										BV_CBMODE = 0;
										//-- no Shift: bring up healing menu
										if (BV_MEDICAL == 0) then {
											BV_MEDICAL = 1;
											A3C_LBR_1 = "MEDICAL";
											//systemchat str _override;
											//if (_overRide) then {
												(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
												{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
												// systemchat "MEDICAL LB";
												["MEDICAL"] call A3C_LABEL_LB;
												
											//};
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
										//((findDisplay 100040) displayCtrl 10018) ctrlSetTextColor [0,1,0,0.6];
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
									//systemchat str _override;
									//if (_overRide) then {
										//-- open right extension: combat mode
										(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
										{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
										["CBMODE"] call A3C_LABEL_LB;
									//};
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
									//player say3d "A3C_reArm";
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
				_color = [1,1,1,0.5]; //momo

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

			//A3C_RADIAL_HOVER = false;


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
						["STANCE",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
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
								//_units = call compile _units;

								['C'] call A3C_ACTIVATEGOCODE;

							}
						];
						A3C_OUTER_RING_BTN_fnc_8 =
						[
							str (A3C_RD_UNITS),
							{
								params ["_btnData","_units"];
								_btnData params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];
								//_units = call compile _units;

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

				if ( (   {count (_x getvariable ["A3C_STROBE",[]]) > 0 } count _grunts > 0)   OR {{{_item = _x; [_item] call A3C_isIRMagazine } count (magazines _x) > 0} count _grunts > 0}) then {
					_itemCategories pushBack "IR_STROBE";
				};

				if ({{_item = _x; [_item] call A3C_isNVGoggles } count (assigneditems _x + items _x) > 0} count _grunts > 0) then {
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

					if (_add && {{[_x,_itemString] call A3C_doesUnitHaveWeaponItem} count _grunts > 0}) then {
						_itemCategories pushBack _itemString;
					};

				} foreach ["FLASHLIGHT","LASER","SILENCER"];

				if (!("SILENCER" in _itemCategories) && {{count ([_x,"MuzzleSlot",0,(currentWeapon _x)] call MCSS_fnc_getWeaponItems) > 0} count A3C_RD_UNITS > 0}) then {
					_itemCategories pushBack "SILENCER";
				};


				//systemchat str _itemCategories;

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
								//

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


									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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
															[_u,_st] spawn A3C_UNIT_STROBE_LOOP;

														};
													};
												} foreach (magazines _u);
											};
										};
									} foreach _units;


									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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

								if ({{_item = _x; [_item] call A3C_isNVGoggles } count (assigneditems _x) > 0} count A3C_RD_UNITS > 0) then {
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

										if ({{_item = _x; [_item] call A3C_isNVGoggles } count (assigneditems _x) > 0} count A3C_RD_UNITS > 0) then {

											_nvgs = "";
											{
												if ([_x] call A3C_isNVGoggles ) exitWith {
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
												if ([_x] call A3C_isNVGoggles ) exitWith {
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


									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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

										//if ({_x isFlashlightOn (currentWeapon _x)} count A3C_RD_UNITS > 0) then {
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
														//_unit setbehaviour "COMBAT";
														[_unit,["BEHAVIOUR","COMBAT"]] call MCSS_fnc_orderIndividual;
														_unit enablegunlights "ForceOn";
														_unit setVariable ["A3C_isGunPoiterSlotOn","FLASHLIGHT"];
													};
												};
											};
										};
									} foreach _units;
									player groupradio _phrase; 



									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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

								//if ({_x isIRLaserOn (currentWeapon _x)} count A3C_RD_UNITS > 0) then {
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

										//if ({_x isIRLaserOn (currentWeapon _x)} count A3C_RD_UNITS > 0) then {
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
												//systemchat str _sl;
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
														//_this playActionNow "dismountSide";
														_unit playActionNow "GestureHiC";
														sleep 1.2;
														//_unit setbehaviour "COMBAT";
														[_unit,["BEHAVIOUR","COMBAT"]] call MCSS_fnc_orderIndividual;
														(group _unit) enableIRLasers true;
														_unit setVariable ["A3C_isGunPoiterSlotOn","LASER"];
													};
												};
											};
										};

									} foreach _units;
									player groupradio _phrase; 
									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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

								if ({[_x,"SILENCER"] call A3C_doesUnitHaveWeaponItem} count (A3C_RD_UNITS - [player]) > 0) then {
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

										if ({[_x,"SILENCER"] call A3C_doesUnitHaveWeaponItem} count A3C_RD_UNITS > 0) then {
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
													//sleep 2.5;
													//_u playMoveNow "aidlpercmstpsraswrfldnon_ai";
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
													//if !(stance _u =="STAND") then {_u setunitPos "UP"; sleep 1};
													//sleep 2.5;
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

									//if (_btnImage != "") then {
										(findDisplay 100040 displayCtrl _buttonImgID) ctrlSetText _btnImage;
										(findDisplay 100040 displayCtrl _buttonClickerID) ctrlSetToolTip _toolTip;
									//};
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

					//["ITEMS"] call A3C_BTN_REINIT; //~~ DO NOT DO THIS! INSTEAD DO EVERYTHING RIGHT HERE
				} else {
					BV_ITEMS = 0;
				};

				/*
				A3C_OUTER_RING_BTN_fnc_10 =
				[
					str (A3C_RD_UNITS),
					{


					}
				];

				A3C_OUTER_RING_BTN_fnc_11 =
				[
					str (A3C_RD_UNITS),
					{
						params ["_btnData","_units"];
						_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
						_units = call compile _units;
						if (({(currentweapon _x) == (handGunWeapon _x)} count _units) > 0) then {
							{_x selectWeapon (primaryWeapon _x)} foreach _units;
							((findDisplay 100040) displayCtrl 9028) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa"; //((getText (configfile >> "CfgWeapons" >> (HandGunWeapon (_units select 0)) >> "picture")));
							((findDisplay 100040) displayCtrl 9029) ctrlSetToolTip "Switch To HandGun";
						} else {
							{_x selectWeapon (handgunWeapon _x)} foreach A3C_RD_UNITS;
							((findDisplay 100040) displayCtrl 9028) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle_switch.paa"; //((getText (configfile >> "CfgWeapons" >> (primaryWeapon (_units select 0)) >> "picture")));
							((findDisplay 100040) displayCtrl 9029) ctrlSetToolTip "Switch To Main Weapon";
						};
					}
				];

				A3C_OUTER_RING_BTN_fnc_12 =
				[
					str (A3C_RD_UNITS),
					{
						params ["_btnData","_units"];
						_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
						_units = call compile _units;
						_btnImage = "";

						{
							_u = _x;
							if (_mb == 1) then {
								if ((count (_u getvariable "A3C_STROBE")) > 0 ) then {
									_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
									_u spawn {
										sleep (random 1);
										deleteVehicle ((_this getvariable "A3C_STROBE") select 0);
										_this addmagazine ((_this getvariable "A3C_STROBE") select 1);
										_this setvariable ["A3C_STROBE",[],true];
									};
								};
							} else {
								if ((count (_u getvariable "A3C_STROBE")) == 0 ) then {
									{
										private ["_am","_array"];
										_it = _x;
										_am = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
										_array = "true" configClasses (configfile >> "CfgAmmo" >> _am >> "NVGMarkers");
										if (count _array > 0) exitwith {
											_btnImage = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
											[_u,_it] spawn {
												_u = _this select 0;
												_it = _this select 1;
												sleep (random 1);
												_u removeMagazine _it;
												_st = "NVG_TargetC" createVehicle getPos _u;
												_u setvariable ["A3C_STROBE",[_st,_it],true];
												[_u,_st] spawn A3C_UNIT_STROBE_LOOP;

											};
										};
									} foreach (magazines _u);
								};
							};
						} foreach ([player] + _units);
						if (_btnImage != "") then {
							(findDisplay 100040 displayCtrl 10030) ctrlSetText _btnImage;
						};
					}
				];
				*/
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

			//{((findDisplay 100040) displayCtrl _x) ctrlSetTextColor [1,1,1,0.6]} foreach [10016,10018,10020,10022];
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
						//systemchat str _classes;
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
												[A3C_RD_UNITS] call A3C_FINDVEHS;
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
						

						/*

						A3C_OUTER_RING_BTN_fnc_9 =
						[
							str (A3C_RD_UNITS),
							{
								//params ["_btnData","_units"];
								//_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
								A3C_RADIAL_VEH_KIND = "PLANE";
								[A3C_RD_UNITS] call A3C_FINDVEHS;
							}
						];
						A3C_OUTER_RING_BTN_fnc_10 =
						[
							str (A3C_RD_UNITS),
							{
								//params ["_btnData","_units"];
								//_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
								A3C_RADIAL_VEH_KIND = "HELICOPTER";
								[A3C_RD_UNITS] call A3C_FINDVEHS;
							}
						];
						A3C_OUTER_RING_BTN_fnc_11 =
						[
							str (A3C_RD_UNITS),
							{
								//params ["_btnData","_units"];
								//_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
								A3C_RADIAL_VEH_KIND = "TANK";
								[A3C_RD_UNITS] call A3C_FINDVEHS;
							}
						];
						A3C_OUTER_RING_BTN_fnc_12 =
						[
							str (A3C_RD_UNITS),
							{
								//params ["_btnData","_units"];
								//_btnData params ["_display","_mb","_sX","_sY","_shift","_ctrl","_alt"];
								A3C_RADIAL_VEH_KIND = "CAR";
								[A3C_RD_UNITS] call A3C_FINDVEHS; //bbb
							}
						];

						//ushushush
						for "_i" from 10008 to 10039 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow false;
						};
						for "_i" from 10024 to 10031 do {
							((findDisplay 100040) displayCtrl _i) ctrlShow true;
						};
						for "_i" from 8053 to 8068 do {
							(findDisplay 100040 displayCtrl _i) ctrlShow false;
						};
						
						//if ((currentVisionMode player) == 1) then {
						//	{((findDisplay 100040) displayCtrl _x) ctrlSetTextColor [0,0.3,0.6,0.5]} foreach [10025,8049,8051,8053];
						//};
						["VEHS"] call A3C_BTN_REINIT;
						*/
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
		/*
		case ("FORM") : {
			//-- 8032 is button!
			_bv = "BV_FORM";

			for "_i" from 10008 to 10031 do {
				((findDisplay 100040) displayCtrl _i) ctrlShow false;
			};
			for "_i" from 8053 to 8068 do {
				(findDisplay 100040 displayCtrl _i) ctrlShow false;
			};
			BV_MEDICAL = 0;
			BV_CBMODE = 0;
			{((findDisplay 100040) displayCtrl _x) ctrlShow false} foreach [8001,8002,8003,8004];
			if (BV_FORM == 0) then {
				((findDisplay 100040) displayCtrl 80311) ctrlShow false;
				if (_btn != -1) then {
					BV_FORM = 1;
				};
				
				for "_i" from 8033 to 8052 do {
					//if !(_i == 8033) then {
						((findDisplay 100040) displayCtrl _i) ctrlShow true;
					//};
				};

			} else {
				BV_FORM = 0;
				for "_i" from 10008 to 10039 do {
					((findDisplay 100040) displayCtrl _i) ctrlShow false;
				};
				for "_i" from 8032 to 8052 do {
					if !(_i == 8032) then {
						((findDisplay 100040) displayCtrl _i) ctrlShow false;
					};
				};
				((findDisplay 100040) displayCtrl 8033) ctrlShow false;
				((findDisplay 100040) displayCtrl 80311) ctrlShow true;
			};
		};
		*/

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
						_playerGrp selectLeader player; //_leader;
						deleteGroup _tempGrp;

						player doMove (position vehicle player);
						player moveTo (position vehicle player);
						player doFollow player;
						A3C_RD_UNITS commandFollow player;
					};
					
				} else {
					[(units group player) - [player]] call A3C_GROUP_RESET;
				};
			//} else {
			//	(groupselectedUnits player) spawn A3C_UNSTUCK;
			};
			//_btn = -1;
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
		//player commandChat str _btn;
	};
	if (_doRefreshGroupSelected) then {
		// systemchat 'group select swap';
		[] spawn {sleep 0.1; {player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS; };
	};
};

A3C_RADIAL_RESET_DYNAMIC_BTNS = {
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
		//(findDisplay 100040 displayCtrl _i) ctrlShow false;
		if (_i % 2 == 0) then {
			(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.6];
		//} else {
		//	(findDisplay 100040 displayCtrl _i) ctrlSetTooltip "";
		};
	};


};



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

[] call A3C_RADIAL_RESET_DYNAMIC_BTNS;



/*
A3C_LAYERFUNC = { //-- the outer ring button function

	systemchat 'yup';


	private ["_btn","_mB"];
	_btn = _this select 0;
	_mB = if (count _this > 1) then {_this select 1} else {0};
	_soundOn = if (count _this > 2) then {_this select 2} else {true};
	_mod = if (count _this > 3) then {_this select 3} else {[false,false,false]};
	_overRide = if (count _this > 4) then {_this select 4} else {true};
	if (_soundOn) then {playsound "A3C_MenuSound1"};
	_doRefreshgroupselected = true;
	//systemchat str _this;
	// str [_btn,_mb];
	switch (_btn) do {





		//-- from here until end, the buttons are all about vehicle boarding (Radial Right Extension buttons)
		case (13) : {
			if (A3C_RADIALMODE == "VEHS") then {
				if (_mb == 0) then {
					[0,"driver",A3C_BOARD_UNITS,A3C_TARGETVEH] call A3C_CREW;
					//A3C_BOARD_UNITS = A3C_RD_UNITS - A3C_BOARD_UNITS;
				} else {
					_d = (driver A3C_TARGETVEH);
					if (_d in units group player) then {
						if (!isPlayer _d) then {
							[_d] spawn MCSS_fnc_GetOut;
							A3C_BOARD_UNITS = [_d] + A3C_BOARD_UNITS;
							A3C_RD_UNITS pushbackUnique _d;
							player groupSelectUnit [_d,true];
							(findDisplay 100040 displayCtrl 8059) ctrlSetTextColor  [1,1,1,0.6];
						};
					};
				};
			} else {

			};

		};
		case (14) : {
			if (A3C_RADIALMODE == "VEHS") then {
				systemchat 'ay';
				if (_mb == 0) then {
					[0,"gunner",A3C_BOARD_UNITS,A3C_TARGETVEH] call A3C_CREW;
				} else {
					// NEEDS OPTIMIZATION
					{
						_vH = (assignedVehicleRole _x); //-- using assignedvehicleRole: we are checking the crew of a vehicle (roles assigned)
						if (_x == (gunner (vehicle _x))) then {
							(findDisplay 100040 displayCtrl 8061) ctrlSetTextColor  [1,1,1,0.6];
							[_x] spawn MCSS_fnc_GetOut;
							A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
						} else {
							if ((_vH select 0) in ["turret","cargo"]) then {
								if !(_x == (commander (vehicle _x))) then {
									_turrs = (allturrets [A3C_TARGETVEH,true]);

									if ((_vH select 1) in _turrs) then {
										_ind = [(_vH select 1),_turrs] call MCSS_fnc_GetArrayIndex;
										_turrs = "true" configClasses (configfile >> "CfgVehicles" >> (typeOf A3C_TARGETVEH) >> "Turrets");
										if (count _turrs > 0) then {
											if (A3C_TARGETVEH iskindof "air") then {
												if (_ind < count _turrs) then {
													if ( (getnumber (configfile >> "CfgVehicles" >> (typeof A3C_TARGETVEH) >> "Turrets" >> (configname (_turrs select _ind)) >> "hasgunner")) > 0) then {
														(findDisplay 100040 displayCtrl 8061) ctrlSetTextColor  [1,1,1,0.6];
														[_x] spawn MCSS_fnc_GetOut;
														A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
													};
												};
											} else {
												if ( (getnumber (configfile >> "CfgVehicles" >> (typeof A3C_TARGETVEH) >> "Turrets" >> (configname (_turrs select _ind)) >> "hasgunner")) > 0) then {
													(findDisplay 100040 displayCtrl 8061) ctrlSetTextColor  [1,1,1,0.6];
													[_x] spawn MCSS_fnc_GetOut;
													A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
												};
											};
										};
									};
								};
							};
						};
					} foreach crew A3C_TARGETVEH;
				};
			} else {

			};
		};
		case (15) : {
			if (A3C_RADIALMODE == "VEHS") then {
				if (_mb == 0) then {
					[0,"commander",A3C_BOARD_UNITS,A3C_TARGETVEH] call A3C_CREW;
				} else {
					{
						_vH = (assignedVehicleRole _x); //-- using assignedvehicleRole: we are checking the crew of a vehicle (roles assigned)
						if ((_vH select 0) == "commander") then {
							[_x] spawn MCSS_fnc_GetOut;
							(findDisplay 100040 displayCtrl 8063) ctrlSetTextColor  [1,1,1,0.6];
							A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
						};
						if ((_vH select 0) == "turret") then {
							_turr = _vH select 1;
							if (count _turr == 1) then {
								if !(_x == (gunner vehicle _x)) then {
									if (A3C_TARGETVEH isKindOf "AIR") then {
										if ((_turr select 0) == 0) then {
											//-- commander
											(findDisplay 100040 displayCtrl 8063) ctrlSetTextColor  [1,1,1,0.6];
											[_x] spawn MCSS_fnc_GetOut;
											A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;

										};
									} else {
										if !((_turr select 0) == 0) then {
											//-- commander
											(findDisplay 100040 displayCtrl 8063) ctrlSetTextColor  [1,1,1,0.6];
											[_x] spawn MCSS_fnc_GetOut;
											A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;

										};
									};

								};
							} else {
								if !(_x == (gunner vehicle _x)) then {
									(findDisplay 100040 displayCtrl 8063) ctrlSetTextColor  [1,1,1,0.6];
									[_x] spawn MCSS_fnc_GetOut;
									A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
								};
							};

						};
					} foreach crew A3C_TARGETVEH;
				};
			} else {

			};
		};
		case (16) : {
			if (A3C_RADIALMODE == "VEHS") then {
				if (_mb == 0) then {
					[0,"cargo",A3C_BOARD_UNITS,A3C_TARGETVEH] call A3C_CREW;
				} else {
					{
						private ["_act"];
						if (_x in units group player) then{
							_veh = vehicle _x;
							_vH = (assignedVehicleRole _x); //-- using assignedvehicleRole: we are checking the crew of a vehicle (roles assigned)
							_turr = [];
							if (count _vH > 1) then {
								_turr = _vH select 1;
							};
							_act = false;
							if ( (count _vH == 0) OR {(_vh select 0) == "cargo"}) then { //-- if role is cargo or EMPTY
								//(findDisplay 100040 displayCtrl 8065) ctrlSetTextColor  [1,1,1,0.6];
								[_x] spawn MCSS_fnc_GetOut;
								A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
								_act = true;
							} else {
								if (count _turr == 1) then {
									if !(_x == (gunner vehicle _x)) then {
										if ((_turr select 0) == 0) then {
											if !((vehicle _x) iskindof "AIR") then {
												//-- passenger
												[_x] spawn MCSS_fnc_GetOut;
												A3C_BOARD_UNITS = [_x] + A3C_BOARD_UNITS;
												_act = true;
											};
										};
									};
								};
							};

							if (_act) then {
								{
									_u = _x;
									if (_x in A3C_board_units) then {
										_vH1 = (assignedVehicleRole _u); //-- using assignedvehicleRole: we are checking the crew of a vehicle (roles assigned)
										_turr1 = if (count _vH1 > 0) then {_vH1 select 1} else {"A3C_PLACEHOLDER"}; //~~ ATTENTION: WAS THIS SUPPOSED TO BE _vH??
										if !((_vH1 select 0) == "cargo") then {
											if ((_vH1 select 0) == "Turret") then {
												if !(_x == (gunner vehicle _x)) then {
													if ((_turr select 0) == 0) then {
														_act = false;
													};
												};
											};
										};
									};
								} foreach ((crew _veh) - [_u]);
							};
							if (_act) then {
								(findDisplay 100040 displayCtrl 8065) ctrlSetTextColor  [1,1,1,0.6];
							};
						};
					} foreach crew A3C_TARGETVEH;
				};
			} else {

			};

		};

		case (17) : {
			if (A3C_RADIALMODE == "VEHS") then {
				A3C_BOARD_UNITS = [A3C_BOARD_UNITS,[],{(_x getvariable "A3C_FORMATION_INDEX")},"ASCEND"] call BIS_fnc_sortBy;
				if (_mb == 0) then {
					[] spawn {
						{

							if (_x in A3C_VEHROLES) then {
								_sc = [0,_x,A3C_BOARD_UNITS,A3C_TARGETVEH] call A3C_CREW;
								sleep 0.5;
							};
						} foreach ["driver","gunner","commander","cargo"];
					};
				} else {
					{
						(findDisplay 100040 displayCtrl _x) ctrlSetTextColor  [1,1,1,0.6];
					} foreach [8059,8061,8063,8065,8067];

					{
						if (_x in (units group player)) then {
							[_x] spawn MCSS_fnc_GetOut;
						};
					} foreach crew A3C_TARGETVEH;

					//{
					//	if ((A3C_TARGETVEH emptyPositions (_x select 0)) > 0) then {
					//		(findDisplay 100040 displayCtrl (_x select 2)) ctrlShow true;
					//	};
					//} foreach [["driver",8059,8060],["gunner",8061,8062],["commander",8063,8064],["cargo",8065,8066]];
				};
			} else {

			};

		};
	};
	if (_doRefreshgroupselected) then {
		[] spawn {
			{
				sleep 0.1;
				{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;
			} foreach [1,2];
		};
	};

};
*/

//

A3C_LABEL_LB = {
	private ["_isCategorySwitch"];
	
	// systemchat format ["LABEL LB, A3C_CurSel: %1", A3C_CurSel];
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

			// systemchat format ["test radial medical: %1", ""];

			private _medics_lb = (group player) getVariable ["A3C_MEDICS_LB", [] ];
			if (count _medics_lb == 1) then {
				_selectedMedic = (_medics_lb select 0);
				//systemchat str (name _selectedMedic);
			};
			private _patients_lb = (group player) getVariable ["A3C_PATIENTS_LB", [] ];
			if (count _patients_lb == 1) then {
				_selectedPatient = (_patients_lb select 0);
				//systemchat str (name _selectedPatient);
			};

			{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8055,8056,8057];
			{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
			//private _squadAI = (units player - [player]);
			//{
			//	_u = _x;
			//	if (({_it = _x; ({[_x,_it] call MCSS_fnc_isInString} count ["Medi","FirstAid","FAK","fieldDressing","morphine"] ) > 0} count items _u) == 0 ) then {
			//		_squadAI = _squadAI - [_u];
			//	};
			//} foreach _squadAI;
			//systemchat str time;

			private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
			(group player) setVariable ["A3C_MEDICS", _medics];
			private _multiMedic = (count _medics) > 1;
			
			if (_multiMedic) then {
				[["ALL MEDICS","",objnull,(findDisplay 100040 displayCtrl 8054),"A3C_CORE\ui\pictures\icon_menu_Medical.paa"]] call A3C_LB_ADD;
				(findDisplay 100040 displayCtrl 8054) lbSetColor [0, [0, 1, 0, 1]];
			};

			//_squadAI = [_squadAI,[],{(getNumber ( configFile >> "CfgVehicles" >> typeOf _x >> "attendant" ))},"DESCEND"] call BIS_fnc_sortBy;
			{
				//private _isMedic = getNumber ( configFile >> "CfgVehicles" >> typeOf _x >> "attendant" ) isEqualTo 1;

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
				] call A3C_LB_ADD;
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

			
			//ctrlsetfocus (findDisplay 100040 displayCtrl 8055);
			_patients = [group player] call A3C_FINDPATIENTS;
			private _multiPatient = (count _patients) > 1;
			if (_multiPatient) then {
				[["HEAL ALL","",objnull,(findDisplay 100040 displayCtrl 8055),""]] call A3C_LB_ADD;
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
				] call A3C_LB_ADD;
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
						_x, //_x,
						''				,
						objnull,
						(findDisplay 100040 displayCtrl 8054),
						"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa" //_img
					]
				] call A3C_LB_ADD; //["_label","_class","_obj","_cbo","_img"];
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
						_x, //_x,
						'',
						objNull,
						(findDisplay 100040 displayCtrl 8055),
						"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa" //_img
					]
				] call A3C_LB_ADD; //["_label","_class","_obj","_cbo","_img"];
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
				// systemchat 'yo';
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
						_buttonColor = if (_occupyingUnit in units player) then {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_Color_setOpacity} else {[A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity};

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
								_buttonColor = if (group _occupyingUnit == group player) then {[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_Color_setOpacity} else {[A3C_UI_COLOR_RED,0.3] call A3C_UI_Color_setOpacity};
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
					//if (_foreachIndex == 0) then {
					//	setMousePosition [(35.5 * _GUI_GRID_W + _GUI_GRID_X) + (_rowEntries * (_btnW + (_btnW * _spacingFactor))),0.5];
					//	systemchat str [(35.5 * _GUI_GRID_W + _GUI_GRID_X),(35.5 * _GUI_GRID_W + _GUI_GRID_X) + (_rowEntries * (_btnW + (_btnW * _spacingFactor)))];
					//};

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
						] call A3C_LB_ADD;
					} foreach A3C_VEHSAV;
				};
			};

			
		};
	};

	(findDisplay 100040 displayCtrl 8056) ctrlSetText _orderText;
	(findDisplay 100040 displayCtrl 8057) ctrlSetText _lbText1;
	(findDisplay 100040 displayCtrl 8058) ctrlSetText _lbText2;
	// systemchat format ["haiyoa cursel %1", A3C_CurSel];
	


};




A3C_FINDVEHS = {
	params ["_units"];
	private _entities = if (count _this > 1) then {_this select 1} else {[A3C_RADIAL_VEH_KIND]};
	A3C_VEHSAV= [];
	A3C_BOARD_UNITS = [];
	//if ("CARS" in _entities) then {
	//	_entities pushBackUnique "SHIP";
	//};

	{
		//if (isnull objectParent _x) then {


			{
				_v = _x;
				if (canMove _v) then {
					if ( (side _x == civilian) OR ( ((side _x) getfriend (side player)) > 0.6)  ) then {
						//if ({(_v emptypositions _x) > 0} count ["driver","gunner","commander","cargo"] > 0) then {
							A3C_VEHSAV pushbackUnique _v;
						//};
					};
					//if (_v == cursortarget) then {
					//	A3C_VEHSAV pushbackUnique _v;
					//};
				};

			} foreach (_x nearentities [_entities,220]);
			if ((vehicle _x) isKindOf A3C_RADIAL_VEH_KIND) then {
				A3C_VEHSAV pushbackUnique (vehicle _x);
			//} else {
			//	if ((A3C_RADIAL_VEH_KIND == "CAR") && {(vehicle _x) isKindOf "SHIP"}) then {
			//		A3C_VEHSAV pushbackUnique (vehicle _x);
			//	};
			};

		//};
	} foreach _units;
	//systemchat str [A3C_RADIAL_VEH_KIND,_entities,A3C_VEHSAV];
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
		[["NO VEHICLES","",objnull,(findDisplay 100040 displayCtrl 8054),""]] call A3C_LB_ADD;
	};
	{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];

	
	
	
	[] spawn {
		["VEHICLES"] call A3C_LABEL_LB;	
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

//// continue here with ([cursortarget,[]] call BIS_fnc_getTurrets) + turretUnit

A3C_FINDVEHROLES = {
	private ["_vehicle","_all"];
	_vehicle = _this select 0;
	A3C_VEHROLES = [];

	if ( ({!(side _x == civilian) && ((side _x getfriend side player) < 0.6)} count (crew _vehicle)) > 0) exitwith {};


	_all = false;

	{
		call compile format
		[
			"
				if ((_vehicle emptypositions '%1') > 0) then {
					A3C_VEHROLES pushbackUnique _x;
					_all = true;
				};
				if !(isNull (%1 _vehicle)) then {
					if !(alive (%1 _vehicle)) then {
						A3C_VEHROLES pushbackUnique _x;
						_all = true;
					};
				};
			",
			_x
		];
	} foreach ["driver","gunner","commander"];



	if ((_vehicle emptypositions "cargo") > 0) then {
		A3C_VEHROLES pushbackUnique "cargo";
		_all = true;
	};
	{
		_u = _x;
		_veh = vehicle _u;
		if !(_u == driver _veh) then {
			if !(_u == gunner _veh) then {
				if !(_u == commander _veh) then {
					if !(alive _x) then {
						if ( ( {_u == (_vehicle turretUnit _x)} count (allturrets [_vehicle ,true])) == 0) then {

							A3C_VEHROLES pushbackUnique "cargo";
							_all = true;
						};
					};
				};
			};
		};
	} foreach (crew _vehicle);

	if (_all) then {
		//-- toggle on "BOARD ALL"
		{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8067,8068];
		(findDisplay 100040 displayCtrl 8067) ctrlSetTextColor  [1,1,1,0.6];
	};



	_turrs = allturrets [_vehicle,true];
	{
		if (!alive (_vehicle turretunit _x)) then {

			if ( (count(_vehicle weaponsTurret _x)) > 0) then {
				A3C_VEHROLES pushbackUnique "gunner";
			} else {
				if (_forEachIndex == 0) then {
					if (_vehicle iskindof "AIR") then {
						A3C_VEHROLES pushbackUnique "commander";
					};
				};
			};

		};
	} foreach _turrs;

	_array = "true" configClasses (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "Turrets");
	{
		if (_foreachIndex > 0) then {
			if ( (getnumber (configfile >> "CfgVehicles" >> (typeof _vehicle) >> "Turrets" >> (configname _x) >> "hasgunner")) > 0) then {
				A3C_VEHROLES pushbackUnique "gunner";
			};
		};
	} foreach _array;

};






A3C_BTN_REINIT = {
	//_mode = _this select 0;

	//A3C_RD_UNITS = (groupSelectedUnits player);
	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};

	} foreach A3C_RD_UNITS;


	((findDisplay 100040) displayctrl 9009) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa"; //((getText (configfile >> "CfgWeapons" >> (primaryWeapon (A3C_RD_UNITS select 0)) >> "picture")));
	//A3C_AI_GREN_ARRAY = [];
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
	//if !(A3C_GREN_MUZZLE in A3C_AI_GREN_ARRAY) then {};


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




			/*
			{
				_u = _x;
				_add = false;
				if (({_it = _x;  ({[_x,_it] call MCSS_fnc_isInString} count ["_IR","Strobe"] ) > 0} count (magazines _u)) > 0 ) then {
					_add = true;
				};
				if ((count (_u getvariable "A3C_STROBE")) > 0) then {
					_add = true;
				};
				if (_add) exitwith {
					((findDisplay 100040) displayCtrl 10030) ctrlSetText (getText (configfile >> "CfgMagazines" >> "B_IR_Grenade" >> "picture"));
					((findDisplay 100040) displayCtrl 10031) ctrlSetToolTip "LMB: ATTACH IR-STROBES , RMB: DETACH IR-STROBES";
				};
			} foreach (A3C_RD_UNITS - [player]);
			*/
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

A3C_ACTIVE_BUTTONUNIT = objnull;
A3C_RD_BTN_UNIT = { // -- currently unused after CT_TREE introduction
	systemchat 'alert radial bttn_unit';
	private ["_unitIndex","_unitArray"];
	_unitIndex = _this select 0;
	_button = ((_this select 0) - (A3C_BUTTONPAGE_TABLET * 18));
	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
		_unitIndex = _unitIndex - 1;
	};
	//if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
	//	_button = _button - 1;
	//};

	_data = _this select 1;
	_mB = _data select 1;
	_sX = _data select 2;
	_sY = _data select 3;
	_shift = _data select 4;
	_ctrl = _data select 5;

	private _unitArray = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {profileNamespace getvariable "A3C_GROUPUNITS"} else {A3C_HC_MENU_REFERENCE_UNITS}; //{A3C_HCALLGROUPS_Current};
	private _unit = _unitArray select _unitIndex;
	//playSound3D ["A3\ui_f\data\sound\Readout\readoutclick.wss", player];
	_cond = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {!alive _unit} else {{alive _x} count units _unit == 0};
	if (_cond) exitwith {player groupchat 'unit not available'};
	if (_mB == 0) then {
		if (_shift) then {
			if ((count A3C_RD_UNITS) < (count _unitArray)) then {
				//-- no or not not all units selected
				_step = 1;
				if (count A3C_RD_UNITS > 0) then {
					if !(_unit == A3C_ACTIVE_BUTTONUNIT) then {
						//-- some units are selected
						_destIndex = [A3C_ACTIVE_BUTTONUNIT,_unitArray] call MCSS_fnc_GetArrayIndex;


						if (_unitIndex > _destIndex) then {
							_step = -1;
						};
						for "_i" from _unitIndex to _destIndex step _step do {
							if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
								if (!isPlayer (_unitArray select _i)) then {
									player groupSelectUnit [(_unitArray select _i),true];
									A3C_RD_UNITS pushbackUnique (_unitArray select _i);
								} else {
									player groupSelectUnit [(_unitArray select _i),false];
								};
							} else {
								A3C_RD_UNITS pushbackUnique (_unitArray select (_i));
							};


						};
						//-- Author Note: Make general function for unitButton Colors
						for "_t" from 8073 to 8090 do {
							_index = ((_t - 8072) + (A3C_BUTTONPAGE_TABLET * 18));
							if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
								_index = _index - 1;
							};
							if (_index < (count _unitArray)) then {
								if ((_unitArray select _index) in A3C_RD_UNITS) then {
									(findDisplay 100040 displayCtrl _t) ctrlSetTextColor [1,1,1,1];
								} else {
									(findDisplay 100040 displayCtrl _t) ctrlSetTextColor [1,1,1,0.5];
								};
							};
						};
					};
				} else {
					//-- no units are selected
					if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
						if (!isPlayer _unit) then {
							player groupSelectUnit [_unit,true];
							A3C_RD_UNITS pushbackUnique _unit;
							(findDisplay 100040 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,0.6];
						} else {
							player groupSelectUnit [_unit,false];
						};
					} else {
						A3C_RD_UNITS pushbackUnique _unit;
					};
				};
			} else {
				//-- all units selected
			};
			A3C_ACTIVE_BUTTONUNIT = _unit;
		} else {
			A3C_ACTIVE_BUTTONUNIT = _unit;
			if (_ctrl) then {
				if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
					if (!(_unit in A3C_RD_UNITS) && {!isPlayer _unit}) then {
						player groupSelectUnit [_unit,true];
						A3C_RD_UNITS pushbackUnique _unit;
						(findDisplay 100040 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,1];
					} else {
						player groupSelectUnit [_unit,false];
						A3C_RD_UNITS = A3C_RD_UNITS - [_unit];
						(findDisplay 100040 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,0.5];
					};
				} else {
					if !(_unit in A3C_RD_UNITS) then {
						A3C_RD_UNITS pushbackUnique _unit;
						(findDisplay 100040 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,1];
					} else {
						A3C_RD_UNITS = A3C_RD_UNITS - [_unit];
						(findDisplay 100040 displayCtrl (8072 + _button)) ctrlSetTextColor [1,1,1,0.5];

					};
				};
			} else {
				for "_i" from 8073 to 8090 do {
					if (_i == (8072 + _button)) then {
						_cond = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {!isPlayer _unit} else {true};
						if (_cond) then {
							(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,1];
						} else {
							(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.5]
						};
					} else {
						(findDisplay 100040 displayCtrl _i) ctrlSetTextColor [1,1,1,0.5]
					};
				};
				if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
					if (!isPlayer _unit) then {
						player groupSelectUnit [_unit,true];
						A3C_RD_UNITS pushbackUnique _unit;
						{player groupSelectUnit [_x,false]} foreach (units group player - [player,_unit]);
						// Author Note: reset other button Colors!
					} else {
						player groupSelectUnit [_unit,false];
					};
				} else {
					A3C_RD_UNITS = [_unit];
				};
			};
		};
	} else {
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
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
				if (alive (_unitArray select _unitIndex) ) then {
					A3C_BUTTON_UNIT = (_unitArray select _unitIndex);
					lbClear ((findDisplay 100040) displayCtrl 8095);
					((findDisplay 100040) displayCtrl 8095) ctrlShow true;
					ctrlsetfocus (finddisplay 100040 displayctrl 8095);
					A3C_LB_MODE = 3;
					//_cP = (ctrlPosition (findDisplay 100040 displayCtrl (7072 + _button)));
					//_sX = _cP select 0;
					//_sY = _cP select 1;
					//_sX1 = _sX min ((ctrlPos (findDisplay 100040 displayCtrl 8074)) select 0 );

					//-- adjust listox x- and y-coordinates
					_sX = _sX min  ( (ctrlPosition (findDisplay 100040 displayCtrl 8074)) select 0 );
					_sY = _sY min  ( (ctrlPosition (findDisplay 100040 displayCtrl 8084)) select 1 );

					private _teamBox = (findDisplay 100040 displayCtrl 8095);
					
					_teamBox ctrlSetPosition [_sX,_sY];
					_teamBox ctrlCommit 0;

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
							// _teamBox lbSetColor [4, [1, 1, 0, 1]];
							_teamBox lbSetSelectColor [3, [1, 1, 0, 1]];
						};
						case ('MAIN') : {
							[_teamBox, 4] call A3C_setCurSel;
							// _teamBox lbSetColor [4, [1, 1, 1, 1]];
							_teamBox lbSetSelectColor [4, [1, 1, 1, 1]];
						};
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
					//{
						if !((_unitArray select _unitIndex) in A3C_HUD_UNITS) then {
							[(_unitArray select _unitIndex),(_unitArray select _unitIndex) getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
						} else {
							[(_unitArray select _unitIndex)] call A3C_HUD_REMOVE_SELECTED;
						};
					//} foreach A3C_RD_UNITS;
				};
			};
		};
	};
	if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
		A3C_RD_UNITS = groupselectedUnits player;
		{
			if (isPlayer _x) then {
				A3C_RD_UNITS = A3C_RD_UNITS - [_x];
				player groupSelectUnit [_x,false];
			};
		} foreach A3C_RD_UNITS;


		//-- Medical controls opened: reset Listbox entries and medical data  uuu
		if (BV_MEDICAL == 1) then {
			["MEDICAL"] call A3C_LABEL_LB;
		};
		if (A3C_LBR_1 == "REARM") then {
			A3C_ReArm_options = [];
			[] call A3C_ReArm_OpenUI;
		};
		if (A3C_RADIALMODE == "ACT") then {
			BV_ACT = 0;
			["ACTIONS",-1] call A3C_RADIAL_BTN_FNC_RING_INNER;
		};

		if (A3C_RADIALMODE == "VEHS") then {
			[A3C_RD_UNITS] call A3C_FINDVEHS;
		};
		[] call A3C_BTN_REINIT;
	} else {

		if (count A3C_RD_UNITS == 0) then {
			(findDisplay 100040 displayCtrl 8005) ctrlSetText "SELECT UNIT";

		} else {
			if (count A3C_RD_UNITS == 1) then {
				
				(findDisplay 100040 displayCtrl 8005) ctrlSetText (groupID (A3C_RD_UNITS select 0));
			} else {
				(findDisplay 100040 displayCtrl 8005) ctrlSetText "MULTIPLE GROUPS";
			};

		};
		["ROE",-1] call A3C_RADIAL_BTN_FNC_RING_INNER;
		A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;

		[] call A3C_Radial_DashBoard;
	};
};

A3C_RADIAL_TREE_MouseDown = {
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
				
				//if (alive (_unitArray select _unitIndex) ) then {
				//	A3C_BUTTON_UNIT = (_unitArray select _unitIndex);

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
					
					
				//};
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
					//{
						if !((_unitArray select _unitIndex) in A3C_HUD_UNITS) then {
							[(_unitArray select _unitIndex),(_unitArray select _unitIndex) getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
						} else {
							[(_unitArray select _unitIndex)] call A3C_HUD_REMOVE_SELECTED;
						};
					//} foreach A3C_RD_UNITS;
				};
			};
		};
	};
};



A3C_RadialMenu_FNC_TEAMCOLOR = {
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

	_count = ({_x in (groupSelectedUnits player)} count _units); //if (_btn == 1) then {({_x in A3C_HUD_UNITS} count _units)} else {({_x in (groupSelectedUnits player)} count _units)};
	if (_btn == 1) then {
		_units commandFollow player;
	} else {
		if (_count == (count _units)) then {
			{
				// if (_btn == 1) then {
				// 	[_x] call A3C_HUD_REMOVE_SELECTED;
				// } else {
					player groupSelectUnit [_x, false];
				// };


			} forEach _units;
		} else {
			{
				// if (_btn == 1) then {
				// 	if !(_x in A3C_HUD_UNITS) then {
				// 		//if !(isnull (findDisplay 100040)) then {[] call A3C_RADIAL_CloseDisplay}; // ~ obsolete, TAB is held down and will open radial again
				// 		[_x,_x getvariable "A3C_FORMATION_INDEX"] call A3C_HUD_ADD_SELECTED;
				// 	};
				// } else {
					if !(_x in (groupSelectedUnits player)) then {
						player groupSelectUnit [_x, true];
					};
				// };

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
		["MEDICAL"] call A3C_LABEL_LB;
	};
	[] call A3C_BTN_REINIT;
};

A3C_SETTINGS = {
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
		A3C_DG_SETTINGS = (finddisplay 46) createDisplay "A3C_SETTINGS_MENU";
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

//~~ WTF this is a unused fnc similar to the above?
A3C_SETTINGS_DIALOG = {

	with uiNameSpace do {
		A3C_DG_SETTINGS = (finddisplay 46) createDisplay "A3C_SETTINGS_MENU";
	};

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
};


A3C_UPDATE_UI_MEDICAL = {
	// player sidechat 'update UI';
	if (A3C_LBR_1 == 'MEDICAL') then {
		if (ctrlShown (findDisplay 100040 displayCtrl 8056)) then {

			{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054,8055];
			["MEDICAL"] call A3C_LABEL_LB;

			
		};
	};


};






	/*
	EDITING NOTES:
	This function is executed when pressing the Healing Button in the radial menu and is depending on input, which is depending on circumstances
	Active Medic(s) will start healing available patients until the array is empty.
	Patients that are actively healed by a medic does not have to be in available array anymore

	Healing System explained:
	When opening the healing section, the arrays A3C_MEDICS and A3C_PATIENTS will be formed. These simply represent availability and necessity for help and represent the planning stage



	*/



// -- Mistakenly made this not knowing that my buggy behavior came from setting cursel (so this one is not really necessary)
A3C_addLbEntry = {
	params ["_control","_lbText"];
	A3C_CurSel = true;
	private _index = _control lbAdd _lbText;
	A3C_CurSel = false;
	_index
};

A3C_setCurSel = {
	params ["_control","_index"];
	
	private _doExecuteLbAction = if (count _this > 2) then {_this select 2} else {false};
	
	if (typeName _doExecuteLbAction != "BOOL") exitWith {
		systemchat format ["A3C_setCurSel: Wrong parameter type for doExecuteAction: %1", _this];
	};
	if !(_doExecuteLbAction) then {
		A3C_CurSel = true;
	};

	// systemchat format ["A3C_setCurSel A3C_CurSel %1, condition %2", A3C_CurSel, !(_doExecuteLbAction)];
	
	_control lbSetCurSel _index;
	if !(_doExecuteLbAction) then {
		[] spawn {
			//-- we need the delay because the LB_Change fnc takes too long to execute
			sleep 0.2; A3C_CurSel = false;
		};
	};
	
};


A3C_LB_ADD =
{
	// 
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
	// 
	

};