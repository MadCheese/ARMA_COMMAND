//-- Action to assemble or disassemble static weapons.
//-- Used by HC actions, waypoint actions, squad actions, and squad waypoint actions.

params ["_units", "_staticData", "_weaponPos", "_weaponDir"];

private _action = _staticData select 0;

private _fnc_playStaticWeaponWorkAnimation = {
	params ["_unit", "_finishedMove"];

	[_unit, _finishedMove] spawn {
		params ["_unit", "_finishedMove"];

		[_unit, "ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove", _unit];

		sleep 7;

		if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {
			[_unit, _finishedMove] remoteExec ["playMove", _unit];
		};
	};
};

if (_action == "ASSEMBLE") then {
	private _requestedStaticClass = _staticData select 1;

	{
		[[_x], A3C_AIGetOut] remoteExec ["bis_fnc_call", _x];
	} forEach _units;

	[_units, "EXECUTING"] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

	{
		_x params ["_assemblyUnits","_staticClassToCreate"];
		

		private _canAssemble = (
			_staticClassToCreate == _requestedStaticClass &&
			{{alive _x} count _assemblyUnits == 2}
		);

		if (_canAssemble) exitWith {
			//-- IFA statics use weapon parts instead of backpacks.
			private _ifaAssemblyWeaponParts = getArray (
				configFile >> "CfgVehicles" >> _requestedStaticClass >> "assembleInfo" >> "LIB_dissasembleTo"
			);

			if (count _ifaAssemblyWeaponParts > 0) then {
				private _tripodWeaponClass = getText (
					configFile >> "CfgVehicles" >> (_ifaAssemblyWeaponParts select 1) >> "LIB_Equipped_Tripod_Name"
				);

				_ifaAssemblyWeaponParts set [1, _tripodWeaponClass];
			};

			private _removedBackpacks = [];
			private _removeGunnerMagazines = false;
			private _usesIFAWeaponParts = count _ifaAssemblyWeaponParts > 0;

			{
				private _unit = _x;

				if (_usesIFAWeaponParts) then {
					private _weaponPartClass = _ifaAssemblyWeaponParts select _forEachIndex;

					if (primaryWeapon (_assemblyUnits select 0) == _weaponPartClass) then {
						_removeGunnerMagazines = true;
					};

					[_unit, _weaponPartClass] remoteExec ["removeWeapon", _unit];
				} else {
					_removedBackpacks pushBack (backpack _unit);
					[_unit] remoteExec ["removeBackpack", _unit];
				};

				[_unit, "amovpknlmstpslowwrfldnon"] call _fnc_playStaticWeaponWorkAnimation;
				[_unit, position _unit] remoteExec ["doMove", _unit];

			} forEach _assemblyUnits;

			sleep 2;

			while {true} do {
				//-- Abort: restore removed equipment if one of the builders dies before completion.
				if ({alive _x} count _assemblyUnits != 2) exitWith {
					if (_usesIFAWeaponParts) then {
						{
							if (_forEachIndex < count _ifaAssemblyWeaponParts) then {
								private _weaponPartClass = _ifaAssemblyWeaponParts select _forEachIndex;

								if (_weaponPartClass != "") then {
									[_x, _weaponPartClass] remoteExec ["addWeapon", _x];
								};
							};
						} forEach _assemblyUnits;
					} else {
						{
							if (_forEachIndex < count _removedBackpacks) then {
								private _backpackClass = _removedBackpacks select _forEachIndex;

								if (_backpackClass != "") then {
									[_x, _backpackClass] remoteExec ["addBackpack", _x];
								};
							};
						} forEach _assemblyUnits;
					};
				};

				//-- Assembly completed once both units have left the work animation.
				if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _assemblyUnits == 0) exitWith {
					if (_usesIFAWeaponParts && {_removeGunnerMagazines}) then {
						private _gunner = _assemblyUnits select 0;
						private _primaryMagazineTypes = getArray (
							configFile >> "CfgWeapons" >> (_ifaAssemblyWeaponParts select 0) >> "magazines"
						);

						{
							if (_x in _primaryMagazineTypes) then {
								[_gunner, _x] remoteExec ["removeMagazine", _gunner];
							};
						} forEach magazines _gunner;
					};

					_weaponPos set [2, 0];

					private _terrainVectors = [_weaponPos, _weaponDir] call MCSS_fnc_TerrainTilt;
					private _createdStatic = _staticClassToCreate createVehicle _weaponPos;

					[_createdStatic, ATLToASL _weaponPos] remoteExec ["setPosASL", _createdStatic];
					[_createdStatic, _terrainVectors] remoteExec ["setVectorDirAndUp", _createdStatic];

					sleep 0.1;

					//-- Final surface alignment; this may partially override setVectorDirAndUp.
					_createdStatic setVectorUp (surfaceNormal _weaponPos);

					private _centerMass = getCenterOfMass _createdStatic;

					_createdStatic enableSimulationGlobal false;

					sleep 1.5;

					_createdStatic enableSimulationGlobal true;

					private _gunner = _assemblyUnits select 0;
					private _assistant = _assemblyUnits select 1;

					[_gunner, _createdStatic] remoteExec ["assignAsGunner", _gunner];
					[_gunner, ["getInGunner", _createdStatic]] remoteExec ["action", _gunner];

					private _assistantAngleOffset = floor random 31;

					if (floor random 2 == 0) then {
						_assistantAngleOffset = _assistantAngleOffset * -1;
					};

					private _assistantPos = _weaponPos getPos [
						(random 4) max 1,
						(getDir _createdStatic) + 180 + _assistantAngleOffset
					];

					[_assistant, _assistantPos] call A3C_ai_shared_fnc_doMove;
					[_assistant, _weaponPos getPos [50, getDir _createdStatic]] remoteExec ["lookAt", _assistant];

					//-- Some static weapons slide/tilt after creation. This tries small center-of-mass offsets until stable.
					private _needsCorrection = false;

					{
						private _massArrayIndex = _x;

						{
							_x params ["_startOffset", "_endOffset"];

							for "_offset" from _startOffset to _endOffset step 0.1 do {
								private _centerMassTest = +_centerMass;

								_centerMassTest set [
									_massArrayIndex,
									(_centerMassTest select _massArrayIndex) + _offset
								];

								_createdStatic setCenterOfMass _centerMassTest;
								_createdStatic setVectorUp (surfaceNormal _weaponPos);

								[_createdStatic, ATLToASL _weaponPos] remoteExec ["setPosASL", _createdStatic];

								_needsCorrection = false;

								sleep 0.2;

								private _timer = time;

								while {time - _timer < 5} do {
									if ({abs _x > 0.3} count velocity _createdStatic > 0) exitWith {
										_needsCorrection = true;
									};

									sleep 0.1;
								};

								if !(_needsCorrection) exitWith {};
							};

							if !(_needsCorrection) exitWith {};
						} forEach [[0, 0.3], [-0.3, -0.1]];

						if !(_needsCorrection) exitWith {};
					} forEach [0, 1, 2];
				};

				sleep 0.2;
			};

			{
				(group _x) setVariable ["A3C_ASSEMBLING", nil, true];
			} forEach _assemblyUnits;
		};
	} forEach A3C_STATIC_PACKS;
} else {
	private _staticWeapon = _staticData select 1;

	private _disassemblyData = [
		_units,
		[],
		_staticData,
		_weaponPos,
		_weaponDir,
		30
	] call A3C_ai_shared_fnc_staticWeaponPrepareDisassembly;

	_disassemblyData params [
		"_disassemblyUnits",
		"_requiredUnitCount",
		"_needsMoreUnits",
		"_ifaDisassemblyItems",
		"_staticMagazineCount"
	];

	if (_needsMoreUnits) exitWith {
		systemChat format [
			"A3C: Current selection (%1) is not suitable to pick up this weapon",
			group (_units select 0)
		];
	};

	if (count _disassemblyUnits != _requiredUnitCount) exitWith {};

	private _staticWeaponType = typeOf _staticWeapon;

	//-- Standard statics disassemble into backpacks.
	private _disassemblyBackpacks = getArray (
		configFile >> "CfgVehicles" >> _staticWeaponType >> "assembleInfo" >> "dissasembleTo"
	);

	//-- IFA statics disassemble into weapons. The second config item maps to the equipped tripod weapon.
	private _ifaPodWeaponClass = if (count _ifaDisassemblyItems > 1) then {
		getText (
			configFile >> "CfgVehicles" >> (_ifaDisassemblyItems select 1) >> "LIB_Equipped_Tripod_Name"
		)
	} else {
		""
	};

	{
		[_x, "amovpercmstpslowwrfldnon"] call _fnc_playStaticWeaponWorkAnimation;
	} forEach _disassemblyUnits;

	sleep 2;

	while {true} do {
		if ({alive _x} count _disassemblyUnits != _requiredUnitCount) exitWith {};

		if ({animationState _x == "ainvpknlmstpslaywrfldnon_medic"} count _disassemblyUnits == 0) exitWith {
			deleteVehicle _staticWeapon;

			//-- If only one unit is ever allowed for a special case, duplicate it so indexed assignment does not fail.
			if (count _disassemblyUnits == 1) then {
				_disassemblyUnits = _disassemblyUnits + _disassemblyUnits;
			};

			if (count _disassemblyBackpacks > 0) then {
				{
					if (_forEachIndex < count _disassemblyBackpacks) then {
						private _backpackClass = _disassemblyBackpacks select _forEachIndex;

						if (_backpackClass != "") then {
							[_x, _backpackClass] remoteExec ["addBackpack", _x];
						};
					};
				} forEach _disassemblyUnits;
			};

			if (count _ifaDisassemblyItems > 0) then {
				private _pickupPos = (
					(_disassemblyUnits select 0) modelToWorld (
						(_disassemblyUnits select 0) selectionPosition "weapon"
					)
				);

				private _weaponHolder = "GroundWeaponHolder" createVehicle _pickupPos;
				private _turretAssigned = false;
				private _ifaTurretWeaponClass = _ifaDisassemblyItems select 0;
				private _ifaTurretIsRifle = _ifaTurretWeaponClass isKindOf ["Rifle", configFile >> "CfgWeapons"];

				//-- Assign turret first. If needed, preserve the unit's replaced primary weapon in a ground holder.
				{
					private _unit = _x;

					if (!_turretAssigned) then {
						if (_ifaTurretIsRifle) then {
							if (primaryWeapon _unit != "") then {
								private _oldPrimaryWeapon = [primaryWeapon _unit] call A3C_main_fnc_getBaseWeapon;
								private _oldPrimaryMagazines = [currentMagazine _unit];
								private _oldPrimaryItems = primaryWeaponItems _unit;
								private _oldPrimaryMagazineTypes = getArray (
									configFile >> "CfgWeapons" >> _oldPrimaryWeapon >> "magazines"
								);

								{
									if (_x in _oldPrimaryMagazineTypes) then {
										_oldPrimaryMagazines pushBack _x;
										[_unit, _x] remoteExec ["removeMagazine", _unit];
									};
								} forEach magazines _unit;

								_weaponHolder addWeaponCargoGlobal [_oldPrimaryWeapon, 1];

								{
									_weaponHolder addMagazineCargoGlobal [_x, 1];
								} forEach _oldPrimaryMagazines;

								{
									_weaponHolder addItemCargoGlobal [_x, 1];
								} forEach _oldPrimaryItems;

								[_unit, _oldPrimaryWeapon] remoteExec ["removeWeapon", _unit];
							};

							_turretAssigned = true;
						} else {
							if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) then {
								_turretAssigned = true;
							};
						};

						if (_turretAssigned) then {
							[_unit, _ifaTurretWeaponClass] remoteExec ["addWeapon", _unit];
							[_unit, _ifaTurretWeaponClass] remoteExec ["selectWeapon", _unit];

							if (_ifaTurretIsRifle) then {
								private _newMagazineTypes = getArray (
									configFile >> "CfgWeapons" >> _ifaTurretWeaponClass >> "magazines"
								);

								if (count _newMagazineTypes > 0 && {_staticMagazineCount > 0}) then {
									private _newMagazineType = _newMagazineTypes select 0;

									for "_i" from 1 to _staticMagazineCount do {
										[_unit, _newMagazineType] remoteExec ["addMagazine", _unit];
									};
								};
							};
						};
					};
				} forEach _disassemblyUnits;

				//-- Assign pod/tripod second. If needed, preserve replaced secondary weapon in the ground holder.
				{
					private _unit = _x;

					if !(_forEachIndex == 0 && {count _disassemblyUnits > 1}) then {
						if ([_unit] call A3C_main_fnc_canUnitCarryIFAstatic) exitWith {
							if (secondaryWeapon _unit != "") then {
								private _oldSecondaryWeapon = [secondaryWeapon _unit] call A3C_main_fnc_getBaseWeapon;
								private _oldSecondaryMagazines = secondaryWeaponMagazine _unit;
								private _oldSecondaryItems = secondaryWeaponItems _unit;
								private _oldSecondaryMagazineTypes = getArray (
									configFile >> "CfgWeapons" >> _oldSecondaryWeapon >> "magazines"
								);

								{
									if (_x in _oldSecondaryMagazineTypes) then {
										_oldSecondaryMagazines pushBack _x;
										[_unit, _x] remoteExec ["removeMagazine", _unit];
									};
								} forEach magazines _unit;

								_weaponHolder addWeaponCargoGlobal [_oldSecondaryWeapon, 1];

								{
									_weaponHolder addMagazineCargoGlobal [_x, 1];
								} forEach _oldSecondaryMagazines;

								{
									_weaponHolder addItemCargoGlobal [_x, 1];
								} forEach _oldSecondaryItems;

								[_unit, _oldSecondaryWeapon] remoteExec ["removeWeapon", _unit];
							};

							if (_ifaPodWeaponClass != "") then {
								[_unit, _ifaPodWeaponClass] remoteExec ["addWeapon", _unit];
							};
						};
					};
				} forEach _disassemblyUnits;

				if (count weaponCargo _weaponHolder == 0) then {
					deleteVehicle _weaponHolder;
				};
			};
		};

		sleep 0.2;
	};
};