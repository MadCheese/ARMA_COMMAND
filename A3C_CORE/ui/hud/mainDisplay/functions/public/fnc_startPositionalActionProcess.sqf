// A3C_UI_mainDisplay_fnc_startPositionalActionProcess

//---------------------------- SHARED POSITIONAL STARTUP FUNCTION

params [
	["_isBusy", false, [false]],
	["_actionID", -1, [0, ""]],
	["_iconType", "", [""]],
	["_iconColor", [1,1,1,1], [[]]],
	["_objectPlacerClass", "", [""]],
	["_objectPlacerColorString", "", [""]]
];



if (_isBusy) exitWith {
	systemChat "A3C: Please wait for your last order to complete";
};


[] spawn {
	//-- disable action menu again since objectPLacer vehicle can be rotated which would trigger the action menu again.
	sleep 0.1; //-- delay needed to not compete with the enabling via closing radial etc
	"DISABLE" call A3C_ui_shared_fnc_toggleActionMenuAbility;
};

//-- UI reaction
A3C_DISABLE_RADIAL = true;
[] call A3C_ui_radialMenu_fnc_closeDisplay;

{
	player groupSelectUnit [_x, false];
} forEach units player;

showCommandingMenu "";

//-- Positional UI
A3C_UI_HUD_3D_TAG_ICON_TYPE = _iconType;
A3C_UI_HUD_3D_TAG_ICON_COL = [_iconColor, 0.7] call A3C_ui_shared_fnc_getColorArrayWithOpacity;
A3C_UI_HUD_3D_TAG_reposition = true;

if (A3C_CURRENT_COMMAND_LEVEL == "SQUAD") then {
	A3C_AI_Squad_Action_ID = _actionID;
} else {
	A3C_AI_HighCommand_Action_ID = _actionID;
};

//-- Spawn object placer
if (_objectPlacerClass isNotEqualTo "") then {

	// systemchat str _objectPlacerClass;

	private _placer = createVehicleLocal [_objectPlacerClass, [0, 0, 100], [], 0, "CAN_COLLIDE"];

	_placer allowDamage false;
	_placer enableSimulation false;
	_placer hideObject true;
	_placer setPhysicsCollisionFlag false;

	private _safePos = [screenToWorld [0.5, 0.5], [0, 100]] call MCSS_fnc_getSafePos;

	if (!isNil "_safePos" && {_safePos isNotEqualTo []}) then {
		_placer setPos _safePos;
	};

	//-- Color object
	if (_objectPlacerColorString isNotEqualTo "") then {
		private _colorStringFinal = "#(rgb,8,8,3)color" + _objectPlacerColorString;

		private _hiddenSelections = getArray (
			configFile >> "CfgVehicles" >> typeOf _placer >> "hiddenSelections"
		);

		private _selectionCount = count _hiddenSelections;

		if (_selectionCount > 0) then {
			for "_i" from 0 to (_selectionCount - 1) do {
				_placer setObjectTexture [_i, _colorStringFinal];
			};
		} else {
			_placer setObjectTexture [0, _colorStringFinal];
		};
	};

	//-- Delay needed so HUD draw script does not immediately move/destroy it
	_placer spawn {
		sleep 0.2;

		_this hideObject false;
		A3C_OBJECTPLACER = _this;
	};
};