// A3C_ai_shared_fnc_medical_actionHealUnit

// Requires the unit's "A3C_PLOT" variable and
// A3C_ai_shared_fnc_actionExecuteUnitPlot.
params ["_unit", "_patient"];

private _unitObjectParent = objectParent _unit;
private _patientObjectParent = objectParent _patient;
private _vehicleHeal = _unitObjectParent == _patientObjectParent;

if (isPlayer _unit) exitWith {};

private _isPlayerPatient = _patient == player;

// Retain the destination setup performed for the patient.
[_patient] call A3C_ai_shared_fnc_setDestination;

private _patientUnitPosMode = switch (stance _patient) do {
	case "STAND": {
		"AUTO"
	};
	case "CROUCH": {
		"MIDDLE"
	};
	case "PRONE": {
		"DOWN"
	};
	default {
		"AUTO"
	};
};

private _assignedPatients = (group _unit) getVariable [
	"A3C_PATIENTS_ASSIGNED",
	[]
];

_assignedPatients pushBackUnique _patient;

(group _unit) setVariable [
	"A3C_PATIENTS_ASSIGNED",
	_assignedPatients
];

private _treatmentPosition = position _patient;

if (
	_unit != _patient
	&& {!_vehicleHeal}
) then {
	if (_isPlayerPatient) then {

		_unit groupChat "Get Support!";
		A3C_MEDICAL_MeetingPos = position player;
	} else {
		_patient forceSpeed 0;
	};

	// Retained as a hook for future AI meetup-position adjustments.
	if (
		_patient getHitPointDamage "Hitlegs" < 0.5
		&& {!([_patient] call A3C_ai_shared_fnc_medical_isUnitUnconscious)}
	) then {
		private _nearbyObjects = nearestObjects [
			_patient,
			[
				"HOUSE",
				"THING",
				"CAR",
				"TANK",
				"HELICOPTER",
				"PLANE"
			],
			15
		];

		if (count _nearbyObjects == 0) then {
			_nearbyObjects = nearestTerrainObjects [
				player,
				[
					"Tree",
					"Bush",
					"Rocks"
				],
				15
			];
		};

		if (count _nearbyObjects > 0) then {
			_nearbyObjects = [
				_nearbyObjects,
				[],
				{
					_x distance player
				},
				"ASCEND"
			] call BIS_fnc_sortBy;

			private _boundingBoxPositions = [
				_nearbyObjects select 0
			] call MCSS_fnc_getBoundingBox;

			_boundingBoxPositions = [
				_boundingBoxPositions,
				[],
				{
					_x distance player
				},
				"ASCEND"
			] call BIS_fnc_sortBy;

			if (_isPlayerPatient) then {
				A3C_MEDICAL_MeetingPos = _boundingBoxPositions select 0;
				_treatmentPosition = _boundingBoxPositions select 0;
			};
		};
	};
};

if (_isPlayerPatient) then {
	if (
		player == leader group player
		&& {!_vehicleHeal}
	) then {
		private _formationUnits = [];

		{
			private _expectedDestination = expectedDestination _x;

			if (
				(_expectedDestination select 1) in [
					"DoNotPlanFormation",
					"FORMATION PLANNED"
				]
				&& {
					!(
						_x in (
							(group player) getVariable [
								"A3C_MEDICS_ACTIVE",
								[]
							]
						)
					)
				}
			) then {
				_formationUnits pushBack _x;
			};
		} forEach ((units group player) - [player]);

		_formationUnits commandFollow player;
	};
};

if (stance _patient == "STAND") then {
	_patient setUnitPos "MIDDLE";
};

if (
	!_vehicleHeal
	&& {_unit distance _patient > 3}
) then {
	private _plotData = [
		[
			[
				_treatmentPosition,
				_treatmentPosition
			],
			[
				"",
				"",
				""
			],
			[
				"None",
				[]
			],
			[
				"NONE",
				"NONE"
			],
			[
				"UP",
				"MIDDLE"
			],
			[
				[
					0,
					false
				]
			],
			true,
			0,
			-1,
			25,
			-1,
			0
		]
	];

	_unit setVariable [
		"A3C_PLOT",
		_plotData,
		true
	];

	[
		_unit,
		_unit getVariable "A3C_PLOT"
	] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

	while {!isNull _patient} do {
		if (
			_patient getVariable [
				"A3C_AbortHealing",
				false
			]
		) exitWith {
			// The player aborted the action with a double-click.
		};

		if ([_unit] call A3C_ai_shared_fnc_medical_isUnitUnconscious) exitWith {
			// An unconscious healer cannot continue.
		};

		// Future self-healing support should avoid recursively recalling
		// this complete function.
		if (
			!alive _unit
			&& {!alive _patient}
		) exitWith {
			if (
				count (
					_unit getVariable [
						"A3C_PLOT",
						[]
					]
				) > 0
			) then {
				_unit setVariable [
					"A3C_ABORT_Data",
					[
						true,
						false
					],
					true
				];

				waitUntil {
					count (
						_unit getVariable [
							"A3C_PLOT",
							[]
						]
					) == 0
				};
			};
		};

		if (
			count (
				_unit getVariable [
					"A3C_PLOT",
					[]
				]
			) == 0
		) exitWith {};

		if (
			_unit distance2D _treatmentPosition <= 2
		) exitWith {
			if (
				count (
					_unit getVariable [
						"A3C_PLOT",
						[]
					]
				) > 0
			) then {
				_unit setVariable [
					"A3C_ABORT_Data",
					[
						true,
						false
					],
					true
				];

				waitUntil {
					count (
						_unit getVariable [
							"A3C_PLOT",
							[]
						]
					) == 0
				};
			};
		};

		sleep 0.1;
	};
};

{
	_x setVariable [
		"A3C_PLOT",
		[],
		true
	];
} forEach [
	_unit,
	_patient
];

private _skipHealing = true;

if (
	_unit distance2D _patient < 9
	|| {_vehicleHeal}
) then {
	_skipHealing = false;
} else {
	if (_isPlayerPatient) then {
		[
			_unit,
			position _unit
		] call A3C_ai_shared_fnc_doMove;

		for "_i" from 1 to 30 do {
			if (
				_patient getVariable [
					"A3C_AbortHealing",
					false
				]
			) exitWith {};

			if (player distance2D _unit < 5) exitWith {
				_skipHealing = false;
			};

			sleep 1;
		};
	};

	if (
		_unit distance2D _patient < 5
		&& {
			!(
				_patient getVariable [
					"A3C_AbortHealing",
					false
				]
			)
		}
	) then {
		(
			(group player) getVariable [
				"A3C_PATIENTS_DESIGNATED",
				[]
			]
		) pushBackUnique _patient;
	};
};

if (
	_patient getVariable [
		"A3C_AbortHealing",
		false
	]
) then {
	_patient setVariable [
		"A3C_AbortHealing",
		false
	];
};

if (_isPlayerPatient) then {
	A3C_MEDICAL_MeetingPos = [];
} else {
	_patient doWatch _unit;
};

if (
	!alive _unit
	|| {_skipHealing}
) then {
	if !(profileNamespace getVariable "A3C_AUTOMEDIC") then {
		systemChat format [
			"A3C: Patient %1 not healed, please repeat action",
			name _patient
		];
	};
} else {
	// Heal the patient.
	if (!_vehicleHeal) then {
		if (_unit == _patient) then {
			_unit action [
				"HealSoldierSelf",
				_unit
			];
		} else {
			_unit doWatch _patient;
			_unit action [
				"HealSoldier",
				_patient
			];
		};

		sleep 3;

		waitUntil {
			!(
				[
					"medic",
					animationState _unit
				] call BIS_fnc_inString
			)
		};

		sleep 1;
	};

	[_patient] call A3C_ai_shared_fnc_medical_applyHealing;

	
	_patient doWatch objNull;
};

_assignedPatients = (group _unit) getVariable [
	"A3C_PATIENTS_ASSIGNED",
	[]
];

_assignedPatients = _assignedPatients - [_patient];

(group _unit) setVariable [
	"A3C_PATIENTS_ASSIGNED",
	_assignedPatients
];

_patient forceSpeed -1;
_patient setUnitPos "AUTO";
_patient lookAt objNull;
_patient setUnitPos _patientUnitPosMode;

waitUntil {
	!(
		[
			"medic",
			animationState _unit
		] call BIS_fnc_inString
	)
};

_patient forceSpeed -1;

if (
	_patient != _unit
	&& {!_isPlayerPatient}
) then {
	[_unit] call A3C_ai_squad_fnc_actionResumeDestination;
};