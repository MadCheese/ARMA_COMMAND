// A3C_ui_mapOverlay_fnc_getIconsAtMapPos

params [
	"_mode",
	"_mapPositionX",
	"_mapPositionY"
];

private _mapControl =
	findDisplay 12 displayCtrl 51;

private _iconsAtPosition = [];

private _iconArray = switch (_mode) do {
	case "SQUAD": {
		A3C_UI_MAPICONS_SQUAD
	};

	case "HC_GP": {
		A3C_UI_MAPICONS_HC_GROUP
	};

	case "HC_WP": {
		A3C_UI_MAPICONS_HC_WPS
	};

	case "HC_VB": {
		A3C_UI_MAPICONS_HC_VICS
	};

	case "TRACKER": {
		A3C_UI_MAPICONS_HC_TRACKER
	};

	case "POLY_MAIN": {
		A3C_UI_MAPICONS_POLYGON_MAIN
	};

	case "POLY_EDGE": {
		A3C_UI_MAPICONS_POLYGON_EDGE
	};

	case "SLINGLOAD": {
		A3C_UI_MAPICONS_PICKUP
	};

	case "DEMO": {
		A3C_UI_MAPICONS_DEMO_VICS
	};

	case "SQ_WP_DOT": {
		A3C_UI_MAPICONS_SQ_WPS_WPDOTS
	};

	case "BOARDING_DRAW": {
		A3C_UI_MAPICONS_BOARDING_DRAW
	};

	default {
		[]
	};
};

{
	private _iconWorldPosition = _x select 2;
	private _iconMapPosition =
		_mapControl ctrlMapWorldToScreen _iconWorldPosition;

	private _iconMapPositionX =
		_iconMapPosition select 0;

	private _iconMapPositionY =
		_iconMapPosition select 1;

	private _iconMapDimensions =
		_x select 1;

	private _iconMapWidth =
		safeZoneWAbs
			* (
				(_iconMapDimensions select 0)
					/ (getResolution select 0)
			);

	private _iconMapHeight =
		safeZoneH
			* (
				(_iconMapDimensions select 1)
					/ (getResolution select 1)
			);

	if (
		_mapPositionX < _iconMapPositionX + (_iconMapWidth / 2)
		&& {_mapPositionX > _iconMapPositionX - (_iconMapWidth / 2)}
		&& {_mapPositionY < _iconMapPositionY + (_iconMapHeight / 2)}
		&& {_mapPositionY > _iconMapPositionY - (_iconMapHeight / 2)}
	) then {
		_iconsAtPosition pushBack _x;
	};
} forEach _iconArray;

if (_mode == "SQ_WP_LOOKDIR") then {
	private _screenWorldPosition =
		_mapControl posScreenToWorld [
			_mapPositionX,
			_mapPositionY
		];

	{
		if (_screenWorldPosition inPolygon (_x select 2)) then {
			_iconsAtPosition pushBack _x;
		};
	} forEach A3C_UI_MAPICONS_SQ_WPS_LOOKDIR;
};

_iconsAtPosition