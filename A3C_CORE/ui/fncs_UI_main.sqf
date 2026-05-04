
//---------------------------------------------------------------------------------------------
//---------- GETTERS --------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

A3C_UI_fnc_getKeybindTranslation = {
	//-- returns a readable string, ie "CTRL + SHIFT + F"
	params ["_addonID","_keyID"];
	_keyData = ([_addonID, _keyID] call CBA_fnc_getKeybind) select 5;
	_keyData params ["_key","_mods"];
	_mods params ["_shift","_ctrl","_alt"];
	private _returnString = "";
	private _modDetected = false;
	{
		if (_x) then {
			switch (_foreachIndex) do {
				case (0) : {
					_returnString = "SHIFT";
					_modDetected = true;
				};
				case (1) : {
					if (_modDetected) then {
						_returnString = _returnString + "+";
					};
					_returnString = _returnString + "CTRL";
					_modDetected = true;
				};
				case (2) : {
					if (_modDetected) then {
						_returnString = _returnString + "+ ";
					};
					_returnString = _returnString + "ALT";
					_modDetected = true;
				};
			};
		};
	} foreach _mods;
	if (_modDetected) then {
		_returnString = _returnString + "+";
	};
	_returnString = call compile format ["parseText '%1 %2'", _returnString, (keyName _key)];
	_returnString
};

//-- determine if keyBind returns true or false (overwrite yes or no)
A3C_UI_fnc_getKeyBool = {
	private ["_key","_modifiers","_return","_array"];
	_key = _this select 0;
	_modifiers = _this select 1;
	_return = false;

	if (_key in [71,72,73,75,76,77,79,80,81]) then {
		if (profileNameSpace getVariable "A3C_NUM_VAR") then {
			_return = true;
		};
	};

	if !(isnil "A3C_FORM_KEY_ID") then {
		if ( ([_key] + _modifiers) isEqualTo A3C_FORM_KEY_ID ) then {
			_return = true;
		};
	};

	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_REG_KEY_ID") ) then {
		if (count A3C_UI_squadPlacement_unitGhosts> 0 ) then {
			_return = true;
			[false,false] spawn A3C_UI_squadPlacement_fnc_executeOrder;

		} else {
			if (!isNull A3C_OBJECTPLACER) then {
				_return = true;
			};
		};
	};
	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_FW_KEY_ID") ) then {
		if (count A3C_UI_squadPlacement_unitGhosts> 0 ) then {
			_return = true;
			[false,true] spawn A3C_UI_squadPlacement_fnc_executeOrder;
			//systemchat 'fwd';
		};

	};
	if ( ([_key] + [_modifiers]) isEqualTo (profileNameSpace getVariable "A3C_ORDER_BW_KEY_ID") ) then {

		if (count A3C_UI_squadPlacement_unitGhosts> 0 ) then {
			//systemchat 'bwd';
			[true,false] spawn A3C_UI_squadPlacement_fnc_executeOrder;
		};
	};
	if (_key == 57) then {
		if (A3C_UI_HUD_3D_TAG_ICON_TYPE != "" OR {count A3C_UI_HUD_ASSIGNVEHICLE_OBJECTS > 0 OR {!isNull A3C_GTI_UNIT}}) then {
			_return = true;
		};
	};
	_return
};


//---------------------------------------------------------------------------------------------
//---------- Setters --------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

A3C_UI_fnc_setOpacity = {
	//-- fnc for map UI to add correct opacity to color array
	params ["_colorArray","_opacity"];
	_colorArray set [3,_opacity];
	_colorArray
};







//---------------------------------------------------------------------------------------------
//---------- Predicates ('is x') --------------------------------------------------------------
//---------------------------------------------------------------------------------------------


//---------- State predicates

//---------- Posession predicates

//---------- Ability predicates

//---------------------------------------------------------------------------------------------
//---------- Generators ----------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

