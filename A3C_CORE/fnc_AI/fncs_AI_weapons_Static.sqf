
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
	[_units,"PLANNING"] call A3C_getSelectionBackpackStatics;
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

//-- find the weapons that a unit selection can possibly assemble.
A3C_STATIC_PACKS = [];
A3C_getSelectionBackpackStatics = {
	params ["_units","_mode"];
	A3C_STATIC_PACKS = [];

	//-- REGULAR APPROACH (BAGS)

	{
		private ["_soldier","_bP"];
		_soldier = _x;
		_gp = group _soldier;
		_bP = "";
		private _allowInfPlanning = isnull objectParent _soldier OR 
		{
			!isPlayer leader group _x &&
			{
				!( driver (vehicle leader _gp) in (units _gp) )
			}
		};
		private _backPackClass = backpack _soldier;
		// systemchat str [_backPackClass,unitbackPack _soldier,unitBackpack _soldier isKindOf "Weapon_Bag_Base", _allowInfPlanning];
		if ( (unitBackpack _soldier isKindOf "Weapon_Bag_Base" || {_backPackClass in A3C_SOG_BASEPACKS}) && {_allowInfPlanning}) then { //~~ currently not allowing cargo plans for player group
			//-- unit has a weapon backpack. Check if a base is available within selection			
			if (_backPackClass in A3C_SOG_BASEPACKS) then {
				//-- SOG weapons: One base for all statics
				{
						private ["_comparedSoldier","_bPConnect"];
						_comparedSoldier = _x;
						_bPConnect = backPack _comparedSoldier; //toLower (backPack _comparedSoldier);

						if (_bPConnect != "") then {
							private _basePacks = getArray (configFile >> "CfgVehicles" >> _bPConnect >> "assembleInfo" >> "base");
							if (_backPackClass in _basePacks) then {
								if ( {_comparedSoldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
									if ( {_soldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
										A3C_STATIC_PACKS pushback
										[
											[_soldier,_comparedSoldier],
											(getText (configfile >> "CfgVehicles" >> _bPConnect >> "assembleInfo" >> "assembleTo"))
										];
									};
								};
							};
						};
					} foreach (_units - [_soldier]);
			} else {
				_bP = toLower _backPackClass;
				if !(_bP == "") then { //-- << needed?
					private _cfgBase = configFile >> "CfgVehicles" >> _bp >> "assembleInfo" >> "base";
					private _compatibleBases = if (isText _cfgBase) then {[toLower (getText _cfgBase)]} else {getArray _cfgBase};
					{
						_compatibleBases set [_foreachIndex, toLower _x];
					} foreach _compatibleBases;
					// systemchat str _compatibleBases;
					{
						private ["_comparedSoldier","_bPConnect"];
						_comparedSoldier = _x;
						_bPConnect = toLower (backPack _comparedSoldier);
						if ((_bPConnect != "") && {_bPConnect in _compatibleBases}) then {

							//-- weapon base found. assign unit uness already occupied
							if ( {_comparedSoldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
								if ( {_soldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
									A3C_STATIC_PACKS pushback
									[
										[_soldier,_comparedSoldier],
										(getText (configfile >> "CfgVehicles" >> _bP >> "assembleInfo" >> "assembleTo"))
									];
								};
							};
						};
					} foreach (_units - [_soldier]);
				};
			};
		};
	} foreach _units;

	//-- IFA APPROACH
	//-- EXAMPLE IFA: LIB_Deployed_Tripod_Name = "LIB_M2_Tripod_Bag";
	//-- _deployedPodClass = getText (configfile >> "CfgWeapons" >> "LIB_M1919A4" >> "LIB_Deployed_Tripod_Name"); //-- "LIB_M2_Tripod_Bag"
	//-- _podWeaponClass = configfile >> "CfgVehicles" >> _deployedPodClass >> "LIB_Equipped_Tripod_Name"; //-- "LIB_M2_Tripod"
	private _partSearchComplete = false;
	{
		_soldier = _x;
		_staticPod = "";
		private _staticTurret = "";
		{
			_refWeapon = _x;
			{
				if (_refWeapon == (_x select 1) select 0) then {
					_staticTurret = _refWeapon;
					_staticPod = (_x select 1) select 1;
				};
			} foreach A3C_IFA_StaticPartPairs;

		} foreach [primaryWeapon _soldier, secondaryWeapon _soldier];

		if (_staticTurret != "") then {
			//-- get the actual weaponclass for the tripod (IFA stores pod as DEPLOYED (cfgVehicles) in assemblyInfo, but we need to check if unit is carrying the corresponding weapontype
			private _podWeaponClass = getText (configfile >> "CfgVehicles" >> _staticPod >> "LIB_Equipped_Tripod_Name");
			//-- we have a turret/weapon that can be attached to a POD to form a static weapon. Note that in case of MG, the unit may be carrying the pod himself, so we do not need to exclude him
			//-- instead of excluding him, we sort the _units array and make sure that _soldier is the first entry of checked units
			_referenceArray = [_soldier] + (_units - [_soldier]);

			{
				_comparedSoldier = _x;
				if (secondaryWeapon _x == _podWeaponClass) then {
					//-- weapon base found!
					if ( {_comparedSoldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
						if ( {_soldier in (_x select 0)} count A3C_STATIC_PACKS == 0) then {
							_vehicleType = "";
							{
								if ((_x select 1) isEqualTo [_staticTurret,_staticPod]) exitWith {
									_vehicleType = _x select 0;
								};
							} foreach A3C_IFA_StaticPartPairs;
							if (_vehicleType != "") then {
								A3C_STATIC_PACKS pushback
								[
									[_soldier,_comparedSoldier],
									_vehicleType
								];
							};
						};
					};
				};
			} foreach _referenceArray;
		};
	} foreach _units;


	if (_mode == "EXECUTING") exitWith {
		_return = +(A3C_STATIC_PACKS);
		_return
	};
	//-- remove occupied units
	private _weapons= [];
	{
		_soldier = ((_x select 0) select 0);
		_weapon = _x select 1;
		private _unitData = ((_soldier getVariable ["A3C_PLOT",[]]) + (_soldier getVariable ["A3C_PLOT_TEMP",[]]));
		{
			_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
			if (_wpAction select 0 == "STATIC") then {
				if ( (_wpAction select 1) select 0 == "ASSEMBLE") then {
					if ( (_wpAction select 1) select 1 == _weapon) then {
						if ({(_x select 0) == (_wpMarkers select 0)} count _weapons == 0) then {
							_weapons pushBack [(_wpMarkers select 0),_weapon];
						};
					};
				};
			};

		} foreach _unitData;
	} foreach A3C_STATIC_PACKS;
	{
		_wpn = (_x select 1);
		{
			if (_wpn == (_x select 1)) exitWith {
				A3C_STATIC_PACKS = A3C_STATIC_PACKS - [_x];
			};
		} foreach A3C_STATIC_PACKS;
	} foreach _weapons;
	_return = +(A3C_STATIC_PACKS);
	_return
};

A3C_WPstatementsASSEMBLE = {
	params [
		["_leader", objNull],
		["_weapon", ""]
	];
	// systemchat format ["A3C_WPstatementsASSEMBLE, weapon: %1", [_weapon]];
	private _weaponData = [units _leader, "PLANNING"] call A3C_getSelectionBackpackStatics;
	private _pVar = (group _leader) getVariable ["A3C_UNIT_POLYS", []];
	private _dir = 0;

	{
		private _poly = _x;
		private _polyID = (_poly select 0) select 1;

		if (["ASS", _polyID] call BIS_fnc_inString) then {
			_dir = [_leader, (_poly select 0) select 0] call BIS_fnc_dirTo;
			_pVar = _pVar - [_poly];
		};
	} forEach _pVar;

	// systemChat format ["A3C_WPstatementsASSEMBLE weaponData: %1", _weaponData];

	private _selectedWeaponData = [];

	if (_weapon != "") then {
		private _idx = _weaponData findIf { (_x select 1) isEqualTo _weapon };
		if (_idx > -1) then {
			_selectedWeaponData = _weaponData select _idx;
		};
	} else {
		if !(_weaponData isEqualTo []) then {
			_selectedWeaponData = _weaponData select 0;
		};
	};

	if !(_selectedWeaponData isEqualTo []) then {
		[
			units _leader,
			["ASSEMBLE", _selectedWeaponData select 1],
			position _leader,
			_dir
		] spawn A3C_WP_ACTION_STATICWEAPON;
	};

	(group _leader) setVariable ["A3C_UNIT_POLYS", _pVar, true];
};


A3C_STATIC_PREPARE_DISASSEMBLY = {
	params ["_units","_busyUnits","_staticData","_weaponPos","_weaponDir","_maxDistance"];
	_backPacks = getArray (configfile >> "CfgVehicles" >> typeOf (_staticData select 1) >> "assembleInfo" >> "dissasembleTo");
	_IFA_items = getArray (configfile >> "CfgVehicles" >> (typeOf (_staticData select 1)) >> "assembleInfo" >> "LIB_dissasembleTo");
	_staticMagazinesCount = if (count _IFA_items > 0) then {count (magazines (_staticData select 1))} else {0};
	_unitsRequired =	2; //-- start with 2 required units. in IFA's case, this number may change to 1

	_isUnitsRequired = true;
	_IFA_isTurretAssigned = false;
	_IFA_isPodAssigned = false;
	_hasPickupAssigned = [];
	private _podClass = if (count _IFA_items > 0) then {getText (configfile >> "CfgVehicles" >> (_IFA_items select 1) >> "LIB_Equipped_Tripod_Name")} else {""};

	private _noBackPackUnits = [];
	private _unarmedUnits = [];
	{
		if (primaryWeapon _x == "") then {
			_units = _units - [_x];
			_unarmedUnits pushBackUnique _x;
		};
	} foreach _units;
	_nonSecUnits = [];
	{
		if (secondaryWeapon _x == "") then {
			_units = _units - [_x];
			_nonSecUnits pushBackUnique _x;
		};
	} foreach _units;

	//-- sort _units (at this point ALL entries will be units WITH a secondaryWeapon.
	//-- We need units without IFA parts or ammo for their secondaryWeapon to be used before their counterparts
	_units =
	[
		_units,
		[],
		{
			_u = _x;
			_value = 0;
			if (A3C_IsIFA) then { //lib_equipped
				//_podWeaponClass = getText (configfile >> "CfgVehicles" >> _staticPod >> "LIB_Equipped_Tripod_Name")
				{
					_parts = _x select 1;
					if (secondaryWeapon _u in [_parts select 0,getText (configfile >> "CfgVehicles" >> _parts select 1 >> "LIB_Equipped_Tripod_Name")]) exitWith {
						_value = 2;
					};
				} foreach A3C_IFA_StaticPartPairs;
			};
			if (_value == 0) then { //-- value has not been added, which means that secWeapon is not an IFA-weaponpart
				_launcherMags = getArray (configfile >> "CfgWeapons" >> secondaryWeapon _x >> "magazines");
				if ({_x in _launcherMags} count (magazines _u + (secondaryWeaponMagazine _u) ) > 0) then {
					//-- unit has launcher with mags - do NOT allow static pickup
					_value = 1;
				};
			};
			_value
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	_units = _unarmedUnits + _nonSecUnits + _units; //-- this is for IFA MG's, so that the guys without gun are checked first, then units with prim weapon and NO secondary, then rest
	{

		if (count _IFA_items > 0) then {
			if (_isUnitsRequired) then {
				//-- IFA turrets can be carried as Rifles (MG) or laucnhers (Mortar)
				if !(_IFA_isTurretAssigned) then {
					if ((_IFA_items select 0) isKindOf ["Rifle", configFile >> "CfgWeapons"]) then {
						_IFA_isTurretAssigned = true;
						_busyUnits pushBackUnique _x;
					} else {
						if ((_IFA_items select 0) isKindOf ["Launcher", configFile >> "CfgWeapons"]) then {
							if ([_x] call A3C_STATIC_isSecondaryAllowed) then {
								_IFA_isTurretAssigned = true;
								_busyUnits pushBackUnique _x;
								_hasPickupAssigned pushBackUnique _x;
								//systemchat format ["%1 is taking turret (tube)",_x];
							};
						};
					};

				};
			};
		} else {


			{
				if (backPack _x  == "") then {
					_noBackPackUnits pushBackUnique _x;
					_units = _units - [_x];
				};
			} foreach _units;



		};
	} foreach _units;

	if (count _IFA_items > 0) then {

		//-- put busy units last in _unitArray
		_units = (_units - _busyUnits) + _busyUnits;


		//-- for IFA etc we only assign the tripod NOW. MG gunners COULD pick up the tripod themselves, but we only want that if no other unit can do the job (respecting unit stamina)
		_assistingUnits = [];
		{
			if (secondaryWeapon _x == "") then {
				if !(_x in _busyUnits) then {
					_units = _units - [_x];
					_assistingUnits pushBackUnique _x;
				};
			};
		} foreach _units;
		_units = _assistingUnits + _units; //-- units with secondaryWeapons as well as the turret units will be moved to the back of the array;
		{
			//-- IFA pods are always carried as launchers
			if !(_IFA_isPodAssigned) then {
				if ([_x] call A3C_STATIC_isSecondaryAllowed) then {
					if !(_x in _hasPickupAssigned) then {
						_IFA_isPodAssigned = true;
						_busyUnits pushBackUnique _x;
					};
				};
			};
			if (_IFA_isPodAssigned && _IFA_isPodAssigned) exitWith {
				_isUnitsRequired = false;
				_unitsRequired = count _busyUnits;
			};
		} foreach _units;
	} else {
		//-- sort units by value of backpack contents (units with no valuable contents first)
		_units =
		[
			_units,
			[],
			{
				private _u = _x;
				private _bpI = backPackItems _u;
				private _bpV = 0; //-- backPack value
				{
					_item = _x;

					//-- determine if item is a tool or medi kit
					_itemType = getNumber (configfile >> "CfgWeapons" >> _item >> "ItemInfo" >> "type");
					if (_itemType in [619,620]) then {
						//-- item is repair or medikit. add value of 10
						_bpV = _bpV + 10;
					};
					//-- check magazine items and assigne value to missiles and other
					if (_item in magazines _u) then {
						private _ammo = getText (configfile >> "CfgMagazines" >> _item >> "ammo");
						private _aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
						if (_aiAmmousageFlags == "") then {
							_aiAmmoUsageFlags = str (getNumber (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags"));
						};
						private _parents = [ (configfile >> "CfgAmmo" >> _ammo),true] call BIS_fnc_returnParents;
						if (({[_x,_aiAmmoUsageFlags] call MCSS_fnc_isInString} count ['128','256','512'] ) > 0) then {
							//if ({_x in _parents} count ["BulletBase","Grenade","GrenadeBase","GrenadeCore"] == 0) then {

							if ({_x in _parents} count ["MissileBase","MissileCore","RocketBase","RocketCore"] > 0) then {
								//-- item is missile or rocket. assign value of 5
								_bpV = _bpV + 5;
							} else {
								//-- bullet-mag with high damage capability or grenade: add 0.5 value
								_bpV = _bpV + 0.5;
							};
						};
					};
				} foreach _bpI;
				_bpV;
			},
			"ASCEND"
		] call BIS_fnc_sortBy;
		_noBackPackUnits = [_noBackPackUnits,[],{_x distance (_staticData select 1)},"ASCEND"] call BIS_fnc_sortBy;
		_units = _noBackPackUnits + _units; //-- final sort units: no backPack units + units sorted by content value of backpack
		{
			if ( (_x distance (_staticData select 1) < _maxDistance) && {count _busyUnits < 2}) then {
				if (count _busyUnits < _unitsRequired) then {
					_busyUnits pushback _x;
					if (count _busyUnits == 2) then {
						_isUnitsRequired = false;
					};
				};
			};
		} foreach _units;
	};
	[_busyUnits,_unitsRequired,_isUnitsRequired,_IFA_items,_staticMagazinesCount]
};


//-- WAYPOINT ACTION assemble and disassemble
A3C_WP_ACTION_STATICWEAPON = { //~~ ISN'T THERE ANOTHER ASSEMBLE FNC? IF YES, DO THEY NEED TO BE DIFFERENT?? #DOUBLES
	params ["_units","_staticData","_weaponPos","_weaponDir"];
	private ["_busyUnits","_backPacks","_weapons"];
	_busyUnits = [];
	_backPacks = [];
	_weapons = []; //-- only relevant for IFA, which uses wepaons instead of backpacks
	
	if (_staticData select 0 == "ASSEMBLE") then {
		{
			// unassignvehicle _x;
			[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
		} foreach _units;

		[_units,"EXECUTING"] call A3C_getSelectionBackpackStatics;

		{
			private _build = false;
			private _staticSize = sizeOf (_x select 1);
			_busyUnits = _x select 0; //-- when assembline, unit order should be [turretGuy,tripodGuy]
			if (_x select 1 == _staticData select 1) then {
				if ({alive _x} count _busyUnits == 2) then {
					_build = true;
				};
			};
			if (_build) exitWith {
				private _weapons = getArray (configfile >> "CfgVehicles" >> (_staticData select 1) >> "assembleInfo" >> "LIB_dissasembleTo");
				if (count _weapons > 0) then {
					_weapons set [1,getText (configfile >> "CfgVehicles" >> (_weapons select 1) >> "LIB_Equipped_Tripod_Name")];
				};
				_removeGunnerMags = false; //-- part of the static may be a unit's primaryWeapon. If so, we have to remove his mags later.
				{
					if (count _weapons == 0) then { //-- no weapons: static is default type (backpack method)
						_backPacks pushBack (backPack _x);
						[_x] remoteExec ["removeBackpack", _x];
					} else { //-- yes weapons: model is IFA
						_unitWeaponPart = _weapons select _foreachIndex;
						if (	(primaryWeapon (_busyUnits select 0)) == _unitWeaponPart) then {
							_removeGunnerMags = true;
						};
						[_x,_unitWeaponPart] remoteExec ["removeWeapon", _x];

					};
					_x spawn {
						[_this,"ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove",_this];
						sleep 7;
						if (animationState _this == "ainvpknlmstpslaywrfldnon_medic") then {
							[_this,"amovpknlmstpslowwrfldnon"] remoteExec ["playMove",_this];
						};
					};
					[_x, position _x] remoteExec ["doMove", _x];
					
					
				} foreach _busyUnits;
				sleep 2;
				while {true} do {
					//-- abort: if builder(s) die(s), abort and reissue backPack to (best way to cancel and not lose items)
					if ({alive _x} count _busyUnits != 2) exitWith {
						if (count _weapons == 0) then {
							{
								[_x,(_backPacks select _foreachIndex)] remoteExec ["addBackPack",_x];
							} foreach _busyUnits;
						} else {
							[_x, (_weapons select _foreachIndex)] remoteExec ["addWeapon", _x];
						};
					};
					//-- assembly done!
					if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _busyUnits == 0) exitWith {
						if (count _weapons > 0) then { //-- count _weapons > 0 : static is an IFA model
							 //-- reset tripod to weaponclass
							if (_removeGunnerMags) then {
								_primaryMags = getArray (configfile >> "CfgWeapons" >> (_weapons select 0) >> "magazines");
								{
									if (_x in _primaryMags) then {
										[(_busyUnits select 0),_x] remoteExec ["removeMagazine",(_busyUnits select 0)];
									};
								} foreach (magazines (_busyUnits select 0));
							};
						};
						getArray (configfile >> "CfgVehicles" >> typeof cursortarget >> "assembleInfo" >> "LIB_dissasembleTo");

						_weaponPos set [2,0];
						private _terrainVectors = [_weaponPos,_weaponDir] call MCSS_fnc_TerrainTilt;
						_vehicleWeapon = (_x select 1) createVehicle _weaponPos;


						[_vehicleWeapon,ATLtoASL _weaponPos] remoteExec ["setPosASL",_vehicleWeapon];

						[_vehicleWeapon,_terrainVectors] remoteExec ["setVectorDirAndUp",_vehicleWeapon];
						sleep 0.1;
						_vehicleWeapon setVectorUp (surfaceNormal _weaponPos); //?? does not mix well with the above use of 'setVectorDirAndUp'
						_centerMass = getCenterOfMass _vehicleWeapon;
						_vehicleWeapon enableSimulationGlobal false;
						sleep 1.5;
						_vehicleWeapon enableSimulationGlobal true;
						[(_busyUnits select 0),_vehicleWeapon] remoteExec ["assignAsGunner",(_busyUnits select 0)];
						[(_busyUnits select 0),["getInGunner", _vehicleWeapon]] remoteExec ["action",(_busyUnits select 0)];



						_randomVal = floor (random 31);
						if (floor random 2 == 0) then {
							_randomVal = _randomVal * -1;
						};
						_assistantPos = _weaponPos getPos [(random 4) max 1,(getDir _vehicleWeapon) + 180 +  _randomVal];
						[_busyUnits select 1,_assistantPos] call A3C_DOMOVE;
						[_busyUnits select 1,_weaponPos getPos [50,getDir _vehicleWeapon]] remoteExec ["lookAt",_busyUnits select 1];


						private _isCorrection = false;

						{
							_massArrayIndex = _x;
							{
								_x params ["_s","_f"];
								for "_i" from _s to _f step 0.1 do {
									_centerMassTest = +(_centerMass);
									_centerMassTest set [_massArrayIndex,(_centerMassTest select _massArrayIndex) + _i];
									_vehicleWeapon setCenterOfMass _centerMassTest;
									_vehicleWeapon setVectorUp (surfaceNormal _weaponPos);
									[_vehicleWeapon,ATLtoASL _weaponPos] remoteExec ["setPosASL",_vehicleWeapon];
									_isCorrection = false;
									sleep .2;
									_timer = time;
									while {time - _timer < 5} do {
										if ({abs _x > 0.3} count velocity _vehicleWeapon > 0) exitWith {_isCorrection = true};
										sleep 0.1;
									};
									if !(_isCorrection) exitWith {};
								};
								if !(_isCorrection) exitWith {};
							} foreach [[0,0.3], [-0.3,-0.1]];
							
							
							if !(_isCorrection) exitWith {};
						} foreach [0,1,2];
					};
					sleep 0.2;
				};
				//systemChat str _busyUnits;
				{
					(group _x) setVariable ["A3C_ASSEMBLING",nil,true];
				} foreach _busyUnits;
			};
		} foreach A3C_STATIC_PACKS;
	} else {
		_data = [_units,_busyUnits,_staticData,_weaponPos,_weaponDir,30] call A3C_STATIC_PREPARE_DISASSEMBLY;
		_data params ["_busyUnits","_unitsRequired","_isUnitsRequired","_IFA_items","_staticMagazinesCount"];

		if (_isUnitsRequired) exitWith {
			systemchat format ["A3C: Current selection (%1) is not suitable to pick up this weapon",group (_units select 0)];
		};
		if (count _busyUnits == _unitsRequired) then { //-- >= because IFA MG's
			{
				_x spawn {
					[_this,"ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove",_this];
					sleep 7;
					if (animationState _this == "ainvpknlmstpslaywrfldnon_medic") then {
						[_this,"amovpercmstpslowwrfldnon"] remoteExec ["playMove",_this];
					};
				};
			} foreach _busyUnits;
			sleep 2;

			while {true} do {
				if ({alive _x} count _busyUnits != _unitsRequired) exitWith {};
				if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _busyUnits == 0) exitWith {
					deletevehicle (_staticData select 1);
					if (count _busyUnits == 1) then {
						_busyUnits = _busyUnits + _busyUnits; //-- if only one unit is required, duplicate unt inside of array so the forEach loop wil still work
					};
					if (count _backPacks > 0) then {
						{
							[_x,(_backPacks select _foreachIndex)] remoteExec ["addBackpack",_x];  //--- ??? WHAT HAPPENS IF THERE IS # UNITS WITHOUT BACKPACK IN SELECTION?
						} foreach _busyUnits;
					};
					if (count _IFA_items > 0) then {

						//-- sloppy method but I don't know better beacsue fnc_sortby does not work here

						//-- create weaponholder FIRST so that everything can be added to it.
						_weaponPos = ((_busyUnits select 0) modelToWorld ((_busyUnits select 0) selectionposition "weapon"));
						_weaponHolder = "GroundWeaponHolder" createVehicle _weaponPos;

						//-- 1. assign turret first!
						private _exit = false;
						{
							_u = _x;
							if ((_IFA_items select 0) isKindOf ["Rifle", configFile >> "CfgWeapons"]) then {
								if (primaryWeapon _u != "") then {
									_weaponType = [primaryWeapon _u] call TAG_fnc_baseWeapon;
									_magazines = [currentMagazine _u];
									_weaponItems = primaryWeaponItems _u;

									_weaponMagTypes = getArray (configfile >> "CfgWeapons" >> _weaponType >> "magazines");
									{
										if (_x in _weaponMagTypes) then {
											_magazines pushBack _x;
											[_u,_x] remoteExec ["removeMagazine",_u];
										};
									} foreach (magazines _x);

									_weaponHolder addWeaponCargoGlobal [_weaponType,1];
									{
										_weaponHolder addMagazineCargoGlobal [_x,1];
									} foreach _magazines;
									{
										_weaponHolder addItemCargoGlobal [_x,1];
									} foreach _weaponItems;
									[_u,_weaponType] remoteExec ["removeWeapon",_u];
								};
								_exit = true;
							} else {
								if ([_x] call A3C_STATIC_isSecondaryAllowed) then {
									//systemchat format ["Assigning Turret (Tube) to %1", _x];
									_exit = true;
								};
							};
							if (_exit) exitWith {
								[_x,(_IFA_items select 0)] remoteExec ["addWeapon",_x];
								[_x,(_IFA_items select 0)] remoteExec ["selectWeapon",_x];
								if ((_IFA_items select 0) isKindOf ["Rifle", configFile >> "CfgWeapons"]) then {
									_newMagType = (getArray (configfile >> "CfgWeapons" >> (_IFA_items select 0) >> "magazines")) select 0;
									if (_staticMagazinesCount != 0) then {
										for "_i" from 1 to _staticMagazinesCount do {
											[_x,_newMagType] remoteExec ["addMagazine",_x];
										};
									};
								};
							};
						} foreach _busyUnits;

						//-- 2. add pod
						{
							_u = _x;
							if !(_foreachIndex == 0 && count _busyUnits > 1) then {      //} else {
								if ([_x] call A3C_STATIC_isSecondaryAllowed) exitWith {
									//systemchat format ["Assigning Pod to %1", _x];
									if (secondaryWeapon _x != "") then {
										_weaponType = [secondaryWeapon _u] call TAG_fnc_baseWeapon;
										_magazines = secondaryWeaponMagazine _u;
										_weaponItems = secondaryWeaponItems _u;

										_weaponMagTypes = getArray (configfile >> "CfgWeapons" >> _weaponType >> "magazines");
										{
											if (_x in _weaponMagTypes) then {
												_magazines pushBack _x;
												[_u,_x] remoteExec ["removeMagazine",_u]; //-- mags actually not needed for secondaryWeapons
											};
										} foreach (magazines _x);

										_weaponHolder addWeaponCargoGlobal [_weaponType,1];
										{
											_weaponHolder addMagazineCargoGlobal [_x,1];
										} foreach _magazines;
										{
											_weaponHolder addItemCargoGlobal [_x,1];
										} foreach _weaponItems;
										[_u,_weaponType] remoteExec ["removeWeapon",_u];
									};
									[_x,_podClass] remoteExec ["addWeapon",_x];
								};
							};
						} foreach _busyUnits;

						if (count weaponCargo _weaponHolder == 0) then {
							deleteVehicle _weaponHolder;
						};

					};
				};
				sleep 0.2;
			};
		};
	};
};

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