// A3C_ui_shared_fnc_Tree_squad_getSubParentCount

params ["_treeControl", "_mainTreeIndex"];

private _parentCount = 0;
private _squadTreeCount = _treeControl tvCount [_mainTreeIndex];

for "_subTreeIndex" from 0 to (_squadTreeCount - 1) do {
	private _subTreeCount = _treeControl tvCount [
		_mainTreeIndex,
		_subTreeIndex
	];

	if (_subTreeCount > 0) then {
		_parentCount = _parentCount + 1;
	};
};

_parentCount