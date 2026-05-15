// A3C_ai_shared_fnc_calculatePath

//-- NOTE: THIS FNC IS NEITHER USED NOR OPTIMIZED. IT'S A PLACEHOLDER TO BE RE-WRITTEN WITH THE HELP OF THE HELP OF:
//-- https://steamcommunity.com/sharedfiles/filedetails/?id=3677819186
//-- ONCE UPDATED, IT WILL BE USED FOR BETTER FOLLOWING LOGIC IN CONVOY (fncs_convoyPath which is also currently unused)

params ["_unit", "_destination"];
// systemchat 'yo';
private _startPos = getPosASL (vehicle _unit);
private _direction = getDir (vehicle _unit);

_startPos set [2,0]; 
_destination set [2,0];




//-- #TODO: create road-positions for depart/destination

private _skyPos = _startPos vectorAdd [0,0,10000];
private _agent = createAgent [typeOf player, [0,0,0], [], 0, "NONE"]; 
private _car =  "B_APC_Tracked_01_rcws_F" createVehicleLocal [0,0,10000 + random 1000]; //"B_Quadbike_01_F", (typeOf vehicle _unit)
_car setPosASL _skyPos;
_car hideObject true;

// {} foreach [_agent, _car] //-- make agents invisible


_agent setBehaviourStrong (behaviour _unit); //"CARELESS";  //-- #TODO: Careless may not always be the best, maybe actual behaviour is relevant
_agent moveInDriver _car;

_car setDir _direction;



// _origDest = (expectedDestination _agent) select 0;
_pathFinal = [];
private _globalVarID =  format ["A3C_CONV_%1",round (random 1000000)];
_agent setVariable [
	"A3C_VEHICLE_PATH",
	[
		[],
		false
	]
];

_agent addEventHandler
[
	"PathCalculated", 
	{  
		params ["_agent", "_path"];

		private _globalVarID = _agent getVariable "A3C_VEHICLE_PATH";

		//-- unsuccessful path
		if (_path isEqualTo []) exitWith {
			_agent setVariable [
				"A3C_VEHICLE_PATH",
				[
					[],
					true
				]
			];
		};

		//-- successful path
		{
			_x set [2,0];
		} foreach _path;		
		
		for "_i" from 0 to 1 do {
			{ //-- remove non road position at beginning and end of path
			
				if (isOnRoad _x) exitWith {
					//systemchat 'road';
				};
				_path = _path - [_x];
			} foreach _path;
			reverse _path; //-- path will be reversed twice, setting it back to normal
		};

		_agent setVariable [
			"A3C_VEHICLE_PATH",
			[
				_path,
				true
			]
		];
	}
];
	
//-- set agent on path
_agent setDestination [_destination, "LEADER PLANNED", true];

// sleep 0.5; 

//-- wait for path calculation to complete
private _timer = time;
waitUntil {(_agent getVariable "A3C_VEHICLE_PATH") select 1  OR (time - _timer > 5)};



private _path = (_agent getVariable ["A3C_VEHICLE_PATH", [[],true] ] ) select 0;


if (_path isEqualTo []) exitWith {
	// systemchat "PATH CALC FAILED";
	_unit setVariable [
		"A3C_VEHICLE_PATH",
		[
			[],
			(_startPos distance2D _destination) //-- replacement distance to the destination in a straight line
		]
	];
};

{
	if (_x distance2D _agent > 30) exitWith {};
	_path = _path - [_x];
} foreach _path; //-- loop just incase of a sneaky snake road, we only check in the beginning


_totalPathLength = 0;
{
	private _initPos = if (_foreachIndex == 0) then {getPosASL _agent} else {_path select (_foreachIndex - 1)};
	private _dist = _initPos distance2D _x;
	_totalPathLength = _totalPathLength + _dist;
	// [format ["M_%1",_foreachIndex],_x,"ICON","mil_dot",[1,1],"","ColorYellow"] call MCSS_fnc_createMarker;
} foreach _path;

{deleteVehicle _x} foreach [vehicle _agent,_agent];

// systemchat format ['PATH CALCULATED, total length: %1', _totalPathLength];
_unit setVariable [
	"A3C_VEHICLE_PATH",
	[
		_path,
		_totalPathLength
	]
];	




