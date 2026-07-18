#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

params ["_display","_key","_shift","_ctrl","_alt"];

// player commandchat format ["MAP KEY-UP: %1 (%2)", _key, keyName _key];

if (A3C_isPlayerLeader) exitWith {false};
if ( !isNull(findDisplay 312) ) exitWith {false}; //-- ZEUS interface is open. Prevent most A3C stuff

A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

switch (true) do {
	case 
	(
		a3c_is_HC_remote
		&& {_key in [200,203,205,208]}
	) :
	{
			_this call A3C_ui_shared_fnc_onKeyUp_remoteVehicle;
	};
	case (
		vehicle player isKindOf "HELICOPTER"
		&& {player == (gunner vehicle player)}
	) : {
			(vehicle player) spawn {
			sleep 1;
			_this flyInHeight((getPosATL _this) select 2);
		};
	};
	
};

false

