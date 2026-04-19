
#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2 ))

//NoUIScale
//UI element sizes
#define MAIN_WIDTH 40
#define MAIN_HEIGHT 40



//-- LAYER 2: DIALOG (Invisible Buttons Only)
class A3C_HUD_MENU
{
	idd = 100050;
	movingenable = false;


	onKeyDown = "_this call A3C_UI_HUD_HudMenu_onKeyDown";
	
	onKeyUp = "_this call A3C_UI_HUD_HudMenu_onKeyUp";

	class ControlsBackground {
	};


	///////
	class Controls
	{


		class A3C_HUD_CtrlsGroup: A3C_RscControlsGroup_NoScroll
		{
			idc = 11111;

			x = 0.5 - (GRIDX( MAIN_WIDTH ) / 2); //-- center ctrlsGroup
			y = (( safezoneY + safezoneH ) * 0.97) - GRIDY( MAIN_HEIGHT);
			w = GRIDX( MAIN_WIDTH );
			h = GRIDY( MAIN_HEIGHT);

			class Controls
			{


				class A3C_HUD_FORM_BOX : A3C_RscButton_Invisible
				{
					idc = 14;
					//text = "#(argb,8,8,3)color(0,1,1,1)";
					x = GRIDX( 20 ) - GRIDX( 6 );
					y = GRIDY( 28 );
					w = GRIDX( 12 );
					h = GRIDY( 12 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "Change Formation";
					onMouseButtonDown = "[1,_this select 1] call A3C_UI_HUD_FORM_BUTTON";
					onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_UI_HUD_FORM_BUTTON} else {[1,1] call A3C_UI_HUD_FORM_BUTTON};";
				};



				class A3C_HUD_TRAVEL_BOX : A3C_RscButton_Invisible
				{
					idc = 16;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = GRIDX( 1 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "Change Stance: TRAVEL";
					onMouseButtonDown = "[0,_this select 1] call A3C_HUD_STANCE_BUTTONS";
					onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_STANCE_BUTTONS} else {[0,1] call A3C_HUD_STANCE_BUTTONS};";
				};

				class A3C_HUD_SPEED_BOX : A3C_RscButton_Invisible
				{
					idc = 15;

					x = GRIDX( 5 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					//tooltip = "";
					action = "[] call A3C_HUD_SPEED_BUTTON";
				};

				class A3C_HUD_DESTINATION_BOX : A3C_RscButton_Invisible
				{
					idc = 17;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = GRIDX( 10 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					tooltip = "Change Stance: DESTINATION";
					onMouseButtonDown = "[1,_this select 1] call A3C_HUD_STANCE_BUTTONS";
					onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_HUD_STANCE_BUTTONS} else {[1,1] call A3C_HUD_STANCE_BUTTONS};";
				};

				class A3C_HUD_GOCODE_BOX : A3C_RscButton_Invisible
				{
					idc = 18;
					//text = "#(argb,8,8,3)color(1,1,1,1)";
					x = GRIDX( 26 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					//tooltip = "";
					onMouseButtonDown = "[0,_this select 1] call A3C_HUD_GOCODE_BUTTON";
					onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_GOCODE_BUTTON} else {[0,1] call A3C_HUD_GOCODE_BUTTON};";
				};

				class A3C_HUD_OVERRIDE_BOX_2 : A3C_RscButton_Invisible
				{
					idc = 11;
					//text = "";

					x = GRIDX( 30 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					//tooltip = "";
					action = "[] call A3C_HUD_WPMODE_BUTTON";
				};


				class A3C_HUD_HIDE_BOX_2 : A3C_RscButton_Invisible
				{
					idc = 13;
					//text = "";
					x = GRIDX( 35 );
					y = GRIDY( 32 );
					w = GRIDX( 4 );
					h = GRIDY( 4 );
					//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
					//tooltip = "Change Formation";
					action = "[] call A3C_UI_HUD_BUTTON";
				};

			};
		};

	};
};

class HUD_Display_ObjectSelector
{
	idd = 100060;
	movingenable = true;

	onKeyUp = "_this call A3C_UI_HUD_ObjectSelector_onKeyUp;";

	class ControlsBackground {
	};

	class Controls
	{
		class 8008: A3C_RscControlsGroup_NoScroll
		{
			idc = 8008;
			x = 0.383108 * safezoneW + safezoneX;
			y =  0.378986 * safezoneH + safezoneY;
			w = 0.192528 * safezoneW;
			h = 0.143016 * safezoneH;
			class Controls
			{

				class A3C_HUD_ObjectSelector_Description_BG: A3C_RscPicture
				{
					idc = 800801;
					text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
					x = 1.8033e-007 * safezoneW;
					y = -1.80325e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HUD_ObjectSelector_Description_Text: A3C_RscText
				{
					idc = 800802;
					text = "TEST"; //--- ToDo: Localize;
					x = 2.45904e-007 * safezoneW;
					y = -3.77043e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class A3C_HUD_ObjectSelector_ListBox: A3C_LISTBOX
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

//-- LAYER 1: VISIBLE UI (Feedback Images Only)
class RscTitles
{

	

	class A3C_HUD_MENU_UI
	{
		idd = 200010;
		duration = 1000000000000;
		fadeIn = 0;
		fadeOut = 0;
		name = "A3C_HUD_MENU_UI";
		onLoad = "profileNamespace setVariable ['A3C_HUD_isOpen',true]; uiNamespace setVariable['A3C_HUD_MENU_UI',_this select 0];";
		onUnload = "profileNamespace setVariable ['A3C_HUD_isOpen',false]; uiNamespace setVariable['A3C_HUD_MENU_UI', displayNull]";
		onDestroy =  "profileNamespace setVariable ['A3C_HUD_isOpen',false]; uiNamespace setVariable['A3C_HUD_MENU_UI', displayNull]";

		class ControlsBackground
		{




			//[0.124999,0.100052,0.900222,1.20014]
			class A3C_UI_HUD_CtrlsGroup : A3C_RscControlsGroup_NoScroll
			{
				idc = 11111;

				x = 0.5 - (GRIDX( MAIN_WIDTH ) / 2); //-- center ctrlsGroup
				y = (( safezoneY + safezoneH ) * 0.97) - GRIDY( MAIN_HEIGHT);
				w = GRIDX( MAIN_WIDTH );
				h = GRIDY( MAIN_HEIGHT);
				class controls
				{

					//-- Background
					class A3C_UI_HUD_BG: A3C_RscPicture
					{
						idc = 15;

						x = 0;
						y = 0;
						w = GRIDX( MAIN_WIDTH );
						h = GRIDY( MAIN_HEIGHT );
					};

					//-- FormSector icon (center circle)
					class A3C_UI_HUD_FORM_BOX: A3C_RscPicture
					{
						idc = 12;

						x = GRIDX( 20 ) - GRIDX( 6 );
						y = GRIDY( 28 );
						w = GRIDX( 12 );
						h = GRIDY( 12 );

						//shadow = 0;
						colorText[] = { 1, 1, 1, 1 };
						//text = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";
					};
					//-- left of formSector
					class A3C_UI_HUD_TRAVEL_BOX : A3C_RscPicture
					{
						idc = 10;
						x = GRIDX( 1 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );
					};
					class A3C_UI_HUD_SPEED_BOX : A3C_RscPicture
					{
						idc = 13;
						x = GRIDX( 5 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );
					};
					class A3C_UI_HUD_DESTINATION_BOX : A3C_RscPicture
					{
						idc = 11;
						x = GRIDX( 10 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );
					};

					//-- right side of FormSector
					class A3C_UI_HUD_GOCODE_BOX : A3C_RscPicture
					{
						idc = 14;
						x = GRIDX( 26 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );
					};
					class A3C_HUD_OVERRIDE_BOX_1 : A3C_RscPicture
					{
						idc = 16;
						x = GRIDX( 30 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );

					};
					class A3C_HUD_HIDE_BOX_1 : A3C_RscPicture
					{

						idc = 17;
						x = GRIDX( 35 );
						y = GRIDY( 32 );
						w = GRIDX( 4 );
						h = GRIDY( 4 );
						text = "A3C_CORE\ui\pictures\icon_menu_showUI_true.paa";
					};

				};
			};
		};
	};

	class A3C_KEY_VIEWER_UI
	{
		idd = 200020;
		duration = 1000000000000;
		fadeIn = 0;
		fadeOut = 0;
		name = "A3C_KEY_VIEWER_UI";
		onLoad = "uiNamespace setVariable['A3C_KEY_VIEWER_UI',_this select 0];";
		onUnload = "uiNamespace setVariable['A3C_KEY_VIEWER_UI', displayNull]";
		onDestroy =  "uiNamespace setVariable['A3C_KEY_VIEWER_UI', displayNull]";
		class Controls
		{
			class A3C_UI_HUD_BG: A3C_RscText
			{
				idc = 11;

				x = 0.5 - (GRIDX( MAIN_WIDTH ) / 2); //-- center ctrlsGroup
				y = (( safezoneY + safezoneH ) * 0.4) - GRIDY( MAIN_HEIGHT);
				w = GRIDX( MAIN_WIDTH );
				h = GRIDY( MAIN_HEIGHT );

				text = "Hello Hello Hello Hello";
				SizeEx = "(((((safezoneW / safezoneH) min 0.1) / 0.1) / 25) * 2)";
			};
		};
	};
};






