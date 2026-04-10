
if (isDedicated) exitwith {};
if (is3den) exitwith {};
waituntil {alive player};

if (isNil 'A3C_CLIENT_IDS') then {
	//-- client / A3C is not running on server - keep variable local (var would be defined on hosting client or dedi)
	A3C_CLIENT_IDS = [];
} else {
	//-- client is hosting or SP (isDedicated was exited above)
	A3C_CLIENT_IDS pushBackUnique (getPlayerUID player);
	publicVariable 'A3C_CLIENT_IDS';
};

//-- assign necessary data and variables to all units



//--------------------  S H A R E D   V A L U E S   A N D   A R R A Y S  ----------------------------
//---------------------------------------------------------------------------------------------------
A3C_UNITCOUNTER = (count (units group player));


//------------------------- D I A L O G  T R I G G E R S ---------------------------------------
//----------------------------------------------------------------------------------------------

//-- create local trigger to detect changes in difficulty / change Mapdata opacity
A3C_HUD_DIFTRIG=createTrigger["EmptyDetector",[0,0,0],false]; A3C_HUD_DIFTRIG setTriggerArea [0,0,0,false];
A3C_HUD_DIFTRIG setTriggerActivation["Any","PRESENT",true];
A3C_HUD_DIFTRIG setTriggerStatements["A3C_DIFFICULTY != difficulty", "[] spawn {sleep 0.03; [] call A3C_RESETDIFFICULTY}", ""];

[] spawn {
	sleep 10;
	setGroupIconsVisible [false,false]; //-- hide any other use of groupIcons 
};


//------------------------Main Eventhandler-----------------------------------------------------
//----------------------------------------------------------------------------------------------

A3C_WAIT_THROW_P = 0;
A3C_FIRED_EVH = {
	params ["_unit", "_weapon", "_muzzl", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	
	if (_weapon == "THROW") exitWith {
		


		if (A3C_GTI_UNIT == _unit) then {
			[player,_magazine] call A3C_Gren_Phrase;
			(_this select 6) setVelocity BR_A3C_TACV_throwVel;
			//_add = if (BR_A3C_TACV_throwV0 <= BR_A3C_TACV_GV0MaxS) then {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd} else {BR_A3C_TACV_throwV0 * BR_A3C_TACV_fatAdd * 2};
			//_unit setFatigue ((getFatigue _unit) + _add);
			A3C_GTI_UNIT = objNull;
		};

		private _reloadTime = getNumber (configFile >> "CfgWeapons" >> "Throw" >> _muzzl >> "magazineReloadTime");
		_A3C_WAIT_THROW_P = [_reloadTime,1] call BIS_fnc_cutDecimals;
		for "_i" from 0 to _reloadTime step 0.1 do {
			A3C_WAIT_THROW_P = if (_A3C_WAIT_THROW_P == 0) then {0} else {
				[(_A3C_WAIT_THROW_P - _i) / _A3C_WAIT_THROW_P,1] call BIS_fnc_cutDecimals;
			};
			sleep 0.1;
		};
		A3C_WAIT_THROW_P = 0;	
	};
};

A3C_SlotItemChanged_HandlerFnc = {
	params ["_unit", "_name", "_slot", "_assigned"];
	if (_slot != 612) exitWith {}; 
	private _notGPS = _name != "A3C_Terminal_NoUAV";
	// systemchat str _notGPS;
	player enableInfoPanelComponent ["left", "MinimapDisplayComponent", _notGPS];
	player enableInfoPanelComponent ["right", "MinimapDisplayComponent", _notGPS];
};


A3C_KILLED_EVH = { //-- only used by player
	_body = _this select 0;
	_groupUnits = (profileNamespace getvariable "A3C_GROUPUNITS");
	if ((count A3C_HUD_ARROWS) > 0) then {
		{[_x] call A3C_HUD_REMOVE_SELECTED} foreach A3C_HUD_UNITS ;
	};

	A3C_SELECTED_UNITS = [];

	[] call A3C_Btn_fnc_Cancel;
	{_x setvariable ["A3C_PLOT_TEMP",[],true];} foreach _groupUnits;


	_gpShuffleUnits = [];
	if !(_body == A3C_ZEUS_UNIT) exitwith {
		selectplayer A3C_ZEUS_UNIT;
	};
	_body removeEventHandler ["KILLED", A3C_KILLED];	//-- remove EH so that it won't be stacked later
	_body removeEventHandler ["FIRED",A3C_FIRED]; 
	_body removeEventHandler ["SlotItemChanged", A3C_SlotItemChanged_Handler]; 
	// if (isClass(configFile >> "CfgPatches" >> "mavik_Data")) then {
	// 	private _id = player getVariable ["DB_playerPutID", -1];
	// 	if (_id != -1) then { player removeEventHandler ["Put", _id] };
	// };
	waituntil {alive player};
	// if (isClass(configFile >> "CfgPatches" >> "mavik_Data")) then {
	// 	private _id = player addEventHandler ["Put", { _this call mavic_fnc_createMavicOnItemCheck }];
	// 	player setVariable ["DB_playerPutID", _id];
	// };
	if !(player == _body) then {
		if (player in _groupUnits) then {
			//player sidechat "group respawn";
			_groupUnits set [0,player];
			if !(player == (leader group player)) then {
					_gpShuffleUnits = ((units group player) - [player]);
					{[_x] join grpnull} foreach _gpShuffleUnits;
					{[_x] joinSilent (group player)} foreach _gpShuffleUnits;
					_groupUnits = (units group player);
			};

			profileNamespace setvariable ["A3C_GROUPUNITS",_groupUnits];

		} else {
			//player sidechat "spawned as new unit";
			_groupUnits set [0,player];
			if !(player == (leader group player)) then {
				if !(isPlayer (leader group player)) then {
					if (isMultiPlayer) then {
						(group player) selectLeader player;
					};
				};
			};
			profileNamespace setvariable ["A3C_GROUPUNITS",_groupUnits];

		};


		A3C_KILLED = player addEventHandler ["KILLED",{[_this select 0] spawn A3C_KILLED_EVH}];
		A3C_FIRED = player addEventHandler ["FIRED",{_this spawn A3C_FIRED_EVH}];
		A3C_SlotItemChanged_Handler = player addEventHandler ["SlotItemChanged",{_this spawn A3C_SlotItemChanged_HandlerFnc}];
	} else {
		//player sidechat "spawned as same unit";
	};
	//-- Detect if player is connected to Zeus module
	A3C_ZEUS_UNIT = player;
	{
		if ((typeOf _x) == "ModuleCurator_F") then {
			A3C_ZEUS_UNIT = player;
			publicvariable "A3C_ZEUS_UNIT";
			[player,_x] execFSM "A3C_CORE\FSM\A3C_ZEUS.fsm";
		};
	} foreach (synchronizedObjects player);
	sleep 0.5;
	if (player == (leader group player)) then {
		[(units group player) - [player]] call A3C_GROUP_RESET;

	};

};
A3C_KILLED = player addEventHandler ["KILLED",{[_this select 0] spawn A3C_KILLED_EVH}];
A3C_FIRED = player addEventHandler ["FIRED",{_this spawn A3C_FIRED_EVH}];
A3C_SlotItemChanged_Handler = player addEventHandler ["SlotItemChanged",{_this spawn A3C_SlotItemChanged_HandlerFnc}];

if ("A3C_Terminal_NoUAV" in ((items player) + (assignedItems player))) then {
	player enableInfoPanelComponent ["left", "MinimapDisplayComponent", false];
	player enableInfoPanelComponent ["right", "MinimapDisplayComponent", false];
};


{
	_x setvariable ["A3C_HUD_DATA",[],true];
	player groupSelectUnit [_x, false];
} foreach units group player;
A3C_ZEUS_UNIT = player;
//-- Detect if player is connected to Zeus module
{
	if ((typeOf _x) == "ModuleCurator_F") then {
		A3C_ZEUS_UNIT = player;
		publicvariable "A3C_ZEUS_UNIT";
		[player,_x] execFSM "A3C_CORE\FSM\A3C_ZEUS.fsm";

	};
} foreach (synchronizedObjects player);
[player] execFSM "A3C_CORE\FSM\A3C_MON_PlayerGroup.fsm";



if (profileNameSpace getVariable "A3C_AUTOMEDIC") then {
	[] spawn {
		sleep 4;
		[] spawn A3C_HEAL_AUTOLOOP;
	};
};

sleep 2;
//systemchat 'now';
{[_x] call A3C_UNIT_INIT} foreach (units group player);
{_x setvariable ["A3C_FORMATION_INDEX", [_x] call A3C_GETUNITINDEX, true]} foreach units group player;
(findDisplay 6999 displayCtrl 7043) ctrlMapCursor ["Track","HC_overFriendly"]; // ~ ?
profileNamespace setvariable ["A3C_GROUPUNITS",(units group player)];
player setvariable ["A3C_FORMATION_INDEX", 1, true];



/*
NOTE - THIS IS A HUGE SHITTY MESS AND NEEDS A FULL OVERHAUL. CURRENT VERSION IS SIMPLY TO NOT BREAK ANYTHING - SHOULD BE OPTIMIZED INTO A SINGLE LOOP
*/


A3C_is_Initialized = true;

// // ATTEMPT AT AN OPTIMIZED LOOP
// 0 spawn {
// 	//-- mission init
// 	waitUntil {!isNull (findDisplay 46) && !isNull player};
// 	sleep 1;
// 	waituntil {alive player};
// 	sleep 0.1;
// 	A3C_HUD_DOWNKEYS = [];
// 	[] call A3C_ADD_KEYBINDS;
// 	A3C_LOADED_EVH = addMissionEventHandler ["Loaded",
// 	{
// 		//diag_log "loaded 1";
// 		[] spawn {
// 			waitUntil {!isNull (findDisplay 46) && !isNull player};
// 			sleep 1;
// 			waituntil {alive player};

// 			A3C_HUD_DOWNKEYS = [];
// 			[] call A3C_ADD_KEYBINDS;
// 			sleep 1;
// 			//diag_log "LOADED";
// 		};
// 	}];

// 	[] execVM "A3C_CORE\ui\tablet\A3C_MAPTAB_fnc_drawMapUI.sqf";
// 	[] execVM "A3C_CORE\ui\HUD\A3C_fnc_drawHudUI.sqf";

// 	//-- In game loop - once per second
	// while {!isNull player && {!isNull (findDisplay 46)}} do {
	// 	A3C_HCALLGROUPS_Current = [] call A3C_HCALLGROUPS;
	// 	sleep 1;
	// };

// 	[] call A3C_LEAVESERVER;
	
// };

0 spawn {
	waitUntil {!isNull (findDisplay 46) && !isNull player};
	sleep 1;
	//
	waituntil {alive player};
	sleep 0.1;
	while {!isNull player && {!isNull (findDisplay 46)}} do {
		A3C_HCALLGROUPS_Current = [] call A3C_HCALLGROUPS;
		sleep 1;
	};
};


// Runner
0 spawn
{
	_cycle = 1;
	while {true} do {
		//diag_log format ["runner %1-1",_cycle];
		waitUntil {!isNull (findDisplay 46) && !isNull player};
		sleep 1;
		//
		waituntil {alive player};
		sleep 0.1;
		//diag_log format ["runner %1-2",_cycle];
		_cycle = _cycle + 1;
		A3C_HUD_DOWNKEYS = [];
		[] call A3C_ADD_KEYBINDS;
		A3C_LOADED_EVH = addMissionEventHandler ["Loaded",
		{
			//diag_log "loaded 1";
			[] spawn {
				waitUntil {!isNull (findDisplay 46) && !isNull player};
				sleep 1;
				waituntil {alive player};

				A3C_HUD_DOWNKEYS = [];
				[] call A3C_ADD_KEYBINDS;
				sleep 1;
				//diag_log "LOADED";
			};
		}];

		[] execVM "A3C_CORE\ui\tablet\A3C_MAPTAB_fnc_drawMapUI.sqf";
		[] execVM "A3C_CORE\ui\HUD\A3C_fnc_drawHudUI.sqf";

		waitUntil {isNull (findDisplay 46)};
		//diag_log "ENDED1";
		waituntil {!alive player};
		//diag_log "ENDED 2";

		[] call A3C_LEAVESERVER;
	};

};

