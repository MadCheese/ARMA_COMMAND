#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"



// disableSerialization;
params ["_display","_key","_shift","_ctrl","_alt"];


//-- declare variable for suppression of Engine Binds
private _blockDefault = false;

//-- CTRL key must block default engine bind to disable map drawing || NOTE : NOTE EVEN EXECUTED
if (_key == 29) then {
	_blockDefault = true;
};

//-- 1: MAP KEYBIND (close map > Does not work if overlay is open)
if ((_this select 1) in actionKeys "showmap") exitWith {
	
	false //-- this will close the map automatically, no need for 'showMap false'
};






//-- Disable Numbers (ie to disable weapon switch) or control SelectionPromptPanel-Listbox
private _mapSelectionPromptPanelListbox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
private _mapSelectionPromptPanelShown = ctrlShown _mapSelectionPromptPanelListbox;

if (
	_key >= 2 && _key <= 10
	&& {
		count groupselectedUnits player == 0
		|| { _mapSelectionPromptPanelShown }
	}
) exitWith {
	if (_mapSelectionPromptPanelShown) then {
		[_key, _mapSelectionPromptPanelListbox] spawn A3C_UI_SelectionPromptPanel_fnc_listbox_NumberControl;
	};
	true
};



//-- 2: DEFAULT EXIT CONDITIONS
if (
	[_key] call A3C_ui_shared_fnc_blockKeyDownEvent
	// || {A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE}
) exitWith {};

if (_alt && {_key == 15}) exitWith {// safety if user alt-tabs out of the game
	A3C_UI_DOWNKEYS = [];
	false
};


[_key] call A3C_ui_shared_fnc_addDownkey;

// player commandchat format ["Display %1, A3C_UI_MAP_onKeyDown_Overlay: %2 - %3", _display, keyName _key, round time];




switch (true) do {
	

	//-- Other keybinds
	case (_key in [28,57,207]) : {

		private _groupContextmenuHC = _display displayCtrl IDC_MAP_HCGP_Parent;
		private _wpContextmenuHC = _display displayCtrl IDC_MAP_HCWP_Parent;

		switch (_key) do {
			case 28: { // Enter
				if (ctrlShown _groupContextmenuHC) then {
					[] call A3C_ui_mapOverlay_fnc_HCGP_onConfirmButton;
				} else {
					if (ctrlShown _wpContextmenuHC) then {
						[] call A3C_ui_mapOverlay_fnc_HCWP_onConfirmButton;
					};
				};
				_blockDefault = true;
			};
			case 57: { // Spacebar
				if ( A3C_MAP_CommandMode in ["INF","AIR"] && {count groupselectedUnits player == 0}) then {
					['ALL'] spawn A3C_ui_mapOverlay_fnc_UFSB_onCommitButton;
				};
				_blockDefault = true;
			};
			case 207: { //-- END-key
				"DELETION HAS MOVED TO THE DEL KEY" spawn MCSS_fnc_ShortHint;
			};
		};
	};
};
_blockDefault
