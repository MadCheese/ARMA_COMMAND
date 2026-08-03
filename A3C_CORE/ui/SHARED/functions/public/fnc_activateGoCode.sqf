#include "..\..\..\mapOverlay\dialog_defines.hpp"

// A3C_ui_shared_fnc_activateGoCode

/*
	Activates a side-qualified go-code for 2.1 seconds.

	Used by the radial menu and map overlay. The corresponding map-overlay
	controls are hidden when the map overlay is open.
*/

params [
	["_code", "", [""]],
	["_activationSide", side (group player), [west]]
];

_code = toUpper _code;

if !(_code in ["A", "B", "C", "D"]) exitWith {
	diag_log format [
		"A3C_ui_shared_fnc_activateGoCode: Invalid go-code: %1",
		_code
	];
};

private _activationVariableName = [
	_code,
	_activationSide
] call A3C_main_fnc_getGoCodeActivationVariableName;

if (_activationVariableName == "") exitWith {
	diag_log format [
		"A3C_ui_shared_fnc_activateGoCode: Invalid activation side for go-code %1: %2",
		_code,
		_activationSide
	];
};

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;

if (!isNull _mapDisplay) then {
	private _goCodeControlIds = switch (_code) do {
		case "A": {
			[
				IDC_MAP_Order_GoCode_A_IMG,
				IDC_MAP_Order_GoCode_A_BTN
			]
		};

		case "B": {
			[
				IDC_MAP_Order_GoCode_B_IMG,
				IDC_MAP_Order_GoCode_B_BTN
			]
		};

		case "C": {
			[
				IDC_MAP_Order_GoCode_C_IMG,
				IDC_MAP_Order_GoCode_C_BTN
			]
		};

		case "D": {
			[
				IDC_MAP_Order_GoCode_D_IMG,
				IDC_MAP_Order_GoCode_D_BTN
			]
		};
	};

	{
		private _control = _mapDisplay displayCtrl _x;

		if (!isNull _control) then {
			_control ctrlShow false;
		};
	} forEach (
		[
			IDC_MAP_DynamicCombo,
			IDC_MAP_SQWP_Parent
		] + _goCodeControlIds
	);
};

private _hasTerminal = (
	(items player) + (assignedItems player)
) findIf {
	["A3C_Terminal", _x] call BIS_fnc_inString
} > -1;

/*
	The activation variable is qualified by both the GoCode and the
	activating player's side.

	For example, code "A" activated by a West player resolves to:
	A3C_GoCode_Activate_A_WEST
*/
[
	_activationVariableName,
	_hasTerminal
] spawn {
	params [
		"_activationVariableName",
		"_hasTerminal"
	];

	missionNamespace setVariable [
		_activationVariableName,
		true
	];

	/*
		Preserved legacy behavior: activation is broadcast only when the
		player has an A3C terminal item.
	*/
	if (_hasTerminal) then {
		publicVariable _activationVariableName;
	};

	sleep 2.1;

	missionNamespace setVariable [
		_activationVariableName,
		false
	];

	/*
		Deactivation was always broadcast in the legacy implementation.
		The additional conditional publicVariable call was redundant and
		has therefore been removed.
	*/
	publicVariable _activationVariableName;
};

[] spawn {
	sleep 0.5;

	[] remoteExec [
		"A3C_ui_shared_fnc_toggleGocodeCtrls",
		0
	];

	sleep 2;

	[] remoteExec [
		"A3C_ui_shared_fnc_toggleGocodeCtrls",
		0
	];
};