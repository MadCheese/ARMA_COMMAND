#include "..\script_component.hpp"

params ["_unit", "_weapon", "_muzzl", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

if (_weapon isEqualTo "THROW") exitWith {
	if (A3C_GTI_UNIT isEqualTo _unit) then {
		[player, _magazine] call A3C_ai_shared_fnc_gtiGrenade_callout;
		_projectile setVelocity BR_A3C_TACV_throwVel;
		A3C_GTI_UNIT = objNull;
	};

	private _reloadTime = getNumber (configFile >> "CfgWeapons" >> "Throw" >> _muzzl >> "magazineReloadTime");
	private _waitThrowP = [_reloadTime, 1] call BIS_fnc_cutDecimals;

	for "_i" from 0 to _reloadTime step 0.1 do {
		A3C_WAIT_THROW_P = if (_waitThrowP isEqualTo 0) then {
			0
		} else {
			private _throwProgress = ((_waitThrowP - _i) / _waitThrowP) max 0;
			[_throwProgress, 1] call BIS_fnc_cutDecimals
		};

		sleep 0.1;
	};

	A3C_WAIT_THROW_P = 0;
};

if (A3C_fireOnMyLeadUnits isNotEqualTo []) then {
	player groupRadio "SentFireNoTarget";
	[] call A3C_ai_squad_fnc_releaseFOML;
};