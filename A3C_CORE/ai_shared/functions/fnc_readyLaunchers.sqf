// A3C_ai_shared_fnc_readyLaunchers

params ["_group"];

private _cfgWeapons = configFile >> "CfgWeapons";

private _launcherUnitsNotReady = (units _group) select {
    !isPlayer _x
    && {
        private _secondaryWeapon = secondaryWeapon _x;
        private _launcherState = _x weaponState _secondaryWeapon;

        _secondaryWeapon != ""
        && {
            _secondaryWeapon isKindOf [
                "Launcher",
                _cfgWeapons
            ]
        }
        && {
            [_secondaryWeapon] call
                A3C_main_fnc_isRHSdisposableLauncher
        }
        && {
            /*
             * An unused RHS disposable has a corresponding
             * weaponClass_used config class. The used launcher does not
             * have another weaponClass_used_used class.
             */
            isClass (
                _cfgWeapons
                >> (_secondaryWeapon + "_used")
            )
        }
        && {
            /*
             * Not readied: no magazine is loaded and ammunition is zero.
             */
            (_launcherState param [3, ""]) == ""
        }
        && {
            (_launcherState param [4, 0]) <= 0
        }
    }
};

if (_launcherUnitsNotReady isNotEqualTo []) then {
    {
        private _unit = _x;
        private _launcher = secondaryWeapon _unit;
        private _launcherState = _unit weaponState _launcher;
        private _launcherMuzzle = _launcherState param [
            1,
            _launcher
        ];

        if (_launcherMuzzle == "") then {
            _launcherMuzzle = _launcher;
        };

        private _compatibleMagazines = compatibleMagazines [
            _launcher,
            _launcherMuzzle
        ];

        if (_compatibleMagazines isEqualTo []) then {
            _compatibleMagazines = compatibleMagazines _launcher;
        };

        if (_compatibleMagazines isNotEqualTo []) then {
            /*
             * Do not add another integral magazine if one already exists
             * in the unit's inventory from an earlier preparation attempt.
             */
            private _hasCompatibleMagazine = (
                magazinesAmmoFull _unit
            ) findIf {
                ((_x param [0, ""]) in _compatibleMagazines)
                && {(_x param [1, 0]) > 0}
            } >= 0;

            if (!_hasCompatibleMagazine) then {
                private _launcherMagazine =
                    _compatibleMagazines select 0;

                _unit addMagazine _launcherMagazine;
            };

            /*
             * For the unprepared RHS disposable, this starts the
             * readiness gesture and loads its integral magazine.
             */
            _unit selectWeapon _launcherMuzzle;
        };
    } forEach _launcherUnitsNotReady;
};