// A3C_UI_mainDisplay_fnc_onMouseZChanged

/*
	Main Display mouse-wheel handler.

	Priority:
	1. Adjust active GTI grenade trajectory angle.
	2. Adjust active suppression or remote-fire indicator height.
	3. Adjust squad-placement radius or spacing while CTRL is held.
	4. Rotate an active positional-action object placer.
	5. Adjust squad-placement formation direction or 360° orientation.

	Returns true when the mouse-wheel event is consumed.
*/
params [
	[
		"_source",
		displayNull,
		[
			displayNull,
			controlNull
		]
	],
	["_scrollDelta", 0, [0]]
];

if (_scrollDelta == 0) exitWith {
	false
};

private _downKeys = missionNamespace getVariable [
	"A3C_UI_DOWNKEYS",
	[]
];

if !(_downKeys isEqualType []) then {
	_downKeys = [];
};

private _ctrlPressed = 29 in _downKeys;

/*
	GTI grenade trajectory adjustment.
*/
private _grenadeUnit = missionNamespace getVariable [
	"A3C_GTI_UNIT",
	objNull
];

if (
	_grenadeUnit isEqualType objNull
	&& {!isNull _grenadeUnit}
) exitWith {
	private _throwAngleAdjustment = missionNamespace getVariable [
		"BR_A3C_TACV_throwTheta_Add",
		0.01
	];

	if (_scrollDelta > 0) then {
		_throwAngleAdjustment =
			_throwAngleAdjustment + 1;
	} else {
		_throwAngleAdjustment =
			_throwAngleAdjustment - 1;
	};

	BR_A3C_TACV_throwTheta_Add = (
		_throwAngleAdjustment max 0.01
	) min 89.99;

	true
};

/*
	Suppression and remote-fire indicators all use the shared suppression
	height variable.

	Only one active indicator is needed to establish that this wheel event
	belongs to the targeting interaction.
*/
private _activeIndicator = objNull;



if (!isNull _activeIndicator) exitWith {
	showCommandingMenu "";

	private _suppressionHeight = missionNamespace getVariable [
		"A3C_SUPPRESSIONHEIGHT",
		0
	];

	if (_scrollDelta > 0) then {
		_suppressionHeight =
			_suppressionHeight + 0.2;
	} else {
		/*
			Preserve the legacy ground check while preventing the shared
			height value from becoming negative.
		*/
		if (
			(position _activeIndicator select 2) > 0
		) then {
			_suppressionHeight =
				(_suppressionHeight - 0.2) max 0;
		};
	};

	A3C_SUPPRESSIONHEIGHT = _suppressionHeight;

	true
};

private _unitGhosts = missionNamespace getVariable [
	"A3C_UI_squadPlacement_unitGhosts",
	[]
];

if !(_unitGhosts isEqualType []) then {
	_unitGhosts = [];
};

private _objectPlacer = missionNamespace getVariable [
	"A3C_OBJECTPLACER",
	objNull
];

if !(_objectPlacer isEqualType objNull) then {
	_objectPlacer = objNull;
};

/*
	Nothing below applies unless squad placement or object placement is
	currently active.
*/
if (
	_unitGhosts isEqualTo []
	&& {isNull _objectPlacer}
) exitWith {
	false
};

private _hudForm = missionNamespace getVariable [
	"A3C_HUD_FORM",
	0
];

/*
	CTRL + mouse wheel changes radius for the circular formation and spacing
	for every other formation.
*/
if (_ctrlPressed) exitWith {
	if (_hudForm == 7) then {
		private _radius = missionNamespace getVariable [
			"A3C_HUD_RADIUS",
			1
		];

		private _minimumRadius = missionNamespace getVariable [
			"A3C_HUD_RADIUS_MIN",
			1
		];

		if (_scrollDelta > 0) then {
			_radius = _radius + 1;
		} else {
			_radius = _radius - 1;
		};

		A3C_HUD_RADIUS =
			_radius max _minimumRadius;
	} else {
		private _spacing = missionNamespace getVariable [
			"A3C_HUD_SPACING",
			2
		];

		if (_scrollDelta > 0) then {
			_spacing = _spacing + 1;
		} else {
			_spacing = _spacing - 1;
		};

		A3C_HUD_SPACING =
			_spacing max 2;
	};

	true
};

A3C_FORMATION_DIR = [
	missionNamespace getVariable [
		"A3C_FORMATION_DIR",
		0
	]
] call MCSS_fnc_correctDir;

/*
	Arma reports larger wheel movement through multiples such as 1.2, 2.4,
	and 3.6. Preserve the legacy acceleration tiers.
*/
private _scrollSpeed =
	abs _scrollDelta;

private _factor = switch true do {
	case (_scrollSpeed == 2.4): {
		5
	};

	case (_scrollSpeed >= 3.6): {
		25
	};

	default {
		1
	};
};

/*
	An active object placer consumes the wheel for rotation rather than
	formation adjustment.
*/
if (!isNull _objectPlacer) exitWith {
	private _placerDirection = missionNamespace getVariable [
		"A3C_OBJECTPLACER_DIR",
		0
	];

	if (_scrollDelta < 0) then {
		_placerDirection =
			_placerDirection - _factor;
	} else {
		_placerDirection =
			_placerDirection + _factor;
	};

	A3C_OBJECTPLACER_DIR = _placerDirection;

	true
};

/*
	For circular formation mode, wheel direction controls inward/outward
	orientation. Other formation modes invert the directional adjustment
	when scrolling downward.
*/
if (_scrollDelta < 0) then {
	if (_hudForm == 7) then {
		A3C_360_out = true;
	} else {
		_factor = -_factor;
	};
} else {
	if (_hudForm == 7) then {
		A3C_360_out = false;
	};
};

A3C_HUD_Snap_DIR = [
	missionNamespace getVariable [
		"A3C_HUD_Snap_DIR",
		0
	]
] call MCSS_fnc_correctDir;

private _snapEnabled = missionNamespace getVariable [
	"A3C_HUD_Snap",
	false
];

if (!_snapEnabled) then {
	A3C_FORMATION_DIR =
		A3C_FORMATION_DIR + _factor;
};

A3C_SCROLLTIME = time;

A3C_FORMATION_DIR = [
	A3C_FORMATION_DIR
] call MCSS_fnc_correctDir;

true