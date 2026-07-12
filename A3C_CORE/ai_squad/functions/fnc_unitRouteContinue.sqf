// A3C_ai_squad_fnc_unitRouteContinue

private _units = _this select {
	!isPlayer _x
};

private _unitNames = "";

{
	_x setVariable ["A3C_HOLD", false, false];
	_x setVariable ["A3C_HOLD_COVER", false, false];

	_unitNames = _unitNames + ([_x] call MCSS_fnc_getUnitNameString);
} forEach _units;

player groupChat (_unitNames + " MOVE");

[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_RefreshControlBar;