#include "..\script_component.hpp"

params ["_unit", "_doFade"];

private _arsenalOpenTimeoutSeconds = 10;
private _unitComboIDC = 1928;
private _referenceControlIDC = 995;
private _unitComboHeight = 0.033 * safeZoneH;

private _restoreOriginalPlayerContext = {
	private _unitsBeforeRestore = units player;

	{
		[_x] call A3C_fnc_setDestination;
	} forEach _unitsBeforeRestore;

	selectPlayer A3C_CurrentPlayerObject;
	(group player) selectLeader player;

	private _unitsAfterRestore = units player;

	{
		[_x] call A3C_AI_action_resumeDestination;
	} forEach _unitsAfterRestore;
};

if (_doFade) then {
	titleCut ["", "BLACK OUT", 0.2];
	sleep 0.2;
};

A3C_CurrentPlayerObject = player;

[] call A3C_UI_RADIAL_CloseDisplay;

A3C_DISABLE_RADIAL = true;

if (15 in A3C_UI_DOWNKEYS) then {
	//-- NOTE: Might require some new method to inform about need to release TAB since clunky keyviewer was removed.
	waitUntil {!(15 in A3C_UI_DOWNKEYS)};
};

A3C_DISABLE_RADIAL = false;

private _unitsBeforePlayerSwitch = units player;

{
	[_x] call A3C_fnc_setDestination;
} forEach _unitsBeforePlayerSwitch;

selectPlayer _unit;
(group player) selectLeader player;

private _unitsAfterPlayerSwitch = units player;

{
	[_x] call A3C_AI_action_resumeDestination;
} forEach _unitsAfterPlayerSwitch;

["Open", true] spawn BIS_fnc_arsenal;

private _arsenalDisplay = displayNull;
private _arsenalOpenTimeout = diag_tickTime + _arsenalOpenTimeoutSeconds;

waitUntil {
	_arsenalDisplay = uiNamespace getVariable ["RscDisplayArsenal", displayNull];

	(!isNull _arsenalDisplay) || {diag_tickTime > _arsenalOpenTimeout}
};

if (isNull _arsenalDisplay) exitWith {
	titleCut ["", "BLACK IN", 0.2];

	call _restoreOriginalPlayerContext;
};

titleCut ["", "BLACK IN", 0.2];

private _referenceControl = _arsenalDisplay displayCtrl _referenceControlIDC;

if (isNull _referenceControl) exitWith {
	_arsenalDisplay closeDisplay 0;

	call _restoreOriginalPlayerContext;
};

private _unitCombo = _arsenalDisplay ctrlCreate ["A3C_RscCombo", _unitComboIDC];

private _unitComboPosition = ctrlPosition _referenceControl;
private _unitComboWidth = _unitComboPosition select 2;
private _unitComboX = 0.5 - (_unitComboWidth / 2);

_unitComboPosition set [0, _unitComboX];
_unitComboPosition set [3, _unitComboHeight];

_unitCombo ctrlSetPosition _unitComboPosition;
_unitCombo ctrlCommit 0;

private _arsenalUnits = units player;

{
	[_unitCombo, [_x, true, false] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;

	if (_x == _unit) then {
		[_unitCombo, _forEachIndex] call A3C_setCurSel;
	};
} forEach _arsenalUnits;

//-- NOTE: This EH is display-lifetime scoped and must be re-added every time the arsenal is opened.
//-- Selecting another unit intentionally closes the arsenal, restores the original player context, then reopens arsenal on the selected unit.
_unitCombo ctrlAddEventHandler [
	"LBSelChanged",
	{
		params ["_unitCombo", "_selectedIndex"];

		private _availableUnits = units player;

		if (_selectedIndex < 0 || {_selectedIndex >= count _availableUnits}) exitWith {};

		private _selectedUnit = _availableUnits select _selectedIndex;
		private _arsenalDisplay = uiNamespace getVariable ["RscDisplayArsenal", displayNull];

		if (!isNull _arsenalDisplay) then {
			_arsenalDisplay closeDisplay 0;
		};

		[_selectedUnit] spawn {
			params ["_selectedUnit"];

			titleCut ["", "BLACK OUT", 0.2];
			sleep 0.2;

			waitUntil {player == A3C_CurrentPlayerObject};

			sleep 0.1;

			[_selectedUnit, false] spawn A3C_UI_arsenal_fnc_squadUnitArsenal;
		};
	}
];

waitUntil {
	_arsenalDisplay = uiNamespace getVariable ["RscDisplayArsenal", displayNull];

	isNull _arsenalDisplay
};

call _restoreOriginalPlayerContext;