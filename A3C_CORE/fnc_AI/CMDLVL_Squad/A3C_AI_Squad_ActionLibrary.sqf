//---------------------------------------------------------------------------------------------
//---------- 1. Non positional actions --------------------------------------------------------
//---------------------------------------------------------------------------------------------

A3C_AI_Squad_Action_clearBuilding = {
	params ["_unitArray","_cursorString"];
	[_unitArray,_cursorString] spawn A3C_AI_Shared_action_CLEARBUILDING;
};
A3C_AI_Squad_Action_Arsenal = {
	params ["_unit"];
	[_unit,true] spawn A3C_UI_ARSENAL_CREATELB;
};

A3C_AI_Squad_Action_Unstuck = {
	params ["_units"];
	_units spawn A3C_AI_Shared_action_UNSTUCK;
};

A3C_AI_Squad_Action_engineOn = {
	params ["_units"];
	{
		private _unit = _x;
		if (!isNull objectParent _unit) then {
			if (_unit == driver vehicle _unit) then {
				if (((getPosATL vehicle _unit) select 2) < 5) then {
					_unit action ["engineOn",vehicle _unit];
				};
			};
		};
	} foreach _units;
};

A3C_AI_Squad_Action_engineOff = {
	params ["_units"];
	[_units] call A3C_AI_Shared_fnc_engineOff;
};

A3C_AI_Squad_Action_orderDetonation = {
	[] call A3C_UI_RADIAL_OBJECTSELECTOR_START_CHARGEDIALOG;
};



A3C_AI_Squad_Action_suppressionStop = {
	A3C_UI_RADIAL_Current_Remfire_Units = A3C_RD_UNITS;
	{
		if !(_x in A3C_SUPPRESSION_UNITS_SQ) then {
			A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_x];
		};
	} foreach A3C_UI_RADIAL_Current_Remfire_Units;
	if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
	[A3C_UI_RADIAL_Current_Remfire_Units,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
};


A3C_AI_Squad_Action_unAssembleWeapon = {

	
	A3C_DISABLE_RADIAL = true;
	[] call A3C_UI_RADIAL_CloseDisplay;


	if (count crew cursorTarget == 0 && {cursorTarget isKindOf "STATICWEAPON"}) exitWith {
		[A3C_UI_RADIAL_Current_Remfire_Units,cursortarget] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;
	};

	if ((gunner cursorTarget) in A3C_UI_RADIAL_Current_Remfire_Units && {cursorTarget isKindOf "STATICWEAPON"} ) then {
		[A3C_UI_RADIAL_Current_Remfire_Units,cursortarget] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;
	} else {
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};

		private _a3c_dsp = if (visibleMap) then {100020} else {100060};
		private _parent = findDisplay _a3c_dsp displayCtrl 8008;
		private _text = findDisplay _a3c_dsp displayCtrl 800802;
		private _listBox = findDisplay _a3c_dsp displayCtrl 800803;

		A3C_OBJECTSELECTOR_MODE = "STATIC_DISASSEMBLE_SQUAD";
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_text ctrlSetText "Pack Weapon";


		A3C_UI_RADIAL_Current_Remfire_Vehicles = [];
		{
			if (_x == gunner vehicle _x && {vehicle _x isKindOf "STATICWEAPON"}) then {
				A3C_UI_RADIAL_Current_Remfire_Vehicles pushBackUnique (vehicle _x);
			};
		} foreach A3C_UI_RADIAL_Current_Remfire_Units;


		if (count A3C_UI_RADIAL_Current_Remfire_Vehicles > 4) then {
			_parentPos = ctrlPosition _parent;
			_parentPos set[3,(_parentPos select 3) + (  ((count _mags) - 4)   * (0.0440051 * safezoneH) )];
			_parent ctrlSetPosition _parentPos;
			_parent ctrlCommit 0;
		};



		ctrlSetFocus _listBox;
		
		lbClear _listBox;
		{
			_str = "";
			if (gunner _x in A3C_UI_RADIAL_Current_Remfire_Units) then {
				_str = format ["%1 (%2)",getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName"),name (gunner _x)];
			} else {
				_str = format ["%1 (Empty)",getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName")];
			};
			[_listBox, _str] call A3C_addLbEntry;
		} foreach (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics);
	};
};

A3C_AI_Squad_Action_openInventory = {
	params ["_target", "_source"];
	A3C_UI_INV_TARGET_UNIT = _target;
	(findDisplay 100040) closeDisplay 0;
	{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
	[_target,_source] spawn A3C_UI_RADIAL_INV_LB_CREATE;
};

A3C_AI_Squad_action_FindCover = {
	params ["_unitArray"];
	[_unitArray] call A3C_AI_Squad_action_FindCoverExecute;
};








//---------------------------------------------------------------------------------------------
//---------- 2. Positional actions ------------------------------------------------------------
//---------------------------------------------------------------------------------------------



A3C_AI_Squad_Action_suppression = {
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
		[_units,[A3C_UI_HUD_3D_TAG_ICON_POS,""],'SUPPRESSION',true] spawn A3C_POLY_ACTION_ON;
	};
};

A3C_AI_Squad_Action_placeChargeHC = {
	A3C_UI_HUD_3D_TAG_reposition = false;
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
		private _mags = [];
		{
			private __u = _x;
			{
				if (getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]) then {
					private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
					private _mineTrigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");
					if (_mineTrigger == "RemoteTrigger" OR isNull cursorTarget) then {
						_mags pushbackUnique _x;
					};
				};
			} foreach (magazines _u)
		} foreach _units;

		private __doRefreshGroupSelected = false;
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};

		private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
		private __parent = findDisplay _a3c_dsp displayCtrl 8008;
		private __text = findDisplay _a3c_dsp displayCtrl 800802;
		private __listBox = findDisplay _a3c_dsp displayCtrl 800803;

		A3C_OBJECTSELECTOR_MODE = "PLACE_CHARGE_SQUAD";
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_text ctrlSetText "Place Charge";

		if (count _mags > 4) then {
			_parentPos = ctrlPosition _parent;
			_parentPos set[3,(_parentPos select 3) + (  ((count _mags) - 4)   * (0.0440051 * safezoneH) )];
			_parent ctrlSetPosition _parentPos;
			_parent ctrlCommit 0;
		};



		ctrlSetFocus _listBox;
		
		lbClear _listBox;
		{
			private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
			[_listBox, _lbText] call A3C_addLbEntry;
		} foreach _mags;
		[_parent,_listBox, count _mags] call A3C_OBJECTSEL_RESIZE;
		


		// A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";

	};
};

A3C_AI_Squad_Action_assembleWeapon = {
	[] spawn A3C_AI_Squad_Action_assembleWeaponExecute;
};

