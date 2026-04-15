
if (isDedicated) exitWith {};


A3C_Map_HC_groupContext_Behaviour = "";
A3C_Map_HC_groupContext_CMode = "";
A3C_Map_HC_groupContext_Form = "";
A3C_Map_HC_groupContext_Color = "";

A3C_SELECTED_HC_GROUPS_SETTINGS = [];
A3C_CONVOYGROUPS = [];

A3C_HC_NearStatics = [];



A3C_HC_GroupMenu_SuppressionRequested = false;

A3C_ALLOW_HCrEFRESH = true;


A3C_Switch_Vehicle_Lights = {
	params ["_vehicle","_mode"];
	{
		private _selName = _x;
		if ("light" in toLower _x) then {
			// _vehicle sethitPointDamage [_selName, _mode];
			[_vehicle, [_selName, _mode]] remoteExec ["sethitPointDamage",_vehicle];		
		};
	} foreach ((getAllHitPointsDamage _vehicle) select 0);

};


A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE = {
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 = [[],{}];

	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_5 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_6 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_7 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_8 = [[],{}];
	A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_9 = [[],{}];
};

[] call A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE;



A3C_MAP_fnc_GroupMenu_Action_BTN = {
	params["_data","_mode","_buttonArray"];
	_buttonArray params ["_buttonImage","_buttonClicker"];
	_fncArray = call compile format ["A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_%1",_mode];
	[_data,_buttonArray,(_fncArray select 0)] spawn (_fncArray select 1);
	[] spawn { sleep 0.1; [A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS] call A3C_MAP_fnc_GroupMenu_LabelActionButtons};

	/*
	switch (_mode) do {
		case (0) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_0 select 1);
		};
		case (1) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_1 select 1);
		};
		case (2) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_2 select 1);
		};
		case (3) : {

			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_3 select 1);
		};
		case (4) : {
			[_data,_buttonArray,(A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 select 0)] spawn (A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_4 select 1);
		};

	};
	*/
};


A3C_HC_engineOffUnits = [];



//-- Hardcoded GROUPMENU ACTIONBUTTONS array
A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS =
[
	[8007161,8007162,8007163], //-- row 1
	[8007171,8007172,8007173],
	[8007181,8007182,8007183],
	[8007191,8007192,8007193],
	[8007201,8007202,8007203],

	[8007211,8007212,8007213], //- row 2
	[8007221,8007222,8007223],
	[8007231,8007232,8007233],
	[8007241,8007242,8007243],
	[8007251,8007252,8007253]
];

/*
[
	"RADIAL"/"MAP" //-- if Radial, use positioning
	[
		["Pos","iconName"/vehicleType], //-- pos = wait for mapclick / 3dPositioner // "iconName"/vehicleType only relevant for Radial?
		["Selector",|]
	]
]
*/	



A3C_MAP_fnc_GroupMenu_LabelActionButtons = {
	params ["_btnArray"];
	
	private _doToggle = if (count _this > 1) then {_this select 1} else {true};
	//-- static / flyinheight
	//-- suppression or arty
	// paradrop
	//-- vehicle board
	//-- unstuck
	//A3C_SELECTED_HC_GROUPS_SETTINGS

	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	if (!isNull findDisplay 100040) then {
		_a3c_dsp = 100040;
	};
	if ({!isNull findDisplay _x} count [100020,100030,100040] == 0) exitWith {};
	//-- wipe action controls

	[] call A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_WIPE;
	{
		_x params ["_img","_btn","_bg"];
		(findDisplay _a3c_dsp displayCtrl _img) ctrlSetText "";
		(findDisplay _a3c_dsp displayCtrl _btn) ctrlSetToolTip "";
		{
			_ct = findDisplay _a3c_dsp displayCtrl _x;
			_ct ctrlShow false; 
		} foreach _x;
	} foreach _btnArray;

	A3C_REMFIRE_MAGTYPES = [];


	A3C_HC_engineOffUnits = [];
	A3C_HC_IROnUnits = [];
	A3C_HC_IROffUnits = [];
	A3C_HC_IR_Laser_On_Units = [];
	A3C_HC_IR_Laser_Off_Units = [];
	A3C_HC_LightsOnUnits = []; //-- since vehicle lights are not a real option, this only goes for INFANTRY
	A3C_HC_LightsOffUnits = [];

	A3C_REMFIRE_TankShot_Units = [];
	A3C_REMFIRE_UGLShot_Units = [];
	A3C_REMFIRE_ATShot_Units = [];
	A3C_REMFIRE_STATICShot_Units = [];

	A3C_HC_DetoShot_Units = [];
	A3C_HC_DetoTrigger_Units = [];

	// private _disableHeal = false; //-- disable heal if action is currently executed. wait until finished before allowing again

	//-- gather actions
	private _actions = [];
	//private _isArty = false;

	private _nearObjects = player nearobjects 2;
	private _nearObjectsTypes = _nearObjects apply {typeOf _x};

	if !(A3C_GROUP_CONVOYS isEqualTo []) then {
		_actions pushBack "CONVOY HALT";
	};

	

	private _playerHasBatteries = [player, "Laserbatteries"] call BIS_fnc_hasItem;

	if (_playerHasBatteries) then {
		private _droneSearchName = if (isClass (configFile >> "CfgVehicles" >> "mavic_3_BLU")) then {
			"mavic"
		} else {
			"mavik"
		};

		private _isDroneNear =
			(player nearObjects 2) findIf {
				_droneSearchName in toLower (typeOf _x)
			} > -1;

		if (_isDroneNear) then {
			_actions pushBack "CHARGE_MAVIC";
		};
	};

	


	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {

		private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
		_leaderVic = vehicle (leader _gp);

		if (_a3c_dsp == 100040 && {typeOf _leaderVic in ["B_T_VTOL_01_armed_F", "B_T_VTOL_01_armed_fixed_F"]}) then {
			_actions PushBack "VTOL_CANNON";
			_actions PushBack "VTOL_GATLING";
			if (typeOf _leaderVic == "B_T_VTOL_01_armed_fixed_F") then {
				_actions PushBack "VTOL_AUTOCANNON";
			};
			
		};

		if ( (typeOf _leaderVic) in ["B_APC_Tracked_01_CRV_F_Fixed", "B_T_APC_Tracked_01_CRV_F_Fixed"]) then {
			if ((_leaderVic getVariable ['MCSS_MCLC_MAGCOUNT', 4]) > 0 && {!(_leaderVic getVariable['MCSS_MCLC_RELOADING', false])}) then {
				_actions PushBack "LINE_CHARGE";
			};
			if ((_leaderVic animationSourcePhase 'moveplow') == 0) then {
				_actions PushBack "PLOW_DEPLOY";
			} else {
				if ((_leaderVic animationSourcePhase 'moveplow') == 1) then {
					_actions PushBack "PLOW_RAISE";
				};
			};
		};
		

		private _isInfOnly = {!isNull objectParent _x} count (units _gp) == 0;

		private _isConvoyGroup = false;
		if (count (A3C_CONVOYGROUPS select {_gp == _x select 0}) == 1) then {
			_actions pushBack "CONVOY_REJOIN";
			_isConvoyGroup = true;
		};

		if (isMultiplayer && {!(isServer)}) then {
			_actions PushBack "OWNERSHIP";
		};

		// 
		if (_gp getVariable ["A3C_MEDICS_ACTIVE", [] ] isEqualTo []) then {
			private _healersAvailable = [units _gp] call A3C_FINDMEDICS;
			private _patients = [_gp] call A3C_FINDPATIENTS;
			// _disableHeal = true;
			if ( { _x isEqualTo [] } count [_healersAvailable, _patients] == 0 ) then {
				//-- there is both healers and patients, so we can add the heal action
				_actions pushBack "HEAL";
			};
		};


		if (_isInfOnly && {[_gp] call A3C_Rearm_Req_HC}) then {
			_actions PushBack "RE-ARM";
		};
		

		if !(_isConvoyGroup) then {
			if (_a3c_dsp == 100020) then {
				_actions PushBack "JOIN GROUP";
			};
		};

		

		

		if ({_leaderVic isKindOf _x} count ["CAR","TANK"] > 0) then {
			_actions PushBack "SPEEDLIMIT";
		};

		if (A3C_ALLOW_HCrEFRESH) then {
			_actions pushBackUnique "REFRESH_HC_GROUP";
		};

		


		//-- add FPV drone to 3D Menu   /// unitIsUAV _leaderVic
		if ( ( (typeOf _leaderVic) in ["B_Crocus_AT", "B_Crocus_AP"]) && {_a3c_dsp == 100040}) then {
			if !("uav_fpv" in (toLower (waypointScript [_gp, currentwaypoint _gp]))) then {
				_actions pushBackUnique "UAV_FPV";
			};
			
		};

		if (_leaderVic isKindOf "AIR") then { //-- para: works for player controlled groups too
			private _isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
			if (((getPosATL _leaderVic) select 2) > 1 && {!(_leaderVic getVariable ["A3C_ParadropActive",false])}) then {
				//-- vehicle is airborne
				//_actions pushBackUnique "LANDING"; // >> landing added to multiple selections
				if ( ({((assignedVehicleRole _x) select 0) == "cargo"} count crew _leaderVic > 0) OR {count (getVehicleCargo _leaderVic) > 0} ) then {
					//-- vehicle has Cargo
					_actions pushBackUnique "PARADROP";
					if (A3C_IsRappel) then {

						if (_isRotor && {isPlayer (leader _gp) OR {{group _x != _gp} count (crew _leaderVic) > 0}}) then {
							//if (isNull findDisplay 100040 OR {}) then {
								_actions pushBackUnique "RAPPEL";
							//};

						};
					};
				};
				//if ([_leaderVic] call A3C_isAttackHelicopter ) then {
				private _var = (_leaderVic) getVariable ["A3C_Freeze_helicopter",[false,0]];
				if (_var select 0) then {
					if (_a3c_dsp != 100040) then { //~~ TEMPORARY - MAKE THIS ACCESSIBLE VIA RADIAL AS WELL!
						_actions pushBackUnique "HELI_OVERWATCH";
					};		
				};

			} else {
				//-- vehicle is on ground
				if ((count ([_leaderVic] call MCSS_fnc_getNearCargoLoadObjects) > 0) OR (count getVehicleCargo _leaderVic > 0)) then {
					//-- vehicle can load an object(s)
					_actions pushBackUnique "PARALOAD";
				};
				if (!isNull findDisplay 100040 && {A3C_israppel}) then {
					if (_isRotor && {{((assignedVehicleRole _x) select 0) == "cargo"} count crew _leaderVic > 0}) then {
						_actions pushBackUnique "RAPPEL";
					};
				};
			};
			if (!(_isRotor) && {_leaderVic isKindOf "PLANE"}) then {
				_casModes = [typeof _leaderVic] call MCSS_fnc_getCASmodes;
				if (count _casModes > 0 && {_a3c_dsp == 100040}) then {
					_actions pushBackUnique "CAS-STRIKE";
				};
			};
			
		} else {

			


			if ({_leaderVic isKindOf _x} count ["TANK","CAR"] > 0 && {canMove _leaderVic} ) then {
				_actions pushBackUnique "VEHICLE-REMOTE";
			};
			
			


			if (!isNull findDisplay 100040) then {

				

				//-- radial menu only
				_testedUnits = units _gp;
				{
					if ([_x] call A3C_canUnitRepair) then {
						_actions pushBackUnique "REPAIR";
					};
					if (!isNull objectParent _x) then {
						_testedUnits = _testedUnits - [_x];
					};
				} foreach _testedUnits;
				if (count units _gp > 1) then {
					if (count ([_testedUnits,"PLANNING"] call A3C_getSelectionBackpackStatics) > 0) then {
						_actions pushBackUnique "STATIC_ASSEMBLE_HC";

					};
				};

				{
					_u = _x;
					{
						if (getText (configfile >> "CfgMagazines" >> _x >> "nameSound") in ["satchelcharge","mine"]) then {
							private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "ammo");
							private _mineTrigger = getText (configfile >> "CfgAmmo" >> _ammo >> "mineTrigger");
							if (_mineTrigger == "RemoteTrigger" OR isNull cursorTarget) then {
								A3C_REMFIRE_MAGTYPES pushbackUnique _x;
							};
							A3C_HC_DetoShot_Units pushBackUnique _u;
						};
					} foreach (magazines _u);

				} foreach _testedUnits;
			};

		};

		//--2: Actions accessible ONLY to AI groups  (hide buttons for player controlled groups)
		if (!isPlayer leader _gp) then { //-- following actions are AI only!

			




			//_actions pushBack "VEHICLE";
			_vehicleType = "GROUND";
			if (_leaderVic isKindOf "AIR") then {
				_vehicleType = "AIR";
			};
			if (_vehicleType == "GROUND") then {

				if (count units _gp > 1) then {
					if ({_x == (gunner vehicle _x) && {(vehicle _x) isKindOf "staticweapon" && {typeOf (vehicle _x) != "A3C_Supression_Target_F" }} } count (units _gp) > 0 ) then {
						_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
					} else {
						//if ( {backPack _x == ""} count (units _gp) >= 2) then {
							A3C_HC_NearStatics = ( (position leader _gp) nearObjects ["staticweapon", 50]);
							A3C_HC_NearStatics = A3C_HC_NearStatics select {
								count crew _x == 0 && 
								{
									(typeOf _x) != "A3C_Supression_Target_F" &&
									{
										[units _gp,_x,true] call A3C_HC_canSelectionPickUpStatic
									}
								}
							};
							if (count A3C_HC_NearStatics > 0) then {
								_actions pushBackUnique "STATIC_DISASSEMBLE_HC";
							};
						//};
					};
				};
			} else {
				_actions pushBackUnique "FLYINGHEIGHT";
			};



			////_artySupImg = "";
			
			//if !(_isArty) then {

			//};
			//(finddisplay _a3c_dsp displayCtrl 800718) ctrlSetText _artySupImg;
			//if ({_x in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)} count units _gp > 0) then { //--aaa !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				//(finddisplay _a3c_dsp displayCtrl 800718) ctrlSetTextColor [1,0,0,1];
				//(finddisplay _a3c_dsp displayCtrl 800719) ctrlSetToolTip "Suppressive Fire (Active)";
			//};
		} else {
			//-- spawn player group cargo monitor
			[_a3c_dsp] spawn { //-- MOVE THIS                                                    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				params ["_a3c_dsp"];
				while {ctrlShown (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT)} do {
					if ({ {group _x != group player} count (crew vehicle _x) > 0} count units player > 0) then {
						//(finddisplay _a3c_dsp displayCtrl 800722) ctrlSetTextColor [1,1,1,1];
						//(finddisplay _a3c_dsp displayCtrl 800723) ctrlShow true;
						//(finddisplay _a3c_dsp displayCtrl 800723) ctrlSetTooltip "CTRL+RMB to dismount other groups";
					} else {
						//(finddisplay _a3c_dsp displayCtrl 800722) ctrlSetTextColor [1,1,1,0.2];
						//(finddisplay _a3c_dsp displayCtrl 800723) ctrlShow false;
						//(finddisplay _a3c_dsp displayCtrl 800723) ctrlSetTooltip "No cargo-groups assigned";
					};
					sleep 0.5;
				};
			};
		};
		private _addUnstuck = false;
		if ({_v = vehicle leader _x; (_v isKindOf "AIR" && {((getPosATL _v) select 2) > 2})} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
			if ({(vehicle leader _x) isKindOf "SHIP"} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
				_addUnstuck = true;
			};
		};
		if (_addUnStuck) then {
			_actions pushBackUnique "UNSTUCK";
		};
		(findDisplay _a3c_dsp displayCtrl 800713) ctrlSetText toUpper (groupID _gp);
	} else {
		(findDisplay _a3c_dsp displayCtrl 800713) ctrlSetText "Multiple Groups";
	};


	// if ({vehicle (leader _x) isKindOf "AIR"} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
	// 	if ({!(_x getVariable ["A3C_VehicleLightsOn", true])} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then {
	// 		_actions pushBack "VEHICLE_LIGHTS_ON";
	// 	};
	// 	if ({(_x getVariable ["A3C_VehicleLightsOn", true])} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then {
	// 		_actions pushBack "VEHICLE_LIGHTS_OFF";
	// 	};
	// };

	_actions pushBackUnique "DELETEGROUP";


	if ({unitIsUAV (vehicle (leader _x))} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
		_actions pushBack "VEHICLE";  //-- TO DO: add vehicle boarding for all-selected once working
	};
	
	
	private _actionExit = false; //-- to be re-used by multiple actions
	
	
	_reBoardFnc = {
		params ["_group"];
		_return = {!isNull (assignedVehicle _x)} count (units _group) == 0 && //-- units-in-vehicle DEFINITELY have assignedV so we know it's foot soldiers only
		{
			_v = (_group getVariable ["A3C_AssignedGroupVehicle",objNull]);
			!isNull _v && {alive _v}
		};

		_return
	};
	{
		
		if ([_x] call _reBoardFnc) then {
			_actions pushBackUnique "VEHICLE_REBOARD";
		};

		if ([_x] call A3C_GroupHasArtilleryCapacity) then {
			_actions pushBackUnique "ARTY";
		};

		//-- exit if both actions are already available
		if ({_x in _actions} count ["VEHICLE_REBOARD", "ARTY"] == 2) exitWith {};
		
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	
	{
		private _gp = _x;
		_gpDrivers = (units _gp) select {
			_oP = objectParent _x;
			!isNull _oP && {
				_x == driver _oP
			};
		};
		_gpVehicles = _gpDrivers apply {objectParent _x};
		{
			if ([_x, 0] call A3C_FireCounterMeasures) exitWith {
				_actions PushBack "COUNTERMEASURES";
				_actionExit = true;
			};
		} foreach _gpVehicles;
		
		if (_actionExit) exitWith {};
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	_actionExit = false; //-- reset bool for re-use



	


	private _suppressionCondition =
	(count A3C_SELECTED_HC_GROUPS_SETTINGS <= 5) &&
	{
		{
			_x == gunner vehicle _x &&
			{
				(getArtilleryAmmo [vehicle _x]) isEqualTo [] &&
				{
					!(vehicle _x isKindOf "PLANE") //!! change this when working out VTOL GUNSHIPS
				}
			}
		} count units _x > 0
	} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0;

	if (
		{
			_leaderVic = vehicle leader _x;
			(_leaderVic isKindOf "AIR") &&
			{
				!(_leaderVic getVariable ["A3C_ParadropActive",false])
			} &&
			{
				_a3c_dsp == 100040 OR {((getPosATL _leaderVic) select 2) > 1}
			}
		} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0
	) then {
		if (_a3c_dsp == 100040) then {
			_actions pushBackUnique "LANDING"; //-- aircraft landings: further evaluation is to be made when action is CALLED
		};
	};

	if (_suppressionCondition) then { 
		_actions pushBackUnique "SUPPRESSION"; //-- SUPPRESSION is ALWAYS added when possible, even when units are suppressing, so that you can change the suppressed position on the fly
		if ({{_x in A3C_SUPPRESSION_UNITS_AI} count (units _x) > 0} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then {
			_actions pushBackUnique "SUPPRESSION_STOP";
		};
	};

	if (!isNull findDisplay 100040) then {
		private _HCunits = units player - [player];
		{
			{
				_HCunits pushbackUnique _x;
			} foreach units _x;
		} foreach A3C_HC_getAllGroups_Player_Current;
		{

			if ((count (_x getvariable ["A3C_UNIT_EXPLOSIVES",[]])) > 0) then {
				A3C_HC_DetoTrigger_Units pushbackUnique _x;
			};
		} foreach _HCunits;

		if (count A3C_HC_DetoTrigger_Units > 0) then {
			_actions pushbackUnique "ORDER_DETO";
		};
	};


	if (count (A3C_CONVOYGROUPS select {(_x select 0) in A3C_SELECTED_HC_GROUPS_SETTINGS}) == 0) then { //-- exclude convoy groups
		_actions pushBack "REJOIN";
		if (count A3C_SELECTED_HC_GROUPS_SETTINGS > 1) then {
			if ({{isNull vehicle _x OR {vehicle _x isKindOf "AIR"}} count units _x > 0} count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) then {
				_actions pushBack "CONVOY_CREATE";
			};
		};
	};
	

	// systemchat str (count _actions < 10);
	if (count _actions < 13) then {
		{
			_gp = _x;
			_addGrouptoIR_Strobe = true;
			_addGrouptoEngine_Off = false;

			{
				private _u = _x;
				private _v = vehicle _u;
				_irData = _u getvariable ["A3C_STROBE",[]];
				if (count _irData > 0) then {
					_addGrouptoIR_Strobe = false;
				};
				if ({[_x,faction _u] call BIS_fnc_instring} count (["BLU_F","BLU_T","BLU_W","IND_F","OPF_F","OPF_T","OPF_V","rhs_faction_us"] ) > 0) then {
					if (!isNull objectParent _u) then {
						if (speed _v < 0.1 && {speed _v > -0.1}) then {
							if (_x == driver _v) then {
								if (isEngineOn _v) then {
									if !(_v isKindOf "AIR" && (getPosATL _v select 2) > 2) then {
										_addGrouptoEngine_Off = true;
									};
								};
							};
						};
					};
				};

			} foreach units _gp;
			if (_addGrouptoIR_Strobe) then {
				private _cond = {
					{
						private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
						private _nvgMarkers = "true" configClasses (configFile >> "CfgAmmo" >> _ammo >> "NVGMarkers") apply {configName _x};
						!(_nvgMarkers isEqualTo [])
					} count (magazines _x) > 0;
				} count (units _gp) > 0;
				if (_cond) then {
					A3C_HC_IROnUnits pushBackUnique _gp;
				};
				
			} else {
				A3C_HC_IROffUnits pushBackUnique _gp;
			};
			if (_addGrouptoEngine_Off) then {
				A3C_HC_engineOffUnits pushBackUnique _gp;
			};
			//-- following is not included in above loop as it has to effect the ENTIRE group.
			{
				_u = _x;
				_hasPointer = [_u,"LASER"] call A3C_doesUnitHaveWeaponItem;
				_hasFlashLight = [_u,"FLASHLIGHT"] call A3C_doesUnitHaveWeaponItem;

				if (_hasPointer) then {
					if ({_x isIRLaserOn (currentWeapon _x)} count units (group _u) > 0) then {
						A3C_HC_IR_Laser_Off_Units pushBackUnique (group _u);
					} else {
						A3C_HC_IR_Laser_On_Units pushbackUnique (group _u);
					};
				};
				if (_hasFlashLight) then {
					if ({_x isFlashlightOn (currentWeapon _x)} count units (group _u) > 0) then {
						A3C_HC_LightsOffUnits pushBackUnique (group _u);
					} else {
						A3C_HC_LightsOnUnits pushbackUnique (group _u);
					};
				};
				if ((!isNull findDisplay 100040) && {_x == (gunner vehicle _x)}) then {
					if (isNull objectParent _x) then {
						if ([_x] call A3C_HasAT) then {
							A3C_REMFIRE_ATShot_Units pushBackUnique _x;
						};
						if ([_x] call A3C_HasGL) then {
							A3C_REMFIRE_UGLShot_Units pushBackUnique _x;
						};

					} else {
						if ([vehicle _x] call A3C_isStaticMissileLauncher) then {
							A3C_REMFIRE_STATICShot_Units pushbackUnique _x;
						} else {
							if ((count (getArtilleryAmmo [vehicle _x])) == 0 && {vehicle _x isKindOf "LAND"}) then { //-- exclude artillery and aircraft
								_isCannonVic = false;
								_isMissileVic = false;
								{
									_weapon = _x;
									_parent = getText (configfile >> "CfgWeapons" >> _weapon >> "nameSound"); //configName (inheritsFrom (configfile >> "CfgWeapons" >> _weapon));
									if ("cannon" in toLower _parent) then {
										_isCannonVic = true;
									} else {
										if ({_x in toLower _parent} count ["missile","rocket"] > 0) exitWith {
											_isMissileVic = true;
										};
									};
									
								} forEach (weapons (vehicle _x));
								
								//if (vehicle _x isKindOf "TANK") then {
								if (_isCannonVic) then {
									A3C_REMFIRE_TankShot_Units pushbackUnique _x;
								} else {
									if (_isMissileVic) then {
										A3C_REMFIRE_STATICShot_Units pushbackUnique _x;
									};
								};
							};
						};
					};
				};

				{
					//private ["_am","_array"];
					//_it = _x;
					//_am = (getText (configfile >> "CfgMagazines" >> _x >> "ammo"));
					//_array = "true" configClasses (configfile >> "CfgAmmo" >> _am >> "NVGMarkers");

					//if (count _array > 0) exitwith {
				//		A3C_HC_IROnUnits pushBackUnique _u; //-- drivers added to IR
					//};
				} foreach (magazines _u);
			} foreach units _gp;

		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;


		if (count A3C_HC_DetoShot_Units > 0) then {
			_actions pushBackUnique "PLACE_CHARGE_HC";
		};


		if (count A3C_REMFIRE_TankShot_Units > 0) then {
			_actions pushBackUnique "TANKSHOT";
		};
		if (count A3C_REMFIRE_STATICShot_Units > 0) then {
			_actions pushBackUnique "STATICSHOT";
		};
		if (count A3C_REMFIRE_ATShot_Units > 0) then {
			_actions pushBackUnique "ATSHOT";
		};
		if (count A3C_REMFIRE_UGLShot_Units > 0) then {
			_actions pushBackUnique "UGLSHOT";
		};



		if (count A3C_HC_engineOffUnits > 0) then {
			_actions pushBackUnique "ENGINE_OFF";
		};
		A3C_HC_IROnUnits = A3C_HC_IROnUnits - A3C_HC_IROffUnits;

		if (count A3C_HC_IROffUnits > 0) then {
			_actions pushBackUnique "IR_OFF";
			A3C_HC_IROnUnits = [];
		};

		if (count A3C_HC_IROnUnits > 0) then {
			_actions pushBackUnique "IR_ON";

		};

		//systemchat str (A3C_HC_IROnUnits - A3C_HC_IROffUnits);

		if (count A3C_HC_IR_Laser_Off_Units > 0) then {
			_actions pushBackUnique "IR_POINTER_OFF";
			A3C_HC_IR_Laser_On_Units = [];
		};

		if (count A3C_HC_IR_Laser_On_Units > 0) then {
			_actions pushBackUnique "IR_POINTER_ON";
		};

		if (count A3C_HC_LightsOffUnits > 0) then {
			_actions pushBackUnique "FLASHLIGHT_OFF";
			A3C_HC_LightsOnUnits = [];
		};
		if (count A3C_HC_LightsOnUnits > 0) then {
			_actions pushBackUnique "FLASHLIGHT_ON";
		};

	};

	_sortedActions = [];

	{
		if (_x in _actions) then {
			_sortedActions pushBack _x;
		};
	} foreach
	[
		"UAV_FPV",
		"CONVOY HALT",
		"CHARGE_MAVIC",
		"VEHICLE",
		"VEHICLE_REBOARD",
		"VEHICLE-REMOTE",
		"HELI_OVERWATCH",
		"SUPPRESSION",
		"SUPPRESSION_STOP",
		"CAS-STRIKE",
		"LANDING",
		"PARADROP",
		"RAPPEL",
		"PARALOAD",
		"FLYINGHEIGHT",
		"REPAIR",
		"ATSHOT",
		"UGLSHOT",
		"STATICSHOT",
		"ARTY",
		"PLOW_DEPLOY",
		"PLOW_RAISE",
		"LINE_CHARGE",
		"TANKSHOT",
		"VTOL_CANNON",
		"VTOL_GATLING",
		"VTOL_AUTOCANNON",
		"COUNTERMEASURES",
		"PLACE_CHARGE_HC",
		"ORDER_DETO",
		"STATIC_ASSEMBLE_HC",
		"STATIC_DISASSEMBLE_HC",
		"IR_OFF",
		"IR_ON",
		"IR_POINTER_OFF",
		"IR_POINTER_ON",
		"FLASHLIGHT_OFF",
		"FLASHLIGHT_ON",
		"ENGINE_OFF",
		"VEHICLE_LIGHTS_ON",
		"VEHICLE_LIGHTS_OFF",
		"SPEEDLIMIT",
		"CONVOY_REJOIN",
		"CONVOY_CREATE",
		"HEAL",
		"RE-ARM",
		"JOIN GROUP",
		//"REJOIN",
		"UNSTUCK",
		"REFRESH_HC_GROUP",
		"OWNERSHIP",
		"DELETEGROUP"	
	];

	//-- player controlled groups in selection: No actions allowed:
	if ({private _ld = leader _x; isPlayer _ld } count A3C_SELECTED_HC_GROUPS_SETTINGS > 0) then { //&& {_ld != player}
		
		[] spawn {
			
			hint "A3C: Player Group(s) detected. No actions allowed. ";
			sleep 2;
			hintSilent "";
		};
		_sortedActions = [];
	};


	_actions = _sortedActions;


	{

		if (_foreachIndex < 10) then {
			_actionName = _x;
			private _params = [];
			private _button_IMG = "";
			private _button_toolTip = "";
			private _buttonFnc = {};
			private _actionAvailable = true;
			_imageColorCode = [1,1,1,1];

			switch (_actionName) do {

				// 

				case ("CONVOY HALT") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoyStop.paa";
					_button_toolTip = "HALT ALL CURRENT CONVOYS";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;

						if (_isRadial) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
						};

						hint format ["%1 convoy(s) have been ordered to halt!", count A3C_GROUP_CONVOYS];

						{
							_convoyElement = _x;
							{
								_gp = _x;
								private _waypoints = waypoints _x;
								private _cwp = currentWaypoint _gp;
								{
									if (_x select 1 >= _cwp) then {
										deleteWaypoint _x;
									};
								} foreach _waypoints;
								private _lv = vehicle leader _gp;
								private _effCom = effectiveCommander _lv;
								if (_effCom in (units _gp)) then {
									private _closePos = _lv getPos [10, getDir _lv];
									[_effCom, _closePos]  call A3C_DOMOVE;
								};
								(leader _gp) setBehaviour "COMBAT";
								{
									private _weaponsFound = false;
									private _oP = objectParent _x;

									if (!isNull _oP) then {
										if (currentWeapon _x != "") then {_weaponsFound = true};
									} else {
										private _turrentWeapons = _oP weaponsTurret ((_oP) unitTurret gunner _oP);
										if !(_turrentWeapons isEqualTo []) then {_weaponsFound = true};
									};
									if (_weaponsFound) exitWith {
										(leader _gp) setBehaviourStrong "COMBAT";
										(leader _gp) setCombatMode "RED";
									};
								} foreach (units _gp);
							} foreach _convoyElement;
							
							
						} foreach A3C_GROUP_CONVOYS;

						[] spawn {
							sleep 2;
							hintSilent "";
						};
						

						A3C_GROUP_CONVOYS = [];

						A3C_SELECTED_HC_GROUPS_SETTINGS = [];
					};
					
				};

				case ("DELETEGROUP") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_trash.paa";
					_button_toolTip = "Delete Group And Vehicles";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;

						if (_isRadial) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
						};

						if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
							{
								_gp = _x;
								if ({isPlayer _x} count(units _gp) == 0) then {
									[_gp] call A3C_DeleteGroup;
								} else {
									systemchat format ["A3C: Group %1 was not deleted. Players detected", groupID _gp];
								};
								
							} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

							A3C_SELECTED_HC_GROUPS_SETTINGS = [];
						} else {
							if (visibleMap) then {
								(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
								(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
							} else {
								with uiNamespace do {
									A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
								};
							};
							
							["DELETE"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
						};

						
					};
					
				};

				case ("VEHICLE-REMOTE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remote.paa";
					_button_toolTip = "Remote Control Vehicle";
					_buttonFnc = {
						// (findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
						// private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						// private _isRadial = _a3c_dsp == 100040;
						// if (_isRadial) then {
						// 	//-- no actual action - just close menu
						// 	A3C_DISABLE_RADIAL = true;
						// 	[] call A3C_RADIAL_CloseDisplay;
						// 	[
						// 		46,
						// 		'RADIAL',
						// 		{

						// 			true
						// 		},
						// 		{
						// 		},
						// 		{
						// 			(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
						// 		},
						// 		true
						// 	] call A3C_UI_RADIAL_ADD_EH_MACROS;
						// } else {
						// 	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
						// 	(findDisplay 12 displayCtrl 51) ctrlEnable true;
						// };
						[] call A3C_GP_RC_UIVehicleRemoteFnc;
					};
				};
				case ("REFRESH_HC_GROUP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_refresh.paa";

					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if (_isRadial) then {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						};
						//systemchat 'ayyyy heyooo';
						{
							_oldGroup = _x;
							_waypointData = [];
							_groupID = groupID _oldGroup;
							_wpIndex = 0;
							private _allVariables = (allVariables _oldGroup) apply {[_x, _oldGroup getVariable [_x,nil]]};
							{
								_wp = _x;
								if (_wp select 1 >= currentWaypoint _oldGroup ) then { //-- exclude first waypoint? && {_foreachIndex > 0}
									_waypointData set
									[
										_wpIndex,
										[
											waypointBehaviour _wp,
											waypointCombatMode _wp,
											waypointCompletionRadius _wp,
											waypointDescription _wp,
											waypointFormation _wp,
											waypointName _wp,
											waypointPosition _wp,
											waypointScript _wp,
											waypointSpeed _wp,
											waypointStatements _wp,
											waypointTimeout _wp,
											waypointType _wp,
											waypointVisible _wp
										]
									];
									_wpIndex = _wpIndex + 1;
								};
								
							} foreach (waypoints _oldGroup);


							_newGroup = createGroup (side _oldGroup);
							(units _oldGroup) joinSilent _newGroup;

							[_newGroup] call A3C_HC_ReInitGroupMovement;
							{
								_x params ["_name","_val"];
								if (!isNil '_newGroup') then {
									if (!isNil '_name') then {
										if (!isNil '_val') then {
											_newGroup setVariable [_name,_val,true]; //-- unfortunately there's no way to know if var was public or not :S > so we broadcast lol
										};
									};
								};				
							} foreach _allVariables;
							deleteGroup _oldGroup;
							_newGroup setGroupIdGlobal [_groupID];
							
						
							{
								_wpData = _x;
								_wp = _newGroup addWaypoint [[0,0,0],0];
								{
									_wpValue = _x;
									//systemchat str [_wpValue];
									diag_log _wpValue;
									switch _foreachIndex do {
										case (0)  : {_wp setWaypointBehaviour _wpValue};
										case (1)  : {_wp setWaypointCombatMode _wpValue};
										case (2)  : {_wp setWaypointCompletionRadius _wpValue};
										case (3)  : {_wp setWaypointDescription _wpValue};
										case (4)  : {_wp setWaypointFormation _wpValue};
										case (5)  : {_wp setWaypointName _wpValue};
										case (6)  : {_wp setWaypointPosition  [_wpValue,0]};
										case (7)  : {_wp setWaypointScript _wpValue};
										case (8)  : {_wp setWaypointSpeed _wpValue};
										case (9)  : {_wp setWaypointStatements _wpValue
										};
										case (10) : {_wp setWaypointTimeout _wpValue};
										case (11) : {_wp setWaypointType _wpValue};
										case (12) : {_wp setWaypointVisible _wpValue};
									};
								} foreach _wpData;
							} foreach _waypointData;

							private _wpPos = waypointPosition [_newGroup, currentWaypoint _newGroup];
							if (_wpPos distance2D (vehicle leader _newGroup) > 20) then {
								[_newGroup,_wpPos] call A3C_HC_MoveToWaypoint; 
							};

							{
								{
									_x enableAI "ALL";
								} foreach [_x, objectParent _x];
							} foreach (units _newGroup);

							[_newGroup] call A3C_HC_ReInitGroupMovement; //-- backup brute force double right hook lol - probably not really needed.
							
						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

						
					};
					_button_toolTip = "Refresh Unresponsive HC-Group";
				};
				case ("CONVOY_CREATE") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoy_create.paa";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if (_isRadial) then {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						};
						[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
					};
					_button_toolTip = "Create Convoy-Group";
				};
				case ("CONVOY_REJOIN") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_convoy_reJoin.paa";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if (_isRadial) then {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						};
						[] spawn A3C_Map_HC_groupContext_ButtonFnc_Convoy;
					};
					_button_toolTip = "Re-Establish Convoy Groups";
				};

				case ("REJOIN") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_rejoinToPlayer.paa";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if !(_isRadial) then {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						} else {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						};
						[A3C_SELECTED_HC_GROUPS_SETTINGS] call A3C_fnc_SecuRejoin_fnc;
					};
					_button_toolTip = "Merge with player group";
				};

				case ("JOIN GROUP") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_joinGroup.paa";
					_buttonFnc = {
						{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
						(findDisplay 12 displayCtrl 51) ctrlEnable true;
						A3C_isMergeGroupActive = true;
						waituntil {!visibleMap OR {!(A3C_isMergeGroupActive)}};
						A3C_isMergeGroupActive = false;
					};
					_button_toolTip = "Merge with other group";
				};

				case ("SPEEDLIMIT") : {
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_groupSpeed.paa";
					_buttonFnc = {
						A3C_OBJECTSELECTOR_MODE = "SPEEDLIMIT";
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;

						if (_isRadial) then {
							_a3c_dsp = 100060;
						};

						_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
						_text = findDisplay _a3c_dsp displayCtrl 800802;
						_listBox = findDisplay _a3c_dsp displayCtrl 800803;

						if (_isRadial) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							with uiNamespace do {
								//disableSerialization;
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
								(findDisplay 100060 displayCtrl 800802) ctrlSetText "Select Max Speed";
								
								
								_parent = findDisplay 100060 displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
								_text = findDisplay 100060 displayCtrl 800802;
								_listBox = findDisplay 100060 displayCtrl 800803; //~~ WHY DO I HAVE TO DO IT THIS WAY HERE?

								_parent ctrlShow true;
								_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
								_parent ctrlCommit 0;
								_parent ctrlShow true;
								{
									_ctrlPos = ctrlPosition _x;
									_ctrlPos set [3,(_ctrlPos select 3) + (  (4)   * (0.0440051 * safezoneH) )];
									_x ctrlSetPosition _ctrlPos;
									_x ctrlCommit 0;
								} foreach [_parent,_listBox];


								lbClear _listBox;
								{
									[_listBox, _x] call A3C_addLbEntry;
								} foreach ["FULL PACE","JOGGING PACE","COMBAT PACE","WALKING PACE"];
								
								
								
								(findDisplay 100060) displayAddEventhandler
								[
									"KeyUp",
									{
										[_this] spawn {
											_button = _this select 0;
											_button = _button - [(_button select 0)];
											if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
												A3C_DISABLE_RADIAL = false;
												//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
												//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
												(findDisplay 100060) closeDisplay 0;
												A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
												{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
											};
										};
									}
								];
								
							};
							
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
							_parent ctrlShow true;
							_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
							_parent ctrlCommit 0;
							_parent ctrlShow true;
							{
								_ctrlPos = ctrlPosition _x;
								_ctrlPos set [3,(_ctrlPos select 3) + (  (4)   * (0.0440051 * safezoneH) )];
								_x ctrlSetPosition _ctrlPos;
								_x ctrlCommit 0;
							} foreach [_parent,_listBox];
						};
						_text ctrlSetText "Select Max Speed";
						
						lbClear _listBox;
						{
							[_listBox, _x] call A3C_addLbEntry;
						} foreach ["FULL PACE","JOGGING PACE","COMBAT PACE","WALKING PACE"];
						
					};
					_button_toolTip = "Limit Group Speed";
				};
				

				case ("TANKSHOT") : {
					_imageColorCode = if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						'A3C_Prevent_TANKSHOT',
						'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa',
						"TANKSHOT"
					] call A3C_UI_RADIAL_fnc_RemFire_EH;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
					_button_toolTip =  format
					[
						"FIRE TANK SHELL - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};

				case ("VTOL_CANNON") : {
					_imageColorCode = [1,1,1,1]; //if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						false, //-- #TODO: Add delay for cannon
						'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa',
						'CANNON'
					] call A3C_UI_RADIAL_fnc_RemFire_VTOL_EH;

					_button_IMG = "\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP CANNON - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};

				case ("VTOL_GATLING") : {
					_imageColorCode = [1,1,1,1]; //if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						false, //-- #TODO: Add delay for cannon
						'\a3c_ui\crosshairs\icon_crosshair_CAS.paa',
						'GATLING'
					] call A3C_UI_RADIAL_fnc_RemFire_VTOL_EH;

					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_Railgun.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP GATLING - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};

				case ("VTOL_AUTOCANNON") : {
					_imageColorCode = [1,1,1,1]; //if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						false, //-- #TODO: Add delay for cannon
						'\a3c_ui\crosshairs\icon_crosshair_remoteTankShell.paa',
						'AUTOCANNON'
					] call A3C_UI_RADIAL_fnc_RemFire_VTOL_EH;

					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_remoteTankShell.paa";
					_button_toolTip =  format
					[
						"FIRE GUNSHIP AUTOCANNON - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};
				



				
				case ("COUNTERMEASURES") : {
					_imageColorCode = [1,1,1,1];
					_params = [];

					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];

						{
							private _gp = _x;
							_gpDrivers = (units _gp) select {
								_oP = objectParent _x;
								!isNull _oP && {
									_x == driver _oP
								};
							};
							_gpVehicles = _gpDrivers apply {objectParent _x};
							{
								// if ([_x, 0] call A3C_FireCounterMeasures) exitWith {
								// 	[_x, 1] call A3C_FireCounterMeasures;
								// };
								[[_x, 1], A3C_FireCounterMeasures] remoteExec ['bis_fnc_call', _x];
								// [_x, 1] call A3C_FireCounterMeasures; //-- includes checks anyways, no need to run fnc twice
							} foreach _gpVehicles;
						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;


						_gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						_leaderVic = vehicle leader _gp;
						[_leaderVic, 1] call A3C_FireCounterMeasures;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_counterSmoke.paa";
					_button_toolTip =  "FIRE COUNTER MEASURES / CONCEALMENT";
				};
				
				case ("UGLSHOT") : {


					_imageColorCode = if (A3C_Prevent_UGLSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						'A3C_Prevent_UGLSHOT',
						'\a3c_ui\crosshairs\icon_crosshair_remote_UGL.paa',
						"UGLSHOT"
					] call A3C_UI_RADIAL_fnc_RemFire_EH;

					_button_IMG = "\a3c_ui\menu\icon_menu_action_remote_UGL.paa";
					_button_toolTip =  format
					[
						"FIRE UGL GRENADE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];


				};
				case ("ATSHOT") : {
					_imageColorCode = if (A3C_Prevent_ATSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						'A3C_Prevent_ATSHOT',
						'\a3c_ui\crosshairs\icon_crosshair_remote_AT.paa',
						"ATSHOT"
					] call A3C_UI_RADIAL_fnc_RemFire_EH;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_remote_AT.paa";
					_button_toolTip =  format
					[
						"FIRE AT-ROCKET - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];


				};
				case ("STATICSHOT") : {
					_imageColorCode = if (A3C_Prevent_STATICSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc =
					[
						'A3C_Prevent_STATICSHOT',
						'\a3c_ui\crosshairs\icon_crosshair_remote_StaticAT.paa',
						"STATICSHOT"
					] call A3C_UI_RADIAL_fnc_RemFire_EH;
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_remote_StaticAT.paa";
					_button_toolTip =  format
					[
						"FIRE STATIC ROCKET LAUNCHER - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];


				};
				case ("ORDER_DETO") : {
					_params = [];

					_buttonFnc = {
						[] call A3C_UI_RADIAL_OBJECTSELECTOR_START_CHARGEDIALOG;
						A3C_HC_DetoTrigger_Units = nil; //~~ this whole var stoll needed?
					};

					_button_IMG = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";
					_button_toolTip = "MANAGE EXPLOSIVES";


				};

				case ("VEHICLE") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						//systemChat str _clickData;
						[_clickData select 1,_clickData select 5] spawn A3C_HC_VEHICLEBOARD;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_vehicleboard.paa";
					_button_toolTip = "ASSIGN AND UNASSIGN VEHICLES. LMB to ASSIGN. RMB TO UNASSIGN. CTRL+RMB TO UNLOAD CARGO GROUPS";
				};

				case ("VEHICLE_REBOARD") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_reBoard.paa";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if (_isRadial) then {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						};
						[A3C_SELECTED_HC_GROUPS_SETTINGS] spawn A3C_HC_REBOARD;
					};
					_button_toolTip = "Re-Board group(s) to previous vehicle(s)";
				};

				
				case ("CHARGE_MAVIC") : {
					_params = [];
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_changeBattery.paa";
					_buttonFnc = {
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100040}};
						private _isRadial = _a3c_dsp == 100040;
						if (_isRadial) then {
							//-- no actual action - just close menu
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
						} else {
							{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
							(findDisplay 12 displayCtrl 51) ctrlEnable true;
						};
						if (isClass (configFile >> "CfgVehicles" >> "mavic_3_BLU")) then {
							private _nearMavics = (player nearobjects 2) select {"mavic" in (toLower (typeOf _x))};
							if !(_nearMavics isEqualTo []) then {
								private _selectedDrone = _nearMavics select 0;
								[_selectedDrone, player] call mavic_fnc_changeBattery;
							};
						} else {
							private _nearMavics = (player nearobjects 2) select {"mavik" in (toLower (typeOf _x))};
							if !(_nearMavics isEqualTo []) then {
								private _selectedDrone = _nearMavics select 0;
								[_selectedDrone, player] call mavic_fnc_changeBattery;
							};
						};
						
					};
					_button_toolTip = "Change Mavic-3 Batteries";
				};

				case ("HELI_OVERWATCH") : {
					
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
						private _isRadial = _a3c_dsp == 100040;
						
						private _var = (vehicle leader _group) getVariable ["A3C_Freeze_helicopter",[false,0]];


						if (_var select 0) then {
							//-- cancel action
							if !(_isRadial) then {
								{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
								(findDisplay 12 displayCtrl 51) ctrlEnable true;
							};
							{
								_vehicle = vehicle _x;
								if (_x == driver _vehicle && {[_vehicle] call A3C_isAttackHelicopter}) then {
									_vehicle setVariable ["A3C_Freeze_helicopter",[false,0],true];
									{_vehicle enableAI _x; } foreach ["TARGET","PATH"];
									//systemchat 'off';
								};
							} foreach (units _group);
						/*
						} else {
							A3C_OBJECTSELECTOR_MODE = "HELI_OVERWATCH_1";
							_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
							_text = findDisplay _a3c_dsp displayCtrl 800802;
							_listBox = findDisplay _a3c_dsp displayCtrl 800803;

							if (_isRadial) then {
								[] call A3C_RADIAL_CloseDisplay;
								with uiNamespace do {
								//disableSerialization;
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
								(findDisplay 100060) displayAddEventhandler
									[
										"KeyUp",
										{
											[_this] spawn {
												_button = _this select 0;
												_button = _button - [(_button select 0)];
												if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
													A3C_DISABLE_RADIAL = false;
													(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
													(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
													(findDisplay 100060) closeDisplay 0;
													A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
													{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
												};
											};
										}
									];
								};
							} else {
								(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
								_parent ctrlShow true;
								_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
								_parent ctrlCommit 0;
								_parent ctrlShow true;
								{
									_ctrlPos = ctrlPosition _x;
									_ctrlPos set [3,(_ctrlPos select 3) + (  (4)   * (0.0440051 * safezoneH) )];
									_x ctrlSetPosition _ctrlPos;
									_x ctrlCommit 0;
								} foreach [_parent,_listBox];
							};
							//if (true) exitWith {};
							_text ctrlSetText "Select Hover Height";
							
							lbClear _listBox;
							{
								[_listBox, _x] call A3C_addLbEntry;
							} foreach ["100","200","500","1000"];
							
						*/
						};


						
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_HELI_OVERWATCH.paa";
					_button_toolTip = "FORCE ATTACK HELI TO HOVER IN PLACE";
				};


				

				case ("UAV_FPV") : {
					_imageColorCode = [1,1,1,1]; //if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						A3C_DISABLE_RADIAL = true;
						[] call A3C_RADIAL_CloseDisplay;
						A3C_UI_HUD_3D_TAG_ICON_TYPE = '\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa'; //"\a3c_ui\menu\icon_menu_action_repair.paa";


						[
							46,
							'SPACE',
							{

								count A3C_RD_UNITS > 0
							},
							{
								_wpPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);

								[_wpPos,''] spawn A3C_UI_HUD_3D_TAG;
								private _group = A3C_RD_UNITS select 0;
								//-- delete current waypoints
								while {(count (waypoints _group)) > 1} do {
									{
										if (_forEachIndex > 0) then {
											deletewaypoint _x;
										};
									} foreach waypoints _group;
								};
								_ct = cursortarget;
								if (!isNull _ct) then {
									_wp = _group addWaypoint [_wpPos,0];
									_wp setWaypointType "SCRIPTED";
									_wp waypointAttachVehicle _ct;
									_wp setWaypointSpeed "FULL";

									_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_UAV_FPV.sqf [getPlayerUID player]"; 
									//[cursortarget, getPlayerUID player]
								} else {
									hint "NO TARGET SELECTED!";
									sleep 3;
									hintSilent "";
								};
								
							},
							{
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
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
							},
							{
								if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								};
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								A3C_UI_HUD_3D_TAG_reposition = false;
								A3C_UI_RADIAL_Current_Remfire_Units = [];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;
						A3C_UI_HUD_3D_TAG_reposition = true;



					};

					_button_IMG = 'A3C_CORE\ui\pictures\icon_menu_action_UAV_FPV.paa';
					_button_toolTip =  format
					[
						"FPV ATTACK - KEEP %1 PRESSED. CONFIRM TARGET WITH 'Spacebar' OR CANCEL BY RELEASING %1.",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};
			

				case ("REPAIR") : {
					_imageColorCode = if (A3C_Prevent_TANKSHOT) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_params = [];

					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						A3C_DISABLE_RADIAL = true;
						[] call A3C_RADIAL_CloseDisplay;
						A3C_UI_HUD_3D_TAG_ICON_TYPE =  "\a3c_ui\menu\icon_menu_action_repair.paa";


						[
							46,
							'SPACE',
							{

								count A3C_RD_UNITS > 0
							},
							{
								_wpPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);

								[_wpPos,''] spawn A3C_UI_HUD_3D_TAG;
								private _group = A3C_RD_UNITS select 0;
								//-- delete current waypoints
								while {(count (waypoints _group)) > 1} do {
									{
										if (_forEachIndex > 0) then {
											deletewaypoint _x;
										};
									} foreach waypoints _group;
								};
								_wp = _group addWaypoint [_wpPos,0];
								_wp setWaypointType "SCRIPTED";
								_wp setWaypointScript "A3C_CORE\fnc_AI\wpFncs\wpScript_repair.sqf [getPlayerUID player, ['ARRIVAL', 0]]";
							},
							{
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								//(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
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
							},
							{
								if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								};
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								A3C_UI_HUD_3D_TAG_reposition = false;
								A3C_UI_RADIAL_Current_Remfire_Units = [];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;
						A3C_UI_HUD_3D_TAG_reposition = true;



					};

					_button_IMG = '\a3c_ui\menu\icon_menu_action_repair.paa';
					_button_toolTip =  format
					[
						"REPAIR VEHICLES - KEEP %1 PRESSED. CONFIRM LOCATION WITH 'Spacebar' OR CANCEL BY RELEASING %1. REPAIR RADIUS: 100m",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};


				case ("LANDING") : {
					_params = [] ;
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _doSpecifyLandingPos = (
							{
								private _gp = _x;
								_leaderVic = vehicle leader _gp;
								_isRotor = ((getNumber (configfile >> "CfgVehicles" >> typeOf _leaderVic >> "landingSpeed")) < 10);
								_isRotor
							} count A3C_SELECTED_HC_GROUPS_SETTINGS > 0
						);

						if (_doSpecifyLandingPos) then {
							if (!isNull findDisplay 100040) then {
								A3C_UI_HUD_3D_TAG_ICON_TYPE =  "";
								A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
								A3C_DISABLE_RADIAL = true;


								//("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["A3C_KEY_VIEWER_UI","PLAIN"];
								//((uiNamespace getVariable "A3C_KEY_VIEWER_UI") displayCtrl 11) ctrlSetText "DRAG OBJECT ON BUILDING OR ROOF. ROTATE WITH MOUSEWHEEL. RELEASE TAB TO CANCEL. CONFIRM WITH SPACEBAR";


								_vehicleType = "A3C_HeliPad";
								{
									_leaderVic = vehicle leader _x;
									if (_leaderVic isKindOf "Helicopter") exitWith {
										_vehicleType = typeOf _leaderVic;
									};
								} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
								[] call A3C_RADIAL_CloseDisplay;
								//_vehicle = createSimpleObject
								//[
								//	getText (configfile >> "CfgVehicles" >> _vehicleType >> "model"),
								//	[0,0,100],
								//	true
								//]; //
								_vehicle = _vehicleType createvehicleLocal [0,0,100]; //
								_vehicle allowdamage false;
								_vehicle enableSimulation false;
								_vehicle disableCollisionWith player;
								_vehicle hideObject true;
								_tPos = ([screenToWorld [0.5,0.5],[0,100]] call MCSS_fnc_getSafePos);
								if (!isNil '_tPos' && {count _tPos > 0}) then {
									_vehicle setpos _tPos;
								};
								_vehicle disableCollisionWith cursortarget;
								sleep 0.2;
								_vehicle hideObject false;
								A3C_OBJECTPLACER = _vehicle; //-- naming delay is necessary so object does not get moved by HUDdraw script immediately to be destroyed
								if (_vehicleType != "A3C_HeliPad") then {
									for "_i" from 0 to 10 do {
										A3C_OBJECTPLACER setObjectTexture [0, "#(rgb,8,8,3)color(0.5,0.1,1,1)"];
									};
								};
								[
									46,
									'SPACE',
									{

										count A3C_RD_UNITS > 0
									},
									{


										A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

										//("A3C_KEY_VIEWER_UI" call BIS_fnc_rscLayer) cutRsc ["","PLAIN"];
										with uiNamespace do {
											//disableSerialization;
											A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
											(findDisplay 100060) displayAddEventhandler
											[
												"KeyUp",
												{
													[_this] spawn {
														_button = _this select 0;
														_button = _button - [(_button select 0)];
														if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
															A3C_DISABLE_RADIAL = false;
															(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
															(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
															(findDisplay 100060) closeDisplay 0;
															A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
															{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
														};
													};
												}
											];

										};


										private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
										_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
										_text = findDisplay _a3c_dsp displayCtrl 800802;
										_listBox = findDisplay _a3c_dsp displayCtrl 800803;

										_text ctrlSetText "CHECKING LZ";
										lbClear _listBox;
										[_listBox, "KEEP TAB PRESSED DOWN"] call A3C_addLbEntry;




										_parent ctrlShow true;


										_requiresPlacementCorrection = true;
										_placerPos = getPosASL A3C_OBJECTPLACER;
										private _landingPosRoot = +(_placerPos);
										private _landingVector = [getDir A3C_OBJECTPLACER] call MCSS_fnc_DegreeToVector;

										_dimensions = [typeof A3C_OBJECTPLACER] call A3C_getVehicleBodyDimensions;
										_dimensions params ["_reference_Width","_reference_Length","_reference_Height","_reference_Rotorsize"];

										_forceDefaultLanding = true;

										_exit = false;
										if (!isNull A3C_SNAP_OBJECT) then {
											//-- position snapped against object

											//systemchat str (typeof A3C_SNAP_OBJECT);

											_placerPosZ = _placerPos select 2;
											_snapObjectPos = (getPosASL A3C_SNAP_OBJECT);

											_snapObjectZ = _snapObjectPos select 2;
											_snapObjectHeight = A3C_SNAP_OBJECT call BIS_fnc_objectHeight;

											_refPosTop = (_placerPos select [0,2]) + [_snapObjectZ + _snapObjectHeight]; //-- placer-pos at boundingBox top

											_ins = lineIntersectsSurfaces
											[
												_refPosTop,
												[_placerPos select 0,_placerPos select 1, 0],
												A3C_OBJECTPLACER,
												objNull,
												true,
												1,
												"GEOM",
												"NONE"
											];

											if (count _ins > 0) then {
												//helper setposASL ((_ins select 0) select 0);
												_intersectPosZ = ((_ins select 0) select 0) select 2;
												//systemchat str [_intersectPosZ,_placerPosZ];
												if (abs(_intersectPosZ - _placerPosZ) < 0.1) then {
													_requiresPlacementCorrection = false;
													_forceDefaultLanding = false;

												};
												if (_requiresPlacementCorrection) then {
													hint "ADJUSTING LZ";
													_LZData = [A3C_SNAP_OBJECT,_reference_Width,_reference_Length] call A3C_getHeliRoofLZ;
													[] spawn {
														hint "LZ ADJUSTED";
														sleep 5;
														hintSilent "";
													};
													if (count _LZData > 0) then {
														_landingPosRoot = _LZData select 0;
														_landingVector = [(_LZData select 1)] call MCSS_fnc_DegreeToVector;
														_forceDefaultLanding = false;




													};


													//systemchat str _LZData;
												};
											//} else {
											//	systemchat "NO INS";
											};
										} else {
											//-- position in the open
											_forceDefaultLanding = false;
											_requiresPlacementCorrection = false;
											_dummyBox = ([A3C_OBJECTPLACER,1] call MCSS_fnc_BBOX);
											_maxRotorHeight = 1000;
											{

												_z = (A3C_OBJECTPLACER modelToWorld (A3C_OBJECTPLACER selectionposition _x)) select 2;
												//systemchat str [_z];
												if (_z < _maxRotorHeight) then {
													_maxRotorHeight = _z;
												};
											} foreach ([A3C_OBJECTPLACER] call MCSS_fnc_getMainRotorSelections);

											_centerAtRotorHeight = getPosASL A3C_OBJECTPLACER;
											_centerAtRotorHeight set [2,_maxRotorHeight];
											_centerAtRotorHeight = ATLtoASL _centerAtRotorHeight;
											{
												_dist = A3C_OBJECTPLACER distance2d _x;
												_dir = A3C_OBJECTPLACER getDir _x;
												_ins = lineIntersectsSurfaces
												[
													_centerAtRotorHeight,
													[_centerAtRotorHeight,_dist,_dir] call BIS_fnc_relPos,
													A3C_OBJECTPLACER,
													objNull,
													true,
													1,
													"GEOM",
													"NONE"
												];
												if (count _ins > 0) exitWith {
													_exit = true;
												};
											} foreach _dummyBox;
										};

										if (_exit) exitWith {
											hint "THE SELECTED GROUND-LZ IS NOT SAFE - PLEASE REPEAT";
											sleep 5;
											hintSilent "";
											//deletevehicle A3C_OBJECTPLACER;
										};



										if !(_requiresPlacementCorrection) then {
											//systemchat "GOOD PLACEMENT";
											//-- could be on roof (!isNull snap_object) but might still need security checks
											//-- could be on ground and use same checks
										} else {
											//if !(_forceDefaultLanding) then {

											//};
											//systemchat "LZ WILL BE ADJUSTED";
											//-- snap_object detected and definitely requires correction
											//-- if (!isNull snap_object), use rooftop position generator
											//-- otherwise use simple, ASL-level security
										};



										if (_forceDefaultLanding) then {
											[] spawn {
												hint "ALERT: NO SUITABLE LZ FOUND ON OBJECT. REVERTING TO DEFAULT LANDING";
												sleep 5;
												hintSilent "";
											};
											A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

										};

										A3C_RADIAL_ACTION_HC_LANDINGDATA = [_landingPosRoot,_landingVector,_forceDefaultLanding];

										A3C_OBJECTSELECTOR_MODE = "HELI_LANDING_HC_TYPE";



										_text ctrlSetText "SELECT LANDING TYPE";

										{
											_ctrlPos = ctrlPosition _x;
											_ctrlPos set [3,(_ctrlPos select 3) + (  (3)   * (0.0440051 * safezoneH) )];
											_x ctrlSetPosition _ctrlPos;
											_x ctrlCommit 0;
										} foreach [_parent,_listBox];

										ctrlSetFocus _listBox;
										
										lbClear _listBox;
										{
											[_listBox, _x] call A3C_addLbEntry;
										} foreach ["COMBAT LANDING","TRANSPORT UNLOAD","FULL LANDING"];
										
									},
									{
										deleteVehicle A3C_OBJECTPLACER; //A3C_OBJECTPLACER = nil;
										(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
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
									},
									{
										if (!isNull A3C_OBJECTPLACER) then {
											deleteVehicle A3C_OBJECTPLACER; //A3C_OBJECTPLACER = nil;
											A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
											(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
										};
										//A3C_UI_HUD_3D_TAG_ICON_TYPE = "";

										(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];

										A3C_UI_HUD_3D_TAG_reposition = false;
									},
									true
								] call A3C_UI_RADIAL_ADD_EH_MACROS;
								A3C_UI_HUD_3D_TAG_reposition = true;
							} else {
								//-- specify mapclick
							};
						} else {
							{
								{
									_v = vehicle _x;
									if (_x == driver _v && {_v isKindof "AIR"}) then {
										if ((getPosATL _v) select 2 > 1) then {
											[_v,"LAND"] remoteExec ["land",_v];
										};
									};
								} foreach units _x;
							} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_landing.paa";
					_button_toolTip = "LAND AIRCRAFT";
				};

				case ("CAS-STRIKE") : {
					_params = [] ;
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];

						if (!isNull findDisplay 100040) then {
							A3C_UI_HUD_3D_TAG_ICON_TYPE = '\a3c_ui\crosshairs\icon_crosshair_CAS.paa';
							A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							[
								46,
								'SPACE',
								{

									count A3C_RD_UNITS > 0
								},
								{


									with uiNamespace do {
										//disableSerialization;
										A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
										(findDisplay 100060) displayAddEventhandler
										[
											"KeyUp",
											{
												[_this] spawn {
													_button = _this select 0;
													_button = _button - [(_button select 0)];
													if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
														A3C_DISABLE_RADIAL = false;
														(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
														(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
														(findDisplay 100060) closeDisplay 0;
														A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
														{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
														A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
													};
												};
											}
										];

									};


									private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
									_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
									_text = findDisplay _a3c_dsp displayCtrl 800802;
									_listBox = findDisplay _a3c_dsp displayCtrl 800803;

									A3C_OBJECTSELECTOR_MODE = "CAS";

									_text ctrlSetText "SELECT CAS-TYPE";



									

									lbClear _listBox;
									{
										_leaderVic = vehicle leader _x;
										_casModes = [typeof _leaderVic] call MCSS_fnc_getCASmodes;
										if (count _casModes > 0) exitWith {
											{
												_casMode = switch (true) do {
													case (_x isEqualTo ["machinegun"]) : {'GUN RUN'};
													case (_x isEqualTo ["missilelauncher"]) : {'MISSILES'};
													case (_x isEqualTo ["machinegun","missilelauncher"]) : {'GUNS + MISSILES'};
													case (_x isEqualTo ["bomblauncher"]) : {'BOMBING RUN'};
												};
												[_listBox, _casMode] call A3C_addLbEntry;
											} foreach _casModes;
										};
									} foreach A3C_RD_UNITS;
									




									{
										_ctrlPos = ctrlPosition _x;
										_ctrlPos set [3,(_ctrlPos select 3) + (  (3)   * (0.0440051 * safezoneH) )];
										_x ctrlSetPosition _ctrlPos;
										_x ctrlCommit 0;
									} foreach [_parent,_listBox];

								},
								{
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
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
								},
								{
									if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
										(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
									};
									if !(A3C_UI_HUD_3D_TAGGING) then {
										A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									};
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
									A3C_UI_HUD_3D_TAG_reposition = false;
									A3C_UI_RADIAL_Current_Remfire_Units = [];
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
							A3C_UI_HUD_3D_TAG_reposition = true;

						} else {
							//-- specify mapclick
						};

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_CAS.paa";
					_button_toolTip =  format
					[
						"ORDER CAS-STRIKE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};


				case ("RAPPEL") : {
					_params = [] ;
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];

						if (!isNull findDisplay 100040) then {
							A3C_UI_HUD_3D_TAG_ICON_TYPE = "\A3C_UI\menu\icon_menu_action_Rappel.paa";
							A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							A3C_OBJECTPLACER = "A3C_HeliPad" createvehicleLocal [0,0,0]; // "Land_JumpTarget_F"
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
									[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
									{
										private _gp = _x;

										_gp setvariable ["A3C_UNIT_POLYS",[],true];

										//-- clear all waypoints
										{
											{
												_x setVariable ["A3C_CLEARING",false,true];
											} foreach (units _x);
										} foreach A3C_SELECTED_UNITS;


										_gp = A3C_RD_UNITS select 0;
										while {(count (waypoints _gp)) > 1} do {
											{
												if (_forEachIndex > 0) then {
													deletewaypoint _x;
												};
											} foreach waypoints _gp;
										};
										
										//-- add new waypoints
										private _leaderVic = (vehicle leader _gp);
										private _rappelWPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);
										private _startPos = getpos _leaderVic;
										private _landOnReturn = !isEngineOn _leaderVic;
										_wp =
										[
											_gp,
											_rappelWPos
										] call A3C_HC_ADD_WP;
										if (A3C_UI_HUD_3D_TAG_ICON_POS distance2D _leaderVic > 50) then {
											_wp2 =
											[
												_gp,
												_startPos
											] call A3C_HC_ADD_WP;
											if (_landOnReturn) then {
												_statements = format
												[
													"
														[this,%1,'%2',[],true] spawn A3C_HC_WPACTION_LANDING_FULL;
													",
													_startPos,
													getPlayerUID player

												];
												_wpStm = waypointStatements _wp2;
												_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
											};
										};
										if (_leaderVic distance2D _rappelWPos < 800) then {
											waitUntil {speed _leaderVic > 80  OR {_leaderVic distance2D _rappelWPos < 300} };
										};

										_statements = format
										[
											"
												[['%1',this,[['NONE','NONE'],'RAPPELL'],'LINE',(currentWaypoint group this),0],A3C_HC_INSERT_ACTION_WP] remoteExec ['bis_fnc_call',0];
											",
											getPlayerUID player
										];
										_wpStm = waypointStatements _wp;
										_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
									} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
								},
								{
									deleteVehicle A3C_OBJECTPLACER; //A3C_OBJECTPLACER = nil;
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
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
								},
								{
									if (!isNull A3C_OBJECTPLACER) then {
										deleteVehicle A3C_OBJECTPLACER; //A3C_OBJECTPLACER = nil;
										A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
										(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
									};
									//A3C_UI_HUD_3D_TAG_ICON_TYPE = "";

									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];

									A3C_UI_HUD_3D_TAG_reposition = false;
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
							A3C_UI_HUD_3D_TAG_reposition = true;
						} else {
							//-- map mode: immideate rappel for stationary vics (change to mapclick)
							{
								private _leader = leader _x;
								private _leaderVic = vehicle _leader;
								{
									_v = vehicle _x;
									if (_x == driver _v && { abs (speed _v) < 2 && {_v isKindof "HELICOPTER"}}) then {
										if ((getPosATL _v) select 2 > 1) then {
											if ((abs speed _v) < 1) then {
												[_v] call AR_Rappel_All_Cargo
											};
										};
									};
								} foreach units _x;
							} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";
					_button_toolTip = "";
					if (_a3c_dsp == 100040) then {
						_button_toolTip =  format
						[
							"RAPPEL CARGO - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1. Creates wp on destination and origin.",
							["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
						];
					} else {
						_button_toolTip = "RAPPEL CARGO";
					};
				};
				case ("PARADROP") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[objNull] call A3C_GP_Btn_Para;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";
					_button_toolTip = "DISCHARGE CARGO (PARA)";
				};
				case ("PARALOAD") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[objNull] call A3C_GP_Btn_Para;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_loadVehicle.paa";
					_button_toolTip = "LOAD VEHICLES IN CARGO";
				};
				case ("FLYINGHEIGHT") : {
					_params = []; 
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						//[] spawn A3C_HC_GroupMenu_fnc_SUPPRESSION; //-- button up??  / _specialParams_specialParams?
						private _group = if (!isNull findDisplay 100040) then {A3C_RD_UNITS select 0} else {A3C_SELECTED_HC_GROUPS_SETTINGS select 0}; //~~ same same??
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};




						if (_a3c_dsp == 100060) then {

							[
								46,
								'RADIAL',
								{

									true
								},
								{
								},
								{
									(findDisplay 100060) closeDisplay 0;
									(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;

							with uiNameSpace do {
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
								(findDisplay 100060) displayAddEventhandler
								[
									"KeyUp",
									{
										[_this] spawn {
											_button = _this select 0;
											_button = _button - [(_button select 0)];
											if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
												(findDisplay 100060) closeDisplay 0;
												(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
												A3C_DISABLE_RADIAL = false;
												A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];

											};
										};
									}
								];
							};
						};




						_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
						_text = findDisplay _a3c_dsp displayCtrl 800802;
						_listBox = findDisplay _a3c_dsp displayCtrl 800803;

						{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
						(findDisplay 12 displayCtrl 51) ctrlEnable true;
						A3C_OBJECTSELECTOR_MODE = "flyInHeight"; //-- !! CHECK IF STILL NEEDED!
						lbClear _listBox;
						_parent ctrlShow true;
						_textSize = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
						
										
						_text ctrlSetText "Select Flying-Height";
						
						_heightArray = A3C_FlyinHeightArrayHeli;
						if ((vehicle leader _group) isKindOf "PLANE") then {
							_heightArray = A3C_FlyinHeightArrayJet;
						};
						[_parent,_listBox,count _heightArray] call A3C_OBJECTSEL_RESIZE;
						{
							[_listBox, _x] call A3C_addLbEntry;
						} foreach _heightArray;
						


					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_flyInHeight.paa";
					_button_toolTip = "Change Flying Height";
				};
				case ("SUPPRESSION") : {
					_params = []; 
					_buttonFnc = {
						//params ["_clickData","_buttonArray","_specialParams"];

						[] spawn A3C_HC_GroupMenu_fnc_SUPPRESSION;

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";
					_button_toolTip = "";
					if (_a3c_dsp == 100040) then {
						_button_toolTip =  format
						[
							"SUPPRESSIVE FIRE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
							["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
						];
					} else {
						_button_toolTip = "SUPPRESSIVE FIRE - RELAY COORDINATES VIA MAPCLICK";
					};

				};
				case ("SUPPRESSION_STOP") : {
					_params = []; 
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						{
							private _gp = _x;
							{
								private _u = _x;
								if (_u in A3C_SUPPRESSION_UNITS_AI) then {
									[[_u],"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
								};
							} foreach units _gp;

						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
					};

					_button_IMG = "\a3\ui_f\data\IGUI\Cfg\Actions\ico_OFF_ca.paa";
					_button_toolTip =  "STOP SUPPRESSING";
				};

				case ("ARTY") : {
					_params = []; 
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];

						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};

						if (!isNull findDisplay 100040) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							A3C_UI_HUD_3D_TAG_ICON_TYPE = '\a3c_ui\crosshairs\icon_crosshair_remote_Artillery.paa';
							A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity;
							[
								46,
								'SPACE',
								{

									(count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""})
								},
								{
									A3C_HC_FOCUS_ARTY = objNull;
									A3C_HC_FOCUS_ARTY_AMMO = ""; //-- what is goin on here
									with uiNamespace do {
										A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
									};
									(findDisplay 100060) displayAddEventhandler
									[
										"KeyUp",
										{
											[_this] spawn {
												_button = _this select 0;
												_button = _button - [(_button select 0)];
												if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
													(findDisplay 100060) closeDisplay 0;
													A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
													{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
												};
											};
										}
									];
									A3C_HC_FOCUS_ARTY_POS = +(A3C_UI_HUD_3D_TAG_ICON_POS);
									["ARTY"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
									[] spawn {
										while {!isNull findDisplay 100060} do {
											sleep 0.5;
										};
										A3C_UI_HUD_3D_TAG_reposition = false;
										private _iconType = '\a3c_ui\crosshairs\icon_crosshair_remote_Artillery.paa';
										//-- mini flicker
										for "_i" from 1 to 2 do {
											A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
											sleep 0.1;
											A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
											sleep 0.1;
										};
										if (A3C_DISABLE_RADIAL) then {
											//-- Radial key not released - reIssue the icon for repeated orders
											A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
											A3C_UI_HUD_3D_TAG_reposition = true;
										} else {
											//-- Radial key released - abort
											A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
											A3C_UI_HUD_3D_TAG_reposition = false;
										}

									};
									
									// A3C_UI_HUD_3D_TAG_reposition = false;
								},
								{
									
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
								},
								{
									//-- in order to allow multiple successive arty orders, we remove confirm keybind when MENU key is released 
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
									(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_UI_HUD_3D_TAG_reposition = false;
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								},
								true
							] call A3C_UI_RADIAL_ADD_EH_MACROS;
							A3C_UI_HUD_3D_TAG_reposition = true;
						} else {
							[_a3c_dsp] spawn {
								params ["_a3c_dsp"];
								(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
								(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
								hintSilent "A3C: Please relay map-coordinates via mapclick!";
								playsound "TacticalPing4";
								sleep 0.5;
								if (visibleMap) then {
									A3C_isArtyAwaitingSuborder = true;
									
									
									private _currentSelection = +(A3C_SELECTED_UNITS);
									[
										"A3C_ARTY_MAPCLICK",
										"onMapSingleClick",
										{
											//-- test for right mouse button?
											_shift = _this select 3;
											A3C_HC_FOCUS_ARTY_POS = _pos;
											//[_pos,_shift] spawn A3C_ORDER_ARTILLERY;
											if !(_shift) then {
												A3C_isArtyAwaitingSuborder = false;
											};
											["ARTY"] call A3C_UI_MAP_Overlay_OPEN_OBJECTSELECTOR_MAP;
											
										} 
									] call BIS_fnc_addStackedEventHandler;

									waitUntil {!(A3C_isArtyAwaitingSuborder) OR {!visibleMap OR {!(_currentSelection isEqualTo A3C_SELECTED_UNITS)}}};
									A3C_isArtyAwaitingSuborder = false;
									["A3C_ARTY_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
								};
							};
						};

					};
					_button_IMG = "a3c_ui\menu\icon_menu_action_Artillery.paa";
					_button_toolTip = "";
					if (_a3c_dsp == 100040) then {
						_button_toolTip =  format
						[
							"FIRE ARTILLERY - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
							["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
						];
					} else {
						_button_toolTip = "FIRE ARTILLERY - RELAY COORDINATES VIA MAPCLICK";
					};

				};
				

				case ("RE-ARM") : {
					_params = [];
					_imageColorCode = [1,1,1,1];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						
						{[_x] spawn A3C_ReArm_Auto_Evaluate} foreach (units _gp);
						player groupradio 'SentCmdRearm';
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};

						if (!isNull findDisplay 100040) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							A3C_UI_RADIAL_EH_KEYUP_CANCEL = (findDisplay 46) displayAddEventHandler
							[
								"KeyUp",
								{
									_button = _this - [(_this select 0)];
									if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
										(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
										{inGameUISetEventHandler [_x, 'true']} foreach ['PrevAction','NextAction'];
										A3C_DISABLE_RADIAL = false;
									};
								}
							];

						} else {
							(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
							(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_reArm.paa";
					_button_toolTip = "RESUPPLY NEARBY";
				};


				case ("HEAL") : {
					_params = [];
					_imageColorCode = [1,1,1,1]; //if (_disableHeal) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[A3C_SELECTED_HC_GROUPS_SETTINGS select 0] call A3C_MEDICAL_START_HC;
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};

						if (!isNull findDisplay 100040) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							A3C_UI_RADIAL_EH_KEYUP_CANCEL = (findDisplay 46) displayAddEventHandler
							[
								"KeyUp",
								{
									_button = _this - [(_this select 0)];
									if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
										(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
										{inGameUISetEventHandler [_x, 'true']} foreach ['PrevAction','NextAction'];
										A3C_DISABLE_RADIAL = false;
									};
								}
							];
						} else {
							(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
							(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_Medical.paa";
					_button_toolTip = "MEDICAL ATTENTION";
				};
				
				case ("OWNERSHIP") : {
					_params = [];
					_imageColorCode = [1,1,1,1]; //if (_disableHeal) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];

						private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						private _transferFnc = {
							params ["_clientID","_group"];

							if (groupOwner _group != _clientID) then {
								//-- transfer ownership to client
								_group setGroupOwner _clientID;
								(format ["%1 has been transfered to your client", groupID _group]) remoteExec ['systemchat',_clientID];
							} else {
								//-- transfer ownership to server
								_group setGroupOwner 2;
								(format ["%1 has been transfered to the server", groupID _group]) remoteExec ['systemchat',_clientID];
							};
						};

						[[clientOwner, _group], _transferFnc] remoteExec ['bis_fnc_call', 2];
						private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};

						if (!isNull findDisplay 100040) then {
							A3C_DISABLE_RADIAL = true;
							[] call A3C_RADIAL_CloseDisplay;
							A3C_UI_RADIAL_EH_KEYUP_CANCEL = (findDisplay 46) displayAddEventHandler
							[
								"KeyUp",
								{
									_button = _this - [(_this select 0)];
									if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
										(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
										{inGameUISetEventHandler [_x, 'true']} foreach ['PrevAction','NextAction'];
										A3C_DISABLE_RADIAL = false;
									};
								}
							];
						} else {
							(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow false;
							(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_transferOwner.paa";
					_button_toolTip = if (local (A3C_SELECTED_HC_GROUPS_SETTINGS select 0)) then {"TRANSFER OWNERSHIP TO SERVER"} else {"CLAIM OWNERSHIP"};
				};
				case ("UNSTUCK") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[] call A3C_HC_UNSTUCK;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_unstuck.paa";
					_button_toolTip = "Unstuck/Unflip units and vehicles";
					//systemchat 'hmm';
				};
				case ("PLACE_CHARGE_HC") : {

					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];


						A3C_UI_HUD_3D_TAG_ICON_TYPE = '\a3c_ui\crosshairs\icon_crosshair_explosives_Place.paa';
						A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
						A3C_DISABLE_RADIAL = true;
						[] call A3C_RADIAL_CloseDisplay;

						A3C_UI_RADIAL_Current_Remfire_Units = +(A3C_HC_DetoShot_Units);


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

								//if !((A3C_RadialMenu_KEY_ID select 0)in A3C_DOWNKEYS) exitWith {};
								//A3C_DOWNKEYS = A3C_DOWNKEYS - [(A3C_RadialMenu_KEY_ID select 0)];
								//A3C_UI_HUD_3D_TAG_reposition = false;


								if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {


									_doRefreshGroupSelected = false;
									with uiNamespace do {
										//disableSerialization;
										A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
										(findDisplay 100060) displayAddEventhandler
										[
											"KeyUp",
											{
												[_this] spawn {
													_button = _this select 0;
													_button = _button - [(_button select 0)];
													if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
														A3C_DISABLE_RADIAL = false;
														A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
														(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];
														(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
														(findDisplay 100060) closeDisplay 0;
														A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
														{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
													};
												};
											}
										];

									};

									private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
									_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
									_text = findDisplay _a3c_dsp displayCtrl 800802;
									_listBox = findDisplay _a3c_dsp displayCtrl 800803;

									A3C_OBJECTSELECTOR_MODE = "PLACE_CHARGE_HC";
									_parent ctrlShow true;
									_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
									_parent ctrlCommit 0;
									_text ctrlSetText "Place Charge";

									if (count A3C_REMFIRE_MAGTYPES > 4) then {
										_parentPos = ctrlPosition _parent;
										_parentPos set[3,(_parentPos select 3) + (  ((count A3C_REMFIRE_MAGTYPES) - 4)   * (0.0440051 * safezoneH) )];
										_parent ctrlSetPosition _parentPos;
										_parent ctrlCommit 0;
									};
									
									ctrlSetFocus _listBox;
									
									lbClear _listBox;
									{
										private _lbText = (getText (configfile >> "CfgMagazines" >> _x >> "displayName"));
										[_listBox, _lbText] call A3C_addLbEntry;
									} foreach A3C_REMFIRE_MAGTYPES;
									[_parent,_listBox, count A3C_REMFIRE_MAGTYPES] call A3C_OBJECTSEL_RESIZE;
									


									[] spawn {
										sleep 0.1;
										while {!isNull findDisplay 100060} do {

											sleep 0.5;
										};
										if (A3C_UI_HUD_3D_TAG_ICON_TYPE == "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa") then {
											A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
										};
									};

								} else {
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								};

							},
							{

								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
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

								//[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
							},
							{
								if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
									(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								};
								if !(A3C_UI_HUD_3D_TAGGING) then {
									A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
								};
								
								(findDisplay 46) displayRemoveEventHandler ['KeyUp', A3C_UI_RADIAL_EH_KEYUP_CANCEL];

								A3C_UI_HUD_3D_TAG_reposition = false;
								A3C_UI_RADIAL_Current_Remfire_Units = [];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;
						A3C_UI_HUD_3D_TAG_reposition = true;

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_explosives_Place.paa";
					_button_toolTip =  format
					[
						"PLACE EXPLOSIVE - KEEP %1 PRESSED. CONFIRM WITH 'Spacebar' OR CANCEL BY RELEASING %1",
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];


				};
				case ("STATIC_ASSEMBLE_HC") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[] call A3C_RADIAL_CloseDisplay;
						A3C_DISABLE_RADIAL = true;
						[
							46,
							'SPACE',
							{

								!isNull A3C_OBJECTPLACER
							},
							{
								{
									private _units = _x select 0;
									private _weapon = _x select 1;
									private _var = [];
									if (_weapon == typeOf A3C_OBJECTPLACER) exitWith {
										//-- clear all waypoints
										{
											{
												_x setVariable ["A3C_CLEARING",false,true];
											} foreach (units _x);
										} foreach A3C_SELECTED_UNITS;

										
										_gp = A3C_RD_UNITS select 0;
										while {(count (waypoints _gp)) > 1} do {
											{
												if (_forEachIndex > 0) then {
													deletewaypoint _x;
												};
											} foreach waypoints _gp;
										};
										_wp =
										[
											_gp,
											position A3C_OBJECTPLACER
										] call A3C_HC_ADD_WP;

										_var = _gp getvariable ["A3C_UNIT_POLYS",[]];

										_prefix = 'ASS'; //-- ASS stands for 'assemble' you cheeky little kitten.
										_tPos = position A3C_OBJECTPLACER;
										_tpos set [2,0]; //==-- security mechanic: sometimes z-value is missing! ~~// does that apply here?

										_tPos = _tPos getPos [50, getDir A3C_OBJECTPLACER];

										if !(A3C_HC_PREVENT_POLY) then {
											_polygon = [];
											//if !(A3C_HC_EDIT_ACTION == "ASSEMBLE WEAPON") then {
												//-- action is NOT assembling weapon. create VISIBLE polygon
												_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],currentWaypoint _gp]] + ([_tPos,getDir A3C_OBJECTPLACER,"ASSEMBLE WEAPON",true] call A3C_SUP_CREATE_POLY));
											//} else {
												//-- action IS assembling weapon. create INVISIBLE polygon
											//	_polygon = ([[_tPos,format ["A3C_%1_MAIN_Mark_%2_%3",parsetext _prefix,getPlayerUID player,A3C_SUP_POLY_IND_MARK],_indSel]] + ( [[_tPos,_tPos,_tPos,_tPos],["","","",""],0]) );
											//};
											A3C_SUP_POLY_IND_MARK = A3C_SUP_POLY_IND_MARK + 1;
											_var pushback _polygon;
										};



										_statements = format
										[
											"

												['%1',this,%2,'%3',(currentWaypoint group this)] call A3C_HC_INSERT_ACTION_WP;
											",
											getPlayerUID player,
											[["NONE","NONE"],"ASSEMBLE WEAPON"],
											formation _gp
										];
										_wpStm = waypointStatements _wp;
										_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
										
										_gp setvariable ["A3C_UNIT_POLYS",_var,true];
										

										//-- create waypoint

										A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  _weapon >> "picture");
										A3C_UI_HUD_3D_TAG_ICON_MOD = "ON";
										[screentoWorld [0.5,0.5],""] spawn A3C_UI_HUD_3D_TAG;
										player commandRadio "SentAssemble";

									};
								} foreach A3C_STATIC_PACKS;
								deleteVehicle A3C_OBJECTPLACER;
							},
							{
								(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
							},
							false
						] call A3C_UI_RADIAL_ADD_EH_MACROS;

						[
							46,
							'RADIAL',
							{!isNull A3C_OBJECTPLACER},
							{
								(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
								deletevehicle A3C_OBJECTPLACER;
							},
							{
								(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
							},
							true
						] call A3C_UI_RADIAL_ADD_EH_MACROS;

						A3C_OBJECTSELECTOR_MODE = "STATIC_ASSEMBLE_HC";
						_staticData = [units (A3C_RD_UNITS select 0),"PLANNING"] call A3C_getSelectionBackpackStatics;
						if (count _staticData == 1) then {
							[0] call A3C_ObjectSelector_LB_Change;
						} else {
							with uiNamespace do {
								//disableSerialization;
								A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
								(findDisplay 100060) displayAddEventhandler
								[
									"KeyUp",
									{
										[_this] spawn {
											_button = _this select 0;
											_button = _button - [(_button select 0)];
											if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
												A3C_DISABLE_RADIAL = false;
												A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
												(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
												(findDisplay 100060) closeDisplay 0;
												A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
												{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
											};
										};
									}
								];
							};

							private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
							_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
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
					};
					_button_IMG = (gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "picture"));
					_button_toolTip =  format
					[
						"ASSEMBLE %1 - KEEP %2 PRESSED. SELECT A WEAPON, POSITION AND ROTATE IT (MOUSEWHEEL). PRESS 'SpaceBar' TO CONFIRM OR RELEASE %1 TO CANCEL ",
						(gettext(configFile >> "CfgVehicles" >> ((A3C_STATIC_PACKS select 0) select 1) >> "displayName")),
						["A3C","A3C_KeyFnc_Menu"] call MCSS_fnc_CBA_KEYBIND_TRANSLATION
					];
				};
				case ("STATIC_DISASSEMBLE_HC") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						[0] spawn A3C_HC_UnassembleWeapon;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_action_STATIC_Packing.paa";
					_button_toolTip = "Pack Static Weapon";
				};



				case ("PLOW_DEPLOY") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						private _leaderVic = vehicle (leader _gp);
						_leaderVic animatesource ['moveplow', 1];
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_LowerPlow.paa";
					_button_toolTip = "Deploy Mine-Plow";
				};
				case ("PLOW_RAISE") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						private _leaderVic = vehicle (leader _gp);
						_leaderVic animatesource ['moveplow', 0];
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_RaisePlow.paa";
					_button_toolTip = "Raise Mine-Plow";
				};
				case ("LINE_CHARGE") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
						private _leaderVic = vehicle (leader _gp);
						private _fnc_MCLC = {
							params ["_leaderVic"];
							[_leaderVic] execVM '\Bobcat_Fixed\scripts\LineCharge.sqf';
						};
						[[_leaderVic], _fnc_MCLC] remoteExec ['bis_fnc_spawn', _leaderVic];
						
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_Menu_LineCharge.paa";
					_button_toolTip = "Pack Static Weapon";
				};

				case ("ENGINE_OFF") : {
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						{
							[units _x] call A3C_fnc_engineOff;
						} foreach A3C_HC_engineOffUnits;

						//A3C_HC_engineOffUnits = [];

					};
					_button_IMG = "\a3\ui_f\data\IGUI\Cfg\Actions\engine_off_ca.paa";
					_button_toolTip = "Engine Off";
				};

				case ("VEHICLE_LIGHTS_OFF") : { 
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						{
							private _gp = _x;
							{
								private _vehicle = objectParent _x;
								if (!isNull _vehicle && {_x == driver _vehicle}) then {
									[_vehicle, 1] call A3C_Switch_Vehicle_Lights;
								};
							} foreach units _gp;
							_gp setVariable ["A3C_VehicleLightsOn",false,true];
						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_headlight_OFF.paa";
					_button_toolTip = "Vehicle Lights Off";
				};

				case ("VEHICLE_LIGHTS_ON") : { 
					_params = [];
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						{
							private _gp = _x;
							{
								private _vehicle = objectParent _x;
								if (!isNull _vehicle && {_x == driver _vehicle}) then {
									[_vehicle, 0] call A3C_Switch_Vehicle_Lights;
								};
							} foreach units _gp;
							_gp setVariable ["A3C_VehicleLightsOn",true,true];
						} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_headlight_ON.paa";
					_button_toolTip = "Vehicle Lights On";
				};

				
				case ("IR_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_IR) then {
							["ON"] spawn A3C_fnc_toggle_IR_STROBES;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};


					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR) then {"IR-strobes ON - stand by for last order instance to complete"} else {"IR-strobes ON"};
				};
				case ("IR_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_IR) then {
							["OFF"] spawn A3C_fnc_toggle_IR_STROBES;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRstrobe_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR) then {"IR-strobes OFF - stand by for last order instance to complete"} else {"IR-strobes OFF"};
				};

				case ("IR_POINTER_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR_Laser) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_IR_Laser) then {
							//["ON"] call A3C_fnc_toggle_IR_Lasers;
							["LASER","ON"] call A3C_fnc_toggle_WeaponAttachMent;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR_Laser) then {"IR-LASERS ON - stand by for last order instance to complete"} else {"IR-LASERS ON"};
				};
				case ("IR_POINTER_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_IR_Laser) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_IR_Laser) then {
							//["OFF"] call A3C_fnc_toggle_IR_Lasers;
							["LASER","OFF"] call A3C_fnc_toggle_WeaponAttachMent;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_IRlaser_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_IR_Laser) then {"IR-LASERS OFF - stand by for last order instance to complete"} else {"IR-LASERS OFF"};
				};
				case ("FLASHLIGHT_ON") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_Flashlight) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_Flashlight) then {
							["FLASHLIGHT","ON"] call A3C_fnc_toggle_WeaponAttachMent;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};
					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_OFF.paa";
					_button_toolTip = if (A3C_Prevent_attach_Flashlight) then {"FLASHLIGHT ON - stand by for last order instance to complete"} else {"FLASHLIGHT ON"};
					//systemchat 'allo?';
				};
				case ("FLASHLIGHT_OFF") : {
					_params = [];
					_imageColorCode = if (A3C_Prevent_attach_Flashlight) then {[1,1,1,0.3]} else {[1,1,1,1]};
					_buttonFnc = {
						params ["_clickData","_buttonArray","_specialParams"];
						if !(A3C_Prevent_attach_Flashlight) then {
							["FLASHLIGHT","OFF"] call A3C_fnc_toggle_WeaponAttachMent;
						} else {
							hint "Please wait for your last order instance to reach all units";
						};

					};
					_button_IMG = "A3C_CORE\ui\pictures\icon_menu_item_FlashLight_ON.paa";
					_button_toolTip = if (A3C_Prevent_attach_Flashlight) then {"FLASHLIGHT OFF - stand by for last order instance to complete"} else {"FLASHLIGHT OFF"};
				};

			};
			_buttonData = _btnArray select _foreachIndex;

			//[_a3c_dsp,_buttonData,_button_IMG,_button_toolTip] spawn {

			//	params ["_a3c_dsp","_buttonData","_button_IMG","_button_toolTip"];
				_buttonData params ["_btnBackgroundCtrl","_btnImageCtrl","_btnClickerCtrl"];

				//for "_i" from 1 to 10 do {


					(findDisplay _a3c_dsp displayCtrl _btnBackgroundCtrl) ctrlSetText "#(argb,8,8,3)color(0,0,0,0.4)";
					(findDisplay _a3c_dsp displayCtrl _btnImageCtrl) ctrlSetText _button_IMG;
					(findDisplay _a3c_dsp displayCtrl _btnImageCtrl) ctrlSetTextColor _imageColorCode;
					(findDisplay _a3c_dsp displayCtrl _btnClickerCtrl) ctrlSetToolTip _button_toolTip;
					if (_doToggle) then {
						{(findDisplay _a3c_dsp displayCtrl _x) ctrlShow true} foreach _buttonData;
					};

				//};

			//};
			if (_a3c_dsp == 100040) then {

				_buttonFnc = (str _buttonFnc) splitString "";
				_buttonFnc deleteAt 0;
				_buttonFnc deleteAt ((count _buttonFnc) -1);
				_buttonFnc = _buttonFnc joinString "";

				_buttonFnc = _buttonFnc + " [] spawn { sleep 0.1; [A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED] call A3C_MAP_fnc_GroupMenu_LabelActionButtons}; ";


				//systemchat str _buttonFnc;

				_buttonFnc = compile _buttonFnc;
				_val =  _foreachIndex + 1;
				call compile format
				[
					"
						A3C_OUTER_RING_BTN_fnc_%1 = [%2,%3];
					",
					_val,
					_params, //-- ~~ !!!!! is ALWAYS [], did not work with formatted stuff. does not hurt for now, but at some point clean up and remove params
					_buttonFnc
				];
			} else {
				call compile format
				[
					"
						A3C_MAP_fnc_GroupMenu_Action_BTN_FNC_%1 = ['%2',%3];
					",
					_foreachIndex,
					_params, //-- ~~ !!!!! is ALWAYS [], did not work with formatted stuff. does not hurt for now, but at some point clean up and remove params
					_buttonFnc
				];
			};


		};
	} foreach _actions;
	_actions
};


A3C_HC_GroupMenu_fnc_SUPPRESSION = {

	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	private _refUnits = A3C_SELECTED_UNITS;
	_remFire_units = [];
	if (!isNull findDisplay 100040) then {
		_a3c_dsp = 100040;
		_refUnits = A3C_RD_UNITS; //~~ has to be RD becasue it can also be called on squad units (subideal, maybe just have one array for everything. A3C_SELECTED_UNITS)
	};
	private _chatMessageParts = [];
	private _currentlySuppressingUnits = [];

	{
		private _group = _x;
		private _leaderVic = (vehicle leader _group);
		//if ({_x in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)} count units _group > 0) exitWith {
		//	_currentlySuppressingUnits = [];
		//	{
		//		if (_x in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) then {
		//			_currentlySuppressingUnits pushBackUnique _x;
		//		};
		//	} foreach (units _group);
		//	if (count _currentlySuppressingUnits > 0) then {
		//		[_currentlySuppressingUnits,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
		//	};
		//};
		if (_a3c_dsp in [100020,100030]) then {
			if (_group in _refUnits) then { //~~ ?? what does this do ecxactly? making sure that group menu switches the button pages?
				["HC"] call A3C_START_TABMODE;
			};
		};

		{

			if (_x == gunner vehicle _x && {(getArtilleryAmmo [vehicle _x]) isEqualTo []}) then {
				_canSuppress = true;
				switch (true) do {
					case (vehicle _x isKindOf "PLANE") : {
						_chatMessageParts pushBackUnique "Planes can not suppress. ";
						_canSuppress = false;
					};
					case (speed  (vehicle _x) > 1 && {vehicle _x isKindOf "HELICOPTER"}) : {
						_chatMessageParts pushBackUnique "Helicopters need to be stationary to suppress. ";
						_canSuppress = false;
					};
				};
				if (_x in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) then {
					_currentlySuppressingUnits pushBackUnique _x;
				};
				if (_canSuppress) then {
					_remFire_units pushBackUnique _x;
				};

			};
		} foreach (units _group);
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	private _chatMessageString = "";
	{
		_chatMessageString = _chatMessageString + _x;
	} foreach _chatMessageParts;
	systemchat _chatMessageString;

	//-- stop current suppression order before ordering a new one:
	if (count _currentlySuppressingUnits > 0) then {
		[_currentlySuppressingUnits,"SUPPRESSION"] call A3C_POLY_ACTION_OFF;
	};

	waituntil {{_x in A3C_SUPPRESSION_UNITS_AI} count _currentlySuppressingUnits == 0};

	A3C_UI_RADIAL_Current_Remfire_Units = []; //-- this time, remfire units are passed as GROUPS rather than UNITS.
	{
		A3C_UI_RADIAL_Current_Remfire_Units pushBackUnique (group _x);
	} foreach _remFire_units;

	//-- give new suppression order via the appropriate medium

	if (_a3c_dsp in [100020,100030]) then {

		systemchat "A3C: Please relay map-coordinates via mapclick!";
		sleep 0.5; //~~ small delay needed for mapclick
		A3C_HC_GroupMenu_SuppressionRequested = true;
		{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
		(findDisplay 12 displayCtrl 51) ctrlEnable true;
		[
			"A3C_SUP_MAPCLICK",
			"onMapSingleClick",
			{
				//_btn = _this select
				//systemchat str _this;
				_shift = _this select 3;
				A3C_HC_GroupMenu_SuppressionRequested = false;
				{
					[_x,_pos] call A3C_HC_Suppression_Immediate;
				} foreach A3C_UI_RADIAL_Current_Remfire_Units;
				["A3C_SUP_MAPCLICK", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
			}
		] call BIS_fnc_addStackedEventHandler;
	} else {
		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3c_ui\menu\icon_menu_action_suppression.paa";//
		A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity;

		[
			46,
			'SPACE',
			{true},
			{},
			{
				if (count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""}) then {
					{
						[_x,A3C_UI_HUD_3D_TAG_ICON_POS] call A3C_HC_Suppression_Immediate;
					} foreach A3C_UI_RADIAL_Current_Remfire_Units;
				};
				// systemchat 'WHooo';
				(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];

				A3C_HC_GroupMenu_SuppressionRequested = false;
				A3C_UI_HUD_3D_TAG_reposition = false;
				[A3C_UI_HUD_3D_TAG_ICON_POS,"SUPPRESSION"] spawn A3C_UI_HUD_3D_TAG;
			},
			false
		] call A3C_UI_RADIAL_ADD_EH_MACROS;

		[
			46,
			'RADIAL',
			{true},
			{},
			{
				if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
					(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CONFIRM];
				};
				(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
				A3C_UI_HUD_3D_TAG_reposition = false;
				A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
			},
			true
		] call A3C_UI_RADIAL_ADD_EH_MACROS;

		A3C_UI_HUD_3D_TAG_reposition = true;
	};
};







A3C_HC_UNSTUCK = {
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS != 1) exitWith {
		systemChat "A3C: Unstuck is only available for single selections";
	};
	private _gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	(units _gp) spawn A3C_UNSTUCK;

};



A3C_Map_HC_groupContext_OpenMenu = {
	params ["_group","_modeNum"];
	private ["_a3c_dsp"];
	A3C_HC_NearStatics = [];

	_a3c_dsp = if (visibleMap) then {100020} else {100030};

	
	

	_startBar = findDisplay _a3c_dsp displayCtrl 404040;
	_startText = findDisplay _a3c_dsp displayCtrl 404041;
	_startText ctrlSetText "CONNECTING";
	_startBar progressSetPosition 0.1;
	{
		_x ctrlShow true;
	} foreach [_startBar,_startText];



	_groupMenuCtrlsGroup = (findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT);
	_groupMenuCtrlsGroup ctrlShow false; //-- hide until dashboard is shown
	_groupMenuCtrlsGroup ctrlSetPosition 
	[
		0.5,
		0.3
	]; //_menuPos;
	_groupMenuCtrlsGroup ctrlCommit 0;
	//(findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT) ctrlShow true; 

	{
		if (isplayer leader _x && {!(leader _x == player)}) then { //&& {(leader _x) != player}  CHANGE THIS TO WORK ON PLAYER GROUP FOR SINGLE SELECTION!!
			A3C_SELECTED_HC_GROUPS_SETTINGS = A3C_SELECTED_HC_GROUPS_SETTINGS - [_x];
			systemchat format ["A3C: %1 is controlled by another player",_x];
		};
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 0) exitWith {};

	private _gp = grpNull;

	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		_gp = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
		//if (_gp == A3C_HC_FocusGroup) then {
		//	(findDisplay _a3c_dsp displayCtrl 800714) ctrlSetText "#(argb,8,8,3)color(0,0.3,0.6,1)";
		//} else {
			(findDisplay _a3c_dsp displayCtrl 800714) ctrlSetText "#(argb,8,8,3)color(0,0.3,0.6,0.2)";
		//};
		private _groupStance = _group getVariable ["A3C_GROUP_STANCE","AUTO"];
		[_groupStance] call A3C_GP_Btns_Stances; //-- WHY>?
	} else {
		(findDisplay _a3c_dsp displayCtrl 800714) ctrlSetText "#(argb,8,8,3)color(0,0.3,0.6,0.2)";
		for "_i" from 800724 to 800727 do {
			(findDisplay _a3c_dsp displayCtrl _i) ctrlSetTextColor [1,1,1,0.1];
		};
	};

	
	
	
	





	disableSerialization;
	// A3C_Map_HC_groupContext_Behaviour = "";
	// A3C_Map_HC_groupContext_CMode = "";
	// A3C_Map_HC_groupContext_Form = "";
	// A3C_Map_HC_groupContext_Color = "";

	//(finddisplay _a3c_dsp displayCtrl 800716) ctrlSetText  "";



	//////////////////////// -- aaa
	//systemchat str _mode;
	if (_modeNum == 0) then {
		A3C_Map_HC_groupContext_Color = _group getVariable ["A3C_HC_GroupColor","blue"];
	};
	{
		_ctrl = (findDisplay _a3c_dsp displayCtrl (_x select 0));
		lbClear _ctrl;
		private _forInd = _forEachIndex;
		[_ctrl, -1] call A3C_setCurSel;
		{
			[_ctrl, _x] call A3C_addLbEntry;
			if (_modeNum == 0) then {
				switch (_forInd) do {
					case (0) : {
						if (behaviour (leader _group) == _x) then {
							
							A3C_Map_HC_groupContext_Behaviour = _x;
							[_ctrl, _forEachIndex] call A3C_setCurSel;
						};
					};
					case (1) : {
						{
							if (combatMode _group == _x) then {
								
								A3C_Map_HC_groupContext_CMode = _x;
								[_ctrl, _forEachIndex] call A3C_setCurSel;
							};
						} foreach ["BLUE","GREEN","WHITE","YELLOW","RED"];
					};
					case (2) : {
						if (formation _group == _x) then {
							
							A3C_Map_HC_groupContext_Form = _x;
							[_ctrl, _forEachIndex] call A3C_setCurSel;
						};
					};
					case (3) : {
						if ( (_group getVariable ["A3C_HC_GroupColor","Blue"]) == _x) then {
							A3C_Map_HC_groupContext_Color = _x;
							[_ctrl, _forEachIndex] call A3C_setCurSel;

						};
					};
				};
			};
		} foreach (_x select 1);
	} foreach
		[
			[800701,["Careless","Safe","Aware","Combat","Stealth"]], // "Careless (Driver)",
			[800702,["Never Fire","Defend Only","Engage At Will","Fire At Will","F&E At Will"]],
			[800703,["Column","Stag Column","Wedge","Ech Left","Ech Right","Vee","Line","File","Diamond"]],
			[800704,["Red","Blue","Green","Black","White"]]
		];

	_targetArray = A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS;
	_startBar progressSetPosition 0.75;
	
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		[] call A3C_Radial_DashBoard;

		waitUntil {
			isNull findDisplay _a3c_dsp ||
			{ ctrlShown ((findDisplay _a3c_dsp) displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) }
		};

		private _display = findDisplay _a3c_dsp;
		if (isNull _display) exitWith {};

		private _dashboardCtrl = _display displayCtrl 11015;
		if (isNull _dashboardCtrl) exitWith {
			systemChat "layout failed: 11015 not found";
		};

		// Controls that define the top row above the listboxes.
		// Add every relevant control here if needed.
		private _topRowCtrls = [
			800724
		];

		// Extra conditional button macro
		private _responseCtrls = [800707, 800711];
		private _showResponseButton = !(profileNamespace getVariable ["HC_GROUP_RESPONSE", false]);

		private _dashboardPos = ctrlPosition _dashboardCtrl;
		private _dashboardBottom = (_dashboardPos select 1) + (_dashboardPos select 3);

		// Find bottom edge of the top row
		private _topBoundary = -1;
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				private _bottom = (_pos select 1) + (_pos select 3);
				if (_bottom > _topBoundary) then {
					_topBoundary = _bottom;
				};
			};
		} forEach _topRowCtrls;

		if (_topBoundary < 0) exitWith {
			systemChat "layout failed: no top row controls found";
		};

		// Height of the conditional bottom button area
		private _responseButtonH = 0;
		if (_showResponseButton) then {
			private _responseCtrl = _display displayCtrl 800707;
			if !(isNull _responseCtrl) then {
				_responseButtonH = (ctrlPosition _responseCtrl) select 3;
			};
		};

		// Space available for the two listbox rows
		private _availableH = _dashboardBottom - _topBoundary - _responseButtonH;
		private _rowH = _availableH / 2;

		// Top row listboxes
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				_pos set [1, _topBoundary];
				_pos set [3, _rowH];
				_ctrl ctrlSetPosition _pos;
				_ctrl ctrlCommit 0;
			};
		} forEach [800701, 800702];

		// Bottom row listboxes
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				_pos set [1, _topBoundary + _rowH];
				_pos set [3, _rowH];
				_ctrl ctrlSetPosition _pos;
				_ctrl ctrlCommit 0;
			};
		} forEach [800703, 800704];

		// Conditional response button pair
		{
			private _ctrl = _display displayCtrl _x;
			if !(isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;

				if (_showResponseButton) then {
					_pos set [1, _dashboardBottom - _responseButtonH];
					_ctrl ctrlSetPosition _pos;
					_ctrl ctrlCommit 0;
					_ctrl ctrlShow true;
				} else {
					_ctrl ctrlShow false;
				};
			};
		} forEach _responseCtrls;
	};

	

	
	{
		_x ctrlShow false;
	} foreach [_startBar,_startText];
	
	_groupMenuCtrlsGroup ctrlShow true;

	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			(findDisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		} foreach [800707, 800711];	
	};

	
	[_targetArray] call A3C_MAP_fnc_GroupMenu_LabelActionButtons; //-- unfortunately has to happen after ctrl is shown

	
	
	
	playsound "ReadOutHideClick1"; 
	// ctrlSetFocus _groupMenuCtrlsGroup;
	
};





A3C_GP_Btn_Para = {//mumu
	params ["_call"];
	private ["_vehicle","_cargoObjects"];
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};


	//_targetVehicle = if (!isNull findDisplay 100040) then {} else {};

	_vehicle = if (isNull _call) then {

			vehicle (leader (A3C_SELECTED_HC_GROUPS_SETTINGS select 0))

	} else {_call};


	if (((getPosATL _vehicle) select 2) > 1) then {
		//-- vehicle is airborne

		_vehicle setVariable ["A3C_ParadropActive",true,true];
		_targetArray = A3C_UI_MAP_GROUPMENU_ACTIONBUTTONS;
		if (!isNull findDisplay 100040) then {
			_targetArray = A3C_UI_RADIAL_BTN_DATA_OUTER_RING_MIXED;
		};
		[_targetArray] call A3C_MAP_fnc_GroupMenu_LabelActionButtons;
		[getPlayerUID player, _vehicle] call A3C_Paradrop_Eject;
		//{
		//		(finddisplay _a3c_dsp displayCtrl _x) ctrlShow false;
		//} foreach [800720,800721];
	} else {
		//-- vehicle is on ground
		_cargoObjects = [_vehicle] call MCSS_fnc_getNearCargoLoadObjects;
		if (count _cargoObjects > 0) then {

			A3C_OBJECTSELECTOR_MODE = "PARALOAD";
			if (!isNull findDisplay 100040) then {
				A3C_DISABLE_RADIAL = true;
				[] call A3C_RADIAL_CloseDisplay;

				[
					46,
					'RADIAL',
					{true},
					{},
					{
						(findDisplay 100060) closeDisplay 0;
						(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
					},
					true
				] call A3C_UI_RADIAL_ADD_EH_MACROS;

				with uiNameSpace do {
					A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
					(findDisplay 100060) displayAddEventhandler
					[
						"KeyUp",
						{
							[_this] spawn {
								_button = _this select 0;
								_button = _button - [(_button select 0)];
								if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
									(findDisplay 100060) closeDisplay 0;
									(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
									A3C_DISABLE_RADIAL = false;
									A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];

								};
							};
						}
					];
				};

			} else {
				{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
			};

			_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
			_text = findDisplay _a3c_dsp displayCtrl 800802;
			_listBox = findDisplay _a3c_dsp displayCtrl 800803;

			_parent ctrlShow true;
			_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
			_parent ctrlCommit 0;
			_text ctrlSetText "Select Object to load";
			ctrlSetFocus _listBox;
			
			lbClear _listBox;
			
			{
				private _lbText = format ["%1: %2 (%3m)",(getText (configfile >> "CfgVehicles" >> typeof _x >> "displayName")),if (count crew _x == 0) then {"Empty"} else {groupID group (crew _x select 0)},round(_vehicle distance _x)];
				[_listBox, _lbText] call A3C_addLbEntry;
			} foreach _cargoObjects;
		} else {
			systemchat "A3C: No loadable objects closeby";
		};

	};



};









A3C_fnc_SecuRejoin_fnc = {
	params ["_groupArray"];
	if (count _groupArray == 0) exitWith {};
	A3C_SELECTED_HC_GROUPS_SETTINGS = +(_groupArray);
	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};
	

	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
	if (count _groupArray <= 1) then {
		[_groupArray] spawn A3C_REJOIN_GROUPS;
	} else {
		if (_a3c_dsp == 100060) then {
			with uiNamespace do {
				//disableSerialization;
				A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
				(findDisplay 100060) displayAddEventhandler
				[
					"KeyUp",
					{
						[_this] spawn {
							_button = _this select 0;
							_button = _button - [(_button select 0)];
							if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
								A3C_DISABLE_RADIAL = false;
								(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
								(findDisplay 100060) closeDisplay 0;
								A3C_DOWNKEYS = A3C_DOWNKEYS - [(_button select 0)];
								{player groupSelectUnit [_x,false]} foreach units player; showCommandingMenu "";
							};
						};
					}
				];
			};
		};
		_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
		_text = findDisplay _a3c_dsp displayCtrl 800802;
		_listBox = findDisplay _a3c_dsp displayCtrl 800803;
		_parent ctrlShow true;
		_parent ctrlSetPosition [0.383108 * safezoneW + safezoneX, 0.378986 * safezoneH + safezoneY];
		_parent ctrlCommit 0;
		_text ctrlSetText format ["Really join %1 groups to your squad?",count A3C_SELECTED_HC_GROUPS_SETTINGS];
		A3C_OBJECTSELECTOR_MODE = "SECU_REJOIN";
		lbClear _listBox;
		
		{
			[_listBox, _x] call A3C_addLbEntry;
		} foreach ["Cancel","Proceed"];
		

	};
};


A3C_REJOIN_GROUPS = {
	params ["_groups"];
	{
		private _units = units _x;
		A3C_HC_DISBANDED = A3C_HC_DISBANDED - [_x];
		(_x getvariable 'A3C_TAB_MARKER') setmarkeralphaLocal 1; //~~ still needed?
		{
			(vehicle _x) spawn {
				[_this,"LOCKED"] remoteExec ["setvehicleLock", _this];
				sleep 5;
				[_this,"UNLOCKED"] remoteExec ["setvehicleLock", _this];
			};
			[[_x],A3C_HC_ROLES] remoteExec ["bis_fnc_spawn",_x];

		} foreach _units;
		_units join group player;
	} foreach _groups;
};

A3C_ORDER_ARTILLERY = {
	params ["_pos","_shift"];
	MCSS_REMOTE_ARTILLERY_ARRAY = MCSS_REMOTE_ARTILLERY_ARRAY select
	{
		_artyAmmo = getArtilleryAmmo [_x];
		{_x in A3C_HC_FOCUS_ARTY_AMMO_ARRAY} count _artyAmmo > 0
	};
	_fireCount = A3C_HC_FOCUS_ARTY_AmmoCount; //-- copy number
	//systemchat str [count MCSS_REMOTE_ARTILLERY_ARRAY,A3C_HC_FOCUS_ARTY_AMMO_ARRAY,_fireCount];
	//private _fireOrders = [];
	//-- stack fireorders
	//--  while _fireCount is > 0, units are distributed shots one by one 
	//-- meaning: unit1 takes shot 1, unit 2 takes shot 2 
	//-- unit needs to check if it can take the shot:
	//-->> unit needs to have more mags of allowed types than existing fireorders of matching types 
	//-- unit gets a shot assigned with the ammo that is has left 
	//-->> take all existing ammo


	private _artyLeaderVic = MCSS_REMOTE_ARTILLERY_ARRAY select 0;
	private _artyLeader = gunner _artyLeaderVic;
	{
		[_x] call A3C_AddToArtyRadio;
	} foreach MCSS_REMOTE_ARTILLERY_ARRAY;

	
	//A3C_CUSTOMRADIO_ID radioChannelAdd [player];
	
	
	//-- create data
	private _canNotFire = true;
	private _artyOrdersCurrent = []; //[vehicle, pos, mag, amount] >> array handling CURRENT artillery order. carries _vehicle
	while {_fireCount > 0} do {
		
		{
			//-- THIS STEP DISTRIBUTES SHELLS OF THE CURRENTLY REQUESTED ORDER THROUGHOUT THE AVAILABLE VEHICLES
			private _artyPiece = _x;
			if (_fireCount == 0) exitWith {};
			
			private _availableMags = (magazinesAmmoFull _artyPiece) select
			{
				_x params ["_magType","_magAmount"];
				(_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY) && {_pos inRangeOfArtillery [[_artyPiece], _magType]}
			};
			private _artyOrdersPlanned = _artyPiece getvariable ["A3C_ARTY_ORDERS",[]];
			//player sidechat str _artyOrdersPlanned;
			_artyOrdersFiltered = _artyOrdersPlanned select
			{
				//-- filter for matching magtype
				_x params ["_firePos","_magType","_orderCount"];
				_magType in A3C_HC_FOCUS_ARTY_AMMO_ARRAY
			};
			private _exit = false;
			{
				_x params ["_firePos","_magType","_orderCount"];
				{
					private _magData = _x;
					_magData params ["_magTypeRef","_magAmount"];
					//systemchat str [_magTypeRef , _magType];
					if (_magTypeRef == _magType) exitWith {
						(_availableMags select _foreachIndex) set [1,_magAmount - _orderCount];
						//_x set [1,_magAmount - _orderCount];
						_exit = true;
						//systemchat str (_magAmount - _orderCount);
					};
				} foreach _availableMags;
				if (_exit) exitWith {};
			} foreach _artyOrdersFiltered;
			_availableMags = _availableMags select {_x select 1 > 0};

			if !(_availableMags isEqualTo []) then {
				private _selectedMag = (_availableMags select 0) select 0;
				

				if ({_x select 0 == _artyPiece && {_x select 2 == _selectedMag && {_x select 1 isEqualTo _pos}}} count _artyOrdersCurrent == 0) then {
					//-- create new entry
					_artyOrdersCurrent set [count _artyOrdersCurrent,[_artyPiece,_pos,_selectedMag,1]];
				} else {
					//-- add to existing entry
					{
						if (_x select 0 == _artyPiece && {_x select 2 == _selectedMag && {_x select 1 isEqualTo _pos}}) exitWith {
							_x set [3,(_x select 3) + 1];
						};
					} foreach _artyOrdersCurrent;
				};
				
				if ({_x select 1 == _selectedMag && {_x select 0 isEqualTo _pos}} count _artyOrdersPlanned == 0) then {
					//-- create new entry
					_artyOrdersPlanned set [count _artyOrdersPlanned,[_pos,_selectedMag,1]];
					_canNotFire = false;
					_fireCount = _fireCount - 1;
				} else {
					//-- add to existing entry
					{
						if (_x select 1 == _selectedMag && {_x select 0 isEqualTo _pos}) exitWith {
							_x set [2,(_x select 2) + 1];
							_canNotFire = false;
							_fireCount = _fireCount - 1;
						};
					} foreach _artyOrdersPlanned;
				};
				_artyPiece setvariable ["A3C_ARTY_ORDERS",_artyOrdersPlanned,true];
			};

		} foreach MCSS_REMOTE_ARTILLERY_ARRAY;
		if (_canNotFire) exitWith {
			hint "ARTILLERY PROBLEM: SOME GUNS ARE NOT IN RANGE";	
		};
	};

	if !(_canNotFire) then {
		hint "";
		//-- comms: REQUESTING SUPPORT
		player customRadio [A3C_CUSTOMRADIO_ID, "SentARTYFireAtWithAmmo"];


		[_artyLeader] spawn {
			params ["_artyLeader"];
			sleep (3 + (random 2));
			_artyLeader customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAcknowledgedSGArty"];
		};
		//systemchat str _artyOrdersCurrent;
		// _artyOrdersCurrent carries data for executed strikes of MULTIPLE vehicles
		// we now cycle through those orders and reference them to existing orders
		{
			//-- THIS STEP CHECKS FOR PRE-EXISTING ORDERS. IF NONE EXIST, WE ADD THE MANAGEMENT EVENTHANDLERS
			sleep random 2;
			_x params ["_vehicle","_pos","_magType","_shellAmount"];

			//-- slightly messy, maybe :) determine if this is first or added order. Manage accordingly
			private _artyOrdersPlanned = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
			private _currentOrder = _x - [_x select 0]; //-- current order instance (_x) in format of "A3C_ARTY_ORDERS" variable
			private _ordersPreExist = _artyOrdersPlanned - [_currentOrder];

			//systemchat str _currentOrder;

			if (_ordersPreExist isEqualTo []) then {

				//systemchat "INITIAL ORDER";


				//-- NO ORDERS EXIST: DISTRIBUTE MANAGEMENT EVENTHANDLERS
				private _spread = if (_shellAmount > 7) then {random 50} else {1};
				

				//-- problem: we only want one 'SPLASH' message for the first shell per order
				//-- we need extra EH because later we can not identify the order-index 
				
				_vehicle setVariable ["A3C_ARTY_TARGETPOS",_pos,true];
				_splashHandler = _vehicle addEventHandler
				[
					"FIRED",
					{
						params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

						_vehicle removeEventHandler [_thisEvent,_thisEventHandler];

						_targetPos = _vehicle getVariable ["A3C_ARTY_TARGETPOS",[]];

						if !(_targetPos isEqualTo []) then {
							private _artyShellETA = _vehicle getArtilleryETA [_targetPos, _magazine];
							_artyShellETA = _artyShellETA max 0;
							private _commsOperator = gunner _vehicle;
							[_artyShellETA,_commsOperator] spawn { //-- SPLASH only relates to the first shell
								params ["_artyShellETA","_commsOperator"];
								//sleep 2;
								//systemchat format ["SPLASH ETA: %1sec", round _artyShellETA];
								sleep (_artyShellETA - 7);
								_commsOperator customRadio [A3C_CUSTOMRADIO_ID, "SentRequestAccomplishedSGArty"];
							};
						};
						_vehicle setVariable ["A3C_ARTY_TARGETPOS",nil,true];	
					}
				];

				private _eventHandlers = _vehicle getVariable ["A3C_ARTY_EH",[]];
				private _ehFired = -1;
				private _ehReloaded = -1;
				if (_eventHandlers isEqualTo []) then {
					_ehFired = _vehicle addEventHandler
					[
						"FIRED",
						{
							params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

							//systemchat format ["A UNIT HAS FIRED (%1)",(round time)];

							_vehicle setVariable ["A3C_ARTY_LAST",time,true];

							//-- SECURITY: REMOVE ALL REMAINING ORDERS IF GUN STOPS SHOOTING
							[_vehicle] spawn {
								params ["_vehicle"];
								sleep 15;
								private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST",nil];
								private _cond = !isNil '_lastShot' &&
								{
									(time - _lastShot) > 14 &&
									{
										private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
										!(_artyOrders isEqualTo [])
									}
								};
								if (_cond) then {

									// systemchat "SAFETY >> fired";
									//-- remove EHs
									private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
									if !(_varData isEqualTo []) then {
										_varData params ["_dataFired","_dataReloaded"];
										_vehicle removeEventHandler [_dataFired select 0,_dataFired select 1];
										_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
									};
									
									//-- reset main orders var
									_vehicle setvariable ["A3C_ARTY_ORDERS",nil,true];
									
									//-- reset currentOrder var
									_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

									//-- remove last fired var
									_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

									//-- delete EH objectNameSpace var 
									_vehicle setVariable ["A3C_ARTY_EH",nil];

									//-- radio feedback: ROUNDS COMPLETE
									private _commsOperator = gunner _vehicle;
									[_vehicle] call A3C_AddToArtyRadio;
									_commsOperator spawn {
										sleep (1 + (random 2));
										_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
									};
								};
							};

							

							
							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
							

							private _orderCurrent = _vehicle getVariable ["A3C_ARTYORDER_CURRENT",[]];
							_orderCurrent params ["_currentFirePos","_currentFireMag","_currentShellAmount"];

							if (_currentFireMag == _magazine) then {
								
								_currentShellAmount = (_currentShellAmount - 1) max 0;
								if (_currentShellAmount > 0) then {
									//-- CURRENT ORDER NOT YET COMPLETE
									//-- remove shot from current order
									_vehicle setVariable ["A3C_ARTYORDER_CURRENT",[_currentFirePos,_currentFireMag,_currentShellAmount], true];
									//-- remove shot from main variable
									{
										_x params ["_firePos","_magType","_orderCount"];
										if (_magType == _magazine) exitWith { //-- assumption: last shot will always be from current order
											_x set [2, _orderCount - 1];
										};
									} foreach _artyOrders; //-- note: just using (_artyOrders select 0) does not work if one magtype is used in multiple orders
									

									//systemchat "removing shell from current orders";
								} else {

									//-- CURRENT ORDER COMPLETE: MOVE TO NEXT OR DELETE VARIABLES

									//-- remove order from main variable
									_artyOrders = _artyOrders - [_orderCurrent];

									
									if (_artyOrders isEqualTo []) then {
										

										//-- No more orders: remove EHs
										_vehicle removeEventHandler [_thisEvent,_thisEventHandler];
										//systemchat "eh's removed REG FIRED";
										private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
										if !(_varData isEqualTo []) then {
											_varData params ["_dataFired","_dataReloaded"];
											_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
											
											//systemchat "eh's removed REG RELOAD";	
											
										};

										//-- MAIN var will be reset after the current parenting if statement is completed

										//-- reset currentOrder var
										_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

										//-- remove last fired var
										_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

										//-- delete EH objectNameSpace var 
										_vehicle setVariable ["A3C_ARTY_EH",nil];

										//-- radio feedback: ROUNDS COMPLETE
										private _commsOperator = gunner _vehicle;
										[_vehicle] call A3C_AddToArtyRadio;
										// systemchat "ARTY ORDERS COMPLETE";
										_commsOperator spawn {
											sleep (1 + (random 2));
											_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYRoundsComplete"];
										};
									} else {
										//-- still more orders lined up
										//systemchat "executing next order";
										_nextOrder = _artyOrders select 0;
										_nextOrder params ["_nextTargetPos","_nextMagType","_nextShellAmount"];
										_vehicle setVariable ["A3C_ARTYORDER_CURRENT",_nextOrder, true];
										[_vehicle,[_nextTargetPos getPos [5,random 360],_nextMagType,_nextShellAmount]] remoteExec ["commandArtilleryFire",_vehicle];
									};
								};
							};
							_vehicle setvariable ["A3C_ARTY_ORDERS",_artyOrders];
						}
					];

					//-- ISSUE: commandArtilleryFire gets cancelled if the vehicle reloads. We add a reloaded-EH that cancels all Arty Data
					_ehReloaded = _vehicle addEventHandler
					[
						"RELOADED",
						{
							params ["_vehicle", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];

							_newMagazine = _newMagazine select 0;
							_oldMagazine = if (isNil '_oldMagazine' OR {_oldMagazine isEqualTo []}) then {"rndm"} else {_oldMagazine select 0};

							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];


							if (_newMagazine == _oldMagazine) then {
								//-- canceled orders due to reload >> (engine bug) reissue remaining artillery orders!
								// systemchat "A VEHICLE IS RELOADING MID ORDER";
								private _targetPos = [];
								private _shellAmount = 0;
								{
									_x params ["_firePos","_magType","_orderCount"];
									//systemchat str [_magazine,_magType];
									if (_magType == _oldMagazine) then {
										_targetPos = _firePos; //-- will use last one (note: will not matter once orders are made stack-able)
										_shellAmount = _shellAmount + _orderCount;
									};
								} foreach _artyOrders;
								
								if !(_targetPos isEqualto []) then {
									[_vehicle,[_targetPos getPos [5,random 360],_oldMagazine,_shellAmount]] remoteExec ["commandArtilleryFire",_vehicle];
								};
							} else {
								// systemchat "A VEHICLE HAS CHANGED MAGS";
							};
						}
					];

					_vehicle setVariable
					[
						"A3C_ARTY_EH",
						[
							["FIRED",_ehFired],
							["RELOADED",_ehReloaded]
						]
					];
				};

				_vehicle setVariable ["A3C_ARTYORDER_CURRENT",_currentOrder,true];
				
				[_vehicle,[_pos getPos [_spread,random 360],_magType,_shellAmount]] remoteExec ["commandArtilleryFire",_vehicle];

				//-- SAFTEY: IF UNIT DOES NOT REACT TO ORDER, DELETE VARIABLES
				_vehicle setVariable ["A3C_ARTY_LAST",time,true]; //-- precaution to be sure to have a reference.
				[_vehicle,_splashHandler,_ehFired,_ehReloaded] spawn {
					params ["_vehicle","_splashHandler","_ehFired","_ehReloaded"];
					sleep 15;
					private _lastShot = _vehicle getVariable ["A3C_ARTY_LAST",nil];
					private _cond = !isNil '_lastShot' &&
					{
						(time - _lastShot) > 14 &&
						{
							private _artyOrders = _vehicle getvariable ["A3C_ARTY_ORDERS",[]];
							!(_artyOrders isEqualTo [])
						}
					};
					if (_cond) then {
						// systemchat "SAFETY >> unresponsive";
						//-- remove EHs
						private _varData = _vehicle getVariable ["A3C_ARTY_EH",[]];
						if !(_varData isEqualTo []) then {
							_varData params ["_dataFired","_dataReloaded"];
							_vehicle removeEventHandler [_dataFired select 0,_dataFired select 1];
							_vehicle removeEventHandler [_dataReloaded select 0,_dataReloaded select 1];
						};

						//-- reset main orders var
						_vehicle setvariable ["A3C_ARTY_ORDERS",nil,true];

						//-- reset currentOrder var
						_vehicle setVariable ["A3C_ARTYORDER_CURRENT",nil, true];

						//-- remove last fired var
						_vehicle setVariable ["A3C_ARTY_LAST",nil,true];

						//-- delete EH objectNameSpace var 
						_vehicle setVariable ["A3C_ARTY_EH",nil];

						//-- radio feedback: ROUNDS COMPLETE
						private _commsOperator = gunner _vehicle;
						[_vehicle] call A3C_AddToArtyRadio;
						_commsOperator spawn {
							sleep (1 + (random 2));
							_this customRadio [A3C_CUSTOMRADIO_ID, "SentARTYCannotExecuteAdjustCoordinates"];
							hint "hint: sometimes vehicles become unresponsive. Try to move the vehicle(s) a bit and make sure that they face the target";
						};

						//-- remove splash handler
						_vehicle removeEventHandler ["FIRED",_splashHandler];
					};
				};
			};	
		} foreach _artyOrdersCurrent;


	};


};

A3C_AddToArtyRadio = {
	params ["_vehicle"];
	private _commsOperator = gunner _vehicle;
	if (!isNull _commsOperator && {alive _commsOperator}) then {
		A3C_CUSTOMRADIO_ID radioChannelAdd [player,_commsOperator];
		if ("ItemRadio" in assignedItems _commsOperator) then {
			_commsOperator addItem "itemRadio"; 
			_commsOperator assignItem "itemRadio";
		};
	};
};


A3C_FlyinHeightArrayHeli = ["25","75","200","500"];
A3C_FlyinHeightArrayJet = ["30","100","500","1000","2000"];



A3C_HC_UnassembleWeapon = {

	if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {};
	params ["_mode"];
	private ["_group","_groupUnits","_wpn","_exit","_imgtext"];
	_group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	_groupUnits = units _group;
	_wpn = if (_mode == 0) then {objNull} else {_this select 1};


	private _a3c_dsp = if (visibleMap) then {100020} else {if (!isNull findDisplay 100030) then {100030} else {100060}};



	//-- main display EH to disable radial until key is let go
	if (!isNull findDisplay 100040 && _a3c_dsp == 100060 ) then {

		[
			46,
			'RADIAL',
			{true},
			{},
			{
				(findDisplay 46) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL];
			},
			true
		] call A3C_UI_RADIAL_ADD_EH_MACROS;

		A3C_DISABLE_RADIAL = true;
		[] call A3C_RADIAL_CloseDisplay;
	};

	if (_a3c_dsp == 100060 && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) then {
		with uiNamespace do {
			//disableSerialization;
			A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_Display_ObjectSelector";
		};
	};


	_parent = findDisplay _a3c_dsp displayCtrl A3C_MAP_OVERLAY_GAMEUI_ObjectSelector_CTRLPARENT;
	_text = findDisplay _a3c_dsp displayCtrl 800802;
	_listBox = findDisplay _a3c_dsp displayCtrl 800803;
	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;


	if ( (_mode == 0) && (count A3C_HC_NearStatics > 0) && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) exitWith {
		//-- open object selector || static
		if (_a3c_dsp == 100060) then {
			//if (count A3C_RD_UNITS > 0) then {



				//-- display EH: needed as 46 UP will not fire
				A3C_UI_RADIAL_EH_KEYUP_CANCEL1 = (findDisplay 100060) displayAddEventHandler
				[
					"KeyUp",
					{
						_button = _this - [(_this select 0)];
						if ((_button select 0) == (A3C_RadialMenu_KEY_ID select 0)) then {
							(findDisplay 100060) closeDisplay 0;

							(findDisplay 100060) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL1];


							if ((count A3C_HUD_UnitIndicators) > 0) then {
								{inGameUISetEventHandler [_x, "true"]} foreach ["PrevAction","NextAction"];
							} else {
								{inGameUISetEventHandler [_x, "false"]} foreach ["PrevAction","NextAction"];
							};
							A3C_DISABLE_RADIAL = false;

						};
					}
				];

			//};
		};


		A3C_OBJECTSELECTOR_MODE = "STATIC_DISASSEMBLE_HC";
		lbClear _listBox;
		_parent ctrlShow true;
		[_parent,_listBox, count A3C_HC_NearStatics] call A3C_OBJECTSEL_RESIZE;
		
		//_parent ctrlCommit 0;
		_text ctrlSetText "Select Static Weapon";
		
		{
			private _lbText = (getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _x)) >> "displayName"));
			[_listBox, _lbText] call A3C_addLbEntry;
		} foreach A3C_HC_NearStatics;
		
	};

	if (_a3c_dsp == 100060 && { {(vehicle _x) isKindOf "staticweapon"} count units _group == 0 }) then { //-- radial menu HC-disassemble: close menu

		(findDisplay 100060) closeDisplay 0;
		//(findDisplay 100060) displayRemoveEventHandler ["KeyUp", A3C_UI_RADIAL_EH_KEYUP_CANCEL1]; //-- not neede
		//A3C_DISABLE_RADIAL = false;
	};




	private _exit = false;
	{
		_u = _x;
		if ((vehicle _x) isKindOf "staticweapon") exitWith { //-- only one weapon possible

			//_groupUnits = _groupUnits - [_x];
			_wpn = vehicle _x;
			//if ({ (backPack _x == "") && (_x distance (vehicle _u) < 30) && (isNull objectParent _x) } count _groupUnits > 0) then {
			if ([units _group,_wpn,true] call A3C_HC_canSelectionPickUpStatic) then {
				player commandRadio "SentDisAssemble";
				A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (configfile >> "CfgVehicles" >>  (typeOf _wpn) >> "picture");
				A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
				[position _wpn,""] spawn A3C_UI_HUD_3D_TAG;

				systemchat format
				[
					"A3C: %1 is packing up their %2",
					groupId _group,
					(getText (configfile >> "CfgVehicles" >> (typeOf _wpn) >> "displayName"))
				];
			} else {
				_exit = true;
				systemchat format
				[
					"A3C: %1 can not be picked up. No units nearby with the capacity to pick up parts",
					(getText (configfile >> "CfgVehicles" >> (typeOf (vehicle _x)) >> "displayName"))
				];
			};
		};
	} foreach (units _group);
	if (_exit) exitWith {};
	if (isNull _wpn) exitWith {};
	//{
	//	(finddisplay _a3c_dsp displayCtrl _x) ctrlShow false;     !!!!!!!!!!!!!!!!!!!!!!
	//} foreach [800716,800717];
	//systemchat "leave static";
	{
		// //unassignvehicle _x;
		// //dogetOut _x;
		// [_x,vehicle _x] remoteExec ["leaveVehicle",_x];
		// [_x] remoteExec ["unassignvehicle",_x];
		// [_x] remoteExec ["doGetOut",_x];
		[[_x], A3C_AIGetOut] remoteExec ['bis_fnc_call', _x];
	} foreach crew _wpn;
	sleep 3;
	[
		(units _group),
		["DISASSEMBLE",_wpn],
		position _wpn,
		getDir _wpn
	] spawn A3C_WP_ACTION_STATICWEAPON;

};



A3C_Map_HC_groupContext_LB_Switch = {
	params ["_box","_lb","_display"];
	if (A3C_CurSel) exitWith {};
	private _immediateAction = [];
	switch (_box) do {
		case (800701) : {
			A3C_Map_HC_groupContext_Behaviour = ["Careless","Safe","Aware","Combat","Stealth"] select _lb; //"Careless (Driver)",
			_immediateAction = ["setBehaviourStrong", A3C_Map_HC_groupContext_Behaviour];
		};
		case (800702) : {
			A3C_Map_HC_groupContext_CMode = ["BLUE","GREEN","WHITE","YELLOW","RED"] select _lb;
			_immediateAction = ["setCombatMode", A3C_Map_HC_groupContext_CMode];
		};
		case (800703) : {
			A3C_Map_HC_groupContext_Form = ["Column","Stag Column","Wedge","Ech Left","Ech Right","Vee","Line","File","Diamond"] select _lb;
			_immediateAction = ["setFormation", A3C_Map_HC_groupContext_Form];
		};
		case (800704) : {
			A3C_Map_HC_groupContext_Color = ["Red","Blue","Green","Black","White"] select _lb;
			
		};
	};

	//-- potential immediate response
	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			private _group = _x;
			if (_box == 800704) then {
				_group setVariable ["A3C_HC_GroupColor",A3C_Map_HC_groupContext_Color,true];
			} else {
				// private _executingEntity = if (_box ) then {leader _group} else {_group};
				[_group, _immediateAction select 1] remoteExec [_immediateAction select 0, leader _group];
			};
		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	};
};
A3C_GROUP_STANCE_Selected = "AUTO";
A3C_GP_Btns_Stances = {
	params ["_stance","_mode"]; //-- #TODO: _mode is always 1
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	A3C_GROUP_STANCE_Selected = _stance;
	if (profileNameSpace getVariable ["HC_GROUP_RESPONSE", false]) then {
		{
			{[_x,_stance] remoteExec ['setUnitPos',_x]} foreach units _x;
			_x setVariable ["A3C_GROUP_STANCE",_stance,true];
		} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
	};
	for "_i" from 800724 to 800727 do {
		(findDisplay _a3c_dsp displayCtrl _i) ctrlSetTextColor [1,1,1,0.1];
	};
	private _ModeButton = switch (_stance) do {
		case ("AUTO") : {800724};
		case ("UP") : {800725};
		case ("MIDDLE") : {800726};
		case ("DOWN") : {800727};
	};
	(findDisplay _a3c_dsp displayCtrl _ModeButton) ctrlSetTextColor [1,1,1,0.7];
};




A3C_Map_HC_groupContext_ButtonFnc_Confirm = {


	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	(findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT) ctrlShow false;

	private _showPlayerHint = false;

	{
		private _ld = leader _x;
		if (isPlayer _ld && {_ld != player}) then {
			_showPlayerHint = true;

			// () remoteExec []; //#TODO: implement structured text hint solution
			
		} else {
			if (A3C_Map_HC_groupContext_Behaviour == "Careless (Driver)") then {
				{
					_s = _x;
					if (_s == driver vehicle _x) then {
						[_s,["BEHAVIOUR","CARELESS"]] call MCSS_fnc_orderIndividual;
					};
				} foreach (units _x);
			} else {
				if (A3C_Map_HC_groupContext_Behaviour != "") then {
					[leader _x,A3C_Map_HC_groupContext_Behaviour] remoteExec ["setBehaviourStrong", leader _x];
				};	
				if (A3C_Map_HC_groupContext_CMode != "") then {
					[leader _x,A3C_Map_HC_groupContext_CMode] remoteExec ["setCombatMode", leader _x];
				};
				
				if (A3C_Map_HC_groupContext_CMode == "RED") then {
					[_x,true] remoteExec ["enableAttack", leader _x];
				} else {
					[_x,false] remoteExec ["enableAttack", leader _x];
				};
				//_x setFormation A3C_Map_HC_groupContext_Form;
				if (A3C_Map_HC_groupContext_Form != "") then {
					[_x,A3C_Map_HC_groupContext_Form] remoteExec ["setFormation", leader _x];
					[_x,A3C_Map_HC_groupContext_Form] remoteExec ["setFormation", leader _x];
				};
				_x setVariable ["A3C_HC_GroupColor",A3C_Map_HC_groupContext_Color,true];
				//systemchat str (_x getVariable ["A3C_HC_GroupColor","oi"]);
				
				if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
					_ctrlText = ctrlText (findDisplay _a3c_dsp displayCtrl 800713);
					if (groupID _x != _ctrlText) then {
						[_x,[_ctrlText]] remoteExec ["setGroupIDGlobal", leader _x];
						_button = _x getVariable ["A3C_TREESEL_INDEX",[]];
						
						if (count _button > 0) then {
							private _CT_TREE = findDisplay _a3c_dsp displayCtrl A3C_SHARED_GAMEUI_TREE_CONTROL;
							_button = _button select 0;
							_CT_TREE tvSetText [_button, _ctrlText];
						};
					};
					if (A3C_MAP_CommandMode == "HC") then {
						["HC"] call A3C_START_TABMODE;
					};
				};
			};
			{[_x,A3C_GROUP_STANCE_Selected] remoteExec ['setUnitPos',_x]} foreach units _x;
			_x setVariable ["A3C_GROUP_STANCE",A3C_GROUP_STANCE_Selected,true];
		};
		
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;

	if (_showPlayerHint) then { //#TODO: implement this functionality of letting players know via structured text hint with desired formation, behavior etc
		[] spawn {
			hint "A3C: Player groups within selection have been notified of your orders. (Not implemented yet)";
			sleep 2;
			hintSilent "";
		};	
	};


	{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
	(findDisplay 12 displayCtrl 51) ctrlEnable true;
};

A3C_HC_FocusGroup = grpNull;

A3C_MAP_HC_setFocusGroup = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	if !(count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) exitWith {};
	private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;
	if ( {isPlayer _x} count units _group > 0) exitWith {
		systemchat "A3C: Group contains a human player and can not be focused";
	};
	if (_group == A3C_HC_FocusGroup) then {
		A3C_HC_FocusGroup = grpNull;
		(findDisplay _a3c_dsp displayCtrl 800714) ctrlSetText "#(argb,8,8,3)color(0,0.3,0.6,0.2)";
	} else {
		A3C_HC_FocusGroup = _group;
		(findDisplay _a3c_dsp displayCtrl 800714) ctrlSetText "#(argb,8,8,3)color(0,0.3,0.6,1)";
	};
};





A3C_CONVOY_GROUPORDER = [];

A3C_Map_HC_groupContext_ButtonFnc_Convoy = {
	private _a3c_dsp = if (visibleMap) then {100020} else {100030};
	if (count A3C_SELECTED_HC_GROUPS_SETTINGS == 1) then {
		//-- rejoin Convoy to former groups
		{
			private _entry = _x;
			if ((A3C_SELECTED_HC_GROUPS_SETTINGS select 0) == (_entry select 0)) exitWith {
				private ["_leaders","_subs"];
				_leaders = [];
				_subs = [];

				{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
				(findDisplay 12 displayCtrl 51) ctrlEnable true;
				A3C_ConvoyGroups = A3C_ConvoyGroups - [_entry];
				private _groupArrays = [];

				{
					_subgroupUnits = _x;
					if ({alive _x} count _subgroupUnits > 0) then {
						_groupArrays pushbackUnique _subgroupUnits;
					};
				} foreach (_entry select 1);
				{
					_gp = createGroup (side (_x select 0));
					{
						[_x] joinSilent _gp;
						if ((!isNull objectParent _x) && (_x == driver vehicle _x)) then {
							(vehicle _x) setUnloadInCombat [true,false];
						};
					} foreach _x;
				} foreach _groupArrays;



				{
					[(group (_x select 0)),[(((_x select 0) getVariable "A3C_CONVOYDATA") select 3)]] remoteExec ["setGroupIDGlobal", leader (group (_x select 0))];
				} foreach _groupArrays;

				deleteGroup (_entry select 0);
			};
		} foreach A3C_ConvoyGroups;
	} else {
		//-- create new convoy in order
		if (count A3C_SELECTED_HC_GROUPS_SETTINGS >= 2) then {
			{(findDisplay 100020 displayCtrl _x) ctrlShow false} foreach [A3C_MAP_OVERLAY_GAMEUI_GROUP_MENU_CTRLPARENT,A3C_SHARED_GAMEUI_GroupDashboard_CTRLPARENT];
			(findDisplay 12 displayCtrl 51) ctrlEnable true;
			private ["_drivers","_nonDrivers"];
			_drivers = [];
			_nonDrivers = [];

			A3C_CONVOY_GROUPORDER = [];

			//-- driver leadvic needs to be in group
			//-- no units can have no assigned vehicle
			private _refUnits = A3C_SELECTED_HC_GROUPS_SETTINGS select 
			{
				_gp = _x;
				_leader = leader _gp;
				_leaderVic = vehicle _leader;
				!isplayer _leader && 
				{
					(driver _leaderVic) in (units _gp) 
				}
			};
			//systemchat str _refUnits;

			//-- Step 1: fetch drivers and footunits
			{
				_gp = _x;
				A3C_CONVOY_GROUPORDER pushBackUnique (units _gp);
				{

					if (!isNull objectParent _x) then {
						if (_x == driver (objectParent _x)) then {
							_drivers pushBackUnique _x;
							(vehicle _x) setUnloadInCombat [false,false];
						};
					//} else {
					//	_foot pushBackUnique _x;
					};
				} foreach (units _gp);
				if (count units _gp == 0) then {deleteGroup _gP};
			} foreach _refUnits;

			//
			//-- create refposition of averages (positions and direction):
			private _avg = 0;
			{_avg = _avg + (getDir (vehicle _x))} foreach _drivers;
			_avg = if (count _drivers == 0) then {0} else {_avg / (count _drivers)};
			private _mapSize = 2000; //(getnumber (configfile >> "CfgWorlds" >> worldName >> "mapSize")) / 2;
			private _avX = 0;
			private _avY = 0;
			if (count _drivers > 0) then {
				_avX = (_drivers apply {(getPos (vehicle _x)) select 0}) call BIS_fnc_arithmeticMean;
				_avY = (_drivers apply {(getPos (vehicle _x)) select 1}) call BIS_fnc_arithmeticMean;
			};
			_center = [_avX,_avY,0];
			_refPos = _center getPos [_mapSize,_avg];


			//
			//-- get leader (closest to refpos)
			_drivers  = [_drivers ,[],{(vehicle _x) distance2D _refPos},"ASCEND"] call BIS_fnc_sortBy;
			_leader = if (count _drivers > 0) then {_drivers select 0} else {leader (_refUnits select 0)};

			if (count _drivers == 0) exitwith {
				systemchat "A3C: Convoy can not be created without drivers :)";
			};

			//
			//-- sort remaining vehicles by distance to leader, then rejoin _leader
			_drivers = _drivers - [_leader];
			_drivers  = [_drivers ,[],{(vehicle _x) distance2D (vehicle _leader)},"ASCEND"] call BIS_fnc_sortBy;
			_drivers = [_leader] + _drivers;

			//
			//-- create (hopefully) correct order of units
			_A3C_ConvoyUnits = [];
			{
				//-- add vehicle crew to group as well
				{
					//if ((group _x) in A3C_HC_getAllGroups_Player_Current) then {
						//if !(isPlayer (leader group _x)) then {
							_A3C_ConvoyUnits pushBackUnique _x;
						//};
					//};
				} foreach (units _x);
				//} foreach (crew vehicle _x);
			} foreach _drivers;

			//
			//-- set groupData variable
			{
				_x setVariable 
				[
					"A3C_CONVOYDATA",
					[
						group _x,
						units (group _x),
						"BLUE",
						(groupID (group _x))
					],
					true
				]; //~~ do not move this
			} foreach _A3C_ConvoyUnits;


			//
			//-- create new group
			private ["_newGroup"];
			_newGroup = createGroup (side player);
			_A3C_ConvoyUnits = _A3C_ConvoyUnits - [_leader];
			[_leader]  joinSilent _newGroup;
			_newGroup selectLeader _leader;
			_A3C_ConvoyUnits joinSilent _newGroup;
			A3C_ConvoyGroups pushBackUnique [_newGroup,A3C_CONVOY_GROUPORDER];
			A3C_HC_DISBANDED pushBackUnique _newGroup;
			_newGroup setGroupIDGlobal [format ["Convoy-%1", count A3C_ConvoyGroups]];
			_newGroup setformation "COLUMN";
			_newGroup setFormDir (getDir (vehicle _leader));
			_newGroup enableAttack false;
			_newGroup setBehaviourStrong "SAFE";
			//{doStop _x} foreach units _newGroup;
			{
				if (!isNull objectParent _x) then {
					if (_x == driver vehicle _x) then {
						if !(vehicle _x isKindOf "AIR") then {
							vehicle _x setConvoySeparation 20;
						};
					};
				};
			} foreach units _newGroup;
			private _lV = objNull;
			systemchat "A3C: New convoy group created";
			A3C_MAP_CommandMode = "HC";
			A3C_SELECTED_UNITS = [_newGroup];
			["HC"] call A3C_START_TABMODE; //-- refresh table if open
			A3C_SELECTED_HC_GROUPS_SETTINGS = [];




			while {!isNull _newGroup} do {
				private _g = _newGroup;
				private _l = leader _g;
				_lv = vehicle _l;
				private _vics = [];
				//-- assist stuck vehicles
				{
					private _u = _x;
					private _v = vehicle _u;

					if (_v != _lv) then {
						if (!isNull objectParent _u) then {
							if (_u == driver _v) then {
								_vics pushback _v;
								if (speed _v == 0) then {
									if (speed vehicle _l > 0) then {
										_u doFollow _l;
										[_u,_l] remoteExec ["doFollow",_u];
										//systemchat 'wipe';
									};
								};
							};
						};
					};
				} foreach units _newGroup;

				//-- leadVic speed
				[_lV,10000] remoteExec ["limitSpeed",_lV];
				private _maxDistance = (count _vics) * 70;
				if (_maxDistance != 0) then {
					if ({!(_x isKindOf "LAND")} count (_vics + [_lv]) == 0) then {
						if ({_x distance _lV > _maxDistance} count _vics > 0) then {
							[_lV,10] remoteExec ["limitSpeed",_lV];
						};
					};
				};
				sleep 5;
			};
			[_lV,10000] remoteExec ["limitSpeed",_lV];
			//systemchat "Exit Loop";
		};
	};
};



