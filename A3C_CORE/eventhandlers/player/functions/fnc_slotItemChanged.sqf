#include "..\script_component.hpp"

params ["_unit", "_name", "_slot", "_assigned"];

if (_slot isNotEqualTo 612) exitWith {};

private _notGPS = _name isNotEqualTo "A3C_Terminal_NoUAV";

player enableInfoPanelComponent ["left", "MinimapDisplayComponent", _notGPS];
player enableInfoPanelComponent ["right", "MinimapDisplayComponent", _notGPS];