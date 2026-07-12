// MCSS_fnc_isUnitCopilot
// Find out if a unit is in a copilot seat.

private _unit = _this;
private _vehicle = objectParent _unit;

if (isNull _vehicle) exitWith {false};

private _turretsConfig = configFile >> "CfgVehicles" >> typeOf _vehicle >> "turrets";
private _isCopilot = false;

for "_turretIndex" from 0 to ((count _turretsConfig) - 1) do {
	private _turretConfig = _turretsConfig select _turretIndex;

	if (getNumber (_turretConfig >> "iscopilot") == 1) exitWith {
		_isCopilot = (_vehicle turretUnit [_turretIndex]) == _unit;
	};
};

_isCopilot