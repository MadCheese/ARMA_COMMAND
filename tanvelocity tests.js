d1 = false;
t1 disableBrakes true;
[] spawn {
	while {true} do {
		v1 = velocitymodelspace t1;
		v1 set [2,5];
		d1 = true;
		t1 setvelocityModelSpace v1;
        sleep 1.5;
        d1 = false;
        sleep 1;
		
	};
};
oneachframe {
	_vehicle = t1;
    if !(d1) then {
        _vehicle setVelocityModelspace [0,5,0];
    };
	
};




player attachTo [t1, [0,0,1.3] ]; 

[] spawn {
	_vPos = getposASL t1;
	_newDir = [(getdir t1) - 1] call MCSS_fnc_CorrectDir;
	_tPos = ATLtoASL (_vPos getPos [1, _newDir]);
	[t1, _vPos, _tPos, 5, _newDir] spawn A3C_AI_RAIL_HELI
};
