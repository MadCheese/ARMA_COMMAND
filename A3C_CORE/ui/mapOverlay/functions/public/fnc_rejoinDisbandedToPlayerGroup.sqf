// A3C_ui_mapOverlay_fnc_rejoinDisbandedToPlayerGroup

params ["_groups"];

{
	private _group = _x;
	private _units = units _group;

	A3C_HC_DISBANDED = A3C_HC_DISBANDED - [_group];

	(
		_group getVariable "A3C_TAB_MARKER"
	) setMarkerAlphaLocal 1; //~~ still needed?

	{
		private _unit = _x;
		private _vehicle = vehicle _unit;

		_vehicle spawn {
			[
				_this,
				"LOCKED"
			] remoteExec [
				"setVehicleLock",
				_this
			];

			sleep 5;

			[
				_this,
				"UNLOCKED"
			] remoteExec [
				"setVehicleLock",
				_this
			];
		};

		[
			[
				_unit
			],
			A3C_ai_highCommand_fnc_restoreUnitRole
		] remoteExec [
			"BIS_fnc_spawn",
			_unit
		];
	} forEach _units;

	_units join group player;
} forEach _groups;