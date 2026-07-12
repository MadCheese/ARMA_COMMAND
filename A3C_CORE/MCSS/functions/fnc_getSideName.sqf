// MCSS_fnc_getSideName

params ["_sideNumber"];

switch (_sideNumber) do {
	case 0: { east };
	case 1: { west };
	case 2: { resistance };
	case 3: { civilian };
	default { sideUnknown };
}