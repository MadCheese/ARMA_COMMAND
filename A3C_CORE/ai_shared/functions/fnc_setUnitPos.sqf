// A3C_ai_shared_fnc_setUnitPos

params ["_units", "_unitPos"];


private _radioMessage = "";

switch (_unitPos) do {
	case ("AUTO") : {
		_radioMessage = "SentBehaviourSafe";
	};
	case ("DOWN") : {
		_radioMessage = "SentUnitPosDown";
	};
	case ("MIDDLE") : {
		_radioMessage = "SentUnitPosMiddle";
	};
	case ("UP") : {
		_radioMessage = "SentUnitPosUp";
	};
};

//-- player radio call
if (_radioMessage != "") then {
	player groupRadio _radioMessage;
};

//-- apply setUnitPos
{
	//-- spawn unitpos to add random delay to each unit (anti robot feel)
	[_x,_unitPos] spawn {
		params ["_unit","_unitPos"];
		sleep (random 1.5);
		_unit setunitPos _unitPos;
	};
} foreach _units;



