
A3C_HC_MoveToWaypoint = {
	params ["_group","_movePos"];
	private _doSlowDown = if (count _this > 2) then {_this select 2} else {false};
	private _leader = leader _group;
	private _leaderVic = vehicle _leader;
	private _effCom = effectiveCommander _leaderVic;
	private _driver = driver _leaderVic;

	if !(_effCom in units _group) exitWith {};

	private _dest = (expectedDestination _effCom) select 0;

	if (_dest distance2d _movePos == 0 && {speed _leaderVic > 1}) exitWith {};

	private _grunts = (units _group - [_leader]) select {_x == driver vehicle _x};
	{_x enableAI "MOVE", _x enableAI "PATH", _x enableAI "ANIM"} foreach (units _group);
	// private _commDest = (expectedDestination _effCom) select 0;
	// if (speed _leaderVic < 5) then {
	// if !(_commDest isEqualTo _movePos) then {
	// if (speed _leaderVic < 5) then {
		[_effCom,_movePos] call A3C_DOMOVE;
		// systemchat str [_movePos,_commDest];
	// };

	// if (_driver != _effCom) then {
		// [_driver,_movePos] call A3C_DOMOVE;
	// };
	
	

	{
		_vic = vehicle _x;
		if (_doSlowDown && {_vic distance2D _movePos < 1000 && {_x isKindOf "HELICOPTER"}}) then {
			_vic limitSpeed 80;
			// systemchat "SLOWDOWN";
		};
	} foreach (([_leader] + _grunts) select {_x == driver vehicle _x});
	_grunts doFollow _leader;
};




A3C_HC_WPScriptBlock = {
	params ["_callerUID","_group"];
	!(isClass(configFile/"CfgPatches"/"A3C_OBJECTS")) ||
	{
		!([_callerUID,_group] call A3C_HC_findExecutingMachine)
	}
};


A3C_HC_ReInitGroupMovement = {
	params ["_group"];
	// systemchat 'test A3C_HC_ReInitGroupMovement';
	{
		private _u = _x;
		private _oP = objectParent _x;
		{_u enableAI _x} foreach ["MOVE","PATH"];
		if (!isNull _oP) then {
			_op limitSpeed 5000;
			private _flyInHeight =_oP getVariable ["A3C_FLYINHEIGHT",75];
			// systemchat format ["A3C_HC_ReInitGroupMovement: FLYINHEIGHT: %1",_flyInHeight];
			_op flyInHeight (_op getVariable ["A3C_FLYINHEIGHT",_flyInHeight]);
			
			{_op enableAI _x} foreach ["MOVE","PATH"];
		};
	} foreach (units _group);
};

