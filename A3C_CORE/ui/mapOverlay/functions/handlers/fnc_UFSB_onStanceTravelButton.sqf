#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onStanceTravelButton

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

private _stanceTravelImage = _display displayCtrl IDC_MAP_UFSB_STANCE_TRAVEL_IMG;

if (A3C_MAP_CommandMode in ["INF", "HC"]) then {
	switch (A3C_STANCE1_TEMP) do {
		case "DOWN": {
			if (_mode == 0) then {
				// Switch to standing.
				A3C_STANCE1_TEMP = "UP";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
			} else {
				// Switch to crouching.
				A3C_STANCE1_TEMP = "MIDDLE";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
			};
		};

		case "MIDDLE": {
			if (_mode == 0) then {
				// Switch to prone.
				A3C_STANCE1_TEMP = "DOWN";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
			} else {
				// Switch to standing.
				A3C_STANCE1_TEMP = "UP";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
			};
		};

		case "UP": {
			if (_mode == 0) then {
				// Switch to crouching.
				A3C_STANCE1_TEMP = "MIDDLE";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
			} else {
				// Switch to prone.
				A3C_STANCE1_TEMP = "DOWN";
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
			};
		};
	};
} else {
	switch (A3C_HELIHEIGHT) do {
		case 500: {
			if (_mode == 0) then {
				A3C_HELIHEIGHT = 200; // High
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
			} else {
				A3C_HELIHEIGHT = 5; // Lowest
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
			};
		};

		case 200: {
			if (_mode == 0) then {
				A3C_HELIHEIGHT = 25; // Medium
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
			} else {
				A3C_HELIHEIGHT = 500; // Highest
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
			};
		};

		case 25: {
			if (_mode == 0) then {
				A3C_HELIHEIGHT = 5; // Lowest
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";
			} else {
				A3C_HELIHEIGHT = 200; // High
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";
			};
		};

		case 5: {
			if (_mode == 0) then {
				A3C_HELIHEIGHT = 500; // Highest
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";
			} else {
				A3C_HELIHEIGHT = 25; // Medium
				_stanceTravelImage ctrlSetText "A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";
			};
		};
	};
};