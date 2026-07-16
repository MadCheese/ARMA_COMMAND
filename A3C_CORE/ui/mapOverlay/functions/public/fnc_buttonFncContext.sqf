#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_buttonFncContext

// AUTHOR NOTE: ~ can this be optimized more and shortened??
params ["_mode"];

private _display = findDisplay IDD_MAP_OVERLAY;

private _sqwpParent =
	_display displayCtrl IDC_MAP_SQWP_Parent;

private _sqwpCombo =
	_display displayCtrl IDC_MAP_SQWP_Combo;

private _speedImage =
	_display displayCtrl IDC_MAP_SQWP_Speed_IMG;

private _stanceTravelImage =
	_display displayCtrl IDC_MAP_SQWP_Stance_Travel_IMG;

private _stanceArrivalImage =
	_display displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG;

private _isCurrentWaypoint = {
	params [
		"_unit",
		"_variableName",
		"_index"
	];

	if (_variableName != "A3C_PLOT") exitWith {
		false
	};

	(_index + 1) == (
		_unit getVariable "A3C_CURRENTWAYPOINT_INDEX"
	)
};

private _applyContextToUnit = {
	params [
		"_unit",
		"_contextMode"
	];

	{
		private _variableName = _x;
		private _data = _unit getVariable _variableName;

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

			if ((_wpMarkers select 0) == A3C_MARKERTOSWITCH) then {
				switch (_contextMode) do {
					case "SPEED": {
						if (_wpSpeed == -1) then {
							_x set [8, 2];

							_speedImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_speed_diminished.paa";
						} else {
							_x set [8, -1];

							_speedImage ctrlSetText
								"A3C_CORE\ui\pictures\icon_menu_speed_full.paa";
						};
					};

					case "STANCE1": {
						switch (_wpStances select 0) do {
							case "DOWN": {
								_wpStances set [0, "UP"];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									_unit setUnitPos "UP";
								};
							};

							case "MIDDLE": {
								_wpStances set [0, "DOWN"];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									_unit setUnitPos "DOWN";
								};
							};

							case "UP": {
								_wpStances set [0, "MIDDLE"];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									_unit setUnitPos "MIDDLE";
								};
							};
						};
					};

					case "STANCE2": {
						switch (_wpStances select 1) do {
							case "DOWN": {
								_wpStances set [1, "UP"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
							};

							case "MIDDLE": {
								_wpStances set [1, "DOWN"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
							};

							case "UP": {
								_wpStances set [1, "MIDDLE"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
							};
						};
					};

					case "HEIGHT": {
						switch (_wpFlyInHeight) do {
							case 200: {
								_x set [9, 75];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									vehicle _unit flyInHeight 75;
								};
							};

							case 75: {
								_x set [9, 25];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									vehicle _unit flyInHeight 25;
								};
							};

							case 25: {
								_x set [9, 5];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									vehicle _unit flyInHeight 5;
								};
							};

							case 5: {
								_x set [9, 200];

								_stanceTravelImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";

								if (
									[
										_unit,
										_variableName,
										_forEachIndex
									] call _isCurrentWaypoint
								) then {
									vehicle _unit flyInHeight 200;
								};
							};
						};
					};

					case "HELIWP": {
						switch (_wpAction select 1) do {
							case "NONE": {
								_wpAction set [1, "PICKUP"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

								_stanceArrivalImage ctrlSetTextColor
									[1, 1, 1, 1];

								[
									A3C_MARKERTOSWITCH,
									"A3C_Marker_PICKUP_AIR",
									"DEFAULT"
								] call MCSS_fnc_SwitchMarker;

								[
									_sqwpCombo,
									1
								] call A3C_ui_shared_fnc_lbSetCurSel;
							};

							case "PICKUP": {
								_wpAction set [1, "DROPOFF"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

								_stanceArrivalImage ctrlSetTextColor
									[1, 1, 1, 1];

								[
									A3C_MARKERTOSWITCH,
									"A3C_Marker_DROPOFF_AIR",
									"DEFAULT"
								] call MCSS_fnc_SwitchMarker;

								[
									_sqwpCombo,
									2
								] call A3C_ui_shared_fnc_lbSetCurSel;
							};

							case "DROPOFF": {
								if (A3C_IsRappel) then {
									_wpAction set [1, "RAPPEL"];

									_stanceArrivalImage ctrlSetText
										"A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";

									_stanceArrivalImage ctrlSetTextColor
										[1, 1, 1, 1];

									[
										A3C_MARKERTOSWITCH,
										"A3C_Marker_Rappel",
										"DEFAULT"
									] call MCSS_fnc_SwitchMarker;

									[
										_sqwpCombo,
										4
									] call A3C_ui_shared_fnc_lbSetCurSel;
								} else {
									_wpAction set [1, "LANDFINAL"];

									_stanceArrivalImage ctrlSetText
										"A3C_CORE\ui\pictures\icon_menu_action_landing.paa";

									_stanceArrivalImage ctrlSetTextColor
										[1, 1, 1, 1];

									[
										A3C_MARKERTOSWITCH,
										"A3C_Marker_LANDING",
										"DEFAULT"
									] call MCSS_fnc_SwitchMarker;

									[
										_sqwpCombo,
										3
									] call A3C_ui_shared_fnc_lbSetCurSel;
								};
							};

							case "RAPPEL": {
								_wpAction set [1, "LANDFINAL"];

								_stanceArrivalImage ctrlSetText
									"A3C_CORE\ui\pictures\icon_menu_action_landing.paa";

								_stanceArrivalImage ctrlSetTextColor
									[1, 1, 1, 1];

								[
									A3C_MARKERTOSWITCH,
									"A3C_Marker_LANDING",
									"DEFAULT"
								] call MCSS_fnc_SwitchMarker;

								[
									_sqwpCombo,
									3
								] call A3C_ui_shared_fnc_lbSetCurSel;
							};

							case "LANDFINAL": {
								_wpAction set [1, "NONE"];

								_stanceArrivalImage ctrlSetText
									"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

								_stanceArrivalImage ctrlSetTextColor (
									[
										A3C_UI_COLOR_BLUE,
										A3C_OPACITY
									] call A3C_UI_fnc_setOpacity
								);

								[
									A3C_MARKERTOSWITCH,
									"A3C_Marker_WAYPOINT",
									"DEFAULT"
								] call MCSS_fnc_SwitchMarker;

								[
									_sqwpCombo,
									0
								] call A3C_ui_shared_fnc_lbSetCurSel;
							};
						};
					};

					case "DELETE": {
						//~~ is this condition still needed since no more HC markers are used??
						if (
							markerType A3C_MARKERTOSWITCH
								!= "A3C_Marker_HCWP"
						) then {
							_sqwpParent ctrlShow false;

							if (
								[
									_unit,
									_variableName,
									_forEachIndex
								] call _isCurrentWaypoint
							) then {
								[
									[
										_unit
									],
									false,
									true,
									true
								] spawn A3C_ai_shared_fnc_cancelUnitPlot;

								_unit setVariable [
									"A3C_BOOL_WP_DELETED",
									true,
									true
								];
							} else {
								{
									deleteMarkerLocal _x;
								} forEach _wpMarkers;

								if (
									(
										_data select _forEachIndex
									) select 10 != -1
								) then {
									{
										_x set [10, -1];
									} forEach _data;
								};

								_data deleteAt _forEachIndex;

								_unit setVariable [
									_variableName,
									_data,
									true
								];
							};
						};
					};
				};
			};
		} forEach _data;

		_unit setVariable [
			_variableName,
			_data,
			true
		];
	} forEach [
		"A3C_PLOT_TEMP",
		"A3C_PLOT"
	];
};

{
	[
		_x,
		_mode
	] call _applyContextToUnit;
} forEach (
	profileNamespace getVariable "A3C_GROUPUNITS"
);