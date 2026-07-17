





if (!isNil "A3C_EVH_DRAW") then {(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw",A3C_EVH_DRAW]};
A3C_EVH_DRAW = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler
[
	"Draw",
	{
		_this call A3C_ui_mapOverlay_fnc_drawMapUI;
	}
]; //add for GPS? Tablet needs to be added each time it is opened


