
class CfgPatches {
    class A3C_Compat_ACE_NLAW {
        name = "A3C - ACE NLAW Compatibility";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"ace_nlaw"};
        skipWhenMissingDependencies = 1;
    };
};

class CfgAmmo {
    class ammo_Penetrator_NLAW;

    class ACE_NLAW_Penetrator: ammo_Penetrator_NLAW {
        hit = 650;
    };
};
