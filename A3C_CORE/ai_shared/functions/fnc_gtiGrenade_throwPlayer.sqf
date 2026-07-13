// A3C_ai_shared_fnc_gtiGrenade_throwPlayer
// Applies GTI grenade throw mode to player. Triggered by CBA keybind.

params ["_mode"];

if (!isNull objectParent player) exitWith {};
if ((currentThrowable player) isEqualTo []) exitWith {};
if (lifeState player in ["INJURED", "INCAPACITATED"]) exitWith {};

A3C_GTI_UNIT = player;

if (_mode == "DOWN") exitWith {
	BR_A3C_TACV_throwTheta = 45;
	BR_A3C_TACV_throwTheta_Add = 0;

	BR_A3C_TACV_oefId = [
		"BR_A3C_TACV_oefId",
		"onEachFrame",
		"A3C_ai_shared_fnc_gtiGrenade_onEachFrameTick"
	] call BIS_fnc_addStackedEventHandler;

	BR_A3C_GRENADEMODE = true;
};

if (BR_A3C_GRENADEMODE) then {
	["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

	if (A3C_WAIT_THROW_P == 0) then {
		A3C_WAIT_THROW_P = 1;

		private _currentThrowable = currentThrowable player;
		private _throwMuzzle = _currentThrowable select 1;

		player forceWeaponFire [_throwMuzzle, _throwMuzzle];

		[] spawn {
			sleep 2.5;

			if (player == A3C_GTI_UNIT && { !BR_A3C_GRENADEMODE }) then {
				A3C_WAIT_THROW_P = 0;
				A3C_GTI_UNIT = objNull;
			};
		};
	};
};

BR_A3C_GRENADEMODE = false;