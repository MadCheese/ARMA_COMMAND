#include "..\..\..\radial\radialMenu\dialog_defines.hpp"
#include "..\..\shared_ui_defines.hpp"

// A3C_ui_shared_fnc_getBackgroundColor

params ["_mode"];

private _radialBackgrounds = [];
private _hudBackground = controlNull;

switch (_mode) do {
	case "RADIAL": {
		_radialBackgrounds = (
			[
				"radial_extendedBackgrounds"
			] call A3C_ui_radialMenu_fnc_ctrlGroup
		) + [
			[
				"bgCore"
			] call A3C_ui_radialMenu_fnc_ctrl
		];

		_radialBackgrounds = _radialBackgrounds select {
			!isNull _x
		};
	};

	case "HUD_MENU": {
		private _hudDisplay = uiNamespace getVariable [
			"A3C_UI_squadPlacement_overlay",
			displayNull
		];

		if (!isNull _hudDisplay) then {
			_hudBackground = _hudDisplay displayCtrl 15;
		};
	};
};

if (sunOrMoon < 1) then {
	switch (_mode) do {
		case "RADIAL": {
			{
				_x ctrlSetTextColor [0, 0.5, 0.8, 0.6];
			} forEach _radialBackgrounds;
		};

		case "HUD_MENU": {
			if (!isNull _hudBackground) then {
				_hudBackground ctrlSetTextColor [0, 0.5, 0.8, 0.4];
			};
		};
	};
} else {
	switch (_mode) do {
		case "RADIAL": {
			{
				_x ctrlSetTextColor [0, 0, 0, 0.6];
			} forEach _radialBackgrounds;
		};

		case "HUD_MENU": {
			if (!isNull _hudBackground) then {
				_hudBackground ctrlSetTextColor [0, 0, 0, 0.4];
			};
		};
	};
};

if (
	_mode == "HUD_MENU" &&
	{ currentVisionMode player == 1 }
) then {
	if (!isNull _hudBackground) then {
		_hudBackground ctrlSetTextColor [0, 0.5, 0.8, 0.4];
	};
};