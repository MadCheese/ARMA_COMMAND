#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

// A3C_ui_mapOverlay_fnc_HCWP_openCargoWaypointPrompt

disableSerialization;

params ["_transportGroups"];

private _cargoGroups = [];

{
	private _transportGroup = _x;

	{
		private _cargoGroup = _x;

		if (
			!isNull _cargoGroup
			&& {!isPlayer (leader _cargoGroup)}
			&& {
				(
					waypointPosition [
						_cargoGroup,
						currentWaypoint _cargoGroup
					]
				) distance2D [0, 0, 0] == 0
			}
		) then {
			_cargoGroups pushBackUnique _cargoGroup;
		};
	} forEach (
		[
			_transportGroup
		] call MCSS_fnc_getCargoGroups
	);
} forEach _transportGroups;

if (_cargoGroups isEqualTo []) exitWith {};

private _display = findDisplay IDD_MAP_OVERLAY;

if (isNull _display) exitWith {};

private _parent =
	_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;

private _text =
	_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;

private _listBox =
	_display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

/*
 * Store the resolved cargo groups on the prompt itself.
 * The response handler does not need to know whether the request came
 * from a single-waypoint or multi-waypoint menu.
 */
_parent setVariable [
	"A3C_CARGO_WAYPOINT_GROUPS",
	+_cargoGroups
];

A3C_SelectionPromptPanel_MODE = "CARGO_WAYPOINTS";

_text ctrlSetText "SET WAYPOINTS FOR CARGO GROUPS?";

_parent ctrlShow true;
_parent ctrlSetPosition [
	0.383108 * safezoneW + safezoneX,
	0.378986 * safezoneH + safezoneY
];
_parent ctrlCommit 0;

lbClear _listBox;

{
	[
		_listBox,
		_x
	] call A3C_ui_shared_fnc_addLbEntry;
} forEach [
	"YES",
	"NO"
];

[
	_parent,
	_listBox,
	2
] call A3C_ui_selectionPromptPanel_fnc_resizeBox;

ctrlSetFocus _listBox;