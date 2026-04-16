
// NOTE: previously A3C_CBA_DOWN_MENU (Remove this comment when cleaned up)
A3C_UI_RADIAL_HandlerFNC_OnKeyDown =	{
	params ["_display","_key"];
	private _mods = (_this select [2,5]);
	private _bool = false;

	//-- prevent continuous firing while holding down menu key
	if (A3C_RadialMenu_KEY_ID select 0 == _key) exitWith {};
	if (_key in A3C_UI_DOWNKEYS) exitWith {};
	
	[_key] call A3C_UI_Shared_FNC_AddDownkey;

	player groupchat format ["[RADIAL] onKeyDown , %1 (%2)", _key, keyname _key];

	//-- Safety: clear A3C_UI_DOWNKEYS - not used in radial
	
	if ([_key,_mods] isEqualTo ((["A3C", "A3C_KeyFnc_Switch_CommandLevel"] call CBA_fnc_getKeybind) select 5)) exitWith {
		["COMMAND_LEVEL","DOWN"] call A3C_FNC_CBA_KEY;
		false
	};
	if (_key -- 16) then {
		_bool = [0] call A3C_UI_RADIAL_CTRLS_QUICKTOGGLE;
	};
	_bool
};


// NOTE: previously A3C_UI_RADIAL_EH_KEYUP_CANCEL (Remove this comment when cleaned up)
A3C_UI_RADIAL_HandlerFNC_OnKeyUp = {
	params ["_display", "_key"];

	player globalchat format ["[RADIAL] onKeyUp , %1 (%2)", _key, keyname _key];

	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [_key];

	if (_key == (A3C_RadialMenu_KEY_ID select 0)) exitWith {
		[] call A3C_RADIAL_CloseDisplay;
		// A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];
		showCommandingMenu "";
		A3C_DISABLE_RADIAL = false;
		if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
			A3C_RD_UNITS = [];
		};
		if ((count A3C_HUD_UnitIndicators) > 0) then {
			{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];
		} else {
			{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
		};
		//-- security: remove any possible extra Radial-ActionEH's
		if (!isNil 'A3C_UI_RADIAL_EH_KEYUP_CONFIRM') then {
			(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
		};
	};

	if (_key == 16) then {
		[1] call A3C_UI_RADIAL_CTRLS_QUICKTOGGLE
	};
};
		


//
// NOTE: previously A3C_RAD_DEVH_MD (Remove this comment when cleaned up)

A3C_UI_RADIAL_HandlerFNC_OnMouseButtonDown = {
	params ["_display","_button","_sX","_sY","_shift","_ctrl","_alt"];

	_ins = lineIntersectsSurfaces
	[
		AGLToASL positionCameraToWorld [0,0,0],
		ATLToASL screenToWorld [_sx,_sy],
		cameraOn,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];

	_clickedVehicle = objnull;
	if (count _ins > 0) then {
		_clickedVehicle = (_ins select 0) select 2;
	};



	if ({ _ctrl = finddisplay 100040 displayctrl _x; ctrlShown _ctrl && {[[_sX,_sY],_ctrl] call MCSS_fnc_isClickPosInCTRLArea}} count A3C_RADIAL_GAMEUI_AllButtonAreas > 0) exitWith {};

	_unitDetected = false;
	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {

		
		_hcAll = A3C_HC_getAllGroups_Player_Current;
		private _group = grpNull;
		private _refGroup = group driver _clickedVehicle;
		if (_refGroup in _hcAll) then {
			_group = _refGroup;
		} else {
			_groupIconsAtClickPos = [[_sX,_sY]] call A3C_UI_RADIAL_iconsAtClickPos;
			//systemchat str  _groupIconsAtClickPos;
			if (count _groupIconsAtClickPos > 0) then {
				_clickedGroupIcon = _groupIconsAtClickPos select 0;
				//_clickedGroupIcon params ["_group","_sizeArray","_iconPos"];
				_group = _clickedGroupIcon select 0;

			};	
		};
		if (!isNull _group) then {
			_unitDetected = true;
			if (_button == 1) then {
				if (_group in A3C_RD_UNITS) then {
					A3C_RD_UNITS = A3C_RD_UNITS - [_group];
				} else {
					A3C_RD_UNITS pushBackUnique _group;
				};
			} else {
				A3C_RD_UNITS = [_group];
			};

			_ind = [_group,_hcAll] call MCSS_fnc_GetArrayIndex;
			A3C_BUTTONPAGE_TABLET = (ceil ((_ind + 1) / 18)) - 1;
			//[] call A3C_RD_LABEL_SELECTORS;
			
			if (count A3C_RD_UNITS == 0) then {
				(findDisplay 100040 displayCtrl 8005) ctrlSetText "SELECT UNIT";

			} else {
				if (count A3C_RD_UNITS == 1) then {
					(findDisplay 100040 displayCtrl 8005) ctrlSetText (groupID (A3C_RD_UNITS select 0));
				} else {
					(findDisplay 100040 displayCtrl 8005) ctrlSetText "MULTIPLE GROUPS";
				};

			};
			//["ROE",-1,false,false] call A3C_RADIAL_BTN_FNC_RING_INNER;
			A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_RD_UNITS;
			[] call A3C_UNITSEL_REFRESH_UI;
			[] call A3C_Radial_DashBoard;
		};
		
	} else {
		_refUnit = driver _clickedVehicle;
		if (_refUnit in units player) then {
			_unitDetected = true;
			if (_button == 1) then {
				if (_refUnit in A3C_RD_UNITS) then {
					A3C_RD_UNITS = A3C_RD_UNITS - [_refUnit];
				} else {
					A3C_RD_UNITS pushBackUnique _refUnit;
				};
			} else {
				A3C_RD_UNITS = [_refUnit];
			};
			[] call A3C_UNITSEL_REFRESH_UI;
		};
		A3C_RD_UNITS = A3C_RD_UNITS select {!isPlayer _x};
		//systemchat 'hm';
		[] spawn {
			for "_i" from 1 to 2 do {
				//sleep (0.1 * _i);
				sleep 0.1;
				{
					if (_x in A3C_RD_UNITS) then {
						player groupSelectUnit [_x,true];
					} else {
						player groupSelectUnit [_x,false];
					};
				} foreach (units player - [player]);
			};
		};
	};

	if (_unitDetected) then {
		
		_CT_TREE = findDisplay 100040 displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
		_CT_TREE tvSetCurSel [-1];
		if (count A3C_RD_UNITS == 1) then {
			
			_button = (A3C_RD_UNITS select 0) getVariable ["A3C_TREESEL_INDEX",[]];
			_button = _button select ((count _button) -1);
			//systemchat str _button;
			_CT_TREE tvSetCurSel _button;
		};
	};
};
