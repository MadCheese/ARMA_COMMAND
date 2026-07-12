// MCSS_fnc_getBoundingBox
// Get object bounding-box corner positions.

params [
	"_object",
	["_mode", 0]
];

private _boundingBox = 0 boundingBoxReal _object;
private _minBounds = _boundingBox select 0;
private _maxBounds = _boundingBox select 1;

private _frontLeft = _object modelToWorld _minBounds;
_frontLeft = [_frontLeft select 0, _frontLeft select 1, 0];

private _frontRight = _object modelToWorld [
	_maxBounds select 0,
	_minBounds select 1,
	0
];
_frontRight = [_frontRight select 0, _frontRight select 1, 0];

private _backRight = _object modelToWorld [
	_maxBounds select 0,
	_maxBounds select 1,
	0
];
_backRight = [_backRight select 0, _backRight select 1, 0];

private _backLeft = _object modelToWorld [
	_minBounds select 0,
	_maxBounds select 1,
	0
];
_backLeft = [_backLeft select 0, _backLeft select 1, 0];

if (_mode == 1) exitWith {
	private _halfWidth = (_frontLeft distance2D _frontRight) / 2;
	private _halfLength = (_frontLeft distance2D _backLeft) / 2;

	private _widthDir = [_frontLeft, _frontRight] call BIS_fnc_dirTo;
	private _lengthDir = [_frontLeft, _backLeft] call BIS_fnc_dirTo;

	private _frontMiddle = [_frontLeft, _halfWidth, _widthDir] call BIS_fnc_relPos;
	private _backMiddle = [_backLeft, _halfWidth, _widthDir] call BIS_fnc_relPos;
	private _leftMiddle = [_frontLeft, _halfLength, _lengthDir] call BIS_fnc_relPos;
	private _rightMiddle = [_frontRight, _halfLength, _lengthDir] call BIS_fnc_relPos;

	[
		_frontLeft,
		_frontMiddle,
		_frontRight,
		_rightMiddle,
		_backRight,
		_backMiddle,
		_backLeft,
		_leftMiddle
	]
};

[
	_frontLeft,
	_frontRight,
	_backRight,
	_backLeft
]