
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
		class HEADER: A3C_RscText
		{
			idc = -1;
			text = "A3C - GLOBAL SETTINGS:"; 
			x = 15.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 10 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		//-- AI Skill Reset
		class SKILL_TXT: A3C_RscText
		{
			idc = -1;
			text = "AI-SKILL RESET:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class SKILL_BTN: A3C_RscButton_Function
		{
			idc = 100;
			text = ""; 
			tooltip = "BOOST AI-SKILL";
			action = "['A3C_SKILL_VAR'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- NUM Controls
		class NUM_TXT: A3C_RscText
		{
			idc = -1;
			text = "NUM-CONTROLS:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 11 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class NUM_BTN: A3C_RscButton_Function
		{
			idc = 101;
			text = "";
			tooltip = "TOGGLE NUMPAD FUNCTIONS";
			action = "['A3C_NUM_VAR'] call A3C_SETTINGS";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- Auto Reset Hud
		class HUD_RESET_TXT: A3C_RscText
		{
			idc = -1;
			text = "AUTO RESET HUD:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class HUD_RESET_BTN: A3C_RscButton_Function
		{
			idc = 102;
			text = ""; 
			tooltip = "Reset HUD-formation to line when opening";
			action = "['A3C_HUD_RES_VAR'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- AI-RAIL
		class AI_RAIL_TXT: A3C_RscText
		{
			idc = -1;
			text = "AI RAIL:"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 16 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class AI_RAIL_BTN: A3C_RscButton_Function
		{
			idc = 103;
			text = ""; 
			tooltip = "Final 'railing' towards destination (experimental)";
			action = "['A3C_FORCERAIL_VAR'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- HUD UI: NORMAL / CORNER
		class HUD_MENU_STYLE_TXT: A3C_RscText
		{
			idc = -1;
			text = "HUD-CORNER-UI"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 18.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class HUD_MENU_STYLE_BTN: A3C_RscButton_Function
		{
			idc = 104;
			text = ""; 
			tooltip = "select HUD layout";
			action = "['A3C_HUD_LAYOUT_CORNER'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- HUD-INDICATORS: UNIT OR DISK
		class HUD_OBJ_STYLE_TXT: A3C_RscText
		{
			idc = -1;
			text = "USE UNIT-HUD"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class HUD_OBJ_STYLE_BTN: A3C_RscButton_Function
		{
			idc = 105;
			text = ""; 
			tooltip = "select HUD objects (OFF: indicators, ON: units)";
			action = "['A3C_HUD_OBJECTS'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 21.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		//-- HC-GP Menu (Map) : Immediate response or manual confirm
		class HC_GP_MENU_RESPONSE_TXT: A3C_RscText
		{
			idc = -1;
			text = "HC-CT-RESPONSE"; 
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 23 * GUI_GRID_H + GUI_GRID_Y;
			w = 9 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};
		class HC_GP_MENU_RESPONSE_BTN: A3C_RscButton_Function
		{
			idc = 106;
			text = ""; 
			tooltip = "HC-Group Menu Response (OFF: CONFIRM, ON: IMMEDIATE)";
			action = "['HC_GROUP_RESPONSE'] call A3C_UI_SettingsMenu_FNC_ChangeSettings";
			sizeEx = 0.04;
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 23.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;

		};
	};
};	
