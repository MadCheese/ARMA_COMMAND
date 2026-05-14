// A3C_ai_highCommand_fnc_actionAddWaypoint

private _waypointPosition = +A3C_UI_HUD_3D_TAG_ICON_POS;

if (count A3C_RD_UNITS > 1) then {
							
	private _units = +(A3C_RD_UNITS);
	[_units, _waypointPosition] spawn A3C_FNCS_CONVOY_MULTIGROUP;

} else {

	{
		private _group = _x;

		private _eligibleForBuildingSearch = A3C_UI_HUD_3D_TAG_ICON_TYPE == "a3c_ui\markers\building.paa";

		private _wpParams = if (_eligibleForBuildingSearch) then {
			[
				_group,
				cursorTarget buildingPos 0,
				[],
				"MOVE",
				[0,0,"AUTO","AUTO","NORMAL","CLEARBUILDING"]
			]
		} else {
			[
				_group,
				_waypointPosition
			]
		};

		_wpParams call A3C_ai_highCommand_fnc_addWaypoint;

	} foreach A3C_RD_UNITS;
	
};
