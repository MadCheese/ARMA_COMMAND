//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------  R U L E S  O F  E N G A G E M E N T     ------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------


A3C_ROE_FOML_RELEASE = {
	//if (count A3C_ROE3_UNITS == 0) exitWith {};
	{

		_c = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};;
		_d = expectedDestination _x;
		_tgt = assignedTarget _x;
		//if (combatmode _x == "BLUE") then { // <-- even though unit does not fire, it returns player's combatmode. can not use.
			[_x,["COMBATMODE","YELLOW"]] call MCSS_fnc_orderIndividual;
			if (isnull _tgt) then {
				_x dotarget _tgt;
			};
			// ^^ put that target stuff into the orderindividual function!
		//};
	} foreach A3C_ROE3_UNITS;
	A3C_BOOL_ROE_3 = false;
	A3C_ROE3_UNITS = [];
	if (!isNil "A3C_FIRED_COMMAND") then {
		player removeEventHandler ["fired", A3C_FIRED_COMMAND];
		A3C_FIRED_COMMAND = nil;
	};
};



//-- Fire at will / Fire only on target
A3C_RadialMenu_ROE = {
	_mode = _this select 0;
	if (count (groupSelectedUnits player) == 0) exitwith {};
	//systemchat str _mode;
	_unitNames = "";
	switch (_mode) do {
		case (0) : {
			{
				_unit = _x;
				_unit setvariable ["A3C_ROE",false,true];
				_unit enableAI "AUTOTARGET";
				_unitNames = _unitNames + ([_unit,1] call MCSS_fnc_NAMESTRING);
			} foreach A3C_RD_UNITS;
			player groupchat _unitNames + " Fire At Will!";
			player groupradio "SentNoTarget"; 
			player groupradio "SentOpenFire";
		};
		case (1) : {
			{
				_unit = _x;
				_unitNames = _unitNames + ([_unit,1] call MCSS_fnc_NAMESTRING);
				_unit setvariable ["A3C_ROE",true,true];
				[_unit] spawn {
					_unit = _this select 0;
					while {alive _unit} do {
						if !(_unit getvariable "A3C_ROE") exitwith {_unit enableAI "AUTOTARGET"};
						_unit disableAI "AUTOTARGET";
						sleep 5;
					};
				};
			} foreach A3C_RD_UNITS;
			player groupradio "SentHoldFireInCombat";
			player groupradio "SentEngageNoTarget";
			player groupchat _unitNames  + " Hold Fire! (Hold Fire Unless Ordered)";
			//systemchat "dayumm";

		};
		case (2) : {
			if (A3C_BOOL_ROE_3) then {
				{
					if !(_x in A3C_ROE3_UNITS) then {
						A3C_ROE3_UNITS pushback _x;
					};
					[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual;
				} foreach A3C_RD_UNITS;
			} else {
				{_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING)} foreach A3C_RD_UNITS;
				player groupchat  _unitNames + " Hold Fire! (Fire On My Lead)";
				player groupradio "SentHoldFireInCombat";
				A3C_ROE3_UNITS = (groupSelectedUnits player);
				{
					if (isPlayer _x) then {A3C_ROE3_UNITS = A3C_ROE3_UNITS - [_x]};
				} foreach A3C_ROE3_UNITS;
				A3C_BOOL_ROE_3 = true;
				{[_x,["COMBATMODE","BLUE"]] call MCSS_fnc_orderIndividual} foreach A3C_ROE3_UNITS;
				if (isNil "A3C_FIRED_COMMAND") then {
					A3C_FIRED_COMMAND = player addEventHandler
					[
						"FIRED",
						{
							[(_this select 1)] spawn {
								if ((_this select 0) == "Throw") then {sleep 5;};
								sleep 0.1;
								player groupChat "Fire!";
								player groupradio "SentFireNoTarget";
								[] call A3C_ROE_FOML_RELEASE;
							};
						}
					];
				};
			};
		};
	};
};


//-- toggle "AUTOCOMBAT" fsm-ability
A3C_TOGGLEDANGER = {
	private ["_units","_unitNames"];
	_units = _this select 0;
	//-- exclude Pilots from re-enabling
	{
		if ( (typeOf (vehicle _x)) isKindOf "AIR") then {
			if (_x == (driver (vehicle _x))) then {
				if (_x in A3C_DANGER_UNITS) then {
					_units = _units - [_x];
				};
			};
		};
	} foreach _units;
	if (count _units == 0) exitwith {};
	_unitNames = "";

	private  _autocombatIMG = "A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa";
	if ({_x in A3C_DANGER_UNITS} count _units == 0) then {
		{
			_script = [_x] spawn {
				private ["_unit"];
				_unit = _this select 0;
				_unit dowatch objnull;
				while {alive _unit} do {
					_unit disableAI "AUTOCOMBAT";
					sleep 5;
				};
			};
			_x setvariable ["A3C_DANGERSCRIPT",_script,true];
			_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING);
			A3C_DANGER_UNITS pushback _x;
		} foreach _units;
		hint format ["AUTOCOMBAT DISABLED FOR %1", _unitNames];
		((findDisplay 7999) displayCtrl 10014) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_autocombat_disabled.paa";
		((findDisplay 7999) displayCtrl 10015) ctrlSetTooltip "ENABLE AUTOCOMBAT";
		sleep 2;
		hint "";
	} else {
		{
			if (_x in A3C_DANGER_UNITS) then {
				terminate (_x getVariable "A3C_DANGERSCRIPT");
				_x enableAI "AUTOCOMBAT";
				_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING);
				A3C_DANGER_UNITS = A3C_DANGER_UNITS - [_x];
			};

		} foreach _units;
		hint format ["AUTOCOMBAT ENABLED FOR %1", _unitNames];
		((findDisplay 7999) displayCtrl 10014) ctrlSetText "A3C_CORE\ui\pictures\icon_menu_autocombat_enabled.paa";
		((findDisplay 7999) displayCtrl 10015) ctrlSetTooltip "DISABLE AUTOCOMBAT";
		sleep 2;
		hint "";
	};
};