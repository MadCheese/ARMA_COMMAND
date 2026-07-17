// A3C_ai_highCommand_fnc_actionToggleIrStrobe

params [["_mode", "", [""]]];

if !(_mode in ["ON", "OFF"]) exitWith {};

private _referenceArray = if (_mode == "ON") then {
	A3C_HC_IROnUnits
} else {
	A3C_HC_IROffUnits
};

private _strobeType = switch (side cameraOn) do {
	case WEST: {"NVG_TargetE"};
	case EAST: {"NVG_TargetW"};
	default {"NVG_TargetC"};
};

private _randomSleepMax = 0;

// Unique enough for this command wave.
private _requestId = format ["%1_%2_%3", clientOwner, diag_tickTime, random 1];

A3C_Prevent_attach_IR = true;

{
	private _group = _x;

	if (!isNull _group) then {
		private _leader = leader _group;

		// Skip player-led groups.
		if (!isPlayer _leader && {player != _leader}) then {
			private _randomSleepGroup = random 5;
			_randomSleepMax = _randomSleepMax max _randomSleepGroup;

			{
				private _unit = _x;

				if (!isNull _unit) then {
					// Public request marker.
					// This lets delayed remote workers detect whether they are stale.
					_unit setVariable [
						"A3C_IR_STROBE_REQUEST",
						[_mode, _requestId],
						true
					];

					[
						[
							_unit,
							_mode,
							_strobeType,
							_randomSleepGroup,
							_requestId
						],
						A3C_ai_shared_fnc_actionIrStrobeSet
					] remoteExec ["BIS_fnc_spawn", _unit];
				};
			} forEach units _group;
		};
	};
} forEach _referenceArray;

[_randomSleepMax] spawn {
	params ["_randomSleepMax"];

	sleep (_randomSleepMax + 1);

	A3C_Prevent_attach_IR = false;
	[false] call A3C_ui_shared_fnc_highCommand_actionsLabel;
};