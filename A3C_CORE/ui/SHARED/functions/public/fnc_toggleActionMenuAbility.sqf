// A3C_ui_shared_fnc_toggleActionMenuAbility

private _mode = _this; //-- "DISABLE" or "ENABLE"

if !(_mode in ["DISABLE", "ENABLE"]) exitWith {
	systemChat format [
		"A3C_ui_shared_fnc_toggleActionMenuAbility: Invalid mode: %1",
		_mode
	];
};

private _modeString = if (_mode == "DISABLE") then {"true"} else {""};

{
	inGameUISetEventHandler [
		_x,
		_modeString
	];
} forEach [
	"PrevAction",
	"NextAction"
];
