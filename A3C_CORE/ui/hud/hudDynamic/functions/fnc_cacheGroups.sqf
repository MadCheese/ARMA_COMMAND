#include "..\script_component.hpp"

// Dynamic child controls are created externally with ctrlCreate.
// Keep groups available for future dynamic grouping, but empty by default.
uiNamespace setVariable [QGVAR(groups), createHashMap];