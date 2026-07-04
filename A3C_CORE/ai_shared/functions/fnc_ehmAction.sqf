// A3C_ai_shared_fnc_ehmAction

params ["_pos", "_top", "_topPos", "_climber", "_climbOnly"];

private _stance = stance _climber;
private _blockedStances = ["PRONE"];

private _babeEmVars = _climber getVariable "babe_em_vars";

if (
	(_babeEmVars select 0)
	|| {(damage _climber) > 0.85}
	|| {_stance in _blockedStances}
	|| {vehicle _climber != _climber}
) exitWith {};

if (_climber == player) then {
	_babeEmVars set [0, false];
	_babeEmVars set [1, false];
};

private _stepA = EM_heightsOn select 0;
private _stepB = EM_heightsOn select 1;

private _onA = EM_heightsOn select 1;
private _onB = EM_heightsOn select 2;

private _onHighA = EM_heightsOn select 2;
private _onHighB = EM_heightsOn select 3;

private _onHeroA = EM_heightsOn select 3;
private _onHeroB = EM_heightsOn select 4;

private _vaultA = EM_heightsOver select 0;
private _vaultB = EM_heightsOver select 1;

private _overA = EM_heightsOver select 1;
private _overB = EM_heightsOver select 2;

private _overHighA = EM_heightsOver select 2;
private _overHighB = EM_heightsOver select 3;

private _overHeroA = EM_heightsOver select 3;
private _overHeroB = EM_heightsOver select 4;

private _weightLimit1 = EM_weightlimits select 0;
private _weightLimit2 = EM_weightlimits select 1;
private _weightLimit3 = EM_weightlimits select 2;
private _jumpWeightLimit = EM_weightlimits select 3;

private _enableOver = EM_enable select 0;
private _enableOn = EM_enable select 1;

EM_default_animspeedcoef = getAnimSpeedCoef player; //-- can stay. if player is objNull, it will still return 1

private _animation = "";

private _staminaPenalty = 2;
_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

if (str _pos == "[0,0,0]") exitWith {
	if (
		isTouchingGround _climber
		&& {!(_babeEmVars select 0)}
		&& {getStamina _climber > 8}
		&& {isNil "_climbOnly"}
	) then {
		[_climber, _jumpWeightLimit] call babe_em_fnc_jump;
	};
};

private _height = ((_climber worldToModel (ASLToAGL _pos)) select 2) max 0;

private _over = false;

if (_top) then {
	switch (true) do {
		case (_height > _onHeroA && {_height <= _onHeroB} && {load _climber < _weightLimit3} && {_enableOn}): {
			_staminaPenalty = 10;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climbonHer_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climbonHer_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climbonHer_pst";
				};
			};
		};

		case (_height > _onHighA && {_height < _onHighB} && {load _climber < _weightLimit2} && {_enableOn}): {
			_staminaPenalty = 8;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climbonH_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climbonH_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climbonH_pst";
				};
			};
		};

		case (_height > _onA && {_height <= _onB} && {load _climber < _weightLimit1} && {_enableOn}): {
			_staminaPenalty = 6;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climbon_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climbon_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climbon_pst";
				};
			};
		};

		case (_height > _stepA && {_height <= _stepB}): {
			_staminaPenalty = 2;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_stepon_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_stepon_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_stepon_pst";
				};
			};
		};
	};
} else {
	switch (true) do {
		case (_height > _overHeroA && {_height <= _overHeroB} && {load _climber < _weightLimit3} && {_enableOver}): {
			_staminaPenalty = 10;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climboverHer_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climboverHer_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climboverHer_pst";
				};
			};
		};

		case (_height > _overHighA && {_height <= _overHighB} && {load _climber < _weightLimit2} && {_enableOver}): {
			_staminaPenalty = 8;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climboverH_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climboverH_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climboverH_pst";
				};
			};
		};

		case (_height > _overA && {_height < _overB} && {load _climber < _weightLimit1} && {_enableOver}): {
			_staminaPenalty = 6;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_climbover_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_climbover_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_climbover_pst";
				};
			};
		};

		case (_height > _vaultA && {_height <= _vaultB}): {
			_staminaPenalty = 4;
			_staminaPenalty = _staminaPenalty * 0.5 + _staminaPenalty * 0.5 * (load _climber);

			switch (currentWeapon _climber) do {
				case (""): {
					_animation = "babe_vaultover_ua";
				};
				case (primaryWeapon _climber): {
					_animation = "babe_vaultover_rfl";
				};
				case (handgunWeapon _climber): {
					_animation = "babe_vaultover_pst";
				};
			};
		};
	};

	_over = true;
};

if (_animation == "") exitWith {
	if (
		isTouchingGround _climber
		&& {!(_babeEmVars select 0)}
		&& {getStamina _climber > 8}
		&& {isNil "_climbOnly"}
	) then {
		[_climber, _jumpWeightLimit] call babe_em_fnc_jump;
	};
};

_babeEmVars = _climber getVariable "babe_em_vars";
_babeEmVars set [0, true];
_climber setVariable ["babe_em_vars", _babeEmVars];

[
	((name _climber) + "EH_em"),
	{animationState (_condpars select 0) == (_condpars select 1)},
	[_climber, _animation],
	"A3C_ai_shared_fnc_ehmExec",
	[_pos, _over, _climber],
	true,
	"A3C_ai_shared_fnc_ehmFinish",
	[_topPos, _over, _staminaPenalty, _climber],
	0
] call babe_core_fnc_addEH;

_climber setAnimSpeedCoef (1 - (load _climber) * 0.3);
_climber playMoveNow _animation;