
if (is3DEN) exitWith {};

//--- A3C init

//-- 1. Server only
if (isServer) then {
	call compile preprocessFileLineNumbers "A3C_CORE\server\functions\initFunctions.sqf";
};

//-- 2. Server And/Or Client


call compile preprocessFileLineNumbers "A3C_CORE\A3C_InitValuesCommon.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_fncs_Main.sqf";



if (A3C_IsAICommand && {!isDedicated}) exitWith {
	waituntil {alive player};
	"ARMA COMMAND DLC" hintC [
		"Unfortunately, ARMA COMMAND is not compatible with ADVANCED AI COMMAND",
		"Initialization aborted                                "
	];
};

call compile preprocessFileLineNumbers "A3C_CORE\data\A3C_data_bPosNoAccess.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_fncs_Debug.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_MCSS.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_sharedCommandingLevels.sqf";





call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Ship.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Suppress.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_GTI.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Medical.sqf";          //-- mixed GLOBAL / CLient
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_reArm.sqf";            //-- mixed GLOBAL / CLient


RHS_ENGINE_STARTUP_OFF = true;
publicVariable 'RHS_ENGINE_STARTUP_OFF';


[] spawn {
	waitUntil {!isNil "A3C_IsA3CServer"};

	if (A3C_IsA3CServer) then {
		if (isServer) then {
			A3C_MISSION_EH = addMissionEventHandler [
				"Ended",
				{
					A3C_MISSIONENDED = true;
					publicVariable "A3C_MISSIONENDED";
				}
			];

			[] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";

			//-- Add custom radio channel
			A3C_CUSTOMRADIO_ID = radioChannelCreate [
				[0.96, 0.34, 0.13, 0.8],
				"A3C_RADIO",
				"%UNIT_NAME",
				[]
			];

			publicVariable "A3C_CUSTOMRADIO_ID";
		} else {
			//-- A3C running on server, player connecting as client:
			//-- TEMP SOLUTION - Try for max. 30 seconds to receive A3C_CUSTOMRADIO_ID, then add player.
			private _addedToRadio = false;

			for "_i" from 1 to 30 do {
				if (!isNil "A3C_CUSTOMRADIO_ID" && {!isNull player}) exitWith {
					A3C_CUSTOMRADIO_ID radioChannelAdd [player];
					_addedToRadio = true;
				};

				sleep 1;
			};

			if (!_addedToRadio) then {
				diag_log "[A3C] Failed to add player to custom radio channel: A3C_CUSTOMRADIO_ID was not available within 30 seconds.";
			};
		};
	} else {

		if (!isServer) then {
			A3C_isHCSkillMaxed = if (!isNil 'A3C_isHCSkillMaxed') then {A3C_isHCSkillMaxed} else {profileNameSpace getVariable ["A3C_SKILL_VAR",true]};
		};

		//-- A3C not running on server. Run on client instead.
		[] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";

		//-- Try for max. 30 seconds to wait for player object before creating local channel.
		private _channelCreated = false;

		for "_i" from 1 to 30 do {
			if (!isNull player) exitWith {
				A3C_CUSTOMRADIO_ID = radioChannelCreate [
					[0.96, 0.34, 0.13, 0.8],
					"A3C_RADIO",
					"%UNIT_NAME",
					[player]
				];

				_channelCreated = true;
			};

			sleep 1;
		};

		if (!_channelCreated) then {
			diag_log "[A3C] Failed to create local custom radio channel: player object was not available within 30 seconds.";
		};
	};
};


//-- Generate A3C function libraries

call compile preprocessFileLineNumbers "A3C_CORE\main\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ai_highCommand\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ai_shared\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ai_rail\functions\initFunctions.sqf";



if (isDedicated) exitWith {};

//-- 3. Init Client/Host Only
call compile preprocessFileLineNumbers "A3C_CORE\A3C_InitValuesClient.sqf";



//-- Generate client-only function libraries
call compile preprocessFileLineNumbers "A3C_CORE\ai_squad\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\mainDisplay\functions\initFunctions.sqf";






call compile preprocessFileLineNumbers "A3C_CORE\ui\UI_createSafeEventHandler.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_init_keyBinds.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\A3C_events.sqf";










//-- Map Overlay

call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\functions\initFunctions.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_Functions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_Handlers.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_Handlers_dispatched.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_HCGP_CONTEXT_Functions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\LEGACY\UI_DSP_MAP_HCWP_CONTEXT_Functions.sqf";



call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Boarding.sqf";         //-- Not HC/remote compatible yet

//-- Shared UI fncs
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_Functions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_Handlers_dispatched.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_TREE_Functions.sqf";

//-- Radial Dialog
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\functions\initFunctions.sqf";

//-- Radial Legacy Functions (to be updated)
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_UI_FNC.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_Init_SquadActions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_Init.sqf";
A3C_SPAWN_RADIAL = compile preprocessfileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\settingsMenu\functions\initFunctions.sqf";


//-- HUD UI elements
call compile preprocessFileLineNumbers "A3C_CORE\ui\HUD\squadPlacement\functions\initFunctions.sqf";
A3C_SPAWN_HUD_MENU = compile preprocessfileLineNumbers "A3C_CORE\ui\HUD\squadPlacement\functions\startSquadPlacementInteraction.sqf";

//-- HUD (findDisplay 46)
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\UI_DSP_HUD_Handlers.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\UI_DSP_HUD_Handlers_dispatched.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\HUD_UI.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\customFormation\UI_DSP_CustomFormation_init.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\customFormation\UI_DSP_CustomFormation_handlers.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\selectionPromptPanel\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\suppressionArea\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\hudDynamic\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\mainDisplay\functions\initFunctions.sqf";


//-- Shared UI
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\functions\initFunctions.sqf";

//-- Arsenal fnc library
call compile preprocessFileLineNumbers "A3C_CORE\ui\arsenal\functions\initFunctions.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\fnc_Player\fncs_Player.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_Mode_ZEUS.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\fncs_UI_main.sqf";


//-- Player Eventhandlers
call compile preprocessFileLineNumbers "A3C_CORE\eventhandlers\player\functions\initFunctions.sqf";




MCSS_fnc_createMarker = compile preprocessfileLineNumbers "A3C_CORE\fnc_GEN\createMarker.sqf";

[] execVM "A3C_CORE\A3C_init_Runner.sqf";
//A3C_loaded = true;






