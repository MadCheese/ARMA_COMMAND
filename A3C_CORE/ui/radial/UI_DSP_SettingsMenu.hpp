
class A3C_DSP_SettingsMenu
{
	idd = 100010;
	movingenable = true;
	class ControlsBackground 
	{
		class RscFrame_1800: A3C_RscPicture
		{
			idc = -1;
			x = 13.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 13 * GUI_GRID_W;
			h = 21.5 * GUI_GRID_H;
			text = "#(argb,8,8,3)color(0,0,0,0.7)";
		};
	};
	class Controls 
	{
		//-- HEADER
		class A3C_DSP_SettingsMenu_HEADER: A3C_RscText
		{
			idc = -1;
			text = "A3C - GLOBAL SETTINGS:"; 
			x = 15.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 10 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class A3C_RscText_1001: A3C_RscText
		{
			idc = -1;
			text = "AI-SKILL RESET:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_1002: A3C_RscText
		{
			idc = -1;
			text = "NUM-CONTROLS:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 11 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_1003: A3C_RscText
		{
			idc = -1;
			text = "AUTO RESET HUD:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_1004: A3C_RscText
		{
			idc = -1;
			text = "AI RAIL:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_1005: A3C_RscText
		{
			idc = -1;
			text = "TABLET STYLE"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 18.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_1006: A3C_RscText
		{
			idc = -1;
			text = "HUD-CORNER-UI"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_HUDOBJECTS: A3C_RscText
		{
			idc = -1;
			text = "USE UNIT-HUD"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 23 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class A3C_RscText_HCGROUP_ACTIONMODE: A3C_RscText
		{
			idc = -1;
			text = "HC-CT-RESPONSE"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 25 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};

		class Switch_Skill: A3C_RscButton_Function
		{
			idc = 1600;
			text = ""; 
			tooltip = "BOOST AI-SKILL";
			action = "['A3C_SKILL_VAR'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class Switch_NUM: A3C_RscButton_Function
		{
			idc = 1601;
			text = ""; 
			tooltip = "TOGGLE NUMPAD FUNCTIONS";
			action = "['A3C_NUM_VAR'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_sup: A3C_RscButton_Function
		{
			idc = 1602;
			text = ""; 
			tooltip = "Reset HUD-formation to line when opening";
			action = "['A3C_HUD_RES_VAR'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_RAIL: A3C_RscButton_Function
		{
			idc = 1603;
			text = ""; 
			tooltip = "Final 'railing' towards destination (experimental)";
			action = "['A3C_FORCERAIL_VAR'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_TAB_IMG: A3C_RscButton_Function
		{
			idc = 1604;
			text = ""; 
			tooltip = "select tablet style";
			action = "[] call A3C_SwitchTabletImage";
			sizeEx = 0.02;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_HUD_UI: A3C_RscButton_Function
		{
			idc = 1605;
			text = ""; 
			tooltip = "select HUD layout";
			action = "['A3C_HUD_LAYOUT_CORNER'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 21.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_HUD_Objects: A3C_RscButton_Function
		{
			idc = 1606;
			text = ""; 
			tooltip = "select HUD objects (OFF: indicators, ON: units)";
			action = "['A3C_HUD_OBJECTS'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 23.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class switch_HCGROUP_ACTIONMODE: A3C_RscButton_Function
		{
			idc = 1607;
			text = ""; 
			tooltip = "HC-Group Menu Response (OFF: CONFIRM, ON: IMMEDIATE)";
			action = "['HC_GROUP_RESPONSE'] call A3C_UI_SETTINGS_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 25.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;

		};
	};
};	
