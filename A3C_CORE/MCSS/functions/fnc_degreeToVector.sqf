
// MCSS_fnc_degreeToVector
//-- convert degree to vectorDir

params ["_degree"];

private _return =
[
	sin _degree,
	cos _degree,
	0
];

_return
