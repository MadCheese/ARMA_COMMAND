#include "..\..\dialog_defines.hpp"
#include "..\..\script_component.hpp"

// A3C_ui_radialMenu_fnc_reArm_openUi

private _isSingleUnit = (count A3C_RD_UNITS) == 1;

A3C_ReArm_Options = [];
BV_LB1 = 10;
BV_LB2 = 11;

private _display = findDisplay IDD_RADIAL_MENU;
private _sourcesListBox = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX;
private _sourcesHeader = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER;
private _contentHeader = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER;
private _background = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND;
private _goButton = _display displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN;

// Populate UI headers.
_sourcesHeader ctrlSetText "Containers";

if (_isSingleUnit) then {
	_contentHeader ctrlSetText "Content: DoubleClick to equip";
} else {
	_contentHeader ctrlSetText "Content (info only)";
};

_background ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
_goButton ctrlSetText "Re-Arm";

{
	lbClear _x;
} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

{
	_x ctrlShow true;
} forEach (["radial_extensionRight"] call FUNC(ctrlGroup));

// Find and sort rearm sources.
{
	private _unit = _x;
	private _unitRearmSources = [
		_unit,
		"PRI_RESUPPLY",
		"SEC_REARM",
		false,
		[]
	] call A3C_main_fnc_getRearmSources;

	{
		A3C_ReArm_Options pushBackUnique _x;
	} forEach _unitRearmSources;
} forEach A3C_RD_UNITS;

// Ordering stage 1.
if (_isSingleUnit) then {
	private _selectedUnit = A3C_RD_UNITS select 0;

	A3C_ReArm_Options = [
		A3C_ReArm_Options,
		[],
		{ _x distance _selectedUnit },
		"ASCEND"
	] call BIS_fnc_sortBy;
} else {
	A3C_ReArm_Options = [
		A3C_ReArm_Options,
		[],
		{ ["LIGHT", _x] call A3C_main_fnc_getRearmSourceQuality },
		"DESCEND"
	] call BIS_fnc_sortBy;
};

// Ordering stage 2: place bodies and holders last, keep rest of order intact.
private _normalSources = [];
private _specialSources = [];

{
	if (_x isKindOf "Man" || { typeOf _x in A3C_WeaponHolderClasses }) then {
		_specialSources pushBackUnique _x;
	} else {
		_normalSources pushBackUnique _x;
	};
} forEach A3C_ReArm_Options;

A3C_ReArm_Options = _normalSources + _specialSources;

// Populate UI listboxes.
{
	private _source = _x;
	private _sourceType = typeOf _source;

	private _icon = "";

	if (_source isKindOf "Man") then {
		_icon = "\a3\ui_f\data\GUI\Cfg\Hints\Death_ca.paa";
	} else {
		if (_sourceType in A3C_WeaponHolderClasses) then {
			_icon = "\a3\ui_f\data\GUI\Cfg\Hints\Rifle_ca.paa";
		} else {
			_icon = getText (configFile >> "CfgVehicles" >> _sourceType >> "picture");

			if (_icon in ["pictureThing"]) then {
				_icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa";
			};
		};
	};

	private _distanceText = "";

	if (_isSingleUnit) then {
		_distanceText = format [
			"(%1m)",
			round (_source distance (A3C_RD_UNITS select 0))
		];
	};

	private _displayName = getText (
		configFile >> "CfgVehicles" >> _sourceType >> "displayName"
	);

	[
		[
			_displayName + _distanceText,
			_sourceType,
			_source,
			_sourcesListBox,
			_icon
		]
	] call A3C_UI_RADIAL_LB_ADD;
} forEach A3C_ReArm_Options;

[_sourcesListBox, 0, true] call A3C_setCurSel;