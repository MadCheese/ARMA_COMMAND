// A3C_server_fnc_distributeMissileTargets

//-- Distribute Missile Targets (used by Server Monitor FSM)

params ["_group", "_sides", "_assignedTargets"];

if (side _group in _sides) then {
	private _groupUnits = units _group;
	private _ehUnitsChanged = false;

	//-- sort units by AIAmmoUsageFlags (damage of ammo)
	_groupUnits = [
		_groupUnits,
		[],
		{
			private _value = 0;
			private _secondaryWeaponMagazine = secondaryWeaponMagazine _x;

			if (count _secondaryWeaponMagazine > 0) then {
				private _magazine = _secondaryWeaponMagazine select 0;
				private _cfgMagazine = configFile >> "CfgMagazines" >> _magazine;
				private _ammoType = getText (_cfgMagazine >> "ammo");
				private _cfgAmmo = configFile >> "CfgAmmo" >> _ammoType;
				private _aiAmmoUsageFlags = getText (_cfgAmmo >> "aiAmmoUsageFlags");

				if (_aiAmmoUsageFlags == "") then {
					_aiAmmoUsageFlags = str (getNumber (_cfgAmmo >> "aiAmmoUsageFlags"));

					switch (true) do {
						case (["512", _aiAmmoUsageFlags] call BIS_fnc_inString): {
							_value = 3;
						};
						case (["128", _aiAmmoUsageFlags] call BIS_fnc_inString): {
							_value = 2;
						};
						case (["256", _aiAmmoUsageFlags] call BIS_fnc_inString): {
							_value = 1;
						};
					};
				};
			};

			_value
		},
		"DESCEND"
	] call BIS_fnc_sortBy;

	{
		private _unit = _x;

		if (isNull objectParent _unit) then { //-- unit has to be on foot
			if (!isPlayer _unit) then { //-- unit may not be controlled by player
				if !(_unit getVariable ["A3C_ROE", false]) then { //-- unit must have AUTOTARGET on by ROE
					private _secondaryWeaponMagazine = secondaryWeaponMagazine _unit;

					if (count _secondaryWeaponMagazine > 0) then { //-- unit has a loaded secondaryWeapon
						private _secondaryWeapon = secondaryWeapon _unit;

						if (currentWeapon _unit == _secondaryWeapon) then {
							private _allowFire = false;

							if !(_unit in A3C_Mon_Server_EH_units) then {
								if (isNull assignedTarget _unit) then {
									_unit doTarget objNull;
									_unit lookAt objNull;
									_unit disableAI "AUTOTARGET";

									private _currentMagazine = currentMagazine _unit;
									private _cfgMagazine = configFile >> "CfgMagazines" >> _currentMagazine;
									private _ammo = getText (_cfgMagazine >> "ammo");
									private _cfgAmmo = configFile >> "CfgAmmo" >> _ammo;
									private _aiAmmoUsageFlags = getText (_cfgAmmo >> "aiAmmoUsageFlags");

									if (_aiAmmoUsageFlags == "") then {
										_aiAmmoUsageFlags = str (getNumber (_cfgAmmo >> "aiAmmoUsageFlags"));
									};

									private _targetTypes = if (["256", _aiAmmoUsageFlags] call BIS_fnc_inString) then {
										["AIR"]
									} else {
										["CAR", "TANK"]
									}; //-- select target types according to ammo

									private _cfgSecondaryWeapon = configFile >> "CfgWeapons" >> _secondaryWeapon;
									private _checkDistance = getNumber (_cfgSecondaryWeapon >> "maxRange"); //-- we only need to check within a distance that the unit can target within
									private _nearTargets = ([
										side _unit,
										_checkDistance,
										"ENEMY",
										position _unit,
										_targetTypes
									] call MCSS_fnc_NearEntities) - _assignedTargets;

									if (count _nearTargets > 0) then {
										private _target = objNull;
										private _targetArmor = -1;

										//-- select movable target with highest armor value
										{
											if (canMove _x) then {
												private _cfgVehicle = configFile >> "CfgVehicles" >> typeOf _x;
												private _armor = getNumber (_cfgVehicle >> "armor");

												if (_armor > _targetArmor) then {
													_target = _x;
													_targetArmor = _armor;
												};
											};
										} forEach _nearTargets;

										if (!isNull _target) then {
											_assignedTargets pushBackUnique _target;
											A3C_Mon_Server_EH_units pushBackUnique _unit;
											_ehUnitsChanged = true;

											private _handle = _unit addEventHandler [
												"FIRED",
												{
													_this spawn A3C_server_fnc_handlerFncMissileDistribution;
												}
											];

											_unit setVariable ["A3C_Mon_Server_Var", [_handle, _target, _ammo], true];

											[_unit, _target] spawn {
												params ["_unit", "_target"];

												sleep random 1;

												[_unit, _target] remoteExec ["doTarget", _unit];
												[_unit, _target] remoteExec ["doFire", _unit];
												[_unit, [_target, 4]] remoteExec ["reveal", _unit];

												private _abort = false;

												for "_i" from 0 to 7 step 0.1 do {
													if !(_unit in A3C_Mon_Server_EH_units) exitWith {};
													if (isNull _unit) exitWith {};
													if (!alive _unit) exitWith {
														_abort = true;
													};
													if (!alive _target) exitWith {
														_abort = true;
													};

													sleep 0.1;
												};

												if (_abort) then {
													(_unit getVariable ["A3C_Mon_Server_Var", [-1, objNull, ""]]) params ["_handle", "_target", "_ammo"];

													[_unit, objNull] remoteExec ["doTarget", _unit];
													[_unit, objNull] remoteExec ["doFire", _unit];
													[_unit, objNull] remoteExec ["lookAt", _unit];
													[_unit, objNull] remoteExec ["doWatch", _unit];

													{
														[_unit, assignedTarget _unit] remoteExec ["forgetTarget", _unit];
													} forEach (units _unit);

													[_unit, primaryWeapon _unit] remoteExec ["selectWeapon", _unit];

													_unit removeEventHandler ["FIRED", _handle];

													A3C_Mon_Server_EH_units = A3C_Mon_Server_EH_units - [_unit];
													publicVariable "A3C_Mon_Server_EH_units";

													_unit setVariable ["A3C_Mon_Server_Var", [-1, objNull, ""], true];
													_unit enableAI "AUTOTARGET";
												};
											};

											//-- new target allocated, unit is allowed to fire
											_allowFire = true;
										};
									};
								};
							} else {
								//-- if they are in current EH units already, they should be able to fire
								_allowFire = true;
							};

							//-- any unit with a launcher that is not being handled will cancel its target
							if !(_allowFire) then {
								if (isNull assignedTarget _unit) then {
									[_unit, objNull] remoteExec ["doTarget", _unit];
									[_unit, objNull] remoteExec ["doFire", _unit];
									[_unit, objNull] remoteExec ["lookAt", _unit];

									{
										[_unit, assignedTarget _unit] remoteExec ["forgetTarget", _unit];
									} forEach units _unit;
								};
							};
						};
					};
				};
			};
		};
	} forEach _groupUnits;

	if (_ehUnitsChanged) then {
		publicVariable "A3C_Mon_Server_EH_units";
	};
};