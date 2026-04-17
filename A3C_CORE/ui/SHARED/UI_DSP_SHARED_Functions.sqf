A3C_UI_Shared_FNC_AddDownkey = {
	//-- purpose: exclude ALT from downkey collection in order to prevent lingering in A3C_UI_DOWNKEYS
	params ["_key"];
	if (_key != 56) then {
		A3C_UI_DOWNKEYS set [count A3C_UI_DOWNKEYS, _key];
	};
};


A3C_UI_Shared_blockKeyDownEvent = {
    params ["_key"];
    if (a3c_is_HC_remote && {_key in [200,203,205,208]}) exitWith {false};
    if !(_key in A3C_UI_DOWNKEYS) exitWith {false};

    true
};


// #TODO: Dashboard fnc could do with optimization for speed

A3C_UI_SHARED_createDashBoard = {
	private _a3c_dsp = if (visibleMap) then {
		100020
	} else {
		if (!isNull findDisplay 100030) then {
			100030
		} else {
			100040
		}
	};
	(findDisplay _a3c_dsp displayCtrl 800713) ctrlSetTextColor [1,1,1,0]; //-- hide ct-edit box because of it's frame
	
	_ref_selected_units = A3C_SELECTED_HC_GROUPS_SETTINGS; //if (_a3c_dsp == 100040) then {} else {A3C_SELECTED_HC_GROUPS_SETTINGS};


	if (count _ref_selected_units == 1) then {

		//--reset box and structured text
		{
			ctrlDelete _x;
		} foreach A3C_UI_SHARED_createDashBoard_ExtraControls;
		A3C_UI_SHARED_createDashBoard_ExtraControls = [];


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
			_parentPos set [0, _gpX - (_parentPos select 2) ];
			_parentPos set [1,_gpY]; 
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
				_unitLoadOut = getUnitLoadout (configFile >> "CfgVehicles" >> typeof _x);
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
		if (count _staminaValues > 0) then {
			{
				_groupStamina = _groupStamina + _x;
			} foreach _staminaValues;
		};
		
		//-- set images and text(findDisplay _a3c_dsp displayCtrl 11001) ctrlSetText _groupID;
		{(findDisplay _a3c_dsp displayCtrl _x) ctrlSetText _groupID;} foreach [11001,800713];
		(findDisplay _a3c_dsp displayCtrl 11002) ctrlSetText _groupIcon;
		(findDisplay _a3c_dsp displayCtrl 11003) ctrlSetText _unitSize;
		(findDisplay _a3c_dsp displayCtrl 11004) ctrlSetText _location;
		(findDisplay _a3c_dsp displayCtrl 11005) ctrlSetText _currentTask;

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

			_progressCol = switch (true) do {
				case (_progress <= 0.3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_Color_setOpacity};
				case (_progress < 0.7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_Color_setOpacity};
				//case (_progress == 0) : { [A3C_UI_COLOR_RED,0.1] call A3C_UI_Color_setOpacity};
				default {[0,1,0,0.6]};
			};
			
			_actualProgressBar progressSetPosition _progress;
			_actualProgressBar ctrlSetTextColor _progressCol; //;
			

			_barTextCtrl = (findDisplay _a3c_dsp) ctrlCreate ["A3C_RscText_GroupDashboard",12003 + _macroIndex, findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT]; //--12003 is the 'ammunition'-bar idc, we build up from here
			_barTextCtrl ctrlSetText _descriptionText;
			
			_barTextCtrl ctrlSetPosition _ctrlPosText;

			if (_progress == 0) then {
				_barTextCtrl ctrlSetTextColor [1,0,0,1]; //([A3C_UI_COLOR_RED,0.9] call A3C_UI_Color_setOpacity);
			};
			{_x ctrlCommit 0} foreach [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			_macro = [_actualProgressBar,_barTextCtrl,_bg_ProgressBar];
			A3C_UI_SHARED_createDashBoard_ExtraControls = A3C_UI_SHARED_createDashBoard_ExtraControls + _macro;
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