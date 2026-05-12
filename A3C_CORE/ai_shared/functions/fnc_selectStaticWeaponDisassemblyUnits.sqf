/*
	Function:
		A3C_ai_shared_fnc_selectStaticWeaponDisassemblyUnits

	Params:
		0: ARRAY  - _units
		1: OBJECT - _weapon
		2: NUMBER - _maxDistance, optional, default 30

	Returns:
		ARRAY - [_unitA, _unitB] or []

	Purpose:
		Selects the two most suitable units from _units to disassemble _weapon.

	Notes:
		- Non-IFA statics use backpack-based disassembly.
		- IFA statics use secondaryWeapon-based disassembly.
*/

params [
	["_units", [], [[]]],
	["_weapon", objNull, [objNull]],
	["_maxDistance", 30, [0]]
];

if (isNull _weapon) exitWith {[]};

/*
	General candidate filtering.
	Distance belongs here because it is part of whether a unit is suitable.
*/
_units = _units select {
	alive _x &&
	{!isPlayer _x} &&
	{!isNull _x} &&
	{_x distance _weapon <= _maxDistance} &&
	{isNull objectParent _x || {vehicle _x == _weapon}}
};

if (count _units < 2) exitWith {[]};

private _crew = crew _weapon;

/*
	If the weapon is manned, every current crew member must be inside _units.
	If not, this subselection is not allowed to disassemble it.
*/
if (
	count _crew > 0 &&
	{{!(_x in _units)} count _crew > 0}
) exitWith {
	[]
};

private _IFA_items = getArray (
	configFile >> "CfgVehicles" >> typeOf _weapon >> "assembleInfo" >> "LIB_dissasembleTo"
);

private _isIFAStatic = count _IFA_items > 0;

if (_isIFAStatic) exitWith {
	/*
		IFA method:
		- prefer current static gunner / crew
		- otherwise prefer units with no secondaryWeapon
		- require secondary slot to be free
		- return the best two units

		This intentionally does not mutate inventory.
	*/
	private _scored = [];

	{
		private _unit = _x;
		private _score = 0;
		private _disqualified = false;

		if (_unit in _crew) then {
			_score = _score + 1000;
		};

		/*
			Per current design:
			IFA disassembly needs secondaryWeapon capacity.
		*/
		if (secondaryWeapon _unit == "") then {
			_score = _score + 500;
		} else {
			_disqualified = true;
		};

		if (!_disqualified) then {
			_scored pushBack [_score, _unit];
		};

	} forEach _units;

	if (count _scored < 2) exitWith {[]};

	_scored sort false;

	[
		(_scored select 0) select 1,
		(_scored select 1) select 1
	]
};

/*
	Non-IFA / backpack method.
*/

private _fnc_isStaticWeaponBackpack = {
	params ["_backpackClass"];

	if (_backpackClass == "") exitWith {false};

	private _assembleTo = getText (
		configFile >> "CfgVehicles" >> _backpackClass >> "assembleInfo" >> "assembleTo"
	);

	private _base = getText (
		configFile >> "CfgVehicles" >> _backpackClass >> "assembleInfo" >> "base"
	);

	(_assembleTo != "") || {_base != ""}
};

private _fnc_getBackpackPenalty = {
	params ["_unit"];

	private _penalty = 0;

	private _items = backpackItems _unit;
	private _magazines = backpackMagazines _unit;

	if ("ToolKit" in _items) then {
		_penalty = _penalty + 35;
	};

	if ("Medikit" in _items) then {
		_penalty = _penalty + 35;
	};

	if ("FirstAidKit" in _items) then {
		_penalty = _penalty + 5;
	};

	/*
		Missile / rocket cargo penalty.
		Use backpackMagazines only; there is no backpackWeapons command.
	*/
	{
		private _ammo = getText (
			configFile >> "CfgMagazines" >> _x >> "ammo"
		);

		private _parents = [
			configFile >> "CfgAmmo" >> _ammo,
			true
		] call BIS_fnc_returnParents;

		if (
			{_x in _parents} count [
				"MissileBase",
				"MissileCore",
				"RocketBase",
				"RocketCore"
			] > 0
		) then {
			_penalty = _penalty + 20;
		};
	} forEach _magazines;

	_penalty
};

/*
	Find which static-weapon backpack classes are present in candidates.
	This lets us protect existing carried static parts.
*/
private _staticBackpackClasses = [];

{
	private _bp = backpack _x;

	if ([_bp] call _fnc_isStaticWeaponBackpack) then {
		_staticBackpackClasses pushBackUnique _bp;
	};
} forEach _units;

/*
	Heuristic:
	- If two or more static backpacks exist, assume they may be a usable static pair.
	  Disqualify carriers to avoid destroying that carried weapon.
	- If only one exists, treat it as orphaned and allow it with a heavy penalty.
*/
private _hasLikelyStaticPair = count _staticBackpackClasses >= 2;

private _scored = [];

{
	private _unit = _x;
	private _score = 0;
	private _disqualified = false;

	private _bp = backpack _unit;
	private _hasBackpack = _bp != "";
	private _isStaticBackpack = [_bp] call _fnc_isStaticWeaponBackpack;

	/*
		Highest preference:
		current weapon crew, because they likely assembled/manned the static.
	*/
	if (_unit in _crew) then {
		_score = _score + 1000;
	};

	if (!_hasBackpack) then {
		_score = _score + 500;
	} else {
		_score = _score + 100;
	};

	if (_isStaticBackpack) then {
		if (_hasLikelyStaticPair) then {
			_disqualified = true;
		} else {
			_score = _score - 300;
		};
	};

	_score = _score - ([_unit] call _fnc_getBackpackPenalty);

	if (!_disqualified) then {
		_scored pushBack [_score, _unit];
	};

} forEach _units;

if (count _scored < 2) exitWith {[]};

_scored sort false;

[
	(_scored select 0) select 1,
	(_scored select 1) select 1
]