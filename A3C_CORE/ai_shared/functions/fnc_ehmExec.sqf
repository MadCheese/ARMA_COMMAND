// A3C_ai_shared_fnc_ehmExec

params ["_pos", "_over", "_climber", "_animClip"];

[
	((name _climber) + "EH_em_loop"),
	{((_condpars select 0) getVariable "babe_em_vars") select 0},
	[_climber],
	{(_pars select 0) setVelocity [0, 0, 0]}, //-- #UNCLEAR what is _pars??
	[_climber],
	false,
	{},
	[],
	0
] call babe_core_fnc_addEH;

private _helper = _climber getVariable "A3C_EM_helper";

if (!isPlayer _climber) then {
	_helper = "babe_helper" createVehicleLocal [0, 0, 0];

	[_climber, _helper] spawn {
		params ["_climber", "_helper"];

		sleep 4;

		deleteVehicle _helper;
		_climber setVariable ["A3C_EM_helper", nil, true];
	};
};

_helper setPosASL _pos;
_helper setDir (getDir _climber);

private _posWT = _climber worldToModel (ASLToAGL _pos);

if (_over) then {
	_climber setPosASL (AGLToASL (_climber modelToWorld [
		_posWT select 0,
		_posWT select 1,
		(_posWT select 2) + 0.1
	]));
} else {
	_climber setPosASL (AGLToASL (_climber modelToWorld [
		_posWT select 0,
		(_posWT select 1) + 0.1,
		(_posWT select 2) + 0.1
	]));
};