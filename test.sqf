_units = [units player select 1]; // -- this is just a test, can be any array of units

_vehicle = cursortarget;

_newLeader = _units select 0;

(group player) selectleader _newLeader;


_otherUnits = (units player) - [player, _newLeader] - _units;

//-- stationaryUnits hack: prevent effects of AI leader calling them back into formation
_stationaryUnits = _otherUnits select {
	currentCommand _x == ""
	&& {
		!(
			"form" in (toLower ((expectedDestination _x) select 1))
		)
	}
};

{_x disableAI "MOVE";} foreach _stationaryUnits;



{_x assignAsCargo _vehicle} foreach _units;
_units orderGetIn true;

waitUntil {
	{currentCommand _x == "GET IN"} count _units > 0
	||
	{
		{alive _x} count _units == 0
	}
};


(group player) selectleader player;

//-- stationaryUnits: Use fsm (silent) to move units (who are now in formation but with disabled movement) to their current position
//-- ONLY THEN re-enable their movement 
//-- result: unit perfectly stationary during entire process.
{
	_x doFSM ["A3C_CORE\fsm\doMove.fsm", position _x,  _x];
	_x enableAI "MOVE";
} foreach _stationaryUnits;


if (true) exitWith {};