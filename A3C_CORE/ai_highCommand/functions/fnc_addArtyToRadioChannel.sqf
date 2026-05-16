
// A3C_ai_highCommand_fnc_addArtyToRadioChannel

params ["_vehicle"];
private _commsOperator = gunner _vehicle;

if (
	!isNull _commsOperator
	&& {alive _commsOperator}
) then {
	//-- cheeky cheeky, if unit has no radio we give him one using magic ;)
	if ("ItemRadio" in assignedItems _commsOperator) then {
		_commsOperator addItem "itemRadio"; 
		_commsOperator assignItem "itemRadio";
	};

	A3C_CUSTOMRADIO_ID radioChannelAdd [player,_commsOperator];
	
};
