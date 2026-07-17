// A3C_ai_shared_fnc_actionWeaponAttachmentToggle

params [
	["_type", "", [""]],
	["_mode", "", [""]]
];

if !(_type in ["LASER", "FLASHLIGHT"]) exitWith {};
if !(_mode in ["ON", "OFF"]) exitWith {};

private _refGroups = [];
private _msgBody = "";

switch (_type) do {
	case "LASER": {
		_refGroups = if (_mode == "ON") then {
			A3C_HC_IR_Laser_On_Units
		} else {
			A3C_HC_IR_Laser_Off_Units
		};

		_msgBody = if (_mode == "ON") then {
			"Engage IR-LASER"
		} else {
			"Disengage IR-Laser"
		};

		A3C_Prevent_attach_IR_Laser = true;
	};

	case "FLASHLIGHT": {
		_refGroups = if (_mode == "ON") then {
			A3C_HC_LightsOnUnits
		} else {
			A3C_HC_LightsOffUnits
		};

		_msgBody = if (_mode == "ON") then {
			"Engage Flashlight"
		} else {
			"Disengage Flashlight"
		};

		A3C_Prevent_attach_Flashlight = true;
	};
};

private _msgTarget = if (count _refGroups == 1) then {
	groupID (_refGroups select 0)
} else {
	"All Target Groups"
};

/*
player commandChat format [
	"%1: %2, %3",
	name player,
	_msgTarget,
	_msgBody
];
*/

private _maxDelay = 0;
private _requestId = format ["%1_%2_%3", clientOwner, diag_tickTime, random 1];
private _requestVar = format ["A3C_ATTACHMENT_REQUEST_%1", _type];

{
	private _group = _x;

	if (!isNull _group) then {
		private _leader = leader _group;

		// Skip player-led groups.
		if (!isPlayer _leader && {player != _leader}) then {
			private _groupDelay = random 7;

			{
				private _unit = _x;

				if (!isNull _unit) then {
					private _unitDelay = random 1;
					private _delay = _groupDelay + _unitDelay;

					_maxDelay = _maxDelay max _delay;

					_unit setVariable [
						_requestVar,
						[_mode, _requestId],
						true
					];

					[
						[
							_unit,
							_type,
							_mode,
							_delay,
							_requestId
						],
						A3C_ai_shared_fnc_actionWeaponAttachmentSet
					] remoteExec ["BIS_fnc_spawn", _unit];
				};
			} forEach units _group;
		};
	};
} forEach _refGroups;

[false] call A3C_ui_shared_fnc_highCommand_actionsLabel;

[_maxDelay, _type] spawn {
	params ["_maxDelay", "_type"];

	sleep (_maxDelay + 1);

	switch (_type) do {
		case "LASER": {
			A3C_Prevent_attach_IR_Laser = false;
		};

		case "FLASHLIGHT": {
			A3C_Prevent_attach_Flashlight = false;
		};
	};

	[false] call A3C_ui_shared_fnc_highCommand_actionsLabel;
};

