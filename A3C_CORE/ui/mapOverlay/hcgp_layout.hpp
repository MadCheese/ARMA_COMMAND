#ifndef A3C_MAP_HCGP_LAYOUT_HPP
#define A3C_MAP_HCGP_LAYOUT_HPP

// Milestone 2A: Small UI, scale 0.55, reported 1920 x 1031 (16:9).
// Measured grid coefficients are authoritative for the combined layout.
#define A3C_HCGP_X(n) ((n) * (pixelGrid * pixelW * 2.5))
#define A3C_HCGP_Y(n) ((n) * (pixelGrid * pixelH * 2.5))
#define A3C_HCGP_LIST_H A3C_HCGP_Y(4.5083)
#define A3C_HCGP_LIST_FONT A3C_HCGP_Y(0.8505)
#define A3C_HCGP_CONFIRM_FONT A3C_HCGP_Y(1.27575)
// Cancel was not sampled. Its inherited font evaluates to 0.04 at the
// reference aspect ratio; keep that Small size and scale the visible X.
#define A3C_HCGP_CANCEL_FONT A3C_HCGP_Y(0.04 / 0.0352734)
#define A3C_MAP_DASH_W A3C_HCGP_X(23.0409)
#define A3C_MAP_DASH_BG_H A3C_HCGP_Y(13.0166)

// Actual child-control measurements, identical in the initial/intermediate/
// completed report. All internal dimensions and fonts use current GX/GY.
#define A3C_MAP_DASH_PARENT_H A3C_HCGP_Y(16.5221)
#define A3C_MAP_DASH_BG_X A3C_HCGP_X(4.76093e-05)
#define A3C_MAP_DASH_TITLE_FONT A3C_HCGP_Y(2.06182)
#define A3C_MAP_DASH_TEXT_H A3C_HCGP_Y(1.08245)
#define A3C_MAP_DASH_ROSTER_FONT A3C_HCGP_Y(1.28864)
#define A3C_MAP_DASH_STEP A3C_HCGP_Y(1.62368)
#define A3C_MAP_DASH_TEXT_X A3C_HCGP_X(-5.49338e-06)
#define A3C_MAP_DASH_TEXT_W A3C_HCGP_X(15.3606)
#define A3C_MAP_DASH_TITLE_Y A3C_HCGP_Y(-1.14267e-06)
#define A3C_MAP_DASH_TITLE_H A3C_HCGP_Y(1.75276)
#define A3C_MAP_DASH_EDIT_W A3C_HCGP_X(13.44)
#define A3C_MAP_DASH_ICON_X A3C_HCGP_X(16.1287)
#define A3C_MAP_DASH_ICON_W A3C_HCGP_X(6.91227)
#define A3C_MAP_DASH_ICON_H A3C_HCGP_Y(6.13467)
#define A3C_MAP_DASH_UNITS_Y A3C_HCGP_Y(2.01049)
#define A3C_MAP_DASH_LOCATION_Y A3C_HCGP_Y(3.20119)
#define A3C_MAP_DASH_TASK_Y A3C_HCGP_Y(4.39189)
#define A3C_MAP_DASH_PROGRESS_X A3C_HCGP_X(0.576026)
#define A3C_MAP_DASH_PROGRESS_Y A3C_HCGP_Y(7.01103)
#define A3C_MAP_DASH_PROGRESS_W A3C_HCGP_X(7.6803)
#define A3C_MAP_DASH_PROGRESS_H A3C_HCGP_Y(0.43819)
#define A3C_MAP_DASH_PROGRESS_TEXT_X A3C_HCGP_X(-3.66226e-06)
#define A3C_MAP_DASH_PROGRESS_TEXT_Y A3C_HCGP_Y(5.92857)
#define A3C_MAP_DASH_ROSTER_LABEL_X A3C_HCGP_X(9.21636)
#define A3C_MAP_DASH_ROSTER_LABEL_W A3C_HCGP_X(4.60818)
#define A3C_MAP_DASH_ROSTER_X A3C_HCGP_X(9.98438)
#define A3C_MAP_DASH_ROSTER_W A3C_HCGP_X(13.0565)
#define A3C_MAP_DASH_ROSTER_H A3C_HCGP_Y(6.00558)

// No medic/repair icons existed in the calibration group. Preserve their
// source proportions using the report's measured reference SafeZone/GX/GY;
// these constant conversions need a support-icon runtime check.
#define A3C_MAP_DASH_SUPPORT_X A3C_HCGP_X(0.150315 * 2.42424 / 0.0252525)
#define A3C_MAP_DASH_SUPPORT_Y A3C_HCGP_Y(3.09064e-006 * 1.81825 / 0.0352734)
#define A3C_MAP_DASH_SUPPORT_W A3C_HCGP_X(0.0159271 * 2.42424 / 0.0252525)
#define A3C_MAP_DASH_SUPPORT_H A3C_HCGP_Y(0.0340016 * 1.81825 / 0.0352734)

#endif
