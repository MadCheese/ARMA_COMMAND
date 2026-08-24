#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

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
	A3C_CurSelRequestId = (
		missionNamespace getVariable [
			"A3C_CurSelRequestId",
			0
		]
	) + 1;
};

_control lbSetCurSel _index;

if (!_doExecuteListBoxAction) then {
	private _controlDisplay = ctrlParent _control;

	if (
		!isNull _controlDisplay
		&& {ctrlIDD _controlDisplay == IDD_RADIAL_MENU}
	) then {
		/*
			Radial list-box handlers execute with call, so their event has already
			finished when lbSetCurSel returns. Release immediately and do not block
			a genuine click made during the following 0.2 seconds.
		*/
		A3C_CurSel = false;
	} else {
		private _requestId = A3C_CurSelRequestId;

		[_requestId] spawn {
			params ["_requestId"];

			// Other displays can still use scheduled list-box handlers.
			sleep 0.2;

			// Only the newest programmatic selection may release the guard. This
			// prevents overlapping calls from unlocking an event started later.
			if (
				_requestId
				== missionNamespace getVariable [
					"A3C_CurSelRequestId",
					-1
				]
			) then {
				A3C_CurSel = false;
			};
		};
	};
};