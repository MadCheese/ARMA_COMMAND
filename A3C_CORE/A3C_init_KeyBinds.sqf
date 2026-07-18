if (isDedicated) exitWith {};


//-- These global variable resets stay here instead of A3C_InitValuesClient.sqf so they can be easily reset.
A3C_UI_HUD_KeyDown_EHID = -1;
A3C_UI_HUD_KeyUp_EHID = -1;
A3C_UI_HUD_MouseButtonDown_EHID = -1;
A3C_UI_HUD_MouseZChanged_EHID = -1;

A3C_UI_MAP_KeyDown_EHID = -1;
A3C_UI_MAP_MouseButtonDown_EHID = -1;
A3C_UI_MAP_MouseButtonUp_EHID = -1;



//-- A3C_UI_FNC_ADD_KEYBINDS adds all keybinds when mission begins. Should keybinds get lost due to savegames or else, the refresh buttons will trigger the function to re-establish binds.
A3C_UI_FNC_ADD_KEYBINDS =
{

	//////////////////////////////////////////////////////
	////                  HUD - EVHS		          ////
	//////////////////////////////////////////////////////


	//-- HUD KeyDown
	[
		findDisplay 46,
		"A3C_UI_HUD_KeyDown_EHID",
		"display",
		"KeyDown",
		{
			private _blockDefaultKey = false;
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				//-- #UNCLEAR - note - if this fires when overlay is open, we could get rid of the MainMap KeyDown handler??
				_blockDefaultKey = _this call A3C_ui_mainDisplay_fnc_onKeyDown_Main;
			};
			_blockDefaultKey
		}
	] call A3C_UI_CreateSafeEventhandler;

	//-- HUD KeyUp
	[
		findDisplay 46,
		"A3C_UI_HUD_KeyUp_EHID",
		"display",
		"KeyUp",
		{
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				_this call A3C_ui_mainDisplay_fnc_onKeyUp_Main;
				false
			};
		}
	] call A3C_UI_CreateSafeEventhandler;

	
	//-- HUD MouseButtonDown
	[
		findDisplay 46,
		"A3C_UI_HUD_MouseButtonDown_EHID",
		"display",
		"MouseButtonDown",
		{
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				_this spawn A3C_ui_mainDisplay_fnc_onMouseButtonDown_Main;
			};
			
			false
		}
	] call A3C_UI_CreateSafeEventhandler;
	
	//-- HUD MouseZChanged
	[
		findDisplay 46,
		"A3C_UI_HUD_MouseZChanged_EHID",
		"display",
		"MouseZChanged",
		{
			//-- visibleMap check not necessary as HUD-MouseZ does not fire on Map
			private _blockDefaultKey = _this call A3C_ui_mainDisplay_fnc_onMouseZChanged;
			_blockDefaultKey
		}
	] call A3C_UI_CreateSafeEventhandler;

	// //-- HUD MouseMoving
	// [
	// 	findDisplay 46,
	// 	"A3C_UI_HUD_MouseMoving_EHID",
	// 	"display",
	// 	"MouseMoving",
	// 	{
	// 		private _blockDefaultKey = _this call A3C_UI_HUD_onMouseMoving;
	// 		_blockDefaultKey
	// 	}
	// ] call A3C_UI_CreateSafeEventhandler;

	//////////////////////////////////////////////////////
	////                  MAP - EVHS		          ////
	//////////////////////////////////////////////////////

	//-- Map KeyDown - this direct map-keybind is currently necessary :) COZ I DON'T UNDERSTAND ARMA lol
	[
		(findDisplay 12 displayctrl 51),
		"A3C_UI_MAP_KeyDown_EHID",
		"ctrl",
		"KeyDown",
		{
			disableSerialization;
			private _return = _this call A3C_ui_mapOverlay_fnc_MAP_onKeyDown;
			_return	
		}
	] call A3C_UI_CreateSafeEventhandler;



	//---------------------------------------  C B A  K E Y B I N D S  -------------------------------
	//------------------------------------------------------------------------------------------------


	
	["A3C", "A3C_KeyFnc_Menu", ["Open 3D Menu", "Open A3C Radial-Menu (Regular Selection)"], {[_this,false] call A3C_ui_radialMenu_fnc_spawnRadialMenu}, {}, [15,[false,false,false]],true] call cba_fnc_addKeybind;
	//
	["A3C", "A3C_KeyFnc_Menu_cursor", ["Open 3D Menu (CursorObject)", "Open A3C Radial-Menu (CursorObject Selection)"], {[_this,true] call A3C_ui_radialMenu_fnc_spawnRadialMenu}, {}, [15,[false,true,false]],true] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_HUD_MENU", ["Open HUD MENU controls", "Get access to your HUD MODE settings via mouse while key is pressed."], {[_this] call A3C_ui_squadPlacement_fnc_startSquadPlacementInteraction}, {}, [42,[true,false,false]],true] call cba_fnc_addKeybind;

	A3C_MAP_KEY_ID = [
		"A3C",
		"A3C_KeyFnc_MapControls",
		[
			"Open Map Controls",
			"Hold down this key to access Planning controls on map"
		],
		{
			["MAP","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager
		},
		{
			// ["MAP","UP",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager
		},
		[
			46,
			[false,false,false]
		],
		false
	] call cba_fnc_addKeybind;

	[
		"A3C",
		"A3C_KeyFnc_Suppress_DRAW_T2",
		[
			"Configure Suppression Zone",
			"Open suppression display"
		],
		{
			if (visibleMap) exitWith {};
			if !(player == leader group player) exitWith {};

			if ((count groupSelectedUnits player) == 0) then {
				{
					if (!isPlayer _x) then {
						player groupSelectUnit [_x, true];
					};
				} forEach (units player - [player]);
			};

			A3C_SUP_DRAWKEY_ID = [
				_this select 1,
				_this select 2,
				_this select 3,
				_this select 4
			];

			A3C_SUPPRESSION_UNITS_SQ_TEMP = +(groupSelectedUnits player);

			{
				if (isPlayer _x) then {
					A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x];
				};
			} forEach A3C_SUPPRESSION_UNITS_SQ_TEMP;

			{
				if (_x in A3C_SUPPRESSION_UNITS_SQ) then {
					A3C_SUPPRESSION_UNITS_SQ_TEMP = A3C_SUPPRESSION_UNITS_SQ_TEMP - [_x];
				};
			} forEach A3C_SUPPRESSION_UNITS_SQ_TEMP;

			if ((count A3C_SUPPRESSION_UNITS_SQ_TEMP) > 0) then {
				[] spawn {
					disableSerialization;

					with uiNamespace do {
						A3C_SUPMENU = (findDisplay 46) createDisplay "A3C_SUPPRESSION_DRAW";
					};

					waitUntil {
						!isNull (uiNamespace getVariable ["A3C_UI_suppressionArea_display", displayNull])
					};

					private _mode = (profileNamespace getVariable ["A3C_SUP_RESTRICTIVE", ["UNLIMITED", 0]]) select 0;
					[_mode, false] call A3C_UI_suppressionArea_fnc_setRestrictionMode;
				};
			} else {
				[] spawn {
					hint "Selection either empty or busy suppressing";
					sleep 5;
					hintSilent "";
				};
			};

			[] spawn {
				sleep 0.1;
				showCommandingMenu "";
			};
		},
		{},
		[20, [false, false, true]],
		false
	] call CBA_fnc_addKeybind;



	["A3C", "A3C_KeyFnc_Lock", ["Lock Formation", "Locks the indicator objects in position while maintaining other options"], {["LOCK","DOWN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [38,[false,false,false]],false ] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Grenade_Player", ["GetTactical Grenade", "Gives enhanced throwing-options"], {["GREN_P","DOWN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {["GREN_P","UP"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, [35,[false,false,false]],false ] call cba_fnc_addKeybind;



	["A3C", "A3C_KeyFnc_Formation_Menu_2", ["Custom Formation Menu", "Custom Formation HUD"], {["FORM","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [33,[true,false,false]],true] call cba_fnc_addKeybind; //["FORM","UP"] call A3C_UI_mainDisplay_fnc_cbaKeyManager
	["A3C", "A3C_KeyFnc_ZEUS_Remote", ["A3C-ZEUS Exit", "Exit A3C-Zeus Remote"], {["ZEUS","DOWN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [21,[true,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Hud_TeamSel_ALL", ["Hud Select: All Units", "Select/Deselect All Units in HUD-mode"], {["HUD","DOWN","ALL"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [5,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_TeamSel_Red", ["Hud Select: Team Red", "Select/Deselect Team Red in HUD mode"], {["HUD","DOWN","RED"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [6,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_TeamSel_Green", ["Hud Select: Team Green", "Select/Deselect Team Green in HUD mode"], {["HUD","DOWN","GREEN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [7,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_TeamSel_Blue", ["Hud Select: Team Blue", "Select/Deselect Team Blue in HUD mode"], {["HUD","DOWN","BLUE"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [8,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_TeamSel_Yellow", ["Hud Select: Team Yellow", "Select/Deselect Team Yellow in HUD mode"], {["HUD","DOWN","YELLOW"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [9,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_TeamSel_White", ["Hud Select: Team White", "Select/Deselect Team White in HUD mode"], {["HUD","DOWN","MAIN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [10,[false,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Hud_Unit_02", ["Hud Select: Unit 02", "Select/Deselect Unit 02 in HUD-mode"], {["HUD","DOWN",02] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [60,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_03", ["Hud Select: Unit 03", "Select/Deselect Unit 03 in HUD-mode"], {["HUD","DOWN",03] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [61,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_04", ["Hud Select: Unit 04", "Select/Deselect Unit 04 in HUD-mode"], {["HUD","DOWN",04] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [62,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_05", ["Hud Select: Unit 05", "Select/Deselect Unit 05 in HUD-mode"], {["HUD","DOWN",05] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [63,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_06", ["Hud Select: Unit 06", "Select/Deselect Unit 06 in HUD-mode"], {["HUD","DOWN",06] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [64,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_07", ["Hud Select: Unit 07", "Select/Deselect Unit 07 in HUD-mode"], {["HUD","DOWN",07] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [65,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_08", ["Hud Select: Unit 08", "Select/Deselect Unit 08 in HUD-mode"], {["HUD","DOWN",08] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [66,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_09", ["Hud Select: Unit 09", "Select/Deselect Unit 09 in HUD-mode"], {["HUD","DOWN",09] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [67,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_10", ["Hud Select: Unit 10", "Select/Deselect Unit 10 in HUD-mode"], {["HUD","DOWN",10] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [68,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_11", ["Hud Select: Unit 11", "Select/Deselect Unit 11 in HUD-mode"], {["HUD","DOWN",11] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [59,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_12", ["Hud Select: Unit 12", "Select/Deselect Unit 12 in HUD-mode"], {["HUD","DOWN",12] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [60,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_13", ["Hud Select: Unit 13", "Select/Deselect Unit 13 in HUD-mode"], {["HUD","DOWN",13] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [61,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_14", ["Hud Select: Unit 14", "Select/Deselect Unit 14 in HUD-mode"], {["HUD","DOWN",14] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [62,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_15", ["Hud Select: Unit 15", "Select/Deselect Unit 15 in HUD-mode"], {["HUD","DOWN",15] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [63,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_16", ["Hud Select: Unit 16", "Select/Deselect Unit 16 in HUD-mode"], {["HUD","DOWN",16] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [64,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_17", ["Hud Select: Unit 17", "Select/Deselect Unit 17 in HUD-mode"], {["HUD","DOWN",17] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [65,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_18", ["Hud Select: Unit 18", "Select/Deselect Unit 18 in HUD-mode"], {["HUD","DOWN",18] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [66,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_19", ["Hud Select: Unit 19", "Select/Deselect Unit 19 in HUD-mode"], {["HUD","DOWN",19] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [67,[true,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Unit_20", ["Hud Select: Unit 20", "Select/Deselect Unit 20 in HUD-mode"], {["HUD","DOWN",20] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [68,[true,true,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Hud_Order_Reg", ["Send To Hud Indicators: Regular"], {["ORDER_REG","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [57,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Order_FW", ["Send To Hud Indicators: FW Peel"], {["ORDER_FW","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [57,[false,true,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Hud_Order_BW", ["Send To Hud Indicators: BW Peel"], {["ORDER_BW","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [57,[false,false,true]],false] call cba_fnc_addKeybind;

	//TEST
	//["A3C", "A3C_KeyFnc_HUD_DRAW_OPTION", ["Action Key for HUD-DrawPath (Requires selected units)", "Enables(Down) / Disables(Up) Path-Drawing via HUD"], {["HUD_DRAW","DOWN"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {["HUD_DRAW","UP"] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, [29,[false,true,false]],false ] call cba_fnc_addKeybind;


	//-- Additional Keybinds for usage with Voice Activation
	["A3C", "A3C_KeyFnc_Voice_GoCode_A", ["Activate GoCode A via key (VA)"], {["GoCode_A","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_GoCode_B", ["Activate GoCode B via key (VA)"], {["GoCode_B","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_GoCode_C", ["Activate GoCode C via key (VA)"], {["GoCode_C","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_GoCode_D", ["Activate GoCode D via key (VA)"], {["GoCode_D","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;


	["A3C", "A3C_KeyFnc_Switch_CommandLevel", ["Switch between SQUAD and PLATOON Level"], {["COMMAND_LEVEL","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [57,[false,true,false]],true] call cba_fnc_addKeybind;


	["A3C", "A3C_KeyFnc_Voice_MedicAll", ["Squad Patch Up via key (VA)"], {["Voice_Medic_All","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Voice_AD", ["Toggle AUTOCOMBAT for selected units via key (VA)"], {["Voice_AUTOCOMBAT","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Voice_Refresh", ["Refresh Squad via key (VA)"], {["Voice_REFRESH","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	[
		"A3C",
		"A3C_KeyFnc_Voice_Regroup",
		["A3C FallBack / ReGroup (VA)"],
		{

			_units = if (count (groupSelectedUnits player) == 0) then {(units player - [player])} else {(groupSelectedUnits player)};
			{
				_x commandFollow player;
			} foreach _units;
			//["REFRESH",1,false] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;
			//[] spawn {
			//	sleep 0.1;
				{player groupSelectUnit [_x,false]} foreach (units player);
				showCommandingMenu "";
			//};
		},
		{},
		[-1,[false,false,false]],
		false
	] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Voice_LookDir", ["Reset looking direction for selected units via key (VA)"], {["Voice_LookDir","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Voice_HudStance_Auto", ["Set Hud-Stance to AUTO via key (VA)"], {["Voice_Stance_Auto","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_HudStance_STAND", ["Set Hud-Stance to STAND via key (VA)"], {["Voice_Stance_STAND","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_HudStance_CROUCH", ["Set Hud-Stance to CROUCH via key (VA)"], {["Voice_Stance_CROUCH","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_HudStance_PRONE", ["Set Hud-Stance to PRONE via key (VA)"], {["Voice_Stance_PRONE","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_HudStance_NOCHANGE", ["Set Hud-Stance to NO CHANGE via key (VA)"], {["Voice_Stance_NOCHANGE","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;

	["A3C", "A3C_KeyFnc_Voice_HOLD", ["Order selected units to STANDBY (VA)"], {["Voice_Hold","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_CONT", ["Order selected units to CONTINUE after HOLD (VA)"], {["Voice_Cont","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],false] call cba_fnc_addKeybind;
	["A3C", "A3C_KeyFnc_Voice_UNLOADD", ["Unload other groups from your vehicle (VA)"], {["Voice_Unload","DOWN",_this] call A3C_UI_mainDisplay_fnc_cbaKeyManager}, {}, [-1,[false,false,false]],true] call cba_fnc_addKeybind;

	[
		"A3C",
		"A3C_KeyFnc_UavMacro",
		["UAV SCREEN TOGGLE"],
		{["DOWN",_this] call A3C_UI_mainDisplay_fnc_uavManagerKeyHandler},
		{},
		[183,[false,false,false]],
		false,
		0,
		true
	] call cba_fnc_addKeybind;
	[
		"A3C",
		"A3C_KeyFnc_UavMacro_1",
		["CONNECT TO NEXT UNCONNECTED UAV (if available)"],
		{["DOWN",_this] call A3C_UI_mainDisplay_fnc_uavManagerKeyHandler},
		{},
		[183,[false,true,false]],
		false,
		0,
		true
	] call cba_fnc_addKeybind;



};


