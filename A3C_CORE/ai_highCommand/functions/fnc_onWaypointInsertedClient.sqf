// A3C_ai_highCommand_fnc_onWaypointInsertedClient

//-- note: normally this fnc would belong into a response of mapOverlay
//--> reason for it being in highCommand is that it's a remotely executed function which might be needed by server
//--> mapOverlay functions are not compiled on dedicated servers, so we need to include it as a highCommand fnc

#include "..\..\ui\mapOverlay\dialog_defines.hpp"

params ["_group", "_wpI"];

if (isDedicated) exitWith {};
if (isNil "A3C_HC_ACTIVEGROUP") exitWith {};

private _display = findDisplay IDD_MAP_OVERLAY;
if (isNull _display) exitWith {};

private _wpMenu = _display displayCtrl IDC_MAP_HCWP_Parent;
if !(ctrlShown _wpMenu) exitWith {};

if (A3C_HC_ACTIVEGROUP == _group) then {
	if (_wpI < A3C_HC_ACTIVE_IND) then {
		A3C_HC_ACTIVE_IND = A3C_HC_ACTIVE_IND + 1;
	};

	if (_wpI == A3C_HC_ACTIVE_IND) then {
		_wpMenu ctrlShow false;
	};
};