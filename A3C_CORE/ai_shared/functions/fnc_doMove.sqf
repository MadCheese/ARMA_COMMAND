// A3C_ai_shared_fnc_doMove

// -- Issues an individual movement order for an AI unit or the vehicle occupied by that unit.
// -- On foot, movement is issued directly to the unit.
// -- In a vehicle, movement is issued to the driver and, where applicable,
// -- also to the vehicle's AI effective commander.
// -- If a player is the vehicle's effective commander, uses the tested
// -- commandMove + moveTo combination on the AI driver.
// -- This function never issues group-level movement orders.


// -- IMPORTANT:
// -- Movement issued by this function is monitored with [_unit] call A3C_main_fnc_isEngineMovementComplete.
//
// -- moveToCompleted is intentionally not used for this normal scripted
// -- movement path, except when player is effectiveCommander. A3C testing found it unreliable with the doMove / moveTo
// -- combination used here, even though BI documentation states that it can
// -- also work with doMove / commandMove.
//
// -- In A3C, moveToCompleted is otherwise reserved for low-level moveTo movement inside
// -- doFSM / commandFSM FSMs, where its state has been confirmed to behave consistently

params ["_unit", "_destination"];



if (
	isNil "_unit"
	|| {isNull _unit}
	|| {isPlayer _unit}
	|| {isNil "_destination"}
) exitWith {};

if (A3C_Debug) then {
	(format ["fnc_doMove: %1 (%2 | %3) to %4", _unit, groupID (group _unit), side _unit,  _destination]) call A3C_Debug_fnc_log;
};

//-- Invalid position: issuing this order would send the unit to world origin.
if (_destination distance2D [0, 0, 0] < 0.1) exitWith {};


//-- Standard individual AI movement push.
//-- doMove and moveTo target the same destination deliberately so that
//-- either movement path can reinforce the other if one fails to take effect.
private _issueMovementOrder = {
	params ["_moveUnit"];

	_moveUnit doMove _destination;
	_moveUnit moveTo _destination;
};


private _parentVehicle = objectParent _unit;
private _isOnFoot = isNull _parentVehicle;




//-- ON FOOT
if (_isOnFoot) exitWith {

	//-- Defensive initialization for callers that inspect expectedDestination.
	if (expectedDestination _unit isEqualTo []) then {
		_unit setDestination [position _unit, "DoNotPlan", true];
	};

	{_unit enableAI _x} foreach ["MOVE", "PATH"];
	_unit forceSpeed -1;

	[_unit] call _issueMovementOrder;

	_unit
};

//-- Remember: Foot soldiers EXIT above!!

//-- MOUNTED 
private _vehicle = vehicle _unit;
private _driver = driver _vehicle;
private _effectiveCommander = effectiveCommander _vehicle;

//-- A vehicle without an AI driver cannot be moved by this function.
if (
	isNull _driver
	|| {isPlayer _driver}
) exitWith {
	_unit
};

//-- A mounted unit may move the vehicle only if the movement order was
//-- issued to the vehicle's driver or its current effective commander.
//-- Cargo, gunners, and other passengers must never move the vehicle merely
//-- because they happen to be inside it.
if !(_unit in [_driver, _effectiveCommander]) exitWith {
	_unit
};


//-- A driver may ignore movement orders while the vehicle's effective
//-- commander belongs to another group. Transfer vehicle command to the
//-- driver before issuing the order.
if (
	isNull _effectiveCommander
	|| {!(_effectiveCommander in units group _driver)}
) then {
	_vehicle setEffectiveCommander _driver;
	_effectiveCommander = effectiveCommander _vehicle;
};


//-- If the local player occupies the vehicle, retain vehicle command.
//-- Without this protection, issuing movement orders can cause the engine
//-- to switch vehicle command and potentially eject the player.



if (
	isPlayer (leader (group _unit))
	&& {player in _vehicle}
	&& {!isPlayer _effectiveCommander}
) then {
	_vehicle setEffectiveCommander player;
	_effectiveCommander = effectiveCommander _vehicle;
};


//-- Prepare this vehicle only for movement.
_vehicle engineOn true;
// _vehicle limitSpeed false;

// if (_vehicle isKindOf "HELICOPTER") then {
// 	_vehicle land "NONE";

// 	private _altitude = _vehicle getVariable ["A3C_FLYINHEIGHT", 75];
// 	_vehicle flyInHeight _altitude;
// };


//-- Prepare the actual AI movement recipients.
private _movementUnits = [_driver];

if (
	!isNull _effectiveCommander
	&& {!isPlayer _effectiveCommander}
	&& {_effectiveCommander isNotEqualTo _driver}
) then {
	_movementUnits pushBack _effectiveCommander;
};

{
	private _movementUnit = _x;

	//-- Defensive initialization for callers that inspect expectedDestination.
	if (expectedDestination _movementUnit isEqualTo []) then {
		_movementUnit setDestination [position _movementUnit, "DoNotPlan", true];
	};

	{
		_movementUnit enableAI _x;
	} forEach ["MOVE", "PATH"];
} forEach _movementUnits;


//-- Issue movement.
if (isPlayer _effectiveCommander) then {

	//-- When a player is the vehicle's effective commander, testing showed that
	//-- the normal doMove path on the AI driver can fail to produce movement.
	//-- commandMove + moveTo on the driver reliably moved both helicopters and
	//-- ground vehicles, so this deliberately uses that alternate command pair.
	_driver commandMove _destination;
	_driver moveTo _destination;

} else {

	//-- Reinforce the same vehicle movement through both valid AI control
	//-- paths when driver and effective commander are different units.
	{
		[_x] call _issueMovementOrder;
	} forEach _movementUnits;
};

_unit