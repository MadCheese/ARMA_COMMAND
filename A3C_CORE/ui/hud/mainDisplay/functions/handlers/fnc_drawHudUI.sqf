// A3C_UI_mainDisplay_fnc_drawHudUI

disableSerialization;

private _playerGroup =
	group player;

A3C_UI_HUDICONS_HC_GROUP = [];
A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS = [];

if (player != leader _playerGroup) exitWith {};

private _cursorTarget =
	cursorTarget;

private _isHighCommand =
	A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND";

private _drawPositions = A3C_HUD_DRAW_POSARRAY apply {
	+_x
};

private _highCommandGroups =
	A3C_HC_allGroupsClient_Current;

// Draw persistent tactical lines.
{
	_x params ["_array","_color"];
	{
		drawLine3D [ASLtoATL (_x select 0),ASLtoATL  (_x select 1), _color];
	} forEach _array;
} forEach
[
	[MCSS_RED_LINES,[1,0,0,1]],
	[MCSS_GREEN_LINES,[0,1,0,1]],
	[MCSS_BLUE_LINES,[0,0,1,1]]
];

// Draw staged positions, their connecting path, and floor guides.
private _selectedUnits =
	groupSelectedUnits player;

if (
	_drawPositions isNotEqualTo []
	&& {_selectedUnits isNotEqualTo []}
) then {
	private _selectedUnit =
		_selectedUnits select 0;

	private _lastDrawPositionIndex =
		(count _drawPositions) - 1;

	{
		_x set [
			2,
			(_x select 2) + 1
		];
	} forEach _drawPositions;

	drawLine3D [
		((getPosASL _selectedUnit) select [0, 2]) + [1],
		((_drawPositions select 0) select [0, 2]) + [1],
		[0, 1, 0, 1]
	];

	{
		private _drawPosition = _x;

		drawIcon3D [
			"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa",
			[0, 0, 1, 1],
			_drawPosition,
			1,
			1,
			0
		];

		if (
			_forEachIndex
			< _lastDrawPositionIndex
		) then {
			drawLine3D [
				_drawPosition,
				_drawPositions select (_forEachIndex + 1),
				[0, 0, 1, 1]
			];
		};

		private _floorPosition =
			(_drawPosition select [0, 2]) + [0];

		drawLine3D [
			_drawPosition,
			_floorPosition,
			[1, 1, 1, 0.7]
		];
	} forEach _drawPositions;
};

// Draw the medic meeting point.
if !(A3C_MEDICAL_MeetingPos isEqualTo []) then {
	drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Actions\heal_ca.paa", [0,0,1,0.7],A3C_MEDICAL_MeetingPos, 1, 1, 0, 'Meet Medic',0,0.05,"PuristaLight","center",true];
};

// Draw high-command group and vehicle-assignment icons.
private _repairedVehicles = [];

if (
	_isHighCommand
	&& {_highCommandGroups isNotEqualTo []}
) then {
	private _blueAlpha03 = [
		A3C_UI_COLOR_BLUE,
		0.3
	] call A3C_ui_shared_fnc_getColorArrayWithOpacity;

	private _blueAlpha06 = [
		A3C_UI_COLOR_BLUE,
		0.6
	] call A3C_ui_shared_fnc_getColorArrayWithOpacity;

	{
		private _group = _x;
		private _groupUnits =
			units _group;

		private _groupLeader =
			leader _group;

		private _leadVehicle =
			vehicle _groupLeader;

		private _leadVehicleDriver =
			driver _leadVehicle;

		if (
			isNull _leadVehicleDriver
			|| {_leadVehicleDriver in _groupUnits}
		) then {
			private _iconType = [
				_group
			] call A3C_main_fnc_getGroupIconType;

			private _iconPosition =
				_leadVehicle modelToWorldVisual [0, 0, 0];

			_iconPosition set [
				2,
				(
					(
						boundingBoxReal _leadVehicle
						select 1
					) select 2
				) + 0.5 + (_iconPosition select 2)
			];

			private _iconSize = linearConversion [
				0,
				2000,
				player distance2D _leadVehicle,
				1,
				0.1,
				true
			];

			if (_leadVehicle == _cursorTarget) then {
				_iconSize =
					_iconSize * 1.4;

				private _iconText = (
					groupID _group
				) + (
					if (side _group != side player) then {
						format [
							" (%1)",
							side _group
						]
					} else {
						""
					}
				);

				drawIcon3D [
					"",
					[1, 1, 1, 1],
					_iconPosition,
					_iconSize,
					_iconSize,
					0,
					_iconText,
					2,
					0.04,
					"PuristaMedium",
					"Center"
				];
			};

			{
				private _repairingData = _x getVariable [
					"A3C_isRepairing",
					[false, objNull]
				];

				if (_repairingData select 0) then {
					_repairedVehicles pushBackUnique (
						_repairingData select 1
					);
				};
			} forEach _groupUnits;

			drawIcon3D [
				_iconType,
				_blueAlpha03,
				_iconPosition,
				_iconSize,
				_iconSize,
				0,
				"",
				0
			];

			if (
				_group in A3C_RD_UNITS
				|| {
					{
						group _x != _group
					} count crew _leadVehicle > 0
				}
			) then {
				private _frameColor = if (
					_group in A3C_RD_UNITS
				) then {
					[1, 1, 1, 1]
				} else {
					[0.5, 0.2, 0.6, 0.1]
				};

				drawIcon3D [
					"\a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
					_frameColor,
					_iconPosition,
					_iconSize * 1.6,
					_iconSize * 1.6,
					0,
					"",
					1,
					0
				];
			};

			private _screenPosition =
				worldToScreen _iconPosition;

			if (_screenPosition isNotEqualTo []) then {
				A3C_UI_HUDICONS_HC_GROUP pushBack [
					_group,
					[_iconSize, _iconSize],
					_screenPosition
				];
			};
		};
	} forEach (
		_highCommandGroups - [_playerGroup]
	);

	// Draw the player group icon without interaction data.
	private _playerLeadVehicle =
		vehicle leader _playerGroup;

	private _playerGroupIconPosition =
		_playerLeadVehicle modelToWorldVisual [0, 0, 0];

	_playerGroupIconPosition set [
		2,
		(
			(
				boundingBoxReal _playerLeadVehicle
				select 1
			) select 2
		) + 0.5 + (_playerGroupIconPosition select 2)
	];

	drawIcon3D [
		[
			_playerGroup
		] call A3C_main_fnc_getGroupIconType,
		_blueAlpha03,
		_playerGroupIconPosition,
		1,
		1,
		0,
		"",
		0
	];

	// Build and draw the current assignable-vehicle icon set.
	if (A3C_UI_HUD_ASSIGNVEHICLE) then {
		A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS =
			A3C_UI_MAPICONS_HC_VICS apply {
				_x select 0
			};

		{
			_x params [
				"_vehicle",
				"",
				"",
				"_iconType"
			];

			private _iconPosition =
				_vehicle modelToWorldVisual [0, 0, 0];

			private _iconSize = linearConversion [
				0,
				800,
				player distance2D _vehicle,
				1,
				0.1,
				true
			];

			if (_vehicle == _cursorTarget) then {
				_iconSize =
					_iconSize * 1.4;
			};

			drawIcon3D [
				"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
				[1, 1, 1, 0.6],
				_iconPosition,
				_iconSize * 1.5,
				_iconSize * 1.5,
				0,
				"",
				1,
				0
			];

			drawIcon3D [
				_iconType,
				_blueAlpha06,
				_iconPosition,
				_iconSize,
				_iconSize,
				0,
				"",
				1,
				0
			];
		} forEach A3C_UI_MAPICONS_HC_VICS;
	};
};

// Draw repair progress for vehicles currently being repaired.
{
	private _repairData = _x getVariable ["A3C_isBeingRepaired",[false,0,[]]];

	if (_repairData select 0) then {
		private _progressColor = [0, 1, 0, 0.6];
		private _vehicleHealth = _repairData select 1;
		private _barPosition = _x modelToWorldVisual [0,0,0];
		_barPosition set [2,(((boundingBoxReal _x) select 1) select 2) + 0.5 + (_barPosition select 2)];

		private _progressStep = round (
			((_vehicleHealth max 0.1) min 1) * 10
		);
		private _repairProgressIcon = format [
			"\a3c_ui\infoAdd\icon_3D_progress_%1.paa",
			_progressStep
		];
		_progressColor = switch (true) do {
			case (_progressStep <= 3) : { [A3C_UI_COLOR_RED,0.6] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
			case (_progressStep < 7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
			default {if (canMove _x) then {[0,1,0,0.6]} else { [A3C_UI_COLOR_YELLOW,0.6] call A3C_ui_shared_fnc_getColorArrayWithOpacity}};
		};

		private _iconSize = linearConversion [ 0, 2000, player distance2D _x, 1, 0.1, true ];
		drawIcon3D
		[
			_repairProgressIcon,
			_progressColor,
			_barPosition vectorAdd [0,0,0.3],
			_iconSize * 1.5,
			_iconSize * 1.5,
			0,
			"",
			0,
			0.04,
			"PuristaMedium",
			"Center"
		];
	};
} forEach _repairedVehicles;

// Draw a custom boarding cursor while the player is in a vehicle.
if (
	_isHighCommand
	&& {_highCommandGroups isNotEqualTo []}
	&& {!isNull objectParent player}
) then {
	private _customCursorTarget =
		[] call MCSS_fnc_getCursortargetCustom;

	if (
		!isNull _customCursorTarget
		&& {
			group driver _customCursorTarget
			in _highCommandGroups
		}
		&& {
			(
				_customCursorTarget canVehicleCargo (vehicle player)
			) select 0
		}
	) then {
		private _iconPosition =
			_customCursorTarget modelToWorldVisual [0, 0, 0];

		drawIcon3D [
			"\a3\ui_f\data\IGUI\Cfg\Cursors\board_ca.paa",
			[1, 1, 1, 0.6],
			_iconPosition,
			1,
			1,
			0,
			"",
			1,
			0
		];
	};
};

// Draw squad-placement unit numbers and team-colored ghost markers.
if (A3C_UI_squadPlacement_units isNotEqualTo []) then {
	private _cameraPositionAsl = AGLToASL (
		positionCameraToWorld [0, 0, 0]
	);

	private _cameraVehicle =
		vehicle cameraOn;

	private _ghostDrawData = [];
	private _intersectionQueries = [];

	{
		private _unit = _x;

		private _hudData = _unit getVariable [
			"A3C_HUD_DATA",
			[objNull, -1]
		];

		_hudData params [
			["_arrow", objNull, [objNull]]
		];

		if (!isNull _arrow) then {
			private _arrowPositionAsl =
				getPosASLVisual _arrow;

			private _losTargetAsl =
				+_arrowPositionAsl;

			/*
				Test slightly above the arrow origin so that terrain at the
				arrow's exact ground contact point is not treated as an
				obstruction.
			*/
			_losTargetAsl set [
				2,
				(_losTargetAsl select 2) + 0.3
			];

			_ghostDrawData pushBack [
				_unit,
				_arrowPositionAsl
			];

			_intersectionQueries pushBack [
				_cameraPositionAsl,
				_losTargetAsl,
				_cameraVehicle,
				_arrow,
				true,
				1,
				"VIEW",
				"GEOM"
			];
		};
	} forEach A3C_UI_squadPlacement_units;

	private _intersectionResults = if (
		_intersectionQueries isEqualTo []
	) then {
		[]
	} else {
		lineIntersectsSurfaces [
			_intersectionQueries
		]
	};

	{
		_x params [
			"_unit",
			"_arrowPositionAsl"
		];

		private _arrowPositionAgl =
			ASLToAGL _arrowPositionAsl;

		private _distance =
			player distance2D _arrowPositionAgl;

		private _maximumDistance = 300;
		private _minimumIconSize = 0.2;
		private _minimumTextSize = 0.025;

		private _iconSize = linearConversion [
			0,
			_maximumDistance,
			_distance,
			1,
			_minimumIconSize,
			true
		];

		private _textSize = linearConversion [
			0,
			_maximumDistance,
			_distance,
			0.05,
			_minimumTextSize,
			true
		];

		private _opacity = linearConversion [
			0,
			_maximumDistance,
			_distance - 30,
			0,
			0.7,
			true
		];

		if (_opacity > 0) then {
			_opacity = _opacity max 0.2;
		};

		private _isOccluded = (
			_intersectionResults select _forEachIndex
		) isNotEqualTo [];

		if (_isOccluded) then {
			_opacity = 0.7;
		};

		private _textPosition =
			+_arrowPositionAgl;

		_textPosition set [
			2,
			(_textPosition select 2) - 0.3
		];

		drawIcon3D [
			"",
			[1, 1, 1, 0.6],
			_textPosition,
			0,
			0,
			0,
			str (
				_unit getVariable "A3C_FORMATION_INDEX"
			),
			1,
			_textSize
		];

		private _assignedTeam = if (
			player == cameraOn
		) then {
			assignedTeam _unit
		} else {
			_unit getVariable [
				"A3C_ASSIGNEDTEAM",
				"MAIN"
			]
		};

		private _color = switch _assignedTeam do {
			case "RED": {
				[
					A3C_UI_COLOR_RED,
					_opacity
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			case "GREEN": {
				[
					[0, 1, 0, 1],
					_opacity
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			case "BLUE": {
				[
					A3C_UI_COLOR_BLUE,
					_opacity
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			case "YELLOW": {
				[
					A3C_UI_COLOR_YELLOW,
					_opacity
				] call A3C_ui_shared_fnc_getColorArrayWithOpacity
			};

			default {
				[1, 1, 1, _opacity]
			};
		};

		drawIcon3D [
			"\a3\ui_f\data\Map\GroupIcons\badge_simple.paa",
			_color,
			_arrowPositionAgl,
			_iconSize,
			_iconSize,
			0,
			"",
			1,
			0.05
		];
	} forEach _ghostDrawData;
};

// Reposition and draw the active positional-action tag.
if (typeName A3C_UI_HUD_3D_TAG_ICON_TYPE == "STRING") then {
	if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {

		if (A3C_UI_HUD_3D_TAG_reposition) then {

			private _surfaceIntersections = lineIntersectsSurfaces
			[
				AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],
				cameraOn,
				A3C_OBJECTPLACER,
				true,
				1,
				"GEOM",
				"NONE"
			];
			if (count _surfaceIntersections == 0) then {
				A3C_UI_HUD_3D_TAG_ICON_POS = screenToWorld [0.5,0.5];
			} else {

				A3C_UI_HUD_3D_TAG_ICON_POS = ASLtoAGL((_surfaceIntersections select 0) select 0);

				if ({_x in toLower A3C_UI_HUD_3D_TAG_ICON_TYPE} count ["movepos","building"] > 0) then {
					private _eligibleForBuildingSearch = (count A3C_RD_UNITS == 1) && {{!isNull objectParent _x && {(assignedVehicleRole _x) select 0 != "cargo"}} count (units (A3C_RD_UNITS select 0)) == 0};

					if (_eligibleForBuildingSearch && {_cursorTarget isKindOf "HOUSE" && {([_cursorTarget] call MCSS_fnc_getLastBuildingPosIndex) > 0}}) then {
						A3C_UI_HUD_3D_TAG_ICON_TYPE = "a3c_ui\markers\building.paa";
						A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
					} else {
						A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3c_ui\hud\icon_HUD_movePos.paa";
						A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_BLUE,0.5] call A3C_ui_shared_fnc_getColorArrayWithOpacity;
					};
				};
			};

			private _distance =
				player distance2D A3C_UI_HUD_3D_TAG_ICON_POS;

			private _minimumSize = 0.25;
			private _maximumDistance = 500;

			A3C_UI_HUD_3D_TAG_ICON_SIZE = (linearConversion [ 0, _maximumDistance, _distance, 1.1, _minimumSize, true ]) *2;

		};

		drawIcon3D
		[
			A3C_UI_HUD_3D_TAG_ICON_TYPE,
			A3C_UI_HUD_3D_TAG_ICON_COL,
			A3C_UI_HUD_3D_TAG_ICON_POS,
			A3C_UI_HUD_3D_TAG_ICON_SIZE,
			A3C_UI_HUD_3D_TAG_ICON_SIZE,
			0,
			'',
			1,
			0.05
		];

		if (A3C_UI_HUD_3D_TAG_ICON_MOD != "NONE") then {
			private _modifierIcon = if (A3C_UI_HUD_3D_TAG_ICON_MOD == "ON") then {
				"\a3c_ui\markers\icon_Rad_3D_Modifier_ON.paa"
			} else {
				"\a3c_ui\markers\icon_Rad_3D_Modifier_OFF.paa"
			};
			drawIcon3D
			[
				_modifierIcon,
				[1,1,1,1],
				A3C_UI_HUD_3D_TAG_ICON_POS,
				A3C_UI_HUD_3D_TAG_ICON_SIZE * 1.7,
				A3C_UI_HUD_3D_TAG_ICON_SIZE * 1.7,
				0,
				'',
				1,
				0.05
			];
		};
	};
};
