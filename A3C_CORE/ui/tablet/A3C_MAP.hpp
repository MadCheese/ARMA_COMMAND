

#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2.5 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2.5 ))

// w10 x h16

//UI element sizes
#define MAIN_WIDTH_GP 12
#define MAIN_HEIGHT_GP 19

#define A3C_MAPTAB_SUBSEL_BUTTON_H (0.08 * safezoneH)
#define A3C_MAPTAB_SUBSEL_BUTTON_W (A3C_MAPTAB_SUBSEL_BUTTON_H * 0.75)

class A3C_MAPDIALOG
{
	idd  = 6998;
	movingenable = true;
	//onSetfocus = 'systemchat '1' ";
	//onKillfocus = 'systemchat '2' ";
	//onKeyDown = "player sidechat str _this";
	//onMouseButtonDown = "systemchat str (_this select 1)";
	onKeyDown = "[6998,_this] call A3C_MapOverlayDefaultkeys";

	//onload = "systemchat 'load'";
	//onunload = "systemchat 'unload'";

	class ControlsBackground 
	{	
//		class A3C_RscPicture_ControlFrame: A3C_RscPicture
//		{
//			idc = 10;
//
//			text = "A3C_CORE\ui\pictures\BG_Map_Overlay.paa";
//			x = 0.202147 * safezoneW + safezoneX;
//			y = 0.0229637 * safezoneH + safezoneY;
//			w = 0.595707 * safezoneW;
//			h = 0.979157 * safezoneH;
//			colorText[] = {0,0,0,0.7};
//		};
		

		
		
		
		//-- ctrlFrame - requires 
		class A3C_RscPicture_ControlFrame: A3C_RscPicture
		{
			idc = 10;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.21933 * safezoneW + safezoneX;
			y = 100 * safezoneH + safezoneY;
			w = 0.555611 * safezoneW;
			h = (0.231037 * safezoneH) + (2* (0.0330046 * safezoneH));
		};
		
		class A3C_RscPicture_ControlFrame_1: A3C_RscButton_Invisible
		{
			idc = 11;
			onMouseEnter = "[] call A3C_MAP_DelLoopObs; ";
			/////onMouseMoving = "(findDisplay 12 displayCtrl 51) ctrlEnable false;";
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
			/////onMouseMoving = "(findDisplay 12 displayCtrl 51) ctrlEnable true;";
			onMouseMoving = "_this call A3C_TAB_UI_Handlers_OnMouseMoving";
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;
		};

		


		
	};
		


	class Controls 
	{
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
			text = ""; //--- ToDo: Localize;
			style = 0;
			x = 14 * GUI_GRID_W + GUI_GRID_X;
			y = 8.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 18.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			sizeEx = 0.07 / (getResolution select 5);
			font = "PuristaMedium";
		};

		
		class A3C_SELECTOR_TREE: A3C_CT_TREE
		{
			idc = 202020;

			colorBackground[] = {0,0,0,0.6}; // Fill color
			//onMouseEnter = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
			onMouseButtonDown = "_this call A3C_TREE_BOXCLICK;";
			//x = 0.5; 
			//y = 0.5;
			x = 0 * safezoneW + safezoneX;
			y = 100; //0.958963 * safezoneH + safezoneY;
			//w = 0.159375 * safezoneW;
			w = (8 * 0.03 / (getResolution select 5)); //0.14 * safezoneW; // ( 10 * ( pixelGrid * pixelW * 2.5 ))
			h = 0.05 / (getResolution select 5); //0.0509959 * safezoneH;
			//onTreeSelChanged = "player commandchat str _this";
			//onTreeLButtonDown = "player commandchat str [_this select 1]; false";
			onTreeLButtonDown = "_this call A3C_TREE_TVCHANGE; false";
			onTreeCollapsed = "[_this,'COLLAPSE',false,0.1] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE;  false";
			onTreeExpanded = "[_this,'OPEN',false,0.1] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE;  false";
			sizeEx = 0.03 / (getResolution select 5);
			// Scrollbar configuration

		};

		class A3C_TOP_ROW_BG: A3C_RscPicture
		{
			idc = 7071;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = (safezoneH + safezoneY); //0.94007 * 
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TOP_ROW_BG_FRAME: A3C_RscFrame
		{
			idc = 7074;

			//text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.288066 * safezoneW + safezoneX;
			y = safezoneH + safezoneY; //0.94007 * 
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

			//text = "#(argb,8,8,3)color(0,0,0,0.6)";
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

			//text = "#(argb,8,8,3)color(0.5,0,0,1)";
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
			tooltip = "team red. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		class A3C_TAB_GREENBOX: A3C_RscPicture
		{
			idc = 1002;

			//text = "#(argb,8,8,3)color(0,1,0,1)";
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
			tooltip = "select team green. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		class A3C_TAB_BLUEBOX: A3C_RscPicture
		{
			idc = 1004;

			//text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
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
			tooltip = "select team blue. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		class A3C_TAB_YELLOWBOX: A3C_RscPicture
		{
			idc = 1006;

			//text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
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
			tooltip = "select team yellow. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		class A3C_TAB_WHITEBOX: A3C_RscPicture
		{
			idc = 1008;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
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
			tooltip = "select team white. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		
		class A3C_TAB_PURPLEBOX: A3C_RscPicture
		{
			idc = 1010;

			//text = "#(argb,8,8,3)color(0.5,0.2,0.6,0.6)";
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
			tooltip = "select all units. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
		};
		
		
		//////////////
		
		
		class A3C_TIMEOUT_CHECKBOX1: A3C_RscPicture
		{
			idc = 7022;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};

		class A3C_TIMEOUT_CHECKBOX2: A3C_RscButton_Invisible
		{
			idc = 7007;
			onMouseButtonDown = "[[7022,7007],'SQ_CONDITION',1,true] call A3C_TOGGLE_SUBSELECTION";
			onMouseZChanged = "[_this select 1] call A3C_BTN_FNC_COND";

			x = 0.545824 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "WP Condition: NONE (LMB to cycle through options)"; //--- ToDo: Localize;
		};
		//class A3C_TEXT_04: A3C_RscText
		//{
		//	idc = 7008;

		//	text = "^"; //--- ToDo: Localize;
		//	x = 0.563007 * safezoneW + safezoneX;
		//	y = 0.818596 * safezoneH + safezoneY;
		//	w = 0.0114559 * safezoneW;
		//	h = 0.0220035 * safezoneH;
		//};
		class A3C_RC_TimeOut: A3C_CT_EDIT
		{
			idc = 7009;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			colorSelection[] = {1,1,1,1};
			colorDisabled[] = {};
			colorBackground[] = {0,0,0,0.6};
			onSetFocus = "['TIMEOUT','ON'] call A3C_MAP_fnc_CT";
			onKillFocus = "['TIMEOUT','OFF'] call A3C_MAP_fnc_CT";
			tooltip = "Set Timeout";
			text = "05"; //--- ToDo: Localize;
			x = 0.580191 * safezoneW + safezoneX;
			y = safezoneH + safezoneY; //0.818596 * 
			w = 0.0229118 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,1};
			sizeEx = "0.03 / (getResolution select 5)";	
		};
		//class A3C_TEXT_05: A3C_RscText
		//{
		//	idc = 7010;

		//	text = "s )"; //--- ToDo: Localize;
		//	x = 0.603103 * safezoneW + safezoneX;
		//	y = 0.818596 * safezoneH + safezoneY;
		//	w = 0.0171838 * safezoneW;
		//	h = 0.0220035 * safezoneH;
		//};
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
		class A3C_WPD_BTN1: A3C_ShortcutButton //A3C_UnitButtonColorable //A3C_RscButton_Function
		{
			idc = 7018;
			
			action = "['ALL'] spawn A3C_Btn_fnc_Execute";
			text = "COMMIT ALL"; //--- ToDo: Localize;
			
			x = 0.517184 * safezoneW + safezoneX;
			y = 2; //0.94007 * safezoneH + safezoneY;
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
			//action = "(findDisplay 6998) closeDisplay 0; A3C_SELECTED_UNITS = []; {_x setvariable ['A3C_PLOT_TEMP',[],true];} foreach units group player; openMap false; [1] call A3C_Btn_fnc_Cancel";
			
			action = "['SELECTED'] spawn A3C_Btn_fnc_Execute";
			text = "COMMIT"; //--- ToDo: Localize;
			x = 0.316706 * safezoneW + safezoneX;
			y = 2; //0.94007 * safezoneH + safezoneY;
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
			action = "(findDisplay 6998) closeDisplay 0; A3C_SELECTED_UNITS = []; {_x setvariable ['A3C_PLOT_TEMP',[],true];} foreach units group player; openMap false; [1] call A3C_Btn_fnc_Cancel";



			text = "EXIT"; //--- ToDo: Localize;
			x = 0.517184 * safezoneW + safezoneX;
			y = 2; //0.94007 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			font = "TahomaB";
			tooltip = "Exit and close map";
			color[] = {1,1,1,1};	
			colorBackground[] = {1,1,1,1};
			size = "0.04 / (getResolution select 5)";
			sizeEx = "0.04 / (getResolution select 5)";	
		};
		/*
		class A3C_UNIT_1: A3C_UnitButtonColorable
		{
			idc = 7025;
			onMouseButtonDown = "[(1 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_2: A3C_UnitButtonColorable
		{
			idc = 7026;
			onMouseButtonDown = "[(2 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";

			x = 0.310978 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_3: A3C_UnitButtonColorable
		{
			idc = 7027;
			onMouseButtonDown = "[(3 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";

			x = 0.373985 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_4: A3C_UnitButtonColorable
		{
			idc = 7028;
			onMouseButtonDown = "[(4 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.436993 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_5: A3C_UnitButtonColorable
		{
			idc = 7029;
			onMouseButtonDown = "[(5 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
			
			x = 0.5 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_6: A3C_UnitButtonColorable
		{
			idc = 7030;
			onMouseButtonDown = "[(6 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.563007 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_7: A3C_UnitButtonColorable
		{
			idc = 7031;
			onMouseButtonDown = "[(7 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_8: A3C_UnitButtonColorable
		{
			idc = 7032;
			onMouseButtonDown = "[(8 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.689022 * safezoneW + safezoneX;
			y = 0.87406 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_9: A3C_UnitButtonColorable
		{
			idc = 7033;
			onMouseButtonDown = "[(9 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_10: A3C_UnitButtonColorable
		{
			idc = 7034;
			onMouseButtonDown = "[(10 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.310978 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_11: A3C_UnitButtonColorable
		{
			idc = 7035;
			onMouseButtonDown = "[(11 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.373985 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_12: A3C_UnitButtonColorable
		{
			idc = 7036;
			onMouseButtonDown = "[(12 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.436993 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_13: A3C_UnitButtonColorable
		{
			idc = 7037;
			onMouseButtonDown = "[(13 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.5 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_14: A3C_UnitButtonColorable
		{
			idc = 7038;
			onMouseButtonDown = "[(14 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.563007 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_15: A3C_UnitButtonColorable
		{
			idc = 7039;
			onMouseButtonDown = "[(15 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_UNIT_16: A3C_UnitButtonColorable
		{
			idc = 7040;
			onMouseButtonDown = "[(16 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";

			x = 0.689022 * safezoneW + safezoneX;
			y = 0.907065 * safezoneH + safezoneY;
			w = 0.0572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		*/
		
		class A3C_map_undo_IMAGE: A3C_RscPicture
		{
			idc = 7092;

			//text = "A3C_CORE\ui\pictures\icon_menu_undo.paa";
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

			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_STANCE1_2: A3C_RscButton_Invisible
		{
			idc = 7045;
			onMouseButtonDown = "[[7044,7045],'SQ_STANCE_1',1,true] call A3C_TOGGLE_SUBSELECTION;";
			onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_1";

			x = 0.24797 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "stance while en route"; //--- ToDo: Localize;
		};
		class A3C_TAB_STANCE2: A3C_RscPicture
		{
			idc = 7046;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_STANCE2_2: A3C_RscButton_Invisible
		{
			idc = 7047;
			onMouseButtonDown = "[[7046,7047],'SQ_STANCE_2',1,true] call A3C_TOGGLE_SUBSELECTION;";
			onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_2;";

			x = 0.339617 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set stance upon arrival"; //--- ToDo: Localize;
		};
		class A3C_TAB_Speed: A3C_RscPicture
		{
			idc = 7048;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
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
			tooltip = "set travel speed"; //--- ToDo: Localize;
		};
		class A3C_TAB_FORMM: A3C_RscPicture
		{
			idc = 7050;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_TAB_FORMM_2: A3C_RscButton_Invisible
		{
			idc = 7051;
			onMouseButtonDown = "[[7050,7051],'SQ_FORMATION',1,true] call A3C_TOGGLE_SUBSELECTION";
			onMouseZChanged = "[_this select 1] call A3C_BUTTON_FORMMODE";

			x = 0.477088 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "set formation (connected tolooking-direction)"; //--- ToDo: Localize;
		};
		//[0.24797,0.33198,0.41599,0.5,0.58401,0.66802]
		
		class A3C_TAB_CMODE: A3C_RscPicture
		{
			idc = 7062;

			//text = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
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
			tooltip = "WP Combat-Mode: Default/Engage"; //--- ToDo: Localize;
		};
		class A3C_wpFiringMode: A3C_RscPicture
		{
			idc = 7064;

			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_wpFiringMode_2: A3C_RscButton_Invisible
		{
			idc = 7065;
			onMouseButtonDown = "[[7064,7065],'SQ_ACTION',1,true] call A3C_TOGGLE_SUBSELECTION";
			onMouseZChanged = "[(_this select 1),false,true] spawn A3C_BUTTON_wpFiringMode;";

			x = 0.431265 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = ""; //--- ToDo: Localize;
		};
		class spacing_input: A3C_CT_EDIT
		{
			idc = 7066;
			type = 2;
			style = 2;
			font = "TahomaB";
			autocomplete = "false";
			onSetFocus = "['SPACING','ON'] call A3C_MAP_fnc_CT";
			onKillFocus = "['SPACING','OFF'] call A3C_MAP_fnc_CT";
			colorSelection[] = {1,1,1,1};
			colorDisabled[] = {};
			sizeEx = "0.03 / (getResolution select 5)";
			tooltip = "Set Unit-Spacing";	
			x = 0.517184 * safezoneW + safezoneX;
			y = safezoneH + safezoneY; //0.818596 * 
			w = 0.0229118 * safezoneW;
			h = 0.0330053 * safezoneH;
			colorText[] = {1,1,1,1};
		};
		/*
		class A3C_TAB_slash2: A3C_RscText
		{
			idc = 7085;

			text = "|"; //--- ToDo: Localize;
			x = 0.368257 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.00572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_TAB_slash3: A3C_RscText
		{
			idc = 7086;

			text = "|"; //--- ToDo: Localize;
			x = 0.414081 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.00572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_TAB_slash4: A3C_RscText
		{
			idc = 7087;

			text = "|"; //--- ToDo: Localize;
			x = 0.459904 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.00572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_TAB_slash5: A3C_RscText
		{
			idc = 7088;

			text = "|"; //--- ToDo: Localize;
			x = 0.505728 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.00572795 * safezoneW;
			h = 0.0220035 * safezoneH;
		};

		class A3C_HELI_INF: A3C_RscPicture
		{
			idc = 7067;

			text = "A3C_CORE\ui\pictures\icon_Menu_page_aircraft.paa";
			x = 0.259426 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_HELI_INF_1: A3C_RscButton_Invisible
		{
			idc = 7068;
			action = "[] call A3C_SWITCH_COMMAND_PAGE";

			x = 0.259426 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		*/
		class A3C_Cancel_Data: A3C_RscPicture
		{
			idc = 7069;

			//text = "A3C_CORE\ui\pictures\icon_menu_cancel.paa";
			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
		};
		class A3C_Cancel_Data_1: A3C_RscButton_Invisible
		{
			idc = 7070;
			onmousebuttondown = "[A3C_SELECTED_UNITS,(_this select 4),(_this select 5)] spawn A3C_CANCELPLANS";

			x = 0.660383 * safezoneW + safezoneX;
			y = 0.818596 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			tooltip = "LMB: delete session. shift+LMB: delete active orders. ctrl+LMB: skip currentwaypoint"; //--- 	ToDo: 	Localize;
		};
		




		class A3C_Refresh_Data_IMG: A3C_RscPicture
		{
			idc = 7072;

			//text = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
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
			tooltip = "refresh group"; //--- ToDo: Localize;
		};


		class A3C_Leavegroup_IMG: A3C_RscPicture
		{
			idc = 7075;

			//text = "A3C_CORE\ui\pictures\icon_menu_hc_disband.paa";
			x = 0.729118 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); //0.94007 * safezoneH + safezoneY;
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
			tooltip = "disband selected units to reserve"; //--- ToDo: Localize;
		};
		/*
		class A3C_Joingroup: A3C_RscPicture
		{
			idc = 7076XXX;

			text = "A3C_CORE\ui\pictures\icon_menu_hc_rejoin.paa";
			x = 0.729118 * safezoneW + safezoneX;
			y = 0.973076 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_Joingroup_1: A3C_RscButton_Invisible
		{
			idc = 7077XXX;
			action = "[1,A3C_HC_DISBANDED] spawn A3C_BTN_HC";

			x = 0.729118 * safezoneW + safezoneX;
			y = 0.973076 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
			tooltip = "re-join disbanded units"; //--- ToDo: Localize;
		};
		*/
		class A3C_LISTBOX_1500: A3C_RscCombo
		{
			idc = 7078;
			onLBSelChanged = "[A3C_LB_MODE,(_this select 1),6998] call A3C_LB_Change";
			//onSetFocus = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
			//onKillFocus = "(findDisplay 12 displayCtrl 51) ctrlEnable true";

			x = 0.00166839 * safezoneW + safezoneX;
			y = 14 * safezoneH + safezoneY;
			w = 0.0630074 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		
		class A3C_IMG_TOGGLETRACKER_BG: A3C_RscPicture
		{
			idc = 1219;
			//text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.746302 * safezoneW + safezoneX;
			y = 0.94007 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0330053 * safezoneH;
			//colorText[] = {1,1,1,0.6};
		};
		class A3C_IMG_TOGGLETRACKER_IMG: A3C_RscPicture
		{
			idc = 1220;
			//text = "A3C_CORE\ui\pictures\icon_menu_toggleForceTracker.paa"; 
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
			tooltip = "Toggle Force Tracking"; //--- ToDo: Localize;
		};
		/*
		class A3C_pageFront_TAB: A3C_RscPicture
		{
			idc = 70981;

			text = "A3C_CORE\ui\pictures\icon_menu_PageNext.paa";
			x = 0.75203 * safezoneW + safezoneX;
			y = 0.885062 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_pageFront_TAB_1: A3C_RscButton_Invisible
		{
			idc = 7097;
			action = "['next',16] call A3C_SWITCHPAGE_TABLET";
			
		
			x = 0.75203 * safezoneW + safezoneX;
			y = 0.885062 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0220035 * safezoneH;
			tooltip = "next page"; //--- ToDo: Localize;
		};
		class A3C_pageBack_TAB: A3C_RscPicture
		{
			idc = 70982;

			text = "A3C_CORE\ui\pictures\icon_menu_PagePrev.paa";
			x = 0.225058 * safezoneW + safezoneX;
			y = 0.885062 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class A3C_pageBack_TAB_2: A3C_RscButton_Invisible
		{
			idc = 7098;
			action = "['prev',16] call A3C_SWITCHPAGE_TABLET";

			x = 0.225058 * safezoneW + safezoneX;
			y = 0.885062 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0220035 * safezoneH;
			tooltip = "previous page"; //--- ToDo: Localize;
		};
		*/
		
		class Order_GoCode_BG: A3C_RscPicture
		{
			idc = 709099;
			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_A: A3C_RscPicture
		{
			idc = 709100;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_A_1: A3C_RscButton_Invisible
		{
			idc = 709101;
			action = "['A'] call A3C_ACTIVATEGOCODE";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_B: A3C_RscPicture
		{
			idc = 709102;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_B_1: A3C_RscButton_Invisible
		{
			idc = 709103;
			action = "['B'] call A3C_ACTIVATEGOCODE";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.94007 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_C: A3C_RscPicture
		{
			idc = 709104;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.973076 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_C_1: A3C_RscButton_Invisible
		{
			idc = 709105;
			action = "['C'] call A3C_ACTIVATEGOCODE";

			x = 0.689022 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.973076 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_D: A3C_RscPicture
		{
			idc = 709106;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.973076 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0220035 * safezoneH;
		};
		class Order_GoCode_D_1: A3C_RscButton_Invisible
		{
			idc = 709107;
			action = "['D'] call A3C_ACTIVATEGOCODE";

			x = 0.706206 * safezoneW + safezoneX;
			y = safezoneY - (0.0220035 * safezoneH); // 0.973076 * safezoneH + safezoneY;
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

			//text = "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";
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
			tooltip = "Selected units STANDBY"; //--- ToDo: Localize;
		};
		class RscMapCont: A3C_RscPicture
		{
			idc = 8002;

			//text = "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";
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
			tooltip = "Selected units CONTINUE"; //--- ToDo: Localize;
		};
		
		class MAP_BG_SUB_BG_1: A3C_RscPicture
		{
			idc = 1010101;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = A3C_MAPTAB_SUBSEL_BUTTON_W * 10; //0.1223154?? * safezoneW; //WRONG
			h = A3C_MAPTAB_SUBSEL_BUTTON_H;
		};
		
		class MAP_BG_SUB_BG_2: A3C_RscPicture
		{
			idc = 1010102;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = A3C_MAPTAB_SUBSEL_BUTTON_W * 10; //0.1223154?? * safezoneW; //WRONG
			h = A3C_MAPTAB_SUBSEL_BUTTON_H;
		};

		//class A3C_LOGO: A3C_RscPicture
		//{
		//	idc = 1201;
		//	text = "\a3\ui_f\data\GUI\Cfg\LoadingScreens\A3_LoadingLogo_ca.paa";
		//	x = 0.482816 * safezoneW + safezoneX;
		//	y = 0.94007 * safezoneH + safezoneY;
		//	w = 0.0286397 * safezoneW;
		//	h = 0.0550088 * safezoneH;
		//	colorText[] = {1,1,1,0.3};
		//};
		
		
		
		///----- ACTION BUTTONS: SUB-SETTINGS
		class PRNT_ACTION_SUBSET_1: A3C_RscControlsGroup_NoScroll
		{
			idc = 8009;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = A3C_MAPTAB_SUBSEL_BUTTON_W * 10;
			h = A3C_MAPTAB_SUBSEL_BUTTON_H * 2;
			class Controls
			{
				class IMG_SUBSET_1_1: A3C_RscPicture
				{
					idc = 800901;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_2: A3C_RscPicture
				{
					idc = 800902;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 1; // A3C_MAPTAB_SUBSEL_BUTTON_W * safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_3: A3C_RscPicture
				{
					idc = 800903;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 2; // 0.0407715 * safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_4: A3C_RscPicture
				{
					idc = 800904;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 3; // 0.0611573 * safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_5: A3C_RscPicture
				{
					idc = 800905;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 4; // 0.0815435 * safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_6: A3C_RscPicture
				{
					idc = 800906;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 5; // 0.1019294? * safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				
				
				class IMG_SUBSET_1_7: A3C_RscPicture
				{
					idc = 800907;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_8: A3C_RscPicture
				{
					idc = 800908;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_9: A3C_RscPicture
				{
					idc = 800909;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_1_10: A3C_RscPicture
				{
					idc = 800910;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				
				
				
				
				
				class BTN_SUBSET_1_1: A3C_RscButton_Invisible
				{
					idc = 800911;
					x = 0* safezoneW;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_2: A3C_RscButton_Invisible
				{
					idc = 800912;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_3: A3C_RscButton_Invisible
				{
					idc = 800913;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_4: A3C_RscButton_Invisible
				{
					idc = 800914;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_5: A3C_RscButton_Invisible
				{
					idc = 800915;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_6: A3C_RscButton_Invisible
				{
					idc = 800916;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				
				class BTN_SUBSET_1_7: A3C_RscButton_Invisible
				{
					idc = 800917;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_9: A3C_RscButton_Invisible
				{
					idc = 800918;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 7;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_0: A3C_RscButton_Invisible
				{
					idc = 800919;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_1_10: A3C_RscButton_Invisible
				{
					idc = 800920;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
			};
		};
		
		
		
		
		class PRNT_ACTION_SUBSET_2: A3C_RscControlsGroup_NoScroll
		{
			idc = 8010;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = A3C_MAPTAB_SUBSEL_BUTTON_W * 10;
			h = A3C_MAPTAB_SUBSEL_BUTTON_H;
			class Controls
			{
				class IMG_SUBSET_2_1: A3C_RscPicture
				{
					idc = 801001;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_2: A3C_RscPicture
				{
					idc = 801002;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_3: A3C_RscPicture
				{
					idc = 801003;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_4: A3C_RscPicture
				{
					idc = 801004;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_5: A3C_RscPicture
				{
					idc = 801005;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_6: A3C_RscPicture
				{
					idc = 801006;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_7: A3C_RscPicture
				{
					idc = 801007;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_8: A3C_RscPicture
				{
					idc = 801008;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_9: A3C_RscPicture
				{
					idc = 801009;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class IMG_SUBSET_2_10: A3C_RscPicture
				{
					idc = 801010;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_1: A3C_RscButton_Invisible
				{
					idc = 801011;
					x = 0;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_2: A3C_RscButton_Invisible
				{
					idc = 801012;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 1;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_3: A3C_RscButton_Invisible
				{
					idc = 801013;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 2;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_4: A3C_RscButton_Invisible
				{
					idc = 801014;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 3;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_5: A3C_RscButton_Invisible
				{
					idc = 801015;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 4;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_6: A3C_RscButton_Invisible
				{
					idc = 801016;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 5;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_7: A3C_RscButton_Invisible
				{
					idc = 801017;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 6;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_8: A3C_RscButton_Invisible
				{
					idc = 801018;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 7;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_9: A3C_RscButton_Invisible
				{
					idc = 801019;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 8;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
				class BTN_SUBSET_2_10: A3C_RscButton_Invisible
				{
					idc = 801020;
					x = A3C_MAPTAB_SUBSEL_BUTTON_W * 9;
					y = 0;
					w = A3C_MAPTAB_SUBSEL_BUTTON_W;
					h = A3C_MAPTAB_SUBSEL_BUTTON_H;
				};
			};
		};
		
		
		
		
		
		
		
		class A3C_RC_Context: A3C_RscControlsGroup
		{
			// left: + right: -
			// up: - down: + 
			idc = 709109;
			x = 62 * GUI_GRID_W + GUI_GRID_X;
			y = -9.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.5 * GUI_GRID_W;
			h = 20 * GUI_GRID_H;
	
			class Controls
			{
				//class bs1 :  A3C_RscPicture
				//{
				//	idc = -1;
				//	text = "#(argb,8,8,3)color(1,1,1,1)";
				//	x = 0 * GUI_GRID_W + GUI_GRID_X;
				//	y = 0 * GUI_GRID_H + GUI_GRID_Y;
				//	w = 5.5 * GUI_GRID_W;
				//	h = 2.5 * GUI_GRID_H;
				//};
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
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 5.5 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),6998] call A3C_LB_Change; ";
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
					//action = "(findDisplay 6999 displayCtrl 709109) ctrlShow false";
					action = "['DELETE'] call A3C_CONTEXTBUTTON";
				};
			};
		};

		class A3C_RC_Context_HC_WP:  A3C_RscControlsGroup_NoScroll
		{
			// left: + right: -
			// up: - down: + 
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
					////onMouseEnter = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
					////onMouseExit = "A3C_BOOL_DISABLEMAPCTRL = false; (findDisplay 12 displayCtrl 51) ctrlEnable 	true";
				};
			};
			class Controls
			{

				
				////////  -------------    R O W   1: GROUPNAME / CLOSE-X
				
				class GPN_BG: A3C_RscPicture ///
				{
					idc = 709116; // not referred
					text = "#(argb,8,8,3)color(0,0,0,1)";
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};


				class GPN_TEXT: A3C_RscText ///
				{
					idc = 709121;
					style = 0;
					text = "GroupName"; //--- ToDo: Localize;
					x = 0 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class Close_BG: A3C_RscPicture ///
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};
				class Close_X: A3C_RscButton_Invisible ///
				{
					idc = -1;
					text = "X";
					action = "(findDisplay 6998 displayCtrl 709115) ctrlShow false;";
					
					x = 9 * GUI_GRID_W;
					y = 0 * GUI_GRID_H;
					w = 2.00029 * GUI_GRID_W;
					h = 1.50017 * GUI_GRID_H;
				};

				////////  -------------    R O W   2: 'GENERAL'-BAR
	//			class GENERAL_BG: A3C_RscPicture
	//			{
	//				idc = -1;
//
//					text = "#(argb,8,8,3)color(0,0,0,1)";
//					x = 0 * GUI_GRID_W;
//					y = 1.5 * GUI_GRID_H;
//					w = 9 * GUI_GRID_W;
//					h = 1 * GUI_GRID_H;
//				};
//				//SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
//				class GENERAL_TEXT: A3C_RscText
//				{
//					idc = -1;
//					style = 0;
//					
//					text = "GENERAL"; //--- ToDo: Localize;
//					x = 0 * GUI_GRID_W;
//					y = 1.5 * GUI_GRID_H;
//					w = 9 * GUI_GRID_W;
//					h = 1 * GUI_GRID_H;
//				};
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
					text = "BEHAVIOUR"; //--- ToDo: Localize;
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
					onLBSelChanged = "[709139,(_this select 1),6998] call A3C_LB_HC";

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
					text = "COMBAT MODE"; //--- ToDo: Localize;
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
					onLBSelChanged = "[709140,(_this select 1),6998] call A3C_LB_HC";

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
					text = "SPEED"; //--- ToDo: Localize;
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

				class WP_SPEED: A3C_RscCombo_Dot /// 
				{
					idc = 709138;
					
					onLBSelChanged = "[709138,(_this select 1),6998] call A3C_LB_HC";
					x = 0 * GUI_GRID_W;
					y = 6.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT SPEED";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
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
					text = "FORMATION"; //--- ToDo: Localize;
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

				class Form_1: A3C_RscCombo_Dot ///
				{
					idc = 709128;	
					
					onLBSelChanged = "[709128,(_this select 1),6998] call A3C_LB_HC";
					x = 0 * GUI_GRID_W;
					y = 8.5 * GUI_GRID_H;
					w = 9 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
					colorBackground[] = {0.6,0.6,0.6,1};
					colorSelectBackground[] = {0.6,0.6,0.6,1};
					tooltip = "WAYPOINT FORMATION";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};

				

				////////  -------------    R O W   5: 'COMPLETION'-Titlebar
				class A3C_RC_GroupConrPreCtrls:  A3C_RscControlsGroup_NoScroll
				{
					// left: + right: -
					// up: - down: + 
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
							text = "COMPLETION"; //--- ToDo: Localize;
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class WP_COMPL_HEADER_Line: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 4 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 4 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						////////  -------------    R O W   6: 'COND-PRE'-Combo

						class Cond_Type_PRE: A3C_RscCombo_Dot ///
						{
							idc = 709123;
							onLBSelChanged = "[709123,(_this select 1),6998] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H;
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.6,0.6,0.6,1};
							colorSelectBackground[] = {0.6,0.6,0.6,1};
							tooltip = "WAYPOINT COMPLETION: TYPE";
							//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
						};
						////////  -------------   EXTRA: PRE-COND-VAL

						class Cond_MODE_PRE: A3C_RscCombo_Dot ///
						{
							idc = 709124;

							
							onLBSelChanged = "[709124,(_this select 1),6998] call A3C_LB_HC";
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
					// left: + right: -
					// up: - down: + 
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
							text = "TYPE"; //--- ToDo: Localize;
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class WP_Type_HEADER_Line: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 3 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class WP_TYPEACTION: A3C_RscCombo_Dot
						{
							idc = 709141;
							onLBSelChanged = "[709141,(_this select 1),6998] call A3C_LB_HC";

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

				class CONFIRM_BG: A3C_RscPicture ///
				{
					idc = 709131;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class CONFIRM_TEXT: A3C_RscButton_Invisible ///
				{
					idc = 709132;
					action = "[] spawn A3C_HC_RC_CONFIRM";
					text = "CONFIRM"; //--- ToDo: Localize;
					shadow = 0;
					x = 0 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class DELETE_BG: A3C_RscPicture ///
				{
					idc = 709133;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class DELETE_TEXT: A3C_RscButton_Invisible ///
				{
					idc = 709134;
					text = "DELETE";
					shadow = 0;
					action = "[] call A3C_HC_REMOVE_WP_RC; (findDisplay 6998 displayCtrl 709115) ctrlShow false;";
					x = 4.5 * GUI_GRID_W;
					y = 14 * GUI_GRID_H;
					w = 4.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

		

				////////  -------------   BLOCK 2: ACTION SETTINGS

				class A3C_RC_GroupActionCtrls:  A3C_RscControlsGroup_NoScroll
				{
					// left: + right: -
					// up: - down: + 
					idc = 709200;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{
			//			class ACT_SET_BG: A3C_RscPicture
			//			{
			//				idc = 709142;
			//				text = "#(argb,8,8,3)color(0,0,0,1)";
			//				x = 0 * GUI_GRID_W;
			//				y = 0; //21.5 * GUI_GRID_H;
			//				w = 9 * GUI_GRID_W;
			//				h = 0.5 * GUI_GRID_H;
			//			};
			//			class ACT_SET_TEXT: A3C_RscText ///
			//			{
			//				idc = 709130;
			//				style = 0;
			//				text = "ACTION SETTINGS"; //--- ToDo: Localize;
			//				SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
			//				x = 0 * GUI_GRID_W;
			//				y = 0; //21.5 * GUI_GRID_H;
			//				w = 5 * GUI_GRID_W;
			//				h = 0.5 * GUI_GRID_H;
			//			};
			//			class ACT_SET_LINE: A3C_RscLine
			//			{
			//				idc = -1;
			//				//style = 0;
			//				x = 5 * GUI_GRID_W;
			//				y = 0.25 * GUI_GRID_H;
			//				w = 3 * GUI_GRID_W;
			//				h = 0 * GUI_GRID_H;
			//			};
						//--FORM

						class ACT_FORM_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT_FORM_TEXT: A3C_RscText ///
						{
							idc = -1;
							style = 0;
							text = "ACTION FORMATION"; //--- ToDo: Localize;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT_FORM_LINE: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class Form_2: A3C_RscCombo_Dot ///
						{
							idc = 709129;
							
							onLBSelChanged = "[709129,(_this select 1),6998] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H; //22.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION FORMATION";
							//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
						};

						//--COND

						class ACT_COND_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT_COND_TEXT: A3C_RscText ///
						{
							idc = -1;
							style = 0;
							text = "ACTION COMPLETION"; //--- ToDo: Localize;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT_COND_LINE: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 5 * GUI_GRID_W;
							y = 2.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};


						class Cond_Type_Post: A3C_RscCombo_Dot ///
						{
							idc = 709125;

							
							onLBSelChanged = "[709125,(_this select 1),6998] call A3C_LB_HC";
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; //24 * GUI_GRID_H;
							w = 4.5 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.8,0.6,0,1};
							colorSelectBackground[] = {0.8,0.6,0,1};
							tooltip = "ACTION COMPLETION: TYPE";
							//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
						};

						class Cond_Mode_Post: A3C_RscCombo_Dot ///
						{
							idc = 709126;

							
							onLBSelChanged = "[709126,(_this select 1),6998] call A3C_LB_HC";
							
							x = 4.5 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; //24 * GUI_GRID_H;
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
					// left: + right: -
					// up: - down: + 
					idc = 709201;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 14 * GUI_GRID_H;
					w = 14.5 * GUI_GRID_W;
					h = 4 * GUI_GRID_H;

					class Controls
					{

						//-- OPTION 1

						class ACT2_1_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT2_1_TEXT: A3C_RscText ///
						{
							idc = 709144;
							style = 0;
							text = "ACTION FORMATION"; //--- ToDo: Localize;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 0 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 5 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};
						class ACT2_1_LINE: A3C_RscLine
						{
							idc = -1;
							//style = 0;
							x = 5 * GUI_GRID_W;
							y = 0.25 * GUI_GRID_H;
							w = 3 * GUI_GRID_W;
							h = 0 * GUI_GRID_H;
						};

						class ACT2_1_COMBO: A3C_RscCombo_Dot ///aiai
						{
							idc = 709145;
							
							onLBSelChanged = "[709145,(_this select 1),6998] call A3C_LB_HC";
							x = 0 * GUI_GRID_W;
							y = 0.5 * GUI_GRID_H; //22.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};
							//tooltip = "ACTION FORMATION";
							//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
						};

						//--OPTION 2

						class ACT2_2_BG: A3C_RscPicture
						{
							idc = -1;

							text = "#(argb,8,8,3)color(0.2,0.2,0.2,1)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; //21.5 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 0.5 * GUI_GRID_H;
						};

						class ACT2_2_TEXT: A3C_RscText ///
						{
							idc = 709146;
							style = 0;
							text = "ACTION COMPLETION"; //--- ToDo: Localize;
							SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
							x = 0 * GUI_GRID_W;
							y = 2 * GUI_GRID_H; //21.5 * GUI_GRID_H;
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


						class ACT2_2_COMBO: A3C_RscCombo_Dot ///
						{
							idc = 709147;

							
							onLBSelChanged = "[709147,(_this select 1),6998] call A3C_LB_HC";
							
							x = 0 * GUI_GRID_W;
							y = 2.5 * GUI_GRID_H; //24 * GUI_GRID_H;
							w = 9 * GUI_GRID_W;
							h = 1.5 * GUI_GRID_H;
							colorBackground[] = {0.2,0.2,0.2,1};
							colorSelectBackground[] = {0.2,0.2,0.2,1};
							//tooltip = "ACTION COMPLETION: TYPE";
							//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
						};
					};
				};
										
			};
		};
		




		class A3C_HC_GROUP_MENU_CTRLPARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 8007;
			x = 0;
			y = 200;//x = 0.5 - (GRIDX( MAIN_WIDTH_GP ) / 2); //x = 100 * safezoneW + safezoneX;
			//y = (( safezoneY + safezoneH ) * 0.97) - GRIDY( MAIN_HEIGHT_GP); // y = 100 * safezoneH + safezoneY;
			//w = 0.213156 * safezoneW;
			//h = 0.340895 * safezoneH;	
			w = GRIDX( MAIN_WIDTH_GP );
			h = GRIDY( MAIN_HEIGHT_GP);

			//onUnload = "systemchat 'ha'; (findDisplay 12 displayCtrl 51) ctrlEnable true;";
			class Controls
			{
				///0,0,0,0.4
				/// 0.18,0.25,0.38,0.7 becomes 


				////////////
				//class A3C_HC_GROUP_MENU_Box_GroupName: A3C_RscPicture
				//{
				//	idc = -1;
				//	///text = "#(argb,8,8,3)color(0.18,0.25,0.38,0.7)";
				//	text = "#(argb,8,8,3)color(0,0,0,0.7)";
				//	x = GRIDX( 0 ); 
				//	y = GRIDY( 0 );
				//	w = GRIDX( 8 );
				//	h = GRIDY( 2 );
				//};
				//class A3C_HC_GROUP_MENU_Box_Groupname_CT: A3C_CT_Edit
				//{
					
				//	idc = 800713;
				//	type = 2;
				//	style = 0;
				//	//font = "PuristaLight";
				//	sizeEx = 0.040;
				//	autocomplete = "false";
				//	colorSelection[] = {1,1,1,0.3};
				//	colorDisabled[] = {0,0,0,0};
				//	onSetFocus = "['GROUPNAME','ON'] call A3C_MAP_fnc_CT";
				//	onKillFocus = "['GROUPNAME','OFF'] call A3C_MAP_fnc_CT";
				//	onKeyDown = "if (_this select 1 == 28) then {[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm}";
				//	x = GRIDX( 0 ); 
				//	y = GRIDY( 0 );
				//	w = GRIDX( 8 );
				//	h = GRIDY( 2 );
				//};
				
				////////////////////
				
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
				
				
				
				///
				
				
				class A3C_HC_GROUP_MENU_Box_Behaviour: A3C_LISTBOX
				{
					idc = 800701;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800701,(_this select 1),6998] call A3C_Map_HC_groupContext_LB_Switch";
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
					onLBSelChanged = "[800702,(_this select 1),6998] call A3C_Map_HC_groupContext_LB_Switch";
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
					onLBSelChanged = "[800703,(_this select 1),6998] call A3C_Map_HC_groupContext_LB_Switch";
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
					onLBSelChanged = "[800704,(_this select 1),6998] call A3C_Map_HC_groupContext_LB_Switch";
					//colorBackground[] = {0.25,0.25,0.25,0.7};
					colorBackground[] = {0.6,0.6,0.6,0.7};
				};
				//class A3C_HC_GROUP_MENU_BG_Rejoin: A3C_RscPicture
				//{
				//	idc = 800705;
				//	text = "#(argb,8,8,3)color(0,1,1,1)";
					
				//	x = GRIDX( 0 ); 
				//	y = GRIDY( 12 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
				
				//class A3C_HC_GROUP_MENU_Button_Rejoin: A3C_RscButton_Invisible
				//{
				//	idc = 800709;
				//	text = "REJOIN";
				//	sizeEx = 0.03;
				//	action = "[A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_fnc_SecuRejoin_fnc";
				//	x = GRIDX( 0 ); 
				//	y = GRIDY( 12 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
				
				//class A3C_HC_GROUP_MENU_BG_Convoy: A3C_RscPicture
				//{
				//	idc = 800706;
				//	text = "#(argb,8,8,3)color(1,1,0,1)";
				//	x = GRIDX( 4 ); 
				//	y = GRIDY( 12 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
				
				//class A3C_HC_GROUP_MENU_Button_Convoy: A3C_RscButton_Invisible
				//{
				//	idc = 800710;
				//	text = "CONVOY";
				//	sizeEx = 0.03;
				//	action = "[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy";
				//	x = GRIDX( 4 ); 
				//	y = GRIDY( 12 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
				
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
				//class A3C_HC_GROUP_MENU_BG_FocusGroup: A3C_RscPicture
				//{
				//	idc = 800714;
				//	text = "#(argb,8,8,3)color(0,0.3,0.6,0.2)";
				//	x = GRIDX( 4 ); 
				//	y = GRIDY( 13.5 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
				//class A3C_HC_GROUP_MENU_Button_FocusGroup: A3C_RscButton_Invisible
				//{
				//	idc = 800715;
				//	text = "FOCUS GROUP";
				//	//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				//	sizeEx = 0.03;
				//	
				//	action = "[] call A3C_MAP_HC_setFocusGroup";
				//	x = GRIDX( 4 ); 
				//	y = GRIDY( 13.5 );
				//	w = GRIDX( 4 );
				//	h = GRIDY( 1.5 );
				//};
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
					action = "(findDisplay 6998 displayCtrl 8007) ctrlShow false; A3C_SELECTED_HC_GROUPS_SETTINGS = []; (findDisplay 6998 displayCtrl 303030) ctrlShow false;";
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
		
		class A3C_ObjectSelector_Parent: A3C_RscControlsGroup_NoScroll
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
					//text = "TEST"; //--- ToDo: Localize;
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
					onMouseEnter = "ctrlSetFocus (findDisplay 6998 displayCtrl 800803)";
					onLBSelChanged = "[(_this select 1)] call A3C_ObjectSelector_LB_Change";
					
				};
			};
		};
		class DASH_PARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 303030;
			x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			//x = 0.716008 * safezoneW + safezoneX;
			y = 100; //0.414993 * safezoneH + safezoneY;
			w = 0.240009 * safezoneW;
			h = 0.289024 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
			//x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			//y = 10 * GUI_GRID_H + GUI_GRID_Y;
			//w = 15 * GUI_GRID_W;
			//h = 7.99999 * GUI_GRID_H;
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
					text = ""; //--- ToDo: Localize;
					style = 0;
					x = -5.72227e-008 * safezoneW;
					y = -2.21673e-008 * safezoneH;
					w = 0.160006 * safezoneW;
					h = 0.0340028 * safezoneH;
					sizeEx = "0.04 / (getResolution select 5)";
				};
				class DASH_TEXT_GROUPNAME_EDIT: A3C_CT_Edit
				{
					
					idc = 800713; //11001
					type = 2;
					style = 0;
					//font = "PuristaLight";
					sizeEx = "0.04 / (getResolution select 5)";
					autocomplete = "false";

					onSetFocus = "['GROUPNAME','ON'] call A3C_MAP_fnc_CT; ['ON'] call A3C_MAP_fnc_CT_DASHBOARD;";
					onKillFocus = "['GROUPNAME','OFF'] call A3C_MAP_fnc_CT; ['OFF'] call A3C_MAP_fnc_CT_DASHBOARD;";
					onKeyDown = "if (_this select 1 == 28) then {[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm}";
					//x = GRIDX( 0 ); 
					//y = GRIDY( 0 );
					//w = GRIDX( 8 );
					//h = GRIDY( 2 );
					x = 0;
					y = 0;
					w = 0.14 * safezoneW;
					h = 0.0340028 * safezoneH;
					font = "PuristaLight";
					colorBackground[] = {1,1,1,0};
					colorDisabled[] = {0,0,0,0};
					colorSelection[] = {1,1,1,0.2};
					colorText[] = {1,1,1,0}; //-- hidden by default, revealded later
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
					text = "Unit Size:"; //--- ToDo: Localize;
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
					text = "Location:"; //--- ToDo: Localize;
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
					text = "Current Task:"; //--- ToDo: Localize;
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
					text = "Health (Soldiers)"; //--- ToDo: Localize;
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

		//		class DASH_TEXT_AMMO: A3C_RscText
		//		{
		//			idc = 12002;
		//			text = "Ammunition"; //--- ToDo: Localize;
		//			style = 0;
		//			x = -5.72227e-008 * safezoneW;
		//			y = (0.136011 * safezoneH) + (0.5 * (0.021 / (getResolution select 5)));
		//			w = 0.0800031 * safezoneW;
		//			h = 0.021 / (getResolution select 5);
		//			sizeEx = "0.021 / (getResolution select 5)"; //"0.011 * safezoneH"
		//		};

				
		//		class DASH_BAR_AMMUNITION: A3C_RscProgress
		//		{
		//			idc = 12003;
		//			x = (0.00800027 - 0.002) * safezoneW;
		//			y = (0.136011 * safezoneH) + (1.5 * (0.021 / (getResolution select 5)));
		//			w = 0.0800031 * safezoneW;
		//			h = 0.0085007 * safezoneH;
		//		};

				class DASH_TEXT_UNITS: A3C_RscText
				{
					idc = 11012;
					text = "Roster"; //--- ToDo: Localize;
					style = 0;
					x = 0.0960037 * safezoneW;
					y = (0.136011 * safezoneH) - ( 0.021 / (getResolution select 5));
					w = 0.0480019 * safezoneW;
					h = 0.021 / (getResolution select 5); //0.0085007 * safezoneH;
					sizeEx = "0.021 / (getResolution select 5)";
				};
		//		class DASH_TEXTBOX_UNITS_BG: A3C_RscPicture
		//		{
		//			idc = 11013;
		//			text = "#(argb,8,8,3)color(0,0,0,1)";
		//			x = 0.104004 * safezoneW;
		//			y = 0.136011 * safezoneH;
		//			w = 0.136005 * safezoneW;
		//			h = 0.085007 * safezoneH;
		//		};
				class DASH_TEXTBOX_UNITS_STRCT: A3C_RscStructuredText
				{
					idc = 11014;
					x = 0.104004 * safezoneW;
					y = 0.136011 * safezoneH;
					w = 0.136005 * safezoneW;
					h = 0.085007 * safezoneH + (1.5 * (0.021 / (getResolution select 5)));
					//sizeEx = 1.5 * GUI_GRID_H;
					//size = 0.2 * GUI_GRID_H;
				};
			};
		};						          	
	};
};
