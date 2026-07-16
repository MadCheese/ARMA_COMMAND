// A3C_ai_shared_fnc_actionStaticWeaponPack

params ["_assemblingUnitSelection", "_weaponToDisassemble"];

{
	player groupSelectUnit [_x, false];
} forEach units player;

showCommandingMenu "";

A3C_UI_HUD_3D_TAG_ICON_TYPE = getText (
	configFile >> "CfgVehicles" >> typeOf _weaponToDisassemble >> "picture"
);

A3C_UI_HUD_3D_TAG_ICON_MOD = "OFF";
A3C_UI_HUD_3D_TAG_ICON_POS = +(position _weaponToDisassemble);

[
	+(position _weaponToDisassemble),
	""
] spawn A3C_UI_HUD_3D_TAG;

if (({ group _x == group player } count crew _weaponToDisassemble) > 0) then {
	{
		[[_x], A3C_ai_shared_fnc_unitGetOut] remoteExec ["BIS_fnc_call", _x];
	} forEach crew _weaponToDisassemble;

	sleep 1;
};

private _selectedTaskUnits = (
	[
		_assemblingUnitSelection,
		[],
		["DISASSEMBLE", _weaponToDisassemble],
		position _weaponToDisassemble,
		0,
		500
	] call A3C_ai_shared_fnc_staticWeaponPrepareDisassembly
) select 0;

if ((count _selectedTaskUnits) == 2) then {
	player groupRadio "SentDisAssemble";

	[_selectedTaskUnits, true, false] call A3C_ai_shared_fnc_cancelUnitPlot;

	private _mainMarker = "A3C_SQ_" + str (random 10000000000);
	private _weaponPos = position _weaponToDisassemble;

	{
		private _unit = _x;

		waitUntil {
			count (_unit getVariable "A3C_PLOT") == 0
		};

		private _plotData = [
			[
				[_weaponPos, _weaponPos getPos [50, 0]],
				[_mainMarker, "", ""],
				["STATIC", ["DISASSEMBLE", _weaponToDisassemble]],
				["NONE", "NONE"],
				["UP", "UP"],
				[[0, false]],
				false,
				0,
				-1,
				25,
				-1,
				0
			]
		];

		private _expectedDestination = [_unit] call A3C_ai_shared_fnc_setDestination;

		_unit setVariable ["A3C_PLOT", _plotData, true];

		[_unit] spawn {
			params ["_unit"];

			private _scriptHandle = [
				_unit,
				_unit getVariable "A3C_PLOT"
			] spawn A3C_ai_shared_fnc_actionExecuteUnitPlot;

			private _hasReached = false;
			private _exit = false;
			private _doReturnToOrders = true;

			while { alive _unit } do {
				if (animationState _unit == "ainvpknlmstpslaywrfldnon_medic") then {
					_hasReached = true;
				};

				if (scriptDone _scriptHandle) exitWith {};

				if (_hasReached) then {
					if (animationState _unit != "ainvpknlmstpslaywrfldnon_medic") then {
						sleep 3;

						_exit = true;

						if ((count (_unit getVariable "A3C_PLOT")) > 0) then {
							_doReturnToOrders = false;
						};
					};
				};

				if (_exit) exitWith {};

				sleep 1;
			};

			if (_doReturnToOrders) then {
				[_unit] call A3C_ai_squad_fnc_actionResumeDestination;
			};
		};
	} forEach _selectedTaskUnits;
};