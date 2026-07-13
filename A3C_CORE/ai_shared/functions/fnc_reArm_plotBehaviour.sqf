// A3C_ai_shared_fnc_reArm_plotBehaviour

params ["_unit", "_rearmData"];

if (isPlayer _unit) exitWith {};
if (_rearmData isEqualTo []) exitWith {};

private _rearmSource = _rearmData select 0;
(_rearmData select 1) params [
	"_requestedItems",
	"_primaryMode",
	"_secondaryMode",
	"_backpackMode"
];

private _selectedWeapon = "";

_unit doWatch _rearmSource;

sleep 1.5;

private _containers = [_rearmSource];

if (_rearmSource isKindOf "Man") then {
	private _corpseWeaponHolders = getCorpseWeaponholders _rearmSource;
	_containers append _corpseWeaponHolders;
};

private _containerContentMap = _containers apply {
	[_x] call A3C_main_fnc_getFlatContainerItems
};

private _fnc_removeFromContentMap = {
	params ["_item", "_itemContainer"];

	if (_item == "INVENTORY") exitWith {};

	private _containerIndex = _containers find _itemContainer;
	if (_containerIndex == -1) exitWith {};

	private _containerItems = _containerContentMap select _containerIndex;
	private _itemIndex = [_item, _containerItems] call MCSS_fnc_getArrayIndex;

	if (_itemIndex != -1) then {
		_containerItems deleteAt _itemIndex;
		_containerContentMap set [_containerIndex, _containerItems];
	};
};

private _fnc_refreshContentMap = {
	_containerContentMap = _containers apply {
		[_x] call A3C_main_fnc_getFlatContainerItems
	};
};

// Collect explicitly requested items.
if !(_requestedItems isEqualTo []) then {
	// Reset default modes since we are collecting targeted items.
	_primaryMode = "";
	_secondaryMode = "";
	_backpackMode = false;

	{
		private _requestedItem = _x;
		private _itemContainer = [
			_requestedItem,
			_rearmSource,
			_containers,
			_containerContentMap
		] call A3C_main_fnc_getItemContainer;

		switch (true) do {
			case (_requestedItem == "INVENTORY"): {
				private _gearPos = _rearmSource getPos [
					sizeOf typeOf _rearmSource * 0.7,
					_rearmSource getDir _unit
				];

				[_unit, _gearPos] call A3C_ai_shared_fnc_doMove;

				_unit setPos _gearPos;
				_unit setDir (_unit getDir _rearmSource);
				_unit action ["GEAR", _rearmSource];
				_unit forceSpeed 0;

				waitUntil {
					isNull findDisplay 602
				};

				_unit forceSpeed -1;
			};

			case (isClass (configFile >> "CfgWeapons" >> _requestedItem)): {
				private _isWeapon = ({
					_requestedItem isKindOf [_x, configFile >> "CfgWeapons"]
				} count ["Rifle", "Launcher", "Pistol"]) > 0;

				if (_isWeapon) then {
					[
						[_unit, _itemContainer, _requestedItem],
						A3C_ai_shared_fnc_reArm_takeWeapon
					] remoteExec ["BIS_fnc_call", _unit];

					[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;

					[_unit, _requestedItem] spawn {
						params ["_unit", "_weapon"];

						sleep 3;

						_unit selectWeapon _weapon;
					};
				} else {
					private _itemMacro = getText (
						configFile >> "CfgWeapons" >> _requestedItem >> "ItemInfo" >> "_generalMacro"
					);

					if (_itemMacro == "") then {
						_itemMacro = getText (
							configFile >> "CfgWeapons" >> _requestedItem >> "_generalMacro"
						);
					};

					switch (true) do {
						case (_itemMacro in ["Binocular", "Laserdesignator", "Rangefinder"]): {
							private _currentBinocular = binocular _unit;

							_unit removeWeapon _currentBinocular;
							_unit addWeapon _requestedItem;
							_unit assignItem _requestedItem;

							if (_itemContainer isKindOf "Man") then {
								_itemContainer removeWeapon _requestedItem;

								if (_currentBinocular != "") then {
									_itemContainer addWeapon _currentBinocular;
								};
							} else {
								private _weaponCargo = weaponCargo _itemContainer;

								if (_currentBinocular != "") then {
									_weaponCargo = _weaponCargo + [_currentBinocular];
								};

								{
									if (_x == _requestedItem) exitWith {
										_weaponCargo deleteAt _forEachIndex;
									};
								} forEach _weaponCargo;

								clearWeaponCargoGlobal _itemContainer;

								{
									_itemContainer addWeaponCargoGlobal [_x, 1];
								} forEach _weaponCargo;
							};

							[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;
						};

						case (_itemMacro == "HeadgearItem"): {
							private _currentHeadgear = headgear _unit;

							_unit removeWeapon _currentHeadgear;
							_unit addWeapon _requestedItem;
							_unit assignItem _requestedItem;

							if (_itemContainer isKindOf "Man") then {
								removeHeadgear _itemContainer;

								if (_currentHeadgear != "") then {
									_itemContainer addHeadgear _currentHeadgear;
								};
							} else {
								private _itemCargo = itemCargo _itemContainer;

								{
									if (_x == _requestedItem) exitWith {
										_itemCargo deleteAt _forEachIndex;
									};
								} forEach _itemCargo;

								if (_currentHeadgear != "") then {
									_itemCargo = _itemCargo + [_currentHeadgear];
								};

								clearItemCargoGlobal _itemContainer;

								{
									_itemContainer addItemCargoGlobal [_x, 1];
								} forEach _itemCargo;
							};

							[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;
						};

						default {
							private _parentClass1 = configName (
								inheritsFrom (configFile >> "CfgWeapons" >> _requestedItem)
							);

							private _parentClass2 = configName (
								inheritsFrom (configFile >> "CfgWeapons" >> _parentClass1)
							);

							private _isVest = ({
								"vest" in toLower _x
							} count [_parentClass1, _parentClass2]) > 0;

							private _oldVest = "";
							private _oldVestItems = [];

							switch (true) do {
								case (_isVest): {
									_oldVest = vest _unit;
									_oldVestItems = vestItems _unit;

									_unit addVest _requestedItem;
								};

								default {
									if (_unit canAdd _requestedItem) then {
										_unit addItem _requestedItem;

										if ([_requestedItem] call A3C_main_fnc_isItemAssignable) then {
											_unit assignItem _requestedItem;
										};
									};
								};
							};

							if (_itemContainer isKindOf "Man") then {
								if (_isVest) then {
									private _sourceVestItems = vestItems _itemContainer;

									removeVest _itemContainer;

									{
										_unit addItemToVest _x;
									} forEach (_sourceVestItems + _oldVestItems);

									if (_oldVest != "") then {
										_itemContainer addVest _oldVest;
									};
								} else {
									_itemContainer removeWeapon _requestedItem;
								};
							} else {
								private _itemCargo = itemCargo _itemContainer;

								{
									if (_x == _requestedItem) exitWith {
										_itemCargo deleteAt _forEachIndex;
									};
								} forEach _itemCargo;

								if (_oldVest != "") then {
									_itemCargo = _itemCargo + [_oldVest];
								};

								clearItemCargoGlobal _itemContainer;

								{
									_itemContainer addItemCargoGlobal [_x, 1];
								} forEach _itemCargo;

								{
									_unit addItemToVest _x;
								} forEach _oldVestItems;
							};

							[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;
						};
					};

					_unit playMoveNow "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown";
				};
			};

			case (isClass (configFile >> "CfgMagazines" >> _requestedItem)): {
				_unit action ["TakeMagazine", _itemContainer, _requestedItem];
				_unit addMagazine _requestedItem;

				[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;
			};

			case (isClass (configFile >> "CfgVehicles" >> _requestedItem)): {
				_unit action ["AddBag", _itemContainer, _requestedItem];

				[_requestedItem, _itemContainer] call _fnc_removeFromContentMap;
			};
		};

		sleep 2;

		[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
	} forEach _requestedItems;
};

if (_backpackMode) then {
	private _selectedBackpack = "";
	private _backpackContainer = objNull;

	{
		private _backpacks = if (_x isKindOf "Man") then {
			private _unitBackpack = backpack _x;

			if (_unitBackpack != "") then {
				[_unitBackpack]
			} else {
				[]
			};
		} else {
			backpackCargo _x
		};

		if !(_backpacks isEqualTo []) exitWith {
			_selectedBackpack = _backpacks select 0;
			_backpackContainer = _x;
		};
	} forEach _containers;

	if (_selectedBackpack != "" && { !isNull _backpackContainer }) then {
		_unit action ["AddBag", _backpackContainer, _selectedBackpack];

		[_selectedBackpack, _backpackContainer] call _fnc_removeFromContentMap;

		[] call A3C_ui_radialMenu_fnc_reArm_updateUi;

		sleep 1.5;
	};
};

if (_primaryMode == "PRI_RESUPPLY" || { _secondaryMode == "SEC_RESUPPLY" }) then {
	{
		_unit action ["rearm", _x];
	} forEach _containers;

	sleep 3;

	[] call _fnc_refreshContentMap;
	[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
};

if (_primaryMode == "PRI_REARM") then {
	private _availableWeapons = [];

	{
		if (_x isKindOf "Man") then {
			_availableWeapons append weapons _x;
		} else {
			_availableWeapons append weaponCargo _x;
		};
	} forEach _containers;

	{
		if (getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 1) then {
			_selectedWeapon = _x;
		};
	} forEach _availableWeapons;

	if (_selectedWeapon != "") then {
		private _weaponContainer = [
			_selectedWeapon,
			_rearmSource,
			_containers,
			_containerContentMap
		] call A3C_main_fnc_getItemContainer;

		[
			[_unit, _weaponContainer, _selectedWeapon],
			A3C_ai_shared_fnc_reArm_takeWeapon
		] remoteExec ["BIS_fnc_call", _unit];

		[_selectedWeapon, _weaponContainer] call _fnc_removeFromContentMap;

		sleep 2;

		{
			_unit action ["rearm", _x];

			sleep 2;
		} forEach _containers;

		sleep 2;

		[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
		[] call _fnc_refreshContentMap;
	};

	sleep 1;
};

if (_secondaryMode == "SEC_REARM") then {
	private _availableWeapons = [];

	{
		if (_x isKindOf "Man") then {
			_availableWeapons append weapons _x;
		} else {
			_availableWeapons append weaponCargo _x;
		};
	} forEach _containers;

	{
		if (getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 4) exitWith {
			_selectedWeapon = _x;
		};
	} forEach _availableWeapons;

	if (_selectedWeapon != "") then {
		private _unitDefaultWeapons = getArray (
			configFile >> "CfgVehicles" >> typeOf _unit >> "weapons"
		);

		private _weaponContainer = [
			_selectedWeapon,
			_rearmSource,
			_containers,
			_containerContentMap
		] call A3C_main_fnc_getItemContainer;

		if (
			({ getNumber (configFile >> "CfgWeapons" >> _x >> "Type") == 4 } count _unitDefaultWeapons > 0) ||
			{ ({ secondaryWeapon _x != "" } count (units player - [player])) == 0 }
		) then {
			[
				[_unit, _weaponContainer, _selectedWeapon],
				A3C_ai_shared_fnc_reArm_takeWeapon
			] remoteExec ["BIS_fnc_call", _unit];

			[_selectedWeapon, _weaponContainer] call _fnc_removeFromContentMap;

			sleep 2;
		};

		{
			_unit action ["rearm", _x];
		} forEach _containers;

		sleep 2;

		[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
		[] call _fnc_refreshContentMap;
		[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
	};
};

if (secondaryWeapon _unit != "") then {
	private _launcher = secondaryWeapon _unit;
	private _launcherMagazines = getArray (
		configFile >> "CfgWeapons" >> _launcher >> "magazines"
	);

	private _availableMagazines = [];
	private _takenMagazines = [];

	{
		if (_x isKindOf "Man") then {
			_availableMagazines append magazines _x;
		} else {
			_availableMagazines append magazineCargo _x;
		};
	} forEach _containers;

	{
		private _magazine = _x;

		if (_magazine in _launcherMagazines) then {
			private _magazineContainer = [
				_magazine,
				_rearmSource,
				_containers,
				_containerContentMap
			] call A3C_main_fnc_getItemContainer;

			if ((count secondaryWeaponMagazine _unit) == 0) then {
				_unit addSecondaryWeaponItem _magazine;
				_takenMagazines pushBack [_magazine, _magazineContainer];

				[_magazine, _magazineContainer] call _fnc_removeFromContentMap;
			} else {
				if (_unit canAddItemToBackpack _magazine) then {
					_unit addItemToBackpack _magazine;
					_takenMagazines pushBack [_magazine, _magazineContainer];

					[_magazine, _magazineContainer] call _fnc_removeFromContentMap;
				};
			};
		};
	} forEach _availableMagazines;

	{
		_x params ["_magazine", "_magazineContainer"];

		if (_magazineContainer isKindOf "Man") then {
			_magazineContainer removeMagazineGlobal _magazine;
		} else {
			private _containerMagazines = magazineCargo _magazineContainer;
			private _magazineIndex = [_magazine, _containerMagazines] call MCSS_fnc_getArrayIndex;

			if (_magazineIndex != -1) then {
				_containerMagazines deleteAt _magazineIndex;
			};

			clearMagazineCargoGlobal _magazineContainer;

			{
				_magazineContainer addMagazineCargoGlobal [_x, 1];
			} forEach _containerMagazines;
		};
	} forEach _takenMagazines;

	[] call A3C_ui_radialMenu_fnc_reArm_updateUi;
};

_unit doWatch objNull;
_unit lookAt objNull;