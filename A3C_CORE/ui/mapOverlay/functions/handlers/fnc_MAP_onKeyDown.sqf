#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_MAP_onKeyDown

/*
 * This handler is needed because ESC behaves differently than all other keys.
 *
 * This keybind is the current fix for what are probably Arma 3 quirks:
 *
 * 1. Arrow keys used for vehicle remote do not seem to register at all
 *    in keyDown events attached to the dialog itself. They do register
 *    on the main map display.
 *
 *    Strangely enough, keyUp registers fine. So for arrows, and the block
 *    with PageUp/PageDown, this handler is required.
 *
 *    It is possible that the project creates this circumstance somewhere.
 *
 * 2. To use ESC for closing popup menus, such as GP/WP context menus,
 *    without closing the entire map, this must be added directly to the map.
 *
 *    `if (_key == 1) exitWith {true};` only works on the main map.
 *
 * The map and overlay handlers are still kept separate for organization.
 * They may eventually be merged into the map event-handler path.
 */

params [
	"_mapControl",
	"_key",
	"_shift",
	"_ctrl",
	"_alt"
];

private _display = findDisplay IDD_MAP_OVERLAY;

private _blockDefault = false;

switch (true) do {
	case (_key == 1): {
		private _groupContextMenuHC =
			_display displayCtrl IDC_MAP_HCGP_Parent;

		private _groupDashboardHC =
			_display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT;

		private _wpContextMenuHC =
			_display displayCtrl IDC_MAP_HCWP_Parent;

		if (ctrlShown _groupContextMenuHC) then {
			{
				_x ctrlShow false;
			} forEach [
				_groupContextMenuHC,
				_groupDashboardHC
			];

			_blockDefault = true;
		} else {
			if (ctrlShown _wpContextMenuHC) then {
				_wpContextMenuHC ctrlShow false;

				_blockDefault = true;
			};
		};
	};

	case (_key == 29): {
		if (!isNull _display) then {
			// Additional prevention of vanilla engine-level line drawing
			// while the overlay is open.
			_blockDefault = true;
		};
	};

	case (
		a3c_is_HC_remote
		&& {_key in [200, 203, 205, 208]}
	): {
		_this call A3C_UI_SHARED_onKeyDown_remoteVehicle;

		_blockDefaultKey = true;
	};
};

_blockDefault