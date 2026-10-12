#include "..\..\dialog_defines.hpp"
#include "..\..\hcgp_layout.hpp"

// Initial opening and dashboard resize notifications only; no layout monitor.
params ["_display", ["_dashboardBottom", A3C_MAP_DASH_BG_H], ["_context", []]];
disableSerialization;
private _applied = false;
isNil {
    if (isNull _display) exitWith {};
    private _panel = _display displayCtrl IDC_MAP_HCGP_Parent;
    if (isNull _panel || {_context isEqualTo []}
        || {!((_panel getVariable ["A3C_HCGP_LayoutContext", []]) isEqualTo _context)}
        || {!((missionNamespace getVariable ["A3C_SELECTED_HC_GROUPS_SETTINGS", []]) isEqualTo (_context select 1))}) exitWith {};

    private _stance = _display displayCtrl IDC_MAP_HCGP_STANCES_AUTO_IMG;
    if (isNull _stance || {!finite _dashboardBottom}) exitWith {};
    private _stancePosition = ctrlPosition _stance;
    private _top = (_stancePosition select 1) + (_stancePosition select 3);
    private _showConfirm = !(profileNamespace getVariable ["HC_GROUP_RESPONSE", false]);
    private _confirmHeight = A3C_HCGP_Y(2);
    private _reserve = if (_showConfirm) then {_confirmHeight} else {0};
    // Preserve the reference 2 + 4.5083 + 4.5083 + 2 = 13.0166.
    // Additional statistics rows increase spacing, never listbox capacity.
    private _bottom = _dashboardBottom max (_top + 2 * A3C_HCGP_LIST_H + _reserve);
    private _height = ((_bottom - _top - _reserve) / 2) min A3C_HCGP_LIST_H;
    private _secondTop = _top + _height;
    {
        _x params ["_id", "_y"];
        private _control = _display displayCtrl _id;
        if (!isNull _control) then {
            private _position = ctrlPosition _control;
            _position set [1, _y];
            _position set [3, _height];
            _control ctrlSetPosition _position;
            _control ctrlCommit 0;
        };
    } forEach [
        [IDC_MAP_HCGP_LISTBOX_BEHAVIOUR, _top],
        [IDC_MAP_HCGP_LISTBOX_COMBATMODE, _top],
        [IDC_MAP_HCGP_LISTBOX_FORMATION, _secondTop],
        [IDC_MAP_HCGP_LISTBOX_TEAMCOLOR, _secondTop]
    ];
    {
        private _control = _display displayCtrl _x;
        if (!isNull _control) then {
            private _position = ctrlPosition _control;
            _position set [1, _secondTop + _height];
            _position set [3, _confirmHeight];
            _control ctrlSetPosition _position;
            _control ctrlCommit 0;
            _control ctrlShow _showConfirm;
        };
    } forEach [IDC_MAP_HCGP_CONFIRM_BG, IDC_MAP_HCGP_CONFIRM_BTN];
    // Retain the intentional origin and existing action-column dimensions.
    // Grow only the clipping viewport when a taller dashboard requires it.
    private _position = ctrlPosition _panel;
    _position set [3, (A3C_HCGP_Y(19)) max _bottom];
    _panel ctrlSetPosition _position;
    _panel ctrlCommit 0;
    _applied = true;
};
_applied
