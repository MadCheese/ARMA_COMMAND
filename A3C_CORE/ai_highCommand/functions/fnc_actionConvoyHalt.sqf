{
	private _convoyElement = _x;

	{
		private _gp = _x;
		private _leader = leader _gp;
		private _units = units _gp;

		[_gp, "ALL"] call A3C_ai_highCommand_fnc_deleteAllWaypoints;

		

		{
			private _unit = _x;
			private _vehicle = objectParent _unit;
			private _weaponsFound = false;

			if (isNull _vehicle) then {
				_weaponsFound = currentWeapon _unit != "";
			} else {
				private _gunner = gunner _vehicle;

				if (!isNull _gunner) then {
					private _turretPath = _vehicle unitTurret _gunner;
					private _turretWeapons = _vehicle weaponsTurret _turretPath;

					_weaponsFound = !(_turretWeapons isEqualTo []);
				};
			};

			if (_weaponsFound) exitWith {
				_leader setBehaviourStrong "COMBAT";
				_leader setCombatMode "RED";
			};
		} forEach _units;
	} forEach _convoyElement;
} forEach A3C_GROUP_CONVOYS;

[] spawn {
	sleep 2;
	hintSilent "";
};

A3C_GROUP_CONVOYS = [];
A3C_SELECTED_HC_GROUPS_SETTINGS = [];