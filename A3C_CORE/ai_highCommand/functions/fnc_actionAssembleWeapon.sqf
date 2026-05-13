private _group = A3C_RD_UNITS select 0;
private _objectPlacerType = typeOf A3C_OBJECTPLACER;
private _objectPlacerPos = position A3C_OBJECTPLACER;
private _objectPlacerDir = getDir A3C_OBJECTPLACER;

{
	_x params ["_staticUnits", "_staticWeaponClass"];

	if (_staticWeaponClass == _objectPlacerType) exitWith {
		//-- clear all waypoints / reset clearing state
		{
			private _selectedGroup = _x;

			{
				_x setVariable ["A3C_CLEARING", false, true];
			} forEach units _selectedGroup;
		} forEach A3C_SELECTED_UNITS;

		while {count waypoints _group > 1} do {
			{
				if (_forEachIndex > 0) then {
					deleteWaypoint _x;
				};
			} forEach waypoints _group;
		};

		private _waypoint = [
			_group,
			_objectPlacerPos
		] call A3C_ai_highCommand_fnc_addWaypoint;

		private _unitPolys = _group getVariable ["A3C_UNIT_POLYS", []];

		private _polyPrefix = "ASS";
		private _polyTargetPos = +_objectPlacerPos;

		//-- Security mechanic: keep polygon/helper position at terrain level.
		_polyTargetPos set [2, 0];
		_polyTargetPos = _polyTargetPos getPos [50, _objectPlacerDir];

		if !(A3C_HC_PREVENT_POLY) then {
			//-- Create visible polygon.
			private _polygonMarkerName = format [
				"A3C_%1_MAIN_Mark_%2_%3",
				parseText _polyPrefix,
				getPlayerUID player,
				A3C_SUP_POLY_IND_MARK
			];

			private _polygon = (
				[[_polyTargetPos, _polygonMarkerName, currentWaypoint _group]] +
				([_polyTargetPos, _objectPlacerDir, "ASSEMBLE WEAPON", true] call A3C_SUP_CREATE_POLY)
			);

			A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
			_unitPolys pushBack _polygon;
		};

		private _waypointScript = format [
			"A3C_CORE\fnc_AI\wpFncs\wpScript_AssembleWeapon.sqf ['%1',%2,%3,'%4']",
			getPlayerUID player,
			["ARRIVAL", 0],
			["NONE", "NONE"],
			_objectPlacerType
		];

		_waypoint setWaypointType "SCRIPTED";
		_waypoint setWaypointScript _waypointScript;

		_group setVariable ["A3C_UNIT_POLYS", _unitPolys, true];

		A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (
			configFile >> "CfgVehicles" >> _staticWeaponClass >> "picture"
		);

		A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";

		player commandRadio "SentAssemble";
	};
} forEach A3C_STATIC_PACKS;