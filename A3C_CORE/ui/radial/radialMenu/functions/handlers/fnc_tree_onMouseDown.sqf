#include "..\..\dialog_defines.hpp"

params ["_treeCtrl", "_btn", "_sX", "_sY", "_shift", "_ctrlKey", "_alt"];

private _boxPos = ctrlPosition (
	findDisplay IDD_RADIAL_MENU
	displayCtrl IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP
);

_sX = _sX - (_boxPos select 0);
_sY = _sY - (_boxPos select 1);

if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	if (_btn == 1) then {
		//-- Precaution: rClick deselects groupSelectedUnits. >> re-select!
		[] spawn {
			for "_i" from 1 to 2 do {
				sleep (0.1 * _i);

				{
					if (!isPlayer _x) then {
						player groupSelectUnit [_x, true];
						A3C_RD_UNITS pushBackUnique _x;
					};
				} forEach A3C_RD_UNITS;
			};
		};

		if (_shift) then {
			private _teamBox = findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX;

			lbClear _teamBox;
			_teamBox ctrlShow true;
			ctrlSetFocus _teamBox;
			A3C_LB_MODE = 3;

			private _listBoxPos = [
				_sX min ((_boxPos select 2) * 0.59),
				_sY min ((_boxPos select 3) * 0.59)
			];

			[_teamBox, "TEAM RED"] call A3C_ui_shared_fnc_addLbEntry;
			_teamBox lbSetColor [0, [1, 0, 0, 1]];

			[_teamBox, "TEAM GREEN"] call A3C_ui_shared_fnc_addLbEntry;
			_teamBox lbSetColor [1, [0, 1, 0, 1]];

			[_teamBox, "TEAM BLUE"] call A3C_ui_shared_fnc_addLbEntry;
			_teamBox lbSetColor [2, [0, 0, 1, 1]];

			[_teamBox, "TEAM YELLOW"] call A3C_ui_shared_fnc_addLbEntry;
			_teamBox lbSetColor [3, [1, 1, 0, 1]];

			[_teamBox, "TEAM WHITE"] call A3C_ui_shared_fnc_addLbEntry;
			_teamBox lbSetColor [4, [1, 1, 1, 1]];

			_teamBox ctrlSetPosition _listBoxPos;
			_teamBox ctrlCommit 0;

			private _assignedTeam = if (player == cameraOn) then {
				assignedTeam (_unitArray select _unitIndex)
			} else {
				(_unitArray select _unitIndex) getVariable ["A3C_ASSIGNEDTEAM", "MAIN"]
			};

			switch (_assignedTeam) do {
				case "RED": {
					[_teamBox, 0] call A3C_ui_shared_fnc_lbSetCurSel;
					_teamBox lbSetSelectColor [0, [1, 0, 0, 1]];
				};

				case "GREEN": {
					[_teamBox, 1] call A3C_ui_shared_fnc_lbSetCurSel;
					_teamBox lbSetSelectColor [1, [0, 1, 0, 1]];
				};

				case "BLUE": {
					[_teamBox, 2] call A3C_ui_shared_fnc_lbSetCurSel;
					_teamBox lbSetSelectColor [2, [0, 0, 1, 1]];
				};

				case "YELLOW": {
					[_teamBox, 3] call A3C_ui_shared_fnc_lbSetCurSel;
					_teamBox lbSetSelectColor [3, [1, 1, 0, 1]];
				};

				case "MAIN": {
					[_teamBox, 4] call A3C_ui_shared_fnc_lbSetCurSel;
					_teamBox lbSetSelectColor [4, [1, 1, 1, 1]];
				};
			};
		} else {
			if (
				((_unitArray select _unitIndex) in A3C_RD_UNITS) &&
				{
					count A3C_RD_UNITS > 1
				}
			) then {
				private _add = {_x in A3C_UI_squadPlacement_units} count A3C_RD_UNITS == 0;

				{
					if (_add) then {
						if !(_x in A3C_UI_squadPlacement_units) then {
							[
								_x,
								_x getVariable "A3C_FORMATION_INDEX"
							] call A3C_UI_squadPlacement_fnc_addUnitGhost;
						};
					} else {
						if (_x in A3C_UI_squadPlacement_units) then {
							[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
						};
					};
				} forEach A3C_RD_UNITS;
			} else {
				if !((_unitArray select _unitIndex) in A3C_UI_squadPlacement_units) then {
					[
						_unitArray select _unitIndex,
						(_unitArray select _unitIndex) getVariable "A3C_FORMATION_INDEX"
					] call A3C_UI_squadPlacement_fnc_addUnitGhost;
				} else {
					[
						_unitArray select _unitIndex
					] call A3C_UI_squadPlacement_fnc_removeUnitGhost;
				};
			};
		};
	};
};