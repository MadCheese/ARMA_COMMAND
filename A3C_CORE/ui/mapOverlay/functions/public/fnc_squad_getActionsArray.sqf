// A3C_ui_mapOverlay_fnc_squad_getActionsArray

params ["_units"];

private _actions = ["NONE"];

if (
	{
		isNull objectParent _x
	} count _units > 0
) then {
	{
		_actions pushBack _x;
	} forEach [
		"GRENADE",
		"SUPPRESSION"
	];
};

private _staticData = [
	_units,
	"PLANNING"
] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons;

if (count _staticData > 0) then {
	_actions pushBackUnique "STATIC";
};

if (
	{
		isNull objectParent _x
			&& {backpack _x == ""}
	} count _units >= 2
) then {
	_actions pushBackUnique "STATIC";
};

//~~ CURRENTLY ONLY SINGLE SELECTIONS. WHY???
if (count _units == 1) then {
	private _unit = _units select 0;

	private _hasExplosiveMagazine = {
		getText (
			configFile
				>> "CfgMagazines"
				>> _x
				>> "nameSound"
		) in [
			"satchelcharge",
			"mine"
		]
	} count magazines _unit > 0;

	if (
		_hasExplosiveMagazine
			&& {isNull objectParent _unit}
	) then {
		_actions pushBack "CTRL_DET";
	};
};

if (
	{
		!isNull objectParent _x
			&& {_x == driver (vehicle _x)}
	} count _units > 0
) then {
	{
		_actions pushBack _x;
	} forEach [
		"CARGO_IN",
		"CARGO_OUT"
	];
};

_actions