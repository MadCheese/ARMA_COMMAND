class HUD_CAM_DISPLAY
{
	idd = 100110;
	movingenable = false;
	onKeyUp = "if ((_this select 1) in (actionKeys 'lookaround')) then { A3C_HUD_CAM_Moving = false};";
	onMouseMoving = "_this call A3C_HUD_CAM_MoveCam";	
	class ControlsBackground
	{
	};
	
	class Controls 
	{			
	};
};
