class MCSS_FOGDIALOG
{
	idd= -1;
	movingenable = true;
	class controls
	{
		class MC_FogValue: A3C_RscSlider
		{
			idc = 10000;
			x = 0.741066 * safezoneW + safezoneX;
			y = 0.0318329 * safezoneH + safezoneY;
			w = 0.24275 * safezoneW;
			h = 0.0418731 * safezoneH;
		};
		class MC_FogDecay: A3C_RscSlider
		{
			idc = 10001;
			x = 0.742449 * safezoneW + safezoneX;
			y = 0.0942549 * safezoneH + safezoneY;
			w = 0.24275 * safezoneW;
			h = 0.0418731 * safezoneH;
		};
		class MC_FOGBASE: A3C_RscSlider
		{
			idc = 10002;
			x = 0.744524 * safezoneW + safezoneX;
			y = 0.156677 * safezoneH + safezoneY;
			w = 0.24275 * safezoneW;
			h = 0.0418731 * safezoneH;
		};
	};
};