// Main
A3C_PREP(ctrlGroup);
A3C_PREP(highCommand_actionsFetch);

// Handlers.
A3C_PREP_SUBDIR(handlers,onLbChange);
A3C_PREP_SUBDIR(handlers,onKeyDown_remoteVehicle);
A3C_PREP_SUBDIR(handlers,onKeyUp_remoteVehicle);
A3C_PREP_SUBDIR(handlers,onMouseButtonDown_remoteVehicle);
A3C_PREP_SUBDIR(handlers,Tree_onBoxClick);
A3C_PREP_SUBDIR(handlers,Tree_onTvChange);

// Public functions.
A3C_PREP_SUBDIR(public,activateGoCode);
A3C_PREP_SUBDIR(public,highCommand_actionDispatchBoardGroupsToVehicle);
A3C_PREP_SUBDIR(public,highCommand_actionsLabel);
A3C_PREP_SUBDIR(public,highCommand_actionSuppressionStart);
A3C_PREP_SUBDIR(public,addDownkey);
A3C_PREP_SUBDIR(public,addLbEntry);
A3C_PREP_SUBDIR(public,blockKeyDownEvent);
A3C_PREP_SUBDIR(public,createDashBoard);
A3C_PREP_SUBDIR(public,findBestShooters);
A3C_PREP_SUBDIR(public,getBackgroundColor);
A3C_PREP_SUBDIR(public,getColorArrayWithOpacity);
A3C_PREP_SUBDIR(public,getKeybindTranslation);
A3C_PREP_SUBDIR(public,getKeyBool);
A3C_PREP_SUBDIR(public,lbSetCurSel);
A3C_PREP_SUBDIR(public,refreshUnitSelectionUi);
A3C_PREP_SUBDIR(public,releaseMenuKey);
A3C_PREP_SUBDIR(public,resetPlayerGroup);
A3C_PREP_SUBDIR(public,resizeTeamColors_XWH);
A3C_PREP_SUBDIR(public,resizeTeamColors_Y);
A3C_PREP_SUBDIR(public,toggleActionMenuAbility);
A3C_PREP_SUBDIR(public,toggleGocodeCtrls);
A3C_PREP_SUBDIR(public,Tree_addItem);
A3C_PREP_SUBDIR(public,Tree_adjustTopRow);
A3C_PREP_SUBDIR(public,Tree_ctrlDelete);
A3C_PREP_SUBDIR(public,Tree_labelItems);
A3C_PREP_SUBDIR(public,Tree_openOrCollapse);
A3C_PREP_SUBDIR(public,Tree_squad_getSubParentCount);
A3C_PREP_SUBDIR(public,Tree_synchronize);

// Responses.
A3C_PREP_SUBDIR(responses,actionDeleteGroupsUiResponse);
A3C_PREP_SUBDIR(responses,mapRadial_actionStandardResponse);