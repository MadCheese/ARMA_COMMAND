//-- needs Edit (except PREFIX)
#define PREFIX A3C
#define COMPONENT templateDialog
#define COMPONENT_BEAUTIFIED Template Dialog

//-- needs no edit
#define QUOTE(var1) #var1
#define DOUBLES(var1,var2) var1##_##var2
#define TRIPLES(var1,var2,var3) var1##_##var2##_##var3
#define QUADRUPLES(var1,var2,var3,var4) var1##_##var2##_##var3##_##var4

#define ADDON DOUBLES(PREFIX,COMPONENT)

#define GVAR(var1) DOUBLES(ADDON,var1)
#define QGVAR(var1) QUOTE(GVAR(var1))

#define FUNC(var1) TRIPLES(ADDON,fnc,var1)
#define QFUNC(var1) QUOTE(FUNC(var1))