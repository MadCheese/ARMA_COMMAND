if (is3DEN) exitWith {};



diag_log "[A3C]: //////////////////////////////////////////////////////////////////////////////////////";
diag_log "[A3C]: STARTING A3C_init";

//--------------------------------------------------------------------------------------------------
// A3C PREINIT
//--------------------------------------------------------------------------------------------------

//-- Used to prevent PostInit from continuing if PreInit deliberately aborts.
if (isNil "A3C_InitAborted") then {
	A3C_InitAborted = false;
};

A3C_InitScreenShown = false;
A3C_InitializationAbortHandled = false;


//--------------------------------------------------------------------------------------------------
// FUNCTION PREPARATION
//--------------------------------------------------------------------------------------------------

//-- Although these are primarily server functions, they must also exist locally on a client
//-- when A3C is not installed on the actual server and A3C_MON_SERVER.fsm runs client-side.
call compile preprocessFileLineNumbers "A3C_CORE\server\functions\initFunctions.sqf";


//--------------------------------------------------------------------------------------------------
// COMMON VALUES / FUNCTIONS
//--------------------------------------------------------------------------------------------------

call compile preprocessFileLineNumbers "A3C_CORE\A3C_InitValuesCommon.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\MCSS\initFunctions.sqf";

call compile preprocessFileLineNumbers "A3C_CORE\main\functions\initFunctions.sqf";


//--------------------------------------------------------------------------------------------------
// INCOMPATIBLE ADDONS
//--------------------------------------------------------------------------------------------------

if (A3C_IsAICommand) exitWith {

	A3C_InitAborted = true;

	if (isServer) then {
		publicVariable "A3C_InitAborted";
	};

	[] call A3C_main_fnc_handleInitializationAbort;
};

if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {
	[] call A3C_main_fnc_handleInitializationAbort;
};

//--------------------------------------------------------------------------------------------------
// INITIALIZATION SCREEN
//--------------------------------------------------------------------------------------------------

if (hasInterface) then {

	"A3C_INIT_BLACK" cutText [
		"",
		"BLACK FADED",
		999
	];

	"A3C_INIT_IMAGE" cutRsc [
		"A3C_InitScreen",
		"PLAIN",
		0,
		false
	];

	A3C_InitScreenShown = true;
};

//--------------------------------------------------------------------------------------------------
// COMMON DATA
//--------------------------------------------------------------------------------------------------

call compile preprocessFileLineNumbers "A3C_CORE\data\A3C_data_bPosNoAccess.sqf";


//--------------------------------------------------------------------------------------------------
// SHARED FUNCTION LIBRARIES
//--------------------------------------------------------------------------------------------------

call compile preprocessFileLineNumbers "A3C_CORE\ai_highCommand\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ai_shared\functions\initFunctions.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ai_rail\functions\initFunctions.sqf";


//-- Debug
call compile preprocessFileLineNumbers "A3C_CORE\Debug\initFunctions.sqf";


//--------------------------------------------------------------------------------------------------
// SERVER PRESENCE
//--------------------------------------------------------------------------------------------------

//-- If A3C PreInit successfully reached this point on an isServer machine,
//-- A3C is installed and its PreInit phase has completed there.
//
//-- Runtime initialization itself happens later in A3C_PostInit_Server.sqf.
if (isServer) then {

	A3C_IsA3CServer = true;
	A3C_IsA3CServerResolved = true;

	publicVariable "A3C_IsA3CServer";
	publicVariable "A3C_IsA3CServerResolved";

	A3C_ServerInitComplete = false;
	publicVariable "A3C_ServerInitComplete";
};

diag_log "[A3C]: FINISHED A3C_init";