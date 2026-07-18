// A3C_ui_shared_fnc_getKeyBool

/*
	Determines whether a key event should be blocked and dispatches
	squad-placement orders when applicable.

	Expected input:
		[
			DIK key,
			[
				shift,
				ctrl,
				alt
			]
		]

	Key-ID formats retained from the legacy implementation:

		A3C_FORM_KEY_ID:
			[key, shift, ctrl, alt]

		A3C_ORDER_REG_KEY_ID,
		A3C_ORDER_FW_KEY_ID,
		A3C_ORDER_BW_KEY_ID:
			[key, [shift, ctrl, alt]]
*/
params [
	["_key", -1, [0]],
	["_modifiers", [], [[]]]
];

if (_key < 0) exitWith {
	false
};

/*
	Normalize the modifier data so comparisons always use exactly:
		[shift, ctrl, alt]
*/
_modifiers = [
	_modifiers param [0, false, [false]],
	_modifiers param [1, false, [false]],
	_modifiers param [2, false, [false]]
];

private _flatKeyId = [
	_key
] + _modifiers;

private _nestedKeyId = [
	_key,
	_modifiers
];

private _blockDefault = false;

/*
	Numpad formation-selection keys.

	DIK:
		71 72 73
		75 76 77
		79 80 81
*/
if (
	_key in [
		71,
		72,
		73,
		75,
		76,
		77,
		79,
		80,
		81
	]
	&& {
		profileNamespace getVariable [
			"A3C_NUM_VAR",
			false
		]
	}
) then {
	_blockDefault = true;
};

/*
	Formation key IDs use the flattened format:
		[key, shift, ctrl, alt]
*/
private _formationKeyId = missionNamespace getVariable [
	"A3C_FORM_KEY_ID",
	[]
];

if (
	_formationKeyId isEqualType []
	&& {
		_flatKeyId isEqualTo _formationKeyId
	}
) then {
	_blockDefault = true;
};

/*
	Squad-placement order key IDs use the nested format:
		[key, [shift, ctrl, alt]]
*/
private _regularOrderKeyId = profileNamespace getVariable [
	"A3C_ORDER_REG_KEY_ID",
	[]
];

private _forwardOrderKeyId = profileNamespace getVariable [
	"A3C_ORDER_FW_KEY_ID",
	[]
];

private _backwardOrderKeyId = profileNamespace getVariable [
	"A3C_ORDER_BW_KEY_ID",
	[]
];

private _unitGhosts = missionNamespace getVariable [
	"A3C_UI_squadPlacement_unitGhosts",
	[]
];

if !(_unitGhosts isEqualType []) then {
	_unitGhosts = [];
};

private _hasUnitGhosts = _unitGhosts isNotEqualTo [];

/*
	Regular placement order.
*/
if (_nestedKeyId isEqualTo _regularOrderKeyId) then {
	if (_hasUnitGhosts) then {
		_blockDefault = true;

		[
			false,
			false
		] spawn A3C_UI_squadPlacement_fnc_executeOrder;
	} else {
		/*
			Block the regular-order key while an object-placement
			interaction is active.
		*/
		private _objectPlacer = missionNamespace getVariable [
			"A3C_OBJECTPLACER",
			objNull
		];

		if (
			_objectPlacer isEqualType objNull
			&& {!isNull _objectPlacer}
		) then {
			_blockDefault = true;
		};
	};
};

/*
	Forward placement order.
*/
if (
	_nestedKeyId isEqualTo _forwardOrderKeyId
	&& {_hasUnitGhosts}
) then {
	_blockDefault = true;

	[
		false,
		true
	] spawn A3C_UI_squadPlacement_fnc_executeOrder;
};

/*
	Backward placement order.

	The legacy function dispatched this order but did not set its return
	value to true. That allowed the engine keybind to continue processing
	after the order had already been issued.
*/
if (
	_nestedKeyId isEqualTo _backwardOrderKeyId
	&& {_hasUnitGhosts}
) then {
	_blockDefault = true;

	[
		true,
		false
	] spawn A3C_UI_squadPlacement_fnc_executeOrder;
};

/*
	Spacebar is consumed while a positional or grenade interaction requires
	confirmation.
*/
if (_key == 57) then {
	private _hudTagIconType = missionNamespace getVariable [
		"A3C_UI_HUD_3D_TAG_ICON_TYPE",
		""
	];

	private _assignVehicleObjects = missionNamespace getVariable [
		"A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS",
		[]
	];

	if !(_assignVehicleObjects isEqualType []) then {
		_assignVehicleObjects = [];
	};

	private _grenadeUnit = missionNamespace getVariable [
		"A3C_GTI_UNIT",
		objNull
	];

	private _hasGrenadeUnit =
		_grenadeUnit isEqualType objNull
		&& {
			!isNull _grenadeUnit
		};

	if (
		_hudTagIconType != ""
		|| {
			_assignVehicleObjects isNotEqualTo []
		}
		|| {
			_hasGrenadeUnit
		}
	) then {
		_blockDefault = true;
	};
};

_blockDefault