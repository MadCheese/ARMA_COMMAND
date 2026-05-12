{
	private _group = _x;
	{
		private _unit = _x;
		if (_unit in A3C_SUPPRESSION_UNITS_AI) then {
			[[_unit],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
		};
	} foreach units _group;
} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;