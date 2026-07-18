#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"



// disableSerialization;
params ["_display","_key","_shift","_ctrl","_alt"];




//-- 1: MAP KEYBIND (close map > Does not work if overlay is open)
if ((_this select 1) in actionKeys "showmap") exitWith {
	
	false //-- this will close the map automatically, no need for 'showMap false'
};


//-- declare variable for suppression of Engine Binds
private _blockDefault = false;

//-- CTRL key must block default engine bind to disable map drawing
if (_key == 29) then {_blockDefault = true;};

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

				if (A3C_Selection_MultiWaypoint isEqualTo []) then {
					//-- SINGLE - need to hover exactly over waypoint
					getMousePosition params ["_sX","_sY"];
					private _wpIcons = (["HC_WP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
					if (count _wpIcons > 0) then {
						_wpIcon = _wpIcons select 0;
						_gp = _wpIcon select 0;
						_wpiC = _wpIcon select 3;
						[_gp, _wpiC] call A3C_ai_highCommand_fnc_removeWaypoint;
					} else {
						//-- Delete selected groups
						private _gpIcons = (["HC_GP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
						private _gpIconGroups = _gpIcons apply {_x select 0};
						if (count _gpIconGroups > 0) then {
							private _targetGroups = if (
								{typeName _x == "GROUP"} count A3C_SELECTED_UNITS > 0
							) then {+A3C_SELECTED_UNITS} else {_gpIconGroups};
							A3C_SELECTED_HC_GROUPS_SETTINGS = +_targetGroups;
							//-- always use selectionPrompt for map-hotkey deletion do prevent accidents
							["DELETE"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
						};
					};
				} else {
					//-- MULTIPLE WAYPOINTS SELECTED - can just delete
					{
						_x params ["_group", "_wpIndex"];
						while {_x in (waypoints _group)} do {
							_x call A3C_ai_highCommand_fnc_removeWaypoint;
						};
						A3C_Selection_MultiWaypoint = A3C_Selection_MultiWaypoint - [_x];
					} foreach A3C_Selection_MultiWaypoint;
				};
			};
		};
	};
};
_blockDefault
