// A3C_ai_squad_fnc_initializeUnit
// Sets init values for new units.
// All units need A3C vars and a vehicleVarName.
// Adds Killed EH in case unit dies while HUD selector is active.

params [
	"_unit",
	["_mode", 1]
];

if (isNull _unit) exitWith {};

private _irType = switch (side _unit) do {
	case west: {
		"B_IR_Grenade"
	};

	case east: {
		"O_IR_Grenade"
	};

	default {
		"I_IR_Grenade"
	};
};

if (profileNamespace getVariable ["A3C_SKILL_VAR", false]) then {
	_unit setSkill 1;
};

private _vehicleVarName = vehicleVarName _unit;
private _playerUID = if (!isNull player) then {
	getPlayerUID player
} else {
	""
};

if (
	(_unit getVariable ["A3C_VVNI", []]) isEqualType 0 &&
	{ !([_playerUID, _vehicleVarName] call BIS_fnc_inString) }
) exitWith {};

if (_mode == 1) then {
	if (_vehicleVarName isEqualTo "") then {
		_vehicleVarName = format [
			"A3C_MEMBER_%1_%2",
			_playerUID,
			A3C_VARNAME_INDEX
		];

		_unit setVehicleVarName _vehicleVarName;
	};

	missionNamespace setVariable [_vehicleVarName, _unit];

	_unit setVariable ["A3C_FORMATION_INDEX", [_unit] call A3C_main_fnc_getUnitIndex, true];
	_unit setVariable ["A3C_VVNI", A3C_VARNAME_INDEX, true];

	A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;
};

if !((_unit getVariable ["A3C_PLOT_TEMP", []]) isEqualTo []) exitWith {};
if !((_unit getVariable ["A3C_PLOT", []]) isEqualTo []) exitWith {};

_unit setVariable ["A3C_PEEL_ACTIVE", false, false];
_unit setVariable ["A3C_PLOT", [], true];
_unit setVariable ["A3C_PLOT_TEMP", [], true];
_unit setVariable ["A3C_CURRENTWAYPOINT_INDEX", 1, true];
_unit setVariable ["A3C_PLOT_ACTIVE", false, true];
_unit setVariable ["A3C_SYNC_WPINDEX", 0, true];
_unit setVariable ["A3C_SYNC_ITEMS", [], true];
_unit setVariable ["A3C_WP_LINES", [], true];
_unit setVariable ["A3C_SUPPRESSION_TARGET", [0, false, -1], true];
_unit setVariable ["A3C_UNIT_POLYS", [], true];
_unit setVariable ["A3C_UNIT_EXPLOSIVES", [], false];
_unit setVariable ["A3C_POLY_ACTIVE", [], true];
_unit setVariable ["A3C_STROBE", [], true];
_unit setVariable ["A3C_CLEARING", false, true];
_unit setVariable ["A3C_DEST", [], true];
_unit setVariable ["babe_em_vars", [false, false, true], true];
_unit setVariable ["A3C_EM_climbing", false, false];
_unit setVariable ["A3C_EM_default_animspeedcoef", getAnimSpeedCoef _unit, false];
_unit setVariable ["A3C_EM_helper", objNull, false];
_unit setVariable ["A3C_PAUSE_PLAN", false, false];
_unit setVariable ["A3C_HOLD", false, false];
_unit setVariable ["A3C_HOLD_COVER", false, false];

// Exclude team AI from AI-enhancing addons.
_unit setVariable ["NOAI", 1, false];
_unit setVariable ["asr_ai_exclude", true, true];
// _unit setVariable ["TCL_Disabled", true, true];
_unit setVariable ["Vcm_Disable", true, true];
_unit setVariable ["dangerAIEnabled", false, true];
_unit setVariable ["lambs_danger_dangerAIEnabled", false, true];

private _eventHandlers = _unit getVariable ["A3C_UNIT_EHs", []];

if (_eventHandlers isEqualTo [] && { _unit != player }) then {
	private _killedEh = _unit addEventHandler [
		"Killed",
		{
			params ["_body"];

			if !((_body getVariable ["A3C_HUD_DATA", []]) isEqualTo []) then {
				[_body] spawn A3C_UI_squadPlacement_fnc_removeUnitGhost;
			};

			private _eventHandlers = _body getVariable ["A3C_UNIT_EHs", []];

			{
				_body removeEventHandler [_x select 0, _x select 1];
			} forEach _eventHandlers;

			_body setVariable ["A3C_UNIT_EHs", []];
		}
	];

	_unit setVariable [
		"A3C_UNIT_EHs",
		[["Killed", _killedEh]]
	];
};

// Add one side-correct IR grenade if the unit has no NVG-marker magazine.
private _hasNVGMarkerMagazine = (magazines _unit findIf {
	private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
	private _nvgMarkers = "true" configClasses (configFile >> "CfgAmmo" >> _ammo >> "NVGMarkers");

	!(_nvgMarkers isEqualTo [])
}) >= 0;

if (!_hasNVGMarkerMagazine) then {
	_unit addMagazine _irType;
};