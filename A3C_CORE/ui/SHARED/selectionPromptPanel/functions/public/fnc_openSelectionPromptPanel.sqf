#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"
#include "..\..\..\shared_ui_defines.hpp"
#include "..\..\..\..\mapOverlay\dialog_defines.hpp"

params ["_mode"];

private _displayId = if (!isNull findDisplay IDD_MAP_OVERLAY) then {
	IDD_MAP_OVERLAY
} else {
	IDD_SELECTION_PROMPT_PANEL
};

private _display = findDisplay _displayId;
private _parent = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Parent;
private _text = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_Description_TXT;
private _listBox = _display displayCtrl IDC_SHARED_UI_SelectionPromptPanel_ListBox;

ctrlSetFocus _listBox;
lbClear _listBox;

private _ctrlShow = true;

switch (_mode) do {
	case "DELETE": {
		A3C_SelectionPromptPanel_MODE = "DELETE";

		private _selectedGroups = A3C_SELECTED_HC_GROUPS_SETTINGS;
		private _count = count _selectedGroups;
		private _suffix = if (_count <= 1) then {""} else {"S"};

		_text ctrlSetText format ["REALLY DELETE %1 GROUP%2?", _count, _suffix];

		[_listBox, "YES"] call A3C_ui_shared_fnc_addLbEntry;
		[_listBox, "NO"] call A3C_ui_shared_fnc_addLbEntry;
	};

	case "MULTIWAYPOINT": {
		A3C_SelectionPromptPanel_MODE = "MULTIWAYPOINT";

		private _selectedUnits = A3C_SELECTED_UNITS;
		private _ref = _selectedUnits select {
			private _group = _x;
			private _leader = leader _group;
			private _leaderVehicle = vehicle _leader;
			private _driver = driver _leaderVehicle;

			_driver in units _group
		};

		private _count = count _ref;
		private _suffix = if (_count <= 1) then {""} else {"S"};

		_text ctrlSetText format ["GIVE WAYPOINT TO %1 GROUP%2", _count, _suffix];

		[_listBox, "YES"] call A3C_ui_shared_fnc_addLbEntry;
		[_listBox, "NO"] call A3C_ui_shared_fnc_addLbEntry;
	};

	case "ARTY": {
		hintSilent "";

		A3C_SelectionPromptPanel_MODE = "ARTY_0";

		_text ctrlSetText "Ammo Within Range";

		private _focusPos = A3C_HC_FOCUS_ARTY_POS;
		private _selectedGroups = A3C_SELECTED_HC_GROUPS_SETTINGS;

		MCSS_REMOTE_ARTILLERY_ARRAY = [];
		A3C_HC_ARTY_AMMO_OPTIONS = [];

		private _aceEnabled = missionNamespace getVariable [
			"A3C_IsAce3",
			false
		];

		{
			private _group = _x;
			private _units = units _group;

			{
				private _unit = _x;
				private _vehicle = objectParent _unit;

				if (
					!isNull _vehicle
					&& {_unit == gunner _vehicle}
				) then {
					private _isACECSW = (
						_aceEnabled
						&& {
							isClass (
								configOf _vehicle
									>> "ACE_CSW"
							)
						}
					);

					private _hasAmmoInRange = if (_isACECSW) then {
						private _availability = [
							[_vehicle],
							_focusPos
						] call A3C_main_fnc_getACECSWArtilleryAvailability;

						_availability findIf {
							(_x select 4) > 0
						} >= 0
					} else {
						private _artyAmmo =
							getArtilleryAmmo [_vehicle];

						private _ammoInRange = _artyAmmo select {
							_focusPos inRangeOfArtillery [
								[_vehicle],
								_x
							]
						};

						_ammoInRange isNotEqualTo []
					};

					if (_hasAmmoInRange) then {
						MCSS_REMOTE_ARTILLERY_ARRAY
							pushBackUnique _vehicle;
					};
				};

			} forEach _units;

		} forEach _selectedGroups;


		private _shellClasses = [
			true,
			false,
			_focusPos
		] call A3C_main_fnc_getArtilleryAmmo;

		{
			_x params [
				"_magClass",
				"_magAmount"
			];

			private _displayName = getText (
				configFile
					>> "CfgMagazines"
					>> _magClass
					>> "displayName"
			);

			private _optionIndex =
				A3C_HC_ARTY_AMMO_OPTIONS findIf {
					(_x select 0) == _displayName
				};

			if (_optionIndex < 0) then {
				A3C_HC_ARTY_AMMO_OPTIONS pushBack [
					_displayName,
					_magAmount,
					[_magClass]
				];
			} else {
				private _option =
					A3C_HC_ARTY_AMMO_OPTIONS
						select _optionIndex;

				_option set [
					1,
					(_option select 1)
					+ _magAmount
				];

				(_option select 2)
					pushBackUnique _magClass;
			};

		} forEach _shellClasses;


		if (A3C_HC_ARTY_AMMO_OPTIONS isEqualTo []) then {
			_ctrlShow = false;

			hint "SELECTED POSITION IS OUT OF RANGE FOR ALL AMMO-TYPES";
			playSound "TacticalPing";
		} else {
			{
				[
					_listBox,
					_x select 0
				] call A3C_ui_shared_fnc_addLbEntry;

			} forEach A3C_HC_ARTY_AMMO_OPTIONS;

			[
				_parent,
				_listBox,
				count A3C_HC_ARTY_AMMO_OPTIONS
			] call A3C_ui_selectionPromptPanel_fnc_resizeBox;
		};
	};

	case "A3C_CTRL_DET_SELECT": {
		A3C_SelectionPromptPanel_MODE = "CTRL_DET";

		_text ctrlSetText "Select Ammo Type";

		private _availableAmmo = [];
		private _selectedUnits = A3C_SELECTED_UNITS;
		private _targetVehicle = A3C_TEMP_ACTION select 1 select 0;
		private _cfgMagazines = configFile >> "CfgMagazines";
		private _cfgAmmo = configFile >> "CfgAmmo";
		private _targetVehicleIsNull = isNull _targetVehicle;

		{
			private _soldier = _x;
			private _magazines = magazines _soldier;

			{
				private _magazine = _x;
				private _magConfig = _cfgMagazines >> _magazine;
				private _nameSound = getText (_magConfig >> "nameSound");

				if (_nameSound in ["satchelcharge", "mine"]) then {
					private _ammo = getText (_magConfig >> "ammo");
					private _mineTrigger = getText (_cfgAmmo >> _ammo >> "mineTrigger");

					if (_mineTrigger == "RemoteTrigger" || {_targetVehicleIsNull}) then {
						_availableAmmo pushBackUnique _magazine;
					};
				};
			} forEach _magazines;
		} forEach _selectedUnits;

		private _ammoCount = count _availableAmmo;

		if (_ammoCount > 4) then {
			private _parentPos = ctrlPosition _parent;
			private _extraRows = _ammoCount - 4;
			private _extraHeight = _extraRows * (0.0440051 * safeZoneH);

			_parentPos set [3, (_parentPos select 3) + _extraHeight];

			_parent ctrlSetPosition _parentPos;
			_parent ctrlCommit 0;
		};

		{
			private _magazine = _x;
			private _displayName = getText (_cfgMagazines >> _magazine >> "displayName");

			[_listBox, _displayName] call A3C_ui_shared_fnc_addLbEntry;
		} forEach _availableAmmo;
	};
};

if (_ctrlShow) then {
	_parent ctrlShow true;
	_parent ctrlSetPosition [
		0.383108 * safeZoneW + safeZoneX,
		0.378986 * safeZoneH + safeZoneY
	];
	_parent ctrlCommit 0;
} else {
	private _promptDisplay = findDisplay IDD_SELECTION_PROMPT_PANEL;

	if (!isNull _promptDisplay) then {
		_promptDisplay closeDisplay 0;
	};
};