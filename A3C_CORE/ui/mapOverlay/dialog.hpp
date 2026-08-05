#include "script_component.hpp"
#include "dialog_defines.hpp"
#include "..\SHARED\shared_ui_defines.hpp"

#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2.5 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2.5 ))


//UI element sizes
#define MAIN_WIDTH_GP 12
#define MAIN_HEIGHT_GP 19

#define A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H (0.08 * safezoneH)
#define A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W (A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 0.75)

class A3C_DSP_MapOverlay
{
	idd = IDD_MAP_OVERLAY;
    movingEnable = true;

    onLoad = EXPAND_AND_QUOTE(_this call FUNC(onLoad));
    onUnload = EXPAND_AND_QUOTE(_this call FUNC(onUnload));

    onKeyDown = EXPAND_AND_QUOTE(private _blockDefaultKey = _this call FUNC(onKeyDown); _blockDefaultKey);
    onKeyUp = EXPAND_AND_QUOTE(_this call FUNC(onKeyUp));

    onMouseButtonDown = EXPAND_AND_QUOTE(_this spawn FUNC(onMouseButtonDown));
    onMouseButtonUp = EXPAND_AND_QUOTE(_this call FUNC(onMouseButtonUp));
		
	class ControlsBackground 
	{	
	
		//---------------------------------------------------------------------------------------------
		//---------- BACKGROUNDS & CONTROL FIELDS -----------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		
		

		class MAP_INPUT_CAPTURE: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_INPUT_CAPTURE; //12;
			onMouseMoving = EXPAND_AND_QUOTE(_this call FUNC(onMouseMoving));
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;
		};

		//---------- UNFOLDABLE SQUAD CONTROL BACKGROUND ----------------------------------------------
		
		//-- DESPITE SEEMINGLY A3C_ui_mapOverlay_fnc_squad_cancelArrowDrag NOT EVER FIRING, THIS DOES PREVENT NEW SQ WAYPOINTS WHEN USING UFSB Controls
		//-- to do: remove this entirely, have a check within mouseButtonDown and exit if hovering over set of boxes
		class MAP_INPUT_BLOCKER: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_INPUT_BLOCKER; //11;
			onMouseEnter = "[] call A3C_ui_mapOverlay_fnc_squad_cancelArrowDrag; ";
			x = 0.21933 * safezoneW + safezoneX;
			y = 100 * safezoneH + safezoneY;
			w = 0.555611 * safezoneW;
			h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		};
		
		class MAP_UFSB_BACKGROUND: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_BACKGROUND; //10;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.21933 * safezoneW + safezoneX;
			y = 100 * safezoneH + safezoneY;
			w = 0.555611 * safezoneW;
			h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		};
		
		class MAP_UFSB_FRAME: A3C_RscFrame 
		{
			idc = IDC_MAP_UFSB_FRAME; //13;
			
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
		
		
		
		

		


		
	};
		


	class Controls 
	{

		


		//---------------------------------------------------------------------------------------------
		//---------- RIGHT SIDE STATIC CONTROL: TREE, TEAM COLORS, EXTRAS -----------------------------
		//---------------------------------------------------------------------------------------------
		
		//-- Tree and teamcolors are shared between radial and mapOverlay
		
		//-- Note: background is already part of tree itself
		class SHARED_UI_TREE_SELECTOR: A3C_CT_TREE
		{
			idc = IDC_SHARED_UI_TREE_SELECTOR;

			colorBackground[] = {0,0,0,0.6};
			onMouseButtonDown = "_this call A3C_ui_shared_fnc_Tree_onBoxClick;";
			x = 0 * safezoneW + safezoneX;
			y = 100;
			w = (8 * 0.03 / (getResolution select 5));
			h = 0.05 / (getResolution select 5);
			onTreeLButtonDown = "_this call A3C_ui_shared_fnc_Tree_onTvChange; false";
			onTreeCollapsed = "[_this,'COLLAPSE',false,0.1] spawn A3C_ui_shared_fnc_Tree_openOrCollapse;  false";
			onTreeExpanded = "[_this,'OPEN',false,0.1] spawn A3C_ui_shared_fnc_Tree_openOrCollapse;  false";
			sizeEx = 0.03 / (getResolution select 5);

		};

		//-- Teamcolor Row

		class MAP_TEAMCOLOR_BG: A3C_RscPicture
		{
			idc = IDC_UI_SHARED_TEAMCOLOR_BG; //7077;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class MAP_TEAMCOLOR_FRAME: A3C_RscFrame
		{
			idc = IDC_SHARED_UI_TEAMCOLOR_FRAME; //7079;
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

		
		class MAP_TCBOX_RED_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_RED_IMG; //1000;
			x = 0.24797 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_RED_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_RED_BTN; //1001;
			onMouseButtonDown = "['Red',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "team red. LMB to select, Shift+LMB to add";
		};
		class MAP_TCBOX_GREEN_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_GREEN_IMG; //1002;
			x = 0.33198 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_GREEN_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_GREEN_BTN; //1003;
			onMouseButtonDown = "['GREEN',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";
			x = 0.33198 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team green. LMB to select, Shift+LMB to add";
		};
		class MAP_TCBOX_BLUE_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_BLUE_IMG; //1004;
			x = 0.41599 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_BLUE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_BLUE_BTN; //1005;
			onMouseButtonDown = "['Blue',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";

			x = 0.41599 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team blue. LMB to select, Shift+LMB to add";
		};
		class MAP_TCBOX_YELLOW_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_YELLOW_IMG; //1006;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_YELLOW_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_YELLOW_BTN; //1007;
			onMouseButtonDown = "['YELLOW',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";

			x = 0.5 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team yellow. LMB to select, Shift+LMB to add";
		};
		class MAP_TCBOX_WHITE_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_WHITE_IMG; //1008;
			x = 0.58401 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_WHITE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_WHITE_BTN; //1009;
			onMouseButtonDown = "['MAIN',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";

			x = 0.58401 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select team white. LMB to select, Shift+LMB to add";
		};
		
		class MAP_TCBOX_PURPLE_IMG: A3C_RscPicture
		{
			idc = IDC_SHARED_UI_TCBOX_PURPLE_IMG; //1010;
			x = 0.66802 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
		};
		class MAP_TCBOX_PURPLE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_SHARED_UI_TCBOX_PURPLE_BTN; //1011;
			onMouseButtonDown = "['PURPLE',(_this select 4)] call A3C_ui_mapOverlay_fnc_UFSB_onTeamColorButton";

			x = 0.66802 * safezoneW + safezoneX;
			y = 0.85733 * safezoneH + safezoneY;
			w = 0.0782815 * safezoneW;
			h = 0.0110018 * safezoneH;
			tooltip = "select all units. LMB to select, Shift+LMB to add";
		};

		//---------- EXTRAS --------------------------------------------
		
		//-- Top Row / Extras - Teamcolors
		class MAP_TOP_EXTRAS_BACKGROUND: A3C_RscPicture
		{
			idc = IDC_MAP_TOP_EXTRAS_BACKGROUND; //7071;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = (safezoneH + safezoneY);
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_TOP_EXTRAS_FRAME: A3C_RscFrame
		{
			idc = IDC_MAP_TOP_EXTRAS_FRAME; //7074;
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


		class MAP_TOP_REFRESH_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_TOP_REFRESH_IMG; //7072;
			x = 0.288066 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_Refresh_Data_1_Clk: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_TOP_REFRESH_BTN; //7073;
			onmousebuttondown = "[(units group player) - [player]] call A3C_ui_shared_fnc_resetPlayerGroup;";

			x = 0.288066 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "refresh group";
		};


		class MAP_TOP_DISBAND_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_TOP_DISBAND_IMG; //7075;
			x = 0.729118 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY; //safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_TOP_DISBAND_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_TOP_DISBAND_BTN; //7076;
			action = "[] spawn A3C_ui_mapOverlay_fnc_UFSB_onDisbandHcButton";
			
			x = 0.729118 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
			tooltip = "Disband selected units to High Command";
		};

		class MAP_TOP_TOGGLETRACKER_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_TOP_TOGGLETRACKER_IMG; //1219;
			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class MAP_TOP_TOGGLETRACKER_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_TOP_TOGGLETRACKER_BTN; //7096;
			action = "[] call A3C_ui_mapOverlay_fnc_onToggleEnemyTracker;";

			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "Toggle Force Tracking";
		};
		
		
		//---------------------------------------------------------------------------------------------
		//---------- UNFOLDABLE SQUAD-BAR (UFSB): UI-CONTROLS -----------------------------------------
		//---------------------------------------------------------------------------------------------
		class MAP_UFSB_STANCE_TRAVEL_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_STANCE_TRAVEL_IMG; //7044;
			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_STANCE_TRAVEL_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_STANCE_TRAVEL_BTN; //7045;
			onMouseButtonDown = EXPAND_AND_QUOTE([ARR_4([ARR_2(IDC_MAP_UFSB_STANCE_TRAVEL_IMG,IDC_MAP_UFSB_STANCE_TRAVEL_BTN)],'SQ_STANCE_1',1,true)] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup);
			onMouseZChanged = "[_this select 1] call A3C_ui_mapOverlay_fnc_UFSB_onStanceTravelButton";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "stance while en route";
		};
		class MAP_UFSB_WP_SPEED_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_WP_SPEED_IMG; //7048;
			x = 0.293794 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_WP_SPEED_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_WP_SPEED_BTN; //7049;
			onMouseButtonDown = "[] call A3C_ui_mapOverlay_fnc_UFSB_onWaypointSpeedButton";
			onMouseZChanged = "[] call A3C_ui_mapOverlay_fnc_UFSB_onWaypointSpeedButton";

			x = 0.293794 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set travel speed";
		};
		class MAP_UFSB_STANCE_ARRIVAL_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_STANCE_ARRIVAL_IMG; //7046;
			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_STANCE_ARRIVAL_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_STANCE_ARRIVAL_BTN; //7047;
			onMouseButtonDown = EXPAND_AND_QUOTE([ARR_4([ARR_2(IDC_MAP_UFSB_STANCE_ARRIVAL_IMG,IDC_MAP_UFSB_STANCE_ARRIVAL_BTN)],'SQ_STANCE_2',1,true)] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup);
			onMouseZChanged = "[_this select 1] call A3C_ui_mapOverlay_fnc_UFSB_onStanceArrivalButton;";

			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set stance upon arrival";
		};

		class MAP_UFSB_COMBATMODE_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_COMBATMODE_IMG; //7062;
			x = 0.385441 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_COMBATMODE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_COMBATMODE_BTN; //7063;
			onMouseButtonDown = "[] call A3C_ui_mapOverlay_fnc_UFSB_onCombatModeButton";
			onMouseZChanged = "[] call A3C_ui_mapOverlay_fnc_UFSB_onCombatModeButton";

			x = 0.385441 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "WP Combat-Mode: Default/Engage";
		};

		class MAP_UFSB_WPACTION_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_WPACTION_IMG; //7064;
			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_WPACTION_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_WPACTION_BTN; //7065;
			onMouseButtonDown = EXPAND_AND_QUOTE([ARR_4([ARR_2(IDC_MAP_UFSB_WPACTION_IMG,IDC_MAP_UFSB_WPACTION_BTN)],'SQ_ACTION',1,true)] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup);
			onMouseZChanged = "[(_this select 1),false,true] spawn A3C_ui_mapOverlay_fnc_UFSB_onActionMouseZ;";

			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "";
		};

		class MAP_UFSB_WPFORMATION_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_WPFORMATION_IMG; //7050;
			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class MAP_UFSB_WPFORMATION_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_WPFORMATION_BTN; //7051;
			onMouseButtonDown = EXPAND_AND_QUOTE([ARR_4([ARR_2(IDC_MAP_UFSB_WPFORMATION_IMG,IDC_MAP_UFSB_WPFORMATION_BTN)],'SQ_FORMATION',1,true)] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup);
			onMouseZChanged = "[_this select 1] call A3C_ui_mapOverlay_fnc_UFSB_onFormationButton";

			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set formation (connected tolooking-direction)";
		};
		
		class MAP_UFSB_SPACING: A3C_CT_EDIT
		{
			idc = IDC_MAP_UFSB_SPACING; //7066;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			onSetFocus = "['SPACING','ON'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive";
			onKillFocus = "['SPACING','OFF'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive";
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
		
		
		
		class MAP_UFSB_WPCONDITION_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_WPCONDITION_IMG; //7022;
			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class MAP_UFSB_WPCONDITION_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_WPCONDITION_BTN; //7007;
			onMouseButtonDown = EXPAND_AND_QUOTE([ARR_4([ARR_2(IDC_MAP_UFSB_WPCONDITION_IMG,IDC_MAP_UFSB_WPCONDITION_BTN)],'SQ_CONDITION',1,true)] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup);
			onMouseZChanged = "[_this select 1] call A3C_ui_mapOverlay_fnc_UFSB_onConditionButton";

			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "WP Condition: NONE (LMB to cycle through options)";
		};
		//-- popup Timeout CT
		class MAP_UFSB_TIMEOUT_POPUP: A3C_CT_EDIT
		{
			idc = IDC_MAP_UFSB_TIMEOUT_POPUP; //7009;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			colorSelection[] = {1,1,1,1};
			colorDisabled[] = {};
			colorBackground[] = {0,0,0,0.6};
			onSetFocus = "['TIMEOUT','ON'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive";
			onKillFocus = "['TIMEOUT','OFF'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive";
			tooltip = "Set Timeout";
			text = "05";
			x = 0.580191 * safezoneW + safezoneX;
			y = safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,1};
			sizeEx = "0.03 / (getResolution select 5)";	
		};

		class MAP_UFSB_UNDO_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_UNDO_IMG; //7092;
			x = 0.620287 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,0.7};
		};
		class MAP_UFSB_UNDO_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_UNDO_BTN; //7041;
			action = "[] call A3C_ui_mapOverlay_fnc_UFSB_onUndoButton";
			toolTip = "Undo";
			x = 0.620287 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;

		};

		class MAP_UFSB_CANCEL_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_CANCEL_IMG; //7069;
			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class MAP_UFSB_CANCEL_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_CANCEL_BTN; //7070;
			onmousebuttondown = "[A3C_SELECTED_UNITS,(_this select 4),(_this select 5)] spawn A3C_ai_shared_fnc_cancelUnitPlot";

			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "LMB: delete session. shift+LMB: delete active orders. ctrl+LMB: skip currentwaypoint"; //--- 	ToDo: 	Localize;
		};

		class MAP_UFSB_HOLD_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_HOLD_IMG; //8000;

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
		};
		class MAP_UFSB_HOLD_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_HOLD_BTN; //8001;
			action = "A3C_SELECTED_UNITS call A3C_ai_squad_fnc_unitRouteHold";

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
			tooltip = "Selected units STANDBY";
		};
		class MAP_UFSB_CONTINUE_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_CONTINUE_IMG; //8002;
			x = 0.654655 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
		};
		class MAP_UFSB_CONTINUE_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_UFSB_CONTINUE_BTN; //8003;
			action = "A3C_SELECTED_UNITS call A3C_ai_squad_fnc_unitRouteContinue";

			x = 0.654655 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0229118 * safezoneW;
			h = 0.044007 * safezoneH;
			tooltip = "Selected units CONTINUE";
		};

		
		//---------- UNFOLDABLE SQUAD-BAR: EXECUTE BUTTONS --------------------------------------------
		
		class MAP_UFSB_CommitAll: A3C_ShortcutButton
		{
			idc = IDC_MAP_UFSB_CommitAll; //7018;
			
			action = "['ALL'] spawn A3C_ui_mapOverlay_fnc_UFSB_onCommitButton";
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
		class MAP_UFSB_CommitSelected: A3C_ShortcutButton
		{
			idc = IDC_MAP_UFSB_CommitSelected; //7019;
			action = "['SELECTED'] spawn A3C_ui_mapOverlay_fnc_UFSB_onCommitButton";
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
		class MAP_UFSB_Exit: A3C_ShortcutButton
		{
			idc = IDC_MAP_UFSB_Exit; //7020;
			action = "[] call A3C_ui_mapOverlay_fnc_UFSB_onExitButton";
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

		//---------- UNKNOWN PURPOSE - not used anywhere

		// class A3C_TEXT_07: A3C_RscText
		// {
		// 	idc = 7014;

		// 	x = -0.0498831 * safezoneW + safezoneX;
		// 	y = 0.00492081 * safezoneH + safezoneY;
		// 	w = 0.234846 * safezoneW;
		// 	h = 0.0330053 * safezoneH;
		// };
		// class A3C_TEXT_08: A3C_RscText
		// {
		// 	idc = 7015;

		// 	x = -0.0326993 * safezoneW + safezoneX;
		// 	y = 0.0709314 * safezoneH + safezoneY;
		// 	w = 0.183294 * safezoneW;
		// 	h = 0.0220035 * safezoneH;
		// };
		
		// class RText_7042: A3C_RscText
		// {
		// 	idc = 7042;
		// 	x = 0 * GUI_GRID_W + GUI_GRID_X;
		// 	y = 1 * GUI_GRID_H + GUI_GRID_Y;
		// 	w = 7.5 * GUI_GRID_W;
		// 	h = 1 * GUI_GRID_H;
		// };
		
		
		
		
		class MAP_UFSB_Subselection_01_BG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_Subselection_01_BG; //1010101;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
		};
		
		class MAP_UFSB_Subselection_02_BG: A3C_RscPicture
		{
			idc = IDC_MAP_UFSB_Subselection_02_BG; //1010102;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
		};

		
		
		
		//---------- UNFOLDABLE SQUAD BAR (UFSQB): POPUP SUB SELECTION -------------------------------

		//---------- SUB SELECTION  ------------------------------------------------------------
		class MAP_UFSB_Subselection_01_Parent: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_MAP_UFSB_Subselection_01_Parent; //8009;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H * 2;
			class Controls
			{
				class MAP_UFSB_Subselection_01_IMG_01: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_01; //800901;
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_01: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_01; //800911;
					x = 0* safezoneW;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_02: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_02; //800902;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_02: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_02; //800912;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_03: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_03; //800903;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_03: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_03; //800913;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_04: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_04; //800904;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_04: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_04; //800914;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_05: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_05; //800905;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_05: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_05; //800915;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_06: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_06; //800906;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_06: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_06; //800916;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_07: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_07; //800907;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_07: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_07; //800917;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_08: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_08; //800908;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_08: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_08; //800918;
					y = 0;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_09: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_09; //800909;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_09: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_09; //800919;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_01_IMG_10: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_01_IMG_10; //800910;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_01_BTN_10: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_01_BTN_10; //800920;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};	
			};
		};
		
		class MAP_UFSB_Subselection_02_Parent: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_MAP_UFSB_Subselection_02_Parent; //8010;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100;
			w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 10;
			h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
			class Controls
			{
				class MAP_UFSB_Subselection_02_IMG_01: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_01; //801001;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_01: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_01; //801011;
					x = 0;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_02: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_02; //801002;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_02: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_02; //801012;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_03: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_03; //801003;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_03: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_03; //801013;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_04: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_04; //801004;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_04: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_04; //801014;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_05: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_05; //801005;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_05: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_05; //801015;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_06: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_06; //801006;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_06: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_06; //801016;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_07: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_07; //801007;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_07: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_07; //801017;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_08: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_08; //801008;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_08: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_08; //801018;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_09: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_09; //801009;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_09: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_09; //801019;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};

				class MAP_UFSB_Subselection_02_IMG_10: A3C_RscPicture
				{
					idc = IDC_MAP_UFSB_Subselection_02_IMG_10; //801010;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};
				class MAP_UFSB_Subselection_02_BTN_10: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_UFSB_Subselection_02_BTN_10; //801020;
					x = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W;
					h = A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H;
				};	
			};
		};

		

		
		
		
		

		


		//---------------------------------------------------------------------------------------------
		//---------- HCGP-CONTEXT: ACTIONS (SEPARATE) -------------------------------------------------
		//---------------------------------------------------------------------------------------------
		

		//---------- STARTUP VISUALIZATION ------------------------------------------------------------

		class MAP_HCGP_STARTUP_BAR: A3C_RscProgress
		{
			idc = IDC_MAP_HCGP_STARTUP_BAR; //404040;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 18.5 * GUI_GRID_W;
			h = 0.25 * GUI_GRID_H;
		};
		class MAP_HCGP_STARTUP_TEXT: A3C_RscText
		{
			idc = IDC_MAP_HCGP_STARTUP_TEXT; //404041;
			text = "";
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 18.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			sizeEx = 0.07 / (getResolution select 5);
			font = "PuristaMedium";
		};

		//---------- CONTEXT MENU ---------------------------------------------------------------------

		class MAP_HCGP_Parent: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_MAP_HCGP_Parent; //8007;

			x = 0;
			y = 200;
			w = GRIDX( MAIN_WIDTH_GP );
			h = GRIDY( MAIN_HEIGHT_GP);



			class Controls
			{
				
				//-- STANCES: These are mostly static, so buttons do not need IDC. Images do require IDC so the active stance can be highlighted in UI
				class MAP_HCGP_Stances_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0,0,0,0.35)";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				
				class MAP_HCGP_STANCES_AUTO_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_STANCES_AUTO_IMG; //800724;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_AUTO_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['AUTO'] call A3C_ui_mapOverlay_fnc_HCGP_onStanceButton";
					tooltip = "set group stance to AUTO";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_STAND_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_STANCES_STAND_IMG; //800725;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 2 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_STAND_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['UP'] call A3C_ui_mapOverlay_fnc_HCGP_onStanceButton";
					tooltip = "set group stance to STAND";
					x = GRIDX( 2 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_CROUCH_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_STANCES_CROUCH_IMG; //800726;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 4 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_CROUCH_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['MIDDLE'] call A3C_ui_mapOverlay_fnc_HCGP_onStanceButton";
					tooltip = "set group stance to CROUCH";
					x = GRIDX( 4 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_PRONE_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_STANCES_PRONE_IMG; //800727;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 6 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_STANCES_PRONE_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['DOWN'] call A3C_ui_mapOverlay_fnc_HCGP_onStanceButton";
					tooltip = "set group stance to PRONE";
					x = GRIDX( 6 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				
				

				
				
				class MAP_HCGP_LISTBOX_BEHAVIOUR: A3C_LISTBOX
				{
					idc = IDC_MAP_HCGP_LISTBOX_BEHAVIOUR; //800701;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(IDC_MAP_HCGP_LISTBOX_BEHAVIOUR,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_mapOverlay_fnc_HCGP_onLbChange);

					colorBackground[] = {0.2,0.2,0.2,0.7};
				};
				
				
				class MAP_HCGP_LISTBOX_COMBATMODE: A3C_LISTBOX
				{
					idc = IDC_MAP_HCGP_LISTBOX_COMBATMODE; //800702;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY( 2 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(IDC_MAP_HCGP_LISTBOX_COMBATMODE,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_mapOverlay_fnc_HCGP_onLbChange);
					colorBackground[] = {0.6,0.6,0.6,0.7};
				};

				class MAP_HCGP_LISTBOX_FORMATION: A3C_LISTBOX
				{
					idc = IDC_MAP_HCGP_LISTBOX_FORMATION; //800703;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY(6 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(IDC_MAP_HCGP_LISTBOX_FORMATION,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_mapOverlay_fnc_HCGP_onLbChange);
					colorBackground[] = {0.2,0.2,0.2,0.7};
				};
				class MAP_HCGP_LISTBOX_TEAMCOLOR: A3C_LISTBOX
				{
					idc = IDC_MAP_HCGP_LISTBOX_TEAMCOLOR; //800704;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY(6 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(IDC_MAP_HCGP_LISTBOX_TEAMCOLOR,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_mapOverlay_fnc_HCGP_onLbChange);
					colorBackground[] = {0.6,0.6,0.6,0.7};
				};
	
				
				class MAP_HCGP_CONFIRM_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_CONFIRM_BG; //800707;
					text = "#(argb,8,8,3)color(0,1,0,0.35)";
					x = GRIDX( 0 ); 
					y = GRIDY( 10 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				
				
				class MAP_HCGP_CONFIRM_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_CONFIRM_BTN; //800711;
					text = "CONFIRM";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
					sizeEx = 0.045;
					action = "[] call A3C_ui_mapOverlay_fnc_HCGP_onConfirmButton";
					x = GRIDX( 0 ); 
					y = GRIDY( 10 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );	
				};

				class MAP_HCGP_CANCEL_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_CANCEL_BG; //800708;
					text = "#(argb,8,8,3)color(1,0,0,1)";
					x = GRIDX( 8 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_CANCEL_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_CANCEL_BTN; //800712;
					text = "X";
					action = EXPAND_AND_QUOTE((findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCGP_Parent) ctrlShow false; A3C_SELECTED_HC_GROUPS_SETTINGS = []; (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_DASHBOARD_PARENT) ctrlShow false);
					x = GRIDX( 8 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};

				//-- ACTION BUTTON MACROS (3 controls per item)
				
				//-- Action Button Macro 0
				class MAP_HCGP_ActionMacro_0_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_0_BG; //8007161;
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_0_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_0_IMG; //8007162;
					text = "";
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_0_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_0_BTN; //8007163;
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,0,[ARR_3(IDC_MAP_HCGP_ActionMacro_0_BG,IDC_MAP_HCGP_ActionMacro_0_IMG,IDC_MAP_HCGP_ActionMacro_0_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				//-- Action Button Macro 1
				class MAP_HCGP_ActionMacro_1_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_1_BG; //8007171;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_1_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_1_IMG; //8007172;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );//--buttonup??
				};
				
				class MAP_HCGP_ActionMacro_1_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_1_BTN; //8007173;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );//--buttonup??
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,1,[ARR_3(IDC_MAP_HCGP_ActionMacro_1_BG,IDC_MAP_HCGP_ActionMacro_1_IMG,IDC_MAP_HCGP_ActionMacro_1_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				
				
				
				//-- Action Button Macro 2
				class MAP_HCGP_ActionMacro_2_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_2_BG; //8007181;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_2_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_2_IMG; //8007182;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_2_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_2_BTN; //8007183;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,2,[ARR_3(IDC_MAP_HCGP_ActionMacro_2_BG,IDC_MAP_HCGP_ActionMacro_2_IMG,IDC_MAP_HCGP_ActionMacro_2_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				
				
				
				//-- Action Button Macro 3
				class MAP_HCGP_ActionMacro_3_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_3_BG; //8007191;
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_3_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_3_IMG; //8007192;
					text = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_3_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_3_BTN; //8007193;
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,3,[ARR_3(IDC_MAP_HCGP_ActionMacro_3_BG,IDC_MAP_HCGP_ActionMacro_3_IMG,IDC_MAP_HCGP_ActionMacro_3_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				
				
				
				
				//-- Action Button Macro 4
				class MAP_HCGP_ActionMacro_4_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_4_BG; //8007201;
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_4_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_4_IMG; //8007202;
					text = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_4_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_4_BTN; //8007203;
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,4,[ARR_3(IDC_MAP_HCGP_ActionMacro_4_BG,IDC_MAP_HCGP_ActionMacro_4_IMG,IDC_MAP_HCGP_ActionMacro_4_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				
				//-- Action Button Macro 5
				class MAP_HCGP_ActionMacro_5_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_5_BG; //8007211;
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_5_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_5_IMG; //8007212;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_5_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_5_BTN; //8007213;
					x = GRIDX( 10 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,5,[ARR_3(IDC_MAP_HCGP_ActionMacro_5_BG,IDC_MAP_HCGP_ActionMacro_5_IMG,IDC_MAP_HCGP_ActionMacro_5_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				//-- Action Button Macro 6
				class MAP_HCGP_ActionMacro_6_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_6_BG; //8007221;
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_6_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_6_IMG; //8007222;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_6_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_6_BTN; //8007223;
					x = GRIDX( 10 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,6,[ARR_3(IDC_MAP_HCGP_ActionMacro_6_BG,IDC_MAP_HCGP_ActionMacro_6_IMG,IDC_MAP_HCGP_ActionMacro_6_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				//-- Action Button Macro 7
				class MAP_HCGP_ActionMacro_7_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_7_BG; //8007231;
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_7_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_7_IMG; //8007232;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_7_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_7_BTN; //8007233;
					x = GRIDX( 10 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,7,[ARR_3(IDC_MAP_HCGP_ActionMacro_7_BG,IDC_MAP_HCGP_ActionMacro_7_IMG,IDC_MAP_HCGP_ActionMacro_7_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				//-- Action Button Macro 8
				class MAP_HCGP_ActionMacro_8_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_8_BG; //8007241;
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_8_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_8_IMG; //8007242;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_8_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_8_BTN; //8007243;
					x = GRIDX( 10 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,8,[ARR_3(IDC_MAP_HCGP_ActionMacro_8_BG,IDC_MAP_HCGP_ActionMacro_8_IMG,IDC_MAP_HCGP_ActionMacro_8_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
				};
				
				
				//-- Action Button Macro 9
				class MAP_HCGP_ActionMacro_9_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_9_BG; //8007251;
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					text = "#(argb,8,8,3)color(0,0,0,0.8)";
				};
				class MAP_HCGP_ActionMacro_9_IMG: A3C_RscPicture
				{
					idc = IDC_MAP_HCGP_ActionMacro_9_IMG; //8007252;
					text = "";
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class MAP_HCGP_ActionMacro_9_BTN: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCGP_ActionMacro_9_BTN; //8007253;
					x = GRIDX( 10 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonDown = EXPAND_AND_QUOTE([ARR_3(_this,9,[ARR_3(IDC_MAP_HCGP_ActionMacro_9_BG,IDC_MAP_HCGP_ActionMacro_9_IMG,IDC_MAP_HCGP_ActionMacro_9_BTN)])] call A3C_ui_mapOverlay_fnc_HCGP_onActionMouseButtonDown);
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

					onSetFocus = "['GROUPNAME','ON'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive; ['ON'] call A3C_ui_mapOverlay_fnc_HCGP_activateDashboardEditName;";
					onKillFocus = "['GROUPNAME','OFF'] call A3C_ui_mapOverlay_fnc_CTEdit_setActive; ['OFF'] call A3C_ui_mapOverlay_fnc_HCGP_activateDashboardEditName;";

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
		

		class MAP_HCWP_Parent:  A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_MAP_HCWP_Parent; //709115;

			x = 4 * GUI_GRID_W + GUI_GRID_X;
			y = 100 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 31 * GUI_GRID_H;

			
			class ControlsBackground
			{
				class MAP_HCWP_InvisibleBackground: A3C_RscButton_Invisible //-- this likely has a important function which i can not remember
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

				
				//-- Top Row: GROUPNAME / CLOSE ('X')
				
				class MAP_HCWP_GroupName_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCWP_GROUPNAME_BG; //709116; 
					text = "#(argb,8,8,3)color(0,0,0,1)";
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};


				class MAP_HCWP_GroupName_TXT: A3C_RscText
				{
					idc = IDC_MAP_HCWP_GROUPNAME_TXT; //709121;
					style = 0;
					text = "GroupName";
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class MAP_HCWP_CloseMenu_BG: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};
				class MAP_HCWP_CloseMenu_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					text = "X";
					action = EXPAND_AND_QUOTE((findDisplay IDD_MAP_OVERLAY displayCtrl IDC_MAP_HCWP_Parent) ctrlShow false);
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};

				//-- WaypointSettings - Listboxes
				//-------------------------------
				
				//-- BEHAVIOUR
				//-- behaviour background needs to be a bit bigger to create spacing - text and line are lowered
				class MAP_HCWP_Behaviour_Header_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 1.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class MAP_HCWP_Behaviour_Header_TXT: A3C_RscText
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
				class MAP_HCWP_Behaviour_Header_Line: A3C_RscLine
				{
					idc = -1;
					//style = 0;
					x = 3 * GUI_GRID_W;
					y = 2.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};


				class MAP_HCWP_Behaviour_Combo: A3C_RscCombo_Dot
				{
					idc = IDC_MAP_HCWP_Behaviour_Combo; //709139;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Behaviour_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);

					x = 0 * GUI_GRID_W;
					y = 2.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};

					tooltip = "WAYPOINT BEHAVIOUR";
				};


				//-- COMBAT MODE
				class MAP_HCWP_CombatMode_Header_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 4 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class MAP_HCWP_CombatMode_Header_TXT: A3C_RscText
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
				class MAP_HCWP_CombatMode_Header_Line: A3C_RscLine
				{
					idc = -1;
					x = 4 * GUI_GRID_W;
					y = 4.25 * GUI_GRID_H;
					w = 4 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};
				class MAP_HCWP_CombatMode_Combo: A3C_RscCombo_Dot
				{
					idc = IDC_MAP_HCWP_CombatMode_Combo; //709140;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_CombatMode_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);

					x = 0 * GUI_GRID_W;
					y = 4.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT COMBATMODE";
				};

				//-- WAYPOINT-SPEED
				class MAP_HCWP_Speed_Header_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 6 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class MAP_HCWP_Speed_Header_TXT: A3C_RscText
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
				class MAP_HCWP_Speed_Header_Line: A3C_RscLine
				{
					idc = -1;
					x = 3 * GUI_GRID_W;
					y = 6.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};
				class MAP_HCWP_Speed_Combo: A3C_RscCombo_Dot 
				{
					idc = IDC_MAP_HCWP_Speed_Combo; //709138;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Speed_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
					x = 0 * GUI_GRID_W;
					y = 6.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT SPEED";
				};

				//-- WAYPOINT-FORMATION
				class MAP_HCWP_Formation_Header_BG: A3C_RscPicture
				{
					idc = -1;

					text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
					x = 0 * GUI_GRID_W;
					y = 8 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 0.5 * GUI_GRID_H;
				};
				class MAP_HCWP_Formation_Header_TXT: A3C_RscText
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
				class MAP_HCWP_Formation_Header_Line: A3C_RscLine
				{
					idc = -1;
					x = 3 * GUI_GRID_W;
					y = 8.25 * GUI_GRID_H;
					w = 5 * GUI_GRID_W;
					h = 0 * GUI_GRID_H;
				};
				class MAP_HCWP_Formation_Combo: A3C_RscCombo_Dot
				{
					idc = IDC_MAP_HCWP_Formation_Combo; //709128;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Formation_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
					x = 0 * GUI_GRID_W;
					y = 8.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT FORMATION";
				};

				//-- WAYPOINT-COMPLETION
				//----------------------
				class MAP_HCWP_Completion_Parent:  A3C_RscControlsGroup_NoScroll
				{
					idc = IDC_MAP_HCWP_Completion_Parent; //709202;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 2 * GUI_GRID_H;

					class Controls
					{
						class MAP_HCWP_Completion_Header_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.6,0.6,0.6,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						//
						class MAP_HCWP_Completion_Header_TXT: A3C_RscText
						{
							idc = IDC_MAP_HCWP_Completion_Header_TXT; //709143;
							style = 0;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							text = "COMPLETION";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class MAP_HCWP_Completion_Header_Line: A3C_RscLine
						{
							idc = -1;
							x = 4 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						//-- Condition - PRE
						//------------------
						class MAP_HCWP_Condition_Pre_Type: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Condition_Pre_Type; //709123;
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Condition_Pre_Type,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.6,0.6,0.6,1};
							colorSelectBackground[] = {0.6,0.6,0.6,1};
							tooltip = "WAYPOINT COMPLETION: TYPE";

						};
						class MAP_HCWP_Condition_Pre_Mode: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Condition_Pre_Mode; //709124;

							
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Condition_Pre_Mode,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
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
				
				//-- WAYPOINT-TYPE COMBO
				//----------------------
				class MAP_HCWP_Type_Parent:  A3C_RscControlsGroup_NoScroll
				{

					idc = IDC_MAP_HCWP_Type_Parent; //709203;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 2 * GUI_GRID_H;

					class Controls
					{
						class MAP_HCWP_Type_Header_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class MAP_HCWP_Type_Header_TXT: A3C_RscText
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
						class MAP_HCWP_Type_Header_Line: A3C_RscLine
						{
							idc = -1;
							x = 3 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class MAP_HCWP_Type_Action: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Type_Action; //709141;
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Type_Action,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);

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

				

		

				//-- WAYPOINT-ACTION SETTINGS MAIN
				//-----------------------------

				class MAP_HCWP_Action_Parent_MAIN:  A3C_RscControlsGroup_NoScroll
				{

					idc = IDC_MAP_HCWP_Action_Parent_MAIN; //709200;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{
		
						//-- Action Formation
						class MAP_HCWP_Action_Formation_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Formation_TXT: A3C_RscText
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
						class MAP_HCWP_Action_Formation_LINE: A3C_RscLine
						{
							idc = -1;
							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Formation_Combo: A3C_RscCombo_Dot 
						{
							idc = IDC_MAP_HCWP_Action_Formation_Combo; //709129;
							
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Action_Formation_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H; 
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION FORMATION";
						};

						//-- Action Condition

						class MAP_HCWP_Action_Condition_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; 
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Condition_TXT: A3C_RscText
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
						class MAP_HCWP_Action_Condition_LINE: A3C_RscLine
						{
							idc = -1;
							x = 5 * GUI_GRID_W;
							y = 2.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						class MAP_HCWP_Condition_Post_Type: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Condition_Post_Type; //709125;

							
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Condition_Post_Type,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; 
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION COMPLETION: TYPE";
						};

						class MAP_HCWP_Condition_Post_Mode: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Condition_Post_Mode; //709126;

							
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Condition_Post_Mode,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							
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

				//-- WAYPOINT-ACTION SETTINGS ADDITIONAL
				//-----------------------------

				class MAP_HCWP_Action_Parent_ADD:  A3C_RscControlsGroup_NoScroll
				{

					idc = IDC_MAP_HCWP_Action_Parent_ADD; //709201;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 14 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{


						class MAP_HCWP_Action_Add_Formation_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Add_Formation_TXT: A3C_RscText
						{
							idc = IDC_MAP_HCWP_Action_Add_Formation_TXT; //709144;
							style = 0;
							text = "ACTION FORMATION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class MAP_HCWP_Action_Add_Formation_LINE: A3C_RscLine
						{
							idc = -1;

							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Add_Formation_Combo: A3C_RscCombo_Dot
						{
							idc = IDC_MAP_HCWP_Action_Add_Formation_Combo; //709145

							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Action_Add_Formation_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};
						};

						//--OPTION 2

						class MAP_HCWP_Action_Add_Completion_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class MAP_HCWP_Action_Add_Completion_TXT: A3C_RscText
						{
							idc = IDC_MAP_HCWP_Action_Add_Completion_TXT; //709146
							style = 0;
							text = "ACTION COMPLETION";
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class MAP_HCWP_Action_Add_Completion_LINE: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 5 * GUI_GRID_W;
							y = 2.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						class MAP_HCWP_Action_Add_Completion_Combo: A3C_RscCombo_Dot 
						{
							idc = IDC_MAP_HCWP_Action_Add_Completion_Combo; //709147;

							
							onLBSelChanged = EXPAND_AND_QUOTE([ARR_2(IDC_MAP_HCWP_Action_Add_Completion_Combo,(_this select 1))] call A3C_ui_mapOverlay_fnc_HCWP_onLbChange);
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};

						};
					};
				};

				//-- Final Row: Confirm & Delete
				//-----------------------------

				class MAP_HCWP_Confirm_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCWP_Confirm_BG; //709131;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class MAP_HCWP_Confirm_TEXT: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCWP_Confirm_TEXT; //709132;
					action = "[] spawn A3C_ui_mapOverlay_fnc_HCWP_onConfirmButton";
					text = "CONFIRM";
					shadow = 0;
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class MAP_HCWP_Delete_BG: A3C_RscPicture
				{
					idc = IDC_MAP_HCWP_Delete_BG; //709133;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class MAP_HCWP_Delete_TEXT: A3C_RscButton_Invisible
				{
					idc = IDC_MAP_HCWP_Delete_TEXT; //709134;
					text = "DELETE";
					shadow = 0;
					action = EXPAND_AND_QUOTE([] call A3C_ui_mapOverlay_fnc_HCWP_onDeleteButton);
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
										
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- OBJECTSELETOR - MAP VARIANT ------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		
		class MAP_SelectionPromptPanel_Parent: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_SHARED_UI_SelectionPromptPanel_Parent; //8008;
			
			x = 20 * safezoneW + safezoneX;
			y = 20 * safezoneH + safezoneY;
			w = 0.192528 * safezoneW;
			h = 0.143016 * safezoneH;
			
			class Controls
			{
				
				class MAP_SelectionPromptPanel_Description_BG: A3C_RscPicture
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_Description_BG; //800801;
					text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
					x = 0;
					y = 0;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class MAP_SelectionPromptPanel_Description_TXT: A3C_RscText
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_Description_TXT; //800802;
					x = 0;
					y = 0;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class MAP_SelectionPromptPanel_ListBox: A3C_LISTBOX
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_ListBox; //800803;
					style = CT_LISTBOX;
					x = 0;
					y = 0.0440052 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0990114 * safezoneH;
					onMouseEnter = EXPAND_AND_QUOTE(ctrlSetFocus (findDisplay IDD_MAP_OVERLAY displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox));
					onLBSelChanged = "[(_this select 1)] call A3C_UI_selectionPromptPanel_fnc_onLBSelChangedShared";	
				};
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- SQUAD LEVEL WAYPOINT MENU --------------------------------------------------------
		//---------------------------------------------------------------------------------------------
		
		class MAP_SQWP_ControlsGroup: A3C_RscControlsGroup
		{
			idc = IDC_MAP_SQWP_Parent; //709109;
			x = 62 * GUI_GRID_W + GUI_GRID_X;
			y = -9.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.5 * GUI_GRID_W;
			h = 20 * GUI_GRID_H;
	
			class Controls
			{

				class MAP_SQWP_Speed_IMG :  A3C_RscPicture
				{
					idc = IDC_MAP_SQWP_Speed_IMG; //709110;
					text = "A3C_CORE\ui\pictures\icon_menu_speed_full.paa"; 
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class MAP_SQWP_Speed_BTN :  A3C_RscButton_Invisible
				{
					idc = IDC_MAP_SQWP_Speed_BTN; //7091101;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['SPEED'] call A3C_ui_mapOverlay_fnc_buttonFncContext";
				};
				class MAP_SQWP_Stance_Travel_IMG :  A3C_RscPicture
				{
					idc = IDC_MAP_SQWP_Stance_Travel_IMG; //709111;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class MAP_SQWP_Stance_Travel_BTN :  A3C_RscButton_Invisible
				{
					idc = IDC_MAP_SQWP_Stance_Travel_BTN; //7091111;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['STANCE1'] call A3C_ui_mapOverlay_fnc_buttonFncContext";
				};
				class MAP_SQWP_Combo :  A3C_RscCombo
				{
					idc = IDC_MAP_SQWP_Combo; //709112;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 5.5 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(A3C_LB_MODE,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_shared_fnc_onLbChange);
				};
				class MAP_SQWP_Stance_Arrival_IMG :  A3C_RscPicture
				{
					idc = IDC_MAP_SQWP_Stance_Arrival_IMG; //709113;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_crouch.paa";
					x = 3 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class MAP_SQWP_Stance_Arrival_BTN :  A3C_RscButton_Invisible
				{
					idc = IDC_MAP_SQWP_Stance_Arrival_BTN; //7091131;
					x = 3 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['STANCE2'] call A3C_ui_mapOverlay_fnc_buttonFncContext";
				};
				class MAP_SQWP_Delete_IMG :  A3C_RscPicture
				{
					idc = IDC_MAP_SQWP_Delete_IMG; //709114;
					text = "A3C_CORE\ui\pictures\icon_Menu_trash.paa";
					x = 4.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class MAP_SQWP_Delete_BTN :  A3C_RscButton_Invisible
				{
					idc = IDC_MAP_SQWP_Delete_BTN; //7091141;
					x = 4.5 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['DELETE'] call A3C_ui_mapOverlay_fnc_buttonFncContext";
				};
			};
		};

		//---------------------------------------------------------------------------------------------
		//---------- MAP TOP RIGHT: GO-CODE CONTROLS --------------------------------------------------
		//---------------------------------------------------------------------------------------------
		class MAP_Order_GoCode_BG: A3C_RscPicture
		{
			idc = IDC_MAP_Order_GoCode_BG; //709099;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_A_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_Order_GoCode_A_IMG; //709100;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_A_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_Order_GoCode_A_BTN; //709101;
			action = "['A'] call A3C_ui_shared_fnc_activateGoCode";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_B_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_Order_GoCode_B_IMG; //709102;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_B_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_Order_GoCode_B_BTN; //709103;
			action = "['B'] call A3C_ui_shared_fnc_activateGoCode";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_C_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_Order_GoCode_C_IMG; //709104;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_C_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_Order_GoCode_C_BTN; //709105;
			action = "['C'] call A3C_ui_shared_fnc_activateGoCode";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_D_IMG: A3C_RscPicture
		{
			idc = IDC_MAP_Order_GoCode_D_IMG; //709106;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Order_GoCode_D_BTN: A3C_RscButton_Invisible
		{
			idc = IDC_MAP_Order_GoCode_D_BTN; //709107;
			action = "['D'] call A3C_ui_shared_fnc_activateGoCode";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH);
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class MAP_Dir_MousePosToPlayerPos_TXT: A3C_RscText
		{
			idc = IDC_MAP_Dir_MousePosToPlayerPos_TXT; //709108

			x = 0.0245802 * safezoneW + safezoneX;
			y = 0.0159226 * safezoneH + safezoneY;
			w = 0.114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};

		//---------------------------------------------------------------------------------------------
		//---------- MAP RSC COMBO SELECTOR (DYNAMIC) --------------------------------------------------
		//---------------------------------------------------------------------------------------------

		class MAP_DynamicCombo: A3C_RscCombo //-- name is misleading as control is used in multiple places
		{
			idc = IDC_MAP_DynamicCombo; //7078
			onLBSelChanged = EXPAND_AND_QUOTE([ARR_3(A3C_LB_MODE,(_this select 1),IDD_MAP_OVERLAY)] call A3C_ui_shared_fnc_onLbChange);
			x = 0.00166839 * safezoneW + safezoneX;
			y = 14 * safezoneH + safezoneY;
			w = 0.0630074 * safezoneW;
			h = 0.0220035 * safezoneH;
		};						          	
	};
};

