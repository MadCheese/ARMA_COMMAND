A3C_UI_CreateSafeEventHandler = {
	params [
		["_target", nil],
		["_idVarName", "", [""]],
		["_targetType", "", [""]],
		["_eventType", "", [""]],
		["_handlerCode", {}, [{}]]
	];

	_targetType = toLower _targetType;

	private _oldId = uiNamespace getVariable [_idVarName, -1];
	if (_oldId == -1) then {
		_oldId = missionNamespace getVariable [_idVarName, -1];
	};

	if (_oldId != -1) then {
		switch (_targetType) do {
			case "ctrl": {
				_target ctrlRemoveEventHandler [_eventType, _oldId];
			};
			case "display": {
				_target displayRemoveEventHandler [_eventType, _oldId];
			};
			default {
				throw format [
					"A3C_UI_CreateSafeEventHandler: invalid _targetType '%1' for '%2'",
					_targetType,
					_idVarName
				];
			};
		};
	};

	private _newId = switch (_targetType) do {
		case "ctrl": {
			_target ctrlAddEventHandler [_eventType, _handlerCode];
		};
		case "display": {
			_target displayAddEventHandler [_eventType, _handlerCode];
		};
		default {
			throw format [
				"A3C_UI_CreateSafeEventHandler: invalid _targetType '%1' for '%2'",
				_targetType,
				_idVarName
			];
		};
	};

	missionNamespace setVariable [_idVarName, _newId];
	uiNamespace setVariable [_idVarName, _newId];

	_newId
};

