// A3C_ai_squad_fnc_actionThrowGTIgrenade

BR_A3C_TEMP_gfeh = A3C_GTI_UNIT addEventHandler [
	"Fired",
	{
		params [
			"_unit",
			"_weapon",
			"_muzzle",
			"_mode",
			"_ammo",
			"_magazine",
			"_projectile"
		];

		_unit forceSpeed -1;

		if (_weapon == "THROW") then {
			_projectile setVelocity BR_A3C_TACV_throwVel;
		};

		if ((side _unit) == WEST) then {
			[_unit] call A3C_Gren_Phrase;
		};

		_unit removeEventHandler ["Fired", BR_A3C_TEMP_gfeh];

		private _fatigueAdd = if (BR_A3C_TACV_throwV0 <= BR_A3C_TACV_GV0MaxS) then {
			BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd
		} else {
			BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd * 2
		};

		_unit setFatigue ((getFatigue _unit) + _fatigueAdd);

		A3C_GREN_MUZZLE = "";
	}
];

private _muzzle = [A3C_GREN_MUZZLE] call MCSS_fnc_getThrowMuzzleForMagazine;

A3C_GTI_UNIT forceSpeed 0;

sleep 0.5;

A3C_GTI_UNIT forceWeaponFire [_muzzle, _muzzle];

["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

A3C_GTI_UNIT = objNull;
A3C_AI_GREN_ARRAY = [];