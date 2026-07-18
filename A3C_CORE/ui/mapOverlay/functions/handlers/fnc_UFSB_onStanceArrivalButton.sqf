#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onStanceArrivalButton

params ["_mode"];

if (_mode < 0) then {
	_mode = 0;
};

if (_mode > 1) then {
	_mode = 1;
};

private _display = findDisplay IDD_MAP_OVERLAY;

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

private _arrivalImage = _display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_IMG;
private _arrivalButton = _display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_BTN;

if (A3C_MAP_CommandMode in ["INF", "HC"]) then {
	switch (A3C_STANCE2_TEMP) do {
		case "DOWN": {
			if (_mode == 0) then {
				A3C_STANCE2_TEMP = "UP";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				_arrivalButton ctrlSetToolTip "STAND";
			} else {
				A3C_STANCE2_TEMP = "MIDDLE";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
				_arrivalButton ctrlSetToolTip "CROUCH";
			};
		};

		case "MIDDLE": {
			if (_mode == 0) then {
				A3C_STANCE2_TEMP = "DOWN";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
				_arrivalButton ctrlSetToolTip "PRONE";
			} else {
				A3C_STANCE2_TEMP = "UP";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
				_arrivalButton ctrlSetToolTip "STAND";
			};
		};

		case "UP": {
			if (_mode == 0) then {
				A3C_STANCE2_TEMP = "MIDDLE";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
				_arrivalButton ctrlSetToolTip "CROUCH";
			} else {
				A3C_STANCE2_TEMP = "DOWN";
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
				_arrivalButton ctrlSetToolTip "PRONE";
			};
		};
	};

	_arrivalImage ctrlSetTextColor [1, 1, 1, 0.6];
} else {
	switch (A3C_TEMP_ACTION select 1) do {
		case "NONE": {
			if (_mode == 0) then {
				// Set to pickup.
				A3C_TEMP_ACTION = ["LANDING", "PICKUP"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "PICKUP";
			} else {
				// Set to final landing.
				A3C_TEMP_ACTION = ["LANDING", "LANDFINAL"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "LAND";
			};
		};

		case "PICKUP": {
			if (_mode == 0) then {
				// Set to drop-off.
				A3C_TEMP_ACTION = ["LANDING", "DROPOFF"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "DROPOFF";
			} else {
				// Set to no arrival action.
				A3C_TEMP_ACTION = ["LANDING", "NONE"];
				_arrivalImage ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				_arrivalImage ctrlSetTextColor (
					[A3C_UI_COLOR_BLUE, A3C_OPACITY] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				);
				_arrivalButton ctrlSetToolTip "MOVE";
			};
		};

		case "DROPOFF": {
			if (_mode == 0) then {
				if (A3C_IsRappel) then {
					// Set to rappel.
					A3C_TEMP_ACTION = ["LANDING", "RAPPEL"];
					_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
					_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
					_arrivalButton ctrlSetToolTip "RAPPEL";
				} else {
					// Set to sling load.
					A3C_TEMP_ACTION = ["SLINGLOAD", "SLINGLOAD"];
					_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
					_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
					_arrivalButton ctrlSetToolTip "Sling Load/Drop";
				};
			} else {
				// Set to pickup.
				A3C_TEMP_ACTION = ["LANDING", "PICKUP"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getIn.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "PICKUP";
			};
		};

		case "RAPPEL": {
			if (_mode == 0) then {
				// Set to paradrop.
				A3C_TEMP_ACTION = ["PARADROP", "PARADROP"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "Para-Drop";
			} else {
				// Set to drop-off.
				A3C_TEMP_ACTION = ["LANDING", "DROPOFF"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "DROPOFF";
			};
		};

		case "PARADROP": {
			if (_mode == 0) then {
				// Set to sling load.
				A3C_TEMP_ACTION = ["SLINGLOAD", "SLINGLOAD"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "Sling Load/Drop";
			} else {
				if (A3C_IsRappel) then {
					// Set to rappel.
					A3C_TEMP_ACTION = ["LANDING", "RAPPEL"];
					_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
					_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
					_arrivalButton ctrlSetToolTip "RAPPEL";
				} else {
					// Set to drop-off.
					A3C_TEMP_ACTION = ["LANDING", "DROPOFF"];
					_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_getOut.paa";
					_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
					_arrivalButton ctrlSetToolTip "DROPOFF";
				};
			};
		};

		case "SLINGLOAD": {
			if (_mode == 0) then {
				// Set to final landing.
				A3C_TEMP_ACTION = ["LANDING", "LANDFINAL"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "LAND";
			} else {
				// Set to paradrop.
				A3C_TEMP_ACTION = ["PARADROP", "PARADROP"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "Para-Drop";
			};
		};

		case "LANDFINAL": {
			if (_mode == 0) then {
				// Set to no arrival action.
				A3C_TEMP_ACTION = ["LANDING", "NONE"];
				_arrivalImage ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
				_arrivalImage ctrlSetTextColor (
					[A3C_UI_COLOR_BLUE, 0.8] call A3C_ui_shared_fnc_getColorArrayWithOpacity
				);
				_arrivalButton ctrlSetToolTip "MOVE";
			} else {
				// Set to sling load.
				A3C_TEMP_ACTION = ["SLINGLOAD", "SLINGLOAD"];
				_arrivalImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";
				_arrivalImage ctrlSetTextColor [1, 1, 1, 1];
				_arrivalButton ctrlSetToolTip "Sling Load/Drop";
			};
		};
	};
};