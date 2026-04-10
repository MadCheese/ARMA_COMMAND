
A3C_SHIP_startBoat = {
	params ["_boat"];
	private _dir = getDir _boat;
	private _startPos = getPosATL _boat;
	private _suitables = [];
	private _waterFound = false;
	private _depth = 0;
	for "_m" from 10 to 100 step 5 do {
		for "_i" from 0 to 360 step 5 do {
			private _testpos = _startPos getpos [_m,_i];
			if (surfaceIsWater _testpos) then {
				_depth = (ASLtoATL ((_testPos select [0,2]) + [0])) select 2;
				if (_depth >= 2) then {
					_waterFound = true;
					_suitables pushBack [_i,_testPos];
				};
			};
		};
		if (_waterFound) exitWith {};
	};
	private _dirSum = 0;
	{_dirSum = _dirSum + (_x select 0)} foreach _suitables;
	_average = if ({_x == 0} count [_dirSum,(count _suitables)] > 0) then {_dirSum / (count _suitables)} else {0};
	_suitables = [_suitables,[],{abs (_average - (_x select 0))},"ASCEND"] call BIS_fnc_sortBy;
	private _pick = _suitables select 0;
	_pick params ["_pickDir","_pickPos"];
	_pickPos set [2,0];
	private _exit = false;
	for "_i" from 1 to (round (_boat distance _pickPos)) do {
		if (_exit) exitWith {};
		private _testpos = _startPos getpos [_i,_pickDir];
		if (surfaceIsWater _testpos) then {
			_testPos set [2,0];
			_depth = ((ASLtoATL _testPos) select 2);
			if (_depth >= 2) then {
				//~~ TO DO: add check for obstructions
				_pickPos = _testPos;
				_exit = true;
			};
		};
	};
	//-- put boat on found position
	_boat setPosASL _pickPos; //-- _pickPos has z-val of 0 - using ASL puts boat on surface
	_boat setDir _pickDir;
};
