// Internal dialog functions.
A3C_PREP(cacheGroups);
A3C_PREP(cacheControls);
A3C_PREP(ctrl);
A3C_PREP(groupCtrl);
A3C_PREP(refresh);
A3C_PREP(onLoad);
A3C_PREP(onUnload);

// UI event handlers.
A3C_PREP_SUBDIR(handlers,onMouseMoving);
A3C_PREP_SUBDIR(handlers,onMouseButtonDown);
A3C_PREP_SUBDIR(handlers,onMouseButtonUp);
A3C_PREP_SUBDIR(handlers,onKeyDown);
A3C_PREP_SUBDIR(handlers,onEditKeyDown);
A3C_PREP_SUBDIR(handlers,onButtonClick);

// Public entry points.
A3C_PREP_SUBDIR(public,closeDisplay);
A3C_PREP_SUBDIR(public,confirmDraw);
A3C_PREP_SUBDIR(public,setOrder);
A3C_PREP_SUBDIR(public,normalizeRestrictionValue);
A3C_PREP_SUBDIR(public,setRestrictionMode);