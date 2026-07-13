// A3C_ai_shared_fnc_reArm_takeWeapon

//-- since remoteExec is always CALL instead of SPAWN (even for bis_fnc_spawn), we need to spawn the fnc to allow sleep.
//-- ^^ #NOTE: that comment above is likely incorrect
_this spawn {
	params ["_unit", "_container", "_weapon"];

	if (isNull _unit) exitWith {};
	if (isNull _container) exitWith {};
	if (_weapon isEqualTo "") exitWith {};
	if (!alive _unit) exitWith {};
	if !(isClass (configFile >> "CfgWeapons" >> _weapon)) exitWith {};

	private _weaponSlotIndex = switch (true) do {
		case (_weapon isKindOf ["Rifle", configFile >> "CfgWeapons"]): {
			0 // primary weapon slot
		};

		case (_weapon isKindOf ["Launcher", configFile >> "CfgWeapons"]): {
			1 // launcher / secondary weapon slot
		};

		case (_weapon isKindOf ["Pistol", configFile >> "CfgWeapons"]): {
			2 // handgun slot
		};

		default {
			-1
		};
	};

	if (_weaponSlotIndex == -1) exitWith {};

	private _fnc_getWeaponCargoSources = {
		params ["_source"];

		if (_source isKindOf "Man" && { !alive _source }) exitWith {
			private _weaponHolders = [];

			{
				_weaponHolders pushBackUnique _x;
			} forEach (getCorpseWeaponHolders _source);

			{
				if ((getCorpse _x) isEqualTo _source) then {
					_weaponHolders pushBackUnique _x;
				};
			} forEach (nearestObjects [_source, ["WeaponHolderSimulated"], 5]);

			_weaponHolders
		};

		private _associatedCorpse = getCorpse _source;

		if (!isNull _associatedCorpse) exitWith {
			private _weaponHolders = [];

			{
				_weaponHolders pushBackUnique _x;
			} forEach (getCorpseWeaponHolders _associatedCorpse);

			_weaponHolders pushBackUnique _source;

			_weaponHolders
		};

		[_source]
	};

	private _fnc_findWeaponStateInSources = {
		params ["_sources", "_weapon"];

		private _sourceContainer = objNull;
		private _sourceWeaponCargo = [];
		private _sourceWeaponIndex = -1;
		private _sourceWeaponState = [];

		{
			private _weaponCargo = weaponsItemsCargo _x;
			private _weaponIndex = _weaponCargo findIf {
				(_x param [0, ""]) isEqualTo _weapon
			};

			if (_weaponIndex != -1) exitWith {
				_sourceContainer = _x;
				_sourceWeaponCargo = _weaponCargo;
				_sourceWeaponIndex = _weaponIndex;
				_sourceWeaponState = +(_weaponCargo select _weaponIndex);
			};
		} forEach _sources;

		[
			_sourceContainer,
			_sourceWeaponCargo,
			_sourceWeaponIndex,
			_sourceWeaponState
		]
	};

	private _fnc_addWeaponStateToCargo = {
		params ["_targetContainer", "_weaponState"];

		private _weaponClass = _weaponState param [0, ""];
		if (_weaponClass isEqualTo "") exitWith {};
		if (isNull _targetContainer) exitWith {};

		_targetContainer addWeaponWithAttachmentsCargoGlobal [_weaponState, 1];
	};

	private _fnc_addWeaponStateToCorpseSecondaryHolder = {
		params ["_corpse", "_weaponState"];

		private _weaponClass = _weaponState param [0, ""];
		if (_weaponClass isEqualTo "") exitWith {};
		if (isNull _corpse) exitWith {};

		private _corpseWeaponHolders = getCorpseWeaponHolders _corpse;
		if ((count _corpseWeaponHolders) < 2) exitWith {};

		private _secondaryWeaponHolder = _corpseWeaponHolders select 1;
		if (isNull _secondaryWeaponHolder) exitWith {};

		[_secondaryWeaponHolder, _weaponState] call _fnc_addWeaponStateToCargo;
	};

	_unit playMoveNow "amovpknlmstpsnonwnondnon_ainvpknlmstpsnonwnondnon_putdown";

	sleep 1;

	if (isNull _unit) exitWith {};
	if (isNull _container) exitWith {};
	if (!alive _unit) exitWith {};
	if !(isClass (configFile >> "CfgWeapons" >> _weapon)) exitWith {};

	private _sourceContainers = [_container] call _fnc_getWeaponCargoSources;
	if (_sourceContainers isEqualTo []) exitWith {};

	private _sourceData = [_sourceContainers, _weapon] call _fnc_findWeaponStateInSources;
	_sourceData params [
		"_sourceContainer",
		"_sourceWeaponCargo",
		"_sourceWeaponIndex",
		"_sourceWeaponState"
	];

	if (isNull _sourceContainer) exitWith {};
	if (_sourceWeaponIndex == -1) exitWith {};
	if ((_sourceWeaponState param [0, ""]) isEqualTo "") exitWith {};

	private _deadManSource = if (_container isKindOf "Man" && { !alive _container }) then {
		_container
	} else {
		getCorpse _sourceContainer
	};

	private _isCorpseSource = !isNull _deadManSource;

	private _unitLoadout = getUnitLoadout _unit;
	private _unitWeaponState = +(_unitLoadout select _weaponSlotIndex);

	// Remove the selected source weapon state from the source cargo.
	_sourceWeaponCargo deleteAt _sourceWeaponIndex;

	clearWeaponCargoGlobal _sourceContainer;

	{
		[_sourceContainer, _x] call _fnc_addWeaponStateToCargo;
	} forEach _sourceWeaponCargo;

	// Store the unit's previous weapon.
	// If the source is either a corpse or one of its weapon holders,
	// deposit into corpseWeaponHolders select 1.
	if !((_unitWeaponState param [0, ""]) isEqualTo "") then {
		if (_isCorpseSource) then {
			[_deadManSource, _unitWeaponState] call _fnc_addWeaponStateToCorpseSecondaryHolder;
		} else {
			[_sourceContainer, _unitWeaponState] call _fnc_addWeaponStateToCargo;
		};
	};

	// Equip the unit with the selected source weapon state.
	_unitLoadout set [_weaponSlotIndex, _sourceWeaponState];
	_unit setUnitLoadout [_unitLoadout, false];

	private _newWeapon = _sourceWeaponState param [0, ""];

	if !(_newWeapon isEqualTo "") then {
		[_unit, _newWeapon] spawn {
			params ["_unit", "_weapon"];

			sleep 0.1;

			if (alive _unit && { _weapon in weapons _unit }) then {
				_unit selectWeapon _weapon;
			};
		};
	};
};