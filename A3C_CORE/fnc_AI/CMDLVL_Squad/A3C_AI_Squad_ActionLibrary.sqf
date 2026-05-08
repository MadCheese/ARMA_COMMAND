#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"
#include "..\..\ui\mapOverlay\dialog_defines.hpp"
#include "..\..\ui\SHARED\shared_ui_defines.hpp"
#include "..\..\ui\SHARED\selectionPromptPanel\dialog_defines.hpp"


//---------------------------------------------------------------------------------------------
//---------- 1. Non positional actions --------------------------------------------------------
//---------------------------------------------------------------------------------------------













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
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
		};

		private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
		private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
		private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
		private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

		A3C_SelectionPromptPanel_MODE = "STATIC_DISASSEMBLE_SQUAD";
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
	findDisplay IDD_RADIAL_MENU closeDisplay 0;
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


A3C_AI_Squad_Action_assembleWeapon = {
	[] spawn A3C_AI_Squad_Action_assembleWeaponExecute;
};

A3C_AI_Squad_Action_throwGTIgrenade = {
	
					
	BR_A3C_TEMP_gfeh = A3C_GTI_UNIT addEventHandler ["fired",
	{
		private _unit = _this select 0;
		_unit forceSpeed -1;
		if (_this select 1 == "THROW") then {
			(_this select 6) setVelocity BR_A3C_TACV_throwVel;
		};
		if ((side _unit) == WEST) then {
			[_unit] call A3C_Gren_Phrase;
		};
		_unit removeEventHandler ["fired", BR_A3C_TEMP_gfeh];
		_add = if (BR_A3C_TACV_throwV0 <= BR_A3C_TACV_GV0MaxS) then {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd} else {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd * 2};
		_unit setFatigue ((getFatigue _unit) + _add);
		A3C_GREN_MUZZLE = "";
	}];
	_mz = ([A3C_GREN_MUZZLE] call MCSS_fnc_GetMuzzle);
	A3C_GTI_UNIT forceSpeed 0;
	sleep 0.5;
	A3C_GTI_UNIT forceWeaponFire [_mz,_mz];
	["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	A3C_GTI_UNIT = objnull;
	A3C_AI_GREN_ARRAY = [];	
};

