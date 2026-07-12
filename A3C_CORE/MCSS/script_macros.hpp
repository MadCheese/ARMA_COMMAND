#define MCSS_QUOTE(var1) #var1
#define MCSS_EXPAND_AND_QUOTE(var1) MCSS_QUOTE(var1)

#define MCSS_DOUBLES(var1,var2) var1##_##var2
#define MCSS_TRIPLES(var1,var2,var3) var1##_##var2##_##var3

#define MCSS_FUNC(var1) MCSS_TRIPLES(MCSS,fnc,var1)
#define MCSS_QFUNC(var1) MCSS_EXPAND_AND_QUOTE(MCSS_FUNC(var1))

#define MCSS_FNCSCRIPT(var1) MCSS_DOUBLES(fnc,var1).sqf

// Register: MCSS_ROOT\functions\fnc_<name>.sqf
#define MCSS_PREP(var1) MCSS_FUNC(var1) = compile preprocessFileLineNumbers MCSS_EXPAND_AND_QUOTE(MCSS_ROOT\functions\MCSS_FNCSCRIPT(var1))

// Register: MCSS_ROOT\functions\<subdir>\fnc_<name>.sqf
#define MCSS_PREP_SUBDIR(subdir,var1) MCSS_FUNC(var1) = compile preprocessFileLineNumbers MCSS_EXPAND_AND_QUOTE(MCSS_ROOT\functions\subdir\MCSS_FNCSCRIPT(var1))