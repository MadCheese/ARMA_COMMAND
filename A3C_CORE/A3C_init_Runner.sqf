
if (isDedicated) exitWith {};
if (is3den) exitWith {};

diag_log "[A3C]: Starting A3C Init Runner";

waituntil {alive player}; //-- might not be necessary because arc_init now handles this for client/host

diag_log "[A3C]: alive player true";

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
A3C_HUD_DIFTRIG setTriggerStatements["A3C_DIFFICULTY != difficulty", "[] spawn {sleep 0.03; [] call A3C_main_fnc_resetDifficulty}", ""];

[] spawn {
	sleep 10;
	setGroupIconsVisible [false,false]; //-- hide any other use of groupIcons 
};


//------------------------Main Eventhandler-----------------------------------------------------
//----------------------------------------------------------------------------------------------

A3C_WAIT_THROW_P = 0;



//-- register player eventhandlers: static CBA group/unitswitch monitors, as well as dynamic player handlers (killed/fired/slotItemChange)
[] call A3C_playerEventhandler_fnc_register;


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
		[] spawn A3C_ai_shared_fnc_medical_startAutoHeal;
	};
};


{[_x] call A3C_ai_squad_fnc_initializeUnit} foreach (units group player);
{_x setvariable ["A3C_FORMATION_INDEX", [_x] call A3C_main_fnc_getUnitIndex, true]} foreach units group player;

profileNamespace setvariable ["A3C_GROUPUNITS",(units group player)];
player setvariable ["A3C_FORMATION_INDEX", 1, true];



/*
NOTE - THIS IS A HUGE SHITTY MESS AND NEEDS A FULL OVERHAUL. CURRENT VERSION IS SIMPLY TO NOT BREAK ANYTHING - SHOULD BE OPTIMIZED INTO A SINGLE LOOP
*/


A3C_is_Initialized = true;

diag_log "[A3C]: Init Runner: A3C_is_Initialized set to true";

if (hasInterface) then {

	"A3C_INIT_IMAGE" cutFadeOut 0;

	"A3C_INIT_BLACK" cutText [
		"",
		"BLACK IN",
		2
	];
};
// // ATTEMPT AT AN OPTIMIZED LOOP
// 0 spawn {
// 	//-- mission init
// 	waitUntil {!isNull (findDisplay 46) && !isNull player};
// 	sleep 1;
// 	waituntil {alive player};
// 	sleep 0.1;
// 	A3C_UI_DOWNKEYS = [];
// 	[] call A3C_UI_FNC_ADD_KEYBINDS;
// 	A3C_LOADED_EVH = addMissionEventHandler ["Loaded",
// 	{
// 		//diag_log "[A3C]: loaded 1";
// 		[] spawn {
// 			waitUntil {!isNull (findDisplay 46) && !isNull player};
// 			sleep 1;
// 			waituntil {alive player};

// 			A3C_UI_DOWNKEYS = [];
// 			[] call A3C_UI_FNC_ADD_KEYBINDS;
// 			sleep 1;
// 			//diag_log "[A3C]: LOADED";
// 		};
// 	}];

// 	[] call A3C_ui_mapOverlay_fnc_refreshMapUiDrawHandler;;
// 	[] call A3C_UI_mainDisplay_fnc_refreshHudUiDrawHandler;

// 	//-- In game loop - once per second
	// while {!isNull player && {!isNull (findDisplay 46)}} do {
	// 	A3C_HC_allGroupsClient_Current = [] call A3C_main_fnc_getAllGroupsClient;
	// 	sleep 1;
	// };

// 	[] call A3C_main_fnc_leaveServer;
	
// };

0 spawn {
	waitUntil {!isNull (findDisplay 46) && !isNull player};
	sleep 1;
	//
	waituntil {alive player};
	sleep 0.1;
	while {!isNull player && {!isNull (findDisplay 46)}} do {
		
		//-- fetch all HC groups once per second so it does not fire on each frame in draw handler
		A3C_HC_allGroupsClient_Current = [] call A3C_main_fnc_getAllGroupsClient;

		//-- clean up completed wp's from A3C_Selection_MultiWaypoint
		if !(A3C_Selection_MultiWaypoint isEqualTo []) then {
			private _groupCache = createHashMap;
			private _newSelection = [];

			{
				private _grp = _x select 0;
				private _wpIndex = _x select 1;

				if (isNull _grp) then { continue };

				private _key = str _grp;
				private _cached = _groupCache getOrDefault [_key, []];

				if (_cached isEqualTo []) then {
					_cached = [
						currentWaypoint _grp,
						count (waypoints _grp)
					];
					_groupCache set [_key, _cached];
				};

				private _currentWp = _cached select 0;
				private _wpCount = _cached select 1;

				if (
					_wpIndex >= _currentWp &&
					_wpIndex < _wpCount
				) then {
					_newSelection pushBack _x;
				};
			} forEach A3C_Selection_MultiWaypoint;

			if !(_newSelection isEqualTo A3C_Selection_MultiWaypoint) then {
				A3C_Selection_MultiWaypoint = _newSelection;
			};
		};

		if
		(
			A3C_isPlayerLeader 
			&& {currentCommand player != ""}
			&& {player == driver (vehicle player)}
		) then
		{
			player commandFollow player;
		};

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
		A3C_UI_DOWNKEYS = [];
		[] call A3C_UI_FNC_ADD_KEYBINDS;
		A3C_LOADED_EVH = addMissionEventHandler ["Loaded",
		{
			//diag_log "[A3C]: loaded 1";
			[] spawn {
				waitUntil {!isNull (findDisplay 46) && !isNull player};
				sleep 1;
				waituntil {alive player};

				A3C_UI_DOWNKEYS = [];
				[] call A3C_UI_FNC_ADD_KEYBINDS;
				sleep 1;
				//diag_log "[A3C]: LOADED";
			};
		}];

		[] call A3C_ui_mapOverlay_fnc_refreshMapUiDrawHandler;;
		[] call A3C_UI_mainDisplay_fnc_refreshHudUiDrawHandler;

		waitUntil {isNull (findDisplay 46)};
		//diag_log "[A3C]: ENDED1";
		waituntil {!alive player};
		//diag_log "[A3C]: ENDED 2";

		[] call A3C_main_fnc_leaveServer;
	};

};


diag_log "[A3C]: FINISHED init_runner, async loops spawned";


