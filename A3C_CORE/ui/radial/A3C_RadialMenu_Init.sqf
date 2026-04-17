
if (isDedicated) exitwith {};

A3C_HC_MENU_REFERENCE_UNITS = [];
A3C_RADIALMODE = "";
A3C_UI_GRID_SIZE = 1;
A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
A3C_UI_RADIAL_CTRLS_SHOWN = [];
A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;
A3C_UI_SHARED_createDashBoard_ExtraControls = [];
A3C_ACTIVE_BUTTONUNIT = objnull;


[] call A3C_RADIAL_RESET_DYNAMIC_BTNS;

//-- Open Radial SQ-levl Behaviour and combatMode controls via A3C_DSP_HUD_DYNAMIC
A3C_UI_Radial_SQ_ROE_MAIN = {
    A3C_DISABLE_RADIAL = true;
    [] call A3C_RADIAL_CloseDisplay;

    with uiNamespace do {
        A3C_HUD_OBS = (findDisplay 46) createDisplay "A3C_DSP_HUD_DYNAMIC";
    };

    setMousePosition [0.5, 0.5];

    // Button properties
    _buttonsPerRow = 5;
    _rows = 2;


    // Scaling factor to control the size of the entire dialog
    private _scaleFactor = 4; // Adjust this value to resize the dialog proportionally

    // Adjusted grid size based on scaling factor
    _grid = 12 * _scaleFactor;

    private _controlsGroup = (findDisplay 100100) ctrlCreate ["RscControlsGroup", 100];
    _controlsGroup ctrlSetPosition
    [
        (safeZoneX + (safeZoneW / 2)) - ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelW * 2 )),
        (safeZoneY + (safeZoneH / 2)) - ( (A3C_UI_GRID_SIZE * (_grid / 4)) * ( pixelGridNoUIScale * pixelH * 2 )),
        ( (A3C_UI_GRID_SIZE * _grid) * ( pixelGridNoUIScale * pixelW * 2 )), 
        ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelH * 2 ))
    ];
    _controlsGroup ctrlCommit 0;

    private _ctrlImageG = (findDisplay 100100) ctrlCreate ["RscPicture", 101, _controlsGroup];
    _ctrlImageG ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_CombatBehaviour.paa";
    _ctrlImageG ctrlSetPosition 
    [
        0, 
        0, 
        ( (A3C_UI_GRID_SIZE * _grid) * ( pixelGridNoUIScale * pixelW * 2 )), 
        ( (A3C_UI_GRID_SIZE * (_grid / 2)) * ( pixelGridNoUIScale * pixelH * 2 ))
    ];

    _bgColor = if (sunOrMoon < 1) then {[0,0.5,0.8,0.6]} else {[0,0,0,0.6]};
    _ctrlImageG ctrlSetTextColor _bgColor;
    _ctrlImageG ctrlCommit 0;

    // Define adjustable boundaries for button placement
    private _horizontalBoundary = 0.1; // Percentage of the background width to leave as horizontal margin
    private _verticalBoundary = 0.29;   // Percentage of the background height to leave as vertical margin

    // Calculate button placement boundaries
    private _backgroundWidth = (A3C_UI_GRID_SIZE * _grid) * (pixelGridNoUIScale * pixelW * 2);
    private _backgroundHeight = (A3C_UI_GRID_SIZE * (_grid / 2)) * (pixelGridNoUIScale * pixelH * 2);
    private _usableWidth = _backgroundWidth * (1 - 2 * _horizontalBoundary);
    private _usableHeight = _backgroundHeight * (1 - 2 * _verticalBoundary);

    // Button dimensions based on usable space
    private _buttonDim = _usableHeight / _rows; // Square buttons, sized to fit rows
    private _horizontalSpacing = (_usableWidth - (_buttonsPerRow * _buttonDim)) / (_buttonsPerRow - 1);

    // Starting offsets for button placement
    private _horizontalOffset = _horizontalBoundary * _backgroundWidth;
    private _verticalOffset = _verticalBoundary * _backgroundHeight;

    // Define button labels and tooltips
    _behaviours = ["CARELESS", "SAFE", "STEALTH", "AWARE", "COMBAT"];
    _behaviourTooltips = ["SET BEHAVIOUR: CARELESS", "SET BEHAVIOUR: SAFE", "SET BEHAVIOUR: STEALTH", "SET BEHAVIOUR: AWARE", "SET BEHAVIOUR: COMBAT"];
    _combatModes = ["BLUE", "GREEN", "WHITE", "YELLOW", "RED"];
    _combatModeTooltips = [
        "SET ROE: NEVER FIRE, KEEP FORMATION",
        "SET ROE: HOLD FIRE, KEEP FORMATION",
        "SET ROE: HOLD FIRE, ENGAGE AT WILL",
        "SET ROE: FIRE AT WILL, KEEP FORMATION",
        "SET ROE: FIRE AT WILL, ENGAGE AT WILL"
    ];
    _colorPalettes = [
        [0.17, 0.86, 0.92, 0.6],  
        [0, 1, 0, 0.4],            
        [1, 1, 1, 0.4],            
        [1, 1, 0, 0.4],            
        [0.5, 0, 0, 0.4]           
    ];

	_awareButtonX = 0.5;
	_awareButtonY = 0.5;
	

    // Loop through rows and buttons
    for "_i" from 0 to (_rows - 1) do {
        _yPos = _verticalOffset + (_i * _buttonDim); // Adjust Y position for centering

        for "_t" from 0 to (_buttonsPerRow - 1) do {
            _xPos = _horizontalOffset + (_t * (_buttonDim + _horizontalSpacing)); // Adjust X position

            private _ctrlImg = (findDisplay 100100) ctrlCreate ["RscPicture", -1, _controlsGroup];
            _ctrlImg ctrlSetText "A3C_CORE\ui\pictures\icon_menu_ROE_OPT.paa";
            _ctrlImg ctrlSetTextColor (_colorPalettes select _t);
            _ctrlImg ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];
            _ctrlImg ctrlCommit 0;

            private _ctrlBtn = (findDisplay 100100) ctrlCreate ["A3C_RscButton_Invisible", -1, _controlsGroup];
            _ctrlBtn ctrlSetPosition [_xPos, _yPos, _buttonDim, _buttonDim];
            private _tooltip = if (_i == 0) then {_behaviourTooltips select _t} else {_combatModeTooltips select _t};
            private _mode = if (_i == 0) then {"BEHAVIOUR"} else {"COMBATMODE"};
            private _value = if (_i == 0) then {_behaviours select _t} else {_combatModes select _t};
            private _buttonAction = format ["['%1', '%2'] call A3C_BHV_CBM_MACRO;", _mode, _value];
            _ctrlBtn ctrlSetTooltip _tooltip;
            _ctrlBtn buttonSetAction _buttonAction;
            _ctrlBtn ctrlCommit 0;

			//-- Save the position of the "AWARE" button (Row 0, Column 3)
            if (_i == 0 && _t == 2) then {
                _awareButtonX = _xPos;
                _awareButtonY = _yPos;
            };
        }
    };

	setMousePosition [_awareButtonX, _awareButtonY];
};








A3C_UI_RADIAL_iconsAtClickPos = {
	params ["_clickPos"];
	_clickPos params ["_clickPosX","_clickPosY"];
	private _iconsAtPosition = [];

	

	{
		_x params ["_group","_sizeArray","_iconPos"];
		_sizeArray params ["_iconScreenWidth","_iconScreenHeight"];

		if (count _iconPos > 0) then {


			_iconScreenWidth =  _iconScreenWidth / 50;
			_iconYDivisor = 50 / (getResolution select 4);
			_iconScreenHeight = _iconScreenHeight / _iconYDivisor;

			_clickDifX = abs ((_iconPos select 0) - (_clickPos select 0));
			_clickDifY = abs ((_iconPos select 1) - (_clickPos select 1));

			if (_clickDifX < _iconScreenWidth && {_clickDifY < _iconScreenHeight}) then {
				_iconsAtPosition pushBackUnique _x;
			};

		};

	} foreach A3C_UI_HUDICONS_HC_GROUP;
	_iconsAtPosition
};


	/*
	EDITING NOTES:
	This function is executed when pressing the Healing Button in the radial menu and is depending on input, which is depending on circumstances
	Active Medic(s) will start healing available patients until the array is empty.
	Patients that are actively healed by a medic does not have to be in available array anymore

	Healing System explained:
	When opening the healing section, the arrays A3C_MEDICS and A3C_PATIENTS will be formed. These simply represent availability and necessity for help and represent the planning stage



	*/



// -- Mistakenly made this not knowing that my buggy behavior came from setting cursel (so this one is not really necessary)
A3C_addLbEntry = {
	params ["_control","_lbText"];
	A3C_CurSel = true;
	private _index = _control lbAdd _lbText;
	A3C_CurSel = false;
	_index
};

A3C_setCurSel = {
	params ["_control","_index"];
	
	private _doExecuteLbAction = if (count _this > 2) then {_this select 2} else {false};
	
	if (typeName _doExecuteLbAction != "BOOL") exitWith {
		systemchat format ["A3C_setCurSel: Wrong parameter type for doExecuteAction: %1", _this];
	};
	if !(_doExecuteLbAction) then {
		A3C_CurSel = true;
	};

	// systemchat format ["A3C_setCurSel A3C_CurSel %1, condition %2", A3C_CurSel, !(_doExecuteLbAction)];
	
	_control lbSetCurSel _index;
	if !(_doExecuteLbAction) then {
		[] spawn {
			//-- we need the delay because the LB_Change fnc takes too long to execute
			sleep 0.2; A3C_CurSel = false;
		};
	};
	
};


A3C_LB_ADD =
{
	// 
	DISABLESERIALIZATION;
	{
		_x params["_label","_class","_obj","_cbo","_img"];
		_index = [_cbo, _label] call A3C_addLbEntry;

		_cbo lbSetData [(lbSize _cbo)-1,  _class];
		switch (A3C_RADIALMODE) do {
			case ("BRAIN") : {
				//_array = "true" configClasses (configFile>>"CfgRanks");
				//{
				//	if ((getText (configfile >> "CfgRanks" >> (configname _x) >> "displayName")) == (rank _obj)) exitWith {
				//		_picture = (getText (configfile >> "CfgRanks" >> (configname _x) >> "texture"));
				//	};
				//} foreach _array;
			};
			case ("VEHS") : {
				_img = ((getText (configfile >> "CfgVehicles" >> _class >> "picture")));
			};
		};
		_cbo lbSetPicture [(lbSize _cbo)-1,_img];
	} forEach _this;
	// 
	

};