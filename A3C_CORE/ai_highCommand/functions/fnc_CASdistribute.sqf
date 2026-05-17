// A3C_ai_highCommand_fnc_CASdistribute

params ["_leader","_casPos","_casType","_caller"];

private _orienter = 0;
private _distributionRound = 1;
private _casPosOrig = +_casPos;
private _dispersion = 50;

private _pilots = units _leader select {
	private _vehicle = objectParent _x;
	_x == driver _vehicle && {_vehicle isKindOf "PLANE"}
};

{
	private _aircraft = vehicle _x;
	_aircraft flyInHeight 1000;
} forEach _pilots;

waitUntil {
	((getPosVisual (vehicle _leader)) select 2) > 900
};

{
	private _pilot = _x;
	private _aircraft = vehicle _pilot;

	private _assignedCasPos = switch (_orienter) do {
		case 0: {
			+_casPosOrig
		};
		case 1: {
			_casPosOrig getPos [_dispersion * _distributionRound, 90]
		};
		case 2: {
			_casPosOrig getPos [_dispersion * _distributionRound, -90]
		};
		case 3: {
			_casPosOrig getPos [_dispersion * _distributionRound, 0]
		};
		case 4: {
			_casPosOrig getPos [_dispersion * _distributionRound, 180]
		};
	};

	_assignedCasPos set [2,0];

	[_aircraft,_assignedCasPos,_casType,_caller] remoteExec ["A3C_ai_highCommand_fnc_CASexecute", _aircraft];

	_orienter = _orienter + 1;

	if (_orienter > 4) then {
		_orienter = 1;
		_distributionRound = _distributionRound + 1;
	};

	sleep 1;
} forEach _pilots;