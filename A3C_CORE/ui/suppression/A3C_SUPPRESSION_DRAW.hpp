class A3C_SUPPRESSION_DRAW
{
	idd = 7998;
	movingenable = false;
	
	
	
	class ControlsBackground {

	};
	
		
	class Controls 
	{
		class A3C_DRAW_BOX: A3C_RscPicture
		{
			idc = 3;
		
			colorText[] = {0.5,0,0,0.5};
			text = "A3C_CORE\ui\pictures\BG_Suppression_Draw.paa";	
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 0 * GUI_GRID_W;
			h = 0 * GUI_GRID_H;
		};
		
		class A3C_SUP_ALIBI_BOX: A3C_RscControlsGroup 
		{
			onMouseMoving = " _this call A3C_SUP_MouseMoving "; //onMouseHolding??
			onMouseButtonDown = " _this call A3C_SUP_MouseDown ";
			onMouseButtonUp = " _this call A3C_SUP_MouseUp ";
			onKeyDown = "_this call A3C_SUP_KeyDown ";
			//onKeyUp = "_this call A3C_SUP_KeyUp ";
			idc = 2;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH * 0.7; 
			class Controls 
			{
				class A3C_RscPicture_ControlFrame_1: A3C_RscButton_Invisible
				{
					idc = 11;
					//text = "#(argb,8,8,3)color(0,0,0,0.5)";
					x = 0;
					y = 0;
					w = safeZoneW;
					h = safeZoneH;
				};
			};           
		};
		class A3C_SUP_SETTINGS_PARENT: A3C_RscControlsGroup
		{
			idc = 2300;
			x = 0.805788 * safezoneW + safezoneX;
			y = 0.709055 * safezoneH + safezoneY;
			w = 0.190268 * safezoneW;
			h = 0.242064 * safezoneH;
			class Controls
			{
				class PIC_HEADER: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0.18,0.25,0.38,0.7)";
					x = -3.24025e-007 * safezoneW;
					y = 2.29539e-007 * safezoneH;
					w = 0.176678 * safezoneW;
					h = 0.0330088 * safezoneH;
				};
				class PIC_BG: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0,0.3,0.6,0.7)";
					x = -3.24025e-007 * safezoneW;
					y = 0.033009 * safezoneH;
					w = 0.176678 * safezoneW;
					h = 0.165044 * safezoneH;
				};
				
				class A3C_SUP_SETTINGS_BTNPic_TYPE_1: A3C_RscPicture
				{
					idc = 1200;
					text = "";
					x = 0.00679543 * safezoneW;
					y = 0.0660178 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BTNPic_TYPE_2: A3C_RscPicture
				{
					idc = 1201;
					text = "";
					x = 0.00679543 * safezoneW;
					y = 0.0990266 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BTNPic_TYPE_3: A3C_RscPicture
				{
					idc = 1202;
					text = "";
					x = 0.00679543 * safezoneW;
					y = 0.132035 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BTNPic_TYPE_4: A3C_RscPicture
				{
					idc = 1203;
					text = "";
					x = 0.00679543 * safezoneW;
					y = 0.165044 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BTN_TYPE_1: A3C_RscButton_Invisible
				{
					idc = 1600;
					x = 0.00679543 * safezoneW;
					y = 0.0660178 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
					action = "['UNLIMITED',true] call A3C_SUP_SETTINGS;";
				};
				class A3C_SUP_SETTINGS_BTN_TYPE_2: A3C_RscButton_Invisible
				{
					idc = 1601;
					x = 0.00679543 * safezoneW;
					y = 0.0990266 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
					action = "['PERCENTAGE',true] call A3C_SUP_SETTINGS";
				};
				class A3C_SUP_SETTINGS_BTN_TYPE_3: A3C_RscButton_Invisible
				{
					idc = 1602;
					x = 0.00679543 * safezoneW;
					y = 0.132035 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
					action = "['MAGAZINE',true] call A3C_SUP_SETTINGS;";
					
				};
				class A3C_SUP_SETTINGS_BTN_TYPE_4: A3C_RscButton_Invisible
				{
					idc = 1603;
					x = 0.00679543 * safezoneW;
					y = 0.165044 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
					action = "['TIME',true] call A3C_SUP_SETTINGS;";
				};
				class A3C_SUP_SETTINGS_TEXT_TYPE: A3C_RscText
				{
					idc = -1;
					text = "Restriction Type"; //--- ToDo: Localize;
					x = 0.00679506 * safezoneW;
					y = 0.044012 * safezoneH;
					w = 0.0747482 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_HEADER: A3C_RscText
				{
					idc = -1;
					text = "SUPPRESSION-SETTINGS"; //--- ToDo: Localize;
					x = 0.00679501 * safezoneW;
					y = 0.011003 * safezoneH;
					w = 0.108725 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_C_Unlimited: A3C_RscText
				{
					idc = 1001;
					text = "Unlimited"; //--- ToDo: Localize;
					x = 0.027181 * safezoneW;
					y = 0.0726189 * safezoneH;
					w = 0.047567 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_C_Percentage: A3C_RscText
				{
					idc = 1002;
					text = "Used Ammo:"; //--- ToDo: Localize;
					x = 0.027181 * safezoneW;
					y = 0.105627 * safezoneH;
					w = 0.0543623 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_C_Magazines: A3C_RscText
				{
					idc = 1003;
					text = "Used Magazines"; //--- ToDo: Localize;
					x = 0.027181 * safezoneW;
					y = 0.138636 * safezoneH;
					w = 0.0747482 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_C_TIME: A3C_RscText
				{
					idc = 1004;
					text = "Time Elapsed"; //--- ToDo: Localize;
					x = 0.027181 * safezoneW;
					y = 0.171645 * safezoneH;
					w = 0.0611576 * safezoneW;
					h = 0.0110029 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXT_CT_Percentage: A3C_CT_EDIT
				{
					idc = 1401;
					x = 0.108724 * safezoneW;
					y = 0.099027 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0220058 * safezoneH;
					type = 2;
					style = 0;
					font = "PuristaLight";
					autocomplete = "false";
					//onSetFocus = "['SPACING','ON'] call A3C_MAP_fnc_CT";
					//onKillFocus = "['SPACING','OFF'] call A3C_MAP_fnc_CT";
					onKeyDown = "['PERCENTAGE'] call A3C_SUP_SET_NUMSAFE";
					colorSelection[] = {1,1,1,1};
					colorDisabled[] = {};
					colorText[] = {0,0,0,1};
					sizeEx = "((( ((safezoneW / safezoneH) min 1.7) / 1.7) / 25) * 1)";
				};
				class A3C_SUP_SETTINGS_TEXT_CT_Magazines: A3C_CT_EDIT
				{
					idc = 1402;
					x = 0.108724 * safezoneW;
					y = 0.132035 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0220058 * safezoneH;
					type = 2;
					style = 0;
					font = "PuristaLight";
					autocomplete = "false";
					//onSetFocus = "['SPACING','ON'] call A3C_MAP_fnc_CT";
					//onKillFocus = "['SPACING','OFF'] call A3C_MAP_fnc_CT";
					onKeyDown = "['MAGAZINE'] call A3C_SUP_SET_NUMSAFE";
					colorSelection[] = {1,1,1,1};
					colorDisabled[] = {};
					colorText[] = {0,0,0,1};
					sizeEx = "((( ((safezoneW / safezoneH) min 1.7) / 1.7) / 25) * 1)";
				};
				class A3C_SUP_SETTINGS_TEXT_CT_TIME: A3C_CT_EDIT
				{
					idc = 1403;
					x = 0.108724 * safezoneW;
					y = 0.165044 * safezoneH;
					w = 0.0203859 * safezoneW;
					h = 0.0220058 * safezoneH;
					type = 2;
					style = 0;
					font = "PuristaLight";
					autocomplete = "false";
					onKeyDown = "['TIME'] call A3C_SUP_SET_NUMSAFE";
					//onSetFocus = "['SPACING','ON'] call A3C_MAP_fnc_CT";
					//onKillFocus = "['SPACING','OFF'] call A3C_MAP_fnc_CT";
					colorSelection[] = {1,1,1,1};
					colorDisabled[] = {};
					colorText[] = {0,0,0,1};
					sizeEx = "((( ((safezoneW / safezoneH) min 1.7) / 1.7) / 25) * 1)";
				};
				class A3C_SUP_SETTINGS_TEXTsuffix_C_Percentage: A3C_RscText
				{
					idc = -1;
					text = "%"; //--- ToDo: Localize;
					x = 0.135905 * safezoneW;
					y = 0.099027 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXTsuffix_C_Magazines: A3C_RscText
				{
					idc = -1;
					text = "mags"; //--- ToDo: Localize;
					x = 0.135905 * safezoneW;
					y = 0.132035 * safezoneH;
					w = 0.0271812 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				class A3C_SUP_SETTINGS_TEXTsuffix_C_TIME: A3C_RscText
				{
					idc = -1;
					text = "s"; //--- ToDo: Localize;
					x = 0.135905 * safezoneW;
					y = 0.165044 * safezoneH;
					w = 0.0135906 * safezoneW;
					h = 0.0220058 * safezoneH;
				};
				
				class A3C_SUP_SETTINGS_BG_CONFIRM: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(0,1,0,1)";
					x = 1.94415e-007 * safezoneW;
					y = 0.198053 * safezoneH;
					w = 0.0883388 * safezoneW;
					h = 0.0330088 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BG_CANCEL: A3C_RscPicture
				{
					idc = -1;
					text = "#(argb,8,8,3)color(1,0,0,1)";
					x = 0.0883389 * safezoneW;
					y = 0.198053 * safezoneH;
					w = 0.0883388 * safezoneW;
					h = 0.0330088 * safezoneH;
				};
				class A3C_SUP_SETTINGS_BTN_CONFIRM: A3C_RscButton_Invisible
				{
					idc = -1;
					text = "CONFIRM"; //--- ToDo: Localize;
					x = 1.94415e-007 * safezoneW;
					y = 0.198053 * safezoneH;
					w = 0.0883388 * safezoneW;
					h = 0.0330088 * safezoneH;
					action = "A3C_SUP_DRAW_TOGGLE = false; A3C_DRAW_ORDER_RELEASE = true; [0, A3C_SUP_DRAWKEY_ID select 0] call A3C_SUP_KeyUp;";
				};
				class A3C_SUP_SETTINGS_BTN_CANCEL: A3C_RscButton_Invisible
				{
					idc = -1;
					text = "CANCEL"; //--- ToDo: Localize;
					x = 0.0883389 * safezoneW;
					y = 0.198053 * safezoneH;
					w = 0.0883388 * safezoneW;
					h = 0.0330088 * safezoneH;
					action = "[] call A3C_SUP_CloseDisplay";
				};
			};
		};
	
				
	};
};
		
