#include "..\..\script_component.hpp"

A3C_DYNAMIC_BUTTON_ACTIONS = [];

A3C_OUTER_RING_BTN_fnc_1 = [[], {}]; //-- Top Ring Button 1
A3C_OUTER_RING_BTN_fnc_2 = [[], {}]; //-- Top Ring Button 2
A3C_OUTER_RING_BTN_fnc_3 = [[], {}]; //-- Top Ring Button 3
A3C_OUTER_RING_BTN_fnc_4 = [[], {}]; //-- Top Ring Button 4

A3C_OUTER_RING_BTN_fnc_5 = [[], {}]; //-- Right Ring Button 1
A3C_OUTER_RING_BTN_fnc_6 = [[], {}]; //-- Right Ring Button 2
A3C_OUTER_RING_BTN_fnc_7 = [[], {}]; //-- Right Ring Button 3
A3C_OUTER_RING_BTN_fnc_8 = [[], {}]; //-- Right Ring Button 4

A3C_OUTER_RING_BTN_fnc_9 = [[], {}]; //-- Bottom Ring Button 1
A3C_OUTER_RING_BTN_fnc_10 = [[], {}]; //-- Bottom Ring Button 2
A3C_OUTER_RING_BTN_fnc_11 = [[], {}]; //-- Bottom Ring Button 3
A3C_OUTER_RING_BTN_fnc_12 = [[], {}]; //-- Bottom Ring Button 4

A3C_OUTER_RING_BTN_fnc_13 = [[], {}]; //-- Left Ring Button 1
A3C_OUTER_RING_BTN_fnc_14 = [[], {}]; //-- Left Ring Button 2
A3C_OUTER_RING_BTN_fnc_15 = [[], {}]; //-- Left Ring Button 3
A3C_OUTER_RING_BTN_fnc_16 = [[], {}]; //-- Left Ring Button 4

{
	_x ctrlSetTextColor [1, 1, 1, 0.6];
} forEach (["radial_outerButtons"] call FUNC(ctrlGroup));