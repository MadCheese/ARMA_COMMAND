// A3C_UI_mainDisplay_fnc_onKeyDown_NUM

/*
	Handles NUM-key squad-placement controls.

	Key groups:

		103–106:
			Replace the current placement selection with a color team.

		71–81:
			Select the squad for placement when necessary, then adjust
			formation direction and formation shape.

	The ordered A3C_GROUPUNITS profile snapshot remains the authoritative
	source because its order is used when assigning placement indices.

	Returns true when the key belongs to either supported key group.
*/
params [
	["_key", -1, [0]]
];

private _teamSelectionKeys = [
	103,
	104,
	105,
	106
];

private _formationKeys = [
	71,
	72,
	73,
	75,
	76,
	77,
	79,
	80,
	81
];

if (
	!(_key in _teamSelectionKeys)
	&& {!(_key in _formationKeys)}
) exitWith {
	false
};

private _groupUnits = profileNamespace getVariable [
	"A3C_GROUPUNITS",
	units group player
];

if !(_groupUnits isEqualType []) then {
	_groupUnits = units group player;
};

/*
	Keep the stored ordering, but remove the player, null references, and
	non-object values.
*/
_groupUnits = _groupUnits select {
	_x isEqualType objNull
	&& {!isNull _x}
	&& {_x != player}
};

private _placementUnits = missionNamespace getVariable [
	"A3C_UI_squadPlacement_units",
	[]
];

if !(_placementUnits isEqualType []) then {
	_placementUnits = [];
};

/*
	Color-team selection.

	The existing placement selection is cleared first. Alive members of the
	requested team are then added using the legacy key value as the second
	addUnitGhost argument.
*/
if (_key in _teamSelectionKeys) exitWith {
	if (_placementUnits isEqualTo []) then {
		A3C_HUD_FORM = 0;
	};

	A3C_HUD_FORM_ICON =
		"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";

	A3C_HUD_FORM_ICON_COLOR = [
		0,
		0,
		0,
		0.2
	];

	A3C_HUD_FORM_ICON_SIZE = 0.8;

	private _teamColor = switch (_key) do {
		case 103: {
			"RED"
		};

		case 104: {
			"GREEN"
		};

		case 105: {
			"BLUE"
		};

		case 106: {
			"YELLOW"
		};

		default {
			""
		};
	};

	private _colorTeamUnits = _groupUnits select {
		private _unit = _x;

		if (!alive _unit) exitWith {
			false
		};

		private _assignedTeam = if (
			player == cameraOn
		) then {
			assignedTeam _unit
		} else {
			_unit getVariable [
				"A3C_ASSIGNEDTEAM",
				"MAIN"
			]
		};

		_assignedTeam == _teamColor
	};

	{
		private _unit = _x;

		if (_unit in _placementUnits) then {
			[
				_unit
			] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
		};

		if (_unit in _colorTeamUnits) then {
			[
				_unit,
				_key
			] call A3C_UI_squadPlacement_fnc_addUnitGhost;
		};
	} forEach _groupUnits;

	true
};

/*
	Formation-direction controls.
*/
private _formationDirection = missionNamespace getVariable [
	"A3C_FORMATION_DIR",
	0
];

A3C_FORMATION_DIR = [
	_formationDirection
] call MCSS_fnc_correctDir;

/*
	When no placement selection exists, initialize it with every alive AI
	member of the stored player-group snapshot.
*/
if (_placementUnits isEqualTo []) then {
	A3C_NUM_DIR = 0;

	{
		private _unit = _x;

		if (
			alive _unit
			&& {!isPlayer _unit}
		) then {
			[
				_unit,
				_forEachIndex
			] call A3C_UI_squadPlacement_fnc_addUnitGhost;
		};
	} forEach _groupUnits;

	if (
		missionNamespace getVariable [
			"A3C_HUD_FORM",
			0
		] == 0
	) then {
		A3C_HUD_FORM = 1;

		A3C_HUD_FORM_ICON =
			"A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";

		A3C_HUD_FORM_ICON_COLOR = [
			0,
			0,
			0,
			0.2
		];

		A3C_HUD_FORM_ICON_SIZE = 0.8;
	};
};

A3C_HUD_FORM_ICON_COLOR = [
	0,
	0,
	0,
	0.2
];

A3C_HUD_FORM_ICON_SIZE = 0.8;

/*
	Toggles between the two line orientations used by keys 72, 75, 77,
	and 80.
*/
private _fnc_toggleLineOrientation = {
	if (
		missionNamespace getVariable [
			"A3C_HUD_FORM",
			0
		] == 0
	) then {
		A3C_HUD_FORM = 1;

		A3C_HUD_FORM_ICON =
			"A3C_CORE\ui\pictures\icon_formSec_Line_Left.paa";
	} else {
		A3C_HUD_FORM = 0;

		A3C_HUD_FORM_ICON =
			"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
	};
};

switch (_key) do {
	case 71: {
		A3C_NUM_DIR = 180;
		A3C_HUD_FORM = 4;

		A3C_HUD_FORM_ICON =
			"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
	};

	case 72: {
		call _fnc_toggleLineOrientation;

		A3C_NUM_DIR = 0;
	};

	case 73: {
		A3C_NUM_DIR = 180;
		A3C_HUD_FORM = 3;

		A3C_HUD_FORM_ICON =
			"\a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_left_ca.paa";
	};

	case 75: {
		call _fnc_toggleLineOrientation;

		A3C_NUM_DIR = 90;
	};

	case 76: {
		/*
			The center NUM key intentionally performs no additional
			direction or formation change. It still initializes the
			placement selection when that selection was empty.
		*/
	};

	case 77: {
		call _fnc_toggleLineOrientation;

		A3C_NUM_DIR = -90;
	};

	case 79: {
		A3C_NUM_DIR = 0;
		A3C_HUD_FORM = 3;

		A3C_HUD_FORM_ICON =
			"\a3\ui_f\data\GUI\RscCommon\RscHTML\arrow_left_ca.paa";
	};

	case 80: {
		call _fnc_toggleLineOrientation;

		A3C_NUM_DIR = 180;
	};

	case 81: {
		A3C_NUM_DIR = 0;
		A3C_HUD_FORM = 4;

		A3C_HUD_FORM_ICON =
			"A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
	};
};

true