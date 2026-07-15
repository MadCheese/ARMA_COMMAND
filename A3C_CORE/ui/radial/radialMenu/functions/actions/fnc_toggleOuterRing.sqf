#include "..\..\script_component.hpp"

params ["_show"];

{
	_x ctrlShow _show;
} forEach (
	(["radial_outerButtonMacros"] call FUNC(ctrlGroup)) +
	(["radial_outerRingBackgrounds"] call FUNC(ctrlGroup))
);