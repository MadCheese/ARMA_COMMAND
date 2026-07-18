#include "..\script_component.hpp"

// A3C_Debug_fnc_hint

private _expression =
	_this;

if (
	!isNil "A3C_isHint"
	&& {A3C_isHint}
) then {
	A3C_isHint = false;

	sleep 0.5;
};

A3C_isHint = true;

while {A3C_isHint} do {
	hintSilent str (
		call _expression
	);

	sleep 0.1;
};