// A3C_ai_shared_fnc_reArm_autoIssueOrder

params ["_unit", "_crate", "_primaryMode", "_secondaryMode", "_backpackMode"];

if (isPlayer _unit) exitWith {};

private _previousDestination = [_unit] call A3C_ai_shared_fnc_setDestination;
private _cratePos = _crate getRelPos [3, random 360];

_unit setVariable ["A3C_REARMING", true, true];

private _markerName = format ["A3C_Mark_P%1", A3C_MARKER_COUNT];

private _wpData = [
	[_cratePos, _cratePos getPos [100, _unit getDir _cratePos]], // Positions
	[_markerName, _markerName, _markerName],                    // Markers
	["REARM", [_crate, [[], _primaryMode, _secondaryMode, _backpackMode]]], // WP action
	["NONE", "NONE"],                                           // WP condition
	["UP", "UP"],                                               // WP stances
	[[0, false]],                                                // WP sync data
	false,                                                       // isWPCompleted
	0,                                                           // combat mode
	-1,                                                          // WP speed
	25,                                                          // WP flying height
	-1,                                                          // WP loop value
	-1.5                                                         // Radius
];

A3C_MARKER_COUNT = A3C_MARKER_COUNT + 1;

_unit setVariable ["A3C_PLOT", [_wpData], true];

[
	_unit,
	_unit getVariable "A3C_PLOT"
] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

waitUntil {
	sleep 0.25;
	(_unit getVariable ["A3C_PLOT", []]) isEqualTo []
};

// Check if unit should stock up on meds.
private _unitItems = items _unit;

private _hasMedicalItem = A3C_MEDICAL_itemStrings findIf {
	private _medicalItemNeedle = toLower _x;

	_unitItems findIf {
		_medicalItemNeedle in toLower _x
	} != -1
} != -1;

if (!_hasMedicalItem) then {
	// Unit has no meds - add them if possible.
	private _itemCount = 0;
	private _crateItems = itemCargo _crate;

	{
		private _crateItem = _x;
		private _crateItemLower = toLower _crateItem;

		if (A3C_MEDICAL_itemStrings findIf { _x in _crateItemLower } != -1) then {
			_unit addItem _crateItem;
			// TODO: Improve ACE compatibility?
			// Not 100% necessary as any item is good enough to heal / revive.

			_itemCount = _itemCount + 1;
		};

		if (_itemCount == 2) exitWith {};
	} forEach _crateItems;
};

[_unit] call A3C_ai_squad_fnc_actionResumeDestination;

_unit setVariable ["A3C_REARMING", nil, true];