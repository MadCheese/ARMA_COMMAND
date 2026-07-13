// A3C_main_fnc_playerConnectToUAV

params ["_uav", "_mode"];

player switchCamera "Internal";
player connectTerminalToUAV objNull;
player connectTerminalToUAV _uav;

if (_mode == 1) then {
	[] spawn A3C_main_fnc_playerTakeUAVControl;
};
