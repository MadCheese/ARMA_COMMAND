// A3C_ai_shared_fnc_landAt

params ["_vehicle", "_landingPosWorld", "_landingMode"];

doStop (driver _vehicle); //-- hack to prevent pilot from taking off and hovering - the entire reason for this fnc 

if (_landingMode == "Land") then {
	//-- no time constraint used (irrelevant, but it's the intended syntax)
	_vehicle landAt [
		_landingPosWorld,
		"Land"
	];
} else {
	//-- time constraint used (irrelevant, but it's the intended syntax)
	_vehicle landAt [
		_landingPosWorld,
		_landingMode,
		999999
	];
};