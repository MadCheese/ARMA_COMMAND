// A3C_ui_shared_fnc_lbSetCurSel

params ["_control", "_index"];

private _doExecuteListBoxAction = if ((count _this) > 2) then {
	_this select 2
} else {
	false
};

if !(_doExecuteListBoxAction isEqualType true) exitWith {
	systemChat format [
		"A3C_ui_shared_fnc_lbSetCurSel: Wrong parameter type for doExecuteAction: %1",
		_this
	];
};

if (!_doExecuteListBoxAction) then {
	A3C_CurSel = true;
};

_control lbSetCurSel _index;

if (!_doExecuteListBoxAction) then {
	[] spawn {
		// The delay is required because the LB change function takes time to execute.
		sleep 0.2;
		A3C_CurSel = false;
	};
};