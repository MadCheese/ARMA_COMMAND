// A3C_ai_squad_fnc_boarding_createPlayerGroupUIProxy

params ["_group"];

private _proxyGroup = group player;

private _groupData = (units _group) apply {
	[
		typeOf _x,
		name _x,
		_x getVariable ["A3C_ASSIGNEDTEAM", "MAIN"],
		primaryWeapon _x,
		secondaryWeapon _x,
		magazines _x
	]
};

private _units = [];
private _proxyData = [];

{
	_x params [
		"_type",
		"_name",
		"_assignedTeam",
		"_primaryWeapon",
		"_secondaryWeapon",
		"_magazines"
	];

	private _unit = _proxyGroup createUnit [
		_type,
		[0, 0, 500 + random 1000],
		[],
		0,
		"NONE"
	];

	_unit hideObject true;
	[
		[_unit],
		{
			params ["_unit"];

			if (!isNull _unit) then {
				_unit hideObjectGlobal true;
			};
		}
	] remoteExecCall ["BIS_fnc_call", 2];

	[_unit, [0,100,0]] call A3C_ai_shared_fnc_doMove; //-- just to give 'busy' status instead of 'away'

	if (!isNull _unit) then {
		_units pushBack _unit;

		_proxyData pushBack [
			_unit,
			_name,
			_assignedTeam,
			_primaryWeapon,
			_secondaryWeapon,
			_magazines
		];
	};

} forEach _groupData;


//-- Unit initialization and command-bar registration continue after
//-- createUnit returns. Finalize proxies after those passes have run.
[
	{
		{
			_x params [
				"_unit",
				"_name",
				"_assignedTeam",
				"_primaryWeapon",
				"_secondaryWeapon",
				"_magazines"
			];

			if (!isNull _unit) then {
				removeAllWeapons _unit;

				if (_primaryWeapon != "") then {
					_unit addWeapon _primaryWeapon;
				};

				if (_secondaryWeapon != "") then {
					_unit addWeapon _secondaryWeapon;
				};

				_unit addBackpack "B_Carryall_green_F";

				{
					_unit addMagazine _x;
				} forEach _magazines;

				private _nameParts = _name splitString " ";

				private _firstName = _name;
				private _lastName = _name;

				if !(_nameParts isEqualTo []) then {
					_firstName = _nameParts select 0;
					_lastName = _nameParts select ((count _nameParts) - 1);
				};

				//-- The command bar displays the last-name component.
				_unit setName [_name, _firstName, _lastName];

				//-- Assign only after the unit exists in the player's group UI.
				_unit assignTeam _assignedTeam;
			};

		} forEach _this;
	},
	_proxyData,
	2
] call CBA_fnc_execAfterNFrames;

_units