// A3C_main_fnc_getMuzzleSwitchGesture

params [
	["_unit", objNull, [objNull]],
	["_weapon", "", [""]],
	["_removeAttachment", false, [false]]
];

if (isNull _unit || {_weapon isEqualTo ""}) exitWith {
	""
};

if (_weapon isEqualTo handgunWeapon _unit) exitWith {
	private _reloadAction = getText (
		configFile
		>> "CfgWeapons"
		>> _weapon
		>> "reloadAction"
	);

	if (_reloadAction isEqualTo "") then {
		"GestureReloadPistol"
	} else {
		_reloadAction
	}
};

if (_removeAttachment) then {
	"GestureDismountMuzzle"
} else {
	"GestureMountMuzzle"
}