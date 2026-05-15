params ["_unit", "_targetPos", "_orderDetails"];
_orderDetails params ["_targetVeh", "_ammoType"];

//-- check for charge

private _cfgMagazines = configFile >> "CfgMagazines";

if (_ammoType == "") then {
	private _magazines = magazines _unit;

	private _magIndex = _magazines findIf {
		getText (_cfgMagazines >> _x >> "nameSound") in ["satchelcharge", "mine"]
	};

	if (_magIndex != -1) then {
		_ammoType = _magazines select _magIndex;
	};
};

if (_ammoType == "") exitWith {
	systemChat "no ammotype";
};

//-- get charge position

private _exit = false;

private _getVehicleChargeAttachData = {
	params ["_targetVeh", "_vehicleLength", "_attachHeight"];

	private _vehiclePosAGL = position _targetVeh;
	private _vehicleDir = getDir _targetVeh;
	private _attachDir = [_vehicleDir + 180] call MCSS_fnc_CorrectDir;

	private _attachPosATL = _vehiclePosAGL getPos [_vehicleLength, _attachDir];
	_attachPosATL set [2, _attachHeight];

	private _vehicleTracePosAGL = (_vehiclePosAGL select [0, 2]) + [_attachHeight];

	private _intersections = lineIntersectsSurfaces [
		AGLToASL _attachPosATL,
		AGLToASL _vehicleTracePosAGL,
		objNull,
		objNull,
		true,
		-1
	];

	private _intersectionIndex = _intersections findIf {
		_x select 2 == _targetVeh
	};

	if (_intersectionIndex == -1) exitWith {
		[_vehiclePosAGL, [0, 0, 0], false]
	};

	_attachPosATL = ASLToATL ((_intersections select _intersectionIndex) select 0);
	_attachPosATL set [2, _attachHeight];

	[
		_attachPosATL,
		_targetVeh worldToModel _attachPosATL,
		true
	]
};

private _attachMTW = [0, 0, 0];
private _hasAttachPoint = false;

//-- get attach data or exit if vehicle left
if (_targetVeh isEqualType objNull && {!isNull _targetVeh}) then {
	private _boundingBoxReal = boundingBoxReal _targetVeh;

	private _vehicleLength = ((_boundingBoxReal select 1) select 1) * 2;
	private _attachHeight = (((_boundingBoxReal select 1) select 2) * 0.75) min 1.3;

	private _targetDist = 50;

	if (!isPlayer leader group _unit) then {
		_targetDist = _targetDist * 1.3; //-- be more generous for AI-led groups
	};

	if (_targetVeh distance _targetPos > _targetDist || {speed _targetVeh > 0}) then {
		//-- the target object is no longer at the position
		_exit = true;
	} else {
		private _attachData = [_targetVeh, _vehicleLength, _attachHeight] call _getVehicleChargeAttachData;
		_targetPos = _attachData select 0;
		_attachMTW = _attachData select 1;
		_hasAttachPoint = _attachData select 2;
	};
};

if (_exit) exitWith {
	systemChat "exit (_exit)";
};

//-- move to position

[_unit, _targetPos] call A3C_ai_shared_fnc_doMove;

private _moveTimeoutAt = time + 30;

waitUntil {
	sleep 0.25;

	!alive _unit ||
	{_unit distance2D _targetPos < 2.5} ||
	{
		unitReady _unit &&
		{_unit distance2D _targetPos < 5}
	} ||
	{time > _moveTimeoutAt}
};

if (!alive _unit) exitWith {};

if (_unit distance2D _targetPos > 4) exitWith {};

//-- ordnance requires MP-global var name

if (isNil "A3C_VARNAME_INDEX") then {
	A3C_VARNAME_INDEX = 1;
};

private _uid = if (!isNull player) then {
	getPlayerUID player
} else {
	"111011101111"
};

private _chargeName = format ["A3C_REMOTE_CHARGE_%1_%2", _uid, A3C_VARNAME_INDEX];
A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;

//-- execute placement where the unit is local

[
	[
		_unit,
		_ammoType,
		_chargeName,
		_targetVeh,
		_targetPos,
		_attachMTW,
		_hasAttachPoint
	],
	{
		params [
			"_unit",
			"_ammoType",
			"_chargeName",
			"_targetVeh",
			"_targetPos",
			"_attachMTW",
			"_hasAttachPoint"
		];

		private _cfgMagazines = configFile >> "CfgMagazines";
		private _cfgAmmo = configFile >> "CfgAmmo";

		private _chargeType = getText (_cfgMagazines >> _ammoType >> "ammo");
		private _mineTrigger = getText (_cfgAmmo >> _chargeType >> "mineTrigger");

		private _placementAnim = "ainvpknlmstpslaywrfldnon_medic";

		_unit playMove _placementAnim;
		sleep 2;

		_unit removeMagazine _ammoType;

		private _hasTargetVehicle = _targetVeh isEqualType objNull && {!isNull _targetVeh};
		private _spawnDir = [getDir _unit] call MCSS_fnc_CorrectDir;
		private _spawnPos = _unit getPos [0.5, _spawnDir];

		if (!_hasTargetVehicle) then {
			_spawnPos = +_targetPos;
			_spawnPos set [2, 0];
		};

		private _ordnance = _chargeType createVehicle _spawnPos;
		missionNamespace setVariable [_chargeName, _ordnance, true];

		sleep 2;

		if (_hasTargetVehicle) then {
			if (_hasAttachPoint) then {
				_ordnance attachTo [_targetVeh, _attachMTW];
				_ordnance setVectorDirAndUp [[-1, 0, 0], [0, -1, 0]];
			} else {
				_ordnance setPos position _targetVeh;
			};
		};

		private _timeoutAt = time + 8;

		waitUntil {
			sleep 0.1;
			animationState _unit != _placementAnim ||
			{time > _timeoutAt} ||
			{!alive _unit}
		};

		if (_mineTrigger == "RemoteTrigger") then {
			_unit setVariable [
				"A3C_UNIT_EXPLOSIVES",
				(_unit getVariable ["A3C_UNIT_EXPLOSIVES", []]) + [_ordnance],
				true
			];
		};
	}
] remoteExec ["BIS_fnc_call", _unit];