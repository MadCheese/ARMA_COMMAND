
params ["_data","_cursorObjectSelection"];


if (isNil 'A3C_is_Initialized') exitWith {
	hint "ARMA COMMAND IS INITIALIZING - STAND BY";
	waituntil {!isNil 'A3C_is_Initialized'};
	hint "ARMA COMMAND INITIALIZED";
	sleep 3;
	hint "";
};


//if (visiblemap) exitWith {};
if  (!isnull (findDisplay 602)) exitwith {};
if  (!isnull (finddisplay 100020)) exitwith {};
if  (!isnull (finddisplay 100030)) exitwith {};
if  (!isnull (finddisplay 100040)) exitwith {};
if  (!isnull (findDisplay 100010)) exitwith {};
if  (!isnull (finddisplay 100050)) exitwith {};






if (A3C_DISABLE_RADIAL) exitwith {};
_exit = false;
if !(player == (leader group player)) then {
	_exit = true;

	if ([player] call A3C_isUnconscious) then {
		if (player == (units group player select 0)) then {
			_exit = false;
		};
	};

};
if (_exit) exitwith {};

//-- security: remove any possible extra Radial-ActionEH's
if (!isNil 'A3C_UI_RADIAL_EH_KEYUP_CONFIRM') then {
	(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
};

//if (!isNil 'A3C_UI_RADIAL_EH_KEYUP_CANCEL') then {
//	(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
//};





_hcAll = A3C_HC_getAllGroups_Player_Current;

_cursortarget = cursortarget;





[] spawn {
	_timer = time;
	while {time < _timer + 0.7} do {
		showUAVFeed false;
	};
};


A3C_RADIAL_HOVER = true;
A3C_DISABLE_RADIAL = false;
A3C_RD_BOOL_UNITS = true;
A3C_BOOL_CTBUILD = false;
A3C_RADIALMODE = "";
A3C_TURRETS = [];

A3C_ACTIVE_BUTTONUNIT = if ((count groupselectedUnits player) > 0) then {groupSelectedunits player select 0} else {objnull};

_exit = false;
if ((currentweapon player) == (secondaryweapon player)) then {
	//if (cameraView == "GUNNER") then {
		if ((getNumber (configfile >> "CfgWeapons" >> (secondaryWeapon player) >> "canLock")) == 2) then {
			if !(isNull _cursortarget) then {
				if !(_cursortarget isKindOf "MAN") then {
					_exit = true;
				};
			};
		};
	//};
};
if ( !isNull(findDisplay 312) ) exitWith {}; //-- ZEUS interface is open. Prevent most A3C stuff
if (_exit) exitWith {};

if !(isnil "A3C_GRENADEHANDLER") then {
	(findDisplay 46) displayRemoveEventHandler ["MouseButtonUP",A3C_GRENADEHANDLER];
};
if !(isnil "A3C_GRENADEHANDLER_1") then {
	(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_GRENADEHANDLER_1];
};
private _selectAll = false;







_btn = _data select 1;
_shift = _data select 2;
_ctrl = _data select 3;
_alt = _data select 4;

A3C_RADIAL_VAL = 0;

A3C_RadialMenu_KEY_ID = [_btn,_shift,_ctrl,_alt];
BV_GREN = 0;
BV_ACT = 0;
BV_ROE = 0;
BV_BRAIN = 0;
BV_FORM = 0;
BV_STANCES = 0;
BV_ITEMS = 0;
BV_VEHS = 0;
BV_MEDICAL = 0;
BV_LB1 = 6;
BV_LB1 = 8;
A3C_TARGETVEH = objnull;

//{
//	if (isnull objectparent _x) then {
//		if  ( (count(assignedvehiclerole _x)) > 0) then {
//			//if ( (_x distance2d (assignedVehicle _x)) > 30) then {
//				unassignvehicle _x;
//			//};
//		};
//	};
//} foreach ((units group player) - [player]);

//sleep 0.3;


//if !(15 in A3C_UI_DOWNKEYS) exitWith {systemchat 'dafuq'};


if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	if ((count (groupSelectedUnits player)) == 0) then {
		{player groupSelectUnit [_x, true]} forEach (units group player) - [player];
		_selectAll = true;
	};

	A3C_RD_UNITS = (groupSelectedUnits player);
	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x,false];
		};

	} foreach A3C_RD_UNITS;
};


with uiNameSpace do {
	A3C_RADIAL = (finddisplay 46) createDisplay "A3C_MENU";
};

if (_cursorObjectSelection) then {
	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [29];
};

{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];


//




//-- set Menu Color according to dayTime
//for "_i" from 8000 to 8004 do {
//	if (sunormoon < 1) then {
//		((findDisplay 100040) displayCtrl _i) ctrlSetTextColor [0,0.5,0.8,0.6];
//	} else {
//		((findDisplay 100040) displayCtrl _i) ctrlSetTextColor [0,0,0,0.9];
//	};
//};
["RADIAL"] call A3C_GET_UI_BG_COLOR;

for "_i" from 10008 to 10039 do {
	((findDisplay 100040) displayCtrl _i) ctrlShow false;
};


((findDisplay 100040) displayCtrl 8005) ctrlSetText (toUpper (groupId (group player)));
{
	((findDisplay 100040) displayCtrl _x) ctrlShow false
} foreach [8054,8055,8067,8068,8071,8095,8096];



A3C_BUTTONPAGE_TABLET = 0;





//-- detect context and label menu

_referenceArray = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {profileNamespace getvariable "A3C_GROUPUNITS"} else {_hcAll};

if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then { //-- this has to happen before inner ring is labeled
	if !(isnull _cursortarget) then {
		if (group (driver _cursortarget) in _hcAll && {_cursorObjectSelection}) then {
			A3C_RD_UNITS = [group driver _cursortarget];
		};
	};
	if (count A3C_RD_UNITS > 0) then {
		 _ind = [A3C_RD_UNITS select 0,_referenceArray] call MCSS_fnc_GetArrayIndex;
		A3C_BUTTONPAGE_TABLET = (ceil ((_ind + 1) / 18)) - 1;
	};
};

[A3C_CURRENT_COMMAND_LEVEL] call A3C_UI_RADIAL_LABEL_INNER_RING; //-- label inner ring (SQUAD or HC)



if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then { //-- this has to happen after inner ring is labeled
	if !(isnull _cursortarget) then {

		if ( (gunner _cursortarget) in (units player) && {({_cursortarget iskindof _x} count ["STATICWEAPON","MAN"]) > 0}) then {
			//if (_cursortarget iskindof "MAN" OR {_cursortarget iskindof "STATICWEAPON"}) then { //~~ does this not repeat the above?
				//if (_selectAll) then {
					
					if (_cursorObjectSelection) then {

						_gunner = gunner _cursortarget;
						//if (_gunner in units player) then {
							A3C_RD_UNITS = [_gunner];

							_ind = [_gunner,_referenceArray] call MCSS_fnc_GetArrayIndex;
							A3C_BUTTONPAGE_TABLET = (ceil ((_ind + 1) / 18)) - 1;

							{
								if (_x == _gunner) then {
									player groupSelectUnit [_x, true];
								} else {
									player groupSelectUnit [_x, false];
								};
							} foreach (units player - [player]);
						//} then {
						//	A3C_RD_UNITS = (units player - [player]);
						//	{
						//		player groupSelectUnit [_x, true];
						//	} foreach A3C_RD_UNITS;
						//};
						
					};
				//};

			//};

			["ACTIONS",-1] call A3C_RADIAL_BTN_FNC_RING_INNER;

		} else {

			if (side _cursortarget in [side player,civilian]) then {
				if (_cursorObjectSelection) then {
					{
						if (_cursortarget isKindOf _x) exitWith {
							//A3C_VEHSAV = [_cursortarget];
							["VEHICLES",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
							A3C_RADIAL_VEH_KIND = _x;
							[A3C_RD_UNITS] call A3C_FINDVEHS;

						};
					} foreach ["CAR","TANK","HELICOPTER","PLANE","SHIP","STATICWEAPON"];
				};




				/*
				_driver = driver _cursortarget;
				if (_cursorObjectSelection) then {
					if ((_driver) in units player) then {
						A3C_RD_UNITS = [_driver];
						{
							if (_x == _driver) then {
								player groupSelectUnit [_x, true];
							} else {
								player groupSelectUnit [_x, false];
							};
						} foreach (units player - [player]);
					};
				} else {
					{
						if (_cursortarget isKindOf _x) exitWith {
							//A3C_VEHSAV = [_cursortarget];
							["VEHICLES",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
							A3C_RADIAL_VEH_KIND = _x;
							[A3C_RD_UNITS] call A3C_FINDVEHS;

						};
					} foreach ["CAR","TANK","HELICOPTER","PLANE","SHIP"];
				};
				*/

			};
		};


	};
};





if (_cursorObjectSelection && {!isNull _cursorTarget && {side _cursorTarget in [side player, civilian] && {count (fullcrew [_cursorTarget,"",true]) > 0}}}) then {
	private _GUI_GRID_W = 0.025;
	private _GUI_GRID_H = 0.04;
	private _vehicleSeatData = (fullcrew [_cursorTarget,"",true]);	
	private _btnH = if (count _vehicleSeatData > 15) then {1} else {2}; //-- 15 seats is threshold instead of 20 because we need the last row for 'board all'
	private _btnW = _btnH * 1.25;	
	_btnW = _btnW * _GUI_GRID_W;
	_btnH = _btnH * _GUI_GRID_H;
	private _mouseX =  (35.5 * _GUI_GRID_W ) + (_btnW / 2);
	private _mouseY = (11.5 * _GUI_GRID_H) + (_btnH / 2);
	[_mouseX,_mouseY] spawn {
		sleep 0.1;
		setMousePosition _this
	};
} else {
	setMousePosition [0.5,0.5];
};








//if (profileNameSpace getVariable "A3C_NUM_VAR") then {
//	((findDisplay 100040) displayCtrl 8027) ctrlSetTextColor [0,1,0,0.6];
//} else {
//	((findDisplay 100040) displayCtrl 8027) ctrlSetTextColor [1,0,0,0.6];
//};

