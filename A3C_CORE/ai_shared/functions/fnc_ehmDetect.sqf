// A3C_ai_shared_fnc_ehmDetect

if (isNil 'A3C_EHM' || {!(A3C_EHM)}) exitWith {false};

params ["_climber", "_destination"];

private _climbOnly = true;

if (isNil "_climber") then {
	_climber = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
};

private _mcDir = if (isNil "_destination") then {
	getDir _climber
} else {
	_climber getDir _destination
};

private _babeEmVars = _climber getVariable "babe_em_vars";
if !(_babeEmVars select 2) exitWith {false};

private _climberPosASL = getPosASL _climber;
private _refPos1 = ((_climberPosASL getPos [0.5, _mcDir]) select [0, 2]) + [_climberPosASL select 2];
private _refPos2 = (_refPos1 select [0, 2]) + [0];

private _ins = lineIntersectsSurfaces [
	_refPos1,
	_refPos2,
	_climber,
	objNull,
	true,
	1,
	"GEOM",
	"NONE"
];

private _checkPos = (_ins select 0) select 0;

//-- A3C additions to check for AI drop
private _doDrop = false;
private _heightDiff = abs ((_climberPosASL select 2) - (_checkPos select 2));

if ((_checkPos select 2) < (_climberPosASL select 2) && {_heightDiff < 3 && {_heightDiff > 0.5}}) then {
	_doDrop = true;
};

private _cos = 0;

if ((_checkPos select 2) < ((_climberPosASL select 2) - 0.5)) then {
	_checkPos = ASLToAGL _checkPos;

	private _headPosAGL = ASLToAGL (ATLToASL (_climber modelToWorld (_climber selectionPosition "Head")));
	private _downPosAGL = _climber modelToWorld [0, 0, -5];

	private _v1 = _headPosAGL vectorFromTo _checkPos;
	private _v2 = (_climber modelToWorld [0, 0, 0]) vectorFromTo _downPosAGL;

	_cos = _v1 vectorCos _v2;
};

private _dpos = [0, 0, 0];

if (_doDrop) exitWith {
	for "_i" from 0 to 20 do {
		private _intCount = 0;

		private _posa = _climber modelToWorld [0, (_i * 0.05), 0.5];
		private _posb = _climber modelToWorld [0, (_i * 0.05), -1.7];

		private _int = lineIntersectsSurfaces [
			AGLToASL _posa,
			AGLToASL _posb,
			_climber,
			objNull,
			true,
			1,
			"GEOM",
			"FIRE"
		];

		_intCount = (count _int) + _intCount;

		_posa = _climber modelToWorld [0, 0, (_i * 0.05)];
		_posb = _climber modelToWorld [0, 1.5, (_i * 0.05)];

		private _int2 = lineIntersectsSurfaces [
			AGLToASL _posa,
			AGLToASL _posb,
			_climber,
			objNull,
			true,
			1,
			"GEOM",
			"FIRE"
		];

		_intCount = (count _int2) + _intCount;

		if (_intCount == 0) then {
			private _anm = "";

			switch (currentWeapon _climber) do {
				case (""): {
					_anm = "babe_drop_ua";
				};
				case (primaryWeapon _climber): {
					_anm = "babe_drop_rfl";
				};
				case (handgunWeapon _climber): {
					_anm = "babe_drop_pst";
				};
			};

			if (_anm != "" && str _dpos != "[0,0,0]") then {
				_babeEmVars = _climber getVariable "babe_em_vars";
				_babeEmVars set [0, true];
				_climber setVariable ["babe_em_vars", _babeEmVars];

				[
					((name _climber) + "EH_em_drop"),
					{animationState (_condpars select 0) == (_condpars select 1)},
					[_climber, _anm],
					"A3C_ai_shared_fnc_execDrop",
					[_dpos, _climber],
					true,
					"A3C_ai_shared_fnc_ehmFinishDrop",
					[_climber],
					0
				] call babe_core_fnc_addEH;

				_climber playMoveNow _anm;
			};
		} else {
			_dpos = (_int select 0) select 0;
		};
	};

	false
};

//-- climb
private _pos = [0, 0, 0];
private _posa = [0, 0, 0];
private _posb = [0, 0, 0];
private _topPos = [0, 0, 0];
private _goodZ = [];
private _blocked = false;
private _top = false;
private _poses = [];
private _int = [];
private _obj = _climber;

for "_i" from 3 to 60 do {
	_posa = _climber modelToWorld [0, 0, (_i * 0.05)];
	_posb = _climber modelToWorld [0, 1.5, (_i * 0.05) + 0.1];

	_int = lineIntersectsSurfaces [
		AGLToASL _posa,
		AGLToASL _posb,
		_climber,
		objNull,
		true,
		1,
		"GEOM",
		"FIRE"
	];

	private _resPos = (_int select 0) select 0;
	private _succ = count _int > 0;

	if (_succ) then {
		_obj = (_int select 0) select 3;

		if (EM_debug) then {
			drawLine3D [_posa, _posb, [1, 0, 0, 1]];
		};

		private _testPos = (_int select 0) select 0;
		private _posWT = _climber worldToModel (ASLToAGL _testPos);

		if ((_posWT select 2) > 0.5) then {
			_pos = _testPos;
			_goodZ pushBack (_posWT select 1);
		};
	} else {
		if (str _pos != "[0,0,0]") then {
			private _ppWT = (_climber worldToModel (ASLToAGL _pos)) select 2;
			private _tpWT = (_i * 0.05) + 0.1;
			private _dst = (_ppWT max _tpWT) - (_ppWT min _tpWT);

			if (EM_debug) then {
				drawLine3D [_posa, _posb, [0, 1, 1, 1]];
			};

			private _posWT = _climber worldToModel (ASLToAGL _pos);

			if (!(_pos in _poses) && (_posWT select 2) > 0.5 && _dst > 0.5) then {
				_poses pushBack _pos;
			};
		};
	};
};

if (typeOf _obj in EM_blacklist_obj) exitWith {false};

if (count _poses > 0) then {
	_pos = _poses select 0;
};

private _posWT = _climber worldToModel (ASLToAGL _pos);

_posa = _climber modelToWorld [
	_posWT select 0,
	(_posWT select 1) + 0.75,
	(_posWT select 2) + 0.5
];

_posb = _climber modelToWorld [
	_posWT select 0,
	(_posWT select 1) + 0.75,
	(_posWT select 2) - 5
];

private _topTest = lineIntersectsSurfaces [
	AGLToASL _posa,
	AGLToASL _posb,
	_climber,
	objNull,
	true,
	1,
	"GEOM",
	"FIRE"
];

_topPos = (_topTest select 0) select 0;

private _obstacle = (_topTest select 0) select 2;
private _posToPos = (_topTest select 0) select 3;

_top = !isNil "_posToPos";

if (!_top) then {
	_topPos = AGLToASL (_climber modelToWorld [0, 2, 0]);
} else {
	private _a = abs (_pos select 2);
	private _b = abs (_topPos select 2);
	private _max = _a max _b;

	if (_max == _a) then {
		if (_a - _b > 0.6) then {
			_top = false;

			if (_a - _b > 1.8) then {
				_topPos = AGLToASL (_climber modelToWorld [0, 2, 0]);
			};
		} else {
			_top = true;
		};
	} else {
		_top = true;
	};
};

if (str _pos != "[0,0,0]" && _top) then {
	private _avZ = 0;
	private _min = 999;
	private _max = 0;

	for "_i" from 0 to (count _goodZ) - 1 do {
		private _z = _goodZ select _i;

		if (_i > 0) then {
			_min = _min min _z;
			_max = _max max _z;
		};

		_avZ = _avZ + _z;
	};

	if (_max - _min > 0.5) then {
		_avZ = _avZ / (count _goodZ);

		_pos = AGLToASL (_climber modelToWorld [
			_posWT select 0,
			_avZ,
			_posWT select 2
		]);
	};
};

_posWT = _climber worldToModel (ASLToAGL _pos);

private _bone = _climber selectionPosition "Spine3";

_posa = _climber modelToWorld _bone;
_posb = _climber modelToWorld [
	_bone select 0,
	_bone select 1,
	(_posWT select 2) + 0.5
];

private _int2 = lineIntersectsSurfaces [
	AGLToASL _posa,
	AGLToASL _posb,
	_climber,
	objNull,
	true,
	1,
	"GEOM",
	"FIRE"
];

_posa = _climber modelToWorld [0, 0, (_posWT select 2) + 0.2];
_posb = _climber modelToWorld [
	_posWT select 0,
	(_posWT select 1) + 0.2,
	(_posWT select 2) + 0.2
];

private _int3 = lineIntersectsSurfaces [
	AGLToASL _posa,
	AGLToASL _posb,
	_climber,
	objNull,
	true,
	1,
	"GEOM",
	"FIRE"
];

private _int2o = if (count _int2 > 0) then {
	(_int2 select 0) select 2
} else {
	objNull
}; //-- modified

private _int3o = if (count _int3 > 0) then {
	(_int3 select 0) select 2
} else {
	objNull
}; //-- modified

_blocked = ((count _int2) + (count _int3) > 0) && {
	(!isNil "_int2o" || {!isNil "_int3o"}) || {!isNull _int2o || {!isNull _int3o}}
};

if (_blocked) then {
	_pos = [0, 0, 0];
};

if (!_top && _obj != _climber && {_obj isKindOf "CaManBase"}) then {
	_pos = [0, 0, 0];
};

private _wide = true;

if (!_top) then {
	_posWT = _climber worldToModel (ASLToAGL _pos);

	private _a = AGLToASL (_climber modelToWorld [
		(_posWT select 0) + 0.3,
		_posWT select 1,
		(_posWT select 2) + 0.2
	]);

	private _b = AGLToASL (_climber modelToWorld [
		(_posWT select 0) - 0.3,
		_posWT select 1,
		(_posWT select 2) + 0.2
	]);

	private _c = AGLToASL (_climber modelToWorld [
		(_posWT select 0) + 0.3,
		(_posWT select 1) + 0.1,
		(_posWT select 2) + 0.2
	]);

	private _d = AGLToASL (_climber modelToWorld [
		(_posWT select 0) - 0.3,
		(_posWT select 1) - 0.1,
		(_posWT select 2) + 0.2
	]);

	private _e = AGLToASL (_climber modelToWorld [
		(_posWT select 0) + 0.3,
		(_posWT select 1) - 0.1,
		(_posWT select 2) + 0.2
	]);

	private _f = AGLToASL (_climber modelToWorld [
		(_posWT select 0) - 0.3,
		(_posWT select 1) + 0.1,
		(_posWT select 2) + 0.2
	]);

	private _int1 = lineIntersectsSurfaces [_a, _b, _climber, objNull, true, 1, "GEOM", "FIRE"];
	_int2 = lineIntersectsSurfaces [_c, _d, _climber, objNull, true, 1, "GEOM", "FIRE"];
	_int3 = lineIntersectsSurfaces [_e, _f, _climber, objNull, true, 1, "GEOM", "FIRE"];

	_wide = (count _int1) + (count _int2) + (count _int3) == 0;
};

if (EM_debug) then {
	babe_em_debug_a setPosASL (_poses select 0);
};

if (!_wide) then {
	_pos = [0, 0, 0];
};

_blocked = false;

if (str _pos != "[0,0,0]" && count _poses > 0) then {
	if (_top) then {
		_posa = _poses select 0;
		_posa set [2, (_posa select 2) + 0.2];

		_posb = [
			_posa select 0,
			_posa select 1,
			(_posa select 2) + 1.25
		];

		private _int4 = lineIntersectsSurfaces [
			_posa,
			_posb,
			_climber,
			objNull,
			true,
			1,
			"GEOM",
			"FIRE"
		];

		if (EM_debug) then {
			private _a = createVehicle ["Sign_Arrow_F", _posa, [], 0, "can_collide"];
			_a setPosASL _posa;

			private _b = createVehicle ["Sign_Arrow_F", _posb, [], 0, "can_collide"];
			_b setPosASL _posb;
		};

		_blocked = count _int4 != 0;
	} else {
		private _rpos = _poses select 0;
		private _mtw = AGLToASL (_climber modelToWorld [0, 2, 0]);

		_posa = [
			_rpos select 0,
			_rpos select 1,
			(_rpos select 2) + 0.5
		];

		_posb = [
			_mtw select 0,
			_mtw select 1,
			_posa select 2
		];

		private _int5 = lineIntersectsSurfaces [
			_posa,
			_posb,
			_climber,
			objNull,
			true,
			1,
			"GEOM",
			"FIRE"
		];

		if (EM_debug) then {
			private _a = createVehicle ["Sign_Arrow_F", _posa, [], 0, "can_collide"];
			_a setPosASL _posa;

			private _b = createVehicle ["Sign_Arrow_F", _posb, [], 0, "can_collide"];
			_b setPosASL _posb;
		};

		_blocked = count _int5 != 0;
	};
};

if (_pos isEqualTo [0, 0, 0]) exitWith {};

if (!_blocked) then {
	if !(_obstacle isKindOf "MAN" && {stance _climber in ["STAND", "PRONE"]}) then {
		//-- added A3C commands for rooftops / forced paths
		private _currentClimberPosASL = getPosASL _climber;
		private _refPos = ((_currentClimberPosASL getPos [-100, _mcDir + 180]) select [0, 2]) + [
			_currentClimberPosASL select 2
		];

		private _refDir = [
			_currentClimberPosASL,
			_refPos,
			_climber,
			objNull,
			true
		] call A3C_main_fnc_getSurfaceNormalAzimuth;

		_climber setDir _refDir;
		[_pos, _top, _topPos, _climber, _climbOnly] call A3C_ai_shared_fnc_ehmAction;
		_climber setVariable ["A3C_EM_ACTIVE", true, true];
	};
};

private _return = !_blocked;
_return