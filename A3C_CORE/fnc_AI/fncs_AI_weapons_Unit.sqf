
//-- EH function for MISSILE-DISTRIBUTION Fired-Eventhandlers
A3C_Mon_Server_EH_FIRED = {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	private ["_target"];
	(_unit getVariable ["A3C_Mon_Server_Var",[-1,objNull,""]]) params ["_handle","_target","_ammo"];
	//player sidechat format ["%1 fired at %2 (%3)",_unit,_target,(gettext(configFile >> "CfgVehicles" >> typeof _target >> "displayName"))];
	waituntil {!alive _projectile};
	_unit removeEventhandler ["FIRED",_handle];
	A3C_Mon_Server_EH_units = A3C_Mon_Server_EH_units - [_unit];
	publicVariable 'A3C_Mon_Server_EH_units';
	_unit setVariable ["A3C_Mon_Server_Var",[-1,objNull,""],true];
	_unit enableAI "AUTOTARGET";
};

//-- Distribute Missile Targets (used by Server Monitor FSM)
A3C_Mon_Server_EH_Fnc = {
	params ["_gp","_sides","_assignedTargets"];
	if (side _gp in _sides) then {
		_gpUnits = (units _gp);
		//-- sort units by AIAmmoUsageFlags (damage of ammo)
		_gpUnits = 
		[
			_gpUnits,
			[],
			{
				private _value = 0;
				private _secMag = (secondaryWeaponMagazine _x);
				if (count _secMag > 0) then {
					_secMag = _secMag select 0;
					private _ammoType = (getText (configfile >> "CfgMagazines" >> _secMag >> "ammo"));
					private _aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammoType >> "aiAmmoUsageFlags");
					if (_aiAmmousageFlags == "") then {
						_aiAmmoUsageFlags = str (getNumber (configfile >> "CfgAmmo" >> _ammoType >> "aiAmmoUsageFlags"));
						switch (true) do {
							case (["512",_aiAmmoUsageFlags] call BIS_fnc_instring) : {_value = 3;};
							case (["128",_aiAmmoUsageFlags] call BIS_fnc_instring) : {_value = 2;};
							case (["256",_aiAmmoUsageFlags] call BIS_fnc_instring) : {_value = 1;};
						};
					};
				};
				_value
			},
			"DESCEND"
		] call BIS_fnc_sortBy;
		{
			_u = _x;
			if (isNull objectParent _u) then { //-- unit has to be on foot
				if (!isPLayer _u) then { //-- unit may not be controlled by player
					if !(_u getVariable ["A3C_ROE",false]) then { //-- unit must have AUTOTARGET on by ROE
						if (count (secondaryWeaponMagazine _u) > 0) then { //-- unit has a loaded secondaryWeapon
							if (currentWeapon _u == secondaryWeapon _u) then {
							//if (secondaryWeapon _u != "") then {
								private _allowFire = false;
								//_u forceSpeed 0;
								if !(_u in A3C_Mon_Server_EH_units) then {
									if (isNull assignedTarget _u) then {
										_u doTarget objNull;
										_u lookAt objNull;
										_u disableAI "AUTOTARGET";
										
										private _ammo = (getText (configfile >> "CfgMagazines" >> currentMagazine _u >> "ammo"));
										private _aiAmmoUsageFlags = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
										if (_aiAmmousageFlags == "") then {
											_aiAmmoUsageFlags = str (getNumber (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags"));
										};
										private _targetTypes = if (["256",_aiAmmoUsageFlags] call BIS_fnc_instring) then {["AIR"]} else {["CAR","TANK"]}; //-- select target types according to ammo
										private _checkDistance = getNumber (configfile >> "CfgWeapons" >> secondaryWeapon _u >> "maxRange"); //-- we only need to check within a distance that the nit can target within
										private _nearTargets = ([(side _u),_checkDistance,"ENEMY",position _x,_targetTypes] call MCSS_fnc_NearEntities) - _assignedTargets;
										if (count _nearTargets > 0) then {
											//-- sort targets by armor value
											_nearTargets = [_nearTargets,[],{getNumber (configfile >> "CfgVehicles" >> typeOf _x >> "armor")},"DESCEND"] call BIS_fnc_sortBy;
											
											{
												_target = _x;
												if (canMove _target) then {
													_assignedTargets pushBackUnique _target;
													A3C_Mon_Server_EH_units pushBackUnique _u;
													publicVariable 'A3C_Mon_Server_EH_units';
													_handle = _u addEventhandler 
													[
														"FIRED",
														{
															_this spawn A3C_Mon_Server_EH_FIRED;
														}
													];
													_u setVariable ["A3C_Mon_Server_Var",[_handle,_target,_ammo],true];
													[_u,_target] spawn {
														params ["_u","_target"];
														sleep random 1;
														[_u,_target] remoteExec ["doTarget",_u];
														[_u,_target] remoteExec ["doFire",_u];
														[_u,[_target,4]] remoteExec ["reveal",_u];
														private _abort = false;
														for "_i" from 0 to 7 step 0.1 do {
															if !(_u in A3C_Mon_Server_EH_units) exitWith {};
															if (isNull _u) exitWith {};
															if (!alive _u) exitWith {_abort = true};
															//if ((currentWeapon _u != secondaryWeapon _u)) exitWith {_abort = true};
															if (!alive _target) exitWith {_abort = true};
															sleep 0.1;
														};
														if (_abort) then {
															//systemchat format ["abort order for %1",_u];
															(_u getVariable ["A3C_Mon_Server_Var",[-1,objNull,'']]) params ["_handle","_target","_ammo"];
															[_u,objNull] remoteExec ["doTarget",_u];
															[_u,objNull] remoteExec ["doFire",_u];
															[_u,objNull] remoteExec ["lookAt",_u];
															[_u,objNull] remoteExec ["doWatch",_u];
															{[_u,(assignedTarget _u)] remoteExec ["forgetTarget",_u]} foreach units _u;
															[_u,primaryWeapon _u] remoteExec ["selectWeapon",_u];
															_u removeEventhandler ["FIRED",_handle];
															A3C_Mon_Server_EH_units = A3C_Mon_Server_EH_units - [_u];
															publicVariable 'A3C_Mon_Server_EH_units';
															_u setVariable ["A3C_Mon_Server_Var",[-1,objNull,""],true];
															_u enableAI "AUTOTARGET";
														};
													};
													//-- new target allocated, unit is allowed to fire
													_allowFire = true;

													//player commandchat format ["%1 target allocated: %2 (%3)",_u,_target,(gettext(configFile >> "CfgVehicles" >> typeof _target >> "displayName"))];
												};
												//_u selectWeapon (secondaryWeapon _u);
												if (_allowFire) exitWith {};
											} foreach _nearTargets;
										};
									};
								} else {
									//-- if they are in current EH units already, they should be able to fire
									_allowFire = true;
								};
								//-- any unit with a launcher that is not being handled will cancel it's target
								if !(_allowFire) then {
									if (isNull assignedTarget _u) then {

										//systemchat format ["prevented %1 from firing",_u];
										[_u,objNull] remoteExec ["doTarget",_u];
										[_u,objNull] remoteExec ["doFire",_u];
										[_u,objNull] remoteExec ["lookAt",_u];
										{[_u,(assignedTarget _u)] remoteExec ["forgetTarget",_u]} foreach units _u;
										//[_u,primaryWeapon _u] remoteExec ["selectWeapon",_u];
									};
								};
							};
						};						
					};
				};
			};
		} foreach _gpUnits;
	};
};


//-- find the base weapon of another weapon ('base weapon' is the weapon model without attached weapon items.
TAG_fnc_baseWeapon = {
	params ["_weapon"];
	_baseCfg = (configFile >> "cfgWeapons");
	_cfg = _baseCfg >> _weapon;

	while {isClass (_cfg >> "LinkedItems") } do {
		_parent = configName (inheritsFrom (_cfg));
		_cfg = _baseCfg >> _parent;
	};
	configName _cfg
	//_return = if (_cfN == _weapon) then {};

	
};

TAG_fnc_baseVehicle = {
	params ["_vehicle"];
	_baseCfg = (configFile >> "cfgVehicles");
	_cfg = _baseCfg >> _vehicle;

	//while {isClass (_cfg >> "LinkedItems") } do {
		_parent = configName (inheritsFrom (_cfg));
		_cfg = _baseCfg >> _parent;
	//};

	configName _cfg
};


//-- check if a unit has UGL capabilities
A3C_HasGL = {
	params ["_unit"];
	private ["_return","_mzls","_wpn","_mgs"];
	_return = true;
	_wpn = (primaryWeapon _unit);
	if !(_unit == (vehicle _unit)) then {_return = false};
	_mzls = (getarray (configfile >> "CfgWeapons" >> _wpn >> "muzzles"));
	if (count _mzls < 2) then {
		_return = false;
	} else {
		_mgs = getArray (configfile >> "CfgWeapons" >> _wpn >> _mzls select 1 >> "magazines");
		if ({_x in _mgs} count ( (primaryweaponmagazine _unit)) == 0) then {_return = false}; // (magazines _unit) +
	};	
	_return
};
//-- check if a unit has AT capabilities
A3C_HasAT = {
	params ["_unit"];
	private ["_return","_mgs","_wpn"];
	_return = false;	
	_wpn = secondaryWeapon _unit;
	if !(_wpn == "") then {
		_mgs = getArray (configfile >> "CfgWeapons" >> _wpn >> "magazines");
		if ({_x in _mgs} count ((secondaryWeaponmagazine _unit)) > 0) then {_return = true}; // (magazines _unit) + 
	};
	if !(_unit == (vehicle _unit)) then {_return = false};
	_return
};

	

