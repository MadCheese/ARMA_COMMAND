// A3C_UI_mainDisplay_fnc_flattenNumericLeaves

//-- Function to return a flat array of keys that are bound to given inputAction
//-- Currently unused but could end up useful.

params ["_value"];
private _out = [];

if (_value isEqualType 0) exitWith {
	[_value]
};

if (_value isEqualType []) then {
	{
		_out append ([_x] call A3C_UI_mainDisplay_fnc_flattenNumericLeaves);
	} forEach _value;
};

_out
