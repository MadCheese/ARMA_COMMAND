#include "..\..\script_component.hpp"

DISABLESERIALIZATION;

{
	_x params ["_label", "_class", "_obj", "_cbo", "_img"];

	[_cbo, _label] call A3C_ui_shared_fnc_addLbEntry;

	private _lbIndex = (lbSize _cbo) - 1;
	_cbo lbSetData [_lbIndex, _class];

	switch (A3C_RADIALMODE) do {
		case "BRAIN": {};
		case "VEHS": {
			_img = getText (configFile >> "CfgVehicles" >> _class >> "picture");
		};
	};

	_cbo lbSetPicture [_lbIndex, _img];
} forEach _this;