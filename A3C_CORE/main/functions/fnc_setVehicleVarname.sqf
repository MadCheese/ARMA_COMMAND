// A3C_main_fnc_setVehicleVarname


//-- FNC to set vehicle varname for a unit - this is often necessary for scripted commands to have any effect


params ["_unit"];

A3C_VARNAME_INDEX = if (!isNil 'A3C_VARNAME_INDEX') then {A3C_VARNAME_INDEX} else {1};

if ((vehicleVarName _unit) == "") then {
	while {(vehicleVarName _unit) == ""} do {
		call compile format
		[
			"
				_unit setvehicleVarName 'A3C_MEMBER_%1_%2';
				A3C_MEMBER_%1_%2 = _unit;
				publicVariable 'A3C_MEMBER_%1_%2';
			",
			if (!isNull player) then {getPlayerUID player} else {"111011101111"},
			A3C_VARNAME_INDEX
		];
	};
} else {
	call compile format
	[
		"
			%1 = _unit;
		",
		(vehiclevarname _unit)
	];
};

A3C_VARNAME_INDEX = A3C_VARNAME_INDEX + 1;

(vehiclevarname _unit)

