#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_addActions

private _display = findDisplay IDD_MAP_OVERLAY;

private _actionTypeCombo =
	_display displayCtrl IDC_MAP_HCWP_Type_Action;

private _group = A3C_HC_ACTIVEGROUP;
private _groupUnits = units _group;
private _leader = leader _group;
private _leaderVehicle = vehicle _leader;

private _isCargoOrInf =
	!(driver _leaderVehicle in _groupUnits)
	|| {isNull objectParent _leader};

private _canCargo =
	!_isCargoOrInf
	&& {
		count fullCrew [
			_leaderVehicle,
			"cargo",
			true
		] > 0
	};

private _actionTypes = [];

private _waypointTypes = if (
	_leaderVehicle isKindOf "AIR"
) then {
	[
		"MOVE",
		"SEARCH / DESTROY",
		"LOITER",
		"CYCLE"
	]
} else {
	[
		"MOVE",
		"SEARCH / DESTROY",
		"CYCLE"
	]
};

private _landingTypes = [];

A3C_HC_CASMODES = [];

private _slingMode = "";

if (
	!_isCargoOrInf
	&& {_leaderVehicle isKindOf "AIR"}
) then {
	if !(
		A3C_HC_EDIT_ACTION in [
			"SLING LOAD",
			"SLING DROP"
		]
	) then {
		_landingTypes = if (
			_leaderVehicle isKindOf "HELICOPTER"
		) then {
			[
				"FIRE SUPPORT",
				"LAND",
				"COMBAT LAND"
			]
		} else {
			[
				"LAND"
			]
		};

		/*
		 * Probe whether this aircraft supports sling loading and
		 * vehicle-in-vehicle transport.
		 */
		private _probeVehicle = "C_Quadbike_01_F" createVehicle [
			0,
			0,
			1000 + random 1000
		];

		private _canSling =
			_leaderVehicle canSlingLoad _probeVehicle;

		private _canVehicleCargo =
			(
				_leaderVehicle canVehicleCargo _probeVehicle
			) select 1;

		deleteVehicle _probeVehicle;

		if (_leaderVehicle isKindOf "HELICOPTER") then {
			if (
				[
					_leaderVehicle
				] call A3C_main_fnc_isAttackHelicopter
			) then {
				_landingTypes pushBackUnique
					"HELI OVERWATCH";
			};

			if (_canSling) then {
				_slingMode = [
					_group
				] call A3C_ai_highCommand_fnc_getSlingMode;
			};
		};

		if (_leaderVehicle isKindOf "PLANE") then {
			private _platformType =
				typeOf _leaderVehicle;

			private _isRotor = (
				getNumber (
					configFile
						>> "CfgVehicles"
						>> _platformType
						>> "landingSpeed"
				)
			) < 10;

			if !_isRotor then {
				A3C_HC_CASMODES = [
					_platformType
				] call A3C_main_fnc_getCASmodes;

				if (count A3C_HC_CASMODES > 0) then {
					_landingTypes pushBackUnique
						"CAS-STRIKE";
				};
			};
		};

		if (_canCargo) then {
			_landingTypes pushBackUnique
				"TRANSPORT UNLOAD";

			_landingTypes pushBackUnique
				"PARADROP";

			if (
				getNumber (
					configFile
						>> "CfgVehicles"
						>> typeOf _leaderVehicle
						>> "landingSpeed"
				) < 10
			) then {
				if (A3C_IsRappel) then {
					_landingTypes pushBackUnique
						"RAPPELL";
				};
			};
		} else {
			if (_canVehicleCargo) then {
				_landingTypes pushBackUnique
					"PARADROP";
			};
		};
	} else {
		_waypointTypes = [
			"MOVE"
		];

		_slingMode = if (
			A3C_HC_EDIT_ACTION == "SLING LOAD"
		) then {
			"HOOK"
		} else {
			"UNHOOK"
		};
	};

	switch (_slingMode) do {
		case "HOOK": {
			_landingTypes pushBack
				"SLING LOAD";
		};

		case "UNHOOK": {
			_landingTypes pushBack
				"SLING DROP";
		};
	};
} else {
	_actionTypes = [
		"FIRE SUPPORT",
		"AMBUSH"
	];

	if (_isCargoOrInf) then {
		if (
			count (
				[
					_groupUnits,
					"PLANNING"
				] call A3C_ai_shared_fnc_getSelectionPackedStaticWeapons
			) > 0
			&& {
				{
					markerType (
						(_x select 0) select 1
					) == "mil_dot"
				} count (
					_group getVariable [
						"A3C_UNIT_POLYS",
						[]
					]
				) < 1
			}
		) then {
			_actionTypes = _actionTypes + [
				"ASSEMBLE WEAPON"
			];
		};

		if (
			count (
				[
					_groupUnits
				] call A3C_ai_shared_fnc_getUnitsWithExplosives
			) > 0
		) then {
			_actionTypes = _actionTypes + [
				"DEMOLITION"
			];
		};

		{
			private _unit = _x;

			private _uavType = getText (
				configFile
					>> "CfgVehicles"
					>> backpack _unit
					>> "assembleInfo"
					>> "assembleTo"
			);

			private _exit = false;

			if (_uavType != "") then {
				private _isUAV = getText (
					configFile
						>> "CfgVehicles"
						>> _uavType
						>> "uavCameraDriverDir"
				) != "";

				if (_isUAV) then {
					_exit = true;

					_actionTypes = _actionTypes + [
						"ASSEMBLE UAV"
					];
				};
			};

			if (_exit) exitWith {};
		} forEach _groupUnits;
	} else {
		/*
		 * Check general cargo capability because cargo groups might
		 * not have boarded yet.
		 */
		if (
			[
				_leaderVehicle
			] call MCSS_fnc_countVehicleCargoSeats > 0
		) then {
			_landingTypes pushBackUnique
				"TRANSPORT UNLOAD";
		};
	};

	if (
		{
			[
				_x
			] call A3C_main_fnc_canRepair
		} count _groupUnits > 0
	) then {
		_actionTypes pushBackUnique
			"REPAIR";
	};
};

private _availableActions =
	_landingTypes
	+ _waypointTypes
	+ _actionTypes;

private _sortedActions = [];

{
	if (_x in _availableActions) then {
		_sortedActions pushBack _x;
	};
} forEach [
	"MOVE",
	"SEARCH / DESTROY",
	"FIRE SUPPORT",
	"AMBUSH",
	"CAS-STRIKE",
	"LOITER",
	"HELI OVERWATCH",
	"LAND",
	"TRANSPORT UNLOAD",
	"COMBAT LAND",
	"PARADROP",
	"RAPPELL",
	"SLING DROP",
	"SLING LOAD",
	"REPAIR",
	"ASSEMBLE WEAPON",
	"ASSEMBLE UAV",
	"DEMOLITION",
	"CYCLE"
];

lbClear _actionTypeCombo;

{
	[
		_actionTypeCombo,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;
} forEach _sortedActions;

{
	private _listboxText =
		_actionTypeCombo lbText _forEachIndex;

	switch (_listboxText) do {
		case "FIRE SUPPORT": {
			_listboxText = "SUPPRESSION";
		};

		case "COMBAT LAND": {
			_listboxText = "COMBATLANDING";
		};

		case "LAND": {
			_listboxText = "FULL LANDING";
		};
	};

	if (
		toLower _listboxText
			== toLower A3C_HC_EDIT_ACTION
	) then {
		[
			_actionTypeCombo,
			_forEachIndex
		] call A3C_ui_shared_fnc_lbSetCurSel;
	};
} forEach _sortedActions;