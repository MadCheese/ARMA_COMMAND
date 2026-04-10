// fish addEventhandler
// [
// 	"FIRED",
// 	{
// 		params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
// 		hint _weapon;
// 	}
// ];



// if (true) exitWith {};
// // _h =  fish fireAtTarget [t2, "autocannon_40mm_VTOL_01"];
// // systemchat str _h;
// _unit = fish turretUnit [2];
// // _unit reveal [t2, 4];
// // _unit commandSuppressiveFire (position t2);
// // if (true) exitWith {};

// _weapon = ["gatling_20mm_VTOL_01", "cannon_105mm_VTOL_01", "autocannon_40mm_VTOL_01"] select 0;
// _modes = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes"));
// systemchat str _weapon;
// {
// 	hint str _x;
// 	_unit forceWeaponFire [_weapon, _x];
// 	sleep 1;
// } foreach _modes;
// hintSilent "";
// if (true) exitWith {};

// //((crew fish) select 3)


if (isNil 'FISH_TEST_ARRAY') then {
	FISH_TEST_ARRAY = [fish, getPosASL t1, "AUTOCANNON", objNull];
};



FISH_TEST_ARRAY spawn A3C_REMOTE_BLACKFISH;


if (true) exitWith {};


pos1 = (position player) getpos [100,180];
systemchat "TESTING MOVE";
v1 setEffectiveCommander (driver v1);
{
	//	_x domove pos1;
	//	_x moveto pos1;
	//	_x setDestination [pos1,"LEADER PLANNED",false];
} foreach [effectiveCommander v1, driver v1];

v1 commandMove pos1;
(driver v1) commandMove pos1;

