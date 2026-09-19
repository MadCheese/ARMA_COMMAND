#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCGP_onConfirmButton

private _display = findDisplay IDD_MAP_OVERLAY;

(
	_display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT
) ctrlShow false;

private _showPlayerHint = false;

{
	private _group = _x;
	private _leader = leader _group;

	if (
		isPlayer _leader
		&& {_leader != player}
	) then {
		_showPlayerHint = true;
	} else {
		if (
			A3C_Map_HC_groupContext_Behaviour
				== "Careless (Driver)"
		) then {
			{
				private _unit = _x;

				if (_unit == driver vehicle _unit) then {
					[
						_unit,
						[
							"BEHAVIOUR",
							"CARELESS"
						]
					] call A3C_ai_shared_fnc_orderbhvCbmIndividual;
				};
			} forEach units _group;
		} else {
			if (
				A3C_Map_HC_groupContext_Behaviour != ""
			) then {
				[
					_leader,
					A3C_Map_HC_groupContext_Behaviour
				] remoteExec [
					"setBehaviourStrong",
					_leader
				];
			};

			if (
				A3C_Map_HC_groupContext_CMode != ""
			) then {
				[
					_leader,
					A3C_Map_HC_groupContext_CMode
				] remoteExec [
					"setCombatMode",
					_leader
				];
			};

			if (
				A3C_Map_HC_groupContext_CMode == "RED"
			) then {
				[
					_group,
					true
				] remoteExec [
					"enableAttack",
					_leader
				];
			} else {
				[
					_group,
					false
				] remoteExec [
					"enableAttack",
					_leader
				];
			};

			if (
				A3C_Map_HC_groupContext_Form != ""
			) then {
				[
					_group,
					A3C_Map_HC_groupContext_Form
				] remoteExec [
					"setFormation",
					_leader
				];

				// Preserved duplicate legacy dispatch.
				[
					_group,
					A3C_Map_HC_groupContext_Form
				] remoteExec [
					"setFormation",
					_leader
				];
			};

			_group setVariable [
				"A3C_HC_GroupColor",
				A3C_Map_HC_groupContext_Color,
				true
			];

			if (
				count A3C_SELECTED_HC_GROUPS_SETTINGS == 1
			) then {
				private _groupName = ctrlText (
					_display
						displayCtrl IDC_MAP_DASHBOARD_GROUPNAME_EDIT
				);

				if (groupId _group != _groupName) then {
					[
						_group,
						[
							_groupName
						]
					] remoteExec [
						"setGroupIdGlobal",
						_leader
					];

					private _treeSelectionPath =
						_group getVariable [
							"A3C_TREESEL_INDEX",
							[]
						];

					if (count _treeSelectionPath > 0) then {
						private _selectionTree =
							_display
								displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

						private _treePath =
							_treeSelectionPath select 0;

						_selectionTree tvSetText [
							_treePath,
							_groupName
						];
					};
				};

				if (A3C_MAP_CommandMode == "HC") then {
					[
						"HC"
					] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
				};
			};
		};

		{
			private _unit = _x;

			[
				_unit,
				A3C_GROUP_STANCE_Selected
			] remoteExec [
				"setUnitPos",
				_unit
			];
		} forEach units _group;

		_group setVariable [
			"A3C_GROUP_STANCE",
			A3C_GROUP_STANCE_Selected,
			true
		];
	};
} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;

if (_showPlayerHint) then {
	// #TODO: Implement player notification using structured text,
	// including the requested formation, behaviour, and related orders.
	[] spawn {
		hint "A3C: Player groups within selection have been notified of your orders. (Not implemented yet)";

		sleep 2;

		hintSilent "";
	};
};

[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
{
	(
		_display displayCtrl _x
	) ctrlShow false;
} forEach [
	IDC_SHARED_UI_DASHBOARD_PARENT
];

(
	findDisplay 12 displayCtrl 51
) ctrlEnable true;