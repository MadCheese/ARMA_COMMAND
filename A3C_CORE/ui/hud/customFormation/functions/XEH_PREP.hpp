/*
    Component framework and display lifecycle.

    These functions remain in the functions root because they form the
    reusable dialog-component infrastructure and primary entry point.
*/
A3C_PREP(cacheControls);
A3C_PREP(cacheGroups);
A3C_PREP(ctrl);
A3C_PREP(groupCtrl);
A3C_PREP(onLoad);
A3C_PREP(onUnload);
A3C_PREP(refresh);
A3C_PREP(spawnDialog);

/*
    Main-dialog control configuration and selection state.
*/
A3C_PREP_SUBDIR(controls,configureTeamButtons);
A3C_PREP_SUBDIR(controls,selectTeam);

/*
    Formation-coordinate validation, conversion, and resampling.
*/
A3C_PREP_SUBDIR(geometry,getGridPositionFromRelativeData);
A3C_PREP_SUBDIR(geometry,getRelativeData);
A3C_PREP_SUBDIR(geometry,isValidFormationData);
A3C_PREP_SUBDIR(geometry,sampleFormationStroke);

/*
    Custom-formation runtime and unit control.
*/
A3C_PREP_SUBDIR(runtime,activateFormation);
A3C_PREP_SUBDIR(runtime,clearFormation);
A3C_PREP_SUBDIR(runtime,formationManager);
A3C_PREP_SUBDIR(runtime,formationTick);
A3C_PREP_SUBDIR(runtime,getCurrentTeamData);
A3C_PREP_SUBDIR(runtime,getDirRange);

/*
    Formation drawing and display-local visualization controls.
*/
A3C_PREP_SUBDIR(visuals,createVisualDot);
A3C_PREP_SUBDIR(visuals,createVisualLine);
A3C_PREP_SUBDIR(visuals,drawDot);
A3C_PREP_SUBDIR(visuals,restoreFormationVisuals);

/*
    Saved-formation persistence, compatibility, loading-list presentation,
    and preset-management display.
*/
A3C_PREP_SUBDIR(presets,deleteSelectedSavedFormations);
A3C_PREP_SUBDIR(presets,getSavedFormationCompatibility);
A3C_PREP_SUBDIR(presets,labelListbox);
A3C_PREP_SUBDIR(presets,manageOnLoad);
A3C_PREP_SUBDIR(presets,manageOnUnload);
A3C_PREP_SUBDIR(presets,openSavedFormationManager);
A3C_PREP_SUBDIR(presets,populateSavedFormationManager);
A3C_PREP_SUBDIR(presets,saveButton);
A3C_PREP_SUBDIR(presets,updateSavedFormationManager);

/*
    UI event handlers.
*/
A3C_PREP_SUBDIR(handlers,onButtonClick);
A3C_PREP_SUBDIR(handlers,onListboxSelectionChanged);
A3C_PREP_SUBDIR(handlers,onManageButtonClick);
A3C_PREP_SUBDIR(handlers,onManageCheckedChanged);
A3C_PREP_SUBDIR(handlers,onManageRowButtonClick);
A3C_PREP_SUBDIR(handlers,onMouseButtonDown);
A3C_PREP_SUBDIR(handlers,onMouseButtonUp);
A3C_PREP_SUBDIR(handlers,onMouseMoving);
A3C_PREP_SUBDIR(handlers,onSaveMouseButtonDown);