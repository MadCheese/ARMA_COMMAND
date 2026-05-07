//-- filter input array of units to those that carry any placeable explosives

#include "..\script_component.hpp"

params ["_units"];

private _cfgMagazines = configFile >> "CfgMagazines";
private _explosiveNameSounds = ["satchelcharge", "mine"];

_units select {
	private _unit = _x;

	(magazines _unit) findIf {
		getText (_cfgMagazines >> _x >> "nameSound") in _explosiveNameSounds
	} != -1
}