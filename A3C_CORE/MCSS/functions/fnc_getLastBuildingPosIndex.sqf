// MCSS_fnc_getLastBuildingPosIndex
// Get the highest available building position index.

params ["_building"];

private _buildingPosIndex = 0;

while { !((_building buildingPos _buildingPosIndex) isEqualTo [0, 0, 0]) } do {
	_buildingPosIndex = _buildingPosIndex + 1;
};

_buildingPosIndex = _buildingPosIndex - 1;

_buildingPosIndex