#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_squad_labelOuterRingGrenades

params ["_muzzle", "_mode"];

private _display = findDisplay IDD_RADIAL_MENU;

//-- Label parent button.
private _color = if (count A3C_AI_GREN_ARRAY == 0) then {
	[1, 1, 1, 0.3]
} else {
	[1, 1, 1, 0.6]
};

(_display displayCtrl IDC_RADIAL_INNERRING_GRENADES_IMG)
	ctrlSetText "A3C_CORE\ui\pictures\icon_menu_grenade.paa";
(_display displayCtrl IDC_RADIAL_INNERRING_GRENADES_IMG)
	ctrlSetTextColor _color;
(_display displayCtrl IDC_RADIAL_INNERRING_GRENADES_BTN)
	ctrlSetToolTip "AI Grenades";

//-- Sort grenades by usability.
A3C_AI_GREN_ARRAY = [
	A3C_AI_GREN_ARRAY,
	[],
	{
		private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
		private _number = 0;
		private _explosive = getNumber (configFile >> "CfgAmmo" >> _ammo >> "explosive");

		if (_explosive == 1) then {
			private _hit = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
			_number = 1000 * _hit;
		} else {
			_number = getNumber (configFile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
		};

		_number
	},
	"DESCEND"
] call BIS_fnc_sortBy;

if (A3C_RADIALMODE == "GRENADE") then {
	//-- Reset outer ring controls.
	{
		_x ctrlShow false;
	} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

	//-- Clear outer ring images.
	{
		_x ctrlSetText "";
	} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

	//-- Clear outer ring button tooltips.
	{
		_x ctrlSetToolTip "";
	} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));

	private _outerRingBackgroundIDs = ["PlaceHolder", "Left", "bottom", "Right", "Top"];

	//-- Outer ring backgrounds.
	private _outerRingBackgrounds = (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup)) select [1, 4];

	{
		private _ctrl = _x;
		private _index = _forEachIndex + 1;

		if (_index <= ((ceil ((count A3C_AI_GREN_ARRAY) / 4)) min 3)) then {
			_ctrl ctrlShow true;
			_ctrl ctrlSetText format [
				"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
				_outerRingBackgroundIDs select _index
			];
		} else {
			_ctrl ctrlShow false;
		};
	} forEach _outerRingBackgrounds;

	if (count A3C_AI_GREN_ARRAY == 0) exitWith {};

	//-- Label button images and functions.
	private _grenadeSlots = [
		[["outerLeft4Img"] call FUNC(ctrl), ["outerLeft4Btn"] call FUNC(ctrl), 16],
		[["outerLeft3Img"] call FUNC(ctrl), ["outerLeft3Btn"] call FUNC(ctrl), 15],
		[["outerLeft2Img"] call FUNC(ctrl), ["outerLeft2Btn"] call FUNC(ctrl), 14],
		[["outerLeft1Img"] call FUNC(ctrl), ["outerLeft1Btn"] call FUNC(ctrl), 13],

		[["outerBottom4Img"] call FUNC(ctrl), ["outerBottom4Btn"] call FUNC(ctrl), 12],
		[["outerBottom3Img"] call FUNC(ctrl), ["outerBottom3Btn"] call FUNC(ctrl), 11],
		[["outerBottom2Img"] call FUNC(ctrl), ["outerBottom2Btn"] call FUNC(ctrl), 10],
		[["outerBottom1Img"] call FUNC(ctrl), ["outerBottom1Btn"] call FUNC(ctrl), 9],

		[["outerRight4Img"] call FUNC(ctrl), ["outerRight4Btn"] call FUNC(ctrl), 8],
		[["outerRight3Img"] call FUNC(ctrl), ["outerRight3Btn"] call FUNC(ctrl), 7],
		[["outerRight2Img"] call FUNC(ctrl), ["outerRight2Btn"] call FUNC(ctrl), 6],
		[["outerRight1Img"] call FUNC(ctrl), ["outerRight1Btn"] call FUNC(ctrl), 5],

		[["outerTop4Img"] call FUNC(ctrl), ["outerTop4Btn"] call FUNC(ctrl), 4],
		[["outerTop3Img"] call FUNC(ctrl), ["outerTop3Btn"] call FUNC(ctrl), 3],
		[["outerTop2Img"] call FUNC(ctrl), ["outerTop2Btn"] call FUNC(ctrl), 2],
		[["outerTop1Img"] call FUNC(ctrl), ["outerTop1Btn"] call FUNC(ctrl), 1]
	];

	{
		private _slot = _grenadeSlots select _forEachIndex;
		_slot params ["_btnImage", "_btnClicker", "_buttonItem"];

		{
			_x ctrlShow true;
		} forEach [_btnImage, _btnClicker];

		_btnImage ctrlSetText getText (configFile >> "CfgMagazines" >> _x >> "picture");
		_btnClicker ctrlSetToolTip getText (configFile >> "CfgMagazines" >> _x >> "displayNameShort");

		call compile format [
			"
				A3C_OUTER_RING_BTN_fnc_%1 =
				[
					[],
					{
						A3C_GREN_MUZZLE = '%2';
						[] spawn A3C_ui_radialMenu_fnc_squad_startGTIgrenadeLoop;
					}
				];
			",
			_buttonItem,
			_x
		];
	} forEach (A3C_AI_GREN_ARRAY select [0, count _grenadeSlots]);
};