//---- action buttons: 10008 - 10039
///////////////////// ACTUAL SHARED FUNCTIONS
A3C_UI_SHARED_FIND_BEST_SHOOTERS = {
	params ["_units","_inputPosASL"];

	{
		//private _unitDistance = (eyePos _x) distance _inputPosASL;
		if (isNull objectParent _x) then {
			//_refPos = _x getRelPos [((_x distance A3C_SQ_REM_INDICATOR) - 10),(_x getRelDir A3C_SQ_REM_INDICATOR)];
			if (lineintersects [eyepos _x,_inputPosASL,_x,A3C_SQ_REM_INDICATOR]) then {_units = _units - [_x]};
		} else {
			_vehPos = getPosASL (vehicle _x);
			_vehPos set [2,(_vehPos select 2) + 1.8];
			if (lineintersects [_vehPos,_inputPosASL,_x,(vehicle _x)]) then {
				if (count (getArtilleryAmmo [vehicle _x]) == 0) then { //-- artillery does not require vision
					_units = _units - [_x];
				};
			};
		};
	} foreach _units;
	if (count _units == 0) exitWith {
		systemchat "A3C: No shot on target";
		[]
	};
	_units
};


A3C_UI_RADIAL_fnc_RemFire_EH = {
	params ["_boolString","_iconType","_remFireType"];

	private _return = compile format
	[
		"
			params ['_clickData','_specialParams'];

			private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};

			A3C_UI_RADIAL_Current_Remfire_Units = switch ('%3') do {
				case ('TANKSHOT') : {+(A3C_REMFIRE_TankShot_Units)};
				case ('ATSHOT') : {+(A3C_REMFIRE_ATShot_Units)};
				case ('UGLSHOT') : {+(A3C_REMFIRE_UGLShot_Units)};
				case ('STATICSHOT') : {+(A3C_REMFIRE_StaticShot_Units)};
				default {[]};
			};

			if !(%1) then {
				if (_a3c_dsp == 100040) then {
					A3C_DISABLE_RADIAL = true;
					[] call A3C_RADIAL_CloseDisplay;
					{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu '';
					A3C_UI_HUD_3D_TAG_ICON_TYPE = '%2';
					A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity;
					[
						46,
						'SPACE',
						{

							count A3C_RD_UNITS > 0 &&
							{
								A3C_UI_HUD_3D_TAG_ICON_TYPE != ''
								&&
								{count A3C_RD_UNITS > 0}
							}
						},
						{

							A3C_UI_HUD_3D_TAG_reposition = false;
							if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
								private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
								private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
								private _unitsByGroups = [];
								if (count A3C_UI_RADIAL_Current_Remfire_Units > 1) then {
									{
										_u = _x;
										_gp = group _x;
										if ({_gp == _x select 0} count _unitsByGroups == 0) then {
											_unitsByGroups pushBackUnique [_gp,[_u]];
										} else {
											{
												if (_gp == _x select 0) then {
													(_x select 1) pushBack _u;
												};
											} foreach _unitsByGroups;
										};
									} foreach A3C_UI_RADIAL_Current_Remfire_Units;
								};
								_shooters = [];
								if (count _unitsByGroups > 0) then {
									{
										private _unitsViewOnTarget = [_x select 1, _aimPos] call A3C_UI_SHARED_FIND_BEST_SHOOTERS;
										if (count _unitsViewOnTarget > 0) then {
											_shooters PushBackUnique  (_unitsViewOnTarget select 0);
										};
									} foreach _unitsByGroups;

								} else {
									_shooters = _units;
								};
								A3C_UI_RADIAL_Current_Remfire_Units = [];
								{
									[[_x,_aimPos,'%3'],A3C_AI_SHARED_ORDER_REMOTE_LAUNCH] remoteExec ['bis_fnc_spawn',_x];
								} foreach _shooters;
								[A3C_UI_HUD_3D_TAG_ICON_POS,'SUPPRESSION'] spawn A3C_UI_HUD_3D_TAG;
								sleep 2;
								waituntil {{_x getVariable ['A3C_unit_is_Remote_Firing',false] && {alive _x}} count _shooters == 0};
								if (!isNull findDisplay 100040 && {(ctrlShown (findDisplay 100040 displayctrl 8001)) && {A3C_RADIALMODE in ['ACT','HC ACTIONS']}}) then {
									[A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
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
						{

							true
						},
						{
							(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
							(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
							A3C_UI_HUD_3D_TAG_ICON_TYPE = '';
							A3C_UI_HUD_3D_TAG_reposition = false;
							A3C_UI_RADIAL_Current_Remfire_Units = [];
						},
						{

						},
						true
					] call A3C_UI_RADIAL_ADD_EH_MACROS;


					A3C_UI_HUD_3D_TAG_reposition = true;
				};
			} else {
				systemchat 'A3C: Plase wait for your last order to complete';
			};
		",
		_boolString,
		_iconType,
		_remFireType
	];
	_return
};
//[_x,_aimPos,'%3'] spawn A3C_AI_SHARED_ORDER_REMOTE_LAUNCH;



////////////////////////////this one is actually radial only

//~~ rename this fnc, it's not really shared after all
A3C_UI_SHARED_DISTRIBUTE_MENU_ACTIONS = {
	params ["_display","_unitArray","_buttonContainers"]; //-- here the entire display is passed in, not just the idc number

	{
		(findDisplay _display displayCtrl (_x select 0)) ctrlSetText "";
		(findDisplay _display displayCtrl (_x select 1)) ctrlSetToolTip "";
		{(findDisplay _display displayCtrl _x) ctrlShow false} foreach _x;
	} foreach _buttonContainers;
	private _a3c_dsp = if (!isNull findDisplay 100040) then {100040} else {if (visibleMap) then {100020} else {100030}}; //-- placeholder for future re-use (currently only 100040 is used)
	if (isNull findDisplay _a3c_dsp) exitWith {};


	A3C_REMFIRE_TankShot_Units = [];
	A3C_REMFIRE_UGLShot_Units = [];
	A3C_REMFIRE_ATShot_Units = [];
	A3C_REMFIRE_StaticShot_Units = [];

	//-- action check 1: find cover
	if ({isNull objectParent _x} count _unitArray > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "FIND_COVER";
	};
	//-- action check 2: Open Inventory
	if (count _unitArray == 1) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "OPEN_INV";
		_nearArsenals = (_unitArray select 0) nearObjects 10;

		private _cond = 
		{
			private _cr = _x;
			count ([_cr,[],false,false,0,2] call bis_fnc_addVirtualItemCargo) > 0 OR
			{
				{"arsenal" in (toLower ((_cr actionParams _x) select 0)) } count (actionIDs _cr) > 0
			}
		} count _nearArsenals > 0;
		

		if (_cond) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "ARSENAL";
		};
		_nearArsenals = nil;
	};

	//-- action check 3: clear building
	if (!isNull cursorTarget) then {
		if (cursorTarget Iskindof "HOUSE") then {
			if (([cursortarget] call MCSS_fnc_countBPos) > 0) then {
				A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "CLEAR_BUILDING";
			};
		};
	};
	//-- action check 4: assemble static weapon
	_canAssemble = false;
	_canDisassemble = false;
	_packUnits = _unitArray; //if (count _unitArray >  1) then {_unitArray} else {units player - [player]};
	_packMode = [_packUnits] call A3C_SMART_getWeaponAssemblyMode;

	if (_packMode == "DUAL") then {
		_canAssemble = true;
		_canDisassemble = true;
	} else {
		if (_packMode == "ASSEMBLE") then {
			_canAssemble = true;
		};
		if (_packMode == "DISASSEMBLE") then {
			_canDisassemble = true;
		};
	};

	//-- action check 5: unassemble static weapon
	if (_canAssemble) then {
		//if (isNull cursorTarget) then { //~~ this check ends up being confusing as you may not be aware that you are looking at a cursortarget
			A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "STATIC_ASSEMBLE_SQUAD";
		//};
	};
	if (_canDisAssemble) then {
		//systemchat 'hey';
		A3C_REMFIRE_nearEmptyStatics = [];
		{

			private _soldier = _x;
			private _weapon = objNull;
			private _cond = false;
			//-- check for empty statics closeby
			{
				if (count crew _x == 0 && {(typeOf _x) != "A3C_Supression_Target_F"}) then {
					A3C_REMFIRE_nearEmptyStatics pushBackUnique _x;
					_cond = true;
				};

			} foreach ((position _x) nearObjects ["staticweapon", 50]);
			if !(_cond) then {
				//-- no emptystatics found yet. we check for statics that are manned by members of player group
				_cond =
				(
					count A3C_REMFIRE_nearEmptyStatics > 0
					OR
					{
						!isNull cursorTarget && {count crew cursortarget == 0 && {cursorTarget isKindOf "STATICWEAPON" && {(typeOf cursorTarget) != "A3C_Supression_Target_F"}}}
						OR
						{
							_veh = vehicle _x;
							(_veh isKindOf "STATICWEAPON") && 
							{
								count ((crew _veh) - units player) == 0 &&
								{
									(typeOf _veh) != "A3C_Supression_Target_F"
								}
							}
						}
					}
				);
				if (_cond) then {
					//-- if we have a static weapon gunner, we need to check if there's friends around to help pick up the weapon
					_weapon = vehicle _soldier;
					_otherUnits = (units player) - [player]; //,_soldier
					{
						if (_x distance _weapon > 300) then {
							_otherUnits = _otherUnits - [_x];
						};
					} foreach _otherUnits;
					if !([_otherUnits,_weapon,false] call A3C_HC_canSelectionPickUpStatic) then {
						//-- weapon can not be disassembled because nobody is there to help
						_cond = false;
					};
				};
			};

			if (_cond) exitWith {
				A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "STATIC_DISASSEMBLE_SQUAD";
			};
		} foreach (units player);
	};

	//-- REMFIRE ACTION CHECK 1: Detonate all remote charges
	private _units = +(_unitArray);
	{
		{
			_units pushbackUnique _x;
		} foreach units _x;
	} foreach A3C_HC_getAllGroups_Player_Current;

	if (({(count (_x getvariable ["A3C_UNIT_EXPLOSIVES",[]])) > 0} count _units) > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "ORDER_DETO";

	};

	//-- REMFIRE ACTION CHECK 2: Place Explosive
	_detoUnits = [_unitArray] call A3C_get_det_units;
	if (count _detoUnits > 0) then {
		//if (side cursortarget == civilian OR ((side cameraOn) getfriend (side cursorTarget) < 0.6) ) then {  //~~turned out to be confusing
			A3C_DYNAMIC_BUTTON_ACTIONS pushbackUnique "PLACE_CHARGE_SQUAD";
		//};
	};

	if ({_x in A3C_SUPPRESSION_UNITS_SQ} count A3C_RD_UNITS > 0) then {A3C_DYNAMIC_BUTTON_ACTIONS pushBack "SUPPRESSION_OFF";};
	if ({!(_x in A3C_SUPPRESSION_UNITS_SQ)} count A3C_RD_UNITS > 0) then {A3C_DYNAMIC_BUTTON_ACTIONS pushBack "SUPPRESSION_ON";};

	if (_a3c_dsp == 100040) then { //-- 3D-HUD Exclusive functions
		//-- REMFIRE ACTION CHECKS 3-6: Remote Projectiles

		{
			if (_x == gunner vehicle _x) then {
				if (isNull objectParent _x) then {
					if ([_x] call A3C_HasGL) then {
						A3C_REMFIRE_UGLShot_Units pushBackUnique _x;
					};
					if ([_x] call A3C_HasAT) then {
						A3C_REMFIRE_ATShot_Units pushBackUnique _x;
					};
				} else {
					//if (vehicle _x isKindOf "STATICWEAPON") then {
					if (_x == gunner vehicle _x && {[vehicle _x] call A3C_isStaticMissileLauncher}) then {
						A3C_REMFIRE_StaticShot_Units pushBackUnique _x;
					} else {
						if (vehicle _x isKindOf "TANK") then { //(count (getArtilleryAmmo [vehicle _unit])) > 0
							A3C_REMFIRE_TankShot_Units pushBackUnique _x;
						};
					};
				};
			};
		} foreach A3C_RD_UNITS;

		if (count A3C_REMFIRE_TankShot_Units > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "TANKSHOT";
		};
		if (count A3C_REMFIRE_StaticShot_Units > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "STATICSHOT";
		};
		if (count A3C_REMFIRE_ATShot_Units > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "ATSHOT";
		};
		if (count A3C_REMFIRE_UGLShot_Units > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "UGLSHOT";
		};
	};


	//-- action check 6: engine off
	if ({!isNull objectParent _x && {_x == driver vehicle _x && {!isEngineOn vehicle _x && {!(vehicle _x isKindOf "AIR")}   }}} count _unitArray > 0) then {
		A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "ENGINE_ON";
	} else {
		if ({!isNull objectParent _x && {_x == driver vehicle _x && {isEngineOn vehicle _x && {!(vehicle _x isKindOf "AIR")}   }}} count _unitArray > 0) then {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBackUnique "ENGINE_OFF";
		};
	};

	{
		if !((vehicle _x) isKindOf "AIR" && {!isTouchingGround (vehicle _x)}) exitWith {
			A3C_DYNAMIC_BUTTON_ACTIONS pushBack "UNSTUCK";
		};
	} foreach A3C_RD_UNITS;




	_sortedActions = [];

	{
		if (_x in A3C_DYNAMIC_BUTTON_ACTIONS) then {
			_sortedActions pushBack _x;
		};
	} foreach
	[
		"FIND_COVER",
		"OPEN_INV",
		"ARSENAL",
		"SUPPRESSION_ON",
		"SUPPRESSION_OFF",
		"STATIC_ASSEMBLE_SQUAD",
		"STATIC_DISASSEMBLE_SQUAD",
		"TANKSHOT",
		"STATICSHOT",
		"ATSHOT",
		"UGLSHOT",
		"ORDER_DETO",
		"PLACE_CHARGE_SQUAD",
		"ENGINE_ON",
		"ENGINE_OFF",
		"CLEAR_BUILDING",
		"UNSTUCK"
	];


	A3C_DYNAMIC_BUTTON_ACTIONS = _sortedActions;
	//systemchat str A3C_DYNAMIC_BUTTON_ACTIONS;

	for "_i" from 0 to ( ((count A3C_DYNAMIC_BUTTON_ACTIONS) - 1) min 11) do { //~~ this could also be a foreach loop?
		_action = A3C_DYNAMIC_BUTTON_ACTIONS select _i;
		_button = _buttonContainers select _i;
		_buttonImage = (findDisplay _display displayCtrl (_button select 0));
		_buttonClicker = (findDisplay _display displayCtrl (_button select 1));
		private _buttonFncData = [];
		switch (_action) do {
			case ("TANKSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
				_buttonFncData =
				[
					[],
					{
						_buttonFnc =
						[
							'A3C_Prevent_TANKSHOT',
							'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa',
							"TANKSHOT"
						] call A3C_UI_RADIAL_fnc_RemFire_EH;
						[] call _buttonFnc;
					},
					true

				];

				_buttonClicker ctrlSetTooltip format
				[
					"FIRE TANK SHELL - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
			};
			case ("STATICSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_remote_StaticAT.paa";
				_buttonFncData =
				[
					[],
					{
						_buttonFnc =
						[
							'A3C_Prevent_STATICSHOT',
							'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa',
							"STATICSHOT"
						] call A3C_UI_RADIAL_fnc_RemFire_EH;
						[] call _buttonFnc;
					},
					true

				];
				_buttonClicker ctrlSetTooltip format
				[
					"FIRE STATIC ROCKET LAUNCHER - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
			};
			case ("ATSHOT") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_remote_AT.paa";
				_buttonFncData =
				[
					[],
					{
						_buttonFnc =
						[
							'A3C_Prevent_ATSHOT',
							'\a3c_ui\crosshairs\icon_crosshair_remote_AT.paa',
							"ATSHOT"
						] call A3C_UI_RADIAL_fnc_RemFire_EH;
						[] call _buttonFnc;
					},
					true

				];
				_buttonClicker ctrlSetTooltip format
				[
					"FIRE AT-ROCKET - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
			};
			case ("UGLSHOT") : {
				_buttonImage ctrlSetText "\a3c_ui\menu\icon_menu_action_remote_UGL.paa";
				_buttonFncData =
				[
					[],
					{
						_buttonFnc =
						[
							'A3C_Prevent_UGLSHOT',
							'\a3c_ui\crosshairs\icon_crosshair_remote_UGL.paa',
							"UGLSHOT"
						] call A3C_UI_RADIAL_fnc_RemFire_EH;
						[] call _buttonFnc;
					},
					true

				];

				_buttonClicker ctrlSetTooltip format
				[
					"FIRE UGL GRENADE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
			};


			case ("CLEAR_BUILDING") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_clearBuilding.paa";
				_buttonFncData =
				[
					[str _unitArray,'cursortarget',_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unitArray","_cursorString","_display"];
						_unitArray = call compile _unitArray;
						[_unitArray,_cursorString] spawn A3C_CLEARBUILDING;
					},
					true

				];

				_buttonClicker ctrlSetTooltip "Clear Building";
			};
			case ("ARSENAL") : {

				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_arsenal.paa";
				_buttonFncData =
				[
					[str (_unitArray select 0),_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unit","_display"];
						_unit = call compile _unit;
						[_unit,true] spawn A3C_UI_ARSENAL_CREATELB;
					},
					true

				];

				_buttonClicker ctrlSetTooltip "OPEN ARSENAL";

			};
			case ("UNSTUCK") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						_units spawn A3C_UNSTUCK;
					},
					true

				];
				_buttonClicker ctrlSetTooltip "Un-Stuck Unit(s)";
			};

			case ("ENGINE_ON") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\engine_on_ca.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						{
							_unit = _x;
							if (!isNull objectParent _unit) then {
								if (_unit == driver vehicle _unit) then {
									if (((getPosATL vehicle _unit) select 2) < 5) then {
										_unit action ["engineOn",vehicle _unit];
									};
								};
							};
						} foreach _units;
						BV_ACT = 0;
						["ACTIONS",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
					},
					true

				];
				_buttonClicker ctrlSetTooltip "Turn Engine(s) On";
			};
			case ("ENGINE_OFF") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\engine_off_ca.paa";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_units","_display"];
						_units = call compile _units;
						[_units] call A3C_AI_Shared_fnc_engineOff;
						BV_ACT = 0;
						["ACTIONS",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
					},
					true

				];

				_buttonClicker ctrlSetTooltip "Turn Engine(s) Off";

			};
			case ("ORDER_DETO") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
				_buttonClicker ctrlSetTooltip "MANAGE EXPLOSIVES";

				//{(findDisplay _display displayCtrl _x) ctrlShow false} foreach [8012,8013];

				_buttonFncData =
				[
					[],
					{
						[] call A3C_UI_RADIAL_OBJECTSELECTOR_START_CHARGEDIALOG;
					},
					false
				];
			};

			case ("SUPPRESSION_ON") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
				_buttonClicker ctrlSetTooltip format
				[
					"SUPPRESS POSITION - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
				_buttonFncData =
				[
					[[],_display],
					{
						//params ["_clickData","_fncData"];
						//_fncData params ["_detoUnits","_display"];
						A3C_UI_RADIAL_Current_Remfire_Units = A3C_RD_UNITS;
						{
							if (_x in A3C_SUPPRESSION_UNITS_SQ) then {
								A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_x];
							};
						} foreach A3C_UI_RADIAL_Current_Remfire_Units;
						if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
						A3C_UI_HUD_3D_TAG_ICON_TYPE =  "\a3c_ui\menu\icon_menu_action_suppression.paa";
						A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
						A3C_DISABLE_RADIAL = true;
						{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
						[] call A3C_RADIAL_CloseDisplay;

						[
							46,
							'SPACE',
							{

								count A3C_RD_UNITS > 0 &&
								{
									A3C_UI_HUD_3D_TAG_ICON_TYPE != ''
									&&
									{count A3C_RD_UNITS > 0}
								}
							},
							{


								//if !((A3C_RadialMenu_KEY_ID select 0)in A3C_UI_DOWNKEYS) exitWith {};
								//A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];
								A3C_UI_HUD_3D_TAG_reposition = false;
								//[A3C_UI_HUD_3D_TAG_ICON_POS,'SUPPRESSION'] spawn A3C_UI_HUD_3D_TAG;
								if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
									//private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
									private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
									//private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
									[A3C_UI_HUD_3D_TAG_ICON_POS,'SUPPRESSION'] spawn A3C_UI_HUD_3D_TAG;
									[_units,[A3C_UI_HUD_3D_TAG_ICON_POS,""],'SUPPRESSION',true] spawn A3C_POLY_ACTION_ON;

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
							{

								true
							},
							{

								//[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
							},
							{
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								A3C_UI_HUD_3D_TAG_ICON_TYPE = '';
								A3C_UI_HUD_3D_TAG_reposition = false;
								A3C_UI_RADIAL_Current_Remfire_Units = [];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;
						A3C_UI_HUD_3D_TAG_reposition = true;
					},
					false
				];


			};
			case ("SUPPRESSION_OFF") : {
				_buttonImage ctrlSetText "\a3\ui_f\data\IGUI\Cfg\Actions\ico_OFF_ca.paa";
				_buttonClicker ctrlSetTooltip "STOP SUPPRESSING";
				_buttonFncData =
				[
					[[],_display],
					{
						//params ["_clickData","_fncData"];
						//_fncData params ["_detoUnits","_display"];
						A3C_UI_RADIAL_Current_Remfire_Units = A3C_RD_UNITS;
						{
							if !(_x in A3C_SUPPRESSION_UNITS_SQ) then {
								A3C_UI_RADIAL_Current_Remfire_Units = A3C_UI_RADIAL_Current_Remfire_Units - [_x];
							};
						} foreach A3C_UI_RADIAL_Current_Remfire_Units;
						if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
						[A3C_UI_RADIAL_Current_Remfire_Units,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
						BV_ACT = 0;
						["ACTIONS",0] call A3C_RADIAL_BTN_FNC_RING_INNER;
					},
					false
				];


			};
			case ("PLACE_CHARGE_SQUAD") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_explosives_Place.paa"; 
				_buttonClicker ctrlSetTooltip format
				[
					"PLACE EXPLOSIVE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
				_buttonFncData =
				[
					[str _detoUnits,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_detoUnits","_display"];
						A3C_UI_RADIAL_Current_Remfire_Units = call compile _detoUnits;
						if (count A3C_UI_RADIAL_Current_Remfire_Units == 0) exitWith {};
						
						A3C_UI_HUD_3D_TAG_ICON_TYPE =  '\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa'; 
						A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
						//systemchat format ["To Do: Place Satchel (%1)", A3C_UI_RADIAL_Current_Remfire_Units];
						A3C_DISABLE_RADIAL = true;
						{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
						[] call A3C_RADIAL_CloseDisplay;

						[
							46,
							'SPACE',
							{

								count A3C_RD_UNITS > 0 &&
								{
									A3C_UI_HUD_3D_TAG_ICON_TYPE != ''
									&&
									{count A3C_RD_UNITS > 0}
								}
							},
							{

								//if !((A3C_RadialMenu_KEY_ID select 0)in A3C_UI_DOWNKEYS) exitWith {};
								//A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];
								A3C_UI_HUD_3D_TAG_reposition = false;
								//[A3C_UI_HUD_3D_TAG_ICON_POS,'SUPPRESSION'] spawn A3C_UI_HUD_3D_TAG;
								if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
									//private _aimpos = ATLtoASL(A3C_UI_HUD_3D_TAG_ICON_POS);
									private _units = +(A3C_UI_RADIAL_Current_Remfire_Units);
									private _mags = [];
									{
										_u = _x;
										{
											if (getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]) then {
												private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
												private _mineTrigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");
												if (_mineTrigger == "RemoteTrigger" OR isNull cursorTarget) then {
													_mags pushbackUnique _x;
												};
											};
										} foreach (magazines _u)
									} foreach _units;
									//systemChat str _mags;

									//
									_doRefreshGroupSelected = false;
									with uiNamespace do {
										//disableSerialization;
										A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
									};

									private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
									_parent = findDisplay _a3c_dsp displayCtrl 8008;
									_text = findDisplay _a3c_dsp displayCtrl 800802;
									_listBox = findDisplay _a3c_dsp displayCtrl 800803;

									A3C_OBJECTSELECTOR_MODE = "PLACE_CHARGE_SQUAD";
									_parent ctrlShow true;
									_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
									_parent ctrlCommit 0;
									_text ctrlSetText "Place Charge";

									if (count _mags > 4) then {
										_parentPos = ctrlPosition _parent;
										_parentPos set[3,(_parentPos select 3) + (  ((count _mags) - 4)   * (0.0440051 * safezoneH) )];
										_parent ctrlSetPosition _parentPos;
										_parent ctrlCommit 0;
									};



									ctrlSetFocus _listBox;
									
									lbClear _listBox;
									{
										private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
										[_listBox, _lbText] call A3C_addLbEntry;
									} foreach _mags;
									[_parent,_listBox, count _mags] call A3C_OBJECTSEL_RESIZE;
									


									[] spawn {
										while {!isNull findDisplay 100060} do {

											sleep 0.5;
										};
										if (A3C_UI_HUD_3D_TAG_ICON_TYPE == "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa") then {
											A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
										};
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
								if (A3C_UI_HUD_3D_TAG_reposition) then {
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = '';
									A3C_UI_HUD_3D_TAG_reposition = false;
								};
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								A3C_UI_RADIAL_Current_Remfire_Units = [];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;
						A3C_UI_HUD_3D_TAG_reposition = true;
					},
					false
				];



			};

			case ("STATIC_ASSEMBLE_SQUAD") : {

				_buttonImage ctrlSetText (gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "picture"));
				_buttonClicker ctrlSetTooltip format
				[
					"ASSEMBLE %1 - KEEP %2 PRESSED. SELECT A WEAPON, POSITION AND ROTATE IT (MOUSEWHEEL). PRESS 'SpaceBar' TO CONFIRM OR RELEASE %1 TO CANCEL ",
					(gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")),
					["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
				];
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_assemblingUnitSelection","_display"];
						_assemblingUnitSelection = call compile _assemblingUnitSelection;
						_staticData = [_assemblingUnitSelection,"PLANNING"] call A3C_getSelectionBackpackStatics;
						if (count _staticData > 0) then {

							if (_display == 100040) then {
								A3C_DISABLE_RADIAL = true;
								(findDisplay _display) closeDisplay 0;
								[
									46,
									'SPACE',
									{

										count A3C_RD_UNITS > 0 &&
										{
											!isNull A3C_OBJECTPLACER
										}
									},
									{

										(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
										[] call A3C_STATIC_ASSEMBLE_3D;

									},
									{
										A3C_UI_HUD_3D_TAG_reposition = false;
									},
									false
								] call A3C_UI_RADIAL_ADD_EH_MACROS;
								[
									46,
									'RADIAL',
									{

										true
									},
									{
										if (!isNull A3C_OBJECTPLACER) then {

											deleteVehicle A3C_OBJECTPLACER;
											(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
										};
										A3C_UI_HUD_3D_TAG_reposition = false;
										(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									},
									{},
									true
								] call A3C_UI_RADIAL_ADD_EH_MACROS;

								private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}}; //~~ how does this differ from _display unless it's 100060?	
								A3C_OBJECTSELECTOR_MODE = if (_a3c_dsp == 100060) then {"STATIC_ASSEMBLE_SQUAD"} else {"PLACEHOLDER"};
								if (count _staticData == 1) then {
									[0] call A3C_ObjectSelector_LB_Change;
								} else {
									with uiNamespace do {
										A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
									};
									_parent = findDisplay _a3c_dsp displayCtrl 8008;
									_text = findDisplay _a3c_dsp displayCtrl 800802;
									_listBox = findDisplay _a3c_dsp displayCtrl 800803;
									
									_parent ctrlShow true;
									_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
									_parent ctrlCommit 0;
									_text ctrlSetText "Select Static Weapon";
									ctrlSetFocus _listBox;
									
									lbClear _listBox;
									{
										private _lbText = (getText (configfile >> "CfgVehicles" >> _x select 1 >> "displayName"));
										[_listBox, _lbText] call A3C_addLbEntry;
									} foreach _staticData;
									
								};
							} else {
								//-- PlaceHolder for map-action menu (to do)
							};


							
						};
					},
					false
				];

			};
			case ("STATIC_DISASSEMBLE_SQUAD") : {
				_unitArray = units player;
				{
					if (isPlayer _x) then {
						_unitArray = _unitArray - [_x];
					};
				} foreach _unitArray;
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_STATIC_Packing.paa";
				_buttonClicker ctrlSetTooltip "DISASSEMBLE Static Weapon";
				_buttonFncData =
				[
					[str _unitArray,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_assemblingUnitSelection","_display"];
						_assemblingUnitSelection = call compile _assemblingUnitSelection;
						A3C_UI_RADIAL_Current_Remfire_Units = _assemblingUnitSelection;


						A3C_DISABLE_RADIAL = true;
						[] call A3C_RADIAL_CloseDisplay;
						//(findDisplay _display) closeDisplay 0;


						[
							46,
							'RADIAL',
							{

								true
							},
							{
								(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
							},
							{},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;

						if (count crew cursorTarget == 0 && {cursorTarget isKindOf "STATICWEAPON"}) exitWith {
							[A3C_UI_RADIAL_Current_Remfire_Units,cursortarget] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;
							//A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  typeOf cursortarget >> "picture");
							//A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
							//[position cursortarget,""] spawn A3C_UI_HUD_3D_TAG;
						};

						if ((gunner cursorTarget) in A3C_UI_RADIAL_Current_Remfire_Units && {cursorTarget isKindOf "STATICWEAPON"} ) then {
							[A3C_UI_RADIAL_Current_Remfire_Units,cursortarget] spawn A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING;

							//A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  typeOf cursortarget >> "picture");
							//A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
							//[position cursortarget,""] spawn A3C_UI_HUD_3D_TAG;
						} else {
							with uiNamespace do {
								//disableSerialization;
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
							};

							private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
							_parent = findDisplay _a3c_dsp displayCtrl 8008;
							_text = findDisplay _a3c_dsp displayCtrl 800802;
							_listBox = findDisplay _a3c_dsp displayCtrl 800803;

							A3C_OBJECTSELECTOR_MODE = "STATIC_DISASSEMBLE_SQUAD";
							_parent ctrlShow true;
							_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
							_parent ctrlCommit 0;
							_text ctrlSetText "Pack Weapon";


							A3C_UI_RADIAL_Current_Remfire_Vehicles = [];
							{
								if (_x == gunner vehicle _x && {vehicle _x isKindOf "STATICWEAPON"}) then {
									A3C_UI_RADIAL_Current_Remfire_Vehicles pushBackUnique (vehicle _x);
								};
							} foreach _assemblingUnitSelection;


							if (count A3C_UI_RADIAL_Current_Remfire_Vehicles > 4) then {
								_parentPos = ctrlPosition _parent;
								_parentPos set[3,(_parentPos select 3) + (  ((count _mags) - 4)   * (0.0440051 * safezoneH) )];
								_parent ctrlSetPosition _parentPos;
								_parent ctrlCommit 0;
							};



							ctrlSetFocus _listBox;
							
							lbClear _listBox;
							{
								_str = "";
								if (gunner _x in A3C_UI_RADIAL_Current_Remfire_Units) then {
									_str = format ["%1 (%2)",getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName"),name (gunner _x)];
								} else {
									_str = format ["%1 (Empty)",getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName")];
								};
								[_listBox, _str] call A3C_addLbEntry;
							} foreach (A3C_UI_RADIAL_Current_Remfire_Vehicles + A3C_REMFIRE_nearEmptyStatics);
							

						};
					},
					false
				];
			};
			case ("OPEN_INV") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_action_openInventory.paa";
				_buttonClicker ctrlSetTooltip "Open Inventory";
				//player commandchat str _unitarray;
				_target = if (player distance (_unitArray select 0) < 5.5) then {player} else {_unitArray select 0}; //-- if player is close, he will become target (right box). otherwise unit iself will be target and source will be weaponholder
				_source = _unitArray select 0; //if (player distance (_unitArray select 0) < 5.5) then {_unitArray select 0} else {objNull};
				_buttonFncData =
				[
					[str _target,str _source,_display],
					{
						params ["_clickData","_fncData"];
						_fncData params ['_target','_source','_display'];
						_target = call compile _target;
						_source = call compile _source;
						A3C_UI_INV_TARGET_UNIT = _target;
						(findDisplay _display) closeDisplay 0;
						{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
						[_target,_source] spawn A3C_UI_INV_LB_CREATE;


					},
					false
				];
				//
			};
			case ("FIND_COVER") : {
				_buttonImage ctrlSetText "A3C_CORE\ui\pictures\icon_menu_takeCover.paa";
				_buttonClicker ctrlSetTooltip "Find Cover";
				_buttonFncData =
				[
					[str _unitArray],
					{
						params ["_clickData","_fncData"];
						_fncData params ["_unitArray"];
						_unitArray = call compile _unitArray;
						[_unitArray] spawn A3C_FindCover;
					},
					true
				];

			};
		};

		call compile format
		[
			"

				A3C_OUTER_RING_BTN_fnc_%1 = %2;
			",
			_i + 1,
			_buttonFncData

		];
	};
	//A3C_DYNAMIC_BUTTON_ACTIONS = A3C_DYNAMIC_BUTTON_ACTIONS + ["","","","",""];
	{
		if (_foreachIndex < count A3C_DYNAMIC_BUTTON_ACTIONS) then {
			{(findDisplay _display displayCtrl _x) ctrlShow true} foreach _x;
		};
	} foreach _buttonContainers;

};


A3C_UI_INV_CONTAINERS = [];

A3C_UI_INV_LB_CREATE = {
	params ["_target","_source"];

	if (isNull _target) exitWith {};
	A3C_DISABLE_RADIAL = true;
	(findDisplay 602) closeDisplay 0;
	waitUntil {isNull (findDisplay 602)};
	sleep 0.2;
	A3C_UI_INV_CONTAINERS = [];
	if (_source == _target) then {
		_source = "GroundWeaponHolder" createVehicle (position _target);
		//_source setPos (position _target);
		//_source attachTo [_target,[0,0,0]];
		//A3C_UI_INV_CONTAINERS = [_source];
	};


	_target action ['GEAR',_source];

	_nearCrates =  (_target nearObjects 5) - (units player);
	{
		if (_x distance _target < 5 && {_x isKindOf "MAN"}) then {
			if (!captive _x OR {(side _x != side player) OR {isplayer leader group _x}}) then {
				_nearCrates = _nearCrates - [_x];
			};
		} else {
			_cargo =( magazineCargo _x) + (weaponCargo _x);

			if (count _cargo == 0) then {

				_nearCrates = _nearCrates - [_x];
			} else {

			};
		};
	} foreach _nearCrates;


	A3C_UI_INV_TARGETS = (units player);


	{
		//if (_x distance _target < 4) then {
			A3C_UI_INV_CONTAINERS pushBackUnique _x;
		//};
		
	} foreach ((((units player) select {_target distance2D _x < 5})  - [_target]) + _nearCrates + [_target]); // -- no better idea how to shuffle the target to the end


	waitUntil { !(isNull (findDisplay 602)) };
	sleep 0.1;
	A3C_DISABLE_RADIAL = false;

	_box1 = (findDisplay 602) ctrlCreate ["A3C_RscCombo",1928]; //-- A3C_RscXListBox
	_box2 = (findDisplay 602) ctrlCreate ["A3C_RscCombo",1929];
	private _lbHeight = (0.033 * safezoneH) ; // times x?

	{
		_x params ["_box","_refCtrl"];
		_ctrlPos = ctrlPosition (findDisplay 602 displayCtrl _refCtrl);
		_box ctrlSetPosition [_ctrlPos select 0, (_ctrlPos select 1) - _lbHeight,_ctrlPos select 2,_lbHeight];
		_box ctrlCommit 0;
	} foreach [[_box1,1001],[_box2,1020]];
	{
		[_box2, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
	} foreach A3C_UI_INV_TARGETS;
	{

		switch (true) do {
			case (typeOf _x == "GroundWeaponHolder" OR {_x == A3C_UI_INV_TARGET_UNIT}) : {

				[_box1, "Ground"] call A3C_addLbEntry;
			};
			case (_x in units player) : {
				[_box1, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
			};
			default {
				private _lbText = gettext(configFile >> "CfgVehicles" >> typeof _x >> "displayName");
				[_box1, _lbText] call A3C_addLbEntry;
			};
		};


	} foreach A3C_UI_INV_CONTAINERS;

	{

		if (_x == _source OR {_x == A3C_UI_INV_TARGET_UNIT && {typeOf _source == "GroundWeaponHolder"}}) then {
			[_box1, _foreachIndex] call A3C_setCurSel;
		};
	} foreach A3C_UI_INV_CONTAINERS;
	{
		if (_x == _target) then {
			[_box2, _foreachIndex] call A3C_setCurSel;
		};
	} foreach A3C_UI_INV_TARGETS;



	_box1 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			_container = A3C_UI_INV_CONTAINERS select (_this select 1);
			[A3C_UI_INV_TARGET_UNIT,_container] spawn A3C_UI_INV_LB_CREATE;
			//player groupchat str [A3C_UI_INV_TARGET_UNIT,_container];
		}
	];
	_box2 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			A3C_UI_INV_TARGET_UNIT = A3C_UI_INV_TARGETS select (_this select 1);
			[A3C_UI_INV_TARGET_UNIT,A3C_UI_INV_TARGET_UNIT] spawn A3C_UI_INV_LB_CREATE;
		}
	];


};//A3C_UI_INV_TARGET_UNIT

A3C_UI_RADIAL_ACTIONS_EXECUTE_STATIC_PACKING = {
	params ["_assemblingUnitSelection","_weaponToDisassemble"];
	{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
	//systemchat str (_weaponToDisassemble == cursortarget);
	A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >> typeOf _weaponToDisassemble >> "picture");
	A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
	A3C_UI_HUD_3D_TAG_ICON_POS =  +(position _weaponToDisassemble);
	[+(position _weaponToDisassemble),""] spawn A3C_UI_HUD_3D_TAG;

	if ({group _x == group player} count crew _weaponToDisassemble > 0) then {
		{
			// unassignVehicle _x;
			// doGetOut _x;
			[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
		} foreach (crew _weaponToDisassemble);
		sleep 1;
	};

	_selectedTastUnits = ([_assemblingUnitSelection,[],["DISASSEMBLE",_weaponToDisassemble],position _weaponToDisassemble,0,500] call A3C_STATIC_PREPARE_DISASSEMBLY) select 0;

	if (count _selectedTastUnits == 2) then {
		player groupRadio "SentDisAssemble";
		[_selectedTastUnits,true,false] call A3C_CANCELPLANS;
		_mainMark = "A3C_SQ_" + (str (random 10000000000));
		_wpnPos = position _weaponToDisassemble;
		
		{
			_unit = _x;
			waitUntil {count (_unit getvariable 'A3C_PLOT') == 0};
			_data =
			[
				[
					[_wpnPos,_wpnPos getPos [50,0]], //-- positions
					[_mainMark,"",""], //-- markers
					 ["STATIC",["DISASSEMBLE",_weaponToDisassemble]], //-- wp action
					["NONE","NONE"], //--WP Condition
					["UP","UP"], //-- WP Stances
					[[0,false]], // WP Sync Data
					false, //-- isWPCompleted
					0, //-- Combat Mode
					-1, //-- WP SPeed
					25, //-- WP Flying Height
					-1, //-- WP Loop Value
					0 // -- radius (for circle, not completion)
				]
			];
			private _expDest = [_unit] call A3C_UNIT_STORE_DESTINATION;
			_unit setvariable ["A3C_PLOT",_data,true];
			[_unit] spawn {
				params ["_unit"];
				_scr = ([_unit,(_unit getvariable 'A3C_PLOT')] spawn A3C_MOVE);
				private _hasReached = false;
				private _exit = false;
				private _doReturnToOrders = true;
				while {alive _unit} do {
					if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {_hasReached = true};
					if (scriptDone _scr) exitWith {};
					if (_hasReached) then {
						//systemchat '1k';
						if ( animationState _unit != "ainvpknlmstpslaywrfldnon_medic") then {
							sleep 3;
							_exit = true;
							if ( count (_unit getvariable 'A3C_PLOT') > 0 ) then {
								_doReturnToOrders = false;
							};
						};
					};
					if (_exit) exitWith {};
					sleep 1;
				};
				//systemchat "loop exit";
				if (_doReturnToOrders) then {
					//systemchat 'fire';
					[_unit] call A3C_UNIT_RESUME_DESTINATION;
				};
			};
		} foreach _selectedTastUnits;
	};

};