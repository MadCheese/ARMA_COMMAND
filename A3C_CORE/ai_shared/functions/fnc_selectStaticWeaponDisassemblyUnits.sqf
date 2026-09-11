// A3C_ai_shared_fnc_selectStaticWeaponDisassemblyUnits

/*
	Params:
		0: ARRAY  - _units
		1: OBJECT - _weapon
		2: NUMBER - _maxDistance, optional, default 30
		3: STRING - _disassemblyProvider, optional, default "LEGACY"
		4: ARRAY  - _disassemblyProviderData, optional, default []

	Returns:
		ARRAY - selected physical worker units or []

	Purpose:
		Selects suitable units from _units to disassemble _weapon.

	Notes:
		- Vanilla/SOG statics use backpack-based disassembly.
		- IFA statics use weapon-part-based disassembly.
		- ACE CSW statics use ACE_CSW configuration data.
		- Legacy vanilla/SOG/IFA paths require two workers.
		- ACE PRIMARY-slot CSWs may use one or two physical workers depending
		on the selected weapon carrier's available secondary slot.
		- ACE SECONDARY-slot CSWs require two physical workers.
*/

params [
	["_units", [], [[]]],
	["_weapon", objNull, [objNull]],
	["_maxDistance", 30, [0]],
	["_disassemblyProvider", "LEGACY", [""]],
	["_disassemblyProviderData", [], [[]]]
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


//-- ACE CSW disassembly
if (_disassemblyProvider == "ACE_CSW") exitWith {
	if (count _disassemblyProviderData < 3) exitWith {
		[]
	};

	_disassemblyProviderData params [
		"_aceWeaponClass",
		"_aceMountClass",
		"_aceWeaponSlot"
	];

	if (
		_aceWeaponClass == ""
		|| {_aceMountClass == ""}
	) exitWith {
		[]
	};

	/*
		Select actual component roles rather than selecting a worker count first.

		Weapon carrier priority:
		1. no primary weapon
		2. free secondary slot
		3. current static crew

		For PRIMARY-slot ACE weapons, one worker is used when the preferred
		weapon carrier also has a free secondary slot. Otherwise a separate
		mount carrier is selected.

		For SECONDARY-slot ACE weapons, weapon and mount always require
		two different workers.
	*/
	private _bestUnits = [];
	private _bestScore = -1;

	{
		private _weaponUnit = _x;
		private _currentPrimaryWeapon = primaryWeapon _weaponUnit;
		private _weaponCanCarry = true;

		/*
			A PRIMARY-slot ACE weapon may replace a normal rifle, which the
			executor preserves. Do not replace another ACE CSW component.
		*/
		if (
			_aceWeaponSlot == "PRIMARY"
			&& {_currentPrimaryWeapon != ""}
		) then {
			private _currentPrimaryACEcfg = (
				configFile
					>> "CfgWeapons"
					>> _currentPrimaryWeapon
					>> "ACE_CSW"
			);

			if (
				isClass _currentPrimaryACEcfg
				&& {
					toLower (getText (_currentPrimaryACEcfg >> "type"))
					in ["weapon", "mount"]
				}
			) then {
				_weaponCanCarry = false;
			};
		};

		//-- SECONDARY-slot ACE weapons require the secondary slot themselves.
		if (
			_aceWeaponSlot == "SECONDARY"
			&& {secondaryWeapon _weaponUnit != ""}
		) then {
			_weaponCanCarry = false;
		};

		if (_weaponCanCarry) then {
			private _weaponScore = 0;

			//-- Strongly prefer designated/static-style units with no primary.
			if (_currentPrimaryWeapon == "") then {
				_weaponScore = _weaponScore + 100;
			};

			//-- Prefer a worker who could also carry the tripod.
			if (secondaryWeapon _weaponUnit == "") then {
				_weaponScore = _weaponScore + 10;
			};

			//-- Crew is a useful tie-breaker, but equipment suitability wins.
			if (_weaponUnit == gunner _weapon) then {
				_weaponScore = _weaponScore + 2;
			} else {
				if (_weaponUnit in _crew) then {
					_weaponScore = _weaponScore + 1;
				};
			};

			/*
				PRIMARY weapon + free SECONDARY:
				this worker can carry both components.
			*/
			if (
				_aceWeaponSlot == "PRIMARY"
				&& {secondaryWeapon _weaponUnit == ""}
			) then {
				private _score = (_weaponScore * 1000) + 999;

				if (_score > _bestScore) then {
					_bestScore = _score;
					_bestUnits = [_weaponUnit];
				};
			} else {
				/*
					Otherwise find a separate tripod carrier.
					The tripod always occupies SECONDARY.
				*/
				{
					private _mountUnit = _x;

					if (
						_mountUnit != _weaponUnit
						&& {secondaryWeapon _mountUnit == ""}
					) then {
						private _mountScore = 0;

						if (_mountUnit in _crew) then {
							_mountScore = _mountScore + 1;
						};

						private _score = (
							_weaponScore * 1000
						) + _mountScore;

						if (_score > _bestScore) then {
							_bestScore = _score;
							_bestUnits = [
								_weaponUnit,
								_mountUnit
							];
						};
					};

				} forEach _units;
			};
		};

	} forEach _units;

	_bestUnits
};

private _IFA_items = getArray (
	configFile >> "CfgVehicles" >> typeOf _weapon >> "assembleInfo" >> "LIB_dissasembleTo"
);

private _isIFAStatic = count _IFA_items > 0;

if (_isIFAStatic) exitWith {
	private _ifaTurretWeaponClass = _IFA_items param [0, ""];

	private _ifaTurretIsRifle = _ifaTurretWeaponClass isKindOf [
		"Rifle",
		configFile >> "CfgWeapons"
	];

	/*
		IFA always uses two physical workers.

		Returned order is important:
			0 = turret carrier
			1 = pod/tripod carrier

		For rifle-based turrets, prefer a worker with no primary weapon.
		For all roles, prefer a free secondary slot where applicable.
	*/
	private _bestUnits = [];
	private _bestScore = -1;

	{
		private _turretUnit = _x;

		private _turretCanCarry = if (_ifaTurretIsRifle) then {
			true
		} else {
			secondaryWeapon _turretUnit == ""
		};

		if (_turretCanCarry) then {
			private _turretScore = 0;

			if (
				_ifaTurretIsRifle
				&& {primaryWeapon _turretUnit == ""}
			) then {
				_turretScore = _turretScore + 100;
			};

			if (secondaryWeapon _turretUnit == "") then {
				_turretScore = _turretScore + 10;
			};

			if (_turretUnit == gunner _weapon) then {
				_turretScore = _turretScore + 2;
			} else {
				if (_turretUnit in _crew) then {
					_turretScore = _turretScore + 1;
				};
			};
			{
				private _podUnit = _x;

				if (
					_podUnit != _turretUnit
					&& {
						[_podUnit] call A3C_main_fnc_canUnitCarryIFAstatic
					}
				) then {
					private _podScore = 0;

					//-- Prefer not having to replace an existing secondary weapon.
					if (secondaryWeapon _podUnit == "") then {
						_podScore = _podScore + 10;
					};

					if (_podUnit in _crew) then {
						_podScore = _podScore + 1;
					};

					private _score = (
						_turretScore * 1000
					) + _podScore;

					if (_score > _bestScore) then {
						_bestScore = _score;
						_bestUnits = [
							_turretUnit,
							_podUnit
						];
					};
				};

			} forEach _units;
		};

	} forEach _units;

	_bestUnits
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
		Prefer the current gunner when candidates are otherwise similarly
		suitable, but equipment suitability remains more important.
	*/
	if (_unit == gunner _weapon) then {
		_score = _score + 2;
	} else {
		if (_unit in _crew) then {
			_score = _score + 1;
		};
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