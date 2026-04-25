#include "script_component.hpp"
#include "dialog_defines.hpp"

#define BAR_X (-10.5 * GUI_GRID_W + GUI_GRID_X)
#define BAR_W (16 * GUI_GRID_W)
#define BAR_H (15.5 * GUI_GRID_H)
#define TREE_W (13 * GUI_GRID_W)
#define TEAMCOL_FRAME_H ((0.03 * safezoneH) + ((safezoneY + safeZoneH) * 0.0141935))


class A3C_DSP_RadialMenu
{
	idd = IDD_RADIAL_MENU;
	movingEnable = false;

	onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
	onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));

	onKeyDown = EXPAND_AND_QUOTE(_this call FUNC(onKeyDown));
	onKeyUp = EXPAND_AND_QUOTE(_this call FUNC(onKeyUp));
	onMouseButtonDown = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonDown));

	
	class ControlsBackground {
		//---------------------------------------------------------------------------------------------
		//---------- RADIAL BACKGROUND: CORE & INNER RING ---------------------------------------------
		//---------------------------------------------------------------------------------------------
		class RADIAL_BG_CORE: A3C_RscPicture
		{
			idc = IDC_RADIAL_BG_CORE;
			text = "A3C_CORE\ui\pictures\BG_Radial_Core.paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
	};

	class Controls
	{
		//---------------------------------------------------------------------------------------------
		//---------- A3C-SETTINGS BUTTON --------------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		class RADIAL_SETTINGS_IMG: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_preferences.paa";
			colorText[] = {1,1,1,0.8};
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
		};

		class RADIAL_SETTINGS_BTN : A3C_RscButton_Invisible
		{
			idc = -1;
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
			tooltip = "Access A3C Settings";
			action = "[] spawn A3C_UI_settingsMenu_fnc_openSettings";
		};

		//---------------------------------------------------------------------------------------------
		//---------- Radial Outer Ring Background Parts -----------------------------------------------
		//---------------------------------------------------------------------------------------------
		class RADIAL_BG_TOP: A3C_RscPicture
		{
			idc = IDC_RADIAL_BG_TOP; //8001;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_RIGHT: A3C_RscPicture
		{
			idc = IDC_RADIAL_BG_RIGHT; //8002;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_BOTTOM: A3C_RscPicture
		{
			idc = IDC_RADIAL_BG_BOTTOM; //8003;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_LEFT: A3C_RscPicture
		{
			idc = IDC_RADIAL_BG_LEFT; //8004;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};

		//---------------------------------------------------------------------------------------------
		//---------- Radial CORE ----------------------------------------------------------------------
		//---------------------------------------------------------------------------------------------

		class RADIAL_CORE_REFRESHDATA_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_CORE_REFRESHDATA_IMG; //21000;
			text = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
			x = 0.493 - (0.5 * (2.5 * GUI_GRID_W));
			y = 0.5 - (0.5 * (1.875 * GUI_GRID_H));
			w = 2.5 * GUI_GRID_W;
			h = 1.875 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class RADIAL_CORE_REFRESHDATA_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_CORE_REFRESHDATA_BTN; //21001;
			onMouseButtonDown = "['REFRESH',(_this select 1),(_this select 4)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 0.493 - (0.5 * (2.5 * GUI_GRID_W));
			y = 0.5 - (0.5 * (1.875 * GUI_GRID_H));
			w = 2.5 * GUI_GRID_W;
			h = 1.875 * GUI_GRID_H;
			tooltip = "left click: reset group. right click: call selected units back to group";
		};

		//---------------------------------------------------------------------------------------------
		//---------- Radial INNER Ring Buttons --------------------------------------------------------
		//---------------------------------------------------------------------------------------------

		class RADIAL_INNERRING_ACTIONS_IMG: A3C_RscPicture
		{
			//-- Note: Included in loops up until 9016
			idc = IDC_RADIAL_INNERRING_ACTIONS_IMG; //9001;
			x = 16.71 * GUI_GRID_W + GUI_GRID_X;
			y = 7.45 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class RADIAL_INNERRING_ACTIONS_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_ACTIONS_BTN; //9002;
			onMouseEnter = "['ACTIONS'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ACTIONS',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			
			x = 15.48 * GUI_GRID_W + GUI_GRID_X;
			y = 7.11 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
		};

		class RADIAL_INNERRING_ROE_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_ROE_IMG; //9003;
			x = 21.03 * GUI_GRID_W + GUI_GRID_X;
			y = 7.57 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class RADIAL_INNERRING_ROE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_ROE_BTN; //9004;
			onMouseEnter = "['ROE'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ROE',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 20 * GUI_GRID_W + GUI_GRID_X;
			y = 7 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "rules of engagement";
		};

		class RADIAL_INNERRING_AUTO_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_AUTO_IMG; //9005;
			x = 24 * GUI_GRID_W + GUI_GRID_X;
			y = 10 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class RADIAL_INNERRING_AUTO_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_AUTO_BTN; //9006;
			onMouseEnter = "['BRAIN'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['BRAIN',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9.98 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI Auto-Functions";
		};

		class RADIAL_INNERRING_STANCES_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_STANCES_IMG; //9007;
			colorText[] = {1,1,1,0.6};
			x = 24.16 * GUI_GRID_W + GUI_GRID_X;
			y = 13.54 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};

		class RADIAL_INNERRING_STANCES_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_STANCES_BTN; //9008;
			onMouseEnter = "['STANCE'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['STANCE',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 3.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI-Stances (RMB: Toggle Go-Codes)";
		};

		class RADIAL_INNERRING_ITEMS_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_ITEMS_IMG; //9009;
			colorText[] = {1,1,1,0.6};
			text = "";
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};

		class RADIAL_INNERRING_ITEMS_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_ITEMS_BTN; //9010;
			onMouseEnter = "['ITEMS'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ITEMS',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 20.16 * GUI_GRID_W + GUI_GRID_X;
			y = 15.96 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "Weapon Items";
		};

		class RADIAL_INNERRING_VEHICLES_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_VEHICLES_IMG; //9011;
			colorText[] = {1,1,1,0.6};
			x = 16.5 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class RADIAL_INNERRING_VEHICLES_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_VEHICLES_BTN; //9012;
			onMouseEnter = "['VEHICLES'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['VEHICLES',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 15.6 * GUI_GRID_W + GUI_GRID_X;
			y = 15.79 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "LClick: Toggle Vehicle options || RClick: Dismount Selected Units";
		};

		class RADIAL_INNERRING_FORMATION_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_FORMATION_IMG; //9013;
			x = 13.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class RADIAL_INNERRING_FORMATION_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_FORMATION_BTN; //9014;
			onMouseEnter = "['RINGFORM'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['RINGFORM',(_this select 1),(_this select 4)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 3.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "Formations";
		};

		class RADIAL_INNERRING_GRENADES_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_INNERRING_GRENADES_IMG; //9015;
			colorText[] = {1,1,1,0.6};
			x = 13.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class RADIAL_INNERRING_GRENADES_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_INNERRING_GRENADES_BTN; //9016;
			onMouseEnter = "['GRENADE'] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['GRENADE',(_this select 1)] call A3C_UI_RADIAL_BTN_FNC_RING_INNER";
			x = 12.4 * GUI_GRID_W + GUI_GRID_X;
			y = 9.83 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
		};

		
		

		//---------------------------------------------------------------------------------------------
		//---------- Radial Outer Ring Buttons --------------------------------------------------------
		//---------------------------------------------------------------------------------------------

		class RADIAL_OUTERTOP_1_IMG: A3C_RscPicture
		{
			//-- NOTE: INCLUDED IN LOOPS (UP TO 10015, 10023, 10031 and 10039)
			idc = IDC_RADIAL_OUTERTOP_1_IMG; //10008;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERTOP_1_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERTOP_1_BTN; //10009;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_1 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_1 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERTOP_2_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERTOP_2_IMG; //10010;
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERTOP_2_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERTOP_2_BTN; //10011;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_2 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_2 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Fire Only AT Given Targets";
		};
		class RADIAL_OUTERTOP_3_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERTOP_3_IMG; //10012;
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERTOP_3_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERTOP_3_BTN; //10013;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_3 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_3 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Units Hold Fire Until You Fire Your Weapon";
		};
		class RADIAL_OUTERTOP_4_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERTOP_4_IMG; //10014;
			x = 24.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERTOP_4_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERTOP_4_BTN; //10015;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_4 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_4 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 24.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Toggle AI Auto-Danger";
		};
		class RADIAL_OUTERRIGHT_1_IMG: A3C_RscPicture
		{
			//-- Note: Included in loops up till 10023
			idc = IDC_RADIAL_OUTERRIGHT_1_IMG; //10016;
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERRIGHT_1_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERRIGHT_1_BTN; //10017;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_5 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_5 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "reset AI looking direction";
		};
		class RADIAL_OUTERRIGHT_2_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERRIGHT_2_IMG; //10018;
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERRIGHT_2_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERRIGHT_2_BTN; //10019;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_6 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_6 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERRIGHT_3_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERRIGHT_3_IMG; //10020;
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERRIGHT_3_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERRIGHT_3_BTN; //10021;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_7 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_7 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to cover";
		};
		class RADIAL_OUTERRIGHT_4_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERRIGHT_4_IMG; //10022;
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERRIGHT_4_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERRIGHT_4_BTN; //10023;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_8 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_8 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to rearm";
		};
		class RADIAL_OUTERBOTTOM_1_IMG: A3C_RscPicture
		{
			//-- note: included in loops up till 10031
			idc = IDC_RADIAL_OUTERBOTTOM_1_IMG; //10024;
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERBOTTOM_1_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERBOTTOM_1_BTN; //10025;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_9 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_9 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERBOTTOM_2_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERBOTTOM_2_IMG; //10026;
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERBOTTOM_2_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERBOTTOM_2_BTN; //10027;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_10 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_10 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERBOTTOM_3_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERBOTTOM_3_IMG; //10028;
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class RADIAL_OUTERBOTTOM_3_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERBOTTOM_3_BTN; //10029;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_11 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_11 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERBOTTOM_4_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERBOTTOM_4_IMG; //10030;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERBOTTOM_4_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERBOTTOM_4_BTN; //10031;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_12 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_12 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_1_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERLEFT_1_IMG; //10032;
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_1_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERLEFT_1_BTN; //10033;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_13 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_13 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_2_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERLEFT_2_IMG; //10034;
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_2_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERLEFT_2_BTN; //10035;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_14 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_14 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_3_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERLEFT_3_IMG; //10036;
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_3_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_OUTERLEFT_3_BTN; //10037;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_15 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_15 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_4_IMG: A3C_RscPicture
		{
			idc = IDC_RADIAL_OUTERLEFT_4_IMG; //10038;
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class RADIAL_OUTERLEFT_4_BTN: A3C_RscButton_Invisible
		{
            //-- NOTE: THIS IS ONE OF THE TRICKY ONES FOR LOOPED CONTROL
			idc = IDC_RADIAL_OUTERLEFT_4_BTN; //10039;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_16 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_16 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		//---------------------------------------------------------------------------------------------
		//---------- Right Ring Extension: Listboxes --------------------------------------------------
		//---------------------------------------------------------------------------------------------

		class RADIAL_EXTENSIONRIGHT_BACKGROUND: A3C_RscPicture
		{
            //-- NOTE: THIS IS ANOTHER TRICKY ONE FOR LOOPS, FROM 8053 to 8058
			idc = IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND; //8053;
			x = 33 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};

		class RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER: A3C_RscText
		{
			idc = IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER; //8057;
			style = 0;
			text = "";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};

		class RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX: A3C_LISTBOX
		{
			idc = IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX; //8054;
			style = CT_LISTBOX;
			onLBSelChanged  = "[BV_LB1,(_this select 1),IDD_RADIAL_MENU] spawn A3C_LB_Change";
			shadow = 0.75;
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4.5 * GUI_GRID_H;
		};

		class RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER: A3C_RscText
		{
			idc = IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER; //8058;
			style = 0;
			text = "";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 12 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};

		class RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX : A3C_LISTBOX
		{
			idc = IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX; //8055;
			style = CT_LISTBOX;   //CT_LISTNBOX  //ST_GROUP_BOX
			onLBSelChanged  = "[BV_LB2,(_this select 1),IDD_RADIAL_MENU] spawn A3C_LB_Change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.3) / 1.3) / 25) * 1)";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4 * GUI_GRID_H;
		};
		class RADIAL_EXTENSIONRIGHT_GO_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_EXTENSIONRIGHT_GO_BTN; //8056;
			action = "if (A3C_LBR_1 == 'MEDICAL') then {[group player, 0] spawn A3C_MEDICAL_START;} else { {[_x,A3C_TARGETVEH] spawn A3C_ReArm_Auto_Evaluate} foreach (groupSelectedUnits player); player groupradio 'SentCmdRearm';}";
			x = 38.5 * GUI_GRID_W + GUI_GRID_X;
			y = 18 * GUI_GRID_H + GUI_GRID_Y;
			w = 6.5 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		
		

		//---------------------------------------------------------------------------------------------
		//---------- Right Ring Extension: HC-DashBoard -----------------------------------------------
		//---------------------------------------------------------------------------------------------
		class RADIAL_DASHBOARD_PARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_RADIAL_DASHBOARD_PARENT; //303030;
			x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			y = 0.414993 * safezoneH + safezoneY;
			w = 0.240009 * safezoneW;
			h = 0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
			class Controls
			{
				class RADIAL_DASHBOARD_BG: A3C_RscPicture
				{
					idc = IDC_RADIAL_DASHBOARD_BG; //11015;
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 4.9593e-007 * safezoneW;
					y = 0 * safezoneH;
					w = 0.240009 * safezoneW;
					h = 0.221018 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};

				class RADIAL_DASHBOARD_GROUPNAME: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_GROUPNAME; //11001;
					text = "";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.160006 * safezoneW;
					h = 0.0340028 * safezoneH;
					sizeEx = "0.04 / (getResolution select 5)";
				};

				class RADIAL_DASHBOARD_GROUPICON: A3C_RscPicture
				{
					idc = IDC_RADIAL_DASHBOARD_GROUPICON; //11002;
					x = 0.168007 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.0720028 * safezoneW;
					h = 0.11901 * safezoneH;
				};

				class RADIAL_DASHBOARD_TXT_UNITSIZE: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_TXT_UNITSIZE; //11003;
					text = "Unit Size:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5));
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class RADIAL_DASHBOARD_TXT_LOCATION: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_TXT_LOCATION; //11004;
					text = "Location:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5)) + (1.1 * (0.021 / (getResolution select 5)) );
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};
				class RADIAL_DASHBOARD_TXT_TASK: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_TXT_TASK; //11005;
					text = "Current Task:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5))  + (2.2 * (0.021 / (getResolution select 5)) );
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class RADIAL_DASHBOARD_PGBARS_BG: A3C_RscPicture
				{
					idc = IDC_RADIAL_DASHBOARD_PGBARS_BG; //12002;
					text = "#(argb,8,8,3)color(0.5,0.5,0.5,0.5)";
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class RADIAL_DASHBOARD_PG_HEALTH_TXT: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_PG_HEALTH_TXT; //12000;
					text = "Health (Soldiers)";
					style = 0;
					x = -3.81485e-008 * safezoneW;
					y = (0.136011 * safezoneH) - ( 0.021 / (getResolution select 5));
					w = 0.0800031 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class RADIAL_DASHBOARD_PG_HEALTH_BAR: A3C_RscProgress
				{
					idc = IDC_RADIAL_DASHBOARD_PG_HEALTH_BAR; //12001;
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class RADIAL_DASHBOARD_PG_ROSTER_TXT: A3C_RscText
				{
					idc = IDC_RADIAL_DASHBOARD_PG_ROSTER_TXT; //11012;
					text = "Roster";
					style = 0;
					x = 0.0960037 * safezoneW;
					y = (0.136011 * safezoneH) - ( 0.021 / (getResolution select 5));
					w = 0.0480019 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};
				class RADIAL_DASHBOARD_PG_ROSTER_STRUCTURED: A3C_RscStructuredText
				{
					idc = IDC_RADIAL_DASHBOARD_PG_ROSTER_STRUCTURED; //11014;
					x = 0.104004 * safezoneW;
					y = 0.136011 * safezoneH;
					w = 0.136005 * safezoneW;
					h = 0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};
			};
		};
		//---------------------------------------------------------------------------------------------
		//---------- Left Ring Extension: Unit selectors ----------------------------------------------
		//---------------------------------------------------------------------------------------------

		class RADIAL_EXTENSIONLEFT_REVEALER: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_EXTENSIONLEFT_REVEALER; //8070;
			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
			onMouseEnter = "['OPEN'] call A3C_UI_RADIAL_TOGGLE_LEFT_EXT";
		};

		class RADIAL_EXTENSIONLEFT_HIDER: A3C_RscButton_Invisible
		{
			idc = IDC_RADIAL_EXTENSIONLEFT_HIDER; //80701;
			x = (-10.5 * GUI_GRID_W + GUI_GRID_X) - (BAR_W);
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
			onMouseButtonDown = "['CLOSE'] call A3C_UI_RADIAL_TOGGLE_LEFT_EXT";
		};

		class RADIAL_EXTENSIONLEFT_BG: A3C_RscPicture
		{
			idc = IDC_RADIAL_EXTENSIONLEFT_BG; //8096;
			text = "A3C_CORE\ui\pictures\BG_Radial_ExtensionLeft.paa";
			colorText[] = {1,1,1,1};
			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
		};

		

		class RADIAL_EXTENSIONLEFT_CTRLSGROUP: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_RADIAL_EXTENSIONLEFT_CTRLSGROUP; //8071;
			onMouseButtonDown = "_this call A3C_UI_RADIAL_TREE_MouseDown;";
			x = BAR_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;

			class ControlsBackground
			{
			};

       		class Controls
			{
				class RADIAL_EXTENSIONLEFT_HOLD_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_HOLD_IMG; //8097;
					text = "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";
					x = 6.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class RADIAL_EXTENSIONLEFT_HOLD_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_HOLD_BTN; //8098;
					onMouseButtonDown = "A3C_RD_UNITS call A3C_UNIT_HOLD;";
					x = 6.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					tooltip = "Selected units STANDBY";
				};
				class RADIAL_EXTENSIONLEFT_CONTINUE_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_CONTINUE_IMG; //8099;
					text = "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class RADIAL_EXTENSIONLEFT_CONTINUE_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_CONTINUE_BTN; //9000;
					onMouseButtonDown = "A3C_RD_UNITS call A3C_UNIT_CONTINUE;";
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					tooltip = "Selected units CONTINUE";
				};

				class RADIAL_EXTENSIONLEFT_TEAMCOLOR_BG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TEAMCOLOR_BG; //7077;
					text = "#(argb,8,8,3)color(0,0,0,0.3)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = BAR_W;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TEAMCOLOR_FRAME: A3C_RscFrame
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TEAMCOLOR_FRAME; //7079;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = BAR_W;
					h = TEAMCOL_FRAME_H;
					colorBackground[] =
					{
						0,
						0,
						0,
						1
					};
					colorText[] =
					{
						0,
						0,
						0,
						1
					};
					sizeEx = 0.7 * GUI_GRID_H;
				};

				class RADIAL_EXTENSIONLEFT_TREE: A3C_CT_TREE
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TREE; //202020;
					x = 0;
					y = (2 * GUI_GRID_H + GUI_GRID_Y) + TEAMCOL_FRAME_H;
					w = BAR_W;
					h = BAR_H - (0.5 * GUI_GRID_H + GUI_GRID_Y) - ((2 * GUI_GRID_H + GUI_GRID_Y) + ( 0.0330053 * safezoneH)); //-- subtract Y of HOLD/CONT button to align to the bottow of BAR
					onTreeLButtonDown = "_this call A3C_TREE_TVCHANGE; false";
					onTreeCollapsed = "[_this,'COLLAPSE',false,0.1] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;  false";
					onTreeExpanded = "[_this,'OPEN',false,0.1] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;  false";
					sizeEx = 0.03 / (getResolution select 5);
					colorBackground[] = {0.2,0.2,0.2,0.3};
					colorBorder[] = {0,0,0,0};
				};

				//-- Teamcolor boxes
				class RADIAL_EXTENSIONLEFT_TCBOX_RED_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_RED_IMG; //1000;
					colorText[] = {1,0,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_RED_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_RED_BTN; //1001;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					tooltip = "select team red (RMB for HUD mode)";
					toolTipColorShade[] = {1,0,0,0.5};
					onMouseButtonDown = "['Red',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_GREEN_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_GREEN_IMG; //1002;
					colorText[] = {0,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_GREEN_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_GREEN_BTN; //1003;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					tooltip = "select team green (RMB for HUD mode)";
					toolTipColorShade[] = {0,1,0,0.5};
					onMouseButtonDown = "['GREEN',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_BLUE_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_BLUE_IMG; //1004;
					colorText[] = {0,0,1,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_BLUE_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_BLUE_BTN; //1005;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {0,0,1,0.5};
					tooltip = "select team blue (RMB for HUD mode)";
					onMouseButtonDown = "['Blue',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_YELLOW_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_YELLOW_IMG; //1006;
					colorText[] = {1,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_YELLOW_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_YELLOW_BTN; //1007;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {1,1,0,0.5};
					tooltip = "select team yellow (RMB for HUD mode)";
					onMouseButtonDown = "['YELLOW',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_WHITE_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_WHITE_IMG; //1008;
					colorText[] = {1,1,1,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_WHITE_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_WHITE_BTN; //1009;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {1,1,1,0.5};
					tooltip = "select team white (RMB for HUD mode)";
					onMouseButtonDown = "['MAIN',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_PURPLE_IMG: A3C_RscPicture
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_PURPLE_IMG; //1010;
					colorText[] = {0.5,0.2,0.6,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class RADIAL_EXTENSIONLEFT_TCBOX_PURPLE_BTN : A3C_RscButton_Invisible
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TCBOX_PURPLE_BTN; //1011;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "select all units (RMB for HUD mode)";
					onMouseButtonDown = "['Purple',(_this select 1),(_this select 5)] call A3C_UI_RADIAL_FNC_TEAMCOLOR";
				};

				class RADIAL_EXTENSIONLEFT_TC_BOX: A3C_LISTBOX
				{
					idc = IDC_RADIAL_EXTENSIONLEFT_TC_BOX; //8095;
					text = "";
					style = CT_LISTBOX;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 6.5 * GUI_GRID_W;
					h = 5.1 * GUI_GRID_H;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),IDD_RADIAL_MENU] call A3C_LB_Change";
				};
   			};
    	};
	};
};