
#define GRIDX( num ) ( num * ( pixelGrid * pixelW * 2 ))
#define GRIDY( num ) ( num * ( pixelGrid * pixelH * 2 ))

//NoUIScale


//UI element sizes
#define MAIN_WIDTH 110
#define MAIN_HEIGHT 60






class HUD_BHV_CBM
{
	idd = 100100;
	movingenable = false;
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



