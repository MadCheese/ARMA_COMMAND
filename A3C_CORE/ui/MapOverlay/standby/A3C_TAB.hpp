#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2.5 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2.5 ))

// w10 x h16

//UI element sizes
#define MAIN_WIDTH_GP 10
#define MAIN_HEIGHT_GP 19



class A3C_SWPDIALOG
{
	idd = 100030;
	movingenable = true;
	onKeyDown = "[100030,_this] call A3C_UI_MAP_HandlerFNC_KeyDown_Overlay";
	class ControlsBackground 
	{		
		class test_map: A3C_RscMapControl
		{
			idc = 7043;
			onMouseMoving = "_this call A3C_GetDiagDeg;";

			//text = "A3C_CORE\ui\pictures\map.paa"; //--- ToDo: Localize;
			x = 0.167779 * safezoneW + safezoneX;
			y = 0.225088 * safezoneH + safezoneY;
			w = 0.681626 * safezoneW;
			h = 0.538827 * safezoneH;
		};
		
		
	};
		
	class Controls 
	{

		class A3C_FRAME_UNITS_BG: A3C_RscPicture
		{
			idc = 11;

			text = "#(argb,8,8,3)color(0,0,0,0.6)";
			x = 0.167779 * safezoneW + safezoneX;
			y = 0.598968 * safezoneH + safezoneY;
			w = 0.681626 * safezoneW;
			h = 0.164947 * safezoneH;
		};
		class A3C_IPADX: A3C_RscPicture
		{
			idc = 10;

			text = "A3C_CORE\ui\pictures\BG_Tablet_Small.paa";
			x = 0.116227 * safezoneW + safezoneX;
			y = 0.0161552 * safezoneH + safezoneY;
			w = 0.784729 * safezoneW;
			h = 0.96769 * safezoneH;
		};
		
		class MAP_BG_SUB_1: A3C_RscPicture
		{
			idc = 1010101;

			text = "#(argb,8,8,3)color(0,0,0,0.7)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = ((0.0203859 * 10) * safezoneW); //0.1223154?? * safezoneW; //WRONG
			h = 0.0330046 * safezoneH;
		};
		class MAP_BG_SUB_2: A3C_RscPicture
		{
			idc = 1010102;

			text = "#(argb,8,8,3)color(0,0,0,0.7)";
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = ((0.0203859 * 10) * safezoneW); //0.1223154?? * safezoneW; //WRONG
			h = 0.0330046 * safezoneH;
		};
		
		///----- ACTION BUTTONS: SUB-SETTINGS
		class A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_1_CTRLPARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 8009;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = ((0.0203859 * 10) * safezoneW); //0.1223154?? * safezoneW; //WRONG
			h = 0.0330046 * safezoneH;
			class Controls
			{
				class IMG_SUBSET_1_1: A3C_RscPicture
				{
					idc = 800901;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_2: A3C_RscPicture
				{
					idc = 800902;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 1) * safezoneW; // 0.0203856 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_3: A3C_RscPicture
				{
					idc = 800903;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 2) * safezoneW; // 0.0407715 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_4: A3C_RscPicture
				{
					idc = 800904;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 3) * safezoneW; // 0.0611573 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_5: A3C_RscPicture
				{
					idc = 800905;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 4) * safezoneW; // 0.0815435 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_6: A3C_RscPicture
				{
					idc = 800906;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 5) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				
				
				class IMG_SUBSET_1_7: A3C_RscPicture
				{
					idc = 800907;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 6) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_8: A3C_RscPicture
				{
					idc = 800908;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 7) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_9: A3C_RscPicture
				{
					idc = 800909;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 8) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_1_10: A3C_RscPicture
				{
					idc = 800910;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 9) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				
				
				
				
				
				class BTN_SUBSET_1_1: A3C_RscButton_Invisible
				{
					idc = 800911;
					x = 0* safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_2: A3C_RscButton_Invisible
				{
					idc = 800912;
					x = (0.0203856 * 1) * safezoneW; // 0.0203859 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_3: A3C_RscButton_Invisible
				{
					idc = 800913;
					x = (0.0203856 * 2) * safezoneW; // 0.0407715 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_4: A3C_RscButton_Invisible
				{
					idc = 800914;
					x = (0.0203856 * 3) * safezoneW; // 0.0611573 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_5: A3C_RscButton_Invisible
				{
					idc = 800915;
					x = (0.0203856 * 4) * safezoneW; // 0.0815435 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_6: A3C_RscButton_Invisible
				{
					idc = 800916;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 5) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				
				class BTN_SUBSET_1_7: A3C_RscButton_Invisible
				{
					idc = 800917;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 6) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_9: A3C_RscButton_Invisible
				{
					idc = 800918;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 7) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_0: A3C_RscButton_Invisible
				{
					idc = 800919;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 8) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_1_10: A3C_RscButton_Invisible
				{
					idc = 800920;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 9) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
			};
		};
		
		
		
		
		class A3C_MAP_OVERLAY_GAMEUI_ACTION_SUBSET_2_CTRLPARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 8010;
			x = 0.289346 * safezoneW + safezoneX;
			y = 100; //0.511002 * safezoneH + safezoneY;
			w = ((0.0203859 * 10) * safezoneW); //0.1223154?? * safezoneW; //WRONG
			h = 0.0330046 * safezoneH;
			class Controls
			{
				class IMG_SUBSET_2_1: A3C_RscPicture
				{
					idc = 801001;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0* safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_2: A3C_RscPicture
				{
					idc = 801002;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 1) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_3: A3C_RscPicture
				{
					idc = 801003;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 2) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_4: A3C_RscPicture
				{
					idc = 801004;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 3) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_5: A3C_RscPicture
				{
					idc = 801005;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 4) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_6: A3C_RscPicture
				{
					idc = 801006;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 5) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_7: A3C_RscPicture
				{
					idc = 801007;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 6) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_8: A3C_RscPicture
				{
					idc = 801008;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 7) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_9: A3C_RscPicture
				{
					idc = 801009;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 8) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class IMG_SUBSET_2_10: A3C_RscPicture
				{
					idc = 801010;
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = (0.0203856 * 9) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_1: A3C_RscButton_Invisible
				{
					idc = 801011;
					x = 0;
					y = 0;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_2: A3C_RscButton_Invisible
				{
					idc = 801012;
					x = (0.0203856 * 1) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_3: A3C_RscButton_Invisible
				{
					idc = 801013;
					x = (0.0203856 * 2) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_4: A3C_RscButton_Invisible
				{
					idc = 801014;
					x = (0.0203856 * 3) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_5: A3C_RscButton_Invisible
				{
					idc = 801015;
					x = (0.0203856 * 4) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_6: A3C_RscButton_Invisible
				{
					idc = 801016;
					x = (0.0203856 * 5) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_7: A3C_RscButton_Invisible
				{
					idc = 801017;
					x = (0.0203856 * 6) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_8: A3C_RscButton_Invisible
				{
					idc = 801018;
					x = (0.0203856 * 7) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_9: A3C_RscButton_Invisible
				{
					idc = 801019;
					x = (0.0203856 * 8) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
				class BTN_SUBSET_2_10: A3C_RscButton_Invisible
				{
					idc = 801020;
					x = (0.0203856 * 9) * safezoneW; // 0.1019294? * safezoneW;
					y = 0 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0330046 * safezoneH;
				};
			};
		};
		
		
		
		//class TFrame1: A3C_RscPicture
		//{
		//	idc = 23001;
		//	text = "#(argb,8,8,3)color(1,1,1,0.9)";
		//	x = 0.190691 * safezoneW + safezoneX;
		//	y = 0.68694 * safezoneH + safezoneY;
		//	w = 0.452508 * safezoneW;
		//	h = 1 * safezoneH;
		//};
		//class TFrame2: A3C_RscPicture
		//{
		//	idc = 23002;
		//	text = "#(argb,8,8,3)color(1,1,0,0.9)";
		//	x = 0.654655 * safezoneW + safezoneX;
		//	y = 0.609965 * safezoneH + safezoneY;
		//	w = 0.189022 * safezoneW;
		//	h = 0.142954 * safezoneH;
		//};
		class MyControls: A3C_RscControlsGroup
		{
			idc = 709109;
		  	x = 0.94678 * safezoneW + safezoneX;
			y = 0.983845 * safezoneH + safezoneY;
			w = 0.0630074 * safezoneW;
			h = 0.0549824 * safezoneH;

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
					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 5.5 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),100030] call A3C_LB_Change; ";
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
					//action = "(findDisplay 100030 displayCtrl 709109) ctrlShow false";
					action = "['DELETE'] call A3C_CONTEXTBUTTON";
				};
			};
		};
		class CtrlsGroupUnitButtons: A3C_RscControlsGroup_NoScroll
		{
			idc = 2301;
			
			x = 0.190691 * safezoneW + safezoneX;
			y = 0.685919 * safezoneH + safezoneY;
			w = 0.22603 * safezoneW; //w = 0.45206 * safezoneW;
			h = 0.2 * safezoneH;
			class Controls
			{
				//class A3C_UB_FAKE: A3C_RscPicture
				//{
				//	idc = 10000000;
				//	onMouseEnter = "ctrlsetfocus (finddisplay 100030 displayctrl 2301); systemchat 'oii'";
				//	text = "#(argb,8,8,3)color(1,1,1,1)"; //--- ToDo: Localize;
				//	x = 0;
				//	y = 0;
				//	w = 0.452508 * safezoneW;
				//	h = safezoneH;
				//};
				class A3C_LISTBOX_1500: A3C_RscCombo
				{
					idc = 7078;
					onLBSelChanged = "[A3C_LB_MODE,(_this select 1),100030] call A3C_LB_Change";

					text = "#(argb,8,8,3)color(1,0,1,1)"; //--- ToDo: Localize;
					x = 100;
					y = 0.994841 * safezoneH + safezoneY;
					w = 0.0630074 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_1: A3C_UnitButtonColorable
				{
					idc = 7025;
					onMouseButtonDown = "[(1 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_2: A3C_UnitButtonColorable
				{
					idc = 7026;
					onMouseButtonDown = "[(2 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";
					onmousemoving = "_this spawn A3C_TAB_DROP";
					//onMouseEnter = "ctrlsetfocus (finddisplay 100030 displayctrl 2301); systemchat 'oi'";	
					x = 0 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_3: A3C_UnitButtonColorable
				{
					idc = 7027;
					onMouseButtonDown = "[(3 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.057279 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_4: A3C_UnitButtonColorable
				{
					idc = 7028;
					onMouseButtonDown = "[(4 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.057279 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_5: A3C_UnitButtonColorable
				{
					idc = 7029;
					onMouseButtonDown = "[(5 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.114559 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_6: A3C_UnitButtonColorable
				{
					idc = 7030;
					onMouseButtonDown = "[(6 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.114559 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_7: A3C_UnitButtonColorable
				{
					idc = 7031;
					onMouseButtonDown = "[(7 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.171838 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_8: A3C_UnitButtonColorable
				{
					idc = 7032;
					onMouseButtonDown = "[(8 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.171838 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_9: A3C_UnitButtonColorable
				{
					idc = 7033;
					onMouseButtonDown = "[(9 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.229118 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_10: A3C_UnitButtonColorable
				{
					idc = 7034;
					onMouseButtonDown = "[(10 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.229118 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_11: A3C_UnitButtonColorable
				{
					idc = 7035;
					onMouseButtonDown = "[(11 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.286397 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_12: A3C_UnitButtonColorable
				{
					idc = 7036;
					onMouseButtonDown = "[(12 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.286397 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_13: A3C_UnitButtonColorable
				{
					idc = 7037;
					onMouseButtonDown = "[(13 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.343677 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_14: A3C_UnitButtonColorable
				{
					idc = 7038;
					onMouseButtonDown = "[(14 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.343677 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_15: A3C_UnitButtonColorable
				{
					idc = 7039;
					onMouseButtonDown = "[(15 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.400956 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_UNIT_16: A3C_UnitButtonColorable
				{
					idc = 7040;
					onMouseButtonDown = "[(16 + (A3C_BUTTONPAGE_TABLET * 16)),_this] call A3C_BTN_SELECT_UNIT;";
					onmousemoving = "_this spawn A3C_TAB_DROP";

					x = 0.400956 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0515515 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
			};
		};
		class CtrlsGroup_UA_Buttons: A3C_RscControlsGroup_NoScroll
		{
			idc = 2302;
			x = 0.654655 * safezoneW + safezoneX;
			y = 0.609965 * safezoneH + safezoneY;
			w = 0.189022 * safezoneW;
			h = 0.142954 * safezoneH;
			//onMouseEnter = "ctrlsetfocus (finddisplay 100030 displayctrl 2302);";
			class Controls
			{
				class A3C_WPD_BTN1: A3C_RscButton_Function
				{
					idc = 7018;
					action = "[] spawn A3C_Btn_fnc_Execute";
					//onMouseEnter = "ctrlsetfocus (finddisplay 100030 displayctrl 2302); systemchat str time;";
					text = "Commit"; //--- ToDo: Localize;
					x = 0 * safezoneW;
					y = 0.076975 * safezoneH;
					w = 0.0458236 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_WPD_BTN2: A3C_RscButton_Function
				{
					idc = 7019;
					action = "[1] call A3C_Btn_fnc_Cancel; A3C_HELI_INF_MODE = 'INF'; A3C_SELECTED_UNITS = [];";

					text = "Exit"; //--- ToDo: Localize;
					x = 0 * safezoneW;
					y = 0.109965 * safezoneH;
					w = 0.0458236 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class RscButton_1602: A3C_RscButton_TEXTONLY
				{
					idc = 7041;
					action = "[] call A3C_UNDO";

					text = "Undo"; //--- ToDo: Localize;
					x = 0.057279 * safezoneW;
					y = 0.032989 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class RscMapHold: A3C_RscPicture
				{
					idc = 8000;

					text = "A3C_CORE\ui\pictures\icon_menu_holdcont_hold.paa";
					x = 0.0801909 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class RscMapHoldBtn: A3C_RscButton_Invisible
				{
					idc = 8001;
					action = "A3C_SELECTED_UNITS call A3C_UNIT_HOLD";
					//onMouseEnter = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
					//onMouseExit = "if ([11] call A3C_InMapControls) then {(findDisplay 12 	displayCtrl 51) ctrlEnable 	true;}";

					x = 0.0801909 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "Selected units STANDBY"; //--- ToDo: Localize;
				};
				class RscMapCont: A3C_RscPicture
				{
					idc = 8002;

					text = "A3C_CORE\ui\pictures\icon_menu_HoldCont_Continue.paa";
					x = 0.103103 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class RscMapContBtn: A3C_RscButton_Invisible
				{
					idc = 8003;
					action = "A3C_SELECTED_UNITS call A3C_UNIT_CONTINUE";
					//onMouseEnter = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
					//onMouseExit = "if ([11] call A3C_InMapControls) then {(findDisplay 12 	displayCtrl 51) ctrlEnable 	true;}";

					x = 0.103103 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "Selected units CONTINUE"; //--- ToDo: Localize;
				};
				class A3C_HELI_INF: A3C_RscPicture
				{
					idc = 7067;

					text = "A3C_CORE\ui\pictures\icon_Menu_page_aircraft.paa";
					x = 0.103103 * safezoneW;
					y = 0.0109962 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_HELI_INF_1: A3C_RscButton_Invisible
				{
					idc = 7068;
					action = "[] call A3C_SWITCH_COMMAND_PAGE";

					x = 0.103103 * safezoneW;
					y = 0.0109962 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_Cancel_Data: A3C_RscPicture
				{
					idc = 7069;

					text = "A3C_CORE\ui\pictures\icon_menu_cancel.paa";
					x = 0.103103 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_Cancel_Data_1: A3C_RscButton_Invisible
				{
					idc = 7070;
					onmousebuttondown = "[A3C_SELECTED_UNITS,(_this select 4),(_this select 5)] spawn A3C_CANCELPLANS";

					x = 0.103103 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "LMB: delete session. shift+LMB: delete active orders. ctrl+LMB: skip currentwaypoint"; //--- ToDo: Localize;
				};
				class A3C_Refresh_Data: A3C_RscPicture
				{
					idc = 7071;

					text = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";
					x = 0.0801909 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_Refresh_Data_1: A3C_RscButton_Invisible
				{
					idc = 7072;
					onmousebuttondown = "[(units group player) - [player]] call A3C_GROUP_RESET;";

					x = 0.0801909 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "refresh group"; //--- ToDo: Localize;
				};
				class A3C_Leavegroup: A3C_RscPicture
				{
					idc = 7074;

					text = "A3C_CORE\ui\pictures\icon_menu_hc_disband.paa";
					x = 0.0572791 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_Leavegroup_1: A3C_RscButton_Invisible
				{
					idc = 7075;
					action = "[0] spawn A3C_BTN_HC";

					x = 0.0572791 * safezoneW;
					y = 0.0659785 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "disband selected units to reserve"; //--- ToDo: Localize;
				};
				class A3C_Joingroup: A3C_RscPicture
				{
					idc = 7076;

					text = "A3C_CORE\ui\pictures\icon_menu_hc_rejoin.paa";
					x = 0.0572791 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_Joingroup_1: A3C_RscButton_Invisible
				{
					idc = 7077;
					action = "[1] spawn A3C_BTN_HC";

					x = 0.0572791 * safezoneW;
					y = 0.109964 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "re-join disbanded units"; //--- ToDo: Localize;
				};
				class A3C_HOME: A3C_RscPicture
				{
					idc = 7073;

					text = "\a3\ui_f\data\GUI\Cfg\LoadingScreens\A3_LoadingLogo_ca.paa";
					x = 0.126015 * safezoneW;
					y = 0.0109962 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "currently no function"; //--- ToDo: Localize;
				};
			};
		};
		class ControlsGroup_WP_SETTINGS: A3C_RscControlsGroup_NoScroll
		{
			idc = 2303;
			x = 0.190691 * safezoneW + safezoneX;
			y = 0.620961 * safezoneH + safezoneY;
			w = 0.229118 * safezoneW;
			h = 0.0549824 * safezoneH;
			class Controls
			{
				class A3C_TIMEOUT_CHECKBOX1: A3C_CheckBoxType
				{
					idc = 7022;

					x = 0.137471 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TIMEOUT_CHECKBOX2: A3C_RscButton_Invisible
				{
					idc = 7007;
					onMouseButtonDown = "[[7022,7007],'SQ_CONDITION',1,true] call A3C_TOGGLE_SUBSELECTION";
					onMouseZChanged = "[_this select 1] call A3C_BTN_FNC_COND";

					x = 0.137471 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "activate/deactivate wp timeout"; //--- ToDo: Localize;
				};
				class A3C_TEXT_04: A3C_RscText
				{
					idc = 7008;

					text = "^"; //--- ToDo: Localize;
					x = 0.154654 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0114559 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class Sleep_Input: A3C_RscText
				{
					idc = 7009;
					type = 2;
					style = 0;
					font = "PuristaLight";
					autocomplete = "false";
					colorSelection[] = {1,1,1,1};
					colorDisabled[] = {};

					text = "05"; //--- ToDo: Localize;
					x = 0.171838 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0229118 * safezoneW;
					h = 0.0219929 * safezoneH;
					colorText[] = {1,1,1,1};
				};
				class A3C_TEXT_05: A3C_RscText
				{
					idc = 7010;

					text = "s )"; //--- ToDo: Localize;
					x = 0.200478 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0114559 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class A3C_TAB_STANCE1: A3C_RscPicture
				{
					idc = 7044;

					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TAB_STANCE1_2: A3C_RscButton_Invisible
				{
					idc = 7045;
					onMouseButtonDown = "[[7044,7045],'SQ_STANCE_1',1,true] call A3C_TOGGLE_SUBSELECTION;";
					onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_1";

					x = -2.66302e-007 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "stance while en route"; //--- ToDo: Localize;
				};
				class A3C_TAB_STANCE2: A3C_RscPicture
				{
					idc = 7046;

					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0.045823 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TAB_STANCE2_2: A3C_RscButton_Invisible
				{
					idc = 7047;
					onMouseButtonDown = "[[7046,7047],'SQ_STANCE_2',1,true] call A3C_TOGGLE_SUBSELECTION;";
					onMouseZChanged = "[_this select 1] call A3C_STANCE_BTN_2;";

					x = 0.0458233 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "set stance upon arrival"; //--- ToDo: Localize;
				};
				class A3C_TAB_Speed: A3C_RscPicture
				{
					idc = 7048;

					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0.0229115 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TAB_Speed_2: A3C_RscButton_Invisible
				{
					idc = 7049;
					onMouseButtonDown = "[] call A3C_SPEED_BTN";
					onMouseZChanged = "[] call A3C_SPEED_BTN";

					x = 0.0229115 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "set travel speed"; //--- ToDo: Localize;
				};
				class A3C_TAB_FORMM: A3C_RscPicture
				{
					idc = 7050;

					text = "#(argb,8,8,3)color(1,1,0,1)";
					x = 0.114559 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TAB_FORMM_2: A3C_RscButton_Invisible
				{
					idc = 7051;
					onMouseButtonDown = "[[7050,7051],'SQ_FORMATION',1,true] call A3C_TOGGLE_SUBSELECTION";
					onMouseZChanged = "[_this select 1] call A3C_BUTTON_FORMMODE";

					x = 0.114559 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "set formation (connected tolooking-direction)"; //--- ToDo: Localize;
				};
				class A3C_TAB_REDBOX: A3C_RscPicture
				{
					idc = 7052;

					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 0 * safezoneW;
					y = 0.043986 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
				};
				class A3C_TAB_REDBOX_2: A3C_RscButton_Invisible
				{
					idc = 7053;
					onMouseButtonDown = "['Red',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
					onMouseEnter = "A3C_TAB_DRAG_TEAM = 'RED'";
					onMouseExit = "A3C_TAB_DRAG_TEAM = 'NONE'";

					x = -2.66302e-007 * safezoneW;
					y = 0.0439861 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
					tooltip = "team red. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
				};
				class A3C_TAB_GREENBOX: A3C_RscPicture
				{
					idc = 7054;

					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 0.034367 * safezoneW;
					y = 0.043986 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
				};
				class A3C_TAB_GREENBOX_2: A3C_RscButton_Invisible
				{
					idc = 7055;
					onMouseButtonDown = "['GREEN',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
					onMouseEnter = "A3C_TAB_DRAG_TEAM = 'GREEN'";
					onMouseExit = "A3C_TAB_DRAG_TEAM = 'NONE'";

					x = 0.0343674 * safezoneW;
					y = 0.0439861 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
					tooltip = "select team green. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
				};
				class A3C_TAB_BLUEBOX: A3C_RscPicture
				{
					idc = 7056;

					text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
					x = 0.068735 * safezoneW;
					y = 0.043986 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
				};
				class A3C_TAB_BLUEBOX_2: A3C_RscButton_Invisible
				{
					idc = 7057;
					onMouseButtonDown = "['Blue',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
					onMouseEnter = "A3C_TAB_DRAG_TEAM = 'BLUE'";
					onMouseExit = "A3C_TAB_DRAG_TEAM = 'NONE'";

					x = 0.0687351 * safezoneW;
					y = 0.0439861 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
					tooltip = "select team blue. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
				};
				class A3C_TAB_YELLOWBOX: A3C_RscPicture
				{
					idc = 7058;
					text = "#(argb,8,8,3)color(0.8,0.6,0,1)";
					x = 0.103103 * safezoneW;
					y = 0.043986 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
				};
				class A3C_TAB_YELLOWBOX_2: A3C_RscButton_Invisible
				{
					idc = 7059;
					onMouseButtonDown = "['YELLOW',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
					onMouseEnter = "A3C_TAB_DRAG_TEAM = 'YELLOW'";
					onMouseExit = "A3C_TAB_DRAG_TEAM = 'NONE'";

					x = 0.103103 * safezoneW;
					y = 0.0439861 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
					tooltip = "select team yellow. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
				};
				class A3C_TAB_WHITEBOX: A3C_RscPicture
				{
					idc = 7060;

					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0.137471 * safezoneW;
					y = 0.043986 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
				};
				class A3C_TAB_WHITEBOX_2: A3C_RscButton_Invisible
				{
					idc = 7061;
					onMouseButtonDown = "['MAIN',(_this select 4)] call A3C_BTN_FNC_TEAMCOLOR";
					onMouseEnter = "A3C_TAB_DRAG_TEAM = 'MAIN'";
					onMouseExit = "A3C_TAB_DRAG_TEAM = 'NONE'";

					x = 0.137471 * safezoneW;
					y = 0.0439861 * safezoneH;
					w = 0.0286397 * safezoneW;
					h = 0.0109965 * safezoneH;
					tooltip = "select team white. LMB to select, Shift+LMB to add"; //--- ToDo: Localize;
				};
				class A3C_TAB_CMODE: A3C_RscPicture
				{
					idc = 7062;

					text = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
					x = 0.068735 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_TAB_CMODE_2: A3C_RscButton_Invisible
				{
					idc = 7063;
					onMouseButtonDown = "[] call A3C_BUTTON_CMODE";
					onMouseZChanged = "[] call A3C_BUTTON_CMODE";

					x = 0.0687351 * safezoneW;
					y = 1.96632e-007 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = "set wp combat mode (use at own risk)"; //--- ToDo: Localize;
				};
				class A3C_wpFiringMode: A3C_RscPicture
				{
					idc = 7064;

					text = "#(argb,8,8,3)color(1,1,1,1)";
					x = 0.091647 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
				};
				class A3C_wpFiringMode_2: A3C_RscButton_Invisible
				{
					idc = 7065;
					onMouseButtonDown = "[[7064,7065],'SQ_ACTION',1,true] call A3C_TOGGLE_SUBSELECTION";
					onMouseZChanged = "[(_this select 1),false,true] spawn A3C_BUTTON_wpFiringMode;";

					x = 0.091647 * safezoneW;
					y = 0 * safezoneH;
					w = 0.0171838 * safezoneW;
					h = 0.0329894 * safezoneH;
					tooltip = ""; //--- ToDo: Localize;
				};
				class A3C_SPACING_TEXT: A3C_RscText
				{
					idc = 7089;

					text = "Spc:"; //--- ToDo: Localize;
					x = 0.171838 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0229118 * safezoneW;
					h = 0.0219929 * safezoneH;
				};
				class Sleep_Input_2: A3C_RscText
				{
					idc = 7066;
					type = 2;
					style = 0;
					font = "PuristaLight";
					autocomplete = "false";
					onSetFocus = "A3C_BOOL_CT_SPACING = true";
					onKillFocus = "A3C_BOOL_CT_SPACING = false";
					colorSelection[] = {1,1,1,1};
					colorDisabled[] = {};

					text = "02"; //--- ToDo: Localize;
					x = 0.200478 * safezoneW;
					y = 0.03299 * safezoneH;
					w = 0.0229118 * safezoneW;
					h = 0.0219929 * safezoneH;
					colorText[] = {1,1,1,1};
				};
			};
		};
		
		class A3C_RscPicture_1201: A3C_RscPicture
		{
			moving = 1;

			idc = 1203;
			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.110499 * safezoneW + safezoneX;
			y = 0.12612 * safezoneH + safezoneY;
			w = 0.790457 * safezoneW;
			h = 0.0989683 * safezoneH;
		};
		class A3C_TEXT_07: A3C_RscText
		{
			idc = 7014;

			x = -0.0384272 * safezoneW + safezoneX;
			y = 0.060141 * safezoneH + safezoneY;
			w = 0.234846 * safezoneW;
			h = 0.0329894 * safezoneH;
		};
		class A3C_TEXT_08: A3C_RscText
		{
			idc = 7015;

			x = -0.0384272 * safezoneW + safezoneX;
			y = 0.0491446 * safezoneH + safezoneY;
			w = 0.183294 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class RText_7042: A3C_RscText
		{
			idc = 7042;

			x = 1 * GUI_GRID_W + GUI_GRID_X;
			y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 7.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		
		class A3C_RscPicture_1200: A3C_RscButton_Invisible
		{
			idc = 7095;
			action = "[] call A3C_TAB_TOGGLE_CONTROLS;";

			x = 0.47136 * safezoneW + safezoneX;
			y = 0.774912 * safezoneH + safezoneY;
			w = 0.0343677 * safezoneW;
			h = 0.0439859 * safezoneH;
			tooltip = "Toggle Controls"; //--- ToDo: Localize;
		};
		class A3C_BTN_TOGGLETRACKER: A3C_RscButton_Invisible
		{
			idc = 7096;
			action = "[] call A3C_TAB_TOGGLE_TRACKER;";

			x = 0.517184 * safezoneW + safezoneX;
			y = 0.774912 * safezoneH + safezoneY;
			w = 0.0343677 * safezoneW;
			h = 0.0439859 * safezoneH;
			tooltip = "Toggle Force Tracking"; //--- ToDo: Localize;
		};
		class A3C_pageFront_TAB: A3C_RscPicture
		{
			idc = 70981;

			text = "A3C_CORE\ui\pictures\icon_menu_PageNext.paa";
			x = 0.626015 * safezoneW + safezoneX;
			y = 0.653951 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class A3C_pageFront_TAB_1: A3C_RscButton_Invisible
		{
			idc = 7097;
			action = "['next',16] call A3C_SWITCHPAGE_TABLET";

			x = 0.626015 * safezoneW + safezoneX;
			y = 0.653951 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0219929 * safezoneH;
			tooltip = "next page"; //--- ToDo: Localize;
		};
		class A3C_pageBack_TAB: A3C_RscPicture
		{
			idc = 70982;

			text = "A3C_CORE\ui\pictures\icon_menu_PagePrev.paa";
			x = 0.585919 * safezoneW + safezoneX;
			y = 0.653951 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class A3C_pageBack_TAB_2: A3C_RscButton_Invisible
		{
			idc = 7098;
			action = "['prev',16] call A3C_SWITCHPAGE_TABLET";

			x = 0.585919 * safezoneW + safezoneX;
			y = 0.653951 * safezoneH + safezoneY;
			w = 0.0171838 * safezoneW;
			h = 0.0219929 * safezoneH;
			tooltip = "previous page"; //--- ToDo: Localize;
		};
		class A3C_RscText_1011: A3C_RscText
		{
			idc = 70983;

			text = "p"; //--- ToDo: Localize;
			x = 0.608831 * safezoneW + safezoneX;
			y = 0.653951 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_A: A3C_RscPicture
		{
			idc = 709100;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";
			x = 0.763486 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_A_1: A3C_RscButton_Invisible
		{
			idc = 709101;
			action = "['A'] call A3C_ACTIVATEGOCODE";

			x = 0.763486 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_B: A3C_RscPicture
		{
			idc = 709102;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";
			x = 0.78067 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_B_1: A3C_RscButton_Invisible
		{
			idc = 709103;
			action = "['B'] call A3C_ACTIVATEGOCODE";

			x = 0.78067 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_C: A3C_RscPicture
		{
			idc = 709104;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";
			x = 0.797853 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_C_1: A3C_RscButton_Invisible
		{
			idc = 709105;
			action = "['C'] call A3C_ACTIVATEGOCODE";

			x = 0.797853 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_D: A3C_RscPicture
		{
			idc = 709106;

			text = "A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";
			x = 0.815037 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class Order_GoCode_D_1: A3C_RscButton_Invisible
		{
			idc = 709107;
			action = "['D'] call A3C_ACTIVATEGOCODE";

			x = 0.815037 * safezoneW + safezoneX;
			y = 0.236085 * safezoneH + safezoneY;
			w = 0.0114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class A3C_DIAGDEG: A3C_RscText_Deg
		{
			idc = 709108;

			x = 0.270882 * safezoneW + safezoneX;
			y = 0.225088 * safezoneH + safezoneY;
			w = 0.114559 * safezoneW;
			h = 0.0219929 * safezoneH;
		};
		class A3C_MAP_OVERLAY_GAMEUI_HC_WP_MENU_CTRLPARENT: A3C_RscControlsGroup
		{
			// left: + right: -
			// up: - down: + 
			idc = 709115;
			x = 100 * GUI_GRID_W + GUI_GRID_X;
			y = 100 * GUI_GRID_H + GUI_GRID_Y;
			w = 11.00718 * GUI_GRID_W;
			h = 25 * GUI_GRID_H;

			
			class ControlsBackGround
			{
				class ALIBI: A3C_RscButton_Invisible
				{
					idc = -1;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 13.5 * GUI_GRID_H;
					////onMouseEnter = "(findDisplay 12 displayCtrl 51) ctrlEnable false";
					////onMouseExit = "A3C_BOOL_DISABLEMAPCTRL = false; (findDisplay 12 displayCtrl 51) ctrlEnable 	true";
				};
			};
			class Controls
			{

				class A3C_RscPicture_1201: A3C_RscPicture
				{
					idc = 709116;
					text = "#(argb,8,8,3)color(0.18,0.25,0.38,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};
				class A3C_RscPicture_1202: A3C_RscPicture
				{
					idc = 709117;
					text = "#(argb,8,8,3)color(0.2,0.3,0.38,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};
				class A3C_RscPicture_1203: A3C_RscPicture
				{
					idc = 709118;
					text = "#(argb,8,8,3)color(0.34,0.45,0.54,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 3 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 7.5 * GUI_GRID_H;
				};
				class A3C_RscPicture_1204: A3C_RscPicture
				{
					idc = 709119;
					text = "#(argb,8,8,3)color(0.2,0.3,0.38,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};

				class A3C_RscText_1000: A3C_RscText
				{
					idc = 709120;
					text = "WP-TYPE"; //--- ToDo: Localize;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};
				class A3C_RscText_1000_1: A3C_RscButton_Invisible
				{
					idc = 709136;
					action = "[0] call A3C_Map_HC_waypointContext_OpenMenu_LB";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};

				class A3C_RscText_1001: A3C_RscText
				{
					idc = 709121;
					text = "GroupName"; //--- ToDo: Localize;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class A3C_RscText_1002: A3C_RscText
				{
					idc = 709122;
					text = "Move-Timing"; //--- ToDo: Localize;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 3 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class Cond_Type_PRE: A3C_RscCombo
				{
					idc = 709123;
					colorBackground[] = {0.2,0.3,0.38,1};
					
					onLBSelChanged = "[709123,(_this select 1),100020] call A3C_LB_HC";
					x = 0.5 * GUI_GRID_W + GUI_GRID_X;
					y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};

				class Cond_MODE_PRE: A3C_RscCombo
				{
					idc = 709124;
					colorBackground[] = {0.2,0.3,0.38,1};
					
					onLBSelChanged = "[709124,(_this select 1),100020] call A3C_LB_HC";
					x = 0.5 * GUI_GRID_W + GUI_GRID_X;
					y = 6 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				class Cond_Type_Post: A3C_RscCombo
				{
					idc = 709125;
					colorBackground[] = {0.8,0.6,0,1};
					
					onLBSelChanged = "[709125,(_this select 1),100020] call A3C_LB_HC";
					x = 5 * GUI_GRID_W + GUI_GRID_X;
					y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};

				class Cond_Mode_Post: A3C_RscCombo
				{
					idc = 709126;
					colorBackground[] = {0.8,0.6,0,1};
					
					onLBSelChanged = "[709126,(_this select 1),100020] call A3C_LB_HC";
					x = 5 * GUI_GRID_W + GUI_GRID_X;
					y = 6 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
				};
				
				class wpSpD: A3C_RscCombo
				{
					idc = 709138;
					colorBackground[] = {0.2,0.3,0.38,1};
					
					onLBSelChanged = "[709138,(_this select 1),100020] call A3C_LB_HC";
					x = 0.5 * GUI_GRID_W + GUI_GRID_X;
					y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 8.5 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};

				//class A3C_RscText_1006: A3C_RscText
				//{
				//	idc = 709127;
				//	text = "Formations"; //--- ToDo: Localize;
				//	x = 0 * GUI_GRID_W + GUI_GRID_X;
				//	y = 7.5 * GUI_GRID_H + GUI_GRID_Y;
				//	w = 9.50718 * GUI_GRID_W;
				//	h = 1.5 * GUI_GRID_H;
				//};
				class Form_1: A3C_RscCombo
				{
					idc = 709128;
					colorBackground[] = {0.2,0.3,0.38,1};
					
					
					onLBSelChanged = "[709128,(_this select 1),100020] call A3C_LB_HC";
					x = 0.5 * GUI_GRID_W + GUI_GRID_X;
					y = 9 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};
				class Form_2: A3C_RscCombo
				{
					idc = 709129;
					colorBackground[] = {0.8,0.6,0,1};
					
					onLBSelChanged = "[709129,(_this select 1),100020] call A3C_LB_HC";
					x = 5 * GUI_GRID_W + GUI_GRID_X;
					y = 9 * GUI_GRID_H + GUI_GRID_Y;
					w = 4 * GUI_GRID_W;
					h = 1 * GUI_GRID_H;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.81)";
				};
				
				class A3C_RscText_1004: A3C_RscText
				{
					idc = 709130;
					text = "NO ACTION"; //--- ToDo: Localize;
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
				};

				class A3C_RscText_1004_1: A3C_RscButton_Invisible
				{
					idc = 709137;

					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 10.5 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 1.49975 * GUI_GRID_H;
					action = "[1] call A3C_Map_HC_waypointContext_OpenMenu_LB";
				};

				class A3C_RscPicture_1200: A3C_RscPicture
				{
					idc = 709131;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H + GUI_GRID_Y;
					w = 4.85 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class A3C_RscPicture_1200_1: A3C_RscButton_Invisible
				{
					idc = 709132;
					text = "CONFIRM";
					action = "[] spawn A3C_Map_HC_waypointContext_ButtonFnc_Confirm";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H + GUI_GRID_Y;
					w = 4.85 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};

				class A3C_RscPicture_1205: A3C_RscPicture
				{
					idc = 709133;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 4.9 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H + GUI_GRID_Y;
					w = 4.6 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class A3C_RscPicture_1205_1: A3C_RscButton_Invisible
				{
					idc = 709134;
					text = "Delete";
					action = "[] call A3C_HC_REMOVE_WP_RC; (findDisplay 100020 displayCtrl 709115) ctrlShow false;"
					x = 4.9 * GUI_GRID_W + GUI_GRID_X;
					y = 12 * GUI_GRID_H + GUI_GRID_Y;
					w = 4.6 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class LB_MENU: A3C_LISTBOX
				{
					idc = 709135;
					rowHeight = 0.05;
					style = 2;
					//style = CT_LISTBOX;
					colorBackground[] = {0.18,0.25,0.38,1};
					colorSelectBackground[] = {0.18,0.25,0.38,1};
					
					onLBSelChanged = "[709135,(_this select 1),100020] call A3C_LB_HC";
					x = 0 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 9.50718 * GUI_GRID_W;
					h = 9 * GUI_GRID_H;
				};

				class A3C_RscPicture_Close: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.5,0,0,1)";
					x = 9.50718 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 1.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};
				class A3C_RscPicture_Close_Btn: A3C_RscButton_Invisible
				{
					idc = -1;
					text = "X";
					action = "(findDisplay 100030 displayCtrl 709115) ctrlShow false;"
					
					x = 9.50718 * GUI_GRID_W + GUI_GRID_X;
					y = 0 * GUI_GRID_H + GUI_GRID_Y;
					w = 1.5 * GUI_GRID_W;
					h = 1.5 * GUI_GRID_H;
				};						
			};
		};


		class A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT: A3C_RscControlsGroup_NoScroll
		{
			idc = 8007;
			x = 0;
			y = 200;//x = 0.5 - (GRIDX( MAIN_WIDTH_GP ) / 2); //x = 100 * safezoneW + safezoneX;
			//y = (( safezoneY + safezoneH ) * 0.97) - GRIDY( MAIN_HEIGHT_GP); // y = 100 * safezoneH + safezoneY;
			//w = 0.213156 * safezoneW;
			//h = 0.340895 * safezoneH;	
			w = GRIDX( MAIN_WIDTH_GP );
			h = GRIDY( MAIN_HEIGHT_GP);
			class Controls
			{
				
				////////////
				class A3C_HC_GROUP_MENU_Box_GroupName: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.18,0.25,0.38,0.7)";
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Box_Groupname_CT: A3C_CT_Edit
				{
					
					idc = 800713;
					type = 2;
					style = 0;
					//font = "PuristaLight";
					autocomplete = "false";
					colorSelection[] = {1,1,1,0.3};
					colorDisabled[] = {0,0,0,0};
					onSetFocus = "['GROUPNAME','ON'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
					onKillFocus = "['GROUPNAME','OFF'] call A3C_UI_MAP_FNC_CTEDIT_ACTIVATE";
					onKeyDown = "if (_this select 1 == 28) then {[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm}";
					x = GRIDX( 0 ); 
					y = GRIDY( 0 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				////////////////////
				
				class A3C_HC_GROUP_MENU_BG_STANCES: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.18,0.25,0.38,0.7)";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 8 );
					h = GRIDY( 2 );
				};
				
				
				class A3C_HC_GROUP_MENU_STANCES_AUTO_IMG: A3C_RscPicture
				{
					idc = 800724;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_AUTO_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['AUTO'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to AUTO";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_STAND_IMG: A3C_RscPicture
				{
					idc = 800725;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 2 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_STAND_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['UP'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to STAND";
					x = GRIDX( 2 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_CROUCH_IMG: A3C_RscPicture
				{
					idc = 800726;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 4 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_CROUCH_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['MIDDLE'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to CROUCH";
					x = GRIDX( 4 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_PRONE_IMG: A3C_RscPicture
				{
					idc = 800727;
					text = "A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";
					colorText[] = {1,1,1,0.1};
					x = GRIDX( 6 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_STANCES_PRONE_BTN: A3C_RscButton_Invisible
				{
					idc = -1;
					action = "['DOWN'] call A3C_GP_Btns_Stances";
					tooltip = "set group stance to PRONE";
					x = GRIDX( 6 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				
				
				
				///
				
				
				class A3C_HC_GROUP_MENU_Box_Behaviour: A3C_LISTBOX
				{
					idc = 800701;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY( 4 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800701,(_this select 1),100030] call A3C_Map_HC_groupContext_LB_Switch";
					colorBackground[] = 
					{
						0.18,
						0.25,
						0.38,
						0.7
					};
				};
				
				
				class A3C_HC_GROUP_MENU_Box_CombatMode: A3C_LISTBOX
				{
					idc = 800702;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY( 4 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800702,(_this select 1),100030] call A3C_Map_HC_groupContext_LB_Switch";
					colorBackground[] = 
					{
						0.34,
						0.45,
						0.54,
						0.7
					};
				};

				class A3C_HC_GROUP_MENU_Box_Formation: A3C_LISTBOX
				{
					idc = 800703;
					style = CT_LISTBOX;
					x = GRIDX( 0 ); 
					y = GRIDY( 8 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800703,(_this select 1),100030] call A3C_Map_HC_groupContext_LB_Switch";
					colorBackground[] = 
					{
						0,
						0,
						0,
						0.7
					};
				};
				class A3C_HC_GROUP_MENU_Box_Color: A3C_LISTBOX
				{
					idc = 800704;
					style = CT_LISTBOX;
					x = GRIDX( 4 ); 
					y = GRIDY( 8 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					sizeEx = 0.03;
					onLBSelChanged = "[800704,(_this select 1),100030] call A3C_Map_HC_groupContext_LB_Switch";
					colorBackground[] = 
					{
						0.25,
						0.25,
						0.25,
						0.7
					};
				};
				class A3C_HC_GROUP_MENU_BG_Rejoin: A3C_RscPicture
				{
					idc = 800705;
					text = "#(argb,8,8,3)color(0,1,1,1)";
					
					x = GRIDX( 0 ); 
					y = GRIDY( 12 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				
				class A3C_HC_GROUP_MENU_Button_Rejoin: A3C_RscButton_Invisible
				{
					idc = 800709;
					text = "REJOIN";
					sizeEx = 0.03;
					action = "[A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_fnc_SecuRejoin_fnc";
					x = GRIDX( 0 ); 
					y = GRIDY( 12 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				
				class A3C_HC_GROUP_MENU_BG_Convoy: A3C_RscPicture
				{
					idc = 800706;
					text = "#(argb,8,8,3)color(1,1,0,1)";
					x = GRIDX( 4 ); 
					y = GRIDY( 12 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				
				class A3C_HC_GROUP_MENU_Button_Convoy: A3C_RscButton_Invisible
				{
					idc = 800710;
					text = "CONVOY";
					sizeEx = 0.03;
					action = "[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy";
					x = GRIDX( 4 ); 
					y = GRIDY( 12 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				
				class A3C_HC_GROUP_MENU_BG_Confirm: A3C_RscPicture
				{
					idc = 800707;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = GRIDX( 0 ); 
					y = GRIDY( 13.5 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				
				
				
				class A3C_HC_GROUP_MENU_Button_Confirm: A3C_RscButton_Invisible
				{
					idc = 800711;
					text = "CONFIRM";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
					sizeEx = 0.03;
					action = "[] call A3C_Map_HC_groupContext_ButtonFnc_Confirm";
					x = GRIDX( 0 ); 
					y = GRIDY( 13.5 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );	
				};
				class A3C_HC_GROUP_MENU_BG_FocusGroup: A3C_RscPicture
				{
					idc = 800714;
					text = "#(argb,8,8,3)color(0,0.3,0.6,0.2)";
					x = GRIDX( 4 ); 
					y = GRIDY( 13.5 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
				};
				class A3C_HC_GROUP_MENU_Button_FocusGroup: A3C_RscButton_Invisible
				{
					idc = 800715;
					text = "FOCUS GROUP";
					//sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
					sizeEx = 0.03;
					action = "[] call A3C_MAP_HC_setFocusGroup";
					x = GRIDX( 4 ); 
					y = GRIDY( 13.5 );
					w = GRIDX( 4 );
					h = GRIDY( 1.5 );
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
					action = "(findDisplay 100030 displayCtrl 8007) ctrlShow false; A3C_SELECTED_HC_GROUPS_SETTINGS = []";
					x = GRIDX( 8 ); 
					y = GRIDY( 0 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				
				class A3C_HC_GROUP_MENU_BG_UNASSEMBLEWEAPON: A3C_RscPicture
				{
					idc = 800716;
					text = "";
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Button_UNASSEMBLEWEAPON: A3C_RscButton_Invisible
				{
					idc = 800717;
					x = GRIDX( 8 ); 
					y = GRIDY( 2 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					action = "[0] spawn A3C_HC_UnassembleWeapon";
					tooltip = "Pack Static Weapon";
				};
				class A3C_HC_GROUP_MENU_BG_FIREARTY: A3C_RscPicture
				{
					idc = 800718;
					text = "";
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_BUTTON_FIREARTY: A3C_RscButton_Invisible
				{
					idc = 800719;
					x = GRIDX( 8 ); 
					y = GRIDY( 4 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					onMouseButtonUp = "[A3C_HC_GroupMenu_ArtySupMode] spawn A3C_HC_GroupMenu_ArtySuppression_FNC";
					tooltip = "Fire Artillery";
				};
				class A3C_HC_GROUP_MENU_BG_PARA: A3C_RscPicture
				{
					idc = 800720;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Button_PARA: A3C_RscButton_Invisible
				{
					idc = 800721;
					x = GRIDX( 8 ); 
					y = GRIDY( 6 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					action = "[objNull] call A3C_GP_Btn_Para";
				};
				class A3C_HC_GROUP_MENU_BG_VEHBOARD: A3C_RscPicture
				{
					idc = 800722;
					text = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Button_VEHBOARD: A3C_RscButton_Invisible
				{
					idc = 800723;
					x = GRIDX( 8 ); 
					y = GRIDY( 8 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					toolTip = "Assign and Unassign vehicles. LMB to assign, RMB to unassign.CTRL+RMB to unload other groups";
					onMouseButtonDown = "[_this select 1,_this select 5] spawn A3C_HC_VEHICLEBOARD";
				};
				
				class A3C_HC_GROUP_MENU_BG_UNSTUCK: A3C_RscPicture
				{
					idc = 800728;
					text = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
				};
				class A3C_HC_GROUP_MENU_Button_UNSTUCK: A3C_RscButton_Invisible
				{
					idc = 800729;
					x = GRIDX( 8 ); 
					y = GRIDY( 10 );
					w = GRIDX( 2 );
					h = GRIDY( 2 );
					toolTip = "Unstuck/Unflip units and vehicles";
					onMouseButtonDown = "[] call A3C_HC_UNSTUCK";
				};	
			};
		};
		class A3C_HC_ObjectSelector_Parent: A3C_RscControlsGroup_NoScroll
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
					x = 1.8033e-007 * safezoneW;
					y = -1.80325e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HC_ObjectSelector_Description_Text: A3C_RscText
				{
					idc = 800802;
					text = "TEST"; //--- ToDo: Localize;
					x = 2.45904e-007 * safezoneW;
					y = -3.77043e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HC_ObjectSelector_ListBox: A3C_LISTBOX
				{
					idc = 800803;
					style = CT_LISTBOX;
					x = 2.45904e-007 * safezoneW;
					y = 0.0440052 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0990114 * safezoneH;
					onLBSelChanged = "[(_this select 1)] call A3C_ObjectSelector_LB_Change";
				};
			};
		};
																          	
	};
};

