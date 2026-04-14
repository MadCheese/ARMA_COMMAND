class HUD_Formation_Menu
{
	idd = 100080;
	movingenable = false;
	class ControlsBackground {
		class A3C_HUD_FORM_BG : A3C_RscPicture
		{
			idc = 100;
			text = "#(argb,8,8,3)color(0,0,0,0.5)";
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;
		};
		class A3C_HUD_FORM_BG1 : A3C_RscButton_Invisible
		{
			idc = 9;
			text = "";
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;
		};
	};
	
		
	class Controls 
	{
		class RscButton_1600: A3C_UnitButtonColorable
		{
			idc = 10;
			text = "TEAM RED"; //--- ToDo: Localize;
			colorText[] = {1,1,1,1};
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.378981 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['RED'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			
		};
		class RscButton_1601: A3C_UnitButtonColorable
		{
			idc = 11;
			text = "TEAM GREEN"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.433989 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['GREEN'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
		};
		class RscButton_1602: A3C_UnitButtonColorable
		{
			idc = 12;
			text = "TEAM BLUE"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.488998 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['BLUE'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
		};
		class RscButton_1603: A3C_UnitButtonColorable
		{
			idc = 13;
			text = "TEAM YELLOW"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.544007 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['YELLOW'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
		};
		class RscButton_1604: A3C_UnitButtonColorable
		{
			idc = 14;
			text = "TEAM MAIN"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.599016 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['MAIN'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
		};


		class RscButton_1605: A3C_UnitButtonColorable
		{
			idc = 15;
			text = "ALL UNITS"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.654025 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "['ALL'] call A3C_C_FORM_SelectTeam;";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
		};


		class RscAC1: A3C_RscPicture
		{
			idc = 16;
			text = "A3C_CORE\ui\pictures\BG_CFM_Oval.paa"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.235958 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.121019 * safezoneH;
		};
		class RscAA3C: A3C_UnitButtonColorable
		{
			idc = 17;
			text = ""; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.235958 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.121019 * safezoneH;
			action = "[0] spawn A3C_C_FORM_ActivateForm";
			size = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 0.6) / 0.3) / 53) * 1)";
			//colorText[] = {1,1,1,1};
		};

		class RscButton_1607: A3C_RscButton
		{
			idc = -1;
			text = "CLEAR DATA"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.180949 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			action = "[] call A3C_C_FORM_Button_ClearForm";
			
		};
		class RscButton_1608: A3C_RscButton
		{
			idc = -1;
			text = "SAVE"; //--- ToDo: Localize;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.709033 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.044007 * safezoneH;
			onMouseButtonDown = "[_this select 1] call A3C_C_FORM_SaveButton";
		};
		class RscButton_1609: A3C_LISTBOX
		{
			idc = 18;
			//text = "SAVED"; //--- ToDo: Localize;
			style = CT_LISTBOX;
			x = 0.883773 * safezoneW + safezoneX;
			y = 0.764042 * safezoneH + safezoneY;
			w = 0.0973751 * safezoneW;
			h = 0.176028 * safezoneH;
			onLBSelChanged = "[(_this select 1)] call A3C_C_FORM_LB_Change";
		};
				
	};
};

class HUD_Formation_Menu_Save
{
	idd = 100090;
	movingenable = false;
	class ControlsBackground {

	};
	
		
	class Controls 
	{
		class RscButton_1607: A3C_CT_EDIT
		{
			idc = 10;
			text = "TEXT"; //--- ToDo: Localize;
			x = 0.282338 * safezoneW + safezoneX;
			y = 0.389982 * safezoneH + safezoneY;
			w = 0.349405 * safezoneW;
			h = 0.0550088 * safezoneH;
		};
		class RscButton_1600: A3C_RscButton
		{
			idc = 11;
			text = "SAVE"; //--- ToDo: Localize;
			x = 0.637471 * safezoneW + safezoneX;
			y = 0.389982 * safezoneH + safezoneY;
			w = 0.0400956 * safezoneW;
			h = 0.0550088 * safezoneH;
		};
		class RscButton_1601: A3C_RscButton
		{
			idc = 12;
			text = "CANCEL"; //--- ToDo: Localize;
			x = 0.683294 * safezoneW + safezoneX;
			y = 0.389982 * safezoneH + safezoneY;
			w = 0.0400956 * safezoneW;
			h = 0.0550088 * safezoneH;
		};		
	};
};
