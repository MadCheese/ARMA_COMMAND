

//------------------------------------------------  G T I  G R E N A D E S   --------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------
//----------------------------------    written by ZAPAT, used and adjusted with permission      ------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------




//---------------------------  ADDITIONAL FUNCTIONS  ----------------------------
//--------- written by Mad_Cheese for GTI-implementation within A3C  -------------

A3C_Detect_Throw = {
	private ["_unit","_mags"];
	_unit = _this select 0;
	_mags = [];
	{
		if (_x call BIS_fnc_isThrowable) then {
			_mags pushBackUnique _x;
		};
	} foreach (magazines _unit);
	_mags
};

//-- Function adapted from ZAPAT: Get Grenade Velocity
A3C_THROW_VEL = {
	params ["_unit","_targetpos"];
	private _maxdist = if ((count _this) > 2) then {_this select 2} else {30};
	private _mode = if ((count _this) > 3) then {_this select 3} else {0};
	private _alpha = 45;
	private _range = _targetpos distance _unit;

	if (_maxDist == 300) then {
		_alpha = 20;
		if (_range > 80) then {_alpha = 30};
		if (_range > 150) then {_alpha = 45};
	};

	if (_range > _maxDist) then {_range = _maxdist};
	private _v0 = sqrt(_range * 9.81 / sin (2 * _alpha));
	private _v0x = cos _alpha * _v0;
	private _v0z = sin _alpha * _v0;
	private _throwDir = [_unit,_targetpos] call BIS_fnc_dirTo;
	private _flyDirSin = sin _throwDir;
	private _flyDirCos = cos _throwDir;
	private _vel = [_flyDirSin * _v0x,_flyDirCos * _v0x, _v0z];
	_vel
};

if (isDedicated) exitWith {};


BR_A3C_TACV_GV0MaxS = 19;		//standing
BR_A3C_TACV_fatEff	= 0.4;	//max - fatEff*max when fat = 1
BR_A3C_TACV_GV0MaxP = 0.75;		//prone
BR_A3C_TACV_GV0MaxC = 0.9;		//crouch
A3C_DISABLE_RADIAL = false;
BR_A3C_TACV_throwTheta = 45;
BR_A3C_TACV_throwTheta_Add = 0;

BR_A3C_fn_relativePos =
{
	private ["_p1", "_dir","_dst","_r","_alt"];
	_p1 = _this select 0;
	_dir = _this select 1;
	_dst = _this select 2;

	_alt = 0;
	if (count _this > 3) then {_alt = _this select 3};

	_r = [(_p1 select 0) + sin _dir * _dst,(_p1 select 1) + cos _dir * _dst,_alt];

	_r
};



BR_A3C_OEFControl = {
	if (isnull A3C_GTI_UNIT) exitwith {};
	private _isPlayer = A3C_GTI_UNIT == player;
	private _screenToWorld = [0,0,0];
	if !(_isPlayer) then {
		A3C_DISABLE_RADIAL = true;
		_screenToWorld = screenToWorld [0.5,0.5];
	};


	//calculate needed v0
	_v0Max = 19; // _un getVariable ["BR_A3C_RPG_throwForce",BR_A3C_TACV_GV0MaxS];
	_v0Max = _v0Max - (getFatigue A3C_GTI_UNIT) * BR_A3C_TACV_fatEff * _v0Max;
	_ehATL = (ASLtoATL (eyepos A3C_GTI_UNIT)) select 2;
	if (_ehATL < 1.4) then {
		if  (_ehATL < 0.8) then {
			_v0Max = _v0Max * BR_A3C_TACV_GV0MaxP
		} else  {
			_v0Max = _v0Max * BR_A3C_TACV_GV0MaxC
		};
	};

	//
	_throwPos = [];
	private _refDir = (eyeDirection A3C_GTI_UNIT) select 2;
	if (_isPlayer && {cursorTarget isKindOf "HOUSE" && {!weaponlowered player OR {([_refDir,2] call BIS_fnc_cutDecimals) != 0}}}) then {
		_ins = lineIntersectsSurfaces
		[
			AGLToASL positionCameraToWorld [0,0,0],
			AGLToASL positionCameraToWorld [0,0,viewDistance],
			A3C_GTI_UNIT,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];
		//if (count _ins == 0) then {_screenToWorld} else {ASLtoATL (_ins select 0 select 0)};
		_throwPos = positionCameraToWorld [0,0,viewDistance];
		//_throwPos = positionCameraToWorld [0,0,viewDistance];
		//{str (atan ((eyeDirection player ) select 2))} spawn fhint
		
		_refDir = if ((abs _refDir) > 0.01) then {_refDir} else {(A3C_GTI_UNIT weapondirection (currentweapon A3C_GTI_UNIT)) select 2};
		_alpha = atan _refDir;
		_alpha = _alpha + 13;
		_alpha = _alpha max 0.01;
		//_beta = ((_alpha + 45) min 90) max 0;
		//systemchat str [_alpha,BR_A3C_TACV_throwTheta];
		BR_A3C_TACV_throwTheta = ((_alpha + BR_A3C_TACV_throwTheta_Add) max 0.01) min 89.9;
	} else {
		
		BR_A3C_TACV_throwTheta = ((45 + BR_A3C_TACV_throwTheta_Add) max 0.01) min 89.9;
		if (_screenToWorld distance2d cameraOn >= viewDistance) then {
			_throwPos = positionCameraToWorld [0,0,viewDistance];
		} else {
			_throwPos = _screenToWorld;
		};	
	};

	if (!(_isPlayer) && {A3C_GREN_ALLOW_UNITSWITCH}) then {
		private _suitableUnits = ((units player) - [player]) select {
			alive _x && {A3C_GREN_MUZZLE in (magazines _x)}
		};
		_suitableUnits =
		[
			_suitableUnits,
			[],
			{
				_x distance _screenToWorld
			},
			"ASCEND"
		] call BIS_fnc_sortBy;
		if (count _suitableUnits > 0) then {
			A3C_GTI_UNIT = _suitableUnits select 0; 
		};

	};


	//BR_A3C_TACV_throwTheta = BR_A3C_TACV_throwTheta * 1.3;
	_range = _throwPos distance A3C_GTI_UNIT;
	_v0 = sqrt(_range * 9.81 / sin (2 * BR_A3C_TACV_throwTheta));

	//maximalize v0 - recalc range
	if (_v0 > _v0Max) then {
		_v0 = _v0Max;
		_range = (_v0 ^ 2 * sin (2 * BR_A3C_TACV_throwTheta)) / 9.81;
	};

	//~~ CLEAN THIS UP! no need to check screenTW so much
	//data
	_v0x = cos BR_A3C_TACV_throwTheta * _v0;
	_v0z = sin BR_A3C_TACV_throwTheta * _v0;
	_modelPos = switch (stance A3C_GTI_UNIT) do {
		case ("STAND") : {[0.232422,0.803711,1.61945]};
		case ("CROUCH") : {[0.230469,0.808594,1.1555]};
		case ("PRONE") : {[0.314453,0.65332,0.926847]};
	};
	_unPos = A3C_GTI_UNIT modelToWorld _modelPos;
	//_unPos = [getPosATL A3C_GTI_UNIT, direction A3C_GTI_UNIT, 1] call BR_A3C_fn_relativePos;
	_unDir = getDir A3C_GTI_UNIT;
	_throwDir = [A3C_GTI_UNIT,_throwPos] call BIS_fnc_dirTo;
	_flyDirSin = sin _throwDir;
	_flyDirCos = cos _throwDir;
	_sPosx = _unPos select 0;
	_sPosy = _unPos select 1;
	_prevtrajATL = +_unPos; //[_sPosx,_sPosy,1.4];
	_prevSz = 0;
	_newtrajASL = [];
	_newtrajATL = [];
	_trayBase = (getPosASL A3C_GTI_UNIT) select 2;

	BR_A3C_TACV_throwVel = [_flyDirSin * _v0x,_flyDirCos * _v0x, _v0z];
	BR_A3C_TACV_throwV0 = _v0;






	//draw trajectory
	
	_lastSz = 0;
	for "_t" from 0.1 to 5 step 0.1 do {
		//_addH = if (_t != 0.1) then {1.4} else {0};
		_dx = _v0x * _t;
		_dy = _v0z * _t - 4.905 * _t ^ 2  +  1.4; //_addH;
		_newtrajASL = [_sPosx + _flyDirSin * _dx,_sPosy + _flyDirCos * _dx,_trayBase + _dy];
		_newtrajATL = ASLtoATL _newtrajASL;
		_cross = 0;
		if (_newtrajATL select 2 <= 0) then {
			_cross = 1
		} else {
			if (lineInterSects [ATLtoASL _prevtrajATL, _newtrajASL]) then {
				_cross = 2;
			};
		};
		_iDim = (((1 / ((getposATL player) distance _newtrajATL)) * 4) max 0.08) min 0.3;
		_iDim = _iDim * 3;
		_col = if (_cross == 0) then {[1,1,1,1]}else{if (_cross == 1) then {[0,1,0,1]} else {[1,0,0,1]};};
		if (_cross != 2 && lineInterSects [(eyepos player), _newtrajASL]) then {_col set [3,0.2]};
		
		if (A3C_GTI_UNIT != player OR {_cross == 0}) then {
			drawIcon3D ["\a3\ui_f\data\Map\Markers\Military\dot_ca.paa", _col,_newtrajATL, _iDim, _iDim, 0]; //, str _iDim,1, 0.025 * safezoneH, "PuristaLight"];
		};
		
		
		
		if (_cross > 0) exitWith {};
		_prevtrajATL = _newtrajATL;
		_prevSz = _iDim;
	};

	if (_isPlayer) then {
		
		//_dist = _throwPos distance player;
		//if (_dist > 30) then {
		//	_throwPos = player getPos [30,_throwDir];
		//};
		//_dist = _dist min 30;
		//private _sZ = linearConversion [0, 30, _dist, 2, 0.4, true];
		private _sZ = _prevSz * 1.5;
		_icon = if (A3C_WAIT_THROW_P in [0,-1]) then {
			gettext (configfile >> "CfgMagazines" >> (currentThrowable player) select 0 >> "picture")
		} else {
			format ["\a3\ui_f\data\IGUI\Cfg\HoldActions\progress\progress_%1_ca.paa", round ((1 - A3C_WAIT_THROW_P) * 20)];
		};
		drawIcon3D [_icon, [1,1,1,0.7],_newtrajATL, _sZ, _sZ, 0];

	};

	A3C_GTI_UNIT doWatch _newtrajATL;
	//if (BR_A3C_TACV_mode == 1) then {_un setDir _throwDir};

};




//-- Apply GTI-grenade to player. Triggered by CBA-keyBind
A3C_GRENADE_PLAYER = {
	_mode = _this select 0;
	if (!isNull objectParent player) exitwith {};
	if ( (count(currentThrowable player)) == 0 ) exitwith {};
	if ((lifeState player) in ["INJURED","INCAPACITATED"]) exitWith {};
	A3C_GTI_UNIT = player;
	if (_mode == "DOWN") then {
		//if (A3C_WAIT_THROW_P == 0) then {
			//private _reloadTime = getNumber (configFile >> "CfgWeapons" >> "Throw" >> ((currentThrowable player) select 1) >> "magazineReloadTime");
			 //[_reloadTime,1] call BIS_fnc_cutDecimals;
			
			BR_A3C_TACV_throwTheta = 45;
			BR_A3C_TACV_throwTheta_Add = 0;
			BR_A3C_TACV_oefId = ["BR_A3C_TACV_oefId", "onEachFrame", "BR_A3C_OEFControl"] call BIS_fnc_addStackedEventHandler;
			BR_A3C_GRENADEMODE = true;
			//player setWeaponReloadingTime [player, (currentThrowable player) select 1, 0];
			//if (count (groupSelectedUnits player) == 0) then {
				A3C_GRENADEHANDLER_P = (findDisplay 46) displayAddEventHandler
				[
					"MouseButtonDown",
					{
						if ((_this select 1) == 1) then {
							A3C_GTI_UNIT = objNull;
							BR_A3C_GRENADEMODE = false;
							(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",A3C_GRENADEHANDLER_P];
							["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
						};
					}
				];
			//};
		//};
	} else {
		if (BR_A3C_GRENADEMODE) then {
			["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
			(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown",A3C_GRENADEHANDLER_P];
			if (A3C_WAIT_THROW_P == 0) then {
				//systemChat str time;
				A3C_WAIT_THROW_P = 1;
				player forceWeaponFire [((currentThrowable player) select 1),((currentThrowable player) select 1)];
				[] spawn {
					sleep 2.5;
					if (player == A3C_GTI_UNIT && {!(BR_A3C_GRENADEMODE)}) then {
						A3C_WAIT_THROW_P = 0;
						A3C_GTI_UNIT = objNull;
					};
				};
				//((currentThrowable player) select 0) spawn {
				//	sleep 1;
				//	if (!isNull A3C_GTI_UNIT) then {
				//		systemchat str (!isNull A3C_GTI_UNIT);
				//		player removeEventHandler ["fired", BR_A3C_TEMP_gfeh];	
				//	} else {
						
				//	};
				//};
			};
		};
		//A3C_GTI_UNIT = objNull;
		BR_A3C_GRENADEMODE = false;
		//A3C_DISABLE_RADIAL = false;
	};
};


A3C_GREN_DATA = {
	private ["_mode","_unit","_mags","_units"];

	_mode = _this select 0; //--
	_doChange = if (count _this > 1) then {_this select 1} else {true};
	_unit = objnull;
	_mags = [];
	_units = if !(isnull (finddisplay 100040)) then {A3C_RD_UNITS} else {A3C_SELECTED_UNITS};
	_display = if (visibleMap) then {100020} else {100030};

	//{
	//	if ((vehicle _x) isKindOf "AIR") then {
	//		_units = _units - [_x];
	//	};
	//} foreach _units;
	//A3C_AI_GREN_ARRAY


	A3C_AI_GREN_ARRAY = [];

	{
		_u = _x;
		{
			if (_x call BIS_fnc_IsThrowable) then {
				A3C_AI_GREN_ARRAY pushbackUnique _x;
			};
		} foreach magazines _u;
	} foreach _units;


	//-- Re-Arrange to have combat grenades first
	{
		private ["_it"];
		_it = _x;
		if (({[_x,_it] call MCSS_fnc_isInString} count ["chem","_ir","Strobe"]) > 0) then {
			_mags pushbackunique _it;
			A3C_AI_GREN_ARRAY = A3C_AI_GREN_ARRAY - [_it];
		};
	} foreach A3C_AI_GREN_ARRAY;
	{A3C_AI_GREN_ARRAY pushbackunique _x} foreach _mags;
	_mags = 0;

	//systemchat str (A3C_GREN_MUZZLE);
	switch (_mode) do {
		case (0) : {
			//-- Select first throwable
			if ((count A3C_AI_GREN_ARRAY) > 0) then {
				A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
			} else {
				A3C_GREN_MUZZLE = "";
			};
		};
		case (1) : {
			//-- Called from WP-Action Button
			if (count A3C_AI_GREN_ARRAY > 0) then {
				if (A3C_GREN_MUZZLE ==  (A3C_AI_GREN_ARRAY select ((count A3C_AI_GREN_ARRAY) -1) )) then {
					//-- if current Muzzle is the last in Gren-Array, script selects first entry
					A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
				} else {
					//-- if current Muzzle is not the last in Gren Array, script selects next entry
					_newMuzzle = A3C_AI_GREN_ARRAY select (([A3C_GREN_MUZZLE,A3C_AI_GREN_ARRAY] call MCSS_fnc_GetArrayIndex) + 1);
					A3C_GREN_MUZZLE = _newMuzzle;
				};
			} else {
				A3C_GREN_MUZZLE = "";
			};
		};
		case (2) : {
			//-- define and assign non existant variable (used in A3C_RadialMenu_INIT.sqf)
			if (isnil "A3C_GREN_MUZZLE") then {A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;};
		};
		case (3) : {
			if (A3C_GREN_MUZZLE ==  (A3C_AI_GREN_ARRAY select ((count A3C_AI_GREN_ARRAY) -1) )) then {
				A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select 0;
			} else {
				A3C_GREN_MUZZLE = A3C_AI_GREN_ARRAY select (([A3C_GREN_MUZZLE,A3C_AI_GREN_ARRAY] call MCSS_fnc_GetArrayIndex) + 1);
			};
		};
	};

	if !(isnull (finddisplay 100040)) then {
		[A3C_GREN_MUZZLE,0,_doChange] call A3C_GREN_VISUAL;
	} else {
		(findDisplay _display displayCtrl 7064) ctrlSetTextColor [1,1,1,1];
		[A3C_GREN_MUZZLE,1,_doChange] call A3C_GREN_VISUAL;
	};

	if ((A3C_TEMP_ACTION select 0) == "GRENADE") then {
		A3C_TEMP_ACTION = ["GRENADE",A3C_GREN_MUZZLE];
	};
};

A3C_GREN_VISUAL = {
	params ["_muzzle","_mode"];
	//player commandchat str [_mode];

	//-- label parent button
	private _col = if (count A3C_AI_GREN_ARRAY == 0) then {[1,1,1,0.3]} else{[1,1,1,0.6]};
	(findDisplay 100040 displayCtrl 9015) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_grenade.paa";
	(findDisplay 100040 displayCtrl 9015) ctrlSetTextColor _col;
	(findDisplay 100040 displayCtrl 9016) ctrlSetToolTip "AI Grenades";


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
		//-- reset outer ring buttons
		for "_i" from 10008 to 10039 do {
			(findDisplay 100040 displayCtrl _i) ctrlShow false;
			if (_i % 2 == 0) then {
				(findDisplay 100040 displayCtrl _i) ctrlSetText "";
			} else {
				(findDisplay 100040 displayCtrl _i) ctrlSetTooltip "";
			};
		};

		_outerRingBackGroundIDs = ["PlaceHolder","Left","bottom","Right","Top"];

		//-- outer ring backgrounds
		for "_i" from 8001 to 8004 do {
			_ind = _i - 8000;

			if ( _ind <= ((ceil ((count A3C_AI_GREN_ARRAY) / 4) ) min 3)    ) then {
				(findDisplay 100040 displayCtrl _i) ctrlShow true; //-- outer circle backgroud shown
				(findDisplay 100040 displayCtrl _i) ctrlSetText (format ["A3C_CORE\ui\pictures\BG_Radial_OuterRing_%1.paa",_outerRingBackGroundIDs select _ind]);
			} else {
				(findDisplay 100040 displayCtrl _i) ctrlShow false; //-- outer circle backgroud hidden
			};
		};
		if (count A3C_AI_GREN_ARRAY == 0) exitWith {};
		//-- label buttons-images and fncs
		{
			_btnID = (10039 - (_foreachIndex * 2));
			_imgID = ((10039 - (_foreachIndex * 2)) - 1);
			_buttonitem = 16 - _foreachIndex;
			//systemchat str _btnID;
			_btnClicker = findDisplay 100040 displayCtrl _btnID;
			_btnImage = findDisplay 100040 displayCtrl _imgID;
			{_x ctrlShow true} foreach [_btnImage,_btnClicker];
			_btnImage ctrlSetText (gettext (configfile >> "CfgMagazines" >> _x >> "picture"));
			_btnClicker ctrlSetToolTip (gettext (configfile >> "CfgMagazines" >> _x >> "displayNameShort"));
			call compile format
			[
				"
					A3C_OUTER_RING_BTN_fnc_%1 =
					[
						[],
						{
							A3C_GREN_MUZZLE = '%2';
							[] spawn A3C_RadialMenu_GREN;
						}
					];
				",
				_buttonitem,
				_x
			];
		} foreach A3C_AI_GREN_ARRAY;
	};
};


A3C_GREN_VISUAL_1 = {
	params ["_muzzle","_mode","_doChange"];
systemchat 'visual';
	_display = if (visibleMap) then {100020} else {100030};
	if (A3C_MAP_CommandMode == "HC") exitWith {};
	if (_mode == 0) then {
		if (count A3C_AI_GREN_ARRAY > 0) then {
			((findDisplay 100040) displayCtrl 9015) ctrlSetText (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "picture"));
			((findDisplay 100040) displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlSetTooltip (format ["Hold LMB for %1, click RMB to change item", (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "displayNameShort"))]);
		} else {
			((findDisplay 100040) displayCtrl 9015) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_GrenMain.paa";
			((findDisplay 100040) displayCtrl 9016) ctrlSetTooltip "currently no items available";
		};
	} else {
		if (_doChange) then {
			if !(A3C_GREN_MUZZLE == "") then {
				((findDisplay 100040) displayCtrl 9016) ctrlSetTooltip (format ["LMB: activate/deactivate %1. Shift+LMB: activate suppressive fire", (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "displayNameShort"))]);
				(findDisplay _display displayCtrl 7064) ctrlsettext (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "picture"));
				(findDisplay _display displayCtrl 7065) ctrlSetToolTip ( "Throw " + (gettext (configfile >> "CfgMagazines" >> A3C_GREN_MUZZLE >> "displayNameShort")) + " || Hold SHIFT to cycle through grenade types");
				A3C_TEMP_ACTION = ["GRENADE",A3C_GREN_MUZZLE];
			} else {
				A3C_TEMP_ACTION = ["GRENADE",""];
				(findDisplay _display displayCtrl 7064) ctrlsettext "A3C_CORE\ui\pictures\icon_menu_smokeGrey.paa";
				(findDisplay _display displayCtrl 7065) ctrlSetToolTip "Throw Grenade: No items available || LMB: Switch Action Type";
			};
		};
	};
};

A3C_RadialMenu_GREN = {

	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") exitWith {};

	//if (_this select 1 == 1) exitwith {
	//	if (count A3C_AI_GREN_ARRAY > 1) then {
	//		[1] call A3C_GREN_DATA;
	//		sleep 0.1;
	//		{player groupSelectUnit [_x,true]} foreach A3C_RD_UNITS;
	//	};
	//};

	_unit = objnull;
	{
		if ( ( {A3C_GREN_MUZZLE == _x} count (magazines _x)) > 0) exitwith {
			_unit = _x;
			A3C_GTI_UNIT = _x;
		};
	} foreach A3C_RD_UNITS;
	if (isnull _unit) exitwith {};
	{[_x] call A3C_HUD_REMOVE_SELECTED} foreach A3C_HUD_UNITS;

	if (isnil "A3C_GREN_MUZZLE") exitwith {
		((findDisplay 100040) displayCtrl 9016) ctrlSetTooltip "currently no items available";
	};
	BR_A3C_TACV_throwTheta = 45;
	BR_A3C_TACV_throwTheta_Add = 0;
	A3C_GREN_ALLOW_UNITSWITCH = if (count A3C_RD_UNITS == 1) then {false} else {true};
	BR_A3C_TACV_oefId = ["BR_A3C_TACV_oefId", "onEachFrame", "BR_A3C_OEFControl"] call BIS_fnc_addStackedEventHandler;

	A3C_DISABLE_RADIAL = true;
	[] call A3C_RADIAL_CloseDisplay;
	[
		46,
		'SPACE',
		{count A3C_RD_UNITS > 0},
		{
			[] spawn {
				if (A3C_DISABLE_RADIAL) then {
					//A3C_DISABLE_RADIAL = false;
					BR_A3C_TEMP_gfeh = A3C_GTI_UNIT addEventHandler ["fired",
					{
						private _unit = _this select 0;
						_unit forceSpeed -1;
						if (_this select 1 == "THROW") then {
							(_this select 6) setVelocity BR_A3C_TACV_throwVel;
						};
						if ((side _unit) == WEST) then {
							[_unit] call A3C_Gren_Phrase;
						};
						_unit removeEventHandler ["fired", BR_A3C_TEMP_gfeh];
						_add = if (BR_A3C_TACV_throwV0 <= BR_A3C_TACV_GV0MaxS) then {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd} else {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd * 2};
						_unit setFatigue ((getFatigue _unit) + _add);
						A3C_GREN_MUZZLE = "";
					}];
					_mz = ([A3C_GREN_MUZZLE] call MCSS_fnc_GetMuzzle);
					A3C_GTI_UNIT forceSpeed 0;
					sleep 0.5;
					A3C_GTI_UNIT forceWeaponFire [_mz,_mz];
					["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
					A3C_GTI_UNIT = objnull;
					A3C_AI_GREN_ARRAY = [];

				};
			};

		},
		{
			(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
		},
		false
	] call A3C_UI_RADIAL_ADD_EH_MACROS;

	[
		46,
		'RADIAL',
		{true},
		{},
		{
			if (A3C_DISABLE_RADIAL) then {
				(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
				A3C_DISABLE_RADIAL = false;
				["BR_A3C_TACV_oefId", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
				A3C_GTI_UNIT = objnull;
				A3C_AI_GREN_ARRAY = [];
			};
			(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];

		},
		true
	] call A3C_UI_RADIAL_ADD_EH_MACROS;
	A3C_UI_HUD_3D_TAG_reposition = true;
	showCommandingMenu "";
};

A3C_Gren_Phrase = {
	_unit = _this select 0;
	_muzzle = if (count _this > 1) then {_this select 1} else {A3C_GREN_MUZZLE};
	A3C_GRENPHR = "A3C_FireInTheHole";
	_chat = "Fire In The Hole";
	if !(_muzzle == "") then {
		_am = (getText (configfile >> "CfgMagazines" >> _muzzle >> "ammo"));
		_exp = (getNumber (configfile >> "CfgAmmo" >> _am >> "explosive"));
		if (_exp > 0) then {
			A3C_GRENPHR = "A3C_ThrowingFrag";
			_chat = "Throwing Frag";
		} else {
			if ((getnumber (configfile >> "CfgAmmo" >> _am >> "aiAmmoUsageFlags")) == 6) then {
				A3C_GRENPHR = "A3C_ThrowingSmoke";
				_chat = "Throwing Smoke";
			};
		};
	};
	//_unit say A3C_GRENPHR;
	_unit groupChat _chat;
};