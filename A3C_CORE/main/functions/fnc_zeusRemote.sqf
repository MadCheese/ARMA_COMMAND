// A3C_main_fnc_zeusRemote

if (isNull findDisplay 312) exitWith {};

params [
	"_control",
	"_button",
	"_posX",
	"_posY",
	"_shift",
	"_ctrl"
];

private _unit = objNull;
private _curatorModule = objNull;
private _zeusCurrent = player;

if (_button == 0) then {
	if (_ctrl && { _shift }) then {
		if !((curatorMouseOver select 0) isEqualTo "") then {
			_unit = curatorMouseOver select 1;

			if (({ isPlayer _x } count units group _unit) == 0) then {
				findDisplay 312 closeDisplay 2;

				selectPlayer (
					leader group effectiveCommander _unit
				);
			};
		};
	};

	if (A3C_ZEUSMISSION) then {
		if (_ctrl && { !_shift }) then {
			if !((curatorMouseOver select 0) isEqualTo "") then {
				_unit = curatorMouseOver select 1;
				systemChat str _unit;
			};
		};
	};
};