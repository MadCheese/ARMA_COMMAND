
if (is3DEN) exitWith {};

//--- A3C init

//-- Server And/Or Client

call compile preprocessFileLineNumbers "A3C_CORE\A3C_Init_VALUES.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_fncs_Main.sqf";

//-- AI Functions 
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_general.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_actions.sqf";




if (A3C_IsAICommand && {!isDedicated}) exitWith {
	waituntil {alive player};
	"ARMA COMMAND DLC" hintC [
		"Unfortunately, ARMA COMMAND is not compatible with ADVANCED AI COMMAND",
		"Initialization aborted                                "
	];
};

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\wpFncs\fncs_waypointScripts.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\data\A3C_data_bPosNoAccess.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_fncs_Debug.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_MCSS.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_UAV_FPV.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_artillery.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_weapons_Unit.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_weapons_Static.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_remoteFire.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_AIR_rappel.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\ai_rails\ai_rails_inf.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\ai_rails\ai_rails_Heli.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_serverMon.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_vehicleRemote.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\CMDLVL_HighCommand\fncs_HighCommand.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\CMDLVL_HighCommand\A3C_AI_HighCommand_ActionLibrary.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_sharedCommandingLevels.sqf";




call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Helicopter.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Ship.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Suppress.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_clearBuilding.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Convoy.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_gunship.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_GTI.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Medical.sqf";          //-- mixed GLOBAL / CLient
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_reArm.sqf";            //-- mixed GLOBAL / CLient


RHS_ENGINE_STARTUP_OFF = true;
publicVariable 'RHS_ENGINE_STARTUP_OFF';


[] spawn {
	waituntil {!isNil 'A3C_IsA3CServer'};
	if (A3C_IsA3CServer) then {
		if (isServer) then {
			A3C_MISSION_EH = addMissionEventHandler
			[
				"Ended",
				{
					[] call {
						A3C_MISSIONENDED = true;
						publicVariable 'A3C_MISSIONENDED';
					};
				}
			];
			[] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";
			//-- add custom radio channel 
			// if (isDedicated) then {
				A3C_CUSTOMRADIO_ID = radioChannelCreate [[0.96, 0.34, 0.13, 0.8], "A3C_RADIO", "%UNIT_NAME", []];
				publicVariable "A3C_CUSTOMRADIO_ID";
			// };

		} else {
			//-- A3C running on server, player connecting as client: add player to radio channel
			A3C_CUSTOMRADIO_ID radioChannelAdd [player];
		};
	} else {
		//-- A3C not running on server. Run on client instead.
		[] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";
		A3C_CUSTOMRADIO_ID = radioChannelCreate [[0.96, 0.34, 0.13, 0.8], "A3C_RADIO", "%UNIT_NAME", [player]]; ///-- #WIP: assuming local only is the way to go
	};
};


//-- Init Client Only
if (isDedicated) exitWith {};




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


call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_findCover.sqf";     //-- Not HC/remote compatible yet
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_Boarding.sqf";         //-- Not HC/remote compatible yet

//-- Shared UI fncs
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_Functions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_Handlers_dispatched.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\UI_DSP_SHARED_TREE_Functions.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_AI_ROE.sqf";

if (A3C_EHM) then {
	call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\fncs_EHM.sqf";
};


//-- Radial Dialog
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\functions\initFunctions.sqf";

//-- Radial Legacy Functions (to be updated)
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_UI_FNC.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_Init_SquadActions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu_Init.sqf";
A3C_SPAWN_RADIAL = compile preprocessfileLineNumbers "A3C_CORE\ui\radial\radialMenu\temp_legacyFncScripts\A3C_RadialMenu.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\settingsMenu\functions\initFunctions.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\CMDLVL_Squad\A3C_AI_Squad_ActionLibrary.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\fnc_AI\CMDLVL_Shared\A3C_AI_Shared_ActionLibrary.sqf";


//-- HUD UI elements
call compile preprocessFileLineNumbers "A3C_CORE\ui\HUD\squadPlacement\functions\initFunctions.sqf";
A3C_SPAWN_HUD_MENU = compile preprocessfileLineNumbers "A3C_CORE\ui\HUD\squadPlacement\functions\startSquadPlacementInteraction.sqf";

//-- HUD (findDisplay 46)
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\UI_DSP_HUD_Handlers.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\UI_DSP_HUD_Handlers_dispatched.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\HUD_UI.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\customFormation\UI_DSP_CustomFormation_init.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\customFormation\UI_DSP_CustomFormation_handlers.sqf";


call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\selectionPromptPanel\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\suppressionArea\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\hudDynamic\functions\initFunctions.sqf";

//-- Shared UI
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\functions\initFunctions.sqf";








call compile preprocessFileLineNumbers "A3C_CORE\fnc_Player\fncs_Player.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\A3C_Mode_ZEUS.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\fncs_UI_main.sqf";


MCSS_fnc_createMarker = compile preprocessfileLineNumbers "A3C_CORE\fnc_GEN\createMarker.sqf";

[] execVM "A3C_CORE\A3C_init_Runner.sqf";
//A3C_loaded = true;






