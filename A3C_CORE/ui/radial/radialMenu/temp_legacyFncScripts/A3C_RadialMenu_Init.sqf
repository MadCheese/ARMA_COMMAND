#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

if (isDedicated) exitWith {};

A3C_HC_MENU_REFERENCE_UNITS = [];
A3C_RADIALMODE = "";
A3C_UI_GRID_SIZE = 1;
A3C_CURRENT_COMMAND_LEVEL = "SQUAD";
A3C_UI_RADIAL_CTRLS_SHOWN = [];
A3C_UI_RADIAL_CTRLS_SHOWN_ACTIVATED = false;
A3C_UI_SHARED_createDashBoard_ExtraControls = [];
A3C_ACTIVE_BUTTONUNIT = objnull;


[] call A3C_UI_RADIAL_RESET_DYNAMIC_BTNS;

//-- Open Radial SQ-levl Behaviour and combatMode controls via A3C_DSP_HUD_DYNAMIC
A3C_UI_Radial_SQ_ROE_MAIN = {
    A3C_DISABLE_RADIAL = true;
    [] call A3C_UI_RADIAL_CloseDisplay;

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

A3C_UI_RADIAL_populateOuterRing_Grenades = {
	params ["_muzzle","_mode"];
	//player commandchat str [_mode];

	//-- label parent button
	private _col = if (count A3C_AI_GREN_ARRAY == 0) then {[1,1,1,0.3]} else{[1,1,1,0.6]};
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_GRENADES_IMG) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_grenade.paa";
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_GRENADES_IMG) ctrlSetTextColor _col;
	(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_GRENADES_BTN) ctrlSetToolTip "AI Grenades";


	//-- sort grenades by usability
	A3C_AI_GREN_ARRAY =
	[
		A3C_AI_GREN_ARRAY,
		[],
		{
			_ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
			_number = 0;
			_explo = getNumber (configfile >> "CfgAmmo" >> _ammo >> "explosive");
			if (_explo == 1) then {
				_hit = getNumber (configfile >> "CfgAmmo" >> _ammo >> "hit");
				_number = 1000 * _hit;
			} else {
				_number = getNumber (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
			};
			_number
		},
		"DESCEND"
	] call BIS_fnc_sortBy;

	if (A3C_RADIALMODE == "GRENADE" ) then {//&& {BV_GREN == 0}
		//-- Reset outer ring controls
		{
			_x ctrlShow false;
		} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

		//-- Clear outer ring images
		{
			_x ctrlSetText "";
		} forEach (["radial_outerImages"] call FUNC(ctrlGroup));

		//-- Clear outer ring button tooltips
		{
			_x ctrlSetTooltip "";
		} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));

		_outerRingBackGroundIDs = ["PlaceHolder","Left","bottom","Right","Top"];

		// Outer ring backgrounds.
		private _outerRingBackgrounds = (["radial_outerRingBackgrounds"] call FUNC(ctrlGroup)) select [1, 4];

		{
			private _ctrl = _x;
			private _ind = _forEachIndex + 1;

			if (_ind <= ((ceil ((count A3C_AI_GREN_ARRAY) / 4)) min 3)) then {
				_ctrl ctrlShow true; // Outer circle background shown.
				_ctrl ctrlSetText format [
					"A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",
					_outerRingBackGroundIDs select _ind
				];
			} else {
				_ctrl ctrlShow false; // Outer circle background hidden.
			};
		} forEach _outerRingBackgrounds;
		
		if (count A3C_AI_GREN_ARRAY == 0) exitWith {};
		//-- label buttons-images and fncs
		private _grenadeSlots = [
			[["outerLeft4Img"] call FUNC(ctrl), ["outerLeft4Btn"] call FUNC(ctrl), 16],
			[["outerLeft3Img"] call FUNC(ctrl), ["outerLeft3Btn"] call FUNC(ctrl), 15],
			[["outerLeft2Img"] call FUNC(ctrl), ["outerLeft2Btn"] call FUNC(ctrl), 14],
			[["outerLeft1Img"] call FUNC(ctrl), ["outerLeft1Btn"] call FUNC(ctrl), 13],

			[["outerBottom4Img"] call FUNC(ctrl), ["outerBottom4Btn"] call FUNC(ctrl), 12],
			[["outerBottom3Img"] call FUNC(ctrl), ["outerBottom3Btn"] call FUNC(ctrl), 11],
			[["outerBottom2Img"] call FUNC(ctrl), ["outerBottom2Btn"] call FUNC(ctrl), 10],
			[["outerBottom1Img"] call FUNC(ctrl), ["outerBottom1Btn"] call FUNC(ctrl), 9],

			[["outerRight4Img"] call FUNC(ctrl), ["outerRight4Btn"] call FUNC(ctrl), 8],
			[["outerRight3Img"] call FUNC(ctrl), ["outerRight3Btn"] call FUNC(ctrl), 7],
			[["outerRight2Img"] call FUNC(ctrl), ["outerRight2Btn"] call FUNC(ctrl), 6],
			[["outerRight1Img"] call FUNC(ctrl), ["outerRight1Btn"] call FUNC(ctrl), 5],

			[["outerTop4Img"] call FUNC(ctrl), ["outerTop4Btn"] call FUNC(ctrl), 4],
			[["outerTop3Img"] call FUNC(ctrl), ["outerTop3Btn"] call FUNC(ctrl), 3],
			[["outerTop2Img"] call FUNC(ctrl), ["outerTop2Btn"] call FUNC(ctrl), 2],
			[["outerTop1Img"] call FUNC(ctrl), ["outerTop1Btn"] call FUNC(ctrl), 1]
		];

		{
			private _slot = _grenadeSlots select _forEachIndex;
			_slot params ["_btnImage", "_btnClicker", "_buttonitem"];

			{
				_x ctrlShow true;
			} forEach [_btnImage, _btnClicker];

			_btnImage ctrlSetText (getText (configFile >> "CfgMagazines" >> _x >> "picture"));
			_btnClicker ctrlSetToolTip (getText (configFile >> "CfgMagazines" >> _x >> "displayNameShort"));

			call compile format [
				"
					A3C_OUTER_RING_BTN_fnc_%1 =
					[
						[],
						{
							A3C_GREN_MUZZLE = '%2';
							[] spawn A3C_UI_RADIAL_startGTIgrenadeLoop;
						}
					];
				",
				_buttonitem,
				_x
			];
		} forEach (A3C_AI_GREN_ARRAY select [0, count _grenadeSlots]);
	};
};

A3C_UI_RADIAL_startGTIgrenadeLoop = {

	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") exitWith {};

	_unit = objnull;
	{
		if ( ( {A3C_GREN_MUZZLE == _x} count (magazines _x)) > 0) exitWith {
			_unit = _x;
			A3C_GTI_UNIT = _x;
		};
	} foreach A3C_RD_UNITS;
	if (isnull _unit) exitWith {};
	{[_x] call A3C_UI_squadPlacement_fnc_removeUnitGhost} foreach A3C_UI_squadPlacement_units;

	if (isnil "A3C_GREN_MUZZLE") exitWith {
		(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_INNERRING_GRENADES_BTN) ctrlSetTooltip "currently no items available";
	};
	BR_A3C_TACV_throwTheta = 45;
	BR_A3C_TACV_throwTheta_Add = 0;
	A3C_GREN_ALLOW_UNITSWITCH = if (count A3C_RD_UNITS == 1) then {false} else {true};
	BR_A3C_TACV_oefId = ["BR_A3C_TACV_oefId", "onEachFrame", "BR_A3C_OEFControl"] call BIS_fnc_addStackedEventHandler;

	[] call A3C_UI_RADIAL_CloseDisplay;

	[
		false, //-- isBusy
		"GTI_GRENADE_SQUAD", //-- actionID
		'', //-- Hud-Icon-class
		[1,1,1,0.7], //-- Hud-Icon-color
		"", //-- placer class
		"" //-- placer color-params
	] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
	
	showCommandingMenu "";
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


