#include "..\script_component.hpp"

// Keep this even when the dialog has no cached groups yet.
uiNamespace setVariable [QGVAR(groups), createHashMap];