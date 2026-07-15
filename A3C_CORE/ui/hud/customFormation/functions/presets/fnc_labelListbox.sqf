#include "..\..\script_component.hpp"

// A3C_UI_customFormation_fnc_labelListbox
//
// Rebuilds the saved-formation list using only entries compatible with the
// current fireteam configuration.
//
// Because filtered listbox rows no longer match profile-array indices, this
// function also builds:
//
//     listbox row 1 -> profile entry N
//     listbox row 2 -> profile entry M
//
// The mapping excludes row 0, which is always CUSTOM.

private _listbox = [
    "savedFormations"
] call FUNC(ctrl);

if (isNull _listbox) exitWith {};

lbClear _listbox;

[_listbox, "CUSTOM"] call A3C_ui_shared_fnc_addLbEntry;

private _savedFormations =
    profileNamespace getVariable [
        "A3C_C_FORMATIONS_SAVED",
        []
    ];

private _currentTeamData =
    [] call FUNC(getCurrentTeamData);

private _visibleSaveIndices = [];
private _blockedCount = 0;

{
    private _compatibility = [
        _x,
        _currentTeamData
    ] call FUNC(getSavedFormationCompatibility);

    private _compatibilityState =
        _compatibility param [
            0,
            "INCOMPATIBLE"
        ];

    if (
        _compatibilityState in [
            "EXACT",
            "ADAPTIVE"
        ]
    ) then {
        private _savedName =
            _x param [
                0,
                "UNNAMED"
            ];

        [_listbox, _savedName] call A3C_ui_shared_fnc_addLbEntry;

        _visibleSaveIndices pushBack
            _forEachIndex;
    } else {
        _blockedCount =
            _blockedCount + 1;
    };
} forEach _savedFormations;

uiNamespace setVariable [
    "A3C_UI_CustomFormation_VisibleSaveIndices",
    _visibleSaveIndices
];

uiNamespace setVariable [
    "A3C_UI_CustomFormation_BlockedSaveCount",
    _blockedCount
];

/*
    The CUSTOM entry always explains the filtering policy.
*/
private _tooltip =
    "Only saved formations compatible with the current squad fireteam configuration are shown. Team-size changes require exact stored stroke data.";

if (_blockedCount > 0) then {
    _tooltip =
        _tooltip
        + " Some saved formations are currently hidden.";
};

_listbox lbSetTooltip [
    0,
    _tooltip
];

/*
    A newly created save can request selection by real profile index.
*/
private _requestedProfileIndex =
    uiNamespace getVariable [
        "A3C_UI_CustomFormation_RequestedSaveProfileIndex",
        -1
    ];

private _selectedIndex = 0;

if (_requestedProfileIndex >= 0) then {
    private _visibleMappingIndex =
        _visibleSaveIndices find
            _requestedProfileIndex;

    if (_visibleMappingIndex >= 0) then {
        _selectedIndex =
            _visibleMappingIndex + 1;
    };

    uiNamespace setVariable [
        "A3C_UI_CustomFormation_RequestedSaveProfileIndex",
        -1
    ];
} else {
    _selectedIndex =
        uiNamespace getVariable [
            "A3C_UI_CustomFormation_saveLB",
            0
        ];

    if (
        (_selectedIndex < 0)
        || {
            _selectedIndex
            >
            count _visibleSaveIndices
        }
    ) then {
        _selectedIndex = 0;
    };
};

uiNamespace setVariable [
    "A3C_UI_CustomFormation_saveLB",
    _selectedIndex
];

[
    _listbox,
    _selectedIndex
] call A3C_ui_shared_fnc_lbSetCurSel;