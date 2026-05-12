#include "..\ui\radial\radialMenu\dialog_defines.hpp"



TAG_fnc_turretRole = { //-- unused
	params[ "_unit", "_vehicle" ];
	
	assignedVehicleRole _unit params[ "_position", "_turretPath" ];
	
	if ( _position == "Turret" ) then {
		_cfgPath = configFile >> "CfgVehicles" >> typeOf _vehicle;
		{
			_cfgPath = ( _cfgPath >> "turrets" ) select _x;
		}forEach _turretPath;
		
		_position = getText( _cfgPath >> "gunnerName" );
	};
	
	hint format[ "Current turret role\n%1", _position ];
};

A3C_isGroupBoarding = {
	params ["_group"];
	
	if (isPlayer (leader _group)) exitWith {false};

	private _return = false;
	{
		if (isNull objectParent _x) then {
			private _aV = assignedVehicle _x;
			if (!isNull _aV && {!(_x in _aV)}) exitWith {
				_return = true;
			};
		};
	} foreach units _group;
	_return
};


/*
A3C_AI_BOARDING_GET_VehicleRoles = { 
	//-- returns roles in usable data, including units that occupy the seats
	//-- used to fetch data to display in Radial Menu (SQ-Boarding) and assign controls accordingly
	//-- note to self: it's better to use the gathered turrets instead of 'assignAsCommander' and 'assignAsGunner' 
	
	params ["_vehicle"];
	
	
	
	
	
	
	private _vehicleType = typeOf _vehicle;
	
	//-- at the moment i can not return assigned turret and cargo seats specifically unless the unit is already occupying the seats
	//-- in order to return empty but assigned turrets (unit in process of boarding), I need to create a MP-global array for assigned vehicles (add when assigning, remove when boarded or cancelled)
	
	//-- step 1: get driver/pilot role
	private _roleArray = [["driver", driver _vehicle]]; 
	
	//-- step 2: get turret-roles (Gunner,Commander,FFV)
	private _allTurrets = allTurrets [_vehicle,true];
	{
		private _turretPath = _x;
		
		//-- get turret position name
		private _cfgPath = configFile >> "CfgVehicles" >> _vehicleType;
		{
			_cfgPath = ( _cfgPath >> "turrets" ) select _x;
		}forEach _turretPath; //-- teacher: Larrow
		private _positionName = getText( _cfgPath >> "gunnerName" );

		_roleArray pushBack
		[
			"Turret",
			_turretPath,
			_positionName,
			_vehicle turretUnit _turretPath
		];
		
	} foreach _allTurrets;
	
	//-- step 3: get cargo-roles
	private _seatCount = ([_vehicleType,true] call BIS_fnc_crewCount) - (count _allTurrets) - 1; //-- the '-1' is to remove driver
	for "_i" from 0 to (_seatCount -1) do {
		private _cargoUnit = objNull;
		{
			_crewUnit = _x;
			if (_vehicle getCargoIndex _crewUnit == _i) exitWith {
				_cargoUnit = _x;
			};
		} foreach (crew _vehicle);
		_roleArray pushBack ["cargo",_i,_cargoUnit];
	};
	_roleArray
	
};


A3C_RADIAL_BOARDING_ButtonFnc = { //~~ needs to be converted to multiple units once working
	params ["_a3c_dsp","_buttonControls","_unit","_vehicle","_roleData"];
	
	_buttonControls params ["_buttonImage","_buttonClicker"];
	switch (_roleData select 0) do {
		case ("driver") : {
			_roleData params ["_role","_occupyingUnit"];
			if (isNull _occupyingUnit) then {
				_unit assignAsDriver _vehicle;
			};
		};
		case ("Turret") : {
			_roleData params ["_role","_turretPath","_positionName","_occupyingUnit"];
			if (isNull _occupyingUnit) then {
				_unit assignAsTurret _turretPath;
			};
		};
		case ("cargo") : {
			_roleData params ["_role","_cargoIndex","_occupyingUnit"];
			if (isNull _occupyingUnit) then {
				_unit assignAsDriver _vehicle;
			};
		};
	};
	if (!isplayer (leader group _unit) ) then {
		[_unit] orderGetIn true;
	};
};

*/

//-- macro button fnc: mount/dismount multiple units at once
A3C_AssignVehicleSeatMacro = {
	params ["_vehicle","_boardingType","_btn","_refUnits"];
	
	private _refUnits = +(_refUnits);
	private _vehicleSeatData = [];
	
	//-- re-arrange
	{
		private _testedRole = _x;
		{
			if (_x select 1 == _testedRole) then {
				_vehicleSeatData pushBackUnique _x;
			};
		} foreach (fullcrew [_vehicle,"",true]);
	} foreach ["driver","gunner","commander","Turret","cargo"];
	
	private _suitableUnits = _refUnits select {isnull objectParent _x};

	if (_btn == 0) then {
		_suitableUnits = _suitableUnits select {count (_x getVariable ["A3C_assignedVehicleSeat",[]]) == 0};
	};

	_currentBtnImage = 10101;
	
	_vicVar = _vehicle getVariable ["A3C_AssignedVehicleCrew",[]];
	
	
	
	{
		private _roleData = _x;
		if (count _suitableUnits == 0) exitWith {};
		_roleData params ["_occupyingUnit","_role","_cargoIndex","_turretPath","_isFFV"];
		if (_boardingType == 'all' OR {_role == "cargo" || {_boardingType == 'cargoFFV' && _isFFV}}) then {
			if (isNull _occupyingUnit OR {!alive _occupyingUnit}) then {

				private _refArray = _roleData select [1,3];
				{
					_boardingData = _x;
					if ({_x in _boardingData} count _refArray >= 2) exitWith {
						_occupyingUnit = _x select 0;
						_buttonColor = if (group _occupyingUnit == group player) then {[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity} else {[A3C_UI_COLOR_RED,0.3] call A3C_UI_fnc_setOpacity};
					};
				} foreach _vicVar;

			};
			if (_btn == 0) then {
				if (isNull _occupyingUnit OR {!alive _occupyingUnit}) then {
					_boardUnit = _suitableUnits select 0;

					[_roleData,_btn,_currentBtnImage,_boardUnit,_refUnits,_vehicle] call A3C_AssignVehicleSeat;
					_suitableUnits = _suitableUnits - [_boardUnit];
					sleep .3;
				};
			} else {
				if (_occupyingUnit in units player) then {
					[_roleData,_btn,_currentBtnImage,_occupyingUnit,_refUnits,_vehicle] call A3C_AssignVehicleSeat;					
				};
			};
		};
		sleep 0.1;
		_currentBtnImage = _currentBtnImage + 2;
	} foreach _vehicleSeatData;
	
};



//-- assigns individual seats. Calledfrom seat-button or board_all fnc
A3C_AssignVehicleSeat = {

	params ["_roleData","_mouseButton","_buttonImgIdc","_specifiedUnit","_refUnits","_vehicle"];

	
	_roleData params ["_occupyingUnit","_role","_cargoIndex","_turretPath","_isFFV"];
	private _buttonImg = findDisplay IDD_RADIAL_MENU displayCtrl _buttonImgIdc;
	private _vehicle = if (!isNil '_vehicle') then {_vehicle} else {A3C_TARGETVEH};
	private _refUnits = if (!isNil '_refUnits') then {_refUnits} else {A3C_RD_UNITS};
	// player commandchat str (count _refUnits);
	if (count _refUnits == 0) exitWith {};
	_fnc_unassign = {
		params ["_unit","_buttonImg","_var"];
		_var params ["_vehicle","_role","_path","_script","_image"];
		if (count _var > 0) then {
			if (typename _script != "STRING") then {
				terminate (_var select 3);
			};
			

			[[_unit], A3C_AIGetOut] remoteExec ['bis_fnc_call', _unit];

			if (A3C_RADIALMODE == "VEHS" && {A3C_TARGETVEH == _vehicle}) then {
				_buttonImg ctrlSetTextColor [1,1,1,1];
			};
			_unit setVariable ["A3C_assignedVehicleSeat",nil];
			
			waitUntil {isnull objectParent _unit};
			_unit domove (position _unit);
			
		};
	};
	
	
	//-- right mousebutton - dismount unit (player group only)
	if (_mouseButton == 1) exitWith {
		if (_occupyingUnit in units player) then {
			if (_occupyingUnit in _vehicle) then {
				_occupyingUnit remoteExec ["unassignVehicle",0];
				doGetOut _occupyingUnit;
				_buttonImg ctrlSetTextColor [1,1,1,1];
			} else {
				if (typeName _occupyingUnit == "OBJECT") then {
					//-- unit in player group, but not yet boarded, after menu reopen
					_var = _occupyingUnit getVariable ["A3C_assignedVehicleSeat",[]];
					[_occupyingUnit,_buttonImg,_var] spawn _fnc_unassign;
				};
			};	
		} else {
			{
				_var = _x getVariable ["A3C_assignedVehicleSeat",[]];
				private _cond = 
				(
					//-- unit in player group, but not yet boarded, before menu-reopen (menu not lcosed before changing mind)
					count _var > 0 && {_var select 0 == _vehicle && {{_x in _roleData} count (_var select [1,2]) == 2}}
				) OR {
					//-- unit has moved into seat during menu usage (menu not closed)
					switch (_role) do {
						case ("driver") : {_x == driver _vehicle};
						case ("gunner") : {_x == gunner _vehicle};
						case ("commander") : {_x == commander _vehicle};
						case ("Turret") : {_x == _vehicle turretUnit _turretPath};
						case ("cargo") : {_cargoIndex == _vehicle getCargoIndex _x};
					};
				};
				if (_cond) exitWith {
					if (_var isEqualTo []) then {_var = [_vehicle,_role,-1,"",""]};
					[_x,_buttonImg,_var] spawn _fnc_unassign;
				};
			} foreach (units player);
		};
	};
	
	_buttonImg ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity);
	
	
	_vicVar = _vehicle getVariable ["A3C_AssignedVehicleCrew",[]];
	private _isSeatOccupied = (typeName _occupyingUnit == "OBJECT" && {!isNull _occupyingUnit && {alive _occupyingUnit}}) OR {typeName _occupyingUnit == "SCALAR" && {_occupyingUnit == 1}};
	
	{
		_boardingData = _x;
		if ({_x in _boardingData} count [_role,_cargoIndex,_turretPath] >= 2) then {
			_isSeatOccupied = true;
		};
	} foreach _vicVar;
	
	
	if (_isSeatOccupied) exitWith {
		// systemchat 'occupado';
	};
	
	private _seatIndexPath = if (_role in ["driver","cargo"]) then {_cargoIndex} else {_turretPath};

	if (!isNull _specifiedUnit) then {
		//-- unit was specified 
		if (isplayer _specifiedUnit) then {
			//-- ignore players
			_specifiedUnit = objNull;
		} else {
			_unitBoardingData = _specifiedUnit getVariable ["A3C_assignedVehicleSeat",[]];
			//-- enable overRide: end script, reset plot and A3C_assignedVehicleSeat
			if (isNull objectParent _specifiedUnit && {count _unitBoardingData > 0}) then {
				_x remoteExec ["unassignVehicle",0];
				terminate _unitBoardingData select 3;
				_specifiedUnit setVariable ["A3C_assignedVehicleSeat",nil,true];
				_specifiedUnit setVariable ["A3C_PLOT_TEMP",[],false];
				_specifiedUnit setVariable ["A3C_PLOT",[],true];
			};
		};
	} else {
		//-- filter suitable boardingUnits - compatible with single and multiple unit selections
		private _suitableUnits = _refUnits select { !isplayer _x && {isNull objectParent _x && {count (_x getVariable ["A3C_assignedVehicleSeat",[]]) == 0}}};
		//hintSilent str _suitableUnits;
		if (count _suitableUnits > 0) then {
			_specifiedUnit = _suitableUnits select 0;
		} else {
			_specifiedUnit = _refUnits select 0;
		};
	};

	if (isNull _specifiedUnit) exitWith {};
	
	//-- overRiding mechanic
	_vari = _specifiedUnit getVariable ["A3C_assignedVehicleSeat",[]];

	_sleep = 0;
	
	_script = "";
	
	if (count _vari > 0) then {
		_vari params ["_boardVic","_boardRole","_boardSeatIndexPath","_scr1","_boardButtonImg"];

		_specifiedUnit domove (position _specifiedUnit);
		terminate _scr1;
		_boardingScriptRunning = _specifiedUnit getVariable ["A3C_boardingScript",[]];
		if (count _boardingScriptRunning > 0 ) then {
			terminate (_boardingScriptRunning select 0);
		};
		
		
		if (A3C_RADIALMODE == "VEHS" && {A3C_TARGETVEH == _boardVic}) then {
			_boardButtonImg ctrlSetTextColor [1,1,1,1];
		};
		_specifiedUnit setVariable ["A3C_boardingScript",nil];
		_specifiedUnit setVariable ["A3C_assignedVehicleSeat",nil];
		
		{
			if (_specifiedUnit == _x select 0) then {
				_vicVar =  _vicVar - [_x]; 
			};
		} foreach _vicVar;
		_vehicle setVariable ["A3C_AssignedVehicleCrew",_vicVar,true]; 
	};
	
	_boardingScript =	[_specifiedUnit,_vehicle,_role,_seatIndexPath,_buttonImg] spawn A3C_boardSquadUnittoSeat;
	_specifiedUnit setVariable ["A3C_boardingScript",[_boardingScript]];

};

// [units player select 0, testVic, ["driver",[]]] call A3C_Boarding_Hack;
A3C_Boarding_Hack = {
	// player sidechat str _this;
	params ["_unit","_vehicle","_role"];
	// _unit = units player select 3;
	// _vehicle = testvic;
	// _role = ["driver",[]];

	_role params ["_roleId","_roleIndex"];

	

	


	_newGroup = createGroup [(side player),true];
	private _isSelected = _unit in (groupSelectedUnits player);
	[_unit] joinSilent _newGroup;
	_gL = (group player) createUnit ["LOGIC" , (position player) vectorAdd [0,0,50], [], 0, ""]; //"LOGIC"  typeOf _unit   
	if (_isSelected) then {
		player groupSelectUnit [_gl,true];
	};
	_gl hideObjectGlobal true;
	_gl enableSimulation false;
			

	switch (_roleId) do {
		case ("driver") : {_unit assignAsDriver _vehicle;};
		case ("gunner") : {_unit assignAsTurret [_vehicle, _roleIndex];};
		case ("commander") : {_unit assignAsTurret [_vehicle, _roleIndex];};
		case ("turret") : {_unit assignAsTurret [_vehicle, _roleIndex];};
		case ("cargo") : {_unit assignAsCargoIndex [_vehicle, _roleIndex];};
	};
	

	[_unit] orderGetIn true;

	// [_unit, _gl] spawn {
	// 	params ["_unit", "_gl"];
		private _expDOrg = (position _gl) vectorAdd [0,20,0];
		[_gl, _expDOrg] call A3C_DOMOVE;
		
		_name = name _unit;
		_nameStringArray = _name splitString " ";
		_firstName = _nameStringArray deleteAt 0;
		_lastName = _nameStringArray joinstring " ";
		_name = [_firstName + " " + _lastName,_firstName,_lastName];
		sleep 0.1;
		_gl setName _name; 

		while {alive _unit} do {
			private _expD = expectedDestination _gl;
			if ((currentCommand _gl) == "STOP" || (_expD select 0) distance2D _expDOrg > 1) exitWith { //
				_unit remoteExec ["unassignVehicle",0];
				sleep 1;
				// systemchat str (_expD select 0);
				[_unit,(_expD select 0)] call A3C_DOMOVE; //-- << not because _expD is [0,0,0]
			};
			if (!isNull (objectParent _unit)) exitWith {};
			// hintSilent str _expD;
		};
		_isSelected = _gl in (groupSelectedUnits player);
		[_gl] join grpNull;
		[_unit] joinSilent (group player);
		if (_isSelected) then {
			player groupSelectUnit [_unit,true];
		};
		deleteVehicle _gl;
		_vicVar = _vehicle getVariable ["A3C_AssignedVehicleCrew",[]];
		_vicVar =_vicVar select {_x select 0 != _unit};
		// {
		// 	if (_unit == _x select 0) exitWith {
		// 		_vicVar = _vicVar - [_x];
		// 	};
		// } foreach _vicVar; 
		_vehicle setVariable ["A3C_AssignedVehicleCrew",_vicVar,true]; 
		_unit setVariable ["A3C_assignedVehicleSeat",nil,true];

	// }; 

};

A3C_boardSquadUnittoSeat = {
	
	params ["_unit","_tv","_role","_seatIndexPath","_buttonImg"];

	// systemchat str _this;
	// if (true) exitWith {};
	
	_isPlayerAssigned = assignedvehicle player == _tv;
	
	
	
	[[_unit],false,true,true] spawn A3C_AI_Shared_cancelUnitPlot;


	
	

	A3C_BOARD_UNITS_ACTIVE pushbackUnique _unit; //~~ what exactly is this needed for?
	
	
	_vicVar = _tv getVariable ["A3C_AssignedVehicleCrew",[]];
	_vicVar pushBack [_unit,_role,_seatIndexPath]; 
	_tv setVariable ["A3C_AssignedVehicleCrew",_vicVar,true]; 

	

	_unit setVariable ["A3C_assignedVehicleSeat",nil,true];
	_unit setVariable ["A3C_PLOT",[],true];
	private _exit = false;
	
	if (isNull _unit OR {!alive _unit}) then {_exit = true;};
	// if ((_unit distance2d _tv) >= ((sizeOf (typeOf _tv)) /1) + 15) then {_exit = true};  /// /3
		
	if (_exit) exitWith {
		if (_unit in A3C_RD_UNITS) then {
			A3C_BOARD_UNITS pushbackUnique _unit;		
		};
		// if ({{_tv in (_x getVariable ["A3C_assignedVehicleSeat",[]])} count units _x == 0} count allPlayers == 0) then {
		// 	_tv enableAI "MOVE";
		// };
		_unit setVariable ["A3C_boardingScript",nil];
		{
			if (_unit == _x select 0) exitWith {
				_vicVar = _vicVar - [_x];
			};
		} foreach _vicVar;
		_tv setVariable ["A3C_AssignedVehicleCrew",_vicVar,true]; 
	};
	sleep 0.5;
	//-- wait for unit script to finish
	private _scr = [_unit, _tv, [_role,_seatIndexPath]] spawn A3C_Boarding_Hack;
	_unit setVariable ["A3C_assignedVehicleSeat",[_tv,_role,_seatIndexPath,_scr,_buttonImg],true];
	waituntil {scriptDone _scr};

	_unit setVariable ["A3C_boardingScript",nil];
	_vicVar = _tv getVariable ["A3C_AssignedVehicleCrew",[]];
	{
		if (_unit == _x select 0) exitWith {
			_vicVar = _vicVar - [_x];
		};
	} foreach _vicVar; 
	_tv setVariable ["A3C_AssignedVehicleCrew",_vicVar,true]; 

	if (A3C_RADIALMODE == "VEHS" && {_tv == A3C_TARGETVEH}) then {
		_buttonImg ctrlSetTextColor ([A3C_UI_COLOR_BLUE,0.7] call A3C_UI_fnc_setOpacity);
	};
	
	if (_isPlayerAssigned) then {
		player assignAsCargo _tv;
	};
	sleep 1;
	// if ({_tv in (_x getVariable ["A3C_assignedVehicleSeat",[]])} count units player == 0) then {
	// 	_tv enableAI "MOVE";
	// };
	
};





//-- Assign player to Vehicle Used by actionMenu/FSM (PLAYER SELF ASSIGN TO LANDING SQUAD-LEVELCHOPPER)
A3C_AssignPlayerToVehicleCargo = {
	_mode = _this select 0;
	_vehicle = cursortarget;
	if (isNull cursorTarget) exitWith {};
	player removeAction A3C_assign_action_playerToVehicle;
	switch (_mode) do {
		case (0): {
			player remoteExec ["unassignVehicle",0];
		};
		case (1): {
			_freeCargo = fullCrew [_vehicle, "cargo", true];
			_ind = 0;
			{
				if (isNull (_x select 0) OR {!alive (_x select 0)}) then {
					_ind = _x select 2;
				};
			} foreach _freeCargo;
			//systemchat str _ind;
			player assignAsCargoIndex [_vehicle,_ind];
			
		};		
	};	
};

//{[_x,"cargo",heli] spawn A3C_BOARD;} foreach (units player - [player]);

