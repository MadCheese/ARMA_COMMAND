// Internal dialog functions.
A3C_PREP(cacheGroups);
A3C_PREP(cacheControls);
A3C_PREP(ctrl);
A3C_PREP(groupCtrl);
A3C_PREP(ctrlGroup);
A3C_PREP(refresh);
A3C_PREP(onLoad);
A3C_PREP(onUnload);

// UI event handlers.
A3C_PREP_SUBDIR(handlers,HCGP_onActionMouseButtonDown);
A3C_PREP_SUBDIR(handlers,HCGP_onConfirmButton);
A3C_PREP_SUBDIR(handlers,HCWP_onLbChange);
A3C_PREP_SUBDIR(handlers,HCGP_onStanceButton);

A3C_PREP_SUBDIR(handlers,HCWP_onConfirmButton);
A3C_PREP_SUBDIR(handlers,HCWP_onConfirmButtonMulti);
A3C_PREP_SUBDIR(handlers,HCWP_onDeleteButton);
A3C_PREP_SUBDIR(handlers,HCGP_onLbChange);
A3C_PREP_SUBDIR(handlers,HCWP_onLbChangeMulti);

A3C_PREP_SUBDIR(handlers,HXT_OMBD_prepLoopOrSyncSQ);
A3C_PREP_SUBDIR(handlers,HXT_OMBU_setLoopOrSyncSQ);

A3C_PREP_SUBDIR(handlers,MAP_onKeyDown);
A3C_PREP_SUBDIR(handlers,onDragMapHCWP);
A3C_PREP_SUBDIR(handlers,onDragMapItem);
A3C_PREP_SUBDIR(handlers,onDragMapStandard);
A3C_PREP_SUBDIR(handlers,onKeyDown);
A3C_PREP_SUBDIR(handlers,onKeyUp);
A3C_PREP_SUBDIR(handlers,onMouseButtonDown);
A3C_PREP_SUBDIR(handlers,onMouseButtonUp);
A3C_PREP_SUBDIR(handlers,onMouseMoving);
A3C_PREP_SUBDIR(handlers,onToggleEnemyTracker);
A3C_PREP_SUBDIR(handlers,UFSB_onActionMouseZ);
A3C_PREP_SUBDIR(handlers,UFSB_onCancelButton);
A3C_PREP_SUBDIR(handlers,UFSB_onCombatModeButton);
A3C_PREP_SUBDIR(handlers,UFSB_onCommitButton);
A3C_PREP_SUBDIR(handlers,UFSB_onConditionButton);
A3C_PREP_SUBDIR(handlers,UFSB_onDisbandHcButton);
A3C_PREP_SUBDIR(handlers,UFSB_onExitButton);
A3C_PREP_SUBDIR(handlers,UFSB_onFormationButton);
A3C_PREP_SUBDIR(handlers,UFSB_onStanceArrivalButton);
A3C_PREP_SUBDIR(handlers,UFSB_onStanceTravelButton);
A3C_PREP_SUBDIR(handlers,UFSB_onSubselectionButton);
A3C_PREP_SUBDIR(handlers,UFSB_onTeamColorButton);
A3C_PREP_SUBDIR(handlers,UFSB_onToggleBar);
A3C_PREP_SUBDIR(handlers,UFSB_onUndoButton);
A3C_PREP_SUBDIR(handlers,UFSB_onWaypointSpeedButton);

//-- public functions
A3C_PREP_SUBDIR(public,adjustPolygonEdge);
A3C_PREP_SUBDIR(public,adjustPolygonMain);
A3C_PREP_SUBDIR(public,buttonFncContext);
A3C_PREP_SUBDIR(public,close_HCGP_Parent);
A3C_PREP_SUBDIR(public,closeMapOverlay);
A3C_PREP_SUBDIR(public,closeSyncCircleMenu);
A3C_PREP_SUBDIR(public,createEnemyForceTracker);
A3C_PREP_SUBDIR(public,CTEdit_setActive);
A3C_PREP_SUBDIR(public,drawIconVehicleMacro);
A3C_PREP_SUBDIR(public,drawMapUI);
A3C_PREP_SUBDIR(public,drawPolygonFrame);
A3C_PREP_SUBDIR(public,drawThiccLine);
A3C_PREP_SUBDIR(public,findCtrlSafePos);
A3C_PREP_SUBDIR(public,getIconData);
A3C_PREP_SUBDIR(public,getIconsAtMapPos);
A3C_PREP_SUBDIR(public,getOpacity);
A3C_PREP_SUBDIR(public,HCGP_actionMergeGroups);
A3C_PREP_SUBDIR(public,HCGP_actionParaLoadAndDrop);
A3C_PREP_SUBDIR(public,HCGP_activateDashboardEditName);
A3C_PREP_SUBDIR(public,HCGP_openMenu);
A3C_PREP_SUBDIR(public,HCWP_addActions);
A3C_PREP_SUBDIR(public,HCWP_dayTimeZeroComp);
A3C_PREP_SUBDIR(public,HCWP_getWaypointPreCondition);
A3C_PREP_SUBDIR(public,HCWP_openCargoWaypointPrompt);
A3C_PREP_SUBDIR(public,HCWP_openMenu);
A3C_PREP_SUBDIR(public,HCWP_openMenuMulti);
A3C_PREP_SUBDIR(public,isCursorOverControl);
A3C_PREP_SUBDIR(public,isWaypointLoop);
A3C_PREP_SUBDIR(public,openOverlay);
A3C_PREP_SUBDIR(public,rejoinDisbandedToPlayerGroup);
A3C_PREP_SUBDIR(public,refreshMapUiDrawHandler);
A3C_PREP_SUBDIR(public,resetMapClick);
A3C_PREP_SUBDIR(public,resetUnitLoopState);
A3C_PREP_SUBDIR(public,SQWP_goCodeSwitch);
A3C_PREP_SUBDIR(public,SQWP_heliActionSwitch);
A3C_PREP_SUBDIR(public,SQWP_openMenu);
A3C_PREP_SUBDIR(public,squad_cancelArrowDrag);
A3C_PREP_SUBDIR(public,squad_createBposMarkers);
A3C_PREP_SUBDIR(public,squad_deleteBposMarkers);
A3C_PREP_SUBDIR(public,squad_findLastWaypointWithoutPolygon);
A3C_PREP_SUBDIR(public,squad_getActionsArray);
A3C_PREP_SUBDIR(public,sync_loadGroupInVehicle);
A3C_PREP_SUBDIR(public,sync_loadVehicleInVehicle);
A3C_PREP_SUBDIR(public,UFSB_applyPageMode);
A3C_PREP_SUBDIR(public,UFSB_refreshControlBar);
A3C_PREP_SUBDIR(public,setorderWIP);
A3C_PREP_SUBDIR(public,UFSB_spawnTimeoutCtBox);
A3C_PREP_SUBDIR(public,UFSB_toggleSubselectionPopup);


//-- Response functions
A3C_PREP_SUBDIR(responses,actionMergeGroupsUiResponse);
A3C_PREP_SUBDIR(responses,completeWaypointUiResponse);




