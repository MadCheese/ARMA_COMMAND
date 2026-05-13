#include "..\..\ui\SHARED\shared_ui_defines.hpp"
#include "..\..\ui\radial\radialMenu\dialog_defines.hpp"
#include "..\..\ui\mapOverlay\dialog_defines.hpp"
#include "..\..\ui\SHARED\selectionPromptPanel\dialog_defines.hpp"







//----- Regular Radial Actions







A3C_AI_HighCommand_Action_casStrike = {
	with uiNamespace do {
		//disableSerialization;
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
	};


	private _a3c_dsp = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {IDD_MAP_OVERLAY} else {IDD_SELECTION_PROMPT_PANEL};
	
	private _parent = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
	private _text = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
	private _listBox = findDisplay _a3c_dsp displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
	_text ctrlSetText "SELECT CAS-TYPE";

	A3C_SelectionPromptPanel_MODE = "CAS";
	
	lbClear _listBox;
	{
		_leaderVic = vehicle leader _x;
		private _casModes = [typeof _leaderVic] call MCSS_fnc_getCASmodes;
		if (count _casModes > 0) exitWith {
			{
				_casMode = switch (true) do {
					case (_x isEqualTo ["machinegun"]) : {'GUN RUN'};
					case (_x isEqualTo ["missilelauncher"]) : {'MISSILES'};
					case (_x isEqualTo ["machinegun","missilelauncher"]) : {'GUNS + MISSILES'};
					case (_x isEqualTo ["bomblauncher"]) : {'BOMBING RUN'};
				};
				[_listBox, _casMode] call A3C_addLbEntry;
			} foreach _casModes;
		};
	} foreach A3C_RD_UNITS;
	{
		_ctrlPos = ctrlPosition _x;
		_ctrlPos set [3,(_ctrlPos select 3) + (  (3)   * (0.0440051 * safezoneH) )];
		_x ctrlSetPosition _ctrlPos;
		_x ctrlCommit 0;
	} foreach [_parent,_listBox];

};

A3C_AI_HighCommand_Action_rappel = {
	{
		private _gp = _x;

		_gp setvariable ["A3C_UNIT_POLYS",[],true];

		//-- clear all waypoints
		{
			{
				_x setVariable ["A3C_CLEARING",false,true];
			} foreach (units _x);
		} foreach A3C_SELECTED_UNITS;


		// _gp = A3C_RD_UNITS select 0; // ?????
		while {(count (waypoints _gp)) > 1} do {
			{
				if (_forEachIndex > 0) then {
					deletewaypoint _x;
				};
			} foreach waypoints _gp;
		};
		
		//-- add new waypoints
		private _leaderVic = (vehicle leader _gp);
		private _rappelWPos = +(A3C_UI_HUD_3D_TAG_ICON_POS);
		private _startPos = getpos _leaderVic;
		private _landOnReturn = !isEngineOn _leaderVic;
		private _wp =
		[
			_gp,
			_rappelWPos
		] call A3C_ai_highCommand_fnc_addWaypoint;
		if (A3C_UI_HUD_3D_TAG_ICON_POS distance2D _leaderVic > 50) then {
			_wp2 =
			[
				_gp,
				_startPos
			] call A3C_ai_highCommand_fnc_addWaypoint;
			if (_landOnReturn) then {
				_statements = format
				[
					"
						[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
					",
					_startPos,
					getPlayerUID player

				];
				_wpStm = waypointStatements _wp2;
				_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
			};
		};
		if (_leaderVic distance2D _rappelWPos < 800) then {
			waitUntil {speed _leaderVic > 80  OR {_leaderVic distance2D _rappelWPos < 300} };
		};

		_statements = format
		[
			"
				[['%1',this,[['NONE','NONE'],'RAPPELL'],'LINE',(currentWaypoint group this),0],A3C_HC_INSERT_ACTION_WP] remoteExec ['bis_fnc_call',0];
			",
			getPlayerUID player
		];
		_wpStm = waypointStatements _wp;
		_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
	} foreach A3C_SELECTED_HC_GROUPS_SETTINGS;
};

A3C_AI_HighCommand_Action_suppression = {
	if (count A3C_RD_UNITS > 0 && {A3C_UI_HUD_3D_TAG_ICON_TYPE != ""}) then {
		{
			[_x,A3C_UI_HUD_3D_TAG_ICON_POS] call A3C_HC_Suppression_Immediate;
		} foreach A3C_UI_RADIAL_Current_Remfire_Units;
	};
	A3C_HC_GroupMenu_SuppressionRequested = false;
};

A3C_AI_HighCommand_Action_artillery = {
	A3C_HC_FOCUS_ARTY = objNull;
	A3C_HC_FOCUS_ARTY_AMMO = ""; //-- what is goin on here
	with uiNamespace do {
		A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
	};

	A3C_HC_FOCUS_ARTY_POS = +(A3C_UI_HUD_3D_TAG_ICON_POS);
	["ARTY"] call A3C_ui_selectionPromptPanel_fnc_openSelectionPromptPanel;
};





A3C_AI_HighCommand_Action_boardGroupToVehicle = {
    private _vehicle = cursortarget;
    [ A3C_RD_UNITS select {!isPlayer leader _x}, _vehicle] call A3C_HC_AssignVehicle;           
    A3C_UI_HUD_3D_TAG_ICON_TYPE = (gettext (configfile >> "CfgVehicles" >> typeof _vehicle >> "picture"));
    _uiPos = getPosASL _vehicle;
    _uiPos set [2,(((boundingBoxReal _vehicle) select 1) select 2) / 2];
    // [_uiPos,"BOARD"] spawn A3C_UI_HUD_3D_TAG;
    A3C_UI_MAPICONS_HC_VICS = [];
    A3C_UI_HUD_ASSIGNVEHICLE = false;   
};


A3C_AI_HighCommand_Action_addWaypoint = {
	if (count A3C_RD_UNITS > 1) then {
								
		private _units = +(A3C_RD_UNITS);
		[_units,A3C_UI_HUD_3D_TAG_ICON_POS] spawn A3C_FNCS_CONVOY_MULTIGROUP;
	} else {
		{
			private _gp = _x;
			private _wpParams = [_gp,A3C_UI_HUD_3D_TAG_ICON_POS];
			private _eligibleForBuildingSearch = A3C_UI_HUD_3D_TAG_ICON_TYPE == "a3c_ui\markers\building.paa";
			if (_eligibleForBuildingSearch) then {
				_wpParams set [1, cursorTarget buildingPos 0];
				_wpParams set [2,[]];
				_wpParams = _wpParams +
				[
					"MOVE",
					[0,0,"AUTO","AUTO","NORMAL","CLEARBUILDING"]
				];
			};
			_wpParams call A3C_ai_highCommand_fnc_addWaypoint;
		} foreach A3C_RD_UNITS;
	};
};


A3C_AI_HighCommand_Action_railedHeliLanding = {
	params ["_landingRailType","_condition"];
	//player commandchat str (!isNull A3C_OBJECTPLACER);

	_landingData = +(A3C_RADIAL_ACTION_HC_LANDINGDATA);
	A3C_RADIAL_ACTION_HC_LANDINGDATA = [];
	_landingData params ["_landingPosRoot","_landingVector","_forceDefaultLanding"];

	A3C_UI_HUD_3D_TAG_ICON_TYPE =  "\a3c_ui\markers\HeliPad.paa";
	[A3C_UI_HUD_3D_TAG_ICON_POS,''] spawn A3C_UI_HUD_3D_TAG;
	private _groups = +(A3C_SELECTED_HC_GROUPS_SETTINGS);

	_distributedPositions = [_landingPosRoot,_groups,count _groups,_landingPosRoot getDir (leader (_groups select 0)),100 ] call A3C_fnc_generateWpWedgePositions;

	private _occupiedLandingPoses = [_landingPosRoot]; //[A3C_UI_HUD_3D_TAG_ICON_POS];
	//private _landingPosRoot = +(A3C_UI_HUD_3D_TAG_ICON_POS);
	{
		private _gp = _x;
		private _leader = leader _gp;

		_leaderVic = vehicle _leader;

		private _groupForeachIndex = _forEachIndex;

		if (_groupForeachIndex > 0) then {
			_forceDefaultLanding = true; //-- make sure that only one vehicle can land precisely (obsolete checkl?)
		};

		// make specific landingpos available only for single group selections and only leadvic. multiple group selections revert to arma landing

		//-- for full landings, delete all other waypoints
		if (_landingRailType == "FULL LANDING") then {

			_gp setvariable ["A3C_UNIT_POLYS",[],true];
			//-- clear all waypoints
			{
				{
					_x setVariable ["A3C_CLEARING",false,true];
				} foreach (units _x);
			} foreach A3C_SELECTED_UNITS;

			[_gp, "ALL"] call A3C_HighCommand_deleteAllWaypoints;
		};




		//-- add new waypoints
		private _leaderVic = (vehicle _leader);
		private _landingWPos = _distributedPositions select _groupForeachIndex; //([_landingPosRoot,[0,100]] call MCSS_fnc_getSafePos)

		private _isGroupOnFinalWP = currentWaypoint _gp >= count waypoints _gp;
		private _createReturnWP = (_landingRailType in ["COMBAT LANDING","TRANSPORT UNLOAD"]) && {_isGroupOnFinalWP && {_landingWPos distance2D _leaderVic > 50}};
		private _landOnReturn  = _createReturnWP && {!isEngineOn _leaderVic};



		_wpi = currentWaypoint _gp;


		private _wp = _gp addWaypoint [_landingWPos,0];


		if (_createReturnWP) then {
			private _startPos = position _leaderVic;
			private _wp2 = _gp addWaypoint [_startPos,0];

			if (_landOnReturn) then {
				//-- land with default Arma mechanic upon return
				private _stmts = format
				[
					"
						[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
					",
					_startPos,
					getPlayerUID player

				];
				_wpStm = waypointStatements _wp2;
				_wp2 setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _stmts];
			};
		};

		private _statements = "";


		if (_groupForeachIndex == 0 && {!(_forceDefaultLanding)}) then {
			_subCondition = if (_landingRailType == "COMBAT LANDING") then {format ["A3C_GoCode_Activate_%1",((_condition splitstring "") select 8)]} else {""};

			//-- assumption: waypointScript gets executed on every machine - if the script is present
			//-- assumption 2: a function can be remo tely executed from the machine that executed the script (needs to be determined?
			_wp setWaypointType "SCRIPTED";

			_wp setWayPointScript format
			[
				"A3C_CORE\fnc_AI\wpFncs\wpScript_railedHeliLanding.sqf ['%1',%2,%3,'%4',%5,'%6']",
				getPlayerUID player,
				["ARRIVAL",""],
				["ARRIVAL",""],
				_landingRailType,
				_landingData,
				_subCondition
			];
		} else {
			switch (_landingRailType) do {
				case ("COMBAT LANDING") : {
					_subCondition = ((_condition splitstring "") select 8);
					//;
					_statements = format
					[
						"
							[['%1',this,[['GoCode','%2'],'COMBATLANDING'],'LINE',(currentwaypoint (group this))],A3C_HC_INSERT_ACTION_WP,nil,false] remoteExec ['bis_fnc_call',0];
							[(group this)] call A3C_HC_FNC_CompleteWaypoint
						",
						getPlayerUID player,
						_subCondition
					];
					A3C_GOCODES_HC pushbackUnique _subCondition;
					publicVariable 'A3C_GOCODES_HC';
					[] remoteExec ["A3C_UI_Shared_fnc_toggleGocodeCtrls",0];

				};
				case ("TRANSPORT UNLOAD") : {
					_wp setWaypointType "TR UNLOAD";
					_statements = "[(group this)] call A3C_HC_FNC_CompleteWaypoint;  ";
				};

				case ("FULL LANDING") : {
					_statements = format
					[
						"
							[this,%1,'%2',[],true] spawn A3C_ai_highCommand_fnc_wpAction_landingFull;
							[(group this)] call A3C_HC_FNC_CompleteWaypoint;
						",
						_landingData select 0,
						getPlayerUID player

					];
				};
			};

		};
		if (_statements != "") then {
			_wpStm = waypointStatements _wp;
			_wp setWaypointStatements [(_wpstm select 0),(_wpstm select 1) + _statements];
		};


		sleep 1;
	} foreach _groups;
};








//---------------------------- MAP ONLY

//---------------------------- SHARED (MAP+RADIAL)