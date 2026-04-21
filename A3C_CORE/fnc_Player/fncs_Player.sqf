A3C_fnc_playerConnectToUAV = {
	params ["_uav", "_mode"];
	if (unitIsUAV cameraOn) then {};
	player switchCamera "Internal";
	player connectTerminalToUAV objNull;
	player connectTerminalToUAV _uav;
	if (_mode == 1) then {
		[] spawn A3C_fnc_playerTakeUAVControl;
	};
};

A3C_fnc_playerTakeUAVControl = {
	private _uav = getConnectedUAV player;
	if (isNull _uav) exitWith {};
	private _hasGunner = !isNull (gunner _uav);
	private _actionRole = if (_hasGunner) then {"Gunner"} else {"Driver"};
	private _actionName = format ["SwitchToUAV%1", _actionRole];
	player action [_actionName, _uav];

};

// A3C_fnc_playerReleaseUAVControl = {
// 	player switchCamera "Internal";
// };