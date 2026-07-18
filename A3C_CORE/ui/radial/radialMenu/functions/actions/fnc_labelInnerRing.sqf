#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

params ["_commandLevel"];

private _display = findDisplay IDD_RADIAL_MENU;

//-- Clean wipe: hide all radial UI elements (inner ring, outer ring buttons, and outer backgrounds)
{
	_x ctrlShow false;
} forEach (
	(["radial_innerButtonMacros"] call FUNC(ctrlGroup)) +
	(["radial_outerButtonMacros"] call FUNC(ctrlGroup)) +
	(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
);

{
	_x ctrlShow false;
} forEach (["radial_extensionLeft"] call FUNC(ctrlGroup));

//-- No need to reset formation stuff. When switched, RD_UNITS is [] anyway.
A3C_RADIAL_HOVER = true;

(_display displayCtrl IDC_RADIAL_INNERRING_FORMATION_IMG)
	ctrlSetText "A3C_CORE\ui\pictures\icon_menu_form_Wedge.Paa";
(_display displayCtrl IDC_RADIAL_INNERRING_FORMATION_BTN)
	ctrlSetToolTip "FORMATIONS";

//-- Ensure formation button is visible.
{
	_x ctrlShow true;
} forEach ([
	["innerFormationImg"] call FUNC(ctrl),
	["innerFormationBtn"] call FUNC(ctrl)
] select {!isNull _x});

if (_commandLevel == "SQUAD") then {
	showHUD ([false] + (shownHUD select [1, 10]));

	(_display displayCtrl IDC_RADIAL_CORE_REFRESHDATA_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_CORE_REFRESHDATA_BTN) ctrlShow true;

	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG)
		ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN)
		ctrlSetToolTip "AI Actions";

	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_ROE_main.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_BTN)
		ctrlSetToolTip "RULES OF ENGAGEMENT";

	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_groupManagement.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN)
		ctrlSetToolTip "AI AUTO_FUNCTIONS";

	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN)
		ctrlSetToolTip "AI STANCES (RMB: TOGGLE GOCODES)";

	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN)
		ctrlSetToolTip "WEAPON ITEMS";

	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN)
		ctrlSetToolTip "LMB: TOGGLE VEHICLE OPTIONS || RMB: DISMOUNT SELECTED UNITS";

	{
		_x ctrlShow true;
	} forEach (["radial_innerButtonMacros"] call FUNC(ctrlGroup));

	[0] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;
	[] call A3C_ui_radialMenu_fnc_squad_labelOuterRingGrenades;

	(_display displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;
} else {
	showHUD ([true] + (shownHUD select [1, 10]));

	[] call A3C_ui_shared_fnc_createDashBoard;

	(_display displayCtrl IDC_RADIAL_CORE_REFRESHDATA_IMG) ctrlShow false;
	(_display displayCtrl IDC_RADIAL_CORE_REFRESHDATA_BTN) ctrlShow false;

	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_pin.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ACTIONS_BTN)
		ctrlSetToolTip format [
			"MOVE - CONFIRM WITH 'Spacebar', CANCEL BY RELEASING %1",
			["A3C", "A3C_KeyFnc_Menu"] call A3C_ui_shared_fnc_getKeybindTranslation
		];

	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_IMG)
		ctrlSetText "\a3\ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ROE_BTN)
		ctrlSetToolTip "HC-ACTIONS";

	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_AUTO_BTN)
		ctrlSetToolTip "HC STANCES";

	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_STANCES_BTN)
		ctrlSetToolTip "GO CODES";

	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_behaviour.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_BTN)
		ctrlSetToolTip "HC BEHAVIOUR";

	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_IMG)
		ctrlSetText "A3C_CORE\ui\pictures\icon_menu_combatMode.paa";
	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN) ctrlShow true;
	(_display displayCtrl IDC_RADIAL_INNERRING_VEHICLES_BTN)
		ctrlSetToolTip "HC COMBAT-MODE";

	A3C_RD_BOOL_UNITS = true;

	{
		_x ctrlShow true;
	} forEach (["radial_holdContinueMacros"] call FUNC(ctrlGroup));
};

(_display displayCtrl IDC_RADIAL_EXTENSIONLEFT_TC_BOX) ctrlShow false;
[IDD_RADIAL_MENU] call A3C_ui_shared_fnc_Tree_labelItems;