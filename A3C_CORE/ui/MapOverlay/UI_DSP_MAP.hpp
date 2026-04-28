#include "..\SHARED\shared_ui_defines.hpp"

#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2.5 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2.5 ))

// w10 x h16

//UI element sizes
#define MAIN_WIDTH_GP 12
#define MAIN_HEIGHT_GP 19

#define A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H (0.08 * safezoneH)
#define A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W (A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 0.75)

class A3C_DSP_MapOverlay
{
	idd = 100020;
	movingenable = true;
	onKeyDown = "private _blockDefaultKey = _this call A3C_UI_MAP_onKeyDown_Overlay; _blockDefaultKey";
	onKeyUp = "_this call A3C_UI_MAP_onKeyUp_Overlay;";

	onMouseButtonDown = "_this spawn A3C_UI_MAP_onOnMouseButtonDown_Overlay; true";
	onMouseButtonUp = "_this spawn A3C_UI_MAP_onOnMouseButtonUp_Overlay; false";
		
	class ControlsBackground 
	{	
	
		//---------------------------------------------------------------------------------------------
		//---------- BACKGROUNDS & CONTROL FIELDS -----------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		
		// //-- THIS NEVER FIRES... TRIED LAYERING ON TOP >> STILL NOTHING, SEEMS REDUNDANT
		// class A3C_RscPicture_ControlFrame_1: A3C_RscButton_Invisible
		// {
		// 	idc = 11;
		// 	onMouseEnter = "[] call A3C_MAP_DelLoopObs; ";
		// 	x = 0.21933 * safezoneW + safezoneX;
		// 	y = 100 * safezoneH + safezoneY;
		// 	w = 0.555611 * safezoneW;
		// 	h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		// };

		//---------- UNFOLDABLE SQUAD CONTROL BACKGROUND ----------------------------------------------
		class A3C_RscPicture_ControlFrame: A3C_RscPicture
		{
			idc = 10;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.21933 * safezoneW + safezoneX;
			y = 100 * safezoneH + safezoneY;
			w = 0.555611 * safezoneW;
			h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		};
		
		class A3C_RscPicture_ControlFrame_Frame: A3C_RscFrame 
		{
			idc = 13;
			
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

			x = 0.21933 * safezoneW + safezoneX;
			y = 100 * safezoneH + safezoneY;
			w = 0.555611 * safezoneW;
			h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		};
		
		
		
		class A3C_MAP_FULLSCREEN: A3C_RscButton_Invisible
		{
			idc = 12;
			onMouseMoving = "_this call A3C_UI_MAP_onOnMouseMoving_Overlay";
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;
		};

		


		
	};
		


	class Controls 
	{

		//---------------------------------------------------------------------------------------------
		//---------- STARTUP VISUALIZATION ------------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		class START_BAR: A3C_RscProgress
		{
			idc = 404040;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 18.5 * GUI_GRID_W;
			h = 0.25 * GUI_GRID_H;
		};
		class START_TEXT: A3C_RscTEXT
		{
			idc = 404041;
			text = "";
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 18.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			sizeEx = 0.07 / (getResolution select 5);
			font = "PuristaMedium";
		};


		//---------------------------------------------------------------------------------------------
		//---------- RIGHT SIDE STATIC CONTROL: TREE, TEAM COLORS, EXTRAS -----------------------------
		//---------------------------------------------------------------------------------------------
		
		class IDC_SHARED_UI_TREE_SELECTOR: A3C_CT_TREE
		{
			idc = 202020;

			colorBackground[] = {0,0,0,0.6};
			onMouseButtonDown = "_this call A3C_TREE_BOXCLICK;";
			x = 0 * safezoneW + safezoneX;
			y = 100;
			w = (8 * 0.03 / (getResolution select 5));
			h = 0.05 / (getResolution select 5);
			onTreeLButtonDown = "_this call A3C_TREE_TVCHANGE; false";
			onTreeCollapsed = "[_this,'COLLAPSE',false,0.1] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;  false";
			onTreeExpanded = "[_this,'OPEN',false,0.1] spawn A3C_UI_MAP_TREE_OPEN_COLLAPSE;  false";
			sizeEx = 0.03 / (getResolution select 5);

		};

		class A3C_TOP_ROW_BG: A3C_RscPicture
		{
			idc = 7071;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = (safezoneH + safezoneY);
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TOP_ROW_BG_FRAME: A3C_RscFrame
		{
			idc = 7074;
			x = 0.288066 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
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


		class A3C_TOP_TEAMCOLOR_BG: A3C_RscPicture
		{
			idc = 7077;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TOP_TEAMCOLOR_FRAME: A3C_RscFrame
		{
			idc = 7079;
			x = 0.298066 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.0330053 * safezoneH;
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
		//-- Teamcolor Selectors -- 1000+
		
		class A3C_TAB_REDBOX: A3C_RscPicture
		{
			idc = 1000;
			x = 0.24797 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_REDBOX_2: A3C_RscButton_Invisible
		{
			idc = 1001;
			onMouseButtonDown = "['Red',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "team red. LMB to select, Shift+LMB to add";
		};
		class A3C_TAB_GREENBOX: A3C_RscPicture
		{
			idc = 1002;
			x = 0.33198 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_GREENBOX_2: A3C_RscButton_Invisible
		{
			idc = 1003;
			onMouseButtonDown = "['GREEN',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
			x = 0.33198 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team green. LMB to select, Shift+LMB to add";
		};
		class A3C_TAB_BLUEBOX: A3C_RscPicture
		{
			idc = 1004;
			x = 0.41599 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_BLUEBOX_2: A3C_RscButton_Invisible
		{
			idc = 1005;
			onMouseButtonDown = "['Blue',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";

			x = 0.41599 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team blue. LMB to select, Shift+LMB to add";
		};
		class A3C_TAB_YELLOWBOX: A3C_RscPicture
		{
			idc = 1006;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_YELLOWBOX_2: A3C_RscButton_Invisible
		{
			idc = 1007;
			onMouseButtonDown = "['YELLOW',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";

			x = 0.5 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team yellow. LMB to select, Shift+LMB to add";
		};
		class A3C_TAB_WHITEBOX: A3C_RscPicture
		{
			idc = 1008;
			x = 0.58401 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_WHITEBOX_2: A3C_RscButton_Invisible
		{
			idc = 1009;
			onMouseButtonDown = "['MAIN',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";

			x = 0.58401 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team white. LMB to select, Shift+LMB to add";
		};
		
		class A3C_TAB_PURPLEBOX: A3C_RscPicture
		{
			idc = 1010;
			x = 0.66802 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class A3C_TAB_PURPLEBOX_2: A3C_RscButton_Invisible
		{
			idc = 1011;
			onMouseButtonDown = "['PURPLE',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";

			x = 0.66802 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select all units. LMB to select, Shift+LMB to add";
		};

		//---------- EXTRAS --------------------------------------------
		class A3C_Leavegroup_IMG: A3C_RscPicture
		{
			idc = 7075;
			x = 0.729118 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_Leavegroup_1_Click: A3C_RscButton_Invisible
		{
			idc = 7076;
			action = "[0] spawn A3C_BTN_HC";
			
			x = 0.729118 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
			tooltip = "disband selected units to reserve";
		};

		class A3C_IMG_TOGGLETRACKER_BG: A3C_RscPicture
		{
			idc = 1219;
			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_IMG_TOGGLETRACKER_IMG: A3C_RscPicture
		{
			idc = 1220;
			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_BTN_TOGGLETRACKER_CLK: A3C_RscButton_Invisible
		{
			idc = 7096;
			action = "[] call A3C_TAB_TOGGLE_TRACKER;";

			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "Toggle Force Tracking";
		};
		
		
		//---------------------------------------------------------------------------------------------
		//---------- UNFOLDABLE SQUAD-BAR: UI-CONTROLS ------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		
		class A3C_TIMEOUT_CHECKBOX1: A3C_RscPicture
		{
			idc = 7022;
			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class A3C_TIMEOUT_CHECKBOX2: A3C_RscButton_Invisible
		{
			idc = 7007;
			onMouseButtonDown = "[[7022,7007],'SQ_CONDITION',1,true] call A3C_UI_MAP_UFSB_TOGGLE_SUBSELECTION_POPUP";
			onMouseZChanged = "[_this select 1] call A3C_BTN_FNC_COND";

			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "WP Condition: NONE (LMB to cycle through options)";
		};

		class 7009: A3C_CT_EDIT
		{
			idc = 7009;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			colorSelection[] = {1,1,1,1};
			colorDisabled[] = {};
			colorBackground[] = {0,0,0,0.6};
			onSetFocus = "['TIMEOUT','ON'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
			onKillFocus = "['TIMEOUT','OFF'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
			tooltip = "Set Timeout";
			text = "05";
			x = 0.580191 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,1};
			sizeEx = "0.03 / (getResolution select 5)";	
		};

		class A3C_TEXT_07: A3C_RscText
		{
			idc = 7014;

			x = -0.0498831 * safezoneW + safezoneX;
			y = 0.00492081 * safezoneH + safezoneY;
			w = 0.234846 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TEXT_08: A3C_RscText
		{
			idc = 7015;

			x = -0.0326993 * safezoneW + safezoneX;
			y = 0.0709314 * safezoneH + safezoneY;
			w = 0.183294 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_map_undo_IMAGE: A3C_RscPicture
		{
			idc = 7092;
			x = 0.620287 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,0.7};
		};
		class A3C_Undo: A3C_RscButton_Invisible
		{
			idc = 7041;
			action = "[] call A3C_UNDO";
			toolTip = "Undo";
			x = 0.620287 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;

		};
		class RText_7042: A3C_RscText
		{
			idc = 7042;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 1 * GUI_GRID_H + GUI_GRID_Y;
			w = 7.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		
		class A3C_TAB_STANCE1: A3C_RscPicture
		{
			idc = 7044;
			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_STANCE1_2: A3C_RscButton_Invisible
		{
			idc = 7045;
			onMouseButtonDown = "[[7044,7045],'SQ_STANCE_1',1,true] call A3C_UI_MAP_UFSB_TOGGLE_SUBSELECTION_POPUP;";
			onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_1";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "stance while en route";
		};
		class A3C_TAB_STANCE2: A3C_RscPicture
		{
			idc = 7046;
			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_STANCE2_2: A3C_RscButton_Invisible
		{
			idc = 7047;
			onMouseButtonDown = "[[7046,7047],'SQ_STANCE_2',1,true] call A3C_UI_MAP_UFSB_TOGGLE_SUBSELECTION_POPUP;";
			onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_2;";

			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set stance upon arrival";
		};
		class A3C_TAB_Speed: A3C_RscPicture
		{
			idc = 7048;
			x = 0.293794 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_Speed_2: A3C_RscButton_Invisible
		{
			idc = 7049;
			onMouseButtonDown = "[] call A3C_SPEED_BTN";
			onMouseZChanged = "[] call A3C_SPEED_BTN";

			x = 0.293794 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set travel speed";
		};
		class A3C_TAB_FORMM: A3C_RscPicture
		{
			idc = 7050;
			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_FORMM_2: A3C_RscButton_Invisible
		{
			idc = 7051;
			onMouseButtonDown = "[[7050,7051],'SQ_FORMATION',1,true] call A3C_UI_MAP_UFSB_TOGGLE_SUBSELECTION_POPUP";
			onMouseZChanged = "[_this select 1] call A3C_BUTTON_FORMMODE";

			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set formation (connected tolooking-direction)";
		};
		
		class A3C_TAB_CMODE: A3C_RscPicture
		{
			idc = 7062;
			x = 0.385441 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_CMODE_2: A3C_RscButton_Invisible
		{
			idc = 7063;
			onMouseButtonDown = "[] call A3C_BUTTON_CMODE";
			onMouseZChanged = "[] call A3C_BUTTON_CMODE";

			x = 0.385441 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "WP Combat-Mode: Default/Engage";
		};
		class A3C_wpFiringMode: A3C_RscPicture
		{
			idc = 7064;
			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_wpFiringMode_2: A3C_RscButton_Invisible
		{
			idc = 7065;
			onMouseButtonDown = "[[7064,7065],'SQ_ACTION',1,true] call A3C_UI_MAP_UFSB_TOGGLE_SUBSELECTION_POPUP";
			onMouseZChanged = "[(_this select 1),false,true] spawn A3C_BUTTON_wpFiringMode;";

			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "";
		};
		class spacing_input: A3C_CT_EDIT
		{
			idc = 7066;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			onSetFocus = "['SPACING','ON'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
			onKillFocus = "['SPACING','OFF'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
			colorSelection[] = {1,1,1,1};
			colorDisabled[] = {};
			sizeEx = "0.03 / (getResolution select 5)";
			tooltip = "Set Unit-Spacing";	
			x = 0.517184 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,1};
		};

		class A3C_Cancel_Data: A3C_RscPicture
		{
			idc = 7069;
			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_Cancel_Data_1: A3C_RscButton_Invisible
		{
			idc = 7070;
			onmousebuttondown = "[A3C_SELECTED_UNITS,(_this select 4),(_this select 5)] spawn A3C_AI_Shared_cancelUnitPlot";

			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "LMB: delete session. shift+LMB: delete active orders. ctrl+LMB: skip currentwaypoint"; //--- 	ToDo: 	Localize;
		};
		
		class A3C_Refresh_Data_IMG: A3C_RscPicture
		{
			idc = 7072;
			x = 0.288066 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_Refresh_Data_1_Clk: A3C_RscButton_Invisible
		{
			idc = 7073;
			onmousebuttondown = "[(units group player) - [player]] call A3C_GROUP_RESET;";

			x = 0.288066 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "refresh group";
		};

		//-- UNFOLDABLE SQUAD BAR (UFSQB): POPUP SUB SELECTION
		class 8010: A3C_RscControlsGroup_NoScroll
		{
			idc = 8010;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
			class Controls
			{
				class IMG_SUBSET_2_1: A3C_RscPicture
				{
					idc = 801001;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_2: A3C_RscPicture
				{
					idc = 801002;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_3: A3C_RscPicture
				{
					idc = 801003;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_4: A3C_RscPicture
				{
					idc = 801004;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_5: A3C_RscPicture
				{
					idc = 801005;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_6: A3C_RscPicture
				{
					idc = 801006;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_7: A3C_RscPicture
				{
					idc = 801007;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_8: A3C_RscPicture
				{
					idc = 801008;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_9: A3C_RscPicture
				{
					idc = 801009;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_10: A3C_RscPicture
				{
					idc = 801010;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_1: A3C_RscButton_Invisible
				{
					idc = 801011;
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_2: A3C_RscButton_Invisible
				{
					idc = 801012;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_3: A3C_RscButton_Invisible
				{
					idc = 801013;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_4: A3C_RscButton_Invisible
				{
					idc = 801014;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_5: A3C_RscButton_Invisible
				{
					idc = 801015;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_6: A3C_RscButton_Invisible
				{
					idc = 801016;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_7: A3C_RscButton_Invisible
				{
					idc = 801017;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_8: A3C_RscButton_Invisible
				{
					idc = 801018;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_9: A3C_RscButton_Invisible
				{
					idc = 801019;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_10: A3C_RscButton_Invisible
				{
					idc = 801020;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- UNFOLDABLE SQUAD-BAR: EXECUTE BUTTONS --------------------------------------------
		//---------------------------------------------------------------------------------------------
		class A3C_WPD_BTN1: A3C_ShortcutButton
		{
			idc = 7018;
			
			action = "['ALL'] spawn A3C_Btn_fnc_Execute";
			text = "COMMIT ALL";
			
			x = 0.517184 * safezoneW + safezoneX;
			y = 2;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			font = "TahomaB";
			tooltip = "Execute all squad-plans";
			color[] = {1,1,1,1};	
			colorBackground[] = {1,1,1,1};
			size = "0.04 / (getResolution select 5)";
			sizeEx = "0.04 / (getResolution select 5)";	
		};
		class A3C_WPD_BTN2: A3C_ShortcutButton
		{
			idc = 7019;
			action = "['SELECTED'] spawn A3C_Btn_fnc_Execute";
			text = "COMMIT";
			x = 0.316706 * safezoneW + safezoneX;
			y = 2;
			w = 0.160383 * safezoneW;
			h = 0.044007 * safezoneH;
			font = "TahomaB";
			tooltip = "Execute plans for selected units";
			color[] = {1,1,1,1};	
			colorBackground[] = {1,1,1,1};
			size = "0.04 / (getResolution select 5)";
			sizeEx = "0.04 / (getResolution select 5)";	
		};
		class A3C_WPD_BTN3: A3C_ShortcutButton
		{
			idc = 7020;
			action = "(findDisplay 100020) closeDisplay 0; A3C_SELECTED_UNITS = []; {_x setvariable ['A3C_PLOT_TEMP',[],true];} foreach units group player; openMap false; [1] call A3C_Btn_fnc_Cancel";
			text = "EXIT";
			x = 0.517184 * safezoneW + safezoneX;
			y = 2;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			font = "TahomaB";
			tooltip = "Exit and close map";
			color[] = {1,1,1,1};	
			colorBackground[] = {1,1,1,1};
			size = "0.04 / (getResolution select 5)";
			sizeEx = "0.04 / (getResolution select 5)";	
		};

		

		

		class A3C_COMBO_ENEMYTARGET: A3C_RscCombo //-- name is misleading as control is used in multiple places
		{
			idc = 7078;
			onLBSelChanged = " [A3C_LB_MODE,(_this select 1),100020] call A3C_LB_Change";
			x = 0.00166839 * safezoneW + safezoneX;
			y = 14 * safezoneH + safezoneY;
			w = 0.0630074 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		
		
		//---------------------------------------------------------------------------------------------
		//---------- MAP TOP RIGHT: GO-CODE CONTROLS --------------------------------------------------
		//---------------------------------------------------------------------------------------------
		class Order_GoCode_BG: A3C_RscPicture
		{
			idc = 709099;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_A: A3C_RscPicture
		{
			idc = 709100;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_A_1: A3C_RscButton_Invisible
		{
			idc = 709101;
			action = "['A'] call A3C_ACTIVATEGOCODE";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_B: A3C_RscPicture
		{
			idc = 709102;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_B_1: A3C_RscButton_Invisible
		{
			idc = 709103;
			action = "['B'] call A3C_ACTIVATEGOCODE";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_C: A3C_RscPicture
		{
			idc = 709104;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_C_1: A3C_RscButton_Invisible
		{
			idc = 709105;
			action = "['C'] call A3C_ACTIVATEGOCODE";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_D: A3C_RscPicture
		{
			idc = 709106;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_D_1: A3C_RscButton_Invisible
		{
			idc = 709107;
			action = "['D'] call A3C_ACTIVATEGOCODE";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_DIAGDEG: A3C_RscText
		{
			idc = 709108;

			x = 0.0245802 * safezoneW + safezoneX;
			y = 0.0159226 * safezoneH + safezoneY;
			w = 0.114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};

		
		class RscMapHold: A3C_RscPicture
		{
			idc = 8000;

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
		};
		class RscMapHoldBtn: A3C_RscButton_Invisible
		{
			idc = 8001;
			action = "A3C_SELECTED_UNITS call A3C_UNIT_HOLD";

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
			tooltip = "Selected units STANDBY";
		};
		class RscMapCont: A3C_RscPicture
		{
			idc = 8002;
			x = 0.654655 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
		};
		class RscMapContBtn: A3C_RscButton_Invisible
		{
			idc = 8003;
			action = "A3C_SELECTED_UNITS call A3C_UNIT_CONTINUE";

			x = 0.654655 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
			tooltip = "Selected units CONTINUE";
		};
		
		class 1010101: A3C_RscPicture
		{
			idc = 1010101;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
		};
		
		class 1010102: A3C_RscPicture
		{
			idc = 1010102;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
		};


		//---------------------------------------------------------------------------------------------
		//---------- HCGP-CONTEXT: ACTIONS (SEPARATE) --------------------------------------------
		//---------------------------------------------------------------------------------------------
		class 8009: A3C_RscControlsGroup_NoScroll
		{
			idc = 8009;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 2;
			class Controls
			{
				class IMG_SUBSET_1_1: A3C_RscPicture
				{
					idc = 800901;
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_2: A3C_RscPicture
				{
					idc = 800902;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_3: A3C_RscPicture
				{
					idc = 800903;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_4: A3C_RscPicture
				{
					idc = 800904;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_5: A3C_RscPicture
				{
					idc = 800905;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_6: A3C_RscPicture
				{
					idc = 800906;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				
				
				class IMG_SUBSET_1_7: A3C_RscPicture
				{
					idc = 800907;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_8: A3C_RscPicture
				{
					idc = 800908;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_9: A3C_RscPicture
				{
					idc = 800909;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_10: A3C_RscPicture
				{
					idc = 800910;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class BTN_SUBSET_1_1: A3C_RscButton_Invisible
				{
					idc = 800911;
					x = 0* safezoneW;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_2: A3C_RscButton_Invisible
				{
					idc = 800912;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_3: A3C_RscButton_Invisible
				{
					idc = 800913;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_4: A3C_RscButton_Invisible
				{
					idc = 800914;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_5: A3C_RscButton_Invisible
				{
					idc = 800915;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_6: A3C_RscButton_Invisible
				{
					idc = 800916;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				
				class BTN_SUBSET_1_7: A3C_RscButton_Invisible
				{
					idc = 800917;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_9: A3C_RscButton_Invisible
				{
					idc = 800918;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_0: A3C_RscButton_Invisible
				{
					idc = 800919;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_10: A3C_RscButton_Invisible
				{
					idc = 800920;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
			};
		};

		//---------- HCGP-CONTEXT: STANCES --------------------------------------------
		class 709109: A3C_RscControlsGroup
		{
			idc = 709109;
			x = 62 * GUI_GRID_W + GUI_GRID_X;
			y = -9.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.5 * GUI_GRID_W;
			h = 20 * GUI_GRID_H;
	
			class Controls
			{

				class ctg1 :  A3C_RscPicture
				{
					idc = 709110;
					text = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa"; 
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class ctg1_1 :  A3C_RscButton_Invisible
				{
					idc = 7091101;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['SPEED'] call A3C_CONTEXTBUTTON";
				};
				class ctg2 :  A3C_RscPicture
				{
					idc = 709111;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class ctg2_1 :  A3C_RscButton_Invisible
				{
					idc = 7091111;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['STANCE1'] call A3C_CONTEXTBUTTON";
				};
				class ctg3 :  A3C_RscCombo
				{
					idc = 709112;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 5.5 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),100020] call A3C_LB_Change; ";
				};
				class ctg4 :  A3C_RscPicture
				{
					idc = 709113;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
					x = 3 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class ctg4_1 :  A3C_RscButton_Invisible
				{
					idc = 7091131;
					x = 3 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['STANCE2'] call A3C_CONTEXTBUTTON";
				};
				class ctg5 :  A3C_RscPicture
				{
					idc = 709114;
					text = "A3C_CORE\ui\pictures\icon_Menu_trash.paa";
					x = 4.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class ctg5_1 :  A3C_RscButton_Invisible
				{
					idc = 7091141;
					x = 4.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['DELETE'] call A3C_CONTEXTBUTTON";
				};
			};
		};
		
		
		
		
		
		
		
		
		
		
		
		



		//---------------------------------------------------------------------------------------------
		//---------- HCGP-CONTEXT MENU ----------------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		class 8007: A3C_RscControlsGroup_NoScroll
		{
			idc = 8007;
			x = 0;
			y = 200;

			w = GRIDX( MAIN_WIDTH_GP );
			h = GRIDY( MAIN_HEIGHT_GP);



			class Controls
			{
				
				
				class A3C_HC_GROUP_MENU_BG_STANCES: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0,0,0,0.35)";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				
				class A3C_HC_GROUP_MENU_STANCES_AUTO_IMG: A3C_RscPicture
				{
					idc = 800724;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_AUTO_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['AUTO'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to AUTO";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_STAND_IMG: A3C_RscPicture
				{
					idc = 800725;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 2 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_STAND_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['UP'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to STAND";
					x = GRIDX( 2 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_CROUCH_IMG: A3C_RscPicture
				{
					idc = 800726;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 4 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_CROUCH_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['MIDDLE'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to CROUCH";
					x = GRIDX( 4 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_PRONE_IMG: A3C_RscPicture
				{
					idc = 800727;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 6 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_PRONE_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['DOWN'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to PRONE";
					x = GRIDX( 6 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				
				

				
				
				class A3C_HC_GROUP_MENU_Box_Behaviour: A3C_LISTBOX
				{
					idc = 800701;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800701,(_this select 1),100020] call A3C_Map_HC_groupContext_LB_Switch";
					//colorBackground[] = {0.18,0.25,0.38,0.7};
					colorBackground[] = {0.2,0.2,0.2,0.7};
				};
				
				
				class A3C_HC_GROUP_MENU_Box_CombatMode: A3C_LISTBOX
				{
					idc = 800702;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY( 2 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800702,(_this select 1),100020] call A3C_Map_HC_groupContext_LB_Switch";
					//colorBackground[] = {0.34,0.45,0.54,0.7};
					colorBackground[] = {0.6,0.6,0.6,0.7};
				};

				class A3C_HC_GROUP_MENU_Box_Formation: A3C_LISTBOX
				{
					idc = 800703;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY(6 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800703,(_this select 1),100020] call A3C_Map_HC_groupContext_LB_Switch";
					//colorBackground[] = {0,0,0,0.7};
					colorBackground[] = {0.2,0.2,0.2,0.7};
				};
				class A3C_HC_GROUP_MENU_Box_Color: A3C_LISTBOX
				{
					idc = 800704;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY(6 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800704,(_this select 1),100020] call A3C_Map_HC_groupContext_LB_Switch";
					//colorBackground[] = {0.25,0.25,0.25,0.7};
					colorBackground[] = {0.6,0.6,0.6,0.7};
				};
	
				
				class A3C_HC_GROUP_MENU_BG_Confirm: A3C_RscPicture
				{
					idc = 800707;
					text = "#(argb,8,8,3)color(0,1,0,0.35)";
					x = GRIDX( 0 ); 
					y = GRIDY( 10 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				
				
				class A3C_HC_GROUP_MENU_Button_Confirm: A3C_RscButton_Invisible
				{
					idc = 800711;
					text = "CONFIRM";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
					sizeEx = 0.045;
					action = "[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm";
					x = GRIDX( 0 ); 
					y = GRIDY( 10 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );	
				};

				class A3C_HC_GROUP_MENU_BG_Cancel: A3C_RscPicture
				{
					idc = 800708;
					text = "#(argb,8,8,3)color(1,0,0,1)";
					x = GRIDX( 8 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Button_Cancel: A3C_RscButton_Invisible
				{
					idc = 800712;
					text = "X";
					action = "(findDisplay 100020 displayCtrl 8007) ctrlShow false; A3C_SELECTED_HC_GROUPS_SETTINGS = []; (findDisplay 100020 displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false;";
					x = GRIDX( 8 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				
				//-- Action Button Macro 0
				class ACTION_BUTTON_0_BG: A3C_RscPicture
				{
					idc = 8007161;
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_0_IMG: A3C_RscPicture
				{
					idc = 8007162;
					text = "";
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_0_BTN: A3C_RscButton_Invisible
				{
					idc = 8007163;
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,0,[8007161,8007162,8007163]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				

				//-- Action Button Macro 1
				class ACTION_BUTTON_1_BG: A3C_RscPicture
				{
					idc = 8007171;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_1_IMG: A3C_RscPicture
				{
					idc = 8007172;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );//--buttonup??
				};
				
				class ACTION_BUTTON_1_BTN: A3C_RscButton_Invisible
				{
					idc = 8007173;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );//--buttonup??
					onMouseButtonDown = "[_this,1,[8007171,8007172,8007173]] call A3C_MAP_fnc_GroupMenu_Action_BTN";

				};
				
				
				
				
				//-- Action Button Macro 2
				class ACTION_BUTTON_2_BG: A3C_RscPicture
				{
					idc = 8007181;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_2_IMG: A3C_RscPicture
				{
					idc = 8007182;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_2_BTN: A3C_RscButton_Invisible
				{
					idc = 8007183;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,2,[8007181,8007182,8007183]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				
				
				
				//-- Action Button Macro 3
				class ACTION_BUTTON_3_BG: A3C_RscPicture
				{
					idc = 8007191;
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_3_IMG: A3C_RscPicture
				{
					idc = 8007192;
					text = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_3_BTN: A3C_RscButton_Invisible
				{
					idc = 8007193;
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,3,[8007191,8007192,8007193]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				
				
				
				
				//-- Action Button Macro 4
				class ACTION_BUTTON_4_BG: A3C_RscPicture
				{
					idc = 8007201;
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_4_IMG: A3C_RscPicture
				{
					idc = 8007202;
					text = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_4_BTN: A3C_RscButton_Invisible
				{
					idc = 8007203;
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,4,[8007201,8007202,8007203]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				
				//-- Action Button Macro 5
				class ACTION_BUTTON_5_BG: A3C_RscPicture
				{
					idc = 8007211;
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_5_IMG: A3C_RscPicture
				{
					idc = 8007212;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_5_BTN: A3C_RscButton_Invisible
				{
					idc = 8007213;
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,5,[8007211,8007212,8007213]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				//-- Action Button Macro 6
				class ACTION_BUTTON_6_BG: A3C_RscPicture
				{
					idc = 8007221;
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_6_IMG: A3C_RscPicture
				{
					idc = 8007222;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_6_BTN: A3C_RscButton_Invisible
				{
					idc = 8007223;
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,6,[8007221,8007222,8007223]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				//-- Action Button Macro 7
				class ACTION_BUTTON_7_BG: A3C_RscPicture
				{
					idc = 8007231;
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_7_IMG: A3C_RscPicture
				{
					idc = 8007232;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_7_BTN: A3C_RscButton_Invisible
				{
					idc = 8007233;
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,7,[8007231,8007232,8007233]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				//-- Action Button Macro 8
				class ACTION_BUTTON_8_BG: A3C_RscPicture
				{
					idc = 8007241;
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_8_IMG: A3C_RscPicture
				{
					idc = 8007242;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_8_BTN: A3C_RscButton_Invisible
				{
					idc = 8007243;
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,8,[8007241,8007242,8007243]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				
				//-- Action Button Macro 9
				class ACTION_BUTTON_9_BG: A3C_RscPicture
				{
					idc = 8007251;
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class ACTION_BUTTON_9_IMG: A3C_RscPicture
				{
					idc = 8007252;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class ACTION_BUTTON_9_BTN: A3C_RscButton_Invisible
				{
					idc = 8007253;
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = "[_this,9,[8007251,8007252,8007253]] call A3C_MAP_fnc_GroupMenu_Action_BTN";
				};
				
				
				
				
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- HC-DASHBOARD - MAP VARIANT (HCGP EXTENSION)---------------------------------------
		//---------------------------------------------------------------------------------------------
		
		class SHARED_UI_DASHBOARD_PARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_SHARED_UI_DASHBOARD_PARENT; //303030;
			x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			y = 100;
			w = 0.240009 * safezoneW;
			h = 0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));

			class Controls
			{
				class SHARED_UI_DASHBOARD_BG: A3C_RscPicture
				{
					idc = IDC_SHARED_UI_DASHBOARD_BG; //11015;
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 4.9593e-007 * safezoneW;
					y = 0 * safezoneH;
					w = 0.240009 * safezoneW;
					h = 0.221018 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};

				class SHARED_UI_DASHBOARD_GROUPNAME: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_GROUPNAME; //11001;
					text = "";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.160006 * safezoneW;
					h = 0.0340028 * safezoneH;
					sizeEx = "0.04 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_GROUPICON: A3C_RscPicture
				{
					idc = IDC_SHARED_UI_DASHBOARD_GROUPICON; //11002;
					x = 0.168007 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.0720028 * safezoneW;
					h = 0.11901 * safezoneH;
				};

				class SHARED_UI_DASHBOARD_TXT_UNITSIZE: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_TXT_UNITSIZE; //11003;
					text = "Unit Size:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5));
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_TXT_LOCATION: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_TXT_LOCATION; //11004;
					text = "Location:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5)) + (1.1 * (0.021 / (getResolution select 5)));
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_TXT_TASK: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_TXT_TASK; //11005;
					text = "Current Task:";
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = (-2.21673e-008 * safezoneH) + (0.0340028 * safezoneH) + (0.005 / (getResolution select 5)) + (2.2 * (0.021 / (getResolution select 5)));
					w = 0.160006 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_PGBARS_BG: A3C_RscPicture
				{
					idc = IDC_SHARED_UI_DASHBOARD_PGBARS_BG; //12002;
					text = "#(argb,8,8,3)color(0.5,0.5,0.5,0.5)";
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class SHARED_UI_DASHBOARD_PG_HEALTH_TXT: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_PG_HEALTH_TXT; //12000;
					text = "Health (Soldiers)";
					style = 0;
					x = -3.81485e-008 * safezoneW;
					y = (0.136011 * safezoneH) - (0.021 / (getResolution select 5));
					w = 0.0800031 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_PG_HEALTH_BAR: A3C_RscProgress
				{
					idc = IDC_SHARED_UI_DASHBOARD_PG_HEALTH_BAR; //12001;
					x = (0.00800027 - 0.002) * safezoneW;
					y = (0.136011 * safezoneH);
					w = 0.0800031 * safezoneW;
					h = 0.0085007 * safezoneH;
				};

				class SHARED_UI_DASHBOARD_PG_ROSTER_TXT: A3C_RscText
				{
					idc = IDC_SHARED_UI_DASHBOARD_PG_ROSTER_TXT; //11012;
					text = "Roster";
					style = 0;
					x = 0.0960037 * safezoneW;
					y = (0.136011 * safezoneH) - (0.021 / (getResolution select 5));
					w = 0.0480019 * safezoneW;
					h = 0.021 / (getResolution select 5);
					sizeEx = "0.021 / (getResolution select 5)";
				};

				class SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED: A3C_RscStructuredText
				{
					idc = IDC_SHARED_UI_DASHBOARD_PG_ROSTER_STRUCTURED; //11014;
					x = 0.104004 * safezoneW;
					y = 0.136011 * safezoneH;
					w = 0.136005 * safezoneW;
					h = 0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
				};

				//-- MAP HAS ONE ADDITIONAL CONTROL: CT EDIT FOR GROUP NAME EDITING
				class MAP_DASHBOARD_GROUPNAME_EDIT: A3C_CT_Edit
				{
					idc = IDC_MAP_DASHBOARD_GROUPNAME_EDIT; //800713;
					type = 2;
					style = 0;
					sizeEx = "0.04 / (getResolution select 5)";
					autocomplete = "false";

					onSetFocus = "['GROUPNAME','ON'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE; ['ON'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE_DASHBOARD;";
					onKillFocus = "['GROUPNAME','OFF'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE; ['OFF'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE_DASHBOARD;";

					x = 0;
					y = 0;
					w = 0.14 * safezoneW;
					h = 0.0340028 * safezoneH;
					font = "PuristaLight";
					colorBackground[] = {1,1,1,0};
					colorDisabled[] = {0,0,0,0};
					colorSelection[] = {1,1,1,0.2};
					colorText[] = {1,1,1,0};
				};
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- HCWP-CONTEXT MENU ----------------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		

		class 709115:  A3C_RscControlsGroup_NoScroll
		{
			idc = 709115;

			x = 4 * GUI_GRID_W + GUI_GRID_X;
			y = 100 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 31 * GUI_GRID_H;

			
			class ControlsBackGround
			{
				class ALIBI: A3C_RscButton_Invisible
				{
					idc = -1;
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 11.5 * GUI_GRID_W;
					h = 28.5 * GUI_GRID_H;
				};
			};
			class Controls
			{

				
				////////  -------------    R O W   1: GROUPNAME / CLOSE-X
				
				class GPN_BG: A3C_RscPicture
				{
					idc = 709116; // not referred
					text = "#(argb,8,8,3)color(0,0,0,1)";
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};


				class GPN_TEXT: A3C_RscText
				{
					idc = 709121;
					style = 0;
					text = "GroupName";
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class Close_BG: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};
				class Close_X: A3C_RscButton_Invisible
				{
					idc = -1;
					text = "X";
					action = "(findDisplay 100020 displayCtrl 709115) ctrlShow false;";
					
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};

				////////  -------------   BLOCK 1
				

				//-- BEHAVIOUR

				//-- behaviour background needs to be a bit bigger to create spacing - text and line are lowered
				class WP_BEHAVIOUR_HEADER_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 1.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class WP_BEHAVIOUR_HEADER_TEXT: A3C_RscText
				{
					idc = -1;
					style = 0;
					SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
					text = "BEHAVIOUR";
					x = 0 * GUI_GRID_W;
					y = 2 * GUI_GRID_H;
					w = 3 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class WP_BEHAVIOUR_HEADER_Line: A3C_RscLine
				{
					idc = -1;
					//style = 0;
					x = 3 * GUI_GRID_W;
					y = 2.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};


				class WP_BEHAVIOUR: A3C_RscCombo_Dot
				{
					idc = 709139;
					onLBSelChanged = "[709139,(_this select 1)] call A3C_LB_HC";

					x = 0 * GUI_GRID_W;
					y = 2.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};

					tooltip = "WAYPOINT BEHAVIOUR";
				};


				//-- COMBAT MODE

				class WP_COMBATMODE_HEADER_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 4 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				//
				class WP_COMBATMODE_HEADER_TEXT: A3C_RscText
				{
					idc = -1;
					style = 0;
					SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
					text = "COMBAT MODE";
					x = 0 * GUI_GRID_W;
					y = 4 * GUI_GRID_H;
					w = 4 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class WP_COMBATMODE_HEADER_Line: A3C_RscLine
				{
					idc = -1;
					//style = 0;
					x = 4 * GUI_GRID_W;
					y = 4.25 * GUI_GRID_H;
					w = 4 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};


				class WP_COMBATMODE: A3C_RscCombo_Dot
				{
					idc = 709140;
					onLBSelChanged = "[709140,(_this select 1)] call A3C_LB_HC";

					x = 0 * GUI_GRID_W;
					y = 4.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT COMBATMODE";
				};

				//-- SPEED

				class WP_SPEED_HEADER_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 6 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				//
				class WP_SPEED_HEADER_TEXT: A3C_RscText
				{
					idc = -1;
					style = 0;
					SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
					text = "SPEED";
					x = 0 * GUI_GRID_W;
					y = 6 * GUI_GRID_H;
					w = 3 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class WP_SPEED_HEADER_Line: A3C_RscLine
				{
					idc = -1;
					//style = 0;
					x = 3 * GUI_GRID_W;
					y = 6.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};

				class WP_SPEED: A3C_RscCombo_Dot 
				{
					idc = 709138;
					
					onLBSelChanged = "[709138,(_this select 1)] call A3C_LB_HC";
					x = 0 * GUI_GRID_W;
					y = 6.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT SPEED";
				};

				//-- FORMATION

				class WP_FORMATION_HEADER_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 8 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				//
				class WP_FORMATION_HEADER_TEXT: A3C_RscText
				{
					idc = -1;
					style = 0;
					SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
					text = "FORMATION";
					x = 0 * GUI_GRID_W;
					y = 8 * GUI_GRID_H;
					w = 3 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class WP_FORMATION_HEADER_Line: A3C_RscLine
				{
					idc = -1;
					//style = 0;
					x = 3 * GUI_GRID_W;
					y = 8.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};

				class Form_1: A3C_RscCombo_Dot
				{
					idc = 709128;	
					
					onLBSelChanged = "[709128,(_this select 1)] call A3C_LB_HC";
					x = 0 * GUI_GRID_W;
					y = 8.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT FORMATION";
				};

				

				////////  -------------    R O W   5: 'COMPLETION'-Titlebar
				class A3C_RC_GroupConrPreCtrls:  A3C_RscControlsGroup_NoScroll
				{
					idc = 709202;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 2 * GUI_GRID_H;

					class Controls
					{
						class WP_COMPL_HEADER_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						//
						class WP_COMPL_HEADER_Text: A3C_RscText
						{
							idc = 709143;
							style = 0;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							text = "COMPLETION";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class WP_COMPL_HEADER_Line: A3C_RscLine
						{
							idc = -1;
							x = 4 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						////////  -------------    R O W   6: 'COND-PRE'-Combo

						class Cond_Type_PRE: A3C_RscCombo_Dot
						{
							idc = 709123;
							onLBSelChanged = "[709123,(_this select 1)] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.6,0.6,0.6,1};
							colorSelectBackground[] = {0.6,0.6,0.6,1};
							tooltip = "WAYPOINT COMPLETION: TYPE";

						};
						////////  -------------   EXTRA: PRE-COND-VAL

						class Cond_MODE_PRE: A3C_RscCombo_Dot
						{
							idc = 709124;

							
							onLBSelChanged = "[709124,(_this select 1)] call A3C_LB_HC";
							x = 4.5 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H; //y = 18 * GUI_GRID_H;
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.6,0.6,0.6,1};
							colorSelectBackground[] = {0.6,0.6,0.6,1};
							tooltip = "WAYPOINT COMPLETION: VALUE";
						};
					};
				};
				////////  -------------    R O W   3: 'TYPE'-TITLEBAR

				class A3C_RC_GroupTpeActionCtrls:  A3C_RscControlsGroup_NoScroll
				{

					idc = 709203;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 2 * GUI_GRID_H;

					class Controls
					{
						class WP_Type_HEADER_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class WP_Type_HEADER_TEXT: A3C_RscText
						{
							idc = -1;
							style = 0;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							text = "TYPE";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class WP_Type_HEADER_Line: A3C_RscLine
						{
							idc = -1;
							x = 3 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class WP_TYPEACTION: A3C_RscCombo_Dot
						{
							idc = 709141;
							onLBSelChanged = "[709141,(_this select 1)] call A3C_LB_HC";

							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};
							tooltip = "WAYPOINT TYPE";
						};
					};
				};

				

				


				

				////////  -------------    R O W   7: COMFIRM/DELETE

				class CONFIRM_BG: A3C_RscPicture
				{
					idc = 709131;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class CONFIRM_TEXT: A3C_RscButton_Invisible
				{
					idc = 709132;
					action = "[] spawn A3C_Map_HC_waypointContext_ButtonFnc_Confirm";
					text = "CONFIRM";
					shadow = 0;
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class DELETE_BG: A3C_RscPicture
				{
					idc = 709133;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class DELETE_TEXT: A3C_RscButton_Invisible
				{
					idc = 709134;
					text = "DELETE";
					shadow = 0;
					action = "[] call A3C_HC_REMOVE_WP_RC; (findDisplay 100020 displayCtrl 709115) ctrlShow false;";
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

		

				////////  -------------   BLOCK 2: ACTION SETTINGS

				class A3C_RC_GroupActionCtrls:  A3C_RscControlsGroup_NoScroll
				{

					idc = 709200;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{
		
						//--FORM

						class ACT_FORM_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT_FORM_TEXT: A3C_RscText
						{
							idc = -1;
							style = 0;
							text = "ACTION FORMATION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H; 
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT_FORM_LINE: A3C_RscLine
						{
							idc = -1;
							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class Form_2: A3C_RscCombo_Dot 
						{
							idc = 709129;
							
							onLBSelChanged = "[709129,(_this select 1)] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H; 
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION FORMATION";
						};

						//--COND

						class ACT_COND_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; 
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT_COND_TEXT: A3C_RscText
						{
							idc = -1;
							style = 0;
							text = "ACTION COMPLETION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; 
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT_COND_LINE: A3C_RscLine
						{
							idc = -1;
							x = 5 * GUI_GRID_W;
							y = 2.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						class Cond_Type_Post: A3C_RscCombo_Dot
						{
							idc = 709125;

							
							onLBSelChanged = "[709125,(_this select 1)] call A3C_LB_HC";
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; 
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION COMPLETION: TYPE";
						};

						class Cond_Mode_Post: A3C_RscCombo_Dot
						{
							idc = 709126;

							
							onLBSelChanged = "[709126,(_this select 1)] call A3C_LB_HC";
							
							x = 4.5 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; 
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION COMPLETION: VALUE";
						};


					};
				};

				////////  -------------   BLOCK 3: ACTION SETTINGS 2

				class A3C_RC_GroupActionCtrls_2:  A3C_RscControlsGroup_NoScroll
				{

					idc = 709201;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 14 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{


						class ACT2_1_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT2_1_TEXT: A3C_RscText
						{
							idc = 709144;
							style = 0;
							text = "ACTION FORMATION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT2_1_LINE: A3C_RscLine
						{
							idc = -1;

							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class ACT2_1_COMBO: A3C_RscCombo_Dot
						{
							idc = 709145;
							
							onLBSelChanged = "[709145,(_this select 1)] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};
						};

						//--OPTION 2

						class ACT2_2_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT2_2_TEXT: A3C_RscText
						{
							idc = 709146;
							style = 0;
							text = "ACTION COMPLETION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT2_2_LINE: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 5 * GUI_GRID_W;
							y = 2.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						class ACT2_2_COMBO: A3C_RscCombo_Dot 
						{
							idc = 709147;

							
							onLBSelChanged = "[709147,(_this select 1)] call A3C_LB_HC";
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};

						};
					};
				};
										
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- OBJECTSELETOR - MAP VARIANT ------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		
		class 8008: A3C_RscControlsGroup_NoScroll
		{
			idc = 8008;
			
			x = 20 * safezoneW + safezoneX;
			y = 20 * safezoneH + safezoneY;
			w = 0.192528 * safezoneW;
			h = 0.143016 * safezoneH;
			
			class Controls
			{
				
				class A3C_HC_ObjectSelector_Description_BG: A3C_RscPicture
				{
					idc = 800801;
					text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
					x = 0;
					y = 0;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HC_ObjectSelector_Description_Text: A3C_RscText
				{
					idc = 800802;
					//text = "TEST";
					x = 0;
					y = 0;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HC_ObjectSelector_ListBox: A3C_LISTBOX
				{
					idc = 800803;
					style = CT_LISTBOX;
					x = 0;
					y = 0.0440052 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0990114 * safezoneH;
					onMouseEnter = "ctrlSetFocus (findDisplay 100020 displayCtrl 800803)";
					onLBSelChanged = "[(_this select 1)] call A3C_ObjectSelector_LB_Change";
					
				};
			};
		};						          	
	};
};

