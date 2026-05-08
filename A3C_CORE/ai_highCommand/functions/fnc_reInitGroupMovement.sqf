params ["_group"];

{
	private _unit = _x;
	private _vehicle = objectParent _unit;

	{
		_unit enableAI _x;
	} forEach ["MOVE", "PATH"];

	if (!isNull _vehicle) then {
		_vehicle limitSpeed 5000;

		private _flyInHeight = _vehicle getVariable ["A3C_FLYINHEIGHT", 75];
		_vehicle flyInHeight _flyInHeight;

		{
			_vehicle enableAI _x;
		} forEach ["MOVE", "PATH"];
	};
} forEach (units _group);