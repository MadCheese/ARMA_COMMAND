#include "..\script_component.hpp"
#include "..\shared_ui_defines.hpp"

params ["_display", "_name"];

if (isNull _display) exitWith {[]};

switch (_name) do {
	case "shared_teamColorMacros": {
		[
			_display displayCtrl IDC_SHARED_UI_TCBOX_RED_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_RED_BTN,
			_display displayCtrl IDC_SHARED_UI_TCBOX_GREEN_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_GREEN_BTN,
			_display displayCtrl IDC_SHARED_UI_TCBOX_BLUE_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_BLUE_BTN,
			_display displayCtrl IDC_SHARED_UI_TCBOX_YELLOW_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_YELLOW_BTN,
			_display displayCtrl IDC_SHARED_UI_TCBOX_WHITE_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_WHITE_BTN,
			_display displayCtrl IDC_SHARED_UI_TCBOX_PURPLE_IMG,
			_display displayCtrl IDC_SHARED_UI_TCBOX_PURPLE_BTN
		] select {!isNull _x}
	};

	default {[]};
};