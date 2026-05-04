#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _interactionDisplay = uiNamespace getVariable [QGVAR(display), displayNull];
private _overlayDisplay = uiNamespace getVariable [QGVAR(overlayDisplay), displayNull];

private _controls = createHashMap;

if !(isNull _interactionDisplay) then {
    _controls set ["formButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_FORM_BTN];
    _controls set ["travelButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_TRAVEL_BTN];
    _controls set ["speedButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_SPEED_BTN];
    _controls set ["destinationButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_DESTINATION_BTN];
    _controls set ["goCodeButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_GOCODE_BTN];
    _controls set ["wpModeButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_WPMODE_BTN];
    _controls set ["hideButton", _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_HIDE_BTN];
};

if !(isNull _overlayDisplay) then {
    _controls set ["overlayTravelImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_TRAVEL_IMG];
    _controls set ["overlayDestinationImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_DESTINATION_IMG];
    _controls set ["overlayFormImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_FORM_IMG];
    _controls set ["overlaySpeedImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_SPEED_IMG];
    _controls set ["overlayGoCodeImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_GOCODE_IMG];
    _controls set ["overlayBackground", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_BG];
    _controls set ["overlayWpModeImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_WPMODE_IMG];
    _controls set ["overlayHideImage", _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_HIDE_IMG];
};

uiNamespace setVariable [QGVAR(controls), _controls];