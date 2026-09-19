#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_highCommand_actionSuppressionStart

/*
	Prepares eligible high-command groups for a suppression action, stops
	any active suppression orders affecting those units, and starts the
	appropriate map or radial targeting process.

	This function requires scheduled execution because it uses sleep and
	waitUntil. Calls made from an unscheduled environment are automatically
	forwarded to a spawned instance.
*/

if (!canSuspend) exitWith {
	[] spawn A3C_ui_shared_fnc_highCommand_actionSuppressionStart;
};

private _radialDisplay = findDisplay IDD_RADIAL_MENU;
private _mapDisplay = findDisplay IDD_MAP_OVERLAY;

/*
	The legacy function ultimately gave the radial display priority when
	both displays were present.
*/
private _isRadial = !isNull _radialDisplay;
private _isMap = !_isRadial && {!isNull _mapDisplay};

if (!_isRadial && {!_isMap}) exitWith {};

private _selectedGroups = +(
	missionNamespace getVariable [
		"A3C_SELECTED_HC_GROUPS_SETTINGS",
		[]
	]
);

if (_selectedGroups isEqualTo []) exitWith {};

if (_isMap) then {
	/*
		Preserve the legacy page-mode switch. The original _refUnits value
		was only used for this map-side membership check.
	*/
	private _currentSelection = missionNamespace getVariable [
		"A3C_SELECTED_UNITS",
		[]
	];

	private _selectionContainsGroup = _selectedGroups findIf {
		_x in _currentSelection
	} >= 0;

	if (_selectionContainsGroup) then {
		["HC"] call A3C_ui_mapOverlay_fnc_UFSB_applyPageMode;
	};
};

private _eligibleUnits = [];
private _currentlySuppressingUnits = [];
private _messageParts = [];

private _activeSuppressionUnits = (
	missionNamespace getVariable [
		"A3C_SUPPRESSION_UNITS_SQ",
		[]
	]
) + (
	missionNamespace getVariable [
		"A3C_SUPPRESSION_UNITS_AI",
		[]
	]
);

{
	private _group = _x;

	{
		private _unit = _x;
		private _vehicle = vehicle _unit;

		if (
			_unit == gunner _vehicle
			&& {
				getNumber (
					(configOf _vehicle)
					>> "artilleryScanner"
				) == 0
			}
		) then {
			private _canSuppress = true;

			switch true do {
				case (_vehicle isKindOf "PLANE"): {
					_messageParts pushBackUnique (
						"Planes can not suppress. "
					);

					_canSuppress = false;
				};

				/*
					The original condition checks only positive speed rather
					than absolute speed. That behavior is retained.
				*/
				case (
					speed _vehicle > 1
					&& {_vehicle isKindOf "HELICOPTER"}
				): {
					_messageParts pushBackUnique (
						"Helicopters need to be stationary to suppress. "
					);

					_canSuppress = false;
				};
			};

			if (_unit in _activeSuppressionUnits) then {
				_currentlySuppressingUnits pushBackUnique _unit;
			};

			if (_canSuppress) then {
				_eligibleUnits pushBackUnique _unit;
			};
		};
	} forEach units _group;
} forEach _selectedGroups;

private _message = _messageParts joinString "";

if (_message != "") then {
	systemChat _message;
};

/*
	Stop the current suppression order before initiating a replacement.
*/
if (_currentlySuppressingUnits isNotEqualTo []) then {
	[
		_currentlySuppressingUnits,
		"SUPPRESSION"
	] call A3C_ai_shared_fnc_polygonAreaActionOff;
};

waitUntil {
	private _activeAiSuppressionUnits = missionNamespace getVariable [
		"A3C_SUPPRESSION_UNITS_AI",
		[]
	];

	_activeAiSuppressionUnits findIf {
		_x in _currentlySuppressingUnits
	} < 0
};

/*
	The positional-action system expects groups here rather than individual
	gunners.
*/
A3C_UI_RADIAL_Current_Remfire_Units = [];

{
	private _group = group _x;

	if (!isNull _group) then {
		A3C_UI_RADIAL_Current_Remfire_Units pushBackUnique _group;
	};
} forEach _eligibleUnits;

/*
	Do not start an empty targeting process when every selected candidate
	was rejected.
*/
if (A3C_UI_RADIAL_Current_Remfire_Units isEqualTo []) exitWith {};

if (_isMap) exitWith {
	systemChat "A3C: Please relay map-coordinates via mapclick!";

	/*
		The existing map-click flow requires a short scheduled delay before
		installing the click handler.
	*/
	sleep 0.5;

	if (isNull _mapDisplay) exitWith {};

	A3C_HC_GroupMenu_SuppressionRequested = true;

	[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;

	private _mainMapDisplay = findDisplay 12;

	if (!isNull _mainMapDisplay) then {
		private _mapControl = _mainMapDisplay displayCtrl 51;

		if (!isNull _mapControl) then {
			_mapControl ctrlEnable true;
		};
	};

	/*
		Prevent duplicate map-click handlers if the action is started again
		before an older handler is resolved.
	*/
	[
		"A3C_SUP_MAPCLICK",
		"onMapSingleClick"
	] call BIS_fnc_removeStackedEventHandler;

	[
		"A3C_SUP_MAPCLICK",
		"onMapSingleClick",
		{
			params [
				"_units",
				"_position",
				"_alt",
				"_shift"
			];

			A3C_HC_GroupMenu_SuppressionRequested = false;

			{
				[
					_x,
					_position
				] call A3C_ai_highCommand_fnc_suppressionImmediate;
			} forEach A3C_UI_RADIAL_Current_Remfire_Units;

			[
				"A3C_SUP_MAPCLICK",
				"onMapSingleClick"
			] call BIS_fnc_removeStackedEventHandler;
		}
	] call BIS_fnc_addStackedEventHandler;
};

/*
	Radial positional targeting.
*/
[
	false,
	"SUPPRESSION",
	"\a3c_ui\menu\icon_menu_action_suppression.paa",
	A3C_UI_COLOR_RED,
	"",
	""
] call A3C_UI_mainDisplay_fnc_startPositionalActionProcess;