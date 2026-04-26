#include "..\ui\radial\radialMenu\dialog_defines.hpp"






///////////////// F N C S  -  E X E C U T E  O R D E R S  


A3C_ReArm_Auto_Evaluate = {
	
	if !(isClass (configFile / "CfgPatches" / "A3C_OBJECTS")) exitWith {}; //-- exit if run on a machine that does not run A3C

	private _unit = _this select 0;
	if (isPlayer _unit) exitWith {};

	private _crate = if (count _this > 1) then {_this select 1} else {objNull};
	if !((vehicle _unit) == _unit) exitWith {}; //-- script may only affect foot-soldiers

	private _switchWeapon = false;

	private _primaryMags = getArray (configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "magazines");
	private _secondaryMags = getArray (configFile >> "CfgWeapons" >> (secondaryWeapon _unit) >> "magazines");
	private _magArray = _primaryMags + _secondaryMags;

	private _primaryCount = {_x in _primaryMags} count (magazines _unit);
	private _secondaryCount = {_x in _secondaryMags} count (magazines _unit);

	//-- determine "modes": what stuff does the unit need (ammo, swap rifle, take backpack, take launcher)
	private _rMode = [_unit] call A3C_ReArm_Mode;
	_rMode params ["_priMode", "_secMode", "_bacMode"];

	//-- if no target is given, find possible sources to reArm from
	if (isNull _crate) then {
		private _list = [_unit, _priMode, _secMode, _bacMode, _magArray] call A3C_ReArm_GetSources;
		_list = [_list,[],{["LIGHT",_x] call A3C_REARM_QUALITY},"DESCEND"] call BIS_fnc_sortBy;
		if (count _list > 0) then {
			_crate = _list select 0;
		};
	};

	//-- spawn action if sources are close, otherwise send negative chat
	if !(isNull _crate) then {
		([_unit, _crate] + _rMode) spawn A3C_ReArm_Auto_OrderIssue;
	} else {
		_unit groupChat (
			[
				"I do not see any way to resupply",
				"Nothing here to benefit from",
				"No way to resupply here"
			] call BIS_fnc_SelectRandom
		);
	};
};


A3C_ReArm_Auto_OrderIssue = {
	params ["_unit", "_crate", "_priMode", "_secMode", "_bacMode"];

	if (isPlayer _unit) exitWith {};

	private _expDest = [_unit] call A3C_fnc_setDestination;
	private _cratePos = _crate getRelPos [3, random 360];

	_unit setVariable ["A3C_REARMING", true, true];

	private _markerName = format ["A3C_Mark_P%1", A3C_MARKER_COUNT];
	private _wpData =
	[
		[_cratePos, _cratePos getPos [100, _unit getDir _cratePos]], //-- positions
		[_markerName, _markerName, _markerName], //-- markers
		["REARM", [_crate, [[], _priMode, _secMode, _bacMode]]], //-- wp action
		["NONE", "NONE"], //-- WP Condition
		["UP", "UP"], //-- WP Stances
		[[0, false]], //-- WP Sync Data
		false, //-- isWPCompleted
		0, //-- Combat Mode
		-1, //-- WP Speed
		25, //-- WP Flying Height
		-1, //-- WP Loop Value
		-1.5 //-- radius
	];

	A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;

	_unit setVariable ["A3C_PLOT", [_wpData], true];
	[_unit, (_unit getVariable "A3C_PLOT")] spawn A3C_AI_Shared_executeUnitPlot;

	waitUntil {count (_unit getVariable ["A3C_PLOT", []]) == 0};

	//-- check if unit should stock up on meds
	private _unitItems = items _unit;
	private _hasMedical = A3C_MEDICAL_itemStrings findIf {
		private _needle = toLower _x;
		_unitItems findIf { _needle in toLower _x } != -1
	} != -1;

	if (!_hasMedical) then {
		//-- unit has no meds - add them if possible
		private _itemCount = 0;
		private _crateItems = itemCargo _crate;

		{
			private _item = _x;
			private _itemLower = toLower _item;

			if (A3C_MEDICAL_itemStrings findIf { _x in _itemLower } != -1) then {
				_unit addItem _item; //-- #TODO: Improve ACE compatibility? Not 100% necessary as any item is good enough to heal / revive
				_itemCount = _itemCount + 1;
			};

			if (_itemCount == 2) exitWith {};
		} forEach _crateItems;
	};

	[_unit] call A3C_AI_action_resumeDestination;
	_unit setVariable ["A3C_REARMING", nil, true];
};

A3C_ReArm_Plot_AddItem = {
	params ["_unit", "_source", "_item"];

	private _cratePos = getPosATL _source;
	private _wpData = _unit getVariable "A3C_PLOT";
	private _cancel = true;
	private _addWp = true;

	{
		private _wpAction = _x select 2;
		if ((_wpAction select 0) == "REARM") then {
			if (count (_wpAction select 1) > 0) then {
				//-- do not cancel if a unit has REARM action with data
				_cancel = false;
				if (((_wpAction select 1) select 0) == _source) then {
					//-- do not add wp if source is already in plans, just add item to array
					if (_item == "INVENTORY") then {
						((((_x select 2) select 1) select 1) select 0) pushBackUnique _item;
					} else {
						((((_x select 2) select 1) select 1) select 0) pushBack _item;
					};
					_addWp = false;
					_unit setVariable ["A3C_PLOT", _wpData, true];
				};
			};
		};
	} forEach _wpData;

	private _wpDataNew = [];

	if (_cancel OR _addWp) then {
		A3C_TEMP_WP_ID_SUB = format ["A3C_Mark_P%1", A3C_MARKER_COUNT];
		A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;
		A3C_MARKERS pushBack A3C_TEMP_WP_ID_SUB;

		_wpDataNew =
		[
			[_cratePos, _cratePos], //-- positions
			[A3C_TEMP_WP_ID_SUB, A3C_TEMP_WP_ID_SUB], //-- markers
			["REARM", [_source, [[_item], "", "", false]]], //-- wp action
			["NONE", "NONE"], //-- WP Condition
			["UP", "UP"], //-- WP Stances
			[[0, false]], //-- WP Sync Data
			false, //-- isWPCompleted
			0, //-- Combat Mode
			-1, //-- WP Speed
			25, //-- WP Flying Height
			-1, //-- WP Loop Value
			-1.5 //-- radius
		];
	};

	if (_cancel) then {
		if (count _wpData > 0) then {
			[[_unit], true, false] call A3C_AI_Shared_cancelUnitPlot;
		};
		waitUntil {count (_unit getVariable "A3C_PLOT") == 0};
		sleep 0.5;
		[_unit] call A3C_fnc_setDestination;

		_unit setVariable ["A3C_PLOT", [_wpDataNew], true];
		[_unit, (_unit getVariable "A3C_PLOT")] spawn A3C_AI_Shared_executeUnitPlot;

		[_unit] spawn {
			params ["_unit"];
			waitUntil {sleep 1; count (_unit getVariable "A3C_PLOT") == 0};
			[_unit] call A3C_AI_action_resumeDestination;
		};

	} else {
		if (_addWp) then {
			_wpData pushBack _wpDataNew;
			_unit setVariable ["A3C_PLOT", _wpData, true];
		};
	};
};

A3C_getFlatContainerItems = {
    params ["_container"];
    private _items = [];

    if (_container isKindOf "MAN") then {
        _items = + (itemsWithMagazines _container);

        private _bp = backPack _container;
        if (_bp != "") then {
            _items pushBack _bp;
        };

        private _headGear = headGear _container;
        if (_headGear != "") then {
            _items pushBack _headGear;
        };

        private _goggles = goggles _container;
        if (_goggles != "") then {
            _items pushBack _goggles;
        };
    } else {
        _items = (weaponCargo _container) + (magazineCargo _container) + (itemCargo _container) + (backPackCargo _container);
    };

    _items
};


A3C_ReArm_Plot_Behavior = {
	params ["_unit", "_reArmData"];

	if (isPlayer _unit) exitWith {};
	if (count _reArmData == 0) exitWith {};

	private _crate = _reArmData select 0;
	(_reArmData select 1) params ["_items", "_priMode", "_secMode", "_bacMode"];

	private _gun = "";
	// private _handgun = "";

	_unit doWatch _crate;
	sleep 1.5;

	private _containers = [_crate];

	if (_crate isKindOf "MAN") then {
		private _corpseWeaponHolders = getCorpseWeaponholders _crate;
		_containers append _corpseWeaponHolders;
	};

	private _containerContentMap = _containers apply { [_x] call A3C_getFlatContainerItems };

	private _fnc_removeFromContentMap = {
		params ["_item", "_itemContainer"];

		if (_item == "INVENTORY") exitWith {};

		private _containerIndex = _containers find _itemContainer;
		if (_containerIndex == -1) exitWith {};

		private _containerItems = _containerContentMap select _containerIndex;
		private _itemIndex = [_item, _containerItems] call MCSS_fnc_GetArrayIndex;

		if (_itemIndex != -1) then {
			_containerItems deleteAt _itemIndex;
			_containerContentMap set [_containerIndex, _containerItems];
		};
	};

	private _fnc_refreshContentMap = {
		_containerContentMap = _containers apply { [_x] call A3C_getFlatContainerItems };
	};

	//-- collect single item
	if (count _items > 0) then {
		//-- reset default modes since we are collecting targeted items
		_priMode = "";
		_secMode = "";
		_bacMode = false;

		{
			private _item = _x;
			private _itemContainer = [_item, _crate, _containers, _containerContentMap] call A3C_getItemContainer;

			switch (true) do {
				case (_item == "INVENTORY"): {
					private _p = _crate getPos [sizeOf (typeOf _crate) * 0.7, _crate getDir _unit];
					[_unit, _p] call A3C_DOMOVE;
					_unit setPos _p;
					_unit setDir (_unit getDir _crate);
					_unit action ["GEAR", _crate];
					_unit forceSpeed 0;
					waitUntil {isNull (findDisplay 602)};
					_unit forceSpeed -1;
				};

				case (isClass (configFile >> "CfgWeapons" >> _item)): {
					if ({_item isKindOf [_x, configFile >> "CfgWeapons"]} count ["Rifle", "Launcher", "Pistol"] > 0) then {

						[[_unit, _itemContainer, _item], A3C_Rearm_TakeWeapon] remoteExec ['bis_fnc_call', _unit];
						
						[_item, _itemContainer] call _fnc_removeFromContentMap;

						[_unit, _item] spawn {
							params ["_unit", "_weapon"];
							sleep 3;
							_unit selectWeapon _weapon;
						};
					} else {
						private _macro = getText (configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "_generalMacro");
						if (_macro == "") then {
							_macro = getText (configFile >> "CfgWeapons" >> _item >> "_generalMacro");
						};

						switch (true) do {
							case (_macro in ["Binocular", "Laserdesignator", "Rangefinder"]): {
								private _bino = binocular _unit;
								_unit removeWeapon _bino;
								_unit addWeapon _item;
								_unit assignItem _item;

								if (_itemContainer isKindOf "MAN") then {
									_itemContainer removeWeapon _item;
									if (_bino != "") then {
										_itemContainer addWeapon _bino;
									};
								} else {
									private _cargo = weaponCargo _itemContainer;
									if (_bino != "") then {
										_cargo = _cargo + [_bino];
									};
									{
										if (_x == _item) exitWith {
											_cargo deleteAt _forEachIndex;
										};
									} forEach _cargo;
									clearWeaponCargoGlobal _itemContainer;
									{
										_itemContainer addWeaponCargoGlobal [_x, 1];
									} forEach _cargo;
								};

								[_item, _itemContainer] call _fnc_removeFromContentMap;
							};

							case (_macro == "HeadgearItem"): {
								private _headGear = headGear _unit;
								_unit removeWeapon _headGear;
								_unit addWeapon _item;
								_unit assignItem _item;

								if (_itemContainer isKindOf "MAN") then {
									removeHeadgear _itemContainer;
									if (_headGear != "") then {
										_itemContainer addHeadGear _headGear;
									};
								} else {
									private _cargo = itemCargo _itemContainer;
									{
										if (_x == _item) exitWith {
											_cargo deleteAt _forEachIndex;
										};
									} forEach _cargo;
									if (_headGear != "") then {
										_cargo = _cargo + [_headGear];
									};
									clearItemCargoGlobal _itemContainer;
									{
										_itemContainer addItemCargoGlobal [_x, 1];
									} forEach _cargo;
								};

								[_item, _itemContainer] call _fnc_removeFromContentMap;
							};

							default {
								private _parent1 = configName (inheritsFrom (configFile >> "CfgWeapons" >> _item));
								private _parent2 = configName (inheritsFrom (configFile >> "CfgWeapons" >> _parent1));

								private _isVest = {"vest" in toLower _x} count [_parent1, _parent2] > 0;
								private _switchWeapon = "";
								private _vest = "";
								private _vestItems = [];

								switch (true) do {
									case (_isVest): {
										_vest = vest _unit;
										_vestItems = vestItems _unit;
										_unit addVest _item;
										_switchWeapon = vest _unit;
									};

									default {
										if (_unit canAdd _item) then {
											_unit addItem _item;
											if ([_item] call LRRW_fnc_isItemAssignable) then {
												_unit assignItem _item;
											};
										};
									};
								};

								if (_itemContainer isKindOf "MAN") then {
									if (_isVest) then {
										private _crateItems = vestItems _itemContainer;
										removeVest _itemContainer;
										{ _unit addItemToVest _x } forEach (_crateItems + _vestItems);
										if (_vest != "") then {
											_itemContainer addVest _vest;
										};
									} else {
										_itemContainer removeWeapon _item;
									};
								} else {
									private _cargo = itemCargo _itemContainer;
									{
										if (_x == _item) exitWith {
											_cargo deleteAt _forEachIndex;
										};
									} forEach _cargo;
									if (_vest != "") then {
										_cargo = _cargo + [_vest];
									};
									clearItemCargoGlobal _itemContainer;
									{
										_itemContainer addItemCargoGlobal [_x, 1];
									} forEach _cargo;
									{ _unit addItemToVest _x } forEach _vestItems;
								};

								[_item, _itemContainer] call _fnc_removeFromContentMap;
							};
						};

						_unit playMoveNow "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown";
					};
				};

				case (isClass (configFile >> "CfgMagazines" >> _item)): {
					_unit action ["TakeMagazine", _itemContainer, _item];
					_unit addMagazine _item;
					[_item, _itemContainer] call _fnc_removeFromContentMap;
				};

				case (isClass (configFile >> "CfgVehicles" >> _item)): {
					_unit action ["AddBag", _itemContainer, _item];
					[_item, _itemContainer] call _fnc_removeFromContentMap;
				};
			};

			
			sleep 2;
			[] call A3C_UPDATE_UI_REARM;
		} forEach _items;
	};

	if (_bacMode) then {
		private _bag = "";
		private _bagContainer = objNull;

		{
			private _bags = if (_x isKindOf "MAN") then {
				private _bp = backPack _x;
				if (_bp != "") then {[_bp]} else {[]};
			} else {
				backPackCargo _x
			};

			if (count _bags > 0) exitWith {
				_bag = _bags select 0;
				_bagContainer = _x;
			};
		} forEach _containers;

		if (_bag != "" && {!isNull _bagContainer}) then {
			_unit action ["AddBag", _bagContainer, _bag];
			[_bag, _bagContainer] call _fnc_removeFromContentMap;
			[] call A3C_UPDATE_UI_REARM;
			sleep 1.5;
		};
	};

	if ((_priMode == "PRI_RESUPPLY") OR (_secMode == "SEC_RESUPPLY")) then {
		{
			_unit action ["rearm", _x];
		} forEach _containers;

		
		sleep 3;
		[] call _fnc_refreshContentMap;
		[] call A3C_UPDATE_UI_REARM;
	};

	if (_priMode == "PRI_REARM") then {
		private _weapons = [];
		{
			if (_x isKindOf "MAN") then {
				_weapons append (weapons _x);
			} else {
				_weapons append (weaponCargo _x);
			};
		} forEach _containers;

		{
			if (getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 1) then {
				_gun = _x;
			};
		} forEach _weapons;

		if (_gun != "") then {
			private _gunContainer = [_gun, _crate, _containers, _containerContentMap] call A3C_getItemContainer;

			[[_unit, _gunContainer, _gun], A3C_Rearm_TakeWeapon] remoteExec ['bis_fnc_call', _unit];
						
			[_gun, _gunContainer] call _fnc_removeFromContentMap;
			sleep 2;

			{
				_unit action ["rearm", _x];
				sleep 2;
			} forEach _containers;

			
			sleep 2;
			[] call A3C_UPDATE_UI_REARM;
			[] call _fnc_refreshContentMap;

			// _handgun = handgunWeapon _unit;
			// _unit removeWeapon _handgun;
			// sleep 1;
			// _unit addWeapon _handgun;

		};

		sleep 1;
	};

	if (_secMode == "SEC_REARM") then {
		private _weapons = [];
		{
			if (_x isKindOf "MAN") then {
				_weapons append (weapons _x);
			} else {
				_weapons append (weaponCargo _x);
			};
		} forEach _containers;

		{
			if (getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 4) exitWith {
				_gun = _x;
			};
		} forEach _weapons;

		if (_gun != "") then {
			private _unitWeapons = getArray (configFile >> "CfgVehicles" >> typeOf _unit >> "weapons");
			private _gunContainer = [_gun, _crate, _containers, _containerContentMap] call A3C_getItemContainer;

			if (({getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 4} count _unitWeapons > 0) OR ({secondaryWeapon _x != ""} count (units player - [player]) == 0)) then {
				[[_unit, _gunContainer, _gun], A3C_Rearm_TakeWeapon] remoteExec ['bis_fnc_call', _unit];
				[_gun, _gunContainer] call _fnc_removeFromContentMap;
				sleep 2;
			};

			{
				_unit action ["rearm", _x];
			} forEach _containers;

			
			sleep 2;
			[] call A3C_UPDATE_UI_REARM;
			[] call _fnc_refreshContentMap;

			// _handgun = handgunWeapon _unit;
			// _unit removeWeapon _handgun;
			// sleep 1;
			// _unit addWeapon _handgun;

			[] call A3C_UPDATE_UI_REARM;
		};
	};

	if (secondaryWeapon _unit != "") then {
		private _wpn = secondaryWeapon _unit;
		private _launcherAmmo = getArray (configFile >> "CfgWeapons" >> _wpn >> "magazines");
		private _crateAmmo = [];
		private _takenMags = [];

		{
			if (_x isKindOf "MAN") then {
				_crateAmmo append (magazines _x);
			} else {
				_crateAmmo append (magazineCargo _x);
			};
		} forEach _containers;

		{
			if (_x in _launcherAmmo) then {
				private _magContainer = [_x, _crate, _containers, _containerContentMap] call A3C_getItemContainer;

				if (count (secondaryWeaponMagazine _unit) == 0) then {
					_unit addSecondaryWeaponItem _x;
					_takenMags pushBack [_x, _magContainer];
					[_x, _magContainer] call _fnc_removeFromContentMap;
				} else {
					if (_unit canAddItemToBackpack _x) then {
						_unit addItemToBackpack _x;
						_takenMags pushBack [_x, _magContainer];
						[_x, _magContainer] call _fnc_removeFromContentMap;
					};
				};
			};
		} forEach _crateAmmo;

		{
			private _mag = _x select 0;
			private _magContainer = _x select 1;

			if (_magContainer isKindOf "MAN") then {
				_magContainer removeMagazineGlobal _mag;
			} else {
				private _containerMags = magazineCargo _magContainer;
				private _arrayIndex = [_mag, _containerMags] call MCSS_fnc_GetArrayIndex;

				if (_arrayIndex != -1) then {
					_containerMags deleteAt _arrayIndex;
				};

				clearMagazineCargoGlobal _magContainer;
				{
					_magContainer addMagazineCargoGlobal [_x, 1];
				} forEach _containerMags;
			};
		} forEach _takenMags;

		[] call A3C_UPDATE_UI_REARM;
	};

	_unit doWatch objNull;
	_unit lookAt objNull;
};




/////////////////  H E L P E R S

A3C_Rearm_TakeWeapon = {
	//-- since remoteExec is always CALL instead of SPAWN (even for bis_fnc_spawn), we need to spawn the fnc to allow sleep.
	_this spawn {
		params ["_unit","_container","_weapon"];
		if (_container isKindOf "MAN" && {!alive _container}) then {
			//-- taking weapon from actual dead units should commonly only relate to handGun
			//-- TakeWeapon Action does not seem to work in this case. So we handle things manually
			_unit playMoveNow "amovpknlmstpsnonwnondnon_ainvpknlmstpsnonwnondnon_putdown";
			sleep 1;
			private _unitWeapon = switch (true) do {
				case (_weapon isKindOf ["Rifle", configFile >> "CfgWeapons"]) : {primaryWeapon _unit};
				case (_weapon isKindOf ["Pistol", configFile >> "CfgWeapons"]) : {handGunWeapon _unit};
				case (_weapon isKindOf ["Launcher", configFile >> "CfgWeapons"]) : {secondaryWeapon _unit};
				default {""};
			};

			if (_unitWeapon != "") then {
				_unit removeWeapon _unitWeapon;
				_container addWeapon _unitWeapon;
			};

			_container removeWeapon _weapon;
			_unit addWeapon _weapon;
		} else {
			_unit action ["TakeWeapon", _container, _weapon];
		};
	};

	
};

A3C_getItemContainer = {
	params ["_item", "_crate", "_containers"];
	private _containerContentMap = if (count _this > 3) then {_this select 3} else {[]};


	if (_item == "INVENTORY") exitWith {_crate};

	if (_containerContentMap isEqualTo []) then {
		_containerContentMap = _containers apply {[_x] call A3C_getFlatContainerItems};
	};
	

	private _containerIndex = _containerContentMap findIf {
		_item in _x
	};

	if (_containerIndex == -1) exitWith {_crate};

	_containers select _containerIndex
};

//-- Find possible sources to reArm from and put them in order << #TODO WHY ORDER? is that not done later?
A3C_ReArm_GetSources = {
	params ["_unit","_priMode","_secMode","_bacMode","_magArray"];
	if (isPlayer _unit) exitWith {[]};

	
	
	private _weapons = [];

	//-- find containers 
	
	private _containersOther = nearestObjects [_unit, ["CAR","HELICOPTER","SHIP","TANK"], 100];

	private _list = _containersOther;

	//-- exclude empty sources
	_list = _list select 
	{
		private _content = (weaponCargo _x) + (magazineCargo _x) + (itemCargo _x) + (backpackCargo _x);
		count _content > 0 
	};

	//-- find corpses (Single unit re-arm only)
	if (count A3C_RD_UNITS == 1) then {

		private _containersHolders = (nearestObjects [_unit, A3C_WeaponHolderClasses, 100]) select {
			//-- exclude corpse-weaponHolders (will be dealt with later)
			isNull (getCorpse _x)
		};
		private _corpses = (nearestObjects [_unit, ["MAN"], 100]) select
		{
			!alive _x && 
			{
				isNull (objectParent _x) && {
					private _backPack = if (backPack _x == "") then {[]} else {[backPack _x]};
					count ((weapons _x) + (magazines _x) + _backPack) > 0
				}
			}
		};

		
		_list = _list + _containersHolders + _corpses;
	};
	
	switch (_PriMode) do {
		case ("PRI_RESUPPLY") : {
								
		};
		case ("PRI_REARM") : {
			//-- primary weapon re-arm requires primary weapons to be present :)
			if (_secMode == "SEC_NONE") then {
				_list = _list select {
					private _source = _x;
					private _weapons = if (_source isKindOf "MAN") then {
						private _w = + (weapons _source);
						{
							_w append (weaponCargo _x);
						} forEach (getCorpseWeaponholders _source);
						_w
					} else {
						weaponCargo _source
					};

					_weapons findIf {
						getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1
					} != -1
				};
			};
			
		};
	};
	switch (_PriMode) do {
		case ("SEC_RESUPPLY") : {
								
		};
		case ("SEC_REARM") : {		
			if (_priMode == "PRI_NONE") then {
				_list = _list select {
					private _source = _x;
					private _weapons = if (_source isKindOf "MAN") then {
						weapons _source
					} else {
						weaponCargo _source
					};

					_weapons findIf {
						getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4
					} > -1
				};
			};
		};
	};
	
	// //-- THIS PART MAY BE REDUNDATNT. CLARIFY: WHY WOULD WE DITCH SOURCES BY DEFAULT?
	// //-- IS SORTING NOT OVERWRITTEN LATER??
	// //-- Note At this point, there's only containers left with some kind of goods

	// //-- sorting may have to be dcne in the other fnc
	// //-- limit to upper range and find closest  #TODO Shorten/Optimize entire code

	// //-- create score map array
	// private _scoreMap = _list apply {[_unit,_x,_priMode,_secMode,_bacMode] call A3C_REARM_QUALITY};
	// //-- get highest score from map
	// private _highestScore = -1;
	// {
	// 	if (_x > _highestScore) then {_highestScore = _x};
	// } foreach _scoreMap;
	// //-- remove sources that are not as good
	// {
	// 	if (_scoreMap select _foreachindex < (_highestScore * 0.8)) then {
	// 		_list = _list - [_x];
	// 	};
	// } foreach _list;

	// //-- sort good sources by distance
	// _list = 
	// [
	// 	_list,
	// 	[],
	// 	{
	// 		(getPosASL _x) distance2D (getPosASL _unit);
	// 	},
	// 	"ASCEND"
	// ] call BIS_fnc_sortBy;

	_list
	
};

//-- determine the 'quality' of a reArm-source, depending on what the unit needs
A3C_REARM_QUALITY = {
	private ["_unit","_holder","_quali","_reArmPrim","_reArmAT"];
			
	_unit = _this select 0;
	_holder = _this select 1;
	
	_quali = 0;	
	_mC = if (_holder isKindOf "MAN") then {(magazines _holder)} else {(magazineCargo _holder)};
	_wC = if (_holder isKindOf "MAN") then {[(primaryWeapon _holder)]} else {(weaponCargo _holder)};
	_iC = if (_holder isKindOf "MAN") then {[(items _holder)]} else {(itemCargo _holder)};
	_bC = if (_holder isKindOf "MAN") then {[(backpack _holder)]} else {(backpackCargo _holder)};
	
	if (typeName _unit == "STRING") exitwith {
		{_quali = _quali + 10} foreach _mC;
		{_quali = _quali + 5} foreach _wC;
		{_quali = _quali + 1} foreach _iC;
		{_quali = _quali + 1} foreach _bC;
		_quali
	};
	if (isPlayer _unit) exitWith {0};
	if (_bacMode) then {
		if (count _bC > 0) then {_quali = _quali + 1};
	};
		
	_PriMode = _this select 2;
	_secMode = _this select 3; // "SEC_NONE": no AT  "SEC_RESUPPLY": needs rocket  "SEC_REARM": needs launcher
	_bacMode = _this select 4;
	_reArmPrim = false;
	_reArmAT = false;
		
	
	if (_priMode == "PRI_REARM") then {	
		{
			_wpon = _x;
			if ((getNumber (configFile >> "CfgWeapons" >> _x >> "Type")) == 1) then {
				if (   ({ _x in (getarray (configfile >> "CfgWeapons" >> _wpon >> "magazines"))} count _mC)  > 2 ) then {
					_reArmPrim = true;
				};
			};			
		} foreach _wC;	
		if (_reArmPrim) then {
			_quali = _quali + 10;
		};
	};
	if (_priMode == "PRI_RESUPPLY") then {		
		if (   ({ _x in (getarray (configfile >> "CfgWeapons" >> (primaryWeapon _unit) >> "magazines"))} count _mC)  > 2 ) then {
			_quali = _quali + 10;
		};

	};
	if (_secMode == "SEC_REARM") then {
		if (   ({(getNumber (configFile >> "CfgWeapons" >> _x >> "Type")) == 4} count _wC)  > 0 ) then {
			_quali = _quali + 10;
		};
		if (   ({ _x in (getarray (configfile >> "CfgWeapons" >> (primaryWeapon _unit) >> "magazines"))} count _mC)  > 2 ) then {
			_quali = _quali + 10;
		};
	};
	if (_secMode == "SEC_RESUPPLY") then {
		{
			_wpn = _x;
			if ((getNumber (configFile >> "CfgWeapons" >> _wpn >> "Type")) == 4) then {
				if (   ({ _x in (getarray (configfile >> "CfgWeapons" >> _wpn >> "magazines"))} count _mC)  > 0 ) then {
					_reArmAT = true;
				};
			};			
		} foreach _wC;	
		if (_reArmAT) then {
			_quali = _quali + 10;
		};		

	};
	//systemchat format ["%1,  %2",_holder, _quali];
	_quali
	
};


A3C_Rearm_Req_HC = { //-- Very performance heavy because of A3C_FINDMEDICS, do not call too often
	params ["_group"];
	private _units = units _group;
	

	private _cfg = configFile >> "CfgWeapons";
	
	private _cond1 = {_x getVariable ["A3C_REARMING", false]} count _units == 0;
	_cond1 && 
	{
		private _medics = [_units] call A3C_FINDMEDICS;
		_medics isEqualTo [] ||
		{
			private _cond = false;
			{
				private _pw = primaryWeapon _x;
				
				_cond = _pw == "" ||
				{
					private _pwMagsCompat = compatibleMagazines [_pw,"this"]; //getArray (_cfg >> _pw >> "magazines");
					private _unitPWMags = (magazines _x) + (primaryWeaponMagazine _x);
					private _pwMagAmount = {_x in _pwMagsCompat} count _unitPWMags;
					_pwMagAmount < 2 ||
					{
						_sw = secondaryWeapon _x;
						(
							_sw != "" &&
							{
								private _swMagsCompat = compatibleMagazines [_sw,"this"]; ; //getArray (_cfg >> _sw >> "magazines");
								private _unitSWMags = (magazines _x + secondaryWeaponMagazine _x);
								private _swMagAmount = {_x in _swMagsCompat} count _unitSWMags;
								_swMagAmount == 0
							}
						)
					}
				};
				if (_cond) exitWith {};
			} foreach _units;
			_cond
		}
	}
};




//-- determine "mode": what does the unit need to reArm?
A3C_ReArm_Mode = {
	private _unit = _this select 0;

	if !((vehicle _unit) == _unit) exitWith {[]};
	if (isPlayer _unit) exitWith {[]};

	private _priMode = "PRI_NONE";
	private _secMode = "SEC_NONE";
	private _bacMode = false;

	private _primaryMags = getArray (configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "magazines");
	private _secondaryMags = getArray (configFile >> "CfgWeapons" >> (secondaryWeapon _unit) >> "magazines");

	private _primaryCount = { _x in _primaryMags } count (magazines _unit);
	private _secondaryCount = { _x in _secondaryMags } count (magazines _unit);

	if (primaryWeapon _unit == "") then {
		_priMode = "PRI_REARM";
	} else {
		if (_primaryCount > 0) then {
			if (_primaryCount < 5) then {
				_priMode = "PRI_RESUPPLY";
			} else {
				if !(secondaryWeapon _unit == "") then {
					if (_secondaryCount == 0) then {
						_priMode = "PRI_RESUPPLY";
					};
				};
			};
		} else {
			_priMode = "PRI_REARM";
		};
	};

	if !(secondaryWeapon _unit == "") then {
		if (({ _x in (getArray (configFile >> "CfgWeapons" >> (secondaryWeapon _unit) >> "magazines")) } count magazines _unit) == 0) then {
			{
				if ((getNumber (configFile >> "CfgWeapons" >> (_x select 0) >> "Type")) == 4) then {
					if ((count (_x select 4)) == 0) then {
						_secMode = "SEC_RESUPPLY";
					};
				};
			} forEach (weaponsItems _unit);

			//-- detect unusable launcher
			if ({ _x == "used" } count ([(secondaryWeapon _unit), "_"] call BIS_fnc_splitString) > 0) then {
				_secMode = "SEC_REARM";
			};
		};
	} else {
		if (player == leader group _unit) then {
			if (({ (getNumber (configFile >> "CfgWeapons" >> _x >> "Type")) == 1 } count (getArray (configFile >> "CfgVehicles" >> (typeOf _unit) >> "weapons"))) > 0) then {
				_secMode = "SEC_REARM";
			};
		};
	};

	if (_priMode == "PRI_REARM") then {
		if !(primaryWeapon _unit == "") then {
			_priMode = "PRI_RESUPPLY";
		};
	};

	if (backPack _unit == "") then {
		_bacMode = true;
	};

	[_priMode, _secMode, _bacMode]
};

LRRW_fnc_isItemAssignable = {
	params ["_itemType"];
	//Is an item assignable
	//_itemType = typeOf _item;

	_hasItemInfo = isClass ( configFile >> "CfgWeapons" >> _itemType >> "ItemInfo" );
	_invType = getNumber ( configFile >> "CfgWeapons" >> _itemType >> "type" );
	_invVal = getNumber ( configFile >> "CfgWeapons" >> _itemType >> "value" );
	_invInfoType = getNumber ( configFile >> "CfgWeapons" >> _itemType >> "ItemInfo" >> "type" );

	private _isAssignable = _hasItemInfo && _invType in [ 131072, 4096 ] && _invVal in [ 2, 5 ] && _invInfoType in [ 0, 616 ];
	_isAssignable
};


if (isDedicated) exitWith {};




/////////////////  U I  -  F U N C T I O N S

A3C_UPDATE_UI_REARM = {
	private _display = findDisplay 100040;
	if (isNull _display) exitWith {};

	private _listboxSources = _display displayCtrl 8054;
	if (isNull _listboxSources) exitWith {};

	private _listboxContent = _display displayCtrl 8055;
	if (isNull _listboxContent) exitWith {};

	if (ctrlShown _listboxSources && {A3C_LBR_1 == "REARM"}) then {
		private _currentLBCurSelSource = lbCurSel _listboxSources;
		private _currentLBCurSelContent = lbCurSel _listboxContent;
		if (_currentLBCurSelSource >= 0) then {
			[_currentLBCurSelSource, 100040] call A3C_Rearm_LBChange_Source;
		};

		if (_currentLBCurSelContent >= 0 && {_currentLBCurSelContent < lbSize _listboxContent}) then {
			[_listboxContent, _currentLBCurSelContent] call A3C_setCurSel;
		};
	};
};


A3C_ReArm_OpenUI = {

	private _isSingleUnit = count A3C_RD_UNITS == 1;
	A3C_ReArm_Options = [];
	BV_LB1 = 10;
	BV_LB2 = 11;

	//-- Populate UI headers
	(findDisplay 100040 displayCtrl 8057) ctrlSetText "Containers";
	if (_isSingleUnit) then {
		(findDisplay 100040 displayCtrl 8058) ctrlSetText "Content: DoubleClick to equip";
	} else {
		(findDisplay 100040 displayCtrl 8058) ctrlSetText "Content (info only)";
	};
	(findDisplay 100040 displayCtrl 8053) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
	(findDisplay 100040 displayCtrl 8056) ctrlSetText "Re-Arm";
	{lbCLear (findDisplay 100040 displayCtrl _x)} foreach [8054, 8055];
	{(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8053,8054,8055,8056,8057,8058];


	//-- Find and sort re-Arm sources
	{
		private _u = _x;
		{
			A3C_ReArm_Options pushBackUnique _x;
		} foreach ([_u,"PRI_RESUPPLY","SEC_REARM",false,[]] call A3C_ReArm_GetSources); //-- list of close reArm Options to unit
	} foreach A3C_RD_UNITS;

	//-- Ordering Stage 1
	if (_isSingleUnit) then {
		A3C_ReArm_Options = [A3C_ReArm_Options,[],{_x distance (A3C_RD_UNITS select 0)},"ASCEND"] call BIS_fnc_sortBy;	
	} else {
		A3C_ReArm_Options = [A3C_ReArm_Options,[],{["LIGHT",_x] call A3C_REARM_QUALITY},"DESCEND"] call BIS_fnc_sortBy;
	};

	//-- Ordering Stage 2 - place bodies and holders last, keep rest of order intact
	private _normal = [];
	private _special = [];
	{
		if ((_x isKindOf "MAN") || {typeOf _x in A3C_WeaponHolderClasses}) then {
			_special pushBackUnique _x;
		} else {
			_normal pushBackUnique _x;
		};
	} forEach A3C_ReArm_Options;
	A3C_ReArm_Options = _normal + _special;

	//-- populate UI listboxes
	{
		private _v = _x;
		private _img = "";
		if (_v isKindOf "MAN") then {
			_img = "\a3\ui_f\data\GUI\Cfg\Hints\Death_ca.paa";
			
		} else {
			if (typeOf _v in A3C_WeaponHolderClasses) then {
				_img = "\a3\ui_f\data\GUI\Cfg\Hints\Rifle_ca.paa";
			} else {
				_img = ((getText (configfile >> "CfgVehicles" >> (typeOf _v) >> "picture")));
				_bL = ["pictureThing"];
				if (_img in _bL) then {
					_img = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa";
				};
			};
		};
		private _addString = "";
		if (_isSingleUnit) then {
			_addString = format ["(%1m)",round (_v distance (A3C_RD_UNITS select 0))];
		};
		[
			[
				(getText (configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName")) + _addString,
				(typeOf _v),
				_v,
				(findDisplay 100040 displayCtrl 8054),
				_img
			]
		] call A3C_UI_RADIAL_LB_ADD;
	} foreach A3C_ReArm_Options;
	[findDisplay 100040 displayCtrl 8054, 0, true] call A3C_setCurSel;		
};


A3C_Rearm_LBChange_Source = {
	params ["_lb", "_a3c_dsp"];

	A3C_REARM_CARGO = [];

	private _display = findDisplay _a3c_dsp;
	private _ctrlCargo = _display displayCtrl 8055;

	lbClear _ctrlCargo;

	if ((count A3C_ReArm_Options > 0) && {_lb >= 0} && {_lb < count A3C_ReArm_Options}) then {

		A3C_TARGETVEH = A3C_ReArm_Options select _lb;

		if (count A3C_RD_UNITS == 1) then {
			[
				[
					"Open Inventory",
					"",
					objNull,
					_ctrlCargo,
					""
				]
			] call A3C_UI_RADIAL_LB_ADD;
		};

		for "_i" from 0 to 3 do {

			private _cfg = "CfgWeapons";
			private _cargo = [];

			switch (_i) do {

				case 0: {
					_cfg = "CfgWeapons";
					if (A3C_TARGETVEH isKindOf "MAN") then {
						_cargo = + (weapons A3C_TARGETVEH);
						{
							_cargo append (weaponCargo _x);
						} forEach (getCorpseWeaponholders A3C_TARGETVEH);
					} else {
						_cargo = getWeaponCargo A3C_TARGETVEH;
					};
				};

				case 1: {
					_cfg = "CfgMagazines";
					if (A3C_TARGETVEH isKindOf "MAN") then {
						_cargo = + (magazines A3C_TARGETVEH);
						{
							_cargo append (magazineCargo _x);
						} forEach (getCorpseWeaponholders A3C_TARGETVEH);
					} else {
						_cargo = getMagazineCargo A3C_TARGETVEH;
					};
				};

				case 2: {
					_cfg = "CfgWeapons";
					if (A3C_TARGETVEH isKindOf "MAN") then {
						_cargo = + (items A3C_TARGETVEH);

						{
							if (_x != "") then {
								_cargo pushBack _x;
							};
						} forEach [vest A3C_TARGETVEH, headGear A3C_TARGETVEH, hmd A3C_TARGETVEH];

						{
							_cargo append (itemCargo _x);
						} forEach (getCorpseWeaponholders A3C_TARGETVEH);
					} else {
						_cargo = getItemCargo A3C_TARGETVEH;
					};
				};

				case 3: {
					_cfg = "CfgVehicles";
					if (A3C_TARGETVEH isKindOf "MAN") then {
						_cargo = [];

						{
							if (_x != "") then {
								_cargo pushBack _x;
							};
						} forEach [backPack A3C_TARGETVEH];

						{
							_cargo append (backpackCargo _x);
						} forEach (getCorpseWeaponholders A3C_TARGETVEH);
					} else {
						_cargo = backpackCargo A3C_TARGETVEH;
					};
				};
			};

			if (count _cargo > 0) then {

				if (typeName (_cargo select 0) == "ARRAY") then {
					private _cargoAggregated = [];
					{
						_cargoAggregated pushBack [_x, (_cargo select 1) select _forEachIndex];
					} forEach (_cargo select 0);
					_cargo = _cargoAggregated;
				} else {
					private _cargoAggregated = [];
					{
						private _class = _x;
						private _idx = _cargoAggregated findIf { (_x select 0) isEqualTo _class };

						if (_idx == -1) then {
							_cargoAggregated pushBack [_class, 1];
						} else {
							(_cargoAggregated select _idx) set [1, ((_cargoAggregated select _idx) select 1) + 1];
						};
					} forEach _cargo;
					_cargo = _cargoAggregated;
				};

				{
					private _m = _x select 0;
					private _amount = _x select 1;
					private _text = (getText (configFile >> _cfg >> _m >> "displayName")) + format [", (%1x)", _amount];
					private _img = getText (configFile >> _cfg >> _m >> "picture");

					A3C_REARM_CARGO pushBack _m;

					[
						[
							_text,
							_m,
							_m,
							_ctrlCargo,
							_img
						]
					] call A3C_UI_RADIAL_LB_ADD;

				} forEach _cargo;
			};
		};

		[_ctrlCargo, 0] call A3C_setCurSel;
	};
};

A3C_Rearm_LBChange_SourceContent = {
	params ["_lb", "_doubleClick", "_a3c_dsp"];

	if (_lb >= 0) then {
		if (_doubleClick && {count A3C_RD_UNITS == 1}) then {

			private _lbText = (findDisplay _a3c_dsp displayCtrl 8055) lbText _lb;
			private _item = if (_lbText == "Open Inventory") then {"INVENTORY"} else {A3C_REARM_CARGO select (_lb - 1)};
			private _unit = A3C_RD_UNITS select 0;

			[_unit, A3C_TARGETVEH, _item] call A3C_ReArm_Plot_AddItem;
		};
	};
};


