#include "..\script_component.hpp"
#include "..\dialog_defines.hpp"

// A3C_UI_squadPlacement_fnc_applyLayout
// Apply identical geometry to the title images and their interaction buttons.
// Child positions are relative to IDC_SQUAD_PLACEMENT_PARENT.

private _isCorner = profileNamespace getVariable ["A3C_HUD_LAYOUT_CORNER", false];
private _gridX = pixelGrid * pixelW * 2;
private _gridY = pixelGrid * pixelH * 2;

// Unchanged regular-layout geometry from dialog.hpp and rscTitles.hpp.
private _parentPos = [
    0.5 - ((40 * _gridX) / 2),
    ((safezoneY + safezoneH) * 0.97) - (40 * _gridY),
    40 * _gridX,
    40 * _gridY
];

private _backgroundPos = [
    0,
    0,
    40 * _gridX,
    40 * _gridY
];

// Each entry contains:
// [button IDC, image IDC, regular local rectangle, corner screen position]
private _items = [
    [
        IDC_SQUAD_PLACEMENT_FORM_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_FORM_IMG,
        [14 * _gridX, 28 * _gridY, 12 * _gridX, 12 * _gridY],
        [0.867525 * safezoneW + safezoneX, 0.784845 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_TRAVEL_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_TRAVEL_IMG,
        [1 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.752122 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_SPEED_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_SPEED_IMG,
        [5 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.792233 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_DESTINATION_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_DESTINATION_IMG,
        [10 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.832343 * safezoneW + safezoneX, 0.906921 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_GOCODE_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_GOCODE_IMG,
        [26 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.946944 * safezoneW + safezoneX, 0.65397 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_WPMODE_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_WPMODE_IMG,
        [30 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.946944 * safezoneW + safezoneX, 0.719957 * safezoneH + safezoneY]
    ],
    [
        IDC_SQUAD_PLACEMENT_HIDE_BTN,
        IDC_SQUAD_PLACEMENT_OVERLAY_HIDE_IMG,
        [35 * _gridX, 32 * _gridY, 4 * _gridX, 4 * _gridY],
        [0.946944 * safezoneW + safezoneX, 0.587983 * safezoneH + safezoneY]
    ]
];

if (_isCorner) then {
    // Place the parent at the original corner background's screen position.
    _parentPos = [
        0.585951 * safezoneW + safezoneX,
        0.335032 * safezoneH + safezoneY,
        0.412564 * safezoneW,
        0.660103 * safezoneH
    ];

    // The background starts at the parent's origin.
    _backgroundPos = [
        0,
        0,
        _parentPos select 2,
        _parentPos select 3
    ];

    {
        private _pos = _x select 2;
        private _screenPos = _x select 3;

        // Convert the original screen position into a parent-relative position.
        // Preserve the existing icon/button width and height.
        _pos set [0, (_screenPos select 0) - (_parentPos select 0)];
        _pos set [1, (_screenPos select 1) - (_parentPos select 1)];

        _x set [2, _pos];

        // Expand the parent if necessary to contain larger controls.
        // The background keeps its own size and is not stretched.
        _parentPos set [
            2,
            (_parentPos select 2) max ((_pos select 0) + (_pos select 2))
        ];

        _parentPos set [
            3,
            (_parentPos select 3) max ((_pos select 1) + (_pos select 3))
        ];
    } forEach _items;
};

{
    _x params ["_display", "_idIndex"];

    if !(isNull _display) then {
        private _parent = _display displayCtrl IDC_SQUAD_PLACEMENT_PARENT;

        if !(isNull _parent) then {
            _parent ctrlSetPosition _parentPos;
            _parent ctrlCommit 0;

            {
                private _control = _display displayCtrl (_x select _idIndex);

                if !(isNull _control) then {
                    _control ctrlSetPosition (_x select 2);
                    _control ctrlCommit 0;
                };
            } forEach _items;

            // Only the overlay display contains the background image.
            if (_idIndex == 1) then {
                private _background = _display displayCtrl IDC_SQUAD_PLACEMENT_OVERLAY_BG;

                if !(isNull _background) then {
                    _background ctrlSetPosition _backgroundPos;

                    _background ctrlSetText (if (_isCorner) then {
                        "A3C_CORE\ui\pictures\BG_HUD_Menu_Corner.paa"
                    } else {
                        "A3C_CORE\ui\pictures\BG_HUD_Menu.paa"
                    });

                    _background ctrlCommit 0;
                };
            };
        };
    };
} forEach [
    [uiNamespace getVariable [QGVAR(display), displayNull], 0],
    [uiNamespace getVariable [QGVAR(overlayDisplay), displayNull], 1]
];