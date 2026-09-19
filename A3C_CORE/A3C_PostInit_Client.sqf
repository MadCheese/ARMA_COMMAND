if (isDedicated) exitWith {};
if (is3DEN) exitWith {};

diag_log "[A3C]: STARTING A3C Postinit Client";

if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {};

//--------------------------------------------------------------------------------------------------
// PLAYER
//--------------------------------------------------------------------------------------------------

//-- PostInit occurs after mission object initialization, but MP/JIP can still require
//-- a short wait until the local player object is available.
waitUntil {
	uiSleep 0.05;

	(missionNamespace getVariable ["A3C_InitAborted", false])
	|| {
		!isNull player
	}
};

if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {};


//--------------------------------------------------------------------------------------------------
// CLIENT VALUES
//--------------------------------------------------------------------------------------------------

call compile preprocessFileLineNumbers "A3C_CORE\A3C_InitValuesClient.sqf";


//--------------------------------------------------------------------------------------------------
// CLIENT FUNCTION LIBRARIES
//--------------------------------------------------------------------------------------------------

call compile preprocessFileLineNumbers "A3C_CORE\ai_squad\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\mainDisplay\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\UI_createSafeEventHandler.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_init_keyBinds.sqf";


//-- Map Overlay
call compile preprocessFileLineNumbers "A3C_CORE\ui\mapOverlay\functions\initFunctions.sqf";


//-- Radial Dialog
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\radialMenu\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\settingsMenu\functions\initFunctions.sqf";


//-- HUD UI elements
call compile preprocessFileLineNumbers "A3C_CORE\ui\HUD\squadPlacement\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\selectionPromptPanel\functions\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\suppressionArea\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\hudDynamic\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\mainDisplay\functions\initFunctions.sqf";


//-- Custom formation
call compile preprocessFileLineNumbers "A3C_CORE\ui\hud\customFormation\functions\initFunctions.sqf";


//-- Shared UI
call compile preprocessFileLineNumbers "A3C_CORE\ui\SHARED\functions\initFunctions.sqf";


//-- Arsenal
call compile preprocessFileLineNumbers "A3C_CORE\ui\arsenal\functions\initFunctions.sqf";


//-- Player Eventhandlers
call compile preprocessFileLineNumbers "A3C_CORE\eventhandlers\player\functions\initFunctions.sqf";


[] call A3C_ui_radialMenu_fnc_resetDynamicButtons;

//--------------------------------------------------------------------------------------------------
// RESOLVE SERVER A3C STATE
//--------------------------------------------------------------------------------------------------

waitUntil {
	uiSleep 0.05;

	(missionNamespace getVariable ["A3C_InitAborted", false])
	|| {
		A3C_IsA3CServerResolved
	}
};

if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {};

//--------------------------------------------------------------------------------------------------
// SERVER-SIDE A3C
//--------------------------------------------------------------------------------------------------

if (A3C_IsA3CServer) then {

	//-- Wait until the authoritative server has completed its A3C runtime initialization.
	waitUntil {
		uiSleep 0.05;

		(missionNamespace getVariable ["A3C_InitAborted", false])
		|| {
			missionNamespace getVariable [
				"A3C_ServerInitComplete",
				false
			]
		}
	};

	if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {};

	//-- Server readiness guarantees that the radio channel has already been created.
	waitUntil {
		uiSleep 0.05;
		!isNil "A3C_CUSTOMRADIO_ID"
	};

	A3C_CUSTOMRADIO_ID radioChannelAdd [player];

} else {


//--------------------------------------------------------------------------------------------------
// CLIENT-ONLY A3C FALLBACK
//--------------------------------------------------------------------------------------------------

	//-- The fallback server monitor uses Display 46 as its client-side
	//-- mission lifetime condition. Make sure the display exists before
	//-- starting the FSM.
	waitUntil {
		uiSleep 0.05;
		!isNull (findDisplay 46)
	};

	[] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";


	//-- Local custom radio channel
	A3C_CUSTOMRADIO_ID = radioChannelCreate [
		[0.96, 0.34, 0.13, 0.8],
		"A3C_RADIO",
		"%UNIT_NAME",
		[player]
	];
};


//--------------------------------------------------------------------------------------------------
// CLIENT RUNTIME
//--------------------------------------------------------------------------------------------------

[] execVM "A3C_CORE\A3C_init_Runner.sqf";

diag_log "[A3C]: FINISHED A3C Postinit Client";