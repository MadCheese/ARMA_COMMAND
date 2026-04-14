




// #define TREE_W ( 0.19477 * safezoneW) //-- listed twice?
#define BAR_X (-10.5 * GUI_GRID_W + GUI_GRID_X)
#define BAR_W (16 * GUI_GRID_W)
#define BAR_H (15.5 * GUI_GRID_H)
#define TREE_W (13 * GUI_GRID_W)
#define TEAMCOL_FRAME_H ((0.03 * safezoneH) + ((safezoneY + safeZoneH) * 0.0141935))// (safezoneY + safeZoneH) * 0.0141935 should be A3C_MAP_GAMEUI_PADDING_Y

class A3C_MENU
{
	idd = 100040;
	movingenable = false;

	//onLoad =   "showHud ([false] + (shownhud select [1,10]))";
	//onUnLoad = "showHud ([true]  + (shownhud select [1,10])); systemchat '0';";
	//onDestroy = "showHud ([true]  + (shownhud select [1,10])); systemchat '1';";
	//onKeyDown = "_bool = [] call A3C_RADIAL_EH_MAIN_KeyDown; _bool";
	//onKeyUp = "if (_this select 1 == 16) then {[1] call A3C_UI_RADIAL_CTRLS_QUICKTOGGLE};";

	class ControlsBackground {
		class A3C_RscPicture_1200: A3C_RscPicture
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




		class A3C_MENU_Top: A3C_RscPicture
		{
			idc = 8001;

			//text = "text = "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Top.paa";
			//text = "";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class A3C_MENU_RIGHT: A3C_RscPicture
		{
			idc = 8002;

			//text = "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Right.paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class A3C_MENU_Bottom: A3C_RscPicture
		{
			idc = 8003;

			//text = "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Bottom.paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};
		class A3C_MENU_LEFT: A3C_RscPicture
		{
			idc = 8004;

			//textColor = "#(argb,8,8,3)color(1,0,0,0.7)";
			//text = "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Left.paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};

//		class A3C_MENU_GroupName: A3C_RscText
//		{
//			idc = 8005;
//			font = "PuristaLight";
//			colorText[] =
//			{
//				1,
//				1,
//				1,
//				0.8
//			};
//			sizeEx = "((( ((safezoneW / safezoneH) min 1.7) / 1.7) / 25) * 1)";
//			x = 17.31 * GUI_GRID_W + GUI_GRID_X;
//			y = 12.1 * GUI_GRID_H + GUI_GRID_Y;
//			w = 5 * GUI_GRID_W;
//			h = 0.7 * GUI_GRID_H;
//		};

		class A3C_RadialMenu_SET: A3C_RscPicture
		{
			idc = -1;

			text = "A3C_CORE\ui\pictures\icon_menu_preferences.paa";
			colorText[] = {1,1,1,0.8};
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
		};


		class A3C_RadialMenu_SET_2 : A3C_RscButton_Invisible
		{
			idc = -1;
			x = (safezoneW + safezoneX) - (0.0354167 * safezoneW);
			y = (safezoneH + safezoneY) - (0.0679966 * safezoneH);
			w = 0.0354167 * safezoneW;
			h = 0.0679966 * safezoneH;
			tooltip = "Access A3C Settings";
			action = "[] spawn A3C_Open_SETTINGS";
		};



		

		


		//--- OUTER RING ACTIONS

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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_2 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_2 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};
			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Fire Only AT Given Targets"; //--- ToDo: Localize;
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_3 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_3 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Units Hold Fire Until You Fire Your Weapon"; //--- ToDo: Localize;
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
		//	onMouseEnter = "['ROE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "['ROE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_4 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_4 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 24.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "Toggle AI Auto-Danger"; //--- ToDo: Localize;
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_5 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_5 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "reset AI looking direction"; //--- ToDo: Localize;
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_7 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_7 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 29.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to cover"; //--- ToDo: Localize;
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_8 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_8 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			tooltip = "send units to rearm"; //--- ToDo: Localize;
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_9 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_9 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;

		};
		class A3C_Bottom_Btn_2: A3C_RscPicture		{
			idc = 10026;


			x = 21 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_Bottom_Btn_2_1: A3C_RscButton_Invisible
		{
			idc = 10027;
			//onKeyDown = "if (A3C_RADIALMODE == 'ITEMS') then {if (_this select 1 == 42) then {['ON'] call A3C_TempNVGLASER_TOGGLE};";
			//onKeyUp = "if (A3C_RADIALMODE == 'ITEMS') then {if (_this select 1 == 42) then {['OFF'] call A3C_TempNVGLASER_TOGGLE};";

		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
			//action = "{_x dowatch objnull; _x lookat objnull;} foreach (groupSelectedUnits player); player groupchat 'STAY ALERT (looking dir)';";
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_11 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_11 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 17 * GUI_GRID_W + GUI_GRID_X;
			y = 20.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			//tooltip = "reset AI looking direction"; //--- ToDo: Localize;
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
			//action = "{_x dowatch objnull; _x lookat objnull;} foreach (groupSelectedUnits player); player groupchat 'STAY ALERT (looking dir)';";
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "[_this,(A3C_OUTER_RING_BTN_fnc_12 select 0)] spawn (A3C_OUTER_RING_BTN_fnc_12 select 1)";
			soundPush[] = {"\a3\Ui_f\data\Sound\ReadOut\ReadoutHideClick2",0.316228,1};

			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 19 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			//tooltip = "reset AI looking direction"; //--- ToDo: Localize;
		};


		/////////////////
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
		//	onMouseEnter = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
		//	onMouseExit = "[A3C_RADIALMODE] call A3C_RADIAL_BTN_FNC_RING_INNER";
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
			//text =  "\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";
			x = 16.71 * GUI_GRID_W + GUI_GRID_X;
			y = 7.45 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {1,1,1,0.6};
		};
		class A3C_MENU_ACTIONS_BTN: A3C_RscButton_Invisible
		{
			//onMouseButtonDown = "['BUILDING',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseEnter = "['ACTIONS'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			//onMouseExit = "['ACTIONS'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ACTIONS',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			idc = 9002;
			x = 15.48 * GUI_GRID_W + GUI_GRID_X;
			y = 7.11 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			//tooltip = "AI Actions"; //--- ToDo: Localize;
		};

		class A3C_MENU_ROE: A3C_RscPicture
		{
			idc = 9003;

			//text = "A3C_CORE\ui\pictures\icon_menu_ROE_main.paa";
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
			//onMouseExit = "['ROE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ROE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";

			x = 20 * GUI_GRID_W + GUI_GRID_X;
			y = 7 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "rules of engagement"; //--- ToDo: Localize;
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
			//onMouseExit = "['BRAIN'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['BRAIN',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";

			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9.98 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI Auto-Functions"; //--- ToDo: Localize;
		};

		class A3C_Stances: A3C_RscPicture
		{
			idc = 9007;
			//text = "A3C_CORE\ui\pictures\icon_menu_stance_stand.paa";
			colorText[] = {1,1,1,0.6};
			x = 24.16 * GUI_GRID_W + GUI_GRID_X;
			y = 13.54 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
		};


		class A3C_Stances_2: A3C_RscButton_Invisible
		{
			idc = 9008;
			//action = "{_x dowatch objnull; _x lookat objnull; _x setUnitPos 'AUTO';} foreach (groupSelectedUnits player);";
			onMouseEnter = "['STANCE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			//onMouseExit = "['STANCE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['STANCE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 3.5 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "AI-Stances (RMB: Toggle Go-Codes)"; //--- ToDo: Localize;
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
			//onMouseExit = "['ITEMS'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['ITEMS',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";

			x = 20.16 * GUI_GRID_W + GUI_GRID_X;
			y = 15.96 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "Weapon Items"; //--- ToDo: Localize;
		};

		class A3C_Vehs: A3C_RscPicture
		{
			idc = 9011;
			//text = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
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
			//onMouseExit = "['VEHICLES'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['VEHICLES',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";

			x = 15.6 * GUI_GRID_W + GUI_GRID_X;
			y = 15.79 * GUI_GRID_H + GUI_GRID_Y;
			w = 4 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			tooltip = "LClick: Toggle Vehicle options || RClick: Dismount Selected Units"; //--- ToDo: Localize;
		};



		class A3C_FormRing: A3C_RscPicture
		{
			idc = 9013;

			//text = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
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
			tooltip = "Formations"; //--- ToDo: Localize;
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
			//onMouseExit = "['GRENADE'] call A3C_RADIAL_BTN_FNC_RING_INNER";
			onMouseButtonDown = "['GRENADE',(_this select 1)] call A3C_RADIAL_BTN_FNC_RING_INNER";
			//onMouseButtonDown = "_this spawn A3C_RadialMenu_GREN;";
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
			tooltip = "left click: reset group. right click: call selected units back to group"; //--- ToDo: Localize;
		};









		//-- RIGHT EXTENSION LISTBOXES

		//class RscCheckbox_80533: A3C_LISTBOX_1
		//{
		//	idc = 80533;
		//	x = 42.09 * GUI_GRID_W + GUI_GRID_X;
		//	y = 9.31 * GUI_GRID_H + GUI_GRID_Y;
		//	w = 18.5 * GUI_GRID_W;
		//	h = 2 * GUI_GRID_H;
		//	//onLBSelChanged = "[A3C_LB_MODE,(_this select 1),100040] call A3C_LB_Change";
		//	text = "#(argb,8,8,3)color(1,1,1,1)";
		//};
		class ExtraFrame: A3C_RscPicture
		{
			idc = 8053;
			//text = "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
			x = 33 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25.5 * GUI_GRID_W;
			h = 20.5 * GUI_GRID_H;
		};


		class RscVehList: A3C_LISTBOX
		{
			idc = 8054;
			style = CT_LISTBOX;
			//onLBSelChanged  = "[] spawn TUT_gui_VehInfo;";
			onLBSelChanged  = "[BV_LB1,(_this select 1),100040] spawn A3C_LB_Change";
		//	colorText[] = {1,1,1,1};
		//	colorDisabled[] = {1,1,1,0.25};
		//	colorScrollbar[] = {1,1,1,1};
		//	colorSelect[] = {1,1,1,1};
		//	colorSelect2[] = {1,1,1,1};
		//	colorSelectBackground[] = {0.8,0.6,0,0.2};
		//	colorSelectBackground2[] = {0.1,0.1,0.1,0.1};
		//	colorBackground[] = {0.1,0.1,0.1,0.7};
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
			//onLBSelChanged  = "[] spawn TUT_gui_VehInfo;";
			onLBSelChanged  = "[BV_LB2,(_this select 1),100040] spawn A3C_LB_Change";
		//	colorText[] = {1,1,1,1};
		//	colorDisabled[] = {1,1,1,0.25};
		//	colorScrollbar[] = {1,1,1,1};
		//	colorSelect[] = {1,1,1,1};
		//	colorSelect2[] = {1,1,1,1};
		//	colorSelectBackground[] = {1,0,0,0.2};
		//	colorSelectBackground2[] = {0.1,0.1,0.1,0.1};
		//	colorBackground[] = {0.1,0.1,0.1,0.7};
		//	shadow = 0.75;
		//	//sizeEx = "(((((safezoneW / safezoneH) min 1.4) / 1.4) / 25) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 1.3) / 1.3) / 25) * 1)";
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4 * GUI_GRID_H;
		};
		class go: A3C_RscButton_Invisible
		{
			idc = 8056;
			//text = "SEND";
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
			text = ""; //--- ToDo: Localize;
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};
		class RscText_1004: A3C_RscText
		{
			idc = 8058;
			style = 0;
			text = ""; //--- ToDo: Localize;
			x = 35 * GUI_GRID_W + GUI_GRID_X;
			y = 12 * GUI_GRID_H + GUI_GRID_Y;
			w = 16 * GUI_GRID_W;
			h = 0.5 * GUI_GRID_H;
		};

//		class Pholder2: A3C_RscPicture
//		{
//			idc = 8069;
//			//text = "A3C_CORE\ui\pictures\BG_Radial_OuterRing_Placeholder.paa";
//			//x = -13.5 * GUI_GRID_W + GUI_GRID_X;
//			//y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
//			//w = 1 * GUI_GRID_W;
//			//h = 1 * GUI_GRID_H;
//			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
//			y = 5 * GUI_GRID_H + GUI_GRID_Y;
//			w = 16 * GUI_GRID_W;
//			h = 15.5 * GUI_GRID_H;
//			text = "#(argb,8,8,3)color(1,1,1,1)";
//		};

		class CommandBar_Revealer: A3C_RscButton_Invisible
		{
			idc = 8070;
			//x = -19 * GUI_GRID_W + GUI_GRID_X;
			//y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			//w = 25.5 * GUI_GRID_W;
			//h = 20.5 * GUI_GRID_H;
			x = -10.5 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = BAR_W;
			h = BAR_H;


			onMouseEnter = "['OPEN'] call A3C_UI_RADIAL_TOGGLE_LEFT_EXT";
			//onMouseExit = "if !(ctrlShown (findDisplay 100040 displayCtrl 8071)) then { playsound 'A3C_MenuSound1'; A3C_RD_BOOL_UNITS = false; {(findDisplay 100040 displayCtrl _x) ctrlShow true} foreach [8071,8096,8097,8098,8099,9000]; (findDisplay 100040 displayCtrl 8095) ctrlShow false; [] call A3C_RD_LABEL_SELECTORS;}";
		};
		class L_ext_commandBar_BG: A3C_RscPicture
		{
			idc = 8096;
			text = "A3C_CORE\ui\pictures\BG_Radial_ExtensionLeft.paa";
			colorText[] = {1,1,1,1};
			//x = -19 * GUI_GRID_W + GUI_GRID_X;
			//y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			//w = 25.5 * GUI_GRID_W;
			//h = 20.5 * GUI_GRID_H;
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
	  		// left: + right: -
	   		// up: - down: +
	  		 idc = 8071;
	  		//x = -19 * GUI_GRID_W + GUI_GRID_X;
			//y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			//w = 30.5 * GUI_GRID_W;
			//h = 25.5 * GUI_GRID_H;
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


				//class JUSTATESTDELETE: A3C_RscPicture
				//{
				//	idc = -1;
				//	text = "#(argb,8,8,3)color(1,1,1,1)";
				//	x = -19 * GUI_GRID_W + GUI_GRID_X;
				//	y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
				//	w = 30.5 * GUI_GRID_W;
				//	h = 25.5 * GUI_GRID_H
				//};

				

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
					tooltip = "Selected units STANDBY"; //--- ToDo: Localize;
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
					tooltip = "Selected units CONTINUE"; //--- ToDo: Localize;
				};


				class A3C_TOP_TEAMCOLOR_BG: A3C_RscPicture
				{
					idc = 7077;

					text = "#(argb,8,8,3)color(0,0,0,0.3)";
					x = 0; //((BAR_W - TREE_W) / 2);
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = BAR_W; //TREE_W;
					h = TEAMCOL_FRAME_H; 
				};
				class A3C_TOP_TEAMCOLOR_FRAME: A3C_RscFrame
				{
					idc = 7079;

					//text = "#(argb,8,8,3)color(0,0,0,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = BAR_W; //TREE_W;
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

					//colorBackground[] = {0,0,0,0.6}; // Fill color
					x = 0; //((BAR_W - TREE_W) / 2);
					y = (2 * GUI_GRID_H + GUI_GRID_Y) + TEAMCOL_FRAME_H;
					w = BAR_W; //TREE_W;
					h = BAR_H - (0.5 * GUI_GRID_H + GUI_GRID_Y) - ((2 * GUI_GRID_H + GUI_GRID_Y) + ( 0.0330053 * safezoneH)); //-- subtract Y of HOLD/CONT button to align to the bottow of BAR
					//onTreeSelChanged = "player commandchat str _this";
					//onTreeLButtonDown = "player commandchat str [_this select 1]; false";
					onTreeLButtonDown = "_this call A3C_TREE_TVCHANGE; false";
					onTreeCollapsed = "[_this,'COLLAPSE',false,0.1] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE;  false";
					onTreeExpanded = "[_this,'OPEN',false,0.1] spawn A3C_MAPTAB_TREE_OPEN_COLLAPSE;  false";
					sizeEx = 0.03 / (getResolution select 5);
					colorBackground[] = {0.2,0.2,0.2,0.3}; // Fill color
					colorBorder[] = {0,0,0,0}; // Frame color
					// Scrollbar configuration
				};

				//-- Teamcolor boxes
				class A3C_RadialMenu_REDBOX: A3C_RscPicture
				{
					idc = 1000; //9017;

					colorText[] = {1,0,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_REDBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1001; //9018;
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
					idc = 1002; //9019;

					colorText[] = {0,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_GREENBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1003; //9020;
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
					idc = 1004; //9021;

					colorText[] = {0,0,1,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_BLUEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1005; //9022;
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
					idc = 1006; //9023;

					colorText[] = {1,1,0,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_YELLOWBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1007; //9024;
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
					idc = 1008; //9025;

					colorText[] = {1,1,1,0.6};
				
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_WHITEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1009; //9026;
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
					idc = 1010; //9027;

					colorText[] = {0.5,0.2,0.6,0.6};
					text = "#(argb,8,8,3)color(1,1,1,0.6)";
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
				};
				class A3C_RadialMenu_PURPLEBOX_2 : A3C_RscButton_Invisible
				{
					idc = 1011; //9028;
					x = 0;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 0;
					h = TEAMCOL_FRAME_H;
					toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "select all units (RMB for HUD mode)";
					onMouseButtonDown = "['Purple',(_this select 1),(_this select 5)] call A3C_RadialMenu_FNC_TEAMCOLOR";
				};



				/*
				class Btn_80691: A3C_UnitButtonColorable
				{
					idc = 8073;

					x = 1.5 * GUI_GRID_W + GUI_GRID_X; //10 * GUI_GRID_W + GUI_GRID_X;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(1 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1251: A3C_UnitButtonColorable
				{
					idc = 8074;

					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 2 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(2 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1252: A3C_UnitButtonColorable
				{
					idc = 8075;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(3 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1253: A3C_UnitButtonColorable
				{
					idc = 8076;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(4 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1254: A3C_UnitButtonColorable
				{
					idc = 8077;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(5 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1255: A3C_UnitButtonColorable
				{
					idc = 8078;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(6 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1256: A3C_UnitButtonColorable
				{
					idc = 8079;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(7 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1257: A3C_UnitButtonColorable
				{
					idc = 8080;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 6.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(8 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1258: A3C_UnitButtonColorable
				{
					idc = 8081;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 8 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(9 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1259: A3C_UnitButtonColorable
				{
					idc = 8082;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 8 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(10 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1260: A3C_UnitButtonColorable
				{
					idc = 8083;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 9.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(11 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1261: A3C_UnitButtonColorable
				{
					idc = 8084;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 9.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(12 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1262: A3C_UnitButtonColorable
				{
					idc = 8085;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 11 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(13 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1263: A3C_UnitButtonColorable
				{
					idc = 8086;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 11 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(14 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1264: A3C_UnitButtonColorable
				{
					idc = 8087;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(15 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1265: A3C_UnitButtonColorable
				{
					idc = 8088;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(16 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1266: A3C_UnitButtonColorable
				{
					idc = 8089;
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 14 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(17 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_1267: A3C_UnitButtonColorable
				{
					idc = 8090;
					x = 8.5 * GUI_GRID_W + GUI_GRID_X;
					y = 14 * GUI_GRID_H + GUI_GRID_Y;
					w = 6 * GUI_GRID_W;
					h = 1.17595 * GUI_GRID_H;
					onMouseButtonDown = "[(18 + (A3C_BUTTONPAGE_TABLET * 18)),_this] call A3C_RD_BTN_UNIT";
					tooltip = "LMB: Select Unit || RMB: Assign FireTeam";
				};
				class RscPicture_Page_Left: A3C_RscPicture
				{
					idc = 8091;
					text = "A3C_CORE\ui\pictures\icon_menu_PagePrev.paa";
					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class RscPicture_Page_Left_1: A3C_RscButton_Invisible
				{
					idc = 8092;

					x = 1.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['prev',18] call A3C_SWITCHPAGE_TABLET";
					tooltip = "Previous Unit Page";
				};
				class RscPicture_Page_Right: A3C_RscPicture
				{
					idc = 8093;
					text = "A3C_CORE\ui\pictures\icon_menu_PageNext.paa";
					x = 13.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class RscPicture_Page_Right_1: A3C_RscButton_Invisible
				{
					idc = 8094;

					x = 13.5 * GUI_GRID_W + GUI_GRID_X;
					y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 1 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					action = "['next',18] call A3C_SWITCHPAGE_TABLET";
					tooltip = "Next Unit Page";
				};
				*/
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

		

		////
		class DASH_PARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 303030;
			x = 33.5 * GUI_GRID_W + GUI_GRID_X;
			//x = 0.716008 * safezoneW + safezoneX;
			y = 0.414993 * safezoneH + safezoneY;
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

