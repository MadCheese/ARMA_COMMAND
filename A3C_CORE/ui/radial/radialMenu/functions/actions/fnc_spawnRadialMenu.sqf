#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_spawnRadialMenu

params ["_data", "_cursorObjectSelection"];

if (isNil "A3C_is_Initialized") exitWith {
	[] spawn {
		hint "ARMA COMMAND IS INITIALIZING - STAND BY";

		waitUntil {
			!isNil "A3C_is_Initialized"
		};

		hint "ARMA COMMAND INITIALIZED";

		sleep 3;

		hint "";
	};
};

if (!isNull (findDisplay 602)) exitWith {};
if (!isNull (findDisplay IDD_MAP_OVERLAY)) exitWith {};
if (!isNull (findDisplay IDD_RADIAL_MENU)) exitWith {};
if (!isNull (findDisplay 100010)) exitWith {};
if (!isNull (findDisplay IDD_SQUAD_PLACEMENT_INTERACTION)) exitWith {};

if (A3C_DISABLE_RADIAL) exitWith {};

private _exit = false;

if !(player == leader group player) then {
	_exit = true;

	if ([player] call A3C_isUnconscious) then {
		if (player == ((units group player) select 0)) then {
			_exit = false;
		};
	};
};

if (_exit) exitWith {};

private _hcAll = A3C_HC_allGroupsClient_Current;
private _cursorTarget = cursorTarget;

[] spawn {
	private _timer = time;

	while {time < _timer + 0.7} do {
		showUAVFeed false;
	};
};

A3C_RADIAL_HOVER = true;
A3C_DISABLE_RADIAL = false;
A3C_RD_BOOL_UNITS = true;
A3C_BOOL_CTBUILD = false;
A3C_RADIALMODE = "";
A3C_TURRETS = [];

A3C_ACTIVE_BUTTONUNIT = if (count (groupSelectedUnits player) > 0) then {
	(groupSelectedUnits player) select 0
} else {
	objNull
};

_exit = false;

if (currentWeapon player == secondaryWeapon player) then {
	if (getNumber (configFile >> "CfgWeapons" >> secondaryWeapon player >> "canLock") == 2) then {
		if (!isNull _cursorTarget) then {
			if !(_cursorTarget isKindOf "MAN") then {
				_exit = true;
			};
		};
	};
};

if (!isNull (findDisplay 312)) exitWith {}; //-- Zeus interface is open. Prevent most A3C stuff.
if (_exit) exitWith {};

_data params ["_ignoredDisplay", "_btn", "_shift", "_ctrl", "_alt"];

A3C_RADIAL_VAL = 0;

A3C_RadialMenu_KEY_ID = [_btn, _shift, _ctrl, _alt];

BV_GREN = 0;
BV_ACT = 0;
BV_ROE = 0;
BV_BRAIN = 0;
BV_FORM = 0;
BV_STANCES = 0;
BV_ITEMS = 0;
BV_VEHS = 0;
BV_MEDICAL = 0;
BV_LB1 = 6;
BV_LB1 = 8;

A3C_TARGETVEH = objNull;

if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	if (count (groupSelectedUnits player) == 0) then {
		{
			player groupSelectUnit [_x, true];
		} forEach ((units group player) - [player]);
	};

	A3C_RD_UNITS = groupSelectedUnits player;

	{
		if (isPlayer _x) then {
			A3C_RD_UNITS = A3C_RD_UNITS - [_x];
			player groupSelectUnit [_x, false];
		};
	} forEach A3C_RD_UNITS;
};

with uiNamespace do {
	(findDisplay 46) createDisplay "A3C_DSP_RadialMenu";
};

if (_cursorObjectSelection) then {
	A3C_UI_DOWNKEYS = A3C_UI_DOWNKEYS - [29];
};

{
	inGameUISetEventHandler [_x, "true"];
} forEach ["PrevAction", "NextAction"];

["RADIAL"] call A3C_ui_shared_fnc_getBackgroundColor;

//-- Hide all outer ring controls.
{
	_x ctrlShow false;
} forEach (["radial_outerButtonMacros"] call FUNC(ctrlGroup));

{
	_x ctrlShow false;
} forEach (
	(["radial_extensionRight"] call FUNC(ctrlGroup)) +
	(["radial_extensionLeft"] call FUNC(ctrlGroup))
);

A3C_BUTTONPAGE_TABLET = 0;

//-- Detect context and label menu.
private _referenceArray = if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	profileNamespace getVariable "A3C_GROUPUNITS"
} else {
	_hcAll
};

if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
	//-- This has to happen before inner ring is labeled.
	if (!isNull _cursorTarget) then {
		if (group (driver _cursorTarget) in _hcAll && {_cursorObjectSelection}) then {
			A3C_RD_UNITS = [group (driver _cursorTarget)];
		};
	};

	if (count A3C_RD_UNITS > 0) then {
		private _index = [A3C_RD_UNITS select 0, _referenceArray] call MCSS_fnc_getArrayIndex;
		A3C_BUTTONPAGE_TABLET = (ceil ((_index + 1) / 18)) - 1;
	};
};

[A3C_CURRENT_COMMAND_LEVEL] call A3C_ui_radialMenu_fnc_labelInnerRing; //-- Label inner ring: SQUAD or HC.

if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	//-- This has to happen after inner ring is labeled.
	if (!isNull _cursorTarget) then {
		if (
			(gunner _cursorTarget) in (units player) &&
			{
				({_cursorTarget isKindOf _x} count ["STATICWEAPON", "MAN"]) > 0
			}
		) then {
			if (_cursorObjectSelection) then {
				private _gunner = gunner _cursorTarget;

				A3C_RD_UNITS = [_gunner];

				private _index = [_gunner, _referenceArray] call MCSS_fnc_getArrayIndex;
				A3C_BUTTONPAGE_TABLET = (ceil ((_index + 1) / 18)) - 1;

				{
					if (_x == _gunner) then {
						player groupSelectUnit [_x, true];
					} else {
						player groupSelectUnit [_x, false];
					};
				} forEach ((units player) - [player]);
			};

			["ACTIONS", -1] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;
		} else {
			if (side _cursorTarget in [side player, civilian]) then {
				if (_cursorObjectSelection) then {
					{
						if (_cursorTarget isKindOf _x) exitWith {
							["VEHICLES", 0] call A3C_ui_radialMenu_fnc_buttonActionInnerRing;

							A3C_RADIAL_VEH_KIND = _x;

							[A3C_RD_UNITS] call A3C_ui_radialMenu_fnc_squad_findVehicles;
						};
					} forEach ["CAR", "TANK", "HELICOPTER", "PLANE", "SHIP", "STATICWEAPON"];
				};
			};
		};
	};
};

if (
	_cursorObjectSelection &&
	{
		!isNull _cursorTarget &&
		{
			side _cursorTarget in [side player, civilian] &&
			{
				count (fullCrew [_cursorTarget, "", true]) > 0
			}
		}
	}
) then {
	private _guiGridW = 0.025;
	private _guiGridH = 0.04;
	private _vehicleSeatData = fullCrew [_cursorTarget, "", true];
	private _buttonHeight = if (count _vehicleSeatData > 15) then {1} else {2}; //-- 15 seats is threshold instead of 20 because we need the last row for "board all".
	private _buttonWidth = _buttonHeight * 1.25;

	_buttonWidth = _buttonWidth * _guiGridW;
	_buttonHeight = _buttonHeight * _guiGridH;

	private _mouseX = (35.5 * _guiGridW) + (_buttonWidth / 2);
	private _mouseY = (11.5 * _guiGridH) + (_buttonHeight / 2);

	[_mouseX, _mouseY] spawn {
		sleep 0.1;

		setMousePosition _this;
	};
} else {
	setMousePosition [0.5, 0.5];
};