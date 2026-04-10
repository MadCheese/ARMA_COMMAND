class HUD_CAM_DISPLAY
{
	idd = 79995;
	movingenable = false;
	
	//onKeyDown = "systemchat 'kd'";
	onKeyUp = "if ((_this select 1) in (actionKeys 'lookaround')) then { A3C_HUD_CAM_Moving = false};";
	onMouseMoving = "_this call A3C_HUD_CAM_MoveCam";
	//onMouseButtonDown = "systemchat 'md'";
	
	class ControlsBackground {
	};
	
		
	class Controls 
	{
		
				
	};
};




//HUD_CAM_DISPLAY = (finddisplay 46) createDisplay "HUD_CAM_DISPLAY";

