#define QUOTE(var1) #var1
#define EXPAND_AND_QUOTE(var1) QUOTE(var1)

#define DOUBLES(var1,var2) var1##_##var2
#define TRIPLES(var1,var2,var3) var1##_##var2##_##var3

#define ADDON DOUBLES(PREFIX,COMPONENT)

#define GVAR(var1) DOUBLES(ADDON,var1)
#define QGVAR(var1) EXPAND_AND_QUOTE(GVAR(var1))

#define FUNC(var1) TRIPLES(ADDON,fnc,var1)
#define QFUNC(var1) EXPAND_AND_QUOTE(FUNC(var1))

#define FNCSCRIPT(var1) DOUBLES(fnc,var1).sqf

// Register: COMPONENT_ROOT\functions\fnc_<name>.sqf
#define A3C_PREP(var1) FUNC(var1) = compile preprocessFileLineNumbers EXPAND_AND_QUOTE(COMPONENT_ROOT\functions\FNCSCRIPT(var1))

// Register: COMPONENT_ROOT\functions\<subdir>\fnc_<name>.sqf
#define A3C_PREP_SUBDIR(subdir,var1) FUNC(var1) = compile preprocessFileLineNumbers EXPAND_AND_QUOTE(COMPONENT_ROOT\functions\subdir\FNCSCRIPT(var1))