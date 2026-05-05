#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

private _controls = createHashMap;

if !(isNull _display) then {
    _controls set ["drawBox", _display displayCtrl IDC_SUPPRESSION_AREA_DRAW_BOX];
    _controls set ["alibiBox", _display displayCtrl IDC_SUPPRESSION_AREA_ALIBI_BOX];
    _controls set ["controlFrame", _display displayCtrl IDC_SUPPRESSION_AREA_CONTROL_FRAME];

    _controls set ["settingsParent", _display displayCtrl IDC_SUPPRESSION_AREA_SETTINGS_PARENT];

    _controls set ["typePicUnlimited", _display displayCtrl IDC_SUPPRESSION_AREA_TYPE_PIC_UNLIMITED];
    _controls set ["typePicPercentage", _display displayCtrl IDC_SUPPRESSION_AREA_TYPE_PIC_PERCENTAGE];
    _controls set ["typePicMagazine", _display displayCtrl IDC_SUPPRESSION_AREA_TYPE_PIC_MAGAZINE];
    _controls set ["typePicTime", _display displayCtrl IDC_SUPPRESSION_AREA_TYPE_PIC_TIME];

    _controls set ["buttonUnlimited", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_UNLIMITED];
    _controls set ["buttonPercentage", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_PERCENTAGE];
    _controls set ["buttonMagazine", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_MAGAZINE];
    _controls set ["buttonTime", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_TIME];

    _controls set ["textUnlimited", _display displayCtrl IDC_SUPPRESSION_AREA_TEXT_UNLIMITED];
    _controls set ["textPercentage", _display displayCtrl IDC_SUPPRESSION_AREA_TEXT_PERCENTAGE];
    _controls set ["textMagazines", _display displayCtrl IDC_SUPPRESSION_AREA_TEXT_MAGAZINES];
    _controls set ["textTime", _display displayCtrl IDC_SUPPRESSION_AREA_TEXT_TIME];

    _controls set ["percentageEdit", _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_PERCENTAGE];
    _controls set ["magazineEdit", _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_MAGAZINES];
    _controls set ["timeEdit", _display displayCtrl IDC_SUPPRESSION_AREA_EDIT_TIME];

    _controls set ["buttonConfirm", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_CONFIRM];
    _controls set ["buttonCancel", _display displayCtrl IDC_SUPPRESSION_AREA_BTN_CANCEL];
};

uiNamespace setVariable [QGVAR(controls), _controls];