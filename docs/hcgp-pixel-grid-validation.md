# Issue #7: map dashboard / HCGP Pixel Grid conversion

The reference is the user's complete Milestone 2A runtime report: Small UI,
scale 0.55, `getResolution=[1920,1031,792,567,1.77778,0.55,0.75,1.33333,false,0.4]`,
GX 0.0252525, GY 0.0352734, SafeZone [W,H,X,Y]
[2.42424,1.81825,-0.712121,-0.409127]. Initial/intermediate frame 65784 and
completed frame 65785 have identical geometry. Completion published six dynamic
controls for two progress entries; no extra-height case was measured.

## Implemented model

All measured internal geometry and fonts use their reported GX/GY coefficients
directly through `mapOverlay/hcgp_layout.hpp`. There is no live SafeZone/UI-scale
calculation in map-dashboard dimensions. Absolute HCGP placement stays [0.5,0.3].
The dashboard remains immediately to its left and shares its Y origin.

| Reference control | Local [x/GX,y/GY,w/GX,h/GY] | Font/GY |
| --- | --- | --- |
| HCGP parent | Screen origin [0.5,0.3]; size [12,19] | — |
| Stance images | x=0/2/4/6; y=0; size [2,2] | — |
| Behaviour / Combat Mode | x=0/4; y=2; size [4,4.5083] | 0.8505 |
| Formation / Team Color | x=0/4; y=6.5083; size [4,4.5083] | 0.8505 |
| Confirm pair | [0,11.0166,8,2] | Button 1.27575 |
| Dashboard parent | Relative X=-23.0409 GX; size [23.0409,16.5221] | — |
| Dashboard background | [4.76093e-05,0,23.0409,13.0166] | — |
| Group name | [-5.49338e-06,-1.14267e-06,15.3606,1.75276] | 2.06182 |
| Group name edit | [0,0,13.44,1.75276] | 2.06182 |
| Group icon | [16.1287,-1.14267e-06,6.91227,6.13467] | — |
| Unit size | [-5.49338e-06,2.01049,15.3606,1.08245] | 1.08245 |
| Location | [-5.49338e-06,3.20119,15.3606,1.08245] | 1.08245 |
| Task | [-5.49338e-06,4.39189,15.3606,1.08245] | 1.08245 |
| Health bar/background | [0.576026,7.01103,7.6803,0.43819] | — |
| Health label | [-3.66226e-06,5.92857,7.6803,1.08245] | 1.08245 |
| Roster heading | [9.21636,5.92857,4.60818,1.08245] | 1.08245 |
| Roster body | [9.98438,7.01103,13.0565,6.00558] | 1.28864 |
| Dynamic bar 1 | [0.576026,8.63471,7.6803,0.43819] | — |
| Dynamic label 1 | [-3.66226e-06,7.55226,7.6803,1.08245] | 1.08245 |
| Dynamic bar 2 | [0.576026,10.2584,7.6803,0.43819] | — |
| Dynamic label 2 | [-3.66226e-06,9.17594,7.6803,1.08245] | 1.08245 |

The progress step is 1.62368 GY. Initial dashboard heights are the measured
baseline heights; final heights add `max(count(progressEntries)-3,0) * step`.
Generated labels retain their existing class/font/color, with a map-only font
height override. The roster keeps its existing relative text-size tags.

There were no medic/repair icons in the reference. Their source geometry is
converted using the report's actual reference SafeZone and GX/GY values; these
are constant calibration conversions, not current-screen dimensions. Test those
icons separately before treating their appearance as verified.

Cancel's visible X was not sampled. Its inherited font expression evaluates
to 0.04 at the reference aspect ratio; a local override converts that reference
size to GY so it scales with its existing Pixel Grid button. Verify it visually.

## Layout and synchronization

Every opening acquires a new panel context containing a serial and selection
snapshot and resets the baseline geometry. Multi-group openings explicitly hide
the dashboard and restore the listbox/Confirm layout. The population and
selection block is unchanged.

The map shell and final UI publication run unscheduled; inventory/statistics
remain in the scheduled worker. Initial and final geometry directly notify
`HCGP_layout` after applying dashboard dimensions. Context, selection, display
and dashboard request guards reject stale updates. Closing invalidates the map
context immediately, and an older delayed close cannot hide a reopened panel.
There are no new event handlers, layout polling or arbitrary synchronization
delays. The radial path retains normal execution and its original geometry,
fonts, statistics, contents and conditional positioning.

HCGP retains dashboard-aligned sizing, capped at the calibrated 4.5083 GY.
Extra height becomes space between the two listbox rows; the lower row and
Confirm remain aligned with the dashboard bottom. The hidden-Confirm mode also
keeps this viewport capacity. The parent's clipping height grows only if needed;
its fixed origin and action-button geometry do not change.

The four HCGP listboxes now use `ST_LEFT + LB_TEXTURES`, matching the shared
base's intended listbox style. The previous `style = CT_LISTBOX` used a type
constant as a style. Shared base/scrollbar definitions are unchanged and
`rowHeight=0` remains automatic. `<unset>` in the report represents an unresolved
config lookup; no definitions were removed based on it.

## Exact engine checks

Restart the mission with updated configuration/functions before testing.

1. Small, original calibration group, Confirm enabled: verify [0.5,0.3] origin,
   dashboard width 23.0409 GX, background height 13.0166 GY, and
   `2 + 4.5083 + 4.5083 + 2 = 13.0166`. Compare dashboard child controls and
   fonts with the table. Reuse the Milestone 2A diagnostic if desired.
2. On the first opening after opening the map, verify five complete entries
   in Behaviour, Combat Mode and Team Color. Scroll Formation by wheel and
   scrollbar to Diamond. Check text alignment and scrollbar artwork after
   the local style correction. Close/reopen without closing the map and repeat.
3. Select two groups, then single -> multiple -> single in the same display.
   Verify baseline heights reset, dashboard visibility, neutral multi-group
   selections, unchanged selection actions, and correct Confirm visibility.
4. Repeat with immediate-response mode enabled and disabled. Verify hidden
   Confirm behavior, actual group-setting changes, and all stance/action buttons.
5. Use groups generating four or more progress entries, including an armed
   pylon aircraft with cargo/launcher infantry where possible. Verify both
   initial and final states: dashboard/roster grow, all labels/bars remain inside
   the dashboard, the gap increases, Formation stays a scrolling viewport,
   and the lower row/Confirm remain aligned with the final bottom.
6. Close during calculation, rapidly reopen another group, switch to multiple
   groups, and close the map. Verify no stale dashboard/geometry resurrection,
   no old delayed close hiding the replacement, and no RPT script errors.
7. Test a medic and repair group, including both icons together, and edit the
   group name. Verify support-icon positioning, fonts, the edit hit area and
   Cancel's X size and operation.
8. Repeat checks 1-7 at Large, then Normal/Very Large and a lower resolution.
   Ratios and row capacity should stay constant. Pixel rounding and the fixed
   anchor can still cause clipping when the combined interface exceeds the
   available screen. No automatic repositioning/fitting was added.
9. Open the radial dashboard for the same group, with ordinary and expanded
   statistics and night/day conditions. Compare placement, fonts, contents and
   interactions with the previous version.

Static validation covers macro expansion/calibrated numerical ratios, baseline
and expanded layout arithmetic, source delimiters/includes, unchanged population
and statistics computation, radial geometry-expression comparison, and protected
file hashes. It does not compile SQF in Arma or establish rendered-row/scrollbar
behavior. Small visual matching and Large issue resolution remain engine tests.

The checks passed for 85 measured control properties and 60 scaled layout
cases (baseline through five extra rows, with Confirm visible/hidden). All four
SQF files passed include/macro preprocessing. Full-dialog clang preprocessing
encounters the same existing SQF array/stringification incompatibilities as HEAD;
new geometry/font expressions passed separate preprocessing and numerical checks.
Changed-file whitespace checks passed; whole-tree `git diff --check` still reports
the existing local trailing whitespace in `fnc_onMouseMoving.sqf:48`, preserved.

Changed implementation files: `ui/mapOverlay/hcgp_layout.hpp`,
`ui/mapOverlay/dialog.hpp`, `ui/mapOverlay/functions/XEH_PREP.hpp`,
`ui/mapOverlay/functions/public/fnc_HCGP_layout.sqf`,
`ui/mapOverlay/functions/public/fnc_HCGP_openMenu.sqf`,
`ui/mapOverlay/functions/public/fnc_close_HCGP_Parent.sqf`, and
`ui/SHARED/functions/public/fnc_createDashBoard.sqf` (all under `A3C_CORE`).
This validation document is the eighth changed/added file.
