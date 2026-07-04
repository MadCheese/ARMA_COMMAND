// A3C_ai_shared_fnc_ehmFinishDrop

params ["_climber"];

[((name _climber) + "EH_em_drop")] call babe_core_fnc_removeEH;
[((name _climber) + "EH_em_loop")] call babe_core_fnc_removeEH;

babe_em_help setPos [0, 0, 0];

private _babeEmVars = _climber getVariable "babe_em_vars";
_babeEmVars set [0, false];
_babeEmVars set [1, false];

_climber setVariable ["babe_em_vars", _babeEmVars];

_climber spawn {
	waitUntil {
		isTouchingGround _this
		&& {!("babe" in animationState _this)}
	};

	_this setVariable ["A3C_EM_ACTIVE", nil, true];
	_this setVelocity [0, 1, 0];
};