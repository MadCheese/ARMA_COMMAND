// A3C_main_fnc_getGoCodeActivationVariableName

params [
	["_code", "", [""]],
	["_side", sideUnknown, [west]]
];

_code = toUpper _code;

if !(_code in ["A", "B", "C", "D"]) exitWith {""};

/*
	Canonical playable-side strings returned by `str`:

	west / blufor              -> "WEST"
	east / opfor               -> "EAST"
	independent / resistance   -> "GUER"
	civilian                   -> "CIV"
*/
private _sideKey = str _side;

if !(_sideKey in ["WEST", "EAST", "GUER", "CIV"]) exitWith {""};

format [
	"A3C_GoCode_Activate_%1_%2",
	_code,
	_sideKey
]