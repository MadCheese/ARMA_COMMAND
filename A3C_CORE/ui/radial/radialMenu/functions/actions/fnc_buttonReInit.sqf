#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_buttonReInit

{
	if (isPlayer _x) then {
		A3C_RD_UNITS = A3C_RD_UNITS - [_x];
		player groupSelectUnit [_x, false];
	};
} forEach A3C_RD_UNITS;

private _display = findDisplay IDD_RADIAL_MENU;

(_display displayCtrl IDC_RADIAL_INNERRING_ITEMS_IMG)
	ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_rifle.paa";

[0] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;

{
	{
		if (_x call BIS_fnc_IsThrowable) then {
			if !(_x in A3C_AI_GREN_ARRAY) then {
				A3C_AI_GREN_ARRAY pushBack _x;
			};
		};
	} forEach magazines _x;
} forEach A3C_RD_UNITS;

switch (A3C_RADIALMODE) do {
	case "ITEMS": {
		private _weaponClass = "";
		private _weaponText = "";

		if ({currentWeapon _x == handGunWeapon _x} count A3C_RD_UNITS > 0) then {
			_weaponClass = primaryWeapon (A3C_RD_UNITS select 0);
			_weaponText = "Main Weapon";
		} else {
			_weaponClass = handGunWeapon (A3C_RD_UNITS select 0);
			_weaponText = "Hand Gun";
		};

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_3_IMG)
			ctrlSetText "A3C_CORE\ui\pictures\icon_menu_item_pistol_switch.paa";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_3_BTN)
			ctrlSetToolTip format ["Switch to %1", _weaponText];

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG)
			ctrlSetText "";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN)
			ctrlSetToolTip "";

		BV_MEDICAL = 0;
		BV_CBMODE = 0;

		private _laserImage = if (
			{
				_x isIRLaserOn currentWeapon _x ||
				{
					_x isFlashLightOn currentWeapon _x
				}
			} count (A3C_RD_UNITS - [player]) > 0
		) then {
			"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa"
		} else {
			"A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa"
		};

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_2_IMG)
			ctrlSetText _laserImage;
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_2_BTN)
			ctrlSetToolTip "LMB: ENABLE IR (requires 'DANGER') , RMB: DISABLE IR";

		private _strobeImage = if (
			{
				count (_x getVariable "A3C_STROBE") > 0
			} count (A3C_RD_UNITS - [player]) > 0
		) then {
			"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa"
		} else {
			"A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa"
		};

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG)
			ctrlSetText _strobeImage;
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN)
			ctrlSetToolTip "LMB: ATTACH IR-STROBES , RMB: DETACH IR-STROBES";
	};

	case "VEHS": {
		BV_MEDICAL = 0;
		BV_CBMODE = 0;

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_1_IMG)
			ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\plane_ca.paa";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_1_BTN)
			ctrlSetToolTip "JET";

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_2_IMG)
			ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_2_BTN)
			ctrlSetToolTip "HELI";

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_3_IMG)
			ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_3_BTN)
			ctrlSetToolTip "TRACKED";

		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_IMG)
			ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayGarage\car_ca.paa";
		(_display displayCtrl IDC_RADIAL_OUTERBOTTOM_4_BTN)
			ctrlSetToolTip "WHEELED";

		//-- BOTTOM RING: reset icon color
		{
			_x ctrlSetTextColor [1, 1, 1, 0.6];
		} forEach (["radial_outerBottomImages"] call FUNC(ctrlGroup));
	};
};