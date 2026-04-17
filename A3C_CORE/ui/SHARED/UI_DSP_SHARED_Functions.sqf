A3C_UI_Shared_FNC_AddDownkey = {
	//-- purpose: exclude ALT from downkey collection in order to prevent lingering in A3C_UI_DOWNKEYS
	params ["_key"];
	if (_key != 56) then {
		A3C_UI_DOWNKEYS set [count A3C_UI_DOWNKEYS, _key];
	};
};


A3C_UI_Shared_shouldBlockKeyRepeat = {
	params ["_key"];
	private _blockKeyRepeat = true;
	if (
		(
			a3c_is_HC_remote
			&& {_key in [17,30,31,32,200,203,205,208]}
		)
		//-- Add || {} if more binds apply
	) then {
		 _blockKeyRepeat = false;
	};
	_blockKeyRepeat
};

