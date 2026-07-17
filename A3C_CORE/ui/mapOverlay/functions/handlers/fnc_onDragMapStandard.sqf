// A3C_ui_mapOverlay_fnc_onDragMapStandard

if (A3C_BOOL_DISABLEMAPCTRL) exitWith {};

params [
	"_mapControlEvent",
	"_screenX",
	"_screenY"
];

disableSerialization;

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _screenWorldPos =
	_mapControl posScreenToWorld [
		_screenX,
		_screenY
	];

if (A3C_MAP_DRAGPLANNING_ACTIVE) then {
	private _addToDrag = false;

	A3C_DRAGPOS = _screenWorldPos;

	private _targetUnit = if (
		typeName A3C_SQ_CLICKED_UNIT == "GROUP"
	) then {
		leader A3C_SQ_CLICKED_UNIT
	} else {
		A3C_SELECTED_UNITS select 0
	}; //--aaa

	if ((time - A3C_LB_TICKTIME) > 0.3) then {
		if (count A3C_MAP_DRAGPLANNING_POSITIONS == 0) then {
			if (_targetUnit distance2D _screenWorldPos >= 5) then {
				_addToDrag = true;
			};
		} else {
			if (
				_screenWorldPos distance2D (
					A3C_MAP_DRAGPLANNING_POSITIONS select (
						count A3C_MAP_DRAGPLANNING_POSITIONS - 1
					)
				) >= 5
			) then {
				_addToDrag = true;
			};
		};

		if (_addToDrag) then {
			A3C_MAP_DRAGPLANNING_POSITIONS pushBack _screenWorldPos;
		};
	};
};

A3C_DRAGPOS = _screenWorldPos;

if (A3C_BOOL_DRAGLINE) then {
	if (A3C_STATE_CHECKING_PICKUP) then {
		private _unit =
			A3C_SELECTED_UNITS select 0;

		private _wpData =
			_unit getVariable "A3C_PLOT_TEMP";

		{
			_x params [
				"_wpPositions",
				"_wpMarkers",
				"_wpAction",
				"_wpCondition",
				"_wpStances",
				"_wpSyncData",
				"_wpCompleted",
				"_wpCombatMode",
				"_wpSpeed",
				"_wpFlyInHeight",
				"_wpLoopValue",
				"_wpRadius"
			];

			if ((_wpMarkers select 0) == A3C_MovedItem_ID) then {
				_wpPositions set [
					0,
					_screenWorldPos
				];
			};
		} forEach _wpData;

		_unit setVariable [
			"A3C_PLOT_TEMP",
			_wpData,
			true
		];
	};
};

if !(getMarkerColor "A3C_RADIMARK" == "") then {
	private _size =
		getMarkerPos "A3C_RADIMARK"
			distance2D _screenWorldPos;

	"A3C_RADIMARK" setMarkerSizeLocal [
		_size,
		_size
	];
};