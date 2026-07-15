// A3C_ui_mapOverlay_fnc_resetMapClick

params ["_mode"];

if (_mode == 0) then {
	onMapSingleClick {
		private _playerVehicle = vehicle player;
		private _doOverwrite = false;

		if !(player == driver _playerVehicle) then {
			if (player == effectiveCommander _playerVehicle) then {
				if !(_shift) then {
					_doOverwrite = true;
				};
			};
		};

		_doOverwrite
	};
} else {
	onMapSingleClick {};
};