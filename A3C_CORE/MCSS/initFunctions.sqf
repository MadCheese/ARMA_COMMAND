#include "script_component.hpp"
#include "XEH_PREP.hpp"




MCSS_RealBB_Vehicles = if (!isNil 'MCSS_RealBB_Vehicles') then {MCSS_RealBB_Vehicles} else {[]};

//-- DEBUG
MCSS_RED_LINES = [];
MCSS_GREEN_LINES = [];
MCSS_BLUE_LINES = [];