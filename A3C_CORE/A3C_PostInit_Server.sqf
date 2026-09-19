if (!isServer) exitWith {};
if (is3DEN) exitWith {};
if (missionNamespace getVariable ["A3C_InitAborted", false]) exitWith {};
diag_log "[A3C]: Starting A3C Postinit Server";
//--------------------------------------------------------------------------------------------------
// SERVER PRESENCE / READINESS
//--------------------------------------------------------------------------------------------------

//-- A3C is installed on the authoritative server.
A3C_IsA3CServer = true;
A3C_IsA3CServerResolved = true;

publicVariable "A3C_IsA3CServer";
publicVariable "A3C_IsA3CServerResolved";

//-- Clients must not begin runtime communication until server startup is complete.
A3C_ServerInitComplete = false;
publicVariable "A3C_ServerInitComplete";


//--------------------------------------------------------------------------------------------------
// MISSION EVENTHANDLERS
//--------------------------------------------------------------------------------------------------

A3C_MISSION_EH = addMissionEventHandler [
	"Ended",
	{
		A3C_MISSIONENDED = true;
		publicVariable "A3C_MISSIONENDED";
	}
];


//--------------------------------------------------------------------------------------------------
// RADIO CHANNEL
//--------------------------------------------------------------------------------------------------

A3C_CUSTOMRADIO_ID = radioChannelCreate [
	[0.96, 0.34, 0.13, 0.8],
	"A3C_RADIO",
	"%UNIT_NAME",
	[]
];

publicVariable "A3C_CUSTOMRADIO_ID";


//--------------------------------------------------------------------------------------------------
// SERVER MONITOR
//--------------------------------------------------------------------------------------------------

A3C_SERVER_MONITOR_FSM = [] execFSM "A3C_CORE\FSM\A3C_MON_SERVER.fsm";


//-- Do not report the server as ready until the FSM has actually entered its Start state.
//-- These variables are initialized by A3C_MON_SERVER.fsm.
[] spawn {
	diag_log "[A3C]: Starting A3C Postinit Server async";
	waitUntil {
		uiSleep 0.01;

		!isNil "A3C_exitServerMon"
		&& {!isNil "A3C_Mon_Server_EH_units"}
	};

	A3C_ServerInitComplete = true;
	publicVariable "A3C_ServerInitComplete";
	diag_log "[A3C]: FINISHED A3C Postinit Server async";
};


diag_log "[A3C]: FINISHED A3C Postinit Server";