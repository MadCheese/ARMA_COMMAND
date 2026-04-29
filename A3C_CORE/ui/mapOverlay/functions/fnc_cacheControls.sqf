#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _controls = createHashMapFromArray [
    ["inputCapture", _display displayCtrl IDC_MAP_INPUT_CAPTURE],
    ["inputBlocker", _display displayCtrl IDC_MAP_INPUT_BLOCKER],

    ["ufsbBackground", _display displayCtrl IDC_MAP_UFSB_BACKGROUND],
    ["ufsbFrame", _display displayCtrl IDC_MAP_UFSB_FRAME],

    ["topExtrasBackground", _display displayCtrl IDC_MAP_TOP_EXTRAS_BACKGROUND],
    ["topExtrasFrame", _display displayCtrl IDC_MAP_TOP_EXTRAS_FRAME],
    ["topRefreshImg", _display displayCtrl IDC_MAP_TOP_REFRESH_IMG],
    ["topRefreshBtn", _display displayCtrl IDC_MAP_TOP_REFRESH_BTN],
    ["topDisbandImg", _display displayCtrl IDC_MAP_TOP_DISBAND_IMG],
    ["topDisbandBtn", _display displayCtrl IDC_MAP_TOP_DISBAND_BTN],
    ["topToggleTrackerImg", _display displayCtrl IDC_MAP_TOP_TOGGLETRACKER_IMG],
    ["topToggleTrackerBtn", _display displayCtrl IDC_MAP_TOP_TOGGLETRACKER_BTN],

    ["ufsbStanceTravelImg", _display displayCtrl IDC_MAP_UFSB_STANCE_TRAVEL_IMG],
    ["ufsbStanceTravelBtn", _display displayCtrl IDC_MAP_UFSB_STANCE_TRAVEL_BTN],
    ["ufsbWpSpeedImg", _display displayCtrl IDC_MAP_UFSB_WP_SPEED_IMG],
    ["ufsbWpSpeedBtn", _display displayCtrl IDC_MAP_UFSB_WP_SPEED_BTN],
    ["ufsbStanceArrivalImg", _display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_IMG],
    ["ufsbStanceArrivalBtn", _display displayCtrl IDC_MAP_UFSB_STANCE_ARRIVAL_BTN],
    ["ufsbCombatModeImg", _display displayCtrl IDC_MAP_UFSB_COMBATMODE_IMG],
    ["ufsbCombatModeBtn", _display displayCtrl IDC_MAP_UFSB_COMBATMODE_BTN],
    ["ufsbWpActionImg", _display displayCtrl IDC_MAP_UFSB_WPACTION_IMG],
    ["ufsbWpActionBtn", _display displayCtrl IDC_MAP_UFSB_WPACTION_BTN],
    ["ufsbWpFormationImg", _display displayCtrl IDC_MAP_UFSB_WPFORMATION_IMG],
    ["ufsbWpFormationBtn", _display displayCtrl IDC_MAP_UFSB_WPFORMATION_BTN],
    ["ufsbSpacing", _display displayCtrl IDC_MAP_UFSB_SPACING],
    ["ufsbWpConditionImg", _display displayCtrl IDC_MAP_UFSB_WPCONDITION_IMG],
    ["ufsbWpConditionBtn", _display displayCtrl IDC_MAP_UFSB_WPCONDITION_BTN],
    ["ufsbTimeoutPopup", _display displayCtrl IDC_MAP_UFSB_TIMEOUT_POPUP],
    ["ufsbUndoImg", _display displayCtrl IDC_MAP_UFSB_UNDO_IMG],
    ["ufsbUndoBtn", _display displayCtrl IDC_MAP_UFSB_UNDO_BTN],
    ["ufsbCancelImg", _display displayCtrl IDC_MAP_UFSB_CANCEL_IMG],
    ["ufsbCancelBtn", _display displayCtrl IDC_MAP_UFSB_CANCEL_BTN],
    ["ufsbHoldImg", _display displayCtrl IDC_MAP_UFSB_HOLD_IMG],
    ["ufsbHoldBtn", _display displayCtrl IDC_MAP_UFSB_HOLD_BTN],
    ["ufsbContinueImg", _display displayCtrl IDC_MAP_UFSB_CONTINUE_IMG],
    ["ufsbContinueBtn", _display displayCtrl IDC_MAP_UFSB_CONTINUE_BTN],

    ["ufsbCommitAll", _display displayCtrl IDC_MAP_UFSB_CommitAll],
    ["ufsbCommitSelected", _display displayCtrl IDC_MAP_UFSB_CommitSelected],
    ["ufsbExit", _display displayCtrl IDC_MAP_UFSB_Exit]
];

uiNamespace setVariable [QGVAR(controls), _controls];