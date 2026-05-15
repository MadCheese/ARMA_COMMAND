
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//----------------------------------------  C 2  -  Z E U S  -  R E M O T E   -----------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------


A3C_ZEUSMISSION = if (!isNil 'A3C_ZEUSMISSION') then {A3C_ZEUSMISSION} else {false};

A3C_ZEUS_REMOTE = {
	
	if (isnull (finddisplay 312)) exitWith {};
	_btn = _this select 1;
	_posX = _this select 2;
	_posY = _this select 3;
	_shift = _this select 4;
	_ctrl = _this select 5;

	_unit = objnull;
	_curatorModule = objnull;
	_zeusCurrent = player;
	if (_btn == 0) then {
		if (_ctrl && _shift) then {
			if !(curatorMouseOver select 0 == "") then {
				_unit = curatorMouseOver select 1;
				if (({isPlayer _x} count (units (group _unit))) == 0) then {
					findDisplay 312 closeDisplay 2;				
					selectPlayer (leader (group (effectiveCommander _unit)));
				};				
			};
		};
		if (A3C_ZEUSMISSION) then {
			if (_ctrl && !(_shift)) then {
				if !(curatorMouseOver select 0 == "") then {
					_unit = curatorMouseOver select 1;
					systemchat str _unit;
				};
			};
		};
	};
};