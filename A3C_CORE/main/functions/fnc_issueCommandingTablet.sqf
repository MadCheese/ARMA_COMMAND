// A3C_main_fnc_issueCommandingTablet

params ["_unit"];

private _tabletType = switch (side player) do {
	case (WEST) :{"B_A3C_Terminal"};
	case (EAST) :{"O_A3C_Terminal"};
	case (resistance) :{"I_A3C_Terminal"};
	default {"A3C_Terminal_NoUAV"};
};

player linkItem _tabletType;