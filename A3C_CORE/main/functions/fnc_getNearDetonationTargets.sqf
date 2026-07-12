// A3C_main_fnc_getNearDetonationTargets

params ["_unit", "_position", "_distance", "_mustKnowAbout"];

private _targetTypes = [
	"Car",
	"Tank",
	"Helicopter",
	"Jet",
	"Plane",
	"Ship",
	"StaticWeapon",
	"ReammoBox",
	"ReammoBox_F"
];

nearestObjects [_position, _targetTypes, _distance] select {
	(abs(speed _x)) <= 1 &&
	{
		!_mustKnowAbout ||
		{ (_unit knowsAbout _x) >= 0.1 }
	}
}