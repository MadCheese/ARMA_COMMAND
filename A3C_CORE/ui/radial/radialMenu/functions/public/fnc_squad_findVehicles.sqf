#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_squad_findVehicles

params ["_units"];

private _entities = if (count _this > 1) then {
	_this select 1
} else {
	[A3C_RADIAL_VEH_KIND]
};

/*
	Choose the vehicle before drawing the extension. The old scheduled refresh
	first rendered index 0 and then, after a delay, could select and render the
	cursor target. That created a visible double refresh and allowed an older
	request to overwrite a newer selection.
*/
private _previousTarget = missionNamespace getVariable [
	"A3C_TARGETVEH",
	objNull
];
private _cursorVehicle = cursorTarget;

A3C_VEHSAV = [];
A3C_BOARD_UNITS = [];

{
	private _unit = _x;

	{
		private _vehicle = _x;

		if (canMove _vehicle) then {
			if (
				side _vehicle == civilian
				|| {
					(side _vehicle) getFriend (side player) > 0.6
				}
			) then {
				A3C_VEHSAV pushBackUnique _vehicle;
			};
		};
	} forEach (_unit nearEntities [_entities, 220]);

	if (vehicle _unit isKindOf A3C_RADIAL_VEH_KIND) then {
		A3C_VEHSAV pushBackUnique vehicle _unit;
	};
} forEach _units;

if (A3C_VEHSAV isNotEqualTo []) then {
	A3C_TARGETVEH = if (_previousTarget in A3C_VEHSAV) then {
		_previousTarget
	} else {
		if (_cursorVehicle in A3C_VEHSAV) then {
			_cursorVehicle
		} else {
			A3C_VEHSAV select 0
		}
	};

	{
		if (
			isNull objectParent _x
			&& {!(_x in A3C_BOARD_UNITS_ACTIVE)}
		) then {
			A3C_BOARD_UNITS pushBackUnique _x;
		};
	} forEach _units;
} else {
	A3C_TARGETVEH = objNull;
};

//-- Clear right extension listboxes before their single deterministic render.
{
	lbClear _x;
} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

["VEHICLES"] call A3C_ui_radialMenu_fnc_labelListbox;

private _display = findDisplay IDD_RADIAL_MENU;

if (!isNull _display) then {
	private _sourceBox = _display displayCtrl
		IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX;

	if (!isNull _sourceBox) then {
		if (A3C_VEHSAV isNotEqualTo []) then {
			private _targetIndex = A3C_VEHSAV find A3C_TARGETVEH;

			if (_targetIndex >= 0) then {
				[
					_sourceBox,
					_targetIndex
				] call A3C_ui_shared_fnc_lbSetCurSel;
			};
		} else {
			[
				[
					"NO VEHICLES",
					"",
					objNull,
					_sourceBox,
					""
				]
			] call A3C_ui_radialMenu_fnc_lbAdd;
		};
	};
};
