#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_onConfirmButtonMulti

disableSerialization;

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {};

private _selection = +(
	_display getVariable [
		"A3C_HCWP_MULTI_SELECTION",
		[]
	]
);

if (count _selection <= 1) exitWith {};

private _groups = [];

{
	_groups pushBackUnique (_x select 0);
} forEach _selection;

if (
	_selection findIf {
		_x in A3C_BLACKLIST_WAYPOINT_EDIT
	} > -1
) exitWith {
	hint "At least one selected waypoint can no longer be edited";
};

if (
	_groups findIf {
		private _group = _x;

		({
			isPlayer _x
		} count (units _group)) > 0
	} > -1
) exitWith {
	hint "Player detected in selected groups - action prohibited";
};

private _fncSelectedText = {
	params ["_idc"];

	private _control =
		_display displayCtrl _idc;

	private _index = lbCurSel _control;

	if (_index < 0) exitWith {
		""
	};

	_control lbText _index
};

private _fncTimeoutValue = {
	params ["_text"];

	switch (_text) do {
		case "30SEK": {30};
		case "60SEK": {60};
		case "90SEK": {90};
		case "2MIN": {120};
		case "3MIN": {180};
		case "4MIN": {240};
		default {90};
	}
};

private _fncDaytimeValue = {
	params ["_text"];

	date params [
		"_year",
		"_month",
		"_day"
	];

	private _parts =
		_text splitString ":";

	format [
		"%1:%2:%3:%4:%5",
		_year,
		_month,
		_day,
		_parts select 0,
		_parts select 1
	]
};

private _behaviour = [
	IDC_MAP_HCWP_Behaviour_Combo
] call _fncSelectedText;

private _combatModeText = [
	IDC_MAP_HCWP_CombatMode_Combo
] call _fncSelectedText;

private _speed = [
	IDC_MAP_HCWP_Speed_Combo
] call _fncSelectedText;

private _formation = [
	IDC_MAP_HCWP_Formation_Combo
] call _fncSelectedText;

private _completionType = toUpper (
	[
		IDC_MAP_HCWP_Condition_Pre_Type
	] call _fncSelectedText
);

private _completionValue = [
	IDC_MAP_HCWP_Condition_Pre_Mode
] call _fncSelectedText;

private _action = toUpper (
	[
		IDC_MAP_HCWP_Type_Action
	] call _fncSelectedText
);

private _combatMode = switch (
	_combatModeText
) do {
	case "NO CHANGE": {
		"NO CHANGE"
	};

	case "NEVER FIRE": {
		"BLUE"
	};

	case "HOLD FIRE, DEFEND": {
		"GREEN"
	};

	case "HOLD FIRE, ENGAGE": {
		"WHITE"
	};

	case "OPEN FIRE": {
		"YELLOW"
	};

	case "FIRE & ENGAGE": {
		"RED"
	};

	default {
		"KEEP CURRENT"
	};
};

if (_formation == "STAG. COL.") then {
	_formation = "STAG COLUMN";
};

if !(
	_action in [
		"NO CHANGE",
		"MOVE",
		"SEARCH / DESTROY",
		"TRANSPORT UNLOAD",
		"COMBAT LAND",
		"LAND"
	]
) exitWith {
	hint "Unsupported multi-waypoint type";
};

private _requestedPreCondition = switch (
	_completionType
) do {
	case "ARRIVAL": {
		[
			"ARRIVAL",
			0
		]
	};

	case "GO-CODE": {
		[
			"GOCODE",
			_completionValue
		]
	};

	case "TIMEOUT": {
		[
			"TIMEOUT",
			[
				_completionValue
			] call _fncTimeoutValue
		]
	};

	case "DAYTIME": {
		[
			"DAYTIME",
			[
				_completionValue
			] call _fncDaytimeValue
		]
	};

	default {
		[]
	};
};

private _postCondition = [
	"NONE",
	"NONE"
];

if (_action == "COMBAT LAND") then {
	private _postType = toUpper (
		[
			IDC_MAP_HCWP_Condition_Post_Type
		] call _fncSelectedText
	);

	private _postValue = [
		IDC_MAP_HCWP_Condition_Post_Mode
	] call _fncSelectedText;

	_postCondition = switch (_postType) do {
		case "TIMEOUT": {
			[
				"TIMEOUT",
				[
					_postValue
				] call _fncTimeoutValue
			]
		};

		case "DAYTIME": {
			[
				"DAYTIME",
				[
					_postValue
				] call _fncDaytimeValue
			]
		};

		default {
			[
				"GOCODE",
				_postValue
			]
		};
	};
};

private _fncScriptData = {
	params ["_waypoint"];

	private _script =
		waypointScript _waypoint;

	private _space =
		_script find " ";

	if (_space < 1) exitWith {
		[
			false,
			"",
			[]
		]
	};

	private _arguments = call compile (
		_script select [
			_space + 1
		]
	);

	if !(
		_arguments isEqualType []
		&& {count _arguments > 1}
		&& {(_arguments select 1) isEqualType []}
		&& {count (_arguments select 1) > 1}
	) exitWith {
		[
			false,
			"",
			[]
		]
	};

	[
		true,
		_script select [
			0,
			_space
		],
		_arguments
	]
};

private _needsScriptConditionAccess =
	(
		_requestedPreCondition isEqualTo []
		&& {_action != "NO CHANGE"}
	)
	|| {
		_requestedPreCondition isNotEqualTo []
		&& {_action == "NO CHANGE"}
	};

if (_needsScriptConditionAccess) then {
	private _unsupported =
		_selection findIf {
			waypointType _x == "SCRIPTED"
			&& {
				!(
					(
						[
							_x
						] call _fncScriptData
					) select 0
				)
			}
		};

	if (_unsupported > -1) exitWith {
		hint "A selected scripted waypoint does not expose an editable completion condition";
	};
};

private _fncPreConditionExpression = {
	params [
		"_group",
		"_data"
	];

	_data params [
		"_mode",
		"_value"
	];

	switch (toUpper _mode) do {
		case "GOCODE": {
			[
				_value,
				side _group
			] call A3C_main_fnc_getGoCodeActivationVariableName
		};

		case "TIMEOUT": {
			"true && (count ['TIMEOUT'] == 1)"
		};

		case "DAYTIME": {
			private _parts =
				_value splitString ":";

			format [
				"(([%1,%2,%3,%4,%5] call A3C_main_fnc_isDaytimeCompleted) && (count ['DAYTIME'] == 1))",
				parseNumber (_parts select 0),
				parseNumber (_parts select 1),
				parseNumber (_parts select 2),
				parseNumber (_parts select 3),
				parseNumber (_parts select 4)
			]
		};

		default {
			"true"
		};
	}
};

private _fncConditionStatement = {
	params [
		"_group",
		"_waypoint",
		"_data"
	];

	private _retained = [];

	{
		private _part = _x;

		private _compact = toLower (
			(_part splitString " ")
				joinString ""
		);

		if (
			_compact != ""
			&& {_compact != "true"}
			&& {
				!(
					[
						"TIMEOUT",
						_part
					] call BIS_fnc_inString
				)
			}
			&& {
				!(
					[
						"GOCODE",
						_part
					] call BIS_fnc_inString
				)
			}
			&& {
				!(
					[
						"DAYTIME",
						_part
					] call BIS_fnc_inString
				)
			}
		) then {
			_retained pushBack _part;
		};
	} forEach (
		(
			waypointStatements _waypoint
		) select 0 splitString "&&"
	);

	_retained pushBack (
		[
			_group,
			_data
		] call _fncPreConditionExpression
	);

	_retained joinString " && "
};

private _fncCleanStatements = {
	params ["_waypoint"];

	private _tokens = [
		"SUPPRESSION",
		"AMBUSH",
		"TR_Unload",
		"HELI_OVERWATCH",
		"REPAIR",
		"setUnitPos",
		"LAND",
		"ASSEMBLE",
		"CASdistribute",
		"SLING LOAD",
		"SLING DROP",
		"ASSEMBLE_UAV",
		"actionAssembleUAV",
		"plantExplosive"
	];

	private _retained = [];

	{
		private _statement = _x;

		private _remove =
			_tokens findIf {
				[
					_x,
					_statement
				] call BIS_fnc_inString
			} > -1;

		if (
			!_remove
			&& {
				count (
					_statement splitString " "
				) >= 2
			}
		) then {
			_retained pushBack _statement;
		};
	} forEach (
		(
			waypointStatements _waypoint
		) select 1 splitString ";"
	);

	_retained joinString "; "
};

private _fncRemovePolygon = {
	params [
		"_group",
		"_waypointIndex"
	];

	private _polygons =
		_group getVariable [
			"A3C_UNIT_POLYS",
			[]
		];

	private _index =
		_polygons findIf {
			((_x select 0) select 2)
				== _waypointIndex
		};

	if (_index > -1) then {
		private _polygon =
			_polygons select _index;

		private _reference =
			+A3C_SUPPRESSION_UNITS_AI;

		{
			[
				_x,
				_polygon
			] call A3C_ai_shared_fnc_polygonAreaRemove;
		} forEach units _group;

		_polygons deleteAt _index;

		if !(
			_reference
				isEqualTo A3C_SUPPRESSION_UNITS_AI
		) then {
			publicVariable
				"A3C_SUPPRESSION_UNITS_AI";
		};
	};

	_group setVariable [
		"A3C_UNIT_POLYS",
		_polygons,
		true
	];
};

private _fncSetScriptPreCondition = {
	params [
		"_waypoint",
		"_data"
	];

	private _scriptData = [
		_waypoint
	] call _fncScriptData;

	_scriptData params [
		"_valid",
		"_path",
		"_arguments"
	];

	if !(_valid) exitWith {};

	_arguments set [
		1,
		+_data
	];

	_waypoint setWaypointScript format [
		"%1 %2",
		_path,
		_arguments
	];
};

private _hasAnyChange =
	_behaviour != "KEEP CURRENT"
	|| {_combatMode != "KEEP CURRENT"}
	|| {_speed != "KEEP CURRENT"}
	|| {_formation != "KEEP CURRENT"}
	|| {_requestedPreCondition isNotEqualTo []}
	|| {_action != "NO CHANGE"};

{
	_x params [
		"_group",
		"_waypointIndex"
	];

	private _waypoint = [
		_group,
		_waypointIndex
	];

	private _preCondition = [];

	if (
		_action != "NO CHANGE"
		|| {_requestedPreCondition isNotEqualTo []}
	) then {
		_preCondition = if (
			_requestedPreCondition isEqualTo []
		) then {
			[
				_waypoint
			] call A3C_ui_mapOverlay_fnc_HCWP_getWaypointPreCondition
		} else {
			+_requestedPreCondition
		};
	};

	if (_action != "NO CHANGE") then {
		[
			_group,
			_waypointIndex
		] call _fncRemovePolygon;

		private _position =
			waypointPosition _waypoint;

		private _type = "MOVE";
		private _script = "";
		private _completionRadius = 0;

		switch (_action) do {
			case "SEARCH / DESTROY": {
				_type = "SAD";
			};

			case "TRANSPORT UNLOAD": {
				_type = "SCRIPTED";

				_script = format [
					"A3C_CORE\waypointScripts\wpScript_TR_Unload.sqf ['%1',%2,%3]",
					getPlayerUID player,
					_preCondition,
					[
						"NONE",
						"NONE"
					]
				];
			};

			case "COMBAT LAND": {
				_type = "SCRIPTED";

				_script = format [
					"A3C_CORE\waypointScripts\wpScript_Landing_Combat.sqf ['%1',%2,%3]",
					getPlayerUID player,
					_preCondition,
					_postCondition
				];
			};

			case "LAND": {
				private _vehicle =
					vehicle leader _group;

				private _runwayLanding =
					getNumber (
						configFile
							>> "CfgVehicles"
							>> typeOf _vehicle
							>> "landingSpeed"
					) > 10;

				if (
					_vehicle isKindOf "PLANE"
					&& {_runwayLanding}
				) then {
					private _airportData = [
						_position
					] call A3C_main_fnc_getNearestAirportData;

					_airportData params [
						"_airportID",
						"_airportName",
						"_airportTaxiIn"
					];

					_position = if (
						_airportID > -1
					) then {
						_airportTaxiIn
					} else {
						position _airportName
					};
				};

				_type = "SCRIPTED";

				_script = format [
					"A3C_CORE\waypointScripts\wpScript_Landing.sqf ['%1',%2,%3]",
					getPlayerUID player,
					_preCondition,
					[
						"NONE",
						"NONE"
					]
				];

				_completionRadius = 1000;
			};
		};

		private _condition = [
			_group,
			_waypoint,
			_preCondition
		] call _fncConditionStatement;

		private _statements = [
			_waypoint
		] call _fncCleanStatements;

		_waypoint setWaypointPosition _position;
		_waypoint setWaypointType _type;
		_waypoint setWaypointScript _script;

		_waypoint setWaypointStatements [
			_condition,
			_statements
		];

		_waypoint setWaypointCompletionRadius
			_completionRadius;

		private _timeout = if (
			_script == ""
			&& {
				(_preCondition select 0)
					== "TIMEOUT"
			}
		) then {
			private _value =
				_preCondition select 1;

			[
				_value,
				_value,
				_value
			]
		} else {
			[
				0,
				0,
				0
			]
		};

		_waypoint setWaypointTimeout _timeout;
	} else {
		if (
			_requestedPreCondition
				isNotEqualTo []
		) then {
			private _condition = [
				_group,
				_waypoint,
				_preCondition
			] call _fncConditionStatement;

			_waypoint setWaypointStatements [
				_condition,
				(
					waypointStatements _waypoint
				) select 1
			];

			if (
				waypointType _waypoint
					== "SCRIPTED"
			) then {
				[
					_waypoint,
					_preCondition
				] call _fncSetScriptPreCondition;

				_waypoint setWaypointTimeout [
					0,
					0,
					0
				];
			} else {
				private _timeout = if (
					(_preCondition select 0)
						== "TIMEOUT"
				) then {
					private _value =
						_preCondition select 1;

					[
						_value,
						_value,
						_value
					]
				} else {
					[
						0,
						0,
						0
					]
				};

				_waypoint setWaypointTimeout
					_timeout;
			};
		};
	};

	if (_behaviour != "KEEP CURRENT") then {
		[
			_waypoint,
			_behaviour
		] remoteExec [
			"setWaypointBehaviour",
			2
		];
	};

	if (_combatMode != "KEEP CURRENT") then {
		_waypoint setWaypointCombatMode
			_combatMode;
	};

	if (_speed != "KEEP CURRENT") then {
		_waypoint setWaypointSpeed _speed;
	};

	if (_formation != "KEEP CURRENT") then {
		_waypoint setWaypointFormation
			_formation;
	};

	if (
		_hasAnyChange
		&& {
			_waypointIndex
				== currentWaypoint _group
		}
	) then {
		{
			private _vehicle =
				objectParent _x;

			if (
				!isNull _vehicle
				&& {_x == driver _vehicle}
				&& {
					_vehicle isKindOf "AIR"
				}
			) then {
				private _flyInHeight =
					_vehicle getVariable [
						"A3C_FLYINHEIGHT",
						75
					];

				[
					_vehicle,
					_flyInHeight
				] spawn {
					params [
						"_vehicle",
						"_flyInHeight"
					];

					sleep 2;

					[
						_vehicle,
						_flyInHeight
					] remoteExec [
						"flyInHeight",
						_vehicle
					];
				};
			};
		} forEach units _group;
	};
} forEach _selection;

(
	_display displayCtrl IDC_MAP_HCWP_Parent
) ctrlShow false;

(findDisplay 12 displayCtrl 51)
	ctrlEnable true;

_display setVariable [
	"A3C_HCWP_MULTI_ACTIVE",
	false
];

_display setVariable [
	"A3C_HCWP_MULTI_INITIALIZING",
	false
];

_display setVariable [
	"A3C_HCWP_MULTI_SELECTION",
	[]
];

_display setVariable [
	"A3C_HCWP_MULTI_GROUPS",
	[]
];

if (_action == "TRANSPORT UNLOAD") then {
	[
		_groups
	] call A3C_ui_mapOverlay_fnc_HCWP_openCargoWaypointPrompt;
};

[] remoteExec [
	"A3C_ui_shared_fnc_toggleGocodeCtrls",
	0
];

A3C_HC_ACTIVE_WPOS = [
	0,
	0,
	0
];

