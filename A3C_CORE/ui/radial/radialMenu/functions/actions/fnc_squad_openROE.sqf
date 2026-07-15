// A3C_ui_radialMenu_fnc_squad_openROE

//-- Open Radial SQ-level behaviour and combatMode controls via A3C_DSP_HUD_DYNAMIC.
A3C_DISABLE_RADIAL = true;

[] call A3C_ui_radialMenu_fnc_closeDisplay;

with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "A3C_DSP_HUD_DYNAMIC";
};

setMousePosition [0.5, 0.5];

private _display = findDisplay 100100;

// Button properties.
private _buttonsPerRow = 5;
private _rows = 2;

// Scaling factor to control the size of the entire dialog.
private _scaleFactor = 4;

// Adjusted grid size based on scaling factor.
private _grid = 12 * _scaleFactor;

private _controlsGroup = _display ctrlCreate ["RscControlsGroup", 100];

_controlsGroup ctrlSetPosition [
	(safeZoneX + (safeZoneW / 2)) - ((A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelW * 2)),
	(safeZoneY + (safeZoneH / 2)) - ((A3C_UI_GRID_SIZE * (_grid / 4)) * (pixelGridNoUIScale * pixelH * 2)),
	(A3C_UI_GRID_SIZE * _grid) * (pixelGridNoUIScale * pixelW * 2),
	(A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelH * 2)
];

_controlsGroup ctrlCommit 0;

private _ctrlImageG = _display ctrlCreate ["RscPicture", 101, _controlsGroup];

_ctrlImageG ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_CombatBehaviour.paa";

_ctrlImageG ctrlSetPosition [
	0,
	0,
	(A3C_UI_GRID_SIZE * _grid) * (pixelGridNoUIScale * pixelW * 2),
	(A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelH * 2)
];

private _bgColor = if (sunOrMoon < 1) then {
	[0, 0.5, 0.8, 0.6]
} else {
	[0, 0, 0, 0.6]
};

_ctrlImageG ctrlSetTextColor _bgColor;
_ctrlImageG ctrlCommit 0;

// Define adjustable boundaries for button placement.
private _horizontalBoundary = 0.1;
private _verticalBoundary = 0.29;

// Calculate button placement boundaries.
private _backgroundWidth = (A3C_UI_GRID_SIZE * _grid) * (pixelGridNoUIScale * pixelW * 2);
private _backgroundHeight = (A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelH * 2);
private _usableWidth = _backgroundWidth * (1 - 2 * _horizontalBoundary);
private _usableHeight = _backgroundHeight * (1 - 2 * _verticalBoundary);

// Button dimensions based on usable space.
private _buttonDim = _usableHeight / _rows;
private _horizontalSpacing = (_usableWidth - (_buttonsPerRow * _buttonDim)) / (_buttonsPerRow - 1);

// Starting offsets for button placement.
private _horizontalOffset = _horizontalBoundary * _backgroundWidth;
private _verticalOffset = _verticalBoundary * _backgroundHeight;

// Define button labels and tooltips.
private _behaviours = ["CARELESS", "SAFE", "STEALTH", "AWARE", "COMBAT"];
private _behaviourTooltips = [
	"SET BEHAVIOUR: CARELESS",
	"SET BEHAVIOUR: SAFE",
	"SET BEHAVIOUR: STEALTH",
	"SET BEHAVIOUR: AWARE",
	"SET BEHAVIOUR: COMBAT"
];

private _combatModes = ["BLUE", "GREEN", "WHITE", "YELLOW", "RED"];
private _combatModeTooltips = [
	"SET ROE: NEVER FIRE, KEEP FORMATION",
	"SET ROE: HOLD FIRE, KEEP FORMATION",
	"SET ROE: HOLD FIRE, ENGAGE AT WILL",
	"SET ROE: FIRE AT WILL, KEEP FORMATION",
	"SET ROE: FIRE AT WILL, ENGAGE AT WILL"
];

private _colorPalettes = [
	[0.17, 0.86, 0.92, 0.6],
	[0, 1, 0, 0.4],
	[1, 1, 1, 0.4],
	[1, 1, 0, 0.4],
	[0.5, 0, 0, 0.4]
];

private _awareButtonX = 0.5;
private _awareButtonY = 0.5;

// Loop through rows and buttons.
for "_i" from 0 to (_rows - 1) do {
	private _yPos = _verticalOffset + (_i * _buttonDim);
	private _image = if (_i == 0) then {
		"A3C_CORE\ui\pictures\icon_menu_behaviour.paa"
	} else {
		"A3C_CORE\ui\pictures\icon_menu_combatMode.paa"
	};

	for "_t" from 0 to (_buttonsPerRow - 1) do {
		private _xPos = _horizontalOffset + (_t * (_buttonDim + _horizontalSpacing));

		private _ctrlImg = _display ctrlCreate ["RscPicture", -1, _controlsGroup];

		_ctrlImg ctrlSetText _image;
		_ctrlImg ctrlSetTextColor (_colorPalettes select _t);
		_ctrlImg ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];
		_ctrlImg ctrlCommit 0;

		private _ctrlBtn = _display ctrlCreate ["A3C_RscButton_Invisible", -1, _controlsGroup];

		_ctrlBtn ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];

		private _tooltip = if (_i == 0) then {
			_behaviourTooltips select _t
		} else {
			_combatModeTooltips select _t
		};

		private _mode = if (_i == 0) then {
			"BEHAVIOUR"
		} else {
			"COMBATMODE"
		};

		private _value = if (_i == 0) then {
			_behaviours select _t
		} else {
			_combatModes select _t
		};

		private _buttonAction = format [
			"['%1', '%2'] call A3C_main_fnc_orderIndividualMacro;",
			_mode,
			_value
		];

		_ctrlBtn ctrlSetTooltip _tooltip;
		_ctrlBtn buttonSetAction _buttonAction;
		_ctrlBtn ctrlCommit 0;

		//-- Save the position of the third behaviour-row button.
		if (_i == 0 && {_t == 2}) then {
			_awareButtonX = _xPos;
			_awareButtonY = _yPos;
		};
	};
};

setMousePosition [_awareButtonX, _awareButtonY];