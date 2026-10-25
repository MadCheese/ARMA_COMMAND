// A3C_ui_mapOverlay_fnc_MAP_onDeleteKey
// Called by the native map display (12) KeyDown handler.
params ["_display", "_key", "_shift", "_ctrl", "_alt"];

if (_key != 211) exitWith {false};

// Leave DELETE available to A3C edit fields and native map text editing.
if (
	missionNamespace getVariable ["A3C_UI_MAP_BOOL_CT_EDIT_ACTIVE", false]
	|| {ctrlType (focusedCtrl _display) == 2} // CT_EDIT
) exitWith {false};

private _handled = false;

if (A3C_Selection_MultiWaypoint isEqualTo []) then {
	//-- SINGLE - need to hover exactly over waypoint
	getMousePosition params ["_sX","_sY"];
	private _wpIcons = (["HC_WP",_sx,_sy] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
	if (count _wpIcons > 0) then {
		private _wpIcon = _wpIcons select 0;
		private _gp = _wpIcon select 0;
		private _wpiC = _wpIcon select 3;
		[_gp, _wpiC] call A3C_ai_highCommand_fnc_removeWaypoint;
		_handled = true;
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
			_handled = true;
		};
	};
} else {
	//-- MULTIPLE WAYPOINTS SELECTED - can just delete
	{
		_x params ["_group", "_wpIndex"];
		while {_x in (waypoints _group)} do {
			_x call A3C_ai_highCommand_fnc_removeWaypoint;
			_handled = true;
		};
		A3C_Selection_MultiWaypoint = A3C_Selection_MultiWaypoint - [_x];
	} foreach A3C_Selection_MultiWaypoint;
};

_handled
