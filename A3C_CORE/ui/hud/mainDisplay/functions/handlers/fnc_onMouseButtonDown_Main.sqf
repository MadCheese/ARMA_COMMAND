// A3C_UI_mainDisplay_fnc_onMouseButtonDown_Main

params [
	["_display", displayNull, [displayNull]],
	["_mouseButton", -1, [0]],
	["_screenX", 0, [0]],
	["_screenY", 0, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

if (A3C_DISABLE_RADIAL) exitWith {
	false
};

if (_mouseButton != 1) exitWith {
	false
};

private _cursorTarget = cursorTarget;

if (_ctrl) exitWith {
	if (a3c_is_HC_remote) exitWith {
		_this call A3C_ui_shared_fnc_onMouseButtonDown_remoteVehicle;

		false
	};

	private _playerGroupUnits = units group player;

	private _isPlayerGroupUnit =
		!isNull _cursorTarget
		&& {_cursorTarget in _playerGroupUnits};

	/*
		Alt + Ctrl + RMB on a squad member:
		Toggle HUD squad-placement selection.
	*/
	if (
		_alt
		&& {_isPlayerGroupUnit}
	) exitWith {
		if (_cursorTarget in A3C_UI_squadPlacement_units) then {
			[
				_cursorTarget
			] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
		} else {
			private _formationIndex = _cursorTarget getVariable [
				"A3C_FORMATION_INDEX",
				-1
			];

			[
				_cursorTarget,
				_formationIndex
			] call A3C_UI_squadPlacement_fnc_addUnitGhost;
		};

		/*
			HUD selection replaces vanilla group selection.
		*/
		{
			player groupSelectUnit [
				_x,
				false
			];
		} forEach +groupSelectedUnits player;

		showCommandingMenu "";

		true
	};

	/*
		Ctrl + RMB on a squad member:
		Toggle vanilla group selection.

		Clear HUD selection first so the two selection systems remain
		mutually exclusive.
	*/
	if (_isPlayerGroupUnit) exitWith {
		{
			[
				_x
			] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
		} forEach +A3C_UI_squadPlacement_units;

		private _selectUnit =
			!(_cursorTarget in groupSelectedUnits player);

		player groupSelectUnit [
			_cursorTarget,
			_selectUnit
		];

		if (groupSelectedUnits player isEqualTo []) then {
			showCommandingMenu "";
		};

		true
	};

	/*
		Ctrl + RMB away from a squad member:
		Execute an active HUD placement order.
	*/
	if (A3C_UI_squadPlacement_units isNotEqualTo []) exitWith {
		[
			_alt,
			_shift
		] call A3C_UI_squadPlacement_fnc_executeOrder;

		true
	};

	false
};

/*
	Regular RMB cancels the player's active GTI grenade interaction.
*/
if (
	BR_A3C_GRENADEMODE
	&& {A3C_GTI_UNIT == player}
) then {
	A3C_GTI_UNIT = objNull;
	BR_A3C_GRENADEMODE = false;

	[
		"BR_A3C_TACV_oefId",
		"onEachFrame"
	] call BIS_fnc_removeStackedEventHandler;
};

false