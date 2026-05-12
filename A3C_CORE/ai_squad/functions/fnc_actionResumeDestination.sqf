// A3C_ai_squad_fnc_actionResumeDestination

params ["_unit"];

private _expectedCurrent = expectedDestination _unit;

if (
	count _expectedCurrent > 0
	&& { (_expectedCurrent select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"] }
) exitWith {}; //-- units are already in formation

private _expectedDestinationData = _unit getVariable ["A3C_DEST", []];

if (!isPlayer _unit && {count _expectedDestinationData > 0}) then {

	private _expectedPosition = _expectedDestinationData select 0;

	if (player == leader group _unit) then {
		if ((_expectedDestinationData select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {
			//-- unit was in formation
			_unit doFollow player;
		} else {
			if !(currentCommand _unit == "STOP") then {
				//-- units had a destination or stationary position and was NOT ordered to stop in meantime
				_unit doWatch objNull;
				_unit lookAt objNull;
				_unit setUnitPos "UP";

				if !(A3C_UI_CustomFormation_BOOL_formationActive) then {
					if ((_expectedDestinationData select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {
						_unit doFollow player;
					} else {
						[_unit, _expectedPosition] call A3C_DOMOVE;

						if (count _expectedDestinationData > 3) then {
							_unit lookAt (_expectedPosition getPos [100, _expectedDestinationData select 3]);
						};
					};
				} else {
					[_unit] spawn {
						params ["_unit"];

						private _formationData = _unit getVariable "A3C_FORM";
						private _formationDistance = _formationData select 0;
						private _formationDirection = getDir player + (_formationData select 1);
						private _formationPosition = player getPos [_formationDistance, _formationDirection];

						_unit setVariable ["A3C_FORM_MEMBER", true, false];

						doStop _unit;
						sleep 0.2;

						[_unit, _formationPosition] call A3C_DOMOVE;

						if !(isMultiplayer) then {
							_unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit, _unit];
						};
					};
				};
			};
		};
	} else {
		if ((_expectedDestinationData select 1) in ["DoNotPlanFormation", "FORMATION PLANNED"]) then {
			[
				[_unit],
				{
					params ["_unit"];

					_unit doFollow (leader (group _unit));
					_unit lookAt objNull;
					_unit setUnitPos "AUTO";
				}
			] remoteExec ["bis_fnc_call", _unit];
		} else {
			if (_expectedPosition distance2D [0, 0, 0] > 0) then {
				[_unit, _expectedPosition] call A3C_DOMOVE;

				if (count _expectedDestinationData > 3) then {
					[_unit, (_expectedPosition getPos [100, _expectedDestinationData select 3]) ] remoteExec ["lookAt", _unit];
				};
			};
		};
	};
};

_unit setVariable ["A3C_DEST", _expectedDestinationData, true];