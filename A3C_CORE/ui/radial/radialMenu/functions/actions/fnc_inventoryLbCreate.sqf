// A3C_ui_radialMenu_fnc_inventoryLbCreate

//-- This function uses numeric IDCs because they refer to the inventory dialog.
params ["_target", "_source"];

if (isNull _target) exitWith {};

A3C_DISABLE_RADIAL = true;

(findDisplay 602) closeDisplay 0;

waitUntil {
	isNull (findDisplay 602)
};

sleep 0.2;

A3C_UI_INV_CONTAINERS = [];

if (_source == _target) then {
	_source = "GroundWeaponHolder" createVehicle position _target;
};

_target action ["GEAR", _source];

private _nearCrates = (_target nearObjects 5) - (units player);

{
	if (_x distance _target < 5 && {_x isKindOf "MAN"}) then {
		if (!captive _x || {(side _x != side player) || {isPlayer leader group _x}}) then {
			_nearCrates = _nearCrates - [_x];
		};
	} else {
		private _cargo = magazineCargo _x + weaponCargo _x;

		if (count _cargo == 0) then {
			_nearCrates = _nearCrates - [_x];
		};
	};
} forEach _nearCrates;

A3C_UI_INV_TARGETS = units player;

{
	A3C_UI_INV_CONTAINERS pushBackUnique _x;
} forEach ((((units player) select {_target distance2D _x < 5}) - [_target]) + _nearCrates + [_target]); //-- No better idea how to shuffle the target to the end.

waitUntil {
	!isNull (findDisplay 602)
};

sleep 0.1;

A3C_DISABLE_RADIAL = false;

private _inventoryDisplay = findDisplay 602;

private _box1 = _inventoryDisplay ctrlCreate ["A3C_RscCombo", 1928];
private _box2 = _inventoryDisplay ctrlCreate ["A3C_RscCombo", 1929];

private _lbHeight = 0.033 * safeZoneH;

{
	_x params ["_box", "_refCtrl"];

	private _ctrlPos = ctrlPosition (_inventoryDisplay displayCtrl _refCtrl);

	_box ctrlSetPosition [
		_ctrlPos select 0,
		(_ctrlPos select 1) - _lbHeight,
		_ctrlPos select 2,
		_lbHeight
	];

	_box ctrlCommit 0;
} forEach [
	[_box1, 1001],
	[_box2, 1020]
];

{
	[_box2, [_x] call MCSS_fnc_getUnitNameString] call A3C_ui_shared_fnc_addLbEntry;
} forEach A3C_UI_INV_TARGETS;

{
	switch (true) do {
		case (typeOf _x == "GroundWeaponHolder" || {_x == A3C_UI_INV_TARGET_UNIT}): {
			[_box1, "Ground"] call A3C_ui_shared_fnc_addLbEntry;
		};

		case (_x in units player): {
			[_box1, [_x] call MCSS_fnc_getUnitNameString] call A3C_ui_shared_fnc_addLbEntry;
		};

		default {
			private _lbText = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
			[_box1, _lbText] call A3C_ui_shared_fnc_addLbEntry;
		};
	};
} forEach A3C_UI_INV_CONTAINERS;

{
	if (_x == _source || {_x == A3C_UI_INV_TARGET_UNIT && {typeOf _source == "GroundWeaponHolder"}}) then {
		[_box1, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
	};
} forEach A3C_UI_INV_CONTAINERS;

{
	if (_x == _target) then {
		[_box2, _forEachIndex] call A3C_ui_shared_fnc_lbSetCurSel;
	};
} forEach A3C_UI_INV_TARGETS;

//-- NOTE: ctrlAddEventHandler is allowed as listbox is created with ctrlCreate.
_box1 ctrlAddEventHandler [
	"LBSelChanged",
	{
		params ["_control", "_selectedIndex"];

		private _container = A3C_UI_INV_CONTAINERS select _selectedIndex;
		[A3C_UI_INV_TARGET_UNIT, _container] spawn A3C_ui_radialMenu_fnc_inventoryLbCreate;
	}
];

_box2 ctrlAddEventHandler [
	"LBSelChanged",
	{
		params ["_control", "_selectedIndex"];

		A3C_UI_INV_TARGET_UNIT = A3C_UI_INV_TARGETS select _selectedIndex;
		[A3C_UI_INV_TARGET_UNIT, A3C_UI_INV_TARGET_UNIT] spawn A3C_ui_radialMenu_fnc_inventoryLbCreate;
	}
];