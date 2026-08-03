#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_openMenu

disableSerialization;

params [
	"_gp",
	"_wpiC",
	"_mode",
	"_a3c_dsp",
	"_ctrlPosWPM"
];

// These legacy local names are intentionally retained because
// A3C_ui_mapOverlay_fnc_HCWP_addActions may inherit caller-local state through call.
private ["_act", "_wpA", "_wpMenu"];

private _wpiA = -1;
private _lbWpType = 0;
private _casTypeCurrent = 0; // Has to be fetched in advance.
private _flexLBCAS = 3;

private _leader = leader _gp;

if (isPlayer _leader && {player != _leader}) exitWith {
	systemChat format [
		"A3C: This waypoint is owned by player %1, no editing possible",
		name _leader
	];
};

if ([_gp, _wpiC] in A3C_BLACKLIST_WAYPOINT_EDIT) exitWith {
	systemChat "A3C: It is too late to cancel this action - wait for completion";
};

private _display = findDisplay _a3c_dsp;
private _wpMenuCtrlsGroup =
	_display displayCtrl IDC_MAP_HCWP_Parent;

_wpMenuCtrlsGroup ctrlShow true;

A3C_HC_ACTIVEGROUP = _gp;
A3C_HC_ACTIVE_IND = _wpiC;

private _wp = [
	_gp,
	_wpiC
];

private _leaderVic = vehicle _leader;

A3C_HC_ACTIVE_PRE_COND_MODE = "ARRIVAL";
A3C_HC_ACTIVE_PRE_COND_VAL = 0;
A3C_HC_ACTIVE_POST_COND_MODE = "NONE";
A3C_HC_ACTIVE_POST_COND_VAL = "NONE";

A3C_HC_ACTIVE_FORM_PRE = "LINE";
A3C_HC_ACTIVE_FORM_POST = "LINE";

A3C_HC_EDIT_ACTION = "MOVE";
A3C_HC_EDIT_TYPE = "MOVE";

A3C_HC_PREVENT_POLY = false;

private _header3Text = "COMPLETION";
private _preCondModeCtrl =
	_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Type;

private _lbV2 = 0;
private _lbV3 = 0;
private _lbV4 = 2;
private _lbV5 = 9;
private _lbV6 = 6;
private _lbVSpeed = 0;

private _lbArray2 = [];
private _lbArray4 = [
	"30SEK",
	"60SEK",
	"90SEK",
	"2MIN",
	"3MIN",
	"4MIN"
];

private _actionScript = "";
private _condition = "true";
private _wpHasPostCondition = false;
private _wpHasSubSelection = false;
private _isLimitedWP = false;

// Default: hide the precondition value, action group, and extra selections.
{
	(
		_display displayCtrl _x
	) ctrlShow false;
} forEach [
	IDC_MAP_HCWP_Condition_Pre_Mode,
	IDC_MAP_HCWP_Action_Parent_MAIN,
	IDC_MAP_HCWP_Action_Parent_ADD
];

private _formationEntries = [
	"COLUMN",
	"STAG. COL.",
	"WEDGE",
	"ECH LEFT",
	"ECH RIGHT",
	"VEE",
	"LINE",
	"FILE",
	"DIAMOND",
	"NO CHANGE"
];

{
	private _control = _display displayCtrl _x;

	lbClear _control;

	{
		[
			_control,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach _formationEntries;
} forEach [
	IDC_MAP_HCWP_Formation_Combo,
	IDC_MAP_HCWP_Action_Formation_Combo
];

// Retained for dynamic caller-scope compatibility with legacy menu helpers.
private _waypoints = waypoints _gp;

A3C_HC_ACTIVE_WPOS = waypointPosition _wp;
A3C_HC_ACTIVE_WPOS set [2, 0];

_condition = if (
	waypointType _wp == "SCRIPTED"
	&& {!("railed" in (waypointScript _wp))}
) then {
	private _parameters = waypointScript _wp;

	_parameters = _parameters splitString " ";

	if (count _parameters > 1) then {
		_parameters deleteAt 0;

		_parameters params [
			"_uidAndPreCondition",
			"_postCondition"
		];

		_uidAndPreCondition = _uidAndPreCondition splitString "";
		_uidAndPreCondition deleteAt (
			(count _uidAndPreCondition) - 1
		);
		_uidAndPreCondition set [
			count _uidAndPreCondition,
			"]"
		];
		_uidAndPreCondition = _uidAndPreCondition joinString "";
		_uidAndPreCondition = call compile _uidAndPreCondition;

		if (!isNil "_postCondition") then {
			_postCondition = _postCondition splitString "";
			_postCondition deleteAt (
				(count _postCondition) - 1
			);
			_postCondition = _postCondition joinString "";
			_postCondition = call compile _postCondition;
		};

		_uidAndPreCondition params [
			"_preConditionType",
			"_preConditionMode"
		];

		// Only the precondition is required here.
		_parameters = _preConditionMode;

		if ((_parameters select 0) == "GOCODE") then {
			_parameters = [
				_parameters select 1,
				side _gp
			] call A3C_main_fnc_getGoCodeActivationVariableName;
		} else {
			_parameters = str _parameters;
		};
	} else {
		// Preserved legacy no-op comparison. This appears intended to be an assignment.
		_parameters == ["ARRIVAL", ""];
	};

	_parameters
} else {
	(waypointStatements _wp) select 0
};

private _wpType = waypointType _wp;

_actionScript = switch (true) do {
	case (_wpType == "SCRIPTED"): {
		waypointScript _wp
	};

	case (_wpType == "SAD"): {
		"SEARCH / DESTROY"
	};

	case (_wpType in ["CYCLE", "LOITER"]): {
		_wpType
	};

	default {
		(waypointStatements _wp) select 1
	};
};

if (_wpType != "SCRIPTED") then {
	private _statementParts = _actionScript splitString ";";

	{
		if (
			"A3C_ai_highCommand_fnc_completeWaypoint" in _x
		) then {
			_statementParts = _statementParts - [_x];
		};
	} forEach _statementParts;

	_actionScript = _statementParts joinString ";";
};

private _form = waypointFormation _wp;

_lbVSpeed = switch (waypointSpeed _wp) do {
	case "UNCHANGED": {0};
	case "LIMITED": {1};
	case "NORMAL": {2};
	case "FULL": {3};
	default {"UNCHANGED"};
};

// Legacy hardcoded control ID: waypoint type label.
(
	_display displayCtrl 709120
) ctrlSetText _wpType;

// Precondition parsing.
if (["GOCODE", _condition] call BIS_fnc_inString) then {
	_lbArray2 = [
		"A",
		"B",
		"C",
		"D"
	];

	A3C_HC_ACTIVE_PRE_COND_MODE = "GOCODE";

	//~~ put all these instring things in function
	private _goCodes = [
		"A",
		"B",
		"C",
		"D"
	];

	private _goCodeIndex = _goCodes findIf {
		private _activationVariableName = [
			_x,
			side _gp
		] call A3C_main_fnc_getGoCodeActivationVariableName;

		[
			_activationVariableName,
			_condition
		] call BIS_fnc_inString
	};

	if (_goCodeIndex > -1) then {
		A3C_HC_ACTIVE_PRE_COND_VAL = _goCodes select _goCodeIndex;
		_lbV2 = _goCodeIndex;
	};
} else {
	if (["TIMEOUT", _condition] call BIS_fnc_inString) then {
		private _timeout = if (_wpType == "SCRIPTED") then {
			(call compile _condition) select 1
		} else {
			(waypointTimeout _wp) select 1
		};

		A3C_HC_ACTIVE_PRE_COND_MODE = "TIMEOUT";

		_lbArray2 = [
			"30SEK",
			"60SEK",
			"90SEK",
			"2MIN",
			"3MIN",
			"4MIN"
		];

		if (_timeout == 30) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 30;
			_lbV2 = 0;
		};

		if (_timeout == 60) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 60;
			_lbV2 = 1;
		};

		if (_timeout == 90) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 90;
			_lbV2 = 2;
		};

		if (_timeout == 120) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 120;
			_lbV2 = 3;
		};

		if (_timeout == 180) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 180;
			_lbV2 = 4;
		};

		if (_timeout == 240) then {
			A3C_HC_ACTIVE_PRE_COND_VAL = 240;
			_lbV2 = 5;
		};
	} else {
		if (["DAYTIME", _condition] call BIS_fnc_inString) then {
			private _conditionParts = "";

			if (_wpType == "SCRIPTED") then {
				_conditionParts =
					(_condition splitString "[],") select 1;
				_conditionParts = call compile _conditionParts;
				_conditionParts = _conditionParts splitString ":";
				_conditionParts = ["_placeholder"] + _conditionParts;
			} else {
				_conditionParts =
					_condition splitString " [],()&=";

				// Remove unnecessary added true conditions.
				while {
					(_conditionParts select 1) == "true"
				} do {
					_conditionParts deleteAt 1;
				};
			};

			A3C_HC_ACTIVE_PRE_COND_MODE = "DAYTIME";

			_conditionParts params [
				"_placeholder",
				"_wpYear",
				"_wpMonth",
				"_wpDay",
				"_wpHour",
				"_wpMinute"
			];

			if (count _wpHour == 1) then {
				_wpHour = [
					parseNumber _wpHour
				] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp;
			};

			if (count _wpMinute == 1) then {
				_wpMinute = [
					parseNumber _wpMinute
				] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp;
			};

			private _hour = date select 3;
			private _minute = date select 4;

			_minute = if (
				((round (_minute * 0.1)) * 10) < _minute
			) then {
				(floor (_minute * 0.1)) * 10
			} else {
				(ceil (_minute * 0.1)) * 10
			};

			private _wpTimeString =
				_wpHour + ":" + _wpMinute;

			_lbV2 = 2;
			_lbArray2 = [];

			A3C_HC_ACTIVE_PRE_COND_VAL = format [
				"%1:%2:%3:%4:%5",
				_wpYear,
				_wpMonth,
				_wpDay,
				_wpHour,
				_wpMinute
			];

			for "_i" from 1 to 7 do {
				if (_minute >= 60) then {
					_hour = _hour + 1;

					if (_hour >= 24) then {
						_hour = 0;
					};

					_minute = 0;
				};

				private _timeString = format [
					"%1:%2",
					[_hour] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp,
					[_minute] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp
				];

				_lbArray2 pushBack _timeString;

				if (_wpTimeString == _timeString) then {
					_lbV2 = _i - 1;
				};

				_minute = _minute + 5;
			};
		};
	};
};

// Waypoint executables.
if (_wpType == "SCRIPTED") then {
	// Remove precondition arguments from the script string.
	private _scriptParts = _actionScript splitString ",";

	for "_i" from 1 to 2 do {
		_scriptParts deleteAt 1;
	};

	_actionScript = _scriptParts joinString ",";
};

switch (true) do {
	case (["CLEARBUILDING", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "CLEAR BUILDING";
		_isLimitedWP = true;
	};

	case (
		["wpScript_groupGetInVehicle", _actionScript]
			call BIS_fnc_inString
	): {
		A3C_HC_EDIT_ACTION = "GET IN (SYNC)";
		_isLimitedWP = true;
	};

	case (
		["wpScript_LoadGroupInVehicle", _actionScript]
			call BIS_fnc_inString
	): {
		A3C_HC_EDIT_ACTION = "LOAD GROUP (SYNC)";
		_isLimitedWP = true;
	};

	case (
		["wpScript_LoadVehicleInVehicle", _actionScript]
			call BIS_fnc_inString
	): {
		A3C_HC_EDIT_ACTION = "LOAD VIC (SYNC)";
		_isLimitedWP = true;
	};

	case (
		["wpScript_groupGetVehicleInVehicle", _actionScript]
			call BIS_fnc_inString
	): {
		A3C_HC_EDIT_ACTION = "BOARD VIC (SYNC)";
		_isLimitedWP = true;
	};

	case (["SEARCH /", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "SEARCH / DESTROY";
	};

	case (["CYCLE", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "CYCLE";
	};

	case (["LOITER", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "LOITER";
		_wpHasSubSelection = true;
	};

	case (["SUPPRESSION", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "SUPPRESSION";
		A3C_HC_PREVENT_POLY = true;
		_wpHasPostCondition = true;
	};

	case (["AMBUSH", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "AMBUSH";
		A3C_HC_PREVENT_POLY = true;
		_wpHasPostCondition = true;
	};

	case (["HELI_OVERWATCH", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "HELI OVERWATCH";
		_wpHasSubSelection = true;
		_wpHasPostCondition = true;
	};

	case (["AssembleWeapon", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "ASSEMBLE WEAPON";
		A3C_HC_PREVENT_POLY = true;
		_wpHasPostCondition = true;
	};

	case (["land", _actionScript] call BIS_fnc_inString): {
		if ("railed" in _actionScript) then {
			_isLimitedWP = true;
			A3C_HC_EDIT_ACTION = "PRECISION LANDING";
		} else {
			if (["COMBAT", _actionScript] call BIS_fnc_inString) then {
				A3C_HC_EDIT_ACTION = "COMBATLANDING";
				_wpHasPostCondition = true;
			} else {
				A3C_HC_EDIT_ACTION = "FULL LANDING";
			};
		};
	};

	case (["RAPPELL", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "RAPPELL";
	};

	case (["TR_Unload", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "TRANSPORT UNLOAD";
	};

	case (["SLING LOAD HOOK", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "SLING LOAD";
	};

	case (["ASSEMBLE UAV", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "ASSEMBLE UAV";
	};

	case (["plantExplosive", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "DEMOLITION";
	};

	case (["REPAIR", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "REPAIR";
	};

	case (["ASSEMBLE_UAV", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "ASSEMBLE UAV";
	};

	case (["SLING LOAD UNHOOK", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "SLING DROP";
	};

	case (["PARADROP", _actionScript] call BIS_fnc_inString): {
		A3C_HC_EDIT_ACTION = "PARADROP";
	};

	case (["CASdistribute", _actionScript] call BIS_fnc_inString): {
		private _vehicleType = typeOf _leaderVic;

		A3C_HC_CASMODES = [
			_vehicleType
		] call A3C_main_fnc_getCASmodes;

		_flexLBCAS = 3;

		if (
			{
				((assignedVehicleRole _x) select 0) == "cargo"
			} count crew (vehicle _leader) > 0
			|| (count getVehicleCargo (vehicle _leader) > 0)
		) then {
			_flexLBCAS = 4;
		};

		_casTypeCurrent = parseNumber (
			(_actionScript splitString ",") select 4
		);

		A3C_HC_EDIT_ACTION = "CAS-STRIKE";
	};
};

private _commandLines = _actionScript splitString ";";

{
	private _commandLine = _x;

	if (["GOCODE", _commandLine] call BIS_fnc_inString) then {
		A3C_HC_ACTIVE_POST_COND_MODE = "GOCODE";
		_lbV3 = 1;
		_lbArray4 = [
			"A",
			"B",
			"C",
			"D"
		];

		if (
			["[""GOCODE"",""A""]", _commandLine]
				call BIS_fnc_inString
		) then {
			A3C_HC_ACTIVE_POST_COND_VAL = "A";
			_lbV4 = 0;
		};

		if (
			["[""GOCODE"",""B""]", _commandLine]
				call BIS_fnc_inString
		) then {
			A3C_HC_ACTIVE_POST_COND_VAL = "B";
			_lbV4 = 1;
		};

		if (
			["[""GOCODE"",""C""]", _commandLine]
				call BIS_fnc_inString
		) then {
			A3C_HC_ACTIVE_POST_COND_VAL = "C";
			_lbV4 = 2;
		};

		if (
			["[""GOCODE"",""D""]", _commandLine]
				call BIS_fnc_inString
		) then {
			A3C_HC_ACTIVE_POST_COND_VAL = "D";
			_lbV4 = 3;
		};
	} else {
		if (["TIME", _commandLine] call BIS_fnc_inString) then {
			if (["TIMEOUT", _commandLine] call BIS_fnc_inString) then {
				A3C_HC_ACTIVE_POST_COND_MODE = "TimeOut";

				_lbArray4 = [
					"30SEK",
					"60SEK",
					"90SEK",
					"2MIN",
					"3MIN",
					"4MIN"
				];

				if (
					["[""TIMEOUT"",30]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 30;
					_lbV4 = 0;
				};

				if (
					["[""TIMEOUT"",60]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 60;
					_lbV4 = 1;
				};

				if (
					["[""TIMEOUT"",90]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 90;
					_lbV4 = 2;
				};

				if (
					["[""TIMEOUT"",120]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 120;
					_lbV4 = 3;
				};

				if (
					["[""TIMEOUT"",180]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 180;
					_lbV4 = 4;
				};

				if (
					["[""TIMEOUT"",240]", _commandLine]
						call BIS_fnc_inString
				) then {
					A3C_HC_ACTIVE_POST_COND_VAL = 240;
					_lbV4 = 5;
				};
			} else {
				A3C_HC_ACTIVE_POST_COND_MODE = "DAYTIME";

				private _conditionParts = [];

				if (_wpType == "SCRIPTED") then {
					_conditionParts =
						_commandLine splitString """[],";
					_conditionParts = _conditionParts select 3;
					_conditionParts = _conditionParts splitString ":";
				} else {
					_conditionParts =
						_commandLine splitString """[],";

					{
						if ("_" in _x) exitWith {};

						_conditionParts = _conditionParts - [_x];
					} forEach _conditionParts;

					_conditionParts = _conditionParts select 3;
					_conditionParts = _conditionParts splitString ":";
				};

				_conditionParts params [
					"_wpYear",
					"_wpMonth",
					"_wpDay",
					"_wpHour",
					"_wpMinute"
				];

				if (count _wpHour == 1) then {
					_wpHour = [
						parseNumber _wpHour
					] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp;
				};

				if (count _wpMinute == 1) then {
					_wpMinute = [
						parseNumber _wpMinute
					] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp;
				};

				private _hour = date select 3;
				private _minute = date select 4;

				_minute = if (
					((round (_minute * 0.1)) * 10) < _minute
				) then {
					(floor (_minute * 0.1)) * 10
				} else {
					(ceil (_minute * 0.1)) * 10
				};

				_lbV3 = 2;
				_lbArray4 = [];

				private _wpTimeString =
					_wpHour + ":" + _wpMinute;

				A3C_HC_ACTIVE_POST_COND_VAL = format [
					"%1:%2:%3:%4:%5",
					_wpYear,
					_wpMonth,
					_wpDay,
					_wpHour,
					_wpMinute
				];

				for "_i" from 1 to 7 do {
					if (_minute >= 60) then {
						_hour = _hour + 1;

						if (_hour >= 24) then {
							_hour = 0;
						};

						_minute = 0;
					};

					private _timeString = format [
						"%1:%2",
						[_hour] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp,
						[_minute] call A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp
					];

					_lbArray4 pushBack _timeString;

					if (_wpTimeString == _timeString) then {
						_lbV4 = _i - 1;
					};

					_minute = _minute + 5;
				};
			};
		};
	};

	if !(
		["CASdistribute", _actionScript]
			call BIS_fnc_inString
	) then {
		{
			if ([_x, _commandLine] call BIS_fnc_inString) then {
				A3C_HC_ACTIVE_FORM_POST = _x;
				_lbV6 = _forEachIndex;
			};
		} forEach [
			"COLUMN",
			"STAG COLUMN",
			"WEDGE",
			"ECH LEFT",
			"ECH RIGHT",
			"VEE",
			"LINE",
			"FILE",
			"DIAMOND",
			"NO CHANGE"
		];
	};
} forEach _commandLines;

{
	if (_x == _form) exitWith {
		_lbV5 = _forEachIndex;
	};
} forEach [
	"COLUMN",
	"STAG COLUMN",
	"WEDGE",
	"ECH LEFT",
	"ECH RIGHT",
	"VEE",
	"LINE",
	"FILE",
	"DIAMOND",
	"NO CHANGE"
];

if (_wpHasPostCondition) then {
	(
		_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN
	) ctrlShow true;
};

if (_isLimitedWP) then {
	private _actionCombo =
		_display displayCtrl IDC_MAP_HCWP_Type_Action;

	lbClear _actionCombo;

	[
		_actionCombo,
		A3C_HC_EDIT_ACTION
	] call A3C_ui_shared_fnc_addLbEntry;

	[
		_actionCombo,
		0,
		true
	] call A3C_ui_shared_fnc_lbSetCurSel;
} else {
	[] call A3C_ui_mapOverlay_fnc_HCWP_addActions;
};

// Reacquire after the legacy helper in case it changed the active display.
_display = findDisplay _a3c_dsp;

// Header: group name and waypoint index.
(
	_display displayCtrl IDC_MAP_HCWP_GROUPNAME_TXT
) ctrlSetText format [
	"%1 - [%2]",
	toUpper groupId _gp,
	_wpiC
];

private _speedCombo =
	_display displayCtrl IDC_MAP_HCWP_Speed_Combo;

lbClear _speedCombo;

if !(
	A3C_HC_EDIT_ACTION in [
		"CLEAR BUILDING",
		"CAS-STRIKE"
	]
) then {
	{
		lbClear _x;
	} forEach (
		[
			"map_hcwp_conditionCombos_clearable"
		] call FUNC(ctrlGroup)
	);
};

{
	[
		_speedCombo,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;
} forEach [
	"UNCHANGED",
	"LIMITED",
	"NORMAL",
	"FULL"
];

[
	_speedCombo,
	_lbVSpeed,
	true
] call A3C_ui_shared_fnc_lbSetCurSel;

private _referencePosition = ctrlPosition (
	_display displayCtrl IDC_MAP_HCWP_Formation_Combo
);

private _referenceHeight = _referencePosition select 3;
private _referenceY =
	(_referencePosition select 1) + _referenceHeight;

// Adjust type/action and precondition/CAS boxes.
private _firstControlId = if (
	A3C_HC_EDIT_ACTION == "CAS-STRIKE"
) then {
	IDC_MAP_HCWP_Type_Parent
} else {
	IDC_MAP_HCWP_Completion_Parent
};

private _secondControlId = if (
	A3C_HC_EDIT_ACTION == "CAS-STRIKE"
) then {
	IDC_MAP_HCWP_Completion_Parent
} else {
	IDC_MAP_HCWP_Type_Parent
};

private _layoutControl =
	_display displayCtrl _firstControlId;

private _layoutPosition = +ctrlPosition _layoutControl;
_layoutPosition set [1, _referenceY];
_layoutControl ctrlSetPosition _layoutPosition;
_layoutControl ctrlCommit 0;

_referenceY = _referenceY + (_layoutPosition select 3);

_layoutControl = _display displayCtrl _secondControlId;
_layoutPosition = +ctrlPosition _layoutControl;
_layoutPosition set [1, _referenceY];
_layoutControl ctrlSetPosition _layoutPosition;
_layoutControl ctrlCommit 0;

if (_wpHasSubSelection) then {
	private _additionalActionParent =
		_display displayCtrl IDC_MAP_HCWP_Action_Parent_ADD;

	private _additionalActionPosition =
		ctrlPosition _additionalActionParent;

	_referencePosition = ctrlPosition (
		_display displayCtrl IDC_MAP_HCWP_Type_Parent
	);

	_referenceHeight = _referencePosition select 3;
	_referenceY =
		(_referencePosition select 1) + _referenceHeight;

	_additionalActionPosition set [1, _referenceY];
	_additionalActionParent ctrlSetPosition _additionalActionPosition;
	_additionalActionParent ctrlCommit 0;
	_additionalActionParent ctrlShow true;

	private _subSelectionText1 =
		_display displayCtrl IDC_MAP_HCWP_Action_Add_Formation_TXT;
	private _subSelectionText2 =
		_display displayCtrl IDC_MAP_HCWP_Action_Add_Completion_TXT;
	private _subSelectionCombo1 =
		_display displayCtrl IDC_MAP_HCWP_Action_Add_Formation_Combo;
	private _subSelectionCombo2 =
		_display displayCtrl IDC_MAP_HCWP_Action_Add_Completion_Combo;

	private _subSelectionIndex1 = 0;
	private _subSelectionIndex2 = 0;
	private _subSelectionLabel1 = "";
	private _subSelectionLabel2 = "";
	private _subSelectionValues1 = [];
	private _subSelectionValues2 = [];

	switch (A3C_HC_EDIT_ACTION) do {
		case "LOITER": {
			_subSelectionLabel1 = "LOITER DIRECTION";
			_subSelectionLabel2 = "LOITER RADIUS";
			_subSelectionValues1 = [
				"CLOCKWISE",
				"CNTR CLOCKWISE"
			];
			_subSelectionValues2 = [
				"100",
				"500",
				"1000",
				"2000"
			];

			A3C_HC_EDIT_COMBOSUBVAL_1 =
				waypointLoiterType _wp;
			A3C_HC_EDIT_COMBOSUBVAL_2 =
				waypointLoiterRadius _wp;

			_subSelectionIndex1 = switch (
				A3C_HC_EDIT_COMBOSUBVAL_1
			) do {
				case "CIRCLE": {0};
				case "CIRCLE_L": {1};
			};

			_subSelectionIndex2 = switch (
				A3C_HC_EDIT_COMBOSUBVAL_2
			) do {
				case 100: {0};
				case 500: {1};
				case 1000: {2};
				case 2000: {3};
			};
		};

		case "HELI OVERWATCH": {
			_subSelectionLabel1 = "HOVER HEIGHT";
			_subSelectionLabel2 = "ORIENTATION";
			_subSelectionValues1 = [
				"100",
				"200",
				"500",
				"1000"
			];
			_subSelectionValues2 = [
				"NORTH",
				"NORTH-EAST",
				"EAST",
				"SOUTH-EAST",
				"SOUTH",
				"SOUTH-WEST",
				"WEST",
				"NORTH-WEST"
			];

			private _scriptData =
				(waypointScript [_gp, _wpiC])
					splitString "[,]";

			private _heightData = _scriptData select 7;
			private _orientationData = _scriptData select 6;

			{
				if (_x == _heightData) exitWith {
					_subSelectionIndex1 = _forEachIndex;
					A3C_HC_EDIT_COMBOSUBVAL_1 = parseNumber _x;
				};
			} forEach _subSelectionValues1;

			_subSelectionIndex2 = switch (_orientationData) do {
				case "0": {0};
				case "45": {1};
				case "90": {2};
				case "135": {3};
				case "180": {4};
				case "225": {5};
				case "270": {6};
				case "315": {7};
			};

			A3C_HC_EDIT_COMBOSUBVAL_2 =
				parseNumber _orientationData;
		};
	};

	_subSelectionText1 ctrlSetText _subSelectionLabel1;
	_subSelectionText2 ctrlSetText _subSelectionLabel2;

	lbClear _subSelectionCombo1;

	{
		[
			_subSelectionCombo1,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach _subSelectionValues1;

	[
		_subSelectionCombo1,
		_subSelectionIndex1,
		true
	] call A3C_ui_shared_fnc_lbSetCurSel;

	lbClear _subSelectionCombo2;

	{
		[
			_subSelectionCombo2,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;
	} forEach _subSelectionValues2;

	[
		_subSelectionCombo2,
		_subSelectionIndex2,
		true
	] call A3C_ui_shared_fnc_lbSetCurSel;
};

// Adjust postcondition controls.
if (_wpHasPostCondition) then {
	private _postConditionReferenceId = if (
		_wpHasSubSelection
	) then {
		IDC_MAP_HCWP_Action_Parent_ADD
	} else {
		IDC_MAP_HCWP_Type_Parent
	};

	_referencePosition = ctrlPosition (
		_display displayCtrl _postConditionReferenceId
	);

	_referenceHeight = _referencePosition select 3;
	_referenceY =
		(_referencePosition select 1) + _referenceHeight;

	private _postConditionParent =
		_display displayCtrl IDC_MAP_HCWP_Action_Parent_MAIN;

	private _postConditionPosition =
		ctrlPosition _postConditionParent;

	_postConditionPosition set [1, _referenceY];
	_postConditionParent ctrlSetPosition _postConditionPosition;
	_postConditionParent ctrlCommit 0;
};

// Adjust confirm/delete buttons.
private _buttonReferenceId = switch (true) do {
	case _wpHasPostCondition: {
		IDC_MAP_HCWP_Action_Parent_MAIN
	};

	case _wpHasSubSelection: {
		IDC_MAP_HCWP_Action_Parent_ADD
	};

	default {
		if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {
			IDC_MAP_HCWP_Type_Parent
		} else {
			IDC_MAP_HCWP_Completion_Parent
		}
	};
};

_referencePosition = ctrlPosition (
	_display displayCtrl _buttonReferenceId
);

_referenceHeight = _referencePosition select 3;
_referenceY =
	(_referencePosition select 1) + _referenceHeight;

{
	private _controlPosition = ctrlPosition _x;
	_controlPosition set [1, _referenceY];
	_x ctrlSetPosition _controlPosition;
	_x ctrlCommit 0;
} forEach (
	[
		"map_hcwp_macro_confirmAndCancel"
	] call FUNC(ctrlGroup)
);

// Apply labels and listbox values.
if (A3C_HC_EDIT_ACTION != "CAS-STRIKE") then {
	lbClear _preCondModeCtrl;

	{
		private _listboxText = if (_x == "GOCODE") then {
			"GO-CODE"
		} else {
			_x
		};

		[
			_preCondModeCtrl,
			_listboxText
		] call A3C_ui_shared_fnc_addLbEntry;

		if (_x == A3C_HC_ACTIVE_PRE_COND_MODE) then {
			[
				_preCondModeCtrl,
				_forEachIndex
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};
	} forEach [
		"ARRIVAL",
		"GOCODE",
		"TIMEOUT",
		"DAYTIME"
	];
};

private _fullWidth = (
	ctrlPosition (
		_display displayCtrl IDC_MAP_HCWP_GROUPNAME_BG
	)
) select 2;

_referencePosition = ctrlPosition _preCondModeCtrl;
_referencePosition params [
	"_referenceX",
	"_conditionReferenceY",
	"_referenceWidth",
	"_conditionReferenceHeight"
];

_conditionReferenceY =
	_conditionReferenceY + _conditionReferenceHeight;

if (A3C_HC_ACTIVE_PRE_COND_MODE != "ARRIVAL") then {
	private _preConditionValueControl =
		_display displayCtrl IDC_MAP_HCWP_Condition_Pre_Mode;

	{
		[
			_preConditionValueControl,
			_x
		] call A3C_ui_shared_fnc_addLbEntry;

		private _listboxValue = _x;

		if (A3C_HC_ACTIVE_PRE_COND_MODE == "TIMEOUT") then {
			_listboxValue = switch (_listboxValue) do {
				case "30SEK": {30};
				case "60SEK": {60};
				case "90SEK": {90};
				case "2MIN": {120};
				case "3MIN": {180};
				case "4MIN": {240};
			};
		};

		if (A3C_HC_ACTIVE_PRE_COND_MODE == "DAYTIME") then {
			//~~ Currently this uses the current date when reopening the UI.
			// Check whether this causes trouble across a date change.
			[
				_preConditionValueControl,
				_lbV2,
				true
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		if (_listboxValue == A3C_HC_ACTIVE_PRE_COND_VAL) then {
			[
				_preConditionValueControl,
				_forEachIndex
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};
	} forEach _lbArray2;

	_preConditionValueControl ctrlShow true;
	_referencePosition set [2, _fullWidth / 2];
} else {
	_referencePosition set [2, _fullWidth];
};

private _postConditionTypes = [
	"TIMEOUT",
	"GOCODE",
	"DAYTIME"
];

if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
	_postConditionTypes = ["None"] + _postConditionTypes;
};

private _postConditionTypeControl =
	_display displayCtrl IDC_MAP_HCWP_Condition_Post_Type;

lbClear _postConditionTypeControl;

{
	[
		_postConditionTypeControl,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;
} forEach _postConditionTypes;

_lbV3 = switch (
	toLower A3C_HC_ACTIVE_POST_COND_MODE
) do {
	case "none": {
		0
	};

	case "timeout": {
		if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
			1
		} else {
			0
		}
	};

	case "gocode": {
		if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
			2
		} else {
			1
		}
	};

	case "daytime": {
		if (A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
			3
		} else {
			2
		}
	};
};

[
	_postConditionTypeControl,
	_lbV3
] call A3C_ui_shared_fnc_lbSetCurSel;

private _postConditionValueControl =
	_display displayCtrl IDC_MAP_HCWP_Condition_Post_Mode;

lbClear _postConditionValueControl;

{
	[
		_postConditionValueControl,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;
} forEach _lbArray4;

_ctrlPosWPM = [
	_a3c_dsp,
	IDC_MAP_HCWP_Parent,
	_ctrlPosWPM
] call A3C_ui_mapOverlay_fnc_findCtrlSafePos;

_wpMenuCtrlsGroup ctrlSetPosition _ctrlPosWPM;
_wpMenuCtrlsGroup ctrlCommit 0;

[
	_postConditionValueControl,
	_lbV4
] call A3C_ui_shared_fnc_lbSetCurSel;

[
	_display displayCtrl IDC_MAP_HCWP_Formation_Combo,
	_lbV5
] call A3C_ui_shared_fnc_lbSetCurSel;

[
	_display displayCtrl IDC_MAP_HCWP_Action_Formation_Combo,
	_lbV6
] call A3C_ui_shared_fnc_lbSetCurSel;

(
	_display displayCtrl IDC_MAP_HCWP_Completion_Header_TXT
) ctrlSetText _header3Text;

// Waypoint behaviour.
private _behaviourCombo =
	_display displayCtrl IDC_MAP_HCWP_Behaviour_Combo;

lbClear _behaviourCombo;

{
	[
		_behaviourCombo,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;

	if (
		_x == waypointBehaviour [
			A3C_HC_ACTIVEGROUP,
			A3C_HC_ACTIVE_IND
		]
	) then {
		[
			_behaviourCombo,
			_forEachIndex
		] call A3C_ui_shared_fnc_lbSetCurSel;
	};
} forEach [
	"UNCHANGED",
	"CARELESS",
	"SAFE",
	"AWARE",
	"COMBAT",
	"STEALTH"
];

// Waypoint combat mode.
private _combatModeCombo =
	_display displayCtrl IDC_MAP_HCWP_CombatMode_Combo;

lbClear _combatModeCombo;

private _combatModeCodes = [
	"NO CHANGE",
	"BLUE",
	"GREEN",
	"WHITE",
	"YELLOW",
	"RED"
];

private _combatModeColors = [
	[0.5, 0.5, 0.5, 1],
	A3C_UI_COLOR_BLUE,
	[0, 1, 0, 1],
	[1, 1, 1, 1],
	A3C_UI_COLOR_YELLOW,
	A3C_UI_COLOR_RED
];

{
	private _combatModeCode =
		_combatModeCodes select _forEachIndex;

	[
		_combatModeCombo,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;

	if (
		_combatModeCode == waypointCombatMode [
			A3C_HC_ACTIVEGROUP,
			A3C_HC_ACTIVE_IND
		]
	) then {
		[
			_combatModeCombo,
			_forEachIndex
		] call A3C_ui_shared_fnc_lbSetCurSel;
	};

	_combatModeCombo lbSetColor [
		_forEachIndex,
		_combatModeColors select _forEachIndex
	];
} forEach [
	"NO CHANGE",
	"NEVER FIRE",
	"HOLD FIRE, DEFEND",
	"HOLD FIRE, ENGAGE",
	"OPEN FIRE",
	"FIRE & ENGAGE"
];

ctrlSetFocus _wpMenuCtrlsGroup;
