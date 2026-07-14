// A3C_UI_customFormation_fnc_getDirRange

#include "..\..\script_component.hpp"

private _playerDirection = getDir player;
private _formationDirection = A3C_UI_CustomFormation_formationDirection;

if (_playerDirection >= 180) then {
    _playerDirection = 360 - _playerDirection;
};

if (_formationDirection >= 180) then {
    _formationDirection = 360 - _formationDirection;
};

abs (_playerDirection - _formationDirection) < 20