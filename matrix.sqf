[cursortarget] spawn {_target = _this select 0;
setacctime 0.1;
_cam = "camera" camCreate position _target;
_cam cameraEffect ["internal","back"];
_cam camSetPos _position;
_cam camSetTarget _target;
_cam camSetFOV 0.1;
_cam camCommit 0;

_step = 0;

while {true} do {
	if (_step > 180) exitWith {};
	_position = ASLtoATL ([(eyepos _target),10,_step] call BIS_fnc_RelPos);
	_cam camSetPos _position;
	_cam camCommit 0;
	_step = _step + 0.002;
};
setacctime 1;
camDestroy _cam;
};
