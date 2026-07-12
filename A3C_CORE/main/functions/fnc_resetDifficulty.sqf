// A3C_main_fnc_resetDifficulty
// Updates A3C difficulty state and marker opacity.
//-- #Unclear: marker code might be redundant as we no longer use markers?

A3C_DIFFICULTY = difficulty;
A3C_OPACITY = if (A3C_DIFFICULTY <= 1) then {
	1
} else {
	0
};

{
	_x setMarkerAlphaLocal A3C_OPACITY;
} forEach (A3C_MARKERS + A3C_HC_MARKERS);