

//-- obsolete.

if (isDedicated) exitwith {};

call compile preprocessFileLineNumbers "A3C_CORE\ui\A3C_events.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_INIT_VALUES.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_fncs_Main.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_Mode_PLANNING.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_Mode_HUD.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\radial\A3C_RadialMenu_INIT.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\ui\MapOverlay\A3C_DIALOG_INIT.sqf";
call compile preprocessFileLineNumbers "A3C_CORE\A3C_Mode_ZEUS.sqf";
[] execVM "A3C_CORE\A3C_EXECUTE.SQF";

A3C_loaded = true;

