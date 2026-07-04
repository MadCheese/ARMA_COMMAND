// A3C_ai_shared_fnc_ehmFinish

params ["_topPos", "_over", "_staminaPenalty", "_climber"];

[((name _climber) + "EH_em")] call babe_core_fnc_removeEH;
[((name _climber) + "EH_em_loop")] call babe_core_fnc_removeEH;

_climber setStamina ((getStamina _climber) - _staminaPenalty);

private _helper = _climber getVariable "A3C_EM_helper";

if (_over) then {
	_climber setPosASL _topPos;
};

_helper setPos [0, 0, 0];

private _babeEmVars = _climber getVariable "babe_em_vars";
_babeEmVars set [0, false];
_babeEmVars set [1, false];

_climber setVariable ["babe_em_vars", _babeEmVars];
_climber setAnimSpeedCoef EM_default_animspeedcoef;

_climber spawn {
	waitUntil {
		isTouchingGround _this
		&& {!("babe" in animationState _this)}
	};

	_this setVariable ["A3C_EM_ACTIVE", nil, true];
};

if (_climber == player) then {
	EM_busy = false;
	EM_climbing = false;
};