#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_getOpacity

params [
	"_color",
	"_object",
	"_index"
];

private _return = _color select [0, 3];

private _opacity = 1;

if (visibleMap) then {
	if (isNull findDisplay IDD_MAP_OVERLAY) then {
		_opacity = 0;
	};
};

if (_opacity == 0) then {
	if (difficulty <= 1) then {
		_opacity = 1;
	};
};

_return pushBack _opacity;

_return