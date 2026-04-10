if (!isNil 'all_markers') then {
	
	{deleteMarker _x} foreach all_markers;

	all_markers = [];
	{
		_t = _x;
		if ( alive _t && {{_t isKindOf _x} count ['MAN','CAR','TANK', 'HOUSE'] == 0 && {{_x in (toLower typeOf _t)} count ['weapon','fx','logic'] == 0}}) then {
			if ('suitcase' in toLower (typeOf _x)) then {
				_marker = 
				[
					format 
					[
						'M_%1',
						_foreachINdex
					],
					position _x,
					'ICON',
					'mil_dot',
					[0.5,0.5],
					typeOf _x,
					'ColorBlufor'
				] call MCSS_fnc_createMarker;
				all_markers pushback _marker;
			};
		};
				
	} foreach ((allmissionObjects 'ALL') - (units player));
} else {
	all_markers = [];
};