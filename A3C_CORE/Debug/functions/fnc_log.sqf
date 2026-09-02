// A3C_Debug_fnc_log

if !(_this isEqualType "") exitWith {
	diag_log "[A3C] ERROR: A3C_Debug_fnc_log called with invalid parameter type.";
};

private _message = "[A3C] " + _this;

_message remoteExec ["diag_log", 0];