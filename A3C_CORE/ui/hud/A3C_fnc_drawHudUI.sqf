


A3C_fnc_drawHudUI = {
	disableserialization;
	_posArray = +(A3C_HUD_DRAW_POSARRAY);

	
	private _hcAllGroups = A3C_HC_allGroupsClient_Current; // [group player] + 
	//{
	//	//[_x,["lightOff", vehicle _x]] remoteExec ["action",_x]
	//	_x action ["lightOff", vehicle _x];
	//	systemchat 'wtf';
	//} foreach allunits;
	
	A3C_UI_HUDICONS_HC_GROUP = [];
	
	if (player != leader group player) exitWith {};
	{
		_x params ["_array","_color"];
		{
			drawLine3D [ASLtoATL (_x select 0),ASLtoATL  (_x select 1), _color];
		} foreach _array;
	} foreach
	[
		[MCSS_RED_LINES,[1,0,0,1]],
		[MCSS_GREEN_LINES,[0,1,0,1]],
		[MCSS_BLUE_LINES,[0,0,1,1]]
	];
	
	
	
	if (count _posArray > 0) then {
	//-- reArrang z val for aesthetic purposes
		_unit = (groupSelectedUnits player) select 0;
		
		{
			_x set [2,(_x select 2) + 1];
		} foreach _posArray;
		drawLine3D [((getPosASL _unit) select [0,2]) + [1], ((_posArray select 0) select [0,2]) + [1], [0,1,0,1]];
		{
			_position = _x;
			drawIcon3D  
			[ 
				"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa",				
				[0,0,1,1], 
				_position,  
				1,  
				1,  
				0
			];
			//-- connecting lines
			if (_foreachIndex < ((count A3C_HUD_DRAW_POSARRAY) - 1)  ) then {
				drawLine3D [_position, _posArray select (_forEachIndex + 1), [0,0,1,1]];
			};
			//-- show line to floor
			private _floorPos = (_position select [0,2]) + [0];
			drawLine3D [_position, _floorPos, [1,1,1,0.7]];
			
		} foreach _posArray;
	}; 
	//systemchat "1";	
	if ({!isNull _x} count [A3C_SUPPRESSION_INDICATOR,A3C_SQ_REM_INDICATOR,A3C_HC_REM_INDICATOR,A3C_HC_SUP_INDICATOR,A3C_OBJECTPLACER] > 0) then {
		
		
		
		_ins = lineIntersectsSurfaces
		[
			AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],
			cameraOn,
			A3C_OBJECTPLACER,
			true,
			1,
			"GEOM",
			"NONE"
		];
		if (count _ins == 0) exitWith {A3C_SUPPRESSION_INDICATOR setPosASL [0,0,0]};
		_intsPos = (_ins select 0 select 0);
		
		A3C_SNAP_OBJECT = ((_ins select 0) select 2);
		
		
		if (!isNull A3C_SUPPRESSION_INDICATOR) then {
			A3C_SUPPRESSION_INDICATOR setPosASL _intsPos;
			A3C_SUPPRESSION_INDICATOR setDir ((positionCameraToWorld [0,0,0]) getDir A3C_SUPPRESSION_INDICATOR); 
			_intsPos set [2,(_intsPos select 2) - 1];
		};
		if (!isNull A3C_SQ_REM_INDICATOR) then {
			A3C_SQ_REM_INDICATOR setPosASL _intsPos;
			A3C_SQ_REM_INDICATOR setDir ((positionCameraToWorld [0,0,0]) getDir A3C_SQ_REM_INDICATOR); 
			_intsPos set [2,(_intsPos select 2) - 1];
		};
		if (!isNull A3C_HC_REM_INDICATOR) then {
			A3C_HC_REM_INDICATOR setPosASL _intsPos;
			A3C_HC_REM_INDICATOR setDir ((positionCameraToWorld [0,0,0]) getDir A3C_HC_REM_INDICATOR); 
			_intsPos set [2,(_intsPos select 2) - 1];
		};
		if (!isNull A3C_HC_SUP_INDICATOR) then {
			A3C_HC_SUP_INDICATOR setPosASL _intsPos;
			A3C_HC_SUP_INDICATOR setDir ((positionCameraToWorld [0,0,0]) getDir A3C_HC_SUP_INDICATOR); 
			_intsPos set [2,(_intsPos select 2) - 1];
		};
		if (!isNull A3C_OBJECTPLACER) then {
			A3C_OBJECTPLACER enableSimulation false;
			private _objects = (A3C_OBJECTPLACER nearobjects (sizeOf typeOf A3C_OBJECTPLACER)) + [A3C_SNAP_OBJECT,cursorObject];
			
			{
				A3C_OBJECTPLACER disableCollisionWith _x;
			} foreach _objects;
			A3C_OBJECTPLACER enableSimulation false;
			A3C_OBJECTPLACER setPosASL _intsPos;
			A3C_OBJECTPLACER setDir A3C_OBJECTPLACER_DIR;
			if (isNull A3C_SNAP_OBJECT) then {
				A3C_OBJECTPLACER setVectorUp (_ins select 0 select 1);
			} else {
				A3C_OBJECTPLACER setVectorUp [0,0,1];
			};
			
			A3C_UI_HUD_3D_TAG_ICON_POS = ASLtoAGL _intsPos; 
		};
		
	};
	
	if !(A3C_MEDICAL_INDICATOR isEqualTo []) then {
		drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Actions\heal_ca.paa", [0,0,1,0.7],A3C_Mpos, 1, 1, 0, 'Meet Medic',0,0.05,"PuristaLight","center",true];
	};


	
	_repairedVehicles = [];
	if (A3C_CURRENT_COMMAND_LEVEL == "HIGHCOMMAND") then {
		if (count _hcAllGroups > 0) then {
			
			_vehiclePickupUnits = [player]; //-- #UNCLEAR: WHAT IS THIS??
			{
				_gp = _x;
				_leader = leader _gp;
				_leadVic = (vehicle _leader);
				
				if (isNull driver _leadVic OR {driver _leadVic in (units _gp)}) then {
					_iconType = [_gp] call A3C_main_fnc_getGroupIconType;
					_iconPos = _leadVic modelToWorldVisual [0,0,0];
					_iconPos set [2,(((boundingboxreal _leadVic) select 1) select 2) + 0.5 + (_iconPos select 2)];
					
					
					_iconSize = linearConversion [ 0, 2000, player distance2D _leadVic, 1, 0.1, true ];

					
					
					_iconText = "";
					if (_leadVic == cursorTarget) then {
						//-- draw group name for hovered groups
						_iconSize = _iconSize * 1.4;
						_iconText = groupID _gp + (if (side _gp != side player) then {format [" (%1)", side _gp]} else {""});
						drawIcon3D
						[
							"",
							[1,1,1,1],
							_iconPos,
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
						_data = _x getVariable ["A3C_isRepairing",[false,objNull]];
						if (_data select 0) then {
							_repairedVehicles pushBackUnique (_data select 1);
						};
					} foreach units _gp;

					// if (_gp == group player) then {
					// 	systemchat format ["DEBUG DRAW-HUD PLAYER GROUP WORKING, %1", _iconType];
					// };

					drawIcon3D
					[
						_iconType,
						[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity,
						_iconPos,
						_iconSize,
						_iconSize,
						0,
						"",
						0
					];
					
					if (_gp in A3C_RD_UNITS OR { {group _x != _gp} count crew _leadVic > 0 }) then {
						//_iconSize = _iconSize * 1.6;
						_frameCol = if (_gp in A3C_RD_UNITS) then {[1,1,1,1]} else {[0.5,0.2,0.6,0.1]};
						drawIcon3D 
						[
							"\a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa",
							_frameCol,
							_iconPos,
							_iconSize * 1.6,
							_iconSize * 1.6,
							0,
							"",
							1,
							0
						];
						
					};
					
					_iconPos = worldToScreen _iconPos;
					if (count _iconPos > 0) then {
						A3C_UI_HUDICONS_HC_GROUP pushBack [_gp,[_iconSize,_iconSize],_iconPos];
					};
					
					
					if (A3C_UI_HUD_ASSIGNVEHICLE && {_gp in A3C_RD_UNITS}) then {
						
						if ({!isNull assignedVehicle _x} count units _gp == 0) then {
							_vehiclePickupUnits pushbackUnique _leader;
							
						};
					};
				};
			} foreach (_hcAllGroups - [group player]);

			//-- draw player group icon with no functionality
			// _iconSize = linearConversion [ 0, 2000, player distance2D (vehicle leader (group player)), 1, 0.1, true ];
			// hintsilent str _iconSize;
			private _leadVicPL = vehicle leader (group player);
			private _iconPosPL = _leadVicPL modelToWorldVisual [0,0,0];
			_iconPosPL set [2,(((boundingboxreal _leadVicPL) select 1) select 2) + 0.5 + (_iconPosPL select 2)];
			drawIcon3D
			[
				[group player] call A3C_main_fnc_getGroupIconType,
				[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity,
				_iconPosPL, //_iconPos,
				1, //_iconSize,
				1, //_iconSize,
				0,
				"",
				0
			];


			

			A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS = [];
			if (A3C_UI_HUD_ASSIGNVEHICLE) then {
				A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS = A3C_UI_MAPICONS_HC_VICS apply {_x select 0}; //-- #TODO Clean up these varnames!!
				// {
				// 	_entities = (position _x) nearentities [["CAR","TANK","AIR","SHIP","MOTORCYCLE","STATICWEAPON"],100];
					
				// 	{
				// 		_v = _x;
				// 		if (side _v in [civilian, side cameraOn]) then {
				// 			if ({(_v emptypositions _x) > 0} count ["driver","gunner","commander","cargo"] > 0) then {
				// 				A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS pushBackUnique _v;
				// 			};
				// 		};
				// 	} foreach _entities;
				// } foreach _vehiclePickupUnits;

				{
					_iconPos = _x modelToWorldVisual [0,0,0];
					//_iconPos set [2,((((boundingboxreal _x) select 1) select 2) / 2) + (_iconPos select 2)];
					_iconSize = linearConversion [ 0, 800, player distance2D _x, 1, 0.1, true ];
					_iconType = (gettext (configfile >> "CfgVehicles" >> typeof _x >> "Icon")); //"\a3\ui_f\data\IGUI\Cfg\Cursors\board_ca.paa"; 
					if (_x == cursorTarget) then {
						_iconSize = _iconSize * 1.4;
					};
					
					//-- draw hexagon background
					drawIcon3D
					[
						"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
						[1,1,1,0.6],
						_iconPos, // vectorAdd [0,0,-0.3],
						_iconSize * 1.5,
						_iconSize * 1.5,
						0,
						'',
						1,
						0
					];
					drawIcon3D
					[
						_iconType,
						[A3C_UI_COLOR_BLUE,0.6] call A3C_UI_fnc_setOpacity, //[0.8,0.6,0,0.6],
						_iconPos,
						_iconSize,
						_iconSize,
						0,
						'',
						1,
						0
					];
				} foreach A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS;
			};
			
		};
		
	};

	{
		_repairData = _x getVariable ["A3C_isBeingRepaired",[false,0,[]]];

		if (_repairData select 0) then {
			_repairProgress = "";
			_progressCol = [0,1,0,0.6];
			_vehicleHealth = _repairData select 1;
			_barPos = _x modelToWorldVisual [0,0,0];
			_barPos set [2,(((boundingboxreal _x) select 1) select 2) + 0.5 + (_barPos select 2)];
			//if (_vehicleHealth == 1) then {
			//	_repairProgress = "\a3c_ui\infoAdd\icon_3D_progress_10.paa";
				
			//} else {
				_integer = (_vehicleHealth max 0.1) * 10; //-- to get the number for the progressbar
				_repairProgress = format ["\a3c_ui\infoAdd\icon_3D_progress_%1.paa",_integer];
				_progressCol = switch (true) do {
					case (_integer <= 3) : { [A3C_UI_COLOR_RED,0.6] call A3C_UI_fnc_setOpacity};
					case (_integer < 7) : { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_fnc_setOpacity};
					default {if (canMove _x) then {[0,1,0,0.6]} else { [A3C_UI_COLOR_YELLOW,0.6] call A3C_UI_fnc_setOpacity}};
				};
			//};
			//-- draw progress bar 
			_iconSize = linearConversion [ 0, 2000, player distance2D _x, 1, 0.1, true ];
			drawIcon3D
			[
				_repairProgress,
				_progressCol,
				_barPos vectorAdd [0,0,0.3],
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
	} foreach _repairedVehicles;



	//-- draw custom cursorTarget if player is in a vehicle
	if (count _hcAllGroups > 0 && {!isNull objectparent player} ) then { //&&  {player == driver vehicle player}
		_cursorTarget = [] call MCSS_fnc_getCursortargetCustom;
		if (!isNull _cursorTarget && { A3C_CURRENT_COMMAND_LEVEL == 'HIGHCOMMAND' && {group driver _cursorTarget in _hcAllGroups && {(_cursorTarget canVehicleCargo (vehicle player)) select 0}}}) then {
			_iconPos = _cursorTarget modelToWorldVisual [0,0,0];
			drawIcon3D
			[
				"\a3\ui_f\data\IGUI\Cfg\Cursors\board_ca.paa",
				[1,1,1,0.6],
				_iconPos,
				1,
				1,
				0,
				'',
				1,
				0
			];
		};
	};
	
	
	
	
	
	


	if (count A3C_UI_squadPlacement_unitGhosts > 0) then {
		private _ignorObj2 = if (cursortarget in A3C_UI_squadPlacement_unitGhosts) then {cursorTarget} else {A3C_UI_squadPlacement_unitGhosts select 0};
		private _intersects = false;

		{
			private _camPos = AGLToASL (positionCameraToWorld [0,0,0]);
			private _arrowPos = getPosASL _x;
			private _cond =  false;
			if !(_intersects) then { //-- attempt to prevent LOS checks when condition is already fulfilled
				_cond = (lineIntersects [_camPos, _arrowPos, vehicle player, _x]) OR 
				{
					terrainIntersect [getPos player, getPos chopper]
				};
			};
			if (!(_intersects) && {_cond}) then {
				_intersects = true;
			};
			_x disableCollisionWith (vehicle cameraOn);
		} foreach A3C_UI_squadPlacement_unitGhosts;
		{
			private _data = _x getvariable ['A3C_HUD_DATA', [objNull,-1] ];
			_data params ["_arrow"];

			if (!isNull _arrow) then {
				_minSize = 0.2;
				_furthestDistance = 300;
				
				_iconSize = linearConversion [ 0, _furthestDistance, player distance2D _arrow, 1, _minSize, true ];
				_minTextSize = 0.025;
				_textSize = linearConversion [ 0, _furthestDistance, player distance2D _arrow, 0.05, _minTextSize, true ];
				
				_minOpacity = 1;
				_opacity = linearConversion [ 0, 300, (player distance2d (A3C_UI_squadPlacement_unitGhosts select 0)) - 30, 0, 0.7, true ];
				if (_opacity > 0) then {_opacity = _opacity max 0.2};
				
				//_objectCollision = lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],vehicle player,(A3C_UI_squadPlacement_unitGhosts select 0),true,1,"GEOM","NONE"];	
				
				_atlPos = getPosATL _arrow;
				_addHeight = 0;
				
				if (_intersects) then {
					_opacity = 0.7;
					//_addHeight = 0.2;
				};
				
				//hintSilent str [_iconSize,_textSize];
				_textPos = ((getPosATL _arrow) select [0,2]) + [((getPosATL _arrow) select 2) - 0.3];
				
				//-- draw Unit Number
				drawIcon3D
				[
					'',
					[1,1,1,0.6],
					_textPos,
					0,
					0,
					0,
					str (_x getvariable 'A3C_FORMATION_INDEX'),
					1,
					_textSize
				];
				private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
				_color = switch (_assignedTeam) do {
					case ("RED") : {[A3C_UI_COLOR_RED,_opacity] call A3C_UI_fnc_setOpacity};
					case ("GREEN") : {[[0,1,0,1],_opacity] call A3C_UI_fnc_setOpacity};
					case ("BLUE") : {[A3C_UI_COLOR_BLUE,_opacity] call A3C_UI_fnc_setOpacity};
					case ("YELLOW") : {[A3C_UI_COLOR_YELLOW,_opacity] call A3C_UI_fnc_setOpacity};
					default {[1,1,1,_opacity]}
				};
				
				
				_atlPos set [2,(_atlPos select 2) + _addHeight];
				
				drawIcon3D
				[
					'\a3\ui_f\data\Map\GroupIcons\badge_simple.paa',
					_color,
					_atlPos,
					_iconSize,
					_iconSize,
					0, //-- dir relates to screen, not to world. needs same function that FORMDIR indicator uses
					'',
					1,
					0.05
				];
			};
			

		} foreach A3C_UI_squadPlacement_units;
	};
	
	
	
	if (typeName A3C_UI_HUD_3D_TAG_ICON_TYPE == "STRING") then {
		if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "") then {
			//systemchat str time;
			if (A3C_UI_HUD_3D_TAG_reposition) then {
				
				_ins = lineIntersectsSurfaces
				[
					AGLToASL positionCameraToWorld [0,0,0],AGLToASL positionCameraToWorld [0,0,viewDistance],
					cameraOn,
					A3C_OBJECTPLACER, //-- this may return objNull, no problem
					true,
					1,
					"GEOM",
					"NONE"
				];
				if (count _ins == 0) then {
					A3C_UI_HUD_3D_TAG_ICON_POS = screenToWorld [0.5,0.5];
				} else {
				//	A3C_UI_RAPPEL_HELIPAD setVectorUp (_ins select 0 select 1);
					A3C_UI_HUD_3D_TAG_ICON_POS = ASLtoAGL((_ins select 0) select 0);

					if ({_x in toLower A3C_UI_HUD_3D_TAG_ICON_TYPE} count ["movepos","building"] > 0) then {
						private _eligibleForBuildingSearch = (count A3C_RD_UNITS == 1) && {{!isNull objectParent _x && {(assignedVehicleRole _x) select 0 != "cargo"}} count (units (A3C_RD_UNITS select 0)) == 0};
						
						if (_eligibleForBuildingSearch && {cursorTarget isKindOf "HOUSE" && {([cursortarget] call MCSS_fnc_getLastBuildingPosIndex) > 0}}) then {
							A3C_UI_HUD_3D_TAG_ICON_TYPE = "a3c_ui\markers\building.paa";
							A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
						} else {
							A3C_UI_HUD_3D_TAG_ICON_TYPE = "\a3c_ui\hud\icon_HUD_movePos.paa";
							A3C_UI_HUD_3D_TAG_ICON_COL = [A3C_UI_COLOR_BLUE,0.5] call A3C_UI_fnc_setOpacity;
						};
					};
				};
				//if (!isNil 'A3C_UI_RAPPEL_HELIPAD' && {!isNull A3C_UI_RAPPEL_HELIPAD}) then {
				//	A3C_UI_RAPPEL_HELIPAD setPosASL (AGLtoASL A3C_UI_HUD_3D_TAG_ICON_POS);	
				//};
				
				//_minSize = 0.6;
				//_furthestDistance = 300;
				_dist = (player distance2D (ASLtoAGL A3C_UI_HUD_3D_TAG_ICON_POS));
				//A3C_UI_HUD_3D_TAG_ICON_SIZE = linearConversion [0, _furthestDistance, _dist, 4, _minSize, true ];
				
				_minSize = 0.25;
				_furthestDistance = 500;
				
				A3C_UI_HUD_3D_TAG_ICON_SIZE = (linearConversion [ 0, _furthestDistance, _dist, 1.1, _minSize, true ]) *2;	
				//hintsilent str [player distance2D (ASLtoAGL A3C_UI_HUD_3D_TAG_ICON_POS),A3C_UI_HUD_3D_TAG_ICON_SIZE];
			};
			//systemchat str [A3C_UI_HUD_3D_TAG_ICON_TYPE,A3C_UI_HUD_3D_TAG_ICON_POS,A3C_UI_HUD_3D_TAG_ICON_COL,A3C_UI_HUD_3D_TAG_ICON_SIZE];
			//player setpos A3C_UI_HUD_3D_TAG_ICON_POS;
			drawIcon3D 
			[
				A3C_UI_HUD_3D_TAG_ICON_TYPE,
				A3C_UI_HUD_3D_TAG_ICON_COL,
				A3C_UI_HUD_3D_TAG_ICON_POS,
				A3C_UI_HUD_3D_TAG_ICON_SIZE,
				A3C_UI_HUD_3D_TAG_ICON_SIZE,
				0, //-- dir relates to screen, not to world. needs same function that FORMDIR indicator uses
				'',
				1,
				0.05
			];

			if (A3C_UI_HUD_3D_TAG_ICON_MOD != "NONE") then {
				private _modIcon = if (A3C_UI_HUD_3D_TAG_ICON_MOD == "ON") then {
					"\a3c_ui\markers\icon_Rad_3D_Modifier_ON.paa"
				} else {
					"\a3c_ui\markers\icon_Rad_3D_Modifier_OFF.paa"
				};
				drawIcon3D
				[
					_modIcon,
					[1,1,1,1],
					A3C_UI_HUD_3D_TAG_ICON_POS,
					A3C_UI_HUD_3D_TAG_ICON_SIZE * 1.7,
					A3C_UI_HUD_3D_TAG_ICON_SIZE * 1.7,
					0, //-- dir relates to screen, not to world. needs same function that FORMDIR indicator uses
					'',
					1,
					0.05
				];
			};
		};
	};		
};



if (!isNil 'A3C_EVH_DRAW_HUD') then {removeMissionEventHandler ["Draw3d",A3C_EVH_DRAW_HUD];};
A3C_EVH_DRAW_HUD = addMissionEventHandler
[
	"Draw3D",
	{
		[] call A3C_fnc_drawHudUI;
	} 
];