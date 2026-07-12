// MCSS_fnc_lineOfSightSimple
// Observer does not need FOV on object; this is a simple direct check for lineIntersects.

private _a = _this select 0;
private _b = _this select 1;

private _ign1 = if (_a isEqualType []) then {
	objNull
} else {
	_a
};

private _ign2 = if ((count _this) > 2) then {
	_this select 2
} else {
	objNull
};

private _resetASL = if ((count _this) > 3) then {
	_this select 3
} else {
	true
};

private _return = false;

private _aslPos1 = if (_a isEqualType []) then {
	if (_resetASL) then {
		ATLtoASL _a
	} else {
		_a
	}
} else {
	if ((vehicle _a) == _a) then {
		eyePos _a
	} else {
		[
			(getPosASL (vehicle _a)) select 0,
			(getPosASL (vehicle _a)) select 1,
			((getPosASL (vehicle _a)) select 2) + ((((boundingBoxReal (vehicle _a)) select 1) select 2) + 0.1)
		]
	}
};

private _aslPos2 = if (_b isEqualType []) then {
	if (_resetASL) then {
		ATLtoASL _b
	} else {
		_b
	}
} else {
	if ((vehicle _b) == _b) then {
		eyePos _b
	} else {
		[
			(getPosASL (vehicle _b)) select 0,
			(getPosASL (vehicle _b)) select 1,
			// Preserved original behavior: Z base uses vehicle _a, not vehicle _b.
			((getPosASL (vehicle _a)) select 2) + ((((boundingBoxReal (vehicle _b)) select 1) select 2) + 0.1)
		]
	}
};

// Preserved only as local equivalents of original unused calculations.
private _refObj1 = if (_a isEqualType []) then {
	objNull
} else {
	vehicle _a
};

private _refObj2 = if (_b isEqualType []) then {
	objNull
} else {
	vehicle _b
};

if (
	(lineIntersects [_aslPos1, _aslPos2, _ign1, _ign2]) ||
	{ terrainIntersectASL [_aslPos1, _aslPos2] }
) then {
	_return = false;
} else {
	_return = true;
};

_return