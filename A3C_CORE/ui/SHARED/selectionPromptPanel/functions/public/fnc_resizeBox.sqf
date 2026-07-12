// A3C_ui_selectionPromptPanel_fnc_resizeBox

params ["_parent", "_listBox", "_amount"];

private _boxHeight = (((safeZoneW / safeZoneH) min 1.2) / 30) * (_amount + 1);

if (!isNull _parent) then {
	private _parentPos = ctrlPosition _parent;

	_parent ctrlSetPosition [
		0.383108 * safeZoneW + safeZoneX,
		0.378986 * safeZoneH + safeZoneY,
		_parentPos select 2,
		(0.0440051 * safeZoneH) + _boxHeight
	];

	_parent ctrlCommit 0;
};

if (!isNull _listBox) then {
	private _listBoxPos = ctrlPosition _listBox;

	_listBox ctrlSetPosition [
		_listBoxPos select 0,
		_listBoxPos select 1,
		_listBoxPos select 2,
		_boxHeight
	];

	_listBox ctrlCommit 0;
};