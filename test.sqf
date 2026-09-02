_units = (units player) - [player];

_vehicle = cursortarget;

(group player) selectleader (_units select 0);

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


if (true) exitWith {};