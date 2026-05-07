//-- currently not used


params ["_unit"];

private _result = ([_unit] call A3C_ai_shared_fnc_getExplosiveUnitMagazines) select {
	private _magCfg = configFile >> "CfgMagazines" >> _x;
	private _ammoCfg = configFile >> "CfgAmmo" >> getText (_magCfg >> "ammo");

	getText (_ammoCfg >> "mineTrigger") == "RemoteTrigger"
};

_result