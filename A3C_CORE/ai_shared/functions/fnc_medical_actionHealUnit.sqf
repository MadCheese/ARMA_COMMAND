// A3C_ai_shared_fnc_medical_actionHealUnit

// Requires the unit's "A3C_PLOT" variable and
// A3C_ai_shared_fnc_actionExecuteUnitPlot.

params [
	["_unit", objNull, [objNull]],
	["_patient", objNull, [objNull]]
];

if (
	isNull _unit
	|| {isNull _patient}
) exitWith {};

if (isPlayer _unit) exitWith {};

private _unitGroup =
	group _unit;

private _unitObjectParent =
	objectParent _unit;

private _patientObjectParent =
	objectParent _patient;

/*
	The treatment counts as an in-vehicle treatment only when both units
	are actually inside the same non-null vehicle.

	Two dismounted units both return objNull from objectParent and must not
	be treated as sharing a vehicle.
*/
private _vehicleHeal =
	!isNull _unitObjectParent
	&& {
		_unitObjectParent
		isEqualTo _patientObjectParent
	};

private _isPlayerPatient =
	isPlayer _patient;

// Retain the destination setup performed for the patient.
[
	_patient
] call A3C_ai_shared_fnc_setDestination;

private _patientUnitPosMode = switch (
	stance _patient
) do {
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

private _assignedPatients = _unitGroup getVariable [
	"A3C_PATIENTS_ASSIGNED",
	[]
];

_assignedPatients pushBackUnique _patient;

_unitGroup setVariable [
	"A3C_PATIENTS_ASSIGNED",
	_assignedPatients
];

private _treatmentPosition =
	position _patient;

if (
	_unit != _patient
	&& {!_vehicleHeal}
) then {
	if (_isPlayerPatient) then {
		_unit groupChat "Get Support!";

		A3C_MEDICAL_MeetingPos =
			position _patient;
	} else {
		_patient forceSpeed 0;
	};

	/*
		Retained as a hook for future AI meetup-position adjustments.

		At present, an alternative treatment position is selected only for
		a player patient.
	*/
	if (
		_patient getHitPointDamage "Hitlegs" < 0.5
		&& {
			!([
				_patient
			] call A3C_ai_shared_fnc_medical_isUnitUnconscious)
		}
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

		if (_nearbyObjects isEqualTo []) then {
			_nearbyObjects = nearestTerrainObjects [
				_patient,
				[
					"Tree",
					"Bush",
					"Rocks"
				],
				15
			];
		};

		if (_nearbyObjects isNotEqualTo []) then {
			_nearbyObjects = [
				_nearbyObjects,
				[],
				{
					_x distance _patient
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
					_x distance _patient
				},
				"ASCEND"
			] call BIS_fnc_sortBy;

			if (
				_isPlayerPatient
				&& {
					_boundingBoxPositions
					isNotEqualTo []
				}
			) then {
				A3C_MEDICAL_MeetingPos =
					_boundingBoxPositions select 0;

				_treatmentPosition =
					_boundingBoxPositions select 0;
			};
		};
	};
};

if (
	_isPlayerPatient
	&& {_patient == leader group _patient}
	&& {!_vehicleHeal}
) then {
	private _patientGroup =
		group _patient;

	private _activeMedics = _patientGroup getVariable [
		"A3C_MEDICS_ACTIVE",
		[]
	];

	private _formationUnits = [];

	{
		private _expectedDestination =
			expectedDestination _x;

		if (
			(_expectedDestination select 1) in [
				"DoNotPlanFormation",
				"FORMATION PLANNED"
			]
			&& {!(_x in _activeMedics)}
		) then {
			_formationUnits pushBack _x;
		};
	} forEach (
		(units _patientGroup) - [_patient]
	);

	_formationUnits commandFollow _patient;
};

if (stance _patient == "STAND") then {
	_patient setUnitPos "MIDDLE";
};

/*
	Skip the full plot movement when the healer is already close enough.

	This decision is independent of whether the patient is an AI unit or a
	player.
*/
private _requiresPlotMovement =
	!_vehicleHeal
	&& {_unit != _patient}
	&& {_unit distance2D _patient > 3};

if (_requiresPlotMovement) then {
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
		_unit getVariable [
			"A3C_PLOT",
			[]
		]
	] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

	while {
		!isNull _patient
	} do {
		if (
			_patient getVariable [
				"A3C_AbortHealing",
				false
			]
		) exitWith {
			// The action was aborted externally.
		};

		if (
			[
				_unit
			] call A3C_ai_shared_fnc_medical_isUnitUnconscious
		) exitWith {
			// An unconscious healer cannot continue.
		};

		if (
			!alive _unit
			|| {!alive _patient}
		) exitWith {
			if (
				(
					_unit getVariable [
						"A3C_PLOT",
						[]
					]
				) isNotEqualTo []
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
					(
						_unit getVariable [
							"A3C_PLOT",
							[]
						]
					) isEqualTo []
				};
			};
		};

		if (
			(
				_unit getVariable [
					"A3C_PLOT",
					[]
				]
			) isEqualTo []
		) exitWith {};

		if (
			_unit distance2D _treatmentPosition
			<= 2
		) exitWith {
			if (
				(
					_unit getVariable [
						"A3C_PLOT",
						[]
					]
				) isNotEqualTo []
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
					(
						_unit getVariable [
							"A3C_PLOT",
							[]
						]
					) isEqualTo []
				};
			};
		};

		sleep 0.1;
	};
};

/*
	Clear any remaining plot data before evaluating the final treatment
	range.
*/
{
	if (!isNull _x) then {
		_x setVariable [
			"A3C_PLOT",
			[],
			true
		];
	};
} forEach [
	_unit,
	_patient
];

private _healingAborted = _patient getVariable [
	"A3C_AbortHealing",
	false
];

/*
	A healer that is already within nine metres may immediately begin the
	treatment interaction. The direct fallback movement is needed only when
	the plot movement did not bring the healer sufficiently close.
*/
private _healerInRange =
	_vehicleHeal
	|| {_unit distance2D _patient < 9};

private _usedFallbackMovement =
	false;

if (
	!_healerInRange
	&& {!_healingAborted}
	&& {alive _unit}
	&& {alive _patient}
	&& {
		!([
			_unit
		] call A3C_ai_shared_fnc_medical_isUnitUnconscious)
	}
) then {
	_usedFallbackMovement = true;

	[
		_unit,
		_treatmentPosition
	] call A3C_ai_shared_fnc_doMove;

	private _movementTimeout =
		time + 30;

	waitUntil {
		sleep 0.25;

		_healingAborted = _patient getVariable [
			"A3C_AbortHealing",
			false
		];

		_healingAborted
		|| {!alive _unit}
		|| {!alive _patient}
		|| {
			[
				_unit
			] call A3C_ai_shared_fnc_medical_isUnitUnconscious
		}
		|| {_unit distance2D _patient < 5}
		|| {time >= _movementTimeout}
	};

	_healerInRange =
		_unit distance2D _patient < 5;
};

/*
	Retain the designated-patient bookkeeping after a successful fallback
	approach, but associate it with the healer's actual group rather than
	group player.
*/
if (
	_usedFallbackMovement
	&& {_healerInRange}
	&& {!_healingAborted}
) then {
	private _designatedPatients = _unitGroup getVariable [
		"A3C_PATIENTS_DESIGNATED",
		[]
	];

	_designatedPatients pushBackUnique _patient;

	_unitGroup setVariable [
		"A3C_PATIENTS_DESIGNATED",
		_designatedPatients
	];
};

private _healerUnconscious = [
	_unit
] call A3C_ai_shared_fnc_medical_isUnitUnconscious;

private _skipHealing =
	!alive _unit
	|| {!alive _patient}
	|| {_healingAborted}
	|| {_healerUnconscious}
	|| {!_healerInRange};

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

if (_skipHealing) then {
	if !(
		profileNamespace getVariable [
			"A3C_AUTOMEDIC",
			false
		]
	) then {
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

	[
		_patient
	] call A3C_ai_shared_fnc_medical_applyHealing;

	_patient doWatch objNull;
};

_assignedPatients = _unitGroup getVariable [
	"A3C_PATIENTS_ASSIGNED",
	[]
];

_assignedPatients =
	_assignedPatients - [_patient];

_unitGroup setVariable [
	"A3C_PATIENTS_ASSIGNED",
	_assignedPatients
];

private _isPlayerLedGroup =
	isPlayer (leader _unitGroup);

_patient forceSpeed -1;
_patient lookAt objNull;

/*
	Player-led squads retain the patient's stance mode from before
	treatment. AI-led high-command groups are reset below after the
	healing animation has ended.
*/
if (_isPlayerLedGroup) then {
	_patient setUnitPos "AUTO";
	_patient setUnitPos _patientUnitPosMode;
};

waitUntil {
	!(
		[
			"medic",
			animationState _unit
		] call BIS_fnc_inString
	)
};

_patient forceSpeed -1;

/*
	AI-led groups must not retain the crouched treatment posture.
	Reset both the healer and patient after the healing animation.
*/

if (!_isPlayerLedGroup) then {
	{
		if (!isNull _x) then {
			_x setUnitPos "AUTO";
		};
	} forEach [
		_unit,
		_patient
	];
};

if (
	_patient != _unit
	&& {!_isPlayerPatient}
) then {
	[
		_unit
	] call A3C_ai_squad_fnc_actionResumeDestination;
};