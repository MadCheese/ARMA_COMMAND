
#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2 ))

//NoUIScale


//UI element sizes
#define MAIN_WIDTH 110
#define MAIN_HEIGHT 60






class A3C_DSP_HUD_DYNAMIC
{
	idd = 100100;
	movingenable = false;

	onKeyUp = "_this call A3C_UI_HUD_DYNAMIC_onKeyUp";

	class ControlsBackground 
	{
		class MCSS_A3C_BHV_CBM_Background: A3C_RscButton_Invisible
		{
			idc = -1;
			x = safezoneX;
			y = safezoneY;
			w = safezoneW;
			h = safezoneH;

		};
		
	}

	
	class controls 
	{
			
	};
};



