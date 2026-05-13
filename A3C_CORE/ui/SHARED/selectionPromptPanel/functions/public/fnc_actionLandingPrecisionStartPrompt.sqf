#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

A3C_RADIAL_ACTION_HC_LANDINGDATA = [];

with uiNamespace do {
	A3C_HUD_OBS = (findDisplay 46) createDisplay "HUD_SelectionPromptPanel";
};

private _displayId = if (!isNull (findDisplay IDD_MAP_OVERLAY)) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _display = findDisplay _displayId;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _descriptionCtrl = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

_descriptionCtrl ctrlSetText "CHECKING LZ";
lbClear _listBox;
[_listBox, "KEEP TAB PRESSED DOWN"] call A3C_addLbEntry;

_parent ctrlShow true;

private _requiresPlacementCorrection = true;
private _placerPos = getPosASL A3C_OBJECTPLACER;
private _landingPosRoot = +_placerPos;
private _landingVector = [getDir A3C_OBJECTPLACER] call MCSS_fnc_DegreeToVector;

private _dimensions = [typeOf A3C_OBJECTPLACER] call A3C_getVehicleBodyDimensions;
_dimensions params ["_referenceWidth", "_referenceLength", "_referenceHeight", "_referenceRotorSize"];

private _forceDefaultLanding = true;
private _hasUnsafeRotorIntersection = false;

if (!isNull A3C_SNAP_OBJECT) then {
	//-- position snapped against object

	private _placerPosZ = _placerPos select 2;
	private _snapObjectPos = getPosASL A3C_SNAP_OBJECT;

	private _snapObjectZ = _snapObjectPos select 2;
	private _snapObjectHeight = A3C_SNAP_OBJECT call BIS_fnc_objectHeight;

	private _refPosTop = (_placerPos select [0, 2]) + [_snapObjectZ + _snapObjectHeight]; //-- placer-pos at boundingBox top

	private _intersections = lineIntersectsSurfaces [
		_refPosTop,
		[_placerPos select 0, _placerPos select 1, 0],
		A3C_OBJECTPLACER,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];

	if (count _intersections > 0) then {
		private _intersectPosZ = ((_intersections select 0) select 0) select 2;

		if (abs (_intersectPosZ - _placerPosZ) < 0.1) then {
			_requiresPlacementCorrection = false;
			_forceDefaultLanding = false;
		};

		if (_requiresPlacementCorrection) then {
			hint "ADJUSTING LZ";

			private _lzData = [A3C_SNAP_OBJECT, _referenceWidth, _referenceLength] call A3C_getHeliRoofLZ;

			[] spawn {
				hint "LZ ADJUSTED";
				sleep 5;
				hintSilent "";
			};

			if (count _lzData > 0) then {
				_landingPosRoot = _lzData select 0;
				_landingVector = [_lzData select 1] call MCSS_fnc_DegreeToVector;
				_forceDefaultLanding = false;
			};
		};
	};
} else {
	//-- position in the open

	_forceDefaultLanding = false;
	_requiresPlacementCorrection = false;

	private _dummyBox = [A3C_OBJECTPLACER, 1] call MCSS_fnc_BBOX;
	private _maxRotorHeight = 1000;

	{
		private _rotorSelectionZ = (A3C_OBJECTPLACER modelToWorld (A3C_OBJECTPLACER selectionPosition _x)) select 2;

		if (_rotorSelectionZ < _maxRotorHeight) then {
			_maxRotorHeight = _rotorSelectionZ;
		};
	} forEach ([A3C_OBJECTPLACER] call MCSS_fnc_getMainRotorSelections);

	private _centerAtRotorHeight = getPosASL A3C_OBJECTPLACER;
	_centerAtRotorHeight set [2, _maxRotorHeight];
	_centerAtRotorHeight = ATLToASL _centerAtRotorHeight;

	{
		private _distance = A3C_OBJECTPLACER distance2D _x;
		private _direction = A3C_OBJECTPLACER getDir _x;

		private _intersections = lineIntersectsSurfaces [
			_centerAtRotorHeight,
			[_centerAtRotorHeight, _distance, _direction] call BIS_fnc_relPos,
			A3C_OBJECTPLACER,
			objNull,
			true,
			1,
			"GEOM",
			"NONE"
		];

		if (count _intersections > 0) exitWith {
			_hasUnsafeRotorIntersection = true;
		};
	} forEach _dummyBox;
};

if (_hasUnsafeRotorIntersection) exitWith {
	hint "THE SELECTED GROUND-LZ IS NOT SAFE - PLEASE REPEAT";
	sleep 5;
	hintSilent "";
};

if (_forceDefaultLanding) then {
	[] spawn {
		hint "ALERT: NO SUITABLE LZ FOUND ON OBJECT. REVERTING TO DEFAULT LANDING";
		sleep 5;
		hintSilent "";
	};

	A3C_RADIAL_ACTION_HC_LANDINGDATA = [];
};

A3C_RADIAL_ACTION_HC_LANDINGDATA = [_landingPosRoot, _landingVector, _forceDefaultLanding];

A3C_SelectionPromptPanel_MODE = "HELI_LANDING_HC_TYPE";

_descriptionCtrl ctrlSetText "SELECT LANDING TYPE";

{
	private _ctrlPos = ctrlPosition _x;
	_ctrlPos set [3, (_ctrlPos select 3) + (3 * (0.0440051 * safeZoneH))];

	_x ctrlSetPosition _ctrlPos;
	_x ctrlCommit 0;
} forEach [_parent, _listBox];

ctrlSetFocus _listBox;

lbClear _listBox;

{
	[_listBox, _x] call A3C_addLbEntry;
} forEach ["COMBAT LANDING", "TRANSPORT UNLOAD", "FULL LANDING"];