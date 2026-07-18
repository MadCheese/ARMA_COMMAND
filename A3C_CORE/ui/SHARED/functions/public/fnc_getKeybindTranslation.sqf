// A3C_ui_shared_fnc_getKeybindTranslation

/*
	Returns the current CBA keybind as a readable plain-text string.

	Example:
		CTRL + SHIFT + F

	Returns "UNBOUND" when the keybind cannot be resolved.
*/
params [
	["_addonId", "", [""]],
	["_keyId", "", [""]]
];

if (
	_addonId == ""
	|| {_keyId == ""}
) exitWith {
	"UNBOUND"
};

private _keybindData = [
	_addonId,
	_keyId
] call CBA_fnc_getKeybind;

if !(_keybindData isEqualType []) exitWith {
	"UNBOUND"
};

/*
	CBA stores the currently active key combination at index 5:

	[
		DIK key,
		[
			shift,
			ctrl,
			alt
		]
	]
*/
private _keyData = _keybindData param [
	5,
	[],
	[[]]
];

if (count _keyData < 2) exitWith {
	"UNBOUND"
};

private _key = _keyData param [
	0,
	-1,
	[0]
];

private _modifiers = _keyData param [
	1,
	[
		false,
		false,
		false
	],
	[[]]
];

if (_key < 0) exitWith {
	"UNBOUND"
};

private _parts = [];

if (_modifiers param [0, false, [false]]) then {
	_parts pushBack "SHIFT";
};

if (_modifiers param [1, false, [false]]) then {
	_parts pushBack "CTRL";
};

if (_modifiers param [2, false, [false]]) then {
	_parts pushBack "ALT";
};

private _keyName = keyName _key;

if (_keyName == "") then {
	_keyName = format [
		"DIK %1",
		_key
	];
};

_parts pushBack _keyName;

_parts joinString " + "