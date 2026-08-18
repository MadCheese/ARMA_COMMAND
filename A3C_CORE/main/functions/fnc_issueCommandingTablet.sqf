// A3C_main_fnc_issueCommandingTablet

params [
    "_unit",
    ["_doUAV", true, [true]]
];

if !(_doUAV) exitWith {
	_unit linkItem "A3C_Terminal_NoUAV";
};

private _tabletType = switch (side _unit) do {
	case (WEST) :{"B_A3C_Terminal"};
	case (EAST) :{"O_A3C_Terminal"};
	case (resistance) :{"I_A3C_Terminal"};
	default {"A3C_Terminal_NoUAV"};
};

_unit linkItem _tabletType;