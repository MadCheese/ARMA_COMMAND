#include "..\..\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_close_HCGP_Parent

params [
	["_delay", 0, [0]]
];

_delay spawn {
	params ["_delay"];

	uiSleep _delay;

	private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
	private _radialDisplay = findDisplay IDD_RADIAL_MENU;

	if (!isNull _mapDisplay) then {
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

	if (!isNull _radialDisplay) then {
		private _dashboard =
			_radialDisplay displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT;

		if (!isNull _dashboard) then {
			_dashboard ctrlShow false;
		};
	};
};