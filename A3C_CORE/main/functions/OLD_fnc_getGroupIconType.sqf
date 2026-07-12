
//-- UNUSED??

params ["_checkedGroup"];

private _groupUnits = units _checkedGroup;



if ((_groupUnits findIf { unitIsUav (vehicle _x) }) >= 0) exitWith {
	"n_uav"
};

if ((_groupUnits findIf { (vehicle _x) isKindOf "Plane" }) >= 0) exitWith {
	"n_plane"
};

if ((_groupUnits findIf { (vehicle _x) isKindOf "Helicopter" }) >= 0) exitWith {
	"n_air"
};

if ((_groupUnits findIf { (vehicle _x) isKindOf "Tank" }) >= 0) exitWith {
	"n_armor"
};

if ((_groupUnits findIf { (vehicle _x) isKindOf "Staticweapon" }) >= 0) exitWith {
	"n_unknown"
};

if ((_groupUnits findIf { (vehicle _x) isKindOf "Car" }) >= 0) exitWith {
	"n_motor_inf"
};

if ((_groupUnits findIf { !isNull objectParent _x }) == -1) exitWith {
	"n_inf"
};


if ((_groupUnits findIf { (vehicle _x) isKindOf "Car" }) >= 0) exitWith {
	"n_motor_inf"
};

"n_unknown"


