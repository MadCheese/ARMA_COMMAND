// A3C_ui_mapOverlay_fnc_completeWaypointUiResponse

#include "..\..\dialog_defines.hpp"

params ["_group", "_currentWaypoint"];

if ({isNil _x} count ["A3C_HC_ACTIVEGROUP", "A3C_HC_ACTIVE_IND"] > 0) exitWith {};

private _display = findDisplay IDD_MAP_OVERLAY;
if (isNull _display) exitWith {};

private _wpMenu = _display displayCtrl IDC_MAP_HCWP_Parent;
if !(ctrlShown _wpMenu) exitWith {};

if (A3C_HC_ACTIVEGROUP == _group && {A3C_HC_ACTIVE_IND == _currentWaypoint}) then {
	_wpMenu ctrlShow false;
};