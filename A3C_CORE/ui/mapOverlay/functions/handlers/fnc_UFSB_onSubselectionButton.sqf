#include "..\..\dialog_defines.hpp"

// A3C_ui_mapOverlay_fnc_UFSB_onSubselectionButton

params [
	"_action",
	"_subSet",
	"_displayId",
	"_originButton",
	"_buttonImageId",
	"_buttonClickerId",
	"_toolTip"
];

private _display = findDisplay _displayId;
private _mapOverlayDisplay = findDisplay IDD_MAP_OVERLAY;

private _originButtonImage =
	_display displayCtrl (_originButton select 0);

private _originButtonClicker =
	_display displayCtrl (_originButton select 1);

private _background1 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_01_BG;

private _background2 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_02_BG;

private _subsetParent1 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_01_Parent;

private _subsetParent2 =
	_display displayCtrl IDC_MAP_UFSB_Subselection_02_Parent;

if (_action == "SQ_COND_TIMEOUT") then {
	["OPEN"] call A3C_ui_mapOverlay_fnc_UFSB_spawnTimeoutCtBox;
} else {
	(
		_mapOverlayDisplay displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP
	) ctrlShow false;
};

if (
	_action == "SQ_ACTION_GRENADE"
	&& {A3C_GREN_MUZZLE == ""}
) then {
	_action = "SQ_ACTION_NONE";
};

if (_action != "SQ_ACTION_GRENADE") then {
	_subsetParent1 ctrlShow false;
	_subsetParent2 ctrlShow false;
	_background1 ctrlShow false;
	_background2 ctrlShow false;
};

// Adjust control frames.
if (
	_subSet == 1
	|| {_action in A3C_AI_GREN_ARRAY}
) then {
	if (_displayId == IDD_MAP_OVERLAY) then {
		private _controlFrameOriginalY =
			A3C_MAP_OVERLAY_GAMEUI_SETTINGSGROUP_Y;

		//~~ ALERT! WHAT IS GOING ON IN TABLET? NO FRAME?
		private _controlFrame = _display displayCtrl 11;
		private _controlFramePosition = ctrlPosition _controlFrame;

		_controlFramePosition set [
			1,
			_controlFrameOriginalY
		];

		private _inputBlocker =
			_display displayCtrl IDC_MAP_INPUT_BLOCKER;

		_inputBlocker ctrlSetPosition _controlFramePosition;
		_inputBlocker ctrlCommit 0;
	};
};

if (_action in A3C_AI_GREN_ARRAY) exitWith {
	private _waypointActionImage =
		_mapOverlayDisplay displayCtrl IDC_MAP_UFSB_WPACTION_IMG;

	private _waypointActionButton =
		_mapOverlayDisplay displayCtrl IDC_MAP_UFSB_WPACTION_BTN;

	_waypointActionImage ctrlSetText getText (
		configFile
			>> "CfgMagazines"
			>> _action
			>> "picture"
	);

	_waypointActionButton ctrlSetToolTip _toolTip;

	A3C_TEMP_ACTION = ["GRENADE", _action];
	A3C_GREN_MUZZLE = _action;

	_subsetParent1 ctrlShow false;
	_subsetParent2 ctrlShow false;
	_background1 ctrlShow false;
	_background2 ctrlShow false;
};

if (
	[
		"SUB_FORM",
		_action
	] call BIS_fnc_inString
) exitWith {
	private _buttonImages = [
		"IamJustHereToreresentIndex0",
		"A3C_CORE\ui\pictures\icon_menu_formDir_Straight.paa",
		"A3C_CORE\ui\pictures\icon_menu_formDir_Right.paa",
		"A3C_CORE\ui\pictures\icon_menu_formDir_Left.paa",
		"A3C_CORE\ui\pictures\icon_menu_formDir_split.paa",
		"\a3\ui_f\data\Map\Markers\Military\circle_ca.paa"
	];

	private _formationId = parseNumber (
		(_action splitString "SUB_FORM") select 0
	);

	A3C_FORMMODE_TEMP = _formationId;

	A3C_SPLIT_UNITS = if (_formationId == 4) then {
		A3C_SELECTED_UNITS
	} else {
		[]
	};

	_originButtonImage ctrlSetText (
		_buttonImages select _formationId
	);

	_originButtonClicker ctrlSetToolTip _toolTip;

	_subsetParent1 ctrlShow false;
	_subsetParent2 ctrlShow false;
	_background1 ctrlShow false;
	_background2 ctrlShow false;
};

switch (_action) do {
	case "SQ_ACTION_NONE": {
		_originButtonImage ctrlSetText
			"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

		_originButtonClicker ctrlSetToolTip _toolTip;

		A3C_TEMP_ACTION = ["NONE", "NONE"];
	};

	case "SQ_ACTION_GRENADE": {
		[
			[
				_buttonImageId,
				_buttonClickerId
			],
			"SQ_ACTION_GRENADE",
			2,
			true
		] call A3C_ui_mapOverlay_fnc_UFSB_toggleSubselectionPopup;
	};

	case "SQ_HELIHEIGHT_MAX": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_1.paa";

		A3C_HELIHEIGHT = 500;
	};

	case "SQ_HELIHEIGHT_HIGH": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_2.paa";

		A3C_HELIHEIGHT = 200;
	};

	case "SQ_HELIHEIGHT_MID": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_3.paa";

		A3C_HELIHEIGHT = 25;
	};

	case "SQ_HELIHEIGHT_MIN": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_Menu_FlyInHeight_4.paa";

		A3C_HELIHEIGHT = 5;
	};

	case "SQ_ACTION_AIR_MOVE": {
		_originButtonImage ctrlSetText
			"\a3\ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: MOVE/NONE || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["LANDING", "NONE"];
	};

	case "SQ_ACTION_LAND_PICKUP": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: PICKUP || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["LANDING", "PICKUP"];
	};

	case "SQ_ACTION_LAND_DROPOFF": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: DROPOFF || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["LANDING", "DROPOFF"];
	};

	case "SQ_ACTION_RAPPELL": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_action_Rappel.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: RAPPEL || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["LANDING", "RAPPEL"];
	};

	case "SQ_ACTION_PARADROP": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_action_paradrop.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: PARADROP || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["PARADROP", "PARADROP"];
	};

	case "SQ_ACTION_SLING": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_SlingUni.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: SLING LOAD/DROP || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["SLINGLOAD", "SLINGLOAD"];
	};

	case "SQ_ACTION_LAND_FULL": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_action_landing.paa";

		_originButtonClicker ctrlSetToolTip
			"WP ACTION: FULL LANDING || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["LANDING", "LANDFINAL"];
	};

	case "SQ_ACTION_SUPPRESSION": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_action_suppression.paa";

		_originButtonClicker ctrlSetToolTip
			"Suppress Area || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["SUPPRESSION", ""];

		if ((A3C_TEMP_CONDITION select 0) == "NONE") then {
			(
				_mapOverlayDisplay
					displayCtrl IDC_MAP_UFSB_WPCONDITION_IMG
			) ctrlSetText
				"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";

			(
				_mapOverlayDisplay
					displayCtrl IDC_MAP_UFSB_WPCONDITION_BTN
			) ctrlSetToolTip
				"WP Condition: GoCode D || Use LMB to open selection or mousewheel to cycle";

			A3C_TEMP_CONDITION = ["GOCODE", "D"];
		};
	};

	case "SQ_ACTION_STATIC": {
		_originButtonImage ctrlSetText
			"\A3\Static_f_gamma\data\ui\gear_StaticTurret_MG_high_CA.paa";

		_originButtonClicker ctrlSetToolTip
			"Pack or unpack static weapon || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["STATIC", []];
	};

	case "SQ_ACTION_CTRL_DET": {
		_originButtonImage ctrlSetText
			"\a3\ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa";

		_originButtonClicker ctrlSetToolTip
			"Plant Explosive || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = [
			"CTRL_DET",
			[
				objNull,
				""
			]
		];
	};

	case "SQ_ACTION_CARGO_IN": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getIn.paa";

		_originButtonClicker ctrlSetToolTip
			"Pickup || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["CARGO_IN", "PICKUP"];
	};

	case "SQ_ACTION_CARGO_OUT": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_getOut.paa";

		_originButtonClicker ctrlSetToolTip
			"Dropoff || Use LMB to open settings or mousewheel to cycle";

		A3C_TEMP_ACTION = ["CARGO_OUT", ""];
	};

	case "SQ_STANCE_1_AUTO": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";

		_originButtonClicker ctrlSetToolTip
			"TravelStance: AUTO || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE1_TEMP = "AUTO";
	};

	case "SQ_STANCE_1_STAND": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";

		_originButtonClicker ctrlSetToolTip
			"TravelStance: STAND || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE1_TEMP = "UP";
	};

	case "SQ_STANCE_1_CROUCH": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";

		_originButtonClicker ctrlSetToolTip
			"TravelStance: CROUCH || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE1_TEMP = "MIDDLE";
	};

	case "SQ_STANCE_1_PRONE": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";

		_originButtonClicker ctrlSetToolTip
			"TravelStance: PRONE || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE1_TEMP = "DOWN";
	};

	case "SQ_STANCE_2_AUTO": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Auto.paa";

		_originButtonClicker ctrlSetToolTip
			"EndStance: AUTO || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE2_TEMP = "AUTO";
	};

	case "SQ_STANCE_2_STAND": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Stand.paa";

		_originButtonClicker ctrlSetToolTip
			"EndStance: STAND || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE2_TEMP = "UP";
	};

	case "SQ_STANCE_2_CROUCH": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Crouch.paa";

		(
			_mapOverlayDisplay
				displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_BTN
		) ctrlSetToolTip
			"EndStance: CROUCH || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE2_TEMP = "MIDDLE";
	};

	case "SQ_STANCE_2_PRONE": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_stance_Prone.paa";

		_originButtonClicker ctrlSetToolTip
			"EndStance: PRONE || Use LMB to open selection or mousewheel to cycle";

		A3C_STANCE2_TEMP = "DOWN";
	};

	case "SQ_COND_NONE": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_gocode_NONE.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: NONE || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = ["NONE", "NONE"];
	};

	case "SQ_COND_TIMEOUT": {
		_originButtonImage ctrlSetText
			"\a3\ui_f\data\IGUI\RscTitles\MPProgress\timer_ca.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: TIMEOUT || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = [
			"TIMEOUT",
			A3C_TIMEOUT_VAL
		];
	};

	case "SQ_COND_GOCODE_A": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_gocode_A.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: GoCode A || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = ["GOCODE", "A"];
	};

	case "SQ_COND_GOCODE_B": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_gocode_B.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: GoCode B || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = ["GOCODE", "B"];
	};

	case "SQ_COND_GOCODE_C": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_gocode_C.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: GoCode C || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = ["GOCODE", "C"];
	};

	case "SQ_COND_GOCODE_D": {
		_originButtonImage ctrlSetText
			"A3C_CORE\ui\pictures\icon_menu_gocode_D.paa";

		_originButtonClicker ctrlSetToolTip
			"WP Condition: GoCode D || Use LMB to open selection or mousewheel to cycle";

		A3C_TEMP_CONDITION = ["GOCODE", "D"];
	};
};