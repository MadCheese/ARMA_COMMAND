diag_log "[A3C]: EXECUTING preInit";

//-- Dev-only settings that A3C may need during PreInit
A3C_DEBUG = false;

//-- Match addon Extended_PreInit_EventHandlers order
call compile preprocessFileLineNumbers "A3C_CORE\A3C_init_KeyBinds_CBA.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_Init.sqf";

diag_log "[A3C]: FINISHED preInit";