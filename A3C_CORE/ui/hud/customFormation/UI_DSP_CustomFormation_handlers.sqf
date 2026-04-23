A3C_UI_CustomFormation_onMouseButtonDown = {
	params ["_display","_button","_posX","_posY"];
	if (_button == 1) exitWith {};
	if (_posX > (0.5 + (6 * A3C_UI_CustomFormation_GridUnit))) exitWith {};

	if (with uiNameSpace do {count A3C_UI_CustomFormation_selectedUnits == 0}) exitWith {};
	A3C_UI_CustomFormation_BOOL_DRAW = true;
	A3C_UI_CustomFormation_BOOL_isMouseUp = true;
	
	with uiNamespace do {
		A3C_UI_CustomFormation_lineLength = 0;
		A3C_UI_CustomFormation_Dots = [];
		A3C_UI_CustomFormation_Poses = [];
		A3C_UI_CustomFormation_saveLB = 0;
		[] call A3C_UI_CustomFormation_fnc_labelListbox;
		{
			if (A3C_C_FORM_LineColor == _x) then {
				switch (_forEachIndex) do {
					case (0) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_RED;
						A3C_UI_CustomFormation_Dots_RED = [];
					};
					case (1) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_GREEN;
						A3C_UI_CustomFormation_Dots_GREEN = [];
					};
					case (2) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_BLUE;
						A3C_UI_CustomFormation_Dots_BLUE = [];
					};
					case (3) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_YELLOW;
						A3C_UI_CustomFormation_Dots_YELLOW = [];
					};
					case (4) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_MAIN;
						A3C_UI_CustomFormation_Dots_MAIN = [];
					};
					case (5) : {
						{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots_ALL;
						A3C_UI_CustomFormation_Dots_ALL = [];
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
};

A3C_UI_CustomFormation_onMouseButtonUp = {
	params ["_display","_button","_posX","_posY"];
	if !(A3C_UI_CustomFormation_BOOL_isMouseUp) exitWith {};
	if (_button == 1) exitwith {};
	//systemchat str [_posX toFixed 2,_posY toFixed 2];
	A3C_UI_CustomFormation_BOOL_isMouseUp = false;
	A3C_UI_CustomFormation_BOOL_DRAW = false;
	//A3C_UI_CustomFormation_Dots = [];
	A3C_UI_CustomFormation_BOOL_ALLOW = true;
	if (with uinamespace do {count A3C_UI_CustomFormation_selectedUnits == 0}) exitWith {};

	[] spawn {					
		sleep 2;
		A3C_UI_CustomFormation_BOOL_ALLOW = false;
	};
	with uiNamespace do {
		//{ctrlDelete _x} foreach A3C_UI_CustomFormation_Dots;
		switch (A3C_C_FORM_LineColor) do {
			case ("#(argb,8,8,3)color(1,0,0,1)") : {A3C_UI_CustomFormation_Dots_RED = +(A3C_UI_CustomFormation_Dots)};
			case ("#(argb,8,8,3)color(0,1,0,1)") : {A3C_UI_CustomFormation_Dots_GREEN = +(A3C_UI_CustomFormation_Dots)};
			case ("#(argb,8,8,3)color(0,0,1,1)") : {A3C_UI_CustomFormation_Dots_BLUE = +(A3C_UI_CustomFormation_Dots)};
			case ("#(argb,8,8,3)color(1,1,0,1)") : {A3C_UI_CustomFormation_Dots_YELLOW = +(A3C_UI_CustomFormation_Dots)};
			case ("#(argb,8,8,3)color(1,1,1,1)") : {A3C_UI_CustomFormation_Dots_MAIN = +(A3C_UI_CustomFormation_Dots)};
			case ("#(argb,8,8,3)color(0.53,0.29,0.69,1)") : {A3C_UI_CustomFormation_Dots_ALL = +(A3C_UI_CustomFormation_Dots)};						
		};
		A3C_UI_CustomFormation_Dots = [];
		A3C_UI_CustomFormation_lineLength = 0;
		{
			if (_forEachIndex > 0) then {
				_d = _x distance (A3C_UI_CustomFormation_Poses select (_forEachIndex - 1));
				A3C_UI_CustomFormation_lineLength = A3C_UI_CustomFormation_lineLength + _d;
			};
		} foreach A3C_UI_CustomFormation_Poses;

		_spacing = (A3C_UI_CustomFormation_lineLength / (count A3C_UI_CustomFormation_selectedUnits)); //(count A3C_UI_CustomFormation_selectedUnits)

		_realPoses = [A3C_UI_CustomFormation_Poses select 0];
		{
			if (_forEachIndex > 0) then {
				_d = _x distance (_realPoses select ((count _realPoses) -1));// (A3C_UI_CustomFormation_Poses select (_forEachIndex - 1));
				if (_d >= _spacing) then {
					_realPoses pushback _x;
				} else {
					if ( (_forEachIndex + 1) == (count A3C_UI_CustomFormation_Poses)) then {									
						if !((count _realPoses) == (count A3C_UI_CustomFormation_selectedUnits)) then {
							_realPoses pushback _x;
						}; 
					};
				};
			};
		} forEach A3C_UI_CustomFormation_Poses;
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
		} foreach A3C_UI_CustomFormation_selectedUnits; //-- has to be selected units!!
		//player commandchat str _realPoses;				
	};
};

A3C_UI_CustomFormation_onMouseMoving = {
	if (A3C_UI_CustomFormation_BOOL_DRAW) then {
		params ["_display","_posX","_posY"];
		private _data = [_posX,_posY] call A3C_UI_CustomFormation_getRelativeData;
		[_posX,_posY] call A3C_UI_CustomFormation_fnc_drawDot;
	};
};

A3C_UI_CustomFormation_onLBselChanged = {
	if (A3C_CurSel) exitwith {};
	if (_this select 0 == 0) exitwith {
		with uiNameSpace do {
			A3C_UI_CustomFormation_saveLB = 0;
		};
	};
	with uiNamespace do {
		params ["_lb"];

		_data = ((profileNameSpace getVariable "A3C_C_FORMATIONS_SAVED") select (_lb - 1)) select 1;
		_finish = (count (units player - [player])) - 1;
		{
			if (_forEachIndex < (count _data)) then {
				_x setvariable ["A3C_FORM",(_data select _forEachIndex),false];
			};
		} forEach (units player - [player]);
		A3C_UI_CustomFormation_saveLB = _lb;
	};
	A3C_UI_CustomFormation_BOOL_ALLOW = true;
	[] spawn {					
		sleep 2;
		A3C_UI_CustomFormation_BOOL_ALLOW = false;
	};
};