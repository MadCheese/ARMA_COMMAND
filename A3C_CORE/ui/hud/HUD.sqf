
if (isDedicated) exitWith {};





//--------------------------------------  H U D   M O D E   F U N C T I O N S  ------------------------------------
//-----------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------




//A3C_HUD_OBJECTS

//-----------------------------  U I  -  F U N C T I O N S  ------------------------------------
//----------------------------------------------------------------------------------------------

{[_x] call A3C_UI_squadPlacement_fnc_setStance} foreach [0,1];


A3C_SWITCHSTANCE = {
	private ["_units","_mode","_unitNames","_stmnt","_snt"];
	_units = _this select 0;
	_mode = _this select 1;
	//_unitNames = "";
	_stmnt = "";
	_snt = "";
	switch (_mode) do {
		case ("AUTO") : {
			_stmnt = "SentBehaviourSafe";
			_snt = "A3C_RELAX";
		};
		case ("DOWN") : {
			_stmnt = "SentUnitPosDown";
			_snt = "A3C_STAYDOWN";
		};
		case ("MIDDLE") : {
			_stmnt = "SentUnitPosMiddle";
			_snt = "A3C_StayLow";
		};
		case ("UP") : {
			_stmnt = "SentUnitPosUp";
			_snt = "A3C_OYF";
		};
	};
	{
		//-- spawn unitpos to add random delay to each unit (anti robot feel)
		[_x,_mode] spawn {
			params ["_u","_mode"];
			sleep (random 1.5);
			_u setunitPos _mode;
		};
	//	_unitNames = _unitNames + ([_x,1] call MCSS_fnc_NAMESTRING);
	} foreach _units;
	player groupRadio _stmnt;
	//if !(_snt == "") then {player  _snt};
};



