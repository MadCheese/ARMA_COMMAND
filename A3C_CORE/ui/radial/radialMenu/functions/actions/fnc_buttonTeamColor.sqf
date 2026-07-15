#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_buttonTeamColor

params ["_color", "_btn", "_ctrl"];

private _units = [];

{
	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _x
	} else {
		_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
	};

	if (_assignedTeam == _color) then {
		_units pushBack _x;
	};
} forEach ((units group player) - [player]);

if (_color == "PURPLE") then {
	_units = (units group player) - [player];
};

if (A3C_RADIAL_VAL == 0) then {
	A3C_RADIAL_VAL = 1;

	if !(_color == "PURPLE") then {
		{
			player groupSelectUnit [_x, false];
		} forEach units group player;
	};
};

private _selectedCount = {_x in groupSelectedUnits player} count _units;

if (_btn == 1) then {
	_units commandFollow player;
} else {
	if (_selectedCount == count _units) then {
		{
			player groupSelectUnit [_x, false];
		} forEach _units;
	} else {
		{
			if !(_x in groupSelectedUnits player) then {
				player groupSelectUnit [_x, true];
			};
		} forEach _units;
	};
};

private _display = findDisplay IDD_RADIAL_MENU;
private _ctTree = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;
_ctTree tvSetCurSel [-1];

A3C_RD_UNITS = groupSelectedUnits player;

{
	if (isPlayer _x) then {
		A3C_RD_UNITS = A3C_RD_UNITS - [_x];
		player groupSelectUnit [_x, false];
	};
} forEach A3C_RD_UNITS;

private _unitArray = profileNamespace getVariable "A3C_GROUPUNITS";

A3C_BOARD_UNITS = [];

{
	if (isNull objectParent _x) then {
		if !(_x in A3C_BOARD_UNITS) then {
			A3C_BOARD_UNITS pushBackUnique _x;
		};
	};
} forEach A3C_RD_UNITS;

if (BV_MEDICAL == 1) then {
	["MEDICAL"] call A3C_ui_radialMenu_fnc_labelListbox;
};

[] call A3C_ui_radialMenu_fnc_buttonReInit;