#include "ui\radial\radialMenu\dialog_defines.hpp"

FHINT = {
	
	if (!isNil 'TT' && {TT}) then {
		TT = false;
		sleep 0.5;
	};
	
	TT = true;
	while {TT} do {
		hintsilent str (call _this);
		sleep 0.1;
	};
};


A3C_Cursorbox = {
	(((lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],vehicle player,objNull,true,1,"GEOM","NONE"]) select 0) select 2) call {
    private ["_obj","_bb","_bbx","_bby","_bbz","_arr","_y","_z"];
    _obj = _this;
    _bb = {
        _bbx = [_this select 0 select 0, _this select 1 select 0];
        _bby = [_this select 0 select 1, _this select 1 select 1];
        _bbz = [_this select 0 select 2, _this select 1 select 2];
        _arr = [];
        0 = {
            _y = _x;
            0 = {
                _z = _x;
                0 = {
                    0 = _arr pushBack (_obj modelToWorld [_x,_y,_z]);
                } count _bbx;
            } count _bbz;
            reverse _bbz;
        } count _bby;
        _arr pushBack (_arr select 0);
        _arr pushBack (_arr select 1);
        _arr
    };
    bbox = boundingBox _obj call _bb;
    bboxr = boundingBoxReal _obj call _bb;
    addMissionEventHandler ["Draw3D", {
        for "_i" from 0 to 7 step 2 do {
            drawLine3D [
                bbox select _i,
                bbox select (_i + 2),
                [0,0,1,1]
            ];
            drawLine3D [
                bboxr select _i,
                bboxr select (_i + 2),
                [0,1,0,1]
            ];
            drawLine3D [
                bbox select (_i + 2),
                bbox select (_i + 3),
                [0,0,1,1]
            ];
            drawLine3D [
                bboxr select (_i + 2),
                bboxr select (_i + 3),
                [0,1,0,1]
            ];
            drawLine3D [
                bbox select (_i + 3),
                bbox select (_i + 1),
                [0,0,1,1]
            ];
            drawLine3D [
                bboxr select (_i + 3),
                bboxr select (_i + 1),
                [0,1,0,1]
            ];
        };
    }];
};
};



A3CDebugHint = false;
A3CHint = {
	params ["_object","_mode"];
	//if (count _this < 1) exitWIth {};
	if (A3CDebugHint) then {
		A3CDebugHint = false;
		sleep 0.1;
	};
	

	
	_hint = "";
	_hintArray = [];
	if (!isNil '_mode') then {
		switch _mode do {
			case ("weapon") : {
				
				_data = [
					format ["Type: %1",name _object],
					format ["Vehicle: %1",typeOf vehicle _object],
					format ["Prim Weapon: %1", primaryWeapon _object],
					format ["Magazine: %1",currentMagazine vehicle _object]
				];
				{
					//if (_forEachINdex == (count _data - 1)) then {
						_hintArray = _hintArray + [_x, lineBreak];
					//} else {
					//	_hintArray = _hintArray + [_x, lineBreak,];
					//};
				} foreach _data; 
				_hint = composeText _hintArray;
			};
			case ("move") : {
				_diag_message = 
				[
					"waypoint aborted",
					linebreak,
					format ["unit: %1", name _object],
					linebreak,
					format ["orig dest: %1",_origdest],
					linebreak,
					format ["current dest: %1",(expecteddestination _unit) select 0],
					linebreak,
					format ["distance between destinations: %1",((expecteddestination _unit) select 0) distance _origdest],
					linebreak,
					format ["current destination mode: %1",(expecteddestination _unit) select 1],
					linebreak,
					format ["current command type: %1",currentcommand _unit]
				];
			};
		};
	};
	
	while {A3CDebugHint} do {
		if (typeName _object == "CODE") then {
			hintsilent (call _object);
		} else {
			hintSilent _hint;
		};
		//
		sleep 0.1;
	};
	
	
};



MoveHint = {
	params ["_unit"];	
	if (A3CDebugHint) then {
		A3CDebugHint = false;
		sleep 1;
	};
	A3CDebugHint = true;
	while {A3CDebugHint} do {
		_diag_message = 
		[
			"waypoint aborted",
			linebreak,
			format ["unit: %1", name _unit],
			linebreak,
			format ["current dest: %1",(expecteddestination _unit) select 0],
			linebreak,
			format ["destination mode: %1",(expecteddestination _unit) select 1],
			linebreak,
			format ["current command type: %1",currentcommand _unit],
			linebreak,
			format ["unitReady Driver: %1",unitReady _unit],
			linebreak,
			format ["unitReady Commander: %1",unitReady (effectiveCommander vehicle _unit)],
			linebreak,
			format ["moveToCompleted: %1",moveToCompleted _unit]
		];
		hintSilent composeText _diag_message;
		sleep 0.1;
	};
};



