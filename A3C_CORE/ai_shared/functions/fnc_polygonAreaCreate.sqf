// A3C_ai_shared_fnc_polygonAreaCreate

params ["_input", "_dir", "_mode", "_draw"];

private _owners = if ((count _this) > 4) then {
	_this select 4
} else {
	nil
};

private _color = switch (_mode) do {
	case "SUPPRESSION": {
		"colorOpfor"
	};

	case "AMBUSH": {
		"colorBlack"
	};
};

private _poses = [];

if ((_input select 0) isEqualType 0) then {
	// _input is a position

	private _inputPos = +_input;
	_inputPos params ["_inputX", "_inputY", "_inputZ"];

	private _size = if ((nearestObjects [_inputPos, ["House"], 10]) isEqualTo []) then {
		10
	} else {
		1.5
	};

	private _polygonData = [];

	for "_i" from 1 to 4 do {
		private _add = switch (_i) do {
			case 1: {
				// Top left
				private _pos = [[_inputX, _inputY, _inputZ], _size, 270 + _dir] call BIS_fnc_relPos;
				[_pos, _size, 0 + _dir] call BIS_fnc_relPos
			};

			case 2: {
				// Top right
				private _pos = [[_inputX, _inputY, _inputZ], _size, 90 + _dir] call BIS_fnc_relPos;
				[_pos, _size, 0 + _dir] call BIS_fnc_relPos
			};

			case 3: {
				// Bottom right
				private _pos = [[_inputX, _inputY, _inputZ], _size * 0.75, 90 + _dir] call BIS_fnc_relPos;
				[_pos, _size, 180 + _dir] call BIS_fnc_relPos
			};

			case 4: {
				// Bottom left
				private _pos = [[_inputX, _inputY, _inputZ], _size * 0.75, 270 + _dir] call BIS_fnc_relPos;
				[_pos, _size, 180 + _dir] call BIS_fnc_relPos
			};
		};

		_polygonData pushBack _add;
	};

	_poses = _polygonData;
} else {
	// _input is polygon array
	_poses = _input;
};

// Create polygon markers.
// Currently this block does not create markers; preserved as no-op behavior.
private _markers = [];

if (_draw) then {
	{
		private _text = if (_forEachIndex == 0) then {
			"SZ"
		} else {
			""
		};
	} forEach _poses;
};

[_poses, _markers, _dir]