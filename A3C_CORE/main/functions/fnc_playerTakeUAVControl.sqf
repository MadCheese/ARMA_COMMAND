// A3C_main_fnc_playerTakeUAVControl

private _uav = getConnectedUAV player;

if (isNull _uav) exitWith {};

private _hasGunner = !isNull (gunner _uav);
private _actionRole = if (_hasGunner) then {"Gunner"} else {"Driver"};
private _actionName = format ["SwitchToUAV%1", _actionRole];
player action [_actionName, _uav];