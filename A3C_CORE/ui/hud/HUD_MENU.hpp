#include "..\SHARED\shared_ui_defines.hpp"


#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2 ))

//NoUIScale
//UI element sizes
#define MAIN_WIDTH 40
#define MAIN_HEIGHT 40



// //-- LAYER 2: DIALOG (Invisible Buttons Only)
// class A3C_HUD_MENU
// {
// 	idd = 100050;
// 	movingenable = false;


// 	onKeyDown = "_this call A3C_UI_HUD_HudMenu_onKeyDown";
	
// 	onKeyUp = "_this call A3C_UI_HUD_HudMenu_onKeyUp";

// 	class ControlsBackground {
// 	};


// 	class Controls
// 	{


// 		class A3C_HUD_CtrlsGroup: A3C_RscControlsGroup_NoScroll
// 		{
// 			idc = 11111;

// 			x = 0.5 - (GRIDX( MAIN_WIDTH ) / 2); //-- center ctrlsGroup
// 			y = (( safezoneY + safezoneH ) * 0.97) - GRIDY( MAIN_HEIGHT);
// 			w = GRIDX( MAIN_WIDTH );
// 			h = GRIDY( MAIN_HEIGHT);

// 			class Controls
// 			{


// 				class A3C_HUD_FORM_BOX : A3C_RscButton_Invisible
// 				{
// 					idc = 14;
			
// 					x = GRIDX( 20 ) - GRIDX( 6 );
// 					y = GRIDY( 28 );
// 					w = GRIDX( 12 );
// 					h = GRIDY( 12 );
					
// 					tooltip = "Change Formation";
// 					onMouseButtonDown = "[1,_this select 1] call A3C_UI_HUD_FORM_BUTTON";
// 					onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_UI_HUD_FORM_BUTTON} else {[1,1] call A3C_UI_HUD_FORM_BUTTON};";
// 				};



// 				class A3C_HUD_TRAVEL_BOX : A3C_RscButton_Invisible
// 				{
// 					idc = 16;
				
// 					x = GRIDX( 1 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );
					
// 					tooltip = "Change Stance: TRAVEL";
// 					onMouseButtonDown = "[0,_this select 1] call A3C_HUD_STANCE_BUTTONS";
// 					onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_STANCE_BUTTONS} else {[0,1] call A3C_HUD_STANCE_BUTTONS};";
// 				};

// 				class A3C_HUD_SPEED_BOX : A3C_RscButton_Invisible
// 				{
// 					idc = 15;

// 					x = GRIDX( 5 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );
					
				
// 					action = "[] call A3C_HUD_SPEED_BUTTON";
// 				};

// 				class A3C_HUD_DESTINATION_BOX : A3C_RscButton_Invisible
// 				{
// 					idc = 17;
				
// 					x = GRIDX( 10 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );
					
// 					tooltip = "Change Stance: DESTINATION";
// 					onMouseButtonDown = "[1,_this select 1] call A3C_HUD_STANCE_BUTTONS";
// 					onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_HUD_STANCE_BUTTONS} else {[1,1] call A3C_HUD_STANCE_BUTTONS};";
// 				};

// 				class A3C_HUD_GOCODE_BOX : A3C_RscButton_Invisible
// 				{
// 					idc = 18;
				
// 					x = GRIDX( 26 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );
					
// 					onMouseButtonDown = "[0,_this select 1] call A3C_HUD_GOCODE_BUTTON";
// 					onMouseZChanged = "if ((_this select 1) < 0) then {[0,0] call A3C_HUD_GOCODE_BUTTON} else {[0,1] call A3C_HUD_GOCODE_BUTTON};";
// 				};

// 				class A3C_HUD_OVERRIDE_BOX_2 : A3C_RscButton_Invisible
// 				{
// 					idc = 11;

// 					x = GRIDX( 30 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );

// 					action = "[] call A3C_HUD_WPMODE_BUTTON";
// 				};


// 				class A3C_HUD_HIDE_BOX_2 : A3C_RscButton_Invisible
// 				{
// 					idc = 13;

// 					x = GRIDX( 35 );
// 					y = GRIDY( 32 );
// 					w = GRIDX( 4 );
// 					h = GRIDY( 4 );

// 					action = "[] call A3C_UI_HUD_BUTTON";
// 				};

// 			};
// 		};

// 	};
// };

class HUD_SelectionPromptPanel
{
	idd = 100060;
	movingenable = true;
	onKeyDown = "_this call A3C_UI_HUD_SelectionPromptPanel_onKeyDown; true";
	onKeyUp = "_this call A3C_UI_HUD_SelectionPromptPanel_onKeyUp;";

	class ControlsBackground {
	};

	class Controls
	{
		class HUD_SelectionPromptPanel_Parent: A3C_RscControlsGroup_NoScroll
		{
			idc = IDC_SHARED_UI_SelectionPromptPanel_Parent; //8008;
			x = 0.383108 * safezoneW + safezoneX;
			y =  0.378986 * safezoneH + safezoneY;
			w = 0.192528 * safezoneW;
			h = 0.143016 * safezoneH;
			class Controls
			{

				class HUD_SelectionPromptPanel_Description_BG: A3C_RscPicture
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_Description_BG; //800801;
					text = "#(argb,8,8,3)color(0,0.3,0.6,1)";
					x = 1.8033e-007 * safezoneW;
					y = -1.80325e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class HUD_SelectionPromptPanel_Description_TXT: A3C_RscText
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_Description_TXT; //800802;
					x = 2.45904e-007 * safezoneW;
					y = -3.77043e-007 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0440051 * safezoneH;
				};
				class HUD_SelectionPromptPanel_ListBox: A3C_LISTBOX
				{
					idc = IDC_SHARED_UI_SelectionPromptPanel_ListBox; //800803;
					style = CT_LISTBOX;
					x = 2.45904e-007 * safezoneW;
					y = 0.0440052 * safezoneH;
					w = 0.192528 * safezoneW;
					h = 0.0990114 * safezoneH;
					onLBSelChanged = "[(_this select 1)] call A3C_SelectionPromptPanel_LB_Change";
				};
			};
		};

	};
};








