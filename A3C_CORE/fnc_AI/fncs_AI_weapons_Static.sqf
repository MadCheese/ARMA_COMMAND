
//-- determine if static weapon is ROCKET LAUNCHER (Used by Remote Fire Fncs)
A3C_isStaticMissileLauncher = {
    params ["_input"];
    private _type = if (typeName _input == "OBJECT") then {typeOf _input} else {_input};
    if !(_type isKindOf "STATICWEAPON") exitWith {false};
    private _magazineArray = getArray (configfile >> "CfgVehicles" >> _type >> "Turrets" >> "MainTurret" >> "magazines");
    private _return = false;
    {
        private _ammo = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
        private _effects = toLower (getText (configfile >> "CfgAmmo" >> _ammo >> "effectsMissile"));
        if (_effects find "missile" > -1) exitWith {
        	//private _explosioneffects = toLower (getText (configfile >> "CfgAmmo" >> _ammo >> "explosioneffects"));
        	//systemchat str _explosioneffects;
            _return = true;
        };
    } foreach _magazineArray;
    _return
};


//-- older version of above fnc
A3C_isStaticMissileLauncher_orig = {
	params ["_input"];
	private ["_magazineArray","_return"];
	if (typeName _input == "OBJECT") then {_input = typeOf _input};
	if !(_input isKindOf "STATICWEAPON") exitWith {false};
	_magazineArray = getArray (configfile >> "CfgVehicles" >> _input >> "Turrets" >> "MainTurret" >> "magazines");
	_return = false;
	{
		_ammo = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
		_effects = toLower (getText (configfile >> "CfgAmmo" >> _ammo >> "effectsMissile"));
		if (["missile",_effects] call BIS_fnc_instring) exitWith {
			_return = true;
		};
	} foreach _magazineArray;
	_return
};

//-- used for squad level: find out if units would assemble or disassemble a weapon
A3C_SMART_getWeaponAssemblyMode = {
	params ["_units"];
	private ["_condition1","_condition2","_return"];
	[_units,"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;
	_condition1 = (({backpack _x == ""} count _units >= 2) ); //-- at least 2 units have no backpack for disassembly
	_condition2 = count A3C_STATIC_PACKS > 0; //-- units have weapons to assemble
	_return = switch (true) do {
		case (_condition1 && !(_condition2)) : {"DISASSEMBLE"};
		case (_condition2 && !(_condition1)) : {"ASSEMBLE"};
		case (_condition1 && _condition2) : {"DUAL"};
		default {"NONE"};
	};
	_return
};



//-- IFA is running: Create arrays with [_weaponType,[_part1, _part2]] for each vehicle with "LIB_dissasembleTo" data
//-- this is because there is no "LIB_asembleTo" config entries
A3C_IFA_StaticPartPairs = [];
if (A3C_IsIFA) then {
	_cfgArray = "true" configClasses (configfile >> "CfgVehicles");
	{
		_assembleInfo = getArray (configfile >> "CfgVehicles" >> configName _x >> "assembleInfo" >> "LIB_dissasembleTo");
		if (count _assembleInfo > 0) then {
			A3C_IFA_StaticPartPairs pushBack [configName _x,_assembleInfo];
		};
	} foreach _cfgArray;
};



A3C_AI_Squad_Action_assembleWeaponExecute = {
	{
		private _units = _x select 0;
		private _weapon = _x select 1;
		if (_weapon == typeOf A3C_OBJECTPLACER) exitWith {
			if ({ !((_x getVariable ["A3C_PLOT",[]]) isEqualTo []) } count _units > 0) then {
				[_units,true,false] call A3C_AI_Shared_cancelUnitPlot;
				waituntil {
					sleep 0.1;
					{
						// private _abort = _x getvariable ["A3C_ABORT_Data",[false,false]];
						private _plot = _x getVariable ["A3C_PLOT",[]];
						!(_plot isEqualTo []) // || { {_x} count _abort > 0 }
					} count _units == 0
				};
			};
			
			player groupRadio "SentAssemble";
			_mainMark = "A3C_SQ_" + (str (random 10000000000));

			{
				_unit = _x;
				waitUntil {count (_unit getvariable 'A3C_PLOT') == 0};
				_data =
				[
					[
						[screentoWorld [0.5,0.5],(screentoWorld [0.5,0.5]) getPos [50,getDir A3C_OBJECTPLACER]], //-- positions
						[_mainMark,"",""], //-- markers
						["STATIC",["ASSEMBLE",_weapon]], //-- wp action
						["NONE","NONE"], //--WP Condition
						["UP","AUTO"], //-- WP Stances
						[[0,false]], // WP Sync Data
						false, //-- isWPCompleted
						0, //-- Combat Mode
						-1, //-- WP SPeed
						25, //-- WP Flying Height
						-1, //-- WP Loop Value
						0 // -- radius (for circle, not completion)
					]
				];
				_unit setvariable ["A3C_PLOT",_data,true];
				_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_AI_Shared_executeUnitPlot);
			} foreach _units;
			A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  _weapon >> "picture");
			A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";
			private _tagPos = +(position A3C_OBJECTPLACER);
			[_tagPos,""] spawn A3C_UI_HUD_3D_TAG;

		};
	} foreach A3C_STATIC_PACKS;
	deleteVehicle A3C_OBJECTPLACER;
};

A3C_SOG_BASEPACKS = ["vn_o_pack_static_base_01","vn_b_pack_static_base_01"];


A3C_STATIC_PACKS = [];












//-- determine if unit selection can pick up a specified static weapon
A3C_HC_canSelectionPickUpStatic = {
	params ["_units","_weapon","_distanceRelevant"];
	private ["_return","_vehicleParts"];
	_return = false;
	_vehicleParts = getArray (configfile >> "CfgVehicles" >> typeOf _weapon >> "assembleInfo" >> "dissasembleTo"); //-- equals [] when nothing is found
	//-- units in vehicles can not disassemble things. EXCEPT the vehicle is the static weapon itself
	{
		if (!isNull objectParent _x) then {
			if (vehicle _x != _weapon) then {
				_units = _units - [_x];
			};
		};
	} foreach _units;
	//-- check for IFA parts
	if (count _vehicleParts == 0) then {
		_vehicleParts = getArray (configfile >> "CfgVehicles" >> typeOf _weapon >> "assembleInfo" >> "LIB_dissasembleTo");
		if (count _vehicleParts > 0) then {
			_vehicleParts set [1,getText (configfile >> "CfgVehicles" >> (_vehicleParts select 1) >> "LIB_Equipped_Tripod_Name")];
		};
	};
	if (count _vehicleParts == 0) exitWith {_return};
	private _assignedUnits = [];
	private _exitAll = false;
	{
		_part = _x;
		//_partType = switch (true) do {
		//	case (_part isKindOf ["Rifle", configFile >> "CfgWeapons"]) : {"PRIMARY"};
		//	case (_part isKindOf ["Rifle", configFile >> "CfgWeapons"]) : {"SECONDARY"};
		//	default {"BACKPACK"};
		//};

		private _exitSub = false;
		if (_exitAll) exitWith {};
		{
			private _add = true;
			_u = _x;
			if (!(_distanceRelevant) OR {_x distance _weapon <= 30}) then {
				switch (true) do {
					case (_part isKindOf ["Rifle", configFile >> "CfgWeapons"]) : {
						//if (primaryWeapon _x == "") then {
							if !(_u in _assignedUnits) then {
								_assignedUnits pushBack _x;
								_exitSub = true;

								//-- trick: unit has no secondary, so we can just exit and use him twice
								if ([_u] call A3C_STATIC_isSecondaryAllowed) then {
									_assignedUnits pushBack _u;
									//_exitSub = true; //-- allready defined as true
									_exitAll = true;
								};
							};
						//};
					};
					case (_part isKindOf ["Launcher", configFile >> "CfgWeapons"]) : {
						//if (secondaryWeapon _x == "") then {
						//	if !(_x in _assignedUnits) then {
						//		_assignedUnits pushBack _x;
						//		_exitSub = true;
						//	};
						//} else {
							if ([_x] call A3C_STATIC_isSecondaryAllowed) then {
								if !(_x in _assignedUnits) then {
									_assignedUnits pushBack _x;
									_exitSub = true;
								};
							};
						//};
					};
					default {
						//if (backPack _x == "") then {
							if !(_x in _assignedUnits) then {
								_assignedUnits pushBack _x;
								_exitSub = true;
							};
						//};
					};
				};
			};
			if (count _assignedUnits == 2) exitWith { //-- capable units have been found - exit!
				_exitAll = true;
				_return = true;
			};
			if (_exitSub) exitWith {}; //-- stop searching for units to carry this part
			//if (_exit) exitWith {_return = true};

		} foreach _units;
	} foreach _vehicleParts;
	_return
};




A3C_STATIC_isSecondaryAllowed = {
	params ["_u"];
	private _add = true;
	//if (secondaryWeapon _u == "") then {
	if (secondaryWeapon _u != "") then {

//	} else {
		if (A3C_IsIFA) then { //lib_equipped
			//_podWeaponClass = getText (configfile >> "CfgVehicles" >> _staticPod >> "LIB_Equipped_Tripod_Name")
			{
				_parts = _x select 1;
				if (secondaryWeapon _u in [_parts select 0,getText (configfile >> "CfgVehicles" >> _parts select 1 >> "LIB_Equipped_Tripod_Name")]) exitWith {
					_add = false;
				};
			} foreach A3C_IFA_StaticPartPairs;
		};
		if (_add) then {
			//-- no IFA parts found: check for secondary Magazines
			_launcherMags = getArray (configfile >> "CfgWeapons" >> secondaryWeapon _u >> "magazines");
			if ({_x in _launcherMags} count (magazines _u + (secondaryWeaponMagazine _u) ) > 0) then {
				//-- unit has launcher with mags - do NOT allow static pickup
				_add = false;
			};
		};
	};
	_add
};