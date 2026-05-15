// A3C_ai_highCommand_fnc_getConditionFromStatements

params ["_cond", "_timeOut"];

private _condLower = toLower _cond;
private _condMode = "";
private _condVal = "";

switch (true) do {
	case ("gocode" in _condLower): {
		_condMode = "GOCODE";

		_condVal = switch (true) do {
			case ("activate_a" in _condLower): {"A"};
			case ("activate_b" in _condLower): {"B"};
			case ("activate_c" in _condLower): {"C"};
			case ("activate_d" in _condLower): {"D"};
			default {""};
		};
	};

	case ("time" in _condLower): {
		if ("timeout" in _condLower) then {
			_condMode = "TIMEOUT";
			_condVal = _timeOut select 1;
		} else {
			_condMode = "DAYTIME";

			private _condParts = _condLower splitString """[],";
			private _timeParts = _condParts select {
				private _statementPart = _x;

				({
					typeName (call compile _x) == "SCALAR"
				} count (_statementPart splitString "")) == count _statementPart
			};

			_condVal = _timeParts joinString ":";
		};
	};
};

[_condMode, _condVal]