#define BAR_X (-10.5 * GUI_GRID_W + GUI_GRID_X)
#define BAR_W (16 * GUI_GRID_W)
#define BAR_H (15.5 * GUI_GRID_H)
#define TREE_W (13 * GUI_GRID_W)
#define TEAMCOL_FRAME_H ((0.03 * safezoneH) + ((safezoneY + safeZoneH) * 0.0141935))// (safezoneY + safeZoneH) * 0.0141935 should be A3C_MAP_GAMEUI_PADDING_Y

class A3C_MENU
{
	idd = 100040;
	movingenable = false;

	onKeyDown = "_this call A3C_UI_RADIAL_onKeyDown";
	onKeyUp = "_this call A3C_UI_RADIAL_onKeyUp";
	onMouseButtonDown = "_this call A3C_UI_RADIAL_onMouseButtonDown";
	
	class ControlsBackground {
		//-- Radial BG: Core + Inner Ring
		class RADIAL_BG_CORE: A3C_RscPicture
		{
			idc = 8000;
			text = "A3C_CORE\ui\pictures\BG_Radial_Core.paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
	};

	class Controls
	{
		//-- A3C SETTINGS BUTTON (BOTTOM RIGHT)
		class A3C_SETTINGS_IMG: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_preferences.paa";
			colorText[] = {1,1,1,0.8};
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
		};

		class A3C_SETTINGS_BTN : A3C_RscButton_Invisible
		{
			idc = -1;
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
			tooltip = "Access A3C Settings";
			action = "[] spawn A3C_UI_settingsMenu_fnc_openSettings";
		};

		//-- Radial BG: OUTER RING PARTS
		class RADIAL_BG_TOP: A3C_RscPicture
		{
			idc = 8001;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_RIGHT: A3C_RscPicture
		{
			idc = 8002;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_BOTTOM: A3C_RscPicture
		{
			idc = 8003;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class RADIAL_BG_LEFT: A3C_RscPicture
		{
			idc = 8004;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		

		//-- OUTER RING ACTIONS

		class A3C_Top_Btn_1: A3C_RscPicture
		{
			idc = 10008;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Top_Btn_1_1: A3C_RscButton_Invisible
		{
			idc = 10009;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_1 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_1 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Top_Btn_2: A3C_RscPicture
		{
			idc = 10010;
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Top_Btn_2_1: A3C_RscButton_Invisible
		{
			idc = 10011;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_2 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_2 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Fire Only AT Given Targets";
		};
		class A3C_Top_Btn_3: A3C_RscPicture
		{
			idc = 10012;
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Top_Btn_3_1: A3C_RscButton_Invisible
		{
			idc = 10013;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_3 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_3 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Units Hold Fire Until You Fire Your Weapon";
		};
		class A3C_Top_Btn_4: A3C_RscPicture
		{
			idc = 10014;
			x = 24.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Top_Btn_4_1: A3C_RscButton_Invisible
		{
			idc = 10015;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_4 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_4 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 24.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Toggle AI Auto-Danger";
		};
		class A3C_Right_Btn_1: A3C_RscPicture
		{
			idc = 10016;
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Right_Btn_1_2: A3C_RscButton_Invisible
		{
			idc = 10017;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_5 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_5 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "reset AI looking direction";
		};
		class A3C_Right_Btn_2: A3C_RscPicture
		{
			idc = 10018;
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Right_Btn_2_1: A3C_RscButton_Invisible
		{
			idc = 10019;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_6 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_6 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Right_Btn_3: A3C_RscPicture
		{
			idc = 10020;
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Right_Btn_3_1: A3C_RscButton_Invisible
		{
			idc = 10021;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_7 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_7 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to cover";
		};
		class A3C_Right_Btn_4: A3C_RscPicture
		{
			idc = 10022;
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Right_Btn_4_1: A3C_RscButton_Invisible
		{
			idc = 10023;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_8 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_8 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to rearm";
		};
		class A3C_Bottom_Btn_1: A3C_RscPicture
		{
			idc = 10024;
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_1_1: A3C_RscButton_Invisible
		{
			idc = 10025;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_9 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_9 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_2: A3C_RscPicture
		{
			idc = 10026;
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_2_1: A3C_RscButton_Invisible
		{
			idc = 10027;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_10 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_10 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_3: A3C_RscPicture
		{
			idc = 10028;
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_3_1: A3C_RscButton_Invisible
		{
			idc = 10029;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_11 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_11 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Bottom_Btn_4: A3C_RscPicture
		{
			idc = 10030;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Bottom_Btn_4_1: A3C_RscButton_Invisible
		{
			idc = 10031;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_12 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_12 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_1: A3C_RscPicture
		{
			idc = 10032;
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_1_1: A3C_RscButton_Invisible
		{
			idc = 10033;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_13 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_13 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_2: A3C_RscPicture
		{
			idc = 10034;
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_2_1: A3C_RscButton_Invisible
		{
			idc = 10035;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_14 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_14 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_3: A3C_RscPicture
		{
			idc = 10036;
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_3_1: A3C_RscButton_Invisible
		{
			idc = 10037;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_15 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_15 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 8.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_4: A3C_RscPicture
		{
			idc = 10038;
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		class A3C_Left_Btn_4_1: A3C_RscButton_Invisible
		{
			idc = 10039;
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_16 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_16 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};

		// -- INNER CIRCLE BUTTONS

		class A3C_MENU_ACTIONS_IMG: A3C_RscPicture
		{
			idc = 9001;
			x = 16.71 * GUI_GRID_W + GUI_GRID_X;
			y = 7.45 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_MENU_ACTIONS_BTN: A3C_RscButton_Invisible
		{
			onMouseEnter = "['ACTIONS'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ACTIONS',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			idc = 9002;
			x = 15.48 * GUI_GRID_W + GUI_GRID_X;
			y = 7.11 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
		};

		class A3C_MENU_ROE: A3C_RscPicture
		{
			idc = 9003;
			x = 21.03 * GUI_GRID_W + GUI_GRID_X;
			y = 7.57 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_MENU_ROE_2: A3C_RscButton_Invisible
		{
			idc = 9004;
			onMouseEnter = "['ROE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ROE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 20 * GUI_GRID_W + GUI_GRID_X;
			y = 7 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "rules of engagement";
		};

		class A3C_Brain: A3C_RscPicture
		{
			idc = 9005;
			x = 24 * GUI_GRID_W + GUI_GRID_X;
			y = 10 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_Brain_2: A3C_RscButton_Invisible
		{
			idc = 9006;
			onMouseEnter = "['BRAIN'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['BRAIN',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9.98 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI Auto-Functions";
		};

		class A3C_Stances: A3C_RscPicture
		{
			idc = 9007;
			colorText[] = {1,1,1,0.6};
			x = 24.16 * GUI_GRID_W + GUI_GRID_X;
			y = 13.54 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};

		class A3C_Stances_2: A3C_RscButton_Invisible
		{
			idc = 9008;
			onMouseEnter = "['STANCE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['STANCE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 3.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI-Stances (RMB: Toggle Go-Codes)";
		};

		class A3C_Items: A3C_RscPicture
		{
			idc = 9009;
			colorText[] = {1,1,1,0.6};
			text = "";
			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};

		class A3C_Items_2: A3C_RscButton_Invisible
		{
			idc = 9010;
			onMouseEnter = "['ITEMS'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ITEMS',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 20.16 * GUI_GRID_W + GUI_GRID_X;
			y = 15.96 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "Weapon Items";
		};

		class A3C_Vehs: A3C_RscPicture
		{
			idc = 9011;
			colorText[] = {1,1,1,0.6};
			x = 16.5 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_Vehs_2: A3C_RscButton_Invisible
		{
			idc = 9012;
			onMouseEnter = "['VEHICLES'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['VEHICLES',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 15.6 * GUI_GRID_W + GUI_GRID_X;
			y = 15.79 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "LClick: Toggle Vehicle options || RClick: Dismount Selected Units";
		};

		class A3C_FormRing: A3C_RscPicture
		{
			idc = 9013;
			x = 13.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_FormRing_2: A3C_RscButton_Invisible
		{
			idc = 9014;
			onMouseEnter = "['RINGFORM'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['RINGFORM',(_this select 1),(_this select 4)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 3.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "Formations";
		};

		class A3C_MENU_GRENMAIN: A3C_RscPicture
		{
			idc = 9015;
			colorText[] = {1,1,1,0.6};
			x = 13.5 * GUI_GRID_W + GUI_GRID_X;
			y = 10 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_MENU_GRENMAIN_2: A3C_RscButton_Invisible
		{
			idc = 9016;
			onMouseEnter = "['GRENADE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['GRENADE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 12.4 * GUI_GRID_W + GUI_GRID_X;
			y = 9.83 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
		};

		class A3C_Refresh_Data: A3C_RscPicture
		{
			idc = 21000;
			text = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
			x = 0.493 - (0.5 * (2.5 * GUI_GRID_W));
			y = 0.5 - (0.5 * (1.875 * GUI_GRID_H));
			w = 2.5 * GUI_GRID_W;
			h = 1.875 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_Refresh_Data_2: A3C_RscButton_Invisible
		{
			idc = 21001;
			onMouseButtonDown = "['REFRESH',(_this select 1),(_this select 4)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 0.493 - (0.5 * (2.5 * GUI_GRID_W));
			y = 0.5 - (0.5 * (1.875 * GUI_GRID_H));
			w = 2.5 * GUI_GRID_W;
			h = 1.875 * GUI_GRID_H;
			tooltip = "left click: reset group. right click: call selected units back to group";
		};

		//-- RIGHT EXTENSION LISTBOXES

		class ExtraFrame: A3C_RscPicture
		{
			idc = 8053;
			x = 33 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};

		class RscVehList: A3C_LISTBOX
		{
			idc = 8054;
			style = CT_LISTBOX;
			onLBSelChanged  = "[BV_LB1,(_this select 1),100040] spawn A3C_LB_Change";
			shadow = 0.75;
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4.5 * GUI_GRID_H;
		};
		class RscVehList_1: A3C_LISTBOX
		{
			idc = 8055;
			style = CT_LISTBOX;   //CT_LISTNBOX  //ST_GROUP_BOX
			onLBSelChanged  = "[BV_LB2,(_this select 1),100040] spawn A3C_LB_Change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.3) / 1.3) / 25) * 1)";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4 * GUI_GRID_H;
		};
		class go: A3C_RscButton_Invisible
		{
			idc = 8056;
			action = "if (A3C_LBR_1 == 'MEDICAL') then {[group player, 0] spawn A3C_MEDICAL_START;} else { {[_x,A3C_TARGETVEH] spawn A3C_ReArm_Auto_Evaluate} foreach (groupSelectedUnits player); player groupradio 'SentCmdRearm';}";
			x = 38.5 * GUI_GRID_W + GUI_GRID_X;
			y = 18 * GUI_GRID_H + GUI_GRID_Y;
			w = 6.5 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class RscText_1000: A3C_RscText
		{
			idc = 8057;
			style = 0;
			text = "";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};
		class RscText_1004: A3C_RscText
		{
			idc = 8058;
			style = 0;
			text = "";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 12 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};

		class CommandBar_Revealer: A3C_RscButton_Invisible
		{
			idc = 8070;
			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
			onMouseEnter = "['OPEN'] call A3C_UI_RADIAL_TOGGLE_LEFT_EXT";
		};
		class L_ext_commandBar_BG: A3C_RscPicture
		{
			idc = 8096;
			text = "A3C_CORE\ui\pictures\BG_Radial_ExtensionLeft.paa";
			colorText[] = {1,1,1,1};
			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
		};

		class CommandBar_Hider: A3C_RscButton_Invisible
		{
			idc = 80701;
			x = (-10.5 * GUI_GRID_W + GUI_GRID_X) - (BAR_W);
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;
			onMouseButtonDown = "['CLOSE'] call A3C_UI_RADIAL_TOGGLE_LEFT_EXT";
		};

		class A3C_CommandBar: A3C_RscControlsGroup_NoScroll
		{
			idc = 8071;
			onMouseButtonDown = "_this call A3C_RADIAL_TREE_MouseDown;";
			x = BAR_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;

			class ControlsBackground
			{
			};

       		class Controls
			{
				class Radial_HOLD_Img: A3C_RscPicture
				{
					idc = 8097;
					text = "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";
					x = 6.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class Radial_HOLD_Btn: A3C_RscButton_Invisible
				{
					idc = 8098;
					onMouseButtonDown = "A3C_RD_UNITS call A3C_UNIT_HOLD;";
					x = 6.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					tooltip = "Selected units STANDBY";
				};
				class Radial_CONT_Img: A3C_RscPicture
				{
					idc = 8099;
					text = "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class Radial_CONT_Btn: A3C_RscButton_Invisible
				{
					idc = 9000;
					onMouseButtonDown = "A3C_RD_UNITS call A3C_UNIT_CONTINUE;";
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					tooltip = "Selected units CONTINUE";
				};

				class A3C_TOP_TEAMCOLOR_BG: A3C_RscPicture
				{
					idc = 7077;
					text = "#(argb,8,8,3)color(0,0,0,0.3)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = BAR_W;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_TOP_TEAMCOLOR_FRAME: A3C_RscFrame
				{
					idc = 7079;
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

				class A3C_SHARED_GAMEUI_TREE_CONTROL: A3C_CT_TREE
				{
					idc = 202020;
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
				class A3C_RadialMenu_REDBOX: A3C_RscPicture
				{
					idc = 1000;
					colorText[] = {1,0,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_REDBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1001;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					tooltip = "select team red (RMB for HUD mode)";
					toolTipColorShade[] = {1,0,0,0.5};
					onMouseButtonDown = "['Red',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};
				class A3C_RadialMenu_GREENBOX: A3C_RscPicture
				{
					idc = 1002;
					colorText[] = {0,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_GREENBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1003;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					tooltip = "select team green (RMB for HUD mode)";
					toolTipColorShade[] = {0,1,0,0.5};
					onMouseButtonDown = "['GREEN',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};
				class A3C_RadialMenu_BLUEBOX: A3C_RscPicture
				{
					idc = 1004;
					colorText[] = {0,0,1,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_BLUEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1005;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {0,0,1,0.5};
					tooltip = "select team blue (RMB for HUD mode)";
					onMouseButtonDown = "['Blue',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};
				class A3C_RadialMenu_YellowBOX: A3C_RscPicture
				{
					idc = 1006;
					colorText[] = {1,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_YELLOWBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1007;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {1,1,0,0.5};
					tooltip = "select team yellow (RMB for HUD mode)";
					onMouseButtonDown = "['YELLOW',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};
				class A3C_RadialMenu_WHITEBOX: A3C_RscPicture
				{
					idc = 1008;
					colorText[] = {1,1,1,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_WHITEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1009;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {1,1,1,0.5};
					tooltip = "select team white (RMB for HUD mode)";
					onMouseButtonDown = "['MAIN',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};
				class A3C_RadialMenu_PURPLEBOX: A3C_RscPicture
				{
					idc = 1010;
					colorText[] = {0.5,0.2,0.6,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_PURPLEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1011;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "select all units (RMB for HUD mode)";
					onMouseButtonDown = "['Purple',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};

				class RscListbox_8095: A3C_LISTBOX
				{
					idc = 8095;
					text = "";
					style = CT_LISTBOX;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 6.5 * GUI_GRID_W;
					h = 5.1 * GUI_GRID_H;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),100040] call A3C_LB_Change";
				};
   			};
    	};

		class DASH_PARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 303030;
			x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			y = 0.414993 * safezoneH + safezoneY;
			w = 0.240009 * safezoneW;
			h = 0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
			class Controls
			{
				class DASH_BG: A3C_RscPicture
				{
					idc = 11015;
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 4.9593e-007 * safezoneW;
					y = 0 * safezoneH;
					w = 0.240009 * safezoneW;
					h = 0.221018 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};

				class DASH_TEXT_GROUPNAME: A3C_RscText
				{
					idc = 11001;
					text = "";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.160006 * safezoneW;
					h = 0.0340028 * safezoneH;
					sizeEx = "0.04 / (getResolution select 5)";
				};

				class DASH_GROUPICON: A3C_RscPicture
				{
					idc = 11002;
					x = 0.168007 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.0720028 * safezoneW;
					h = 0.11901 * safezoneH;
				};

				class DASH_TEXT_UNITSIZE: A3C_RscText
				{
					idc = 11003;
					text = "Unit Size:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5));
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class DASH_text_Location_1: A3C_RscText
				{
					idc = 11004;
					text = "Location:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5)) + (1.1 * (0.021 / (getResolution select 5)) );
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};
				class DASH_TEXT_TASK: A3C_RscText
				{
					idc = 11005;
					text = "Current Task:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5))  + (2.2 * (0.021 / (getResolution select 5)) );
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class DASH_BAR_BG_HEALTH: A3C_RscPicture
				{
					idc = 12002;
					text = "#(argb,8,8,3)color(0.5,0.5,0.5,0.5)";
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class DASH_text_Health: A3C_RscText
				{
					idc = 12000;
					text = "Health (Soldiers)";
					style = 0;
					x = -3.81485e-008 * safezoneW;
					y = (0.136011 * safezoneH) - ( 0.021 / (getResolution select 5));
					w = 0.0800031 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class DASH_BAR_HEALTH: A3C_RscProgress
				{
					idc = 12001;
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class DASH_TEXT_UNITS: A3C_RscText
				{
					idc = 11012;
					text = "Roster";
					style = 0;
					x = 0.0960037 * safezoneW;
					y = (0.136011 * safezoneH) - ( 0.021 / (getResolution select 5));
					w = 0.0480019 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};
				class DASH_TEXTBOX_UNITS_STRCT: A3C_RscStructuredText
				{
					idc = 11014;
					x = 0.104004 * safezoneW;
					y = 0.136011 * safezoneH;
					w = 0.136005 * safezoneW;
					h = 0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};
			};
		};
	};
};