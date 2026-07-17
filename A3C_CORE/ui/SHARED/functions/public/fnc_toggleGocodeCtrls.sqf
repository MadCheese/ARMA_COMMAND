#include "..\..\shared_ui_defines.hpp"
#include "..\..\..\mapOverlay\dialog_defines.hpp"
#include "..\..\..\radial\radialMenu\dialog_defines.hpp"

// A3C_ui_shared_fnc_toggleGocodeCtrls

/*
	Refreshes the availability and placement of go-code controls.

	Squad plots and high-command waypoints are scanned once. The resulting
	availability state is then applied to go-codes A through D.
*/

if (isDedicated) exitWith {};

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_RADIAL_MENU
};

private _display = findDisplay _displayId;

if (isNull _display) exitWith {};

private _isRadial = _displayId == IDD_RADIAL_MENU;

private _goCodes = [
	"A",
	"B",
	"C",
	"D"
];

private _availableGoCodes = createHashMap;

{
	_availableGoCodes set [
		_x,
		false
	];
} forEach _goCodes;

/*
	Scan the player's squad plots.

	A3C_PLOT:
		Only the current and future plot entries are relevant.

	A3C_PLOT_TEMP:
		All temporary entries remain relevant.
*/
private _fnc_scanPlot = {
	params [
		"_plot",
		"_firstIndex"
	];

	private _plotCount = count _plot;

	if (_plotCount == 0) exitWith {};

	_firstIndex = _firstIndex max 0;

	for "_plotIndex" from _firstIndex to (_plotCount - 1) do {
		private _plotEntry = _plot select _plotIndex;

		if (_plotEntry isEqualType []) then {
			private _actionData = _plotEntry param [
				3,
				[]
			];

			if (
				_actionData isEqualType []
				&& {count _actionData > 1}
				&& {
					toUpper (
						_actionData param [0, ""]
					) == "GOCODE"
				}
			) then {
				private _goCode = toUpper (
					_actionData param [1, ""]
				);

				if (_goCode in _goCodes) then {
					_availableGoCodes set [
						_goCode,
						true
					];
				};
			};
		};
	};
};

private _groupUnits = profileNamespace getVariable [
	"A3C_GROUPUNITS",
	[]
];

{
	private _unit = _x;

	private _currentPlotIndex = (
		_unit getVariable [
			"A3C_CURRENTWAYPOINT_INDEX",
			1
		]
	) - 1;

	[
		_unit getVariable [
			"A3C_PLOT",
			[]
		],
		_currentPlotIndex
	] call _fnc_scanPlot;

	[
		_unit getVariable [
			"A3C_PLOT_TEMP",
			[]
		],
		0
	] call _fnc_scanPlot;
} forEach _groupUnits;

/*
	Scan current and future high-command waypoints.

	The legacy function searched for:
	- "GoCode"
	- Either "Activate_X" or the quoted code string, such as "A"

	Both matching forms are preserved.
*/
private _highCommandGroups = missionNamespace getVariable [
	"A3C_HC_allGroupsClient_Current",
	[]
];

{
	private _group = _x;
	private _currentWaypointIndex = currentWaypoint _group;

	{
		private _waypoint = _x;
		private _waypointIndex = _waypoint select 1;

		if (_waypointIndex >= _currentWaypointIndex) then {
			private _searchStrings = if (
				waypointType _waypoint == "SCRIPTED"
			) then {
				[
					waypointScript _waypoint
				]
			} else {
				waypointStatements _waypoint
			};

			{
				private _searchString = toLower _x;

				if ("gocode" in _searchString) then {
					{
						private _goCode = _x;

						if !(
							_availableGoCodes get _goCode
						) then {
							private _goCodeLower = toLower _goCode;

							private _activationToken = format [
								"activate_%1",
								_goCodeLower
							];

							private _quotedCodeToken = toLower (
								str _goCode
							);

							if (
								_activationToken in _searchString
								|| {
									_quotedCodeToken in _searchString
								}
							) then {
								_availableGoCodes set [
									_goCode,
									true
								];
							};
						};
					} forEach _goCodes;
				};
			} forEach _searchStrings;
		};
	} forEach waypoints _group;
} forEach _highCommandGroups;

if (_isRadial) exitWith {
	/*
		Radial controls retain their fixed positions. Availability is
		represented only through image opacity/color.
	*/
	{
		private _goCode = _x;

		private _imageControlId = switch (_goCode) do {
			case "A": {
				IDC_RADIAL_OUTERRIGHT_1_IMG
			};

			case "B": {
				IDC_RADIAL_OUTERRIGHT_2_IMG
			};

			case "C": {
				IDC_RADIAL_OUTERRIGHT_3_IMG
			};

			case "D": {
				IDC_RADIAL_OUTERRIGHT_4_IMG
			};

			default {
				-1
			};
		};

		if (_imageControlId >= 0) then {
			private _imageControl = _display displayCtrl _imageControlId;

			if (!isNull _imageControl) then {
				private _textColor = if (
					_availableGoCodes get _goCode
				) then {
					[0.8, 0.6, 0, 0.6]
				} else {
					[1, 1, 1, 0.2]
				};

				_imageControl ctrlSetTextColor _textColor;
			};
		};
	} forEach _goCodes;
};

/*
	Map-overlay controls are dynamically packed from right to left.

	Processing D, C, B, A retains the final visual order A, B, C, D from
	left to right.
*/
private _mapDisplay = findDisplay 12;

if (!isNull _mapDisplay) then {
	private _mapControl = _mapDisplay displayCtrl 51;

	if (!isNull _mapControl) then {
		_mapControl ctrlEnable true;
	};
};

private _rootPosition = [
	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X,
	A3C_MAP_GAMEUI_MENU_Y,
	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W,
	A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H
];

private _buttonsPlaced = 0;

{
	private _goCode = _x;

	private _controlIds = switch (_goCode) do {
		case "A": {
			[
				IDC_MAP_Order_GoCode_A_IMG,
				IDC_MAP_Order_GoCode_A_BTN
			]
		};

		case "B": {
			[
				IDC_MAP_Order_GoCode_B_IMG,
				IDC_MAP_Order_GoCode_B_BTN
			]
		};

		case "C": {
			[
				IDC_MAP_Order_GoCode_C_IMG,
				IDC_MAP_Order_GoCode_C_BTN
			]
		};

		case "D": {
			[
				IDC_MAP_Order_GoCode_D_IMG,
				IDC_MAP_Order_GoCode_D_BTN
			]
		};

		default {
			[]
		};
	};

	private _buttonPosition = +_rootPosition;
	private _isAvailable = _availableGoCodes get _goCode;

	if (_isAvailable) then {
		_buttonPosition set [
			0,
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X
			- (
				A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W
				* _buttonsPlaced
			)
		];

		_buttonsPlaced = _buttonsPlaced + 1;
	} else {
		_buttonPosition set [
			1,
			safeZoneY
			- A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H
		];
	};

	{
		private _control = _display displayCtrl _x;

		if (!isNull _control) then {
			_control ctrlSetPosition _buttonPosition;
			_control ctrlCommit 0;
			_control ctrlShow _isAvailable;
		};
	} forEach _controlIds;
} forEach [
	"D",
	"C",
	"B",
	"A"
];

private _backgroundControl = _display displayCtrl IDC_MAP_Order_GoCode_BG;

if (!isNull _backgroundControl) then {
	if (_buttonsPlaced > 0) then {
		private _backgroundWidth =
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W
			* _buttonsPlaced;

		_backgroundControl ctrlSetPosition [
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_X
			- (
				_backgroundWidth
				- A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_W
			),
			A3C_MAP_GAMEUI_MENU_Y,
			_backgroundWidth,
			A3C_MAP_OVERLAY_GAMEUI_GOCODE_BUTTONPOS_ROOT_H
		];

		_backgroundControl ctrlCommit 0;
		_backgroundControl ctrlShow true;
	} else {
		_backgroundControl ctrlShow false;
	};
};