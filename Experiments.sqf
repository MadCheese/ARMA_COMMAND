//-- WIP attempt to request information from the server - this will only work on var states so far
//-- WOULD NOT WORK BECAUSE YOU CANT CONVERT VARNAME ITSELF INTO STRING, ONLY THE STATE :(
fnc_getVarStateOnMachine = {
	params ["_varString","_clientOwner"]; //-- variable passed in as a string, not var itself
	_result = if (isNil _varString) then {nil} else {call compile _varString}; //-- return nil if variable does not exist, compile varstate from string if it does exists
	_fnc = {
		params ["_varString", "_result"];
		call compile format
		[
			"%1_RESPONSE_LAST = %2",
			_varString,
			_result
		];
	};
	[[_varString, _result], _fnc] remoteExec ["bis_fnc_call", _clientOwner];
};

//-- usage:
[[str , clientOwner], _fnc] remoteExec ["bis_fnc_call", 2]; //-- request from server

