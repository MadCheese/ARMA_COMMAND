#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _interactionDisplay = uiNamespace getVariable [QGVAR(display), displayNull];
private _overlayDisplay = uiNamespace getVariable [QGVAR(overlayDisplay), displayNull];

private _groups = createHashMap;

if !(isNull _interactionDisplay) then {
    _groups set [
        "interactionButtons",
        [
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_FORM_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_TRAVEL_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_SPEED_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_DESTINATION_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_GOCODE_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_WPMODE_BTN,
            _interactionDisplay displayCtrl IDC_SQUAD_PLACEMENT_HIDE_BTN
        ] select {!isNull _x}
    ];
};

if !(isNull _overlayDisplay) then {
    _groups set [
        "overlayImages",
        [
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_TRAVEL_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_DESTINATION_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_FORM_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_SPEED_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_GOCODE_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_WPMODE_IMG,
            _overlayDisplay displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_HIDE_IMG
        ] select {!isNull _x}
    ];
};

uiNamespace setVariable [QGVAR(groups), _groups];