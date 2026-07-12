
if (isDedicated) exitWith {};

A3C_UI_CustomFormation_GridUnit = ((abs SafeZoneY) + (safeZoneY + safeZoneH)) / 12;



A3C_UI_CustomFormation_fnc_getDirRange = {
	private ["_dirCoef1","_dirCoef2","_return"];
	_dirCoef1 = getDir player;
	if (_dirCoef1 >=180) then {
		_dirCoef1 = 360 - _dirCoef1;
	};
	_dirCoef2 = A3C_UI_CustomFormation_formationDirection;
	if (_dirCoef2 >=180) then {
		_dirCoef2 = 360 - _dirCoef2;
	};
	_return = (abs (_dirCoef1 - _dirCoef2)) < 20;
	_return
};

A3C_UI_CustomFormation_fnc_selectTeam = {
	with uiNameSpace do {
		params ["_team"];
		A3C_UI_CustomFormation_selectedUnits = [];

		(findDisplay 100080 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,0.2];
		(findDisplay 100080 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,0.2];
		(findDisplay 100080 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,0.2];
		(findDisplay 100080 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,0.2];
		(findDisplay 100080 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,0.2];
		(findDisplay 100080 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,0.2];


		{
			private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
			if ((_assignedTeam == _team) OR (_team == 'ALL')) then {
				A3C_UI_CustomFormation_selectedUnits pushback _x;
			};
		} foreach (units player - [player]);
		
		switch (_team) do {
			case ("RED") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,0,0,1)";
				(findDisplay 100080 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,1];
			};
			case ("GREEN") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0,1,0,1)";
				(findDisplay 100080 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,1];
			};
			case ("BLUE") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0,0,1,1)";
				(findDisplay 100080 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,1];
			};
			case ("YELLOW") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,1,0,1)";
				(findDisplay 100080 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,1];
			};
			
			case ("MAIN") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,1,1,1)";
				(findDisplay 100080 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,1];
				
			};
			case ("ALL") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0.53,0.29,0.69,1)";				
				(findDisplay 100080 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,1];
			};
		};		
		//systemchat str A3C_UI_CustomFormation_selectedUnits;
	};	
};

A3C_UI_CustomFormation_fnc_activateFormation = {
	params ["_mode"];
	if (isDedicated) exitWith {};
	if !(player == leader group player) exitWith {};
	if (A3C_UI_CustomFormation_BOOL_formationActive) then {
		A3C_UI_CustomFormation_BOOL_formationActive = false;
		(findDisplay 100080 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
		(findDisplay 100080 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
		{
			_x setVariable ["A3C_FORM_MEMBER",false,false];
		} foreach (units player - [player]);
	} else {
		//if (with uinamespace do {count A3C_UI_CustomFormation_selectedUnits > 0}) then {
			A3C_UI_CustomFormation_BOOL_formationActive = true;
			A3C_UI_CustomFormation_BOOL_ALLOW = true;
			[] spawn {					
				sleep 2;
				A3C_UI_CustomFormation_BOOL_ALLOW = false;
			};
			(findDisplay 100080 displayCtrl 16) ctrlSetTextColor [0,1,0,1];
			(findDisplay 100080 displayCtrl 17) ctrlSetText "DEACTIVATE FORMATION";
			A3C_UI_CustomFormation_formationDirection = getDir player;
			//A3C_UI_CustomFormation_selectedUnits = (units player) - [player];
			//_units = if (_mode == 0) then {with uinamespace do {A3C_UI_CustomFormation_selectedUnits}} else {units player - [player]};
			_units = units player - [player];
			{
				if (isPlayer _x) then {_units = _units - [_x]};
			} foreach _units;
			
			{
				if (_mode == 1) then {
					_x setVariable ["A3C_FORM",[_x distance player, player getRelDir _x],false];
				} else {
					if (count (_x getVariable ["A3C_FORM",[]]) == 0) then {
						_x setVariable ["A3C_FORM",[_x distance player, player getRelDir _x],false];
					};
				};			
			} foreach _units;
			
			A3C_UI_CustomFormation_moveVar = 0;
			[] spawn {
				while {A3C_UI_CustomFormation_BOOL_formationActive} do {
					if (speed player == 0) then {
						A3C_UI_CustomFormation_moveVar = 0;
					} else {
						if ([] call A3C_UI_CustomFormation_fnc_getDirRange) then {
							A3C_UI_CustomFormation_moveVar = A3C_UI_CustomFormation_moveVar + 3;
						} else {
							//A3C_UI_CustomFormation_formationDirection = getDir player;
						};
						A3C_UI_CustomFormation_moveVar = A3C_UI_CustomFormation_moveVar + 1;
					};
					if (A3C_UI_CustomFormation_moveVar >= 3) then {
						A3C_UI_CustomFormation_formationDirection = getDir player;
					};
					//hintsilent str A3C_UI_CustomFormation_moveVar;
					if (speed player == 0) then {sleep 0.1} else{sleep 0.5};
				};
			};

			sleep 0.1;
			{
				[_x] spawn {
					params ["_unit"];
					if (isDedicated) exitWith {};
					if (isPlayer _unit) exitWith {};
					_unit doTarget objNull;
					_unit dowatch objNull;
					_unit lookAt objNull;
					if (isMultiplayer) then {doStop _unit; sleep 0.2;};
					//_unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit,_unit]; 
					while {A3C_UI_CustomFormation_BOOL_formationActive && {alive _unit}} do {
						if (A3C_UI_CustomFormation_moveVar >= 3 OR A3C_UI_CustomFormation_BOOL_ALLOW) then {
							//systemchat str time;
							_var = _unit getVariable ["A3C_FORM",[] ];
							if (count _var > 0) then {
								_formDist = (_var select 0);
								_formDir = (getDir player) + (_var select 1);
								_formPos = (player getpos [_formDist,_formDir]);
								
								_dist = _unit distance _formPos;
								if ((_dist > 2) && (speed player > 10)) then {
									_formPos = [_formPos,5,(getDir player)] call BIS_fnc_relPos;
								};
								_dist = _unit distance _formPos; //
								if (currentCommand _unit == "SCRIPTED" OR isMultiplayer) then {
									//if !((expecTedDestination _unit select 1) == "DoNotPlan") then {
										if (_unit getVariable ["A3C_FORM_MEMBER",false]) then {
											_unit moveTo _formPos;
										};
									//};
								};
								//if (isMultiplayer) then {
									//if (((expectedDestination _unit select 0) distance _formPos) <= 10) then {
										//_unit moveTo _formPos;
									//};
								//};
								if (["form",(expecTedDestination _unit select 1) ] call BIS_fnc_instring) then {
									doStop _unit;
									sleep 0.2;
									//systemchat str time;
									_unit setVariable ["A3C_FORM_MEMBER",true,false];
									if (isMultiplayer) then {
										_unit moveTo (position _unit);
									} else {
										_unit doFSM ["A3C_CORE\fsm\doFormation.fsm", position _unit,_unit];
									}; 
								};
								
								//systemchat str _dist;
								if ( ( (_dist < 7) && (speed player == 0))  ) then { // _dist < 3 OR 
									_unit ForceSpeed 2; //((speed player) + 0.3) max 2;
									//sleep 0.5;
								} else {
									_unit ForceSpeed -1;
									
									if (_dist < 4) then {
										if (speed player < 6) then {
											_unit ForceSpeed 2;
										};
									};
									

								};
							};
						};
						//sleep 0.1;
						if (speed _unit == 0) then {sleep 0.1} else {sleep 0.2};
						if (!isNull objectParent _unit) then {sleep 1.5};
					};
					_unit setVariable ["A3C_FORM_MEMBER",false,false];
					_unit forceSpeed -1;
				};
			} foreach _units;
		//};
	};
	A3C_UI_CustomFormation_BOOL_ALLOW = true;
	[] spawn {					
		sleep 2;
		A3C_UI_CustomFormation_BOOL_ALLOW = false;
	};
};

A3C_UI_CustomFormation_fnc_clearFormation = {
	with uiNamespace do {
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_RED;
		A3C_UI_CustomFormation_Dots_RED = [];
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_GREEN;
		A3C_UI_CustomFormation_Dots_GREEN = [];
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_BLUE;
		A3C_UI_CustomFormation_Dots_BLUE = [];
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_YELLOW;
		A3C_UI_CustomFormation_Dots_YELLOW = [];
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_MAIN;
		A3C_UI_CustomFormation_Dots_MAIN = [];
		{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_ALL;
		A3C_UI_CustomFormation_Dots_ALL = [];
		A3C_UI_CustomFormation_saveLB = 0;
		[] call A3C_UI_CustomFormation_fnc_labelListbox;
		
	};
	A3C_UI_CustomFormation_BOOL_formationActive = false;
	(findDisplay 100080 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
	(findDisplay 100080 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
	{
		_x setVariable ["A3C_FORM",[],false];
		_x setVariable ["A3C_FORM_MEMBER",false,false];
	} foreach (units player - [player]);

};
profileNameSpace setVariable ["A3C_C_FORMATIONS_SAVED",profileNameSpace getVariable ["A3C_C_FORMATIONS_SAVED",[]]];




A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
A3C_UI_CustomFormation_FNC_SaveButton = {
	params ["_btn"];
	if (!(A3C_UI_CustomFormation_BOOL_formationActive) && (_btn == 0)) exitWith {
		systemchat "A3C: Please Engage The Formation First";
	};
	//systemchat str _btn;
	if (_btn == 0) then {
		if !(A3C_UI_CustomFormation_SaveOverlayIsOpen) then {
			A3C_UI_CustomFormation_SaveOverlayIsOpen = true;
			//systemchat "open";
			with uiNamespace do {
				A3C_C_FORM_SaveBox = A3C_UI_CustomFormation_Display ctrlCreate ["RscEdit", 20];
				A3C_C_FORM_SaveBox ctrlSetPosition 
				[
					0.660383 * safezoneW + safezoneX,
					0.709033 * safezoneH + safezoneY,
					0.217662 * safezoneW,
					0.044007 * safezoneH
				];
				A3C_C_FORM_SaveBox ctrlCommit 0;
			};
		} else {
			//save
			//systemchat "save";
			
			with uiNamespace do {
				_nameString =  str (parsetext (ctrlText A3C_C_FORM_SaveBox));
				if !(_nameString == "") then {
					_dataArray = [];
					{
						_dataArray pushBack (_x getVariable ["A3C_FORM",[]]);
					} foreach (units player - [player]);
					_dataArray = [_nameString,_dataArray];
					_profileData = profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED";
					_profileData pushback _dataArray;
					profileNameSpace setVariable ["A3C_C_FORMATIONS_SAVED",_profileData];
					if (ctrlShown A3C_C_FORM_SaveBox) then {
						ctrlDelete A3C_C_FORM_SaveBox;			
					};
					A3C_UI_CustomFormation_saveLB = (count _profileData); //-- no -1 because CUSTOM is there
					[] call A3C_UI_CustomFormation_fnc_labelListbox;
				} else {
					systemchat "A3C: No Name Detected";
				};
			};
			A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
			
		};
	} else {
		_tickTime = (time - A3C_LB_TICKTIME);
		//_doubleClick = false;
		if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
			//_doubleClick = true;
			if !(with uiNameSpace do {A3C_UI_CustomFormation_saveLB == 0}) then {
				_profileData = profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED";
				_profileData deleteAt ((lbCurSel (findDisplay 100080 displayCtrl 18)) -1);
				profileNameSpace setVariable ["A3C_C_FORMATIONS_SAVED",_profileData];
				with uiNamespace do {
					A3C_UI_CustomFormation_saveLB = 0;
				};
			};	
		};
		A3C_LB_TICKTIME = time;
		with uiNamespace do {
			if (ctrlShown A3C_C_FORM_SaveBox) then {
				ctrlDelete A3C_C_FORM_SaveBox;			
			};
			[] call A3C_UI_CustomFormation_fnc_labelListbox;
		};
		A3C_UI_CustomFormation_SaveOverlayIsOpen = false;
	};
};






A3C_UI_CustomFormation_FNC_spawnDialog = {
	disableSerialization;
	A3C_UI_DOWNKEYS = [];
	with uiNameSpace do {
		A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0.53,0.29,0.69,1)";
		A3C_UI_CustomFormation_selectedUnits = (units player) - [player];
		A3C_UI_CustomFormation_Display = objnull;
		A3C_UI_CustomFormation_Dots_RED = [];
		A3C_UI_CustomFormation_Dots_GREEN = [];
		A3C_UI_CustomFormation_Dots_BLUE = [];
		A3C_UI_CustomFormation_Dots_YELLOW = [];
		A3C_UI_CustomFormation_Dots_MAIN = [];
		A3C_UI_CustomFormation_Dots_ALL = [];
		
		//systemchat "11";
		
		private _display = findDisplay 46 createDisplay "HUD_Formation_Menu"; //"RscDisplayEmpty";

		(findDisplay 100080 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,0.2];
		(findDisplay 100080 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,0.2];
		(findDisplay 100080 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,0.2];
		(findDisplay 100080 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,0.2];
		(findDisplay 100080 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,0.2];
		(findDisplay 100080 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,1];
		
		[] call A3C_UI_CustomFormation_fnc_labelListbox;
		

		private _id = 101;

		private _frame1 = (findDisplay 100080 displayCtrl 9);
		A3C_UI_CustomFormation_Display = _display;

		
		A3C_UI_CustomFormation_BOOL_isMouseUp = false;

		//hint str [safezoneX,safezoneY,safezoneW,safezoneH];
		_difX = (abs SafeZoneX) + (safeZoneW + safeZoneX);
		_difY = (abs SafeZoneY) + (safeZoneY + safeZoneH);
		A3C_UI_CustomFormation_GridUnit = _difY / 12; //--12: total will be 60m, so in the end this will translate to 5 m increments 
		_amountOfX = _difX / A3C_UI_CustomFormation_GridUnit;
		_radius = (_difY / 2);
		_startX = (0.5 - (6 * A3C_UI_CustomFormation_GridUnit)); //safeZoneX + 
		_endX = (0.5 + (6 * A3C_UI_CustomFormation_GridUnit));
		 
		_cX = safeZoneX + (_difX / 2);
		_cY = safeZoneY + (_difY / 2);

		//player commandchat str (0.5 - (6 * A3C_UI_CustomFormation_GridUnit));

		for "_gridY" from safeZoneY to (safeZoneY + safeZoneH) step A3C_UI_CustomFormation_GridUnit do {
			for "_gridX" from _startX to _endX step A3C_UI_CustomFormation_GridUnit do {
				_edit = _display ctrlCreate ["RscPicture", _id];
				_edit ctrlSetPosition [_gridX ,_gridY  ,0.005 * (safezoneH / safeZoneW),0.005 * safezoneH]; //?   * safezoneW * safezoneH
				_edit ctrlSetText "#(argb,8,8,3)color(1,1,1,1)";
				//-- no idea why, but more simple checks did not work although _gridX returned 0.5
				if ([str _gridX,str _gridY] isEqualTo ["0.5","0.5"]) then {
					_edit ctrlSetText "#(argb,8,8,3)color(1,0,0,1)";
				};
				_edit ctrlCommit 0;
				_id = _id + 1;
			};
		};
	};
	if (A3C_UI_CustomFormation_BOOL_formationActive) then {			
		(findDisplay 100080 displayCtrl 16) ctrlSettextColor [0,1,0,1];
		(findDisplay 100080 displayCtrl 17) ctrlSetText "DEACTIVATE FORMATION";
	} else {
		(findDisplay 100080 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
		(findDisplay 100080 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
	};
};


with uiNamespace do {
	
	A3C_UI_CustomFormation_saveLB = 0;
	
	A3C_UI_CustomFormation_fnc_labelListbox = {

		_listbox = (findDisplay 100080 displayCtrl 18);
		lbClear _listBox;
		[_listBox, "CUSTOM"] call A3C_addLbEntry;
		{
			[_listBox, (_x select 0)] call A3C_addLbEntry;
		} foreach (profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED");
		[_listbox, A3C_UI_CustomFormation_saveLB] call A3C_setCurSel;	

	};
	A3C_UI_CustomFormation_getRelativeData = {
		params ["_posX","_posY"];
		Private ["_dist","_dir","_return"];
		// systemchat str [_posX,_posY, A3C_UI_CustomFormation_GridUnit];
		_dist = ([_posX,_posY] distance [0.5,0.5]) / A3C_UI_CustomFormation_GridUnit;
		_dist = _dist * 5;
		_dir = (360 - ( [_posX,_posY] getDir [0.5,0.5]) );// [360 - ( [_posX,_posY] getDir [0.5,0.5])] call MCSS_fnc_correctDir;	
		_return = [_dist,_dir];
		//player sidechat str _return;
		_return
	};
};




A3C_UI_CustomFormation_fnc_drawDot = {
	
	//if (A3C_UI_CustomFormation_BOOL_DRAW) then {
		with uiNameSpace do {
			params ["_gridX","_gridY"];
			private ["_relData"];
			_idc = 1000 + (count A3C_UI_CustomFormation_Dots);
			
			_dot = (A3C_UI_CustomFormation_Display) ctrlCreate ["RscPicture", _idC];
			A3C_UI_CustomFormation_Dots pushBackUnique _dot;
			
			_relData = ([_gridX,_gridY] call A3C_UI_CustomFormation_getRelativeData);
			
			//_relPos = [player,_relData select 0,_relData select 1] call BIS_fnc_getRelPos; // not yet considering player dir
			_relPos = player getRelPos [_relData select 0,_relData select 1];
			_relPos set [2,0];
			
			if (_idc == 1000) then {
				A3C_UI_CustomFormation_Poses = [_relPos];		
			} else {
				_dist = (_relPos distance (A3C_UI_CustomFormation_Poses select ((count A3C_UI_CustomFormation_Poses) -1)));
				//A3C_UI_CustomFormation_lineLength = A3C_UI_CustomFormation_lineLength + _dist;
				//if (_dist >= 3) then {
					
					A3C_UI_CustomFormation_Poses pushback _relPos;
					//systemchat "add";
				//};
				//systemchat str (_relPos distance (A3C_UI_CustomFormation_Poses select ((count A3C_UI_CustomFormation_Poses) -1)));
				//_dir = () select 1;

				//A3C_UI_CustomFormation_tickDir = [360 - ( [_gridX,_gridY] getDir [0.5,0.5])] call MCSS_fnc_correctDir;
			};
			//systemchat str A3C_UI_CustomFormation_lineLength;
			//_dot ctrlSetPosition [_gridX ,_gridY  ,1 * (safezoneH / safeZoneW),1 * safezoneH];
			_dot ctrlSetText A3C_C_FORM_LineColor; //"#(argb,8,8,3)color(1,1,1,1)"; 
			_dot ctrlSetPosition [_gridX ,_gridY  ,0.005 * (safezoneH / safeZoneW),0.005 * safezoneH];
			_dot ctrlCommit 0;
			//systemchat str [_gridX ,_gridY  ,0.005 * (safezoneH / safeZoneW),0.005 * safezoneH];
		};
	//};
};

