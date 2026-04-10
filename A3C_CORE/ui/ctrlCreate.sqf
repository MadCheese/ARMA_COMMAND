/*
	Author: Mad_Cheese

	Description:
	Creates a control to the given display / ctrlsGroup
	
	Parameter(s):
	_this select 0: 
	_this select 1:
	_this select 2: 
	_this select 3: 
	_this select 4: 
	_this select 5: 
			
	Returns: 
	created Control

Example:

[
	12,                 //-- the display (in this case, the main map)
	"RscButton",
	7000,
	-2,                 //-- no ControlsGroup (otherwise specify Idc)
	[0.5,0.5,1,1],
	[0,0,0,1],       //-- background color
	[1,1,1,1],       //-- text color     
	"HEY",
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	"systemchat 'button';"
] call MCSS_fnc_ctrlCreate;

>> would create a RscButton ton the map with no eventhandlers and no parent controlsGroup


*/
params
[
	"_dsp",
	"_type",
	"_idc",
	"_cG",		
	"_cPos",
	"_colBack",
	"_colTxt",
	"_txt",
	"_txtSize",
	"_mouseEnter",
	"_mouseExit",
	"_mbDown",
	"_mbUp",
	"_mMoving",
	"_kDown",
	"_kUp",
	"_action"
];
private ["_ctrl"];

_cD = if (_cG == -2)  then {[_type,_idc]} else {[_type,_idc,(findDisplay _dsP) displayCtrl _cG]};
systemchat str _cD;
_ctrl = (findDisplay _dsp) ctrlCreate _cD; 
_ctrl ctrlSetPosition _cPos; 
_ctrl ctrlCommit 0; 

if (count _colBack > 0) then {
	_ctrl ctrlSetBackgroundColor _colBack;
	_ctrl ctrlSetActiveColor _colBack;
};
if (count _colTxt > 0) then {
	_ctrl ctrlSetTextColor _colTxt;	
};

for "_i" from 6 to 12 do {
	_evH = switch (_i) do {
		case (6) : {["MouseEnter",_mouseEnter]};
		case (7) : {["MouseExit",_mouseExit]};
		case (8) : {["MouseButtonDown",_mBDown]};
		case (9) : {["mouseButtonUp",_mbUP]};
		case (10): {["mouseMoving",_mMoving]};
		case (11) : {["keyDown",_kDown]};
		case (12) : {["keyUp",_kUp]};
	};
	_ctrl ctrlAddEventHandler [_evH select 0,_evH select 1];
};
{
	if !(_action isEqualTo {}) then { 
	};
} foreach ["MouseEnter","MouseExit","MouseButtonDown","mouseButtonUp","mouseMoving","keyDown","keyUp"];
if !(_txt == "") then {
	if !(_txtSize == 1) then {
		_ctrl ctrlSetStructuredText parseText (format 
		[
			"
				<t size='%1'>&#160;</t><br/><t size='%2' align='center'>%3&#160;&#160;</t>
			",
			(_txtSize / 0.5),
			_txtSize,
			(parsetext _txt)
	
		]);
	} else {
		_ctrl ctrlSetText _txt;
	};
};


if !(_action == "") then { 
	_ctrl buttonSetAction _action;
};

_ctrl