#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_reArm_lbChangeSource

params ["_sourceIndex"];

A3C_REARM_CARGO = [];

private _display = findDisplay IDD_RADIAL_MENU;
if (isNull _display) exitWith {};

private _contentListBox = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX;
if (isNull _contentListBox) exitWith {};

lbClear _contentListBox;

if (
	(count A3C_ReArm_Options) > 0 &&
	{ _sourceIndex >= 0 } &&
	{ _sourceIndex < count A3C_ReArm_Options }
) then {
	A3C_TARGETVEH = A3C_ReArm_Options select _sourceIndex;

	private _selectedSource = A3C_TARGETVEH;
	private _corpseWeaponHolders = if (_selectedSource isKindOf "Man") then {
		getCorpseWeaponHolders _selectedSource
	} else {
		[]
	};

	if ((count A3C_RD_UNITS) == 1) then {
		[
			[
				"Open Inventory",
				"",
				objNull,
				_contentListBox,
				""
			]
		] call A3C_ui_radialMenu_fnc_lbAdd;
	};

	for "_cargoTypeIndex" from 0 to 3 do {
		private _configRoot = "CfgWeapons";
		private _cargo = [];

		switch (_cargoTypeIndex) do {
			case 0: {
				_configRoot = "CfgWeapons";

				if (_selectedSource isKindOf "Man") then {
					_cargo = +(weapons _selectedSource);

					{
						_cargo append (weaponCargo _x);
					} forEach _corpseWeaponHolders;
				} else {
					_cargo = getWeaponCargo _selectedSource;
				};
			};

			case 1: {
				_configRoot = "CfgMagazines";

				if (_selectedSource isKindOf "Man") then {
					_cargo = +(magazines _selectedSource);

					{
						_cargo append (magazineCargo _x);
					} forEach _corpseWeaponHolders;
				} else {
					_cargo = getMagazineCargo _selectedSource;
				};
			};

			case 2: {
				_configRoot = "CfgWeapons";

				if (_selectedSource isKindOf "Man") then {
					_cargo = +(items _selectedSource);

					{
						if (_x != "") then {
							_cargo pushBack _x;
						};
					} forEach [
						vest _selectedSource,
						headgear _selectedSource,
						hmd _selectedSource
					];

					{
						_cargo append (itemCargo _x);
					} forEach _corpseWeaponHolders;
				} else {
					_cargo = getItemCargo _selectedSource;
				};
			};

			case 3: {
				_configRoot = "CfgVehicles";

				if (_selectedSource isKindOf "Man") then {
					_cargo = [];

					{
						if (_x != "") then {
							_cargo pushBack _x;
						};
					} forEach [
						backpack _selectedSource
					];

					{
						_cargo append (backpackCargo _x);
					} forEach _corpseWeaponHolders;
				} else {
					_cargo = backpackCargo _selectedSource;
				};
			};
		};

		if ((count _cargo) > 0) then {
			private _aggregatedCargo = [];

			if ((_cargo select 0) isEqualType []) then {
				{
					_aggregatedCargo pushBack [
						_x,
						(_cargo select 1) select _forEachIndex
					];
				} forEach (_cargo select 0);
			} else {
				{
					private _className = _x;
					private _existingIndex = _aggregatedCargo findIf {
						(_x select 0) isEqualTo _className
					};

					if (_existingIndex == -1) then {
						_aggregatedCargo pushBack [_className, 1];
					} else {
						private _existingEntry = _aggregatedCargo select _existingIndex;
						_existingEntry set [1, (_existingEntry select 1) + 1];
					};
				} forEach _cargo;
			};

			{
				_x params ["_className", "_amount"];

				private _displayName = getText (
					configFile >> _configRoot >> _className >> "displayName"
				);

				private _text = _displayName + format [", (%1x)", _amount];

				private _icon = getText (
					configFile >> _configRoot >> _className >> "picture"
				);

				A3C_REARM_CARGO pushBack _className;

				[
					[
						_text,
						_className,
						_className,
						_contentListBox,
						_icon
					]
				] call A3C_ui_radialMenu_fnc_lbAdd;
			} forEach _aggregatedCargo;
		};
	};

	[_contentListBox, 0] call A3C_ui_shared_fnc_lbSetCurSel;
};