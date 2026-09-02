// A3C_ui_mapOverlay_fnc_drawMapUI

disableSerialization;

params ["_mapControl"];


if ( (A3C_OPACITY == 0) OR {!visibleMap} ) exitWith {};
if (!isNil 'A3C_disableMapPlanning' && {A3C_disableMapPlanning}) exitWith {};
if !(A3C_isPlayerLeader) exitWith {};
private _isShiftHeld = 42 in A3C_UI_DOWNKEYS;


private _isHighCommandInterfaceActive = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};

private _highCommandGroups = A3C_HC_allGroupsClient_Current;
if !(group player in _highCommandGroups) then {
	_highCommandGroups = [group player] + _highCommandGroups; // Add the player group because it must be represented in the UI even when the player does not carry a tablet.
};


private _mapScale = ctrlMapScale _mapControl;
private _useStandardWaypointLines = _mapScale > 0.04;
private _cfgVehicles = configFile >> "CfgVehicles";
private _cfgMagazines = configFile >> "CfgMagazines";

private _mainSquadWaypointIconSize = ((0.08 * 10^(abs log _mapScale)) min 45) max 20;
private _subSquadWaypointIconSize = ((0.025 * 10^(abs log _mapScale)) min 40) max 20;
private _conditionIconOpacity = 1 - (((_mapScale min 0.02) min A3C_OPACITY) / 0.02);
private _conditionIconOffset = (_conditionIconOpacity * 3) min 1;
private _conditionIconSize = ((0.08 * 10^(abs log _mapScale)) min 45) max 20;
private _waypointSelectionCircleSize = 35;
private _waypointSelectionCircleVerticalOffsetFactor = 0.3;

A3C_HC_WP_SYNC_ARRAYS = [];

A3C_UI_MAPICONS_POLYGON_MAIN = [];
A3C_UI_MAPICONS_POLYGON_EDGE = [];
A3C_UI_MAPICONS_SQUAD = [];
A3C_UI_MAPICONS_SQ_WPS_WPDOTS = [];
A3C_UI_MAPICONS_SQ_WPS_LOOKDIR = [];

A3C_UI_MAPICONS_HC_GROUP = [];
A3C_UI_MAPICONS_HC_WPS = [];
A3C_UI_MAPICONS_HC_TRACKER = [];
A3C_UI_MAPICONS_PICKUP = [];
A3C_UI_MAPICONS_DEMO_VICS = [];
A3C_UI_MAPICONS_BOARDING_DRAW = [];
A3C_UI_MAPICONS_HC_CONES = [];

private _zoomLabelOffsetFactor = linearConversion [ 0.001, 0.05, _mapScale, 0, 1, true ];


private _shouldCheckHoveredGroup = true;
	

////////////////////////////////////////////////////
//-- PLANNING STAGE: DIRECTION ARROW OR LOOP-LINE //
////////////////////////////////////////////////////

if (!isNil 'A3C_restrictMapPlanning' && {A3C_restrictMapPlanning && { {["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) == 0 }}) exitWith {};
if (A3C_BOOL_DRAGLINE && {count A3C_DRAGPOS > 0}) then {
	switch (A3C_CONNECTING_MODE) do {
		case ("LOOKDIR") : {
			if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION"]) then {
				_mapControl drawArrow [A3C_CLICKPOS_ORIG, A3C_DRAGPOS, [0,0.54,0.98,1]];
			};
		};
		case ("LOOP") : {
			_mapControl drawline [A3C_LOOPSYNC_START select 1, A3C_DRAGPOS, [0,0.74,0.14,1]];
		};
		case ("SYNC") : {
			// SYNC is obsolete; consolidate LOOP into LOOPSYNC.
		};
		case ("HCBOARD") : {
			{
				private _boardingGroup = _x;
				_mapControl drawArrow [leader _boardingGroup,A3C_DRAGPOS, [0,0,1,1]];
			} foreach A3C_BOARDING_GROUPS;

			
		};
		case ("HCSYNC") : {
			_mapControl drawArrow [A3C_CLICKPOS_ORIG,A3C_DRAGPOS, [1,1,0,1]];
		};
	};
};

////////////////////////////////////////////
//-- PLANNING STAGE: CONTEXT PICKUP ICONS //
////////////////////////////////////////////


// HC boarding: selectable vehicle icons.
private _squadWaypointSyncGroups = [];

// Attach explosive: vehicle pickup icons.
if (A3C_HC_DETONATION_BOOL) then {
	private _demolitionTargets = [leader A3C_HC_ACTIVEGROUP,waypointPosition [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND],50,true] call A3C_main_fnc_getNearDetonationTargets;
	if !(_demolitionTargets isEqualTo []) then {
		{
			private _demolitionTarget = _x;
			[
				_mapControl,
				_demolitionTarget,
				25,
				[A3C_UI_COLOR_RED,1] call A3C_ui_shared_fnc_getColorArrayWithOpacity,
				(gettext(_cfgVehicles >> typeof _demolitionTarget >> "displayName"))
			] call A3C_ui_mapOverlay_fnc_drawIconVehicleMacro;		
			A3C_UI_MAPICONS_DEMO_VICS pushBack [_demolitionTarget,[25,25],getpos _demolitionTarget];
		} foreach _demolitionTargets;
	} else {
		A3C_HC_DETONATION_BOOL = false;
	};
	
};


private _lastDragCandidateVehicle;
// Drag path: vehicle pickup icons.
if (count A3C_MAP_DRAGPLANNING_POSITIONS > 0) then {
	if (_isShiftHeld) then {
		private _dragTargetUnits = [];
		if (typeName A3C_SQ_CLICKED_UNIT == "GROUP") then {
			_dragTargetUnits = [leader A3C_SQ_CLICKED_UNIT];
		} else {
			_dragTargetUnits = +(A3C_SELECTED_UNITS);
		};
		private _candidateBoardingVehicles = A3C_DRAGPOS nearentities [["CAR","TANK","AIR","SHIP","MOTORCYCLE"],220];
		{
			_lastDragCandidateVehicle = _x;
			// if ({
			// 	private _crewMember = _x;
			// 	((side _crewMember) getFriend (side player)) < 0.6
			// } count crew _lastDragCandidateVehicle > 0) then {
			// };
			if ({
				private _seatRole = _x;
				(_lastDragCandidateVehicle emptyPositions _seatRole) > 0
			} count ["driver","gunner","commander","cargo"] == 0) then {
				_candidateBoardingVehicles = _candidateBoardingVehicles - [_lastDragCandidateVehicle];
			};
			private _candidateVehicleReferencePosition = if (surfaceIsWater getPos _lastDragCandidateVehicle) then {getPosASL _lastDragCandidateVehicle} else {getPosATL _lastDragCandidateVehicle};
			if ({
				private _movementValue = _x;
				_movementValue > 2
			} count [speed _lastDragCandidateVehicle, _candidateVehicleReferencePosition select 2] > 0) then {
				_candidateBoardingVehicles = _candidateBoardingVehicles - [_lastDragCandidateVehicle];
			};
			if ({
				private _dragTargetUnit = _x;
				_dragTargetUnit knowsAbout _lastDragCandidateVehicle > 0.5
			} count _dragTargetUnits == 0) then {
				_candidateBoardingVehicles = _candidateBoardingVehicles - [_lastDragCandidateVehicle];
			};
		} foreach _candidateBoardingVehicles;
		private _boardingVehicleIconSize = 35;
		{
			private _boardingVehicle = _x;
			_mapControl drawIcon
			[
				gettext (_cfgVehicles >> typeOf _boardingVehicle >> "picture"),
				[1,1,0,1],
				getPos _boardingVehicle,
				_boardingVehicleIconSize,
				_boardingVehicleIconSize,
				0,
				"11",
				0,
				0.03,
				'PuristaLight',
				'right'
			];
			A3C_UI_MAPICONS_BOARDING_DRAW pushBack [_boardingVehicle,[_boardingVehicleIconSize,_boardingVehicleIconSize],getPos _boardingVehicle,nil];
		} foreach _candidateBoardingVehicles;


	};
};

////////////////////////////
//-- UI-ICONS SQUAD LEVEL //
////////////////////////////


private _sharedDrawColor;

// Planning data: waypoint lines.
{
	private _squadUnit = _x;
	private _isLoopSegmentActive = false;
	private _loopStartPosition = [];
	private _squadUnitVehicle = vehicle _squadUnit;
	private _squadVehicleDriver = driver _squadUnitVehicle;
	private _squadUnitPosition = getPos _squadUnit;
	private _squadUnitPositionASL = getPosASL _squadUnit;
	private _squadUnitDirection = getDir _squadUnit;
	private _squadUnitParent = objectParent _squadUnit;
	private _isSquadUnitInVehicle = !isNull _squadUnitParent;
	private _isSquadVehicleDriver = _squadUnit == _squadVehicleDriver;
	private _currentSquadWaypointIndex = _squadUnit getVariable "A3C_CURRENTWAYPOINT_INDEX";
	private _activePlotData = _squadUnit getVariable "A3C_PLOT";
	private _temporaryPlotData = _squadUnit getVariable "A3C_PLOT_TEMP";

	private _squadUnitIconPath = "";
	private _squadIconWidth = 0;
	private _squadIconHeight = 0;
	private _formationIndexText = "";
	_sharedDrawColor = [1,1,1,1];


	if (_squadUnit == player) then {
	} else {
		{
			private _plotDataTypeIndex = _forEachIndex;
			private _currentPlotData = _x;
			{
				private _waypointData = _x;
				_waypointData params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];

				private _lineStartPosition = []; // Default: empty waypoint position.
				private _waypointIndex = _forEachIndex;
				private _waypointColor = if (_plotDataTypeIndex == 0) then {[A3C_UI_COLOR_BLACK,1] call A3C_ui_shared_fnc_getColorArrayWithOpacity} else {[A3C_UI_COLOR_GREY,1] call A3C_ui_shared_fnc_getColorArrayWithOpacity}; // Active and temporary waypoint data use different default colors.
				private _waypointPosition = _wpPositions select 0;
				private _waypointDirectionPosition = _wpPositions select 1;
				private _mainMarkerId = _wpMarkers select 0;
				private _subMarkerId = _wpMarkers select 1;
				private _waypointActionType = _wpAction select 0;
				private _waypointActionData = _wpAction select 1;
				private _waypointConditionType = _wpCondition select 0;
				private _waypointConditionData = _wpCondition select 1;
				private _firingWaypointMode = if (_waypointActionType in ["GRENADE","SUPPRESSION"]) then {2} else {0}; //~~ change this value here and in smokeless_wp
				private _waypointOpacity = if (_plotDataTypeIndex == 0) then {if (_isSquadVehicleDriver) then {0.6} else {0.3}} else {0.3};
				_waypointOpacity = _waypointOpacity min A3C_OPACITY;


				private _shouldDrawWaypoint = true;
				if (_plotDataTypeIndex == 0) then {
					//-- active orders: only draw line for uncompleted wp's
					if ((_waypointIndex + 1) >= _currentSquadWaypointIndex) then {

						if ((_waypointIndex + 1) == _currentSquadWaypointIndex) then {
							//-- current WP: root on unit, color green
							_waypointColor = [0.01,0.72,0.32,1];
							_lineStartPosition = _squadUnitPositionASL;
						} else {
							//-- followup wp. find last smokeless wp.
							_lineStartPosition = [_squadUnit,1,(_waypointIndex)] call A3C_ui_mapOverlay_fnc_squad_findLastWaypointWithoutPolygon;
						};
					} else {
						_shouldDrawWaypoint = false;
					};
				} else {
					private _rootPlotTypeIndex = 0;
					private _rootSearchIndex = +_waypointIndex;
					if (count _activePlotData > 0) then {
						if (_waypointIndex == 0) then {
							_rootPlotTypeIndex = 1;
							_rootSearchIndex = (count _activePlotData);
						} else {

							_lineStartPosition = [_squadUnit,0,(_rootSearchIndex)] call A3C_ui_mapOverlay_fnc_squad_findLastWaypointWithoutPolygon;
							if ((_lineStartPosition distance2D (position _squadUnit)) < 1) then {
								_rootPlotTypeIndex = 1;
								_rootSearchIndex = (count _activePlotData);
							};
						};
					};
					_lineStartPosition = [_squadUnit,_rootPlotTypeIndex,(_rootSearchIndex)] call A3C_ui_mapOverlay_fnc_squad_findLastWaypointWithoutPolygon;

				};
				if ( _firingWaypointMode >= 2) then {
					// Smoke-related waypoints use yellow path lines.
					_waypointColor = [1,1,0,1];
				};
				_waypointColor set [3,_waypointOpacity];
				if (_shouldDrawWaypoint) then {

					if (_useStandardWaypointLines) then {
						_mapControl drawline [_lineStartPosition,_waypointPosition, _waypointColor];
					} else {
						//-- draw THICC wp-lines
						[_mapControl,_lineStartPosition,_waypointPosition,0.5,_waypointColor] call A3C_ui_mapOverlay_fnc_drawThiccLine;
					};
					

					private _waypointSyncRecords = _wpSyncData;
					{
						private _syncRecord = _x;
						private _syncId = _syncRecord select 0;

						if !(_syncId == 0) then {
							private _syncGroupIndex = _squadWaypointSyncGroups findIf {
								private _existingSyncGroup = _x;
								(_existingSyncGroup select 0) == _syncId
							};

							if (_syncGroupIndex == -1) then {
								_squadWaypointSyncGroups pushBack [_syncId,[_waypointPosition]];
							} else {
								((_squadWaypointSyncGroups select _syncGroupIndex) select 1) pushBackUnique _waypointPosition;
							};
						};
					} foreach _waypointSyncRecords;

					//-- draw waypoint dot
					private _waypointDirection = _waypointPosition getDir _waypointDirectionPosition;
					private _isMainWaypoint = _subMarkerId == "";
					_waypointColor = if (_isMainWaypoint) then {[0,0,0,_waypointOpacity]} else {[0.7,0,0,_waypointOpacity]};
					private _waypointMarkerId = if (_isMainWaypoint) then {_mainMarkerId} else {_subMarkerId};
					private _waypointIconSize = if (_isMainWaypoint) then {_mainSquadWaypointIconSize} else {_subSquadWaypointIconSize};
					private _waypointLabel = "";
					private _waypointIconPath = "\a3\ui_f\data\Map\Markers\Military\box_ca.paa";

					if (_isMainWaypoint) then {
						switch (_waypointActionType) do {
							case ("STATIC") : {
								_waypointIconPath = "\a3c_ui\markers\A3C_Marker_PackStaticWeapon.paa";
								if ((_waypointActionData) select 0 == "ASSEMBLE") then {
									_waypointLabel = format ["Assemble %1",(getText (_cfgVehicles >> (_waypointActionData select 1) >> "displayName"))];
								} else {
									_waypointLabel = format ["Disassemble %1",(gettext (_cfgVehicles >> typeOf ((_waypointActionData) select 1) >> "displayname"))];
								};
								_waypointColor = [1,1,1,_waypointOpacity];
							};
							case ("SLINGLOAD") : {
								if (typeName (_waypointActionData) == "STRING") then {
									_waypointIconPath = "\a3c_ui\markers\A3C_Marker_SlingDrop.paa";
									_waypointLabel = "Drop Sling Cargo";
								} else {
									_waypointIconPath = "\a3c_ui\markers\A3C_Marker_SlingLoad.paa";
									_waypointLabel = format ["Sling Load %1",(gettext (_cfgVehicles >> typeOf (_waypointActionData)>> "displayname"))];
								};

								_waypointColor = [1,1,1,_waypointOpacity];
							};
							case ("PARADROP") : {
								_waypointIconPath = "\a3c_ui\markers\A3C_Marker_Paradrop.paa";
								_waypointColor = [1,1,1,_waypointOpacity];
							};
							case ("CTRL_DET") : {
								_waypointIconPath = "\a3c_ui\markers\A3C_Marker_Detonation.paa";
								_waypointColor = [1,1,1,_waypointOpacity];
								(_waypointActionData) params ["_targetVehicle","_ammoType"];
								if ( !isNull _targetVehicle) then {
									_waypointLabel = format
									[
										"Destroy %1 (%2)",
										gettext (_cfgVehicles >> typeOf _targetVehicle >> "displayName"),
										if (_ammoType == "") then {"undecided"} else {getText (_cfgMagazines >> _ammoType >> "displayName")}
									]
								} else {
									_waypointLabel = format
									[
										"Place %1",
										if (_ammoType == "") then {"Explosive"} else {getText (_cfgMagazines >> _ammoType >> "displayName")}
									]
								};
							};
							case ("GRENADE") : {
								_waypointOpacity = 0.5 min A3C_OPACITY;
								_waypointIconPath = (gettext (_cfgMagazines >> _waypointActionData >> "picture"));
								_waypointLabel = (gettext (_cfgMagazines >> _waypointActionData >> "displayname"));
								_waypointColor = [1,1,1,_waypointOpacity];
							};
							case ("LANDING") : {
								switch (_waypointActionData) do {
									case ("RAPPEL") : {
										_waypointIconPath = "\a3c_ui\markers\A3C_Marker_Rappel.paa";
										_waypointColor = [1,1,1,_waypointOpacity];
									};
									case ("PICKUP") : {
										_waypointIconPath = "\a3c_ui\markers\getin_ca.paa";
										_waypointColor = [1,1,1,_waypointOpacity];
									};
									case ("DROPOFF") : {
										_waypointIconPath = "\a3c_ui\markers\getout_ca.paa";
										_waypointColor = [1,1,1,_waypointOpacity];
									};
									case ("LANDFINAL") : {
										_waypointIconPath = "\a3c_ui\markers\helipad.paa";
										_waypointColor = [1,1,1,_waypointOpacity];
									};
								};

							};
						};


					};

					if !(_waypointActionType in ["SUPPRESSION"]) then {
						//-- draw wp-lookingdir cone
						if !(_waypointActionType in ["GRENADE","LANDING","SLINGLOAD","CTRL_DET"]) then {
							if !(A3C_TEMP_WP_ID_MAIN == _mainMarkerId) then {
									private _directionConeLength = if (_isMainWaypoint) then {10} else {5};
									private _directionConeVertices =
									[
										_waypointPosition,
										_waypointPosition getPos [_directionConeLength,_waypointDirection - 25],
										_waypointPosition getPos [_directionConeLength,_waypointDirection + 25]
									];
									_mapControl drawTriangle
									[
										_directionConeVertices,
										[0,1,1,_waypointOpacity],
										"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
									];
									A3C_UI_MAPICONS_SQ_WPS_LOOKDIR pushBack [_squadUnit,[_waypointIconSize,_waypointIconSize],_directionConeVertices,_waypointMarkerId];
							};
						};

						//-- draw wp icon
						_mapControl drawIcon
						[
							_waypointIconPath,
							_waypointColor,
							_waypointPosition,
							_waypointIconSize,
							_waypointIconSize,
							0,
							_waypointLabel,
							0,
							0.03,
							'PuristaLight',
							'right'
						];
						A3C_UI_MAPICONS_SQ_WPS_WPDOTS pushBack [_squadUnit,[_waypointIconSize,_waypointIconSize],_waypointPosition,_wpMarkers];


					};
					if !("NONE" in _wpCondition) then {
						_waypointOpacity = _conditionIconOpacity;
						private _conditionIconColor = [1,1,1,_waypointOpacity];
						private _conditionIconPath = "";
						switch (_waypointConditionType) do {
							case ("GOCODE") : {
								_conditionIconPath = format ["\a3c_ui\markers\icon_GoCode_%1.paa",(_waypointConditionData)];

							};
							case ("TIMEOUT") : {
								_conditionIconPath = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\watch_ca.paa";
								_conditionIconColor = [0,0,0,_waypointOpacity];
							};
							//-- draw sq-wp condition icon
						};
						_mapControl drawIcon
						[
							_conditionIconPath,
							_conditionIconColor,
							_waypointPosition getPos [_conditionIconOffset, 0],
							_waypointIconSize * 0.5,
							_waypointIconSize * 0.5,
							0,
							'',
							0,
							0.03,
							'PuristaLight',
							'right'
						];
					};


				};
				// Loop checks run for every waypoint, including completed waypoints.
				if ( _wpLoopValue < -1) then {
					// Loop start.
					_isLoopSegmentActive = true;
					_loopStartPosition = _waypointPosition;
				};
				if (_isLoopSegmentActive) then {

					if (_wpLoopValue > -1) then {
						// Loop end.
						_isLoopSegmentActive = false;
						// Connect the loop end to the recorded loop start.
						_mapControl drawline [_waypointPosition,_loopStartPosition, [0.19,0.63,0.95,A3C_OPACITY]];
					} else {
						// Connect waypoints within the loop to the following waypoint.
						_mapControl drawline [_waypointPosition,((_currentPlotData select (_waypointIndex + 1)) select 0) select 0, [0.19,0.63,0.95,A3C_OPACITY]];
					};
				};
			} foreach _currentPlotData;
		} foreach [_activePlotData,_temporaryPlotData];
		private _isUnitHeld = _squadUnit getVariable ["A3C_HOLD",false];
		private _unitOpacity = if (_isUnitHeld) then {0.3} else {0.4};
		_unitOpacity = _unitOpacity min A3C_OPACITY;
		private _assignedTeamName = if (player == cameraOn) then {assignedTeam _squadUnit} else {_squadUnit getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
		private _squadUnitColor = switch (_assignedTeamName) do {
			case ("RED") :{if (_isUnitHeld) then {[1,0.55,0.52,_unitOpacity]} else {[A3C_UI_COLOR_RED,_unitOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity} };
			case ("GREEN") :{if (_isUnitHeld) then {[0.6,1,0.5,_unitOpacity]} else {[0,1,0,_unitOpacity]}};
			case ("BLUE") :{if (_isUnitHeld) then {[0.5,0.67,0.98,_unitOpacity]} else {[A3C_UI_COLOR_BLUE,_unitOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity} };
			case ("YELLOW") :{if (_isUnitHeld) then {[0.98,0.95,0.63,_unitOpacity]} else {[A3C_UI_COLOR_YELLOW,_unitOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity} };
			case ("MAIN") :{if (_isUnitHeld) then {[0.52,0.52,0.52,_unitOpacity]} else {[0.8,0.8,0.8,_unitOpacity]}};
			default {[0.8,0.8,0.8,_unitOpacity]};
		};
		if (!_isSquadUnitInVehicle) then {
			_squadUnitIconPath = "A3C_Objects\images\icon_UnitHexagon.paa";
			_squadIconWidth = 25;
			_squadIconHeight = 25;
		} else {
			
			if (_isSquadVehicleDriver) then {
				_squadUnitIconPath = (gettext(_cfgVehicles >> (typeof _squadUnitVehicle) >> "Icon"));
				if ( (getPosATL _squadUnitVehicle) select 2 < 1 &&  {count ([_squadUnitVehicle] call A3C_main_fnc_getNearCargoLoadObjects) > 0}  ) then {
					_squadIconWidth = 35;
					_squadIconHeight = 35;
				} else {
					_squadIconWidth = 20;
					_squadIconHeight = 20;

				};
				//-- draw hexagon background
				_mapControl drawIcon
				[
					"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
					if (_assignedTeamName == "MAIN") then {[0.7,0.7,0.7,_unitOpacity]} else {_squadUnitColor},
					_squadUnitPosition,
					_squadIconWidth * 1.5,
					_squadIconHeight * 1.5,
					_squadUnitDirection,
					"",
					1,
					0.03,
					'PuristaLight',
					'center'
				];
				_squadUnitColor = [1,1,1,0.9 min A3C_OPACITY];
			} else {
				_squadUnitIconPath = "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
				_squadIconWidth = 15;
				_squadIconHeight = 15;
			};
			

		};
		
		if (_squadUnit == player) then {_unitOpacity = 1};
		

		_sharedDrawColor = if (!isNil '_sharedDrawColor') then {_sharedDrawColor} else {[0.8,0.8,0.8,_unitOpacity]};


		private _unitIconDrawResult = _mapControl drawIcon
		[
			_squadUnitIconPath,
			_squadUnitColor,
			_squadUnitPosition,
			_squadIconWidth,
			_squadIconHeight,
			_squadUnitDirection,
			"",
			1,
			0.03,
			'PuristaLight',
			'center'
		];
		A3C_UI_MAPICONS_SQUAD pushbackUnique [_squadUnit,[_squadIconWidth,_squadIconWidth], _squadUnitPositionASL];

		_formationIndexText = str (_squadUnit getvariable 'A3C_FORMATION_INDEX');
		private _formationIndexDrawResult = _mapControl drawIcon
		[
			"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
			(_squadUnitColor select [0,3]) + [A3C_OPACITY],
			_squadUnitPosition,
			0,
			0,
			_squadUnitDirection,
			"   " + _formationIndexText,
			1,
			0.03,
			if (_squadUnit == player) then {'PuristaBold'} else {'PuristaLight'},
			if (_squadUnit == player) then {'center'} else {'right'}
		];
		private _selectionCircleSize = if (_isSquadUnitInVehicle && {_isSquadVehicleDriver}) then {_squadIconWidth * 2.5} else {_squadIconWidth * 1.5};
		//-- unit selected circle
		if (_squadUnit in A3C_SELECTED_UNITS) then {
			private _selectionIconDrawResult = _mapControl drawIcon
			[
				"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
				[1,1,1,0.4 min A3C_OPACITY],
				_squadUnitPosition,
				_selectionCircleSize,
				_selectionCircleSize,
				0,
				"",
				1,
				0.03,
				'PuristaLight',
				'center'
			];
		};
	};

	//-- unit icon number: PLAYER will display group name in bold yellow. Subordinates will display their formation index number


} foreach (units player);


//-- Draw Sync Lines for squad level waypoints
{
	private _syncPositionGroup = _x;
	private _syncedWaypointPositions = _syncPositionGroup select 1;
	private _syncDestinationPosition = _syncedWaypointPositions select ((count _syncedWaypointPositions) - 1);
	{
		private _syncSourcePosition = _x;
		_mapControl drawline [_syncSourcePosition,_syncDestinationPosition, [1,0,1,A3C_OPACITY]];
	} forEach _syncedWaypointPositions;
} foreach _squadWaypointSyncGroups;


//-- DRAW PATH: UI Line (composed of rectangles, but built with triangles due to no better idea)

if (
	!isNull A3C_SQ_CLICKED_UNIT
	&& {A3C_MAP_DRAGPLANNING_POSITIONS isNotEqualTo []}
) then {
	private _dragPathTargetUnit = if (typeName A3C_SQ_CLICKED_UNIT == "GROUP") then {leader A3C_SQ_CLICKED_UNIT} else {(A3C_SELECTED_UNITS select 0)};
	{
		private _dragPosition = _x;
		private _previousDragPosition = if (_forEachIndex == 0) then {[]} else {A3C_MAP_DRAGPLANNING_POSITIONS select (_forEachIndex - 1)};
		private _segmentDirection = if (_forEachIndex == 0) then {_dragPathTargetUnit getDir _dragPosition} else {  _previousDragPosition getdir _dragPosition};
		private _segmentBottomLeft = if (_forEachIndex == 0) then {(_dragPosition getPos [5,_segmentDirection + 180]) getPos [1,_segmentDirection - 90]} else {_previousDragPosition getPos [1,_segmentDirection - 90]};
		private _segmentBottomRight = if (_forEachIndex == 0) then {(_dragPosition getPos [5,_segmentDirection + 180]) getPos [1,_segmentDirection + 90]} else {_previousDragPosition getPos [1,_segmentDirection + 90]};
		private _segmentTopLeft = _dragPosition getPos [1,_segmentDirection - 90];
		private _segmentTopRight = _dragPosition getPos [1,_segmentDirection + 90];


		private _segmentVertices =
		[
			_segmentBottomLeft,
			_segmentTopLeft,
			_segmentTopRight,
			_segmentBottomRight
		];
		_mapControl drawTriangle
		[
			[
				_segmentVertices select 0,
				_segmentVertices select 1,
				_segmentVertices select 2,
				_segmentVertices select 2,
				_segmentVertices select 3,
				_segmentVertices select 0
			],
			[0,0,1,0.7],
			"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
		];
	} foreach A3C_MAP_DRAGPLANNING_POSITIONS;
};



//////////////////////////////////
//-- UI-ICONS HIGHCOMMAND LEVEL //
//////////////////////////////////
{
	private _highCommandGroup = _x;
	private _groupLeader = leader _highCommandGroup;
	private _leaderVehicle = vehicle _groupLeader;
	private _leaderVehicleDriver = driver _leaderVehicle;
	private _groupUnits = units _highCommandGroup;
	private _isLeaderVehicleDrivenByGroup = _leaderVehicleDriver in _groupUnits;
	private _isAirGroup = _leaderVehicle isKindOf "AIR";
	private _currentGroupWaypointIndex = currentWaypoint _highCommandGroup;
	private _isGroupSelected = _highCommandGroup in A3C_SELECTED_UNITS;
	private _groupIconColor = [0,0,0,0];
	private _groupWaypoints = [];
	private _crewGroupOffsetIndex = 0;
	private _groupLeaderPosition = getPos _groupLeader;

	private _groupOpacity = if (!(_isGroupSelected) && {!_isLeaderVehicleDrivenByGroup OR {(!isNull (isVehicleCargo _leaderVehicle))}}) then {0.4} else {0.7};
	_groupOpacity = _groupOpacity min A3C_OPACITY;

	private _vehicleCrewGroups = [];
	if !( isNull objectParent _groupLeader && {_groupLeader == _leaderVehicleDriver}) then {
		{
			private _crewMember = _x;
			_vehicleCrewGroups pushBackUnique (group _crewMember);
		} foreach (crew _leaderVehicle);
	};
	_crewGroupOffsetIndex = [_highCommandGroup,_vehicleCrewGroups] call MCSS_fnc_getArrayIndex;
	if (_crewGroupOffsetIndex == -1) then {_crewGroupOffsetIndex = 0};
	private _groupIconPosition = _leaderVehicle getPos [2 * _crewGroupOffsetIndex, (getDir _leaderVehicle) + 180];
	
	
	if !(_isHighCommandInterfaceActive) then {
		_groupWaypoints = (waypoints _highCommandGroup);
		// Without AIC, draw waypoint icons, waypoint markers, and group markers.
		private _waypointCount = count _groupWaypoints;
		_groupLeaderPosition = getPos _leaderVehicle;
		

		private _canDrawGroup = !captive _groupLeader OR {_highCommandGroup == group player};

		if (_canDrawGroup) then {
			private _groupColorName = toLower (
				_highCommandGroup getVariable [
					"A3C_HC_GroupColor",
					switch (side _highCommandGroup) do {
						case (west) : {"blue"};
						case (east) : {"red"};
						case (resistance) : {"green"};
						default {"blue"};
					}
				]
			);
			_groupIconColor = switch (_groupColorName) do {
				case ("red") : {[A3C_UI_COLOR_RED,_groupOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
				case ("blue") : {[A3C_UI_COLOR_BLUE,_groupOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
				case ("green") : {[0,1,0,_groupOpacity]};
				case ("black") : {[A3C_UI_COLOR_Black,_groupOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
				case ("white") : {[1,1,1,_groupOpacity]};
				default {[A3C_UI_COLOR_BLUE,_groupOpacity] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
			};
			{
				private _waypoint = _x;
				private _waypointIndex = _waypoint select 1;
				private _waypointPosition = waypointPosition _waypoint;

				private _waypointLineStart = [1000,1000,0];
				private _waypointLineEnd = [1000,100,0];

				if (_currentGroupWaypointIndex <= _waypointIndex) then {
					private _waypointType = waypointType _waypoint;
					private _waypointStatements = waypointStatements _waypoint;
					private _rawWaypointScript = waypointScript _waypoint;
					private _waypointConditionCode = _waypointStatements select 0;
					private _waypointScriptCode = if (_rawWaypointScript == "") then {_waypointStatements select 1} else {_rawWaypointScript};
					private _waypointScriptLower = toLower _waypointScriptCode;

					private _attachedWaypointObject = waypointAttachedVehicle _waypoint;
					_attachedWaypointObject = if (!isNil '_attachedWaypointObject') then {
						_attachedWaypointObject
					} else {
						waypointAttachedObject _waypoint;
					};
					
					if (!isNil '_attachedWaypointObject' && {!isNull _attachedWaypointObject && {alive _attachedWaypointObject && {!(_attachedWaypointObject in _groupUnits)}}}) then {
						[_mapControl,_waypointPosition,getPos _attachedWaypointObject,0.5,[1,1,1,0.8]] call A3C_ui_mapOverlay_fnc_drawThiccLine;
						[
							_mapControl,
							_attachedWaypointObject,
							17,
							[0.13,0.13,0.13,0.5],
							(gettext(_cfgVehicles >> typeof _attachedWaypointObject >> "displayName"))
						] call A3C_ui_mapOverlay_fnc_drawIconVehicleMacro;
					};	

					//-- draw WP Lines
					if (_waypointIndex == _currentGroupWaypointIndex) then {
						if (_useStandardWaypointLines) then {
							_mapControl drawline [_groupIconPosition,_waypointPosition, _groupIconColor];
						} else {
							//-- draw THICC wp-lines
							[_mapControl,_groupIconPosition,_waypointPosition,0.5,_groupIconColor] call A3C_ui_mapOverlay_fnc_drawThiccLine;
						};
						
						
						if (_waypointCount > (_forEachIndex + 1)) then {
							_waypointLineStart = (_waypointPosition);
							_waypointLineEnd = (waypointPosition [_highCommandGroup,(_forEachIndex + 1)]);
							[_mapControl,_waypointLineStart,_waypointLineEnd,0.5,_groupIconColor] call A3C_ui_mapOverlay_fnc_drawThiccLine;
						};
					} else {
						if (_waypointCount > (_forEachIndex + 1)) then {
							[_mapControl,_waypointPosition,waypointPosition [_highCommandGroup,(_forEachIndex + 1)],0.5,_groupIconColor] call A3C_ui_mapOverlay_fnc_drawThiccLine;
						};
					};
					//-- draw WP-ICON

					private _waypointIconPath =  "\a3c_ui\markers\icon_waypoint_maps.paa";

					_sharedDrawColor = _groupIconColor;
					
					if (_waypointType == "CYCLE") then {
						_sharedDrawColor = [1,1,1,_groupOpacity];
					};

					private _waypointIconSize = 45;

					if (_isAirGroup) then {
						if (_waypointType == "LOITER") then {
							_waypointIconSize = 20;
							_sharedDrawColor = [1,1,1,_groupOpacity];
							_waypointIconPath = "\a3c_ui\markers\icon_marker_wp_loiter.paa";
						} else {
							switch (true) do {
								case (["LANDING",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									if (["LANDING_COMBAT",_waypointScriptCode] call BIS_fnc_instring) then {
										_waypointIconPath = "\a3c_ui\markers\getin_ca.paa";
									} else {
										_waypointIconPath = "\a3c_ui\markers\helipad.paa";
									};
								};
								case (["PARADROP",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "\a3c_ui\markers\A3C_Marker_Paradrop.paa";
								};
								case (["RAPPEL",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "a3c_ui\markers\A3C_Marker_Rappel.paa"
								};
								case (["SLING LOAD HOOK",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "a3c_ui\markers\A3C_Marker_SlingLoad.paa"
								};
								case (["SLING LOAD UNHOOK",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "a3c_ui\markers\A3C_Marker_SlingDrop.paa"
								};
								case ("overwatch" in _waypointScriptLower) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "a3c_ui\markers\marker_action_overWatch.paa";

									// Draw the overwatch cone.
									private _overwatchDirection = parseNumber ((_waypointScriptCode splitstring ",") select 5);

									//-- draw Vehicle Firing Sector (has to happen first so that it's underneath the group icon)
									private _helicopterFreezeState = _leaderVehicle getVariable ["A3C_Freeze_helicopter",[false,0]];
										private _overwatchConeVertices = 
										[
											_waypointPosition,
											_waypointPosition getPos [300,_overwatchDirection - 45],
											_waypointPosition getPos [300,_overwatchDirection + 45]
										];
										_mapControl drawTriangle
										[
											[
												_overwatchConeVertices select 0,
												_overwatchConeVertices select 1,
												_overwatchConeVertices select 2
											],
											if (_helicopterFreezeState select 0) then {A3C_UI_COLOR_RED} else {A3C_UI_COLOR_YELLOW},
											"#(rgb,1,1,1)color(1,1,1,0.2)"
										];
										A3C_UI_MAPICONS_HC_CONES pushBack [_waypoint,_overwatchDirection,_overwatchConeVertices];
								};
								case (["CAS-STRIKE",_waypointScriptCode] call BIS_fnc_instring OR ["CASdistribute",_waypointScriptCode] call BIS_fnc_instring) : {
									_waypointIconSize = 20;
									_sharedDrawColor = [1,1,1,_groupOpacity];
									_waypointIconPath = "A3C_UI\Markers\A3C_MARKER_CAS.paa";
								};
							};
						};
					} else {
						switch (true) do {
							case ("repair" in _waypointScriptCode) : {
								//-- circle
								private _repairTargets = (_waypointPosition nearEntities [["Car","Motorcycle","Tank","AIR"], 100]) select {
									private _repairCandidate = _x;
									[side _groupLeader, _repairCandidate,"VISUAL"] call A3C_main_fnc_isVehicleDamaged
								};
								private _repairAreaColor = switch (true) do {
									case (count _repairTargets > 3) : {A3C_UI_COLOR_RED};
									case (count _repairTargets > 2) : {[0.99,0.36,0.12,1]};
									case (count _repairTargets > 1) : {A3C_UI_COLOR_YELLOW};
									default {[0,1,0,1]};
								};


								_mapControl drawEllipse
								[
									_waypointPosition,
									100,
									100,
									0,
									[_repairAreaColor,0.5 min A3C_OPACITY] call A3C_ui_shared_fnc_getColorArrayWithOpacity,
									"#(ai,512,512,9)perlinNoise(256,256,0,1)"
								];
								//-- vehicles to repair
								{
									private _repairTarget = _x;
									_mapControl drawIcon
									[
										"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\repair_ca.paa",
										if ((_repairTarget getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0) then {[0,1,0,A3C_OPACITY]} else {[0,0,0,A3C_OPACITY]},
										position _repairTarget,
										15,
										15,
										0,
										"",
										0,
										0.03,
										'PuristaLight',
										'center'
									];
								} foreach _repairTargets;


								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\A3C_marker_action_repair.paa";
							};
							case (["CLEARBUILDING",_waypointScriptCode] call BIS_fnc_instring) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\building.paa";
								if (["CLEARBUILDING_ACTIVE",_waypointScriptCode] call BIS_fnc_instring) then {
									_sharedDrawColor = [0.99,0.37,0.11,_groupOpacity];
								};
								
							};
							case (["plantExplosive",_waypointScriptCode] call BIS_fnc_instring) : {
								_waypointIconSize = 20;
								_waypointIconPath = "a3c_ui\markers\A3C_Marker_Detonation.paa";
								_sharedDrawColor = [1,1,1,_groupOpacity];
								// if (["objnull",_waypointScriptCode] call BIS_fnc_instring) then {
								// 	_sharedDrawColor = [1,1,1,_groupOpacity];
								// } else {
								// 	_sharedDrawColor = [0.99,0.42,0.4,_groupOpacity];

								// };
							};
							case (["ASSEMBLE_UAV",_waypointScriptCode] call BIS_fnc_instring) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\iconMarkerUAV.paa"
							};
						};
					};
					if (_waypointType in ["SAD"]) then {
						_waypointIconSize = 20;
						_sharedDrawColor = [1,1,1,_groupOpacity];
						_waypointIconPath = "a3c_ui\markers\icon_marker_wp_SAD.paa"

					} else {
						switch (true) do {
							case ("tr_unload" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\getout_ca.paa"
							};
							case ("loadgroupinvehicle" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\getin_ca.paa"
							};
							case ("groupgetinvehicle" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\icon_marker_vehicleBoard.paa"
							};
							case ("getvehicleinvehicle" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "\a3c_ui\markers\getin_ca.paa"
							};
							case ("loadvehicleinvehicle" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "\a3c_ui\markers\getin_ca.paa"
							};
							case ("ambush" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "\a3c_ui\markers\icon_marker_ambush.paa"
							};
							case ("suppress" in (_waypointScriptLower)) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "\a3c_ui\markers\icon_marker_fireSupport.paa"
							};
							case ("AssembleWeapon" in _waypointScriptCode) : {
								_waypointIconSize = 20;
								_sharedDrawColor = [1,1,1,_groupOpacity];
								_waypointIconPath = "a3c_ui\markers\A3C_MARKER_PackStaticWeapon.paa"
							};
						};
					};

					if (_waypointIndex >= _currentGroupWaypointIndex) then { //~~ necessary?
						_mapControl drawIcon
						[
							_waypointIconPath,
							_sharedDrawColor,
							_waypointPosition,
							_waypointIconSize,
							_waypointIconSize,
							0,
							"",
							0,
							0.03,
							'PuristaLight',
							'center'
						];
						private _waypointHitboxSize = _waypointIconSize;
						A3C_UI_MAPICONS_HC_WPS pushBack [_highCommandGroup,[_waypointHitboxSize,_waypointHitboxSize],(_waypointPosition),_waypointIndex];
					};

					private _conditionIconPath = "";
					private _conditionIconColor = [1,1,1,1];
					{
						private _conditionSourceText = _x;
						if (["GoCode",_conditionSourceText] call BIS_fnc_inString) then {
							{
								private _goCode = _x;
								if ({
									private _goCodeActivationToken = _x;
									[_goCodeActivationToken,_conditionSourceText] call BIS_fnc_inString
								} count [format ["Activate_%1",_goCode],str _goCode] > 0) then {
									_conditionIconPath = format ["\a3c_ui\markers\icon_GoCode_%1.paa",_goCode];
								};
							} foreach ["A","B","C","D"];
						};
					} foreach [_waypointConditionCode,_waypointScriptCode];

					if ( !(_waypointConditionCode == "") ) then {
						if (["time",_waypointConditionCode] call BIS_fnc_instring OR {["date",_waypointConditionCode] call BIS_fnc_instring}) then {
							_conditionIconPath = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\watch_ca.paa";
							_conditionIconColor = [0,0,0,1];
						};
					};

					if (_conditionIconPath != "") then {
						_conditionIconColor set [3,_conditionIconOpacity];

						_mapControl drawIcon
						[
							_conditionIconPath,
							_conditionIconColor,
							_waypointPosition getPos [_conditionIconOffset, 0],
							_conditionIconSize * 0.5,
							_conditionIconSize * 0.5,
							0,
							'',
							0,
							0.03,
							'PuristaLight',
							'right'
						];
					};

					private _synchronizedWaypoints = synchronizedWaypoints _waypoint;
					if (count _synchronizedWaypoints > 0) then {
						{
							private _synchronizedWaypoint = _x;
							private _existingSyncPairIndex = A3C_HC_WP_SYNC_ARRAYS findIf {
								private _existingSyncPair = _x;
								_waypoint in _existingSyncPair
							};

							if (_existingSyncPairIndex == -1) then {
								A3C_HC_WP_SYNC_ARRAYS pushBackUnique [_waypoint,_synchronizedWaypoint];
							};
						} forEach _synchronizedWaypoints;
					};
					// Highlight waypoints belonging to a selected group or the
					// current multi-waypoint selection. Multi-waypoint selection
					// takes visual priority.

					private _isMultiWaypointSelected =
						_waypoint in A3C_Selection_MultiWaypoint;

					if (
						_isMultiWaypointSelected
						|| {_isGroupSelected}
					) then {
						private _waypointSelectionCircleColor =
							if (_isMultiWaypointSelected) then {
								[1,1,0,1]
							} else {
								[
									A3C_UI_COLOR_BLUE,
									0.15 min A3C_OPACITY
								] call A3C_ui_shared_fnc_getColorArrayWithOpacity
							};

						private _waypointSelectionCircleText =
							if (_isMultiWaypointSelected) then {
								format [
									"%1 (%2)",
									groupID _highCommandGroup,
									_waypointIndex
								]
							} else {
								""
							};

						private _waypointSelectionCirclePosition =
							_waypointPosition;

						private _waypointSelectionCircleScreenPosition =
							_mapControl ctrlMapWorldToScreen
								_waypointSelectionCirclePosition;

						if (
							_waypointIconPath isEqualTo "\a3c_ui\markers\icon_waypoint_maps.paa"
							&& {
								_waypointSelectionCircleScreenPosition isNotEqualTo []
							}
						) then {
							// Screen Y increases downward, so subtracting moves the circle up.
							_waypointSelectionCircleScreenPosition set
							[
								1,
								(
									_waypointSelectionCircleScreenPosition
										select 1
								)
									- (
										(_waypointSelectionCircleSize / 480)
										* _waypointSelectionCircleVerticalOffsetFactor
									)
							];

							_waypointSelectionCirclePosition =
								_mapControl ctrlMapScreenToWorld
									_waypointSelectionCircleScreenPosition;
						};

						_mapControl drawIcon
						[
							"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
							_waypointSelectionCircleColor,
							_waypointSelectionCirclePosition,
							_waypointSelectionCircleSize,
							_waypointSelectionCircleSize,
							0,
							_waypointSelectionCircleText,
							0,
							0.03,
							"PuristaLight",
							"right"
						];
					};	
				};
			} foreach _groupWaypoints;


			//-- draw Group Icon
	
			private _groupIconPath = [_highCommandGroup] call A3C_main_fnc_getGroupIconType;
			_groupIconColor set [3,_groupOpacity];

			private _groupIconSize = (2* 10^(abs log _mapScale));
			_groupIconSize = _groupIconSize max (8 * safezoneH);
			_groupIconSize = _groupIconSize min (25 * safezoneH);

			if !(_isLeaderVehicleDrivenByGroup) then {
				_groupIconSize = _groupIconSize * 0.7;
			};
			private _groupBackgroundIconPath = if ("b_hq_ca" in _groupIconPath) then {"A3C_UI\markers\icon_map_backgroundHQ.paa"} else {"A3C_UI\markers\icon_map_backgroundHC.paa"};
			private _groupOutlineColor = if (_highCommandGroup getVariable ["A3C_HC_GroupColor","blue"] == "WHITE") then {[0,0,0,1]} else {[1,1,1,1]};
			

			//-- orientation helper for remote HC vehicle control
			if (a3c_is_HC_remote && {_leaderVehicle == a3c_remote_tank_obj}) then {
				_mapControl drawLine
				[
					getpos _leaderVehicle,
					(getPosASL _leaderVehicle) getPos [10, getDir _leaderVehicle],
					_groupIconColor
				];
			};

			

			//-- icon macro group
			{
				private _groupIconLayer = _x;
				_mapControl drawIcon
				[
					_groupIconLayer select 0,
					_groupIconLayer select 1,
					_groupIconPosition,
					_groupIconSize,
					_groupIconSize,
					0,
					"",
					0,
					0.03,
					'PuristaLight',
					'center'
				];
			} foreach [
				[_groupBackgroundIconPath,_groupIconColor],
				[_groupIconPath,_groupOutlineColor]
			];

			
			//-- draw selection and speed-limit state icon

			private _speedLimit =
				_leaderVehicle getVariable ["A3C_LIMIT_SPEED", false];

			private _groupStateIconPath =
				[
					_isGroupSelected,
					_speedLimit
				] call A3C_ui_shared_fnc_getGroupStateIconPath;

			private _groupAuxiliaryOpacity =
				if (_isGroupSelected) then {
					_groupOpacity
				} else {
					_groupOpacity min 0.3
				};

			_mapControl drawIcon
			[
				_groupStateIconPath,
				[1,1,1,_groupAuxiliaryOpacity],
				_groupIconPosition,
				_groupIconSize * 2.2,
				_groupIconSize * 2.2,
				0,
				"",
				2,
				0.03,
				"PuristaLight",
				"center"
			];


			private _behaviourIconColor = switch (behaviour (_groupLeader)) do {
				case ("COMBAT") : {[1,0,0,_groupAuxiliaryOpacity]};
				case ("AWARE") : {[1,1,0,_groupAuxiliaryOpacity]};
				case ("SAFE") : {[1,1,1,_groupAuxiliaryOpacity]};
				case ("STEALTH") : {[1,0,0,_groupAuxiliaryOpacity]};
				case ("CARELESS") : {[0.25, 0.85, 0.8, _groupAuxiliaryOpacity]};
				default {[.5,.5,.5,_groupAuxiliaryOpacity]}
			};

		
			private _combatModeIconColor = switch (combatMode (_groupLeader)) do {
				case ("RED") : {[1,0,0,_groupAuxiliaryOpacity]};
				case ("YELLOW") : {[1,1,0,_groupAuxiliaryOpacity] };
				case ("WHITE") : {[1,1,1,_groupAuxiliaryOpacity]};
				case ("GREEN") : {[0,1,0,_groupAuxiliaryOpacity]};
				case ("BLUE") : {[0,0,1,_groupAuxiliaryOpacity]};
				default {[.5,.5,.5,_groupAuxiliaryOpacity]}
			};
		
			
			//-- behaviour:
			_mapControl drawIcon
			[
				"A3C_UI\icons\icon_gp_behavior.paa",
				_behaviourIconColor,
				_groupIconPosition,
				_groupIconSize * 1.5,
				_groupIconSize * 1.5,
				0,
				"",
				2,
				0.03,
				'PuristaLight',
				'center'
			];

			//-- combatmode:
			_mapControl drawIcon
			[
				"A3C_UI\icons\icon_gp_cbMode.paa",
				_combatModeIconColor,
				_groupIconPosition,
				_groupIconSize * 1.5,
				_groupIconSize * 1.5,
				0,
				"",
				2,
				0.03,
				'PuristaLight',
				'center'
			];

			// Indicate groups currently boarding or dismounting.

			if (
				[_highCommandGroup] call A3C_ai_highCommand_fnc_isGroupBoarding
				|| {
						{
							isNull assignedVehicle _x
							&& {!isNull objectParent _x}
						} count units _highCommandGroup > 0
					}
			) then {
				_mapControl drawIcon
				[
					"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa",
					[1,1,1,_groupAuxiliaryOpacity],
					_groupIconPosition,
					_groupIconSize * 1,
					_groupIconSize * 1,
					0,
					"",
					2,
					0.03,
					'PuristaLight',
					'center'
				];
			};

			
			A3C_UI_MAPICONS_HC_GROUP pushBack [_highCommandGroup,[_groupIconSize * 1.5,_groupIconSize * 1.5],_groupIconPosition];

			if ((_groupLeader) getVariable ["A3C_CLEARING",false]) then {
				{
					private _clearingUnit = _x;
					_mapControl drawIcon
					[
						"\a3\ui_f\data\Map\Markers\Military\box_CA.paa",
						[0.99,0.95,0.54,0.3 min A3C_OPACITY],
						getPos _clearingUnit,
						20,
						20,
						getDir _clearingUnit,
						'',
						1,
						0.03,
						'PuristaLight',
						'right'
					];
					_mapControl drawLine [getpos _clearingUnit, getPos _leaderVehicle, [0.99,0.95,0.54,0.3 min A3C_OPACITY]];
				} foreach ((_groupUnits) - [_groupLeader]);
			};
			
			private _groupVehicleDisplayNames = if (!isNull objectParent _groupLeader) then {[(parseText (getText (_cfgVehicles >> typeOf _leaderVehicle >> "displayName")))]} else {[]};;

			private _groupVehicles = [];

			{
				private _groupUnit = _x;
				if (!isNull objectParent _groupUnit) then {
					if (_groupUnit == driver vehicle _groupUnit) then {
						_groupVehicles pushBackUnique (objectParent _groupUnit);
					};
				};
			} foreach (_groupUnits);

			
			private _shouldDrawGroupName = (isPlayer (_groupLeader)) OR {_isGroupSelected};
			if !(_shouldDrawGroupName) then {
				if (_shouldCheckHoveredGroup) then {
					private _hoveredGroupIcons = (["HC_GP",A3C_MAP_X,A3C_MAP_Y] call A3C_ui_mapOverlay_fnc_getIconsAtMapPos);
					if ({
						private _hoveredGroupIconData = _x;
						_highCommandGroup == _hoveredGroupIconData select 0
					} count _hoveredGroupIcons > 0) then {
						_shouldDrawGroupName = true;
					};
				};
			};

			if (_shouldDrawGroupName) then {
				private _groupNameOffset = 2 + (59 * _zoomLabelOffsetFactor);
				_mapControl drawIcon
				[
					"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa",
					if (_groupLeader == player) then {[0.85,0.85,0,A3C_OPACITY min _groupOpacity]} else {[1,1,1,A3C_OPACITY min _groupOpacity]},
					_groupIconPosition vectorAdd [0,-(_groupNameOffset),0],
					0,
					0,
					0,
					format ["%1: %2 %3",(_forEachIndex + 2), groupID (_highCommandGroups select _forEachIndex), if (side _groupLeader != side player) then {format ["(%1)",side _groupLeader]} else {""}],
					2,
					if (_isLeaderVehicleDrivenByGroup) then {0.03} else {0.025},
					if (_groupLeader == player) then {'PuristaBold'} else {'PuristaLight'},
					'center'
				];
			};
			private _groupStatus = _highCommandGroup getVariable 
			[
				"A3C_UI_Group_Status",
				["",[]]
			];
			if (_groupStatus select 0 != "") then {
				private _minimumStatusOffset = if (_shouldDrawGroupName) then {7} else {2};
				private _statusVectorDistance = _minimumStatusOffset + (59 * _zoomLabelOffsetFactor);
					private _groupStatusColor = _groupStatus select 1;
					_groupStatusColor set [3,A3C_OPACITY];
					_mapControl drawIcon
					[
						"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa",
						_groupStatusColor,
						_groupIconPosition vectorAdd [0,-(_statusVectorDistance),0],
						0,
						0,
						0,
						_groupStatus select 0,
						0,
						0.03,
						'PuristaLight',
						'center'
					];

			};
			

			// Static weapon icons.
			{
				private _staticWeaponUnit = _x;
				_highCommandGroup = group _staticWeaponUnit; //~~ Confirm whether this reassignment is required.
				if ((vehicle _staticWeaponUnit) isKindOf "staticweapon") then {
					private _staticWeaponIconDrawResult = _mapControl drawIcon
					[
						(gettext(_cfgVehicles >> (typeof (vehicle _staticWeaponUnit)) >> "icon")),
						[A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_ui_shared_fnc_getColorArrayWithOpacity,
						getPos _staticWeaponUnit,
						35,
						35,
						getDir (vehicle _staticWeaponUnit),
						format [     '%1 | %2',(gettext(_cfgVehicles >> typeof (vehicle _staticWeaponUnit) >> "displayName")), groupID _highCommandGroup],
						1,
						0.03,
						'PuristaLight',
						'right'
					];
				};
			} foreach (_groupUnits);

			//-- draw convoy subunits
			if ({
				private _convoyGroupData = _x;
				_highCommandGroup == _convoyGroupData select 0
			} count A3C_CONVOYGROUPS > 0) then {
				{
					private _convoyVehicle = _x;
					_mapControl drawIcon
					[
						"\a3\ui_f\data\Map\Markers\Military\box_CA.paa",
						[0.99,0.95,0.54,0.3 min A3C_OPACITY],
						getPos _convoyVehicle,
						35,
						55,
						getDir _convoyVehicle,
						'',
						1,
						0.03,
						'PuristaLight',
						'right'
					];
				} foreach (_groupVehicles - [_leaderVehicle]);
			};	
		};
	};
	
	
} foreach (_highCommandGroups);


// Draw HC waypoint synchronization lines after collecting synchronization data from the waypoint pass.
{
	private _waypointSyncPair = _x;
	private _firstWaypointPosition = waypointPosition (_waypointSyncPair select 0);
	private _secondWaypointPosition = waypointPosition (_waypointSyncPair select 1);
	if ({
		private _syncedWaypoint = _x;
		currentWaypoint (_syncedWaypoint select 0) > (_syncedWaypoint select 1)
	} count _waypointSyncPair == 0) then { //-- draw only for active waypoints
		_mapControl drawLine [_firstWaypointPosition,_secondWaypointPosition, [1,1,0,1]];
	};
} foreach A3C_HC_WP_SYNC_ARRAYS;


if (!(A3C_DISABLE_TRACKER) && {A3C_TRACKER_VISIBLE == 1} ) then {
	{
		private _trackerEntry = _x;
		private _trackedGroup = _trackerEntry select 0;
		if (_trackedGroup in allGroups) then {
			if ({
				private _trackedUnit = _x;
				alive _trackedUnit
			} count units _trackedGroup == 0) then {
				A3C_TRACKER_GROUPS = A3C_TRACKER_GROUPS - [_trackerEntry];
			} else {
				if ({
					private _trackedUnit = _x;
					player knowsAbout (vehicle _trackedUnit) > 0
				} count (units _trackedGroup) > 0) then {
					private _trackerIconSize = [25,45];
					private _trackerIconDrawResult = _mapControl drawIcon
					[
						[_trackedGroup] call A3C_main_fnc_getGroupIconType,
						(_trackerEntry select 3), //-- color
						(_trackerEntry select 1), //-- position
						25,
						35,
						0,
						"",
						1,
						0.03,
						'PuristaLight',
						'right'
					];
					switch (_trackerEntry select 2) do {
						case ("ENEMY") : {
							A3C_UI_MAPICONS_HC_TRACKER pushBackUnique [_trackedGroup,_trackerIconSize,(_trackerEntry select 1),"ENEMY"];

						};
						case ("CIVILIAN") : {
						};
					};
				};
			};
		};
	} foreach A3C_TRACKER_GROUPS;
};


//-- draw active-suppression lines
{
	private _suppressionGroup = _x;

	// Prevent suppression lines from other player-controlled groups.
	if (
		!isPlayer leader _suppressionGroup
		|| {player == leader _suppressionGroup}
	) then {
		{
			private _suppressingUnit = _x;

			private _suppressionTargetData =
				_suppressingUnit getVariable [
					"A3C_SUPPRESSION_TARGET",
					[0, false, -1]
				];

			private _suppressionTarget =
				_suppressionTargetData param [
					0,
					0
				];

			private _suppressionPolygonReference =
				_suppressionTargetData param [
					2,
					-1
				];

			// A scalar target indicates that suppression is inactive.
			if !(_suppressionTarget isEqualType 0) then {
				private _polygonOwner =
					if (
						group _suppressingUnit
							== group player
					) then {
						_suppressingUnit
					} else {
						group _suppressingUnit
					};

				private _availablePolygons =
					_polygonOwner getVariable [
						"A3C_UNIT_POLYS",
						[]
					];

				if !(
					_suppressionPolygonReference
						isEqualTo -1
				) then {
					private _suppressionPolygon = nil;

					{
						private _candidatePolygon = _x;
						private _candidateMetadata =
							_candidatePolygon param [
								0,
								[]
							];

						private _candidateReference =
							if (
								_suppressionPolygonReference
									isEqualType ""
							) then {
								_candidateMetadata param [
									1,
									""
								]
							} else {
								_candidateMetadata param [
									2,
									-1
								]
							};

						if (
							_candidateReference
								isEqualTo
								_suppressionPolygonReference
						) exitWith {
							_suppressionPolygon =
								_candidatePolygon;
						};
					} forEach _availablePolygons;

					if (!isNil "_suppressionPolygon") then {
						private _polygonPositions =
							+(
								_suppressionPolygon param [
									1,
									[]
								]
							);

						_polygonPositions = [
							_polygonPositions,
							[],
							{
								_x distance2D
									_suppressingUnit
							},
							"ASCEND"
						] call BIS_fnc_sortBy;

						if !(_polygonPositions isEqualTo []) then {
							private _nearestPolygonPosition =
								_polygonPositions select 0;

							_mapControl drawLine [
								getPos _suppressingUnit,
								_nearestPolygonPosition,
								[
									A3C_UI_COLOR_RED,
									0.3
								] call A3C_ui_shared_fnc_getColorArrayWithOpacity
							];

							_mapControl drawIcon [
								"\a3\ui_f\data\Map\Markers\Military\dot_CA.paa",
								[1, 1, 1, 0.6],
								getPos _suppressingUnit,
								15,
								15,
								0,
								"",
								1,
								0.03,
								"PuristaLight",
								"right"
							];
						};
					};
				};
			};
		} forEach units _suppressionGroup;
	};
} forEach (
	[group player]
	+ _highCommandGroups
);

// A3C_ALL_POLYS is recreated from entity variables on each frame.
A3C_ALL_POLYS = [];

// Draw area-of-fire polygons and waypoint-type icons.
{
	private _polygonOwner = _x;
	private _ownerPolygons = _polygonOwner getVariable [
		"A3C_UNIT_POLYS",
		[]
	];
	private _activePolygonReferences = [];

	if (typeName _polygonOwner == "GROUP") then {
		_activePolygonReferences = waypoints _polygonOwner;

		{
			private _activeWaypoint = _x;
			if (
				((waypointStatements [_polygonOwner, currentWaypoint _polygonOwner]) select 0) == "false"
				|| {currentWaypoint _polygonOwner > (_activeWaypoint select 1)}
			) then {
				_activePolygonReferences = _activePolygonReferences - [_activeWaypoint];
			};
		} forEach _activePolygonReferences;
	};

	{
		private _polygon = _x;
		private _shouldAddPolygon = true;

		if (typeName _polygonOwner != "GROUP") then {
			private _polygonMarkerId = (_polygon select 0) select 1;

			_activePolygonReferences =
				(_polygonOwner getVariable [
					"A3C_PLOT_TEMP",
					[]
				])
				+ (_polygonOwner getVariable [
					"A3C_PLOT",
					[]
				]);

			if (
				{
					private _plotEntry = _x;
					((_plotEntry select 1) select 0) == _polygonMarkerId
				} count _activePolygonReferences == 0
			) then {
				if !(
					_polygonOwner in (
						A3C_SUPPRESSION_UNITS_SQ
						+ A3C_SUPPRESSION_UNITS_AI
					)
				) then {
					//~~ The polygon ID may still be marker-based and fail
					//~~ to match _polygonMarkerId; confirm whether this remains true.
					[
						_polygonOwner,
						_polygon
					] call A3C_ai_shared_fnc_polygonAreaRemove;

					_shouldAddPolygon = false;
				};
			};
		};

		if (_shouldAddPolygon) then {
			A3C_ALL_POLYS pushBackUnique _polygon;

			if (typeName _polygonOwner == "GROUP") then {
				private _ownerWaypoints = waypoints _polygonOwner;
				private _linkedWaypointPosition = [0, 0, 0];
				private _shouldDrawWaypointLink = false;
				private _waypointGroups = [];

				{
					private _ownerWaypoint = _x;
					_waypointGroups pushBack (_ownerWaypoint select 0);
				} forEach _ownerWaypoints;

				{
					private _ownerWaypoint = _x;
					if (
						((_polygon select 0) select 2)
							== (_ownerWaypoint select 1)
					) exitWith {
						_linkedWaypointPosition = waypointPosition _ownerWaypoint;
						_shouldDrawWaypointLink = true;
					};
				} forEach _ownerWaypoints;

				if (_shouldDrawWaypointLink) then {
					_mapControl drawLine [
						_linkedWaypointPosition,
						(_polygon select 0) select 0,
						[
							A3C_UI_COLOR_RED,
							0.3
						] call A3C_ui_shared_fnc_getColorArrayWithOpacity
					];
				};
			};
		};
	} forEach _ownerPolygons;
} forEach (
	_highCommandGroups
		+ units player
);


//-- draw polygons
{
	private _polygonData = _x;
	private _polygonId = (_polygonData select 0) select 1;
	private _polygonType	= switch (true) do {
		case (["SUP",_polygonId] call BIS_fnc_instring) : {"SUP"};
		case (["AMB",_polygonId] call BIS_fnc_instring) : {"AMB"};
		case (["ASS",_polygonId] call BIS_fnc_instring) : {"ASS"};
		default {"OTHER"};
	};

	//-- draw polygon, unless it's an Assembly Polygon
	if (count _polygonData > 0 && {count (_polygonData select 1) > 0 }) then {
		private _polygonColor = switch (_polygonType) do {
			case ("SUP") : {[A3C_UI_COLOR_RED,0.7] call A3C_ui_shared_fnc_getColorArrayWithOpacity};
			case ("AMB") : {[0,0,0,0.7]};
			case ("ASS") : {[0,0,0,0.7]};
			case ("OTHER") : {[1,1,1,0.7]};
		};

		private _polygonCenterIconPath = switch (_polygonType) do {
			case ("SUP") : {'\a3\ui_f\data\Map\GroupIcons\selector_selectedMission_ca.paa'};
			case ("AMB") : {'\a3\ui_f\data\Map\Markers\Military\ambush_CA.paa'};
			case ("ASS") : {'\a3\ui_f\data\Map\GroupIcons\badge_gs.paa'};
			case ("OTHER") : {""};
		};
		// Explicit RGBA colors are used because marker-color config conversion has not worked reliably since the Contact platform update.

		private _polygonVertices = _polygonData select 1;
		private _polygonBaseSize = if (_polygonType == "ASS") then {0.5} else {1};
		private _polygonCenterIconSize = ((_polygonBaseSize * 0.15) * 10^(abs log (ctrlMapScale _mapControl))) max 20;
		private _polygonVertexIconSize = ((0.8 * 0.15) * 10^(abs log _mapScale)) max 10;
		private _polygonIconDirection = 0;

		_mapControl drawIcon
		[
			_polygonCenterIconPath,
			_polygonColor,
			(_polygonData select 0) select 0,
			_polygonCenterIconSize,
			_polygonCenterIconSize,
			_polygonIconDirection,
			'',
			1,
			0.03,
			'PuristaLight',
			'right'
		];
		if !(_polygonType == "ASS") then { // "ASS" denotes assembly polygons.
		
			_mapControl drawTriangle
			[
				[
					_polygonVertices select 0,
					_polygonVertices select 1,
					_polygonVertices select 2,
					_polygonVertices select 2,
					_polygonVertices select 3,
					_polygonVertices select 0
				],
				((_polygonColor select [0,3]) + [0.4]),
				"#(rgb,1,1,1)color(1,1,1,0.5)"
			];
		
			{
				private _polygonVertex = _x;
				_mapControl drawIcon
				[
					'\a3\ui_f\data\Map\Markers\Military\dot_CA.paa',
					_polygonColor,
					_polygonVertex,
					_polygonVertexIconSize,
					_polygonVertexIconSize,
					0,
					'',
					1,
					0.03,
					'PuristaLight',
					'right'
				];
				A3C_UI_MAPICONS_POLYGON_EDGE pushBackUnique [_polygonId,[_polygonVertexIconSize,_polygonVertexIconSize],_polygonVertex] ;
			} foreach _polygonVertices;
		
			[_mapControl,_polygonVertices,0.5,_polygonColor] call A3C_ui_mapOverlay_fnc_drawPolygonFrame;
		};

		A3C_UI_MAPICONS_POLYGON_MAIN pushback [_polygonId,[_polygonCenterIconSize,_polygonCenterIconSize],(_polygonData select 0) select 0];  //-- [_polygonId,[_polygonCenterIconSize,_polygonCenterIconSize],_polyCenter,_polygonVertices,_polygonVertexIconSize]. Edge Icons have to be generated/tested in TAB_INIT.
		//~~ once ready, make extra array for edges. include _polyId, _polygonVertices and _polygonVertexIconSize for identification in TAB_INIT
	};
} foreach A3C_ALL_POLYS;
if !(A3C_Prevent_SCALING) then {
	private _markerScaleFactor = 0.05 / _mapScale;
	{
		private _markerName = _x;
		private _markerSizeCacheKey = "#markerSize_" + _markerName;
		if (markerShape _markerName == "ICON") then {
			if (isNil {missionNamespace getVariable _markerSizeCacheKey}) then {
				missionNamespace setVariable [_markerSizeCacheKey, (markerSize _markerName)];
			};
			_markerName setMarkerSizeLocal
			[
				(((missionNamespace getVariable _markerSizeCacheKey) select 0) * _markerScaleFactor) min ((missionNamespace getVariable _markerSizeCacheKey) select 0) ,
				(((missionNamespace getVariable _markerSizeCacheKey) select 1) * _markerScaleFactor) min ((missionNamespace getVariable _markerSizeCacheKey) select 1)
			];
		};
	} forEach (A3C_MARKERS + A3C_MARKERS_TEMP);
};

if (A3C_TAB_BUILDING_BOOL) then {
	for "_buildingPositionIndex" from 0 to ([A3C_TAB_BUILDING] call MCSS_fnc_getLastBuildingPosIndex) do {
		private _buildingPosition = A3C_TAB_BUILDING buildingPos _buildingPositionIndex;
		private _buildingIconData = [_buildingPosition] call A3C_ui_mapOverlay_fnc_getIconData;
		_mapControl drawIcon
		[
			'\a3\ui_f\data\map\GroupIcons\icon_selected.paa',
			(_buildingIconData select 0),
			_buildingPosition,
			(_buildingIconData select 1),
			(_buildingIconData select 1),
			0,
			(str _buildingPositionIndex),
			1,
			(_buildingIconData select 2),
			'PuristaLight',
			'right'
		];
	};
};

if (A3C_MapSel_Field_Active) then {
	private _rootPosition =
		A3C_MapSel_Field_Root;

	private _destinationPosition =
		A3C_MapSel_Field_DEST;

	private _selectionFieldCenter = [
		(
			(_rootPosition select 0)
			+ (_destinationPosition select 0)
		) / 2,
		(
			(_rootPosition select 1)
			+ (_destinationPosition select 1)
		) / 2,
		0
	];

	private _selectionFieldHalfWidth =
		abs (
			(_destinationPosition select 0)
			- (_rootPosition select 0)
		) / 2;

	private _selectionFieldHalfHeight =
		abs (
			(_destinationPosition select 1)
			- (_rootPosition select 1)
		) / 2;

	_mapControl drawRectangle [
		_selectionFieldCenter,
		_selectionFieldHalfWidth,
		_selectionFieldHalfHeight,
		0,
		[0, 0.54, 0.98, 1],
		"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
	];
};


if (count A3C_PICKUP_OBJECTS > 0) then {
	{
		private _pickupObject = _x;

		[
			_mapControl,
			_pickupObject,
			25,
			[
				A3C_UI_COLOR_BLUE,
				1
			] call A3C_ui_shared_fnc_getColorArrayWithOpacity,
			getText (
				_cfgVehicles
				>> typeOf _pickupObject
				>> "displayName"
			)
		] call A3C_ui_mapOverlay_fnc_drawIconVehicleMacro;

		A3C_UI_MAPICONS_PICKUP pushBackUnique [
			_pickupObject,
			[25, 25],
			getPosASL _pickupObject
		];
	} forEach A3C_PICKUP_OBJECTS;
};

if (A3C_Boarding_Mapselection_ACTIVE) then {
	{
		private _boardingVehicleIconData = _x;
		[
			_mapControl,
			_boardingVehicleIconData select 0,
			32.5,
			[A3C_UI_COLOR_BLUE,1] call A3C_ui_shared_fnc_getColorArrayWithOpacity,
			""
		] call A3C_ui_mapOverlay_fnc_drawIconVehicleMacro;
	} foreach A3C_UI_MAPICONS_HC_VICS;

};

// //-- MultiWaypoint - highlight selected Waypoints
// private _selectedWaypointIconSize = 35;

// {
// 	private _waypoint = _x;
// 	_mapControl drawIcon
// 	[
// 		"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
// 		[1,1,0,1],
// 		waypointPosition _waypoint,
// 		_selectedWaypointIconSize,
// 		_selectedWaypointIconSize,
// 		0,
// 		format ["%1 (%2)", groupID (_waypoint select 0), _waypoint select 1],
// 		0,
// 		0.03,
// 		'PuristaLight',
// 		'right'
// 	];

// } foreach A3C_Selection_MultiWaypoint;
