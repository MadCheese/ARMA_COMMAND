// A3C_ai_squad_fnc_unitRouteHold

private _units = _this select {
	!isPlayer _x
};

private _unitNames = "";
private _coverUnits = [];

{
	private _expectedDestination = expectedDestination _x;

	if ((_expectedDestination select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {
		if !(_x getVariable ["A3C_HOLD_COVER", false]) then {
			_x setVariable ["A3C_HOLD_COVER", true, false];
			_coverUnits pushBackUnique _x;
		};
	};

	_x setVariable ["A3C_HOLD", true, false];

	_unitNames = _unitNames + ([_x] call MCSS_fnc_getUnitNameString);
} forEach _units;

if !(_coverUnits isEqualTo []) then {
	[_coverUnits, 1] spawn A3C_ai_squad_fnc_actionFindCover;
};

player groupChat (_unitNames + " HOLD");

[A3C_MAP_CommandMode] call A3C_UI_MAP_UFSB_RefreshControlBar;