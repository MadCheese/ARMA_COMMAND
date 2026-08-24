#include "..\..\script_component.hpp"
#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_onLbChange

/*
	Shared list-box change handler used by the map overlay and radial menu.

	Modes:
	0: Squad waypoint context — helicopter
	1: Assign or clear target — squad and high command
	2: Squad waypoint context — infantry
	3: Squad-level team-color assignment
	4: Removed legacy high-command rejoin mode
	5: Removed legacy medical mode
	6: Medic selection
	7: Patient selection
	8: Vehicle selection
	9: Removed/no-op
	10: Rearm source selection
	11: Rearm source-content selection
	12: Individual behaviour selection
	13: Individual combat-mode selection
*/

if (
	missionNamespace getVariable [
		"A3C_CurSel",
		false
	]
) exitWith {};

params [
	"_mode",
	"_listBoxIndex",
	"_displayId"
];

if (isNil "_mode") exitWith {};

/*
	Legacy callers may pass the mode inside an array. The previous second
	element was stored in _btn but never used.
*/
if (_mode isEqualType []) then {
	_mode = _mode param [0, -1];
};

private _timeSinceLastSelection = time - A3C_LB_TICKTIME;

private _isDoubleClick =
	_timeSinceLastSelection > 0.07
	&& {_timeSinceLastSelection < 0.3};

A3C_LB_TICKTIME = time;

switch (_mode) do {
	case 0: {
		[_listBoxIndex] call A3C_ui_mapOverlay_fnc_SQWP_heliActionSwitch;

		private _display = findDisplay _displayId;

		if (!isNull _display) then {
			(_display displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;
		};
	};

	case 1: {
		private _display = findDisplay _displayId;

		if (!isNull _display) then {
			{
				(_display displayCtrl _x) ctrlShow false;
			} forEach [
				IDC_MAP_DynamicCombo,
				IDC_MAP_SQWP_Parent
			];
		};

		if (A3C_SELECTED_UNITS isEqualTo []) exitWith {};

		private _targetGroup = A3C_TRACKED_ENEMYGROUP;
		private _destinationUnits = units _targetGroup;

		if (_destinationUnits isEqualTo []) exitWith {};

		if ((A3C_SELECTED_UNITS select 0) isEqualType grpNull) then {
			{
				private _selectedGroup = _x;

				{
					private _soldier = _x;

					private _target = if (
						_forEachIndex < count _destinationUnits
					) then {
						_destinationUnits select _forEachIndex
					} else {
						_destinationUnits select 0
					};

					if (_listBoxIndex == 1) then {
						[
							[
								_soldier,
								_target
							],
							{
								params [
									"_soldier",
									"_target"
								];

								_soldier reveal [_target, 4];
								_soldier commandTarget _target;
								_soldier commandFire _target;
							}
						] remoteExec [
							"BIS_fnc_spawn",
							_soldier
						];
					};
				} forEach units _selectedGroup;

				player groupChat format [
					"%1 - target that enemy!",
					groupID _selectedGroup
				];
			} forEach A3C_SELECTED_UNITS;
		} else {
			/*
				Preserved as a reference rather than copying the array. The
				legacy function could append armed turret occupants to the
				global A3C_SELECTED_UNITS array through this reference.
			*/
			private _targetUnits = A3C_SELECTED_UNITS;

			{
				private _candidateUnit = _x;

				private _sharesSelectedVehicle = {
					_candidateUnit in vehicle _x
				} count A3C_SELECTED_UNITS > 0;

				if (
					_sharesSelectedVehicle
					&& {!(_candidateUnit in _targetUnits)}
				) then {
					private _assignedRole = assignedVehicleRole _candidateUnit;

					if (
						_assignedRole isNotEqualTo []
						&& {
							(_assignedRole select 0) == "Turret"
						}
					) then {
						private _turretPath = _assignedRole select 1;
						private _candidateVehicle = vehicle _candidateUnit;

						if (
							count (
								_candidateVehicle weaponsTurret _turretPath
							) > 0
						) then {
							_targetUnits pushBack _candidateUnit;
						};
					};
				};
			} forEach units group player;

			{
				private _soldier = _x;

				private _target = if (
					_forEachIndex < count _destinationUnits
				) then {
					_destinationUnits select _forEachIndex
				} else {
					_destinationUnits select 0
				};

				_soldier reveal [_target, 4];

				if (_listBoxIndex == 0) then {
					if (
						assignedTarget _soldier
						in _destinationUnits
					) then {
						_soldier doTarget objNull;
						_soldier lookAt objNull;
						_soldier doWatch objNull;
					};
				} else {
					private _targetVehicle = vehicle _target;

					_soldier commandTarget _targetVehicle;
					_soldier lookAt _targetVehicle;
					_soldier doWatch _targetVehicle;
				};
			} forEach _targetUnits;
		};
	};

	case 2: {
		private _display = findDisplay _displayId;

		if (!isNull _display) then {
			(_display displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;
		};

		_listBoxIndex call A3C_ui_mapOverlay_fnc_SQWP_goCodeSwitch;
	};

	case 3: {
		private _isMap = !isNull (findDisplay IDD_MAP_OVERLAY);

		private _affectedUnits = if (_isMap) then {
			A3C_SELECTED_UNITS
		} else {
			A3C_RD_UNITS
		};

		private _teamData = switch (_listBoxIndex) do {
			case 0: {
				[
					"RED",
					[A3C_UI_COLOR_RED, 1] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				]
			};

			case 1: {
				[
					"GREEN",
					[0, 1, 0, 1]
				]
			};

			case 2: {
				[
					"BLUE",
					[A3C_UI_COLOR_BLUE, 1] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				]
			};

			case 3: {
				[
					"YELLOW",
					[A3C_UI_COLOR_YELLOW, 1] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				]
			};

			default {
				[
					"MAIN",
					[1, 1, 1, 1]
				]
			};
		};

		_teamData params [
			"_teamColor",
			"_treeColor"
		];

		private _display = findDisplay _displayId;

		private _treeControl = if (!isNull _display) then {
			_display displayCtrl IDC_SHARED_UI_TREE_SELECTOR
		} else {
			controlNull
		};

		{
			private _unit = _x;

			_unit assignTeam _teamColor;
			_unit setVariable [
				"A3C_ASSIGNEDTEAM",
				_teamColor
			];

			private _treeSelectionPath = _unit getVariable [
				"A3C_TREESEL_INDEX",
				[]
			];

			if (
				_treeSelectionPath isNotEqualTo []
				&& {!isNull _treeControl}
			) then {
				private _subTreePath = _treeSelectionPath select (
					(count _treeSelectionPath) - 1
				);

				_treeControl tvSetColor [
					_subTreePath,
					_treeColor
				];
			};
		} forEach _affectedUnits;

		if (_isMap) then {
			if (!isNull _display) then {
				{
					(_display displayCtrl _x) ctrlShow false;
				} forEach [
					IDC_MAP_DynamicCombo,
					IDC_MAP_SQWP_Parent
				];
			};

			/*
				The map variant now performs its complete team-color layout
				in one immediate pass.
			*/
			[
				0
			] call A3C_ui_shared_fnc_resizeTeamColors_Y;
		} else {
			private _radialDisplay =
				findDisplay IDD_RADIAL_MENU;

			if (!isNull _radialDisplay) then {
				(
					_radialDisplay
						displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX
				) ctrlShow false;
			};

			/*
				Preserve the existing radial two-stage layout. The radial
				menu uses separate layers and is not part of the map fix.
			*/
			[
				_displayId,
				A3C_MAP_CommandMode
			] call A3C_ui_shared_fnc_resizeTeamColors_XWH;

			[] spawn {
				sleep 0.1;

				[
					0
				] call A3C_ui_shared_fnc_resizeTeamColors_Y;
			};
		};
	};

	// Modes 4 and 5 were removed.

	case 6: {
		if (_listBoxIndex < 0) exitWith {};

		private _medics = (group player) getVariable [
			"A3C_MEDICS",
			[]
		];

		if (_medics isEqualTo []) exitWith {};

		private _selectedMedics = [];

		if (
			_listBoxIndex == 0
			&& {count _medics > 1}
		) then {
			_selectedMedics = _medics;
		} else {
			if (count _medics > 1) then {
				_selectedMedics = [
					_medics select (_listBoxIndex - 1)
				];
			} else {
				_selectedMedics = [
					_medics select 0
				];
			};
		};

		(group player) setVariable [
			"A3C_MEDICS_LB",
			_selectedMedics
		];
	};

	case 7: {
		if (_listBoxIndex < 0) exitWith {};

		private _patients = (group player) getVariable [
			"A3C_PATIENTS",
			[]
		];

		if (_patients isEqualTo []) exitWith {};

		private _radialDisplay = findDisplay IDD_RADIAL_MENU;

		if (isNull _radialDisplay) exitWith {};

		private _patientListBox = _radialDisplay displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX;

		if (isNull _patientListBox) exitWith {};

		/*
			When more than one entry exists, index 0 is the "all patients"
			entry and individual patients begin at index 1.
		*/
		private _hasAllPatientsEntry = lbSize _patientListBox > 1;

		private _patientIndex = if (_hasAllPatientsEntry) then {
			_listBoxIndex - 1
		} else {
			_listBoxIndex
		};

		private _selectedPatients = if (
			_hasAllPatientsEntry
			&& {_listBoxIndex == 0}
		) then {
			_patients
		} else {
			if (
				_patientIndex < 0
				|| {_patientIndex >= count _patients}
			) exitWith {
				[]
			};

			[
				_patients select _patientIndex
			]
		};

		if (_selectedPatients isEqualTo []) exitWith {};

		private _minimumDoubleClickIndex = if (_hasAllPatientsEntry) then {
			1
		} else {
			0
		};

		if (
			_isDoubleClick
			&& {
				_listBoxIndex >= _minimumDoubleClickIndex
			}
		) then {
			if (
				_patientIndex < 0
				|| {_patientIndex >= count _patients}
			) exitWith {};

			private _patient = _patients select _patientIndex;

			_patient setVariable [
				"A3C_AbortHealing",
				true
			];

			{
				private _evaluatedPatients = (group player) getVariable [
					_x,
					[]
				];

				_evaluatedPatients = _evaluatedPatients - [_patient];

				(group player) setVariable [
					_x,
					_evaluatedPatients
				];
			} forEach [
				"A3C_PATIENTS_ASSIGNED",
				"A3C_PATIENTS_DESIGNATED"
			];

			systemChat format [
				"HEALING CANCELLED FOR %1",
				name _patient
			];

			[] call A3C_ui_radialMenu_fnc_refreshMedical;
		} else {
			(group player) setVariable [
				"A3C_PATIENTS_LB",
				_selectedPatients
			];
		};
	};

	case 8: {
		if (
			_listBoxIndex >= 0
			&& {_listBoxIndex < count A3C_VEHSAV}
		) then {
			private _selectedVehicle = A3C_VEHSAV select _listBoxIndex;
			private _currentVehicle = missionNamespace getVariable [
				"A3C_TARGETVEH",
				objNull
			];

			if (
				!isNull _selectedVehicle
				&& {_selectedVehicle isNotEqualTo _currentVehicle}
			) then {
				A3C_TARGETVEH = _selectedVehicle;

				[
					"VEHICLES",
					1
				] call A3C_ui_radialMenu_fnc_labelListbox;
			};
		};
	};

	// Mode 9 was an empty legacy branch.

	case 10: {
		[
			_listBoxIndex
		] call A3C_ui_radialMenu_fnc_reArm_lbChangeSource;
	};

	case 11: {
		[
			_listBoxIndex,
			_isDoubleClick
		] call A3C_ui_radialMenu_fnc_reArm_lbChangeSourceContent;
	};

	case 12: {
		private _behaviour = switch (_listBoxIndex) do {
			case 0: {"CARELESS"};
			case 1: {"SAFE"};
			case 2: {"AWARE"};
			case 3: {"COMBAT"};
			case 4: {"STEALTH"};
		};

		{
			[
				_x,
				[
					"BEHAVIOUR",
					_behaviour
				]
			] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
		} forEach A3C_RD_UNITS;
	};

	case 13: {
		private _combatMode = switch (_listBoxIndex) do {
			case 0: {"BLUE"};
			case 1: {"GREEN"};
			case 2: {"WHITE"};
			case 3: {"YELLOW"};
			case 4: {"RED"};
		};

		{
			[
				_x,
				[
					"COMBATMODE",
					_combatMode
				]
			] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
		} forEach A3C_RD_UNITS;
	};
};
