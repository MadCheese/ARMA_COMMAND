//-- CURRENTLY UNUSED!

//--- Snippet adapted from ADVANCED RAPELLING BY DUDA!! ~~ give credit in forums
//--- Takes ASL position.

params ["_vehicle", "_rappelPos", "_hoverHeight"];

//--- Prevent issue in SP where vehicle will not let itself be forceMoved when time is > 1.
if !(isMultiplayer) then {
	setAccTime 1;
};

private _velocityMagnitude = 15;

//------------------------------------------------------------------------------------------------------------------------

while {alive _vehicle} do {
	private _vectorUp = vectorUp _vehicle;
	private _vehiclePosASL = getPosASL _vehicle;

	_vectorUp params ["_vectorUpX", "_vectorUpY", "_vectorUpZ"];

	if (_vectorUpX != 0) then {
		if (_vectorUpX > 0) then {
			_vectorUpX = (_vectorUpX - 0.1) max 0;
		} else {
			_vectorUpX = (_vectorUpX + 0.1) min 0;
		};
	};

	if (_vectorUpY != 0) then {
		if (_vectorUpY > 0) then {
			_vectorUpY = (_vectorUpY - 0.1) max 0;
		} else {
			_vectorUpY = (_vectorUpY + 0.1) min 0;
		};
	};

	if (_vectorUpZ < 1) then {
		_vectorUpZ = (_vectorUpZ + 0.1) min 1;
	};

	//-- #TODO Call this function where _vehicle is local and replace remoteExec calls with direct local commands.
	[_vehicle, [_vectorUpX, _vectorUpY, _vectorUpZ]] remoteExec ["setVectorUp", _vehicle];

	private _distanceToPosition = _vehiclePosASL distance _rappelPos;

	if (_distanceToPosition <= 10) then {
		_velocityMagnitude = ((_distanceToPosition / 10) * _velocityMagnitude) max 5;
	} else {
		if (_distanceToPosition <= 50) then {
			if (_velocityMagnitude > 5) then {
				_velocityMagnitude = _velocityMagnitude - 0.1;
			};
		};
	};

	if (_distanceToPosition <= 2) exitWith {};

	[_vehicle, [0, 0, 1]] remoteExec ["setVectorUp", _vehicle];

	private _currentVelocity = velocity _vehicle;
	_currentVelocity = _currentVelocity vectorAdd ((_vehiclePosASL vectorFromTo _rappelPos) vectorMultiply _velocityMagnitude);
	_currentVelocity = vectorNormalized _currentVelocity vectorMultiply ((vectorMagnitude _currentVelocity) min _velocityMagnitude);

	[_vehicle, _currentVelocity] remoteExec ["setVelocity", _vehicle];
	[_vehicle, _hoverHeight] remoteExec ["flyInHeight", _vehicle];

	sleep 0.05;
};