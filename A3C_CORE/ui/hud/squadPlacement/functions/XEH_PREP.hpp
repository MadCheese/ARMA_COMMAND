// Internal dialog functions.
A3C_PREP(cacheGroups);
A3C_PREP(cacheControls);
A3C_PREP(ctrl);
A3C_PREP(groupCtrl);
A3C_PREP(refresh);
A3C_PREP(onLoad);
A3C_PREP(onUnload);
A3C_PREP(onOverlayLoad);
A3C_PREP(onOverlayUnload);

// UI event handlers.
A3C_PREP_SUBDIR(handlers,onButtonClick);
A3C_PREP_SUBDIR(handlers,onKeyDown);
A3C_PREP_SUBDIR(handlers,onKeyUp);
A3C_PREP_SUBDIR(handlers,onMouseButtonDown);
A3C_PREP_SUBDIR(handlers,onMouseZChanged);

// Public entry points.
A3C_PREP_SUBDIR(public,speedButton);
A3C_PREP_SUBDIR(public,wpModeButton);
A3C_PREP_SUBDIR(public,toggleUIControls);
A3C_PREP_SUBDIR(public,formButton);
A3C_PREP_SUBDIR(public,stanceButtons);
A3C_PREP_SUBDIR(public,goCodeButton);
A3C_PREP_SUBDIR(public,executeOrder);
A3C_PREP_SUBDIR(public,setStance);
A3C_PREP_SUBDIR(public,refreshOverlay);
A3C_PREP_SUBDIR(public,executeUnitPlacement);
A3C_PREP_SUBDIR(public,switchUnitGhostStance);
A3C_PREP_SUBDIR(public,addUnitGhost);
A3C_PREP_SUBDIR(public,removeUnitGhost);
A3C_PREP_SUBDIR(public,createFormation);
A3C_PREP_SUBDIR(public,createBuildingFormation);
A3C_PREP_SUBDIR(public,snapFormation);
A3C_PREP_SUBDIR(public,orientUnitGhosts);
A3C_PREP_SUBDIR(public,positionUnitGhostsLoop);
A3C_PREP_SUBDIR(public,sortBuildingPositionsByAim);