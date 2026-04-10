findDisplay 12 ctrlCreate ["A3C_MAPDIALOG", 6998];

[] spawn {
	sleep 3;
	_ar = [];
	disableserialization;
	
	{
		_ar pushBack [_x,ctrlPosition _x];
	} foreach (allControls (findDisplay 6998));
	copytoclipboard str _ar;
};



[] spawn {disableSerialization; _button1 = (findDisplay 12) ctrlCreate ["RscButton",1928]; 
  _button1 ctrlSetPosition  [0.5 * safezoneW + safezoneX,0.5 * safezoneH + safezoneY,0.12375 * safezoneW,0.033 * safezoneH]; 
  _button1 ctrlCommit 0; 
  _button1 ctrlSetText "button"; 
  _button1 buttonSetAction "hint 'button pressed'";}; 
  
  
    
    
    