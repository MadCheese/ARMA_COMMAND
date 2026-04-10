{
	private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'AIC_fnc_executeCommandMenuAction'} else {_fnc_scriptName};
	private _fnc_scriptName = 'AIC_fnc_executeCommandMenuAction';
	scriptName _fnc_scriptName;

























































































































































































































































































































































params ["_groupControlId",["_actionIndex",-1]];

private ["_group","_actions","_handler","_params"];

_group = missionNamespace getVariable [format ["AIC_Group_Control_%1_Group",(_groupControlId)],nil];
_actions = missionNamespace getVariable ["AIC_Command_Actions",[]];

if(count _actions > _actionIndex && _actionIndex >= 0) then {
_handler = (_actions select _actionIndex) select 2;
_params = (_actions select _actionIndex) select 3;
_inputType = (_actions select _actionIndex) select 4;
if(_inputType == "NONE") then {
[_group,_groupControlId,_params] spawn _handler;
};
if(_inputType == "VEHICLE") then {
_commandControls = missionNamespace getVariable ["AIC_Command_Controls",[]];
{		
[_x,false] call AIC_fnc_setMapElementForeground;
[_x,false] call AIC_fnc_setMapElementEnabled;
} forEach _commandControls;
_inputControl = ["VEHICLE",[_groupControlId]] call AIC_fnc_createInputControl;
[_inputControl,true] call AIC_fnc_setMapElementVisible;
while{true} do {
_output = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
if(!isNil "_output") exitWith {};
sleep 0.1;
};
_selectedVehicle = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
[_inputControl] call AIC_fnc_deleteInputControl;
{		
[_x,true] call AIC_fnc_setMapElementForeground;
[_x,true] call AIC_fnc_setMapElementEnabled;
} forEach _commandControls;
[_group,_groupControlId,_selectedVehicle,_params] spawn _handler;
};
if(_inputType == "GROUP") then {
_groupControls = missionNamespace getVariable ["AIC_Group_Controls",[]];
{		
[_x,false] call AIC_fnc_setMapElementVisible;
[_x,false] call AIC_fnc_setMapElementForeground;
[_x,false] call AIC_fnc_setMapElementEnabled;
} forEach _groupControls;
[_groupControlId,true] call AIC_fnc_setMapElementVisible;
[_groupControlId,true] call AIC_fnc_setMapElementForeground;
[_groupControlId,false] call AIC_fnc_setMapElementEnabled;
_inputControl = ["GROUP",[_groupControlId]] call AIC_fnc_createInputControl;
[_inputControl,true] call AIC_fnc_setMapElementVisible;
while{true} do {
_output = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
if(!isNil "_output") exitWith {};
sleep 0.1;
};
_selectedGroup = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
[_inputControl] call AIC_fnc_deleteInputControl;
{		
[_x,true] call AIC_fnc_setMapElementVisible;
[_x,true] call AIC_fnc_setMapElementForeground;
[_x,true] call AIC_fnc_setMapElementEnabled;
} forEach _groupControls;
[_group,_groupControlId,_selectedGroup,_params] spawn _handler;
};
if(_inputType == "POSITION") then {
_commandControls = missionNamespace getVariable ["AIC_Command_Controls",[]];
{		
[_x,false] call AIC_fnc_setMapElementForeground;
[_x,false] call AIC_fnc_setMapElementEnabled;
} forEach _commandControls;
_inputControl = ["POSITION",[_groupControlId]] call AIC_fnc_createInputControl;
[_inputControl,true] call AIC_fnc_setMapElementVisible;
while{true} do {
_output = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
if(!isNil "_output") exitWith {};
sleep 0.1;
};
_selectedPosition = missionNamespace getVariable [format ["AIC_Input_Control_%1_Output",(_inputControl)],nil];
[_inputControl] call AIC_fnc_deleteInputControl;
{		
[_x,true] call AIC_fnc_setMapElementForeground;
[_x,true] call AIC_fnc_setMapElementEnabled;
} forEach _commandControls;
[_group,_groupControlId,_selectedPosition,_params] spawn _handler;
};
};}