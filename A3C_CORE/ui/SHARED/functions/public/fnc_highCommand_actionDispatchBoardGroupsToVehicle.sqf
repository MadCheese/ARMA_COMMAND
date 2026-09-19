#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_highCommand_actionDispatchBoardGroupsToVehicle

/*
	Starts high-command vehicle assignment or dispatches a dismount order.

	_button:
		0	Assign selected groups to a vehicle.
		Any other value
			Dismount or unassign groups.

	_ctrl:
		false
			Dismount the directly selected groups.

		true
			Dismount other groups sharing vehicles with the selected groups.
*/
params [
	["_button", 0, [0]],
	["_ctrl", false, [false]]
];

private _mapDisplay = findDisplay IDD_MAP_OVERLAY;
private _radialDisplay = findDisplay IDD_RADIAL_MENU;

private _isMap = !isNull _mapDisplay;
private _isRadial = !_isMap && {!isNull _radialDisplay};

if (!_isMap && {!_isRadial}) exitWith {};

private _display = if (_isMap) then {
	_mapDisplay
} else {
	_radialDisplay
};

private _selectedGroups = +(
	missionNamespace getVariable [
		"A3C_SELECTED_HC_GROUPS_SETTINGS",
		[]
	]
);

if (_selectedGroups isEqualTo []) exitWith {};

/*
	Hide the group-action panel and dashboard while the boarding or
	dismount interaction is being processed.
*/
if (_isMap) then {
	[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
} else {
	{
		private _control = _display displayCtrl _x;

		if (!isNull _control) then {
			_control ctrlShow false;
		};
	} forEach [
		// IDC_MAP_HCGP_Parent,
		IDC_SHARED_UI_DASHBOARD_PARENT
	];
};

if (_button == 0) exitWith {
	/*
		Keep the nested selected-groups array expected by the existing
		boardable-vehicle helper.
	*/
	
	A3C_UI_MAPICONS_HC_VICS = [
		_selectedGroups
	] call A3C_main_fnc_getBoardableVehicles;
	
	if (_isRadial) then {
		A3C_UI_HUD_ASSIGNVEHICLE = true;

		[
			false,
			"BoardVehicle_HC",
			"",
			[1, 0, 0, 1],
			"",
			""
		] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
	} else {
		private _boardingActive = missionNamespace getVariable [
			"A3C_Boarding_Mapselection_ACTIVE",
			false
		];

		// systemchat format ["TEST DISPATCH BOARDING %1, %2, %3",_selectedGroups, count A3C_UI_MAPICONS_HC_VICS, _boardingActive];


		if (!_boardingActive) then {
			A3C_BOARDING_GROUPS = +_selectedGroups;

			A3C_BOOL_MOUSEMOVING = true;

			A3C_MMCode = {
				_this spawn A3C_ui_mapOverlay_fnc_onDragMapStandard;
			};

			A3C_BOOL_DRAGLINE = true;
			A3C_CONNECTING_MODE = "HCBOARD";
			A3C_Boarding_Mapselection_ACTIVE = true;
		};
	};
};

/*
	This function runs where the target group's leader is local.

	Each unit is ordered out through the existing helper. Vehicles returned
	by that helper then have the dismounted group's crew assignments removed.
*/
private _dismountFunction = {
	params [
		["_group", grpNull, [grpNull]]
	];

	if (isNull _group) exitWith {};

	private _groupUnits = units _group;
	private _affectedVehicles = [];

	{
		private _unit = _x;
		private _parentVehicle = objectParent _unit;
		private _assignedVehicle = assignedVehicle _unit;

		if (!isNull _parentVehicle) then {
			// Unit has already boarded - dismount normally.
			_affectedVehicles pushBackUnique _parentVehicle;

			[
				_unit
			] call A3C_ai_shared_fnc_unitGetOut;
		} else {
			if (!isNull _assignedVehicle) then {
				// Unit is still boarding - cancel the pending assignment.
				_affectedVehicles pushBackUnique _assignedVehicle;

				_unit remoteExec [
					"unassignVehicle",
					0
				];

				[
					_unit
				] orderGetIn false;
			};
		};
	} forEach _groupUnits;

	{
		private _vehicle = _x;

		private _assignedCrew = _vehicle getVariable [
			"A3C_AssignedVehicleCrew",
			[]
		];

		_assignedCrew = _assignedCrew select {
			private _assignedUnit = _x param [
				0,
				objNull
			];

			!(_assignedUnit in _groupUnits)
		};

		_vehicle setVariable [
			"A3C_AssignedVehicleCrew",
			_assignedCrew,
			true
		];
	} forEach _affectedVehicles;
};

private _aiGroups = _selectedGroups select {
	!isPlayer leader _x
};

{
	private _selectedGroup = _x;
	private _selectedGroupUnits = units _selectedGroup;

	private _groupsToDismount = if (_ctrl) then {
		[]
	} else {
		[_selectedGroup]
	};

	if (_ctrl) then {
		/*
			CTRL+dismount only targets groups carried by vehicles that are
			actually driven by members of the selected group.

			This prevents selecting a cargo group from dismounting the vehicle's
			driver group.

			Pending A3C boarding assignments are included as well.
		*/
		private _drivenVehicles = [
			_selectedGroup
		] call A3C_main_fnc_getGroupDrivenVehicles;

		{
			private _vehicle = _x;

			// Groups already inside the vehicle.
			{
				private _cargoGroup = group _x;

				if (
					_cargoGroup != _selectedGroup
					&& {!isPlayer leader _cargoGroup}
				) then {
					_groupsToDismount pushBackUnique _cargoGroup;
				};
			} forEach crew _vehicle;

			// Groups currently boarding the vehicle.
			private _assignedCrew = _vehicle getVariable [
				"A3C_AssignedVehicleCrew",
				[]
			];

			{
				private _assignedUnit = _x param [
					0,
					objNull
				];

				if (!isNull _assignedUnit) then {
					private _cargoGroup = group _assignedUnit;

					if (
						_cargoGroup != _selectedGroup
						&& {!isPlayer leader _cargoGroup}
					) then {
						_groupsToDismount pushBackUnique _cargoGroup;
					};
				};
			} forEach _assignedCrew;
		} forEach _drivenVehicles;
	};


	// Never issue this mass-dismount order to the player's own group.

	_groupsToDismount = _groupsToDismount - [group player];

	{
		private _groupToDismount = _x;
		private _targetLeader = leader _groupToDismount;

		if (!isNull _targetLeader) then {
			[
				[
					_groupToDismount
				],
				_dismountFunction
			] remoteExec [
				"BIS_fnc_call",
				_targetLeader
			];
		};
	} forEach _groupsToDismount;

	if (_groupsToDismount isNotEqualTo []) then {
		if (_ctrl) then {
			private _groupString = "";
			private _dismountCount = count _groupsToDismount;

			{
				private _prefix = "";
				private _suffix = "";

				if (_forEachIndex == (_dismountCount - 1)) then {
					if (_dismountCount > 1) then {
						_prefix = " and ";
					};
				} else {
					if (_forEachIndex < (_dismountCount - 2)) then {
						_suffix = ", ";
					};
				};

				_groupString =
					_groupString
					+ _prefix
					+ groupID _x
					+ _suffix;
			} forEach _groupsToDismount;

			systemChat format [
				"A3C: %1 is dismounting %2",
				groupID _selectedGroup,
				_groupString
			];
		} else {
			systemChat format [
				"A3C: %1 was unassigned from all vehicles",
				groupID _selectedGroup
			];
		};
	};
} forEach _aiGroups;