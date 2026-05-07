#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

params ["_lb"];

private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _doubleClick = false;
private _tickTime = time - A3C_LB_TICKTIME;

private _display = findDisplay _a3c_dsp;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

if ((_tickTime > 0.07) && {_tickTime < 0.3}) then {
	_doubleClick = true;
};

_doubleClick = true; // Preserved: current code forces selection handling regardless of click timing.
A3C_LB_TICKTIME = time;

if (_doubleClick) then {
	switch (A3C_SelectionPromptPanel_MODE) do {
		case ("DELETE") : {
			switch (_lb) do {
				case (0) : {
					{
						private _group = _x;

						if ({isPlayer _x} count (units _group) == 0) then {
							[_group] call A3C_DeleteGroup;
						} else {
							systemChat format ["A3C: Group %1 was not deleted. Players detected", groupID _group];
						};
					} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;

					A3C_SELECTED_HC_GROUPS_SETTINGS = [];
				};
			};

			_parent ctrlShow false;
			_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent ctrlShow false;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};
		};

		case ("CARGO_WAYPOINTS") : {
			switch (_lb) do {
				case (0) : {
					//-- YES: fetch cargo groups and prompt to place waypoints
					//-- save unit selection to reestablish later
					private _cargoGroups = ([A3C_HC_ACTIVEGROUP] call MCSS_fnc_getCargoGroups) select {
						private _groupRef = _x;
						(waypointPosition [_groupRef, currentWaypoint _groupRef]) distance2D [0,0,0] == 0
					};

					[_cargoGroups] spawn {
						params ["_cargoGroups"];

						private _storedSelection = +A3C_SELECTED_UNITS;
						private _storedMode = A3C_MAP_CommandMode;
						private _doExit = false;

						{
							private _groupRef = _x;

							A3C_MAP_CommandMode = "HC";
							A3C_SELECTED_HC_GROUPS_SETTINGS = [_groupRef];
							A3C_SELECTED_UNITS = [_groupRef];

							private _hintText = format ["PLACE WAYPOINT FOR %1  %2", groupID _groupRef, A3C_SELECTED_HC_GROUPS_SETTINGS];

							hint _hintText;
							waitUntil {
								hintSilent _hintText;
								!visibleMap || {
									(waypointPosition [_groupRef, currentWaypoint _groupRef]) distance2D [0,0,0] > 0
								}
							};

							if (!visibleMap) exitWith {
								systemChat "MAP CLOSED";
								_doExit = true;
								hintSilent "";
							};
						} forEach _cargoGroups;

						if !(_doExit) then {
							A3C_SELECTED_UNITS = _storedSelection; //-- only override if map was not closed
							A3C_SELECTED_HC_GROUPS_SETTINGS = _storedSelection; //-- only override if map was not closed
							A3C_MAP_CommandMode = _storedMode;

							hint "Done!";
							sleep 2;
							hintSilent "";
						};
					};
				};

				case (1) : {
					//-- NO: do nothing
				};
			};

			_parent ctrlShow false;
		};

		case ("SPEEDLIMIT") : {
			private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
			private _leaderVehicle = vehicle leader _group;

			private _speed = switch (_lb) do {
				case (0) : {1000};
				case (1) : {14};
				case (2) : {11};
				case (3) : {5};
			};

			[_leaderVehicle, _speed] remoteExec ["limitSpeed", _leaderVehicle];

			_parent ctrlShow false;
		};

		case ("CAS") : {
			private _casPos = +A3C_UI_HUD_3D_TAG_ICON_POS;
			private _lbText = _listBox lbText _lb;

			private _casModeNumeric = switch (_lbText) do {
				case ("GUN RUN") : {0};
				case ("MISSILES") : {1};
				case ("GUNS + MISSILES") : {2};
				case ("BOMBING RUN") : {3};
			};

			[A3C_UI_HUD_3D_TAG_ICON_POS, ""] spawn A3C_UI_HUD_3D_TAG;

			private _groups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

			_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent ctrlShow false;

			if (_groups isEqualTo []) exitWith {};

			player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];

			private _commsOperator = leader (_groups select 0);
			A3C_CUSTOMRADIO_ID radioChannelAdd [_commsOperator];
			_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];

			{
				private _group = _x;
				private _leaderVehicle = vehicle leader _group;
				private _isGroupOnFinalWP = currentWaypoint _group >= count waypoints _group;
				private _createReturnWP = _isGroupOnFinalWP && {_casPos distance2D _leaderVehicle > 50};
				private _landOnReturn = _createReturnWP && {!isEngineOn _leaderVehicle};
				private _wpIndex = currentWaypoint _group;

				private _wp = [
					_group,
					_casPos,
					[],
					"MOVE",
					[0,1000,"AUTO","AUTO",-1,"NONE"],
					false,
					_wpIndex + 1
				] call A3C_HC_ADD_WP;

				if (_createReturnWP) then {
					private _startPos = position _leaderVehicle;
					private _returnWP = _group addWaypoint [_startPos, 0];

					if (_landOnReturn) then {
						//-- land with default Arma mechanic upon return
						private _landingStatements = format [
							"
								[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
							",
							_startPos,
							getPlayerUID player
						];

						private _returnWPStatements = waypointStatements _returnWP;
						_returnWP setWaypointStatements [
							_returnWPStatements select 0,
							(_returnWPStatements select 1) + _landingStatements
						];
					};
				};

				private _statements = format [
					"
						[this,%1,%2,'%3'] remoteExec ['A3C_HC_distribute_CAS', this];
					",
					A3C_UI_HUD_3D_TAG_ICON_POS,
					_casModeNumeric,
					getPlayerUID player
				];

				private _wpStatements = waypointStatements _wp;
				_wp setWaypointStatements [
					_wpStatements select 0,
					(_wpStatements select 1) + _statements
				];
			} forEach _groups;
		};

		case ("MULTIWAYPOINT") : {
			A3C_MULTIWAYPOINT = if (_lb == 0) then {true} else {false};
			_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent ctrlShow false;
		};

		case ("DETONATE_SELECTED_CHARGE_SHARED") : {
			player customRadio [A3C_CUSTOMRADIO_ID, "SentCmdDetonate"];

			if (_listBox lbText _lb == "DETONATE ALL CHARGES") then {
				//-- detonate all charges at once

				[] spawn {
					sleep 1;

					{
						_x params ["_unit", "_charge"];

						private _explosives = _unit getVariable ["A3C_UNIT_EXPLOSIVES", []];

						//-- AI-Unit radio response
						A3C_CUSTOMRADIO_ID radioChannelAdd [_unit];
						_unit customRadio [A3C_CUSTOMRADIO_ID, "SentConfirmAttack"];

						sleep (1 + random 1.5);

						detach _charge; //-- detach is global
						sleep 0.1;

						_explosives = _explosives - [_charge];
						_unit setVariable [
							"A3C_UNIT_EXPLOSIVES",
							_explosives,
							if (isPlayer leader group _unit) then {false} else {true}
						];

						_charge setDamage 1;
					} forEach A3C_UI_RADIAL_Current_Remfire_Units;

					A3C_UI_RADIAL_Current_Remfire_Units = [];
				};
			} else {
				//-- detonate individual charge
				private _target = A3C_UI_RADIAL_Current_Remfire_Units select (_lb - 1);

				A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_target];

				_target spawn {
					params ["_unit", "_charge"];

					//-- AI-Unit radio response
					A3C_CUSTOMRADIO_ID radioChannelAdd [_unit];
					_unit customRadio [A3C_CUSTOMRADIO_ID, "SentConfirmAttack"];

					sleep 1;

					private _explosives = _unit getVariable ["A3C_UNIT_EXPLOSIVES", []];

					sleep (1 + random 1.5);

					detach _charge;
					sleep 0.1;

					_explosives = _explosives - [_charge];

					for "_i" from 1 to 10 do {
						_charge setDamage 1;
					};

					_unit setVariable [
						"A3C_UNIT_EXPLOSIVES",
						_explosives,
						if (isPlayer leader group _unit) then {false} else {true}
					];

					[] call A3C_UI_selectionPromptPanel_fnc_chargePromptRefresh;
				};
			};
		};

		case ("ARTY_0") : {
			A3C_SelectionPromptPanel_MODE = "ARTY_1";

			private _lbText = _listBox lbText _lb;

			A3C_HC_FOCUS_ARTY_AMMO_ARRAY = (getArtilleryAmmo MCSS_REMOTE_ARTILLERY_ARRAY) select {
				private _displayName = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
				_displayName == _lbText
			};

			lbClear _listBox;

			_text ctrlSetText "Select amount of shells";
			ctrlSetFocus _listBox;

			private _ammoAmount = 0;
			private _shellDisplays = ([true, true, A3C_HC_FOCUS_ARTY_POS] call A3C_getArtilleryAmmo) select {
				_x select 0 == _lbText
			};

			if !(_shellDisplays isEqualTo []) then {
				private _selectedShell = _shellDisplays select 0;
				_ammoAmount = (_selectedShell select 1) min 100;

				private _candidates = [1,2,3,4,8,10,20,30,40,50,75,100];
				private _lbEntries = [];

				{
					if (_x <= _ammoAmount) then {
						_lbEntries pushBack _x;
					};
				} forEach _candidates;

				// Always ensure the full available amount is the last option.
				if (_ammoAmount > 0 && {!(_ammoAmount in _lbEntries)}) then {
					_lbEntries pushBack _ammoAmount;
				};

				{
					[_listBox, str _x] call A3C_addLbEntry;
				} forEach _lbEntries;

				[_parent, _listBox, count _lbEntries] call A3C_OBJECTSEL_RESIZE;
			};
		};

		case ("ARTY_1") : {
			A3C_HC_FOCUS_ARTY_AmmoCount = call compile (_listBox lbText _lb);

			_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent ctrlShow false;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};

			[A3C_HC_FOCUS_ARTY_POS, false] spawn A3C_ORDER_ARTILLERY;
		};

		case ("CTRL_DET") : {
			private _chargeDisplayName = _listBox lbText _lb;
			private _chargeMagName = "";

			_parent ctrlShow false;

			(findDisplay 12 displayCtrl 51) ctrlEnable true;

			_parent spawn {
				//-- Preserved: repeated hiding appears to work around display/update timing after dropping on target vehicle.
				for "_i" from 1 to 10 do {
					_this ctrlShow false;
					sleep 0.1;
				};
			};

			{
				private _soldier = _x;

				{
					if (getText (configFile >> "CfgMagazines" >> _x >> "displayName") == _chargeDisplayName) exitWith {
						_chargeMagName = _x; //-- dirty workaround to retrieve classname from displayname. has to happen first so all units receive same data
					};
				} forEach magazines _soldier;
			} forEach A3C_SELECTED_UNITS;

			{
				private _soldier = _x;
				private _plotTemp = _soldier getVariable ["A3C_PLOT_TEMP", []];

				{
					private _mainMarkerID = format ["%1", parseText ((_x select 1) select 0)];
					private _wpAction = _x select 2;

					if (_mainMarkerID == A3C_MAP_CONNECTING_ID) exitWith {
						if (_wpAction select 0 == "CTRL_DET") then {
							(_wpAction select 1) set [1, _chargeMagName];
						};
					};
				} forEach _plotTemp;

				_soldier setVariable ["A3C_PLOT_TEMP", _plotTemp, true];
			} forEach A3C_SELECTED_UNITS;

			A3C_MAP_CONNECTING_ID = "";
		};

		case ("PARALOAD") : {
			private _vehicle = vehicle leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0);
			private _cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
			private _vehicleToLoad = _cargoObjects select _lb;

			[_vehicle, _vehicleToLoad] call A3C_LoadVehicleCargo;

			_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;

			lbClear _listBox;

			if (count _cargoObjects > 0) then {
				{
					private _lbText = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
					[_listBox, _lbText] call A3C_addLbEntry;
				} forEach _cargoObjects;
			} else {
				_parent ctrlShow false;
			};
		};

		case ("PARALOAD_SQ") : {
			private _vehicle = vehicle A3C_SQ_CLICKED_UNIT;
			private _cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
			private _vehicleToLoad = _cargoObjects select _lb;

			[_vehicle, _vehicleToLoad] call A3C_LoadVehicleCargo;

			_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;

			lbClear _listBox;

			if (count _cargoObjects > 0) then {
				{
					private _lbText = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
					[_listBox, _lbText] call A3C_addLbEntry;
				} forEach _cargoObjects;
			} else {
				_parent ctrlShow false;
			};
		};

		case ("flyInHeight") : {
			private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

			private _wpCurr = [_group, currentWaypoint _group];
			private _wpType = waypointType _wpCurr;
			private _wpPos = if (_wpType != "") then {
				waypointPosition _wpCurr
			} else {
				(getPosASL (vehicle leader _group) select [0, 2]) + [0]
			}; //-- avoid [0,0,0] clash

			//-- #FLYINHEIGHTASL
			private _height = parseNumber (_listBox lbText _lb);

			{
				private _vehicle = vehicle _x;

				if (_x == driver _vehicle && {_vehicle isKindOf "AIR"}) then {
					[_vehicle, _height] remoteExec ["flyInHeight", _vehicle];
					_vehicle setVariable ["A3C_FLYINHEIGHT", _height, true];
				};
			} forEach units _group;

			_parent ctrlShow false;
		};

		case ("LOITER_DIR") : {
			A3C_SelectionPromptPanel_MODE = "LOITER_RAD";

			_text ctrlSetText "Select Loiter Radius";

			switch (_lb) do {
				case (0) : {A3C_LoiterDir = "CIRCLE"};
				case (1) : {A3C_LoiterDir = "CIRCLE_L"};
			};

			ctrlSetFocus _listBox;
			lbClear _listBox;

			private _textSize = (((safezoneW / safezoneH) min 1.2) / 1.2 / 25) * 1;

			{
				private _ctrlPos = ctrlPosition _x;

				if (_forEachIndex == 0) then {
					_ctrlPos set [0, 0.383108 * safezoneW + safezoneX];
					_ctrlPos set [1, 0.378986 * safezoneH + safezoneY];
				};

				_ctrlPos set [3, _textSize * 6];

				_x ctrlSetPosition _ctrlPos;
				_x ctrlCommit 0;
			} forEach [_parent, _listBox];

			{
				[_listBox, _x] call A3C_addLbEntry;
			} forEach ["100", "500", "1000", "2000"];
		};

		case ("LOITER_RAD") : {
			switch (_lb) do {
				case (0) : {A3C_LoiterRadius = 100};
				case (1) : {A3C_LoiterRadius = 500};
				case (2) : {A3C_LoiterRadius = 1000};
				case (3) : {A3C_LoiterRadius = 2000};
			};

			_parent ctrlShow false;
		};

		case ("SECU_REJOIN") : {
			_parent ctrlShow false;

			switch (_lb) do {
				case (0) : {A3C_LoiterRadius = 100};
				case (1) : {
					[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_REJOIN_GROUPS;
				};
			};
		};

		case ("STATIC_ASSEMBLE_SQUAD") : {
			private _weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {
				getText (configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")
			} else {
				_listBox lbText _lb
			};

			[] call A3C_UI_RADIAL_CloseDisplay;

			{
				player groupSelectUnit [_x, false];
			} forEach units player;

			showCommandingMenu "";

			{
				private _weapon = _x select 1;

				if (getText (configFile >> "CfgVehicles" >> _weapon >> "displayName") == _weaponToAssemble) exitWith {
					[
						false, //-- isBusy
						"STATIC_ASSEMBLE_SQUAD", //-- actionID
						"", //-- Hud-Icon-class
						[1,1,1,0.7], //-- Hud-Icon-color
						_weapon, //-- placer class
						"" //-- placer color-params
					] call A3C_AI_SHARED_Action_StartPositionalProcess;

					A3C_STATIC_PACKS = [_x];
					A3C_OBJECTPLACER_DIR = getDir cameraOn;
				};
			} forEach A3C_STATIC_PACKS;

			_parent ctrlShow false;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};
		};

		case ("STATIC_DISASSEMBLE_SQUAD") : {
			private _chargeDisplayName = _listBox lbText _lb;
			private _weapon = (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics) select _lb;

			[
				A3C_UI_RADIAL_Current_Remfire_Units,
				_weapon
			] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;

			A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configFile >> "CfgVehicles" >> typeOf _weapon >> "picture");
			A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";

			[position _weapon, ""] spawn A3C_UI_HUD_3D_TAG;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};
		};

		case ("STATIC_ASSEMBLE_HC") : {
			private _weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {
				getText (configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")
			} else {
				_listBox lbText _lb
			};

			[] call A3C_UI_RADIAL_CloseDisplay;

			{
				player groupSelectUnit [_x, false];
			} forEach units player;

			showCommandingMenu "";

			{
				private _weapon = _x select 1;

				if (getText (configFile >> "CfgVehicles" >> _weapon >> "displayName") == _weaponToAssemble) exitWith {
					A3C_STATIC_PACKS = [_x];
					A3C_OBJECTPLACER_DIR = getDir cameraOn;

					[
						false, //-- isBusy
						"STATIC_ASSEMBLE_HC", //-- actionID
						"", //-- Hud-Icon-class
						[1,1,1,0.7], //-- Hud-Icon-color
						_weapon, //-- placer class
						"" //-- placer color-params
					] call A3C_AI_SHARED_Action_StartPositionalProcess;
				};
			} forEach A3C_STATIC_PACKS;

			_parent ctrlShow false;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};
		};

		case ("STATIC_DISASSEMBLE_HC") : {
			private _weapon = A3C_HC_NearStatics select _lb;

			[1, _weapon] spawn A3C_AI_HighCommand_Action_unAssembleWeapon;

			_parent ctrlShow false;

			player commandRadio "SentDisAssemble";

			systemChat format [
				"%1 is packing up a %2",
				groupId (A3C_SELECTED_HC_GROUPS_SETTINGS select 0),
				getText (configFile >> "CfgVehicles" >> typeOf _weapon >> "displayName")
			];
		};

		case ("PLACE_CHARGE_SQUAD") : {
			private _chargeDisplayName = _listBox lbText _lb;
			private _demoUnits = [];
			private _magName = "";

			{
				private _soldier = _x;

				{
					private _testedMagName = _x;

					if (getText (configFile >> "CfgMagazines" >> _testedMagName >> "displayName") == _chargeDisplayName) exitWith {
						_demoUnits pushBackUnique _soldier;
						_magName = _testedMagName;
					};
				} forEach magazines _x;
			} forEach A3C_RD_UNITS;

			private _unit = _demoUnits select 0;

			player groupRadio "SentCmdPlaceCharge";

			[[_unit], true, false] call A3C_AI_Shared_cancelUnitPlot;

			private _expDestination = [_unit] call A3C_fnc_setDestination;

			private _detoObject = if ({cursorTarget isKindOf _x} count ["AIR", "CAR", "TANK", "WHEELED", "ARMORED", "MOTORCYCLE"] > 0) then {
				cursorTarget
			} else {
				objNull
			};

			private _detoPosition = A3C_UI_HUD_3D_TAG_ICON_POS;

			_detoObject = cursorTarget; //-- either object or objNull

			private _detoInfo = [];

			//-- prevent accidental attachment to moving soldiers
			if (_detoObject isKindOf "MAN") then {
				_detoObject = objNull;
			};

			private _intersections = lineIntersectsSurfaces [
				AGLToASL positionCameraToWorld [0,0,0],
				AGLToASL positionCameraToWorld [0,0,1000],
				player,
				objNull,
				true,
				1,
				"GEOM",
				"NONE"
			];

			_intersections = _intersections select {!((_x select 2) isKindOf "MAN")}; //-- ignore accidental men running by

			if !(_intersections isEqualTo []) then {
				private _intersection = _intersections select 0; //-- limit to first intersect
				_intersection params ["_intersectPos", "_surfaceNormal", "_intersectObject"];

				_detoObject = _intersectObject;
				_detoInfo = [_intersectPos, _surfaceNormal];
			};

			private _mainMarker = "A3C_SQ_" + str random 10000000000;

			private _data = [
				[
					[_detoPosition, _detoPosition getPos [50, 0]], //-- positions
					[_mainMarker, "", ""], //-- markers
					["CTRL_DET", [_detoObject, _magName, _detoInfo]], //-- wp action
					["NONE", "NONE"], //--WP Condition
					["UP", "UP"], //-- WP Stances
					[[0, false]], // WP Sync Data
					true, //-- isWPCompleted
					0, //-- Combat Mode
					-1, //-- WP SPeed
					25, //-- WP Flying Height
					-1, //-- WP Loop Value
					0 // -- radius (for circle, not completion)
				]
			];

			_parent ctrlShow false;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};

			[_unit, _data] spawn {
				params ["_unit", "_data"];

				waitUntil {count (_unit getVariable "A3C_PLOT") == 0};

				_unit setVariable ["A3C_PLOT", _data, true];

				private _scriptHandle = [_unit, _unit getVariable "A3C_PLOT"] spawn A3C_AI_Shared_executeUnitPlot;
				private _hasReached = false;
				private _exit = false;
				private _doReturnToOrders = true;

				while {alive _unit} do {
					if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {
						_hasReached = true;
					};

					if (scriptDone _scriptHandle) exitWith {};

					if (_hasReached) then {
						if (animationState _unit != "ainvpknlmstpslaywrfldnon_medic") then {
							sleep 3;
							_exit = true;

							if (count (_unit getVariable "A3C_PLOT") > 0) then {
								_doReturnToOrders = false;
							};
						};
					};

					if (_exit) exitWith {};

					sleep 1;
				};

				if (_doReturnToOrders) then {
					[_unit] call A3C_AI_action_resumeDestination;
				};
			};

			private _magPic = getText (configFile >> "CfgMagazines" >> _magName >> "picture");

			A3C_UI_HUD_3D_TAG_ICON_TYPE = if (_magPic == "") then {
				A3C_UI_HUD_3D_TAG_ICON_TYPE
			} else {
				_magPic
			};

			[_detoPosition, "DEMOLITION"] spawn A3C_UI_HUD_3D_TAG;
		};

		case ("PLACE_CHARGE_HC") : {
			private _magName = "";
			private _chargeDisplayName = _listBox lbText _lb;

			{
				private _testedMagName = _x;

				if (getText (configFile >> "CfgMagazines" >> _testedMagName >> "displayName") == _chargeDisplayName) exitWith {
					_magName = _testedMagName;
				};
			} forEach A3C_REMFIRE_MAGTYPES;

			{
				private _group = _x;

				_group setVariable ["A3C_UNIT_POLYS", [], true];

				//-- clear all waypoints
				{
					{
						_x setVariable ["A3C_CLEARING", false, true];
					} forEach units _x;
				} forEach A3C_SELECTED_UNITS;

				_group = A3C_RD_UNITS select 0;

				[_group, "ALL"] call A3C_HighCommand_deleteAllWaypoints;

				private _wp = [
					_group,
					ASLToATL A3C_UI_HUD_3D_TAG_ICON_POS
				] call A3C_HC_ADD_WP;

				private _cursorObject = if (!isNull cursorTarget && {{cursorTarget isKindOf _x} count ["CAR", "TANK", "SHIP", "AIR", "MOTORCYCLE"] > 0}) then {
					cursorTarget
				} else {
					objNull
				};

				[_cursorObject] call MCSS_fnc_setVehicleVarname;

				private _statements = format [
					"
						[[group this,'%1'], A3C_AI_HighCommand_wpAction_plantExplosive] remoteExec ['bis_fnc_call',0];
					",
					_magName
				];

				private _wpStatements = waypointStatements _wp;

				_wp waypointAttachVehicle _cursorObject;
				_wp setWaypointStatements [
					_wpStatements select 0,
					(_wpStatements select 1) + _statements
				];

				private _returnWP = [
					_group,
					getPos (vehicle leader _group)
				] call A3C_HC_ADD_WP;
			} forEach A3C_RD_UNITS;

			player groupRadio "SentCmdPlaceCharge";

			private _magPic = getText (configFile >> "CfgMagazines" >> _magName >> "picture");

			A3C_UI_HUD_3D_TAG_ICON_TYPE = if (_magPic == "") then {
				A3C_UI_HUD_3D_TAG_ICON_TYPE
			} else {
				_magPic
			};

			[A3C_UI_HUD_3D_TAG_ICON_POS, "DEMOLITION"] spawn A3C_UI_HUD_3D_TAG;

			with uiNamespace do {
				(findDisplay IDD_SELECTION_PROMPT_PANEL) closeDisplay 0;
			};
		};

		case ("PLACE_CHARGE_HC_MAP") : {
			private _chargeDisplayName = _listBox lbText _lb;
			private _magName = "";

			{
				private _testedMagName = _x;

				if (getText (configFile >> "CfgMagazines" >> _testedMagName >> "displayName") == _chargeDisplayName) exitWith {
					_magName = _testedMagName;
				};
			} forEach A3C_REMFIRE_MAGTYPES;

			A3C_HC_DETONATION_BOOL = true;

			[A3C_HC_ACTIVEGROUP, A3C_HC_ACTIVE_IND] waypointAttachVehicle objNull;

			//-- step 1: set deto on waypoint (no target)
			private _statements = waypointStatements [A3C_HC_ACTIVEGROUP, A3C_HC_ACTIVE_IND];

			_statements = [
				_statements select 0,
				format [
					"
						[(group this)] call A3C_HC_FNC_CompleteWaypoint;
						[[group this,'%1'], A3C_AI_HighCommand_wpAction_plantExplosive] remoteExec ['bis_fnc_call',0];
					",
					_magName
				]
			];

			[A3C_HC_ACTIVEGROUP, A3C_HC_ACTIVE_IND] setWaypointStatements _statements;

			_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent ctrlShow false;
		};

		case ("HELI_LANDING_HC_TYPE") : {
			private _hideParent = true;
			private _landingRailType = _listBox lbText _lb;

			switch (_landingRailType) do {
				case ("COMBAT LANDING") : {
					A3C_SelectionPromptPanel_MODE = "HELI_LANDING_GOCODE";
					_hideParent = false;

					_text ctrlSetText "SELECT GO-CODE";

					ctrlSetFocus _listBox;
					lbClear _listBox;

					{
						[_listBox, _x] call A3C_addLbEntry;
					} forEach ["GO-CODE A", "GO-CODE B", "GO-CODE C", "GO-CODE D"];
				};
			};

			if (_hideParent) then {
				_parent ctrlShow false;
				[_landingRailType, ""] spawn A3C_AI_HighCommand_Action_railedHeliLanding;
			};
		};

		case ("HELI_LANDING_GOCODE") : {
			_parent ctrlShow false;

			private _condition = _listBox lbText _lb;

			["COMBAT LANDING", _condition] spawn A3C_AI_HighCommand_Action_railedHeliLanding; //-- condition is goCode type a,b,c,d
		};
	};
};