#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_squad_findVehicles

params ["_units"];

private _entities = if (count _this > 1) then {
	_this select 1
} else {
	[A3C_RADIAL_VEH_KIND]
};

A3C_VEHSAV = [];
A3C_BOARD_UNITS = [];

{
	private _unit = _x;

	{
		private _vehicle = _x;

		if (canMove _vehicle) then {
			if (
				side _vehicle == civilian ||
				{
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

if (count A3C_VEHSAV > 0) then {
	A3C_TARGETVEH = A3C_VEHSAV select 0;

	{
		if (isNull objectParent _x) then {
			if !(_x in A3C_BOARD_UNITS) then {
				if !(_x in A3C_BOARD_UNITS_ACTIVE) then {
					A3C_BOARD_UNITS pushBackUnique _x;
				};
			};
		};
	} forEach _units;
} else {
	A3C_TARGETVEH = objNull;
};

if (count A3C_VEHSAV == 0) then {
	[
		[
			"NO VEHICLES",
			"",
			objNull,
			findDisplay IDD_RADIAL_MENU
				displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX,
			""
		]
	] call A3C_ui_radialMenu_fnc_lbAdd;
};

//-- Clear right extension listboxes.
{
	lbClear _x;
} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

[] spawn {
	["VEHICLES"] call A3C_ui_radialMenu_fnc_labelListbox;

	sleep 0.1;

	private _display = findDisplay IDD_RADIAL_MENU;

	if (cursorTarget in A3C_VEHSAV) then {
		[
			_display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX,
			[cursorTarget, A3C_VEHSAV] call MCSS_fnc_getArrayIndex,
			true
		] call A3C_ui_shared_fnc_lbSetCurSel;
	} else {
		{
			[_x, 0] call A3C_ui_shared_fnc_lbSetCurSel;
		} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));
	};
};