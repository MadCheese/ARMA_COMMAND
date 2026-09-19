diag_log "[A3C]: EXECUTING postInit";

if (is3DEN) exitWith {};

//-- Dedicated server, hosted server, or SP server portion
if (isServer) then {
    call compile preprocessFileLineNumbers "A3C_CORE\A3C_PostInit_Server.sqf";
};

//-- Player client portion.
//-- On a hosted server/SP both blocks execute, just like the real addon needs.
if (hasInterface) then {
	[] execVM "A3C_CORE\A3C_PostInit_Client.sqf";
};

diag_log "[A3C]: FINISHED postInit";