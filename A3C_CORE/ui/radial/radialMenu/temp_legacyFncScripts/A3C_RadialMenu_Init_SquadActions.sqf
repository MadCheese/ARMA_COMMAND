#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"
#include "..\..\..\SHARED\selectionPromptPanel\dialog_defines.hpp"




A3C_UI_RADIAL_SQUAD_DISTRIBUTE_MENU_ACTIONS = {
	params ["_display", "_unitArray"]; //-- _display is the display IDD

	private _a3c_dsp = _display;
	if (isNull findDisplay _a3c_dsp) exitWith {};

	private _outerButtonMacros = ["radial_outerButtonMacros"] call FUNC(ctrlGroup);
	private _outerImages = ["radial_outerImages"] call FUNC(ctrlGroup);
	private _outerButtons = ["radial_outerButtons"] call FUNC(ctrlGroup);

	private _outerButtonPairs = [
		[["outerTop1Img"] call FUNC(ctrl), ["outerTop1Btn"] call FUNC(ctrl)],
		[["outerTop2Img"] call FUNC(ctrl), ["outerTop2Btn"] call FUNC(ctrl)],
		[["outerTop3Img"] call FUNC(ctrl), ["outerTop3Btn"] call FUNC(ctrl)],
		[["outerTop4Img"] call FUNC(ctrl), ["outerTop4Btn"] call FUNC(ctrl)],

		[["outerRight1Img"] call FUNC(ctrl), ["outerRight1Btn"] call FUNC(ctrl)],
		[["outerRight2Img"] call FUNC(ctrl), ["outerRight2Btn"] call FUNC(ctrl)],
		[["outerRight3Img"] call FUNC(ctrl), ["outerRight3Btn"] call FUNC(ctrl)],
		[["outerRight4Img"] call FUNC(ctrl), ["outerRight4Btn"] call FUNC(ctrl)],

		[["outerBottom1Img"] call FUNC(ctrl), ["outerBottom1Btn"] call FUNC(ctrl)],
		[["outerBottom2Img"] call FUNC(ctrl), ["outerBottom2Btn"] call FUNC(ctrl)],
		[["outerBottom3Img"] call FUNC(ctrl), ["outerBottom3Btn"] call FUNC(ctrl)],
		[["outerBottom4Img"] call FUNC(ctrl), ["outerBottom4Btn"] call FUNC(ctrl)],

		[["outerLeft1Img"] call FUNC(ctrl), ["outerLeft1Btn"] call FUNC(ctrl)],
		[["outerLeft2Img"] call FUNC(ctrl), ["outerLeft2Btn"] call FUNC(ctrl)],
		[["outerLeft3Img"] call FUNC(ctrl), ["outerLeft3Btn"] call FUNC(ctrl)],
		[["outerLeft4Img"] call FUNC(ctrl), ["outerLeft4Btn"] call FUNC(ctrl)]
	];

	//-- Reset outer ring action buttons
	{
		_x ctrlShow false;
	} forEach _outerButtonMacros;

	{
		_x ctrlSetText "";
	} forEach _outerImages;

	{
		_x ctrlSetToolTip "";
	} forEach _outerButtons;

	A3C_REMFIRE_TankShot_Units = [];
	A3C_REMFIRE_UGLShot_Units = [];
	A3C_REMFIRE_ATShot_Units = [];
	A3C_REMFIRE_StaticShot_Units = [];

	//-- action check 1: find cover
	if ({isNull objectParent _x} count _unitArray > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "FIND_COVER";
	};
	//-- action check 2: Open Inventory
	if (count _unitArray == 1) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "OPEN_INV";
		_nearArsenals = (_unitArray select 0) nearObjects 10;

		private _cond = 
		{
			private _cr = _x;
			count ([_cr,[],false,false,0,2] call bis_fnc_addVirtualItemCargo) > 0 OR
			{
				{"arsenal" in (toLower ((_cr actionParams _x) select 0)) } count (actionIDs _cr) > 0
			}
		} count _nearArsenals > 0;
		

		if (_cond) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "ARSENAL";
		};
		_nearArsenals = nil;
	};

	//-- action check 3: clear building
	if (!isNull cursorTarget) then {
		if (cursorTarget Iskindof "HOUSE") then {
			if (([cursortarget] call MCSS_fnc_countBPos) > 0) then {
				A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "CLEAR_BUILDING";
			};
		};
	};
	//-- action check 4: assemble static weapon
	_canAssemble = false;
	_canDisassemble = false;
	_packUnits = _unitArray; //if (count _unitArray >  1) then {_unitArray} else {units player - [player]};
	_packMode = [_packUnits] call A3C_SMART_getWeaponAssemblyMode;

	if (_packMode == "DUAL") then {
		_canAssemble = true;
		_canDisassemble = true;
	} else {
		if (_packMode == "ASSEMBLE") then {
			_canAssemble = true;
		};
		if (_packMode == "DISASSEMBLE") then {
			_canDisassemble = true;
		};
	};

	//-- action check 5: unassemble static weapon
	if (_canAssemble) then {
		//if (isNull cursorTarget) then { //~~ this check ends up being confusing as you may not be aware that you are looking at a cursortarget
			A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "STATIC_ASSEMBLE_SQUAD";
		//};
	};
	if (_canDisAssemble) then {
		//systemchat 'hey';
		A3C_REMFIRE_nearEmptyStatics = [];
		{

			private _soldier = _x;
			private _weapon = objNull;
			private _cond = false;
			//-- check for empty statics closeby
			{
				if (count crew _x == 0 && {(typeOf _x) != "A3C_Supression_Target_F"}) then {
					A3C_REMFIRE_nearEmptyStatics pushBackUnique _x;
					_cond = true;
				};

			} foreach ((position _x) nearObjects ["staticweapon", 50]);
			if !(_cond) then {
				//-- no emptystatics found yet. we check for statics that are manned by members of player group
				_cond =
				(
					count A3C_REMFIRE_nearEmptyStatics > 0
					OR
					{
						!isNull cursorTarget && {count crew cursortarget == 0 && {cursorTarget isKindOf "STATICWEAPON" && {(typeOf cursorTarget) != "A3C_Supression_Target_F"}}}
						OR
						{
							_veh = vehicle _x;
							(_veh isKindOf "STATICWEAPON") && 
							{
								count ((crew _veh) - units player) == 0 &&
								{
									(typeOf _veh) != "A3C_Supression_Target_F"
								}
							}
						}
					}
				);
				if (_cond) then {
					//-- if we have a static weapon gunner, we need to check if there's friends around to help pick up the weapon
					_weapon = vehicle _soldier;
					_otherUnits = (units player) - [player]; //,_soldier
					{
						if (_x distance _weapon > 300) then {
							_otherUnits = _otherUnits - [_x];
						};
					} foreach _otherUnits;
					if !([_otherUnits,_weapon,false] call A3C_HC_canSelectionPickUpStatic) then {
						//-- weapon can not be disassembled because nobody is there to help
						_cond = false;
					};
				};
			};

			if (_cond) exitWith {
				A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "STATIC_DISASSEMBLE_SQUAD";
			};
		} foreach (units player);
	};

	//-- REMFIRE ACTION CHECK 1: Detonate all remote charges
	private _units = +(_unitArray);
	{
		{
			_units pushbackUnique _x;
		} foreach units _x;
	} foreach A3C_HC_getAllGroups_Player_Current;

	if (({(count (_x getvariable ["A3C_UNIT_EXPLOSIVES",[]])) > 0} count _units) > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "ORDER_DETO";

	};

	//-- REMFIRE ACTION CHECK 2: Place Explosive
	_detoUnits = [_unitArray] call A3C_ai_shared_fnc_getUnitsWithExplosives;
	if (count _detoUnits > 0) then {
		//if (side cursortarget == civilian OR ((side cameraOn) getfriend (side cursorTarget) < 0.6) ) then {  //~~turned out to be confusing
			A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "PLACE_CHARGE_SQUAD";
		//};
	};
	

	if ({_x in A3C_SUPPRESSION_UNITS_SQ} count A3C_RD_UNITS > 0) then {A3C_DYNAMIC_BUTTON_ACTIONS pushBack "SUPPRESSION_OFF";};
	if ({!(_x in A3C_SUPPRESSION_UNITS_SQ)} count A3C_RD_UNITS > 0) then {A3C_DYNAMIC_BUTTON_ACTIONS pushBack "SUPPRESSION_ON";};


	//-- REMFIRE ACTION CHECKS 3-6: Remote Projectiles

	{
		if (_x == gunner vehicle _x) then {
			if (isNull objectParent _x) then {
				if ([_x] call A3C_HasGL) then {
					A3C_REMFIRE_UGLShot_Units pushBackUnique _x;
				};
				if ([_x] call A3C_HasAT) then {
					A3C_REMFIRE_ATShot_Units pushBackUnique _x;
				};
			} else {
				//if (vehicle _x isKindOf "STATICWEAPON") then {
				if (_x == gunner vehicle _x && {[vehicle _x] call A3C_isStaticMissileLauncher}) then {
					A3C_REMFIRE_StaticShot_Units pushBackUnique _x;
				} else {
					if (vehicle _x isKindOf "TANK") then { //(count (getArtilleryAmmo [vehicle _unit])) > 0
						A3C_REMFIRE_TankShot_Units pushBackUnique _x;
					};
				};
			};
		};
	} foreach A3C_RD_UNITS;

	if (count A3C_REMFIRE_TankShot_Units > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBack "TANKSHOT";
	};
	if (count A3C_REMFIRE_StaticShot_Units > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBack "STATICSHOT";
	};
	if (count A3C_REMFIRE_ATShot_Units > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBack "ATSHOT";
	};
	if (count A3C_REMFIRE_UGLShot_Units > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBack "UGLSHOT";
	};



	//-- action check 6: engine off
	if ({!isNull objectParent _x && {_x == driver vehicle _x && {!isEngineOn vehicle _x && {!(vehicle _x isKindOf "AIR")}   }}} count _unitArray > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "ENGINE_ON";
	} else {
		if ({!isNull objectParent _x && {_x == driver vehicle _x && {isEngineOn vehicle _x && {!(vehicle _x isKindOf "AIR")}   }}} count _unitArray > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "ENGINE_OFF";
		};
	};

	{
		if !((vehicle _x) isKindOf "AIR" && {!isTouchingGround (vehicle _x)}) exitWith {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "UNSTUCK";
		};
	} foreach A3C_RD_UNITS;




	_sortedActions = [];

	{
		if (_x in A3C_DYNAMIC_BUTTON_ACTIONS) then {
			_sortedActions pushBack _x;
		};
	} foreach
	[
		"FIND_COVER",
		"OPEN_INV",
		"ARSENAL",
		"SUPPRESSION_ON",
		"SUPPRESSION_OFF",
		"STATIC_ASSEMBLE_SQUAD",
		"STATIC_DISASSEMBLE_SQUAD",
		"TANKSHOT",
		"STATICSHOT",
		"ATSHOT",
		"UGLSHOT",
		"ORDER_DETO",
		"PLACE_CHARGE_SQUAD",
		"ENGINE_ON",
		"ENGINE_OFF",
		"CLEAR_BUILDING",
		"UNSTUCK"
	];


	A3C_DYNAMIC_BUTTON_ACTIONS = _sortedActions;
	
	// systemchat str A3C_DYNAMIC_BUTTON_ACTIONS;

	// {} foreach A3C_DYNAMIC_BUTTON_ACTIONS;

	for "_i" from 0 to ( ((count A3C_DYNAMIC_BUTTON_ACTIONS) - 1) min 11) do { //~~ this could also be a foreach loop?
		private _action = A3C_DYNAMIC_BUTTON_ACTIONS select _i;
		private _button = _outerButtonPairs select _i;
		_button params ["_buttonImage", "_buttonClicker"];
		private _buttonFncData = [];
		switch (_action) do {

			//----------- NON-POSITIONAL ACTIONS

			case ("CLEAR_BUILDING") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_clearBuilding.paa";
				_buttonFncData =
				[
					[str _unitArray,'cursortarget',_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unitArray","_cursorString","_display"];
						_unitArray = call compile _unitArray;
						[_unitArray,_cursorString] call A3C_ai_shared_fnc_actionClearBuilding;
					},
					true

				];
				_buttonClicker ctrlSetTooltip "Clear Building";
			};
			case ("ARSENAL") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_arsenal.paa";
				_buttonFncData =
				[
					[str (_unitArray select 0),_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unit","_display"];
						_unit = call compile _unit;
						[_unit] call A3C_ai_squad_fnc_actionArsenal;
					},
					true
				];
				_buttonClicker ctrlSetTooltip "OPEN ARSENAL";
			};
			case ("UNSTUCK") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						_units spawn A3C_ai_shared_fnc_actionUnstuck;
					},
					true
				];
				_buttonClicker ctrlSetTooltip "Un-Stuck Unit(s)";
			};

			case ("ENGINE_ON") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\engine_on_ca.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						[_units] call A3C_ai_shared_fnc_actionEngineOn;
						BV_ACT = 0;
						["ACTIONS",0] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
					},
					true

				];
				_buttonClicker ctrlSetTooltip "Turn Engine(s) On";
			};
			case ("ENGINE_OFF") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\engine_off_ca.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						[_units] call A3C_ai_shared_fnc_actionEngineOff;	
						BV_ACT = 0;
						["ACTIONS",0] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
					},
					true

				];

				_buttonClicker ctrlSetTooltip "Turn Engine(s) Off";

			};
			case ("ORDER_DETO") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
				_buttonClicker ctrlSetTooltip "MANAGE EXPLOSIVES";
				_buttonFncData =
				[
					[],
					{
						[] call A3C_UI_SelectionPromptPanel_fnc_actionChargeDetonatePromptStart;
					},
					false
				];
			};

			case ("SUPPRESSION_OFF") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\ico_OFF_ca.paa";
				_buttonClicker ctrlSetTooltip "STOP SUPPRESSING";
				_buttonFncData =
				[
					[[],_display],
					{
						[] call A3C_AI_Squad_Action_suppressionStop;
						BV_ACT = 0;
						["ACTIONS",0] call A3C_UI_RADIAL_BTN_FNC_RING_INNER;
					},
					false
				];


			};

			case ("STATIC_DISASSEMBLE_SQUAD") : {
				_unitArray = units player;
				{
					if (isPlayer _x) then {
						_unitArray = _unitArray - [_x];
					};
				} foreach _unitArray;
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_STATIC_Packing.paa";
				_buttonClicker ctrlSetTooltip "DISASSEMBLE Static Weapon";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_assemblingUnitSelection","_display"];
						_assemblingUnitSelection = call compile _assemblingUnitSelection;
						A3C_UI_RADIAL_Current_Remfire_Units = _assemblingUnitSelection;
						[] call A3C_AI_Squad_Action_unAssembleWeapon;
					},
					false
				];
			};
			case ("OPEN_INV") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_openInventory.paa";
				_buttonClicker ctrlSetTooltip "Open Inventory";
				private _target = if (player distance (_unitArray select 0) < 5.5) then {player} else {_unitArray select 0}; //-- if player is close, he will become target (right box). otherwise unit iself will be target and source will be weaponholder
				private _source = _unitArray select 0; //if (player distance (_unitArray select 0) < 5.5) then {_unitArray select 0} else {objNull};
				_buttonFncData =
				[
					[str _target,str _source,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ['_target','_source','_display'];
						_target = call compile _target;
						_source = call compile _source;
						[_target, _source] call A3C_AI_Squad_Action_openInventory;
					},
					false
				];
				//
			};
			case ("FIND_COVER") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_takeCover.paa";
				_buttonClicker ctrlSetTooltip "Find Cover";
				_buttonFncData =
				[
					[str _unitArray],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unitArray"];
						_unitArray = call compile _unitArray;
						[_unitArray] call A3C_AI_Squad_action_FindCover;
					},
					true
				];

			};

			//----- Remote-Fire Actions (use )

			case ("TANKSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
				_buttonClicker ctrlSetTooltip format
				[
					"FIRE TANK SHELL - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
				_buttonFncData =
				[
					[],
					{
						[
							A3C_Prevent_TANKSHOT, //-- isBusy
							'TANKSHOT', //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							'', //-- placer class
							'' //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					true

				];

				
			};
			case ("STATICSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_remote_StaticAT.paa";
				_buttonFncData =
				[
					[],
					{
						[
							A3C_Prevent_STATICSHOT, //-- isBusy
							"STATICSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					true

				];
				_buttonClicker ctrlSetTooltip format
				[
					"FIRE STATIC ROCKET LAUNCHER - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
			};
			case ("ATSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_remote_AT.paa";
				_buttonFncData =
				[
					[],
					{
						[
							A3C_Prevent_ATSHOT, //-- isBusy
							"ATSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_AT.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					true

				];
				_buttonClicker ctrlSetTooltip format
				[
					"FIRE AT-ROCKET - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
			};
			case ("UGLSHOT") : {
				_buttonImage ctrlSetText "\a3c_ui\menu\icon_menu_action_remote_UGL.paa";
				_buttonFncData =
				[
					[],
					{
						[
							A3C_Prevent_UGLSHOT, //-- isBusy
							"UGLSHOT", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_remote_UGL.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					true

				];

				_buttonClicker ctrlSetTooltip format
				[
					"FIRE UGL GRENADE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
			};

			//----------- POSITIONAL ACTIONS
			

			case ("SUPPRESSION_ON") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
				_buttonClicker ctrlSetTooltip format
				[
					"SUPPRESS POSITION - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
				_buttonFncData =
				[
					[[],_display],
					{
						A3C_UI_RADIAL_Current_Remfire_Units = A3C_RD_UNITS;
						{
							if (_x in A3C_SUPPRESSION_UNITS_SQ) then {
								A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_x];
							};
						} foreach A3C_UI_RADIAL_Current_Remfire_Units;
						if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
						
						[
							false, //-- isBusy
							"SUPPRESSION", //-- actionID
							'\a3c_ui\menu\icon_menu_action_suppression.paa', //-- Hud-Icon-class
							[1,0,0,1], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					false
				];


			};
			
			case ("PLACE_CHARGE_SQUAD") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_explosives_Place.paa"; 
				_buttonClicker ctrlSetTooltip format
				[
					"PLACE EXPLOSIVE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
				_buttonFncData =
				[
					[str _detoUnits,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_detoUnits","_display"];
						A3C_UI_RADIAL_Current_Remfire_Units = call compile _detoUnits;
						if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
						{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
						[
							false, //-- isBusy
							"PLACE_CHARGE_SQUAD", //-- actionID
							'\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa', //-- Hud-Icon-class
							[1,1,1,0.7], //-- Hud-Icon-color
							"", //-- placer class
							"" //-- placer color-params
						] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
					},
					false
				];
			};

			case ("STATIC_ASSEMBLE_SQUAD") : {

				_buttonImage ctrlSetText (gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "picture"));
				_buttonClicker ctrlSetTooltip format
				[
					"ASSEMBLE %1 - KEEP %2 PRESSED. SELECT A WEAPON, POSITION AND ROTATE IT (MOUSEWHEEL). PRESS 'SpaceBar' TO CONFIRM OR RELEASE %1 TO CANCEL ",
					(gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")),
					["A3C","A3C_KeyFnc_Menu"] call A3C_UI_fnc_getKeybindTranslation
				];
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_assemblingUnitSelection","_display"];
						_assemblingUnitSelection = call compile _assemblingUnitSelection;
						
						

						_staticData = [_assemblingUnitSelection,"PLANNING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;
						if (count _staticData > 0) then {

							
							A3C_DISABLE_RADIAL = true;
							(findDisplay _display) closeDisplay 0;
							

							private _a3c_dsp = IDD_SELECTION_PROMPT_PANEL;	
							A3C_SelectionPromptPanel_MODE = "STATIC_ASSEMBLE_SQUAD";
							if (count _staticData == 1) then {
								[0] call A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared;
							} else {
								with uiNamespace do {
									A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
								};
								_parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
								_text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
								_listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
								
								_parent ctrlShow true;
								_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
								_parent ctrlCommit 0;
								_text ctrlSetText "Select Static Weapon";
								ctrlSetFocus _listBox;
								
								lbClear _listBox;
								{
									private _lbText = (getText (configfile >> "CfgVehicles" >> _x select 1 >> "displayName"));
									[_listBox, _lbText] call A3C_addLbEntry;
								} foreach _staticData;
								
							};
						};
					},
					false
				];

			};
			
		};

		call compile format
		[
			"

				A3C_OUTER_RING_BTN_fnc_%1 = %2;
			",
			_i + 1,
			_buttonFncData

		];
	};
	{
		if (_forEachIndex < count A3C_DYNAMIC_BUTTON_ACTIONS) then {
			_x params ["_buttonImage", "_buttonClicker"];
			{
				_x ctrlShow true;
			} forEach [_buttonImage, _buttonClicker];
		};
	} forEach _outerButtonPairs;

};






A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING = {
	params ["_assemblingUnitSelection","_weaponToDisassemble"];
	{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
	//systemchat str (_weaponToDisassemble == cursortarget);
	A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >> typeOf _weaponToDisassemble >> "picture");
	A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
	A3C_UI_HUD_3D_TAG_ICON_POS =  +(position _weaponToDisassemble);
	[+(position _weaponToDisassemble),""] spawn A3C_UI_HUD_3D_TAG;

	if ({group _x == group player} count crew _weaponToDisassemble > 0) then {
		{
			// unassignVehicle _x;
			// doGetOut _x;
			[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
		} foreach (crew _weaponToDisassemble);
		sleep 1;
	};

	_selectedTastUnits = ([_assemblingUnitSelection,[],["DISASSEMBLE",_weaponToDisassemble],position _weaponToDisassemble,0,500] call A3C_ai_shared_fnc_staticWeaponPrepareDisassembly) select 0;

	if (count _selectedTastUnits == 2) then {
		player groupRadio "SentDisAssemble";
		[_selectedTastUnits,true,false] call A3C_AI_Shared_cancelUnitPlot;
		_mainMark = "A3C_SQ_" + (str (random 10000000000));
		_wpnPos = position _weaponToDisassemble;
		
		{
			_unit = _x;
			waitUntil {count (_unit getvariable 'A3C_PLOT') == 0};
			_data =
			[
				[
					[_wpnPos,_wpnPos getPos [50,0]], //-- positions
					[_mainMark,"",""], //-- markers
					 ["STATIC",["DISASSEMBLE",_weaponToDisassemble]], //-- wp action
					["NONE","NONE"], //--WP Condition
					["UP","UP"], //-- WP Stances
					[[0,false]], // WP Sync Data
					false, //-- isWPCompleted
					0, //-- Combat Mode
					-1, //-- WP SPeed
					25, //-- WP Flying Height
					-1, //-- WP Loop Value
					0 // -- radius (for circle, not completion)
				]
			];
			private _expDest = [_unit] call A3C_fnc_setDestination;
			_unit setvariable ["A3C_PLOT",_data,true];
			[_unit] spawn {
				params ["_unit"];
				_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_AI_Shared_executeUnitPlot);
				private _hasReached = false;
				private _exit = false;
				private _doReturnToOrders = true;
				while {alive _unit} do {
					if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {_hasReached = true};
					if (scriptDone _scr) exitWith {};
					if (_hasReached) then {
						//systemchat '1k';
						if ( animationState _unit != "ainvpknlmstpslaywrfldnon_medic") then {
							sleep 3;
							_exit = true;
							if ( count (_unit getvariable 'A3C_PLOT') > 0 ) then {
								_doReturnToOrders = false;
							};
						};
					};
					if (_exit) exitWith {};
					sleep 1;
				};
				//systemchat "loop exit";
				if (_doReturnToOrders) then {
					//systemchat 'fire';
					[_unit] call A3C_ai_squad_fnc_actionResumeDestination;
				};
			};
		} foreach _selectedTastUnits;
	};

};