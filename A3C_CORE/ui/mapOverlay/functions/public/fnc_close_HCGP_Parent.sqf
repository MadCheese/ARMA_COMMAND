#include "..\..\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_close_HCGP_Parent

params [
	["_delay", 0, [0]]
];
disableSerialization;

// Invalidate the map geometry owner immediately, before the delayed hide.
// The radial dashboard retains its existing close behavior.
private _closingMap = findDisplay IDD_MAP_OVERLAY;
if (!isNull _closingMap) then {
    (_closingMap displayCtrl IDC_MAP_HCGP_Parent) setVariable ["A3C_HCGP_LayoutContext", nil];
};

[_delay, _closingMap] spawn {
	params ["_delay", "_mapDisplay"];
	disableSerialization;

	uiSleep _delay;

	private _radialDisplay = findDisplay IDD_RADIAL_MENU;

    isNil {
	if (!isNull _mapDisplay && {
        ((_mapDisplay displayCtrl IDC_MAP_HCGP_Parent) getVariable ["A3C_HCGP_LayoutContext", []]) isEqualTo []
    }) then {
		{
			private _control = _mapDisplay displayCtrl _x;

			if (!isNull _control) then {
				_control ctrlShow false;
			};
		} forEach [
			IDC_MAP_HCGP_Parent,
			IDC_SHARED_UI_DASHBOARD_PARENT
		];
	};
    };

	if (!isNull _radialDisplay) then {
		private _dashboard =
			_radialDisplay displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT;

		if (!isNull _dashboard) then {
			_dashboard ctrlShow false;
		};
	};
};
