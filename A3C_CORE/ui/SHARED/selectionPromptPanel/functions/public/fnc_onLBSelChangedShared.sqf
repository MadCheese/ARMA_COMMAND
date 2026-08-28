#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

//-- A3C_ui_selectionPromptPanel_fnc_onLBSelChangedShared

params ["_selectedIndex"];

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _isMapPrompt = _displayId == IDD_MAP_OVERLAY;

private _display = findDisplay _displayId;
private _parentCtrl = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _descriptionCtrl = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBoxCtrl = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

/*
	Close the Selection Prompt Panel according to its current UI context.

	Map:
	The panel is a controlsGroup inside the map-overlay display, so only
	hide the panel.

	HUD:
	The panel owns its display. Close it and restore the commanding-menu
	input state that was suppressed while the prompt was active.
*/
private _closeSelectionPrompt = {
	params [
		"_promptDisplay",
		"_mapPrompt"
	];

	if (isNull _promptDisplay) exitWith {};

	if (_mapPrompt) then {
		(
			_promptDisplay
				displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent
		) ctrlShow false;
	} else {
		_promptDisplay closeDisplay 0;

		"ENABLE" call A3C_ui_shared_fnc_toggleActionMenuAbility;

		{
			player groupSelectUnit [
				_x,
				false
			];
		} forEach units group player;

		showCommandingMenu "";
	};
};

private _doubleClick = false;
private _tickTime = time - A3C_LB_TICKTIME;

if ((_tickTime > 0.07) && {_tickTime < 0.3}) then {
	_doubleClick = true;
};

_doubleClick = true; // Preserved: current code forces selection handling regardless of click timing.
A3C_LB_TICKTIME = time;

if (_doubleClick) then {
	switch (A3C_SelectionPromptPanel_MODE) do {
		case ("DELETE") : {
			switch (_selectedIndex) do {
				case (0) : {
					{
						private _selectedGroup = _x;

						if ({isPlayer _x} count (units _selectedGroup) == 0) then {
							[_selectedGroup] call A3C_main_fnc_deleteGroup;
						} else {
							systemChat format ["A3C: Group %1 was not deleted. Players detected", groupID _selectedGroup];
						};
					} forEach A3C_SELECTED_HC_GROUPS_SETTINGS;

					A3C_SELECTED_HC_GROUPS_SETTINGS = [];
					A3C_SELECTED_UNITS = [];
				};
			};

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("CARGO_WAYPOINTS") : {
			switch (_selectedIndex) do {
				case (0) : {
					//-- YES: fetch cargo groups and prompt to place waypoints
					//-- save unit selection to reestablish later
					A3C_isIssuingCargoWPs = true;
					
					private _cargoGroups = +(
						_parentCtrl getVariable [
							"A3C_CARGO_WAYPOINT_GROUPS",
							[]
						]
					);


					//-- Revalidate before beginning the interaction. A cargo group might have
					//-- received a waypoint while the YES/NO prompt was open.

					_cargoGroups = _cargoGroups select {
						private _cargoGroup = _x;

						!isNull _cargoGroup
						&& {
							(
								waypointPosition [
									_cargoGroup,
									currentWaypoint _cargoGroup
								]
							) distance2D [0, 0, 0] == 0
						}
					};

					[_cargoGroups] spawn {
						params ["_cargoGroups"];

						

						private _storedSelection = +A3C_SELECTED_UNITS;
						private _storedCommandMode = A3C_MAP_CommandMode;
						private _doExit = false;

						{
							private _cargoGroup = _x;

							A3C_MAP_CommandMode = "HC";
							A3C_SELECTED_HC_GROUPS_SETTINGS = [_cargoGroup];
							A3C_SELECTED_UNITS = [_cargoGroup];

							private _hintText = format ["PLACE WAYPOINT FOR %1  %2", groupID _cargoGroup, A3C_SELECTED_HC_GROUPS_SETTINGS];

							hint _hintText;
							waitUntil {
								hintSilent _hintText;
								!visibleMap || {
									(waypointPosition [_cargoGroup, currentWaypoint _cargoGroup]) distance2D [0,0,0] > 0
								}
							};

							if (!visibleMap) exitWith {
								// systemChat "MAP CLOSED";
								_doExit = true;
								hintSilent "";
							};
						} forEach _cargoGroups;

						if !(_doExit) then {
							A3C_SELECTED_UNITS = _storedSelection; //-- only override if map was not closed
							A3C_SELECTED_HC_GROUPS_SETTINGS = _storedSelection; //-- only override if map was not closed
							A3C_MAP_CommandMode = _storedCommandMode;

							hint "Done!";
							sleep 2;
							hintSilent "";
						};
						A3C_isIssuingCargoWPs = false;
					};
				};

				case (1) : {
					//-- NO - do nothing, prompt is closed automatically
				};
			};

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("SPEEDLIMIT") : {
			private _selectedGroup = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
			private _leaderVehicle = vehicle leader _selectedGroup;

			private _speed = switch (_selectedIndex) do {
				case (0) : {false};
				case (1) : {14};
				case (2) : {11};
				case (3) : {5};
			};

			[_leaderVehicle, _speed] remoteExec ["limitSpeed", _leaderVehicle];

			if (_selectedIndex == 0) then {
				_leaderVehicle setVariable ["A3C_LIMIT_SPEED", nil, true];
			} else {
				_leaderVehicle setVariable ["A3C_LIMIT_SPEED", true, true];
			};
			
			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("CAS") : {
			private _casPos = +A3C_UI_HUD_3D_TAG_ICON_POS;
			private _selectedLbText = _listBoxCtrl lbText _selectedIndex;

			private _casModeNumeric = switch (_selectedLbText) do {
				case ("GUN RUN") : {0};
				case ("MISSILES") : {1};
				case ("GUNS + MISSILES") : {2};
				case ("BOMBING RUN") : {3};
			};

			[A3C_UI_HUD_3D_TAG_ICON_POS, ""] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

			private _selectedGroups = +A3C_SELECTED_HC_GROUPS_SETTINGS;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			if (_selectedGroups isEqualTo []) exitWith {};

			player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];

			private _commsOperator = leader (_selectedGroups select 0);
			A3C_CUSTOMRADIO_ID radioChannelAdd [_commsOperator];
			_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];

			{
				private _selectedGroup = _x;
				private _leaderVehicle = vehicle leader _selectedGroup;
				private _isGroupOnFinalWP = currentWaypoint _selectedGroup >= count waypoints _selectedGroup;
				private _createReturnWP = _isGroupOnFinalWP && {_casPos distance2D _leaderVehicle > 50};
				private _landOnReturn = _createReturnWP && {!isEngineOn _leaderVehicle};
				private _wpIndex = currentWaypoint _selectedGroup;

				private _casWP = [
					_selectedGroup,
					_casPos,
					[],
					"MOVE",
					[0,1000,"AUTO","AUTO",-1,"NONE"],
					false,
					_wpIndex + 1
				] call A3C_ai_highCommand_fnc_addWaypoint;

				if (_createReturnWP) then {
					private _startPos = position _leaderVehicle;
					private _returnWP = _selectedGroup addWaypoint [_startPos, 0];

					if (_landOnReturn) then {
						//-- land with default Arma mechanic upon return
						private _landingStatements = format [
							"
								[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
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

				private _casStatements = format [
					"
						[this,%1,%2,'%3'] remoteExec ['A3C_ai_highCommand_fnc_CASdistribute', this];
					",
					A3C_UI_HUD_3D_TAG_ICON_POS,
					_casModeNumeric,
					getPlayerUID player
				];

				private _casWPStatements = waypointStatements _casWP;
				_casWP setWaypointStatements [
					_casWPStatements select 0,
					(_casWPStatements select 1) + _casStatements
				];
			} forEach _selectedGroups;
		};

		case ("MULTIWAYPOINT") : {
			A3C_MULTIWAYPOINT = if (_selectedIndex == 0) then {true} else {false};
			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("DETONATE_SELECTED_CHARGE_SHARED") : {
			player customRadio [A3C_CUSTOMRADIO_ID, "SentCmdDetonate"];
			private _remfireUnits = +A3C_UI_RADIAL_Current_Remfire_Units;

			if (_listBoxCtrl lbText _selectedIndex == "DETONATE ALL CHARGES") then {
				//-- detonate all charges at once

				[_remfireUnits] spawn {
					params ["_remfireUnits"];

					
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
					} forEach _remfireUnits;

					A3C_UI_RADIAL_Current_Remfire_Units = [];
				};
				//-- Note: We do NOT close menu
			} else {
				//-- detonate individual charge

				private _selectedChargeTarget = _remfireUnits select (_selectedIndex - 1);

				A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_selectedChargeTarget];

				_selectedChargeTarget spawn {
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

					[] call A3C_UI_selectionPromptPanel_fnc_actionChargeDetonatePromptRefresh;
				};
			};
		};

		case ("ARTY_0") : {
			A3C_SelectionPromptPanel_MODE = "ARTY_1";

			private _selectedLbText = _listBoxCtrl lbText _selectedIndex;

			A3C_HC_FOCUS_ARTY_AMMO_ARRAY = (getArtilleryAmmo MCSS_REMOTE_ARTILLERY_ARRAY) select {
				private _displayName = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
				_displayName == _selectedLbText
			};

			lbClear _listBoxCtrl;

			_descriptionCtrl ctrlSetText "Select amount of shells";
			ctrlSetFocus _listBoxCtrl;

			private _ammoAmount = 0;
			private _shellDisplays = ([true, true, A3C_HC_FOCUS_ARTY_POS] call A3C_main_fnc_getArtilleryAmmo) select {
				_x select 0 == _selectedLbText
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
					[_listBoxCtrl, str _x] call A3C_ui_shared_fnc_addLbEntry;
				} forEach _lbEntries;

				[_parentCtrl, _listBoxCtrl, count _lbEntries] call A3C_ui_selectionPromptPanel_fnc_resizeBox;
			};
		};

		case ("ARTY_1") : {
			A3C_HC_FOCUS_ARTY_AmmoCount = call compile (
				_listBoxCtrl lbText _selectedIndex
			);

			/*
				HUD prompt completion is immediate.

				The map version has separate delayed-close behavior while an
				artillery suborder is awaiting completion.
			*/
			if (!_isMapPrompt) then {
				[
					_display,
					false
				] call _closeSelectionPrompt;
			};

			[
				A3C_HC_FOCUS_ARTY_POS,
				false
			] spawn A3C_ai_shared_fnc_actionFireArtillery;

			if (A3C_isArtyAwaitingSuborder) then {
				[
					_isMapPrompt,
					_parentCtrl
				] spawn {
					params [
						"_mapPrompt",
						"_parentCtrl"
					];

					sleep 0.4;

					if (
						_mapPrompt
						&& {!isNull _parentCtrl}
					) then {
						_parentCtrl ctrlShow false;
					};

					if !(29 in A3C_UI_DOWNKEYS) then {
						A3C_isArtyAwaitingSuborder = false;
					};
				};
			} else {
				if (_isMapPrompt) then {
					[
						_display,
						true
					] call _closeSelectionPrompt;
				};
			};
		};

		case ("CTRL_DET") : {
			private _chargeDisplayName = _listBoxCtrl lbText _selectedIndex;
			private _chargeMagName = "";

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			

			if (_isMapPrompt) then {
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
				_parentCtrl spawn {
					//-- Preserved: repeated hiding appears to work around display/update timing after dropping on target vehicle.
					for "_i" from 1 to 10 do {
						_this ctrlShow false;
						sleep 0.1;
					};
				};
			};

			{
				private _selectedSoldier = _x;

				{
					if (getText (configFile >> "CfgMagazines" >> _x >> "displayName") == _chargeDisplayName) exitWith {
						_chargeMagName = _x; //-- dirty workaround to retrieve classname from displayname. has to happen first so all units receive same data
					};
				} forEach magazines _selectedSoldier;
			} forEach A3C_SELECTED_UNITS;

			{
				private _selectedSoldier = _x;
				private _plotTemp = _selectedSoldier getVariable ["A3C_PLOT_TEMP", []];

				{
					private _mainMarkerID = format ["%1", parseText ((_x select 1) select 0)];
					private _wpAction = _x select 2;

					if (_mainMarkerID == A3C_MAP_CONNECTING_ID) exitWith {
						if (_wpAction select 0 == "CTRL_DET") then {
							(_wpAction select 1) set [1, _chargeMagName];
						};
					};
				} forEach _plotTemp;

				_selectedSoldier setVariable ["A3C_PLOT_TEMP", _plotTemp, true];
			} forEach A3C_SELECTED_UNITS;

			A3C_MAP_CONNECTING_ID = "";
		};

		case ("PARALOAD") : {
			private _selectedVehicle = vehicle leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0);
			private _cargoObjects = [_selectedVehicle] call A3C_main_fnc_getNearCargoLoadObjects;
			private _vehicleToLoad = _cargoObjects select _selectedIndex;

			[_selectedVehicle, _vehicleToLoad] call A3C_ai_shared_fnc_loadVehicleCargo;



			_cargoObjects = [_selectedVehicle] call A3C_main_fnc_getNearCargoLoadObjects;

			lbClear _listBoxCtrl;

			if (count _cargoObjects > 0) then {
				{
					private _lbEntryText = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
					[_listBoxCtrl, _lbEntryText] call A3C_ui_shared_fnc_addLbEntry;
				} forEach _cargoObjects;
			} else {
				[
					_display,
					_isMapPrompt
				] call _closeSelectionPrompt;
			};
		};

		case ("PARALOAD_SQ") : {
			private _selectedVehicle = vehicle A3C_SQ_CLICKED_UNIT;
			private _cargoObjects = [_selectedVehicle] call A3C_main_fnc_getNearCargoLoadObjects;
			private _vehicleToLoad = _cargoObjects select _selectedIndex;

			[_selectedVehicle, _vehicleToLoad] call A3C_ai_shared_fnc_loadVehicleCargo;

			_cargoObjects = [_selectedVehicle] call A3C_main_fnc_getNearCargoLoadObjects;

			lbClear _listBoxCtrl;

			if (count _cargoObjects > 0) then {
				{
					private _lbEntryText = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
					[_listBoxCtrl, _lbEntryText] call A3C_ui_shared_fnc_addLbEntry;
				} forEach _cargoObjects;
			} else {
				[
					_display,
					_isMapPrompt
				] call _closeSelectionPrompt;
			};
		};

		case ("flyInHeight") : {
			private _selectedGroup = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

			private _currentWP = [_selectedGroup, currentWaypoint _selectedGroup];
			private _currentWPType = waypointType _currentWP;
			private _currentWPPos = if (_currentWPType != "") then {
				waypointPosition _currentWP
			} else {
				(getPosASL (vehicle leader _selectedGroup) select [0, 2]) + [0]
			}; //-- avoid [0,0,0] clash

			//-- #FLYINHEIGHTASL
			private _height = parseNumber (_listBoxCtrl lbText _selectedIndex);

			{
				private _unitVehicle = vehicle _x;

				if (_x == driver _unitVehicle && {_unitVehicle isKindOf "AIR"}) then {
					[_unitVehicle, _height] remoteExec ["flyInHeight", _unitVehicle];
					_unitVehicle setVariable ["A3C_FLYINHEIGHT", _height, true];
				};
			} forEach units _selectedGroup;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("LOITER_DIR") : {
			A3C_SelectionPromptPanel_MODE = "LOITER_RAD";

			_descriptionCtrl ctrlSetText "Select Loiter Radius";

			switch (_selectedIndex) do {
				case (0) : {A3C_LoiterDir = "CIRCLE"};
				case (1) : {A3C_LoiterDir = "CIRCLE_L"};
			};

			ctrlSetFocus _listBoxCtrl;
			lbClear _listBoxCtrl;

			private _textSize = (((safezoneW / safezoneH) min 1.2) / 1.2 / 25) * 1;

			{
				private _ctrl = _x;
				private _ctrlPos = ctrlPosition _ctrl;

				if (_forEachIndex == 0) then {
					_ctrlPos set [0, 0.383108 * safezoneW + safezoneX];
					_ctrlPos set [1, 0.378986 * safezoneH + safezoneY];
				};

				_ctrlPos set [3, _textSize * 6];

				_ctrl ctrlSetPosition _ctrlPos;
				_ctrl ctrlCommit 0;
			} forEach [_parentCtrl, _listBoxCtrl];

			{
				[_listBoxCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
			} forEach ["100", "500", "1000", "2000"];
		};

		case ("LOITER_RAD") : {
			switch (_selectedIndex) do {
				case (0) : {A3C_LoiterRadius = 100};
				case (1) : {A3C_LoiterRadius = 500};
				case (2) : {A3C_LoiterRadius = 1000};
				case (3) : {A3C_LoiterRadius = 2000};
			};

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("SECU_REJOIN") : {
			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			switch (_selectedIndex) do {
				case (0) : {
					//-- CANCEL: do nothing.
				};
				case (1) : {
					[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_ui_mapOverlay_fnc_rejoinDisbandedToPlayerGroup;
				};
			};
		};

		case ("STATIC_ASSEMBLE_SQUAD") : {
			private _weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {
				getText (configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")
			} else {
				_listBoxCtrl lbText _selectedIndex
			};

			[] call A3C_ui_radialMenu_fnc_closeDisplay;

			{
				private _weaponClass = _x select 1;

				if (getText (configFile >> "CfgVehicles" >> _weaponClass >> "displayName") == _weaponToAssemble) exitWith {
					[
						false, //-- isBusy
						"STATIC_ASSEMBLE_SQUAD", //-- actionID
						"", //-- Hud-Icon-class
						[1,1,1,0.7], //-- Hud-Icon-color
						_weaponClass, //-- placer class
						"" //-- placer color-params
					] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;

					A3C_STATIC_PACKS = [_x];
					A3C_OBJECTPLACER_DIR = getDir cameraOn;
				};
			} forEach A3C_STATIC_PACKS;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("STATIC_DISASSEMBLE_SQUAD") : {
			private _chargeDisplayName = _listBoxCtrl lbText _selectedIndex;
			private _selectedWeapon = (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics) select _selectedIndex;

			[
				A3C_UI_RADIAL_Current_Remfire_Units,
				_selectedWeapon
			] spawn A3C_ai_shared_fnc_actionStaticWeaponPack;

			A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configFile >> "CfgVehicles" >> typeOf _selectedWeapon >> "picture");
			A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";

			[position _selectedWeapon, ""] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("STATIC_ASSEMBLE_HC") : {
			private _weaponToAssemble = if (count A3C_STATIC_PACKS == 1) then {
				getText (configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")
			} else {
				_listBoxCtrl lbText _selectedIndex
			};

			[] call A3C_ui_radialMenu_fnc_closeDisplay;

			{
				private _weaponClass = _x select 1;

				if (getText (configFile >> "CfgVehicles" >> _weaponClass >> "displayName") == _weaponToAssemble) exitWith {
					A3C_STATIC_PACKS = [_x];
					A3C_OBJECTPLACER_DIR = getDir cameraOn;

					[
						false, //-- isBusy
						"STATIC_ASSEMBLE_HC", //-- actionID
						"", //-- Hud-Icon-class
						[1,1,1,0.7], //-- Hud-Icon-color
						_weaponClass, //-- placer class
						"" //-- placer color-params
					] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;
				};
			} forEach A3C_STATIC_PACKS;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("STATIC_DISASSEMBLE_HC") : {
			private _selectedWeapon = A3C_HC_NearStatics select _selectedIndex;

			[1, _selectedWeapon] spawn A3C_ai_highCommand_fnc_actionUnAssembleWeaponDispatch;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			player commandRadio "SentDisAssemble";

			systemChat format [
				"%1 is packing up a %2",
				groupId (A3C_SELECTED_HC_GROUPS_SETTINGS select 0),
				getText (configFile >> "CfgVehicles" >> typeOf _selectedWeapon >> "displayName")
			];
		};

		case ("PLACE_CHARGE_SQUAD") : {
			private _chargeDisplayName = _listBoxCtrl lbText _selectedIndex;
			private _demoUnits = [];
			private _magName = "";

			{
				private _selectedSoldier = _x;

				{
					private _testedMagName = _x;

					if (getText (configFile >> "CfgMagazines" >> _testedMagName >> "displayName") == _chargeDisplayName) exitWith {
						_demoUnits pushBackUnique _selectedSoldier;
						_magName = _testedMagName;
					};
				} forEach magazines _x;
			} forEach A3C_RD_UNITS;

			private _demoUnit = _demoUnits select 0;

			player groupRadio "SentCmdPlaceCharge";

			[[_demoUnit], true, false] call A3C_ai_shared_fnc_cancelUnitPlot;

			private _expDestination = [_demoUnit] call A3C_ai_shared_fnc_setDestination;

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

			private _plotData = [
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

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			[_demoUnit, _plotData] spawn {
				params ["_unit", "_data"];

				waitUntil {count (_unit getVariable "A3C_PLOT") == 0};

				_unit setVariable ["A3C_PLOT", _data, true];

				private _scriptHandle = [_unit, _unit getVariable "A3C_PLOT"] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;
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
					[_unit] call A3C_ai_squad_fnc_actionResumeDestination;
				};
			};

			private _magPic = getText (configFile >> "CfgMagazines" >> _magName >> "picture");

			A3C_UI_HUD_3D_TAG_ICON_TYPE = if (_magPic == "") then {
				A3C_UI_HUD_3D_TAG_ICON_TYPE
			} else {
				_magPic
			};

			[_detoPosition, "STANDARD"] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;
		};

		case ("PLACE_CHARGE_HC") : {
			private _magName = "";
			private _chargeDisplayName = _listBoxCtrl lbText _selectedIndex;

			{
				private _testedMagName = _x;

				if (
					getText (
						configFile >>
						"CfgMagazines" >>
						_testedMagName >>
						"displayName"
					) == _chargeDisplayName
				) exitWith {
					_magName = _testedMagName;
				};
			} forEach A3C_REMFIRE_MAGTYPES;

			if (_magName == "") exitWith {
				if (A3C_DEBUG) then {
					systemChat format [
						"place charge aborted: magazine not found | display name %1",
						_chargeDisplayName
					];
				};
			};

			/*
				Reset clearing state once before processing the selected groups.
				There is no need to repeat this entire loop for every group in
				A3C_RD_UNITS.
			*/
			{
				{
					_x setVariable [
						"A3C_CLEARING",
						false,
						true
					];
				} forEach units _x;
			} forEach A3C_SELECTED_UNITS;

			/*
				Capture the object once. Re-reading cursorTarget inside the group
				loop could theoretically produce different targets for different
				groups.
			*/
			private _cursorObject = if (
				!isNull cursorTarget &&
				{
					{
						cursorTarget isKindOf _x
					} count [
						"CAR",
						"TANK",
						"SHIP",
						"AIR",
						"MOTORCYCLE"
					] > 0
				}
			) then {
				cursorTarget
			} else {
				objNull
			};

			[_cursorObject] call A3C_main_fnc_setVehicleVarname;


			{
				private _selectedGroup = _x;

				_selectedGroup setVariable [
					"A3C_UNIT_POLYS",
					[],
					true
				];

				//-- clear all existing waypoints
				[
					_selectedGroup,
					"ALL"
				] call A3C_ai_highCommand_fnc_deleteAllWaypoints;

				//-- add the plant-charge waypoint
				private _plantExplosiveWP = [
					_selectedGroup,
					ASLToATL A3C_UI_HUD_3D_TAG_ICON_POS
				] call A3C_ai_highCommand_fnc_addWaypoint;

				private _waypointScript = format [
					"A3C_CORE\waypointScripts\wpScript_plantExplosives.sqf ['%1',%2,%3,%4]",
					getPlayerUID player,
					["ARRIVAL", 0],
					["NONE", "NONE"],
					[_magName]
				];

				_plantExplosiveWP setWaypointType "Scripted";
				_plantExplosiveWP setWaypointScript _waypointScript;
				_plantExplosiveWP waypointAttachVehicle _cursorObject;

				//-- add return waypoint
				private _returnWP = [
					_selectedGroup,
					getPos (vehicle leader _selectedGroup)
				] call A3C_ai_highCommand_fnc_addWaypoint;

				if (A3C_DEBUG) then {
					diag_log format [
						[
							"[A3C PLACE CHARGE] Issued waypoints",
							"group: %1",
							"plant index: %2",
							"return index: %3",
							"waypoint count: %4",
							"existing plant activation: %5"
						] joinString " | ",
						_selectedGroup,
						_plantExplosiveWP select 1,
						_returnWP select 1,
						count waypoints _selectedGroup,
						_existingActivation
					];
				};
			} forEach A3C_RD_UNITS;

			player groupRadio "SentCmdPlaceCharge";

			private _magPic = getText (
				configFile >>
					"CfgMagazines" >>
					_magName >>
					"picture"
			);

			if (_magPic != "") then {
				A3C_UI_HUD_3D_TAG_ICON_TYPE = _magPic;
			};

			[
				A3C_UI_HUD_3D_TAG_ICON_POS,
				"STANDARD"
			] spawn A3C_ui_mainDisplay_fnc_3D_TagFlicker;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("PLACE_CHARGE_HC_MAP") : {
			private _chargeDisplayName = _listBoxCtrl lbText _selectedIndex;
			private _magName = "";

			{
				private _testedMagName = _x;

				if (getText (configFile >> "CfgMagazines" >> _testedMagName >> "displayName") == _chargeDisplayName) exitWith {
					_magName = _testedMagName;
				};
			} forEach A3C_REMFIRE_MAGTYPES;

			A3C_HC_DETONATION_BOOL = true;

			private _plantExplosiveWP = +([A3C_HC_ACTIVEGROUP, A3C_HC_ACTIVE_IND]);

			
			private _waypointScript = format [
					"A3C_CORE\waypointScripts\wpScript_plantExplosives.sqf ['%1',%2,%3,%4]",
					getPlayerUID player,
					["ARRIVAL", 0],
					["NONE", "NONE"],
					[_magName]
				];

			_plantExplosiveWP setWaypointType "Scripted";
			_plantExplosiveWP setWaypointScript _waypointScript;
			//-- vehicle/waypoint attachment happens via icon click so we predefine it as objNull
			_plantExplosiveWP waypointAttachVehicle objNull;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;
		};

		case ("HELI_LANDING_HC_TYPE") : {
			private _hideParent = true;
			private _landingRailType = _listBoxCtrl lbText _selectedIndex;

			switch (_landingRailType) do {
				case ("COMBAT LANDING") : {
					A3C_SelectionPromptPanel_MODE = "HELI_LANDING_GOCODE";
					_hideParent = false;

					_descriptionCtrl ctrlSetText "SELECT GO-CODE";

					ctrlSetFocus _listBoxCtrl;
					lbClear _listBoxCtrl;

					{
						[_listBoxCtrl, _x] call A3C_ui_shared_fnc_addLbEntry;
					} forEach ["GO-CODE A", "GO-CODE B", "GO-CODE C", "GO-CODE D"];
				};
			};

			if (_hideParent) then {
				[
					_display,
					_isMapPrompt
				] call _closeSelectionPrompt;

				[
					_landingRailType,
					""
				] spawn A3C_ai_highCommand_fnc_actionHeliLandingRailed;
			};
		};

		case ("HELI_LANDING_GOCODE") : {
			private _condition = _listBoxCtrl lbText _selectedIndex;

			[
				_display,
				_isMapPrompt
			] call _closeSelectionPrompt;

			[
				"COMBAT LANDING",
				_condition
			] spawn A3C_ai_highCommand_fnc_actionHeliLandingRailed; //-- condition is goCode type a,b,c,d
		};
	};
};