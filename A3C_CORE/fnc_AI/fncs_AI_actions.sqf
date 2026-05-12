
//---------------------------------------------------------------------------------------------
//---------- ACTIONS: functions that make AI do stuff -----------------------------------------
//---------------------------------------------------------------------------------------------




A3C_AI_action_repairAnim = {
	params ["_unit"];
	if ( (_unit getVariable ["A3C_HandlerID_AnimDone", [false, -1]]) select 0) exitWith {};

	private _anims =
	[
		"Acts_carFixingWheel",
		"inbasemoves_assemblingvehicleerc",
		"inbasemoves_repairvehicleknl",
		"ainvpknlmstpslaywrfldnon_medic"
	];
	_anim = _anims call BIS_fnc_SelectRandom;
	[_unit,"ANIM"] remoteExec ["disableAI",0];
	[_unit,_anim] remoteExec ["switchMove",0];

	private _handler = _unit addEventHandler [ "AnimDone", {
		params[ "_unit", "_anim" ];
		if !( (_unit getVariable ["A3C_HandlerID_AnimDone", [false, -1]]) select 0) exitWith {};
		private _anims =
		[
			"Acts_carFixingWheel",
			"inbasemoves_assemblingvehicleerc",
			"inbasemoves_repairvehicleknl",
			"ainvpknlmstpslaywrfldnon_medic"
		];
		_anim = _anims call BIS_fnc_SelectRandom;
		[_unit,_anim] remoteExec ["switchMove",0];
	}];

	_unit setVariable ["A3C_HandlerID_AnimDone", [true, _handler], true];	
};





