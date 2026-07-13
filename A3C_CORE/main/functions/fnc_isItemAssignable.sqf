// A3C_main_fnc_isItemAssignable

params ["_itemType"];

private _itemConfig = configFile >> "CfgWeapons" >> _itemType;
private _itemInfoConfig = _itemConfig >> "ItemInfo";

private _hasItemInfo = isClass _itemInfoConfig;
private _inventoryType = getNumber (_itemConfig >> "type");
private _inventoryValue = getNumber (_itemConfig >> "value");
private _itemInfoType = getNumber (_itemInfoConfig >> "type");

(
	_hasItemInfo &&
	{ _inventoryType in [131072, 4096] } &&
	{ _inventoryValue in [2, 5] } &&
	{ _itemInfoType in [0, 616] }
)