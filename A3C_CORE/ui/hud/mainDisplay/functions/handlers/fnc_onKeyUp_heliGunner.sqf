// A3C_UI_mainDisplay_fnc_onKeyUp_heliGunner

/*
	Finalizes helicopter collective input after the player releases a
	collective-control key.

	Once the helicopter's vertical movement has settled, its current ATL
	height becomes the AI pilot's new commanded flight height.

	A per-vehicle token invalidates older release workers when a newer
	collective-release event is processed.

	Returns false because the KeyUp event is not consumed.
*/
params [
	["_display", displayNull, [displayNull]],
	["_key", -1, [0]],
	["_shift", false, [false]],
	["_ctrl", false, [false]],
	["_alt", false, [false]]
];

private _isCollectiveRaise =
	inputAction "HeliCollectiveRaise" > 0;

private _isCollectiveLower =
	inputAction "HeliCollectiveLower" > 0;

if (
	!_isCollectiveRaise
	&& {!_isCollectiveLower}
) exitWith {
	false
};

private _helicopter = vehicle player;

if (
	isNull _helicopter
	|| {!alive _helicopter}
) exitWith {
	false
};

[
	[
		_helicopter
	],
	{
		params [
			["_helicopter", objNull, [objNull]]
		];

		if (
			isNull _helicopter
			|| {!alive _helicopter}
		) exitWith {};

		private _releaseToken = (
			_helicopter getVariable [
				"A3C_collectiveReleaseToken",
				0
			]
		) + 1;

		_helicopter setVariable [
			"A3C_collectiveReleaseToken",
			_releaseToken
		];

		[
			_helicopter,
			_releaseToken
		] spawn {
			params [
				["_helicopter", objNull, [objNull]],
				["_releaseToken", -1, [0]]
			];

			waitUntil {
				sleep 0.05;

				isNull _helicopter
				|| {!alive _helicopter}
				|| {!local _helicopter}
				|| {
					(
						_helicopter getVariable [
							"A3C_collectiveReleaseToken",
							-1
						]
					) != _releaseToken
				}
				|| {
					abs (
						velocity _helicopter select 2
					) < 1
				}
			};

			if (
				!isNull _helicopter
				&& {alive _helicopter}
				&& {local _helicopter}
				&& {
					(
						_helicopter getVariable [
							"A3C_collectiveReleaseToken",
							-1
						]
					) == _releaseToken
				}
			) then {
				_helicopter flyInHeight (
					getPosATL _helicopter select 2
				);

				_helicopter setVariable [
					"A3C_collectiveReleaseToken",
					nil
				];
			};
		};
	}
] remoteExec [
	"BIS_fnc_call",
	_helicopter
];

false