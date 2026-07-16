// A3C_ui_mapOverlay_fnc_HCWP_dayTimeZeroComp

/*
  Unorthodox method: Formats a single-digit time component with a leading zero.
 
  Examples:
  0  -> "00"
  5  -> "05"
  10 -> 10
 */
params ["_inputValue"];

if (_inputValue < 10) then {
	_inputValue = if (_inputValue == 0) then {
		"00"
	} else {
		format [
			"0%1",
			_inputValue
		]
	};
};

_inputValue