#include "..\script_component.hpp"

// Intentionally minimal.
// The selection prompt content is populated by external selection-prompt logic.
// This function exists so lifecycle and future refresh calls have a safe target.

[] call FUNC(cacheControls);