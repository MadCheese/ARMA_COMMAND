// A3C_ui_mapOverlay_fnc_squad_createBposMarkers

// TODO: Remove these markers and render the information through drawMapUI.

private _buildingBounds = boundingBoxReal A3C_TAB_BUILDING;
private _buildingMaxBounds = _buildingBounds select 1;

A3C_BUILDING_VIEWER = createMarkerLocal [
	"A3C_BUILDING_VIEWER",
	position A3C_TAB_BUILDING
];

"A3C_BUILDING_VIEWER" setMarkerAlphaLocal 0.5;
"A3C_BUILDING_VIEWER" setMarkerShapeLocal "RECTANGLE";
"A3C_BUILDING_VIEWER" setMarkerColorLocal "ColorGreen";
"A3C_BUILDING_VIEWER" setMarkerPosLocal (position A3C_TAB_BUILDING);
"A3C_BUILDING_VIEWER" setMarkerDirLocal (getDir A3C_TAB_BUILDING);
"A3C_BUILDING_VIEWER" setMarkerSizeLocal [
	_buildingMaxBounds select 0,
	_buildingMaxBounds select 1
];

A3C_BPMARKERS pushBack "A3C_BUILDING_VIEWER";

private _doorPositions = [
	A3C_TAB_BUILDING
] call A3C_main_fnc_buildingGetDoorPositions;

{
	call compile format [
		"
			A3C_BDPS_D_%1 = createMarkerLocal ['A3C_BDPS_D_%1', position A3C_TAB_BUILDING];
			'A3C_BDPS_D_%1' setMarkerShapeLocal 'RECTANGLE';
			'A3C_BDPS_D_%1' setMarkerPosLocal %2;
			'A3C_BDPS_D_%1' setMarkerTextLocal str %1;
			'A3C_BDPS_D_%1' setMarkerDirLocal ([A3C_TAB_BUILDING, %2] call A3C_main_fnc_buildingGetDoorDirection);
			'A3C_BDPS_D_%1' setMarkerSizeLocal [0.5, 0.1];
			'A3C_BDPS_D_%1' setMarkerColorLocal 'ColorBlufor';
			'A3C_BDPS_D_%1' setMarkerAlphaLocal 1;
			A3C_BPMARKERS pushBack 'A3C_BDPS_D_%1';

			if ((%2 select 2) <= 2) then {
				'A3C_BDPS_D_%1' setMarkerColorLocal 'ColorBlufor';
			};

			if ((%2 select 2) > 2) then {
				'A3C_BDPS_D_%1' setMarkerColorLocal 'ColorGreen';
			};

			if ((%2 select 2) > 8) then {
				'A3C_BDPS_D_%1' setMarkerColorLocal 'ColorYellow';
			};
		",
		_forEachIndex,
		_x
	];
} forEach _doorPositions;

private _lastBuildingPositionIndex = [
	A3C_TAB_BUILDING
] call MCSS_fnc_getLastBuildingPosIndex;