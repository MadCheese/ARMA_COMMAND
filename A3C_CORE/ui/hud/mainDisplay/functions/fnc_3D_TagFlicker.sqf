// A3C_ui_mainDisplay_fnc_3D_TagFlicker

params ["_pos", "_mode"];

A3C_UI_HUD_3D_TAGGING = true;

private _iconType = A3C_UI_HUD_3D_TAG_ICON_TYPE;

A3C_UI_HUD_3D_TAG_ICON_COL = switch (_mode) do {
	case "STANDARD": {
		[1, 1, 1, 0.7]
	};

	case "BOARD": {
		[
			A3C_UI_COLOR_YELLOW,
			0.7
		] call A3C_ui_shared_fnc_getColorArrayWithOpacity
	};

	case "SUPPRESSION": {
		[
			A3C_UI_COLOR_RED,
			0.7
		] call A3C_ui_shared_fnc_getColorArrayWithOpacity
	};

	default {
		A3C_UI_HUD_3D_TAG_ICON_COL
	};
};

if (
	!isNull cursorTarget &&
	{ _mode in ["STANDARD", "BOARD"] }
) then {
	_pos = getPos cursorTarget;
	_pos set [
		2,
		((boundingBox cursorTarget select 1) select 2) / 2
	];
};

// Animate icon zoom.
if !(_mode in ["HC_WP", "SUPPRESSION"]) then {
	private _startTime = time;
	private _animationLength = 3;

	while { (time - _startTime) < _animationLength } do {
		A3C_UI_HUD_3D_TAG_ICON_POS = _pos;

		private _animationProgress = (
			_animationLength - (time - _startTime)
		) / _animationLength;

		A3C_UI_HUD_3D_TAG_ICON_SIZE = (4 * _animationProgress) max 2;

		if (A3C_UI_HUD_3D_TAG_ICON_SIZE == 2) exitWith {};
	};
};

// End flicker.
for "_i" from 1 to 4 do {
	A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
	sleep 0.1;

	A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
	sleep 0.1;
};

// Reset variables to defaults.
A3C_UI_HUD_3D_TAG_ICON_COL = [1, 1, 1, 0.7];
A3C_UI_HUD_3D_TAG_ICON_SIZE = 3;
A3C_UI_HUD_3D_TAG_ICON_POS = [0, 0, 0];
A3C_UI_HUD_3D_TAG_ICON_MOD = "NONE";
A3C_UI_HUD_3D_TAGGING = false;