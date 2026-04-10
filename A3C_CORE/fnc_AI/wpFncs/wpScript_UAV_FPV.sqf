


// params
// [
// 	"_group",
// 	"_pos",
// 	"_target",
// 	"_callerUID",
// ];

_group = _this select 0;
_pos = _this select 1;
_target = _this select 2;
_callerUID = _this select 3;


if ([_callerUID,_group] call A3C_HC_WPScriptBlock) exitWith {};

[_group] call A3C_HC_ReInitGroupMovement;

// systemchat ("WP SCRIPT " + (str time));

// if (true) exitWith {
// 	sleep 10;
// 	true
// };

private _drone = vehicle (leader _group);
private _movePos = position _target;

[_drone] call MCSS_fnc_setVehicleVarname;
[_target] call MCSS_fnc_setVehicleVarname;

_drone enableAI "ALL";
_drone engineOn true;
// _drone setMass 400; //-- increase mass to increase max flying speed

_drone flyInHeight 100;

private _tickTime = time;

private _flyingHeight = 100;

private _condMove = {
	params ["_drone","_target", "_flyingHeight"];
	canMove _drone &&
	{
		_drone distance2d _target > 200 || //-- keep moving if target is far
		{
			// (position _drone) select 2 < _flyingHeight
			(position _drone) select 2 < 30 //-- keep moving if drone altitude is too low
		}
	}
};

private _condSpeed = {
	params ["_drone","_target"];
	private _currentSpeed = speed _drone;
	private _fov = 40;
	_currentSpeed < 150 && //-- Reminder: satisfied condition is responsible for the debug hint flicker ;)
	{
		_currentSpeed > 20 &&
		{
			(getPosATL _drone) select 2 > 20 &&
			{
				private _relDir = _drone getRelDir _target;
				// systemchat str _relDir;




				// ///////////////////////// REMOVE THIS ENTIRE BLOCK AFTER TESTING
				// _c1 = _relDir < _fov; //-- CLEAN THIS UP AFTER
				// _c2 = _relDir > (360 - _fov);

				// if (_c1) then {
				// 	player sidechat str _relDir;
				// } else {
				// 	if (_c2) then {
				// 		player groupchat str _relDir;
				// 	} else {
				// 		//-- NO ADJUST
				// 		player globalchat str _relDir;
				// 	};
				// };
				// /////////////////////////




				// _b = _c1 || {_c2};
				// // systemchat str [_b, round (speed _drone)];
				

				// _c1 || {_c2}
				
				private _return = _relDir < _fov ||
				{
					_relDir > (360 - _fov)
				};
				// systemchat format
				// [
				// 	"bool: %1 - speed: %2 - height: %3 - targetDistance: %4",
				// 	_return,
				// 	round (speed _drone),
				// 	round ((getPosATL _drone) select 2),
				// 	round (_drone distance2D _target)
				// ];
				_return
			}
		}
	}
};



while {[_drone, _target, _flyingHeight] call _condMove} do {
	if (time - _tickTime >= 5) then {
		// [_group, currentWaypoint _group] setWaypointPosition [position _target, 0];
		_movePos = position _target;
		[(driver _drone),_movePos] call A3C_DOMOVE;
		_tickTime = time; 
	};

	if (speed _drone > 10) then {
		private _vm = velocityModelSpace _drone;

		//-- adjust height no matter what
		if ((getPosATL _drone) select 2 > (_flyingHeight - 5)) then { //-- allow buffer of 5 for flyingheight
			_vm set [2,(_vm select 2) - 0.4];
		};

		if ([_drone, _target] call _condSpeed) then {
			// hintSilent "ADJUST";
			
			
			_vm set [1,(_vm select 1) + 0.2];
			
		// } else {
		// 	hintSilent "NO ADJUST";
		};

		_drone setVelocityModelspace _vm;
	};
	
	

	private _sleep = [1 / diag_fps,2] call BIS_fnc_cutDecimals;

	sleep _sleep; //0.01; //-- REMOVE AFTER TESTING!!
	// systemchat "moving drone " + (str time);
	// sleep 2;
	
};




if (canMove _drone) then {
	// [_drone, _target] spawn A3C_UAV_FPV_V1; 
	[_drone, _target] spawn A3C_FPV_RAIL;
	[_group] spawn {
		params ["_group"];
		while {alive leader _group} do {
			{deleteWaypoint _x} foreach (waypoints _group);
			sleep 0.5;
		};
	};
} else {
	_drone setdamage 1;
};

true

