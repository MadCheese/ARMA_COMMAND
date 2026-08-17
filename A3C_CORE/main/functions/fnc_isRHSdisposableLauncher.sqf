// A3C_main_fnc_isRHSdisposableLauncher

params ["_launcher"];


private _weaponsConfig = configFile >> "CfgWeapons";

getNumber (
	_weaponsConfig
	>> _launcher
	>> "rhs_disposable"
) > 0
&& {
	isClass (
		_weaponsConfig
		>> (_launcher + "_used")
	)
}