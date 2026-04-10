
//-- remove player controlled groups from checkGroups (only relevant for this particular check)
{
	if (isPLayer leader _x) then {
		A3C_MON_SERVER_checkGroups = A3C_MON_SERVER_checkGroups - [_x];
	};
} foreach A3C_MON_SERVER_checkGroups;
publicVariable'A3C_MON_SERVER_checkGroups';

//-- RELAY INTEL: PLAYERS TO HC
{
	private _player = _x;
	_tgts = [(side _player),1000,"ENEMY",position (vehicle _player),["MAN","CAR","TANK","AIR","SHIP"]] call MCSS_fnc_NearEntities;
	{
		_t = _x;
		_kn = _player knowsabout _t;
		if (_kn > 1.5) then {
			{
				if (side _x == side _player) then {
					_x reveal [_t,_kn];
				};
			} foreach A3C_MON_SERVER_checkGroups;
		};
	} foreach _tgts;
} foreach allplayers;


//-- other settings
{
	_gp = _x;
	_x enableAttack false;
	{
		//-- enable Autocombat for SAFE Mode
		if (behaviour _x in ["SAFE"]) then {
			[_x,"AUTOCOMBAT"] remoteExec ["enableAI",_x];
		} else {
			[_x,"AUTOCOMBAT"] remoteExec ["disableAI",_x];
		};
		//-- Skill Reset
		if (A3C_isHCSkillMaxed) then {
			[_x,1] remoteExec ["setSkill",_x];
		};
		//-- prevent loaded AI groups from dismounting in combat mode (more suited for non commanded units)
		if (!isnull objectParent _x) then {
			if (_x == driver vehicle _x) then {
				[(vehicle _x),[false,false]] remoteExec ["setUnloadInCombat",(vehicle _x)];	
//				if !((vehicle _x) isKindOf "AIR") then { //-- make liberation specific
//					[vehicle _x,1] remoteExec ["setFuel",vehicle _x ];
//				};
			};
		};
		//-- Force AI to follow leader
		if (currentCommand _x == "STOP") then {
			[_x, (leader group _x)] remoteExec ["doFollow",_x];
		};
	} foreach (units _x);
	
	//-- RELAY INTEL: HC TO PLAYERS
	_tgts =  ((leader _x) targetsQuery [objNull, sideUnknown, "", [], 60]);
	{
		_unit = _x select 1;
		if (!alive _unit) then {_tgts = _tgts - [_x]};
		if (_unit distance2D (leader _gp) > 3000) then {_tgts = _tgts - [_x]};
		if (side _unit getfriend side player > 0.6) then {_tgts = _tgts - [_x]};
	} foreach 	_tgts;

	{
		_t = _x select 1;
		_kn = (leader _gp) knowsabout _t;	
		if (_kn > 1.5) then {
			if ({unitIsUAV _x} count units _gp > 0) then {
				_kn = _kn * 0.4;
				if ([_t,vehicle (leader _gp)] call MCSS_fnc_LOS_SIMPLE) then {
					{
						if (side (leader _gp) == side _x) then {
							[_x,[_t,_kn]] remoteExec ["reveal",_x];
						};
					} foreach allplayers;	
				};
			} else {
				{
					if (side (leader _gp) == side _x) then {
						[_x,[_t,_kn]] remoteExec ["reveal",_x];
					};
				} foreach allplayers;	
			};			
		};
	} foreach _tgts;
} foreach A3C_MON_SERVER_checkGroups;