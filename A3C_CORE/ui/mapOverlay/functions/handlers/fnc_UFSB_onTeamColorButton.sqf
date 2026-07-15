#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton

params ["_teamColor", "_shift"];

private _display = findDisplay IDD_MAP_OVERLAY;
private _selectionTree = _display displayCtrl IDC_SHARED_UI_TREE_SELECTOR;

_selectionTree tvSetCurSel [-1];

{
	(_display displayCtrl _x) ctrlShow false;
} forEach [
	IDC_MAP_DynamicCombo,
	IDC_MAP_SQWP_Parent
];

if (!_shift) then {
	A3C_SELECTED_UNITS = [];
};

private _groupUnits = profileNamespace getVariable "A3C_GROUPUNITS";
private _unitArray = _groupUnits - [player];
private _units = [];

{
	private _assignedTeam = if (player == cameraOn) then {
		assignedTeam _x
	} else {
		_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
	};

	if (_assignedTeam == _teamColor) then {
		if (!isPlayer _x) then {
			_units pushBack _x;
		};
	};
} forEach _unitArray;

if (_teamColor == "PURPLE") then {
	_units = _groupUnits - [player];

	{
		if (isPlayer _x) then {
			_units = _units - [_x];
		};
	} forEach _units;
};

private _selectedCount = {
	_x in A3C_SELECTED_UNITS
} count _units;

if (_selectedCount == count _units) then {
	{
		A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];

		call compile format [
			"A3C_UNIT_%1_BV = 0",
			_forEachIndex + 1
		];
	} forEach _units;
} else {
	{
		if (_x == driver (vehicle _x)) then {
			if (!isPlayer _x) then {
				A3C_SELECTED_UNITS pushBackUnique _x;

				call compile format [
					"A3C_UNIT_%1_BV = 1",
					_forEachIndex + 1
				];
			} else {
				systemChat format [
					"A3C: %1 is controlled by a player and will not be selected",
					name _x
				];
			};
		};
	} forEach _units;
};

private _switchCommandMode = false;

if (_teamColor == "PURPLE") then {
	private _filterCondition = {};

	switch (A3C_MAP_CommandMode) do {
		case "INF": {
			_filterCondition = {
				typeOf (vehicle _this) isKindOf "AIR"
			};
		};

		case "AIR": {
			_filterCondition = {
				!(typeOf (vehicle _this) isKindOf "AIR")
			};
		};

		case "HC": {
			_switchCommandMode = true;
		};
	};

	if (!_switchCommandMode) then {
		{
			if (_x call _filterCondition) then {
				A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
			};
		} forEach A3C_SELECTED_UNITS;
	};
} else {
	_switchCommandMode = true;
};

if (_switchCommandMode) then {
	private _selectedAirDrivers = {
		_x == driver (vehicle _x)
			&& {typeOf (vehicle _x) isKindOf "AIR"}
	} count A3C_SELECTED_UNITS;

	if (
		_selectedAirDrivers
			> (count A3C_SELECTED_UNITS / 2)
	) then {
		A3C_MAP_CommandMode = "AIR";

		{
			if !(typeOf (vehicle _x) isKindOf "AIR") then {
				A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
			};
		} forEach A3C_SELECTED_UNITS;
	} else {
		{
			if (typeOf (vehicle _x) isKindOf "AIR") then {
				A3C_SELECTED_UNITS = A3C_SELECTED_UNITS - [_x];
			};
		} forEach A3C_SELECTED_UNITS;

		A3C_MAP_CommandMode = "INF";
	};
};

A3C_SPLIT_UNITS = A3C_SELECTED_UNITS;

[A3C_MAP_CommandMode] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
[] call A3C_UNITSEL_REFRESH_UI;