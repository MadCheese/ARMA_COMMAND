
if (isDedicated) exitWith {};

A3C_facY = ((abs SafeZoneY) + (safeZoneY + safeZoneH)) / 12;

A3C_C_FORM_BOOL_DRAW = false;
A3C_C_FORM_BOOL_ALLOW = false;
A3C_C_FORM_ACTIVE = false;

A3C_C_FORM_DIRECTION = getDir player;

A3C_HUD_FORM_DirRange = {
	private ["_dirCoef1","_dirCoef2","_return"];
	_dirCoef1 = getDir player;
	if (_dirCoef1 >=180) then {
		_dirCoef1 = 360 - _dirCoef1;
	};
	_dirCoef2 = A3C_C_FORM_DIRECTION;
	if (_dirCoef2 >=180) then {
		_dirCoef2 = 360 - _dirCoef2;
	};
	_return = ([_dirCoef1,_dirCoef2] call MCSS_fnc_FindDifference) < 20;
	_return
};

A3C_C_FORM_SelectTeam = {
	with uiNameSpace do {
		params ["_team"];
		A3C_C_FORM_SelectedUnits = [];

		(findDisplay 79994 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,0.2];
		(findDisplay 79994 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,0.2];
		(findDisplay 79994 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,0.2];
		(findDisplay 79994 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,0.2];
		(findDisplay 79994 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,0.2];
		(findDisplay 79994 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,0.2];


		{
			private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
			if ((_assignedTeam == _team) OR (_team == 'ALL')) then {
				A3C_C_FORM_SelectedUnits pushback _x;
			};
		} foreach (units player - [player]);
		
		switch (_team) do {
			case ("RED") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,0,0,1)";
				(findDisplay 79994 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,1];
			};
			case ("GREEN") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0,1,0,1)";
				(findDisplay 79994 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,1];
			};
			case ("BLUE") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0,0,1,1)";
				(findDisplay 79994 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,1];
			};
			case ("YELLOW") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,1,0,1)";
				(findDisplay 79994 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,1];
			};
			
			case ("MAIN") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(1,1,1,1)";
				(findDisplay 79994 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,1];
				
			};
			case ("ALL") : {
				A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0.53,0.29,0.69,1)";				
				(findDisplay 79994 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,1];
			};
		};		
		//systemchat str A3C_C_FORM_SelectedUnits;
	};	
};

A3C_C_FORM_ActivateForm = {
	params ["_mode"];
	if (isDedicated) exitWith {};
	if !(player == leader group player) exitWith {};
	if (A3C_C_FORM_ACTIVE) then {
		A3C_C_FORM_ACTIVE = false;
		(findDisplay 79994 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
		(findDisplay 79994 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
		{
			_x setVariable ["A3C_FORM_MEMBER",false,false];
		} foreach (units player - [player]);
	} else {
		//if (with uinamespace do {count A3C_C_FORM_SelectedUnits > 0}) then {
			A3C_C_FORM_ACTIVE = true;
			A3C_C_FORM_BOOL_ALLOW = true;
			[] spawn {					
				sleep 2;
				A3C_C_FORM_BOOL_ALLOW = false;
			};
			(findDisplay 79994 displayCtrl 16) ctrlSetTextColor [0,1,0,1];
			(findDisplay 79994 displayCtrl 17) ctrlSetText "DEACTIVATE FORMATION";
			A3C_C_FORM_DIRECTION = getDir player;
			//A3C_C_FORM_SelectedUnits = (units player) - [player];
			//_units = if (_mode == 0) then {with uinamespace do {A3C_C_FORM_SelectedUnits}} else {units player - [player]};
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
			
			A3C_FORM_MOVEVAR = 0;
			[] spawn {
				while {A3C_C_FORM_ACTIVE} do {
					if (speed player == 0) then {
						A3C_FORM_MOVEVAR = 0;
					} else {
						if ([] call A3C_HUD_FORM_DirRange) then {
							A3C_FORM_MOVEVAR = A3C_FORM_MOVEVAR + 3;
						} else {
							//A3C_C_FORM_DIRECTION = getDir player;
						};
						A3C_FORM_MOVEVAR = A3C_FORM_MOVEVAR + 1;
					};
					if (A3C_FORM_MOVEVAR >= 3) then {
						A3C_C_FORM_DIRECTION = getDir player;
					};
					//hintsilent str A3C_FORM_MOVEVAR;
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
					while {A3C_C_FORM_ACTIVE && {alive _unit}} do {
						if (A3C_FORM_MOVEVAR >= 3 OR A3C_C_FORM_BOOL_ALLOW) then {
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
	A3C_C_FORM_BOOL_ALLOW = true;
	[] spawn {					
		sleep 2;
		A3C_C_FORM_BOOL_ALLOW = false;
	};
};
A3C_C_FORM_Button_ClearForm = {
	with uiNamespace do {
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_RED;
		A3C_C_FORM_DOTS_RED = [];
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_GREEN;
		A3C_C_FORM_DOTS_GREEN = [];
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_BLUE;
		A3C_C_FORM_DOTS_BLUE = [];
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_YELLOW;
		A3C_C_FORM_DOTS_YELLOW = [];
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_MAIN;
		A3C_C_FORM_DOTS_MAIN = [];
		{ctrlDelete _x} foreach A3C_C_FORM_DOTS_ALL;
		A3C_C_FORM_DOTS_ALL = [];
		A3C_C_FORM_Save_LB = 0;
		[] call A3C_C_FORM_Label_LB;
		
	};
	A3C_C_FORM_ACTIVE = false;
	(findDisplay 79994 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
	(findDisplay 79994 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
	{
		_x setVariable ["A3C_FORM",[],false];
		_x setVariable ["A3C_FORM_MEMBER",false,false];
	} foreach (units player - [player]);

};
profileNameSpace setVariable ["A3C_C_FORMATIONS_SAVED",profileNameSpace getVariable ["A3C_C_FORMATIONS_SAVED",[]]];




A3C_C_FORM_SaveOverlayIsOpen = false;
A3C_C_FORM_SaveButton = {
	params ["_btn"];
	if (!(A3C_C_FORM_ACTIVE) && (_btn == 0)) exitWith {
		systemchat "A3C: Please Engage The Formation First";
	};
	//systemchat str _btn;
	if (_btn == 0) then {
		if !(A3C_C_FORM_SaveOverlayIsOpen) then {
			A3C_C_FORM_SaveOverlayIsOpen = true;
			//systemchat "open";
			with uiNamespace do {
				A3C_C_FORM_SaveBox = A3C_C_FORM_DISPLAY ctrlCreate ["RscEdit", 20];
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
					A3C_C_FORM_Save_LB = (count _profileData); //-- no -1 because CUSTOM is there
					[] call A3C_C_FORM_Label_LB;
				} else {
					systemchat "A3C: No Name Detected";
				};
			};
			A3C_C_FORM_SaveOverlayIsOpen = false;
			
		};
	} else {
		_tickTime = (time - A3C_LB_TICKTIME);
		//_doubleClick = false;
		if ((_tickTime > 0.07) && (_tickTime < 0.3)) then {
			//_doubleClick = true;
			if !(with uiNameSpace do {A3C_C_FORM_Save_LB == 0}) then {
				_profileData = profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED";
				_profileData deleteAt ((lbCurSel (findDisplay 79994 displayCtrl 18)) -1);
				profileNameSpace setVariable ["A3C_C_FORMATIONS_SAVED",_profileData];
				with uiNamespace do {
					A3C_C_FORM_Save_LB = 0;
				};
			};	
		};
		A3C_LB_TICKTIME = time;
		with uiNamespace do {
			if (ctrlShown A3C_C_FORM_SaveBox) then {
				ctrlDelete A3C_C_FORM_SaveBox;			
			};
			[] call A3C_C_FORM_Label_LB;
		};
		A3C_C_FORM_SaveOverlayIsOpen = false;
	};
};

A3C_C_FORM_SPAWNDIALOG = {
	disableSerialization;
	A3C_DOWNKEYS = [];
	with uiNameSpace do {
		A3C_C_FORM_LineColor = "#(argb,8,8,3)color(0.53,0.29,0.69,1)";
		A3C_C_FORM_SelectedUnits = (units player) - [player];
		A3C_C_FORM_DISPLAY = objnull;
		A3C_C_FORM_DOTS_RED = [];
		A3C_C_FORM_DOTS_GREEN = [];
		A3C_C_FORM_DOTS_BLUE = [];
		A3C_C_FORM_DOTS_YELLOW = [];
		A3C_C_FORM_DOTS_MAIN = [];
		A3C_C_FORM_DOTS_ALL = [];
		
		//systemchat "11";
		
		_display = findDisplay 46 createDisplay "HUD_Formation_Menu"; //"RscDisplayEmpty";

		(findDisplay 79994 displayCtrl 10) ctrlSetBackgroundColor [1,0,0,0.2];
		(findDisplay 79994 displayCtrl 11) ctrlSetBackgroundColor [0,1,0,0.2];
		(findDisplay 79994 displayCtrl 12) ctrlSetBackgroundColor [0,0,1,0.2];
		(findDisplay 79994 displayCtrl 13) ctrlSetBackgroundColor [1,1,0,0.2];
		(findDisplay 79994 displayCtrl 14) ctrlSetBackgroundColor [1,1,1,0.2];
		(findDisplay 79994 displayCtrl 15) ctrlSetBackgroundColor [0.53,0.29,0.69,1];
		
		[] call A3C_C_FORM_Label_LB;
		
		//_display = createDialog "HUD_Formation_Menu";
		//if (true) exitWith {};
		_id = 101;
		//systemchat str _display;
		//_frame = _display ctrlCreate ["RscPicture", 8];
		//_frame ctrlSetPosition [safezoneX,safezoneY,safezoneW,safezoneH]; //[0,0,1,1];
		//_frame ctrlSetText "#(argb,8,8,3)color(0,0,0,0.5)";
		//_frame ctrlCommit 0;
		_frame1 = (findDisplay 79994 displayCtrl 9);//_display ctrlCreate ["RscEdit", 9];
		A3C_C_FORM_DISPLAY = _display;
		//_frame1 ctrlSetPosition [safezoneX,safezoneY,safezoneW,safeZoneH]; //[0,0,1,1];
		//_frame1 ctrlCommit 0;
		//_frame1 ctrlSetText "#(argb,8,8,3)color(1,1,0,1)";
		
		A3C_C_FORM_MouseUp = false;
		/*
		_tBox = _display ctrlCreate ["RscEdit", 20];
		_tBox ctrlSetPosition 
		[
			0.282338 * safezoneW + safezoneX,
			0.389982 * safezoneH + safezoneY,
			0.349405 * safezoneW,
			0.0550088 * safezoneH
		];
		_btnSave = _display ctrlCreate ["RscButton", 21];
		_btnSave ctrlSetText "SAVE";
		_btnSave ctrlSetPosition 
		[
			0.637471 * safezoneW + safezoneX,
			0.389982 * safezoneH + safezoneY,
			0.0400956 * safezoneW,
			0.0550088 * safezoneH
		];
		_btnCancel = _display ctrlCreate ["RscButton", 22];
		_btnCancel ctrlSetText "CANCEL";
		_btnCancel ctrlSetActi
		_btnCancel ctrlSetPosition 
		[
			0.683294 * safezoneW + safezoneX,
			0.389982 * safezoneH + safezoneY,
			0.0400956 * safezoneW,
			0.0550088 * safezoneH
		];		
		{_x ctrlCommit 0} foreach [_tBox,_btnSave,_btnCancel];
		*/
		_frame1 ctrlAddEventHandler
		[
			"mouseMoving",
			{
				if (A3C_C_FORM_BOOL_DRAW) then {
					//with UINamespace do {
						params ["_display","_posX","_posY"];
						//systemchat str [_posX toFixed 2,_posY toFixed 2];
						_data = [_posX,_posY] call A3C_C_FORM_GETRELDATA;
						
						[_posX,_posY] call A3C_C_FORM_DrawDot;
					
						//systemchat str _data;
					//};
				};
			}
		];
		_frame1 ctrlAddEventHandler
		[
			"mouseButtonDown",
			{
				params ["_display","_button","_posX","_posY"];
				if (_button == 1) exitWith {};
				if (_posX > (0.5 + (6 * A3C_facY))) exitWith {};
				//systemchat str [_posX toFixed 2,_posY toFixed 2];
				if (with uiNameSpace do {count A3C_C_FORM_SelectedUnits == 0}) exitWith {};
				A3C_C_FORM_BOOL_DRAW = true;
				A3C_C_FORM_MouseUp = true;
				
				with uiNamespace do {
					A3C_C_FORM_LineLength = 0;
					A3C_C_FORM_Dots = [];
					A3C_C_FORM_POSES = [];
					A3C_C_FORM_Save_LB = 0;
					[] call A3C_C_FORM_Label_LB;
					{
						if (A3C_C_FORM_LineColor == _x) then {
							switch (_forEachIndex) do {
								case (0) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_RED;
									A3C_C_FORM_DOTS_RED = [];
								};
								case (1) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_GREEN;
									A3C_C_FORM_DOTS_GREEN = [];
								};
								case (2) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_BLUE;
									A3C_C_FORM_DOTS_BLUE = [];
								};
								case (3) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_YELLOW;
									A3C_C_FORM_DOTS_YELLOW = [];
								};
								case (4) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_MAIN;
									A3C_C_FORM_DOTS_MAIN = [];
								};
								case (5) : {
									{ctrlDelete _x} foreach A3C_C_FORM_DOTS_ALL;
									A3C_C_FORM_DOTS_ALL = [];
								};
							};
						};
					} foreach
					[
						"#(argb,8,8,3)color(1,0,0,1)",
						"#(argb,8,8,3)color(0,1,0,1)",
						"#(argb,8,8,3)color(0,0,1,1)",
						"#(argb,8,8,3)color(1,1,0,1)",
						"#(argb,8,8,3)color(1,1,1,1)",
						"#(argb,8,8,3)color(0.53,0.29,0.69,1)"
					];
				};
			}
		];
		_frame1 ctrlAddEventHandler
		[
			"mouseButtonUp",
			{
				params ["_display","_button","_posX","_posY"];
				if !(A3C_C_FORM_MouseUp) exitWith {};
				if (_button == 1) exitwith {};
				//systemchat str [_posX toFixed 2,_posY toFixed 2];
				A3C_C_FORM_MouseUp = false;
				A3C_C_FORM_BOOL_DRAW = false;
				//A3C_C_FORM_Dots = [];
				A3C_C_FORM_BOOL_ALLOW = true;
				if (with uinamespace do {count A3C_C_FORM_SelectedUnits == 0}) exitWith {};
				
				[] spawn {					
					sleep 2;
					A3C_C_FORM_BOOL_ALLOW = false;
				};
				with uiNamespace do {
					//{ctrlDelete _x} foreach A3C_C_FORM_Dots;
					switch (A3C_C_FORM_LineColor) do {
						case ("#(argb,8,8,3)color(1,0,0,1)") : {A3C_C_FORM_DOTS_RED = +(A3C_C_FORM_Dots)};
						case ("#(argb,8,8,3)color(0,1,0,1)") : {A3C_C_FORM_DOTS_GREEN = +(A3C_C_FORM_Dots)};
						case ("#(argb,8,8,3)color(0,0,1,1)") : {A3C_C_FORM_DOTS_BLUE = +(A3C_C_FORM_Dots)};
						case ("#(argb,8,8,3)color(1,1,0,1)") : {A3C_C_FORM_DOTS_YELLOW = +(A3C_C_FORM_Dots)};
						case ("#(argb,8,8,3)color(1,1,1,1)") : {A3C_C_FORM_DOTS_MAIN = +(A3C_C_FORM_Dots)};
						case ("#(argb,8,8,3)color(0.53,0.29,0.69,1)") : {A3C_C_FORM_DOTS_ALL = +(A3C_C_FORM_Dots)};						
					};
					A3C_C_FORM_Dots = [];
					A3C_C_FORM_LineLength = 0;
					{
						if (_forEachIndex > 0) then {
							_d = _x distance (A3C_C_FORM_POSES select (_forEachIndex - 1));
							A3C_C_FORM_LineLength = A3C_C_FORM_LineLength + _d;
						};
					} foreach A3C_C_FORM_POSES;

					_spacing = (A3C_C_FORM_LineLength / (count A3C_C_FORM_SelectedUnits)); //(count A3C_C_FORM_SelectedUnits)

					_realPoses = [A3C_C_FORM_POSES select 0];
					{
						if (_forEachIndex > 0) then {
							_d = _x distance (_realPoses select ((count _realPoses) -1));// (A3C_C_FORM_POSES select (_forEachIndex - 1));
							if (_d >= _spacing) then {
								_realPoses pushback _x;
							} else {
								if ( (_forEachIndex + 1) == (count A3C_C_FORM_POSES)) then {									
									if !((count _realPoses) == (count A3C_C_FORM_SelectedUnits)) then {
										_realPoses pushback _x;
									}; 
								};
							};
						};
					} forEach A3C_C_FORM_POSES;
					{
						_pos = _realPoses select _forEachIndex;
						_vDist = player distance _pos;
						_vDir = player getRelDir _pos;
						_x setVariable ["A3C_FORM",[_vDist,_vDir],false];
						//if !(currentCommand _x == "SCRIPTED") then {
							//_x spawn {
							//	doStop _this;
							//	sleep 0.2;
							//	_this doFSM ["A3C_CORE\fsm\doFormation.fsm", position _this,_this]; 
							//};
						//}; //-- making sure that stationary units go to formation when formation is drawn
					} foreach A3C_C_FORM_SelectedUnits; //-- has to be selected units!!
					//player commandchat str _realPoses;				
				}; 
			}
		];
		//hint str [safezoneX,safezoneY,safezoneW,safezoneH];
		_difX = (abs SafeZoneX) + (safeZoneW + safeZoneX);
		_difY = (abs SafeZoneY) + (safeZoneY + safeZoneH);
		A3C_facY = _difY / 12; //--12: total will be 60m, so in the end this will translate to 5 m increments 
		_amountOfX = _difX / A3C_facY;
		_radius = (_difY / 2);
		_startX = (0.5 - (6 * A3C_facY)); //safeZoneX + 
		_endX = (0.5 + (6 * A3C_facY));
		 
		_cX = safeZoneX + (_difX / 2);
		_cY = safeZoneY + (_difY / 2);

		//player commandchat str (0.5 - (6 * A3C_facY));

		for "_gridY" from safeZoneY to (safeZoneY + safeZoneH) step A3C_facY do {
			for "_gridX" from _startX to _endX step A3C_facY do {
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
	if (A3C_C_FORM_ACTIVE) then {			
		(findDisplay 79994 displayCtrl 16) ctrlSettextColor [0,1,0,1];
		(findDisplay 79994 displayCtrl 17) ctrlSetText "DEACTIVATE FORMATION";
	} else {
		(findDisplay 79994 displayCtrl 16) ctrlSetTextColor [1,0,0,1];
		(findDisplay 79994 displayCtrl 17) ctrlSetText "ACTIVATE FORMATION";
	};
};
A3C_C_FORM_Dots = [];
A3C_C_FORM_TickDir = 0;
A3C_C_FORM_POSES = [];
A3C_C_FORM_LineLength = 0;

A3C_C_FORM_LB_Change = {
	if (A3C_CurSel) exitwith {};
	if (_this select 0 == 0) exitwith {
		with uiNameSpace do {
			A3C_C_FORM_Save_LB = 0;
		};
	};
	with uiNamespace do {
		params ["_lb"];
		//if (A3C_CurSel) exitwith {};
		//player sidechat str (lbCurSel (findDisplay 79994 displayCtrl 18));
		//_listbox = (findDisplay 79994 displayCtrl 18);
		_data = ((profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED") select (_lb - 1)) select 1;
		_finish = (count (units player - [player])) - 1;
		{
			if (_forEachIndex < (count _data)) then {
				_x setvariable ["A3C_FORM",(_data select _forEachIndex),false];
			};
		} forEach (units player - [player]);
		A3C_C_FORM_Save_LB = _lb;
	};
	A3C_C_FORM_BOOL_ALLOW = true;
	[] spawn {					
		sleep 2;
		A3C_C_FORM_BOOL_ALLOW = false;
	};
};


with uiNamespace do {
	
	A3C_C_FORM_Save_LB = 0;
	
	A3C_C_FORM_Label_LB = {

		_listbox = (findDisplay 79994 displayCtrl 18);
		lbClear _listBox;
		[_listBox, "CUSTOM"] call A3C_addLbEntry;
		{
			[_listBox, (_x select 0)] call A3C_addLbEntry;
		} foreach (profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED");
		[_listbox, A3C_C_FORM_Save_LB] call A3C_setCurSel;	

	};
	A3C_C_FORM_GETRELDATA = {
		//
			params ["_posX","_posY"];
			Private ["_dist","_dir","_return"];
			_dist = ([_posX,_posY] distance [0.5,0.5]) / A3C_facY;
			_dist = _dist * 5;
			_dir = (360 - ( [_posX,_posY] getDir [0.5,0.5]) );// [360 - ( [_posX,_posY] getDir [0.5,0.5])] call MCSS_fnc_CorrectDir;	
			_return = [_dist,_dir];
			//player sidechat str _return;
			_return
		//};
	};
	A3C_C_FORM_WorldtoGrid = {
		params ["_pos"];
	};
	
};




A3C_C_FORM_DrawDot = {
	
	//if (A3C_C_FORM_BOOL_DRAW) then {
		with uiNameSpace do {
			params ["_gridX","_gridY"];
			private ["_relData"];
			_idc = 1000 + (count A3C_C_FORM_Dots);
			
			_dot = (A3C_C_FORM_DISPLAY) ctrlCreate ["RscPicture", _idC];
			A3C_C_FORM_Dots pushBackUnique _dot;
			
			_relData = ([_gridX,_gridY] call A3C_C_FORM_GETRELDATA);
			
			//_relPos = [player,_relData select 0,_relData select 1] call BIS_fnc_getRelPos; // not yet considering player dir
			_relPos = player getRelPos [_relData select 0,_relData select 1];
			_relPos set [2,0];
			
			if (_idc == 1000) then {
				A3C_C_FORM_POSES = [_relPos];		
			} else {
				_dist = (_relPos distance (A3C_C_FORM_POSES select ((count A3C_C_FORM_POSES) -1)));
				//A3C_C_FORM_LineLength = A3C_C_FORM_LineLength + _dist;
				//if (_dist >= 3) then {
					
					A3C_C_FORM_POSES pushback _relPos;
					//systemchat "add";
				//};
				//systemchat str (_relPos distance (A3C_C_FORM_POSES select ((count A3C_C_FORM_POSES) -1)));
				//_dir = () select 1;

				//A3C_C_FORM_TickDir = [360 - ( [_gridX,_gridY] getDir [0.5,0.5])] call MCSS_fnc_CorrectDir;
			};
			//systemchat str A3C_C_FORM_LineLength;
			//_dot ctrlSetPosition [_gridX ,_gridY  ,1 * (safezoneH / safeZoneW),1 * safezoneH];
			_dot ctrlSetText A3C_C_FORM_LineColor; //"#(argb,8,8,3)color(1,1,1,1)"; 
			_dot ctrlSetPosition [_gridX ,_gridY  ,0.005 * (safezoneH / safeZoneW),0.005 * safezoneH];
			_dot ctrlCommit 0;
			//systemchat str [_gridX ,_gridY  ,0.005 * (safezoneH / safeZoneW),0.005 * safezoneH];
		};
	//};
};

