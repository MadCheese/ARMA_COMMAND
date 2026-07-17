// A3C_ui_shared_fnc_addDownkey

/*
	Adds a key to the shared collection of currently held keys.

	DIK 56—the left Alt key—is intentionally excluded to prevent it from
	remaining in A3C_UI_DOWNKEYS after radial-menu interaction.
*/
params [
	["_key", -1, [0]]
];

if (_key < 0 || {_key == 56}) exitWith {};

A3C_UI_DOWNKEYS pushBackUnique _key;