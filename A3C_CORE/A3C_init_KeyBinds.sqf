if (isDedicated) exitWith {};


//-- These global variable resets stay here instead of A3C_InitValuesClient.sqf so they can be easily reset.
A3C_UI_HUD_KeyDown_EHID = -1;
A3C_UI_HUD_KeyUp_EHID = -1;
A3C_UI_HUD_MouseButtonDown_EHID = -1;
A3C_UI_HUD_MouseZChanged_EHID = -1;

A3C_UI_MAP_KeyDown_EHID = -1;
A3C_UI_MAP_MouseButtonDown_EHID = -1;
A3C_UI_MAP_MouseButtonUp_EHID = -1;



//-- A3C_UI_FNC_ADD_KEYBINDS adds all keybinds when mission begins. Should keybinds get lost due to savegames or else, the refresh buttons will trigger the function to re-establish binds.
A3C_UI_FNC_ADD_KEYBINDS =
{

	//////////////////////////////////////////////////////
	////                  HUD - EVHS		          ////
	//////////////////////////////////////////////////////


	//-- HUD KeyDown
	[
		findDisplay 46,
		"A3C_UI_HUD_KeyDown_EHID",
		"display",
		"KeyDown",
		{
			private _blockDefaultKey = false;
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				//-- #UNCLEAR - note - if this fires when overlay is open, we could get rid of the MainMap KeyDown handler??
				_blockDefaultKey = _this call A3C_ui_mainDisplay_fnc_onKeyDown_Main;
			};
			_blockDefaultKey
		}
	] call A3C_UI_CreateSafeEventhandler;

	//-- HUD KeyUp
	[
		findDisplay 46,
		"A3C_UI_HUD_KeyUp_EHID",
		"display",
		"KeyUp",
		{
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				_this call A3C_ui_mainDisplay_fnc_onKeyUp_Main;
				false
			};
		}
	] call A3C_UI_CreateSafeEventhandler;

	
	//-- HUD MouseButtonDown
	[
		findDisplay 46,
		"A3C_UI_HUD_MouseButtonDown_EHID",
		"display",
		"MouseButtonDown",
		{
			if (!visibleMap) then { //-- NOTE: THis is indeed necessary. If map is active and overlay is hidden, this bind still fires
				_this spawn A3C_ui_mainDisplay_fnc_onMouseButtonDown_Main;
			};
			
			false
		}
	] call A3C_UI_CreateSafeEventhandler;
	
	//-- HUD MouseZChanged
	[
		findDisplay 46,
		"A3C_UI_HUD_MouseZChanged_EHID",
		"display",
		"MouseZChanged",
		{
			//-- visibleMap check not necessary as HUD-MouseZ does not fire on Map
			private _blockDefaultKey = _this call A3C_ui_mainDisplay_fnc_onMouseZChanged;
			_blockDefaultKey
		}
	] call A3C_UI_CreateSafeEventhandler;

	// //-- HUD MouseMoving
	// [
	// 	findDisplay 46,
	// 	"A3C_UI_HUD_MouseMoving_EHID",
	// 	"display",
	// 	"MouseMoving",
	// 	{
	// 		private _blockDefaultKey = _this call A3C_UI_HUD_onMouseMoving;
	// 		_blockDefaultKey
	// 	}
	// ] call A3C_UI_CreateSafeEventhandler;

	//////////////////////////////////////////////////////
	////                  MAP - EVHS		          ////
	//////////////////////////////////////////////////////

	//-- Map KeyDown - this direct map-keybind is currently necessary :) COZ I DON'T UNDERSTAND ARMA lol
	[
		(findDisplay 12 displayctrl 51),
		"A3C_UI_MAP_KeyDown_EHID",
		"ctrl",
		"KeyDown",
		{
			disableSerialization;
			private _return = _this call A3C_ui_mapOverlay_fnc_MAP_onKeyDown;
			_return	
		}
	] call A3C_UI_CreateSafeEventhandler;

};


