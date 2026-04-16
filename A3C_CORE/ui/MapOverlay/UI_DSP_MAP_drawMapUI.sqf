
A3C_UI_MAPICONS_POLYGON_MAIN = [];
A3C_UI_MAPICONS_POLYGON_EDGE = [];
A3C_UI_MAPICONS_SQUAD = [];
A3C_UI_MAPICONS_SQ_WPS_WPDOTS = [];
A3C_UI_MAPICONS_SQ_WPS_LOOKDIR = [];
//A3C_UI_MAPICONS_SQ_WPS_MAIN_IDS_HANDLED = [];
A3C_UI_MAPICONS_HC_GROUP = [];
A3C_UI_MAPICONS_HC_WPS = [];
A3C_UI_MAPICONS_HC_TRACKER = [];
A3C_UI_MAPICONS_PICKUP = [];
A3C_UI_MAPICONS_DEMO_VICS = [];
A3C_UI_MAPICONS_BOARDING_DRAW = [];


A3C_UI_MAPICONS_HC_CONES = [];


//A3C_UI_MAPICONS_HC_VICS = [];

//A3C_UI_MAPICONS_HC_VICS = []; // defined in button function


MAP_UI_fnc_drawMapUI = {
	disableserialization;
	
	if ( (A3C_OPACITY == 0) OR {!visibleMap} ) exitWith {};
	if (!isNil 'A3C_disableMapPlanning' && {A3C_disableMapPlanning}) exitWith {};
	if !(player == leader group player) exitWith {};
	private _shift = 42 in A3C_DOWNKEYS;

	
	private ["_unitIcon","_plotTemp","_plotMain","_data","_isHighCommand","_allGroupsHC","_color","_syncWPS"];

	_plotTemp = [];
	_plotMain = [];
	_isHighCommand = ({typeof _x in ["HighCommand","AdvancedAICommand_Commanders"]} count (synchronizedObjects player) > 0) && {hcShownBar};
	
	_allGroupsHC = A3C_HC_getAllGroups_Player_Current;
	if !(group player in _allGroupsHC) then {
		_allGroupsHC = [group player] + _allGroupsHC; //-- add player group (player does not carry tablet item, but we need to show it in UI
	};


	/*
	_p1 = screenToWorld [safeZoneX,safeZoneY];
	_p2 = screenToWorld [safeZoneX + safeZoneW,safeZoneY];
	_pd = _p1 distance2d _p2;
	(_this select 0) drawRectangle [
		(findDisplay 12 displayCtrl 51) posscreentoworld [0.5,0.5],
		_pd,
		_pd,
		0,
		[1,1,1,1],
		"#(rgb,8,8,3)color(0,1,0,1)"
		//"#(rgb,8,8,3)color(0.13,0.13,0.13,1)"
	];
	*/

	//systemchat str _this;
	//if (visibleMap && {isnull (findDisplay 100020)}) exitWith {};
	//if (A3C_OPACITY == 0) exitwith {};
	private _ctrlMapScale = ctrlMapScale (_this select 0);

	A3C_HC_WP_SYNC_ARRAYS = [];

	A3C_UI_MAPICONS_POLYGON_MAIN = [];
	A3C_UI_MAPICONS_POLYGON_EDGE = [];
	A3C_UI_MAPICONS_SQUAD = [];
	A3C_UI_MAPICONS_SQ_WPS_WPDOTS = [];
	A3C_UI_MAPICONS_SQ_WPS_LOOKDIR = [];
	//A3C_UI_MAPICONS_SQ_WPS_MAIN_IDS_HANDLED = [];
	A3C_UI_MAPICONS_HC_GROUP = [];
	A3C_UI_MAPICONS_HC_WPS = [];
	A3C_UI_MAPICONS_HC_TRACKER = [];
	A3C_UI_MAPICONS_PICKUP = [];
	A3C_UI_MAPICONS_DEMO_VICS = [];
	A3C_UI_MAPICONS_BOARDING_DRAW = [];
	A3C_UI_MAPICONS_HC_CONES = [];

	private _zoomDistanceFac = linearConversion [ 0.001, 0.05, _ctrlMapScale, 0, 1, true ];


	private _doFindIconGroup = true;
		
	//hintsilent str _gpIcons; //_zoomDistanceFac;

	////////////////////////////////////////////////////
	//-- PLANNING STAGE: DIRECTION ARROW OR LOOP-LINE //
	////////////////////////////////////////////////////

	if (!isNil 'A3C_restrictMapPlanning' && {A3C_restrictMapPlanning && { {["A3C_Terminal", _x] call BIS_fnc_instring} count ((Items player) + (assignedItems player)) == 0 }}) exitWith {};
	if (A3C_BOOL_DRAGLINE && {count A3C_DRAGPOS > 0}) then {
		switch (A3C_CONNECTING_MODE) do {
			case ("LOOKDIR") : {
				if !((A3C_TEMP_ACTION select 0) in ["SUPPRESSION"]) then { //"GRENADE",
					(_this select 0) drawArrow [A3C_CLICKPOS_ORIG, A3C_DRAGPOS, [0,0.54,0.98,1]];
				};
			};
			case ("LOOP") : {
				(_this select 0) drawline [A3C_LOOPSYNC_START select 1, A3C_DRAGPOS, [0,0.74,0.14,1]];
			};
			case ("SYNC") : {
				//-- obsolete. change LOOP to LOOPSYNC
			};
			case ("HCBOARD") : {
				{
					(_this select 0) drawArrow [leader _x,A3C_DRAGPOS, [0,0,1,1]];
				} foreach A3C_HC_VEHICLEBOARD_GROUPS;

				
			};
			case ("HCSYNC") : {
				(_this select 0) drawArrow [A3C_CLICKPOS_ORIG,A3C_DRAGPOS, [1,1,0,1]];
			};
		};
	};

	////////////////////////////////////////////
	//-- PLANNING STAGE: CONTEXT PICKUP ICONS //
	////////////////////////////////////////////


	//-- boarding HC - units: Select Vehicle icons
	_syncWPS = [];
	
	//-- Attach Explosiive: Vehicle Pickup Icons
	if (A3C_HC_DETONATION_BOOL) then {
		_demolition_snapObjects = [leader A3C_HC_ACTIVEGROUP,waypointPosition [A3C_HC_ACTIVEGROUP,A3C_HC_ACTIVE_IND],50,true] call MCSS_fnc_nearDetonationTargets;
		if !(_demolition_snapObjects isEqualTo []) then {
			{
				[
					_this select 0,
					_x,
					25,
					[A3C_UI_COLOR_RED,1] call A3C_UI_Color_setOpacity,
					(gettext(configFile >> "CfgVehicles" >> typeof _x >> "displayName"))
				] call A3C_UI_MAP_DRAW_MACRO_VEHICON;		
				A3C_UI_MAPICONS_DEMO_VICS pushBack [_x,[25,25],getpos _x];
			} foreach _demolition_snapObjects;
		} else {
			A3C_HC_DETONATION_BOOL = false;
		};
		//systemchat str _demolition_snapObjects;
		
	};


	//-- DRAG PATH: Vehicle Pickup Icons
	if (count A3C_MAP_DRAGPLANNING_POSITIONS > 0) then {
		if (_shift) then {
			_targetUnits = [];
			if (typeName A3C_SQ_CLICKED_UNIT == "GROUP") then {
				_targetUnits = [leader A3C_SQ_CLICKED_UNIT];
			} else {
				_targetUnits = +(A3C_SELECTED_UNITS);
			};
			// systemchat str A3C_DRAGPOS;
			_entities = A3C_DRAGPOS nearentities [["CAR","TANK","AIR","SHIP","MOTORCYCLE"],220];
			{
				_v = _x;
				if ({( ((side _x) getfriend (side player)) < 0.6)} count crew _v > 0) then {
					//_entities = _entities - [_x];
				};
				if ({(_v emptypositions _x) > 0} count ["driver","gunner","commander","cargo"] == 0) then {
					_entities = _entities - [_x];
				};
				_refPos = if (surfaceIsWater getPos _v) then {getPosASL _v} else {getPosATL _v};
				if ({_x > 2} count [speed _x, _refPos select 2] > 0) then {
					_entities = _entities - [_x];
				};
				if ({_x knowsAbout _v > 0.5} count _targetUnits == 0) then {
					_entities = _entities - [_x];
				};
			} foreach _entities;
			_sz = 35;
			{
				//systemchat str (getpos _x);
				_this select 0 drawIcon
				[
					gettext (configfile >> "CfgVehicles" >> typeOf _x >> "picture"),
					[1,1,0,1],
					getPos _x,
					_sz,
					_sz,
					0,
					"11",
					0,
					0.03,
					'PuristaLight',
					'right'
				];
				A3C_UI_MAPICONS_BOARDING_DRAW pushBack [_x,[_sz,_sz],getPos _x,nil];
			} foreach _entities;


		};
	};

	////////////////////////////
	//-- UI-ICONS SQUAD LEVEL //
	////////////////////////////


	//- PLANNING DATA: WAYPOINT LINES
	{
		private ["_unit","_i","_isLoop","_loopStart"];
		_unit = _x;
		_i = _foreachIndex;
		_isLoop = false;
		_loopStart = [];
		private _vehicle = vehicle _x;
		private _driver = driver _vehicle;
		_plotMain = _unit getvariable "A3C_PLOT";
		_plotTemp = _unit getvariable "A3C_PLOT_TEMP";

		_icon = "";
		_s1 = 0;
		_s2 = 0;
		_nStr = "";
		_color = [1,1,1,1];


		if (_unit == player) then {
			//~~ #?
		} else {
			{
				private ["_varInd","_data"];
				_varInd = _foreachIndex;
				_data = _x;
				{
					_x params ["_wpPositions","_wpMarkers","_wpAction","_wpCondition","_wpStances","_wpSyncData","_wpCompleted","_wpCombatMode","_wpSpeed","_wpFlyInHeight","_wpLoopValue","_wpRadius"];
					private ["_root","_color","_index","_draw","_syncData","_wPos","_wpFiringMode"];

					_root = []; //-- default: empty WP position.
					_index = _forEachIndex;
					_color = if (_varInd == 0) then {[A3C_UI_COLOR_BLACK,1] call A3C_UI_Color_setOpacity} else {[A3C_UI_COLOR_GREY,1] call A3C_UI_Color_setOpacity}; //-- default color: ColorBlufor   [0,0.3,0.6,A3C_OPACITY] //
					_wpFiringMode = if ((_wpAction select 0) in ["GRENADE","SUPPRESSION"]) then {2} else {0}; //~~ change this value here and in smokeless_wp
					_wPos = _wpPositions select 0;
					_mainMarkerID = _wpMarkers select 0;
					_subMarkerID = _wpMarkers select 1;
					_dirMarkerID = _wpMarkers select 1;
					_opacity = if (_varInd == 0) then {if (_unit == driver vehicle _unit) then {0.6} else {0.3}} else {0.3};
					_opacity = _opacity min A3C_OPACITY;




					_draw = true;
					if (_varInd == 0) then {
						//-- active orders: only draw line for uncompleted wp's
						if ((_index + 1) >= (_unit getvariable "A3C_CURRENTWAYPOINT_INDEX")) then {

							if ((_index + 1) == (_unit getvariable "A3C_CURRENTWAYPOINT_INDEX")) then {
								//-- current WP: root on unit, color green
								_color = [0.01,0.72,0.32,1];
								_root = (getPosASL _unit);
							} else {
								//-- followup wp. find last smokeless wp.
								_root = [_unit,1,(_index)] call A3C_FIND_SMOKELESS_WP;
								//systemchat "oi";
							};
						} else {
							_draw = false;
						};
					} else {
						_tVar = 0;
						_copyIndex = +_index;
						if (count _plotMain > 0) then {
							//systemchat str _index;
							if (_index == 0) then {
								_tVar = 1;
								_copyIndex = (count _plotMain);
								//systemchat "uh1";
							} else {

								_root = [_unit,0,(_copyIndex)] call A3C_FIND_SMOKELESS_WP;
								//systemchat "heyyy";
								if ((_root distance2d (position _unit)) < 1) then {
									_tVar = 1;
									_copyIndex = (count _plotMain);
								};
							};
						};
						_root = [_unit,_tVar,(_copyIndex)] call A3C_FIND_SMOKELESS_WP;

					};
					if ( _wpFiringMode >= 2) then {
						//-- WP has Smoke-Settings: change lineColor to Yellow
						_color = [1,1,0,1];
					};
					_color set [3,_opacity];
					if (_draw) then {

						if (_ctrlMapScale > 0.04) then {
							(_this select 0) drawline [_root,_wPos, _color];
						} else {
							//-- draw THICC wp-lines
							[_this select 0,_root,_wPos,0.5,_color] call A3C_UI_MAP_DRAW_THICC_LINE;
						};
						

						_syncData = (_x select 5);
						{
							private ["_syncIndex","_add"];
							_syncIndex = (_x select 0);
							_add = true;
							if !(_syncIndex == 0) then {
								{
									if (_syncIndex == (_x select 0)) then {
										_add = false;
										(_x select 1) pushBackUnique _wPos;
									};
								} foreach _syncWPS;

								if (_add) then {
									_syncWPS pushBack [_syncIndex,[_wPos]];
								};
							};
						} foreach _syncData; //~~ change to _wpSyncData

						//-- draw waypoint dot
						_lookingDir = (_wpPositions select 0) getDir (_wpPositions select 1);
						_isMain = _subMarkerID == "";
						_color = if (_isMain) then {[0,0,0,_opacity]} else {[0.7,0,0,_opacity]};
						_szFact = if (_isMain) then {0.08} else {0.025};
						_szMax = if (_isMain) then {45} else {40};
						_szMin = 20; //if (_isMain) then {40} else {20};
						_markerID = if (_isMain) then {_mainMarkerID} else {_subMarkerID};
						_sz = (_szFact * 10^(abs log _ctrlMapScale)) min _szMax;
						_sz = _sz max _szMin;
						_txt = "";
						_wpIcon = "\a3\ui_f\data\Map\Markers\Military\box_ca.paa";

						if (_isMain) then {
							switch (_wpAction select 0) do {
								case ("STATIC") : {
									_wpIcon = "\a3c_ui\markers\A3C_Marker_PackStaticWeapon.paa";
									if ((_wpAction select 1) select 0 == "ASSEMBLE") then {
										_txt = format ["Assemble %1",(gettext (configfile >> "CfgVehicles" >> (_wpAction select 1) select 1 >> "displayname"))];
									} else {
										_txt = format ["Disassemble %1",(gettext (configfile >> "CfgVehicles" >> typeOf ((_wpAction select 1) select 1) >> "displayname"))];
									};
									_color = [1,1,1,_opacity];
								};
								case ("SLINGLOAD") : {
									if (typeName (_wpAction select 1) == "STRING") then {
										_wpicon = "\a3c_ui\markers\A3C_Marker_SlingDrop.paa";
										_txt = "Drop Sling Cargo";
									} else {
										_wpicon = "\a3c_ui\markers\A3C_Marker_SlingLoad.paa";
										_txt = format ["Sling Load %1",(gettext (configfile >> "CfgVehicles" >> typeOf (_wpAction select 1)>> "displayname"))];
									};

									_color = [1,1,1,_opacity];
								};
								case ("PARADROP") : {
									_wpicon = "\a3c_ui\markers\A3C_Marker_Paradrop.paa";
									_color = [1,1,1,_opacity];
								};
								case ("CTRL_DET") : {
									_wpicon = "\a3c_ui\markers\A3C_Marker_Detonation.paa";
									_color = [1,1,1,_opacity];
									(_wpAction select 1) params ["_targetVehicle","_ammoType"];
									if ( !isNull _targetVehicle) then {
										_txt = format
										[
											"Destroy %1 (%2)",
											gettext (configfile >> "CfgVehicles" >> typeOf _targetVehicle >> "displayName"),
											if (_ammoType == "") then {"undecided"} else {getText (configfile >> "CfgMagazines" >> _ammoType >> "displayName")}
										]
									} else {
										_txt = format
										[
											"Place %1",
											if (_ammoType == "") then {"Explosive"} else {getText (configfile >> "CfgMagazines" >> _ammoType >> "displayName")}
										]
									};
								};
								case ("GRENADE") : {
									_opacity = 0.5 min A3C_OPACITY;
									_wpicon = (gettext (configfile >> "CfgMagazines" >> _wpAction select 1 >> "picture"));
									_txt = (gettext (configfile >> "CfgMagazines" >> _wpAction select 1 >> "displayname"));
									_color = [1,1,1,_opacity];
								};
								case ("LANDING") : {
									switch (_wpAction select 1) do {
										case ("RAPPEL") : {
											_wpicon = "\a3c_ui\markers\A3C_Marker_Rappel.paa";
											_color = [1,1,1,_opacity];
										};
										case ("PICKUP") : {
											_wpicon = "\a3c_ui\markers\getin_ca.paa";
											_color = [1,1,1,_opacity];
										};
										case ("DROPOFF") : {
											_wpicon = "\a3c_ui\markers\getout_ca.paa";
											_color = [1,1,1,_opacity];
										};
										case ("LANDFINAL") : {
											_wpicon = "\a3c_ui\markers\helipad.paa";
											_color = [1,1,1,_opacity];
										};
									};

								};
							};



						};

						if !(_wpAction select 0 in ["SUPPRESSION"]) then { //,
							//-- draw wp-lookingdir cone
							if !(_wpAction select 0 in ["GRENADE","LANDING","SLINGLOAD","CTRL_DET"]) then {
								if !(A3C_TEMP_WP_ID_MAIN == _wpMarkers select 0) then {
										_castSize = if (_isMain) then {10} else {5};
										_area =
										[
											_wPos,
											_wPos getPos [_castSize,_lookingdir - 25],
											_wPos getPos [_castSize,_lookingdir + 25]
										];
										_this select 0 drawTriangle
										[
											_area,
											[0,1,1,_opacity],
											"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
										];
										A3C_UI_MAPICONS_SQ_WPS_LOOKDIR pushBack [_unit,[_sz,_sz],_area,_markerID];
									//};
								};
							};

							//-- draw wp icon
							_this select 0 drawIcon
							[
								_wpIcon,
								_color,
								_wPos,
								_sz,
								_sz,
								0,
								_txt,
								0,
								0.03,
								'PuristaLight',
								'right'
							];
							A3C_UI_MAPICONS_SQ_WPS_WPDOTS pushBack [_unit,[_sz,_sz],_wPos,_wpMarkers];




						};
						if !("NONE" in _wpCondition) then {
							_opacity = (_ctrlMapScale min 0.02) min A3C_OPACITY;
							_opacity = _opacity / 0.02;
							_opacity = 1 - _opacity;
							_dist = (_opacity * 3) min 1;

							_condIconcolor = [1,1,1,_opacity];
							_condIcon = "";
							switch (_wpCondition select 0) do {
								case ("GOCODE") : {
									//systemchat format ["\a3c_ui\markers\icon_GoCode_%1.paa",(_wpCondition select 1)];
									_condIcon = format ["\a3c_ui\markers\icon_GoCode_%1.paa",(_wpCondition select 1)];
									//systemchat format ["\a3c_ui\markers\icon_GoCode_%1.paa",(_wpCondition select 1)];

								};
								case ("TIMEOUT") : {
									_condIcon = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\watch_ca.paa";
									_condIconcolor = [0,0,0,_opacity];
								};
								//-- draw sq-wp condition icon
							};
							_this select 0 drawIcon
							[
								_condIcon,
								_condIconcolor,
								_wPos getPos [_dist ,0],
								_sz * 0.5,
								_sz * 0.5,
								0,
								'',
								0,
								0.03,
								'PuristaLight',
								'right'
							];
						};



					};
					//-- Loop checks: run on every waypoint regardless if finished
					//systemchat str _wpLoopValue;
					if ( _wpLoopValue < -1) then {
						//--Loop
						_isLoop = true;
						_loopStart = (_wpPositions select 0);
					};
					if (_isLoop) then {

						if ((_x select 10) > -1) then {
							//-- loop end
							_isLoop = false;
							//-- create line from (_wpPositions select 0) to _loopStart
							(_this select 0) drawline [(_wpPositions select 0),_loopStart, [0.19,0.63,0.95,A3C_OPACITY]];
						} else {
							//-- wp within Loop: draw line from (_wpPositions select 0) to ((_plotMain select (_forEachIndex + 1)) select 0)
							(_this select 0) drawline [(_wpPositions select 0),((_data select (_index + 1)) select 0) select 0, [0.19,0.63,0.95,A3C_OPACITY]];
						};
					};
				} foreach _x;
			} foreach [_plotMain,_plotTemp];
			////
			_hold = _x getvariable ["A3C_HOLD",false];
			_op = if (_hold) then {0.3} else {0.4};
			_op = _op min A3C_OPACITY;
			private _assignedTeam = if (player == cameraOn) then {assignedTeam _x} else {_x getVariable ["A3C_ASSIGNEDTEAM","MAIN"]};
			private _unitColor = switch (_assignedTeam) do {
				case ("RED") :{if (_hold) then {[1,0.55,0.52,_op]} else {[A3C_UI_COLOR_RED,_op] call A3C_UI_Color_setOpacity} };
				case ("GREEN") :{if (_hold) then {[0.6,1,0.5,_op]} else {[0,1,0,_op]}};
				case ("BLUE") :{if (_hold) then {[0.5,0.67,0.98,_op]} else {[A3C_UI_COLOR_BLUE,_op] call A3C_UI_Color_setOpacity} };
				case ("YELLOW") :{if (_hold) then {[0.98,0.95,0.63,_op]} else {[A3C_UI_COLOR_YELLOW,_op] call A3C_UI_Color_setOpacity} };
				case ("MAIN") :{if (_hold) then {[0.52,0.52,0.52,_op]} else {[0.8,0.8,0.8,_op]}};
				default {[0.8,0.8,0.8,_op]};
			};
			//_unitColor = [0.8,0.8,0.8,_op];
			if (isnull objectParent _x) then {
				_icon = "A3C_Objects\images\icon_UnitHexagon.paa"; //"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa"; //
				_s1 = 25;
				_s2 = 25;
			} else {
				//systemchat str "0";
				
				if (_x == _driver) then {
					_icon = (gettext(configfile >> "CfgVehicles" >> (typeof _vehicle) >> "Icon")); //"A3C_Objects\images\icon_UnitVehicle.paa";
					if ( (getPosATL _vehicle) select 2 < 1 &&  {count ([_vehicle] call MCSS_fnc_getNearCargoLoadObjects) > 0}  ) then {
						_s1 = 35;
						_s2 = 35;
						//systemchat str "1";
					} else {
						_s1 = 20;
						_s2 = 20;
						//systemchat str "2";

					};
					//-- draw hexagon background
					_this select 0 drawIcon
					[
						"A3C_UI\markers\icon_marker_vehicleHexagon.paa",
						if (_assignedTeam == "MAIN") then {[0.7,0.7,0.7,_op]} else {_unitColor},
						getPos _x,
						_s1 * 1.5,
						_s2 * 1.5,
						getDir _x,
						"",
						1,
						0.03,
						'PuristaLight',
						'center'
					];
					_unitColor = [1,1,1,0.9 min A3C_OPACITY];
					//_unitColor = [1,1,1,1]; //-- reset unitColor to white for vehicle drivers as the additional hex already has that color
				} else {
					_icon = "\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";
					_s1 = 15;
					_s2 = 15;
				};
				


			};
			
			if (_x == player) then {_op = 1};
			

			_color = if (!isNil '_color') then {_color} else {[0.8,0.8,0.8,_op]};



			_unitIcon = _this select 0 drawIcon
			[
				_icon,
				_unitColor,
				getPos _x,
				_s1,
				_s2,
				getDir _x,
				"",
				1,
				0.03,
				'PuristaLight',
				'center'
			];
			A3C_UI_MAPICONS_SQUAD pushbackUnique [_x,[_s1,_s1], getPosASL _x];

			_nStr = str (_x getvariable 'A3C_FORMATION_INDEX');
			_unitIconNumber = _this select 0 drawIcon
			[
				"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
				(_unitColor select [0,3]) + [A3C_OPACITY],
				getPos _x,
				0,
				0,
				getDir _x,
				"   " + _nStr,
				1,
				0.03,
				if (_x == player) then {'PuristaBold'} else {'PuristaLight'},
				if (_x == player) then {'center'} else {'right'}
			];
			_szCircle = if (!isnull objectParent _x && {_x == _driver}) then {_s1 * 2.5} else {_s1 * 1.5};
			//-- unit selected circle
			if (_x in A3C_SELECTED_UNITS) then {
				_unitIconSelected = _this select 0 drawIcon
				[
					"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
					[1,1,1,0.4 min A3C_OPACITY],
					getPos _x,
					_szCircle,
					_szCircle,
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
	//hintsilent str _syncWPS;
	{
		_sWposes = (_x select 1);
		_swDest = _swPoses select ((count _swPoses) - 1);
		{
			(_this select 0) drawline [_x,_swDest, [1,0,1,A3C_OPACITY]];
		} forEach _sWPoses;
		//if (count _x == 2) then {
			//_r = (_x select 1) select 0;
			//_d = (_x select 1) select 1;
			//if (!isnil '_d') then {
			//	(_this select 0) drawline [_r,_d, [1,0,1,A3C_OPACITY]];
			//};
		//};
	} foreach _syncWPS;


	//-- DRAW PATH: UI Line (composed of rectangles, but built with triangles due to no better idea)
	private _targetUnit = if (typeName A3C_SQ_CLICKED_UNIT == "GROUP") then {leader A3C_SQ_CLICKED_UNIT} else {(A3C_SELECTED_UNITS select 0)};
	{

		_referencePos = if (_foreachIndex == 0) then {[]} else {A3C_MAP_DRAGPLANNING_POSITIONS select (_foreachIndex - 1)};
		_dir = if (_foreachIndex == 0) then {_targetUnit getDir _x} else {  _referencePos getdir _x};
		_bottomleft = if (_foreachIndex == 0) then {(_x getPos [5,_dir + 180]) getPos [1,_dir - 90]} else {_referencePos getPos [1,_dir - 90]};
		_bottomright = if (_foreachIndex == 0) then {(_x getPos [5,_dir + 180]) getPos [1,_dir + 90]} else {_referencePos getPos [1,_dir + 90]};
		_topleft = _x getPos [1,_dir - 90];
		_topright = _x getPos [1,_dir + 90];


		_selPoses =
		[
			_bottomleft,
			_topLeft,
			_topRight,
			_bottomRight
		];
		_this select 0 drawTriangle
		[
			[
				_selPoses select 0,
				_selPoses select 1,
				_selPoses select 2,
				_selPoses select 2,
				_selPoses select 3,
				_selPoses select 0
			],
			[0,0,1,0.7],
			"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
		];
	} foreach A3C_MAP_DRAGPLANNING_POSITIONS;

	//////////////////////////////////
	//-- UI-ICONS HIGHCOMMAND LEVEL //
	//////////////////////////////////
	{
		private ["_group","_count","_wps","_leader","_shiftFactor"];
		_group = _x;
		_leader = (leader _x);
		private _leaderVic = (vehicle _leader);
		private _leaderVicDirection = getDir _leaderVic;
		private _groupIsSel = _group in A3C_SELECTED_UNITS;
		private _iconColorArray = [0,0,0,0];
		_wps = [];
		_shiftFactor = 0;
		_leaderPos = getPos (leader _group);

		_opacity = if (!(_groupIsSel) && {!(driver _leaderVic in (units _group)) OR {(!isNull (isVehicleCargo _leaderVic))}}) then {0.4} else {0.7};
		_opacity = _opacity min A3C_OPACITY;

		_crewGroups = [];
		if !( isNull objectParent _leader && {_leader == (driver (vehicle _leader))}) then {
			{
				_crewGroups pushBackUnique (group _x);
			} foreach (crew _leaderVic);
		};
		_shiftFactor = [_group,_crewGroups] call MCSS_fnc_GetArrayIndex;
		if (_shiftFactor == -1) then {_shiftFactor = 0};
		private _gpIconPos = (vehicle (leader _x)) getPos [2 * _shiftFactor, (getDir (vehicle (leader _x))) + 180];
		
		
		if !(_isHighCommand) then {
			_wps = (waypoints _group);
			//-- No AIC only: Waypoint icons, waypoint markers and group markers
			_count = count _wps;
			_leaderPos = getPos (vehicle (leader _group));
			

			//_isGPScapable = {_u = _x; { _item = _x; {_refString = _x; [_refString,toLower _item] call BIS_fnc_instring} count ["gps","dagr","terminal"] > 0 } count assignedItems _u > 0} count units _group > 0;
			//_isGPScapable = true; //
			private _allowDrawing = !captive leader _group OR {_group == group player};

			if (_allowDrawing) then { //&& _isGPScapable
				_iconColorString = toLower (_group getVariable ["A3C_HC_GroupColor","blue"]);
				_iconColorArray = switch (_iconColorString) do {
					case ("red") : {[A3C_UI_COLOR_RED,_opacity] call A3C_UI_Color_setOpacity};
					case ("blue") : {[A3C_UI_COLOR_BLUE,_opacity] call A3C_UI_Color_setOpacity};
					case ("green") : {[0,1,0,_opacity]};
					case ("black") : {[A3C_UI_COLOR_Black,_opacity] call A3C_UI_Color_setOpacity};
					case ("white") : {[1,1,1,_opacity]};
					default {[A3C_UI_COLOR_BLUE,_opacity] call A3C_UI_Color_setOpacity};
				};
				{
					private ["_wp","_startPos","_endPos","_draw"];
					_wp = _x;



					_wPos = waypointPosition _wp;



					_startPos = [1000,1000,0];
					_endPos = [1000,100,0];

					if ((currentWaypoint _group) <= (_wp select 1)) then {

						private _wpAttachedVehicle = waypointAttachedVehicle _wp;
						_wpAttachedVehicle = if (!isNil '_wpAttachedVehicle') then {
							_wpAttachedVehicle
						} else {
							waypointAttachedObject _wp;
						};
						
						if (!isNil '_wpAttachedVehicle' && {!isNull _wpAttachedVehicle && {alive _wpAttachedVehicle && {!(_wpAttachedVehicle in units _group)}}}) then {
							[_this select 0,_wPos,getPos _wpAttachedVehicle,0.5,[1,1,1,0.8]] call A3C_UI_MAP_DRAW_THICC_LINE;
							[
								_this select 0,
								_wpAttachedVehicle,
								17,
								[0.13,0.13,0.13,0.5],
								(gettext(configFile >> "CfgVehicles" >> typeof _wpAttachedVehicle >> "displayName"))
							] call A3C_UI_MAP_DRAW_MACRO_VEHICON;
						};	

						//-- draw WP Lines
						if ((_wp select 1)  == (currentWaypoint _group)) then {
							if (_ctrlMapScale > 0.04) then {
								(_this select 0) drawline [_gpIconPos,waypointPosition _wp, _iconColorArray];
							} else {
								//-- draw THICC wp-lines
								[_this select 0,_gpIconPos,waypointPosition _wp,0.5,_iconColorArray] call A3C_UI_MAP_DRAW_THICC_LINE;
							};
							
							
							if (_count > (_forEachIndex + 1)) then {
								_startPos = (waypointPosition _wp);
								_endPos = (waypointPosition [_group,(_foreachIndex + 1)]);
								//(_this select 0) drawline [_startPos,_endPos,_iconColorArray];
								[_this select 0,_startPos,_endPos,0.5,_iconColorArray] call A3C_UI_MAP_DRAW_THICC_LINE;
							};
						} else {
							if (_count > (_forEachIndex + 1)) then {
								//(_this select 0) drawline [(waypointPosition _wp),(waypointPosition [_group,(_foreachIndex + 1)]),_iconColorArray];
								[_this select 0,waypointPosition _wp,waypointPosition [_group,(_foreachIndex + 1)],0.5,_iconColorArray] call A3C_UI_MAP_DRAW_THICC_LINE;
							};
						};
						//-- draw WP-ICON

						_wpIcon =  "\a3c_ui\markers\icon_waypoint_maps.paa"; //"\a3\ui_f\data\Map\Markers\Military\dot_ca.paa";

						_color = _iconColorArray;
						
						if (waypointType _wp == "CYCLE") then {
							_color = [1,1,1,_opacity];
						};

						_cond = (waypointStatements _wp) select 0;
						_scr = if (waypointscript _wp == "") then {(waypointStatements _wp) select 1} else {waypointscript _wp};
						_sz = 45;

						if ((vehicle (_leader)) isKindOf "AIR") then {
							if (waypointType _wp == "LOITER") then {
								_sz = 20;
								_color = [1,1,1,_opacity];
								_wpicon = "\a3c_ui\markers\icon_marker_wp_loiter.paa";
							} else {
								switch (true) do {
									case (["LANDING",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										if (["LANDING_COMBAT",_scr] call BIS_fnc_instring) then {
											_wpicon = "\a3c_ui\markers\getin_ca.paa";
										} else {
											_wpIcon = "\a3c_ui\markers\helipad.paa";
										};
									};
									case (["PARADROP",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "\a3c_ui\markers\A3C_Marker_Paradrop.paa";
									};
									case (["RAPPEL",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "a3c_ui\markers\A3C_Marker_Rappel.paa"
									};
									case (["SLING LOAD HOOK",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "a3c_ui\markers\A3C_Marker_SlingLoad.paa"
									};
									case (["SLING LOAD UNHOOK",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "a3c_ui\markers\A3C_Marker_SlingDrop.paa"
									};
									case ("overwatch" in toLower _scr) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "a3c_ui\markers\marker_action_overWatch.paa";

										//-- draw cone here!
										_coneDir = parseNumber ((_scr splitstring ",") select 5);
										//hintSilent str (_scr splitstring ",");

										//-- draw Vehicle Firing Sector (has to happen first so that it's underneath the group icon)
										_var = _leaderVic getVariable ["A3C_Freeze_helicopter",[false,0]];
										//if (_var select 0) then {
											//_basePos = (getPosASL _leaderVic) select [0,2];
											//_coneDir = 0;
											_polyPoses = 
											[
												_wPos,
												_wPos getPos [300,_coneDir - 45],
												_wPos getPos [300,_coneDir + 45]
											];
											_this select 0 drawTriangle
											[
												[
													_polyPoses select 0,
													_polyPoses select 1,
													_polyPoses select 2
												],
												if (_var select 0) then {A3C_UI_COLOR_RED} else {A3C_UI_COLOR_YELLOW},
												"#(rgb,1,1,1)color(1,1,1,0.2)"
											];
											A3C_UI_MAPICONS_HC_CONES pushBack [_wp,_coneDir,_polyPoses];
										//};
									};
									case (["CAS-STRIKE",_scr] call BIS_fnc_instring OR ["bute_CAS",_scr] call BIS_fnc_instring) : {
										_sz = 20;
										_color = [1,1,1,_opacity];
										_wpIcon = "A3C_UI\Markers\A3C_MARKER_CAS.paa";
									};
								};
							};
						} else {
							switch (true) do {
								case ("repair" in _scr) : {
									//-- circle
									_entities = (_wPos nearEntities [["Car","Motorcycle","Tank","AIR"], 100]) select {[side _leader, _x,"VISUAL"] call A3C_VEHICLE_needsTreatment};
									_circleColor = switch (true) do {
										case (count _entities > 3) : {A3C_UI_COLOR_RED};
										case (count _entities > 2) : {[0.99,0.36,0.12,1]};
										case (count _entities > 1) : {A3C_UI_COLOR_YELLOW};
										default {[0,1,0,1]};
									};



									_this select 0 drawEllipse
									[
										_wPos,
										100,
										100,
										0,
										[_circleColor,0.5 min A3C_OPACITY] call A3C_UI_Color_setOpacity,
										"#(ai,512,512,9)perlinNoise(256,256,0,1)"
									];
									//-- vehicles to repair
									{
										_this select 0 drawIcon
										[
											"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\repair_ca.paa",//(gettext(configfile >> "CfgVehicles" >> (typeof _x) >> "picture")),
											if ((_x getVariable ["A3C_isBeingRepaired",[false,0,[]]]) select 0) then {[0,1,0,A3C_OPACITY]} else {[0,0,0,A3C_OPACITY]},
											position _x,
											15,
											15,
											0,
											"",
											0,
											0.03,
											'PuristaLight',
											'center'
										];
									} foreach _entities;



									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\A3C_marker_action_repair.paa";
								};
								case (["CLEARBUILDING",_scr] call BIS_fnc_instring) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\building.paa";
									if (["CLEARBUILDING_ACTIVE",_scr] call BIS_fnc_instring) then {
										_color = [0.99,0.37,0.11,_opacity];
									};
									
								};
								case (["PlantExplosive_HC",_scr] call BIS_fnc_instring) : {
									_sz = 20;
									_wpIcon = "a3c_ui\markers\A3C_Marker_Detonation.paa";
									if (["objnull",_scr] call BIS_fnc_instring) then {
										_color = [1,1,1,_opacity];
									} else {
										_color = [0.99,0.42,0.4,_opacity];

									};
								};
								case (["ASSEMBLE_UAV",_scr] call BIS_fnc_instring) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\iconMarkerUAV.paa"
								};
							};
						};
						if (waypointType _wp in ["SAD"]) then { //,"TR UNLOAD"
							_sz = 20;
							_color = [1,1,1,_opacity];
							// if (waypointType _wp == "SAD") then {
								_wpIcon = "a3c_ui\markers\icon_marker_wp_SAD.paa"
							// } else {
								// _wpIcon = "a3c_ui\markers\getout_ca.paa"
							// };
						} else {
							switch (true) do {
								case ("tr_unload" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\getout_ca.paa"
								};
								case ("loadgroupinvehicle" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\getin_ca.paa"
								};
								case ("groupgetinvehicle" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\icon_marker_vehicleBoard.paa"
								};
								case ("getvehicleinvehicle" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "\a3c_ui\markers\getin_ca.paa"
								};
								case ("loadvehicleinvehicle" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "\a3c_ui\markers\getin_ca.paa"
								};
								case ("ambush" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "\a3c_ui\markers\icon_marker_ambush.paa"
								};
								case ("suppress" in (tolower _scr)) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "\a3c_ui\markers\icon_marker_fireSupport.paa"
								};
								//case (["TRANSPORT UNLOAD",_scr] call BIS_fnc_instring) : {
								//	_sz = 20;
								//	_color = [1,1,1,_opacity];
								//	_wpIcon = "a3c_ui\markers\getout_ca.paa"
								//};
								case ("AssembleWeapon" in _scr) : {
									_sz = 20;
									_color = [1,1,1,_opacity];
									_wpIcon = "a3c_ui\markers\A3C_MARKER_PackStaticWeapon.paa"
								};
							};
						};

						if (_wp select 1 >= (currentWaypoint _group)) then { //~~ necessary?
							_this select 0 drawIcon
							[
								_wpIcon,
								_color,
								_wPos,
								_sz,
								_sz,
								0,
								"",
								0,
								0.03,
								'PuristaLight',
								'center'
							];
							private _szEdited = _sz * 1.5;
							A3C_UI_MAPICONS_HC_WPS pushBack [_group,[_szEdited,_szEdited],(waypointposition _wp),_wp select 1];
						};

						_condIcon = "";
						_condIconcolor = [1,1,1,1];
						{
							private _checkString = _x;
							if (["GoCode",_checkString] call BIS_fnc_inString) then {
								{
									private _gc = _x;
									if ({[_x,_checkString] call BIS_fnc_inString} count [format ["Activate_%1",_gc],str _gc] > 0) then {
										_condIcon = format ["\a3c_ui\markers\icon_GoCode_%1.paa",_gc]; //--aaa
									};
								} foreach ["A","B","C","D"];
							};
						} foreach [_cond,_scr];

						if ( !(_cond == "") ) then {
							if (["time",_cond] call BIS_fnc_instring OR {["date",_cond] call BIS_fnc_instring}) then {
								_condIcon = "\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\watch_ca.paa";
								_condIconcolor = [0,0,0,1];
							};
						};

						if (_condIcon != "") then {
							_condOpacity = (_ctrlMapScale min 0.02) min A3C_OPACITY;
							_condOpacity = _condOpacity / 0.02;
							_condOpacity = 1 - _condOpacity;
							_dist = (_condOpacity * 3) min 1;
							_condIconcolor set [3,_condOpacity];
							_szFact = 0.08; // else {0.025};
							_szMax = 45; //} else {40};
							_szMin = 20;
							_szCond = (_szFact * 10^(abs log _ctrlMapScale)) min _szMax;
							_szCond = _szCond max _szMin;

							_this select 0 drawIcon
							[
								_condIcon,
								_condIconcolor,
								_wPos getPos [_dist ,0],
								_szCond * 0.5,
								_szCond * 0.5,
								0,
								'',
								0,
								0.03,
								'PuristaLight',
								'right'
							];
						};

						private _syncedWPs = synchronizedWaypoints _wp;
						if (count _syncedWPs > 0) then {
							{
								if ({_wp in _x} count A3C_HC_WP_SYNC_ARRAYS == 0 ) then {
									A3C_HC_WP_SYNC_ARRAYS pushbackUnique [_wp,_x];
								};

							} foreach _syncedWPs;
						};	
					};
				} foreach _wps;


				if (_group == group player) then {
					{
						if ((waypointStatements _x) select 0 == "false") then {
							deletewaypoint _x;							
						};
					} foreach _wps;
				};

				//-- draw Group Icon
		
				_iconType = [_group] call A3C_HC_getIconType;
				_iconColorArray set [3,_opacity];

				_sz = (2* 10^(abs log _ctrlMapScale)); // min _szMax;
				_sz = _sz max (8 * safezoneH);
				_sz = _sz min (25 * safezoneH);

				if !(driver _leaderVic in units _group) then {
					_sz = _sz * 0.7;
				};
				_hcBackground = if ("b_hq_ca" in _iconType) then {"A3C_UI\markers\icon_map_backgroundHQ.paa"} else {"A3C_UI\markers\icon_map_backgroundHC.paa"};
				private _outlineColor = if (_group getVariable ["A3C_HC_GroupColor","blue"] == "WHITE") then {[0,0,0,1]} else {[1,1,1,1]},
				

				//-- orientation helper for remote HC vehicle control
				if (a3c_is_HC_remote && {_leaderVic == a3c_remote_tank_obj}) then {
					(_this select 0) drawLine
					[
						getpos _leaderVic,
						(getPosASL _leaderVic) getPos [10, getDir _leaderVic],
						_iconColorArray
					];
				};

				//-- icon macro group
				{
					
					_this select 0 drawIcon
					[
						_x select 0,
						_x select 1,
						_gpIconPos, //vehicle
						_sz, //40,
						_sz, //35,
						0,
						"",
						0,
						0.03,
						'PuristaLight',
						'center'
					];
				} foreach [
					[_hcBackground,_iconColorArray],
					[_iconType,_outlineColor]
				];

				

				//-- draw selection indicator Icon
				
				_op = if (_groupIsSel) then {_opacity} else {_opacity min 0.3};
				_this select 0 drawIcon
				// "\a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa"         "\a3\ui_f\data\IGUI\Cfg\Cursors\board_ca.paa"
				//"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa"       "\a3\ui_f\data\Map\GroupIcons\selector_selectable_ca.paa"
				[
					if (_x in A3C_SELECTED_UNITS) then {"\a3\ui_f\data\IGUI\Cfg\IslandMap\iconSelect_ca.paa"} else {"\a3\ui_f\data\IGUI\Cfg\Cursors\board_ca.paa"},
					[1,1,1,_op],
					_gpIconPos, //
					_sz * 1.5,
					_sz * 1.5,
					0,
					"",
					2,
					0.03,
					'PuristaLight',
					'center'
				];

				// case 0 : {[0,0,1,1]};
				// 	case 1 : {[0,1,0,1]};
				// 	case 2 : {[1,1,1,1]};
				// 	case 3 : {[1,1,0,1]};
				// 	case 4 : {[1,0,0,1]};

	
				_colBHV = switch (behaviour (leader _group)) do {
					case ("COMBAT") : {[1,0,0,_oP]};
					case ("AWARE") : {[1,1,0,_oP]};
					case ("SAFE") : {[1,1,1,_oP]};
					case ("STEALTH") : {[1,0,0,_oP]};
					case ("CARELESS") : {[0.25, 0.85, 0.8, _op]};
					default {[.5,.5,.5,_oP]}
				};

			

				_colCBG = switch (combatMode (leader _group)) do {
					case ("RED") : {[1,0,0,_oP]};
					case ("YELLOW") : {[1,1,0,_oP] };
					case ("WHITE") : {[1,1,1,_oP]};
					case ("GREEN") : {[0,1,0,_oP]};
					case ("BLUE") : {[0,0,1,_oP]};
					default {[.5,.5,.5,_oP]}
				};
			
				

				//-- behaviour:
				(_this select 0) drawIcon
				[
					"A3C_UI\icons\icon_gp_behavior.paa",
					_colBHV,
					_gpIconPos, //
					_sz * 1.5,
					_sz * 1.5,
					0,
					"",
					2,
					0.03,
					'PuristaLight',
					'center'
				];

				//-- combatmode:
				(_this select 0) drawIcon
				[
					"A3C_UI\icons\icon_gp_cbMode.paa",
					_colCBG,
					_gpIconPos, //
					_sz * 1.5,
					_sz * 1.5,
					0,
					"",
					2,
					0.03,
					'PuristaLight',
					'center'
				];

				//-- are units boarding

				if ([_group] call A3C_isGroupBoarding) then {
					(_this select 0) drawIcon
					[
						"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa",
						[1,1,1,_op],
						_gpIconPos, // vectorAdd [0,0,3], //
						_sz * 1,
						_sz * 1,
						0,
						"",
						2,
						0.03,
						'PuristaLight',
						'center'
					];
				};

				

				A3C_UI_MAPICONS_HC_GROUP pushBack [_x,[_sz * 1.5,_sz * 1.5],_gpIconPos];

				if ((leader _group) getVariable ["A3C_CLEARING",false]) then {
					{
						_this select 0 drawIcon
						[
							"\a3\ui_f\data\Map\Markers\Military\box_CA.paa",
							[0.99,0.95,0.54,0.3 min A3C_OPACITY],
							getPos _x,
							20,
							20,
							getDir _x,
							'',
							1,
							0.03,
							'PuristaLight',
							'right'
						];
						(_this select 0) drawLine [getpos _x, getPos _leaderVic, [0.99,0.95,0.54,0.3 min A3C_OPACITY]];
					} foreach ((units _group) - [leader _group]);
				};
				
				private _groupVicDNS = if (!isNull objectParent _leader) then {[(parseText (getText (configFile >> "CfgVehicles" >> typeOf _leaderVic >> "displayName")))]} else {[]};;

				private _groupVics = [];

				{
					if (!isNull objectParent _x) then {
						if (_x == driver vehicle _x) then {
							_groupVics pushBackUnique (objectParent _x);
						};
					};
				} foreach (units _x);

				
				_drawName = (isPlayer (leader _group)) OR {_groupIsSel};
				if !(_drawName) then {
					if (_doFindIconGroup) then {
						private _groupIconsMouseUnder = (["HC_GP",A3C_MAP_X,A3C_MAP_Y] call A3C_UI_MAP_Overlay_getIconsAtMapPos);
						// hintsilent str _groupIconsMouseUnder;
						if ({_group == _x select 0} count _groupIconsMouseUnder > 0) then {
							_drawName = true;
							// _doFindIconGroup = false;
						};
					};
				};

				if (_drawName) then {
					_addVectorDist = 2 + (59 * _zoomDistanceFac);
					_this select 0 drawIcon
					[
						"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa",
						if (_leader == player) then {[0.85,0.85,0,A3C_OPACITY min _opacity]} else {[1,1,1,A3C_OPACITY min _opacity]},
						_gpiconPos vectorAdd [0,-(_addVectorDist),0],
						0,
						0,
						0,
						format ["%1: %2 %3",(_foreachIndex + 2), groupID (_allGroupsHC select _foreachIndex), if (side _leader != side player) then {format ["(%1)",side _leader]} else {""}],
						//format ["%1: %2 %3",(_foreachIndex + 2), groupID (_allGroupsHC select _foreachIndex),if (count _groupVicDNS > 0 && {driver vehicle _leader in units _group}) then {str _groupVicDNS} else {""}],
						2,
						if ( (driver vehicle _leader) in (units _group) ) then {0.03} else {0.025},
						if (_leader == player) then {'PuristaBold'} else {'PuristaLight'}, //'PuristaLight',
						'center'
					];
				};
				_groupStatus = _group getVariable 
				[
					"A3C_UI_Group_Status",
					["",[]]
				];
				if (_groupStatus select 0 != "") then {
					_minDIst = if (_drawName) then {7} else {2};
					_addVectorDist = _minDist + (59 * _zoomDistanceFac);
					//if (_ctrlMapScale <= 0.1) then {
						//_offSet = linearConversion [ 0, 0.1, _ctrlMapScale, 1.5, 80, true ];
						private _col = _groupStatus select 1;
						_col set [3,A3C_OPACITY];
						_this select 0 drawIcon
						[
							"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa",
							_col,
							_gpiconPos vectorAdd [0,-(_addVectorDist),0],
							0,
							0,
							0,
							_groupStatus select 0,
							0,
							0.03,
							'PuristaLight',
							'center'
						];

					//};
				};
				

				//_this select 0 drawIcon
				//[
				//	"\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayer\arrow_up_ca.paa",
				//	[1,1,1,1],
				//	_iconPos2,
				//	0,
				//	0,
				//	0,
				//	if (count _groupVicDNS > 0) then {str _groupVicDNS} else {""},
				//	2,
				//	0.03,
				//	'PuristaLight',
				//	'center'
				//];
				// - static weapon icons (universal)
				{
					_group = group _x; //~~ needed???
					if ((vehicle _x) isKindOf "staticweapon") then {
						//systemchat str (typeof (vehicle _x));
						_wpnIcon = _this select 0 drawIcon
						[
							(gettext(configfile >> "CfgVehicles" >> (typeof (vehicle _x)) >> "icon")),
							[A3C_UI_COLOR_BLUE,A3C_OPACITY] call A3C_UI_Color_setOpacity,
							getPos _x,
							35,
							35,
							getDir (vehicle _x),
							format [     '%1 | %2',(gettext(configFile >> "CfgVehicles" >> typeof (vehicle _x) >> "displayName")), groupID _group],
							1,
							0.03,
							'PuristaLight',
							'right'
						];
					};
				} foreach (units _x);

				//-- draw convoy subunits
				if ({_group == _x select 0} count A3C_CONVOYGROUPS > 0) then {
					//if (count _groupVics > 0) then {systemchat str _groupVics};
					{
						_this select 0 drawIcon
						[
							"\a3\ui_f\data\Map\Markers\Military\box_CA.paa",
							[0.99,0.95,0.54,0.3 min A3C_OPACITY],
							getPos _x,
							35,
							55,
							getDir _x,
							'',
							1,
							0.03,
							'PuristaLight',
							'right'
						];
					} foreach (_groupVics - [vehicle leader _group]);
				};	
			};
		};
		
		
	} foreach (_allGroupsHC); // + [group player]);

	//-- draw HC waypoint sync lines (has to happen after waypoints are drawn to gather intel)
	{
		_wpos1 = waypointPosition (_x select 0);
		_wpos2 = waypointPosition (_x select 1);
		if ({currentWaypoint (_x select 0) > (_x select 1)} count _x == 0) then { //-- draw only for active waypoints
			(_this select 0) drawLine [_wpos1,_wpos2, [1,1,0,1]];
		};
	} foreach A3C_HC_WP_SYNC_ARRAYS;


	if (!(A3C_DISABLE_TRACKER) && {A3C_TRACKER_VISIBLE == 1} ) then { //&&
		{
			_gp = _x select 0;
			if ((_x select 0) in allGroups) then {
				if ({alive _x} count units (_x select 0) == 0) then {
					A3C_TRACKER_GROUPS = A3C_TRACKER_GROUPS - [_x];
					deleteGroup (_x select 0);
				} else {
					if ({player knowsAbout (vehicle _x) > 0} count (units _gp) > 0) then {
						_size = [25,45];
						_wpnIcon = _this select 0 drawIcon
						[
							[_gp] call A3C_HC_getIconType,
							(_x select 3), //-- color
							(_x select 1), //-- position
							25,
							35,
							0,
							"",
							1,
							0.03,
							'PuristaLight',
							'right'
						];
						switch (_x select 2) do {
							case ("ENEMY") : {
								//A3C_UI_MAPICONS_HC_WPS pushBack [_group,[_sz,_sz],(waypointposition _wp),_wp select 1];
								A3C_UI_MAPICONS_HC_TRACKER pushBackUnique [_gp,_size,(_x select 1),"ENEMY"];

							};
							case ("CIVILIAN") : {
								//A3C_UI_MAPICONS_HC_TRACKER pushBackUnique [];
							};
						};
					};
				};
			};
		} foreach A3C_TRACKER_GROUPS;
	};




	//-- draw active-suppression lines
	{
		_g = _x;
		if (!isPlayer (leader _g) OR (player == leader _g)) then { //-- prevent drawing polyLines from other player controlled groups
			{
				private ["_u","_p1","_poly","_poses","_root"];
				_u = _x;
				_p1 = _u getvariable ["A3C_SUPPRESSION_TARGET",[0,false,-1]];
				private _polyIndex = _p1 select 2;
				if !(typeName (_p1 select 0) == "SCALAR") then { //-- determine if uniut is currently suppressing. maybe change SCALAR to objNull and !isNul check
					private _allUnitPolys = if (group _u == group player) then {_u getvariable ["A3C_UNIT_POLYS",[]]} else {(group _u) getvariable ["A3C_UNIT_POLYS",[]]};
					if (_polyIndex != -1) then {
						_poly = nil;
						{
							_id = (_x select 0) select 2;
							if (_id == _polyIndex) exitWith {
								_poly = _x;
							};
						} foreach _allUnitPolys;
						if (!isNil '_poly') then {
							_poses = (_poly select 1);
							_poses = [_poses,[],{_x distance2D _u},"ASCEND"] call BIS_fnc_sortBy;
							_root = _poses select 0;
							_unitPos = if (typeName _u == "OBJECT") then {getPos _u} else {getPos (leader _u)}; //-- unNecessary
							(_this select 0) drawline [getPos _x, _root, [A3C_UI_COLOR_RED,0.3] call A3C_UI_Color_setOpacity];
							_this select 0 drawIcon
							[
								"\a3\ui_f\data\Map\Markers\Military\dot_CA.paa",
								[1,1,1,0.6],
								getPos _u,
								15,
								15,
								0,
								'',
								1,
								0.03,
								'PuristaLight',
								'right'
							];
						};

					};
				};
			} foreach (units _x);
		};
	} foreach ([(group player)] + _allGroupsHC);



	/////////////////////////////////

	//-- A3C_ALL_POLYS is recreated from group variables on each frame
	A3C_ALL_POLYS = [];

	//-- Draw Area-of-Fire Polygons and waypointTYpe Icons

	{
		private ["_u","_var","_oldWP","_act"];
		_u = _x;
		_var = (_u getvariable "A3C_UNIT_POLYS");
		_act = [];



		if (typeName _u == "GROUP") then {
			_act = waypoints _x;
			{
				if ( ((waypointStatements [_u, currentWaypoint _u]) select 0) == "false" OR {(currentWaypoint _u > (_x select 1))}) then {

					_act = _act - [_x];

				};
			} foreach _act;
		};

		{
			private ["_poly","_add","_rec"];
			_poly = _x;
			_add = true;
			_rec = "";
			if (typeName _u == "GROUP") then {
				_rec = "REC";
			} else {

				private ["_mark","_act"];
				_mark = (_poly select 0) select 1;

				_act = (_u getVariable "A3C_PLOT_TEMP") + (_u getVariable "A3C_PLOT");
				if ({((_x select 1) select 0) == _mark} count _act == 0) then { //--
					//systemchat str [_mark,_act];
					if !(_u in (A3C_SUPPRESSION_UNITS_SQ + A3C_SUPPRESSION_UNITS_AI)) then {
						//~~ ATTENTION: CURRENTLY this is executed because the given poly ID does not match with _mark, because it is still a marker. //STILL TRUE??
						[_u,_poly] call A3C_SUP_REMOVE_POLY;
						//systemchat "kill";
						_var = _var - [_poly];
						_add = false;
						//hint "poly removed draw3";
					};
				} else {
					_rec = "REC";
				};

			};
			if (_add) then {
				_poly pushBackUnique _rec;
				A3C_ALL_POLYS pushbackUnique _poly;
				//systemchat "yo";
				if (typeName _u == "GROUP") then {
					private ["_wpA","_root1","_draw"];
					_wpA = waypoints _u;
					_root1 = [0,0,0];
					_draw = false;
					_t = [];
					{
						_t pushback (_x select 0);
					} foreach _wpa;
					//hintsilent str _t;
					
					{
						if ( ((_poly select 0) select 2) == (_x select 1) ) exitwith {
							_root1 = waypointPosition _x;
							_draw = true;
						};
					} foreach _wpA;
					
					if (_draw) then {
						(_this select 0) drawline [_root1,(_poly select 0) select 0, [A3C_UI_COLOR_RED,0.3] call A3C_UI_Color_setOpacity];
					};
				};
				//_poly = _poly - [_rec];


			};
		} foreach _var;
		//if (typeName _u == "GROUP") then {

			_u setVariable ["A3C_UNIT_POLYS",_var,true];
		//};

	} foreach ( _allGroupsHC + (units player) );


	//-- draw polygons
	{
		private _polyID = (_x select 0) select 1;
		private _polyType	= switch (true) do {
			case (["SUP",_polyID] call BIS_fnc_instring) : {"SUP"};
			case (["AMB",_polyID] call BIS_fnc_instring) : {"AMB"};
			case (["ASS",_polyID] call BIS_fnc_instring) : {"ASS"};
			default {"OTHER"};
		};

		//-- draw polygon, unless it's an Assembly Polygon
		if (count _x > 0 && {count (_x select 1) > 0 }) then {
			private _color = switch (_polyType) do {
				case ("SUP") : {[A3C_UI_COLOR_RED,0.7] call A3C_UI_Color_setOpacity}; //{"ColorOpfor"}; NOTE: ColorOpfor does not work after Contact Patch
				case ("AMB") : {[0,0,0,0.7]}; //{"ColorBlack"};
				case ("ASS") : {[0,0,0,0.7]}; //{"ColorBlack"};
				case ("OTHER") : {[1,1,1,0.7]}; //{"ColorWhite"};
			};

			private _iconMainType = switch (_polyType) do {
				case ("SUP") : {'\a3\ui_f\data\Map\GroupIcons\selector_selectedMission_ca.paa'};
				case ("AMB") : {'\a3\ui_f\data\Map\Markers\Military\ambush_CA.paa'};
				case ("ASS") : {'\a3\ui_f\data\Map\GroupIcons\badge_gs.paa'};
				case ("OTHER") : {""};
			};
			//-- convert color to RGBA --DOES NOT WORK WITH COLOROPFOR ETC SINCE CONTACT PATCH
			//_color = (getArray (configFile >> "CfgMarkerColors" >> _color >> "color")) call BIS_fnc_colorConfigToRGBA;

			_polyPoses = (_x select 1);
			_sizeBase = if (_polyType == "ASS") then {0.5} else {1};
			private _sizeMain = ((_sizeBase * 0.15) * 10^(abs log (ctrlMapScale (_this select 0)))) max 20;
			private _sizeEdge = ((0.8 * 0.15) * 10^(abs log _ctrlMapScale)) max 10;
			//hintsilent str _sizeEdge;
			_dir = 0;

			(_this select 0) drawIcon
			[
				_iconMainType,
				_color,
				(_x select 0) select 0,
				_sizeMain,
				_sizeMain,
				_dir,
				'',
				1,
				0.03,
				'PuristaLight',
				'right'
			];
			if !(_polyType == "ASS") then { //-- 'ASS' stands for 'ASSemble', you cheeky kitten.
			
				_this select 0 drawTriangle
				[
					[
						_polyPoses select 0,
						_polyPoses select 1,
						_polyPoses select 2,
						_polyPoses select 2,
						_polyPoses select 3,
						_polyPoses select 0
					],
					((_color select [0,3]) + [0.4]),
					"#(rgb,1,1,1)color(1,1,1,0.5)"
				];
			
				{
					(_this select 0) drawIcon
					[
						'\a3\ui_f\data\Map\Markers\Military\dot_CA.paa',
						_color,
						_x,
						_sizeEdge,
						_sizeEdge,
						0,
						'',
						1,
						0.03,
						'PuristaLight',
						'right'
					];
					A3C_UI_MAPICONS_POLYGON_EDGE pushBackUnique [_polyID,[_sizeEdge,_sizeEdge],_x] ;
				} foreach _polyPoses;
			
				[_this select 0,_polyPoses,0.5,_color] call A3C_UI_MAP_DRAW_Polyframe;
			};

			A3C_UI_MAPICONS_POLYGON_MAIN pushback [_polyID,[_sizeMain,_sizeMain],(_x select 0) select 0];  //-- [_polyID,[_sizeMain,_sizeMain],_polyCenter,_polyPoses,_sizeEdge]. Edge Icons have to be generated/tested in TAB_INIT.
			//~~ once ready, make extra array for edges. include _polyId, _polyPoses and _sizeEdge for identification in TAB_INIT
		};
	} foreach A3C_ALL_POLYS;
	if !(A3C_Prevent_SCALING) then {
		_scale = 0.05 / _ctrlMapScale;
		{
			_m = "#markerSize_" + _x;
			if (markerShape _x == "ICON") then {
				if (isNil {missionNamespace getVariable _m}) then {
					missionNamespace setVariable [_m, (markerSize _x)];
				};
				_x setMarkerSizeLocal
				[
					(((missionNamespace getVariable _m) select 0) * _scale) min ((missionNamespace getVariable _m) select 0) ,
					(((missionNamespace getVariable _m) select 1) * _scale) min ((missionNamespace getVariable _m) select 1)
				];
			};
		} forEach (A3C_MARKERS + A3C_MARKERS_TEMP);
	};

	if (A3C_TAB_BUILDING_BOOL) then {
		for "_i" from 0 to ([A3C_TAB_BUILDING] call MCSS_fnc_countBPos) do {
			_bPos = (A3C_TAB_BUILDING buildingPos _i);
			_sz = ([_bPos] call A3C_ICONCOLORSIZE);
			(_this select 0) drawIcon
			[
				'\a3\ui_f\data\map\GroupIcons\icon_selected.paa',
				(_sz select 0),
				_bPos,
				(_sz select 1),
				(_sz select 1),
				0,
				(str _i),
				1,
				(_sz select 2),
				'PuristaLight',
				'right'
			];
		};
	};
	if (A3C_MapSel_Field_Active) then {
		_selPoses =
		[
			A3C_MapSel_Field_Root,
			[(A3C_MapSel_Field_DEST select 0), (A3C_MapSel_Field_Root select 1), 0],
			A3C_MapSel_Field_DEST,
			[(A3C_MapSel_Field_Root select 0), (A3C_MapSel_Field_DEST select 1), 0]
		];
		_this select 0 drawTriangle
		[
			[
				_selPoses select 0,
				_selPoses select 1,
				_selPoses select 2,
				_selPoses select 2,
				_selPoses select 3,
				_selPoses select 0
			],
			_color,
			"#(rgb,1,1,1)color(0,0.3,0.6,0.2)"
		];
	};



	if (count A3C_PICKUP_OBJECTS > 0) then {
		{

			[
				_this select 0,
				_x,
				25,
				[A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity,
				(gettext(configFile >> "CfgVehicles" >> typeof _v >> "displayName"))
			] call A3C_UI_MAP_DRAW_MACRO_VEHICON;	
			A3C_UI_MAPICONS_PICKUP pushbackUnique [_x,[25,25], getPosASL _x];
		} foreach A3C_PICKUP_OBJECTS;
	};
	if (A3C_HC_VEHICLEBOARD_BOOL) then {
		{
			[
				_this select 0,
				_x select 0,
				32.5,
				[A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity,
				""
			] call A3C_UI_MAP_DRAW_MACRO_VEHICON;
		} foreach A3C_UI_MAPICONS_HC_VICS;

	};

	//-- MultiWaypoint - highlight selected Waypoints
	 _sz = 35;

    {
        private _wp = _x;
        _this select 0 drawIcon
		[
			"\a3\ui_f\data\Map\GroupIcons\selector_selected_ca.paa",
			[1,1,0,1],
			waypointPosition _wp,
			_sz,
			_sz,
			0,
			format ["%1 (%2)", groupID (_wp select 0), _wp select 1],
			0,
			0.03,
			'PuristaLight',
			'right'
		];

    } foreach A3C_Selection_MultiWaypoint;



};




if (!isNil "A3C_EVH_DRAW") then {(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw",A3C_EVH_DRAW]};
A3C_EVH_DRAW = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler
[
	"Draw",
	{
		_this call MAP_UI_fnc_drawMapUI;
	}
]; //add for GPS? Tablet needs to be added each time it is opened


/*
if (!isNil "A3C_EVH_DRAW1") then {(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw",A3C_EVH_DRAW1]};
A3C_EVH_DRAW1 = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler
[
	"Draw",
	{
		[
					_this select 0,
					vehicle player,
					25,
					[A3C_UI_COLOR_RED,1] call A3C_UI_Color_setOpacity,
					""
				] call A3C_UI_MAP_DRAW_MACRO_VEHICON;	
	}
];