#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_SQWP_heliActionSwitch

params [
	"_actionIndex", // 0: NONE | 1: PICKUP | 2: DROPOFF | 3: LANDFINAL | 4: RAPPEL | 5: PARADROP
	["_hide", false]
];

private _display = findDisplay IDD_MAP_OVERLAY;
private _arrivalImage = _display displayCtrl IDC_MAP_SQWP_Stance_Arrival_IMG;
private _newAction = "";

switch (_actionIndex) do {
	case 0: {
		_arrivalImage ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
		_arrivalImage ctrlSetTextColor (
			[A3C_UI_COLOR_BLUE, 0.8] call A3C_ui_shared_fnc_getColorArrayWithOpacity
		);

		_newAction = ["LANDING", "NONE"];
	};

	case 1: {
		_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
		_arrivalImage ctrlSetTextColor [1, 1, 1, 1];

		_newAction = ["LANDING", "PICKUP"];
	};

	case 2: {
		_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
		_arrivalImage ctrlSetTextColor [1, 1, 1, 1];

		_newAction = ["LANDING", "DROPOFF"];
	};

	case 3: {
		_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
		_arrivalImage ctrlSetTextColor [1, 1, 1, 1];

		_newAction = ["LANDING", "LANDFINAL"];
	};

	case 4: {
		_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
		_arrivalImage ctrlSetTextColor [1, 1, 1, 1];

		_newAction = ["LANDING", "RAPPEL"];
	};

	case 5: {
		_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
		_arrivalImage ctrlSetTextColor [1, 1, 1, 1];

		_newAction = ["PARADROP", "PARADROP"];
	};
};

if (_hide) then {
	(_display displayCtrl IDC_MAP_SQWP_Parent) ctrlShow false;
};

{
	private _unit = _x;

	{
		private _plotVariableName = _x;
		private _plotData = _unit getVariable _plotVariableName;

		{
			private _waypointMarkers = _x select 1;

			if ((_waypointMarkers select 0) == A3C_MARKERTOSWITCH) then {
				_x set [2, _newAction];
			};
		} forEach _plotData;

		_unit setVariable [
			_plotVariableName,
			_plotData,
			true
		];
	} forEach [
		"A3C_PLOT_TEMP",
		"A3C_PLOT"
	];
} forEach (profileNamespace getVariable "A3C_GROUPUNITS");