// ["NAME",_pos,"ICON","mil_dot",[1,1],"FACTORY","ColorYellow"] call MCSS_fnc_createMarker;


call compile format
[
	"
		%1 = createmarkerLocal ['%1', [0,0,0]];
		'%1' setmarkerposLocal %2;
		'%1' setmarkershapeLocal '%3';
		'%1' setmarkertypeLocal '%4';
		'%1' setmarkersizeLocal %5;
		'%1' setmarkerTextLocal '%6';
		'%1' setmarkerColorLocal '%7';
		'%1' setmarkerAlphaLocal %8;
		'%1' setMarkerBrushLocal '%9';				
	",
	parseText (_this select 0),
	_this select 1,
	_this select 2,
	_this select 3,
	_this select 4,
	_this select 5,
	_this select 6,
	if (count _this > 7) then {_this select 7} else {1},
	if (count _this > 8) then {_this select 8} else {'Solid'}	
];

_this select 0