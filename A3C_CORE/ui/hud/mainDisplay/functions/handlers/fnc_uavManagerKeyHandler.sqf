// A3C_UI_mainDisplay_fnc_uavManagerKeyHandler

params ["_eventType", "_props"];
_props params ["_display", "_key", "_shift", "_ctrl", "_alt"];

private _playerHasTerminal = (assignedItems player findIf {
	getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "type") == 621
}) != -1;

if (!_playerHasTerminal) exitWith {
	hint "YOU HAVE NO UAV TERMINAL";
};

if (!_ctrl && { isNull (getConnectedUAV player) }) exitWith {
	[
		"DOWN",
		[_display, _key, false, true, false]
	] spawn A3C_UI_mainDisplay_fnc_uavManagerKeyHandler;
};

if (_ctrl) then {
	private _playerSide = side player;

	private _connectableUAVs = allUnitsUAV select {
		private _uavOwner = (UAVControl _x) select 0;
		private _isAvailable = isNull _uavOwner;

		_isAvailable &&
		{
			private _uavSideNumber = getNumber (
				configFile >> "CfgVehicles" >> typeOf _x >> "side"
			);

			private _uavSide = [_uavSideNumber] call MCSS_fnc_getSideName;

			_playerSide == _uavSide
		}
	};

	[_connectableUAVs] spawn {
		disableSerialization;

		params ["_uavs"];

		if (_uavs isEqualTo []) exitWith {
			systemChat "No connectable UAVs found.";
		};

		// Close previous instance if it exists.
		private _oldDisplay = uiNamespace getVariable ["TAG_UAV_PICKER_DISPLAY", displayNull];

		if (!isNull _oldDisplay) then {
			_oldDisplay closeDisplay 1;
		};

		private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
		uiNamespace setVariable ["TAG_UAV_PICKER_DISPLAY", _display];

		private _uavCount = count _uavs;

		// Compact centered layout.
		private _panelWidth = 0.34;
		private _rowHeight = 0.032;
		private _padding = 0.006;
		private _titleHeight = 0.04;
		private _closeButtonHeight = 0.03;
		private _iconWidth = 0.028;

		private _visibleRows = _uavCount max 1;
		private _panelHeight =
			_titleHeight +
			(_visibleRows * _rowHeight) +
			((_visibleRows + 1) * _padding) +
			_closeButtonHeight +
			_padding;

		private _panelX = safeZoneX + (safeZoneW * 0.5) - (_panelWidth * 0.5);
		private _panelY = safeZoneY + (safeZoneH * 0.5) - (_panelHeight * 0.5);

		// Background.
		private _background = _display ctrlCreate ["RscText", 1000];
		_background ctrlSetPosition [_panelX, _panelY, _panelWidth, _panelHeight];
		_background ctrlSetBackgroundColor [0, 0, 0, 0.8];
		_background ctrlCommit 0;

		// Title.
		private _title = _display ctrlCreate ["A3C_RscText", 1001];
		_title ctrlSetPosition [
			_panelX + _padding,
			_panelY + _padding,
			_panelWidth - (2 * _padding),
			_titleHeight - _padding
		];
		_title ctrlSetText format ["Available UAVs (%1)", _uavCount];
		_title ctrlSetBackgroundColor [0.85, 0.40, 0.00, 1.00];
		_title ctrlSetTextColor [1, 1, 1, 1];
		_title ctrlSetFontHeight 0.035;
		_title ctrlCommit 0;

		// Entries.
		{
			private _uav = _x;
			private _buttonIDC = 1100 + _forEachIndex;
			private _pictureIDC = 2100 + _forEachIndex;
			private _iconBackgroundIDC = 3000 + _forEachIndex;

			private _rowY = _panelY + _titleHeight + _padding + (_forEachIndex * _rowHeight);

			uiNamespace setVariable [format ["TAG_UAV_PICKER_%1", _buttonIDC], _uav];

			private _uavConfig = configFile >> "CfgVehicles" >> typeOf _uav;
			private _uavName = getText (_uavConfig >> "displayName");

			private _driverGroup = group driver _uav;
			private _groupText = if (isNull _driverGroup) then {
				"NO GROUP"
			} else {
				groupId _driverGroup
			};

			private _label = format ["%1 (%2)", _uavName, _groupText];

			private _flightHeight = round ((getPos _uav) select 2);
			private _heightText = if (_flightHeight == 0) then {
				""
			} else {
				format [" - %1m", _flightHeight]
			};

			_label = _label + _heightText;

			private _picturePath = getText (_uavConfig >> "picture");

			if (_picturePath isEqualTo "") then {
				_picturePath = getText (_uavConfig >> "icon");
			};

			// Icon background.
			private _iconBackground = _display ctrlCreate ["RscText", _iconBackgroundIDC];
			_iconBackground ctrlSetPosition [
				_panelX + _padding,
				_rowY,
				_iconWidth,
				_rowHeight - _padding
			];
			_iconBackground ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.8];
			_iconBackground ctrlCommit 0;

			// Icon picture.
			private _picture = _display ctrlCreate ["RscPicture", _pictureIDC];
			_picture ctrlSetPosition [
				_panelX + _padding + 0.001,
				_rowY + 0.001,
				_iconWidth - 0.002,
				(_rowHeight - _padding) - 0.002
			];

			if !(_picturePath isEqualTo "") then {
				_picture ctrlSetText _picturePath;
			};

			_picture ctrlCommit 0;

			// Button.
			private _button = _display ctrlCreate ["RscButton", _buttonIDC];
			_button ctrlSetPosition [
				_panelX + _padding + _iconWidth + _padding,
				_rowY,
				_panelWidth - (3 * _padding) - _iconWidth,
				_rowHeight - _padding
			];
			_button ctrlSetText _label;
			_button ctrlSetTooltip "LMB - CONNECT / RMB - CONNECT AND CONTROL";
			_button ctrlCommit 0;

			_button ctrlAddEventHandler [
				"MouseButtonDown",
				{
					disableSerialization;

					params ["_control", "_button"];

					private _uav = uiNamespace getVariable [
						format ["TAG_UAV_PICKER_%1", ctrlIDC _control],
						objNull
					];

					if (isNull _uav) exitWith {
						systemChat "UAV lookup failed.";
						(ctrlParent _control) closeDisplay 1;
						true
					};

					switch (_button) do {
						case 0: {
							[_uav, 0] spawn A3C_main_fnc_playerConnectToUAV;
							(ctrlParent _control) closeDisplay 1;
						};

						case 1: {
							[_uav, 1] spawn A3C_main_fnc_playerConnectToUAV;
							(ctrlParent _control) closeDisplay 1;
						};
					};

					true
				}
			];
		} forEach _uavs;

		// Close button.
		private _closeButton = _display ctrlCreate ["RscButton", 1999];
		_closeButton ctrlSetPosition [
			_panelX + _padding,
			_panelY + _panelHeight - _closeButtonHeight,
			_panelWidth - (2 * _padding),
			_closeButtonHeight - _padding
		];
		_closeButton ctrlSetText "Close";
		_closeButton ctrlCommit 0;

		_closeButton ctrlAddEventHandler [
			"ButtonClick",
			{
				(ctrlParent (_this select 0)) closeDisplay 1;
			}
		];
	};
} else {
	if !(unitIsUAV cameraOn) then {
		// Take UAV control.
		[] spawn A3C_main_fnc_playerTakeUAVControl;
	} else {
		// Release UAV control.
		player switchCamera "Internal";
	};
};