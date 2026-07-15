// A3C_ui_mapOverlay_fnc_drawPolygonFrame

params ["_ctrl", "_positions", "_thickness", "_color"];

private _dashLength = 5;
private _dashSpacing = 5;
private _dashStep = _dashLength + _dashSpacing;

{
	private _edgeStart = _positions select (_x select 0);
	private _edgeEnd = _positions select (_x select 1);
	private _direction = _edgeStart getDir _edgeEnd;
	private _distance = _edgeStart distance2D _edgeEnd;
	private _dashAmount = _distance / _dashStep;
	private _rootPosition = +_edgeStart;
	private _leftDirection = _direction - 90;
	private _rightDirection = _direction + 90;

	for "_i" from 1 to _dashAmount do {
		private _dashEnd = _rootPosition getPos [_dashLength, _direction];

		private _corners = [
			_rootPosition getPos [_thickness, _leftDirection],
			_dashEnd getPos [_thickness, _leftDirection],
			_dashEnd getPos [_thickness, _rightDirection],
			_rootPosition getPos [_thickness, _rightDirection]
		];

		_ctrl drawTriangle [
			[
				_corners select 0,
				_corners select 1,
				_corners select 2,
				_corners select 2,
				_corners select 3,
				_corners select 0
			],
			_color,
			"#(rgb,1,1,1)color(1,1,1,1)"
		];

		_rootPosition = _rootPosition getPos [_dashStep, _direction];
	};
} forEach [
	[0, 1],
	[1, 2],
	[2, 3],
	[3, 0]
];