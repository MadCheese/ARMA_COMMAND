// A3C_ui_mapOverlay_fnc_SQWP_goCodeSwitch

private _selection = _this;

if (_selection > 4) exitWith {
	private _buildingPosition = A3C_TAB_BUILDING buildingPos (_selection - 5);
	private _markerPosition2D = (getMarkerPos A3C_MARKERTOSWITCH) select [0, 2];

	{
		private _soldier = _x;
		private _data = _soldier getVariable A3C_CHECKVAR;

		{
			private _entry = _x;

			if ((_entry select 2) == A3C_MARKERTOSWITCH) then {
				private _entryPosition2D = (_entry select 0) select [0, 2];

				if (_markerPosition2D distance _entryPosition2D < 0.2) then {
					_entry set [0, _buildingPosition];

					_entry set [
						1,
						[
							A3C_TAB_BUILDING,
							100,
							[
								A3C_TAB_BUILDING,
								_buildingPosition
							] call BIS_fnc_dirTo
						] call BIS_fnc_relPos
					];

					_data set [_forEachIndex, _entry];
					_soldier setVariable [A3C_CHECKVAR, _data, true];
				};
			};
		} forEach _data;
	} forEach (profileNamespace getVariable "A3C_GROUPUNITS");
};

private _result = "NONE";
private _markerSize = [1, 1];

switch (_selection) do {
	case 0: {
		_result = "NONE";
	};

	case 1: {
		_result = "A";
	};

	case 2: {
		_result = "B";
	};

	case 3: {
		_result = "C";
	};

	case 4: {
		_result = "D";
	};
};

// TODO: Check whether A3C_MARKERTOSWITCH is still relevant.
// Theory: The marker name is used only for identification, while its other
// properties may be unused.
{
	private _unit = _x;
	private _data = _unit getVariable A3C_CHECKVAR;

	{
		if (((_x select 1) select 0) == A3C_MARKERTOSWITCH) then {
			_x set [3, ["GOCODE", _result]];
		};
	} forEach _data;

	_unit setVariable [A3C_CHECKVAR, _data, true];
} forEach A3C_GCUNITS;

[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls", 0];

missionNamespace setVariable [
	"#markerSize_" + A3C_MARKERTOSWITCH,
	_markerSize
];