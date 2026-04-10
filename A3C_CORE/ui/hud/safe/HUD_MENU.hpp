class A3C_HUD_MENU
{
	idd = 79992;
	movingenable = false;
	class ControlsBackground {

	};
	
		
	class Controls 
	{
		
		class A3C_HUD_TRAVEL_BOX : A3C_RscButton_Invisible
		{
			idc = 16;
			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 12.5 * GUI_GRID_W + GUI_GRID_X;
			y = 1.1 * GUI_GRID_H + GUI_GRID_Y;
			w = 5 * GUI_GRID_W;
			h = (5 * GUI_GRID_H) * 0.79;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			tooltip = "Change Stance: TRAVEL";
			onMouseButtonDown = "[0,_this select 1] call A3C_HUD_STANCE_BUTTONS";
			onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_STANCE_BUTTONS} else {[0,1] call A3C_HUD_STANCE_BUTTONS};";
		};
		class A3C_HUD_DESTINATION_BOX : A3C_RscButton_Invisible
		{
			idc = 17;
			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 23.5 * GUI_GRID_W + GUI_GRID_X;
			y = 1.1 * GUI_GRID_H + GUI_GRID_Y;
			w = 5 * GUI_GRID_W;
			h = (5 * GUI_GRID_H) * 0.79;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			tooltip = "Change Stance: DESTINATION";
			onMouseButtonDown = "[1,_this select 1] call A3C_HUD_STANCE_BUTTONS";
			onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_HUD_STANCE_BUTTONS} else {[1,1] call A3C_HUD_STANCE_BUTTONS};";
		};
		
		
		
		
		class A3C_HUD_OVERRIDE_BOX_1 : A3C_RscPicture
		{
			idc = 10;
			text = "";
			x = 18.7 * GUI_GRID_W + GUI_GRID_X;
			y = -1.3 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
		};
		class A3C_HUD_OVERRIDE_BOX_2 : A3C_RscButton_Invisible
		{
			idc = 11;
			//text = "";
			x = 18.7 * GUI_GRID_W + GUI_GRID_X;
			y = -1.3 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			//tooltip = "";
			action = "[] call A3C_HUD_WPMODE_BUTTON";
		};
		class A3C_HUD_HIDE_BOX_1 : A3C_RscPicture
		{
			idc = 12;
			text = "";
			x = 20.5 * GUI_GRID_W + GUI_GRID_X;
			y = -1.3 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			//tooltip = "Change Formation";
			//action = "['Purple',(_this select 1)] call A3C_RadialMenu_FNC_TEAMCOLOR";
		};
		class A3C_HUD_HIDE_BOX_2 : A3C_RscButton_Invisible
		{
			idc = 13;
			//text = "";
			x = 20.5 * GUI_GRID_W + GUI_GRID_X;
			y = -1.3 * GUI_GRID_H + GUI_GRID_Y;
			w = 1.5 * GUI_GRID_W;
			h = 1.5 * GUI_GRID_H;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			//tooltip = "Change Formation";
			action = "[] call A3C_HUD_UI_BUTTON";
		};
		
		
		class A3C_HUD_SPEED_BOX : A3C_RscButton_Invisible
		{
			idc = 15;
			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 19.3 * GUI_GRID_W + GUI_GRID_X;
			y = 3.1 * GUI_GRID_H + GUI_GRID_Y;
			w = 2.5 * GUI_GRID_W;
			h = (2.5 * GUI_GRID_H) * 0.79;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			//tooltip = "";
			action = "[] call A3C_HUD_SPEED_BUTTON";
		};
		class A3C_HUD_GOCODE_BOX : A3C_RscButton_Invisible
		{
			idc = 18;
			//text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 20.7 * GUI_GRID_W + GUI_GRID_X;
			y = 1 * GUI_GRID_H + GUI_GRID_Y;
			w = 2.5 * GUI_GRID_W;
			h = (2.5 * GUI_GRID_H) * 0.79;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			//tooltip = "";
			onMouseButtonDown = "[0,_this select 1] call A3C_HUD_GOCODE_BUTTON";
			onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_GOCODE_BUTTON} else {[0,1] call A3C_HUD_GOCODE_BUTTON};";
		};
		class A3C_HUD_FORM_BOX : A3C_RscButton_Invisible
		{
			idc = 14;
			//text = "#(argb,8,8,3)color(0,1,1,1)";
			x = 17.8 * GUI_GRID_W + GUI_GRID_X;
			y = 1 * GUI_GRID_H + GUI_GRID_Y;
			w = 2.5 * GUI_GRID_W;
			h = (2.5 * GUI_GRID_H) * 0.79;
			//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
			tooltip = "Change Formation";
			onMouseButtonDown = "[1,_this select 1] call A3C_HUD_UI_FORM_BUTTON";
			onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_HUD_UI_FORM_BUTTON} else {[1,1] call A3C_HUD_UI_FORM_BUTTON};";
		};
	};
};

//cutRsc ["A3C_HUD_MENU_UI","PLAIN"];
class RscTitles
	{

	class A3C_HUD_MENU_UI
	{
		idd = 79993;
		duration = 1000000000000;
		fadeIn = 0;
		fadeOut = 0;
		name = "A3C_HUD_MENU_UI";
		onLoad = "profileNamespace setVariable ['A3C_HUD_isOpen',true]; uiNamespace setVariable['A3C_HUD_MENU_UI',_this select 0]";
		onUnload = "profileNamespace setVariable ['A3C_HUD_isOpen',false]; uiNamespace setVariable['A3C_HUD_MENU_UI', displayNull]";
		onDestroy =  "profileNamespace setVariable ['A3C_HUD_isOpen',false]; uiNamespace setVariable['A3C_HUD_MENU_UI', displayNull]";
		
		class ControlsBackground
		{
			class A3C_HUD_UI_BG : A3C_RscPicture
			{
				idc = 15;
				//text = "#(argb,8,8,3)color(1,1,1,0.3)";
				//colorText[] = {1,1,1,0.7};
				x = 12 * GUI_GRID_W + GUI_GRID_X;
				y = 0.5 * GUI_GRID_H + GUI_GRID_Y;
				w = 17 * GUI_GRID_W;
				h = 5 * GUI_GRID_H;
			};

			class A3C_HUD_UI_TRAVEL_BOX : A3C_RscPicture
			{
				idc = 10;
				//text = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\si_stand_ca.paa";
				x = 12.5 * GUI_GRID_W + GUI_GRID_X;
				y = 1.1 * GUI_GRID_H + GUI_GRID_Y;
				w = 5 * GUI_GRID_W;
				h = (5 * GUI_GRID_H) * 0.79;
				//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
				//tooltip = "Change Stance: TRAVEL";
				//action = "[0,_this select 1] call A3C_HUD_UI_STANCE_BUTTONS";
			};
			class A3C_HUD_UI_DESTINATION_BOX : A3C_RscPicture
			{
				idc = 11;
				//text = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\si_stand_ca.paa";
				x = 23.5 * GUI_GRID_W + GUI_GRID_X;
				y = 1.1 * GUI_GRID_H + GUI_GRID_Y;
				w = 5 * GUI_GRID_W;
				h = (5 * GUI_GRID_H) * 0.79;
				//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
				//tooltip = "Change Stance: DESTINATION";
				//action = "[1] call A3C_HUD_UI_STANCE_BUTTONS";
			};
		
			class A3C_HUD_UI_FORM_BOX : A3C_RscPicture
			{
				idc = 12;
				//text = "#(argb,8,8,3)color(0,1,1,1)";
				x = 17.8 * GUI_GRID_W + GUI_GRID_X;
				y = 1 * GUI_GRID_H + GUI_GRID_Y;
				w = 2.5 * GUI_GRID_W;
				h = (2.5 * GUI_GRID_H) * 0.79;
				//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
				//tooltip = "Change Formation";
				//action = "[1] call A3C_HUD_UI_FORM_BUTTON";
			};
			class A3C_HUD_UI_SPEED_BOX : A3C_RscPicture
			{
				idc = 13;
				//text = "#(argb,8,8,3)color(1,1,1,1)";
				x = 19.3 * GUI_GRID_W + GUI_GRID_X;
				y = 3.1 * GUI_GRID_H + GUI_GRID_Y;
				w = 2.5 * GUI_GRID_W;
				h = (2.5 * GUI_GRID_H) * 0.79;
				//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
				//tooltip = "";
				//action = "[] call A3C_HUD_UI_SPEED_BUTTON";
			};
			class A3C_HUD_UI_GOCODE_BOX : A3C_RscPicture
			{
				idc = 14;
				//text = "#(argb,8,8,3)color(0,1,1,1)";
				x = 20.7 * GUI_GRID_W + GUI_GRID_X;
				y = 1 * GUI_GRID_H + GUI_GRID_Y;
				w = 2.5 * GUI_GRID_W;
				h = (2.5 * GUI_GRID_H) * 0.79;
				//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
				//tooltip = "Change Formation";
				//action = "[] call A3C_HUD_UI_FORM_BUTTON";
			};
		};
	};
};




	