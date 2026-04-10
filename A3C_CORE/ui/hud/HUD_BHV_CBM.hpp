
#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2 ))

//NoUIScale


//UI element sizes
#define MAIN_WIDTH 110
#define MAIN_HEIGHT 60






class HUD_BHV_CBM
{
	idd = 79997;
	movingenable = false;
	class ControlsBackground 
	{
		class MCSS_A3C_BHV_CBM_Background: A3C_RscButton_Invisible
		{
			idc = -1;
			// text = "#(argb,8,8,3)color(1,1,1,1)";
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;

		};
		
	}

	
	class controls 
	{

		// class A3C_HUD_CtrlsGroup: A3C_RscControlsGroup_NoScroll
		// {
		// 	idc = 11111;

		// 	// x = 0.5 - (GRIDX( MAIN_WIDTH ) / 2); //-- center ctrlsGroup
		// 	// y = ( safezoneY + safezoneH )  - GRIDY( MAIN_HEIGHT);
		// 	// w = GRIDX( MAIN_WIDTH );
		// 	// h = GRIDY( MAIN_HEIGHT);
		// 	x = safezoneX;
		// 	y = safezoneY;
		// 	w = safezoneW;
		// 	h = safezoneH;

		// 	class Controls
		// 	{


		// 		// class A3C_BHV_1 : A3C_RscPicture//A3C_RscButton_Invisible
		// 		// {
		// 		// 	idc = 14;
		// 		// 	//text = "#(argb,8,8,3)color(0,1,1,1)";
		// 		// 	// x = GRIDX( 0 ); // - GRIDX( 6 );
		// 		// 	// y = GRIDY( 0 );
		// 		// 	// w = GRIDX( 15 );
		// 		// 	// h = GRIDY( 15 );
		// 		// 	x = GRIDX( 0 ); // - GRIDX( 6 );
		// 		// 	y = GRIDY( 0 );
		// 		// 	w = GRIDX( MAIN_WIDTH );
		// 		// 	h = GRIDY( MAIN_HEIGHT);


		// 		// 	//DEBUG
		// 		// 	colorText[] = { 1, 1, 1, 1 };
		// 		// 	text = "A3C_CORE\ui\pictures\icon_formSec_Line_Right.paa";


		// 		// 	//toolTipColorShade[] = {0.5,0.2,0.6,0.6};
		// 		// 	// tooltip = "Change Formation";
		// 		// 	// onMouseButtonDown = "[1,_this select 1] call A3C_HUD_UI_FORM_BUTTON";
		// 		// 	// onMouseZChanged = "if ((_this select 1) < 0) then {[1,0] call A3C_HUD_UI_FORM_BUTTON} else {[1,1] call A3C_HUD_UI_FORM_BUTTON};";
		// 		// };



				

		// 	};
		// };

			
	};
};



