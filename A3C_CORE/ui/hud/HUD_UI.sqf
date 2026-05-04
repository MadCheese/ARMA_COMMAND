

#include "selectionPromptPanel\dialog_defines.hpp"




A3C_UI_ARSENAL_CREATELB = {
	params ["_unit","_doFade"];
	if (_doFade) then {
		titlecut ["","black out",0.2];
		sleep.2;
	};

	A3C_CurrentPlayerObject = player;
	[] call A3C_UI_RADIAL_CloseDisplay;
	A3C_DISABLE_RADIAL = true;
	if (15 in A3C_UI_DOWNKEYS) then {
		//-- note: might require some new method to inform about need to release TAB since clunky keyviwer was removed
		waitUntil {!(15 in A3C_UI_DOWNKEYS)};
	};

	A3C_DISABLE_RADIAL = false;
	{[_x] call A3C_fnc_setDestination} foreach (units player);
	selectPlayer _unit;
	(group player) selectLeader player;
	{[_x] call A3C_AI_action_resumeDestination} foreach (units player);
	["Open",true] spawn BIS_fnc_arsenal;
	waituntil {_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]); !isNull _arsenalDisplay};
	titlecut ["","black in",0.2];
	_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]);
	_refControl = _arsenalDisplay displayCtrl 995;



	private _lbHeight = (0.033 * safezoneH) ;
	_box1 = _arsenalDisplay ctrlCreate ["A3C_RscCombo",1928];
	_boxPos = ctrlPosition _refControl;
	_boxWidth = _boxPos select 2;
	_boxX = 0.5 - (_boxWidth / 2);
	_boxPos set [0,_boxX];
	_boxPos set [3,_lbHeight];
	_box1 ctrlSetPosition _boxPos;
	_box1 ctrlCommit 0;
	{
		[_box1, [_x] call MCSS_fnc_NAMESTRING] call A3C_addLbEntry;
		if (_x == _unit) then {
			[_box1, _foreachIndex] call A3C_setCurSel;
		};
	} foreach units player;

	//-- NOTE: This EH actually needs to be added each time since it only exists during display lifetime.
	_box1 ctrlAddEventHandler
	[
		"LBSelChanged",
		{
			_originalUnit = player;
			_newUnit = (units player) select (_this select 1);
			(uiNamespace getVariable ["RscDisplayArsenal", displayNull]) closeDisplay 0;
			[_newUnit,_originalUnit] spawn {
				params ["_newUnit","_originalUnit"];
				titlecut ["","black out",0.2];
				sleep .2;
				waitUntil {player == A3C_CurrentPlayerObject};
				sleep 0.1;

				[_newUnit,false] spawn A3C_UI_ARSENAL_CREATELB;
			};


		}
	];


	waituntil {_arsenalDisplay = (uiNamespace getVariable ["RscDisplayArsenal", displayNull]); isNull _arsenalDisplay};
	{[_x] call A3C_fnc_setDestination} foreach (units player);
	selectPlayer A3C_CurrentPlayerObject;
	(group player) selectLeader player;
	{[_x] call A3C_AI_action_resumeDestination} foreach (units player);


};





//-- charge is null object in "A3C_UNIT_EXPLOSIVES" variable
A3C_UI_RADIAL_SelectionPromptPanel_LABEL_DETONATIONTARGETS = {
	_parent = (findDisplay IDD_SELECTION_PROMPT_PANEL displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent);
	_listBox = findDisplay IDD_SELECTION_PROMPT_PANEL displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;
	private _hcAll = A3C_HC_getAllGroups_Player_Current;
	_hcAll pushBackUnique (group player);
	A3C_UI_RADIAL_Current_Remfire_Units = [];
	{
		if (!isPlayer leader _x OR {player == leader _x}) then {
			{
				_u = _x;
				_var = _u getvariable ["A3C_UNIT_EXPLOSIVES",[]];
				if (count _var > 0) then {
					{
						A3C_UI_RADIAL_Current_Remfire_Units pushbackUnique [_u,_x];
					} foreach _var;
				};
			} foreach units _x;
		};

	} foreach _hcAll;
	

	ctrlSetFocus _listBox;
	
	lbClear _listBox;
	private _count = 0;
	//systemchat str A3C_UI_RADIAL_Current_Remfire_Units;
	if (count A3C_UI_RADIAL_Current_Remfire_Units > 0) then {
		[_listBox, "DETONATE ALL CHARGES"] call A3C_addLbEntry;
		_count = 1;
		{
			_x params ["_unit","_charge"];
			//systemchat str _charge;
			_displayName = "";
			{

				if ((typeOf _charge) in _x) exitWith {
					_displayName = _x select 1;
				};
			} foreach A3C_DATA_REMOTE_AMMO;
			_mapGridString = mapgridPosition player;
			_mapGridString = _mapGridString splitString "";
			_mapGridString =
			[
				(_mapGridString select [0,3] joinString ""),
				(_mapGridString select [3,5] joinString "")
			];
			_mapGridString = _mapGridString joinString "-";
			private _lbText = format
			[
				"%1 | %2 | %3",
				_displayName,
				if (group _unit == group player) then {name _unit} else {groupID (group _unit)},
				_mapGridString
			];
			[_listBox, _lbText] call A3C_addLbEntry;
			_count = _count + 1;
		} foreach A3C_UI_RADIAL_Current_Remfire_Units;
	};
	[_parent,_listBox, _count] call A3C_OBJECTSEL_RESIZE;
	
};





A3C_UI_HUD_3D_TAGGING = false;
A3C_UI_HUD_3D_TAG = {
	params ["_pos","_mode"];
	A3C_UI_HUD_3D_TAGGING = true;
	_iconType = A3C_UI_HUD_3D_TAG_ICON_TYPE;
	//private _iconType = switch (_mode) do {
	//	case ("DEMOLITION") : {"\a3\ui_f\data\IGUI\Cfg\Cursors\explosive_ca.paa"};
	//	default {A3C_UI_HUD_3D_TAG_ICON_TYPE};
	//};
	A3C_UI_HUD_3D_TAG_ICON_COL = switch (_mode) do {
		case ("DEMOLITION") : {[1,1,1,0.7]};
		//case ("HC_WP") : {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_fnc_setOpacity};
		case ("BOARD") : {[A3C_UI_COLOR_YELLOW,0.7] call A3C_UI_fnc_setOpacity};
		case ("SUPPRESSION") : {[A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity};
		default {A3C_UI_HUD_3D_TAG_ICON_COL};
	};
	if (!isNull cursorTarget && {(_mode in ["DEMOLITION","BOARD"])}) then {
		_pos = getPos cursorTarget;
		_pos set [2,((boundingbox cursortarget select 1) select 2) / 2];
	};

	//-- animate icon zoom
	if !(_mode in ["HC_WP","SUPPRESSION"]) then {
		_timer = time;
		_animLength = 3;
		while {time - _timer < _animLength} do {
			A3C_UI_HUD_3D_TAG_ICON_POS = _pos;
			_t = (_animLength - (time - _timer)) / _animLength;
			A3C_UI_HUD_3D_TAG_ICON_SIZE = (4 * _t) max 2;
			if (A3C_UI_HUD_3D_TAG_ICON_SIZE == 2) exitWith {};
			//hintSilent str A3C_UI_HUD_3D_TAG_ICON_SIZE;
		};
	};
	
	//-- end flicker
	for "_i" from 1 to 4 do {
		A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
		sleep 0.1;
		A3C_UI_HUD_3D_TAG_ICON_TYPE = "";
		sleep 0.1;
	};
	//-- reset vars to default
	A3C_UI_HUD_3D_TAG_ICON_COL = [1,1,1,0.7];
	A3C_UI_HUD_3D_TAG_ICON_SIZE = 3;
	A3C_UI_HUD_3D_TAG_ICON_POS = [0,0,0];
	A3C_UI_HUD_3D_TAG_ICON_MOD = "NONE";
	A3C_UI_HUD_3D_TAGGING = false;
};

