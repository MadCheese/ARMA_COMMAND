#include "..\script_component.hpp"

private _hasUnits = !isNil "A3C_UI_squadPlacement_units" && {
    (count A3C_UI_squadPlacement_units) > 0
};

if (_hasUnits) then {
    [] call FUNC(refreshOverlay);
};