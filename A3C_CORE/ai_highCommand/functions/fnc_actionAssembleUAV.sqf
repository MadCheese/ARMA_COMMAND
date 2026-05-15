// A3C_ai_highCommand_fnc_actionAssembleUAV

params ["_leader", "_activeWpos", "_callerUID"];
// _activeWpos currently unused.

private _group = group _leader;

if !([_callerUID, _group] call A3C_ai_highCommand_fnc_findExecutingMachine) exitWith {};

{
	private _unit = _x;
	private _backpack = backpack _unit;
	private _uavType = getText (configFile >> "CfgVehicles" >> _backpack >> "assembleInfo" >> "assembleTo");
	private _exit = false;

	if (_uavType != "") then {
		private _isUAV = (getText (configFile >> "CfgVehicles" >> _uavType >> "uavCameraDriverDir")) != "";

		if (_isUAV) then {
			_exit = true;

			[_unit, "ainvpknlmstpslaywrfldnon_medic"] remoteExec ["playMove", _unit];

			sleep 2;

			removeBackpackGlobal _unit;

			sleep 5;

			if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {
				[_unit, "amovpknlmstpslowwrfldnon"] remoteExec ["playMove", _unit];
			};

			if (alive _unit) then {
				private _uavObject = _uavType createVehicle (_unit getPos [1.5, getDir _unit]);

				createVehicleCrew _uavObject;

				_uavObject flyInHeight 500;

				[driver _uavObject, _uavObject getPos [15, getDir _uavObject]] call A3C_ai_shared_fnc_doMove;
			} else {
				// Somehow a spawned backpack does not want to be deleted.
				// Since the unit's backpack was removed before, it is spawned on ground if killed.
				private _dummyBackpack = _backpack createVehicleLocal (_unit getPos [1, getDir _unit]);
			};
		};
	};

	if (_exit) exitWith {};
} forEach (units _group);