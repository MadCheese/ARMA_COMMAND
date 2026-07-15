#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup

params [
	"_originButton",
	"_actionButton",
	"_subSet",
	"_doToggleControls"
];

private _displayId = IDD_MAP_OVERLAY;
private _display = findDisplay _displayId;

(_display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP) ctrlShow false;

// Reassign stance controls to aircraft actions while on the aircraft page.
if (A3C_MAP_CommandMode == "AIR") then {
	if (_actionButton == "SQ_STANCE_1") then {
		_actionButton = "SQ_HELIHEIGHT";
	};

	if (_actionButton == "SQ_STANCE_2") then {
		_actionButton = "SQ_ACTION";
	};
};

private _originButtonImage = _originButton select 0;
private _originButtonClicker = _originButton select 0;

private _controlFrameOriginalY =
	A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y;

private _controlFrame = _display displayCtrl 11;
private _controlFramePosition = ctrlPosition _controlFrame;

private _subsetControl1 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_01_Parent;

private _subsetControl2 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_02_Parent;

private _shiftFactorX = 0;
private _selectionAmount = 0;
private _buttonImages = [];
private _subsetActionStrings = [];
private _doExit = false;

private _subsetControls = if (_subSet == 1) then {
	[
		[
			IDC_MAP_UFSB_Subselection_01_IMG_01,
			IDC_MAP_UFSB_Subselection_01_BTN_01
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_02,
			IDC_MAP_UFSB_Subselection_01_BTN_02
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_03,
			IDC_MAP_UFSB_Subselection_01_BTN_03
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_04,
			IDC_MAP_UFSB_Subselection_01_BTN_04
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_05,
			IDC_MAP_UFSB_Subselection_01_BTN_05
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_06,
			IDC_MAP_UFSB_Subselection_01_BTN_06
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_07,
			IDC_MAP_UFSB_Subselection_01_BTN_07
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_08,
			IDC_MAP_UFSB_Subselection_01_BTN_08
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_09,
			IDC_MAP_UFSB_Subselection_01_BTN_09
		],
		[
			IDC_MAP_UFSB_Subselection_01_IMG_10,
			IDC_MAP_UFSB_Subselection_01_BTN_10
		]
	]
} else {
	[
		[
			IDC_MAP_UFSB_Subselection_02_IMG_01,
			IDC_MAP_UFSB_Subselection_02_BTN_01
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_02,
			IDC_MAP_UFSB_Subselection_02_BTN_02
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_03,
			IDC_MAP_UFSB_Subselection_02_BTN_03
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_04,
			IDC_MAP_UFSB_Subselection_02_BTN_04
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_05,
			IDC_MAP_UFSB_Subselection_02_BTN_05
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_06,
			IDC_MAP_UFSB_Subselection_02_BTN_06
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_07,
			IDC_MAP_UFSB_Subselection_02_BTN_07
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_08,
			IDC_MAP_UFSB_Subselection_02_BTN_08
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_09,
			IDC_MAP_UFSB_Subselection_02_BTN_09
		],
		[
			IDC_MAP_UFSB_Subselection_02_IMG_10,
			IDC_MAP_UFSB_Subselection_02_BTN_10
		]
	]
};

// Reset subset button controls.
if (_subSet == 1) then {
	{
		_x ctrlSetText "";
	} forEach (
		["map_ufsb_subSet_1_images"] call FUNC(ctrlGroup)
	);

	{
		_x buttonSetAction "";
	} forEach (
		["map_ufsb_subSet_1_buttons"] call FUNC(ctrlGroup)
	);
};

if (_subSet == 2) then {
	{
		_x ctrlSetText "";
	} forEach (
		["map_ufsb_subSet_2_images"] call FUNC(ctrlGroup)
	);

	{
		_x buttonSetAction "";
	} forEach (
		["map_ufsb_subSet_2_buttons"] call FUNC(ctrlGroup)
	);
};

// Create subset UI data.
switch (_actionButton) do {
	case "SQ_STANCE_1": {
		_shiftFactorX = 0;
		_selectionAmount = 4;

		_buttonImages = [
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
		];

		_subsetActionStrings = [
			"SQ_STANCE_1_AUTO",
			"SQ_STANCE_1_STAND",
			"SQ_STANCE_1_CROUCH",
			"SQ_STANCE_1_PRONE"
		];
	};

	case "SQ_HELIHEIGHT": {
		_shiftFactorX = -1;
		_selectionAmount = 4;

		_buttonImages = [
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa",
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa",
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa",
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa"
		];

		_subsetActionStrings = [
			"SQ_HELIHEIGHT_MAX",
			"SQ_HELIHEIGHT_HIGH",
			"SQ_HELIHEIGHT_MID",
			"SQ_HELIHEIGHT_MIN"
		];
	};

	case "SQ_STANCE_2": {
		_shiftFactorX = -1;
		_selectionAmount = 4;

		_buttonImages = [
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa",
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa"
		];

		_subsetActionStrings = [
			"SQ_STANCE_2_AUTO",
			"SQ_STANCE_2_STAND",
			"SQ_STANCE_2_CROUCH",
			"SQ_STANCE_2_PRONE"
		];
	};

	case "SQ_ACTION": {
		if (count A3C_SELECTED_UNITS == 0) exitWith {
			_doExit = true;
		};

		private _actionArray = [];

		if (A3C_MAP_CommandMode == "INF") then {
			_subsetActionStrings pushBackUnique "SQ_ACTION_NONE";

			_buttonImages = [
				"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa"
			];

			_actionArray = [
				A3C_SELECTED_UNITS
			] call A3C_ui_mapOverlay_fnc_squad_getActionsArray;
		};

		if (A3C_MAP_CommandMode == "AIR") then {
			_actionArray = [
				"SQ_AIR_MOVE",
				"SQ_LAND_PICKUP",
				"SQ_LAND_DROPOFF",
				"SQ_RAPPELL",
				"SQ_PARADROP",
				"SQ_SLING",
				"SQ_LAND_FULL"
			];
		};

		_selectionAmount = count _actionArray;

		_shiftFactorX = (
			floor (count _actionArray / 3)
		) max 0;

		_shiftFactorX = _shiftFactorX * -1;

		if ("GRENADE" in _actionArray) then {
			[
				0,
				false
			] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;

			if (A3C_GREN_MUZZLE != "") then {
				_buttonImages pushBackUnique getText (
					configFile
						>> "CfgMagazines"
						>> A3C_GREN_MUZZLE
						>> "picture"
				);
			} else {
				_buttonImages pushBackUnique
					"A3C_CORE\ui\pictures\icon_menu_smokeGrey.paa";
			};

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_GRENADE";
		};

		if ("SUPPRESSION" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_SUPPRESSION";
		};

		if ("STATIC" in _actionArray) then {
			_buttonImages pushBackUnique
				"\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_STATIC";
		};

		if ("CTRL_DET" in _actionArray) then {
			_buttonImages pushBackUnique
				"\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_CTRL_DET";
		};

		if ("CARGO_IN" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_CARGO_IN";
		};

		if ("CARGO_OUT" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_CARGO_OUT";
		};

		if ("SQ_AIR_MOVE" in _actionArray) then {
			_buttonImages pushBackUnique
				"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_AIR_MOVE";
		};

		if ("SQ_LAND_PICKUP" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_LAND_PICKUP";
		};

		if ("SQ_LAND_DROPOFF" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_LAND_DROPOFF";
		};

		if ("SQ_RAPPELL" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_RAPPELL";
		};

		if ("SQ_PARADROP" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_PARADROP";
		};

		if ("SQ_SLING" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_slingUNI.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_SLING";
		};

		if ("SQ_LAND_FULL" in _actionArray) then {
			_buttonImages pushBackUnique
				"A3C_CORE\ui\pictures\icon_menu_action_landing.paa";

			_subsetActionStrings pushBackUnique
				"SQ_ACTION_LAND_FULL";
		};

		ctrlSetFocus (
			_display displayCtrl _originButtonClicker
		);
	};

	case "SQ_ACTION_GRENADE": {
		[
			0,
			false
		] call A3C_ai_shared_fnc_gtiGrenade_setGrenadeData;

		_buttonImages = [];

		{
			private _image = getText (
				configFile
					>> "CfgMagazines"
					>> _x
					>> "picture"
			);

			// Do not use pushBackUnique; grenade classes can share images.
			_buttonImages pushBack _image;
			_subsetActionStrings pushBack _x;
		} forEach A3C_AI_GREN_ARRAY;

		_selectionAmount = count A3C_AI_GREN_ARRAY;

		_shiftFactorX = (
			floor (_selectionAmount / 3)
		) max 0;

		_shiftFactorX = _shiftFactorX * -1;
	};

	case "SQ_FORMATION": {
		if (count A3C_SELECTED_UNITS < 2) then {
			_doExit = true;
		};

		_shiftFactorX = -3;
		_selectionAmount = 5;

		_buttonImages = [
			"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa",
			"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa",
			"\a3\ui_f\data\Map\Markers\Military\circle_ca.paa"
		];

		_subsetActionStrings = [
			"SUB_FORM1",
			"SUB_FORM2",
			"SUB_FORM3",
			"SUB_FORM4",
			"SUB_FORM5"
		];
	};

	case "SQ_CONDITION": {
		_shiftFactorX = -1;
		_selectionAmount = 6;

		_buttonImages = [
			"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa",
			"\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa",
			"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa",
			"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa",
			"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa",
			"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa"
		];

		_subsetActionStrings = [
			"SQ_COND_NONE",
			"SQ_COND_TIMEOUT",
			"SQ_COND_GOCODE_A",
			"SQ_COND_GOCODE_B",
			"SQ_COND_GOCODE_C",
			"SQ_COND_GOCODE_D"
		];
	};
};

if (_doExit) exitWith {
	_subsetControl1 ctrlShow false;
	_subsetControl2 ctrlShow false;
};

private _originButtonControl =
	_display displayCtrl _originButtonImage;

private _originButtonPosition = [];

if (_subSet == 1) then {
	_originButtonPosition = ctrlPosition _originButtonControl;
} else {
	private _parentPosition = ctrlPosition (
		_display displayCtrl IDC_MAP_UFSB_Subselection_01_Parent
	);

	private _relativeOriginPosition =
		ctrlPosition _originButtonControl;

	_originButtonPosition = [
		(_parentPosition select 0)
			+ (_relativeOriginPosition select 0),

		(_parentPosition select 1)
			+ (_relativeOriginPosition select 1),

		_relativeOriginPosition select 2,
		_relativeOriginPosition select 3
	];
};

// Create the positional array for the subset bar.
private _subsetBarPosition = [
	(
		(_originButtonPosition select 0)
			+ (
				_shiftFactorX
					* A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W
			)
	) max A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_X_EXPANDED,

	_controlFrameOriginalY
		- (
			A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
				* _subSet
		)
];

// Assign button images and actions.
{
	private _buttonPair = _x;

	if (_forEachIndex < count _buttonImages) then {
		private _actionString =
			_subsetActionStrings select _forEachIndex;

		private _toolTip = switch (_actionString) do {
			case "SQ_ACTION_NONE": {
				"No Action || Use LMB to open settings or mousewheel to cycle"
			};

			case "SQ_ACTION_GRENADE": {
				"Throwables"
			};

			case "SQ_ACTION_SUPPRESSION": {
				"Suppress Area"
			};

			case "SQ_ACTION_STATIC": {
				"Deploy or pack Static Weapon"
			};

			case "SQ_ACTION_CTRL_DET": {
				"Plant Explosive"
			};

			case "SQ_ACTION_CARGO_IN": {
				"Pickup"
			};

			case "SQ_ACTION_CARGO_OUT": {
				"Dropoff"
			};

			case "SQ_COND_NONE": {
				"NONE"
			};

			case "SQ_COND_TIMEOUT": {
				"TIMEOUT"
			};

			case "SQ_COND_GOCODE_A": {
				"GoCode A"
			};

			case "SQ_COND_GOCODE_B": {
				"GoCode B"
			};

			case "SQ_COND_GOCODE_C": {
				"GoCode C"
			};

			case "SQ_COND_GOCODE_D": {
				"GoCode D"
			};

			case "SUB_FORM1": {
				"Orient towards looking direction"
			};

			case "SUB_FORM2": {
				"Orient towards looking direction +90deg"
			};

			case "SUB_FORM3": {
				"Orient towards looking direction -90deg"
			};

			case "SUB_FORM4": {
				"Split Formation (give synchronized Waypoints to units one by one"
			};

			case "SUB_FORM5": {
				"Circle (Drag to adjust size)"
			};

			case "SQ_ACTION_AIR_MOVE": {
				"Move"
			};

			case "SQ_ACTION_LAND_PICKUP": {
				"Pickup"
			};

			case "SQ_ACTION_LAND_DROPOFF": {
				"DropOff"
			};

			case "SQ_ACTION_RAPPELL": {
				"Rappel"
			};

			case "SQ_ACTION_PARADROP": {
				"Paradrop"
			};

			case "SQ_ACTION_SLING": {
				"Sling LOAD/DROP"
			};

			case "SQ_ACTION_LAND_FULL": {
				"Full Landing"
			};

			case "SQ_HELIHEIGHT_MAX": {
				"Max - 500m"
			};

			case "SQ_HELIHEIGHT_HIGH": {
				"High - 200m"
			};

			case "SQ_HELIHEIGHT_MID": {
				"Default - 25m"
			};

			case "SQ_HELIHEIGHT_MIN": {
				"Low - 5m (RISKY)"
			};

			default {
				""
			};
		};

		if (_actionString in A3C_AI_GREN_ARRAY) then {
			_actionString =
				_subsetActionStrings select _forEachIndex;

			_toolTip = "Throw " + getText (
				configFile
					>> "CfgMagazines"
					>> _actionString
					>> "displayNameShort"
			);
		};

		private _imageControl =
			_display displayCtrl (_buttonPair select 0);

		private _buttonControl =
			_display displayCtrl (_buttonPair select 1);

		_imageControl ctrlSetText (
			_buttonImages select _forEachIndex
		);

		_buttonControl ctrlSetToolTip _toolTip;

		_buttonControl buttonSetAction format [
			"['%1',%2,%3,%4,%5,%6,'%7'] call A3C_ui_mapOverlay_fnc_UFSB_onSubselectionButton",
			_actionString,
			_subSet,
			_displayId,
			_originButton,
			_buttonPair select 0,
			_buttonPair select 1,
			_toolTip
		];
	};
} forEach _subsetControls;

// Shortcuts for subset background controls.
private _background1 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_01_BG;

private _background2 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_02_BG;

if (_subSet == 1) then {
	if (_doToggleControls) then {
		if (
			ctrlShown _subsetControl1
				&& {_actionButton == A3C_LAST_SUBSET_ACTION}
		) then {
			_subsetControl1 ctrlShow false;
			_subsetControl2 ctrlShow false;
			_background1 ctrlShow false;
			_background2 ctrlShow false;

			_controlFramePosition set [
				1,
				_controlFrameOriginalY
			];
		} else {
			if (ctrlShown _subsetControl2) then {
				_controlFramePosition set [
					1,
					_controlFrameOriginalY
				];

				_subsetControl1 ctrlShow false;
				_subsetControl2 ctrlShow false;
				_background1 ctrlShow false;
				_background2 ctrlShow false;
			} else {
				_subsetBarPosition set [
					2,
					A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W
						* _selectionAmount
				];

				_subsetBarPosition set [
					3,
					A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
				];

				_controlFramePosition set [
					1,
					_controlFrameOriginalY
						- A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
				];

				_background1 ctrlSetPosition _subsetBarPosition;
				_background1 ctrlCommit 0;
				_background1 ctrlShow true;

				_subsetBarPosition set [
					3,
					A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
						* 1.5
				];

				_subsetControl1 ctrlSetPosition _subsetBarPosition;
				_subsetControl1 ctrlCommit 0;
				_subsetControl1 ctrlShow true;
			};
		};
	};
} else {
	if (_doToggleControls) then {
		if (
			ctrlShown _subsetControl2
				&& {_actionButton == A3C_LAST_SUBSET_ACTION}
		) then {
			_subsetControl2 ctrlShow false;
			_background2 ctrlShow false;

			_controlFramePosition set [
				1,
				_controlFrameOriginalY
					- A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
			];
		} else {
			_controlFramePosition set [
				1,
				_controlFrameOriginalY
					- (
						2
							* A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
					)
			];

			_subsetBarPosition set [
				2,
				A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_W
					* _selectionAmount
			];

			_subsetBarPosition set [
				3,
				A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
			];

			_background2 ctrlSetPosition _subsetBarPosition;
			_background2 ctrlCommit 0;
			_background2 ctrlShow true;

			_subsetBarPosition set [
				3,
				A3C_MAP_OVERLAY_GAMEUI_SUBSEL_BUTTON_H
					* 1.5
			];

			_subsetControl2 ctrlSetPosition _subsetBarPosition;
			_subsetControl2 ctrlCommit 0;
			_subsetControl2 ctrlShow true;
		};
	};
};

private _inputBlocker =
	_display displayCtrl IDC_MAP_INPUT_BLOCKER;

_inputBlocker ctrlSetPosition _controlFramePosition;
_inputBlocker ctrlCommit 0;

A3C_LAST_SUBSET_ACTION = _actionButton;