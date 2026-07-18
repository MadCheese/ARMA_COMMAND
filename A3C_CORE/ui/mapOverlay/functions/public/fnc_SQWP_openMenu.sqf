#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_SQWP_openMenu

params [
	"_marker",
	"_pos"
];

private _screenX = _pos select 0;
private _screenY = _pos select 1;

//~~ #BUG - always "" because we do not use markers
private _markerType = markerType _marker;

private _mode = "INF";
private _display = findDisplay IDD_MAP_OVERLAY;

private _units = [];

private _sqwpParent =
	_display displayCtrl IDC_MAP_SQWP_Parent;

private _sqwpCombo =
	_display displayCtrl IDC_MAP_SQWP_Combo;

private _hcwpParent =
	_display displayCtrl IDC_MAP_HCWP_Parent;

private _stanceTravelImage =
	_display displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG;

private _stanceArrivalImage =
	_display displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG;

private _speedImage =
	_display displayCtrl IDC_MAP_SQWP_Speed_IMG;

private _findSquadWaypoint = {
	params [
		"_soldier",
		"_scanMode",
		"_scanMarker"
	];

	private _return = false;

	{
		private _variableName = _x;
		private _data = _soldier getVariable [_variableName, []];

		{
			_x params [
				"_wpPositions",
				"_wpMarkers",
				"_wpAction",
				"_wpCondition",
				"_wpStances",
				"_wpSyncData",
				"_wpCompleted",
				"_wpCombatMode",
				"_wpSpeed",
				"_wpFlyInHeight",
				"_wpLoopValue",
				"_wpRadius"
			];

			if (_scanMarker in _wpMarkers) then {
				A3C_CHECKVAR = _variableName;
				_return = true;

				if (_scanMode == "INF") then {
					switch (_wpStances select 0) do {
						case "DOWN": {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";
						};

						case "MIDDLE": {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
						};

						case "UP": {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
						};
					};

					switch (_wpStances select 1) do {
						case "DOWN": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_prone.paa";
						};

						case "MIDDLE": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
						};

						case "UP": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
						};
					};
				};

				if (_scanMode == "HELI") then {
					switch (_wpFlyInHeight) do {
						case 200: {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
						};

						case 75: {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
						};

						case 25: {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
						};

						case 5: {
							_stanceTravelImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
						};
					};

					switch (_wpAction select 1) do {
						case "NONE": {
							_stanceArrivalImage ctrlSetText
								"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

							_stanceArrivalImage ctrlSetTextColor (
								[
									A3C_UI_COLOR_BLUE,
									0.8
								] call A3C_ui_shared_fnc_getColorArrayWithOpacity
							);
						};

						case "PICKUP": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

							_stanceArrivalImage ctrlSetTextColor
								[1, 1, 1, 1];
						};

						case "DROPOFF": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

							_stanceArrivalImage ctrlSetTextColor
								[1, 1, 1, 1];
						};

						case "RAPPEL": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";

							_stanceArrivalImage ctrlSetTextColor
								[1, 1, 1, 1];
						};

						case "LANDFINAL": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_action_landing.paa";

							_stanceArrivalImage ctrlSetTextColor
								[1, 1, 1, 1];
						};

						case "PARADROP": {
							_stanceArrivalImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";

							_stanceArrivalImage ctrlSetTextColor
								[1, 1, 1, 1];
						};
					};
				};

				if (_wpSpeed == 2) then {
					_speedImage ctrlSetText
						"A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
				} else {
					_speedImage ctrlSetText
						"A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
				};
			};
		} forEach _data;
	} forEach [
		"A3C_PLOT",
		"A3C_PLOT_TEMP"
	];

	_return
};

{
	if (
		[
			_x,
			_mode,
			_marker
		] call _findSquadWaypoint
	) then {
		_units pushBack _x;
	};
} forEach (
	profileNamespace getVariable "A3C_GROUPUNITS"
);

if (
	{
		private _objectParent = objectParent _x;

		!(
			_x == driver _objectParent
			&& {_objectParent isKindOf "AIR"}
		)
	} count _units == 0
) then {
	_mode = "HELI";
};

A3C_MARKERTOSWITCH = _marker;

lbClear _sqwpCombo;

_sqwpParent ctrlSetPosition [
	_screenX,
	_screenY
];

_sqwpParent ctrlCommit 0;

if (_mode == "HELI") then {
	_sqwpParent ctrlShow true;

	A3C_LB_MODE = 0;

	_sqwpParent ctrlSetPosition [
		_screenX,
		_screenY
	];

	_sqwpParent ctrlCommit 0;

	[
		_sqwpCombo,
		"NONE"
	] call A3C_ui_shared_fnc_addLbEntry;

	[
		_sqwpCombo,
		"PICKUP"
	] call A3C_ui_shared_fnc_addLbEntry;

	[
		_sqwpCombo,
		"DROPOFF"
	] call A3C_ui_shared_fnc_addLbEntry;

	[
		_sqwpCombo,
		"LANDFINAL"
	] call A3C_ui_shared_fnc_addLbEntry;

	if (A3C_IsRappel) then {
		[
			_sqwpCombo,
			"RAPPEL"
		] call A3C_ui_shared_fnc_addLbEntry;
	};

	[
		_sqwpCombo,
		"PARADROP"
	] call A3C_ui_shared_fnc_addLbEntry;

	private _paradropSelection = if (A3C_IsRappel) then {
		5
	} else {
		4
	};

	switch (markerType A3C_MARKERTOSWITCH) do {
		case "A3C_Marker_WAYPOINT": {
			[
				_sqwpCombo,
				0
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		case "A3C_Marker_PICKUP_AIR": {
			[
				_sqwpCombo,
				1
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		case "A3C_Marker_DROPOFF_AIR": {
			[
				_sqwpCombo,
				2
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		case "A3C_Marker_LANDING": {
			[
				_sqwpCombo,
				3
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		case "A3C_Marker_RAPPEL": {
			[
				_sqwpCombo,
				4
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};

		case "A3C_Marker_Paradrop": {
			[
				_sqwpCombo,
				_paradropSelection
			] call A3C_ui_shared_fnc_lbSetCurSel;
		};
	};
};

A3C_CHECKVAR = "A3C_PLOT_TEMP";

if (_mode == "INF") then {
	if (count _units > 0) then {
		A3C_GCUNITS = _units;
		A3C_MARKERTOSWITCH = _marker;

		lbClear _sqwpCombo;

		_sqwpParent ctrlShow true;

		A3C_LB_MODE = 2;

		_sqwpParent ctrlSetPosition [
			_screenX,
			_screenY
		];

		_sqwpParent ctrlCommit 0;

		[
			_sqwpCombo,
			"NONE"
		] call A3C_ui_shared_fnc_addLbEntry;

		[
			_sqwpCombo,
			"A"
		] call A3C_ui_shared_fnc_addLbEntry;

		[
			_sqwpCombo,
			"B"
		] call A3C_ui_shared_fnc_addLbEntry;

		[
			_sqwpCombo,
			"C"
		] call A3C_ui_shared_fnc_addLbEntry;

		[
			_sqwpCombo,
			"D"
		] call A3C_ui_shared_fnc_addLbEntry;

		if (
			markerType A3C_MARKERTOSWITCH
				== "A3C_Marker_BUILDING"
		) then {
			A3C_TAB_BUILDING =
				nearestBuilding getMarkerPos A3C_MARKERTOSWITCH;

			for "_i" from 0 to (
				[
					A3C_TAB_BUILDING
				] call MCSS_fnc_getLastBuildingPosIndex
			) do {
				[
					_sqwpCombo,
					format [
						"BPos %1",
						_i
					]
				] call A3C_ui_shared_fnc_addLbEntry;
			};
		};

		switch (_markerType) do {
			//~~ #BUG - markertype always, "", will ALWAYS use default :S
			case "A3C_Marker_GoCode_A": {
				[
					_sqwpCombo,
					1
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};

			case "A3C_Marker_GoCode_B": {
				[
					_sqwpCombo,
					2
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};

			case "A3C_Marker_GoCode_C": {
				[
					_sqwpCombo,
					3
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};

			case "A3C_Marker_GoCode_D": {
				[
					_sqwpCombo,
					4
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};

			default {
				[
					_sqwpCombo,
					0
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};
		};
	};
};

lbClear _hcwpParent;

if (count _units == 1) then {
	[
		_hcwpParent,
		"NONE"
	] call A3C_ui_shared_fnc_addLbEntry;

	[
		_hcwpParent,
		1
	] call A3C_ui_shared_fnc_lbSetCurSel;
};