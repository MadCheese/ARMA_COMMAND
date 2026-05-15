// A3C_ai_squad_fnc_actionAssembleWeapon

private _objectPlacerType = typeOf A3C_OBJECTPLACER;

{
	_x params ["_units", "_weapon"];

	if (_weapon == _objectPlacerType) exitWith {
		if (_units findIf {!((_x getVariable ["A3C_PLOT", []]) isEqualTo [])} > -1) then {
			[_units, true, false] call A3C_AI_Shared_cancelUnitPlot;

			waitUntil {
				sleep 0.1;

				_units findIf {
					!((_x getVariable ["A3C_PLOT", []]) isEqualTo [])
				} == -1
			};
		};

		player groupRadio "SentAssemble";

		private _mainMark = "A3C_SQ_" + str random 10000000000;
		private _screenCenterPos = screenToWorld [0.5, 0.5];
		private _assembleTargetPos = _screenCenterPos getPos [50, getDir A3C_OBJECTPLACER];

		{
			private _unit = _x;

			waitUntil {
				(_unit getVariable ["A3C_PLOT", []]) isEqualTo []
			};

			private _plotData = [
				[
					[_screenCenterPos, _assembleTargetPos],		// Positions
					[_mainMark, "", ""],							// Markers
					["STATIC", ["ASSEMBLE", _weapon]],				// WP action
					["NONE", "NONE"],								// WP condition
					["UP", "AUTO"],								// WP stances
					[[0, false]],									// WP sync data
					false,											// Is WP completed
					0,												// Combat mode
					-1,												// WP speed
					25,												// WP flying height
					-1,												// WP loop value
					0												// Radius, for circle, not completion
				]
			];

			_unit setVariable ["A3C_PLOT", _plotData, true];
			[_unit, _unit getVariable ["A3C_PLOT", []]] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;
		} forEach _units;

		A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configFile >> "CfgVehicles" >> _weapon >> "picture");
		A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";

		private _tagPos = +position A3C_OBJECTPLACER;
		[_tagPos, ""] spawn A3C_UI_HUD_3D_TAG;
	};
} forEach A3C_STATIC_PACKS;

deleteVehicle A3C_OBJECTPLACER;