if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
	//-- single group selection: delete immediately (no confirmation needed)
	{
		private _gp = _x;
		if ({isPlayer _x} count(units _gp) == 0) then {
			[_gp] call A3C_main_fnc_deleteGroup;
		} else {
			systemchat format ["A3C: Group %1 was not deleted. Players detected", groupID _gp];
		};
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	A3C_SELECTED_HC_GROUPS_SETTINGS = [];
	A3C_SELECTED_UNITS = [];
} else {
	//-- multiple groups selected: prompt confirmation (HUD-variant of SPP is spawned in UI response)
	["DELETE"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;

};

