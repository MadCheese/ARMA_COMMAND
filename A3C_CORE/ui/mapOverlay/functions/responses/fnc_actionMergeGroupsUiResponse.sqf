#include "..\..\dialog_defines.hpp"
#include "..\..\..\SHARED\shared_ui_defines.hpp"

//-- Note: This action does not have a action script itself. Instead, the mouseDown eventhandler registers A3C_isMergeGroupActive
//--> click on icon will execute the action, so we do not need A3C_ui_mapOverlay_fnc_HCGP_actionMergeGroups


[] call A3C_ui_mapOverlay_fnc_close_HCGP_Parent;
A3C_isMergeGroupActive = true;
hint "Click on the group to join";
waituntil {!visibleMap OR {!(A3C_isMergeGroupActive)}};
hint "";
A3C_isMergeGroupActive = false;