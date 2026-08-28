// A3C_ui_shared_fnc_getGroupStateIconPath

params [
	["_isSelected", false, [false]],
	["_speedLimit", false, [false]]
];

switch (true) do {

	case (_isSelected && {_speedLimit}) : {
		"A3C_UI\icons\icon_menu_selectedTrue_SpeedLimit.paa"
	};

	case (_isSelected) : {
		"A3C_UI\icons\icon_menu_selectedTrue_NoSpeedLimit.paa"
	};

	case (_speedLimit) : {
		"A3C_UI\icons\icon_menu_selectedFalse_SpeedLimit.paa"
	};

	default {
		"A3C_UI\icons\icon_menu_selectedFalse_NoSpeedLimit.paa"
	};

};